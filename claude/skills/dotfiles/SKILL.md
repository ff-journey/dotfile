---
name: dotfiles
description: >-
  Manage dotfiles repo (Windows Terminal + PowerShell 7 config sync).
  Use when user wants to sync/push terminal or shell config changes to git,
  pull terminal config updates on home machine, record a newly installed CLI
  tool into bootstrap.ps1, or set up dotfiles on a new machine.
  Triggers on phrases like 同步terminal配置, 同步命令行配置, 同步shell配置,
  更新terminal配置, 记录命令行工具, push dotfiles, pull dotfiles,
  装了新命令行工具, dotfiles, PowerShell配置同步, 终端配置同步.
---

# Dotfiles Skill

## Repo Info

- **Work machine**: `D:\dotfiles`
- **Home machine**: wherever cloned (ask if unknown)
- **Remote**: `https://github.com/ff-journey/dotfile.git`
- **Tracked files**:
  - `powershell/Microsoft.PowerShell_profile.ps1` ← symlinked from `$PROFILE`
  - `terminal/settings.json` ← symlinked from Windows Terminal settings
  - `bootstrap.ps1` ← dependency installer (winget + gsudo + Developer Mode)
  - `setup.ps1` ← symlink creator (auto-elevates if needed)

## Privilege Escalation Strategy

The dotfiles use a two-layer approach to minimize admin interruptions:

1. **Developer Mode** — enabled once via `bootstrap.ps1` (gsudo triggers UAC).
   After this, symlink creation no longer needs admin.
2. **gsudo** — installed via winget. For the rare cases that still need admin
   (font install, registry writes), gsudo elevates a single command with a UAC
   prompt, so the whole terminal does NOT need to run as admin.

### When Claude Code needs admin

If a command fails with "access denied" or "requires elevation":
- Prefix the command with `gsudo` (or `gsudo -- <command>` for commands with flags).
- gsudo will show a UAC dialog to the user — this is the only manual step needed.

## Workflows

### 1. Sync config changes (push)

Run in dotfiles dir, show user what changed first:

```powershell
git -C D:\dotfiles status
git -C D:\dotfiles diff
```

Then commit and push:

```powershell
git -C D:\dotfiles add powershell/Microsoft.PowerShell_profile.ps1 terminal/settings.json
git -C D:\dotfiles commit -m "update: <brief description>"
git -C D:\dotfiles push
```

Only stage config files unless user also wants bootstrap/setup changes committed.

### 2. Pull updates (home machine)

```powershell
cd <dotfiles-dir>
git pull
```

Symlinks already point to repo files — no recreation needed. Remind user to restart terminal.

### 3. Record a newly installed tool

Add a line to `bootstrap.ps1` under the `# ── Core tools ──` section:

```powershell
Install-WingetPackage "<winget-id>" "<display-name>"
```

Find winget ID if unknown:
```powershell
winget search <tool-name>
```

Then commit:
```powershell
git -C D:\dotfiles add bootstrap.ps1
git -C D:\dotfiles commit -m "add: <tool-name> to bootstrap"
git -C D:\dotfiles push
```

### 4. First-time setup on new machine

```powershell
git clone https://github.com/ff-journey/dotfile.git <target-dir>
cd <target-dir>
.\bootstrap.ps1          # installs deps, gsudo, enables Developer Mode (UAC once)
.\setup.ps1              # creates symlinks (no admin needed after Developer Mode)
```

## Notes

- `bootstrap.ps1` is idempotent — safe to re-run
- `setup.ps1` auto-elevates via gsudo if Developer Mode is not enabled
- `terminal/settings.json` contains Anaconda paths with `D:\conda` — may differ on home machine, edit before push if needed
- gsudo caches credentials briefly — multiple elevated commands in quick succession only prompt UAC once
