---
id: render-stack-portability
aliases: []
tags:
  - work-items
  - render
  - terraform
  - portability
  - infrastructure
depends_on:
  - database-engine-and-iac-strategy
  - render-infrastructure-requirements
order: 8
phase: work-items
status: done
title: Render Stack Portability
---

# Render Stack Portability

## Goal

- [x] Make the Render/Terraform stack portable across Render accounts by parameterizing account-specific values.

## Scope

- Render workspace owner ID as a variable.
- Render API auth as a secret.
- Per-environment Render service IDs as secrets.
- Per-environment Render environment IDs as repository variables.
- Current-account adoption IDs stay isolated to the active workspace.
- Document the hardcoded vs variable boundary for future reuse.

## Operational Note

- The current repository is still tied to one Render workspace for the adopted QA resources.
- The stack should remain reusable by another account as long as that account supplies its own owner ID, API key, and resource IDs.
- The `Hobby` plan still limits the active promotion chain, so portability here means configuration reuse, not a guarantee of identical live topology.

## Portability Matrix

| Area | Hardcoded | Variable / Secret |
| --- | --- | --- |
| Terraform module names | `web`, `database`, `worker`, `dns` | n/a |
| Environment names | `qa`, `staging`, `prod` | n/a |
| GitHub Actions workflow names | `CI`, `Infra Render`, `Promote Staging` | n/a |
| Render workspace owner | n/a | `RENDER_OWNER_ID` |
| Render API auth | n/a | `RENDER_API_KEY` |
| Rails master key | n/a | `RAILS_MASTER_KEY` |
| Render service IDs | n/a | `RENDER_QA_SERVICE_ID`, `RENDER_STAGING_SERVICE_ID`, `RENDER_PROD_SERVICE_ID` |
| Render environment IDs | n/a | `RENDER_QA_ENVIRONMENT_ID`, `RENDER_STAGING_ENVIRONMENT_ID`, `RENDER_PROD_ENVIRONMENT_ID` |
| Adopted QA resource IDs | n/a | `RENDER_QA_ADOPTED_WEB_SERVICE_ID`, `RENDER_QA_ADOPTED_DATABASE_ID`, `RENDER_QA_ADOPTED_ENVIRONMENT_ID` |

## Implementation Plan

- [x] Parameterize `owner_id` in every Render provider block.
- [x] Pass `TF_VAR_owner_id` through GitHub Actions jobs that run Terraform.
- [x] Add `RENDER_OWNER_ID` to the GitHub repository variables interface.
- [x] Keep the current workspace resource IDs out of reusable defaults.
- [x] Keep the hardcoded vs variable matrix documented in the work items.
- [x] Validate that QA `terraform plan` still succeeds with the portable inputs.

## Affected Docs

- `docs/work-items/006-render-infrastructure-requirements.md`
- `docs/work-items/007-database-engine-and-iac-strategy.md`
- `docs/work-items/index.md`

## Affected Ops

- `.github/workflows/infra-render.yml`
- `Makefile`
- `ops/scripts/secrets.sh`
- `ops/infra/render/envs/qa/providers.tf`
- `ops/infra/render/envs/staging/providers.tf`
- `ops/infra/render/envs/prod/providers.tf`
- `ops/infra/render/envs/qa/variables.tf`
- `ops/infra/render/envs/staging/variables.tf`
- `ops/infra/render/envs/prod/variables.tf`

## Checklist

- [x] Externalize the Render workspace owner ID.
- [x] Keep API keys and resource IDs outside the code.
- [x] Document the portability boundary for another Render account.
- [x] Verify the QA Terraform plan still passes after parameterization.

## Validation

- [x] A different Render workspace can reuse the same Terraform structure by setting its own `RENDER_OWNER_ID` and resource IDs.
- [x] The current QA workflow still plans successfully.

## Notes

- This work item is about portability and reuse, not about unlocking the Hobby plan limits.
- Keep the code minimal and favor variables for anything account-specific.
- Follow-up validation and bootstrap guidance should live in separate work items.
- The adopted QA IDs remain only in `ops/infra/render/envs/qa/imports.tf` as workspace-specific adoption state.
