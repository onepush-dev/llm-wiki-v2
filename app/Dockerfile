# llm-wiki-v2 (crow-hq/llm-wiki-v2, AGPL-3.0) on Railway. FROM the upstream image built unmodified from tag v1.0.0
# (see .github/workflows/publish-ghcr.yml), plus Caddy basic auth in front: the upstream server has no authentication.
ARG BASE=ghcr.io/onepush-dev/llm-wiki-v2-base:1.0.0
FROM caddy:2.10-alpine AS caddy

FROM ${BASE}
LABEL org.opencontainers.image.source="https://github.com/onepush-dev/llm-wiki-v2" \
      org.opencontainers.image.licenses="AGPL-3.0-or-later"
COPY --from=caddy /usr/bin/caddy /usr/local/bin/caddy
COPY --chmod=755 railway-start.sh /usr/local/bin/railway-start.sh
# Wiki (plain OKF markdown), settings saved from the page and the usage log all live on the /data volume.
ENV OKF_BUNDLE=/data/wiki \
    OKF_CONFIG=/data/config.json \
    OKF_USAGE_LOG=/data/wiki/.usage.jsonl \
    WIKI_USER=admin \
    HOME=/data
EXPOSE 8080
ENTRYPOINT []
CMD ["railway-start.sh"]
