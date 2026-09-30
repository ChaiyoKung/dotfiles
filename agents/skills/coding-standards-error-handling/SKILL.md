---
name: coding-standards-error-handling
description: 'Use this whenever you write or review code that throws, catches, logs, or returns an error, or that calls an external or 3rd-party API - e.g. "add a try/catch," "handle this failure," "what log level should this be," "call the Stripe/vendor API," "add retry," "add a timeout," "validate this response," "parse this input" - even if the user never says "error handling." Covers never letting an error pass silently, main path vs best-effort path, log levels for expected vs unexpected errors, naming throwing vs `safe` validation/parsing functions, and zero trust for external APIs (idempotent retry with backoff, response schema validation, configurable timeout). Pair with the coding-standards-general skill for guard clauses and other general principles.'
---

# Error Handling Standards

Rules for how code fails, and for how it talks to services we do not control. They apply to any language. Code examples use TypeScript for illustration only.

## 1. Never Let an Error Pass Silently

Every error needs at least one trail that someone can follow:

- a log,
- a re-thrown exception, or
- a return type the caller must handle.

If none of these exist, the error is silent, even if the code caught it.

```ts
// ❌ Don't: caught, but no trail
try {
  await chargeCard(order);
} catch (error) {}

// ✅ Do: leave a trail (here: log, then re-throw)
try {
  await chargeCard(order);
} catch (error) {
  logger.error("Failed to charge card", { orderId: order.id, error });
  throw error;
}
```

**Why:** a silent error is a bug that nobody can find. The user sees a wrong result, and the logs show nothing.

---

## 2. Main Path vs Best-Effort Path

Ask first: does this failure hurt the user?

| Path                                                                          | What to do                                                                               |
| ----------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| **Main path** (payment, core business logic)                                  | Force the caller to handle the error. Throw it, or return an error type. A log alone is not enough. |
| **Best-effort path** (analytics, non-critical cleanup): failure does not hurt the user | It is fine to swallow the error. Still log it, so it is visible in the backend, even if the UI does not need to know. |

```ts
// ✅ Best-effort: swallow, but log
try {
  await analytics.track("checkout_completed", { orderId });
} catch (error) {
  logger.warn("Failed to send analytics event", { orderId, error });
}
```

**Why:** on the main path, a log alone lets the flow continue as if nothing failed. On a best-effort path, throwing would break a feature the user cares about because of something they do not care about.

---

## 3. Log Levels

An expected error is one that you throw and let the system turn into a response for the caller (for example, a validation failure). That is loud enough. Log it at **INFO**, not WARN or ERROR.

Keep **ERROR** for real, unexpected bugs.

**Why:** if expected errors use ERROR, real bugs get lost in the noise. Then real bugs are silent in practice.

---

## 4. Naming Validation and Parsing Functions

- Name the plain version so it **always throws**: `parseEmail`, `validateOrder`.
- Give the non-throwing variant a clearly different name, like a `safe` prefix: `safeParseEmail`.
- Follow the idiom of the language if it has one (`try_` in Rust, `XOrNull` in Kotlin). The exact word does not matter. The two names must be clearly different.
- **Do not build both variants by default.** Start with only the throwing one. Add the safe variant when a real caller needs to handle the failure without a try/catch.

**Why:** a reader should know from the name alone whether a call can throw. Building both variants "just in case" adds code that nobody calls.

---

## 5. External APIs: Zero Trust

Trust neither the response nor the uptime of any external or 3rd-party API. This includes internal services from other teams that we do not control.

**Only exception:** a call with no business impact if it fails, like a fire-and-forget event.

Three rules follow:

1. **Retry with backoff, but carefully.**
   - Retry only idempotent operations.
   - Retry only on network failure or timeout. Never retry on a validation failure.
   - The max number of attempts must be configurable, with a default value.
2. **Validate the response before you use it.** Check the format or schema. If it is wrong, fail loud right away. Do not let bad data flow into the main logic. (This is the "never silent" rule from section 1.)
3. **Control the total request timeout on our side.** The value must be configurable, with a default value.

```ts
const DEFAULT_MAX_ATTEMPTS = 3;
const DEFAULT_TIMEOUT_MS = 5_000;

async function fetchInvoice(id: string, options?: { maxAttempts?: number; timeoutMs?: number }) {
  const { maxAttempts = DEFAULT_MAX_ATTEMPTS, timeoutMs = DEFAULT_TIMEOUT_MS } = options ?? {};

  // GET is idempotent, so retry is safe. Retry only on network failure or timeout.
  const response = await fetchWithRetry(`${BASE_URL}/invoices/${id}`, { maxAttempts, timeoutMs });

  // Never trust the shape. Throws right away if it is wrong.
  return invoiceSchema.parse(await response.json());
}
```

**Why:** we do not control the vendor. Their service can be slow, down, or change its response without notice. Retrying a non-idempotent call can charge a customer twice. Retrying a validation failure never helps, because the same input fails again. A missing timeout can hang our own service.
