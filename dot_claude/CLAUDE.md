# Global collaboration style

## Push back first — before any planning or code

If this request has a reasonable case against it, say so in 1–2 sentences and **stop**.
Do not plan. Do not write code. Do not call tools. Wait for confirmation before proceeding.

This applies especially to:
- Tests on personal projects
- Warnings or defensive code for edge cases that are already loud on failure
- Abstractions or helpers that don't have more than one call site yet
- Refactors that weren't asked for

This includes technical claims, not just requests: if you assert something as fact
about how the code behaves and I have evidence otherwise, correct me plainly rather
than deferring — I trust corrections more than agreement.

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
- Global variables — especially mutable ones — are never acceptable, including in
  dynamic languages like Python and Lua where module-level "globals" are easy to
  reach for. Use function/closure-local state, class instances, or explicit
  parameters instead. If module-level state seems unavoidable, keep it as a
  private/local binding and only expose a setter function, never a directly
  mutable public field.

## Git workflow

- Never commit directly to `main`, `master`, or `development` in a repo that
  already shows a branch+PR workflow (existing topic branches, PR-numbered
  merge commits in `git log`). Create a topic branch first, matching the
  repo's existing naming convention (e.g. `fix/*`, `feat/*`), even for small
  changes — then commit there.
- In repos with no such evidence (solo/scratch repos, no branch or PR
  history), committing directly to the default branch is fine.
- If unsure which convention a repo follows, check `git branch -a` and
  recent `git log` before the first commit of a session.
- Don't hard-wrap body text in commit messages or PR descriptions — write
  each paragraph as a single unwrapped line and let it soft-wrap. Bullet
  lists are fine as separate lines; the rule is about not manually breaking
  a prose paragraph across lines.
- Keep commit and PR descriptions concise but informative: a tight bulleted summary of
  what changed and why, not prose paragraphs or an exhaustive line-by-line
  restatement of the diff. Cut anything a reviewer can get from the diff itself.

## Communication

- Concise responses. One sentence per update while working.
- No trailing summaries restating what you just did — I can read the diff.
- If you're weighing a choice, give a recommendation, not a survey of options.
- For exploratory questions, 2–3 sentences with a recommendation and the main tradeoff.

## Summaries and session notes

When asked for a summary (or writing one proactively), save it as a markdown
file under this project's Claude project directory — the same directory that
holds this project's `memory/` folder (`~/.claude/projects/<project-slug>/`),
not inside the git-tracked source repo. A stray summary file in the repo
risks being accidentally committed. Give me a file path to the result.

## What requires conversation before acting

- Architectural changes spanning more than two files
- Adding a new dependency
- Changing a public API or schema
- Any broad refactor that wasn't explicitly requested

## What to just do

- Small, focused bug fixes
- Obvious improvements within the scope of what was asked
- Running lint/tests before declaring something done
