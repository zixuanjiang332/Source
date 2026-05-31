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
  "scripts/levels/AnimatedBackgroundProp.gd",
  "scripts/resources/WeaponData.gd",
  "assets/pixel/characters/yuan/spr_yuan_demo_idle.png",
  "assets/pixel/characters/yuan/chr_yuan_concept_01_early_clone.png",
  "assets/pixel/characters/yuan/chr_yuan_concept_01_early_clone_no_weapon.png",
  "assets/pixel/characters/yuan/chr_yuan_concept_02_machine_arms.png",
  "assets/pixel/characters/yuan/chr_yuan_concept_02_machine_arms_no_weapon.png",
  "assets/pixel/characters/yuan/chr_yuan_concept_03_machine_eye_heart.png",
  "assets/pixel/characters/yuan/chr_yuan_concept_03_machine_eye_heart_no_weapon.png",
  "assets/pixel/weapons/weapon_concept_sheet_01.png",
  "assets/ui/bg_start_menu_yuan_face_v2.png",
  "assets/ui/main_menu_concept_01.png",
  "assets/ui/portrait_yuan_stage_01.png",
  "assets/ui/icon_initial_dagger.png",
  "assets/pixel/background/lab/bg_lab_wall_tiles.png",
  "assets/pixel/background/lab/bg_lab_floor_tiles.png",
  "assets/pixel/background/lab/prop_lab_med_bed_glow.png",
  "assets/pixel/background/lab/prop_lab_tank_liquid.png",
  "assets/pixel/background/lab/prop_lab_terminal_scan.png",
  "assets/pixel/background/lab/prop_lab_warning_light.png",
  "assets/pixel/background/lab/prop_lab_cable_spark.png",
  "assets/pixel/background/lab/prop_lab_elevator_pulse.png",
  "assets/pixel/background/lab/prop_lab_mech_arm_idle.png",
  "assets/pixel/background/lab/prop_lab_floor_light_strip.png",
  "resources/characters/player_stats.tres",
  "resources/weapons/initial_dagger.tres",
  "resources/attacks/dagger_cut_1.tres",
  "resources/attacks/dagger_cut_2.tres",
  "resources/attacks/dagger_cut_3.tres",
  "resources/attacks/dagger_flash_step.tres",
  "resources/attacks/player_slash_1.tres",
  "resources/vfx/vfx_catalog.tres",
  "docs/GAME_FRAMEWORK.md",
  "docs/GITHUB_WORKFLOW.md",
  "docs/DOCUMENTATION_GOVERNANCE.md",
  "docs/PROGRESS_LOG.md",
  "docs/CHANGELOG.md",
  "docs/DECISION_LOG.md",
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
