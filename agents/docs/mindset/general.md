---
created: 2026-09-30T03:44:07Z
updated: 2026-09-30T03:44:07Z
---

# General

- **I don't write date and time logic by hand. I use a library.** Date code is hard to read, and it has many edge cases (DST, leap years, month lengths, timezones). A library keeps the code clear and correct.
- **In JS/TS, my choice is `dayjs`. In other languages, I use the best-fit library for that language.** I prefer a library over native APIs like `Intl` and `Temporal` because native code is harder to read. If a date library is already installed in the project, I use it for everything, even simple tasks.
- **The only exception is a project with no date library.** There, `Date.now()` and comparing raw timestamps are fine. Anything about calendar, timezone, or format still needs a library.
