# OpenCode CLI Server Manager
$env:OPENCODE_SERVER_USERNAME = "opencode"
$env:OPENCODE_SERVER_PASSWORD = "b9ndit"
$env:OPENCODE_SERVER_PORT = "4096"
$env:OPENCODE_SERVER_HOSTNAME = "0.0.0.0"
$env:PATH = "C:\Users\chenbingzhi\.local\bin;C:\Users\chenbingzhi\.bun\bin;$env:PATH"

function Get-ServerStatus {
    $procs = Get-Process -Name "opencode" -ErrorAction SilentlyContinue
    if ($procs) { return $true } else { return $false }
}

function Start-Server {
    if (Get-ServerStatus) {
        Write-Host "[!] Server is already running." -ForegroundColor Yellow
        return
    }

    $script = @"
`$env:OPENCODE_SERVER_USERNAME='$env:OPENCODE_SERVER_USERNAME'
`$env:OPENCODE_SERVER_PASSWORD='$env:OPENCODE_SERVER_PASSWORD'
`$env:OPENCODE_SERVER_PORT='$env:OPENCODE_SERVER_PORT'
`$env:OPENCODE_SERVER_HOSTNAME='$env:OPENCODE_SERVER_HOSTNAME'
`$env:PATH='$env:PATH'
opencode serve
"@

    $tmp = Join-Path $env:TEMP "opencode-server.ps1"
    $script | Set-Content -Encoding UTF8 $tmp

    Start-Process powershell.exe `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$tmp`"" `
        -WindowStyle Hidden

    Start-Sleep 2

    if (Get-ServerStatus) {
        Write-Host "[OK] Server started on ${env:OPENCODE_SERVER_HOSTNAME}:${env:OPENCODE_SERVER_PORT}" -ForegroundColor Green
    }
    else {
        Write-Host "[FAIL] Failed to start server." -ForegroundColor Red
    }
}

function Stop-Server {
    if (-not (Get-ServerStatus)) {
        Write-Host "[!] Server is not running." -ForegroundColor Yellow
        return
    }
    Stop-Process -Name "opencode" -Force
    Start-Sleep -Seconds 1
    if (-not (Get-ServerStatus)) {
        Write-Host "[OK] Server stopped." -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Failed to stop server." -ForegroundColor Red
    }
}

function Restart-Server {
    Stop-Server
    Start-Sleep -Seconds 1
    Start-Server
}

# Main
$isRunning = Get-ServerStatus

Write-Host ""
Write-Host "==============================" -ForegroundColor Cyan
Write-Host "  OpenCode CLI Server Manager" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host ""
if ($isRunning) {
    Write-Host "[Status] Running" -ForegroundColor Green
} else {
    Write-Host "[Status] Stopped" -ForegroundColor Red
}
Write-Host ""
Write-Host "  1. $(if ($isRunning) { 'Restart' } else { 'Start' })"
Write-Host "  2. Stop"
Write-Host "  3. Exit"
Write-Host ""

$choice = Read-Host "Select [1-3]"

switch ($choice) {
    "1" { if ($isRunning) { Restart-Server } else { Start-Server } }
    "2" { Stop-Server }
    "3" { }
    default { Write-Host "Invalid option." -ForegroundColor Red }
}

Write-Host ""
Read-Host "Press Enter to close"
