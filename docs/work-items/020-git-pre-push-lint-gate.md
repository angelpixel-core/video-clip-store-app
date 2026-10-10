---
id: git-pre-push-lint-gate
aliases: []
tags:
  - work-items
  - git
  - hooks
  - lint
  - pre-push
  - ops
depends_on: []
order: 20
phase: work-items
status: done
title: Git Pre-Push Lint Gate
---

# Git Pre-Push Lint Gate

## Goal

- [x] Block `git push` when `make lint` fails, using a native Git hook instead of Husky.

## Scope

- Use a repository-managed native Git hook setup.
- Run `make lint` before allowing a push to the remote.
- Keep an explicit bypass path for emergencies.
- Document local hook installation and activation.

## Operational Note

- This item is about local developer guardrails, not CI enforcement.
- The hook should be lightweight and portable across shells/environments as much as possible.

## Implementation Plan

- [x] `ops/lint/setup-hooks.sh` - set `core.hooksPath` to the repo-managed hook directory.
- [x] `ops/lint/pre-push` - run `make lint` and abort the push if it fails.
- [x] `Makefile` - add a helper target for setting up hooks locally if needed.
- [x] `README.md` - document how to install, bypass, and update the hook.

## Affected Docs

- `docs/work-items/index.md`
- `README.md` or repo onboarding docs if present

## Affected Ops

- `ops/lint/setup-hooks.sh`
- `ops/lint/pre-push`
- `Makefile`

## Checklist

- [x] `git push` is blocked when `make lint` fails.
- [x] Developers can install the hook with a documented command.
- [x] There is a documented bypass path for emergencies.

## Validation

- [x] A failing lint run aborts the push locally.
- [x] A passing lint run allows the push.

## Notes

- Prefer the native Git hook path over Husky for less dependency surface.
- Keep the hook focused on `make lint`; do not duplicate CI logic beyond that gate.
