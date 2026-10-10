---
id: raw-footage-provider-metadata
aliases: []
tags:
  - work-items
  - client
  - raw-footage
  - metadata
  - preview
  - ui
  - database
depends_on:
  - sprint-0-data-model
  - sprint-0-client-views
order: 29
phase: work-items
status: done
title: Raw Footage Provider Metadata
---

# Raw Footage Provider Metadata

## Goal

- [x] Replace the old YouTube-only raw footage flow with provider-aware metadata and live preview support.

## Scope

- Keep `raw_footage_url` as the single visible input for the client.
- Detect supported providers from the entered URL and persist derived metadata on the order.
- Render enriched previews only when the URL is recognized.
- Support YouTube, Vimeo, Twitch, Instagram, and TikTok video URLs.
- Keep the metadata portable across MySQL and PostgreSQL by storing it as `json`.
- Preserve the existing order submission and comment flows.

## Operational Note

- The form should not ask for a separate YouTube field anymore.
- Preview UI should fade/slide into view only after the URL is recognized.
- The legacy `youtube_url` path should be treated as a cleanup candidate, not part of the client-facing flow.

## Implementation Plan

- [x] Add `raw_footage_metadata` to `projects` as portable `json`.
- [x] Derive provider metadata from `raw_footage_url` on the server.
- [x] Remove the separate `youtube_url` field from the client form.
- [x] Add live preview handling in the order form controller.
- [x] Render provider-aware previews on the client card and order detail pages.
- [x] Add focused unit and system coverage for the new flow.

## Affected Docs

- `docs/work-items/index.md`
- `docs/sprints/00-foundation/03-data-model.md`
- `docs/sprints/00-foundation/04-client-views.md`

## Affected Ops

- `app/models/project.rb`
- `app/services/raw_footage_url_parser.rb`
- `app/controllers/projects_controller.rb`
- `app/frontend/controllers/order_form_controller.js`
- `app/frontend/entrypoints/application.css`
- `app/views/projects/new.html.erb`
- `app/views/projects/edit.html.erb`
- `app/views/projects/_project.html.erb`
- `app/views/projects/show.html.erb`
- `db/migrate/20260720153000_add_raw_footage_metadata_to_projects.rb`
- `spec/unit/services/raw_footage_url_parser_spec.rb`
- `spec/unit/models/project_spec.rb`
- `spec/system/project_show_comments_spec.rb`

## Checklist

- [x] The order stores raw footage metadata in a portable JSON column.
- [x] The client only sees `raw_footage_url`.
- [x] Recognized providers show a richer preview.
- [x] Unrecognized URLs fall back to the generic raw footage field.

## Validation

- [x] Unit specs cover metadata derivation.
- [x] System specs cover the updated order show/client card flow.

## Notes

- Leave the legacy `youtube_url` column for a later cleanup pass if needed.
