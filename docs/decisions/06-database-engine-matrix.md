---
id: database-engine-matrix
title: Database Engine Matrix
phase: decisions
order: 6
aliases: []
tags:
  - decisions
  - database
  - mysql
  - postgresql
  - rails
---

# Database Engine Matrix

## Decision

Use MySQL for local development and CI validation, then switch to PostgreSQL starting at QA and keep PostgreSQL for staging and production.

## Matrix

| Environment | Engine | Purpose | Notes |
| --- | --- | --- | --- |
| `dev` | MySQL | Local developer loop | Matches the current local compose stack and keeps the fastest feedback path. |
| `test` | MySQL | Deterministic automated validation | Uses the Dockerized test runner and matches the local baseline. |
| `qa` | PostgreSQL | First real deployed environment | Catches compatibility differences before release promotion. |
| `staging` | PostgreSQL | Release candidate validation | Must behave like production. |
| `prod` | PostgreSQL | Production runtime | Final release target on Render. |

## Rationale

- MySQL remains the simplest local and CI baseline for the current application shape.
- PostgreSQL is the target runtime engine for the deployed environments because it is available natively on Render.
- Introducing the engine switch at QA ensures the first deployed environment exposes cross-engine issues early enough to fix them before release.
- The mixed-engine model lets the app honor local development ergonomics while aligning the actual release path with the deployment platform.

## Tradeoffs

### What MySQL gives us

- Familiar web-app baseline.
- Simple local setup.
- Fast feedback in the current Docker-based dev/test flow.

### What PostgreSQL gives us

- Better JSON and JSON indexing support.
- More expressive SQL and richer types.
- Stronger fit for future platform features.
- Native managed availability on Render.

### Risks we accept

- Engine-specific queries may behave differently between `test` and `qa`.
- Some migrations or SQL idioms may be portable only if kept conservative.
- Bugs may appear first in QA because the engine changes there.

## Mitigations

- Keep `schema.rb` as the default schema format while the app stays within a portable subset.
- Prefer Rails adapters and portable SQL over engine-specific features.
- Treat QA as the compatibility checkpoint for the engine switch.
- Revisit `structure.sql` only if engine-specific features become necessary.

## Notes

- This matrix is deliberate, not accidental.
- If the app later needs MySQL-only or PostgreSQL-only features, the matrix and schema strategy should be revisited together.
