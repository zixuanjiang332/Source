$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$python = "python"

Push-Location $root
try {
  & $python ".\tools\build_player_yuan_runtime_from_fist_pass.py"

  $playerScene = Join-Path $root "scenes\player\Player.tscn"
  $sceneText = Get-Content -LiteralPath $playerScene -Raw
  $sceneText = $sceneText -replace 'res://resources/characters/player_yuan_early_clone_frames.tres', 'res://resources/characters/player_yuan_runtime_frames.tres'
  [System.IO.File]::WriteAllText(
    $playerScene,
    $sceneText,
    [System.Text.UTF8Encoding]::new($false)
  )

  $obsoleteFramePatterns = @(
    "atk_1_*.png",
    "atk_1_*.png.import",
    "atk_2_*.png",
    "atk_2_*.png.import",
    "atk_3_*.png",
    "atk_3_*.png.import",
    "skill_*.png",
    "skill_*.png.import"
  )

  $legacyFrameDir = Join-Path $root "assets\pixel\characters\player_yuan_early_clone\frames"
  foreach ($pattern in $obsoleteFramePatterns) {
    Get-ChildItem -LiteralPath $legacyFrameDir -Filter $pattern -ErrorAction SilentlyContinue | Remove-Item -Force
  }

  Write-Host "Deployed Yuan fist pass runtime set."
  Write-Host "Player scene now points to res://resources/characters/player_yuan_runtime_frames.tres"
} finally {
  Pop-Location
}
