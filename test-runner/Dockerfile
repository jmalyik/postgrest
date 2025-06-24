FROM alpine:3.19
RUN apk add --no-cache curl jq bash
WORKDIR /usr/src/app
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
CMD ["/usr/src/app/entrypoint.sh"]
