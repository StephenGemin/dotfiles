# dotfiles

My personal, cross-platform machine setup, managed with [chezmoi](https://www.chezmoi.io/).
The source of truth is this repo; `chezmoi apply` renders it into `$HOME` on Debian-based
Linux, macOS, and Windows. Keep it portable, idempotent, and free of machine-specific
or secret values.

## Project goals

- Cross-platform: Windows, macOS, and Debian-based Linux from one source tree. No WSL.
- A unified set of apps, tools, commands, and aliases across all three.
- Works for both personal and work machines (`install_host` = `home` / `work`).
- Colemak-DH keymaps.

## Project structure

```
.chezmoi.toml.tmpl       chezmoi config template; prompts on `init` and exports [data]
                         (name, email, install_host, wingit_install_dir, osid)
.chezmoidata/            static template data merged into the `.` context
  brew.yaml              .packages.{darwin,debian}.{brews,casks}
  common.toml            .fontsDir, .terminalFont, .user.software.*
.chezmoitemplates/       named fragments included via includeTemplate/template
                         (e.g. is-linux-debian, get-catppuccin-themes-dir, app configs)
.chezmoiexternal.toml    external git repos & files (nvim-starter, fonts, plantuml.jar)
.chezmoiignore           which source files are NOT applied + per-OS gating
.chezmoiscripts/         run_onchange_ scripts, gated per-OS (debian/darwin/windows)
scripts/                 real, shellcheck-linted bash invoked by the run scripts
  install_debian.sh      Debian package/tool install (apt/snap/cargo/brew/pipx)
  logging.sh             log_* / error / success helpers, sourced by other scripts
dot_gitconfig.tmpl       -> ~/.gitconfig; check before adding/recommending git aliases —
                         behavior (rebase.autosquash, fetch.prune, push.autoSetupRemote,
                         etc.) may already be configured here instead of needing an alias
dot_*                    files applied to $HOME (dot_bashrc -> ~/.bashrc, etc.)
dot_config/              -> ~/.config (wezterm, git, powershell, sh_plugins, ...)
  sh_plugins/            zsh aliases & functions (Linux + macOS) — paired with powershell/
  powershell/            pwsh equivalents (Windows) — must stay in sync with sh_plugins/
dot_local/               -> ~/.local
dot_claude/CLAUDE.md     -> ~/.claude/CLAUDE.md; the user's GLOBAL Claude Code
                         instructions (applies to every project, not just this repo) —
                         don't confuse with this repo's own CLAUDE.md below
  settings.json          -> ~/.claude/settings.json; deny rule + hook wiring
  hooks/executable_no-session-link.sh -> ~/.claude/hooks/no-session-link.sh; the
                         mechanism dot_claude/CLAUDE.md's top rule cites
AppData/                 Windows-only target paths (Roaming/...), gated in .chezmoiignore
Library/                 macOS-only target paths (~/Library/Application Support/...),
                         gated in .chezmoiignore — same role as AppData/ for Windows
.github/workflows/ci.yml shellcheck + chezmoi apply/verify on Linux & macOS
.claude/                 project-level Claude Code config (not applied to $HOME)
  agents/                subagent definitions (dotfiles-coder)
  commands/              slash commands (plan, code, review, docs)
CLAUDE.md                this repo's own Claude Code instructions (project-scoped)
README.md                user-facing install + tooling docs
```

## Reading this repo efficiently

Use the structure map above to go straight to the relevant file instead of scanning the
whole tree. Do not read the entire repo on every task — it is large (config dumps,
generated XML, font assets) and most files are unrelated to any given change. Read only:

1. The file you are changing, plus the one or two files it directly references.
2. Additional files only when the structure map and those files leave you without enough
   information to act correctly.

For example: a Debian package change touches `.chezmoidata/brew.yaml` or
`scripts/install_debian.sh`; a template-data question is answered by `.chezmoidata/` and
`.chezmoi.toml.tmpl`; platform gating lives in `.chezmoiignore` and `.osid`/`is-linux-debian`.
Prefer targeted search over broad reads, and stop reading once you have what you need.
This keeps context small and avoids unnecessary token usage.

## Philosophy

This repo is intentionally lean and convention-driven. Every change should leave it
simpler, more portable, or more correct — not more clever. Prefer chezmoi's built-in
mechanisms (source-state attributes, templates, `.chezmoidata`, externals) over bespoke
scripting. If a need can be met with existing data or a template, do that before adding code.

## chezmoi source-state naming (read before renaming anything)

File names *are* configuration. chezmoi derives the target path and behavior from the
source name:

- `dot_` prefix → leading `.` in `$HOME` (`dot_bashrc` → `~/.bashrc`).
- `.tmpl` suffix → rendered as a Go `text/template` with chezmoi data + sprig funcs.
- `run_onchange_` → a script re-run when its rendered content changes. Several embed a
  `# {{ include "<file>" | sha256sum }}` line so editing the referenced file (e.g.
  `scripts/install_debian.sh`, `.chezmoidata/brew.yaml`) re-triggers the run. Keep that
  line when editing these scripts.
- `exact_`, `private_`, `readonly_`, `encrypted_` carry their usual chezmoi meaning if
  introduced — don't add them without reason.

Renaming a source file silently changes the target path or behavior. Treat renames as a
behavior change, not cosmetics.

## Platform gating

Three mechanisms, used consistently — don't invent a fourth:

- `.chezmoiignore` excludes whole paths per OS (e.g. `AppData/` off-Windows, `powershell`
  off-Windows). README, LICENSE, `scripts/`, and `.editorconfig` are never applied.
- `.osid` (`linux-ubuntu`, `darwin`, `windows`, ...) and `.chezmoi.os` drive `{{ if }}`
  branches inside templates and scripts.
- The `is-linux-debian` template gates Debian-only logic.

Scripts gate themselves by wrapping their body in a conditional that emits an **empty**
script on non-matching OSes; chezmoi skips empty scripts. Preserve that pattern.

## Template data contract

Templates depend on a stable data shape. Changing these keys breaks rendering elsewhere —
grep first, change deliberately:

- From `.chezmoidata/`: `.packages.{darwin,debian}.{brews,casks}`, `.fontsDir`,
  `.terminalFont.{name,size}`, `.user.software.{python_version,default_shell}`.
- From `.chezmoi.toml.tmpl` `[data]`: `.name`, `.email`, `.install_host`,
  `.wingit_install_dir`, `.osid`.

Add packages by editing `.chezmoidata`, not by hardcoding them in scripts.

## What requires a conversation first

- Adding, dropping, or changing support for a platform.
- Renaming or relocating any applied dotfile (changes the target path in `$HOME`).
- Changing the template data contract or the `chezmoi init` prompts in `.chezmoi.toml.tmpl`.
- Adding a new package manager, or an external dep in `.chezmoiexternal.toml`.
- Anything touching identity/secrets or how `install_host` (home/work) is resolved.
- Broad restructuring across multiple directories.

## Build and test

```sh
chezmoi diff                 # preview what apply would change
chezmoi execute-template < f # render a single template to check data/logic
chezmoi apply --exclude externals
chezmoi verify --exclude externals   # must report no drift after apply
shellcheck scripts/install_debian.sh scripts/logging.sh
bash -n scripts/install_debian.sh    # syntax check
```

CI (`.github/workflows/ci.yml`) is the contract and must stay green:
shellcheck + `bash -n`, then on **both Linux and macOS** a fresh `apply` → `verify`
followed by a re-`apply` → `verify` (idempotency). `apply` must be safe to run twice and
leave no drift. Use `CI=true` to keep network/install steps in dry-run mode.

## Code style

- bash: `#!/usr/bin/env bash`, `set -eu`, shellcheck-clean. Justify every `# shellcheck
  disable=...` with a short reason inline.
- Guard installs with `command_exists` (or equivalent) so re-runs are no-ops.
- Use the `logging.sh` helpers (`log_task`, `log_info`, `error`, `success`) rather than
  bare `echo` for status.
- EditorConfig is authoritative: UTF-8, LF, 4-space indent (2 for `*.yml`/`*.yaml`),
  trailing whitespace trimmed (except Markdown), final newline.
- Clear names over abbreviations; keep functions small and single-purpose.

## What to avoid

- Hardcoding machine-specific paths, usernames, or secrets — use template data / prompts.
- Committing rendered output, target-side files, secrets, or build/editor/cache artifacts.
- Breaking idempotency — `apply` re-runs must not drift (CI verifies this).
- OS-specific code that breaks the other two platforms; gate it instead.
- Adding tooling or externals without considering `.chezmoiignore` and per-OS gating.
- GNU-only assumptions in code that also runs on macOS (BSD) — prefer portable flags.
