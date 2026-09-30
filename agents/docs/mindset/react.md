---
created: 2026-09-30T08:17:46Z
updated: 2026-09-30T08:28:18Z
---

# React

- **I split JSX into a named component so the parent reads like a table of contents.** The name tells me what the part is, without reading its markup. Readability comes first; file length and reuse do not decide this. A component used only once is fine, and reuse is only a bonus.
- **I do not extract a short JSX element that already says what it is, like `<Text>` or `<Divider />`.** The exception is an element with many props that change it from its default look. Then a named component is worth it, because the name explains the styling.
- **A component keeps the same look everywhere, and the parent decides where to place it.** I keep the look (color, padding, radius, blur) inside the component. I pass the placement (`pos`, `top`, `left`, `right`, `zIndex`) in from outside. Then I can move the component anywhere, and it does not need to know its surroundings.
- **One component has one job. I do not build a super component that wraps many controls and needs a long list of props to wire them.** Such a props list only copies the parent's state and handlers. I keep the small controls visible in the parent and wrap only the part that has one clear job.
- **Every component that takes props has a props type named after it: `{ComponentName}Props`.** The name links the type to its component, so I can read the code without searching for what the props are.
