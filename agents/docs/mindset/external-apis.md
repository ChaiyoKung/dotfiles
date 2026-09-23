---
created: 2026-09-23T12:19:02Z
updated: 2026-09-23T12:19:02Z
---

# External APIs

- **Use zero trust for every external or 3rd-party API call — never trust its response or its uptime.** This applies to real external vendors and also to internal services from other teams that we don't control. The only exception is a call with no business impact if it fails, like a fire-and-forget event. Three things follow from this: (1) retry with backoff, but only for idempotent operations, and only on network failure or timeout — never on a validation failure; max attempts must be configurable, with a default value. (2) Always validate the response format or schema before we use it; if it's wrong, fail loud right away instead of letting bad data flow into the main logic. (3) Control the total request timeout on our side; this value must be configurable too, with a default value.
