---
id: application-boundaries-and-repositories
aliases: []
tags:
  - work-items
  - architecture
  - repositories
  - use-cases
  - controllers
  - modularization
depends_on:
  - payment-outbound-notifications
  - payment-invoice-generation-and-storage
order: 41
phase: work-items
status: done
title: Application Boundaries and Repositories
---

# Application Boundaries and Repositories

## Goal

- [x] Modularize the application boundaries so controllers stay thin, business workflows move to use cases/handlers, and local persistence access is isolated behind repositories.
- [x] Consolidate the `identity` vocabulary so workspace lookup, `User`, `Account`, and `Role` follow one explicit model instead of overlapping legacy names.

## Scope

- Split HTTP concerns from domain orchestration.
- Extract controller logic into use cases / handlers.
- Introduce repositories only for local persistence where they add value.
- Keep repositories focused on `ActiveRecord` access, not external integrations.
- Remove demo-only flags from domain objects and move them to test/demo tooling.
- Prepare the codebase for more explicit domain workflows without over-abstracting.
- Keep `Identity::Application::Queries::ResolveWorkspaceAccount` as the single workspace lookup entrypoint.
- Redesign the `identity` model so `User` is the identity root, `Account` is the operational workspace profile, and `Role` is an assignable concept that can grow from one role to many.
- Remove the assumption that a role is encoded only on `Account`; existing `client` and `pm` access should be expressible through `User` role assignments.
- Keep the current runtime behavior stable while the model is reshaped behind the existing application boundary.

## Operational Note

- `service` should mean external integration or side effect.
- `repository` should mean local persistence access.
- `use case` / `handler` should orchestrate business steps and talk to repositories/services.
- Controllers should only parse request input and render responses.

## Architecture Pattern

- Domain contracts live under `app/domains/**/domain/repositories/**/contract.rb`.
- Persistence implementations live under `app/models/**/adapters/persistence/**/repository.rb`.
- Active Record classes live alongside the adapter implementation under the same persistence namespace.
- Mappers translate between domain aggregates and persistence records; they keep repositories thin.

### Ordering Example

- `Ordering::Domain::Repositories::Order::Contract` defines the expected repository API.
- `Ordering::Adapters::Persistence::Order::Repository` implements the contract using Active Record.
- `Ordering::Adapters::Persistence::Order::Mapper` converts between `Order` aggregates and persistence records.
- `Ordering::Adapters::Persistence::Order::OrderRecord`, `OrderLineRecord`, and `SourceVideoRecord` are the ORM-backed records.

### Identity Example

- `Identity::Application::Queries::ResolveWorkspaceAccount` resolves the active workspace account used by the application.
- `Identity::Domain::Aggregates::User` owns identity-level data, access state, preferences, memberships, and lifecycle rules.
- `Identity::Domain::Aggregates::Account` remains the workspace-facing profile used by the app.
- `Identity::Domain::ValueObjects::Role` models role membership so a user can hold one or many roles.
- `Identity::Adapters::Persistence::Account::Repository` remains the persistence adapter for account lookups while the model transitions.

### Identity Architecture

- `User` is the identity root and owns the stable person-level invariants.
- `Account` is the tenant/workspace surface and keeps plan, limits, features, and workspace settings.
- `Membership` binds a `User` to an `Account`.
- `Role` belongs to the membership and grants capabilities/privileges.
- Capabilities live on `Role`, not on `Account`.
- If needed later, `role_capabilities` can refine granular permissions without changing the core split.

### Ordering Flow

```text
COMMAND / USE CASE
  CreateCheckoutOrder / PlaceOrder / ConfirmOrder
        |
        v
DOMAIN AGGREGATE
  Ordering::Domain::Aggregates::Order
        |
        |  applies policies
        |  emits events
        v
DOMAIN EVENT
  OrderDraftedEvent / OrderPlacedEvent / ...
        |
        v
DOMAIN CONTRACT
  Ordering::Domain::Repositories::Order::Contract
        |
        v
PERSISTENCE ADAPTER
  Ordering::Adapters::Persistence::Order::Repository
        |
        v
MAPPER
  Ordering::Adapters::Persistence::Order::Mapper
        |
        +------------------------------+
        |                              |
        v                              v
ACTIVE RECORD ROOT                ACTIVE RECORD CHILDREN
  OrderRecord                       OrderLineRecord
                                        SourceVideoRecord
        |                              |
        +--------------+---------------+
                       v
                      DB
```

- The use case talks to the domain contract, never directly to Active Record.
- The adapter implements the contract and uses the mapper to translate the aggregate tree.
- The records are infrastructure only; they do not carry domain behavior.
- The aggregate root owns the lifecycle and event emission for its children.

## Implementation Plan

- [x] Identify the highest-value flows to extract first.
- [x] Move payment and notification orchestration out of controllers into use cases.
- [x] Add repositories for local models only where repeated query/write logic exists.
- [x] Keep domain objects free of HTTP/demo concerns.
- [x] Define a consistent folder/package structure for application, domain, repository, and service layers.
- [x] Add specs around the extracted boundaries.
- [x] Keep `WorkspaceResolver` on `ResolveWorkspaceAccount` and document that the defaults are injected implicitly through configuration.
- [x] Introduce the `User`/`Role` redesign without breaking the current `Account`-based application flows.
- [x] Migrate or wrap the current single-role account behavior so client/PM access still resolves correctly.
- [x] Add specs that document the new identity vocabulary and the transition boundary.

### Identity Rollout Plan

