---
id: conversation-comments-ui-refinement
aliases: []
tags:
  - work-items
  - ui
  - comments
  - conversation
  - stimulus
order: 56
phase: work-items
status: completed
title: Conversation and Comments UI Refinement
---

# Conversation and Comments UI Refinement

## Goal

- [x] Apply the collapsible disclosure and normalized spacing pattern to the **Conversation & Comments** section in the order show view (`#order-comments`).
  - Native accessible `<details class="conversation-details" open>` container with counter badge `#order-comments-count` and rotating chevron indicator.
  - Normalizes comment card layout (`_comment.html.erb`):
    - Differentiated author role badges (`CLIENT` in primary, `PM` in dark) preserving selector expectations.
    - Clean timestamp chips.
    - Monospace/pre-wrap preserved multiline body styling.
    - Inline copy-to-clipboard button (📋) using Stimulus `clipboard-copy` controller.
  - Refines comment submission form (`_comment_form.html.erb`) with styled background, clear role indicator ("Posting as Client / PM"), and clean typography.
  - Preserves 100% of DOM IDs and selectors for ActionCable real-time comment synchronization and system tests.

## Scope

- View templates:
  - `app/views/orders/show.html.erb`
  - `app/views/orders/_comment.html.erb`
  - `app/views/orders/_comment_form.html.erb`
- Stylesheets:
  - `app/assets/stylesheets/application.css`
- Documentation:
  - `docs/work-items/056-conversation-comments-ui-refinement.md`
  - `docs/work-items/index.md`
