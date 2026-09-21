# TypeScript Coding Style & Convention

This document collects a set of personal TypeScript coding conventions, with Do/Don't examples and the key benefit behind each rule.

---

## 1. Use `export` instead of `export default`

**Rule:** Prefer named exports by default. Only use `export default` when forced to by a framework/library (e.g. a Next.js page component, or certain dynamic `import()` / lazy-loading cases).

```ts
// ❌ Avoid
export default class MyClass {}

// ✅ Do
export class MyClass {}
```

**Key benefit:** Refactor-friendly and gives accurate autocomplete — renaming via the IDE updates every import automatically, since named exports can't be renamed inconsistently by each importer.

---

## 2. Use `error` instead of the abbreviation `err`

**Rule:** Name variables fully and descriptively; avoid unnecessary abbreviations.

```ts
// ❌ Don't
try {
  // some code
} catch (err) {
  console.error(err);
}

// ✅ Do
try {
  // some code
} catch (error) {
  console.error(error);
}
```

**Key benefit:** Easier to read and easier to search — a full, consistent name avoids ambiguity and collisions with unrelated short variables (like `e` for events).

---

## 3. Extract the error message into a variable, or better, a dedicated function

**Rule:** Avoid repeating inline conditionals to extract an error message. At minimum, pull it out into a variable; ideally, create a shared function reused across the whole project.

```ts
// ❌ Don't
try {
  // some code
} catch (error) {
  console.error(error instanceof Error ? error.message : "Unknown error");
}

// ✅ Do
try {
  // some code
} catch (error) {
  const errorMessage = error instanceof Error ? error.message : "Unknown error";
  console.error(errorMessage);
}

// ✅✅ Better
function extractErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message;
  }

  return String(error);
}

try {
  // some code
} catch (error) {
  const errorMessage = extractErrorMessage(error);
  console.error(errorMessage);
}
```

**Key benefit:** Less duplication and a single point of change — the `instanceof Error` check tends to repeat at every catch site, so centralizing it means one place to update or test.

---

## 4. React components must always export a Props interface

**Rule:** When creating a React component, always declare and export a separate `interface` for its props, rather than inlining the type in the function parameters.

```tsx
// ❌ Don't
export function MyComponent({ name }: { name: string }) {
  return <div>{name}</div>;
}

// ✅ Do
export interface MyComponentProps {
  name: string;
}

export function MyComponent({ name }: MyComponentProps) {
  return <div>{name}</div>;
}
```

**Key benefit:** Reusable and self-documenting — other files can import the props type directly, and the component's contract is clear without reading its body.