FROM alpine:latest
ARG SFTP_USER=webuser
ARG SFTP_PASSWORD=securepassword
ARG PHP_VERSION=83

RUN apk update \
    && apk add --no-cache \
        bash \
        nano \
        nginx \
        php${PHP_VERSION}-fpm \
        php${PHP_VERSION}-mysqli \
        openssh \
        shadow \
    && rm -rf /var/cache/apk/* \
    && ssh-keygen -A \
    && rm -f /etc/nginx/conf.d/default.conf \
    && mkdir -p /home/alpine/www/uploads \
    && echo '<?php phpinfo(); ?>' > /home/alpine/www/index.php

RUN adduser -D -s /sbin/nologin --no-create-home ${SFTP_USER} \
    && echo "${SFTP_USER}:${SFTP_PASSWORD}" | chpasswd

RUN chown root:root /home/alpine \
    && chown root:root /home/alpine/www \
    && chmod 755 /home/alpine \
    && chmod 755 /home/alpine/www \
    && chown ${SFTP_USER}:${SFTP_USER} /home/alpine/www/uploads \
    && chmod 775 /home/alpine/www/uploads

RUN sed -i 's/Subsystem sftp.*/Subsystem sftp internal-sftp/g' /etc/ssh/sshd_config \
    && echo "PermitRootLogin no" >> /etc/ssh/sshd_config \
    && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
    && echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config \
    && echo "" >> /etc/ssh/sshd_config \
    && echo "Match User ${SFTP_USER}" >> /etc/ssh/sshd_config \
    && echo "    ChrootDirectory /home/alpine/www" >> /etc/ssh/sshd_config \
    && echo "    ForceCommand internal-sftp" >> /etc/ssh/sshd_config \
    && echo "    AllowTcpForwarding no" >> /etc/ssh/sshd_config \
    && echo "    X11Forwarding no" >> /etc/ssh/sshd_config

RUN echo "server { \
    listen 80; \
    root /home/alpine/www; \
    index index.html index.php; \
    location / { \
        try_files \$uri \$uri/ =404; \
    } \
    location ~ \.php$ { \
        fastcgi_pass unix:/var/run/php${PHP_VERSION}-fpm/php${PHP_VERSION}-fpm.sock; \
        fastcgi_index index.php; \
        include fastcgi.conf; \
    } \
}" > /etc/nginx/http.d/default.conf

RUN sed -i 's/user = nobody/user = nginx/g' /etc/php${PHP_VERSION}/php-fpm.d/www.conf \
    && sed -i 's/group = nobody/group = nginx/g' /etc/php${PHP_VERSION}/php-fpm.d/www.conf

EXPOSE 80 22

WORKDIR /home/alpine/www

CMD sh -c "/usr/sbin/sshd && php-fpm${PHP_VERSION} -F && nginx -g 'daemon off;'"
