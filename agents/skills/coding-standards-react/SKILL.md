---
name: coding-standards-react
description: 'Use this whenever writing, editing, or reviewing a React component, hook, or JSX/TSX file - e.g. "add a component," "fix this hook," "why does this re-render," "split this component" - even if the user never says "React standards." Covers file/folder structure by feature, component size and responsibility, composition vs prop-explosion, custom hooks, useEffect discipline and dependency arrays, rules of hooks, compound components, container/presentational split, state management and lifting state, props design, list keys, controlled vs uncontrolled inputs, performance optimization, and behavior-based testing. Pair with the coding-standards-general and coding-standards-typescript skills for full coverage.'
---

# React Coding Standards

React-specific patterns and hygiene. For naming, KISS/DRY, error handling, and testing principles that apply to any language, use the coding-standards-general skill; for TypeScript-specific rules, use the coding-standards-typescript skill.

> **Core principle:** Don't reach for a pattern because it's considered best practice. Start from "what problem does this component have?" — not "which pattern should this use?" — then pick the pattern that solves that problem. If there's no problem, no pattern is needed.

---

## 1. File and Folder Structure

### ✅ Do: Organize by Feature / Domain

```text
features/
  checkout/
    Checkout.jsx
    useCheckout.js
    Checkout.module.css
    Checkout.test.jsx
```

**Why it's better:** related files sit next to each other, so there's less jumping between `components/`, `hooks/`, and `styles/`. Easier to find, refactor, and delete an entire feature at once.

### ❌ Don't: Organize Only by Technical Type

```text
components/
hooks/
reducers/
styles/
```

**Why it's bad:** as the project grows, files belonging to one feature scatter across directories — harder to find, harder to trace dependencies, harder to remove a feature cleanly.

---

## 2. Component Size and Responsibility

Use ~150–200 lines as a warning signal, not a strict rule.

Consider splitting a component when it:
- Has deeply nested conditional JSX
- Manages several unrelated pieces of state
- Handles data fetching, business logic, and rendering together
- Has multiple responsibilities
- Needs heavy scrolling to understand the `return`
- Contains a section of UI that represents a clear, independent concept

### ❌ Don't: Put Fetching, Logic, Styling, and Rendering in One Component

```text
UserPage
 ├── fetch data
 ├── transform data
 ├── validate data
 ├── manage form
 ├── handle modal
 ├── handle pagination
 ├── business logic
 └── render 500 lines of JSX
```

**Why:** this becomes a **God Component** — changing one part unintentionally affects another, and testing/debugging gets much harder.

> Don't split a component just because it crosses 200 lines. If it still has one responsibility and is easy to follow, leave it.

---

## 3. Composition

Composition builds complex UI by combining smaller components, instead of one component with a config prop for every variation.

### ✅ Do: Use Composition When Consumers Need to Control Structure or Content

```jsx
<Modal>
  <Modal.Header>Delete Account</Modal.Header>
  <Modal.Body>Are you sure you want to delete your account?</Modal.Body>
  <Modal.Footer>
    <Button variant="secondary">Cancel</Button>
    <Button variant="danger">Delete</Button>
  </Modal.Footer>
</Modal>
```

**Why it's better:** makes UI structure explicit, reduces configuration props, supports variation naturally, keeps each component focused.

### ❌ Don't: Use Large Numbers of Props to Control Every Part of the UI

```jsx
<Card
  title="User Profile"
  titleIcon={<UserIcon />}
  content={<UserProfile />}
  footer={<CardFooter />}
  showHeader
  showFooter
  showIcon
  showDivider
  headerAlign="left"
  contentPadding="large"
/>
```

**Why it's bad:** five boolean props already means 2⁵ = 32 possible combinations, some meaningless or contradictory.

---

## 4. Custom Hooks

Custom Hooks encapsulate **stateful logic, side effects, or reusable behavior** — not just "code that happens to run inside a component."

### ✅ Do: Extract Complex or Reusable Logic into Custom Hooks

```jsx
function useUserProfile(userId) {
  const [user, setUser] = useState(null);
  useEffect(() => {
    fetchUser(userId).then(setUser);
  }, [userId]);
  return user;
}

function UserProfile({ userId }) {
  const user = useUserProfile(userId);
  return <div>{user?.name}</div>;
}
```

**Why:** separates behavior/logic from UI — easier-to-read components, reusable logic, logic testable independent of rendering.

Good custom-Hook candidates: `usePagination`, `useSearch`, `useDebounce`, `useUserProfile`, `useAuthentication`, `useMediaQuery`, `useForm`.

### ❌ Don't: Create a Custom Hook Just to Move Code Out of a Component

```jsx
// ❌ no state, no effect, no context — not a Hook
function useButtonText() {
  return "Submit";
}
```

If it doesn't touch React state, effects, context, or other Hooks, it's a regular function:

```jsx
function getButtonText() {
  return "Submit";
}
```

### ❌ Don't: Use a Custom Hook for Pure Utility Logic

```jsx
// ❌
function useFormatCurrency(amount) {
  return formatCurrency(amount);
}
```

