---
name: engineering-mindset
description: Capture and maintain the user's personal software-engineering mindset — durable opinions, values, and habits about how they like to build software (e.g. "prefer explicit over implicit", "avoid premature abstraction", "always write the test first"), stored as one file per topic inside a global folder at ~/.agents/docs/mindset/ that travels across every project, not just the current repo. Use this whenever the user states a general rule or opinion about how they like to write, test, design, review, or debug software — even in passing, even if they never ask you to write it down. Also use whenever the user explicitly asks to write, update, review, or read their mindset/philosophy doc (e.g. "จดไว้ใน mindset ของฉัน", "add this to my mindset doc", "what's my testing philosophy?", "/mindset"). Do NOT use this for project-specific facts, terminology, or decisions tied to one codebase (that's the domain-modeling skill / CONTEXT.md / ADRs), and not for one-off calls about a single piece of code.
---

# Engineering Mindset

Keep a running, personal record of how the user thinks about building software — not facts about any one project, but beliefs they'd carry into any project. Think of it as their engineering philosophy, written in their own voice, that any future Claude session (in any repo) can read to understand how they like to work.

## Where it lives

One folder, global, not per-project: `~/.agents/docs/mindset/`. Each topic gets its own file inside it (e.g. `testing.md`, `architecture.md`, `code-review.md`) — never one giant file with sections.

Create the folder, and each topic file, lazily — only when the first principle for that topic is ready to be written. Don't scaffold empty files or an empty folder in advance.

## What belongs here (and what doesn't)

A statement belongs in `mindset/` only if it would still be true in a different project, in a different language, next year. Ask: "is this a rule about *this codebase*, or a rule about *how I build software*?"

- **Belongs here:** "I'd rather duplicate three lines than introduce the wrong abstraction." "Tests should read like documentation." "I don't trust a PR review that only checks the diff, not the surrounding code."
- **Does NOT belong here:**
  - A fact, term, or decision specific to one codebase → that's [[domain-modeling]]'s job (`CONTEXT.md` / ADRs).
  - A one-off judgment call about a single piece of code ("let's inline this helper") with no general rule behind it.
  - Feedback purely about how Claude personally should behave with this user (tone, verbosity, when to ask questions) → that belongs in Claude's own memory, not this doc, because this doc is meant to be read by the user too, not just by Claude.

If a statement is ambiguous between "mindset" and "project fact," ask the user which it is rather than guessing.

## Capture it two ways

**Passively, during normal conversation.** The moment the user states a general opinion or rule about how they like to build software, start capturing it right there — don't wait to be asked, and don't batch it up for later. This mirrors how the domain-modeling skill captures glossary terms the instant they're resolved. If it's a brand-new entry, grill it first (see below), then write it, and say in one short line what file you added it to, so the user can correct you if you misread it or filed it under the wrong topic.

**On request.** When the user directly asks you to write, update, review, or read the doc, open the relevant file(s) under `~/.agents/docs/mindset/` and do exactly that — add the new entry (grilling it first, see below), edit an existing one, or read files back to them. If they ask for the whole thing and there are several files, list the folder first so you don't miss one.

Before adding a new entry, skim the existing files for something that already covers the same ground — don't assume the current topic file is the only place it could be. If the new statement refines, contradicts, or narrows an existing entry, edit that entry in place instead of appending a near-duplicate. If it flatly contradicts an older entry, point that out to the user and ask which one still holds before you write anything.

## Grill every new entry before you write it

A mindset entry is meant to outlive this conversation — it travels into every future project, in the user's own voice, as something they stand behind. That's a high bar for a single offhand sentence to clear. So before writing any **brand-new** entry (not when you're just editing or narrowing one that's already on file), invoke the `grilling` skill on the statement itself, using the statement as the seed of the design tree: what makes this true for them, does it hold in every language and project or only some, what's the sharpest way to say it, what's the exception that would break it.

Let grilling size itself to the statement — a simple, already-sharp opinion may clear its frontier in a single round; a sweeping claim ("I always write tests first") may need a few rounds to find its real boundaries. Only write the entry once the frontier is empty and the user has confirmed the sharpened wording — write that sharpened version to the file, not the user's original phrasing. This replaces guessing at the right tightening on your own; let the user's own answers do that work instead.

## Format

Use the structure and rules in [MINDSET-FORMAT.md](./MINDSET-FORMAT.md) — including the `created`/`updated` UTC timestamps every file carries in its frontmatter. Get the real time with `date -u`, don't guess it; MINDSET-FORMAT.md has the exact command and rules for when each timestamp changes.
