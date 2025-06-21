# syntax=docker/dockerfile:1
FROM caddy:latest
RUN caddy add-package github.com/caddy-dns/cloudflare
RUN caddy add-package github.com/ueffel/caddy-brotli
RUN caddy add-package github.com/caddyserver/caddy-l4
RUN apk add --no-cache curl