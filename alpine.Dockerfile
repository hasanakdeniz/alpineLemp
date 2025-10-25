FROM alpine:latest

# Kurulum ve Temizlik
RUN apk update \
    && apk add --no-cache bash nano nginx php php-fpm php-mysqli **openssh** **openssh-sftp-server** \
    && rm -rf /etc/nginx/http.d/default.conf \
    && mkdir -p /home/alpine/www \
    && echo '<?php phpinfo(); ?>' > /home/alpine/www/index.php \
    # SSH Sunucusu Ayarları
    && ssh-keygen -A \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config \
    && adduser -D **alpineuser** \
    && echo "**alpineuser:sifre**" | chpasswd

# Nginx Yapılandırması
RUN echo 'server { listen 80; listen [::]:80; root /home/alpine/www; index index.html index.php index.htm; location / { try_files $uri $uri/ =404; }    location ~ \.php$ { fastcgi_pass 127.0.0.1:9000; fastcgi_index index.php; include fastcgi.conf; } }' > /etc/nginx/http.d/default.conf

EXPOSE 80 443 **22**

WORKDIR /home/alpine/www

# Başlatma Komutu
CMD **/usr/sbin/sshd &&** php-fpm83 && nginx -g 'daemon off;'
