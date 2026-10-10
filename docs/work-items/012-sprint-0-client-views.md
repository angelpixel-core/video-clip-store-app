---
id: sprint-0-client-views
aliases: []
tags:
  - work-items
  - sprint-0
  - ui
  - views
  - forms
depends_on:
  - sprint-0-data-model
  - testing-foundation
  - frontend-toolchain
order: 12
phase: work-items
status: done
title: Sprint 0 Client Views
---

# Sprint 0 Client Views

## Goal

- [x] Implement the client-facing order index and order flow for Sprint 0.

## Scope

- Order index view for the logged-in client.
- Order create view for selecting video types and entering order details.
- Payment modal UI for the simulated checkout step.
- Submission behavior that creates the order, persists video type selections, and redirects back to the order index.
- Keep the flow aligned with the Sprint 0 data model already implemented.

## Operational Note

- This work item is the UI layer for the Sprint 0 order flow.
- The domain model already exists; this item should consume it rather than redesign it.

## Implementation Plan

- [x] Add the order index and order create screens.
- [x] Wire the video type selection UI to the existing `VideoType` and `VideoTypeSelection` models.
- [x] Add the payment modal and submission flow.
- [x] Create the order and selection records on submit.
- [x] Redirect back to the order index after a successful submission.
- [x] Add minimal UI or controller specs needed to protect the flow.

## Affected Docs

- `docs/sprints/00-foundation/04-client-views.md`
- `docs/sprints/00-foundation/03-data-model.md`
- `docs/sprints/00-foundation/07-acceptance-criteria.md`

## Affected Ops

- `app/controllers/`
- `app/views/`
- `app/helpers/` if needed
- `app/javascript/` if the modal needs client-side behavior
- `spec/requests/` or `spec/system/` depending on the implementation style

## Checklist

- [x] The client can see an order index.
- [x] The client can start an order from the UI.
- [x] Video type selections are persisted through the existing data model.
- [x] The payment step completes and redirects successfully.

## Validation

- [x] The relevant UI or request specs pass.
- [x] The order flow creates the expected records.
- [x] The UI matches the Sprint 0 client-views doc.

## Notes

- Favor the smallest UI surface that satisfies the Sprint 0 docs.
- Keep the flow simple and deterministic; this is a simulated checkout.
