# dotfiles setup script
# With Developer Mode enabled, symlinks work without admin.
# If Developer Mode is off, the script will auto-elevate via gsudo.
#
# Usage:
#   cd D:\dotfiles
#   .\setup.ps1

$dotfiles = Split-Path -Parent $MyInvocation.MyCommand.Path

# ── Check if we can create symlinks ─────────────────────────────────────────
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$devModePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
$devModeEnabled = (Get-ItemProperty -Path $devModePath -Name AllowDevelopmentWithoutDevLicense -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense -eq 1

if (-not $isAdmin -and -not $devModeEnabled) {
    Write-Host "Neither admin nor Developer Mode detected. Elevating via gsudo..." -ForegroundColor Yellow
    gsudo -- pwsh -File "$dotfiles\setup.ps1"
    exit $LASTEXITCODE
}

function New-Symlink($target, $link) {
    if (Test-Path $link -PathType Leaf) {
        $item = Get-Item $link -Force
        if ($item.LinkType -eq "SymbolicLink") {
            Write-Host "  already linked: $link" -ForegroundColor DarkGray
            return
        }
        $backup = "$link.bak"
        Move-Item $link $backup -Force
        Write-Host "  backed up: $link -> $backup" -ForegroundColor Yellow
    }
    $parentDir = Split-Path $link
    if (!(Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }
    New-Item -ItemType SymbolicLink -Path $link -Target $target -Force -ErrorAction Stop | Out-Null
    Write-Host "  linked: $link" -ForegroundColor Green
}

function New-DirSymlink($target, $link) {
    if (Test-Path $link) {
        $item = Get-Item $link -Force
        if ($item.LinkType -eq "SymbolicLink") {
            Write-Host "  already linked: $link" -ForegroundColor DarkGray
            return
        }
        $backup = "$link.bak"
        Move-Item $link $backup -Force
        Write-Host "  backed up: $link -> $backup" -ForegroundColor Yellow
    }
    $parentDir = Split-Path $link
    if (!(Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }
    New-Item -ItemType SymbolicLink -Path $link -Target $target -Force -ErrorAction Stop | Out-Null
    Write-Host "  linked: $link" -ForegroundColor Green
}

Write-Host "`n=== dotfiles setup ===" -ForegroundColor Cyan

# PowerShell 7 profile
$psProfile = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
New-Symlink "$dotfiles\powershell\Microsoft.PowerShell_profile.ps1" $psProfile

# Windows Terminal settings
$wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
New-Symlink "$dotfiles\terminal\settings.json" $wtSettings

# Claude Code skills (user-created only)
$claudeSkillDotfiles = "$env:USERPROFILE\.claude\skills\dotfiles"
New-DirSymlink "$dotfiles\claude\skills\dotfiles" $claudeSkillDotfiles

$claudeSkillCreator = "$env:USERPROFILE\.claude\skills\skill-creator"
New-DirSymlink "$dotfiles\claude\skills\skill-creator" $claudeSkillCreator

$claudeSkillLearnerCreator = "$env:USERPROFILE\.claude\skills\project-learner-creator"
New-DirSymlink "$dotfiles\claude\skills\project-learner-creator" $claudeSkillLearnerCreator

$claudeSkillPreviewCreator = "$env:USERPROFILE\.claude\skills\project-preview-creator"
New-DirSymlink "$dotfiles\claude\skills\project-preview-creator" $claudeSkillPreviewCreator

$claudeSkillInterviewCreator = "$env:USERPROFILE\.claude\skills\interview-prep-creator"
New-DirSymlink "$dotfiles\claude\skills\interview-prep-creator" $claudeSkillInterviewCreator

Write-Host "`nDone! Restart your terminal to apply changes.`n" -ForegroundColor Cyan
