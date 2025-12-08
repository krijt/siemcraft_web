FROM nginx:1.27-alpine

RUN apk add --no-cache certbot openssl \
  && mkdir -p /var/www/certbot /etc/nginx/ssl

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENV DOMAIN=siemcraft.verkeerd-verbonden.nl

EXPOSE 80 443

ENTRYPOINT ["/docker-entrypoint.sh"]
