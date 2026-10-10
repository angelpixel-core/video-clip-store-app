---
id: payment-card-backface-isolation-and-sandbox
aliases: []
tags:
  - work-items
  - payments
  - ui
  - sandbox
  - 3d-card
depends_on: []
order: 53
phase: work-items
status: completed
title: Payment Card Backface Isolation and Sandbox Integration
---

# Payment Card Backface Isolation and Sandbox Integration

## Goal

- [x] Integrate external payment sandbox stack (`angelszymczak/payment-sandbox:0.1.0` and `payment-postgres`) via Docker Compose.
- [x] Vendor and configure `payment-sdk` Ruby gem for end-to-end payment intent lifecycle.
- [x] Eliminate 100% of front face element bleed-through on the back face of the 3D payment card in Chromium and WebKit.
- [x] Provide intuitive tactile unflip interaction and full keyboard accessibility (`Tab` and `Shift+Tab`).
- [x] Validate with Capybara / Selenium system tests with 0 failures.

## Scope

- Compose stack orchestration for payment sandbox on port 10201 and PostgreSQL on port 10202.
- Local vendored `payment-sdk` gem loaded via Gemfile and configured with an initializer.
- CSS 3D layer isolation: `transform-style: flat`, `backface-visibility: hidden` on children, and `translateZ(1px)` separation.
- Interaction controls: pointer events toggling, unflip delegation on card back click, and propagation prevention on CVC box.
- System test coverage for card flip and validation flows.

## Affected Areas

- `ops/compose/compose.yml`
- `env/dev/stack/compose.env`
- `env/dev/app/core.env`
- `Gemfile`, `Gemfile.lock`
- `vendor/gems/payment-ruby-sdk`
- `config/initializers/payment_sdk.rb`
- `app/frontend/entrypoints/application.css`
- `app/frontend/controllers/order_form_controller.js`
- `app/views/orders/_payment_modal.html.erb`
- `spec/system/payment_modal_card_flip_spec.rb`
- `spec/system/payment_modal_validation_spec.rb`
