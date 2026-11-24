[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/whitebophir?utm_medium=integration&utm_source=button&utm_campaign=whitebophir)

# Whitebophir on Railway

A one-click Railway template for [Whitebophir (WBO)](https://github.com/lovasoa/whitebophir), the open-source online collaborative whiteboard.

## What it deploys

| Service | What it does |
|---|---|
| **Whitebophir** | WBO **v2.18.45** (`lovasoa/wbo:v2.18.45@sha256:1f4939f26a17da6003b21af9f4ee58cb7aacf24009755b40dd0e894bc22411c7`) on `127.0.0.1:5001`, behind a small Caddy 2.11.9 front on `$PORT`. Caddy adds HTTP basic auth, passes the visitor's real IP to WBO, and serves an unauthenticated `/healthz`. Boards are SVG files on a Railway volume at `/data`. |

No database is needed. It runs in about 60–100 MB of RAM, so it fits Railway's Free plan (0.5 GB / 1 vCPU, tested). If WBO or Caddy stops unexpectedly, the service exits non-zero and Railway's `ON_FAILURE` policy restarts it.

## Variables

| Variable | Default | What it's for |
|---|---|---|
| `BASIC_AUTH_USER` | `wbo` | Username for the login prompt in front of every board. |
| `BASIC_AUTH_PASSWORD` | `${{secret(24)}}` (generated) | Password for that login. Set it to an empty value to make your boards public. |
| `PORT` | `8080` | Port the Caddy front listens on (Railway's domain points here). |

Optional, from upstream: `AUTH_SECRET_KEY` (JWT board permissions), `WBO_BOARD_MODERATORS`, `WBO_DEFAULT_BOARD`, `TURNSTILE_SITE_KEY`/`TURNSTILE_SECRET_KEY`, rate limits. See the [upstream README](https://github.com/lovasoa/whitebophir#configuration).

## After deploy

Open the public URL and sign in with `wbo` and the `BASIC_AUTH_PASSWORD` from the service's Variables tab. Use `/boards/YOUR-BOARD-NAME` for a named board, `/random` for a new one, and `/preview/YOUR-BOARD-NAME` to download a board as SVG.

## Updates

This template builds from this repo. When we bump WBO here, Railway shows an "update available" notice on your project, and you choose when to apply it. Read [`CHANGELOG.md`](CHANGELOG.md) first: breaking changes are listed at the top of each entry. Your boards stay on the `/data` volume across updates.

## Files

- `Dockerfile`: the pinned WBO image plus the Caddy binary and the wrapper.
- `start.sh`: writes the basic-auth config, starts WBO and Caddy, and exits non-zero if either one stops.
- `Caddyfile`: the reverse proxy, the basic auth and `/healthz`.
- `OVERVIEW.md`: the Railway marketplace overview.

Licences: WBO is AGPL-3.0 (source: https://github.com/lovasoa/whitebophir); Caddy is Apache-2.0.
