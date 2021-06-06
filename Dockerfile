FROM alpine
RUN apk update && apk add rsync openssh
COPY . /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]