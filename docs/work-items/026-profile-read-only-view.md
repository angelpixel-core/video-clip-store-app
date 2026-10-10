---
id: profile-read-only-view
aliases: []
tags:
  - work-items
  - profile
  - ui
  - avatar
  - token
depends_on:
  - avatar-navbar-account-menu
order: 26
phase: work-items
status: done
title: Profile Read-Only View
---

# Profile Read-Only View

## Goal

- [x] Create a read-only `/profile` page that shows the current user's identity and demo credentials.

## Scope

- Show:
  - name
  - email
  - current role
  - avatar placeholder
  - demo token with reveal/copy controls
- Keep the page read-only for this stage.
- Do not add `ActiveStorage` yet.
- Do not add avatar uploads or URL editing yet.
- Keep the layout consistent with the existing app shell.

## Operational Note

- This is a first-pass profile surface for review.
- The goal is to validate the UX before introducing avatar storage or upload flows.
- The token shown here is a demo credential display, not browser session auth.

## Implementation Plan

- [x] `app/views/profile/show.html.erb` or equivalent - render the profile card and identity details.
- [x] `app/controllers/profile_controller.rb` or equivalent - load the current profile context.
- [x] `app/frontend/entrypoints/application.css` - style the profile layout and token controls.
- [x] `spec/system/` - verify the profile page renders and the reveal/copy controls work.

## Affected Docs

- `docs/work-items/index.md`
- `docs/work-items/024-avatar-navbar-account-menu.md`
- `docs/work-items/025-profile-avatar-uploads.md`

## Affected Ops

- `app/views/profile/`
- `app/controllers/profile_controller.rb`
- `app/frontend/entrypoints/application.css`
- `spec/system/`

## Checklist

- [x] `/profile` renders successfully.
- [x] The page shows name, email, and role.
- [x] The avatar placeholder is always visible.
- [x] The token can be revealed and copied.
- [x] The layout matches the rest of the app.

## Validation

- [x] System spec verifies the profile page renders.
- [x] System spec verifies the token reveal/copy controls.
- [x] System spec verifies the avatar placeholder appears.

## Notes

- Keep this stage read-only.
- Reassess after trying the page before introducing `ActiveStorage`.
- If the profile feels useful, the next work item can add avatar storage/upload support.
