---
id: billing-presentation-and-adapter-taxonomy
aliases: []
tags:
  - work-items
  - billing
  - architecture
  - presentation
  - adapters
depends_on:
  - application-boundaries-and-repositories
order: 48
phase: work-items
status: done
title: Billing Presentation and Adapter Taxonomy
---

# Billing Presentation and Adapter Taxonomy

## Goal

- [x] Document a clear billing folder taxonomy that separates domain logic, application orchestration, outbound integrations, inbound entry points, and presentation concerns.

## Scope

- Define what belongs in `domain/`, `application/`, `adapters/`, and `presentation/` under `billing`.
- Clarify why fiscal providers are outbound adapters.
- Clarify why HTML/JSON/stream/binary renderers belong in presentation.
- Document how Rails controllers, routes, and views consume billing output without entering the bounded context.

## Affected Docs

- `docs/decisions/10-billing-presentation-and-adapter-taxonomy.md`
- `app/domains/billing/README.md`
- `app/domains/billing/domain/README.md`
- `app/domains/billing/application/README.md`
- `app/domains/billing/adapters/README.md`
- `app/domains/billing/presentation/README.md`

## Affected Ops

- `app/domains/billing/`
- `docs/decisions/`
- `docs/work-items/`

## Checklist

- [x] Taxonomy is written down in one architecture decision.
- [x] Route maps exist in the billing source tree.
- [x] Presentation is separated from outbound integrations.
- [x] Rails framework concerns are documented as external to the bounded context.

## Validation

- [x] Documentation reflects the existing billing layout and the intended future `presentation/` layer.

## Notes

- This is documentation-only and does not change runtime behavior.
