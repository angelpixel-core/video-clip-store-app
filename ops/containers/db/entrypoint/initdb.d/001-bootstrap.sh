#!/usr/bin/env sh
set -eu

: "${MYSQL_ROOT_PASSWORD:?MYSQL_ROOT_PASSWORD is required}"
: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
: "${MYSQL_USER:?MYSQL_USER is required}"
: "${MYSQL_PASSWORD:?MYSQL_PASSWORD is required}"

PRIMARY_DATABASE="${MYSQL_DATABASE}"
QUEUE_DATABASE="${MYSQL_QUEUE_DATABASE:-${MYSQL_DATABASE}_queue}"
CABLE_DATABASE="${MYSQL_CABLE_DATABASE:-${MYSQL_DATABASE}_cable}"
TEST_DATABASE="${MYSQL_TEST_DATABASE:-video_project_submission_app_test}"
TEST_QUEUE_DATABASE="${MYSQL_TEST_QUEUE_DATABASE:-${TEST_DATABASE}_queue}"
TEST_CABLE_DATABASE="${MYSQL_TEST_CABLE_DATABASE:-${TEST_DATABASE}_cable}"

create_db_and_grant() {
  db_name="$1"
  mysql --protocol=socket -uroot -p"${MYSQL_ROOT_PASSWORD}" <<SQL
CREATE DATABASE IF NOT EXISTS \`${db_name}\`;
GRANT ALL PRIVILEGES ON \`${db_name}\`.* TO '${MYSQL_USER}'@'%';
SQL
}

mysql --protocol=socket -uroot -p"${MYSQL_ROOT_PASSWORD}" <<SQL
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
FLUSH PRIVILEGES;
SQL

create_db_and_grant "$PRIMARY_DATABASE"
create_db_and_grant "$QUEUE_DATABASE"
create_db_and_grant "$CABLE_DATABASE"
create_db_and_grant "$TEST_DATABASE"
create_db_and_grant "$TEST_QUEUE_DATABASE"
create_db_and_grant "$TEST_CABLE_DATABASE"
