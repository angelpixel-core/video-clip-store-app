---
id: rails-interface-layer-by-context
aliases: []
tags:
  - work-items
  - architecture
  - rails
  - controllers
  - views
  - presenters
  - jobs
  - mailers
  - channels
depends_on:
  - context-infrastructure-and-ordering-alignment
order: 59
phase: work-items
status: completed
title: Rails Interface Layer Segmented by Context (Phase 3)
---

# Rails Interface Layer Segmented by Context (Phase 3)

## Goal

- [x] Organize all Rails interface/driver folders (`app/controllers/`, `app/views/`, `app/presenters/`, `app/jobs/`, `app/mailers/`, `app/channels/`) using `<context>` as their immediate subdirectory (`app/<layer>/<context>/`).
- [x] Extract all Rails framework artifacts (`ActionController`, `ActiveJob`, `ActionMailer`) that were embedded inside `app/contexts/` out into their native Rails folders under `app/<layer>/<context>/`.
- [x] Clean up artificial mailer view paths in `app/views/` (`app/views/*/adapters/outbound/mailers/...` → `app/views/<context>/<mailer_name>/`).

## Scope

- `config/routes.rb` (using `scope module: :<context>` to preserve all URLs and route helpers).
- `app/controllers/<context>/`
- `app/views/<context>/`
- `app/presenters/<context>/`
- `app/jobs/<context>/`
- `app/mailers/<context>/`
- `app/channels/<context>/`

## Affected Docs

- `docs/work-items/059-rails-interface-layer-by-context.md`
- `docs/work-items/index.md`

## Affected Ops

- `config/routes.rb`
- `app/controllers/**`
- `app/views/**`
- `app/presenters/**`
- `app/jobs/**`
- `app/mailers/**`
- `app/channels/**`

## Implementation Plan

- [x] **Step 1: Segment `app/controllers/<context>/` and `app/views/<context>/`**
  - [x] Move `OrdersController` and `CommentsController` to `app/controllers/ordering/` (`Ordering::OrdersController`, `Ordering::CommentsController`) and move `app/views/orders/` to `app/views/ordering/orders/`.
  - [x] Move `ProfileController` to `app/controllers/identity/profile_controller.rb` (`Identity::ProfileController`) and `app/views/profile/` to `app/views/identity/profile/`.
  - [x] Move `NotificationsController` to `app/controllers/notifications/notifications_controller.rb` (`Notifications::NotificationsController`).
  - [x] Move `DbHealthController` to `app/controllers/shared/db_health_controller.rb` (`Shared::DbHealthController`).
  - [x] Extract `PaymentWebhooksController` from `app/contexts/payments/` to `app/controllers/payments/payment_webhooks_controller.rb` (`Payments::PaymentWebhooksController`).
  - [x] Extract `AdminVideoTypesController` and `PublicCatalogController` from `app/contexts/catalog/` to `app/controllers/catalog/`.
  - [x] Configure `scope module: :<context>` blocks in `config/routes.rb` so URLs and route helpers (`orders_path`, `order_path`, `profile_path`, etc.) remain 100% unchanged.
- [x] **Step 2: Segment `app/mailers/<context>/` and Mailer Views**
  - [x] Move `InvoiceMailer` from `app/contexts/billing/` to `app/mailers/billing/invoice_mailer.rb` (`Billing::InvoiceMailer`) and move its views to `app/views/billing/invoice_mailer/`.
  - [x] Move `PaymentNotificationMailer` from `app/contexts/payments/` to `app/mailers/payments/payment_notification_mailer.rb` (`Payments::PaymentNotificationMailer`) and move its views to `app/views/payments/payment_notification_mailer/`.
  - [x] Move `ProjectNotificationMailer` to `app/mailers/notifications/project_notification_mailer.rb` (`Notifications::ProjectNotificationMailer`) and move its views to `app/views/notifications/project_notification_mailer/`.
  - [x] Delete legacy `app/views/billing/adapters/` and `app/views/payments/adapters/` trees.
- [x] **Step 3: Segment `app/jobs/<context>/`**
  - [x] Move `NotificationJob` to `app/jobs/notifications/notification_job.rb` (`Notifications::NotificationJob`).
  - [x] Extract `DispatchInvoiceJob` and `GenerateInvoiceJob` from `app/contexts/billing/` to `app/jobs/billing/`.
  - [x] Extract `DispatchPaymentNotificationJob` and webhook `Job` from `app/contexts/payments/` to `app/jobs/payments/`.
  - [x] Extract `CheckCapacityJob` from `app/contexts/capacity/` to `app/jobs/capacity/check_capacity_job.rb`.
- [x] **Step 4: Segment `app/presenters/<context>/` and `app/channels/<context>/`**
  - [x] Rename `app/presenters/orders/order_form_presenter.rb` to `app/presenters/ordering/order_form_presenter.rb` (`Ordering::OrderFormPresenter`).
  - [x] Keep `app/presenters/catalog/offer_catalog_presenter.rb` (`Catalog::OfferCatalogPresenter`).
  - [x] Move `NotificationsChannel` to `app/channels/notifications/notifications_channel.rb` and `OrderCommentsChannel` / `OrderStatusChannel` to `app/channels/ordering/`, updating frontend channel subscriptions if namespaces change.

## Checklist

- [x] Every controller, view folder, presenter, job, mailer, and channel (except base `application_*` classes and `layouts`/`pwa`) lives under `app/<layer>/<context>/`.
- [x] Zero `ActionController`, `ActiveJob`, or `ActionMailer` subclasses remain inside `app/contexts/`.
- [x] `app/views/*/adapters/` directories no longer exist.
- [x] All route helpers and HTTP endpoints remain backwards-compatible.

## Validation

- [x] `bundle exec rails zeitwerk:check` passes cleanly.
- [x] Full unit, request, mailer, and system spec suites pass.
- [x] `bundle exec rubocop` passes with 0 offenses.

