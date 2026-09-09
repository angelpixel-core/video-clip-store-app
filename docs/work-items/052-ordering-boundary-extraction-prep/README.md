---
id: ordering-boundary-extraction-prep
aliases: []
tags:
  - work-items
  - ordering
  - boundaries
  - extraction
  - architecture
depends_on:
  - application-boundaries-and-repositories
  - order-workflow-orchestration
order: 52
phase: work-items
status: planned
title: Ordering Boundary Extraction Preparation
---

# Ordering Boundary Extraction Preparation

## Goal

- [ ] Prepare `ordering` for extraction as a standalone Rails application without changing the current product behavior.
- [ ] Make the boundary contract explicit before moving code or data ownership.

## Current Boundary

`ordering` currently owns:

- the `Order` domain aggregate
- order lifecycle and transition policies
- order snapshots, line items, and source video data
- submission validation and payment handoff
- operator order listing/query behavior
- order form presentation

The physical domain tree is already under `app/domains/ordering/`, but the runtime still has compatibility code in `app/models/order.rb` and legacy `projects` persistence.

## Audit Findings

- `ProcessSubmission` currently coordinates validation, availability, capacity, payment, invoicing, and notifications in one application command.
- `ordering/package.yml` directly depends on `payments`, `billing`, and `capacity`, while those boundaries also depend on ordering-related persistence or contracts.
- `Ordering::Application::DTO::Submission` accepts multiple transitional object shapes through `respond_to?` checks.
- `ListingQuery` directly uses the ordering persistence record instead of a query port.
- `app/models/order.rb` writes the legacy `projects` record and synchronizes the `orders` read model through `sync_order_listing!`.
- Fulfillment persistence currently lives under `app/models/fulfillment/` while its contract lives under `app/domains/fulfillment/`.

## Scope

- Reduce direct downstream knowledge inside `ordering`.
- Define explicit ports for post-payment and post-checkpoint work.
- Stabilize the `Submission` input contract.
- Separate order lifecycle responsibilities from cross-domain workflow orchestration.
- Document the compatibility seam between `Project`, the legacy `projects` table, and the `orders` read model.
- Add contract coverage before extraction.

## Non-Goals

- Do not extract a new Rails application in this work item.
- Do not rename `Billing::` namespaces or the physical `billing/` tree.
- Do not remove the legacy `Project` compatibility surface yet.
- Do not move `delivery` out of `ordering` before its ownership contract is defined.
- Do not redesign payment, capacity, invoicing, or fulfillment internals.

## Target Boundary

`ordering` should own the customer order lifecycle and expose stable contracts for:

- creating and updating an order
- validating a submission
- placing or confirming an order
- reading order listings and details
- exposing order-specific presentation data
- publishing order lifecycle facts

Cross-domain work should be invoked through explicit ports or event contracts rather than concrete jobs and classes from downstream domains.

## First Implementation Slice: Follow-Up Ports

Replace direct calls from `ProcessSubmission` to concrete follow-up implementations:

```ruby
Billing::Application::Handlers::GenerateInvoiceJob.perform_later(payment.id)
NotificationJob.perform_later(submission.order.id)
```

with injected contracts for:

- invoice follow-up
- notification follow-up

The default adapters may continue to call the current jobs. This first slice must preserve:

- follow-ups only after the payment success checkpoint
- no follow-ups after validation or payment failure
- retry-safe behavior
- the existing result contract

## Phased Plan

### Phase 1: Stabilize the current contract

- [x] Keep `ProcessSubmission` behavior unchanged while introducing explicit follow-up dependencies.
- [x] Add specs for follow-up success, failure, and non-execution paths.
- [x] Document the result contract for success and failure.
- [x] Confirm the current order lifecycle states and transition policies.

### Phase 2: Reduce downstream coupling

- [x] Define payment, availability, capacity, invoicing, and notification ports at the correct boundary.
- [x] Remove concrete `Billing::` and `NotificationJob` references from the ordering workflow core.
- [x] Add architecture specs for ordering port boundaries and composition-root wiring.
- [x] Decide whether the submission saga belongs outside the ordering boundary.
- [ ] Break package cycles through contracts, events, or read models.

### Phase 3: Normalize submission input

- [ ] Replace `respond_to?` compatibility branches in `Submission` with an explicit input contract.
- [ ] Define the minimum order, customer, line item, source video, payment, and fulfillment identity data required by submission.
- [ ] Keep Rails models and legacy `Project` objects at the adapter edge.
- [ ] Add contract specs for the normalized submission DTO.

### Submission Saga Migration Plan

The submission saga belongs outside `ordering` because it coordinates availability, capacity, payment, invoicing, and notifications. The target owner is the neutral marketplace workflow boundary:

```text
Marketplace::Application::Workflows::Checkout
```

`Checkout` owns orchestration and compensation, while `ordering` owns the order aggregate, lifecycle rules, submission input contract, and order lifecycle facts.

Migration sequence:

1. Create `Marketplace::Application::Workflows::Checkout` with the current `Core::Result` contract.
2. Move the orchestration currently implemented by `Ordering::Application::Commands::ProcessSubmission` into `Checkout`.
3. Keep payment, availability, capacity, invoicing, and notification ports as workflow dependencies.
4. Turn `Fulfillment::Application::Commands::SubmitOrder` into a temporary compatibility facade that prepares the order and delegates to `Checkout`.
5. Move order/selections preparation into an ordering-owned command where it is not already part of the aggregate contract.
6. Update controllers and application callers to invoke `Checkout` directly.
7. Preserve compensation behavior: release capacity after payment or checkpoint failure, and enqueue invoice/notification work only after capacity commit.
8. Add workflow specs for step ordering, compensation, result mapping, and port isolation.
9. Remove `Ordering::Application::Commands::ProcessSubmission` after all callers migrate.
10. Remove the temporary fulfillment facade and update package dependencies after the workflow boundary is stable.

