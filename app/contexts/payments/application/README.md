# Payments Application Route Map

The application layer coordinates payment workflows.

## Contents

- `commands/` - state-changing use cases.
- `dto/` - application data transfer objects.
- `handlers/` - orchestration helpers and async jobs.
- `ports/` - outbound interfaces used by application code.
- `queries/` - read-only use cases.
- `gateways.rb` - provider selection and wiring helper.

## Rules

- Application code returns result objects and coordinates domain work.
- Application code does not talk directly to external systems without a port or adapter.
