---
id: payment-webhook-ingestion
aliases: []
tags:
  - work-items
  - payment
  - webhook
  - ingestion
  - events
depends_on:
  - payment-domain-idempotency
  - payment-provider-fake
order: 33
phase: work-items
status: done
title: Payment Webhook Ingestion
---

# Payment Webhook Ingestion

## Goal

- [x] Add a webhook endpoint that records provider events and ignores duplicate deliveries.

## Scope

- Create a provider webhook route and controller.
- Persist raw webhook payloads with provider event ids and basic authenticity metadata.
- Deduplicate repeated deliveries before they reach business logic.
- Add a local rake task that simulates an asynchronous provider callback by POSTing a signed event to the webhook endpoint.

## Operational Note

- This item only ingests and stores events.
- It should not transition payment state directly; the handler pipeline owns that.

## Implementation Plan

- [x] Add the webhook route and controller action for provider events.
- [x] Persist incoming payloads in a raw event table with a unique provider event id.
- [x] Reject or ignore duplicate webhook deliveries without reprocessing them.
- [x] Add a `payments:simulate_webhook` rake task for local async-response simulation.

## Affected Docs

- `docs/work-items/031-payment-domain-and-idempotency.md`
- `docs/work-items/032-payment-provider-fake.md`
- `docs/sprints/00-foundation/01-scope.md`

## Affected Ops

- `config/routes.rb`
- `app/controllers/`
- `app/models/`
- `lib/tasks/`
- `spec/requests/`

## Checklist

- [x] A webhook event is stored once even if the provider retries delivery.
- [x] The simulated webhook task can replay a fake provider event locally.
- [x] Duplicate payloads do not create duplicate payment side effects.

## Validation

- [x] Request specs cover valid, invalid, and duplicate webhook deliveries.
- [x] The simulation task works in development and test.

## Notes

- Keep the controller thin: receive, validate, persist, and hand off.
