---
id: pm-row-actions-async-refresh
title: PM Row Actions Async Refresh
phase: decisions
order: 8
aliases: []
tags:
  - decisions
  - pm
  - projects
  - ui
  - async
  - concurrency
  - stimulus
---

# PM Row Actions Async Refresh

## Decision

Implement PM row actions (`accept` and `complete`) as progressively enhanced async requests that update the PM workspace without a full page reload.

## Context

The PM orders table already supports server-side pagination and sorting. The remaining gap is that the row actions still submit as normal forms and reload the page. The desired behavior is to keep the PM workspace in sync after a row action while preserving a normal non-JS fallback.

## Rationale

- The app already refreshes PM workspace fragments from the current HTML for notification updates, so the same model fits row-action updates.
- The existing Rails app does not use Turbo Streams, so introducing Turbo only for this edge would add a new pattern without enough payoff.
- `Stimulus + fetch` keeps the implementation small and matches the existing frontend stack.
- A database lock on the order row is sufficient to prevent concurrent transitions from racing each other.
- Returning `204 No Content` for async success keeps the UI path simple; the client refreshes the workspace from the current page state afterward.

## Strategy

- Add a small Stimulus controller that intercepts PM row action form submits.
- Send async requests with a custom header to distinguish them from normal HTML form submits.
- Wrap the state transition in a row-level lock so only one transition can win.
- On async success, return `204` and refresh the PM workspace fragments from the current HTML.
- On invalid or stale state, return `409` or `422` in the normal HTML path and let the UI refresh from the source of truth.
- Keep the existing `button_to` fallback so the actions still work without JavaScript.

## Scope

- `accept` and `complete` actions in the PM table rows.
- Reuse the same refresh helper used by PM notification updates.
- Preserve the current page, sort, and notification state after action completion.

## Not Chosen

- Turbo Streams: rejected because the repo does not otherwise use Turbo and this change is small enough for a lighter-weight pattern.
- Event sourcing / event bus / Karafka: rejected because the use case is a single synchronous UI transition, not a multi-consumer workflow.
- Full page reloads: rejected because they discard the current PM workspace state and are unnecessary.

## Data Flow

```text
PM clicks Accept/Complete
  -> Stimulus intercepts submit
  -> fetch PATCH /projects/:id/{accept|complete} with async header
  -> ProjectsController locks the order and transitions state
  -> returns 204 on success
  -> frontend refreshes PM workspace fragments from current HTML
  -> table row, badge, and notification panel stay in sync
```

## Consequences

- The UI remains responsive and consistent after row actions.
- The implementation stays small and aligned with the current app stack.
- Concurrent action attempts are handled at the database boundary instead of via a distributed event system.
