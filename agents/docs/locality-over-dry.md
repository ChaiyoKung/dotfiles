# Coding Mindset — Locality Over DRY

A personal set of code-review preferences: when it's worth deduplicating repeated code, and when it isn't.

## The principle

**Prefer code where you can understand what a specific call site does by reading only that call site — even if it means the same shape of logic appears 2, 4, or 14 times.** Don't introduce a shared abstraction (a generic wrapper function, a lookup/rule table, a shared custom hook) whose only job is to remove that duplication, if using it means the reader now has to open a second definition and mentally re-substitute parameters to know what actually happens.

Duplication that stays fully readable in place is preferred over an abstraction that's shorter but requires a second lookup.

---

## 1. Prefer an explicit `if`/`else` chain over a lookup/rule table

**Rule:** When branching on a small, fixed set of cases, write out each case. Don't collapse them into a data table + a generic "apply the rule" block unless the table is genuinely large or changes at runtime.

```ts
// ❌ Avoid
const SHIPPING_RULES: Record<string, { carrier: string; baseFee: number }> = {
  domestic: { carrier: "local-post", baseFee: 3.5 },
  regional: { carrier: "regional-express", baseFee: 8 },
  international: { carrier: "global-freight", baseFee: 20 },
};

const rule = SHIPPING_RULES[zone];
if (rule) {
  const fee = rule.baseFee + weightSurcharge(weightKg, rule.carrier);
  return { carrier: rule.carrier, fee };
}

// ✅ Do
if (zone === "domestic") {
  return { carrier: "local-post", fee: 3.5 + weightSurcharge(weightKg, "local-post") };
} else if (zone === "regional") {
  return { carrier: "regional-express", fee: 8 + weightSurcharge(weightKg, "regional-express") };
} else if (zone === "international") {
  return { carrier: "global-freight", fee: 20 + weightSurcharge(weightKg, "global-freight") };
}
```

**Key reason:** the `if` chain tells you everything at that one line — carrier, base fee, and how the surcharge is computed for that zone. The table version means first resolving `SHIPPING_RULES[zone]`, then feeding two of its fields back into `weightSurcharge`, before you know what actually gets returned. That's an extra hop for something that isn't more correct — just shorter.

---

## 2. Prefer several explicit functions over one generic parameterized function

**Rule:** When 3-4 functions do "the same shape of thing" with one or two values swapped, don't fold them into a single function that takes those values as parameters, if the fold makes any one caller's behavior require substitution to understand.

```ts
// ❌ Avoid
function setListingVisibility(kind: "article" | "product", id: string, visible: boolean): void {
  const record = getTypedRecord(id, kind);
  db.save(id, { ...record, visible });
}

export function publishArticle(id: string) { setListingVisibility("article", id, true); }
export function unpublishArticle(id: string) { setListingVisibility("article", id, false); }
export function publishProduct(id: string) { setListingVisibility("product", id, true); }
export function unpublishProduct(id: string) { setListingVisibility("product", id, false); }

// ✅ Do
export function publishArticle(id: string): void {
  const article = getTypedRecord(id, "article");
  db.save(id, { ...article, visible: true });
}

export function unpublishArticle(id: string): void {
  const article = getTypedRecord(id, "article");
  db.save(id, { ...article, visible: false });
}

export function publishProduct(id: string): void {
  const product = getTypedRecord(id, "product");
  db.save(id, { ...product, visible: true });
}

export function unpublishProduct(id: string): void {
  const product = getTypedRecord(id, "product");
  db.save(id, { ...product, visible: false });
}
```

**Key reason:** `publishArticle` on its own tells you exactly what happens. With `setListingVisibility`, you have to mentally plug `("article", id, true)` back into the generic body to get the same answer — a translation step the explicit version doesn't need.

---

## 3. Don't extract a constant for a rarely-repeated, self-explanatory literal

**Rule:** A literal that appears only 2 times and is already clear on its own doesn't need a named constant. Extract it when it repeats enough to risk drifting, or when the value's *meaning* isn't obvious from the literal itself (a real magic number/string) — not just because it's technically duplicated.

```ts
// ❌ Avoid
const DRAFT_CACHE_PREFIX = "draft:";

function getDraftKey(userId: string): string {
  return `${DRAFT_CACHE_PREFIX}${userId}:current`;
}

function getDraftHistoryKey(userId: string): string {
  return `${DRAFT_CACHE_PREFIX}${userId}:history`;
}

// ✅ Do
function getDraftKey(userId: string): string {
  return `draft:${userId}:current`;
}

function getDraftHistoryKey(userId: string): string {
  return `draft:${userId}:history`;
}
```

**Key reason:** for 2 occurrences of a short, readable prefix, a constant adds a jump-to-definition step without adding real safety — `"draft:"` isn't a magic number whose meaning needs a name to explain it. Extracting a *behavior* used project-wide (like a shared validation check) is a different thing from extracting a literal that only ever shows up in one small pair of functions.

