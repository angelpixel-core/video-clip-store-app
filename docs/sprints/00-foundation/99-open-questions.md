---
id: sprint-0-open-questions
title: Open Questions
phase: sprint-0
order: 99
aliases: []
tags:
  - sprint-0
  - questions
---

# Open Questions

- [x] Clarify whether the domain should model ordered video selections, video items, or video types on an order.
  - [x] Decision: `VideoType` is a customer-facing deliverable category, and the client's choices are stored as `VideoTypeSelection` records on the order.
- [ ] Confirm how client identity is established for requests.
- [ ] Confirm whether the app will integrate with SSO, an upstream token, or another trusted gateway.
- [ ] Confirm whether authentication and authorization are out of scope for Sprint 0.
  - [ ] Decision reference: `docs/decisions/01-client-identity-namespace.md` (Portal namespace with `AUTH_INTEGRATION_ENABLED` provisional bypass).
- [ ] Capture any additional open questions as they arise.
