# Changelog

Each entry is one version of this Railway template. Breaking changes are listed first.

## 2026-11-24: Whitebophir v2.18.45

First release.

- WBO `lovasoa/wbo:v2.18.45@sha256:1f4939f26a17da6003b21af9f4ee58cb7aacf24009755b40dd0e894bc22411c7`.
- Caddy 2.11.9 (binary copied from `caddy:2.11.9-alpine@sha256:003a9780…`) in front for HTTP basic auth (generated password), real client IPs and an unauthenticated `/healthz`.
- Boards are stored as SVG files on a Railway volume at `/data` (`WBO_HISTORY_DIR`).
- If WBO or Caddy stops unexpectedly, the service exits non-zero so Railway's `ON_FAILURE` policy restarts it.