Use the plain function directly when it's pure logic with no React dependency.

---

## 5. `useEffect` and Effect Logic

### ✅ Do: Extract Complex Effect Logic into Dedicated Hooks

Instead of stacking unrelated effects in one component:

```jsx
useEffect(() => { /* fetch user */ }, [userId]);
useEffect(() => { /* subscribe websocket */ }, [userId]);
useEffect(() => { /* sync URL */ }, [filter]);
useEffect(() => { /* save to local storage */ }, [settings]);
```

Extract each behavior into its own Hook:

```jsx
const user = useUser(userId);
const socket = useUserSocket(userId);
useUrlFilter(filter);
usePersistSettings(settings);
```

**Why:** reduces "useEffect soup" — each behavior gets a clear boundary.

### ❌ Don't: Use `useEffect` to Calculate Values That Can Be Derived During Render

```jsx
// ❌
const [filteredItems, setFilteredItems] = useState([]);
useEffect(() => {
  setFilteredItems(items.filter(item => item.category === filter));
}, [items, filter]);
```

```jsx
// ✅
const filteredItems = items.filter(item => item.category === filter);
```

**Why:** fewer unnecessary renders, fewer effect dependencies to keep in sync, no risk of stale derived state.

---

## 6. Rules of Hooks

Always call Hooks at the top level — never inside `if`, `for`, or a nested function:

```jsx
// ❌
if (isLoggedIn) {
  useEffect(() => { /* ... */ }, []);
}

// ❌
function handleClick() {
  const [value, setValue] = useState();
}
```

**Why:** React relies on Hook call order to preserve state across renders — a conditional call order makes React associate state with the wrong Hook.

Enable `eslint-plugin-react-hooks` so violations are caught automatically, not by review.

---

## 7. `useEffect` Dependency Array

Keep dependencies consistent with the logic that actually runs inside the effect:

```jsx
useEffect(() => {
  fetchUser(userId);
}, [userId]);
```

### ❌ Don't: Disable `react-hooks/exhaustive-deps` as a Habit

```jsx
// ❌
useEffect(() => {
  // ...
  // eslint-disable-next-line react-hooks/exhaustive-deps
}, []);
```

**Why:** disabling the lint rule hides a real missing dependency instead of fixing it, and risks a **stale closure** (the effect reads a value captured from an earlier render).

If a value genuinely shouldn't re-trigger the effect, fix the design instead: functional state updates, `useRef`, extracting into a custom Hook, or moving logic out of the effect entirely. Ask before disabling the rule.

---

## 8. Compound Components

A group of related components that share state or behavior, usually via Context.

### ✅ Do: Use Compound Components When Multiple Parts Have a Clear Relationship

```jsx
<Tabs>
  <Tabs.List>
    <Tabs.Tab value="profile">Profile</Tabs.Tab>
    <Tabs.Tab value="settings">Settings</Tabs.Tab>
  </Tabs.List>
  <Tabs.Panel value="profile"><Profile /></Tabs.Panel>
  <Tabs.Panel value="settings"><Settings /></Tabs.Panel>
</Tabs>
```

Good candidates: `Tabs`, `Accordion`, `Dropdown`, `Menu`, `Modal`, `Select`, `Table`, `Form`.

### ❌ Don't: Use Compound Components Just for Namespacing

```jsx
// ❌ no shared state/behavior between these — just a naming convention
<Dashboard>
  <Dashboard.Header />
  <Dashboard.RandomWidget />
  <Dashboard.UnrelatedComponent />
</Dashboard>
```

### ❌ Don't: Force Every Multi-Part Component to Become a Compound Component

If there's no shared state and consumers don't need to customize each part, a plain prop API is simpler:

```jsx
// ✅ simpler, if there's no real customization need
<UserCard user={user} />
```

---

## 9. Container / Presentational

Separate data/business logic from UI rendering — only when the separation actually reduces complexity.

### ✅ Do: Separate When It Makes the UI Easier to Understand

```jsx
// Container
function UserListContainer() {
  const { data, isLoading, error } = useUsers();
  if (isLoading) return <UserListLoading />;
  if (error) return <UserListError />;
  return <UserList users={data} />;
}

// Presentational
function UserList({ users }) {
  return (
    <ul>
      {users.map(user => <li key={user.id}>{user.name}</li>)}
    </ul>
  );
}
```

### ❌ Don't: Treat Container / Presentational as a Mandatory Rule

Don't split a simple component like this:

```jsx
function UserCard({ user }) {
  return <div>{user.name}</div>;
}
```

into `UserCardContainer.jsx` + `UserCard.jsx`. That's more files and more indirection for no benefit — Container/Presentational is a tool, not a requirement for every component.

---

## 10. State Management

### ✅ Do: Derive Values During Render When Possible

```jsx
const filteredItems = items.filter(item => item.category === filter);
```

**Why:** keeps a single source of truth (`items` + `filter` → `filteredItems`) with no third state value to keep in sync.

### ❌ Don't: Store Derived Data as Separate State

