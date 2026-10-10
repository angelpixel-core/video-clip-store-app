---
id: 01-stabilization-and-e2e-flow
title: Stabilization and End-to-End Flow Roadmap
phase: roadmap
order: 1
aliases: []
tags:
  - roadmap
  - stabilization
  - e2e
  - plan
---

# 01 Stabilization and End-to-End Flow Roadmap

This roadmap outlines the complete plan to audit, repair, and complete the video project submission app. It covers database migrations, seed data, role management, catalog synchronization, checkout and payment webhook simulation, invoice generation, and PM workspace operations.

---

## Progress Overview

- [x] **Phase 0: Environment & Docker Stack Foundation**
- [x] **Phase 1: Database Bootstrap & Seed Synchronization**
- [x] **Phase 2: Fulfillment & Repository Robustness**
- [x] **Phase 3: Payments & Webhook Simulation Workflow**
- [x] **Phase 4: Billing & Invoice Generation Verification**
- [x] **Phase 5: PM Fulfillment Operations & Real-time State Updates**
- [x] **Phase 6: Quality Gates & End-to-End Verification**

---

## Detailed Phases and Tasks

### Phase 0: Environment & Docker Stack Foundation

- [x] **Docker & Compose Configuration**
  - [x] Verify `ops/compose/compose.yml` service definitions (`web`, `assets`, `worker`, `db`).
  - [x] Verify port mappings (`20001` for Rails web, `20002` for MySQL database).
  - [x] Validate Docker Compose environment files in `env/dev/stack/compose.env`, `env/dev/app/core.env`, and `env/dev/app/db.env`.
- [x] **Local Tooling and Makefile**
  - [x] Inspect existing `Makefile` targets (`stack/up`, `stack/down`, `db/seeds`, `payments/simulate_webhook`).
  - [x] Add `make db/setup` target to `Makefile` for one-command complete database initialization.
  - [x] Update `ops/scripts/db.sh` to support the `setup` action (running migrations with data, followed by seeds).

---

### Phase 1: Database Bootstrap & Seed Synchronization

- [x] **Data Migrations Audit (`db/data/`)**
  - [x] Review `db/data/20260729203959_bootstrap_identity_records.rb` (default PM and Client workspace accounts).
  - [x] Review `db/data/20260730000100_bootstrap_tenant_and_organization.rb` (default Tenant and Organization).
  - [x] Update `db/data/20260802091000_bootstrap_offer_catalog.rb` so it gracefully handles environments where `video_types` is empty without failing or skipping initialization.
- [x] **Seeds Overhaul (`db/seeds.rb`)**
  - [x] Make `db/seeds.rb` completely self-sufficient and idempotent.
  - [x] Ensure default Tenant (`wanderlust`) and Organization (`wanderlust-videos`) exist.
  - [x] Ensure default PM Account (`pm@example.com`, role: `:pm`) and Client Account (`client@example.com`, role: `:client`) exist with associated Users and Memberships.
  - [x] Ensure canonical Offer (`video_editing`), OfferItemType (`video_type`), and assignment exist in the catalog domain.
  - [x] Seed standard video offerings ("Social Cut" - $150, "Highlight Reel" - $250) in `video_types` table.
  - [x] Create or sync matching `OfferVariant` records with identical names, descriptions, prices, and output formats.
  - [x] Create default sample draft `Project` / `Order` for immediate dev exploration.
- [x] **Entrypoint Automation (`ops/containers/app/entrypoint.sh`)**
  - [x] Ensure container startup with `RUN_DB_PREPARE=1` runs both structural migrations and data migrations (`db:prepare:with_data` or `db:data:migrate`).

---

### Phase 2: Fulfillment & Repository Robustness

- [x] **Order Repository Selection Resolver**
  - [x] Review `Fulfillment::Adapters::Persistence::Order::Repository#replace_selections`.
  - [x] Update `resolve_video_type_id`:
    - [x] Check if the ID exists directly in `VideoType`.
    - [x] Look up corresponding `OfferVariant` by ID and resolve matching `VideoType` by name.
    - [x] Provide safe fallback: if `VideoType` record does not exist for the variant, create or initialize it from the variant attributes to prevent `RecordNotFound` exceptions.
- [x] **Read Model Synchronization (`Order#sync_order_listing!`)**
  - [x] Verify that `Order#sync_order_listing!` accurately writes to the `orders` read model table.
  - [x] Verify `order_lines` snapshot records contain proper `offer_variant_id`, `name`, `price_cents`, and `quantity`.
  - [x] Verify `source_video` records synchronize when `raw_footage_url` is present.

---

### Phase 3: Payments & Webhook Simulation Workflow

- [x] **Fake Gateway Checkout Submission**
  - [x] Confirm order submission creates payment with provider `fake` and status `:processing`.
  - [x] Ensure order transitions from `:draft` to `:pending` upon successful submission.
  - [x] Keep payment in `:processing` state initially to accurately mirror asynchronous payment gateways.
