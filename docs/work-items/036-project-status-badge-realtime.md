---
id: project-status-badge-realtime
aliases: []
tags:
  - work-items
  - project
  - status
  - badge
  - realtime
  - actioncable
depends_on:
  - project-lifecycle-states
  - client-notifications-persistent-toasts
  - in-app-pm-notifications
order: 36
phase: work-items
status: done
title: Order Status Badge Realtime
---

# Order Status Badge Realtime

## Goal

- [x] Keep order status badges in sync in realtime for client and PM views when the order lifecycle changes.

## Scope

- Broadcast order status changes over ActionCable.
- Render the status badge through a shared partial so client and detail views stay consistent.
- Subscribe client order cards and the order show page to live status updates.
- Reuse the new badge helpers in PM order cards and table rows for consistent labels.
- Add a regression system spec that verifies the badge updates without a full reload.

## Operational Note

- This work should stay on the existing ActionCable stack used by notifications and comments.
- Keep the badge payload small and HTML-based to avoid duplicating presentation logic in JS.

## Implementation Plan

- [x] Add an `OrderStatusChannel` that streams updates per order id.
- [x] Broadcast rendered badge HTML from `Order` after status changes.
- [x] Add a shared `projects/_status_badge` partial.
- [x] Mount the badge in the client order card and order show page.
- [x] Subscribe the frontend entrypoint to order status updates.
- [x] Add a system spec for the live badge update flow.

## Affected Docs

- `docs/work-items/015-project-lifecycle-states.md`
- `docs/work-items/028-client-notifications-persistent-toasts.md`
- `docs/work-items/index.md`

## Affected Ops

- `app/models/project.rb`
- `app/channels/project_status_channel.rb`
- `app/frontend/channels/project_status_channel.js`
- `app/frontend/entrypoints/application.js`
- `app/views/projects/_project.html.erb`
- `app/views/projects/show.html.erb`
- `app/views/projects/_status_badge.html.erb`
- `app/views/projects/_pm_project.html.erb`
- `app/views/projects/_pm_project_table_row.html.erb`
- `spec/system/project_status_badge_realtime_spec.rb`

## Checklist

- [x] Changing an order status broadcasts a live update.
- [x] Client order cards show the new status without reload.
- [x] Order show updates its status badge without reload.
- [x] PM order views reuse the same badge labels.

## Validation

- [x] A system spec covers the realtime badge update path.
- [x] The new spec passes in headless Chrome.

## Notes

- The regression spec sets the workspace env vars locally so it can run in isolation.
