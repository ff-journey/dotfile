# ECS Server

Aliyun/Tencent ECS used for frp server and other remote services.

## Connection

| Field | Value |
|-------|-------|
| Host | `1.14.109.188` |
| User | `root` |
| Key  | `C:\Users\Admin\.ssh\id_ed25519_github` |

## SSH one-liner

```bash
ssh -i ~/.ssh/id_ed25519_github root@1.14.109.188
```

PowerShell / cmd:

```powershell
ssh -i C:\Users\Admin\.ssh\id_ed25519_github root@1.14.109.188
```

## Run remote command

```bash
ssh -i ~/.ssh/id_ed25519_github root@1.14.109.188 '<command>'
```

Example — start frps remotely:

```bash
ssh -i ~/.ssh/id_ed25519_github root@1.14.109.188 'bash /opt/frp/frps.sh start'
```

## Notes

- frps config lives at `/opt/frp/frps.toml` on the server (managed manually, not via dotfiles).
- See [frp.md](frp.md) for frps start/stop commands.
- Server is Tencent Cloud (hostname `VM-0-15-opencloudos`, OS: OpenCloudOS / Linux 6.6).

## Gotcha: key file has CRLF line endings

`C:\Users\Admin\.ssh\id_ed25519_github` is stored with CRLF endings, so OpenSSH
(Git Bash / MSYS) fails to parse it with `Load key ...: invalid format` →
`Permission denied (publickey)`.

Workaround from Git Bash — use a LF-normalized temp copy:

```bash
tr -d '\r' < ~/.ssh/id_ed25519_github > /tmp/ecs_key && chmod 600 /tmp/ecs_key
ssh -i /tmp/ecs_key root@1.14.109.188 '<command>'
rm -f /tmp/ecs_key
```

Windows-native `ssh.exe` (PowerShell / cmd) handles CRLF fine, so the plain
`ssh -i C:\Users\Admin\.ssh\id_ed25519_github root@1.14.109.188` form works there.
