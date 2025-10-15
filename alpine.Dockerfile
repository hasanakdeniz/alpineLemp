FROM alpine:3.22
RUN apk add update && apk add --no-cache nano mysql-client
ENTRYPOINT ["mysql"]
