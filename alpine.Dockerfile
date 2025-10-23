FROM alpine:latest

RUN apk update && apk add --no-cache nginx
RUN rm -f /etc/nginx/http.d/default.conf

RUN echo 'server { listen 80; listen [::]:80; root /home/alpine/www; index index.html index.htm; location / { try_files $uri $uri/ =404; } }' > /etc/nginx/http.d/default.conf

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
