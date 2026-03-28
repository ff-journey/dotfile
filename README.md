# dotfiles

Windows Terminal + PowerShell 7 configuration.

## Dependencies

| 工具 | 用途 | 安装方式 |
|---|---|---|
| [PowerShell 7](https://github.com/PowerShell/PowerShell) | Shell | `winget install Microsoft.PowerShell` |
| [Windows Terminal](https://github.com/microsoft/terminal) | 终端模拟器 | `winget install Microsoft.WindowsTerminal` |
| [oh-my-posh](https://ohmyposh.dev) | Prompt 渲染引擎 | `winget install JanDeDobbeleer.OhMyPosh` |
| [JetBrainsMono NF](https://www.nerdfonts.com) | Nerd Font（图标字体） | `oh-my-posh font install JetBrainsMono` |

**oh-my-posh 主题**：`paradox`（路径 `$env:POSH_THEMES_PATH/paradox.omp.json`）

## 安装流程（新机器）

```powershell
# 1. 克隆仓库
git clone https://github.com/<your-username>/dotfiles.git D:\dotfiles
cd D:\dotfiles

# 2. 安装依赖（普通用户权限）
.\bootstrap.ps1

# 3. 创建符号链接（需要管理员）
#    右键 Windows Terminal -> "以管理员身份运行"
.\setup.ps1
```

## 文件结构

```
dotfiles/
├── powershell/
│   └── Microsoft.PowerShell_profile.ps1   # $PROFILE
├── terminal/
│   └── settings.json                       # Windows Terminal 配置
├── bootstrap.ps1                           # 安装依赖
└── setup.ps1                               # 创建符号链接
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
