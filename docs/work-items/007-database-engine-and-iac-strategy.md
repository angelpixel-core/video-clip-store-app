---
id: database-engine-and-iac-strategy
aliases: []
tags:
  - work-items
  - database
  - mysql
  - postgresql
  - terraform
  - render
depends_on:
  - render-infrastructure-requirements
  - ssh-authentication-and-commit-signing
order: 7
phase: work-items
status: done
title: Database Engine and IaC Strategy
---

# Database Engine and IaC Strategy

## Goal

- [x] Define and implement the database engine matrix and Terraform-based infrastructure strategy for QA now.
  - [x] Staging and prod remain future extension points.

## Operational Note

- The currently deployed Render environment is now treated as `production`.
- `qa` and `staging` will be created as new environments rather than reusing the existing production runtime.
- Because the workspace is on Render Hobby, keep QA as the only active deploy target for now.
- Keep the manual `Promote` gate and `development -> main` release PR flow active.
- Leave staging and production deploy triggers in the repo, but disable the steps that actually deploy to those environments until the workspace plan changes.

## Current Flow

| Event | Workflow | Action |
| --- | --- | --- |
| Push to `work-items/*` | `ci.yml` | Run lint and tests, then open or update the PR to `development`. |
| Merge to `development` | Render deploy path | Deploy the active runtime to QA. |
| Manual approval in QA | `promote-staging.yml` | Keep the `Promote` gate, but do not deploy to staging on Hobby. |
| QA approval succeeds | `promote-staging.yml` | Create or update the `development -> main` release PR. |
| Push / merge to `main` | release flow | Run the usual checks and create the release tag when applicable. |
| Any staging/prod deploy trigger | `promote-staging.yml` / infra workflows | Disabled until the workspace plan changes. |

## Portability Matrix

| Area | Hardcoded | Variable / Secret |
| --- | --- | --- |
| Terraform module names | `web`, `database`, `worker`, `dns` | n/a |
| Environment names | `qa`, `staging`, `prod` | n/a |
| GitHub Actions workflow names | `CI`, `Infra Render`, `Promote Staging` | n/a |
| Render workspace owner | n/a | `RENDER_OWNER_ID` |
| Render API auth | n/a | `RENDER_API_KEY` |
| Rails master key | n/a | `RAILS_MASTER_KEY` |
| Render service IDs | n/a | `RENDER_QA_SERVICE_ID`, `RENDER_STAGING_SERVICE_ID`, `RENDER_PROD_SERVICE_ID` |
| Render environment IDs | n/a | `RENDER_QA_ENVIRONMENT_ID`, `RENDER_STAGING_ENVIRONMENT_ID`, `RENDER_PROD_ENVIRONMENT_ID` |
| Service/import IDs currently adopted | `srv-d9a05ut7vvec738cb0n0`, `dpg-d9a0goecjfls73928u5g-a` | n/a until re-adopting elsewhere |

## Scope

- MySQL for `dev` and `test`.
- PostgreSQL for `qa`.
- Rails app compatibility for PostgreSQL on Render.
- Rails database adapter configuration for QA.
- Schema format choice and portability guardrails.
- Terraform-based provisioning for Render resources.
- Staging and prod will follow the same pattern when they are activated.

## Implementation Plan

- [x] Create the Terraform base files for each environment under `ops/infra/render/envs/{qa,staging,prod}`.
- [x] Create reusable modules under `ops/infra/render/components/{web,worker,database,dns}`.
- [x] Wire `qa` to the live Render web service and PostgreSQL service.
- [x] Express QA adoption with Terraform `import` blocks.
- [x] Validate the QA wiring with `terraform fmt`, `terraform init -backend=false`, and `terraform plan`.
  - [x] Run `terraform fmt -recursive ops/infra/render`.
  - [x] Run `terraform -chdir=ops/infra/render/envs/qa init -input=false -backend=false`.
  - [x] Run `terraform -chdir=ops/infra/render/envs/qa plan` and confirm the existing QA web service and Postgres are adopted, not recreated.
  - [x] Confirm the worker stays absent until a real QA worker exists in Render.
- [x] Reconcile the imported QA Render state to reduce provider-normalized plan drift.
- [x] Mirror the same structure into `staging` without live state yet.
  - [x] Add a manual `Promote` workflow in GitHub Actions that preserves the approval gate.
  - [x] Create the `development -> main` PR automatically after the approval gate succeeds.
  - [x] Keep the staging deploy steps present in the workflow, but disabled for the current Hobby plan.
  - [x] Keep the production deploy steps present in the workflow, but disabled for the current Hobby plan.

### Staging Scaffold Checklist

- [x] `ops/infra/render/envs/staging/versions.tf`
  - [x] Keep the same Terraform and provider constraints as QA.
- [x] `ops/infra/render/envs/staging/providers.tf`
  - [x] Wire `owner_id` and `RENDER_API_KEY` the same way as QA.
- [x] `ops/infra/render/envs/staging/variables.tf`
  - [x] Define `rails_master_key` and `environment_id` as required inputs.
- [x] `ops/infra/render/envs/staging/main.tf`
  - [x] Mirror the QA module layout for `web` and `database` without live IDs or imports.
  - [x] Keep `worker` absent unless staging explicitly needs it.
- [x] `ops/infra/render/envs/staging/outputs.tf`
  - [x] Expose the IDs and URLs needed for validation and promotion.
- [x] `ops/infra/render/envs/staging/imports.tf`
  - [x] Leave empty or placeholder-only until staging has live Render state.
- [x] `ops/infra/render/envs/staging/README.md`
  - [x] Document staging as the manual signoff and promotion gate after QA.
