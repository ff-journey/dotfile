---
name: dotfiles
description: >-
  Manage dotfiles repo (Windows Terminal + PowerShell 7 + frp config sync).
  Use when user wants to sync/push terminal or shell config changes to git,
  pull terminal config updates on home machine, record a newly installed CLI
  tool into bootstrap.ps1, set up dotfiles on a new machine,
  or manage frp client/server (start, stop, add proxy).
  Triggers on phrases like terminal push, terminal pull,
  frpc start, frpc stop, frpc add, frps start, frps stop,
  同步terminal配置, 同步命令行配置, 同步shell配置,
  更新terminal配置, 记录命令行工具, push dotfiles, pull dotfiles,
  装了新命令行工具, dotfiles, PowerShell配置同步, 终端配置同步.
---

# Dotfiles Skill

## Resolve $DOTFILES Path

**Never hardcode the dotfiles path.** Resolve dynamically:

```bash
DOTFILES="$(dirname "$(dirname "$(dirname "$(readlink -f "$HOME/.claude/skills/dotfiles")")")")"
```

The symlink `~/.claude/skills/dotfiles` → `<repo>/claude/skills/dotfiles/`, three levels up = repo root.

All commands below use `$DOTFILES` as the resolved path.

## Command Routing

| Command | Action | Reference |
|---------|--------|-----------|
| `terminal push` | Stage, commit, push config changes | [terminal-sync.md](references/terminal-sync.md) |
| `terminal pull` | Pull + run bootstrap + setup | [terminal-sync.md](references/terminal-sync.md) |
| `frpc start` | Start frp client + auto-start | [frp.md](references/frp.md) — "frpc start" |
| `frpc stop` | Stop frp client + remove auto-start | [frp.md](references/frp.md) — "frpc start" |
| `frpc add` | Add port mapping to frpc config | [frp.md](references/frp.md) — "frpc add" |
| `frps start` | Start frp server + systemd | [frp.md](references/frp.md) — "frps start" |
| `frps stop` | Stop frp server + remove service | [frp.md](references/frp.md) — "frps start" |
| Record new tool | Add to bootstrap.ps1 | [setup.md](references/setup.md) — "Record tool" |
| New machine setup | Clone + bootstrap + setup | [setup.md](references/setup.md) — "First-time setup" |

## Quick Reference

- **Remote**: `https://github.com/ff-journey/dotfile.git`
- **Privilege escalation**: gsudo for single-command elevation; Developer Mode for symlinks without admin
- **frp secrets**: `frpc.toml` / `frps.toml` are gitignored. Only `.example` files are tracked
- `bootstrap.ps1` is idempotent — safe to re-run
- `setup.ps1` auto-elevates via gsudo if Developer Mode is not enabled
