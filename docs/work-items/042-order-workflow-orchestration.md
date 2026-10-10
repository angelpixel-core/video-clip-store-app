---
id: order-workflow-orchestration
aliases: []
tags:
  - work-items
  - payment
  - orders
  - workflow
  - orchestration
  - saga
depends_on:
  - application-boundaries-and-repositories
  - payment-outbound-notifications
  - payment-invoice-generation-and-storage
order: 42
phase: work-items
status: done
title: Order Submission Workflow Orchestration
---

# Order Submission Workflow Orchestration

## Goal

- [x] Model the order/submission/payment flow as an explicit workflow with clear steps for validation, capture/confirmation, success handling, invoice creation, and follow-up notifications.

## Scope

- Introduce a workflow/orchestrator layer for order processing.
- Model payment-related business steps as ordered stages instead of controller-driven branching.
- Separate pre-payment validation from payment capture/confirmation.
- Allow downstream steps to run only after the payment state reaches the expected checkpoint.
- Keep the workflow extensible for future payment methods and fulfillment paths.
- Avoid coupling the workflow to a single provider or a single notification type.

## Naming Direction

- `Catalog::Bundle` represents what is sold.
- `Ordering::Order` represents the customer purchase.
- `Ordering::LineItem` represents each selected bundle inside the order.
- `Ordering::Submission` represents the act of sending the order into payment and follow-up processing.
- `Fulfillment::Project` represents the operational work derived from the order.
- `Payments::Payment` remains the payment record and should not become the primary workflow root.

## Workflow Map

### Current Flow Today

```text
OrdersController#update
  -> Fulfillment::Application::Commands::UpdateProject
    -> Fulfillment::Application::Commands::SubmitProject (when finalize=1)
      -> pre-flight validation (selections present)
      -> Project.transaction / project.with_lock
      -> project.submit!
      -> sync selections
      -> Payments::Application::Commands::CreatePayment
        -> create or reuse active payment
        -> provider gateway call
        -> update payment state to processing / failed
      -> NotificationJob.perform_later(project.id)
        -> Orders::Notifications::Service
          -> create project notification
          -> notification delivery
```

### Target Workflow

```text
Workflow entrypoint
  Ordering::Application::Commands::ProcessSubmission
    |
    |-- Step 1: validate_submission
    |     - requires line items
    |     - validates order/submission attributes
    |
    |-- Step 2: capture_or_confirm_payment
    |     - delegates to Payments::Application::Commands::CreatePayment
    |     - persists payment attempt and provider state
    |
    |-- Step 3: success_handling
    |     - records success checkpoint
    |     - hands off to follow-up jobs
    |
    |-- Step 4: enqueue_follow_up_work
          - notification dispatch
          - invoice generation/storage
          - provider-agnostic post-confirmation work
```

### Step Boundaries

- `validate_submission` should fail fast before any side effects.
- `capture_or_confirm_payment` should own payment state transitions only.
- `success_handling` should run only after the payment reaches the expected checkpoint.
- `enqueue_follow_up_work` should be idempotent and safe to retry.

### Current File Mapping

- `Fulfillment::Application::Commands::SubmitProject` owns the current workflow orchestration and still acts as the transition bridge.
- `Payments::Application::Commands::CreatePayment` owns payment capture/provider confirmation.
- `Payments::Application::Handlers::GenerateInvoiceJob` owns invoice generation/storage after success.
- `Payments::Application::Handlers::DispatchPaymentNotificationJob` owns payment status email delivery.
- `Orders::Notifications::Service` and `NotificationJob` own project submission notifications.

### Command Sequence

```text
Controller / bridge
  -> Fulfillment::Application::Commands::SubmitProject
    -> build Ordering::Application::DTO::Submission
       - order
       - fulfillment_account
       - payment_provider
       - payment_method_type
       - metadata
    -> Ordering::Application::Commands::ProcessSubmission.call(submission:)
      -> validate_submission(submission)
         - requires order present
         - requires line items present
         - requires fulfillment account present
         - validates submittable order state
      <- failure? stop and return failure

      -> capture_or_confirm_payment(submission)
         -> Payments::Application::Commands::CreatePayment.call(
              project/order: submission.order,
              provider: submission.payment_provider,
              payment_method_type: submission.payment_method_type
            )
         <- payment_result
         - if failure: stop and return failure

      -> success_handling(submission, payment)
         - record the success checkpoint
         - prepare downstream payloads

      -> enqueue_follow_up_work(submission, payment)
         -> notification dispatch
         -> invoice generation/storage
         -> fulfillment kickoff jobs
      <- Core::Result::Success(data: { submission:, order:, payment: })
```

### Failure Paths

- Validation failure stops before any payment side effects.
- Payment provider failure marks the payment failed and stops downstream work.
- Downstream enqueue failure should be retry-safe and either return a failure only if it is part of the transactional guarantee, or be deferred to job retries.

### Command Boundary Rules

- Keep `validate_submission` explicit and fast-failing.
- Keep payment capture/confirmation inside `Payments::Application::Commands::CreatePayment`.
- Keep `success_handling` limited to checkpointing and payload preparation.
- Keep `enqueue_follow_up_work` idempotent and retry-friendly.
- Do not put provider-specific branching, mailer bodies, or transport concerns in the command.

### Return Contract

```ruby
Success:
  { submission:, order:, payment: }

Failure:
  { message:, code:, data: }
```

## Operational Note

- This is the business flow layer, not transport code.
- The workflow should coordinate repositories, use cases, mailers, and jobs.
- If a step fails, the workflow should make the failure point explicit and retry-safe.
- This layer should be able to grow into a saga-style flow if we later need compensating actions.

## Implementation Plan

- [x] Introduce `Ordering::Application::Commands::ProcessSubmission` as the orchestration entrypoint.
- [x] Extract `validate_submission` as a named step that runs before any payment side effects.
- [x] Keep payment capture/confirmation inside `Payments::Application::Commands::CreatePayment`.
- [x] Add an explicit success checkpoint that runs only after payment reaches the expected state.
- [x] Trigger invoice and notification follow-up work only from the success checkpoint.
- [x] Make the workflow boundaries explicit and testable with one spec per stage.
- [x] Add specs for success, validation failure, provider failure, and downstream-job failure.

## Affected Docs

- `docs/work-items/031-payment-domain-and-idempotency.md`
- `docs/work-items/039-payment-outbound-notifications.md`
- `docs/work-items/040-payment-invoice-generation-and-storage.md`
- `docs/work-items/041-application-boundaries-and-repositories.md`

## Affected Ops

- `app/services/`
- `app/jobs/`
- `app/models/`
- `app/controllers/`
- `spec/unit/`
- `spec/system/`

## Checklist

- [x] Payment validation happens before capture.
- [x] Payment capture/confirmation is a distinct workflow step.
- [x] Downstream mail/invoice steps only run after success.
- [x] Workflow steps are explicit and retry-safe.
- [x] Future payment methods can plug into the same flow.

## Validation

- [x] Specs cover the workflow stages and failure points.
- [x] Specs cover downstream handoff after successful payment.
- [x] Workflow remains readable and does not collapse back into controller logic.

## Notes

- Start with the minimal workflow we need now.
- If compensation becomes necessary, evolve this into a saga-style implementation later.
- Keep provider-specific details out of the workflow core.
