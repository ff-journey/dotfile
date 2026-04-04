Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView  # 或者 InlineView
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -MaximumHistoryCount 10000
Set-PSReadLineOption -Colors @{
    Command   = 'Cyan'
    Parameter = 'DarkCyan'
    String    = 'Green'
    Error     = 'Red'
}
Set-Alias ll Get-ChildItem
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/paradox.omp.json" | Invoke-Expression
oh-my-posh init pwsh | Invoke-Expression
function which($cmd) { Get-Command $cmd | Select-Object -ExpandProperty Source }
function grep { Select-String @args }

#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
If (Test-Path "G:\tool\conda\py310\Scripts\conda.exe") {
    (& "G:\tool\conda\py310\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
}
#endregion
