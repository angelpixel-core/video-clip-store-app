---
id: avatar-navbar-account-menu
aliases: []
tags:
  - work-items
  - ui
  - navbar
  - avatar
  - dropdown
  - roles
depends_on:
  - role-switcher-prototype
  - floating-pm-notifications
order: 24
phase: work-items
status: done
title: Avatar Navbar Account Menu
---

# Avatar Navbar Account Menu

## Goal

- [x] Replace the textual `Client / PM` toggle with an avatar-based account menu in the top-right navbar.

## Scope

- Show a circular avatar button in the top-right of the global header.
- If an avatar image exists, render it inside the button.
- If no avatar image exists, render an initial derived from the user name.
- Keep the notifications bell to the left of the avatar.
- On click, open a dropdown with:
  - Switch to PM or Switch to Client
  - profile
  - settings
- Keep this change strictly in the UI layer for now; do not introduce the `User` model migration in this work item.

## Operational Note

- This is a presentation change, not a domain refactor.
- The avatar should feel native to the current navbar shell instead of looking like a separate control.
- The `User` + roles model should be handled in a separate work item.

## Implementation Plan

- [x] `app/views/layouts/application.html.erb` - replace the current role toggle with an avatar button and dropdown.
- [x] `app/frontend/entrypoints/application.css` - style the avatar, dropdown, and compact actions to match the navbar.
- [x] `app/frontend/controllers/` or equivalent - keep the menu interaction lightweight if needed.
- [x] `spec/system/` - verify the avatar button and dropdown render correctly in both modes.

## Affected Docs

- `docs/work-items/index.md`
- `docs/work-items/016-role-switcher-prototype.md`
- `docs/work-items/021-floating-pm-notifications.md`

## Affected Ops

- `app/views/layouts/application.html.erb`
- `app/frontend/entrypoints/application.css`
- `app/frontend/controllers/`
- `spec/system/`

## Checklist

- [x] The header shows an avatar button instead of the text toggle.
- [x] The bell remains to the left of the avatar.
- [x] The avatar falls back to an initial when no image exists.
- [x] The dropdown exposes switch/profile/settings actions.
- [x] The header still matches the rest of the visual system.

## Validation

- [x] System spec verifies the avatar menu renders and opens.
- [x] System spec verifies the bell and avatar order in the navbar.

## Notes

- Prefer a subtle avatar treatment over a heavy badge or pill.
- Keep the menu behavior simple and consistent with the existing navbar interactions.
