# Billing Domain Route Map

Pure billing rules live here.

## Contents

- `aggregates/` - aggregate roots and lifecycle behavior.
- `entities/` - domain entities that belong to the billing model.
- `events/` - domain events emitted by billing rules.
- `policies/` - business policies and decision rules.
- `repositories/` - domain repository contracts.
- `value_objects/` - immutable billing concepts.

## Rules

- No Rails classes here.
- No HTTP, mail, persistence, or third-party integration code here.
- Domain objects may express invariants, policies, and event emission only.
