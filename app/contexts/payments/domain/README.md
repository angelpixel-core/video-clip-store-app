# Payments Domain Route Map

Pure payment rules live here.

## Contents

- `aggregates/` - aggregate roots and lifecycle behavior.
- `entities/` - domain entities.
- `errors/` - domain errors.
- `events/` - domain events.
- `policies/` - business rules and decision logic.
- `repositories/` - domain repository contracts.
- `value_objects/` - immutable payment concepts.

## Rules

- No Rails controllers, mailers, jobs, or HTTP/webhook code here.
- Domain objects may emit events and enforce invariants only.
