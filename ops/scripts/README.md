# Scripts

This directory contains shell helpers used by `make stack/*`, `make db/*`, `make secrets/*`, `make test/*`, and `make repo/*` targets.

## Notes

- Keep scripts small and environment-driven.
- Prefer these helpers over embedding long shell snippets in the Makefile.
- `stack.sh` manages local compose orchestration and ensures the ignored `env/.local/<env>.env` overlay exists for Compose.
- `db.sh` runs database-related Rails commands inside the `web` compose service, including seed loading, project cleanup, and the Rails console.
- `secrets.sh` manages GitHub, Render, and local secret operations.
