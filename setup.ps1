# dotfiles setup script
# Run as Administrator in PowerShell 7:
#   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
#   .\setup.ps1

$dotfiles = Split-Path -Parent $MyInvocation.MyCommand.Path

function New-Symlink($target, $link) {
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
    New-Item -ItemType SymbolicLink -Path $link -Target $target -Force | Out-Null
    Write-Host "  linked: $link" -ForegroundColor Green
}

Write-Host "`n=== dotfiles setup ===" -ForegroundColor Cyan

# PowerShell 7 profile
$psProfile = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
New-Symlink "$dotfiles\powershell\Microsoft.PowerShell_profile.ps1" $psProfile

# Windows Terminal settings
$wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
New-Symlink "$dotfiles\terminal\settings.json" $wtSettings

Write-Host "`nDone! Restart your terminal to apply changes.`n" -ForegroundColor Cyan
