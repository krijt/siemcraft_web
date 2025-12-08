#!/bin/sh
set -eu

DOMAIN="${DOMAIN:-siemcraft.verkeerd-verbonden.nl}"
EMAIL="${LETSENCRYPT_EMAIL:-}"
STAGING="${LETSENCRYPT_STAGING:-0}"

WEBROOT=/var/www/certbot
LE_LIVE_DIR="/etc/letsencrypt/live/${DOMAIN}"
NGINX_CERT=/etc/nginx/ssl/server.crt
NGINX_KEY=/etc/nginx/ssl/server.key
SELF_CERT=/etc/nginx/ssl/selfsigned.crt
SELF_KEY=/etc/nginx/ssl/selfsigned.key

ensure_self_signed() {
  if [ ! -f "${SELF_CERT}" ] || [ ! -f "${SELF_KEY}" ]; then
    openssl req -x509 -nodes -newkey rsa:2048 -days 7 \
      -keyout "${SELF_KEY}" \
      -out "${SELF_CERT}" \
      -subj "/CN=${DOMAIN}"
  fi

  ln -sf "${SELF_CERT}" "${NGINX_CERT}"
  ln -sf "${SELF_KEY}" "${NGINX_KEY}"
}

try_issue_cert() {
  if [ -z "${EMAIL}" ]; then
    echo "LETSENCRYPT_EMAIL not set; keeping self-signed certificate." >&2
    return
  fi

  certbot_opts="--webroot -w ${WEBROOT} -d ${DOMAIN} --email ${EMAIL} --agree-tos --non-interactive --rsa-key-size 4096 --keep-until-expiring"
  if [ "${STAGING}" = "1" ]; then
    certbot_opts="${certbot_opts} --staging"
  fi

  if certbot certonly ${certbot_opts}; then
    ln -sf "${LE_LIVE_DIR}/fullchain.pem" "${NGINX_CERT}"
    ln -sf "${LE_LIVE_DIR}/privkey.pem" "${NGINX_KEY}"
    nginx -s reload 2>/dev/null || true
  else
    echo "Certbot failed; continuing with existing certificates." >&2
  fi
}

prepare_cron() {
  echo "0 3 * * * certbot renew --quiet --post-hook \"nginx -s reload\"" > /etc/crontabs/root
  crond -l 2 -b
}

mkdir -p "${WEBROOT}" /etc/letsencrypt/live "${LE_LIVE_DIR}" /etc/nginx/ssl

if [ ! -f "${LE_LIVE_DIR}/fullchain.pem" ] || [ ! -f "${LE_LIVE_DIR}/privkey.pem" ]; then
  ensure_self_signed
else
  ln -sf "${LE_LIVE_DIR}/fullchain.pem" "${NGINX_CERT}"
  ln -sf "${LE_LIVE_DIR}/privkey.pem" "${NGINX_KEY}"
fi

nginx -g 'daemon on;'
try_issue_cert
prepare_cron
nginx -s quit

exec nginx -g 'daemon off;'
