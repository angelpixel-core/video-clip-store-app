---
id: order-reopen-and-refund-review-flow
aliases: []
tags:
  - work-items
  - orders
  - payment
  - refund
  - workflow
  - review
depends_on:
  - order-workflow-orchestration
  - payment-domain-and-idempotency
  - payment-outbound-notifications
order: 47
phase: work-items
status: done
title: Order Reopen and Refund Review Flow
---

# Order Reopen and Refund Review Flow

## Goal

- [x] Define the exact state/action matrix for client cancellation, client reopen, client refund request, and PM refund review.

## Scope

- Keep `cancelled` reversible by the client through `retomar orden`.
- Keep refund requests separate from refunds themselves.
- Allow the client to cancel before payment success.
- Block cancel once `payment.succeeded` has happened.
- Allow the client to request a refund only when the feature flag is enabled.
- Keep PM/operator as the only actor that can approve, reject, and forward the refund.
- Show the refund as "en proceso" immediately after PM approval while the provider/webhook path finishes it.

## State Model

### Order States

| State | Meaning | Reversible |
| --- | --- | --- |
| `draft` | Editable draft before submission | Yes |
| `pending` | Submitted and waiting for PM or payment outcome | Yes |
| `in_progress` | Accepted by PM and moving forward | No |
| `completed` | Finished by PM | No |
| `cancelled` | Cancelled by client or PM before a successful payment | Yes, via reopen |

### Payment States

| State | Meaning |
| --- | --- |
| `unpaid` | No payment attempt yet |
| `pending` | Payment request started |
| `processing` | External gateway accepted the attempt but has not finalized yet |
| `succeeded` | External gateway confirmed success |
| `failed` | Attempt failed |
| `refunded` | Refund fully processed |

### Refund States

| State | Meaning |
| --- | --- |
| `refund_pending` | Operator review pending |
| `refund_processing` | Operator approved and provider/webhook processing is in flight |
| `failed` | Operator rejected or refund processing failed |

## Action Matrix

| Actor | Action | Precondition | Transition | Side Effects |
| --- | --- | --- | --- | --- |
| Client | `cancel-order` | Order is `pending` or `in_progress`, and no `payment.succeeded` exists | `pending|in_progress -> cancelled` | Stop any further order progress; no refund is created |
| PM | `cancel-order` | Same as client cancel, if the PM needs to intervene on an unpaid order | `pending|in_progress -> cancelled` | Stop any further order progress; no refund is created |
| Client | `retomar-orden` | Order is `cancelled` | `cancelled -> draft` | Restore editing flow |
| Client | `request-refund` | Feature flag enabled, order has `payment.succeeded`, and no pending/processing refund exists | `payment.succeeded -> refund_pending` | Notify PM/operator, block new payment attempts |
| PM | `approve-refund-request` | Refund request exists in `refund_pending` | `refund_pending -> refund_processing` | Forward refund to provider, show "refund en proceso", notify client |
| PM | `reject-refund-request` | Refund request exists in `refund_pending` | `refund_pending -> refund.failed` | Keep payment outcome unchanged, notify client |
| PM | `accept-order` | Order is `pending` and payment already succeeded | `pending -> in_progress` | Notify client and PM |
| PM | `complete-order` | Order is `in_progress` | `in_progress -> completed` | Notify client and PM |

## Rules

- `cancel-order` must become stale immediately once `payment.succeeded` exists.
- `retomar-orden` must always return to `draft`.
- `request-refund` is only a request; it never executes the refund directly.
- `approve-refund-request` and `reject-refund-request` are PM/operator-only.
- New payment attempts must be blocked while a refund is `refund_pending` or `refund_processing`.
- Once a refund is `refund_processing`, the order should be treated as closed from the payment side until the provider/webhook resolves it.

## Current Codebase

- `app/models/project.rb` and `app/domains/ordering/adapters/persistence/order/order_record.rb` already expose payment/refund helpers.
- `app/services/orders/action_service.rb` already routes `cancel`, `request_refund`, and PM refund review actions.
- `app/views/orders/show.html.erb` already has separate client and PM action areas.
- `app/views/orders/_client_order_actions.html.erb` already renders client-side actions.
- `app/views/orders/_workspace_order_actions.html.erb` already renders PM-side actions.

## Implementation Plan

- [x] Add `retomar-orden` for cancelled orders.
- [x] Ensure client cancel stays stale after `payment.succeeded`.
- [x] Keep refund request gated behind the client feature flag.
- [x] Keep PM approval/rejection separated from refund execution.
- [x] Add coverage for reopen, stale cancel, and refund review transitions.

## Notes

- The client should never execute the refund directly.
- The PM/operator owns the refund decision and forwarding step; the provider/webhook finishes the money movement.
- `cancelled` is an editing pause, not a terminal business end-state.
