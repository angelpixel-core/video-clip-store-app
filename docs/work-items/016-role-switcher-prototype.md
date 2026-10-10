---
id: role-switcher-prototype
aliases: []
tags:
  - work-items
  - ui
  - prototype
  - roles
  - sessionstorage
depends_on:
  - sprint-0-client-views
  - project-lifecycle-states
order: 16
phase: work-items
status: done
title: Role Switcher Prototype
---

# Role Switcher Prototype

## Goal

- [x] Add a simple frontend-only role switcher for the demo UI.

## Scope

- Show a global header with a client/PM selector.
- Default the selector to client.
- Persist the selection in `sessionStorage` so each tab keeps its own mode.
- Use the selected mode to change visibility and available actions in the UI.
- Keep the switcher strictly in the frontend; do not use Rails session or persisted roles.

## Operational Note

- This is a prototype control, not a security boundary.
- The selector should not use the Rails session because that would leak across tabs and windows.
- The PM mode is demo-only and should only expose the projects index workspace.

## Implementation Plan

- [x] Add a global header selector and default state in the layout shell.
- [x] Persist the mode in `sessionStorage`.
- [x] Read the mode on page load and restore it.
- [x] Write the mode to `body` or the root container as a UI state hook.
- [x] Switch the visible navigation and actions by mode.
- [x] Keep PM mode limited to the projects index workspace in the UI.

## Affected Docs

- `app/views/layouts/application.html.erb`
- `app/frontend/entrypoints/application.js`
- `app/frontend/controllers/`
- `docs/sprints/00-foundation/04-client-views.md`
- `docs/sprints/00-foundation/01-scope.md`

## Affected Ops

- `app/views/`
- `app/frontend/` or equivalent client-side code
- `spec/system/`

## Checklist

- [x] The selector defaults to client.
- [x] The selector persists per tab.
- [x] The PM view and client view swap correctly in the frontend shell.
- [x] The PM mode only exposes the projects index workspace.

## Validation

- [x] UI specs or manual checks confirm tab-isolated state.

## Notes

- Keep the UI mode switch separate from real authentication.
- Favor the simplest possible header shell.
