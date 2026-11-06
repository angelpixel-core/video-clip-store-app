---
id: contexts-shared-kernel-and-legacy-cleanup
aliases: []
tags:
  - work-items
  - architecture
  - contexts
  - shared-kernel
  - zeitwerk
  - packwerk
  - cleanup
depends_on:
  - application-boundaries-and-repositories
  - billing-presentation-and-adapter-taxonomy
order: 57
phase: work-items
status: todo
title: Contexts, Shared Kernel and Legacy Folder Cleanup (Phase 1)
---

# Contexts, Shared Kernel and Legacy Folder Cleanup (Phase 1)

## Goal

- [ ] Rename `app/domains/` to `app/contexts/` and extract `app/domains/shared/` into `app/shared_kernel/` as direct root autoload paths under `app/`.
- [ ] Eliminate legacy root folders `app/value_objects/`, `app/services/`, and `lib/core/` by deleting dead code and migrating active orchestration/contracts into their corresponding Bounded Contexts or `app/shared_kernel/`.
- [ ] Clean up repository workspace hygiene (`**/.DS_Store`, `.playwright-mcp/`, and `.gitignore` rules).

## Scope

- Rename `app/domains/<context>` → `app/contexts/<context>` for `billing`, `capacity`, `catalog`, `fulfillment`, `identity`, `notifications`, `ordering`, and `payments`.
- Extract `app/domains/shared` → `app/shared_kernel`.
- Remove dead classes and specs:
  - `app/value_objects/email_address.rb` (`EmailAddress`)
  - `app/services/submission_policy.rb` (`SubmissionPolicy`)
  - `app/models/submission.rb` (`Submission`)
  - `lib/core/services/notifications/channel.rb` (`Core::Services::Notifications::Channel`)
  - `lib/core/services/notifications/dispatcher.rb` (`Core::Services::Notifications::Dispatcher`)
- Migrate active contracts and feature flags to `app/shared_kernel/`:
  - `lib/core/services/provider.rb` → `app/shared_kernel/core/services/provider.rb`
  - `app/models/features.rb` → `app/shared_kernel/features.rb`
- Migrate active services out of `app/services/` and remove `app/services/`:
  - `app/services/orders/action_service.rb` → `app/contexts/fulfillment/application/services/action_service.rb`
  - `app/services/orders/notifications/service.rb` → `app/contexts/notifications/application/notifications/order_event_service.rb`
  - `app/services/project_notification_subject.rb` → `app/contexts/notifications/application/notifications/project_notification_subject.rb`

## Affected Docs

- `docs/work-items/057-contexts-shared-kernel-and-legacy-cleanup.md`
- `docs/work-items/index.md`
- `docs/decisions/13-bounded-contexts-and-rails-interface-taxonomy.md`

## Affected Ops

- `.gitignore`
- `config/application.rb`
- `packwerk.yml`
- `package.yml`
- `app/contexts/*/package.yml`
- `app/shared_kernel/package.yml`

## Implementation Plan

- [ ] **Step 1: Repository Hygiene**
  - [ ] Remove untracked `.DS_Store` files across the repository and add `.DS_Store` / `**/.DS_Store` to `.gitignore`.
  - [ ] Remove local `.playwright-mcp/` log/snapshot artifacts.
  - [ ] Verify `log/` only tracks `.keep`.
- [ ] **Step 2: `app/shared_kernel/` & `app/contexts/` Extraction**
  - [ ] Move `app/domains/shared/` to `app/shared_kernel/`.
  - [ ] Move `app/domains/{billing,capacity,catalog,fulfillment,identity,notifications,ordering,payments}` to `app/contexts/`.
  - [ ] Remove empty `app/domains/` directory.
  - [ ] Update `config/application.rb` autoload/eager_load paths from `app/domains/shared` to `app/shared_kernel`.
  - [ ] Update `packwerk.yml`, root `package.yml`, and all `app/contexts/*/package.yml` dependencies from `app/domains/*` to `app/contexts/*` and `app/shared_kernel`.
- [ ] **Step 3: Dead Code Removal (`app/value_objects/`, `Submission`, `lib/core/services/notifications/`)**
  - [ ] Delete `app/value_objects/email_address.rb`, `spec/unit/value_objects/email_address_spec.rb`, and remove `app/value_objects/`.
  - [ ] Delete `app/services/submission_policy.rb` and `spec/unit/services/submission_policy_spec.rb`.
  - [ ] Delete `app/models/submission.rb` and `spec/unit/models/submission_spec.rb`.
  - [ ] Delete `lib/core/services/notifications/channel.rb` and `lib/core/services/notifications/dispatcher.rb`.
- [ ] **Step 4: Shared Kernel Consolidation (`Provider` & `Features`)**
  - [ ] Move `lib/core/services/provider.rb` into `app/shared_kernel/core/services/provider.rb` and remove `lib/core/`.
  - [ ] Move `app/models/features.rb` into `app/shared_kernel/features.rb` (and move `spec/unit/models/features_spec.rb` accordingly).
- [ ] **Step 5: Migrate `app/services/` into Contexts**
  - [ ] Move `app/services/orders/action_service.rb` into `app/contexts/fulfillment/application/` and update callers in `WorkspaceProjectShell` and specs.
  - [ ] Move `app/services/orders/notifications/service.rb` and `app/services/project_notification_subject.rb` into `app/contexts/notifications/application/` and update callers (`ProjectNotificationMailer`, `ActionService`, `SubmitOrder`, and specs).
  - [ ] Remove empty `app/services/` directory.
  - [ ] Rename `spec/unit/domains/` to `spec/unit/contexts/`.

## Checklist

- [ ] `app/domains/` no longer exists; `app/contexts/` and `app/shared_kernel/` are active.
- [ ] `app/value_objects/` no longer exists.
- [ ] `app/services/` no longer exists.
- [ ] `lib/core/` no longer exists; `lib/` only contains `lib/parsers/` and `lib/tasks/`.
- [ ] `packwerk.yml` and all `package.yml` manifests point to `app/contexts/*` and `app/shared_kernel`.
- [ ] No lingering `.DS_Store` or `.playwright-mcp` artifacts exist in the working tree.

## Validation

- [ ] `bundle exec rails zeitwerk:check` passes cleanly.
- [ ] `make test/unit` passes with 0 failures.
- [ ] `bundle exec rubocop` passes with 0 offenses.

## Notes

- Preserves existing Ruby module constants (`Billing::*`, `Payments::*`, `Ordering::*`, `Core::Result`, `Features`) during Phase 1 to ensure a zero-regression foundation for Phases 2–4.

