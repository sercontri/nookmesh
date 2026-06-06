# ------------------------------------------------------------
# NookMesh Subscriptions Service
# Lightweight scheduler container
# ------------------------------------------------------------

FROM alpine:3.22

RUN apk add --no-cache \
    bash \
    tzdata \
    docker-cli \
    jq \
    openssl

COPY cron/nookmesh /etc/crontabs/root
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]