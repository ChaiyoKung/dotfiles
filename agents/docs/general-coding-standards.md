# General Coding Standards

These principles apply regardless of programming language. Code examples below use TypeScript syntax for illustration only — the underlying principle applies to any language.

## 1. Principles & Coding Standards

Basic habits that make code easy to read and clear on its own.

- **Naming:** Give variables, functions, and classes names that show what they do. Don't use short forms or names that are not clear.
- **Same Code Style:** Keep the same format (indent, structure) across the whole project.
- **KISS (Keep It Simple, Stupid):** Keep the logic simple. Don't add anything you don't need.
- **DRY (Don't Repeat Yourself), but readability first:** Reducing duplicate code is good, but easy-to-read code for humans matters more. Duplicated code that stays clear is fine. Don't force a shared function if it makes the code harder to read.
- **No Magic Values:** Move strange numbers or strings (Magic Numbers/Strings) into constants or enums.
- **Useful Comments:** Comments should explain **"why"** you chose an approach, not **"what"** the code does.
- **Boy Scout Rule:** "Leave the code cleaner than you found it." Clean up old code when you get the chance.

### ❌ Don't: Use Unclear Names

```typescript
function p(d: any) {
  let x = 0;
  for (let i = 0; i < d.length; i++) {
    if (d[i].s === "active") {
      x += d[i].p;
    }
  }
  return x;
}
```

**Why it's bad:** `p`, `d`, `x`, `s` say nothing about intent. A reader has to run the loop in their head to figure out this sums the price of active orders — and `d: any` hides the shape entirely, so a typo like `d[i].ps` fails silently at runtime instead of at compile time.

### ✅ Do: Use Names That Show Intent

```typescript
interface Order {
  status: "active" | "cancelled" | "completed";
  price: number;
}

function calculateActiveOrdersTotalPrice(orders: Order[]): number {
  return orders
    .filter((order) => order.status === "active")
    .reduce((total, order) => total + order.price, 0);
}
```

**Why it's better:** the function name states what it returns, the `Order` type catches typos at compile time, and `filter`/`reduce` read as the same sentence you'd say out loud — no need to trace a loop to understand it.

### ❌ Don't: Use Magic Numbers

```typescript
function checkStatus(user: any) {
  if (user.status === 2) {
    setTimeout(refreshToken, 86400000);
  }
}
```

**Why it's bad:** `2` and `86400000` mean nothing on their own. A reader has to guess or go dig up what status `2` is and why the delay is that exact number — and if the same magic number appears elsewhere, changing it means finding every copy by hand.

### ✅ Do: Extract Constants and Enums

```typescript
const ONE_DAY_IN_MS = 24 * 60 * 60 * 1000;

enum UserStatus {
  PENDING = 1,
  ACTIVE = 2,
  SUSPENDED = 3,
}

function checkStatus(user: User): void {
  if (user.status === UserStatus.ACTIVE) {
    setTimeout(refreshToken, ONE_DAY_IN_MS);
  }
}
```

**Why it's better:** the name `ONE_DAY_IN_MS` and the enum `UserStatus.ACTIVE` explain themselves, so a reader doesn't need outside context. Changing the delay or adding a new status means editing one place, not searching the codebase for a bare number.

### DRY vs Readability (Rule of Three)

Four cases where "reduce duplication" and "keep it readable" pull in different directions — and how to judge each one.

#### ❌ Don't: Fork Behavior with Boolean Flags

```typescript
function sendNotification(user, message, isUrgent, isEmail, skipQuietHours) {
  if (isUrgent && !skipQuietHours) {
    // quiet-hours check
  }
  if (isEmail) {
    sendEmail(user, message, isUrgent ? "high" : "normal");
  } else {
    sendPush(user, message, skipQuietHours);
  }
}
```

**Why it's bad:** one function now covers every combination of three flags (up to 8 real cases). Callers have to memorize which flag means what, and readers have to trace every branch even when they only care about the email path.

#### ✅ Do: Split into Separate Functions per Use Case

```typescript
function sendUrgentEmail(user: User, message: string): void {
  sendEmail(user, message, "high");
}

function sendNormalPush(user: User, message: string): void {
  if (isQuietHours(user)) return;
  sendPush(user, message);
}
```

**Why it's better:** a little duplication between the `sendEmail`/`sendPush` calls is fine — the function names say exactly what happens, with no flag combination to decode, because these really are different use cases (an urgent email ignores quiet hours; a normal push respects them).

#### ❌ Don't: Merge Code That Looks the Same but Means Something Different

```typescript
// Merged because User and Product validation happen to look similar today
function validateEntity(entity: any, type: "user" | "product"): boolean {
  if (!entity.name || entity.name.length < 2) return false;
  if (type === "user" && !entity.email.includes("@")) return false;
  if (type === "product" && entity.price < 0) return false;
  return true;
}
```

**Why it's bad:** the name check happens to match today, but `User` and `Product` are different domains with independent reasons to change. Every new business rule adds another `if (type === ...)`, and a fix for one entity risks breaking the other.

#### ✅ Do: Split by Domain Even with Minor Duplication

```typescript
function validateUser(user: User): boolean {
  if (!user.name || user.name.length < 2) return false;
  if (!user.email.includes("@")) return false;
  return true;
}

function validateProduct(product: Product): boolean {
  if (!product.name || product.name.length < 2) return false;
  if (product.price < 0) return false;
  return true;
}
```

**Why it's better:** split by domain even though the name-length line repeats once — `User` and `Product` will change their rules on their own schedule. This is "false duplication": it looks the same but isn't the same concept, so don't DRY it.

#### ❌ Don't: Duplicate a Real Shared Business Rule

```typescript
function getOrderTotal(order: Order): number {
  let total = order.items.reduce((sum, i) => sum + i.price * i.qty, 0);
  if (order.country === "TH") total *= 1.07;
  else if (order.country === "SG") total *= 1.08;
  return total;
}

function getInvoiceTotal(invoice: Invoice): number {
  let total = invoice.items.reduce((sum, i) => sum + i.price * i.qty, 0);
  if (invoice.country === "TH") total *= 1.07;
  else if (invoice.country === "SG") total *= 1.08;
  return total;
}
```

**Why it's bad:** the tax rate is one real business rule, duplicated in two places. A VAT change means finding both copies — and risking missing one.

#### ✅ Do: Extract the Shared Rule

```typescript
function calculateSubtotal(items: LineItem[]): number {
  return items.reduce((sum, i) => sum + i.price * i.qty, 0);
}

function applyTax(amount: number, country: string): number {
  const taxRates: Record<string, number> = { TH: 1.07, SG: 1.08 };
  return amount * (taxRates[country] ?? 1);
}

function getOrderTotal(order: Order): number {
  return applyTax(calculateSubtotal(order.items), order.country);
}

function getInvoiceTotal(invoice: Invoice): number {
  return applyTax(calculateSubtotal(invoice.items), invoice.country);
}
```

**Why it's better:** extract only the parts that are genuinely the same business rule (tax rate, subtotal). `getOrderTotal` reads as a flow you understand without opening the implementation underneath.

#### ❌ Don't: Over-Parameterize a Shared Abstraction

```typescript
function renderList(items: unknown[], options: RenderListOptions = {}) {
  // options: showHeader, headerText, showFooter, footerText, itemRenderer,
  // emptyMessage, sortBy, sortOrder, filterFn, groupBy, onItemClick, className
  // ...80 lines of if/else covering every combination
}
```

**Why it's bad:** one function tries to cover every use case the project has ever needed, so every call site requires reading the whole option list to know what applies. Even though it's technically "DRY," the cognitive load is higher than before the abstraction existed.

#### ✅ Do: Wrap the Abstraction per Use Case

```typescript
function renderUserList(users: User[], onUserClick: (u: User) => void) {
  return renderList(users, {
    render: (u) => `${u.name} (${u.email})`,
    onClick: onUserClick,
    empty: "No users",
  });
}

function renderProductList(products: Product[]) {
  return renderList(products, {
    render: (p) => `${p.name} - $${p.price}`,
    empty: "No products",
  });
}

// renderList keeps only the options every call site actually uses
function renderList<T>(items: T[], { render, onClick, empty }: RenderListCore<T>) {
  if (items.length === 0) return empty;
  return items.map((i) => `<li onclick="${onClick}">${render(i)}</li>`).join("");
}
```

**Why it's better:** wrap per real use case (`renderUserList`, `renderProductList`) and keep the shared `renderList` core limited to the options actually in use — don't pre-build for a future that hasn't happened yet (YAGNI).

#### Decision Table

| Question                                                                           | If yes                                                | If no                                                     |
| ----------------------------------------------------------------------------------- | ------------------------------------------------------ | ---------------------------------------------------------- |
| Does the duplicated code always change together (one true single source of truth)? | DRY it                                                | Leave it duplicated                                       |
| Is it understandable within ~30 seconds on first read?                             | Passes                                                | Refactor for readability, even at the cost of duplication |
| Does understanding one piece of logic require jumping across more than 2 files?    | Sign of over-abstraction                              | Fine                                                      |
| Does the function take more than 1-2 boolean flags to fork its behavior?           | Risk of over-abstraction — split the function instead | Fine                                                      |

---

## 2. Architecture & Error Handling

Structuring work and handling errors properly to improve system stability.

- **Single Responsibility Principle (SRP):** Each function or module should do exactly one thing.
- **Guard Clauses (Early Return):** Check and rule out invalid conditions immediately to reduce nested `if-else` depth (avoid the "Arrow Anti-Pattern").
- **Proper Error Handling:** Handle exceptions explicitly. Avoid empty `catch` blocks or silently swallowing errors.

### ❌ Don't: Nest Conditions and Swallow Errors

```typescript
function processPayment(user: any, amount: number) {
  try {
    if (user != null) {
      if (user.isVerified) {
        if (amount > 0) {
          paymentGateway.charge(user.id, amount);
        }
      }
    }
  } catch (e) {
    // error hidden, not handled
  }
}
```

**Why it's bad:** three nested `if`s force a reader to hold all three conditions in their head just to find the real logic buried inside. The empty `catch` swallows any error — if the charge fails, nobody finds out, and the failure is silent to both the user and the logs.

### ✅ Do: Use Guard Clauses and Handle Errors Explicitly

```typescript
function processPayment(user: User | null, amount: number): void {
  if (!user) {
    throw new Error("User is required for payment processing");
  }
  if (!user.isVerified) {
    throw new Error("Unverified user cannot process payments");
  }
  if (amount <= 0) {
    throw new Error("Payment amount must be greater than zero");
  }

  try {
    paymentGateway.charge(user.id, amount);
  } catch (error) {
    logger.error("Failed to execute payment charge", { userId: user.id, amount, error });
    throw error;
  }
}
```

**Why it's better:** each guard clause rules out one invalid case and exits right away, so the code that's left is only the real logic, at one indent level. The `catch` logs the error with context (`userId`, `amount`) before re-throwing, so failures are visible and debuggable instead of disappearing.

---

## 3. Testing Guidelines (F.I.R.S.T.)

Writing good unit tests to build confidence when fixing or refactoring code.

- **Fast:** Tests should run quickly, so they can be run often during development.
- **Independent:** Each test case should not depend on the result of a previous test.
- **Repeatable:** Running the same test any number of times, in any environment, should give the same result.
- **Self-Validating:** Tests should check and report Pass/Fail on their own.
- **Timely:** Write tests alongside the feature, not long after.

### ❌ Don't: Write Vague, Weak Assertions

```typescript
test("discount test", () => {
  const items = [{ id: "1", price: 500, quantity: 2 }];
  const res = DiscountCalculator.applyBulkDiscount(items);
  expect(res).toBeTruthy();
  expect(res == 900).toBe(true);
});
```

**Why it's bad:** the test name "discount test" says nothing about what's being checked, so a failure doesn't tell you what broke. `expect(res).toBeTruthy()` passes for almost any non-zero result, so it wouldn't catch a wrong discount amount — and `res == 900` duplicates the real check right below it for no reason.

### ✅ Do: Use the AAA Pattern with Precise Assertions

```typescript
describe("DiscountCalculator", () => {
  it("should apply 10% discount when total amount is 1,000 or greater", () => {
    // 1. Arrange
    const items: CartItem[] = [
      { id: "item-1", name: "Keyboard", price: 500, quantity: 2 }
    ];

    // 2. Act
    const finalPrice = DiscountCalculator.applyBulkDiscount(items);

    // 3. Assert
    expect(finalPrice).toBe(900);
  });
});
```

**Why it's better:** the test name states the exact rule being checked, so a failure tells you what's wrong without reading the test body. The three labeled sections (Arrange, Act, Assert) separate setup from the check, and `toBe(900)` fails on any wrong value instead of just any falsy one.
