# Billing Handlers

Handlers coordinate multi-step billing work.

Current handlers:

- `dispatch_invoice_job.rb`
- `generate_invoice_job.rb`
- `invoice_builder.rb`

## Rule

- Handlers orchestrate work between domain objects and ports/adapters.
