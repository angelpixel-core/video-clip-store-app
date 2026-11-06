---
id: e2e-operations-walkthrough-and-bundle-sync
aliases: []
tags:
  - work-items
  - docs
  - walkthrough
  - operations
  - compose
order: 54
phase: work-items
status: completed
title: E2E Operations Walkthrough and Bundle Sync Automation
---

# E2E Operations Walkthrough and Bundle Sync Automation

## Goal

- [x] Document step-by-step E2E operations walkthrough in `README.md` covering the full order lifecycle from customer checkout to payment unblocking, PM acceptance, and final delivery.
- [x] Automate bundle sync inside `ops/containers/app/entrypoint.sh` and `ops/compose/compose.yml` so containers gracefully auto-install missing gems if `Gemfile.lock` changes.
- [x] Document webhook unblocking methods (Web UI Dev Tools and terminal CLI trigger).

## Scope

- Root `README.md` update with `## End-to-End Walkthrough & Operations Guide`.
- Automatic `bundle check || bundle install` in container entrypoint and assets command.
- Documentation index update.
