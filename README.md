# dotfiles

Windows Terminal + PowerShell 7 configuration.

## Dependencies

| 工具 | 用途 | 安装方式 |
|---|---|---|
| [PowerShell 7](https://github.com/PowerShell/PowerShell) | Shell | `winget install Microsoft.PowerShell` |
| [Windows Terminal](https://github.com/microsoft/terminal) | 终端模拟器 | `winget install Microsoft.WindowsTerminal` |
| [oh-my-posh](https://ohmyposh.dev) | Prompt 渲染引擎 | `winget install JanDeDobbeleer.OhMyPosh` |
| [JetBrainsMono NF](https://www.nerdfonts.com) | Nerd Font（图标字体） | `oh-my-posh font install JetBrainsMono` |
| [gsudo](https://github.com/gerardog/gsudo) | sudo for Windows（单命令提权） | `winget install gerardog.gsudo` |

**oh-my-posh 主题**：`paradox`（路径 `$env:POSH_THEMES_PATH/paradox.omp.json`）

## 安装流程（新机器）

```powershell
# 1. 克隆仓库
git clone https://github.com/<your-username>/dotfiles.git D:\dotfiles
cd D:\dotfiles

# 2. 安装依赖 + 开启开发者模式（UAC 弹窗确认一次）
.\bootstrap.ps1

# 3. 创建符号链接（开发者模式下无需管理员）
.\setup.ps1
```

> **提权策略**：`bootstrap.ps1` 会通过 gsudo 开启 Windows 开发者模式，
> 之后创建符号链接不再需要管理员权限。字体安装等少数操作仍通过 gsudo 按需提权。

## 文件结构

```
dotfiles/
├── powershell/
│   └── Microsoft.PowerShell_profile.ps1   # $PROFILE
├── terminal/
│   └── settings.json                       # Windows Terminal 配置
├── frp/
│   ├── frpc.toml.example                   # frp 客户端配置模板
│   ├── frpc.ps1                            # frp 客户端启停 + 开机自启 (Windows)
│   ├── frps.toml.example                   # frp 服务端配置模板
│   └── frps.sh                             # frp 服务端启停 + systemd (Linux)
├── bootstrap.ps1                           # 安装依赖 + gsudo + 开发者模式
└── setup.ps1                               # 创建符号链接（自动提权）
```

## 日常同步

```powershell
# 推送更新
cd D:\dotfiles
git add .
git commit -m "update: ..."
git push

# 拉取更新（另一台机器）
cd D:\dotfiles
git pull
```
