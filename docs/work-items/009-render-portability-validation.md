---
id: render-portability-validation
aliases: []
tags:
  - work-items
  - render
  - portability
  - validation
  - github
depends_on:
  - render-stack-portability
order: 9
phase: work-items
status: draft
title: Render Portability Validation
---

# Render Portability Validation

## Goal

- [ ] Validate the stack on a different GitHub account and Render workspace without changing the source code.

## Scope

- Run the repo from a second GitHub account or throwaway repo copy.
- Create or connect a second Render workspace.
- Set the required GitHub secrets and repository variables for the new account.
- Confirm the workflows still run with the portable inputs.
- Confirm the release/release-gate behavior still works in the new account.

## Operational Note

- This is the proof step for the portability work.
- The goal is not to add new features; it is to verify the existing codebase can be reused elsewhere.

## Implementation Plan

- [ ] Create or fork a test repository under a second GitHub account.
- [ ] Create a matching Render workspace or project for that account.
- [ ] Provision the required GitHub secrets and repository variables.
- [ ] Run the CI and infra workflows in the new account.
- [ ] Record any account-specific values that still need to be parameterized.

## Affected Docs

- `docs/work-items/008-render-stack-portability.md`

## Affected Ops

- GitHub repository settings for the second account
- GitHub Actions secrets and repository variables
- Render dashboard / workspace settings for the second account
- `.github/workflows/`

## Checklist

- [ ] The stack runs in a second account without editing the Terraform source.
- [ ] The workflows can be triggered in the new account.
- [ ] Any remaining account-specific assumptions are documented.

## Validation

- [ ] `ci.yml` passes in the second account.
- [ ] `infra-render.yml` passes in the second account.
- [ ] The release gate still behaves as expected.

## Notes

- Keep the account-specific setup steps out of this item; that belongs in the bootstrap guide.
