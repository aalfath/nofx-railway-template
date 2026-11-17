#!/bin/sh
# Start NOFX behind nginx. Everything NOFX keeps (SQLite database, logs,
# planning workspaces, generated keys) lives in /app/data, the Railway volume.
set -eu

export PORT="${PORT:-8080}"
DATA=/app/data
KEYS="$DATA/.keys"
mkdir -p "$KEYS"
chmod 700 "$KEYS"

# Use the variable if set, else a value generated once and kept on the volume.
persist() { # name generator-command
  eval "cur=\${$1:-}"
  if [ -z "$cur" ]; then
    if [ ! -s "$KEYS/$1" ]; then
      (umask 077; sh -c "$2" > "$KEYS/$1")
      echo "nofx-start: generated $1 and stored it in $KEYS"
    fi
    cur=$(cat "$KEYS/$1")
  fi
  export "$1=$cur"
}
persist JWT_SECRET 'openssl rand -base64 48 | tr -d "\n"'
persist DATA_ENCRYPTION_KEY 'openssl rand -base64 32 | tr -d "\n"'
persist RSA_PRIVATE_KEY 'openssl genrsa 2048 2>/dev/null'
# SETUP_PASSWORD guards first-run registration (user "setup"). The Railway
# template sets it; without it, read it from $KEYS/SETUP_PASSWORD on the volume.
persist SETUP_PASSWORD 'openssl rand -hex 16'

# Fixed NOFX settings for this container (override any of them with a variable).
export DB_TYPE="${DB_TYPE:-sqlite}"
export DB_PATH="${DB_PATH:-$DATA/data.db}"
export API_SERVER_PORT=8081
export NOFX_API_BIND_ADDRESS=127.0.0.1
export NOFX_TRUSTED_PROXIES="${NOFX_TRUSTED_PROXIES:-127.0.0.1}"
export AI_MAX_TOKENS="${AI_MAX_TOKENS:-8000}"
export TZ="${TZ:-UTC}"
if [ -z "${CORS_ALLOWED_ORIGINS:-}" ] && [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
  export CORS_ALLOWED_ORIGINS="https://$RAILWAY_PUBLIC_DOMAIN"
fi

# nginx: render the site and the first-run password file.
printf 'setup:%s\n' "$(openssl passwd -apr1 "$SETUP_PASSWORD")" > /etc/nginx/nofx-setup.htpasswd
chmod 640 /etc/nginx/nofx-setup.htpasswd
chown root:nginx /etc/nginx/nofx-setup.htpasswd 2>/dev/null || true
LISTEN_V6=""
[ -s /proc/net/if_inet6 ] && LISTEN_V6="listen [::]:${PORT};"
export LISTEN_V6
# Replace the base image's site (it points at a separate "nofx" host).
rm -f /etc/nginx/conf.d/*.conf
envsubst '${PORT} ${LISTEN_V6}' < /etc/nofx/nginx.conf.template > /etc/nginx/conf.d/nofx.conf
GATE_ON='auth_basic $nofx_setup_realm; auth_basic_user_file /etc/nginx/nofx-setup.htpasswd;'
if [ -f "$KEYS/initialized" ]; then
  echo "# first-run gate lifted" > /etc/nofx/gate.conf
else
  echo "$GATE_ON" > /etc/nofx/gate.conf
fi
nginx -t -q
nginx

# Lift the first-run gate once NOFX has its first account.
if [ ! -f "$KEYS/initialized" ]; then
  (
    while :; do
      sleep 3
      if curl -fsS http://127.0.0.1:8081/api/config 2>/dev/null | grep -q '"initialized":true'; then
        touch "$KEYS/initialized"
        echo "# first-run gate lifted" > /etc/nofx/gate.conf
        nginx -s reload && echo "nofx-start: first account exists; setup password gate lifted"
        break
      fi
    done
  ) &
fi

# NOFX writes one log file a day to data/; keep 14 days.
( while :; do find "$DATA" -maxdepth 1 -name 'nofx_*.log' -mtime +14 -delete 2>/dev/null || true; sleep 86400; done ) &

cd /app
exec /app/nofx
