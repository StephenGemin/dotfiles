Review the current working diff against dotfiles standards. Run the automated checks,
then inspect the diff manually. Report every finding with severity.

---

## Automated checks

Run these and include their full output in your report:

```sh
shellcheck scripts/install_debian.sh scripts/logging.sh
bash -n scripts/install_debian.sh
chezmoi diff
chezmoi apply --exclude externals && chezmoi verify --exclude externals
```

For any `.sh` files touched outside `scripts/`, run `shellcheck` and `bash -n` on those too.

---

## Manual diff inspection

Check each item and mark ✅ (pass) or flag with severity:

**Security / secrets**
- [ ] No hardcoded machine-specific paths, IP addresses, or usernames
- [ ] No credentials, tokens, API keys, or private keys
- [ ] No rendered target-side files committed (e.g., actual `~/.bashrc` content)

**Portability**
- [ ] No GNU-only flags in code that runs on macOS (check `find`, `sed`, `date`, `stat`, `xargs`)
- [ ] macOS-only logic is inside `{{ if eq .chezmoi.os "darwin" }}` or darwin-gated scripts
- [ ] Debian-only logic is gated by the `is-linux-debian` template
- [ ] Windows-only paths are under `AppData/` and gated in `.chezmoiignore`

**Idempotency**
- [ ] `chezmoi apply` twice leaves no drift (confirmed by verify step above)
- [ ] Install commands are guarded — re-runs are no-ops

**chezmoi conventions**
- [ ] Source file names follow chezmoi naming (`dot_`, `.tmpl`, `run_onchange_` as appropriate)
- [ ] No source file renamed without intent (a rename changes the target path in `$HOME`)
- [ ] `run_onchange_` scripts preserve their `# {{ include "<file>" | sha256sum }}` trigger lines
- [ ] Template data contract unchanged: no `.chezmoidata` keys renamed/removed without grepping all uses

**Diff quality**
- [ ] No unrelated reformatting, whitespace churn, or out-of-scope changes
- [ ] No editor artifacts, cache files, or generated output
- [ ] Commit message follows Conventional Commits: `type(scope): summary`

---

## Report format

For each issue:
- **[BLOCK]** `filename:line` — description (must fix before committing)
- **[WARN]** `filename:line` — description (should fix, won't break CI)
- **[INFO]** — observation that doesn't require action

End with one of:
- `✅ Ready to commit`
- `⚠️  Warnings only — your call`
- `🚫 Blocking issues found — fix before committing`
