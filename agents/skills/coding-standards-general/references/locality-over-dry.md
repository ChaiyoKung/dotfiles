# Locality Over DRY — Extended Examples

Read this when you're deciding whether to fold several near-identical functions into one parameterized function, or whether a repeated literal needs a named constant. The core principle (from the SKILL.md "Locality Wins Ties" section): prefer code where a reader can understand a call site by reading only that call site, even if the same shape of logic appears several times.

---

## Prefer several explicit functions over one generic parameterized function

**Rule:** When 3-4 functions do "the same shape of thing" with one or two values swapped, don't fold them into a single function that takes those values as parameters, if the fold makes any one caller's behavior require substitution to understand.

```ts
// ❌ Avoid
function setListingVisibility(kind: "article" | "product", id: string, visible: boolean): void {
  const record = getTypedRecord(id, kind);
  db.save(id, { ...record, visible });
}

export function publishArticle(id: string) { setListingVisibility("article", id, true); }
export function unpublishArticle(id: string) { setListingVisibility("article", id, false); }

// ✅ Do
export function publishArticle(id: string): void {
  const article = getTypedRecord(id, "article");
  db.save(id, { ...article, visible: true });
}

export function unpublishArticle(id: string): void {
  const article = getTypedRecord(id, "article");
  db.save(id, { ...article, visible: false });
}
```

**Key reason:** `publishArticle` on its own tells you exactly what happens. With `setListingVisibility`, you have to mentally plug `("article", id, true)` back into the generic body to get the same answer — a translation step the explicit version doesn't need.

---

## Don't extract a constant for a rarely-repeated, self-explanatory literal

**Rule:** A literal that appears only 2 times and is already clear on its own doesn't need a named constant. Extract it when it repeats enough to risk drifting, or when the value's *meaning* isn't obvious from the literal itself (a real magic number/string) — not just because it's technically duplicated.

```ts
// ❌ Avoid
const DRAFT_CACHE_PREFIX = "draft:";

function getDraftKey(userId: string): string {
  return `${DRAFT_CACHE_PREFIX}${userId}:current`;
}

// ✅ Do
function getDraftKey(userId: string): string {
  return `draft:${userId}:current`;
}
```

**Key reason:** for 2 occurrences of a short, readable prefix, a constant adds a jump-to-definition step without adding real safety. Extracting a *behavior* used project-wide (like a shared validation check) is a different thing from extracting a literal that only ever shows up in one small pair of functions.

---

## What this does NOT mean

Not a blanket "don't refactor" rule. Always still worth doing regardless of duplication: real bug fixes, dead code removal, missing test coverage, encapsulation/correctness fixes, mechanical consistency fixes (barrel exports, `satisfies`), splitting an oversized file into smaller focused files, and sharing a single well-defined *pure* helper function (e.g. an `extractErrorMessage`-style function with one obvious job that each caller still calls explicitly) — as long as it's not a control-flow wrapper that hides what happens on error/success.

Rule of three (don't abstract until you see the same shape 3+ times) is necessary but not sufficient here. Even a dozen-plus repetitions of a simple, explicit pattern can be worth keeping as-is — the deciding factor isn't the repeat count, it's whether the abstraction keeps each call site's behavior readable in place, or forces a second lookup to understand it.
