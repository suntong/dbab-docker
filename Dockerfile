FROM alpine:latest

MAINTAINER Tong Sun (https://github.com/suntong/)

#set enviromental values for certificate CA generation
ENV CN=squid.local \
 O=squid \
 OU=squid \
 C=US \
 SQUID_HTTP_PORT="3128" \
 SQUID_HTTPS_PORT="4128" \
 SQUID_CACHE_DIR="/var/cache/squid" \
 SQUID_CERT_DIR="/etc/squid/cert" \
 CMD_ENTRY="/usr/local/bin/docker-entrypoint.sh" \
 CMD_START="/usr/local/bin/start.sh" \
 X=X

#set proxies for alpine apk package manager
ARG all_proxy
ARG NAME="docker-squid-alpine"
ARG DESCRIPTION="Squid Proxy with SSL bump support"

LABEL name="$NAME" \
 version="$VERSION" \
 architecture="amd64" \
 description="$DESCRIPTION" \
 org.label-schema.description="$DESCRIPTION" \
 org.label-schema.name="$NAME"

VOLUME ["$SQUID_CACHE_DIR", "$SQUID_CERT_DIR"]

EXPOSE $SQUID_HTTP_PORT/tcp $SQUID_HTTPS_PORT/tcp

HEALTHCHECK CMD /bin/true || exit 1

ENV http_proxy=$all_proxy \
 https_proxy=$all_proxy

RUN apk add --no-cache \
  squid \
  openssl \
  ca-certificates \
 && update-ca-certificates \
 && rm -rf /var/cache/apk/* \
 && mkdir -vp /etc/squid/cert/ \
 && chown -R squid:squid /etc/squid/cert/ \
 && true

#COPY openssl.cnf.add /etc/ssl
#COPY conf/squid*.conf /etc/squid/
#RUN cat /etc/ssl/openssl.cnf.add >> /etc/ssl/openssl.cnf

COPY cmd/*.sh /usr/local/bin/
RUN chmod +rx "$CMD_START" $CMD_ENTRY

#ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/local/bin/start.sh"]
