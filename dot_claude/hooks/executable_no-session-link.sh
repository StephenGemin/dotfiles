#!/bin/bash
# PreToolUse hook (matcher: Bash). Blocks any git commit whose command string
# embeds a Claude session link. Only session URLs are forbidden; the
# Co-Authored-By trailer is allowed. Exit 2 blocks the call and stderr
# becomes the reason shown to Claude.
payload=$(cat)
case "$payload" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac
if printf '%s' "$payload" | grep -qE 'Claude-Session:|claude\.ai/code/session'; then
  echo "Blocked: commit message contains a Claude session link (Claude-Session: / claude.ai/code/session). Re-run the commit without it; the Co-Authored-By trailer is fine." >&2
  exit 2
fi
exit 0
