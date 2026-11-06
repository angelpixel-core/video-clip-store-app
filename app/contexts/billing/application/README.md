# Billing Application Route Map

The application layer coordinates billing use cases.

## Contents

- `commands/` - state-changing use cases.
- `queries/` - read-only use cases.
- `handlers/` - orchestration helpers and async jobs.
- `ports/` - outbound interfaces used by application code.

## Rules

- Application code returns result objects.
- Application code coordinates domain objects and ports.
- Application code does not talk directly to third-party services or Rails views.
