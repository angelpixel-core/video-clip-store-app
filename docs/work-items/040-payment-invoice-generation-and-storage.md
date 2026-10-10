---
id: payment-invoice-generation-and-storage
aliases: []
tags:
  - work-items
  - payment
  - invoice
  - storage
  - mail
  - pdf
  - workflow
depends_on:
  - payment-outbound-notifications
  - payment-retry-observability
  - mail-delivery-environment-setup
order: 40
phase: work-items
status: done
title: Payment Invoice Generation and Storage
---

# Payment Invoice Generation and Storage

## Goal

- [x] Generate an invoice after a successful payment, store it durably, and notify the customer with the invoice attached or linked.

## Scope

- Trigger invoice generation only after the payment reaches a confirmed success state.
- Generate the invoice as a separate async step after the payment transaction commits.
- Store the generated invoice in durable storage via `ActiveStorage` as an HTML artifact.
- Send a follow-up email to the customer once the invoice is ready.
- Keep payment storage/card-data concerns separate from invoice storage.
- Do not introduce card credential persistence.

## Operational Note

- The payment state change should complete before invoice generation begins.
- Invoice generation is a downstream workflow step, not part of the payment transaction.
- The invoice artifact is a durable output asset, so storage is part of the domain flow.
- The initial implementation stores an HTML invoice attachment on the payment record and emails the customer after the invoice is attached.
- QA and production use S3-compatible object storage for ActiveStorage attachments; development and test stay on disk.

## Implementation Plan

- [x] Add an invoice generation step that runs after payment success is committed.
- [x] Persist invoice metadata on the payment domain model.
- [x] Generate the invoice artifact and store it in `ActiveStorage`.
- [x] Route QA and production attachments through object storage instead of local disk.
- [x] Enqueue a mail/send step when the invoice is available.
- [x] Add customer-facing email content for invoice delivery.
- [x] Add specs for success flow, storage persistence, and email delivery.

## Affected Docs

- `docs/work-items/031-payment-domain-and-idempotency.md`
- `docs/work-items/039-payment-outbound-notifications.md`
- `docs/work-items/035-payment-retry-and-observability.md`
- `docs/work-items/018-mail-delivery-environment-setup.md`

## Affected Ops

- `app/services/`
- `app/jobs/`
- `app/mailers/`
- `app/models/`
- `app/controllers/`
- `spec/mailers/`
- `spec/unit/`
- `spec/system/`
- `storage/` or `ActiveStorage` setup if needed

## Checklist

- [x] Successful payment enqueues invoice generation after commit.
- [x] Invoice artifact is stored durably.
- [x] Customer receives invoice email after the invoice is ready.
- [x] Payment success mail and invoice mail are separated cleanly.
- [x] No sensitive card data is stored as part of the invoice flow.

## Validation

- [x] Specs cover invoice generation and storage.
- [x] Specs cover the follow-up email delivery.
- [x] The flow remains retry-safe and idempotent.

## Notes

- Treat the invoice as a domain output asset, not as a payment credential artifact.
- If the generated invoice needs a download URL, keep that in the storage-backed attachment flow.
- If the email needs both an attachment and a link, prefer the storage-backed attachment plus a stable download link.
