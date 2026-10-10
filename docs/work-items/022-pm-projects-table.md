---
id: pm-projects-table
aliases: []
tags:
  - work-items
  - pm
  - projects
  - table
  - realtime
  - ui
depends_on:
  - floating-pm-notifications
order: 22
phase: work-items
status: done
title: PM Orders Table
---

# PM Orders Table

## Goal

- [x] Show PM orders as a table with realtime updates, sorted by creation date.

## Scope

- Render the PM order list as a table only in PM mode.
- Keep the client view unchanged.
- Show order ID, order name, created date, total budget, status, and actions.
- Sort PM orders by `created_at DESC`.
- Do not show video type details in the table.
- Reserve video type breakdown for `projects#show`.
- Compute total budget from `video_type.price_cents * quantity` across project selections.
- Append newly created orders into the PM table in realtime when the client submits an order.
- Keep the PM notification flow working alongside the table updates.

## Operational Note

- This is a PM-only presentation change.
- The table is a summary view, not a replacement for `projects#show`.
- Realtime insertion should stay aligned with the existing notification broadcast path.

## Implementation Plan

- [x] `app/views/projects/index.html.erb` - replace the PM grid with a table view in PM mode.
- [x] `app/controllers/projects_controller.rb` - ensure PM orders are loaded sorted by `created_at DESC` and expose any data needed for the budget column.
- [x] `app/models/project.rb` or a presenter/helper - compute total budget from selections.
- [x] `app/views/projects/_pm_project_table_row.html.erb` or similar - render a single PM table row.
- [x] `app/frontend/channels/pm_notification_channel.js` - update the PM table in realtime when a new project is submitted.
- [x] `app/frontend/entrypoints/application.css` - add table styling consistent with the current editorial theme.
- [x] `spec/requests/projects_spec.rb` - verify PM table copy and ordering.
- [x] `spec/system/projects_notifications_spec.rb` - verify realtime row insertion and PM-mode-only rendering.

## Affected Docs

- `docs/work-items/index.md`
- `docs/work-items/021-floating-pm-notifications.md`

## Affected Ops

- `app/views/projects/index.html.erb`
- `app/controllers/projects_controller.rb`
- `app/views/projects/_pm_project_table_row.html.erb` or equivalent
- `app/frontend/channels/pm_notification_channel.js`
- `app/frontend/entrypoints/application.css`
- `spec/requests/projects_spec.rb`
- `spec/system/projects_notifications_spec.rb`

## Checklist

- [x] PM mode shows a table instead of cards.
- [x] The table includes ID, order name, created date, total budget, status, and actions.
- [x] The PM table is sorted by newest order first.
- [x] Video type details are not shown in the table.
- [x] Total budget matches the sum of selected video types and quantities.
- [x] New client-created orders appear in the PM table in realtime.
- [x] Client mode remains unchanged.
- [x] The PM table card header keeps only the `Assigned projects` title.

## Validation

- [x] Request spec verifies PM table structure and ordering.
- [x] System spec verifies PM mode renders the table and client mode does not.
- [x] System spec verifies a newly created project appears in the PM table without a full refresh.
- [x] Unit/spec coverage verifies budget calculation from project selections.

## Notes

- Prefer a table partial for each row rather than embedding complex row logic in the main index view.
- Keep the realtime update aligned with the notification broadcast path to avoid duplicate refresh logic.
- If the table grows too wide, keep it horizontally readable rather than collapsing into cards.
- The PM header should avoid repeating the workspace eyebrow inside the card header.
