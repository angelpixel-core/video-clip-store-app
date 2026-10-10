---
id: BITACORA
aliases: []
tags: []
---

# Bitacora de Work Items

## 001 Bootstrap and Environment

- **What**: Established the Rails baseline, local Docker/MySQL environment, init scripts, `schema.rb`, and stage-separated environment templates.
- **Why**: To provide the minimum runnable foundation for the project before higher-level frontend, infra, and domain work.
- **Where**: `ops/compose/compose.yml`, `ops/containers/app/Dockerfile`, `ops/containers/db/entrypoint/initdb.d/001-bootstrap.sh`, `config/database.yml`, `env/*`
- **Learned**: Keep bootstrap minimal, prefer `schema.rb` over `structure.sql` when possible, and use per-consumer env templates to avoid leakage between app/db/stack/repo provisioning.

## 002 Testing Foundation

- **What**: Defined the shared testing stack and directory structure for RSpec, Capybara, WebMock, VCR, Cucumber, and manual Mutant evidence.
- **Why**: To standardize testing across unit, request, integration, smoke, acceptance, contract, and performance layers.
- **Where**: `spec/`, `bin/rspec`, `bin/cucumber`, `ops/containers/app/entrypoint.sh`, `ops/containers/app/Dockerfile`, `Gemfile`
- **Learned**: Keep test architecture under `spec/`, make Cucumber manual-only, and treat request specs as the base for future API contract generation.

## 003 CI/CD and Environments

- **What**: Defined the end-to-end delivery pipeline across local/dev, CI/test, QA, staging, and production with promotion rules and environment-specific image stages.
- **Why**: To make deployment behavior explicit, deterministic, and gated from local development through production.
- **Where**: `Makefile`, `ops/scripts/stack.sh`, `ops/scripts/repo/create.sh`, `ops/compose/compose.yml`, `ops/containers/app/Dockerfile`, `docs/work-items/001-bootstrap-and-environment.md`
- **Learned**: Keep QA, staging, and prod separate on purpose; run lint early once; and make PR automation use a dedicated token plus manual merge control.

## 004 Frontend Toolchain

- **What**: Set up Vite as the frontend toolchain and moved Bootstrap/jQuery to frontend dependencies.
- **Why**: To separate frontend asset management from Rails and keep the development loop hot-reload friendly.
- **Where**: `Gemfile`, `config/application.rb`, `app/views/layouts/application.html.erb`, `package.json`, `ops/containers/app/Dockerfile`, `ops/containers/app/entrypoint.sh`
- **Learned**: Keep Rails focused on backend concerns, treat Bootstrap/jQuery as frontend dependencies, and remove importmap-based frontend management when Vite owns the asset pipeline.

## 005 SSH Authentication and Commit Signing

- **What**: Documented and applied SSH authentication plus SSH commit signing with separate keys for auth and signing.
- **Why**: To make GitHub access and commit verification explicit, reproducible, and safer by default.
- **Where**: `~/.ssh/config`, `~/.ssh/company/repositories/github/<org>/<repo>/<auth-key>`, `~/.ssh/company/repositories/github/<org>/<repo>/<signing-key>`, global `git config`, `docs/decisions/04-ssh-authentication-and-commit-signing.md`
- **Learned**: Keep auth and signing keys separate, prefer SSH signing over GPG for this repo, and verify signatures with `git log --show-signature -1`.

## 006 Render Infrastructure Requirements

- **What**: Defined the Render infrastructure requirements for production, including workspace bootstrap, service map, PostgreSQL, DNS/TLS, and deployment handoff.
- **Why**: To make the production hosting target explicit and unblock the remaining deployment promotion work.
- **Where**: Render workspace and services, GitHub Actions deployment workflow, DNS/registrar, `docs/decisions/05-render-infrastructure-target.md`, `docs/decisions/06-database-engine-matrix.md`, `docs/decisions/07-infrastructure-as-code-strategy.md`
- **Learned**: Treat the current `-qa` slug as a legacy naming artifact, keep DNS selection and backup policy explicit, and use Render-managed PostgreSQL for production.

## 007 Database Engine and IaC Strategy

- **What**: Defined the database engine matrix and Terraform-based infra strategy, starting with QA adoption on Render and scaffolding staging/prod for later rollout.
- **Why**: To make database/runtime boundaries explicit and keep infrastructure portable and reproducible across environments.
- **Where**: `ops/infra/render/`, `ops/infra/render/components/{web,worker,database,dns}/`, `ops/infra/render/envs/{qa,staging,prod}/`, `.github/workflows/promote-staging.yml`, `Gemfile.lock`
- **Learned**: Keep `dev/test` on MySQL and `qa` on PostgreSQL, adopt live Render resources via Terraform instead of recreating them, and leave staging/prod disabled until the workspace plan changes.

## 008 Render Stack Portability

- **What**: Parameterized the Render/Terraform stack so it can be reused across Render accounts by externalizing account-specific values.
- **Why**: To make the infrastructure portable without hardcoding workspace-specific IDs into reusable defaults.
- **Where**: `.github/workflows/infra-render.yml`, `Makefile`, `ops/scripts/secrets.sh`, `ops/infra/render/envs/{qa,staging,prod}/providers.tf`, `variables.tf`
- **Learned**: Keep the workspace owner ID, API key, and resource IDs as inputs; portability means configuration reuse, not bypassing the current Hobby-plan limits.

## 009 Render Portability Validation

- **What**: Defined the proof step for verifying the stack on a second GitHub account and Render workspace without changing source code.
- **Why**: To confirm the portability work actually survives a fresh account/workspace setup.
- **Where**: GitHub repository settings, GitHub Actions secrets/variables, Render dashboard/workspace settings, `.github/workflows/`
- **Learned**: Validation should prove the same Terraform/workflow source works in another account; account-specific bootstrap belongs elsewhere.

## 010 Render Bootstrap Guide

- **What**: Documented the bootstrap runbook for creating the repo, wiring Render, and ordering the initial workflows in a fresh account.
- **Why**: To make first-time setup reproducible without relying on prior session memory.
- **Where**: GitHub repository creation, Render workspace/project creation, GitHub Actions secrets and repository variables, `make secrets/*`
- **Learned**: Keep the guide operational rather than architectural, and list the manual checkpoints explicitly so a new operator can follow it end to end.
