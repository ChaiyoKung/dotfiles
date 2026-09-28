---
name: markdown-diagrams-mermaid
description: Use this every time you draw a diagram inside a .md file — a flow, an architecture picture, a sequence of steps, a data model, or a state machine — even if the user does not say "mermaid" or "diagram." Write it as a mermaid code block, not as ASCII art (boxes and lines made of `-`, `|`, `+`, `>`). Applies to README files, design docs, ADRs, and any other Markdown file.
---

# Use Mermaid for Diagrams in Markdown

## Core rule

When a `.md` file needs a diagram, write it as a fenced ```mermaid``` code block. Do not draw it with ASCII art (lines made of `-`, `|`, `+`, `>`, boxes made of characters).

## Why this matters

- **It renders as a real picture.** GitHub, GitLab, and most Markdown viewers turn a mermaid block into an actual diagram with boxes and arrows. ASCII art stays as plain text — the reader has to imagine the shape.
- **It is easier to edit.** To move a box or add a step in ASCII art, you must re-align every line by hand. In Mermaid, you just add or change one line of text.
- **It scales.** A 3-box ASCII diagram is fine. A 10-box one turns into a mess of misaligned characters. Mermaid stays clean no matter how big the diagram gets.

## Pick the right diagram type

Look at what you want to show, then pick the matching Mermaid type:

| You want to show... | Use this diagram type | First line of the block |
|---|---|---|
| A process, a decision tree, system architecture | Flowchart | `flowchart TD` (or `LR` for left-to-right) |
| Messages or calls between people/services over time | Sequence diagram | `sequenceDiagram` |
| Classes, objects, and how they relate | Class diagram | `classDiagram` |
| Database tables and their relations | ER diagram | `erDiagram` |
| A state machine (states and what triggers a change) | State diagram | `stateDiagram-v2` |
| A timeline of tasks | Gantt chart | `gantt` |

If you are not sure which type fits, ask: "Is this about **time and order** (things happening one after another) or **structure** (how things are connected)?" Sequence and state diagrams are about order. Flowchart, class, and ER diagrams are about structure.

## Examples

**Flowchart** — a process or architecture:

```mermaid
flowchart TD
    A[User submits form] --> B{Valid input?}
    B -->|Yes| C[Save to database]
    B -->|No| D[Show error message]
    C --> E[Send confirmation email]
```

**Sequence diagram** — interaction over time:

```mermaid
sequenceDiagram
    participant Client
    participant API
    participant DB
    Client->>API: POST /orders
    API->>DB: INSERT order
    DB-->>API: order id
    API-->>Client: 201 Created
```

**Class diagram** — structure of code:

```mermaid
classDiagram
    class Order {
        +String id
        +List~Item~ items
        +total() Decimal
    }
    class Item {
        +String name
        +Decimal price
    }
    Order "1" --> "*" Item
```

**ER diagram** — data model:

```mermaid
erDiagram
    CUSTOMER ||--o{ ORDER : places
    ORDER ||--|{ ORDER_ITEM : contains
    PRODUCT ||--o{ ORDER_ITEM : "ordered in"
```

**State diagram** — a state machine:

```mermaid
stateDiagram-v2
    [*] --> Pending
    Pending --> Approved : approve()
    Pending --> Rejected : reject()
    Approved --> [*]
    Rejected --> [*]
```

## Do / Don't

**❌ Don't** (ASCII art)

```markdown
  +--------+       +--------+       +----------+
  | Client | ----> |  API   | ----> | Database |
  +--------+       +--------+       +----------+
```

**✅ Do** (Mermaid)

```markdown
```mermaid
flowchart LR
    Client --> API --> Database
```
```

## Keep the syntax correct

- Always name the diagram type on the first line inside the block (`flowchart TD`, `sequenceDiagram`, etc.) — a mermaid block with no type keyword fails to render.
- Node IDs (the short names like `A`, `B`, `Client`) cannot contain spaces; put the human-readable label in brackets instead, e.g. `A[User submits form]`.
- Keep arrow syntax per diagram type: flowcharts use `-->`, sequence diagrams use `->>` (call) and `-->>`  (reply), state diagrams use `-->`.
- If the diagram is going to be read by someone, not just Claude, mentally render it (or ask the user to preview it) before trusting complex syntax — a typo in arrow syntax fails silently as unrendered text in some viewers.
