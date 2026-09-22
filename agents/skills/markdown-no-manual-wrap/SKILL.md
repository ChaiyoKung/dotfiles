---
name: markdown-no-manual-wrap
description: Use this every time you write or edit a .md file with normal prose in it, even if the user does not say "markdown" or "line break" — for example a README, a doc, a report, or a plan file.
---

# No Manual Line Breaks in Markdown Prose

## Core rule

Inside a paragraph of normal text, never press Enter in the middle of a sentence or idea. Write the whole paragraph as **one line**, no matter how long. Let the text editor wrap it on screen for you (this is called "soft wrap" or "word wrap" — almost every editor turns it on by default).

## Do / Don't

**❌ Don't** (manual line breaks inside the paragraph)

```markdown
This project uses TypeScript for type safety.
It also uses ESLint for linting and Prettier
for code formatting. Make sure you run `npm test`
before you open a pull request.
```

**✅ Do** (one line per paragraph, let the editor wrap it)

```markdown
This project uses TypeScript for type safety. It also uses ESLint for linting and Prettier for code formatting. Make sure you run `npm test` before you open a pull request.
```

A blank line still separates two paragraphs — that part does not change:

```markdown
This is the first paragraph, written as one long line with no manual breaks in the middle.

This is the second paragraph, also one long line, separated from the first by a blank line.
```
