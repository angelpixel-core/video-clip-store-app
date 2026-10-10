---
id: in-app-pm-notifications
aliases: []
tags:
  - work-items
  - notifications
  - ui
  - realtime
  - pm
depends_on:
  - notification-delivery-channels
  - sprint-0-client-views
  - sprint-0-data-model
order: 14
phase: work-items
status: done
title: In-App PM Notifications
---

# In-App PM Notifications

## Goal

- [x] Show PM notifications inside the app as toasts/snackbars and persist their read state.

## Scope

- Persist notifications in the database as the source of truth.
- Add a `read_at` or `seen_at` field to track acknowledgment.
- Render pending notifications when the PM enters the PM view.
- Optionally stream new notifications in real time when the PM has the view open, but do not block the work item on it.
- Mark notifications as seen/read when the PM acknowledges them.
- Keep the acknowledgment UI and its minimal non-Bootstrap styling as a contiguous subslice of this work item.

## Discovery

- `read_at` already exists in the notifications table and schema, so the first slice only needs model behavior and specs.
- The PM inbox is rendered server-side on `projects#index` for now; the acknowledgment UI remains a contiguous follow-up slice.
- The acknowledgment UI is server-driven (`button_to` + redirect), so this slice does not need `app/javascript`.
- The realtime delivery slice moved to `docs/work-items/019-optional-realtime-pm-notifications.md`.

## Operational Note

- This item is about in-app presentation, not browser push notifications.
- A toast acknowledgment should mean the PM actually saw the notification, not just closed it.

## Implementation Plan

- [x] `db/schema.rb` - confirm the read-state column already exists for `notifications`.
- [x] `app/models/notification.rb` - add the read-state validation or helper methods needed for unread queries.
- [x] `app/controllers/projects_controller.rb` - load unread notifications when the PM view opens.
- [x] `app/views/projects/index.html.erb` - render a compact PM inbox for each pending notification.
- [x] `app/views/projects/_notification.html.erb` - render the compact notification card/preview.
- [x] `app/controllers/notifications_controller.rb` - mark a PM notification as read and redirect back.
- [x] `config/routes.rb` - add the notification acknowledgment route.
- [x] `app/assets/stylesheets/application.css` - add the small custom CSS needed for the toast/ack component.
- [x] `spec/requests/projects_spec.rb` - verify the PM inbox renders unread notifications and excludes read ones.
- [x] `spec/system/projects_notifications_spec.rb` - verify the toast appears and can be acknowledged.
- [x] `spec/models/` or `spec/unit/models/` - verify the unread/read state behavior.
- [x] Realtime delivery moved to `docs/work-items/019-optional-realtime-pm-notifications.md`.

## Affected Docs

- `docs/sprints/00-foundation/04-client-views.md`
- `docs/sprints/00-foundation/05-background-jobs.md`
- `docs/sprints/00-foundation/02-domain.md`

## Affected Ops

- `app/models/notification.rb`
- `app/views/`
- `app/controllers/`
- `app/assets/stylesheets/application.css`
- `config/routes.rb`
- `spec/system/projects_notifications_spec.rb`
- `spec/models/` or `spec/unit/models/`

## Checklist

- [x] PM notifications are visible in the app.
- [x] Pending notifications appear when the PM enters the view.
- [x] Acknowledged notifications are marked as read.

## Validation

- [x] UI specs verify the toast and acknowledgment flow.
- [x] Unread notifications are loaded from persistence.
- [x] The acknowledgment updates the stored read state.

## Notes

- Prefer a notification list plus a minimal toast over a detail screen.
- Keep the payload compact: order name, client name, and a short message are enough.
