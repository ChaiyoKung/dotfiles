---
name: coding-standards-typescript
description: 'Use this whenever writing or editing TypeScript (.ts/.tsx) code, or setting up/adjusting eslint.config.js, .prettierrc, tsconfig.json, or Husky/lint-staged git hooks - even if the user never says "TypeScript standards." Covers naming casing conventions (PascalCase for types/interfaces/classes, camelCase for variables/functions, UPPER_SNAKE_CASE for true constants, `error` not `err`), named exports over `export default`, extracting error messages into a shared helper, and a recommended ESLint flat config + Prettier setup. Pair with the coding-standards-general skill for naming intent, DRY, and error-handling principles that apply beyond TypeScript, and coding-standards-react for React/JSX-specific patterns like Props typing.'
---

# TypeScript Coding Standards

Language-specific rules for TypeScript projects. For naming intent, KISS, DRY, error handling, and testing principles that apply to any language, use the coding-standards-general skill.

## 1. Naming Casing

Follow standard TypeScript casing: `PascalCase` for types/interfaces/classes, `camelCase` for variables/functions, `UPPER_SNAKE_CASE` for true constants.

Name a caught error `error`, not the abbreviation `err`:

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

**Why:** a full, consistent name is easier to read and search for, and avoids collisions with unrelated short variables (like `e` for events).

---

## 2. Named Exports over `export default`

**Rule:** Prefer named exports by default. Only use `export default` when forced to by a framework/library (e.g. a Next.js page component, or certain dynamic `import()` / lazy-loading cases).

```ts
// ❌ Avoid
export default class MyClass {}

// ✅ Do
export class MyClass {}
```

**Why:** refactor-friendly and gives accurate autocomplete — renaming via the IDE updates every import automatically, since named exports can't be renamed inconsistently by each importer.

---

## 3. Extracting Error Messages

**Rule:** Avoid repeating the same inline conditional to pull a message out of a caught error. At minimum, pull it into a variable; ideally, share one small pure function across the project.

```ts
// ❌ Don't
try {
  // some code
} catch (error) {
  console.error(error instanceof Error ? error.message : "Unknown error");
}

// ✅✅ Better — a small, single-purpose helper, called explicitly at each site
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

**Why:** the `instanceof Error` check tends to repeat at every catch site, so centralizing it means one place to update or test. This is the kind of small, pure, single-purpose helper that's always fine to share — it's not a control-flow wrapper hiding what a call site does, just one obvious substitution any reader can already guess.

---

## 4. Automated Tooling (Linters & Formatters)

Using automated tools to enforce code standards, instead of relying only on manual review.

- **Formatter:** Handles code appearance and layout (e.g. Prettier, Black, gofmt).
- **Linter:** Checks quality, catches bugs, and flags anti-patterns (e.g. ESLint, Ruff, golangci-lint).
- **Git Hooks:** Use Husky with `lint-staged` to automatically run format and lint on changed files before commit.

  [Developer Edit] ➔ [Git Commit] ➔ [Husky / lint-staged] ➔ [Prettier & ESLint Fix] ➔ [Commit Success]

> Note: actual config files (`eslint.config.js`, `.prettierrc`, `tsconfig.json`, etc.) should live at the repo root, not in this document — the agent and CI read from the config files directly. The examples below show a reasonable generic starting point; adjust per project as needed.

### Configuration Examples (TypeScript Stack)

#### `eslint.config.js`

ESLint 9+ uses flat config by default, and ESLint 10 removed the legacy `.eslintrc*` system entirely — `eslint.config.js` is now the only supported format.

```javascript
import js from "@eslint/js";
import tseslint from "typescript-eslint";
import prettier from "eslint-config-prettier";
import globals from "globals";

export default tseslint.config(
  js.configs.recommended,
  ...tseslint.configs.recommended,
  prettier,
  {
    languageOptions: {
      globals: { ...globals.browser, ...globals.node },
    },
    rules: {
      "@typescript-eslint/no-unused-vars": ["error", { argsIgnorePattern: "^_" }],
      "no-console": ["warn", { allow: ["warn", "error"] }],
      eqeqeq: ["error", "always"],
      curly: ["error", "all"],
    },
  }
);
```

#### `.prettierrc`

```json
{
  "arrowParens": "always",
  "bracketSameLine": false,
  "bracketSpacing": true,
  "jsxSingleQuote": false,
  "printWidth": 120,
  "semi": true,
  "singleQuote": false,
  "tabWidth": 2,
  "trailingComma": "es5",
  "useTabs": false
}
```
