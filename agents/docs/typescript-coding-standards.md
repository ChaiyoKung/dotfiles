# TypeScript Coding Standards

Language-specific rules for TypeScript projects. For naming intent, KISS, DRY, error handling, and testing principles that apply to any language, see [general-coding-standards.md](general-coding-standards.md).

## 1. Naming Casing

Follow standard TypeScript casing: `PascalCase` for types/interfaces/classes, `camelCase` for variables/functions, `UPPER_SNAKE_CASE` for true constants.

---

## 2. Automated Tooling (Linters & Formatters)

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
