FROM alpine:latest

RUN apk update && apk add --no-cache bash nano nginx php php-fpm php-mysqli \
    && adduser -D -g 'www' www \
    && rm -rf /etc/nginx/http.d/default.conf \
    && mkdir -p /home/alpine/www \
    && chown -R www:www /var/lib/nginx \
    && chown -R www:www /home/alpine/www \
    && chmod -R 777 /home/alpine/www \
    && echo '<?php phpinfo(); ?>' > /home/alpine/www/index.php

RUN echo 'server { listen 80; listen [::]:80; root /home/alpine/www; index index.html index.php index.htm; location / { try_files $uri $uri/ =404; }   location ~ \.php$ { fastcgi_pass 127.0.0.1:9000; fastcgi_index index.php; include fastcgi.conf; } }' > /etc/nginx/http.d/default.conf

EXPOSE 80 443
