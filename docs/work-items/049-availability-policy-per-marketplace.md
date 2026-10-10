---
id: availability-policy-per-marketplace
aliases: []
tags:
  - work-items
  - availability
  - capacity
  - ordering
  - fulfillment
  - policies
depends_on:
  - capacity-reservation-workflow
  - order-workflow-orchestration
  - order-domain-and-project-rename
order: 49
phase: work-items
status: done
title: Availability Policy Per Marketplace
---

# Availability Policy Per Marketplace

## Goal

- [ ] Define a marketplace-specific availability policy that composes rules by `OfferVariant`, `Offer`, operational resource, or combinations of those dimensions.

## Scope

- Rename the business concept from global `Capacity` to marketplace-specific `Availability` where the domain meaning is acceptance and reservation.
- Introduce a marketplace-owned policy contract for availability checks.
- Support composable rules for variant-level, offer-level, resource-level, and combination-based availability.
- Keep reservation binding at `submit` time, not at draft time.
- Preserve the `OfferVariant` catalog and the existing legacy `video_type` bridge during the transition.

## Current Codebase

- `docs/decisions/12-availability-vs-capacity.md` captures the naming and domain direction.
- `docs/work-items/045-capacity-reservation-workflow.md` already models the reservation lifecycle and submit-time flow.
- `app/domains/capacity/application/queries/check_capacity.rb` and `app/domains/capacity/domain/policies/capacity_calculation_policy.rb` currently provide the capacity-based read path.
- `app/domains/ordering/application/commands/process_submission.rb` already reserves and commits capacity at submit time.
- `app/domains/ordering/application/dto/submission.rb` already exposes line items for consumption and reservation calculations.

## Design Notes

- Treat availability as a marketplace policy, not a single global semaphore.
- Keep the policy explicit and composable so each marketplace can define its own rule set.
- Avoid embedding forecasting or PM throughput estimation into the core domain.
- Keep draft flows permissive; make submit the point where availability becomes binding.

## Implementation Plan

- [x] Define the `AvailabilityPolicy` contract and rule composition model.
- [x] Decide whether the implementation namespace should be `capacity` or `availability` and rename accordingly.
- [x] Wire submit-time checks to the marketplace-selected availability policy.
- [x] Add rule coverage for variant, offer, resource, and combination-based scenarios.
- [x] Update docs and specs to reflect the new terminology.

## Expected Result

- Marketplaces can define their own availability rules without changing the ordering core.
- Availability is checked and reserved at submit time.
- The domain vocabulary clearly separates catalog (`OfferVariant`) from operational availability (`Availability`).

## Affected Docs

- `docs/decisions/12-availability-vs-capacity.md`
- `docs/work-items/045-capacity-reservation-workflow.md`
- `docs/work-items/index.md`

## Affected Ops

- `app/domains/capacity/` or `app/domains/availability/`
- `app/domains/ordering/application/commands/process_submission.rb`
- `app/domains/ordering/application/dto/submission.rb`
- `app/models/order.rb`
- `app/models/video_type_selection.rb`
- `spec/unit/domains/capacity/` or `spec/unit/domains/availability/`

## Checklist

- [x] Availability is modeled per marketplace.
- [x] Rules can be composed by variant, offer, resource, and combinations.
- [x] Submit is the only binding reservation point.
- [x] The naming decision is reflected consistently in docs and code.

## Validation

- [x] Specs cover rule composition and submit-time reservation behavior.
- [x] No ambiguity remains between catalog vocabulary and availability vocabulary.
- [x] Define a marketplace-specific availability policy that composes rules by `OfferVariant`, `Offer`, operational resource, or combinations of those dimensions.

## Notes

- This work item is intentionally separate from the reservation lifecycle work item.
- The reservation workflow remains valid; this item changes the policy that decides when a reservation should happen.
- Next step: plan the domain redistribution under the new `Commerce` / `Operations` / `Finance` umbrella using the versioned bounded-context map.
- This item is resolved at the architecture level; implementation work continues in the follow-up restructuring effort.
- Resolution: catalog and availability vocabulary are now separated in the new bounded-context map.
- Follow-up: finalize the domain migration and terminology cleanup in the next architecture pass.
