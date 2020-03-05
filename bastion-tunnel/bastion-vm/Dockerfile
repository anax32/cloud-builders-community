# https://cloud.google.com/solutions/creating-kubernetes-engine-private-clusters-with-net-proxies#creating_the_docker_image
# thanks for all your hard work guys, appreciate it
FROM alpine

# FIXME: what's going on with the directory moves?
RUN apk add -U \
      curl \
      jq \
      privoxy \
    && \
    mv /etc/privoxy/templates /etc/privoxy-templates && \
    rm -rf /var/cache/apk/* /etc/privoxy/* && \
    mv /etc/privoxy-templates /etc/privoxy/templates

ADD --chown=privoxy:privoxy config /etc/privoxy/
ADD --chown=privoxy:privoxy k8s-only.action /etc/privoxy/
ADD --chown=privoxy:privoxy k8s-rewrite-internal.filter /etc/privoxy/

ADD k8s-api-proxy.sh /usr/local/bin/

EXPOSE 8118/tcp

ENTRYPOINT ["./k8s-api-proxy.sh"]
