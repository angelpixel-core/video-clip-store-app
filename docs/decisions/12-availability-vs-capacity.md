---
id: availability-vs-capacity
title: Availability vs Capacity
phase: decisions
order: 12
aliases: []
tags:
  - decisions
  - ordering
  - fulfillment
  - availability
  - capacity
  - architecture
---

# Availability vs Capacity

## Decision

The system should model marketplace-specific availability, not a global capacity. `Availability` is the domain concept for deciding whether a submission can be accepted and reserved, while `OfferVariant` remains the sellable catalog item.

## Scope

- Availability can be defined per marketplace.
- A marketplace policy may compose rules based on `OfferVariant`, `Offer`, operational resources, or combinations of those dimensions.
- Reservation happens at `submit`, not at draft time.
- Drafts remain non-final and may pass without locking supply.

## Rationale

- A global capacity model is too coarse for real marketplaces.
- Different businesses need different rules: by service, by product variant, by resource, or by combination.
- `Availability` better matches the business meaning than `Capacity` when the rule is about acceptance and reservation, not a fixed stock count.
- A marketplace-level policy keeps the system flexible without baking assumptions into the core ordering flow.

## Consequences

- `Capacity` should be treated as an implementation detail or legacy term, not the primary business abstraction.
- Policy composition must stay explicit and small so marketplaces can define their own rules cleanly.
- The existing `video_type` bridge must remain separate from availability logic.

## Notes

- The submit flow is the only point where availability must become binding.
- This decision does not replace the `OfferVariant` catalog vocabulary.
