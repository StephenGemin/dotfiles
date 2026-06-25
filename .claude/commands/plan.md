You are in planning mode for this dotfiles repository. Produce a structured plan — no code, no edits.

**Task:** $ARGUMENTS

---

**Step 1 — Conversation gate**
Check AGENTS.md § "What requires a conversation first". If the task touches any listed area
(platform support changes, dotfile renames, template data contract, new package managers,
identity/secrets, broad restructuring), STOP and explain why before planning anything.

**Step 2 — Map to files**
Using AGENTS.md § "Project structure", identify exactly which files need to change.
Be specific: name the file, the section within it, and why. If a file looks relevant but
doesn't actually need touching, say so explicitly.

**Step 3 — Risk assessment**
- Portability: does this behave differently on macOS vs Linux vs Windows? Is gating needed?
- Idempotency: will `chezmoi apply` twice leave no drift?
- Template data contract: are any `.chezmoidata` keys or `.chezmoi.toml.tmpl` prompts changing?
- Naming: does any source file name change? (A rename changes the target path in `$HOME`.)
- Secrets: could this introduce machine-specific paths, usernames, or credentials?

**Step 4 — Output the plan**

1. **Summary** — one sentence describing the change
2. **Files to modify** — each file, what changes, and why
3. **Files to skip** — files that seem relevant but don't need touching (and why)
4. **Verification steps** — exact commands to run after coding:
   ```sh
   bash -n <touched .sh files>
   shellcheck <touched .sh files>
   chezmoi diff
   chezmoi apply --exclude externals && chezmoi verify --exclude externals
   ```
5. **Open questions** — anything that needs an answer before coding begins

Do not write any code. Do not edit any files.
