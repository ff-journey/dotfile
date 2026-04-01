# 检查依赖和符号链接状态
Write-Host "=== 依赖检查 ===" -ForegroundColor Cyan

$tools = @(
    @{id="Microsoft.PowerShell"; name="PowerShell 7"},
    @{id="Microsoft.WindowsTerminal"; name="Windows Terminal"},
    @{id="JanDeDobbeleer.OhMyPosh"; name="oh-my-posh"}
)
foreach ($t in $tools) {
    $r = winget list --id $t.id --accept-source-agreements 2>&1 | Select-String $t.id
    if ($r) { Write-Host "  [OK] $($t.name)" -ForegroundColor Green }
    else     { Write-Host "  [--] $($t.name) NOT installed" -ForegroundColor Yellow }
}

Write-Host "`n=== 字体检查 ===" -ForegroundColor Cyan
$font = [System.Drawing.Text.InstalledFontCollection]::new().Families | Where-Object { $_.Name -like "*JetBrainsMono*" }
if ($font) { Write-Host "  [OK] JetBrainsMono Nerd Font" -ForegroundColor Green }
else        { Write-Host "  [--] JetBrainsMono NOT installed" -ForegroundColor Yellow }

Write-Host "`n=== 符号链接检查 ===" -ForegroundColor Cyan
$psProfile = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
$wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

foreach ($path in @($psProfile, $wtSettings)) {
    if (Test-Path $path -PathType Leaf) {
        $item = Get-Item $path -Force
        Write-Host "  [OK] $path (LinkType=$($item.LinkType))" -ForegroundColor Green
    } else {
        Write-Host "  [--] NOT found: $path" -ForegroundColor Yellow
    }
}
