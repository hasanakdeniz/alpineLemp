FROM alpine:latest

RUN apk update && apk add --no-cache nginx php-fpm php-cli php-opcache php-json php-curl php-mbstring php-xml php-mysqli \
    && rm -f /etc/nginx/http.d/default.conf \
    && mkdir -p /home/alpine/www \
    && sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php/php-fpm.d/www.conf \
    && echo '<?php phpinfo();' > /home/alpine/www/index.php

RUN echo 'server { listen 80; listen [::]:80; root /home/alpine/www; index index.php index.html index.htm; location / { try_files $uri $uri/ =404; } location ~ \.php$ { try_files $uri =404; fastcgi_split_path_info ^(.+\.php)(/.+)$; fastcgi_pass 127.0.0.1:9000; fastcgi_index index.php; include fastcgi.conf; } }' > /etc/nginx/http.d/default.conf

EXPOSE 80 443

CMD sh -c "php-fpm && nginx -g 'daemon off;'"
