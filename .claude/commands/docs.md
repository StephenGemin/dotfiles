Update documentation to reflect the changes just made. Apply the changes directly.

---

## Sync rules (from CLAUDE.md)

Check each file against the change that was just made:

### README.md
Update if:
- Install steps changed (new prerequisites, changed commands)
- Per-OS support table (`✅/❓/🚫`) changed — a platform gained or lost support
- "Project State" or "Highlights" sections are affected by the change

### AGENTS.md — `## Project structure`
Update if:
- A new directory was added to the source tree
- An existing directory was removed or renamed
- A new significant file type or naming convention was introduced

### AGENTS.md — template-data and naming sections
Update if:
- A `.chezmoidata` key was added, removed, or renamed
- A `.chezmoi.toml.tmpl` prompt was added, changed, or removed
- A new source-state naming convention was introduced

---

If no documentation needs updating, say so explicitly with a brief reason and make no edits.

If updates are needed, apply them now and report which sections you changed and why.