1. Schema
   - [x] Migration 1: create a new `users` table with `email` (unique, not null), `access_state`, `preferred_locale`, `timezone`, `notification_settings`, and lifecycle timestamps such as `invited_at`, `verified_at`, `suspended_at`, and `deactivated_at`.
   - [x] Migration 2: create a new `memberships` table with `user_id`, `account_id`, `role`, timestamps, a unique index on `[user_id, account_id]`, and lookup indexes for account/role queries.
   - [x] Migration 3: add tenant/workspace configuration columns to `accounts` only if we need them during the transition, such as `plan`, `limits`, and `settings`, without dropping the existing columns yet.
   - [x] Migration 4: keep the current `accounts.email`, `accounts.role`, and existing relationship columns in place until the later migration/cleanup step proves parity.
2. Domain model
   - [x] Define the `User` aggregate as the canonical identity root with email uniqueness, access state, lifecycle timestamps, and preferences.
   - [x] Define the `Account` aggregate as the tenant/workspace surface with plan, limits, feature flags, and workspace settings.
   - [x] Introduce `Membership` as the association object that binds one `User` to one `Account`.
   - [x] Move role assignment onto `Membership` and keep `Role` as the capability-bearing value object or membership attribute.
   - [x] Keep `Account` role-related behavior only as a compatibility bridge until callers move to memberships.
   - [x] Add domain invariants that make `User` the source of identity and `Account` the source of tenant/workspace configuration.
3. Persistence
   - [x] 1. Add a `User` contract plus repository/adapter pair for user lookups and lifecycle updates.
   - [x] 2. Add a `Membership` contract plus repository/adapter pair for binding users to accounts and resolving roles.
   - [x] 3. Keep the current `Account` repository/adapter working during the transition, but teach it to traverse memberships when the caller needs user-account relationships.
   - [x] 4. Move `UserRepository` off direct `UserRecord` access into the new adapter boundary so application code only talks to contracts.
   - [x] 5. Add persistence specs for `User`, `Membership`, and the compatibility behavior in `AccountRepository`.
   - [x] 6. Preserve the existing `Account` lookup APIs until the application boundary switches over.
4. Application boundary
    - [x] Keep `ResolveWorkspaceAccount` stable.
    - [x] Update `WorkspaceResolver` and workspace helpers to derive behavior from the new identity model.
    - [x] Preserve `Account`-based callsites until the migration is complete.
5. Migration
   - [x] Backfill existing workspace identities into `users` and `memberships`.
   - [x] Validate that client/PM access still resolves correctly after the backfill.
   - [x] Remove legacy assumptions that `Account` owns identity or authorization only after parity is proven.
6. Specs
    - [x] Add unit specs for `User` invariants.
    - [x] Add specs for `Membership` role behavior.
    - [x] Add repository specs for the new persistence boundaries.
    - [x] Add transition specs for workspace resolution and existing account-facing flows.

Do not start step N+1 until step N is complete and validated.

## Affected Docs

- `docs/work-items/031-payment-domain-and-idempotency.md`
- `docs/work-items/034-payment-event-handler-pipeline.md`
- `docs/work-items/039-payment-outbound-notifications.md`
- `docs/work-items/040-payment-invoice-generation-and-storage.md`
- `docs/work-items/041-application-boundaries-and-repositories.md`

## Affected Ops

- `app/controllers/`
- `app/services/`
- `app/repositories/`
- `app/domain/`
- `app/jobs/`
- `spec/unit/`
- `spec/requests/`

## Checklist

- [x] Controllers no longer contain business workflow orchestration.
- [x] Repositories own repeated local data access.
- [x] Use cases coordinate domain steps and side effects.
- [x] Demo/test flags are not part of domain models.
- [x] The architecture is easier to extend for invoices, mail, and future payment methods.
- [x] `ResolveWorkspaceAccount` is the only workspace lookup query name used by application code.
- [x] `User`, `Account`, and `Role` have distinct responsibilities.
- [x] Role assignment can evolve beyond a single enum-like field on `Account`.
- [x] `User` owns identity and lifecycle while `Account` owns tenant/workspace settings.
- [x] `Membership` binds a user to an account and carries the role.

## Validation

- [x] Specs cover the extracted use cases.
- [x] Specs cover repository behavior.
- [x] Controllers remain thin and stable.
- [x] Specs cover `ResolveWorkspaceAccount` and its consumers.
- [x] Specs cover the `User`/`Account`/`Role` relationship boundary.

## Notes

- Start small: one flow first, then repeat the pattern.
- Don’t introduce repositories everywhere by default.
- Route modularization can be a follow-up if controller extraction forces it.
- For nested domain areas, prefer `Contract` in the domain and `Repository` in persistence to keep the boundary explicit.
- For `identity`, keep the operational `Account` surface stable while the richer `User`/`Role` model is introduced underneath it.
- Identity decision: `User` is identity, `Account` is tenant, `Membership` binds them, and `Role` grants capabilities.
- Neutral workspace access now flows through `workspace_for(:client)` / `workspace_for(:pm)` instead of `current_client` / `default_pm`.
- Workspace shell selection is driven by the `workspace_role` cookie and the `workspace-switch` UI controller.
- PM accept/complete orchestration now lives in `Orders::ActionService` instead of `OrdersController`.
- Next controller extraction to tackle: move the draft submission/payment flow out of `OrdersController#update`.
- Draft submission and payment orchestration now lives in `Fulfillment::Application::Commands::SubmitProject`.
