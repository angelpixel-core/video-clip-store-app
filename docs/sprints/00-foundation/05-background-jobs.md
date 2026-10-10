---
id: sprint-0-background-jobs
title: Background Jobs
phase: sprint-0
order: 5
aliases: []
tags:
  - sprint-0
  - jobs
  - notifications
---

# Background Jobs

## Requirements

- [x] The PM notification must be created asynchronously.

## Implementation Notes

- [x] Keep the job boundary narrow.
- [x] `NotificationJob` enqueues the PM notification and delegates delivery to `NotificationService`.
- [x] Development uses Solid Queue locally with a separate worker process.
- [x] The UI flow should not wait on notification delivery.
