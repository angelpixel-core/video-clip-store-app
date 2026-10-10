#!/usr/bin/env sh
set -eu

TEST_ENV="${TEST_ENV:-test}"
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "${SCRIPT_DIR}/../.." && pwd)
TEST_STACK_ENV_FILE="${ROOT_DIR}/env/${TEST_ENV}/stack/compose.env"
TEST_APP_CORE_ENV_FILE="${ROOT_DIR}/env/${TEST_ENV}/app/core.env"
TEST_APP_DB_ENV_FILE="${ROOT_DIR}/env/${TEST_ENV}/app/db.env"
TEST_DB_BOOTSTRAP_ENV_FILE="${ROOT_DIR}/env/${TEST_ENV}/db/bootstrap.env"

IMAGE_NAME="${IMAGE_NAME:-video-project-submission-app:test}"
TEST_DB_CONTAINER_NAME="${TEST_DB_CONTAINER_NAME:-video-project-submission-app-test-db}"

require_file() {
  if [ ! -f "$1" ]; then
    echo "Missing file: $1" >&2
    exit 1
  fi
}

load_env_file() {
  file="$1"
  [ -f "$file" ] || return 0

  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ''|'#'*)
        continue
        ;;
    esac

    case "$line" in
      *=*)
        key=${line%%=*}
        value=${line#*=}

        export "$key=$value"
        ;;
    esac
  done < "$file"
}

build_image() {
  require_file "$TEST_STACK_ENV_FILE"
  docker build \
    --file "${ROOT_DIR}/ops/containers/app/Dockerfile" \
    --target test \
    --build-arg "RUBY_VERSION=${RUBY_VERSION:-4.0.3}" \
    --tag "$IMAGE_NAME" \
    "$ROOT_DIR"
}

ensure_database() {
  require_file "$TEST_DB_BOOTSTRAP_ENV_FILE"
  load_env_file "$TEST_APP_DB_ENV_FILE"
  load_env_file "$TEST_DB_BOOTSTRAP_ENV_FILE"
  docker network inspect video_project_submission_app_net >/dev/null 2>&1 || \
    docker network create --driver bridge video_project_submission_app_net >/dev/null
  docker rm -f video-project-submission-app-db >/dev/null 2>&1 || true
  docker rm -f "$TEST_DB_CONTAINER_NAME" >/dev/null 2>&1 || true
  docker run -d \
    --name "$TEST_DB_CONTAINER_NAME" \
    --network video_project_submission_app_net \
    --network-alias db \
    --env-file "$TEST_DB_BOOTSTRAP_ENV_FILE" \
    -v "${ROOT_DIR}/ops/containers/db/entrypoint/initdb.d:/docker-entrypoint-initdb.d:ro" \
    mysql:8.4 mysqld --port="${DB_PORT:-3306}" >/dev/null

  cleanup_database() {
    docker rm -f "$TEST_DB_CONTAINER_NAME" >/dev/null 2>&1 || true
  }

  trap cleanup_database EXIT INT TERM

  wait_for_database
}

wait_for_database() {
  host="${DB_HOST:-db}"
  port="${DB_PORT:-3306}"
  root_password="${MYSQL_ROOT_PASSWORD:-root_password}"
  max_attempts="${DB_WAIT_ATTEMPTS:-300}"
  attempt=1

  while [ "$attempt" -le "$max_attempts" ]; do
    if docker exec "$TEST_DB_CONTAINER_NAME" mysqladmin ping -h 127.0.0.1 -P "$port" -uroot -p"$root_password" --silent >/dev/null 2>&1; then
      return 0
    fi

    sleep 1
    attempt=$((attempt + 1))
  done

  echo "Timed out waiting for database on ${host}:${port}" >&2
  docker logs "$TEST_DB_CONTAINER_NAME" >&2 || true
  return 1
}

run_in_image() {
  command="$1"
  shift

  load_env_file "$TEST_APP_CORE_ENV_FILE"
  load_env_file "$TEST_APP_DB_ENV_FILE"

  if [ -n "${DATABASE_URL:-}" ]; then
    docker run --rm \
      --network video_project_submission_app_net \
      --env-file "$TEST_APP_CORE_ENV_FILE" \
      --env-file "$TEST_APP_DB_ENV_FILE" \
      --env "DATABASE_URL=${DATABASE_URL}" \
      "$IMAGE_NAME" \
      sh -lc "$command" sh "$@"
  else
    docker run --rm \
      --network video_project_submission_app_net \
      --env-file "$TEST_APP_CORE_ENV_FILE" \
      --env-file "$TEST_APP_DB_ENV_FILE" \
      "$IMAGE_NAME" \
      sh -lc "$command" sh "$@"
  fi
}

case "${1:-}" in
  build)
    build_image
    ;;
  verify)
    ensure_database
    build_image
    run_in_image 'bundle exec rails db:prepare:with_data && bundle exec ruby -e "require \"./config/environment\"; puts Rails.env"'
    ;;
  rspec)
    shift
    ensure_database
    build_image
    if [ -n "${TEST_ARGS:-}" ]; then
      run_in_image "bundle exec rails db:prepare:with_data && bundle exec rspec ${TEST_ARGS}" "$@"
    else
      run_in_image 'bundle exec rails db:prepare:with_data && bundle exec rspec "$@"' "$@"
    fi
    ;;
  cucumber)
    shift
    ensure_database
    build_image
    if [ -n "${TEST_ARGS:-}" ]; then
      run_in_image "bundle exec rails db:prepare:with_data && bundle exec cucumber spec/acceptance/features --require spec/acceptance/support --require spec/acceptance/step_definitions ${TEST_ARGS}" "$@"
    else
      run_in_image 'bundle exec rails db:prepare:with_data && bundle exec cucumber spec/acceptance/features --require spec/acceptance/support --require spec/acceptance/step_definitions "$@"' "$@"
    fi
    ;;
  *)
    echo "Usage: test.sh {build|verify|rspec|cucumber}" >&2
    exit 1
    ;;
esac
