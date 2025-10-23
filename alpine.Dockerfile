FROM alpine:latest

RUN apk update && apk add --no-cache bash nano nginx \
    && rm -f /etc/nginx/http.d/default.conf \
    && mkdir -p /home/alpine/www \
    && echo 'merhaba' > /home/alpine/www/index.html

RUN echo 'server { listen 80; listen [::]:80; root /home/alpine/www; index index.html index.htm; location / { try_files $uri $uri/ =404; } }' > /etc/nginx/http.d/default.conf

EXPOSE 80 443

CMD sh -c "nginx -g 'daemon off;'"
