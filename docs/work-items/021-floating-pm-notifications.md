---
id: floating-pm-notifications
aliases: []
tags:
  - work-items
  - notifications
  - ui
  - realtime
  - pm
depends_on:
  - optional-realtime-pm-notifications
order: 21
phase: work-items
status: done
title: Floating PM Notifications
---

# Floating PM Notifications

## Goal

- [x] Show PM notifications as floating toasts and keep the PM workspace layout stable.

## Scope

- Render unread notifications as compact floating cards in the bottom-right corner.
- Do not insert the notification feed into the normal body flow.
- Keep the PM list scroll position stable when notifications arrive.
- Allow click-through to `projects#show` from the notification card.
- Keep `Mark as read` as a separate action that only marks the notification read.
- Support a small visible stack, with overflow handled in a header indicator/panel.
- Keep the implementation lightweight, using CSS + Stimulus/vanilla JS, not Framer Motion.

## Operational Note

- This item is a UX refinement on top of the realtime channel already in place.
- Realtime delivery is a dependency, not part of this slice.
- The notification toast is feedback, not the only place to manage unread state.

## Implementation Plan

- [x] `app/views/projects/index.html.erb` - remove the inline inbox block and add a floating notification host.
- [x] `app/views/projects/_notification.html.erb` - split the card UI into a compact toast variant and a read-action variant.
- [x] `app/frontend/channels/pm_notification_channel.js` - update the refresh logic to target the floating host instead of the body flow.
- [x] `app/frontend/controllers/` or `app/frontend/entrypoints/` - manage toast stacking, overflow count, and auto-dismiss behavior.
- [x] `app/views/layouts/application.html.erb` or header partial - add the bell/notification counter entry point.
- [x] `app/controllers/notifications_controller.rb` - keep `Mark as read` from navigating to `projects#show`.
- [x] `app/controllers/projects_controller.rb` or routes - support clicking a notification to open `projects#show`.
- [x] `app/assets/stylesheets/application.css` or component CSS - add fixed positioning, enter/exit transitions, and stack styling.
- [x] `spec/system/projects_notifications_spec.rb` - verify toasts float, do not push content, and `Mark as read` stays on the same page.
- [x] `spec/system/` or `spec/integration/` - verify click-through to `projects#show` from the notification card.

## Affected Docs

- `docs/work-items/019-optional-realtime-pm-notifications.md`
- `docs/work-items/index.md`

## Affected Ops

- `app/views/projects/index.html.erb`
- `app/views/projects/_notification.html.erb`
- `app/frontend/channels/pm_notification_channel.js`
- `app/frontend/controllers/` or `app/frontend/entrypoints/`
- `app/views/layouts/application.html.erb`
- `app/controllers/notifications_controller.rb`
- `app/controllers/projects_controller.rb`
- `app/assets/stylesheets/application.css`
- `spec/system/projects_notifications_spec.rb`

## Checklist

- [x] Notifications appear without changing the page layout flow.
- [x] New toasts slide in from the bottom-right and stack upward.
- [x] Only a small number of toasts are visible at once.
- [x] `Mark as read` only marks read and does not navigate.
- [x] Clicking the notification card opens `projects#show`.
- [x] The PM can still see unread count/history via the header affordance.

## Validation

- [x] System spec verifies a toast appears while the page stays scrolled in place.
- [x] System spec verifies the notification click opens the order show page.
- [x] System spec verifies `Mark as read` updates state without navigation.
- [x] Realtime updates still work when multiple notifications arrive in sequence.

## Notes

- Prefer CSS transforms + transitions over heavier animation libraries.
- Keep the toast stack bounded; overflow belongs in the header affordance, not the body.
- If the interaction gets too broad, keep the floating toast minimal and defer the richer history panel.
