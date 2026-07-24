#!/usr/bin/env bash

#
# Usage:
#   ./nvim_config_migration.sh            show which config is active
#   ./nvim_config_migration.sh config     switch to the repo default (nvim-config)
#   ./nvim_config_migration.sh starter    switch back to nvim-starter, this machine only
#
# Editing the url in .chezmoidata/common.toml is not enough on its own: a chezmoi
# git-repo external clones only when the target is absent, and otherwise pulls
# whatever remote the checkout already has. So this deletes the checkout to force a
# fresh clone, and passes --refresh-externals (refreshPeriod would otherwise skip
# the external entirely) and --force (the delete makes chezmoi prompt).
#
# "starter" writes nvimRepo into the chezmoi config, which overrides .chezmoidata
# and stays local to this machine. "config" removes it again.
#

set -eu

STARTER_URL="https://github.com/StephenGemin/nvim-starter"

# shellcheck source=scripts/logging.sh
source "$(dirname "${BASH_SOURCE[0]}")/logging.sh"

usage() {
  cat <<EOF
Usage: $0 [config|starter]

  (no args)   show which Neovim config is active
  config      switch to the repo default (nvim-config)
  starter     switch back to nvim-starter, this machine only

Options:
  -h, --help  Show this help message and exit
EOF
}

# chezmoi reports native paths; MSYS/git-bash needs POSIX ones for rm/git.
to_posix() {
  if command -v cygpath >/dev/null 2>&1; then
    cygpath -u "$1"
  else
    printf '%s\n' "$1"
  fi
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

action="${1:-status}"
case "$action" in
  status | config | starter) ;;
  *)
    usage >&2
    error "unknown action: $action"
    ;;
esac

command -v chezmoi >/dev/null 2>&1 || error "chezmoi not found on PATH"

# Mirrors the os conditional in .chezmoiexternal.toml, asked of chezmoi so the
# path is correct and native on every platform.
target_native="$(chezmoi execute-template \
  '{{ if eq .osid "windows" }}{{ joinPath .chezmoi.homeDir "AppData" "Local" "nvim" }}{{ else }}{{ joinPath .chezmoi.homeDir ".config" "nvim" }}{{ end }}')"
target="$(to_posix "$target_native")"
config_file="$(to_posix "$(chezmoi execute-template '{{ .chezmoi.configFile }}')")"

current_url() {
  git -C "$target" remote get-url origin 2>/dev/null || true
}

if [[ "$action" == "status" ]]; then
  url="$(current_url)"
  [[ -n "$url" ]] || error "no checkout at $target_native"
  log_info "$target_native -> $url"
  exit 0
fi

# Checked before anything is mutated, so bailing here leaves the machine untouched.
# Deleting a git checkout: refuse if it holds commits that exist nowhere else.
if [[ -d "$target/.git" ]]; then
  unpushed="$(git -C "$target" log --oneline '@{u}..' 2>/dev/null || true)"
  if [[ -n "$unpushed" ]]; then
    log_error "$target_native has commits not on its remote:"
    printf '%s\n' "$unpushed" >&2
    error "push or drop them first"
  fi
fi

# Line-oriented rather than a real TOML parse: chezmoi.toml is generated from
# .chezmoi.toml.tmpl, so nvimRepo only ever appears as one line under [data].
log_task "updating nvimRepo in $config_file"
tmp="$config_file.tmp.$$"
trap 'rm -f "$tmp"' EXIT
awk -v url="$([[ "$action" == "starter" ]] && printf '%s' "$STARTER_URL")" '
  /^[[:space:]]*nvimRepo[[:space:]]*=/ { next }
  { print }
  /^\[data\]/ && url != "" { printf "    nvimRepo = \"%s\"\n", url }
' "$config_file" >"$tmp"
mv "$tmp" "$config_file"
trap - EXIT

# Resolved only after the config edit: while the override is still in place,
# .nvimRepo reads back as the override itself, so "config" would see the machine
# as already correct and do nothing.
if [[ "$action" == "config" ]]; then
  desired="$(chezmoi execute-template '{{ .nvimRepo }}')"
else
  desired="$STARTER_URL"
fi

if [[ "$(current_url)" == "$desired" ]]; then
  success "already on $desired"
fi

log_task "removing $target_native"
rm -rf "$target"

log_task "re-cloning via chezmoi"
chezmoi apply --refresh-externals --force "$target_native"

actual="$(current_url)"
[[ "$actual" == "$desired" ]] || error "expected $desired, got ${actual:-nothing}"
success "$target_native -> $actual"
