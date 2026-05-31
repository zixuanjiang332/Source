$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$required = @(
  "project.godot",
  ".gitattributes",
  ".gitignore",
  "scenes/main/Main.tscn",
  "scenes/levels/DemoLevel.tscn",
  "scenes/player/Player.tscn",
  "scripts/core/GameEvents.gd",
  "scripts/combat/Hitbox.gd",
  "scripts/combat/Hurtbox.gd",
  "resources/characters/player_stats.tres",
  "resources/attacks/player_slash_1.tres",
  "resources/vfx/vfx_catalog.tres",
  "docs/GAME_FRAMEWORK.md",
  "docs/GITHUB_WORKFLOW.md",
  "docs/ART_BIBLE.md",
  "docs/PROGRAMMING_STANDARDS.md",
  "docs/PROGRAMMER_COLLABORATION.md",
  "docs/ASSET_HANDOFF.md",
  "docs/PIXEL_ART_PROMPT_GUIDE.md",
  "docs/VFX_PROMPT_GUIDE.md",
  "docs/AI_ASSET_POLICY.md"
)

$missing = @()
foreach ($path in $required) {
  $fullPath = Join-Path $root $path
  if (-not (Test-Path -LiteralPath $fullPath)) {
    $missing += $path
  }
}

if ($missing.Count -gt 0) {
  Write-Host "Missing required files:" -ForegroundColor Red
  $missing | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
  exit 1
}

$scanFiles = Get-ChildItem -Path $root -Recurse -File -Include *.tscn,*.tres,*.gd |
  Where-Object { $_.FullName -notmatch "\\.godot\\" -and $_.FullName -notmatch "\\.git\\" -and $_.FullName -notmatch "\\.codegraph\\" }

$brokenRefs = @()
foreach ($file in $scanFiles) {
  $content = Get-Content -LiteralPath $file.FullName -Raw
  $matches = [regex]::Matches($content, 'res://([^"\)]+)')
  foreach ($match in $matches) {
    $relative = $match.Groups[1].Value -replace '/', [IO.Path]::DirectorySeparatorChar
    $target = Join-Path $root $relative
    if (-not (Test-Path -LiteralPath $target)) {
      $brokenRefs += "$($file.FullName): res://$($match.Groups[1].Value)"
    }
  }
}

if ($brokenRefs.Count -gt 0) {
  Write-Host "Broken res:// references:" -ForegroundColor Red
  $brokenRefs | Sort-Object -Unique | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
  exit 1
}

Write-Host "Project skeleton validation passed." -ForegroundColor Green
