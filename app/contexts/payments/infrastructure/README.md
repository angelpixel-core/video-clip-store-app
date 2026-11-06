# Payments Adapters

Payments adapters connect the bounded context to the outside world.

## Contents

- `inbound/` - external events and requests.
- `outbound/` - mailers, gateways, webhook simulators, and persistence adapters.

## Rule

- If payments receives it, it is inbound.
- If payments calls it, it is outbound.
