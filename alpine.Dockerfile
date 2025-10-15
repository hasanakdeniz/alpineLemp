FROM alpine:3.22
RUN apk add --no-cache update nano mysql-client
ENTRYPOINT ["mysql"]
