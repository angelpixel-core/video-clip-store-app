---
id: payments-domain-popo-decoupling
aliases: []
tags:
  - work-items
  - architecture
  - payments
  - domain
  - persistence
  - active-record
  - popo
depends_on:
  - rails-interface-layer-by-context
order: 60
phase: work-items
status: in-progress
title: Payments Domain POPO and ActiveRecord Persistence Decoupling (Phase 4)
---

# Payments Domain POPO and ActiveRecord Persistence Decoupling (Phase 4)

## Goal

- [ ] Decouple `app/contexts/payments/domain/` (`Payments::Domain::Aggregates::Payment` and `Payments::Domain::Entities::*`) from `ApplicationRecord`, ActiveStorage, and `after_commit` framework callbacks.
- [ ] Introduce explicit ActiveRecord persistence records (`PaymentRecord`, `PaymentAttemptRecord`, `RefundRecord`, etc.) and Mappers under `app/contexts/payments/infrastructure/persistence/` matching the pattern used in `billing`, `identity`, `capacity`, and `ordering`.

## Scope

- `app/contexts/payments/domain/aggregates/payment.rb`
- `app/contexts/payments/domain/entities/*`
- `app/contexts/payments/infrastructure/persistence/*`
- `app/contexts/payments/application/commands/*`

## Affected Docs

- `docs/work-items/060-payments-domain-popo-decoupling.md`
- `docs/work-items/index.md`
- `docs/payments.md`

## Affected Ops

- `app/contexts/payments/**`
- `spec/unit/contexts/payments/**`

## Implementation Plan

- [x] **Step 1: Extract ActiveRecord Persistence Records in `payments/infrastructure/persistence/`**
  - [x] Create/extract ActiveRecord record classes (`PaymentRecord`, `PaymentAttemptRecord`, `PaymentMethodReferenceRecord`, `RefundRecord`, `PaymentWebhookEventRecord`, `PaymentWebhookEventAttemptRecord`, `PaymentNotificationIntentRecord`, `PaymentInvoiceDeliveryIntentRecord`) bound to their existing database tables (`self.table_name = ...`).
  - [x] Build bidirectional `Mapper` classes in `app/contexts/payments/infrastructure/persistence/` following the `billing` and `ordering` mapper pattern.
- [x] **Step 2: Convert `payments/domain/` Classes to Pure Ruby Domain Objects (POPOs)**
  - [x] Refactor `Payments::Domain::Aggregates::Payment` and `Payments::Domain::Entities::*` into framework-free domain classes enforcing domain invariants and transitions.
- [ ] **Step 3: Move Side-Effect Callbacks (`after_commit`) to Application Layer**
  - [ ] Move invoice generation job enqueueing and ActionCable status broadcasting out of ActiveRecord `after_commit` callbacks into explicit Application Command / Event Handler steps.
- [ ] **Step 4: Update Repositories and Specs**
  - [ ] Update `Payments::Infrastructure::Persistence::Payment::Repository` and `Webhook::Event::Repository` to persist and hydrate via the new records/mappers.
  - [ ] Update unit, request, and system specs.

## Checklist

- [x] Zero classes inside `app/contexts/payments/domain/` inherit from `ApplicationRecord`.
- [x] All persistence records and mappers for `payments` live under `app/contexts/payments/infrastructure/persistence/`.
- [ ] Invoice generation and realtime UI broadcasts are triggered explicitly by application use cases/handlers rather than hidden model callbacks.

## Validation

- [ ] `bundle exec rails zeitwerk:check` passes cleanly.
- [ ] Full unit, request, and system test suites (`payment_modal_*`, `project_show_payment_history_spec`, `webhooks_spec`) pass with 0 failures.
- [ ] `bundle exec rubocop` passes with 0 offenses.

