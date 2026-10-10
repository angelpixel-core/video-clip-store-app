---
id: render-bootstrap-guide
aliases: []
tags:
  - work-items
  - render
  - github
  - bootstrap
  - guide
depends_on:
  - render-stack-portability
order: 10
phase: work-items
status: draft
title: Render Bootstrap Guide
---

# Render Bootstrap Guide

## Goal

- [ ] Document the manual and semi-automated steps needed to bootstrap this repo in a fresh GitHub and Render account.

## Scope

- Create the repository from GitHub UI or `gh`.
- Push the base code into the new repository.
- Create the Render workspace and project.
- Record which Render resources must be created manually.
- Record which GitHub secrets and repository variables must be set.
- Record the order in which the workflows should be run.

## Operational Note

- This guide is the operator runbook for first-time setup.
- It should make the bootstrap reproducible without needing to remember prior sessions.

## Implementation Plan

- [ ] Document the repository creation path (`gh` or GitHub UI).
- [ ] Document the Render workspace/project creation path.
- [ ] Document the secrets/variables required before workflows can run.
- [ ] Document the order of execution for CI, infra, and release workflows.
- [ ] Document the manual checkpoints that still need human confirmation.

## Affected Docs

- `docs/work-items/008-render-stack-portability.md`
- `docs/work-items/009-render-portability-validation.md`
- `docs/work-items/index.md`

## Affected Ops

- GitHub repository creation
- GitHub Actions secrets and repository variables
- Render dashboard / workspace creation
- `make secrets/*`

## Checklist

- [ ] Another person can bootstrap the stack using only this guide.
- [ ] The guide lists every manual prerequisite.
- [ ] The guide lists the minimal set of secrets and vars.

## Validation

- [ ] A fresh account can follow the guide without reading the source code.

## Notes

- Keep this guide operational, not architectural.
