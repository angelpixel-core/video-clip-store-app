---
id: data-bootstrap-migrations
aliases: []
tags:
  - work-items
  - data
  - bootstrap
  - identity
  - migrations
  - seeds
  - environments
depends_on:
  - application-boundaries-and-repositories
  - order-domain-and-project-rename
order: 46
phase: work-items
status: done
title: Data Bootstrap Migrations
---

# Data Bootstrap Migrations

## Goal

- [x] Introduce a data bootstrap layer for minimum required records so fresh installs can start from an empty schema without relying on demo seeds.

## Scope

- Keep `seeds` for demo/local sample data.
- Add a separate data migration path for minimum required records.
- Bootstrap identity fixtures that the app needs to run, such as default workspace users, memberships, and any fixed reference data.
- Keep bootstrap values environment-driven where deploys need different addresses or identifiers.
- Avoid using data migrations for editable or customer-specific demo content.

## Current Codebase

- `db/data/20260729203959_bootstrap_identity_records.rb` now creates the required identity bootstrap records.
- `db/seeds.rb` now keeps only optional demo data such as the seed project and video types.
- `Identity::Application::Services::WorkspaceResolver` already depends on default workspace email environment variables.
- `Identity::Domain::Aggregates::User`, `Account`, and `Membership` already exist and are linked through persistence repositories.
- Environment templates now expose `DEFAULT_CLIENT_WORKSPACE_EMAIL` and `DEFAULT_PM_WORKSPACE_EMAIL`.
- `db/data/` is the bootstrap migration location, and `db:data:migrate` is the explicit runtime entrypoint.

## Design Notes

- Treat data migrations as required bootstrap, not demo content.
- Keep them idempotent and environment-aware.
- Prefer env vars for environment-specific bootstrap identities.
- Keep seeds small and deterministic for local/demo usage.

## Planned Flow

```text
schema migrate
  -> data bootstrap migrate
    -> create minimum identity records
    -> create minimum reference data
    -> resolve workspace defaults from env
  -> seeds (optional demo/local only)
```

## Implementation Plan

- [x] Define the data migration location and execution path for minimum bootstrap data.
- [x] Move required identity bootstrap records out of `db/seeds.rb` into data migrations.
- [x] Keep optional demo data in `db/seeds.rb`.
- [x] Make bootstrap values configurable through environment variables where needed.
- [x] Add specs or smoke checks for the bootstrap path.

## Expected Result

- A fresh database can boot with the minimum required identity data.
- Local/demo seeds remain available without becoming a source of production invariants.
- Environment-specific values can be supplied without hardcoding them into the migration.

## Affected Docs

- `docs/changes/003-payment-confirmation-operational-guide.md`
- `docs/work-items/041-application-boundaries-and-repositories.md`
- `docs/work-items/044-order-domain-and-project-rename.md`

## Affected Ops

- `db/migrate/`
- `db/seeds.rb`
- `db/data/`
- `env/*/app/core.env`
- `spec/unit/`
- `spec/requests/`

## Checklist

- [x] Bootstrap data is separated from demo seeds.
- [x] Minimum identity data is created through data migrations.
- [x] Workspace defaults are environment-driven.
- [x] Fresh installs can start without manual bootstrap steps.

## Validation

- [x] Specs or smoke checks cover the bootstrap flow.
- [x] Seeds remain deterministic and optional.
- [x] No environment-specific values are hardcoded into bootstrap data.

## Notes

- The goal is not to seed everything, only the minimum the app cannot function without.
- If a record is editable by users, it usually does not belong in bootstrap data unless it is also a hard dependency.
- `data migrations` should capture required product invariants; `seeds` should capture convenience/demo data.

## Follow-up Plan

- Introduce `Tenant` as the technical boundary and `Organization` as the business-facing root, both bootstrapped from environment variables.
- Replace the legacy `Project` naming with `Order` in the public domain and UI.
- Keep the existing catalog base, but formalize `Offering` / `OfferingVariant` naming over the current video-type structure.
- Treat `Fulfillment` as the internal execution process for an `Order`, not as the customer-facing purchase object.
- Use a data migrate to materialize the initial tenant/organization pair and associate existing records to it before removing legacy compatibility.
