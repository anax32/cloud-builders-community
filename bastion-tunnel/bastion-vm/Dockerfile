# https://cloud.google.com/solutions/creating-kubernetes-engine-private-clusters-with-net-proxies#creating_the_docker_image
# thanks for all your hard work guys, appreciate it
FROM alpine

# FIXME: what's going on with the directory moves?
RUN apk add -U \
      privoxy

ADD --chown=privoxy:privoxy config /etc/privoxy/

EXPOSE 8118/tcp

ENTRYPOINT ["privoxy"]

CMD ["--no-daemon", "/etc/privoxy/config"]
