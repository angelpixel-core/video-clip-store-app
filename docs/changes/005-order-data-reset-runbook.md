---
id: order-data-reset-runbook
title: Order Data Reset Runbook
phase: changes
order: 5
aliases: []
tags:
  - changes
  - runbook
  - cleanup
  - orders
  - data-reset
---

# Order Data Reset Runbook

## Goal

- [x] Reset all order-owned data and demo workspace records while preserving video types.

## When To Use

- Rebuild a local demo database from scratch.
- Clear stale orders, payments, notifications, comments, webhook history, and demo workspace records.
- Prepare a clean environment for validating order setup flows.

## What Gets Removed

- `projects`
- `video_type_selections`
- `payments`
- `payment_attempts`
- `payment_webhook_events`
- `payment_webhook_event_attempts`
- `payment_notification_intents`
- `comments`
- `notifications`

## What Stays

- `video_types`

## Command

```bash
make maintenance/reset_order_data DRY_RUN=1
```

```bash
make maintenance/reset_order_data CONFIRM=YES
```

## Expected Result

- The dry run prints row counts for every order-owned table and workspace fixture table.
- The confirmed run deletes those rows in dependency-safe order.
- Video types remain untouched.

## Verify

1. Open a Rails console and confirm the `clients` and `pms` tables are empty while `VideoType.count` remains non-zero.
2. Confirm `Order.count`, `Payment.count`, `Comment.count`, and `Notification.count` are `0`.
3. Confirm `PaymentWebhookEvent.count` and `PaymentNotificationIntent.count` are `0`.

## Notes

- Run this only when you really want to wipe all order data.
- `DRY_RUN=1` is safe and prints what will be deleted without changing the database.
- The task now removes demo workspace records too, so fresh runs should bootstrap users again if needed.
