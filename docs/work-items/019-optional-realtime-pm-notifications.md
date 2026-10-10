---
id: optional-realtime-pm-notifications
aliases: []
tags:
  - work-items
  - notifications
  - realtime
  - pm
  - optional
depends_on:
  - in-app-pm-notifications
order: 19
phase: work-items
status: completed
title: Optional Realtime PM Notifications
---

# Optional Realtime PM Notifications

## Goal

- [x] Stream PM notifications in real time when the PM has the inbox open, but keep the feature optional and non-blocking.

## Scope

- Add realtime delivery only if it remains simple in the current stack.
- Use Action Cable end-to-end with the existing Rails/Vite frontend split.
- Keep the server-rendered PM inbox and acknowledgment flow as the baseline.
- Do not block completion of the in-app notification work on this slice.

## Operational Note

- This item exists only to defer the realtime stretch goal from work item 14.
- The PM notifications feature is already usable without realtime.

## Implementation Plan

- [x] `app/channels/` - add the realtime channel if the stack supports it cleanly.
- [x] `app/frontend/` - subscribe to the realtime stream with the existing frontend entrypoint.
- [x] `app/controllers/` or `app/models/` - broadcast unread notifications on create or acknowledgment changes.
- [x] `spec/system/` or `spec/integration/` - verify the PM sees updates without refreshing when realtime is enabled.

## Affected Docs

- `docs/work-items/014-in-app-pm-notifications.md`

## Affected Ops

- `app/channels/`
- `app/frontend/`
- `app/controllers/`
- `app/models/`
- `spec/system/`
- `spec/integration/`

## Checklist

- [x] PM notifications can appear without a page refresh when realtime is enabled.
- [x] The baseline in-app notification flow still works without realtime.
- [x] The implementation stays small enough to keep the optional slice easy to skip.

## Validation

- [x] Realtime specs pass only if the implementation is kept simple enough to support them.
- [x] The server-rendered PM inbox still works when realtime is disabled or unavailable.

## Notes

- Keep this item optional and smaller than the core notification work.
- Prefer the smallest Action Cable channel + frontend subscription that delivers unread updates.
- If realtime gets too complex, keep the baseline flow and stop here.
