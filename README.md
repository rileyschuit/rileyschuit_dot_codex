# Codex profile backup

This private repository backs up the portable parts of the local Codex profile,
including configuration and conversation history.

## What is backed up

- `config.toml`, hooks, and the Herdr session helper
- Codex conversation history, archived sessions, and session indexes
- Local goals, memories, queues, and other SQLite-backed recoverable state
- Desktop preferences and project trust records

## What is intentionally not backed up

- `auth.json` — contains the Codex login credential; sign in again after a restore
- Downloaded plugin and marketplace caches — Codex recreates them
- Generated application-server binaries — they are machine-specific and exceed
  GitHub's file-size limit
- IPC files, transient shell snapshots, and other caches

## Restore on a new or rebuilt machine

1. Install the Codex desktop app or CLI, then start it once and close it. This
   installs the runtime files that are deliberately not stored here.
2. Preserve the freshly-created profile and clone this repository in its place:

   ```bash
   mv ~/.codex ~/.codex.before-restore
   git clone git@github.com:rileyschuit/rileyschuit_dot_codex.git ~/.codex
   ```

3. Start Codex and sign in again. The login credential is never stored in Git.
4. Let Codex recreate its bundled marketplaces and caches. The ECC marketplace
   and `ecc@ecc` plugin are declared in `config.toml`; if it is not restored
   automatically, run:

   ```bash
   codex plugin marketplace add affaan-m/ECC
   codex plugin add ecc@ecc
   ```

5. Confirm the profile and plugins:

   ```bash
   codex plugin list
   ```

If the restore is successful, remove `~/.codex.before-restore` after you have
confirmed your history and settings are present.

## Nightly backup

`codex-push.timer` runs every night at midnight and commits then pushes any
changed tracked profile or history files. `Persistent=true` means systemd runs a
missed backup shortly after the next user login.

Check it with:

```bash
systemctl --user status codex-push.timer
journalctl --user -u codex-push.service
```

## Manual backup

Review and push changes whenever you want to snapshot new history:

```bash
cd ~/.codex
git status
git add -A
git commit -m "Back up Codex profile"
git push
```

The `.gitignore` is an allowlist: it retains the recoverable profile and history
while keeping credentials and generated runtime data out of Git.
