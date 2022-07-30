FROM alpine
LABEL maintainer="William Guilherme <wguilherme@securitygeek.io>"

RUN set -xe \
    && apk add --no-cache iptables openssl strongswan util-linux mtr

ADD entrypoint.sh /entrypoint.sh
ADD ipsec.conf /etc/
ADD ipsec.secrets /etc/

ENV VPN_SECRET= \
    VPN_FQDN= \
    VPN_TARGET= \
    VPN_SOURCE= \
    TARGET= \
    MTR_OUTPUT="--csv" \
    MTR_CYCLES="5" \
    MTR_FIELDS="BAW" \
    MTR_TYPE="" \
    MTR_HOPS=30 \
    MTR_INTERVAL=1 \
    MTR_NODNS=""

EXPOSE 500/udp 4500/udp

ENTRYPOINT ["/entrypoint.sh"]