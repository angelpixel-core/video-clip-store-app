#!/usr/bin/env sh
set -eu

STACK_ENV="${STACK_ENV:-dev}"
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "${SCRIPT_DIR}/../.." && pwd)
STACK_COMPOSE_FILE="${ROOT_DIR}/ops/compose/compose.yml"
STACK_ENV_FILE="${ROOT_DIR}/env/${STACK_ENV}/stack/compose.env"
STACK_LOCAL_SECRET_FILE="${ROOT_DIR}/env/.local/${STACK_ENV}.env"

require_file() {
  if [ ! -f "$1" ]; then
    echo "Missing file: $1" >&2
    exit 1
  fi
}

run_compose() {
  require_file "$STACK_ENV_FILE"
  mkdir -p "$(dirname "$STACK_LOCAL_SECRET_FILE")"
  [ -f "$STACK_LOCAL_SECRET_FILE" ] || : > "$STACK_LOCAL_SECRET_FILE"
  docker compose --env-file "$STACK_ENV_FILE" -f "$STACK_COMPOSE_FILE" "$@"
}

sync_file_to_gh() {
  file="$1"
  [ -f "$file" ] || return 0

  command -v gh >/dev/null 2>&1 || {
    echo "gh is required for secrets sync" >&2
    exit 1
  }

  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ''|'#'*) continue ;;
    esac
    key=${line%%=*}
    value=${line#*=}
    gh secret set "$key" --app actions --body "$value" >/dev/null
  done < "$file"
}

sync_file_to_vercel() {
  file="$1"
  environment="$2"
  [ -f "$file" ] || return 0

  command -v vercel >/dev/null 2>&1 || {
    echo "vercel is required for secrets sync" >&2
    exit 1
  }

  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ''|'#'*) continue ;;
    esac
    key=${line%%=*}
    value=${line#*=}
    vercel env add "$key" "$value" "$environment" >/dev/null
  done < "$file"
}

case "${1:-}" in
  up)
    shift
    run_compose up "$@"
    ;;
  down)
    shift
    run_compose down "$@"
    ;;
  config)
    shift
    run_compose config "$@"
    ;;
  logs)
    shift
    run_compose logs -f "$@"
    ;;
  exec)
    shift
    run_compose exec web sh "$@"
    ;;
  doctor)
    require_file "$STACK_ENV_FILE"
    run_compose config >/dev/null
    ;;
  secrets/sync/gh|secrets/sync/ci)
    SECRET_ENV="${SECRET_ENV:-test}"
    sync_file_to_gh "${ROOT_DIR}/env/${SECRET_ENV}/app/secrets.local.env"
    sync_file_to_gh "${ROOT_DIR}/env/${SECRET_ENV}/db/secrets.local.env"
    sync_file_to_gh "${ROOT_DIR}/env/${SECRET_ENV}/stack/secrets.local.env"
    ;;
  secrets/sync/vercel)
    SECRET_ENV="${SECRET_ENV:-prod}"
    VERCEL_ENVIRONMENT="${VERCEL_ENVIRONMENT:-production}"
    sync_file_to_vercel "${ROOT_DIR}/env/${SECRET_ENV}/app/secrets.local.env" "$VERCEL_ENVIRONMENT"
    sync_file_to_vercel "${ROOT_DIR}/env/${SECRET_ENV}/db/secrets.local.env" "$VERCEL_ENVIRONMENT"
    sync_file_to_vercel "${ROOT_DIR}/env/${SECRET_ENV}/stack/secrets.local.env" "$VERCEL_ENVIRONMENT"
    ;;
  *)
    echo "Usage: stack.sh {up|down|config|logs|exec|doctor|secrets/sync/gh|secrets/sync/ci|secrets/sync/vercel}" >&2
    exit 1
    ;;
esac
