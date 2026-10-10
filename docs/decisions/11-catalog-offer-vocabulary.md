---
id: catalog-offer-vocabulary
title: Catalog Offer Vocabulary
phase: decisions
order: 11
aliases: []
tags:
  - decisions
  - catalog
  - ordering
  - offers
  - vocabulary
  - architecture
---

# Catalog Offer Vocabulary

## Decision

The catalog and ordering layers use the following frozen vocabulary:

- `Offer`: the sellable service or product.
- `OfferItemType`: the reusable global type of component an offer can contain.
- `OfferVariant`: the concrete selectable option within an offer.
- `Order`: the customer's request for one offer and its selected variants.
- `Project`: legacy fulfillment vocabulary, kept only as a transitional compatibility term.

## Scope

- `Offer` replaces the old idea of a project-level bundle or service definition.
- `OfferItemType` is global and reusable across offers.
- `OfferVariant` is the user-facing option that gets selected inside an order.
- `Order` remains the transactional request placed by the customer.
- `Project` should not be used for new catalog or ordering concepts.

## Rationale

- `video_type` is too narrow to scale across future services like food or logistics.
- `OfferItemType` keeps the system open to reusable global categories.
- `OfferVariant` naturally captures a concrete choice like `Highlight Reel` or `Vegetarian`.
- Freezing the vocabulary now avoids further drift while the data model is still being shaped.

## Notes

- `Offering` and `OfferingVariant` are legacy aliases and should be removed once the new naming is fully adopted.
- `OfferItemType` is a domain concept, not a UI label.
- `Order` is the customer-facing request; fulfillment may still use legacy `Project` as a temporary bridge.
