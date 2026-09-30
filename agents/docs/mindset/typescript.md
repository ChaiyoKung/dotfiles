---
created: 2026-09-30T08:28:18Z
updated: 2026-09-30T08:28:18Z
---

# TypeScript

- **I use `interface X extends Y` only when I add fields to `Y`. When the shape is exactly the same as `Y`, I use `type X = Y`.** The keyword shows the intent: `extends` says "this adds something," and `=` says "this is the same." Code should explain itself.
