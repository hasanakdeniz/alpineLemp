FROM alpine:latest
ARG SFTP_USER=SFTP_USER
ARG SFTP_PASSWORD=SFTP_PASSWORD

RUN apk update && apk add --no-cache bash nano nginx php php-fpm php-mysqli openssh openssh-sftp-server \
    && adduser -D -g 'www' --no-create-home www \
    && rm -rf /etc/nginx/http.d/default.conf \
    && mkdir -p /home/alpine/www/upload \
    && echo '<?php phpinfo(); ?>' > /home/alpine/www/index.php \
    && ssh-keygen -A

RUN adduser -D -s /bin/false --no-create-home ${SFTP_USER}
RUN echo "${SFTP_USER}:${SFTP_PASSWORD}" | chpasswd

# SSHD Yapılandırması:
RUN echo "Subsystem sftp internal-sftp" > /etc/ssh/sshd_config \
    && echo "PermitRootLogin no" >> /etc/ssh/sshd_config \
    && echo "Port 22" >> /etc/ssh/sshd_config \
    && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
    && echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config \
    && echo "X11Forwarding no" >> /etc/ssh/sshd_config \
    && echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config \
    && echo "" >> /etc/ssh/sshd_config \
    && echo "Match User ${SFTP_USER}" >> /etc/ssh/sshd_config \
    && echo " ChrootDirectory /home/alpine/www" >> /etc/ssh/sshd_config \
    && echo " ForceCommand internal-sftp" >> /etc/ssh/sshd_config \
    && echo " AllowTcpForwarding no" >> /etc/ssh/sshd_config \
    && echo " X11Forwarding no" >> /etc/ssh/sshd_config \
    && echo " PermitTunnel no" >> /etc/ssh/sshd_config

RUN echo 'server { listen 80; listen [::]:80; root /home/alpine/www; index index.html index.php index.htm; location / { try_files $uri $uri/ =404; }    location ~ \.php$ { fastcgi_pass 127.0.0.1:9000; fastcgi_index index.php; include fastcgi.conf; } }' > /etc/nginx/http.d/default.conf

# CHROOT GEREKSİNİMİ: /home/alpine/www'nin sahibi root olmalı.
RUN chown root:root /home/alpine/www \
    && chmod 755 /home/alpine/www

EXPOSE 80 443 22

WORKDIR /home/alpine/www

# CMD Komutunda İzinleri Ayarlama:
# 1. Nginx ve PHP-FPM için izinler (www:www)
# 2. SFTP kullanıcısının yazabileceği ALT KLASÖR'e (${SFTP_USER}) izin verme
CMD sh -c "chown -R www:www /var/lib/nginx \
    && chown -R www:www /home/alpine/www \
    && chown ${SFTP_USER}:${SFTP_USER} /home/alpine/www/upload \
    && chmod 775 /home/alpine/www/upload \
    && /usr/sbin/sshd -D -e & php-fpm83 && nginx -g 'daemon off;'"
