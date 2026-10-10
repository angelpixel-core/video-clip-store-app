---
id: order-domain-and-project-rename
aliases: []
tags:
  - work-items
  - ordering
  - projects
  - rename
  - workflow
  - controllers
depends_on:
  - application-boundaries-and-repositories
  - order-workflow-orchestration
order: 44
phase: work-items
status: done
title: Order Domain and Project Rename
---

# Order Domain and Project Rename

## Goal

- [x] Recenter the product around `order` as the primary domain concept, keeping `project` only as a temporary compatibility surface during migration.
- [x] Split the current `project` responsibilities into explicit domains: `catalog` for what is sold, `ordering` for the customer request, `fulfillment` for internal work, and `notifications` for the final artifact/dispatch layer.

## Scope

- Rename the operator-facing shell from `projects` to `orders`.
- Reframe the existing `Project` model as a compatibility layer around the new order vocabulary.
- Move orchestration and listing concerns into an ordering-oriented namespace.
- Keep client-visible behavior stable during transition.
- Introduce explicit boundaries for:
  - `catalog` = sellable offer
  - `ordering` = customer order / submission
  - `fulfillment` = internal work
  - `delivery` = final output
- Avoid introducing a vague `asset` abstraction unless a concrete domain role emerges.

## Operational Note

- `Project` is legacy vocabulary, not the target domain name.
- `Order` should be the root business concept for the customer request lifecycle.
- `Submission` should be the explicit act of sending an order into payment and follow-up processing.
- `Offer` should represent what the customer chooses from the catalog.
- `OfferVariant` should represent each selected catalog option inside the order.
- `Project` should represent fulfillment work derived from the order.
- `Delivery` should represent the final artifact returned to the customer plus closure/confirmation notifications.

## Final Vocabulary

- `Order`: the customer's request and selection set.
- `Submission`: the workflow event that sends an order into payment and downstream processing.
- `Project`: the internal fulfillment work item derived from a submission.
- `Delivery`: the final artifact returned to the customer, plus closure and confirmation notifications.
- `Offer`: the sellable catalog choice the customer adds to an order.
- `OfferItemType`: the reusable global type of component an offer can contain.
- `OfferVariant`: a chosen catalog option inside an order, with quantity.

## Proposed Naming

- `catalog.offer`
- `catalog.offer_item_type`
- `catalog.offer_variant`
- `ordering.order`
- `ordering.offer_variant_selection`
- `ordering.submission`
- `fulfillment.project`
- `fulfillment.task`
- `fulfillment.delivery`
- `fulfillment.asset`
- `projects` only as a migration compatibility shim

## Implementation Plan

- [x] Define the final domain vocabulary and map each existing `Project` responsibility to its target domain.
- [x] Introduce `Order` as the primary ordering model or aggregate, with compatibility wrappers where needed.
- [x] Move the operator listing query out of `app/queries/projects` into the ordering domain namespace.
- [x] Rename the operator shell routes/controllers/views from `projects` to `orders`.
- [x] Keep legacy `projects` routes/controllers temporarily as redirects or adapters.
- [x] Update specs to document the new order vocabulary and migration boundary.
- [x] Remove `Project` from the visible UI once the ordering shell is complete.

## Checklist

- [x] The customer request lifecycle is named `order` instead of `project`.
- [x] The operator shell uses `orders` terminology.
- [x] `catalog`, `ordering`, `fulfillment`, and `delivery` have distinct responsibilities.
- [x] `project` only exists as transitional compatibility.
- [x] The listing/query layer lives under the ordering domain.
- [x] The migration path is explicit and test-covered.

## Validation

- [x] Specs cover the new order vocabulary.
- [x] Specs cover compatibility from legacy `project` callsites.
- [x] Operator-facing pages no longer depend on project terminology in the target path.
- [x] The rename does not break existing customer-facing behavior during transition.

## Notes

- Prefer a full vocabulary shift over partial renames to avoid confusion.
- If the order root needs a more explicit name than `Order`, consider `SubmissionOrder`, but only if `Order` would be ambiguous in the codebase.
- Keep the migration layered: vocabulary first, compatibility second, cleanup last.
- Legacy model/service names remain only as internal compatibility; the public `/projects` shell is gone.
- `/projects` was removed as a public route and the legacy `projects` view tree was deleted in favor of `orders`.
- Comment anchors now use `order-comments` to match the new surface.
- `OfferItemType` is the global taxonomy, and `OfferVariant` is the concrete selectable option.
- TODO(cleanup): Remove remaining legacy ids, filenames, and compatibility aliases only after the rest of the domain matrix is stable.
