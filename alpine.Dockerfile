FROM alpine:latest
RUN apk update && apk add --no-cache nano nginx
EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
