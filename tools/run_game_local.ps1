$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$candidates = @(
  "E:\Godot\Godot_v4.6.3-stable_win64.exe",
  "E:\Godot\Godot_v4.6.3-stable_win64_console.exe",
  "C:\Users\PC\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64.exe",
  "C:\Users\PC\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64_console.exe"
)

$godot = $candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $godot) {
  throw "Godot executable not found in known paths. Update tools/run_game_local.ps1 with your local install path."
}

Push-Location $root
try {
  & $godot --path .
} finally {
  Pop-Location
}
