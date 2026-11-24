# Deploy and Host Whitebophir on Railway

Whitebophir (WBO) is an open-source online collaborative whiteboard. Many people can draw on the same large board at once and see each other's changes in real time. It has pencil, lines, shapes, text, an eraser and a grid, and it saves every board as an SVG file you can download.

## About Hosting Whitebophir

This template runs one service: the official WBO image v2.18.45, pinned by version and digest, built from a public GitHub repo. A small Caddy front listens on Railway's port. It asks for a username and password on every page and websocket, so a fresh deploy isn't an open public board. The password is generated at deploy time. Boards are saved as SVG files on a Railway volume mounted at `/data`, so they survive redeploys and restarts. WBO uses no database. It runs in about 60–100 MB of RAM, so it fits Railway's Free plan (0.5 GB). If WBO or Caddy stops unexpectedly, the service exits with an error and Railway restarts it.

## Common Use Cases

* Sketching ideas and diagrams together on a video call
* Teaching or tutoring with a shared board (math, drawings, explanations)
* A private team whiteboard that keeps its boards on your own volume

## Dependencies for Whitebophir Hosting

* One Railway service built from `aalfath/whitebophir-railway-template` (WBO plus a Caddy basic-auth front)
* One Railway volume at `/data` for the board files

### Deployment Dependencies

* WBO source and docs: https://github.com/lovasoa/whitebophir
* Release v2.18.45: https://github.com/lovasoa/whitebophir/releases/tag/v2.18.45
* Official image: https://hub.docker.com/r/lovasoa/wbo
* Template repo: https://github.com/aalfath/whitebophir-railway-template

### Implementation Details

After the deploy finishes, open the service's public URL. Your browser asks for a login: the username is `wbo` (`BASIC_AUTH_USER`) and the password is the generated `BASIC_AUTH_PASSWORD` in the service's Variables tab. Share that login with the people you want to draw with. Open `/boards/YOUR-BOARD-NAME` to make or join a named board, or `/random` for a new one. `/preview/YOUR-BOARD-NAME` downloads a board as SVG.

Anyone with the login can edit any board. To make the boards public, set `BASIC_AUTH_PASSWORD` to an empty value and redeploy. WBO's own JWT board permissions (`AUTH_SECRET_KEY`), moderators and Cloudflare Turnstile work as described in the upstream README. You can add them as variables.

`/healthz` is the unauthenticated health check. WBO sees each visitor's real IP for its per-IP rate limits. Updates: when we bump WBO in the template repo, Railway shows "update available" on your project, and the repo's `CHANGELOG.md` lists what changed.

## Why Deploy Whitebophir on Railway?

<!-- Recommended: Keep this section as shown below -->
Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Whitebophir on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
<!-- End recommended section -->
