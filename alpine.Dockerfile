FROM alpine:latest

RUN apk update && apk add --no-cache bash nano nginx
RUN rm -f /etc/nginx/http.d/default.conf

RUN echo 'server { listen 80; listen [::]:80; root /home/alpine/www; index index.php index.html index.htm; location / { try_files $uri $uri/ =404; } }' > /etc/nginx/http.d/default.conf
RUN mkdir -p /home/alpine/www
RUN echo 'merhaba' > /home/alpine/www/index.php

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
