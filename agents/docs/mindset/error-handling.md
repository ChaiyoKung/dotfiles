---
created: 2026-09-28T07:28:42Z
updated: 2026-09-28T07:57:58Z
---

# Error Handling

- **Never let an error pass silently — every error needs at least one trail someone can follow: a log, a re-thrown exception, or a return type the caller must handle.** If none of these exist, the error is silent, even if it was caught.
- **On the main path (like payment or core business logic), always force the caller to handle the error — throw it or return an error type. A log alone is not enough.** On a best-effort path where failure doesn't hurt the user (like analytics or non-critical cleanup), it's fine to swallow the error, but always log it so it's visible in the backend, even if the UI doesn't need to know.
- **An expected error (like a validation failure) that you throw and let the system turn into a response for the caller counts as loud enough — but log it at INFO level, not WARN or ERROR.** Reserve ERROR for real, unexpected bugs. Using the wrong level dilutes the signal for real bugs, which makes them silent in practice.
- **For validation/parsing functions, name the plain version so it always throws, and give the non-throwing variant a distinct name like a `safe` prefix.** The exact word can follow whatever idiom the language already has (`try_` in Rust, `XOrNull` in Kotlin); what matters is that the two names are clearly distinct, not the specific word.
- **Don't build both a throwing and a safe variant by default for every validation/parsing function.** Start with just the throwing one, and add the safe variant only when a real caller needs to handle the failure without a try/catch.
