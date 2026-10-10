---
id: grouped-rubocop-reporting
aliases: []
tags:
  - work-items
  - lint
  - rubocop
  - ci
depends_on: []
order: 50
phase: work-items
status: planned
title: Grouped RuboCop Reporting
---

# Grouped RuboCop Reporting

## Goal

- [ ] Group RuboCop lint output by offense type first, then list affected files with line and column details underneath.

## Scope

- Replace the current per-file GitHub formatter output with grouped reporting by cop name.
- Keep CI and local lint behavior aligned.
- Preserve human-readable annotations for developers and PR checks.

## Current Codebase

- `Makefile` runs `bin/rubocop -f github`.
- GitHub formatter output is flat per offense and file.
- CI and local lint both depend on the same RuboCop entrypoint.

## Design Notes

- The simplest path is likely a custom RuboCop formatter or a post-processing wrapper around RuboCop JSON output.
- Grouping should be by cop name, not by file.
- The output should keep file, line, and column coordinates.

## Implementation Plan

- [ ] Decide whether to implement a custom RuboCop formatter or a wrapper script over JSON output.
- [ ] Add grouped output without losing machine-readable annotations for CI.
- [ ] Update the lint entrypoint so local and CI use the same grouped format.
- [ ] Add a small validation or test around the formatter behavior.

## Expected Result

- RuboCop offenses are reported grouped by cop name.
- Repeated offenses across multiple files become easier to scan.
- The lint signal remains usable in CI and locally.

## Affected Docs

- `docs/work-items/index.md`

## Affected Ops

- `Makefile`
- `bin/rubocop` or a new lint wrapper script
- `.github/workflows/ci.yml` if the lint entrypoint changes

## Checklist

- [ ] Offenses are grouped by type.
- [ ] File, line, and column details remain visible.
- [ ] Local and CI lint output stay aligned.

## Validation

- [ ] Run RuboCop against the current offense set and confirm the grouped view.

## Notes

- This is a tooling concern and should stay out of the business domain docs.
