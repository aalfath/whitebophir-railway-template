# Whitebophir (WBO) for Railway: the official image, pinned by version and digest,
# with a small Caddy front for HTTP basic auth, real client IPs and a /healthz path.
FROM caddy:2.11.9-alpine@sha256:003a97808e781aa9f7e75cc2f43d34d461099031faf5e20faefb9f61126836f0 AS caddy

FROM lovasoa/wbo:v2.18.45@sha256:1f4939f26a17da6003b21af9f4ee58cb7aacf24009755b40dd0e894bc22411c7

USER root
COPY --from=caddy /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/wbo-railway/Caddyfile
COPY start.sh /usr/local/bin/wbo-railway-start
RUN chmod 0755 /usr/local/bin/wbo-railway-start \
    && mkdir -p /data && chown 1000:1000 /data

# Boards live on the Railway volume mounted at /data.
ENV NODE_ENV=production \
    WBO_HISTORY_DIR=/data \
    WBO_IP_SOURCE=X-Forwarded-For \
    WBO_INTERNAL_PORT=5001 \
    PORT=8080 \
    GOMAXPROCS=2
EXPOSE 8080

CMD ["/usr/local/bin/wbo-railway-start"]
