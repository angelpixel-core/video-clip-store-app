---
id: project-lifecycle-states
aliases: []
tags:
  - work-items
  - projects
  - workflow
  - status
depends_on:
  - sprint-0-data-model
  - sprint-0-client-views
  - in-app-pm-notifications
order: 15
phase: work-items
status: done
title: Order Lifecycle States
---

# Order Lifecycle States

## Goal

- [x] Update the order workflow to reflect the PM review and completion lifecycle.

## Scope

- Keep `draft` as the client editing state.
- Introduce `pending` as the initial post-submit state.
- Move the order to `in_progress` when the PM accepts it.
- Keep `completed` as the final state after fulfillment.
- Gate client editing and PM actions according to the current state.
- Express the transitions with AASM on the existing `status` column.

## Operational Note

- This item is the workflow source of truth for order status transitions.
- The client should no longer land on `in_progress` immediately after submit.

## Implementation Plan

- [x] Add or adjust the status state machine with AASM.
- [x] Update the submit flow to create `pending` orders.
- [x] Add the PM accept action that moves orders to `in_progress`.
- [x] Add the completion action that moves orders to `completed`.
- [x] Update the order list labels and buttons to match the new states.
- [x] Keep client editing limited to `draft` orders.

## Affected Docs

- `docs/sprints/00-foundation/01-scope.md`
- `docs/sprints/00-foundation/02-domain.md`
- `docs/sprints/00-foundation/03-data-model.md`
- `docs/sprints/00-foundation/04-client-views.md`

## Affected Ops

- `app/models/project.rb`
- `app/controllers/projects_controller.rb`
- `app/views/`
- `spec/requests/`
- `spec/models/`

## Checklist

- [x] New projects start as `pending`.
- [x] PM acceptance moves an order to `in_progress`.
- [x] Completion is only available in `in_progress`.
- [x] Client editing is only available in `draft`.

## Validation

- [x] Status transition specs pass.
- [x] The UI shows the expected labels and enabled actions.

## Notes

- Keep the state machine minimal unless new transitions are actually needed.
- Avoid coupling the status transition to notification delivery details.
