# bootstrap.ps1 — install all dependencies before running setup.ps1
# Run as normal user (winget does NOT need admin):
#   .\bootstrap.ps1

Write-Host "`n=== dotfiles bootstrap ===" -ForegroundColor Cyan

function Install-WingetPackage($id, $name) {
    $installed = winget list --id $id --accept-source-agreements 2>&1 | Select-String $id
    if ($installed) {
        Write-Host "  already installed: $name" -ForegroundColor DarkGray
    } else {
        Write-Host "  installing: $name ..." -ForegroundColor Yellow
        winget install --id $id --accept-source-agreements --accept-package-agreements -e
    }
}

# ── Core tools ──────────────────────────────────────────────────────────────
Install-WingetPackage "Microsoft.PowerShell"        "PowerShell 7"
Install-WingetPackage "Microsoft.WindowsTerminal"   "Windows Terminal"
Install-WingetPackage "JanDeDobbeleer.OhMyPosh"     "oh-my-posh"

# ── Nerd Font (JetBrainsMono) ────────────────────────────────────────────────
# oh-my-posh can install fonts directly (requires admin for system-wide install)
$fontInstalled = [System.Drawing.Text.InstalledFontCollection]::new().Families | Where-Object { $_.Name -like "*JetBrainsMono*" }
if ($fontInstalled) {
    Write-Host "  already installed: JetBrainsMono Nerd Font" -ForegroundColor DarkGray
} else {
    Write-Host "  installing: JetBrainsMono Nerd Font (requires admin) ..." -ForegroundColor Yellow
    oh-my-posh font install JetBrainsMono
}

Write-Host "`nAll dependencies installed." -ForegroundColor Green
Write-Host "Next: run .\setup.ps1 as Administrator to create symlinks.`n" -ForegroundColor Cyan
