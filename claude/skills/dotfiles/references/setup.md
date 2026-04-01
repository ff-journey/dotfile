# Setup & Maintenance

All commands use `$DOTFILES` (see SKILL.md for resolution).

## First-time setup on new machine

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

## Record a newly installed tool

Add to `bootstrap.ps1` under `# ── Core tools ──`:

```powershell
Install-WingetPackage "<winget-id>" "<display-name>"
```

Find winget ID: `winget search <tool-name>`

Then commit via `terminal push`.

## Privilege Escalation

Two-layer approach:

1. **Developer Mode** — enabled once via `bootstrap.ps1` (gsudo triggers UAC). Symlinks work without admin after this.
2. **gsudo** — `winget install gerardog.gsudo`. Elevates single commands with UAC prompt.

When Claude Code hits "access denied":
- Prefix with `gsudo` or `gsudo -- <command>`.

## Tracked Files

| File | Purpose |
|------|---------|
| `powershell/Microsoft.PowerShell_profile.ps1` | Symlinked from `$PROFILE` |
| `terminal/settings.json` | Symlinked from Windows Terminal settings |
| `bootstrap.ps1` | Dependency installer (winget + gsudo + Developer Mode) |
| `setup.ps1` | Symlink creator (auto-elevates if needed) |
| `frp/frpc.toml.example` | frp client config template |
| `frp/frpc.ps1` | frp client start/stop (Windows) |
| `frp/frps.sh` | frp server start/stop (deploy to ECS `/opt/frp/`) |

## Notes

- `terminal/settings.json` contains Anaconda paths with `D:\conda` — may differ on other machines
- gsudo caches credentials briefly — multiple elevated commands only prompt UAC once
- `frpc.toml` is gitignored (secrets). Only `.example` file tracked
- ECS frps config managed manually at `/opt/frp/frps.toml`, not via dotfiles
- Runtime files (`.pid`, `.log`) also gitignored
