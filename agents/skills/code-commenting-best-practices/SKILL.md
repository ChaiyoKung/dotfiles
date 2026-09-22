---
name: code-commenting-best-practices
description: 'Use this whenever you are about to add or edit a comment in code, write a docstring/JSDoc, or review a diff/PR where comments are part of the change - even if the user never says "comments" or "commenting style." For example: "add a comment explaining this", "document this function", "why is this code hard to follow, should I comment it?", or "review this PR" when the diff includes new comments. Covers when a comment is actually justified (explaining "why", not "what"), refactoring - naming and extracting functions - as the first choice over commenting unclear code, signs a comment is patching a naming/structure problem instead of fixing it, and doc-comments for public/exported interfaces. Pair with the coding-standards-general skill for other general principles beyond commenting.'
---

# Code Commenting Best Practices

*Examples below are written in TypeScript, but the principles apply to any language.*

### Core Mindset

> **Code should be understandable on its own, without relying on comments — unless truly necessary.**

Comments are not the first tool you reach for. They're a **last resort**, used only after refactoring still leaves something the code itself cannot express. The priority order should be:

> **Name things well → extract clear functions/variables → only then, comment if something still isn't clear**

---

## 1. Self-Documenting Code Comes First

**❌ Don't** (using a comment to patch unclear code)

```typescript
// Check if user is over 18 and has verified email
if (u.a > 18 && u.ev) { ... }
```

**✅ Do** (refactor until no comment is needed)

```typescript
const isAdult = user.age > 18;
const isEmailVerified = user.emailVerified;

if (isAdult && isEmailVerified) { ... }
```

**Why:** The problem was never "missing a comment" — it was poor naming (`u.a`, `u.ev`) from the start. Fix the root cause instead of covering it with a label.

---

## 2. Before Commenting, Ask: "Can This Be Extracted Into a Function?"

**❌ Don't**

```typescript
// Check if the order is ready to ship: paid, has address, and items in stock
if (order.paid && order.address && order.items.every(i => i.inStock)) {
  ship(order);
}
```

**✅ Do**

```typescript
function isReadyToShip(order: Order): boolean {
  const isPaid = order.paid;
  const hasAddress = Boolean(order.address);
  const allItemsInStock = order.items.every(item => item.inStock);

  return isPaid && hasAddress && allItemsInStock;
}

if (isReadyToShip(order)) {
  ship(order);
}
```

**Why:** The function name `isReadyToShip` communicates intent more directly than a comment ever could. It's also testable and reusable — two things a comment can never be.

---

## 3. When a Comment IS Justified: Explaining "Why," Not "What"

Some things **cannot** be expressed through code alone — external context, business rules, constraints from other systems, or decisions made in the past. In these cases, a comment isn't a shortcut; it's genuinely necessary.

**✅ Do**

```typescript
function calcShippingFee(distanceKm: number): number {
  // Company policy: deliveries under 5km are always free
  // (decided by the Ops team, Dec 2025)
  if (distanceKm < 5) return 0;

  return distanceKm * RATE_PER_KM;
}
```

**Why:** No variable or function name can explain *why* 5km is the free-shipping threshold — that's knowledge that lives outside the code. This is exactly where a comment earns its place.

---

## 4. Signs You're Using a Comment to Patch the Wrong Problem

| Signal | Do this instead |
|---|---|
| Comment explains what a variable/parameter is | Rename it to something self-explanatory |
| Comment divides a long function into sections (`// --- validate ---`, `// --- save ---`) | Extract each section into its own named function |
| Comment walks through logic line by line | Make the logic more declarative (e.g. use `.filter()`/`.map()` instead of a manual loop) |
| Comment repeats what the type signature already says | Let TypeScript's types speak for themselves |

**❌ Don't**

```typescript
function processOrder(o: any) {
  // --- validate ---
  if (!o.id) throw new Error("invalid");

  // --- calculate total ---
  let total = 0;
  for (const item of o.items) total += item.price * item.qty;

  // --- save ---
  db.save(o);
}
```

**✅ Do**

```typescript
function processOrder(order: Order) {
  validateOrder(order);
  const total = calculateTotal(order.items);
  saveOrder(order);
}

function validateOrder(order: Order): void {
  if (!order.id) throw new Error("Invalid order: missing id");
}

function calculateTotal(items: OrderItem[]): number {
  return items.reduce((sum, item) => sum + item.price * item.qty, 0);
}
```

**Why:** Section-dividing comments are a clear sign a function is doing too much (violating Single Responsibility). Extracting functions fixes the actual problem — and you get separately testable units for free.

---

## 5. Let the Type/Data Structure Do the Explaining

If your language has a type system, enums, or structured data types, use them to replace comments that explain what a value means.

**❌ Don't**

```typescript
// status: 1 = pending, 2 = approved, 3 = rejected
function updateStatus(status: number) { ... }
```

**✅ Do**

```typescript
type OrderStatus = "pending" | "approved" | "rejected";

function updateStatus(status: OrderStatus) { ... }
```

**Why:** A named type gives you autocomplete and (in typed languages) compiler-enforced correctness — no one has to read a comment and hope they pass the right value. A well-chosen type is a comment that's actually enforced, rather than one that can silently go stale.

---

## 6. Document Public/Exported Interfaces — But Do It Sparingly

Use your language's standard doc-comment convention (JSDoc, docstrings, Javadoc, etc.) for functions that other developers will call without reading the implementation.

**❌ Don't**

```typescript
export function calcDiscount(price: number, rate: number): number {
  return price - price * rate;
}
```

**✅ Do**

```typescript
/**
 * Calculates the price after applying a discount.
 * @param price - Original price before discount
 * @param rate - Discount rate, e.g. 0.1 = 10%
 * @returns Final price after the discount is applied
 */
export function calcDiscount(price: number, rate: number): number {
  return price - price * rate;
}
```

**Why:** Exported/public functions are consumed by other developers (and by IDE tooltips) who may never open the implementation. A doc comment documents the contract without requiring them to.
