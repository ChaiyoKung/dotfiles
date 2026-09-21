# Locality Over DRY — Async Submit Hook Example

Read this when you're deciding whether to extract a generic hook for repeated async-handler boilerplate (loading flag, error state, try/catch/finally).

## ❌ Don't: Extract a Generic Hook Just to Remove Repeated Async Boilerplate

```jsx
// ❌ generic "reset error, run action, catch, clear loading" hook
function useAsyncSubmit(action) {
  const [error, setError] = useState(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  async function submit(...args) {
    setError(null);
    setIsSubmitting(true);
    try {
      await action(...args);
    } catch (caughtError) {
      setError(toErrorMessage(caughtError));
    } finally {
      setIsSubmitting(false);
    }
  }

  return { submit, error, isSubmitting };
}

const { submit: handleSignup, error: signupError } = useAsyncSubmit(createAccount);
```

## ✅ Do: Write the Same Shape Out at Each Call Site

```jsx
const [signupError, setSignupError] = useState(null);
const [isSubmitting, setIsSubmitting] = useState(false);

async function handleSignup(formValues) {
  setSignupError(null);
  setIsSubmitting(true);
  try {
    await createAccount(formValues);
  } catch (error) {
    setSignupError(toErrorMessage(error));
  } finally {
    setIsSubmitting(false);
  }
}
```

**Why:** `handleSignup` on its own shows the whole flow start to finish. `useAsyncSubmit` moves the same shape behind a generic hook, so understanding any one caller means reading the hook too. A small, single-purpose pure helper like `toErrorMessage` is still fine to share — it's the control-flow wrapper (the hook itself) that's worth keeping inline.
