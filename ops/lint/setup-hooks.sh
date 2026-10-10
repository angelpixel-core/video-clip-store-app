#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "${SCRIPT_DIR}/../.." && pwd)
HOOKS_PATH=".githooks"
HOOKS_DIR="${ROOT_DIR}/${HOOKS_PATH}"

if ! git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not inside a git repository: $ROOT_DIR" >&2
  exit 1
fi

mkdir -p "$HOOKS_DIR"
git -C "$ROOT_DIR" config core.hooksPath "$HOOKS_PATH"

echo "Configured Git hooks at ${HOOKS_PATH}"
