---
id: payment-history-on-project-show
aliases: []
tags:
  - work-items
  - payment
  - project
  - show
  - pm
  - history
depends_on:
  - payment-event-handler-pipeline
  - payment-webhook-ingestion
order: 37
phase: work-items
status: done
title: Payment History on Order Show
---

# Payment History on Order Show

## Goal

- [x] Show PM-only payment history on the order detail page, including payment attempts and webhook events.

## Scope

- Display payment history only in the PM workspace.
- Include both `payment_attempts` and `payment_webhook_events` in the history view.
- Keep the client workspace unchanged.
- Reuse the existing role-scoping convention instead of adding new JS.

## Implementation Plan

- [x] Load the order payments on the show page.
- [x] Add a PM-only payment history section to the order detail view.
- [x] Render payment attempts and webhook events in a readable timeline/card format.
- [x] Add a system spec that verifies the client cannot see the section and the PM can.

## Affected Docs

- `docs/work-items/034-payment-event-handler-pipeline.md`

## Affected Ops

- `app/controllers/projects_controller.rb`
- `app/models/payment.rb`
- `app/models/payment_webhook_event.rb`
- `app/views/projects/`
- `spec/system/`

## Checklist

- [x] PMs can inspect payment attempts and webhook events from the order show page.
- [x] Clients do not see the payment history section.

## Validation

- [x] System spec covers PM visibility and client hiding.

## Notes

- The view uses the existing `data-role-scope="pm"` gating.
