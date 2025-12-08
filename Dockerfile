FROM nginx:1.27-alpine

RUN apk add --no-cache certbot openssl \
  && mkdir -p /var/www/certbot /etc/nginx/ssl

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY index.html /usr/share/nginx/html/index.html
COPY assets /usr/share/nginx/html/assets
RUN chmod +x /docker-entrypoint.sh

ENV DOMAIN=siemcraft.verkeerd-verbonden.nl

EXPOSE 80 5443

ENTRYPOINT ["/docker-entrypoint.sh"]
