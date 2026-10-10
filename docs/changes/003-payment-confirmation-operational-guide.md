---
id: payment-confirmation-operational-guide
title: Payment Confirmation Operational Guide
phase: changes
order: 3
aliases: []
tags:
  - changes
  - runbook
  - payments
  - local
  - qa
  - demo
---

# Payment Confirmation Operational Guide

## Goal

- [x] Reproduce the full payment confirmation flow locally and in QA demos.

## Overview

- Use this when an order is stuck in `processing` and you need to confirm the webhook pipeline end to end.
- Use this for local development, QA demos, and troubleshooting payment confirmations.
- The trigger sends a signed `payment.succeeded` webhook and resolves the payment from `PROJECT_ID` when available.

## Prerequisites

- An order with at least one payment.
- The web app and worker running.
- `DEFAULT_CLIENT_WORKSPACE_EMAIL` and `DEFAULT_PM_WORKSPACE_EMAIL` set in the environment.

## Local Dev

1. Create or pick an order with a payment.
2. Confirm the current payment state in the order show page.
3. Run the signed trigger from the repo root:

```bash
make payments/send_signed_fake_webhook PROJECT_ID=<project_id>
```

4. Example with a real local order id:

```bash
make payments/send_signed_fake_webhook PROJECT_ID=4
```

5. If you want to target a specific payment directly:

```bash
make payments/send_signed_fake_webhook PAYMENT_ID=4
```

6. Watch the logs for:
- `POST "/payments/webhooks/fake/events"`
- `Enqueued Payments::ProcessWebhookEventJob`
- `Performed Payments::ProcessWebhookEventJob`

7. Refresh the order show page.
8. Confirm:
- payment status becomes `succeeded`
- `confirmed_at` is present
- payment history shows `Confirmed`
- webhook history shows `processed`

## QA Demo

1. Use a QA order that is still waiting on payment confirmation.
2. Point the trigger at the QA webhook endpoint and the QA order id:

```bash
WEBHOOK_URL=https://qa.example.com/payments/webhooks/fake/events \
  make payments/send_signed_fake_webhook PROJECT_ID=4
```

3. If the order has no active payment, the trigger falls back to the most recent payment.
4. Confirm the PM view shows the payment history and the client view does not.

## Retry Demo

1. Pick an order with an active or recent payment.
2. Run the signed trigger with the demo fail flag:

```bash
DEMO_FAIL_ONCE=1 make payments/send_signed_fake_webhook PROJECT_ID=<project_id> EVENT_ID=evt_retry
```

3. Confirm the first attempt fails transiently and the job retries automatically.
4. Check the payment history or logs for:
- `processing_attempts_count = 2`
- `last_failure_message = Demo transient webhook failure.`
- event status ending in `processed`
- separate `Attempt #1` and `Attempt #2` rows under the webhook event
5. If you want to replay a failed or received event manually:

```bash
make payments/replay_failed_webhook_events
```

6. To replay a single event by provider event id:

```bash
EVENT_ID=evt_retry make payments/replay_webhook_event
```

## Troubleshooting

- If the payment stays `processing`, check whether the worker is running.
- If the task aborts with no payment, confirm the order id and payment history.
- If the webhook logs appear but nothing changes, inspect the worker logs for `Payments::ProcessWebhookEventJob`.
- If the order is already terminal, the webhook event may be accepted but treated as stale.

## Notes

- `PROJECT_ID` is the preferred input for the trigger.
- `PAYMENT_ID` still works as an explicit override.
- `WEBHOOK_URL` defaults to the local app endpoint, so local demos usually only need `PROJECT_ID`.
- `DEMO_FAIL_ONCE=1` is for demos only and forces one transient failure before the job succeeds on retry.
