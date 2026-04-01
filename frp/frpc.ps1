# frpc.ps1 — frp client: start/stop with optional auto-start
# Usage: .\frpc.ps1 start | stop
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("start", "stop")]
    [string]$Action
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigFile = "$ScriptDir\frpc.toml"
$PidFile    = "$ScriptDir\frpc.pid"
$LogFile    = "$ScriptDir\frpc.log"
$ErrLog     = "$ScriptDir\frpc-err.log"
$TaskName   = "frpc-dotfiles"

# ── Locate frpc binary ──────────────────────────────────────────────────────
$FrpcBin = Get-Command frpc -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if (-not $FrpcBin) {
    # fallback: common install locations
    $candidates = @(
        "$env:ProgramFiles\frp\frpc.exe",
        "$env:LOCALAPPDATA\frp\frpc.exe"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { $FrpcBin = $c; break }
    }
}
if (-not $FrpcBin) {
    Write-Host "ERROR: frpc binary not found. Install frp or add it to PATH." -ForegroundColor Red
    exit 1
}

# ── Check config ─────────────────────────────────────────────────────────────
if (-not (Test-Path $ConfigFile)) {
    Write-Host "ERROR: $ConfigFile not found." -ForegroundColor Red
    Write-Host "  Copy frpc.toml.example to frpc.toml and fill in auth.token" -ForegroundColor Yellow
    exit 1
}

switch ($Action) {
    "start" {
        # Check if already running
        if (Test-Path $PidFile) {
            $procId = Get-Content $PidFile
            $proc = Get-Process -Id $procId -ErrorAction SilentlyContinue
            if ($proc) {
                Write-Host "frpc is already running (PID: $procId)" -ForegroundColor DarkGray
                exit 0
            }
            Remove-Item $PidFile -Force
        }

        Write-Host "Starting frpc..." -ForegroundColor Cyan
        $proc = Start-Process -FilePath $FrpcBin `
            -ArgumentList "-c", $ConfigFile `
            -RedirectStandardOutput $LogFile `
            -RedirectStandardError $ErrLog `
            -NoNewWindow -PassThru
        $proc.Id | Set-Content $PidFile
        Write-Host "  frpc started (PID: $($proc.Id))" -ForegroundColor Green

        # ── Register scheduled task for auto-start ───────────────────────
        $existing = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        if (-not $existing) {
            Write-Host "  Registering auto-start task '$TaskName'..." -ForegroundColor Cyan
            $action = New-ScheduledTaskAction `
                -Execute "pwsh.exe" `
                -Argument "-NoProfile -File `"$ScriptDir\frpc.ps1`" start" `
                -WorkingDirectory $ScriptDir
            $trigger = New-ScheduledTaskTrigger -AtLogon
            $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
            gsudo -- pwsh -Command {
                param($TaskName, $action, $trigger, $settings)
                Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -RunLevel Highest -Force | Out-Null
            } -args $TaskName, $action, $trigger, $settings
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  Auto-start registered." -ForegroundColor Green
            } else {
                Write-Host "  Failed to register auto-start. You can do it manually via Task Scheduler." -ForegroundColor Yellow
            }
        } else {
            Write-Host "  Auto-start task already exists." -ForegroundColor DarkGray
        }
    }

    "stop" {
        # Stop the process
        if (Test-Path $PidFile) {
            $procId = Get-Content $PidFile
            $proc = Get-Process -Id $procId -ErrorAction SilentlyContinue
            if ($proc) {
                Write-Host "Stopping frpc (PID: $procId)..." -ForegroundColor Cyan
                Stop-Process -Id $procId -Force
                Write-Host "  frpc stopped." -ForegroundColor Green
            } else {
                Write-Host "  Process $procId not running." -ForegroundColor DarkGray
            }
            Remove-Item $PidFile -Force
        } else {
            Write-Host "  frpc is not running." -ForegroundColor DarkGray
        }

        # Remove scheduled task
        $existing = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        if ($existing) {
            Write-Host "  Removing auto-start task '$TaskName'..." -ForegroundColor Cyan
            gsudo -- pwsh -Command {
                param($TaskName)
                Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
            } -args $TaskName
            Write-Host "  Auto-start removed." -ForegroundColor Green
        }
    }
}
