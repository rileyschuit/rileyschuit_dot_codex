#!/usr/bin/env bash
# Commit and push the portable Codex profile and history. Safe to run by hand.
set -uo pipefail

profile_dir="${HOME}/.codex"
log_file="${profile_dir}/scripts/sync.log"

log() {
  printf '%s  %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >>"${log_file}"
}

cd "${profile_dir}" || {
  log "PUSH FAILED (cannot cd to ${profile_dir})"
  exit 1
}

log "PUSH start"

if [ -z "$(git status --porcelain)" ]; then
  log "nothing to push"
  exit 0
fi

git add -A
if ! git diff --cached --quiet; then
  git commit -m "sync $(date '+%Y-%m-%d %H:%M')" >/dev/null || {
    log "PUSH FAILED (commit failed)"
    exit 1
  }
fi

if git push; then
  log "PUSH done"
else
  log "PUSH FAILED (push failed)"
  exit 1
fi
