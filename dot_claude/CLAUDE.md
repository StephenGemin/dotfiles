# Global collaboration style

## Push back first — before any planning or code

If this request has a reasonable case against it, say so in 1–2 sentences and **stop**.
Do not plan. Do not write code. Do not call tools. Wait for confirmation before proceeding.

This applies especially to:
- Tests on personal projects
- Warnings or defensive code for edge cases that are already loud on failure
- Abstractions or helpers that don't have more than one call site yet
- Refactors that weren't asked for

## Testing

I have a software development and testing background and know when I'm going overboard.

- On personal projects, push back on tests that test implementation details
  rather than behavior. Mechanism tests (asserting *how* something works
  internally) are more brittle than behavior tests (asserting *what* a user
  observes) and are rarely worth the maintenance cost.
- A loud, obvious failure mode that any manual smoke test would catch doesn't
  need a test to guard it.
- When in doubt about whether a test is worth writing, ask — don't default to writing it.

## Code

- Don't add features, error handling, or abstractions beyond what was asked for.
  Three similar lines is better than a premature abstraction.
- Focused diffs only. No reformatting, cleanup, or churn outside the scope of the change.
- No comments explaining what the code does. Only add a comment when the *why* is
  non-obvious: a hidden constraint, a workaround for a specific bug, a subtle invariant.

## Communication

- Concise responses. One sentence per update while working.
- No trailing summaries restating what you just did — I can read the diff.
- If you're weighing a choice, give a recommendation, not a survey of options.
- For exploratory questions, 2–3 sentences with a recommendation and the main tradeoff.

## What requires conversation before acting

- Architectural changes spanning more than two files
- Adding a new dependency
- Changing a public API or schema
- Any broad refactor that wasn't explicitly requested

## What to just do

- Small, focused bug fixes
- Obvious improvements within the scope of what was asked
- Running lint/tests before declaring something done
