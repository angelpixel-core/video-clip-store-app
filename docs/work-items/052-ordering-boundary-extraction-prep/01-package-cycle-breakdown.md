---
title: Ordering Package Cycle Breakdown
work_item: ordering-boundary-extraction-prep
status: planned
tags:
  - ordering
  - boundaries
  - package-cycles
  - architecture
---

# Ordering Package Cycle Breakdown

## Goal

Break cross-domain package cycles without moving implementation into the wrong boundary. Domain and application layers should depend on contracts, events, or read models; concrete cross-domain wiring belongs in Marketplace workflows and adapters.

## Cycles Identified

1. `ordering -> billing -> ordering`
2. `billing -> payments -> billing`
3. `ordering -> capacity -> ordering`
4. `catalog -> capacity` is used in code but is not declared in `catalog/package.yml`.
5. `ordering -> catalog` combined with Catalog's indirect Capacity rule creates an undeclared transitive dependency.

## Target Dependency Rule

Domain and application cores must not import concrete downstream domain classes. Cross-domain dependencies may exist only in:

- `Marketplace::Application::Workflows::Checkout`
- outbound and inbound adapters
- event consumers and projectors
- local read-model implementations

## Cycle Breakdowns

### Ordering and Billing

Ordering should invoke an invoicing port owned by the workflow boundary. Billing should consume an `InvoiceRequest` contract or payment-success event rather than importing Ordering aggregates or policies.

Preferred mechanism: invoicing port during migration, followed by an event contract.

### Billing and Payments

Payments should publish a `PaymentCaptured` event containing the minimum invoice snapshot:

- payment id
- order/project id
- amount and currency
- provider
- billing identity
- invoice line data or an immutable invoice input reference

Billing consumes the event and generates the invoice without querying the Payments aggregate. Payment aggregates must not dispatch Billing jobs directly.

Preferred mechanism: domain event plus immutable snapshot.

### Ordering and Capacity

Capacity should consume an `OrderWorkloadSnapshot` containing only the data required for workload calculation:

- order id
- units
- production period
- relevant order status

Capacity must not load the Ordering aggregate. A local workload read model is preferred for queries, with order lifecycle events updating it.

Preferred mechanism: events for changes and a local read model for queries.

### Catalog and Capacity

Catalog should own commercial offering availability. Capacity is an operational concern and should be coordinated by Checkout rather than by Catalog's domain policy.

If Catalog requires capacity data, define a Catalog-owned `CapacityAvailability` port backed by a Capacity read model. Do not call `Capacity::Domain::Policies` directly from Catalog.

Preferred mechanism: remove the dependency where possible; otherwise use a Catalog-owned port.

## Planned Dependency Graph

```text
Marketplace::Checkout
  -> Ordering contracts
  -> Catalog contracts
  -> Capacity contracts
  -> Payment contracts
  -> Invoicing contracts
  -> Notification contracts

Ordering
  -> shared contracts and identity only

Payments <-> Billing
  -> events and immutable snapshots, no reciprocal concrete imports

Capacity
  -> workload events and local read models

Catalog
  -> offering availability and optional capacity port
```

## Implementation Sequence

1. Create `Marketplace::Application::Workflows::Checkout` and move submission orchestration there.
2. Remove downstream dependencies from `ordering/package.yml`.
3. Define and publish the `PaymentCaptured` event contract.
4. Migrate Billing to consume the event and remove direct Payment aggregate access.
5. Define `OrderWorkloadSnapshot` and migrate Capacity to consume it.
6. Remove Capacity's direct Ordering dependency.
7. Separate Catalog availability from operational Capacity rules.
8. Update all `package.yml` manifests and validate the dependency graph.
9. Add architecture specs that prevent prohibited imports and undeclared dependencies.

## Acceptance Criteria

- [ ] `ordering/package.yml` has no concrete downstream domain dependencies.
- [ ] Billing and Payments communicate through events or stable contracts.
- [ ] Capacity consumes workload data without loading Ordering aggregates.
- [ ] Catalog does not call Capacity domain policies directly.
- [ ] All package dependencies are declared and acyclic.
- [ ] Architecture specs fail when a prohibited cross-domain import is added.
- [ ] Existing runtime behavior and compensation semantics remain unchanged.
