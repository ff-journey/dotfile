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
Install-WingetPackage "gerardog.gsudo"              "gsudo (sudo for Windows)"

# ── Enable Developer Mode (allows symlinks without admin) ───────────────────
$devModePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
$devModeEnabled = (Get-ItemProperty -Path $devModePath -Name AllowDevelopmentWithoutDevLicense -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense -eq 1
if ($devModeEnabled) {
    Write-Host "  already enabled: Developer Mode" -ForegroundColor DarkGray
} else {
    Write-Host "  enabling: Developer Mode (requires admin for one-time registry write) ..." -ForegroundColor Yellow
    gsudo {
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v AllowDevelopmentWithoutDevLicense /d 1
    }
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Developer Mode enabled." -ForegroundColor Green
    } else {
        Write-Host "  Failed to enable Developer Mode. You can enable it manually:" -ForegroundColor Red
        Write-Host "    Settings -> System -> For developers -> Developer Mode" -ForegroundColor Yellow
    }
}

# ── Nerd Font (JetBrainsMono) ────────────────────────────────────────────────
# oh-my-posh can install fonts directly (requires admin for system-wide install)
$fontInstalled = [System.Drawing.Text.InstalledFontCollection]::new().Families | Where-Object { $_.Name -like "*JetBrainsMono*" }
if ($fontInstalled) {
    Write-Host "  already installed: JetBrainsMono Nerd Font" -ForegroundColor DarkGray
} else {
    Write-Host "  installing: JetBrainsMono Nerd Font (elevating via gsudo) ..." -ForegroundColor Yellow
    gsudo -- oh-my-posh font install JetBrainsMono
}

Write-Host "`nAll dependencies installed." -ForegroundColor Green
Write-Host "Next: run .\setup.ps1 to create symlinks (no admin needed with Developer Mode).`n" -ForegroundColor Cyan
