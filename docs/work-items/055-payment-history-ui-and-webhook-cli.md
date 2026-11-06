---
id: payment-history-ui-and-webhook-cli
aliases: []
tags:
  - work-items
  - payments
  - ui
  - stimulus
  - cli
order: 55
phase: work-items
status: completed
title: Payment History UI Refinement, Dev Tools Guard and Webhook CLI Fix
---

# Payment History UI Refinement, Dev Tools Guard and Webhook CLI Fix

## Goal

- [x] Refine Payment History UI in `/orders/:id`:
  - Native accessible `<details open>` collapsible sections for Payment History, Webhook Events, and Payment Attempts.
  - Shorten verbose references (`render_short_reference`) to significant prefix segments with full text tooltips.
  - Add inline copy-to-clipboard button (📋) with Stimulus `clipboard-copy` controller.
  - Normalize spacing, heights, and responsive metadata layout for payment status, creation, and confirmation timestamps.
- [x] Guard Dev Tools behind environment-based feature flags (`Features.payment_simulation_devtool_enabled?`), restricted exclusively to `development` (disabled in test, QA, staging, and production), and automatically hide once payment succeeds.
- [x] Fix terminal webhook simulation command (`make payments/send_signed_fake_webhook` and `make payments/simulate_webhook`):
  - Add `payments:send_signed_fake_webhook` alias to `lib/tasks/payments.rake`.
  - Introduce `ops/scripts/payments.sh` to seamlessly route commands inside the running Docker `web` container or fallback to local execution.

## Scope

- UI: `app/views/orders/_payment_history.html.erb`, `app/views/orders/show.html.erb`, `app/assets/stylesheets/application.css`.
- Frontend: `app/frontend/controllers/clipboard_copy_controller.js`, `app/helpers/reference_format_helper.rb`.
- Feature Flag: `app/models/features.rb`, `app/controllers/orders_controller.rb`.
- CLI & Operations: `Makefile`, `ops/scripts/payments.sh`, `lib/tasks/payments.rake`.
- Tests: `spec/unit/models/features_spec.rb`, `spec/unit/helpers/reference_format_helper_spec.rb`, `spec/unit/tasks/payments_rake_spec.rb`, `spec/requests/orders_spec.rb`.
