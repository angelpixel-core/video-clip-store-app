# Billing Outbound Adapters

Outbound adapters are called by billing when it needs something outside the core.

## Contents

- `mailers/` - email delivery adapters.
- `integrations/tax_providers/` - third-party fiscal integrations.
- `persistence/` - local persistence implementations.

## Conceptual Labels

- `integrations/` is the semantic bucket for outbound third-party dependencies.
- `mailers/` is the semantic bucket for email delivery adapters.

## Rule

- Outbound adapters implement dependencies that billing calls, not dependencies that call billing.
