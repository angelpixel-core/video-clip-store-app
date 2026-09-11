# Compose

This directory contains compose entrypoints for running the local stack.

## Files

- `compose.yml` - Main stack definition.

## Notes

- Prefer environment-driven configuration.
- Keep the stack minimal and scoped to the current work item.
- Use `env/<env>/stack/compose.env` as the source of stack-level values when invoking Compose.
- The stack currently uses a dedicated bridge network named `video_clip_store_app_net`.
