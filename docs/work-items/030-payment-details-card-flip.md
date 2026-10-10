---
id: payment-details-card-flip
aliases: []
tags:
  - work-items
  - client
  - payment
  - ui
  - animation
  - validation
depends_on:
  - sprint-0-client-views
order: 30
phase: work-items
status: done
title: Payment Details Card Flip
---

# Payment Details Card Flip

## Goal

- [x] Upgrade the payment modal with a card-flip interaction and field validations for simulated checkout.

## Scope

- Keep `billing email` as contact information, not as card data.
- Animate a credit card front/back in the modal.
- Place the card inputs inside the card shell instead of in a separate form stack.
- Flip the card when the CVC control is used.
- Validate `name on card`, `card number`, `expiry`, and `CVC`.
- Format the visible card input state as the user types.
- Keep the implementation lightweight and avoid introducing a 3D/animation library unless absolutely necessary.

## Operational Note

- This is a UX-only payment step for the existing simulated checkout flow.
- Prefer CSS 3D transforms plus Stimulus behavior over a heavy rendering library.
- The flip should be driven by focus state, not by clicking the card.

## Implementation Plan

- [x] Add a card visual inside the payment modal with front/back faces.
- [x] Flip the card on `focus` of the CVC field and restore it on blur.
- [x] Add field-level validation and formatting for card number, expiry, and CVC.
- [x] Keep the existing billing email field as a separate contact input.
- [x] Update the modal copy so users understand the payment details are simulated.
- [x] Add focused request/system coverage for the payment modal behavior.

## Affected Docs

- `docs/work-items/index.md`
- `docs/sprints/00-foundation/04-client-views.md`

## Affected Ops

- `app/views/projects/_payment_modal.html.erb`
- `app/frontend/controllers/order_form_controller.js`
- `app/frontend/entrypoints/application.css`
- `spec/system/` or `spec/requests/` for modal behavior coverage

## Checklist

- [x] The payment modal includes a visual card front/back.
- [x] Focusing CVC flips the card to the back.
- [x] Blurring CVC returns the card to the front.
- [x] Card fields are validated and formatted.
- [x] Billing email remains a contact field.

## Validation

- [x] The modal renders without layout regressions.
- [x] The flip animation works in the browser.
- [x] Validation errors surface clearly for invalid card data.

## Notes

- The front/back card shell now carries the visible card inputs; the remaining slice is billing-email/copy cleanup.
