---
id: pm-projects-table-interactions
aliases: []
tags:
  - work-items
  - pm
  - projects
  - table
  - pagination
  - sorting
  - realtime
  - hotwire
  - ui
depends_on:
  - pm-projects-table
order: 23
phase: work-items
status: done
title: PM Orders Table Interactions
---

# PM Orders Table Interactions

## Goal

- [x] Add pagination, column sorting, and non-reloading row actions to the PM orders table.

## Decision Link

- See `docs/decisions/08-pm-row-actions-async-refresh.md` for the chosen async refresh strategy and concurrency approach.

## Scope

- Paginate the PM orders table with 10 records per page.
- Keep pagination on the PM side only.
- Allow sorting by `ID`, `Created at`, and `Total budget`.
- Execute PM row actions without a full page reload.
- Preserve the current PM table layout and the client view.
- Keep realtime updates aligned with the active page and sort order.
- If a new order arrives and belongs on the current page, insert it in sorted position.
- If that insertion pushes the last row off the page, carry it to the next page and continue the chain as needed.

## Operational Note

- This is a PM-only interaction layer on top of the existing PM orders table.
- Server-side pagination and sorting are preferred so the URL remains the source of truth.
- Realtime updates should respect the current sort and page state instead of appending blindly.
- Hotwire/Turbo is a strong fit for non-reloading actions and partial table updates.

## Implementation Plan

- [x] `app/controllers/projects_controller.rb` - accept pagination and sort params for the PM table.
- [x] `app/views/projects/index.html.erb` - render PM table controls, sortable headers, and pagination.
- [x] `app/views/projects/_pm_project_table_row.html.erb` or equivalent - keep row markup reusable for async updates.
- [x] `app/frontend/channels/pm_notification_channel.js` - update the visible PM table when new rows arrive, respecting page/sort state.
- [x] `app/controllers/projects_controller.rb` or a dedicated responder - return async responses for PM row actions.
- [x] `app/frontend/entrypoints/application.css` - style sortable headers, pagination, and row transitions if needed.
- [x] `spec/requests/projects_spec.rb` - verify pagination, sorting, and async row action behavior.
- [x] `spec/system/projects_notifications_spec.rb` - verify row actions do not reload and realtime insertions stay ordered.

## Affected Docs

- `docs/work-items/index.md`
- `docs/work-items/022-pm-projects-table.md`
- `docs/decisions/08-pm-row-actions-async-refresh.md`

## Affected Ops

- `app/controllers/projects_controller.rb`
- `app/views/projects/index.html.erb`
- `app/views/projects/_pm_project_table_row.html.erb`
- `app/frontend/channels/pm_notification_channel.js`
- `app/frontend/entrypoints/application.css`
- `spec/requests/projects_spec.rb`
- `spec/system/projects_notifications_spec.rb`

## Checklist

- [x] PM table shows 10 rows per page.
- [x] PM users can sort by ID, Created at, and Total budget.
- [x] Row actions do not trigger a full page reload.
- [x] Realtime inserts respect the current page and sort order.
- [x] New projects can push rows across page boundaries in a stable chain.
- [x] Client mode remains unchanged.

## Validation

- [x] Request spec verifies page size, sorting, and async row-action behavior.
- [x] System spec verifies actions work without reload.
- [x] System spec verifies a realtime order insertion lands in the correct sorted location.
- [x] System spec verifies page overflow/cascade behavior when inserting at the bottom of a page.

## Notes

- Prefer server-side pagination/sorting over client-only sorting.
- Keep the PM table as the source of truth for realtime updates.
- Use the documented async refresh strategy instead of introducing Turbo Streams for this work item.
