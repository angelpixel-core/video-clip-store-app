# Video Project Submission App

Rails application for collecting video editing orders, simulating checkout, and coordinating fulfillment between a client workspace and a project-manager workspace.

## Overview

The public UI is order-centric: clients create a draft, choose from a catalog of video editing offers, attach raw footage, and submit the order through a simulated payment step. PMs review assigned orders, move them through fulfillment states, and handle refund actions. Payment processing is intentionally isolated behind a fake provider and webhook-driven workflow so the domain can evolve without binding the app to a real gateway too early.

The current codebase still keeps some legacy persistence names, most notably the `projects` table behind the `Order` model, while the UI and higher-level workflows speak in terms of orders.

## Product Workflows

### Customer Workflow

- Create a draft order from `/orders/new`.
- Choose offers from the catalog and build a cart.
- Provide an order name and raw footage URL.
- Review the simulated payment step and submit the order.
- Inspect order detail pages, payment history, comments, notifications, and profile data.
- Mark notifications as read.

### PM Workflow

- Review the PM workspace order table on `/orders`.
- Sort, page, and inspect assigned orders.
- Accept, cancel, complete, or reopen orders.
- Request, approve, or reject refunds.
- Watch row updates refresh over ActionCable when actions are performed asynchronously.

### Payment Workflow

- Create a payment against an order using the `fake` provider.
- Persist payment attempts, method references, webhook events, refund requests, and notification intents.
- Ingest signed payment webhooks at `POST /payments/webhooks/:provider/events`.
- Generate invoices after successful payment and store them through Active Storage.
- Notify both workspaces through the notification pipeline.

Operational payment docs are indexed in [`docs/payments.md`](docs/payments.md).

## Architecture

The application is organized as a modular Rails codebase with Packwerk dependency enforcement.

- `identity` owns users, accounts, memberships, and workspace resolution.
- `catalog` owns offers, variants, and offer-item assignments.
- `ordering` owns the order read model and listing/query workflows.
- `fulfillment` owns order lifecycle actions such as accept, cancel, complete, and reopen.
- `capacity` tracks capacity reservations tied to orders.
- `payments` owns payment creation, webhook ingestion, attempts, refunds, and provider gateways.
- `billing` owns invoice issuance, tax integration, and invoice persistence.
- `notifications` owns delivery channels and dispatch orchestration.
- `shared` contains common building blocks.

Dependency direction is explicit in each `package.yml`. Domain and application code are separated from persistence and integration adapters, and the billing and payments route maps document the intended boundaries inside those contexts.

## Project Structure

```text
.
├── app/
├── bin/
├── config/
├── db/
├── docs/
├── env/
├── lib/
├── ops/
├── spec/
├── Makefile
├── Gemfile
├── package.json
└── vite.config.ts
```

- `app/domains/` contains the modular domain boundaries.
- `app/controllers/`, `app/views/`, and `app/services/` hold the Rails edge and orchestration code.
- `db/data/` contains required bootstrap data migrations.
- `env/` stores environment templates for app, DB, and stack values.
- `ops/` contains Docker, scripts, and Render/Terraform infrastructure.
- `docs/` holds work items, operational runbooks, and architecture notes.

## Tech Stack

- Ruby 4.0.3
- Rails 8.1.3.1
- Node.js 20.19.0
- Vite 8
- MySQL for local and test environments
- PostgreSQL for QA, staging, and production on Render
- Solid Queue, Solid Cable, and Solid Cache
- Docker Compose for the local stack
- Terraform for Render infrastructure

## Getting Started

### Prerequisites

- Ruby 4.0.3
- Node.js 20.19.0
- Docker and Docker Compose
- Make

### Local Setup

The easiest way to run the app locally is the Dockerized stack:

```sh
make stack/up STACK_ARGS="-d --build"
```

Then open:

- `http://localhost:20001` for the app
- `http://localhost:20001/up` for health
- `http://localhost:20001/letter_opener` in development for email previews

Stop it with:

```sh
make stack/down
```

If you prefer the native Ruby/Node workflow:

```sh
bin/setup --skip-server
bin/dev
```

`bin/setup` installs dependencies and prepares the database; `bin/dev` starts Rails and Vite together.

### Database Bootstrap

Required bootstrap records live in `db/data/`. The repository keeps demo content separate in `db/seeds.rb`.

When you need the bootstrap data path explicitly, use the Rails data-migration flow documented in `db/data/README.md`.

## Configuration

Environment templates live under `env/` and are split by consumer:

- `env/<env>/app/core.env`
- `env/<env>/app/db.env`
- `env/<env>/db/bootstrap.env`
- `env/<env>/stack/compose.env`
- `env/.local/<env>.env`

Useful variables include:

- `STACK_ENV`
- `APP_IMAGE_STAGE`
- `APP_PORT`
- `APP_HOST_PORT`
- `ASSETS_PORT`
- `ASSETS_HOST_PORT`
- `DB_PORT`
- `DB_HOST_PORT`
- `DB_HOST`
- `DB_NAME`
- `DB_USER`
- `DB_PASSWORD`
- `MYSQL_ROOT_PASSWORD`
- `MYSQL_DATABASE`
- `MYSQL_USER`
- `MYSQL_PASSWORD`
- `DATABASE_URL`
- `RAILS_MASTER_KEY`
- `DEFAULT_CLIENT_WORKSPACE_EMAIL`
- `DEFAULT_PM_WORKSPACE_EMAIL`
- `DEFAULT_TENANT_NAME`
- `DEFAULT_TENANT_SLUG`
- `DEFAULT_ORGANIZATION_NAME`
- `DEFAULT_ORGANIZATION_SLUG`
- `PAYMENTS_WEBHOOK_SECRET`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `AWS_BUCKET`
- `SMTP_ADDRESS`
- `SMTP_PORT`
- `SMTP_USER_NAME`
- `SMTP_PASSWORD`

## Testing and Quality

Canonical commands:

```sh
make lint
make test/ci
make test/qa
make test/all
bin/ci
```

Other useful targets:

```sh
make hooks/setup
make test/unit
make test/integration
make test/smoke
make test/acceptance
make test/performance
```

The pre-push hook runs `make lint` before allowing a push.

## Operations

The `ops/` directory keeps operational concerns isolated from the app code:

- `ops/compose/` for the local Docker Compose stack
- `ops/containers/` for multi-stage container builds and runtime entrypoints
- `ops/scripts/` for shell wrappers used by `make`
- `ops/infra/render/` for Render and Terraform infrastructure

Render is modeled as separate environment stacks:

- `qa` uses the `development` branch
- `staging` uses the `development` branch
- `prod` uses the `main` branch

The Render web services build with `bundle install && npm ci && bundle exec vite build` and start with Puma. QA runs jobs in-process; worker modules are defined in the environment stacks and enabled where configured. DNS/TLS is scaffolded but not yet implemented.

## Current Status

- The customer and PM order flows are implemented.
- Payments are wired through the `fake` provider and signed webhook simulation.
- Invoices are generated and persisted after successful payments.
- The app still carries some legacy naming at the persistence layer (`projects` behind `Order`).
- Render/Terraform infrastructure is scaffolded, but custom domain DNS/TLS remains a placeholder.

## Notes

- `make stack/up` supports rebuild flags through `STACK_ARGS`, for example `make stack/up STACK_ARGS="-d --build"`.
- `make stack/config` is useful for validating the Compose stack without starting containers.
