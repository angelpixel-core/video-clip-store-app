---
id: pm-acronym-inflection-cleanup
aliases: []
tags:
  - work-items
  - rails
  - naming
  - inflections
depends_on:
  - sprint-0-data-model
order: 17
phase: work-items
status: done
title: PM Acronym Inflection Cleanup
---

# PM Acronym Inflection Cleanup

## Goal

- [x] Teach Rails to treat `PM` as an acronym and align the PM boundary naming across the app.

## Scope

- Register `PM` as an acronym in Rails inflections.
- Rename the PM model and mailer constants to match the acronym.
- Fix association class resolution where `belongs_to :pm` infers the wrong constant after the rename.
- Avoid unnecessary renames outside the affected naming boundary.

## Operational Note

- This is a naming cleanup, not a behavior change.
- The change should stay narrow so it does not cascade into unrelated refactors.

## Implementation Plan

- [x] Add the acronym inflection.
- [x] Rename the PM model and mailer constants to the acronym form.
- [x] Update associations that infer the PM class name.
- [x] Verify autoloading and constant resolution still work.
- [x] Update any affected direct references and specs.

## Affected Docs

- `docs/sprints/00-foundation/02-domain.md`
- `docs/sprints/00-foundation/03-data-model.md`

## Affected Ops

- `config/initializers/inflections.rb`
- `app/models/`
- `app/mailers/`
- `app/services/`
- `spec/`

## Checklist

- [x] Rails recognizes `PM` as an acronym.
- [x] The PM model and mailer constants use the acronym form.
- [x] Associations that point at PM resolve the renamed class.
- [x] Naming remains consistent in the codebase.

## Validation

- [x] The app boots cleanly after the inflection change.
- [x] `bin/rails zeitwerk:check` passes.
- [x] Specs referencing `PM` continue to pass.

## Notes

- Avoid broad renames unless the acronym cleanup actually requires them.
