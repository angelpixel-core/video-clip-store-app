---
id: client-notifications-persistent-toasts
aliases: []
tags:
  - work-items
  - client
  - notifications
  - toasts
  - ui
  - realtime
  - persistence
depends_on:
  - pm-projects-table-interactions
  - in-app-pm-notifications
order: 28
phase: work-items
status: done
title: Client Notifications and Toasts
---

# Client Notifications and Toasts

## Goal

- [x] Add persistent client notifications with floating toast cards and an inbox dropdown.

## Scope

- Show client notifications when the PM changes order state.
- Keep notifications persistent and unread/read aware.
- Show floating toast cards for new notifications.
- Add a client campana/dropdown with a badge and history list.
- Allow the client to acknowledge notifications without leaving the current page.
- Keep the PM notification flow intact.
- Make the notification model ready for future comment/message events.

## Operational Note

- This is the client-side mirror of the existing PM notification system.
- The client should get both immediate toasts and a durable inbox.
- The work should reuse the current HTML refresh pattern instead of adding a second delivery stack.

## Implementation Plan

- [x] `app/models/notification.rb` - generalize the recipient and broadcast behavior.
- [x] `app/models/client.rb` - expose client notifications.
- [x] `app/controllers/client_notifications_controller.rb` or equivalent - mark client notifications as read.
- [x] `app/channels/client_notification_channel.rb` - stream client notification refreshes.
- [x] `app/frontend/channels/client_notification_channel.js` - subscribe and refresh the client inbox/toasts.
- [x] `app/frontend/lib/` or equivalent - share the refresh helper between PM and client inboxes.
- [x] `app/views/layouts/application.html.erb` - add the client campana in the navbar.
- [x] `app/views/projects/` or equivalent - render client toast/inbox partials.
- [x] `spec/requests/` - verify persistence, acknowledgment, and recipient scoping.
- [x] `spec/system/` - verify dropdown, badge, toast rendering, and read-state updates.

## Affected Docs

- `docs/work-items/index.md`
- `docs/decisions/09-client-notifications-persistent-toasts.md`
- `docs/work-items/014-in-app-pm-notifications.md`
- `docs/work-items/019-optional-realtime-pm-notifications.md`

## Affected Ops

- `app/models/notification.rb`
- `app/models/client.rb`
- `app/controllers/client_notifications_controller.rb`
- `app/channels/client_notification_channel.rb`
- `app/frontend/channels/client_notification_channel.js`
- `app/views/layouts/application.html.erb`
- `app/views/projects/`
- `spec/requests/`
- `spec/system/`

## Checklist

- [x] Client notifications are persisted and unread by default.
- [x] The client sees floating toast cards for new notifications.
- [x] The client sees an inbox dropdown with unread count.
- [x] The client can mark notifications as read.
- [x] PM notifications continue to work.

## Validation

- [x] Request specs verify client notification persistence and read state.
- [x] System specs verify the client dropdown and toasts render.
- [x] System specs verify acknowledgement does not navigate away.

## Notes

- Favor the smallest generalization that supports both PM and client recipients.
- Keep future comment/message notifications on the same notification domain.
