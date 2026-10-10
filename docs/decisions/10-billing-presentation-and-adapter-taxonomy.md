---
id: billing-presentation-and-adapter-taxonomy
title: Billing Presentation and Adapter Taxonomy
phase: decisions
order: 10
aliases: []
tags:
  - decisions
  - billing
  - architecture
  - presentation
  - adapters
---

# Billing Presentation and Adapter Taxonomy

## Decision

Billing uses a four-part structure for behavior, orchestration, integration, and output shaping:

- `domain/` for pure billing rules and invariants.
- `application/` for commands, queries, handlers, and ports.
- `adapters/` for inbound entry points and outbound integrations.
- `presentation/` for HTML, JSON, stream, and binary response shaping.

## Scope

- `inbound` adapters receive external input and hand it to application use cases.
- `outbound` adapters are called by billing when it needs persistence, email, fiscal providers, or other external systems.
- `presentation` is for transforming billing data into a renderable or serializable output.
- Rails controllers, routes, views, and framework-specific render flow remain outside the bounded context and consume billing presenters/adapters from the edge.

## Rationale

- The domain boundary stays clear when external dependencies are named by direction.
- `tax providers` are outbound because billing initiates the call to a third-party fiscal service.
- `invoice HTML` is presentation because it formats billing data into a viewable document, not an integration call.
- The same structure can support HTTP, GraphQL, gRPC, streams, and future device/protocol entry points without changing domain code.

## Notes

- `presentation` is intentionally broader than Rails views.
- `HTML`, `JSON`, `stream`, and `binary` are output shapes, not business rules.
- `integrations` is reserved for outbound dependencies that cross the billing boundary.
- `repository` remains reserved for local persistence.
