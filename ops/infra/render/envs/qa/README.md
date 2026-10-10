# QA

## Inventory

| Resource | Name | Notes |
| --- | --- | --- |
| Web service | `video-project-submission-app-qa` | Existing Render service; Rails web runtime for QA. |
| Worker service | `video-project-submission-app-qa-worker` | Scaffolded in Terraform, but `enable_worker` stays `false` until Render can host a dedicated QA worker. |
| PostgreSQL service | `video-project-submission-app-qa-db` | Managed Postgres adopted from the live QA environment. |
| Hostname | `video-project-submission-app-qa.onrender.com` | Current Render hostname for QA. |
| TLS | Render-managed | Certificate termination handled by Render. |

## Runtime Inputs

- `RAILS_ENV=qa`
- `RAILS_LOG_TO_STDOUT=true`
- `RAILS_MASTER_KEY`
- `DATABASE_URL`

## Validation Command

- Run this from your local machine after the QA deploy finishes:

```shell
curl -fsS https://video-project-submission-app-qa.onrender.com/up/db
```

- Expected response: `ok`
- Verified: `ok`

## Notes

- QA is the first deployed compatibility checkpoint.
- Terraform should adopt this live state rather than recreate it.
- Render currently shows the QA web service environment as `Production`; treat that as a Render platform quirk, not the project environment.

## Adoption Path

- Use Terraform `import` blocks as the final adoption mechanism.
- Adopt the existing QA web service and PostgreSQL service into the QA Terraform state.
- Keep the QA worker disabled by default until Render can host a dedicated QA worker.

### Verified Render Resources

| Resource | Render ID | Status |
| --- | --- | --- |
| Web service | `srv-d9a05ut7vvec738cb0n0` | Exists |
| PostgreSQL service | `dpg-d9a0goecjfls73928u5g-a` | Exists |
| Worker service | n/a | Not created yet |

### Import Blocks

```hcl
import {
  to = render_service.web
  id = "srv-d9a05ut7vvec738cb0n0"
}

import {
  to = render_postgresql.database
  id = "dpg-d9a0goecjfls73928u5g-a"
}
```

### Follow-Up

- After import, run plan until the QA state is fully represented in code.
- Only add a worker import once a QA worker service is created in Render and `enable_worker` is ready to flip on.
