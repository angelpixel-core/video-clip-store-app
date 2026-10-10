---
id: payment-retry-demo-runbook
title: Payment Retry Demo Runbook
phase: changes
order: 4
aliases: []
tags:
  - changes
  - runbook
  - payments
  - retry
  - demo
---

# Payment Retry Demo Runbook

## Goal

- [x] Reproduce the payment retry flow from the terminal with a deterministic one-time failure.

## When To Use

- Show that the payment webhook job retries automatically.
- Verify the audit trail on a webhook event after a transient failure.
- Demo local recovery without using the UI.

## Demo Command

```bash
DEMO_FAIL_ONCE=1 make payments/send_signed_fake_webhook PROJECT_ID=<project_id> EVENT_ID=evt_retry
```

## Expected Result

- The first job attempt fails with `Demo transient webhook failure.`
- The job retries automatically.
- The event ends as `processed`.
- `processing_attempts_count` reaches `2`.
- The payment history shows separate `Attempt #1` and `Attempt #2` rows under the webhook event.
- `last_failure_message` stays populated with the demo failure message.

## Verify

1. Refresh the PM payment history on the order show page.
2. Confirm the event shows the retry metadata.
3. Confirm the payment itself is still only created once and ends in `succeeded`.

## Manual Replay

```bash
make payments/replay_failed_webhook_events
```

```bash
EVENT_ID=evt_retry make payments/replay_webhook_event
```

## Notes

- `DEMO_FAIL_ONCE=1` is demo-only.
- `PROJECT_ID` is preferred; `PAYMENT_ID` still works as an override.
