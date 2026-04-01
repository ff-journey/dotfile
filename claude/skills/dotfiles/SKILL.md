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

## Locating the Dotfiles Directory

**IMPORTANT**: Do NOT hardcode the dotfiles path. Resolve it dynamically:

On Windows (PowerShell / bash on Windows):
```powershell
# Follow the symlink from ~/.claude/skills/dotfiles to find the repo
$dotfilesDir = (Get-Item "$env:USERPROFILE\.claude\skills\dotfiles" -Force).Target | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
```

In bash:
```bash
DOTFILES_DIR="$(dirname "$(dirname "$(dirname "$(readlink -f "$HOME/.claude/skills/dotfiles")")")")"
```

The symlink `~/.claude/skills/dotfiles` → `<dotfiles-repo>/claude/skills/dotfiles/`,
so going up three levels gives the repo root.

Use the resolved path for ALL git commands and script invocations below.
In the workflow examples, `$DOTFILES` represents this resolved path.

## Repo Info

- **Remote**: `https://github.com/ff-journey/dotfile.git`
- **Tracked files**:
  - `powershell/Microsoft.PowerShell_profile.ps1` ← symlinked from `$PROFILE`
  - `terminal/settings.json` ← symlinked from Windows Terminal settings
  - `bootstrap.ps1` ← dependency installer (winget + gsudo + Developer Mode)
  - `setup.ps1` ← symlink creator (auto-elevates if needed)
  - `frp/frpc.toml.example` ← frp client config template
  - `frp/frpc.ps1` ← frp client start/stop script (Windows)
  - `frp/frps.toml.example` ← frp server config template
  - `frp/frps.sh` ← frp server start/stop script (Linux)

## Privilege Escalation Strategy

The dotfiles use a two-layer approach to minimize admin interruptions:

1. **Developer Mode** — enabled once via `bootstrap.ps1` (gsudo triggers UAC).
   After this, symlink creation no longer needs admin.
2. **gsudo** — installed via winget. For the rare cases that still need admin
   (font install, registry writes, scheduled tasks), gsudo elevates a single
   command with a UAC prompt, so the whole terminal does NOT need to run as admin.

### When Claude Code needs admin

If a command fails with "access denied" or "requires elevation":
- Prefix the command with `gsudo` (or `gsudo -- <command>` for commands with flags).
- gsudo will show a UAC dialog to the user — this is the only manual step needed.

## Workflows

### 1. terminal push — 推送本地最新改动到 git 仓库

Trigger: `terminal push`, `push dotfiles`, `同步terminal配置`

Steps:
1. Resolve `$DOTFILES` path (see "Locating the Dotfiles Directory").
2. Show what changed:
```bash
git -C $DOTFILES status
git -C $DOTFILES diff
```
3. Stage changed files, commit, and push:
```bash
git -C $DOTFILES add <changed-files>
git -C $DOTFILES commit -m "update: <brief description>"
git -C $DOTFILES push
```
Only stage files that actually have changes. Describe the changes in the commit message.

### 2. terminal pull — 拉取最新配置并执行配置脚本

Trigger: `terminal pull`, `pull dotfiles`, `拉取terminal配置`

Steps:
1. Resolve `$DOTFILES` path.
2. Pull latest from remote:
```bash
git -C $DOTFILES pull
```
3. Run bootstrap to ensure all dependencies are installed:
```powershell
pwsh -File $DOTFILES\bootstrap.ps1
```
4. Run setup to ensure all symlinks are in place:
```powershell
pwsh -File $DOTFILES\setup.ps1
```
5. Remind user to restart terminal to apply changes.

### 3. frpc start — 启动 frp 客户端并设置开机自启

Trigger: `frpc start`

Steps:
1. Resolve `$DOTFILES` path.
2. Check that `$DOTFILES/frp/frpc.toml` exists. If not, prompt user:
   - Copy `frpc.toml.example` to `frpc.toml`
   - Fill in `auth.token`
3. Run:
```powershell
pwsh -File $DOTFILES\frp\frpc.ps1 start
```
This starts frpc AND registers a Windows Scheduled Task for auto-start at logon (UAC via gsudo).

To stop and remove auto-start:
```powershell
pwsh -File $DOTFILES\frp\frpc.ps1 stop
```

### 4. frps start — 启动 frp 服务端并设置开机自启

Trigger: `frps start`

Steps:
1. Resolve `$DOTFILES` path (on the Linux server).
2. Check that `$DOTFILES/frp/frps.toml` exists. If not, prompt user:
   - Copy `frps.toml.example` to `frps.toml`
   - Fill in `auth.token`
3. Run:
```bash
bash $DOTFILES/frp/frps.sh start
```
This starts frps AND creates a systemd service for auto-start on boot.

To stop and remove auto-start:
```bash
bash $DOTFILES/frp/frps.sh stop
```

### 5. frpc add — 客户端增加端口映射

Trigger: `frpc add`, `frp 加端口`, `frp 增加映射`

Steps:
1. Resolve `$DOTFILES` path.
2. Read current `$DOTFILES/frp/frpc.toml`.
3. Append a new proxy block:
```toml
[[proxies]]
name = "<service-name>"
type = "tcp"
localIP = "127.0.0.1"
localPort = <local-port>
remotePort = <remote-port>
```
4. Also update `frpc.toml.example` with the same block (but keep token as CHANGE_ME).
5. If frpc is currently running, remind user to restart it for changes to take effect:
```powershell
pwsh -File $DOTFILES\frp\frpc.ps1 stop
pwsh -File $DOTFILES\frp\frpc.ps1 start
```

### 6. Record a newly installed tool

Add a line to `bootstrap.ps1` under the `# ── Core tools ──` section:

```powershell
Install-WingetPackage "<winget-id>" "<display-name>"
```

Find winget ID if unknown:
```powershell
winget search <tool-name>
```

Then commit via `terminal push`.

### 7. First-time setup on new machine

```powershell
git clone https://github.com/ff-journey/dotfile.git <target-dir>
cd <target-dir>
.\bootstrap.ps1          # installs deps, gsudo, enables Developer Mode (UAC once)
.\setup.ps1              # creates symlinks (no admin needed after Developer Mode)

# If using frp on this machine:
cp frp\frpc.toml.example frp\frpc.toml
# Edit frp\frpc.toml — fill in auth.token
.\frp\frpc.ps1 start     # starts frpc + registers auto-start
```

## Notes

- `bootstrap.ps1` is idempotent — safe to re-run
- `setup.ps1` auto-elevates via gsudo if Developer Mode is not enabled
- `terminal/settings.json` contains Anaconda paths with `D:\conda` — may differ on home machine, edit before push if needed
- gsudo caches credentials briefly — multiple elevated commands in quick succession only prompt UAC once
- `frp/frpc.toml` and `frp/frps.toml` are gitignored (contain secrets). Only `.example` files are tracked
- frp runtime files (`.pid`, `.log`) are also gitignored
