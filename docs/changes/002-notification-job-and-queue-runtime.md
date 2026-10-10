---
id: notification-job-and-queue-runtime
title: Notification Job and Queue Runtime
phase: changes
order: 2
aliases: []
tags:
  - changes
  - jobs
  - notifications
  - solid_queue
  - infrastructure
---

# Notification Job and Queue Runtime

## What

- The order submission flow now enqueues the PM notification asynchronously.
- Development runs the queue locally with Solid Queue and a separate worker process.
- The app-side database environment contract stays distinct from MySQL container bootstrap defaults.

## Why

- PM notification delivery should not block the user submission flow.
- Local development needed a realistic queue runtime without changing the deployed environment model.
- Keeping application DB settings separate from container bootstrap variables avoids mixing concerns.

## Impacted Files

- `app/jobs/notification_job.rb`
- `app/services/notification_service.rb`
- `app/controllers/projects_controller.rb`
- `config/environments/development.rb`
- `config/database.yml`
- `ops/compose/compose.yml`

## Related Docs

- `docs/sprints/00-foundation/04-client-views.md`
- `docs/sprints/00-foundation/05-background-jobs.md`
