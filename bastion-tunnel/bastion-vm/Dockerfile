FROM alpine

# FIXME: what's going on with the directory moves?
RUN apk add -U \
      privoxy

ADD --chown=privoxy:privoxy config /etc/privoxy/

EXPOSE 8118/tcp

ENTRYPOINT ["privoxy"]

CMD ["--no-daemon", "/etc/privoxy/config"]