Implementation phases:

### Checkout Phase 1: Add the workflow

- [ ] Create `Marketplace::Application::Workflows::Checkout`.
- [ ] Require explicit payment, availability, capacity, invoicing, and notification ports.
- [ ] Preserve the current `Core::Result` success and failure contract.
- [ ] Preserve the order of reserve, payment, commit, and follow-up operations.
- [ ] Preserve capacity compensation after payment or checkpoint failure.
- [ ] Add parity specs without deleting `ProcessSubmission` yet.

Commit sequence:

1. `feat: add Marketplace Checkout workflow`
2. `test: cover Checkout workflow parity`

### Checkout Phase 2: Move ownership and wiring

- [ ] Move the workflow-facing ports to `Marketplace::Application::Ports`.
- [ ] Move or recreate outbound adapters under `Marketplace::Adapters::Outbound`.
- [ ] Keep downstream implementation details out of the Checkout workflow.
- [ ] Make `Fulfillment::Application::Commands::SubmitOrder` delegate to Checkout.
- [ ] Keep SubmitOrder as a temporary compatibility facade for controller callers.
- [ ] Add architecture specs for Marketplace port ownership and composition-root wiring.

Commit sequence:

1. `refactor: move Checkout ports to Marketplace`
2. `refactor: wire SubmitOrder through Checkout`
3. `test: guard Marketplace workflow boundaries`

### Checkout Phase 3: Retire the ordering saga

- [ ] Migrate all direct `ProcessSubmission` callers to Checkout or the compatibility facade.
- [ ] Confirm no production callers depend on `Ordering::Application::Commands::ProcessSubmission`.
- [ ] Remove the duplicated ProcessSubmission orchestration.
- [ ] Remove obsolete Ordering ports and adapters after all consumers migrate.
- [ ] Remove the temporary Fulfillment facade if no longer needed.
- [ ] Update package dependencies and verify there are no cycles.

Commit sequence:

1. `refactor: migrate submission callers to Checkout`
2. `refactor: remove ordering submission saga`
3. `docs: finalize Checkout boundary`

Responsibility boundaries:

- `Marketplace::Application::Workflows::Checkout`: cross-domain orchestration and compensation.
- `Ordering`: order lifecycle, order data, submission validation, and lifecycle events.
- `Catalog`: offering availability rules.
- `Capacity`: reservations, commits, releases, and expiration.
- `Payments`: payment lifecycle, gateways, refunds, and reconciliation.
- `Billing`: invoice generation and invoice delivery.
- `Notifications`: notification creation, channels, dispatch, and retry.
- `Fulfillment`: production and delivery operations after checkout.

### Phase 4: Separate persistence ownership

- [ ] Document whether `orders` is the ordering write model, read model, or both.
- [ ] Isolate `sync_order_listing!` from the legacy `Project` model.
- [ ] Define the migration path from `projects` persistence to order-owned persistence.
- [ ] Ensure capacity and other domains consume an explicit order projection instead of reaching into ordering internals.

### Phase 5: Prepare extraction

- [ ] Move all ordering adapters and their persistence records under the ordering boundary.
- [ ] Define an external API or SDK contract for order operations and queries.
- [ ] Define event contracts for order placed, confirmed, cancelled, completed, and payment failed.
- [ ] Run the ordering contract suite independently from downstream implementation details.

### Phase 6: Extract to a standalone app

- [ ] Create the standalone Rails application only after the contracts and data ownership are stable.
- [ ] Move ordering domain, application, persistence, and presentation code into the new app.
- [ ] Keep the marketplace shell as an API/SDK consumer.
- [ ] Retire compatibility shims only after all consumers use the new order contract.

## Proposed Commit Sequence

1. `docs: add ordering extraction prep work item`
2. `refactor: inject ordering follow-up jobs`
3. `test: cover ordering follow-up ports`
4. `refactor: normalize ordering submission input`
5. `refactor: isolate ordering persistence ownership`
6. `docs: define ordering extraction contracts`
7. `feat: extract ordering application`

Each commit should preserve the current runtime behavior and remain independently verifiable.

## Validation

- [ ] Existing ordering unit specs remain green.
- [ ] Follow-up jobs are still enqueued only after the success checkpoint.
- [ ] Ordering tests no longer need concrete invoicing or notification implementations for workflow-core behavior.
- [ ] The package dependency graph has no new cycles.
- [ ] Legacy `Project` compatibility remains covered while migration is in progress.
- [ ] The ordering public contract is documented before extraction begins.

## Review Questions

- Should submission orchestration remain inside `ordering`, or become a separate marketplace workflow boundary?
- Is `orders` currently a read model, a write model, or a transitional projection?
- Which order lifecycle events are public contracts for downstream domains?
- Should `delivery_status` remain part of the order aggregate until the delivery boundary is extracted?
- What is the minimum external API needed by the storefront and operator shell?

## Notes

- This is a preparation plan, not an extraction implementation.
- The first code slice is intentionally small: replace direct follow-up job calls with explicit ports.
- `ProcessSubmission` no longer accepts legacy follow-up keywords; concrete invoicing and notification adapters are composed by `SubmitOrder`.
- Package-cycle analysis and the dependency-breakdown plan live in `01-package-cycle-breakdown.md`.
- `billing` remains the physical namespace; `invoicing` remains the product vocabulary.
- The main unresolved architectural boundary is the split between `ordering` submission workflow and `fulfillment` operational work.
