# dotfiles

## Reading the repo

Read files based on the `## Project structure` map in AGENTS.md — go straight to the
relevant file rather than reading the whole repo. Only open additional files when the
structure map and the files you have already read leave you without enough information.
Stop reading once you can act. This keeps context small and avoids wasting tokens.

## Agent workflow

Four slash commands cover the standard change lifecycle:

- `/plan <task>` — structured planning: maps files, flags risks, gates conversation-first
  items. No code written. Use for anything non-trivial.
- `/code <task>` — invokes the `dotfiles-coder` subagent: implements the change, runs
  `shellcheck` / `bash -n` / `chezmoi verify`, and self-reviews before finishing.
- `/review` — standalone review checklist when needed outside the normal pipeline.
- `/docs` — updates README.md and AGENTS.md directly based on what changed.

Agent files live in `.claude/` (version-controlled, excluded from `chezmoi apply`).

## Documentation

Use `/docs` after completing a code change — it applies documentation updates directly.
Outside of `/docs`, do not update documentation without explicit approval.

Files to keep in sync when behavior changes:
- `README.md` — update install steps, the per-OS support tables (✅/❓/🚫), and the
  "Project State" / "Highlights" sections when supported platforms, tools, or the
  install flow change.
- `AGENTS.md` `## Project structure` — update when the directory layout changes.
- `AGENTS.md` template-data and naming sections — update if the `.chezmoidata` keys,
  `.chezmoi.toml.tmpl` prompts, or source-state naming conventions change.

## Commit messages

Follow Conventional Commits, matching the existing history: `type(scope): summary`.
Common types: `feat`, `fix`, `chore`, `docs`. Scope is usually the platform or area —
`(macos)`, `(debian)`, `(pwsh)`, `(git)`, `(readme)`. Keep the summary imperative and
focused on one logical change.

## Pull requests

Before opening or updating a PR, confirm:
- shellcheck and `bash -n` pass for `scripts/install_debian.sh` and `scripts/logging.sh`.
- `chezmoi apply --exclude externals` then `chezmoi verify --exclude externals` report
  no drift, and a second `apply` is a no-op (idempotent) — on Linux and macOS where
  reachable. CI runs both.
- Templates render: `chezmoi execute-template` (or `chezmoi diff`) on anything touched.
- No secrets, machine-specific values, rendered/target files, or editor/cache artifacts
  in the diff.
- The diff is focused: no unrelated reformatting or churn.

Do not create a PR unless explicitly asked.