```jsx
// ❌
const [filteredItems, setFilteredItems] = useState([]);
useEffect(() => {
  setFilteredItems(items.filter(item => item.category === filter));
}, [items, filter]);
```

---

## 11. Lifting State Up

Lift state only to the nearest common ancestor that actually needs it:

```text
        Checkout
        │
      state
      /   \
   Cart   Summary
```

**Why:** keeps state close to its consumers, avoids unnecessary prop drilling, and keeps re-render scope narrow.

Don't move all state to the root or a global store by default — state that belongs to one component/feature shouldn't automatically become global just because a pattern exists for it. Use global state only when there's a real requirement for broad shared state.

---

## 12. Props Design

### ✅ Do: Use Enum-like Props for Mutually Exclusive Variations

```jsx
<Button variant="primary" size="large" />
```

### ❌ Don't: Use Many Boolean Props to Represent Variants

```jsx
// ❌ isLarge + isSmall is an impossible state
<Button isLarge isSmall isRed isRounded isOutlined isCompact />
```

**Why:** boolean props multiply into combinations that include contradictory states (`isLarge` + `isSmall` at once). Prefer `size="large"` for mutually exclusive concepts.

---

## 13. Keys in Lists

### ✅ Do: Use a Unique and Stable ID

```jsx
{items.map(item => <Item key={item.id} item={item} />)}
```

### ❌ Don't: Use Array Index as a Key When the List Can Reorder

```jsx
// ❌ breaks if items can be removed, inserted, reordered, or filtered
{items.map((item, index) => <Item key={index} item={item} />)}
```

**Why:** when order changes, an index-based key can point React at the wrong item, and local state (e.g. an input's value) can appear under the wrong row.

> Array indexes are fine for a truly static list that never reorders — but prefer a stable ID whenever one exists.

---

## 14. Controlled vs Uncontrolled Components

Keep state ownership explicit:

```jsx
// Controlled
<input value={name} onChange={e => setName(e.target.value)} />

// Uncontrolled
<input defaultValue="John" ref={inputRef} />
```

### ❌ Don't: Accidentally Switch Between Controlled and Uncontrolled

```jsx
// ❌ if maybeUndefined starts as undefined and later becomes a real value
<input value={maybeUndefined} onChange={handleChange} />
```

**Why:** produces the "component is changing an uncontrolled input to be controlled" warning and inconsistent input behavior. If a controlled value can be missing, default it (`value={name ?? ""}`).

---

## 15. Performance Optimization

Optimize based on evidence — React DevTools Profiler, real measurements, actual benchmarks — before reaching for `useMemo`, `useCallback`, or `React.memo`.

### ❌ Don't: Add Memoization Everywhere by Default

```jsx
// ❌ added because "memoization is assumed to help", not because it was measured
const value = useMemo(() => calculate(value), [value]);
const handleClick = useCallback(() => { /* ... */ }, []);
const Component = memo(MyComponent);
```

**Why:** memoization isn't free — dependency comparisons, memoization overhead, and reduced readability are real costs. Add it once profiling shows a measurable win, not as a habit.

---

## 16. Composition vs Inheritance

Prefer composition:

```jsx
<Card>
  <Card.Header>Title</Card.Header>
  <Card.Body>Content</Card.Body>
</Card>
```

### ❌ Don't: Use Class Inheritance to Share React Behavior

```text
// ❌
BaseComponent
    ├── UserComponent
    ├── AdminComponent
    └── GuestComponent
```

**Why:** inheritance couples parent and child — a base-class change can affect subclasses unexpectedly. Prefer composition, custom Hooks, or shared utility functions instead.

---

## 17. Testing

Test user-visible behavior, not internal implementation:

```jsx
fireEvent.click(screen.getByText("Submit"));
expect(screen.getByText("Success")).toBeInTheDocument();
```

Prefer user-oriented APIs (`userEvent`) when available.

**Why:** behavior-based tests stay valid across internal refactors (e.g. `useState` → `useReducer`) as long as the user-visible outcome is unchanged. Assertions like `state.someInternalValue === true` are brittle — they fail on harmless refactors even when nothing user-visible changed.

---

## 18. Choosing the Right Pattern

Don't start with "which design pattern should this component use?" Start with "what problem does this component have?", then match the pattern to the problem:

| Problem                                              | Pattern to Consider            |
| ----------------------------------------------------- | ------------------------------- |
| Need to customize UI structure or content            | **Composition**                |
| Reusable stateful behavior or side effects           | **Custom Hooks**               |
| Multiple related components sharing state/behavior   | **Compound Components**        |
| Data/business logic makes UI hard to understand      | **Container / Presentational** |
| No clear problem                                      | **No pattern needed**          |

Patterns compose: a `Tabs` component might use a custom Hook internally for state, while exposing a Compound Component API via composition.

---

## Final Principle

Good React code isn't the code with the most design patterns in it. It's code that's easy to understand, clearly scoped, loosely coupled, easy to change, easy to test, and free of unnecessary abstraction.

When code gets complex, find the actual problem first — then introduce the pattern that addresses it.
