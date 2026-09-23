# mindset/ Format

## Folder layout

Every topic is its own file, all living flat inside `~/.agents/docs/mindset/`:

```
~/.agents/docs/mindset/
├── general.md
├── testing.md
├── architecture.md
└── code-review.md
```

There's no index file and no `README.md` — the file list *is* the index. Listing the folder is enough to see what topics exist.

## Where a new entry goes

- If an existing file already covers the topic, add the entry there.
- If no file fits yet, put it in `general.md` (create it if it doesn't exist).
- Once `general.md` has three or more entries about the same topic, split them out into their own file (e.g. `testing.md`) and remove them from `general.md`. This is the same rule-of-three judgment used for code duplication — one or two loose entries don't earn a file, three related ones do.

## File naming

Lowercase, kebab-case, named after the topic itself, not generic words: `code-review.md`, not `review.md` or `CodeReview.md`. Before creating a new file, check for a close synonym already in the folder (`testing.md` vs `tests.md`) and reuse it instead of forking a near-duplicate.

## File content

```md
---
created: 2026-09-23T10:15:00Z
updated: 2026-09-23T10:15:00Z
---

# {Topic Title}

- **{Principle}.** {reasoning, 1-2 sentences}
- **{Principle}.** {reasoning, 1-2 sentences}
```

Frontmatter, then one `#` title naming the topic, then a flat bullet list. No sub-sections inside a topic file — if a topic grows complex enough to need its own sub-sections, it's probably actually two topics; split the file instead.

## Timestamps

Both `created` and `updated` are UTC, in `YYYY-MM-DDTHH:MM:SSZ` format. Get the real current time with `date -u +"%Y-%m-%dT%H:%M:%SZ"` — don't guess it or reuse a date mentioned earlier in the conversation, since that may be local time or a stale value.

- **New file:** set `created` and `updated` to the same current timestamp.
- **Editing an existing file** (new entry, edited entry, entry removed): update `updated` to the current timestamp. Leave `created` untouched.
- **Splitting entries out of `general.md` into a new topic file:** the new file is a new file, so its `created` is now — not backdated to whenever the entry first appeared in `general.md`. Update `general.md`'s own `updated` too, since you're editing it to remove those entries.

## Rules

- **Write in the user's voice, as a rule they hold — not a description of a past event.** "I'd rather duplicate three lines than guess at the wrong abstraction," not "the user said they duplicated some code once."
- **Keep each entry tight.** One bold line stating the principle, then at most one or two sentences of reasoning. This is a philosophy doc, not an essay collection.
- **Be opinionated, not wishy-washy.** A hedged statement ("I guess I kind of prefer...") is a sign the entry isn't ready yet — that's what the grilling step in SKILL.md is for. Don't tighten it into a clear stance on your own guess; write down the stance the user actually confirmed.
- **One entry, one idea.** Don't merge two unrelated opinions into one bullet just because they came up in the same sentence.
- **No project names, ticket numbers, or codebase-specific details.** Those anchor the entry to one project and break the "would this still be true elsewhere" test — if a detail like that shows up, it's a sign the statement belongs in that project's `CONTEXT.md` instead.
