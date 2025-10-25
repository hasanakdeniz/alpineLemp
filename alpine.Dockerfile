FROM alpine:latest

RUN apk update && apk add --no-cache bash nano nginx php php-fpm php-mysqli openssh openssh-sftp-server openssh-server-pam \
    && rm -rf /etc/nginx/http.d/default.conf \
    && mkdir -p /home/alpine/www \
    && echo '<?php phpinfo(); ?>' > /home/alpine/www/index.php \
    && ssh-keygen -A \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config \
    && sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config \
    && adduser -D test\
    && echo "test:test" | chpasswd \
    && sed -i '/^Subsystem sftp/c\Subsystem sftp internal-sftp' /etc/ssh/sshd_config \
    && echo "Match User test" >> /etc/ssh/sshd_config \
    && echo "  ChrootDirectory /home/alpine/www" >> /etc/ssh/sshd_config \
    && echo "  ForceCommand internal-sftp" >> /etc/ssh/sshd_config \
    && chown root:root /home/alpine/www \
    && chmod 755 /home/alpine/www

RUN echo 'server { listen 80; listen [::]:80; root /home/alpine/www; index index.html index.php index.htm; location / { try_files $uri $uri/ =404; }    location ~ \.php$ { fastcgi_pass 127.0.0.1:9000; fastcgi_index index.php; include fastcgi.conf; } }' > /etc/nginx/http.d/default.conf

EXPOSE 80 443 2222

WORKDIR /home/alpine/www

CMD /usr/sbin/sshd -D -e & php-fpm83 && nginx -g 'daemon off;'
