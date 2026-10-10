---
id: payment-outbound-notifications
aliases: []
tags:
  - work-items
  - payment
  - notifications
  - mail
  - outbox
  - workflow
depends_on:
  - payment-event-handler-pipeline
  - payment-retry-observability
  - mail-delivery-environment-setup
  - notification-delivery-channels
order: 39
phase: work-items
status: done
title: Payment Outbound Notifications
---

# Payment Outbound Notifications

## Goal

- [x] Persist payment state changes and their outbound notification intents atomically, then deliver emails and other subscribers asynchronously after commit.

## Scope

- Capture payment success and payment failure notifications as part of the same business transaction that changes payment state.
- Keep controllers thin; the payment state transition and notification intent should happen in a `use_cases` layer.
- Deliver emails asynchronously after commit so the transaction does not wait on slow side effects.
- Allow multiple subscribers for the same payment event, including email and logging.
- Keep demo/test flags out of domain objects and model parameters.

## Mail Matrix

| Event | Client | PM | Templates |
|---|---|---|---|
| `project_created` | Yes | Yes | `text` + `html` |
| `project_accepted` | Yes | Yes | `text` + `html` |
| `project_rejected` | Yes | Yes | `text` + `html` |
| `payment_failed` | Yes | Yes | `text` + `html` |
| `payment_succeeded` | Yes | Yes | `text` + `html` |

## Content Rules

- Client emails should stay short and action-oriented.
- PM emails should be more detailed and operational.
- `project_rejected` should be prepared even though the reject action does not exist yet.
- Payment emails should go to both the client and the PM.
- Every mail should have both a text and an HTML template.

## Operational Note

- The transaction should own the state change and the notification intent.
- The actual mail delivery must happen outside the transaction, via job or outbox processing.
- Logger-based notification is a first-class subscriber, not a special case in controller code.

## Architecture

- `controllers`: only HTTP, params, and response.
- `use_cases`: business orchestration.
- `repositories`: local persistence access.
- `services`: external side effects.
- `domain`: pure events and value objects.

## Proposed Flow

1. A payment use case changes `Payment#status`.
2. In the same transaction, it creates a `notification_intent` or outbox event.
3. A job processes the intent after commit.
4. A dispatcher fans out to services:
    - email
    - logger
    - future subscribers

## Proposed Mailers

- `app/mailers/pm_notification_mailer.rb`
- `app/mailers/client_notification_mailer.rb`
- `app/mailers/payment_notification_mailer.rb`

## Proposed Templates

- `app/views/pm_notification_mailer/*.text.erb`
- `app/views/pm_notification_mailer/*.html.erb`
- `app/views/client_notification_mailer/*.text.erb`
- `app/views/client_notification_mailer/*.html.erb`
- `app/views/payment_notification_mailer/*.text.erb`
- `app/views/payment_notification_mailer/*.html.erb`

## Proposed Files

- `app/use_cases/payments/confirm.rb`
- `app/use_cases/payments/fail.rb`
- `app/use_cases/payment_notifications/record_intent.rb`
- `app/use_cases/payment_notifications/dispatch.rb`
- `app/repositories/payment_notification_intent_repository.rb`
- `app/repositories/payment_repository.rb`
- `app/services/payment_notifications/email_service.rb`
- `app/services/payment_notifications/logger_service.rb`
- `app/services/payment_notifications/dispatcher.rb`
- `app/domain/payment_status_changed.rb`
- `app/domain/payment_notification_intent.rb`
- `app/jobs/payment_notification_dispatcher_job.rb`

## Implementation Plan

- [x] Introduce a domain event or notification intent for payment state transitions.
- [x] Persist outbound notification intent in the same transaction that updates payment status.
- [x] Add an async worker to dispatch payment notification intents after commit.
- [x] Implement customer mail notifications for payment success and payment failure.
- [x] Wire logger notifications as an additional subscriber.
- [x] Add specs for atomic state change + intent persistence, plus async delivery behavior.

## Contracts

### `app/use_cases/payments/confirm.rb`
- Input: `payment_id`, optional context
- Responsibility: update payment state and persist notification intent
- Output: success or failure result

### `app/use_cases/payments/fail.rb`
- Input: `payment_id`, optional context
- Responsibility: mark payment failed and persist notification intent
- Output: success or failure result

### `app/use_cases/payment_notifications/record_intent.rb`
- Input: `Payments::Domain::Entities::PaymentNotificationIntent`
- Responsibility: create the outbox row
- Output: persisted intent

### `app/services/payment_notifications/dispatcher.rb`
- Input: intent
- Responsibility: call subscribers based on event type/state
- Output: dispatch result

### `app/services/payment_notifications/email_service.rb`
- Responsibility: send payment success/failure mail
- Must not decide business rules

### `app/services/payment_notifications/logger_service.rb`
- Responsibility: audit/log the notification
- Must not decide business rules

## Email Events

### `project_created`
- Send to the client and the PM.
- Use separate content for each recipient.

### `project_accepted`
- Send to the client and the PM.
- Content should describe the next workflow step.

### `project_rejected`
- Send to the client and the PM.
- Keep the mailer/template ready for a future reject action.

### `payment_failed`
- Send to the client and the PM.
- Include the failure reason and the retry context when available.

### `payment_succeeded`
- Send to the client and the PM.
- Include the successful payment context and the relevant amounts.

## Current Slice

- [x] Persist payment notification intents on payment state change.
- [x] Enqueue `PaymentNotificationDispatcherJob` after commit when an intent is created.
- [x] Dispatch intents through a dedicated `PaymentNotifications::Dispatcher` service.
- [x] Provide a logger subscriber as the first delivery channel.
- [x] Add customer mail notifications and any additional subscribers.

## Affected Docs

- `docs/work-items/031-payment-domain-and-idempotency.md`
- `docs/work-items/034-payment-event-handler-pipeline.md`
- `docs/work-items/035-payment-retry-and-observability.md`
- `docs/work-items/018-mail-delivery-environment-setup.md`
- `docs/work-items/040-payment-invoice-generation-and-storage.md`

## Affected Ops

- `app/controllers/`
- `app/use_cases/`
- `app/repositories/`
- `app/services/`
- `app/domain/`
- `app/jobs/`
- `app/mailers/`
- `app/models/`
- `spec/mailers/`
- `spec/unit/`
- `spec/requests/`
- `spec/system/`

## Checklist

- [x] Payment success persists the state change and notification intent atomically.
- [x] Payment failure persists the state change and notification intent atomically.
- [x] The email send happens async after the transaction commits.
- [x] Multiple notification subscribers can react to the same payment event.
- [x] Demo/test-only flags are not part of domain models or controller params.

## Validation

- [x] Specs cover success and failure notification paths.
- [x] Specs cover async delivery and duplicate-safe behavior.
- [x] The flow remains safe if a notification worker retries.

## Notes

- Prefer a small orchestration layer over putting side-effect logic in controllers.
- If a repository abstraction is introduced later, keep it focused on local persistence and not on external side effects.
