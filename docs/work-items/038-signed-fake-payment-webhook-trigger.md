---
id: signed-fake-payment-webhook-trigger
aliases: []
tags:
  - work-items
  - payment
  - webhook
  - rake
  - make
  - tooling
depends_on:
  - payment-webhook-ingestion
  - payment-event-handler-pipeline
order: 38
phase: work-items
status: done
title: Signed Fake Payment Webhook Trigger
---

# Signed Fake Payment Webhook Trigger

## Goal

- [x] Provide a local rake/make trigger for sending a signed fake `payment.succeeded` webhook.

## Scope

- Keep the existing generic webhook simulator task.
- Add a convenience task that defaults to a successful payment webhook.
- Allow the trigger to take `PROJECT_ID` and resolve the current order payment automatically.
- Add a `make` wrapper so the trigger can run from the repo root.

## Implementation Plan

- [x] Add a rake task that sends a signed fake webhook with `payment.succeeded` as the default type.
- [x] Allow the rake task to resolve the payment from `PROJECT_ID` when present.
- [x] Fall back to the most recent payment if the order no longer has an active payment.
- [x] Add a `make` wrapper for the new rake task.
- [x] Keep env-var overrides for local demos and testing.
- [x] Add specs for the new task.

## Affected Docs

- `docs/work-items/033-payment-webhook-ingestion.md`
- `docs/work-items/034-payment-event-handler-pipeline.md`

## Affected Ops

- `lib/tasks/payments.rake`
- `Makefile`
- `spec/unit/tasks/`

## Checklist

- [x] The repo can trigger a signed fake successful payment webhook from `rake`.
- [x] The repo can target the active payment for an order from `rake`.
- [x] The repo can target the most recent payment for an order from `rake` when no active payment exists.
- [x] The repo can trigger the same flow from `make`.

## Validation

- [x] Task specs pass.

## Notes

- This is a convenience wrapper over the existing webhook simulator.
- `PROJECT_ID` takes precedence when provided so local demos can target the payment associated with the order, even if it is no longer active.
