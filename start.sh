#!/bin/sh
# Start Whitebophir on 127.0.0.1 and Caddy on $PORT. If either one stops,
# stop the other and exit non-zero so Railway's ON_FAILURE policy restarts us.
set -eu

DATA_DIR="${WBO_HISTORY_DIR:-/data}"
INTERNAL_PORT="${WBO_INTERNAL_PORT:-5001}"
PUBLIC_PORT="${PORT:-8080}"
if [ "$INTERNAL_PORT" = "$PUBLIC_PORT" ]; then
	echo "wbo-railway: WBO_INTERNAL_PORT must differ from PORT ($PUBLIC_PORT)" >&2
	exit 1
fi

# Railway volumes are mounted owned by root: hand the board folder to the app user.
mkdir -p "$DATA_DIR"
chown 1000:1000 "$DATA_DIR"

# HTTP basic auth in front of every board (on unless BASIC_AUTH_PASSWORD is empty).
mkdir -p /tmp/wbo-railway
if [ -n "${BASIC_AUTH_PASSWORD:-}" ]; then
	user="${BASIC_AUTH_USER:-wbo}"
	case "$user" in
		*[!A-Za-z0-9._@-]*|"") echo "wbo-railway: BASIC_AUTH_USER may use only letters, digits and . _ @ -" >&2; exit 1 ;;
	esac
	hash="$(printf '%s' "$BASIC_AUTH_PASSWORD" | caddy hash-password)"
	printf 'basic_auth {\n\t%s %s\n}\n' "$user" "$hash" > /tmp/wbo-railway/auth.caddy
	echo "wbo-railway: basic auth on for user '$user'"
else
	: > /tmp/wbo-railway/auth.caddy
	echo "wbo-railway: BASIC_AUTH_PASSWORD is empty, boards are open to anyone with the URL" >&2
fi
caddy validate --config /etc/wbo-railway/Caddyfile --adapter caddyfile >/dev/null 2>&1 || {
	caddy validate --config /etc/wbo-railway/Caddyfile --adapter caddyfile
	exit 1
}

cd /opt/app
# WBO runs as the unprivileged node user (uid 1000), listening on loopback only.
su node -s /bin/sh -c "cd /opt/app && exec env -u BASIC_AUTH_PASSWORD PORT='$INTERNAL_PORT' HOST=127.0.0.1 /usr/local/bin/node server/server.mjs" &
wbo_pid=$!
caddy run --config /etc/wbo-railway/Caddyfile --adapter caddyfile &
caddy_pid=$!

stopping=0
on_term() {
	stopping=1
	kill -TERM "$wbo_pid" "$caddy_pid" 2>/dev/null || true
}
trap on_term TERM INT

# BusyBox `wait -n` doesn't return on the first child exit, so poll.
while kill -0 "$wbo_pid" 2>/dev/null && kill -0 "$caddy_pid" 2>/dev/null; do
	sleep 1
done

if [ "$stopping" = 1 ]; then
	wait "$wbo_pid" 2>/dev/null || true
	exit 0
fi
echo "wbo-railway: a process stopped unexpectedly, exiting so Railway restarts the service" >&2
kill -TERM "$wbo_pid" "$caddy_pid" 2>/dev/null || true
sleep 2
exit 1
