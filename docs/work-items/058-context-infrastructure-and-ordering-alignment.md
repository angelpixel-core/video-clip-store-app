---
id: context-infrastructure-and-ordering-alignment
aliases: []
tags:
  - work-items
  - architecture
  - contexts
  - infrastructure
  - persistence
  - ordering
  - fulfillment
depends_on:
  - contexts-shared-kernel-and-legacy-cleanup
order: 58
phase: work-items
status: todo
title: Context Infrastructure Unification and Ordering/Fulfillment Alignment (Phase 2)
---

# Context Infrastructure Unification and Ordering/Fulfillment Alignment (Phase 2)

## Goal

- [ ] Standardize every Bounded Context under `app/contexts/<context>/` around the 3 canonical layers: `domain/`, `application/`, and `infrastructure/` (`persistence/`, `external/`, `di/`).
- [ ] Consolidate scattered persistence adapters from `app/models/{billing,fulfillment,identity}/adapters/persistence/` and DI containers from `app/system/` into their owning contexts' `infrastructure/` layer.
- [ ] Align the boundary between `ordering` and `fulfillment` by moving customer order lifecycle commands (`CreateDraftOrder`, `AutosaveDraftOrder`, `UpdateOrder`, `SubmitOrder`) from `fulfillment` to `ordering`.

## Scope

- All 8 Bounded Contexts in `app/contexts/{billing,capacity,catalog,fulfillment,identity,notifications,ordering,payments}` and `app/shared_kernel`.
- Consolidation of `app/models/<context>/adapters/persistence/` and `app/system/` into `infrastructure/persistence/` and `infrastructure/di/`.
- Removal of empty `app/contexts/billing/presentation/` directories.
- Normalization of `dtos/` and repository contracts across contexts.

## Affected Docs

- `docs/work-items/058-context-infrastructure-and-ordering-alignment.md`
- `docs/work-items/index.md`
- `docs/decisions/10-billing-presentation-and-adapter-taxonomy.md`

## Affected Ops

- `app/contexts/**`
- `app/shared_kernel/**`
- `app/models/**`
- `app/system/**` (removed)

## Implementation Plan

- [ ] **Step 1: Rename `adapters/` to `infrastructure/` Across Contexts**
  - [ ] Rename `app/contexts/*/adapters` to `app/contexts/*/infrastructure` and update module namespaces (`*::Infrastructure::*`).
  - [ ] Remove empty `app/contexts/billing/presentation/` directories and `app/contexts/billing/adapters/outbound/persistence/` placeholder.
- [ ] **Step 2: Consolidate Scattered Persistence from `app/models/`**
  - [ ] Move `app/models/billing/adapters/persistence/invoice/*` to `app/contexts/billing/infrastructure/persistence/invoice/`.
  - [ ] Move `app/models/identity/adapters/persistence/*` to `app/contexts/identity/infrastructure/persistence/*`.
  - [ ] Move `app/models/fulfillment/adapters/persistence/order/repository.rb` to `app/contexts/ordering/infrastructure/persistence/order/` (or `fulfillment/infrastructure/persistence/order/`).
  - [ ] Remove `app/models/{billing,fulfillment,identity}` directories from `app/models/`.
- [ ] **Step 3: Move DI Containers from `app/system/` to `infrastructure/di/`**
  - [ ] Move `app/system/billing/container.rb` to `app/contexts/billing/infrastructure/di/container.rb`.
  - [ ] Move `app/system/payments/container.rb` to `app/contexts/payments/infrastructure/di/container.rb`.
  - [ ] Move `app/system/app_container.rb` to `app/shared_kernel/infrastructure/di/app_container.rb`.
  - [ ] Remove `app/system/` directory.
- [ ] **Step 4: Align `ordering` and `fulfillment` Commands**
  - [ ] Move `CreateDraftOrder`, `AutosaveDraftOrder`, `UpdateOrder`, and `SubmitOrder` from `app/contexts/fulfillment/application/commands/` to `app/contexts/ordering/application/commands/`.
  - [ ] Keep `ProcessOrderAction` and `ActionService` in `app/contexts/fulfillment/application/`.
  - [ ] Update controller/service callsites, `package.yml` dependencies, and unit specs.
- [ ] **Step 5: Normalize Internal Subfolders (`dtos/`, `repositories/`)**
  - [ ] Standardize `application/dto/` → `application/dtos/`.
  - [ ] Deduplicate `identity/domain/repositories/` contracts (`account_repository.rb` vs `account/contract.rb`).

## Checklist

- [ ] Every context in `app/contexts/<context>/` strictly follows `domain/`, `application/`, `infrastructure/`.
- [ ] `app/contexts/billing/presentation/` no longer exists.
- [ ] `app/models/{billing,fulfillment,identity}/` no longer exist inside `app/models/`.
- [ ] `app/system/` no longer exists.
- [ ] `CreateDraftOrder`, `AutosaveDraftOrder`, `UpdateOrder`, and `SubmitOrder` reside under `Ordering::Application::Commands`.

## Validation

- [ ] `bundle exec rails zeitwerk:check` passes cleanly.
- [ ] `make test/unit` and integration specs pass with 0 failures.
- [ ] `bundle exec rubocop` passes with 0 offenses.

