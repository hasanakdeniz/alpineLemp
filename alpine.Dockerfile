FROM alpine:latest
ARG SFTP_USER=SFTP_USER
ARG SFTP_PASSWORD=SFTP_PASSWORD

RUN apk update && apk add --no-cache bash nano nginx php php-fpm php-mysqli openssh \
    && adduser -D -g 'www' --no-create-home www \
    && rm -rf /etc/nginx/http.d/default.conf \
    && mkdir -p /home/alpine/www \
    && echo '<?php phpinfo(); ?>' > /home/alpine/www/index.php \
    && ssh-keygen -A

RUN adduser -D -s /bin/bash --no-create-home ${SFTP_USER}
RUN echo "${SFTP_USER}:${SFTP_PASSWORD}" | chpasswd

RUN echo "Subsystem sftp /usr/lib/ssh/sftp-server" >> /etc/ssh/sshd_config \
    && echo "ChrootDirectory /home/alpine/www" >> /etc/ssh/sshd_config \
    && echo "PermitRootLogin no" >> /etc/ssh/sshd_config \
    && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
    && echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config \
    && echo "X11Forwarding no" >> /etc/ssh/sshd_config \
    && echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config \
    && echo "Subsystem sftp internal-sftp" >> /etc/ssh/sshd_config

RUN echo 'server { listen 80; listen [::]:80; root /home/alpine/www; index index.html index.php index.htm; location / { try_files $uri $uri/ =404; }   location ~ \.php$ { fastcgi_pass 127.0.0.1:9000; fastcgi_index index.php; include fastcgi.conf; } }' > /etc/nginx/http.d/default.conf

RUN chown root:root /home/alpine/www \
    && chmod 755 /home/alpine/www

EXPOSE 80 443 22

WORKDIR /home/alpine/www

CMD sh -c "chown -R www:www /var/lib/nginx && chown -R www:www /home/alpine/www && chmod -R 777 /home/alpine/www && /usr/sbin/sshd && php-fpm83 && nginx -g 'daemon off;'"
