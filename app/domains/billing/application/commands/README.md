# Billing Commands

Commands are billing write use cases.

Current commands:

- `issue_credit_note.rb`
- `issue_invoice.rb`
- `mark_invoice_paid.rb`

## Rule

- Commands mutate state or trigger workflows and should return a result object.
