# dotfiles setup script
# Must run as Administrator:
#   Right-click Windows Terminal -> "Run as administrator"
#   Then: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
#         cd D:\dotfiles  (or wherever you cloned)
#         .\setup.ps1

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Please run this script as Administrator." -ForegroundColor Red
    exit 1
}

$dotfiles = Split-Path -Parent $MyInvocation.MyCommand.Path

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

Write-Host "`nDone! Restart your terminal to apply changes.`n" -ForegroundColor Cyan
