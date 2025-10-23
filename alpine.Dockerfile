FROM alpine:latest

RUN apk update && apk add --no-cache bash nano openrc nginx php php-fpm \
    && adduser -D -g 'www' www \
    && rm -f /etc/nginx/http.d/default.conf \
    && mkdir -p /home/alpine/www \
    && chown -R www:www /var/lib/nginx \
    && chown -R www:www /home/alpine/www \
    && echo 'merhaba' > /home/alpine/www/index.html

RUN echo 'server { listen 80; listen [::]:80; root /home/alpine/www; index index.html index.php index.htm; location / { try_files $uri $uri/ =404; }   location ~ \.php$ { fastcgi_pass 127.0.0.1:9000; fastcgi_index index.php; include fastcgi.conf; } }' > /etc/nginx/http.d/default.conf

EXPOSE 80 443

CMD sh -c "php-fpm83 && nginx -g 'daemon off;'"
