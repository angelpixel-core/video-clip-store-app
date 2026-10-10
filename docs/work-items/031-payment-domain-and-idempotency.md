---
id: payment-domain-idempotency
aliases: []
tags:
  - work-items
  - payment
  - domain
  - idempotency
  - backend
depends_on:
  - payment-details-card-flip
order: 31
phase: work-items
status: done
title: Payment Domain and Idempotency
---

# Payment Domain and Idempotency

## Goal

- [x] Model payments as first-class records and make checkout idempotent before any provider integration is added.

## Scope

- Introduce a `Payment` record separate from `Order`.
- Track payment attempts, provider references, and a durable idempotency key.
- Prevent duplicate payment creation when the client retries submission.
- Allow multiple historical payments per order while keeping one active payment at a time.
- Keep the payment state machine small and explicit.

## Operational Note

- This item establishes the payment domain boundary.
- Do not call a real provider here; the provider adapter comes in the next work item.

## Implementation Plan

- [x] Add `Payment` and `PaymentAttempt` persistence with status, provider, provider reference, and idempotency key fields.
- [x] Add model validations and unique constraints that prevent duplicate payment attempts for the same idempotency key.
- [x] Add a service that creates or reuses the payment attempt for a submission request.
- [x] Add tests for duplicate submission reuse and the initial payment state transitions.

## Affected Docs

- `docs/sprints/00-foundation/01-scope.md`
- `docs/work-items/030-payment-details-card-flip.md`

## Affected Ops

- `db/migrate/`
- `app/models/`
- `app/services/`
- `spec/models/`
- `spec/services/`

## Checklist

- [x] One checkout submission creates one active payment record.
- [x] Repeated submission requests reuse the same idempotent payment attempt.
- [x] Duplicate idempotency keys cannot create a second payment attempt.

## Validation

- [x] Model and service specs pass.
- [x] The payment domain can be created without a provider integration.

## Notes

- Keep the `Order` model focused on order lifecycle; payment state should live in the payment domain.
- One active payment per order is enforced in the service/model layer; completed or failed payments remain historical.
