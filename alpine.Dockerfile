FROM alpine:latest

# 1. Paket Kurulumu, Kullanıcı ve İzinler
RUN apk update && apk add --no-cache bash nano nginx \
    php8-fpm php8-cli php8-opcache php8-json php8-curl php8-mbstring php8-xml php8-mysqli php8-gd php8-zlib \
    && adduser -D -g 'www' www \
    && rm -f /etc/nginx/http.d/default.conf \
    && mkdir -p /home/alpine/www \
    && chown -R www:www /var/lib/nginx \
    && chown -R www:www /home/alpine/www \
    && echo '<h1>PHP Nginx Calisiyor!</h1><?php phpinfo();' > /home/alpine/www/index.php \
    && sed -i '1iuser www www;' /etc/nginx/nginx.conf \
    # Mevcut www.conf'u silmek yerine, üzerine yeni bir tane yazarız.
    && rm -f /etc/php8/php-fpm.d/www.conf

# 2. PHP-FPM TCP Konfigürasyonunu Yazar
RUN echo "[www]\n\
user = www\n\
group = www\n\
listen = 9000\n\
pm = dynamic\n\
pm.max_children = 5\n\
pm.start_servers = 2\n\
pm.min_spare_servers = 1\n\
pm.max_spare_servers = 3\n\
chdir = /" > /etc/php8/php-fpm.d/www.conf

# 3. PHP Destekli Nginx Konfigürasyonunu Yazar
RUN echo 'server { listen 80; listen [::]:80; root /home/alpine/www; index index.php index.html index.htm; location / { try_files $uri $uri/ =404; } location ~ \.php$ { try_files $uri =404; fastcgi_split_path_info ^(.+\.php)(/.+)$; fastcgi_pass 127.0.0.1:9000; fastcgi_index index.php; include fastcgi.conf; } }' > /etc/nginx/http.d/default.conf

EXPOSE 80 443

# Hem PHP-FPM'i hem de Nginx'i arka planda başlatır
CMD sh -c "php-fpm8 && nginx -g 'daemon off;'"
