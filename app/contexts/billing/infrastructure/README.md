# Billing Adapters

Adapters connect billing to the outside world.

## Contents

- `inbound/` - entry points that bring external events or requests into billing.
- `outbound/` - integrations billing calls when it needs external behavior.

## Rule

- Direction matters more than technology name.
- If billing receives it, it is inbound.
- If billing calls it, it is outbound.

## Current Physical Paths

- `inbound/event_consumers/`
- `outbound/mailers/`
- `outbound/integrations/tax_providers/`
- `outbound/persistence/`
