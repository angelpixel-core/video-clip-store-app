---
id: client-notifications-persistent-toasts
title: Client Notifications Persistent Toasts
phase: decisions
order: 9
aliases: []
tags:
  - decisions
  - client
  - notifications
  - ui
  - realtime
  - toasts
  - persistence
---

# Client Notifications Persistent Toasts

## Decision

Add persistent client notifications with a campana/dropdown and floating toast cards, reusing the same notification lifecycle pattern already used for PM notifications.

## Context

The app already persists PM notifications, renders unread counts, and refreshes the PM workspace over Action Cable. The client needs the same class of feedback when the PM changes order state and for future comment/message events. The notification layer should remain persistent and role-aware instead of introducing a separate ephemeral alert system.

## Rationale

- Client notifications need unread/read state, so persistence is the source of truth.
- Keeping PM and client notifications in the same model avoids a parallel system and keeps delivery logic coherent.
- Floating toast cards plus a dropdown inbox give immediate visibility and a durable history.
- Reusing the current HTML-refresh pattern keeps the frontend small and consistent with the PM implementation.
- A single notification domain can support future events like comments/messages without redesigning the UI again.

## Strategy

- Generalize `Notification` so it can target either a `pm` or a `client` recipient.
- Keep PM notifications working as-is.
- Add a client inbox in the navbar with unread badge, dropdown history, and mark-as-read actions.
- Add client floating toasts in the workspace, mirroring the PM toast behavior.
- Broadcast refresh events to the correct recipient channel whenever notifications are created or acknowledged.
- Create notifications for order status changes and future comment/message events at the domain service layer.

## Not Chosen

- Separate client-only notification table: rejected because it duplicates storage and delivery behavior.
- Browser push notifications: rejected because the requirement is in-app persistence, not push delivery.
- Event sourcing / event bus / Karafka: rejected because the notification workflow is synchronous UI feedback, not a multi-consumer pipeline.

## Data Flow

```text
PM changes order state / adds comment
  -> domain service creates Notification for client
  -> Notification persists with unread state
  -> after-save broadcast to client notification channel
  -> client inbox/toasts refresh from current HTML
  -> client marks notification as read
  -> read_at updates and channel broadcasts refresh again
```

## Consequences

- The client gets persistent, discoverable notifications with immediate toasts.
- PM and client notification behavior stays aligned.
- Future events can reuse the same notification model and UI patterns.
