---
id: remove-legacy-submission-layer
title: Remove Legacy Submission Layer
phase: changes
order: 1
aliases: []
tags:
  - changes
  - cleanup
  - submissions
  - legacy
---

# Remove Legacy Submission Layer

## What

- `Submission` and `SubmissionPolicy` are legacy placeholders and are no longer used by the active Sprint 0 order flow.

## Why

- The order workflow now uses database-backed drafts and `Order` as the source of truth.
- Keeping the submission layer around without a live caller risks confusion and duplicated domain concepts.

## Impacted Files

- `app/models/submission.rb`
- `app/services/submission_policy.rb`
- `spec/unit/models/submission_spec.rb`
- `spec/unit/services/submission_policy_spec.rb`
- `spec/acceptance/step_definitions/submission_steps.rb`
- `spec/smoke/submission_smoke_spec.rb`

## Cleanup Plan

- Remove the legacy submission files after the remaining submission-related flow is either reimplemented or explicitly retired.
- Update any remaining docs or specs that still refer to submission creation as a live path.

## Related Docs

- `docs/sprints/00-foundation/04-client-views.md`
- `docs/sprints/00-foundation/01-scope.md`
- `docs/sprints/00-foundation/99-open-questions.md`
