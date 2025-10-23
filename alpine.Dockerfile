FROM alpine:latest

# Kurulum, kullanıcı oluşturma, izinleri ayarlama, PHP-FPM konfigürasyonu ve test dosyası oluşturma
RUN apk update && apk add --no-cache bash nano nginx \
    php8-fpm php8-cli php8-opcache php8-json php8-curl php8-mbstring php8-xml php8-mysqli php8-gd php8-zlib \
    && adduser -D -g 'www' www \
    && rm -f /etc/nginx/http.d/default.conf \
    && mkdir -p /home/alpine/www \
    && chown -R www:www /var/lib/nginx \
    && chown -R www:www /home/alpine/www \
    && echo '<h1>PHP Nginx Calisiyor!</h1><?php phpinfo();' > /home/alpine/www/index.php \
    && sed -i '1iuser www www;' /etc/nginx/nginx.conf \
    # PHP-FPM'i TCP port 9000'de dinlemesi için ayarla (Düzeltildi)
    && sed -i 's#listen = /var/run/php-fpm.sock#listen = 9000#g' /etc/php8/php-fpm.d/www.conf

# PHP destekli Nginx konfigürasyonunu yazar
RUN echo 'server { listen 80; listen [::]:80; root /home/alpine/www; index index.php index.html index.htm; location / { try_files $uri $uri/ =404; } location ~ \.php$ { try_files $uri =404; fastcgi_split_path_info ^(.+\.php)(/.+)$; fastcgi_pass 127.0.0.1:9000; fastcgi_index index.php; include fastcgi.conf; } }' > /etc/nginx/http.d/default.conf

EXPOSE 80 443

# Hem PHP-FPM'i hem de Nginx'i arka planda başlatır
CMD sh -c "php-fpm8 && nginx -g 'daemon off;'"
