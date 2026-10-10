# Billing Route Map

Billing is split into four layers:

- `domain/` for pure business rules.
- `application/` for use cases and orchestration.
- `adapters/` for inbound entry points and outbound integrations.
- `presentation/` for HTML, JSON, stream, and binary output shaping.

## Current Tree

```text
billing/
  domain/
  application/
  adapters/
    inbound/
      event_consumers/
    outbound/
      mailers/
      integrations/
        tax_providers/
          arca/
      persistence/
  presentation/
    html/
    json/
    stream/
    binary/
```

## Current Physical Subtrees

- `adapters/inbound/event_consumers/`
- `adapters/outbound/mailers/`
- `adapters/outbound/integrations/tax_providers/`
- `adapters/outbound/persistence/`
- `presentation/html/`
- `presentation/json/`
- `presentation/stream/`
- `presentation/binary/`

## Rules

- Domain code does not depend on Rails controllers, views, or framework renderers.
- Application use cases return result objects and coordinate domain work.
- Inbound adapters receive external events, requests, or protocol messages.
- Outbound adapters call external systems or local persistence.
- Presentation turns billing data into a deliverable shape for the edge of the app.
