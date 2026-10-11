#!/usr/bin/env sh
set -eu

STACK_ENV="${STACK_ENV:-dev}"
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "${SCRIPT_DIR}/../.." && pwd)
STACK_COMPOSE_FILE="${ROOT_DIR}/ops/compose/compose.yml"
STACK_ENV_FILE="${ROOT_DIR}/env/${STACK_ENV}/stack/compose.env"

action="${1:-simulate_webhook}"

case "$action" in
  simulate_webhook|send_signed_fake_webhook)
    rake_task="payments:simulate_webhook"
    ;;
  replay_webhook_event)
    rake_task="payments:replay_webhook_event"
    ;;
  replay_failed_webhook_events)
    rake_task="payments:replay_failed_webhook_events"
    ;;
  *)
    rake_task="payments:$action"
    ;;
esac

# If docker compose stack is running with the 'web' service active, execute inside container
if [ -f "$STACK_ENV_FILE" ] && docker compose --env-file "$STACK_ENV_FILE" -f "$STACK_COMPOSE_FILE" ps --status running web 2>/dev/null | grep -q "web"; then
  docker compose --env-file "$STACK_ENV_FILE" -f "$STACK_COMPOSE_FILE" exec web env \
    PROJECT_ID="${PROJECT_ID:-}" \
    PAYMENT_ID="${PAYMENT_ID:-}" \
    PROVIDER="${PROVIDER:-}" \
    EVENT_ID="${EVENT_ID:-}" \
    TYPE="${TYPE:-}" \
    PROVIDER_REFERENCE="${PROVIDER_REFERENCE:-}" \
    AMOUNT_CENTS="${AMOUNT_CENTS:-}" \
    DEMO_FAIL_ONCE="${DEMO_FAIL_ONCE:-}" \
    DEMO_FAIL_ALWAYS="${DEMO_FAIL_ALWAYS:-}" \
    WEBHOOK_URL="${WEBHOOK_URL:-}" \
    bundle exec rake "$rake_task"
else
  PROJECT_ID="${PROJECT_ID:-}" \
  PAYMENT_ID="${PAYMENT_ID:-}" \
  PROVIDER="${PROVIDER:-}" \
  EVENT_ID="${EVENT_ID:-}" \
  TYPE="${TYPE:-}" \
  PROVIDER_REFERENCE="${PROVIDER_REFERENCE:-}" \
  AMOUNT_CENTS="${AMOUNT_CENTS:-}" \
  DEMO_FAIL_ONCE="${DEMO_FAIL_ONCE:-}" \
  DEMO_FAIL_ALWAYS="${DEMO_FAIL_ALWAYS:-}" \
  WEBHOOK_URL="${WEBHOOK_URL:-}" \
  bundle exec rake "$rake_task"
fi