- [x] `.github/workflows/promote-staging.yml`
  - [x] Add `workflow_dispatch` so QA can trigger `Promote` from GitHub Actions.
  - [x] Deploy the QA-approved artifact to staging.
  - [x] Run staging smoke checks after deploy.
  - [x] Create or update the `development -> main` PR only after staging succeeds.
- [x] `docs/work-items/003-ci-cd-and-environments.md`
  - [x] Update the delivery flow to show QA approval -> Promote -> staging -> release PR -> main -> prod.
- [x] `docs/decisions/03-ci-pr-promotion-strategy.md`
  - [x] Record that the release PR is system-created after staging success.
  - [x] Record that the release PR uses a dedicated token.

### Production Scaffold Checklist

- [x] `ops/infra/render/envs/prod/versions.tf`
  - [x] Keep the same Terraform and provider constraints as QA.
- [x] `ops/infra/render/envs/prod/providers.tf`
  - [x] Wire `owner_id` and `RENDER_API_KEY` the same way as QA.
- [x] `ops/infra/render/envs/prod/variables.tf`
  - [x] Define `rails_master_key` and `environment_id` as required inputs.
  - [x] Define a worker enablement input so the prod worker can be prepared without turning it on yet.
- [x] `ops/infra/render/envs/prod/main.tf`
  - [x] Mirror the staging module layout for `web` and `database` without live IDs or imports.
  - [x] Prepare the `worker` module wiring, but keep it disabled by default until prod actually needs it.
- [x] `ops/infra/render/envs/prod/outputs.tf`
  - [x] Expose the IDs and URLs needed for validation and promotion.
- [x] `ops/infra/render/envs/prod/imports.tf`
  - [x] Leave empty or placeholder-only until production has live Render state.
- [x] `ops/infra/render/envs/prod/README.md`
  - [x] Document prod as the final release environment after the release tag is created.

## Affected Docs

- `docs/decisions/05-render-infrastructure-target.md`
- `docs/decisions/06-database-engine-matrix.md`
- `docs/decisions/07-infrastructure-as-code-strategy.md`
- `docs/decisions/index.md`
- `docs/work-items/006-render-infrastructure-requirements.md`
- `docs/overview.md`

## Affected Ops

- `Gemfile`
- `Gemfile.lock`
- `config/database.yml`
- `db/schema.rb`
- `ops/infra/render/`
- `ops/infra/render/components/database/`
- `ops/infra/render/envs/staging/`
- `ops/infra/render/envs/prod/`
- `.github/workflows/promote-staging.yml`
- GitHub Actions infra workflow

## Checklist

- [x] Document the MySQL-to-PostgreSQL environment matrix.
  - [x] Keep `dev` and `test` on MySQL and `qa` on PostgreSQL, with staging/prod reserved for future rollout.
- [x] Confirm `schema.rb` remains the default schema format.
  - [x] The schema strategy is already captured in `docs/decisions/02-rails-schema-format.md`.
- [x] Update Rails database configuration for PostgreSQL in `qa`.
  - [x] Add or adjust a QA-specific Rails config so `DATABASE_URL` is consumed in the deployed environment.
- [x] Add the production PostgreSQL driver dependency.
  - [x] `pg` is already present in the production bundle group in `Gemfile`.
- [x] Define the infra layout for Render provisioning.
  - [x] Create a tool-agnostic `ops/infra/render/` tree organized by platform and environment.
  - [x] Add reusable component/module directories for `web`, `worker`, `database`, and `dns`.
  - [x] Add environment directories for `qa`, `staging`, and `prod`.
- [x] Define the infra inventory for each environment.
  - [x] Provision one web service, one worker service, and one managed PostgreSQL service per environment.
  - [x] Keep QA and staging workers separate so queue/config boundaries stay isolated.
  - [x] Capture env vars, secrets, hostname, and TLS requirements per environment.
- [x] Define the infra pipeline triggers for `fmt`, `validate`, `plan`, and `apply`.
  - [x] Run `fmt` and `validate` on pull requests that touch `ops/infra/render/**`.
  - [x] Run `plan` for `qa` and `staging` on pull requests that touch `ops/infra/render/**`.
  - [x] Trigger `apply` manually, one environment at a time.
  - [x] Gate `apply` with approval or protected environment rules.
  - [x] Add GitHub Actions wiring for infra-only validation and approval-gated apply.
- [x] Define the adoption path for existing QA Render resources.
  - [x] Document how Terraform will adopt the live QA Render state before staging is introduced.
  - [x] Capture the concrete Render resource names and hostnames when the Terraform stack is introduced.

## Validation 

- [x] The environment matrix is explicit and documented.
- [x] The Terraform strategy is explicit and documented.
- [x] The Rails database configuration supports all runtime environments.
  - [x] QA-specific Rails database config is present and wired through `DATABASE_URL`.
- [x] The Rails app can connect to PostgreSQL in Render without affecting local MySQL.
  - [x] Verified with `curl -fsS https://video-project-submission-app-qa.onrender.com/up/db` after the QA deploy finished.
- [x] The infra pipeline can be run independently of app feature work.
  - [x] `ops/infra/render/` exists, the workflow is in place, and QA `terraform fmt`, `init`, and `plan` are validated.

## Notes

- Keep the matrix conservative while the project stays on `schema.rb`.
- Prefer separate pipelines for app code and infrastructure code.
- Avoid introducing Pulumi as an extra wrapper unless Terraform becomes insufficient.
- Future rollout note: staging and prod follow the same matrix once QA is stable.
- This work item closes the loop on the database-engine and provisioning strategy for QA first.