---

## 4. Prefer an explicit try/catch per call site over a generic error-handling wrapper

**Rule:** When several handlers each need their own error handling, write the try/catch in each one. Don't fold them through a higher-order wrapper function, even if there are a dozen or more of them.

```ts
// ❌ Avoid
function withApiErrors<In, Out>(handler: (input: In) => Out) {
  return (input: In): Out => {
    try {
      return handler(input);
    } catch (error) {
      return toErrorResponse(error);
    }
  };
}

export const getInvoice = withApiErrors(invoiceService.getInvoice);
export const cancelSubscription = withApiErrors(subscriptionService.cancel);

// ✅ Do
export function getInvoice(id: string) {
  try {
    return invoiceService.getInvoice(id);
  } catch (error) {
    return toErrorResponse(error);
  }
}

export function cancelSubscription(id: string) {
  try {
    return subscriptionService.cancel(id);
  } catch (error) {
    return toErrorResponse(error);
  }
}
```

**Key reason:** with the wrapper, knowing how `getInvoice` handles an error means opening `withApiErrors`'s definition too. With the explicit version, the answer is right there in the function itself. This holds even at a dozen-plus repetitions — the repeat count doesn't change whether the abstraction stays legible; see "rule of three" below.

---

## 5. Prefer inline async handling over a shared "do the same thing" hook

**Rule:** When two components each need "reset error, run an async action, catch and store the error, clear a loading flag," write that shape out in each component. Don't extract a generic hook that both call through.

```ts
// ❌ Avoid
function useAsyncSubmit<Args extends unknown[]>(action: (...args: Args) => Promise<void>) {
  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  async function submit(...args: Args) {
    setError(null);
    setIsSubmitting(true);
    try {
      await action(...args);
    } catch (caughtError) {
      setError(toErrorMessage(caughtError));
    } finally {
      setIsSubmitting(false);
    }
  }

  return { submit, error, isSubmitting };
}

const { submit: handleSignup, error: signupError } = useAsyncSubmit(createAccount);

// ✅ Do
const [signupError, setSignupError] = useState<string | null>(null);
const [isSubmitting, setIsSubmitting] = useState(false);

async function handleSignup(formValues: SignupForm) {
  setSignupError(null);
  setIsSubmitting(true);
  try {
    await createAccount(formValues);
  } catch (error) {
    const errorMessage = toErrorMessage(error);
    setSignupError(errorMessage);
  } finally {
    setIsSubmitting(false);
  }
}
```

**Key reason:** `handleSignup` on its own shows the whole flow start to finish. `useAsyncSubmit` moves the same shape behind a generic hook, so understanding any one caller means reading the hook too. Note that a small, single-purpose helper like `toErrorMessage` is still fine to share here — it's one pure function with one obvious job (turn an unknown thrown value into a message), not a control-flow wrapper the reader has to trace through.

---

## What this does NOT mean

This is not a blanket "don't refactor" or "don't share code" rule. Things that are always worth doing, regardless of duplication:

- **Real bug fixes** — a wrong status code, a missing `catch`, an off-by-one. Always fix actual defects.
- **Dead code removal** — delete or un-export what nothing calls.
- **Missing test coverage** — add tests for untested branching logic, especially edge cases like cycle/fallback paths.
- **Encapsulation/correctness fixes** — e.g. returning a copy instead of a live internal reference. These aren't about deduplication, they're about correctness.
- **Mechanical consistency fixes** — barrel exports, type-safety additions (`satisfies`), removing genuinely dead re-exports. Small, no new abstraction layer.
- **Splitting an oversized file into smaller, focused files** — pulling a large component's helpers/orchestration logic or a UI subsection into their own files. This is about file size and separation of concerns, not about genericizing repeated logic. Each extracted piece stays concrete and specific to one caller; nothing becomes a parameterized wrapper that multiple call sites feed through.
- **Sharing a single, well-defined, pure helper function** (like `toErrorMessage` above) — fine, as long as it's a small function with one obvious job that each caller still calls explicitly and directly, not a control-flow wrapper that hides what happens on error/success.

The dividing line: extracting a *concrete piece of logic* into its own place (a file, a small pure function used from anywhere) is fine. Turning *repeated concrete logic* into a *generic, parameterized abstraction* (a rule table, a HOF, a hook) that multiple call sites feed through and that the reader must open to understand any one of them — that's the thing to avoid, even at the cost of real code duplication.

---

## Rule of three still applies, but locality wins ties

Classic "rule of three" (don't abstract until you see the same shape 3+ times) is necessary but not sufficient here. Even a dozen or more repetitions of a simple, explicit pattern (see #4 above) can be worth keeping as-is. The deciding factor isn't the repeat count — it's whether the abstraction keeps each call site's behavior readable in place, or forces a second lookup to understand it.
