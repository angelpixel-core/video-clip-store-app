---
id: ci-main-branch-trigger
aliases: []
tags:
  - work-items
  - ci
  - workflows
  - github-actions
depends_on:
  - payments-domain-popo-decoupling
order: 61
phase: work-items
status: in-progress
title: CI Workflow Main Branch Pull Request Trigger
---

# CI Workflow Main Branch Pull Request Trigger

## Goal

- [ ] Include `main` in the `pull_request` branch trigger list of `.github/workflows/ci.yml` so that release pull requests targeting `main` automatically run `pr_merge_gate`.

## Scope

- `.github/workflows/ci.yml`

## Affected Docs

- `docs/work-items/061-ci-main-branch-trigger.md`
- `docs/work-items/index.md`

## Checklist

- [x] `.github/workflows/ci.yml` triggers on pull requests targeting `development` and `main`.

## Validation

- [x] `bin/rails zeitwerk:check` passes cleanly.
- [x] `bin/rubocop` passes with 0 offenses.
