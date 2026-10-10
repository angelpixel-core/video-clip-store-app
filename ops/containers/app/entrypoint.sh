#!/usr/bin/env sh
set -e

echo "Waiting for MySQL..."

MYSQL_HOST="${DB_HOST:-${MYSQL_HOST:-db}}"
MYSQL_PORT="${DB_PORT:-${MYSQL_PORT:-3306}}"
MYSQL_USER="${DB_USER:-${MYSQL_USER:-app}}"
MYSQL_PASSWORD="${DB_PASSWORD:-${MYSQL_PASSWORD:-app_password}}"

for i in 1 2 3 4 5 6 7 8 9 10; do
  if MYSQL_PWD="$MYSQL_PASSWORD" mysqladmin ping -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" --silent >/dev/null 2>&1; then
    break
  fi
  sleep 1
  if [ "$i" = "10" ]; then
    echo "MySQL not ready"
    exit 1
  fi
done

if [ "${RUN_DB_PREPARE:-0}" = "1" ] && [ -f /app/bin/rails ]; then
  bundle exec rails db:prepare
fi

export PORT="${APP_PORT:-${PORT:-3000}}"

exec "$@"
