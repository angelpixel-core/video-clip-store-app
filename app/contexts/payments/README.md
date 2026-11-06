# Payments Route Map

Payments is split into four layers:

- `domain/` for payment rules and lifecycle.
- `application/` for use cases and orchestration.
- `adapters/` for inbound entry points and outbound integrations.
- `presentation/` is not currently a payments layer; output shaping stays inside the outbound adapters that deliver mail or external responses.

## Current Tree

```text
payments/
  domain/
    aggregates/
    entities/
    errors/
    events/
    policies/
    repositories/
    value_objects/
  application/
    commands/
    dto/
    handlers/
    ports/
    queries/
    gateways.rb
  adapters/
    inbound/
      webhooks/
        event/
          handler/
    outbound/
      mailers/
      gateways/
      webhooks/
      persistence/
        payment/
        webhook/
          event/
```

## Rules

- Domain code stays pure and does not depend on Rails or infrastructure.
- Application code coordinates payment workflows and returns result objects.
- Inbound adapters receive external events or requests.
- Outbound adapters call external services, persistence, or delivery channels.
