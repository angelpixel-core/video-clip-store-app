---
id: rails-schema-format
title: Rails Schema Format
phase: decisions
order: 2
aliases: []
tags:
  - decisions
  - rails
  - migrations
  - schema
---

# Rails Schema Format

## Decision

Use `schema.rb` for Rails schema output.

## Rationale

- Keeps the migration state easy to read and maintain.
- Matches the current application needs without requiring SQL dump management.
- Avoids the extra operational overhead of `structure.sql` unless MySQL-specific features make it necessary later.

## Notes

- Revisit only if the schema needs SQL-level features not expressible in `schema.rb`.
