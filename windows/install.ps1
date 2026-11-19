#Requires -RunAsAdministrator
$ErrorActionPreference = "Stop"

# 1. Enable Windows Long Paths (recommended by Komorebi)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1

# 2. Install Komorebi, whkd, and AutoHotkey via winget
winget install -e --id LGUG2Z.komorebi --accept-source-agreements --accept-package-agreements
winget install -e --id LGUG2Z.whkd --accept-source-agreements --accept-package-agreements
winget install -e --id AutoHotkey.AutoHotkey --accept-source-agreements --accept-package-agreements

# Refresh PATH in the current session
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# 3. Copy dotfiles, icons, and tray script to $USERPROFILE
$RepoRoot = $PSScriptRoot
$UserHome = $env:USERPROFILE
$ConfigDir = Join-Path $UserHome ".config"

New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null

if (Test-Path (Join-Path $RepoRoot "komorebi.json")) {
    Copy-Item -Path (Join-Path $RepoRoot "komorebi.json") -Destination (Join-Path $UserHome "komorebi.json") -Force
}

if (Test-Path (Join-Path $RepoRoot "whkdrc")) {
    Copy-Item -Path (Join-Path $RepoRoot "whkdrc") -Destination (Join-Path $ConfigDir "whkdrc") -Force
}

if (Test-Path (Join-Path $RepoRoot "komorebi_icons")) {
    Copy-Item -Path (Join-Path $RepoRoot "komorebi_icons") -Destination (Join-Path $UserHome "komorebi_icons") -Recurse -Force
}

# Supports either a folder named komorebi_ws_tray or a .ahk file in the repo root
$TrayFolder = Join-Path $RepoRoot "komorebi_ws_tray"
$TrayScript = Join-Path $RepoRoot "komorebi_ws_tray.ahk"
$DestTrayScript = Join-Path $UserHome "komorebi_ws_tray.ahk"

if (Test-Path $TrayFolder) {
    Copy-Item -Path $TrayFolder -Destination (Join-Path $UserHome "komorebi_ws_tray") -Recurse -Force
    $insideScript = Get-ChildItem -Path (Join-Path $UserHome "komorebi_ws_tray") -Filter "*.ahk" | Select-Object -First 1
    if ($insideScript) { $DestTrayScript = $insideScript.FullName }
} elseif (Test-Path $TrayScript) {
    Copy-Item -Path $TrayScript -Destination $DestTrayScript -Force
}

# 4. Generate default applications.json if not already present
if (-not (Test-Path (Join-Path $UserHome "applications.json"))) {
    komorebic fetch-asc
}

# 5. Start Komorebi, whkd, and the AHK tray script
komorebic stop --whkd 2>$null
komorebic start --whkd

if (Test-Path $DestTrayScript) {
    Start-Process -FilePath $DestTrayScript
}