- [x] **Webhook Simulator Enhancement (`lib/tasks/payments.rake`)**
  - [x] Update `resolved_payment_from_env` in `payments.rake` to automatically select the most recent `processing` payment if `PROJECT_ID` or `PAYMENT_ID` is omitted.
  - [x] Verify `make payments/simulate_webhook` delivers signed `payment.succeeded` event to `POST /payments/webhooks/fake/events`.
- [x] **In-App Dev Webhook Trigger**
  - [x] In development mode (`Rails.env.development?`), add a quick "Simulate Payment Succeeded" button in the order show view (`app/views/orders/show.html.erb`).
  - [x] Add route and controller action to execute the webhook simulator internally without leaving the browser.
  - [x] Verify payment status updates to `:succeeded` upon webhook ingestion.

---

### Phase 4: Billing & Invoice Generation Verification

- [x] **Invoice Lifecycle**
  - [x] Verify `Payments::Domain::Aggregates::Payment` triggers `enqueue_invoice_generation_job` when transitioning to `:succeeded`.
  - [x] Verify `Billing::Application::Handlers::GenerateInvoiceJob` executes `IssueInvoice` command.
  - [x] Verify HTML/PDF invoice is generated and attached to `payment.invoice_document` via ActiveStorage.
  - [x] Verify `Payments::Domain::Entities::PaymentInvoiceDeliveryIntent` is recorded.
  - [x] Verify `Billing::Adapters::Outbound::Mailers::InvoiceMailer` preview is accessible in development via LetterOpener (`/letter_opener`).

---

### Phase 5: PM Fulfillment Operations & Real-Time Updates

- [x] **Order Management Workflow**
  - [x] Verify PM orders table listing on `GET /orders` via `Ordering::Application::Queries::ListingQuery`.
  - [x] Verify ActionCable status badge updates in real-time when payment succeeds.
  - [x] Verify PM can accept paid order via `PATCH /orders/:id/accept` (transitions order to `in_progress`).
  - [x] Verify PM can complete in-progress order via `PATCH /orders/:id/complete` (transitions order to `completed`).
  - [x] Verify PM can cancel unpaid pending orders via `PATCH /orders/:id/cancel`.
  - [x] Verify refund workflow:
    - [x] PM or Client requests refund (`PATCH /orders/:id/request_refund`).
    - [x] PM reviews refund request (`PATCH /orders/:id/approve_refund_request` or `reject_refund_request`).

---

### Phase 6: Quality Gates & End-to-End Verification

- [x] **Architectural & Static Checks**
  - [x] Run `bundle exec packwerk check` (must pass with 0 offenses).
  - [x] Run `bundle exec rails zeitwerk:check` (must pass with 0 autoload errors).
  - [x] Run `bin/rubocop` (verify no critical syntax or style offenses).
- [x] **Automated Test Suite**
  - [x] Run unit tests: `make test/unit`.
  - [x] Run integration tests: `make test/integration`.
- [x] **End-to-End Manual Verification**
  - [x] Build and start Docker stack: `make stack/up STACK_ARGS="-d --build"`.
  - [x] Verify health endpoints: `curl http://localhost:20001/up` and `curl http://localhost:20001/up/db`.
  - [x] Run database seeds: `make db/seeds`.
  - [x] In Client workspace:
    - [x] Request new order, fill required fields, and add video selections.
    - [x] Save as Draft, verify it appears in draft state.
    - [x] Submit for review. Verify state is `:pending`.
  - [x] Simulate Webhook:
    - [x] Trigger `Simulate Payment Succeeded` from order details view.
    - [x] Verify order state transitions to `:in_progress` or PM actions become available.
  - [x] In PM workspace:
    - [x] Accept order. Verify badge changes to "Accepted" or "In Progress".
    - [x] Complete order. Verify badge changes to "Completed".
  - [x] Verify emails in LetterOpener (`http://localhost:20001/letter_opener`):
    - [x] Order submitted confirmation.
    - [x] Payment succeeded/Invoice email.
    - [x] Order completed notification.
    - [x] Create new order (`/orders/new`).
    - [x] Enter title and raw footage URL.
    - [x] Select video editing options from catalog.
    - [x] Submit card details in checkout modal.
    - [x] Verify order created in `pending` state with payment `processing`.
  - [x] Trigger payment completion:
    - [x] Execute `make payments/simulate_webhook` or click dev simulate button.
    - [x] Verify payment badge updates to `succeeded` and invoice is attached.
  - [x] In PM workspace:
    - [x] Switch to PM role.
    - [x] View order in assigned table.
    - [x] Accept order (status -> `in_progress`).
    - [x] Complete order (status -> `completed`).
