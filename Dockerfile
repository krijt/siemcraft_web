FROM nginx:1.26-alpine

RUN apk add --no-cache certbot openssl nginx-mod-http-fancyindex \
  && mkdir -p /var/www/certbot /etc/nginx/ssl \
  && sed -i '1iload_module /usr/lib/nginx/modules/ngx_http_fancyindex_module.so;' /etc/nginx/nginx.conf

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY index.html /usr/share/nginx/html/index.html
COPY assets /usr/share/nginx/html/assets
RUN chmod +x /docker-entrypoint.sh

ENV DOMAIN=siemcraft.verkeerd-verbonden.nl

EXPOSE 80 5443

ENTRYPOINT ["/docker-entrypoint.sh"]
