# frp Management

All commands use `$DOTFILES` (see SKILL.md for resolution).

## Prerequisites — Install frp

Before any frp command, check that the binary exists. If not, guide installation:

### Windows (frpc)

```powershell
# Option 1: scoop
scoop install frp

# Option 2: manual — download from https://github.com/fatedier/frp/releases (windows_amd64.zip)
# Place frpc.exe in PATH or one of:
#   $env:ProgramFiles\frp\frpc.exe
#   $env:LOCALAPPDATA\frp\frpc.exe
#   G:\tool\frp\frp_0.68.0_windows_amd64\frpc.exe  (home PC)
```

### Linux (frps)

```bash
# Option 1: package manager (Arch: pacman -S frp)

# Option 2: download binary
curl -Lo /tmp/frp.tar.gz https://github.com/fatedier/frp/releases/latest/download/frp_0.68.0_linux_amd64.tar.gz
tar -xzf /tmp/frp.tar.gz -C /tmp
sudo cp /tmp/frp_*/frps /usr/local/bin/
sudo chmod +x /usr/local/bin/frps
```

## frpc start

1. Check `$DOTFILES/frp/frpc.toml` exists. If not:
   - Copy `frpc.toml.example` → `frpc.toml`
   - Prompt user to fill in `auth.token`
2. Run:
```powershell
pwsh -File $DOTFILES/frp/frpc.ps1 start
```
This starts frpc AND registers a Windows Scheduled Task for auto-start (UAC via gsudo).

To stop and remove auto-start:
```powershell
pwsh -File $DOTFILES/frp/frpc.ps1 stop
```

## frps start

ECS server frp directory: `/opt/frp/` (config managed manually on the server, NOT via dotfiles).

1. Run:
```bash
bash /opt/frp/frps.sh start
```
This starts frps with `/opt/frp/frps.toml` and creates a systemd service for auto-start.

To stop and remove service:
```bash
bash /opt/frp/frps.sh stop
```

## frpc add

1. Read `$DOTFILES/frp/frpc.toml`.
2. Append:
```toml
[[proxies]]
name = "<service-name>"
type = "tcp"
localIP = "127.0.0.1"
localPort = <local-port>
remotePort = <remote-port>
```
3. Also update `frpc.toml.example` (keep token as `CHANGE_ME`).
4. If frpc is running, remind user to restart:
```powershell
pwsh -File $DOTFILES/frp/frpc.ps1 stop
pwsh -File $DOTFILES/frp/frpc.ps1 start
```

