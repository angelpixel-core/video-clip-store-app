---
id: notification-delivery-channels
aliases: []
tags:
  - work-items
  - notifications
  - jobs
  - mail
  - logging
depends_on:
  - sprint-0-background-jobs
order: 13
phase: work-items
status: done
title: Notification Delivery Channels
---

# Notification Delivery Channels

## Goal

- [x] Refactor the PM notification flow into explicit delivery channels.

## Scope

- Keep the current log output as one delivery channel.
- Introduce an internal adapter or channel object around the log implementation.
- Add a mail delivery channel for PM notification email.
- Keep the implementation small and composable so more channels can be added later.

## Operational Note

- This item is about delivery plumbing, not UI presentation.
- The logger remains the first working channel and should not be removed.

## Discovery

- `ApplicationMailer` already exists, so the mail channel can use the normal Rails mailer stack.
- Unit specs already exist for `NotificationService`, `NotificationJob`, and `Notification`, so the refactor can extend the current test shape instead of inventing a new one.
- The log channel should stay explicit as part of the delivery pipeline, not as an incidental `Rails.logger` call hidden inside the service.

## Implementation Plan

- [x] `app/services/notification_service.rb` - keep the orchestrator role and delegate each delivery channel.
- [x] `app/services/notification_delivery/logger_channel.rb` - extract the current log line into an explicit logger channel.
- [x] `app/mailers/pm_notification_mailer.rb` - add the PM email delivery channel.
- [x] `app/views/pm_notification_mailer/` - add the email template and any shared mailer partials needed.
- [x] `spec/mailers/pm_notification_mailer_spec.rb` - add coverage for the PM email delivery.
- [x] `spec/unit/services/notification_service_spec.rb` - update the orchestration spec to cover the channel handoff.
- [x] `spec/unit/jobs/notification_job_spec.rb` - keep the job delegation spec intact.
- [x] `spec/unit/services/notification_delivery/logger_channel_spec.rb` - add coverage for the logger channel if it is extracted as its own object.

## Affected Docs

- `docs/sprints/00-foundation/05-background-jobs.md`
- `docs/changes/002-notification-job-and-queue-runtime.md`

## Affected Ops

- `app/services/notification_service.rb`
- `app/jobs/notification_job.rb`
- `app/services/notification_delivery/`
- `app/mailers/` if mail delivery is implemented through Action Mailer
- `app/views/pm_notification_mailer/`
- `spec/`

## Checklist

- [x] `NotificationService` still orchestrates delivery from an order ID.
- [x] The logger channel still emits the PM notification log line.
- [x] The PM mailer sends the compact notification email.
- [x] `NotificationJob` still only delegates to `NotificationService`.

## Related Sections

- `spec/unit/services/notification_service_spec.rb`
- `spec/unit/jobs/notification_job_spec.rb`
- `spec/unit/models/notification_spec.rb`

## Validation

- [x] Notification-related specs pass.
- [x] The PM notification still enqueues asynchronously.

## Notes

- Favor the smallest adapter that cleanly separates channels.
- Keep the log output as a safe fallback and debugging aid.
