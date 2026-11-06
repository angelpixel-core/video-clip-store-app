---
id: bounded-contexts-and-rails-interface-taxonomy
title: Bounded Contexts and Rails Interface Taxonomy
phase: decisions
order: 13
aliases: []
tags:
  - decisions
  - architecture
  - contexts
  - shared-kernel
  - rails
  - zeitwerk
  - packwerk
---

# Bounded Contexts and Rails Interface Taxonomy

## Decision

The application organizes business logic and framework interfaces around explicit Bounded Contexts (`ordering`, `fulfillment`, `catalog`, `capacity`, `payments`, `billing`, `identity`, `notifications`) plus a cross-cutting `shared_kernel`:

1. **Bounded Contexts & Shared Kernel (`app/contexts/<context>/` and `app/shared_kernel/`)**:
   - Placed directly under `app/` so Rails 8 / Zeitwerk treats both as root autoload paths (`Billing::Domain::*`, `Ordering::Application::*`).
   - Each Bounded Context under `app/contexts/<context>/` contains strictly three layers:
     - `domain/` (`aggregates/`, `entities/`, `value_objects/`, `policies/`, `events/`, `errors/`, `repositories/`)
     - `application/` (`commands/`, `queries/`, `handlers/`, `workflows/`, `ports/`, `dtos/`)
     - `infrastructure/` (`persistence/`, `external/`, `di/`)
2. **Rails as the Driver/Interface Layer (`app/<layer>/<context>/`)**:
   - Rails owns the incoming HTTP/Web/Realtime/Worker interface and view rendering (`config/routes.rb` → `app/controllers/<context>/` → `app/presenters/<context>/` → `app/views/<context>/`, plus `app/jobs/<context>/`, `app/mailers/<context>/`, and `app/channels/<context>/`).
   - Every Ruby/ERB subdirectory of `app/` segments its contents by `<context>` at the first level, keeping only framework base classes (`application_*.rb`, `layouts/`, `pwa/`) at the root or under `shared/`.
3. **Elimination of Legacy Root Siblings**:
   - `app/value_objects/`, `app/services/`, `app/system/`, and `lib/core/` are retired in favor of `app/contexts/<context>/` and `app/shared_kernel/`.
   - `lib/` is reserved strictly for `lib/tasks/*.rake` and pure stateless utilities with zero business rules (`lib/parsers/`).

## Scope

- Supersedes the context-internal `presentation/` and `adapters/inbound/` HTTP placement from ADR-10 by keeping Rails controllers, jobs, mailers, presenters, and views in their native `app/<layer>/<context>/` directories outside `app/contexts/<context>/`.
- Unifies persistence records, repositories, and mappers inside `app/contexts/<context>/infrastructure/persistence/`.
- Aligns customer order lifecycle commands (`CreateDraftOrder`, `AutosaveDraftOrder`, `UpdateOrder`, `SubmitOrder`) under `ordering`, leaving operational execution (`ProcessOrderAction`, `ActionService`) in `fulfillment`.

## Rationale

- Preserves the Rails-way experience for routing, controllers, ERB rendering, mailers, jobs, and ActionCable channels while enforcing Clean/Hexagonal/DDD boundaries inside `app/contexts/<context>/`.
- Leverages Zeitwerk's native convention where multiple `app/*/<context>` directories seamlessly share the top-level Ruby module namespace (`<Context>::*`) without custom autoload hacks.
- Eliminates structural drift across slices (`adapters` vs `models/*/adapters`, `dto` vs `dtos`, scattered DI containers).

## Consequences

- Implemented incrementally across Work-Items 057, 058, 059, and 060.

