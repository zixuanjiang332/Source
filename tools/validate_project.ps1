$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$required = @(
  "project.godot",
  ".gitattributes",
  ".gitignore",
  "scenes/main/Main.tscn",
  "scenes/levels/DemoLevel.tscn",
  "scenes/levels/RebirthLevel.tscn",
  "scenes/levels/MainCityLevel.tscn",
  "scenes/player/Player.tscn",
  "scripts/core/GameEvents.gd",
  "scripts/combat/Hitbox.gd",
  "scripts/combat/Hurtbox.gd",
  "scripts/levels/AnimatedBackgroundProp.gd",
  "scripts/levels/RebirthLevel.gd",
  "scripts/levels/MainCityLevel.gd",
  "scripts/player/PlayerAnimationController.gd",
  "scripts/resources/WeaponData.gd",
  "scripts/resources/VfxEntry.gd",
  "scripts/resources/SfxEntry.gd",
  "scripts/vfx/SpriteSheetVfx.gd",
  "assets/pixel/spr_player_yuan_early_clone.png",
  "assets/pixel/spr_player_yuan_runtime.png",
  "assets/pixel/characters/player_yuan_early_clone/spr_player_yuan_ultimate_slam.png",
  "assets/pixel/characters/player_yuan_early_clone/frames/idle_00.png",
  "assets/pixel/characters/yuan/spr_yuan_demo_idle.png",
  "assets/pixel/characters/yuan/chr_yuan_concept_01_early_clone.png",
  "assets/pixel/characters/yuan/chr_yuan_concept_01_early_clone_no_weapon.png",
  "assets/pixel/characters/yuan/chr_yuan_concept_02_machine_arms.png",
  "assets/pixel/characters/yuan/chr_yuan_concept_02_machine_arms_no_weapon.png",
  "assets/pixel/characters/yuan/chr_yuan_concept_03_machine_eye_heart.png",
  "assets/pixel/characters/yuan/chr_yuan_concept_03_machine_eye_heart_no_weapon.png",
  "assets/pixel/weapons/weapon_concept_sheet_01.png",
  "assets/pixel/vfx/yuan_ultimate/vfx_yuan_ult_afterimage.png",
  "assets/pixel/vfx/yuan_ultimate/vfx_yuan_ult_blue_slash_01.png",
  "assets/pixel/vfx/yuan_ultimate/vfx_yuan_ult_blue_slash_02.png",
  "assets/pixel/vfx/yuan_ultimate/vfx_yuan_ult_blue_slash_03.png",
  "assets/pixel/vfx/yuan_ultimate/vfx_yuan_ult_blue_slash_04.png",
  "assets/pixel/vfx/yuan_ultimate/vfx_yuan_ult_blue_slash_05.png",
  "assets/pixel/vfx/yuan_ultimate/vfx_yuan_ult_blue_slash_06.png",
  "assets/pixel/vfx/yuan_ultimate/vfx_yuan_ult_blue_slash_07.png",
  "assets/pixel/vfx/yuan_ultimate/vfx_yuan_ult_red_slam_arc.png",
  "assets/pixel/vfx/yuan_ultimate/vfx_yuan_ult_red_impact.png",
  "assets/audio/sfx/sfx_yuan_ult_charge_01.wav",
  "assets/audio/sfx/sfx_yuan_ult_afterimage_01.wav",
  "assets/audio/sfx/sfx_yuan_ult_blue_slash_01.wav",
  "assets/audio/sfx/sfx_yuan_ult_blue_slash_02.wav",
  "assets/audio/sfx/sfx_yuan_ult_blue_slash_03.wav",
  "assets/audio/sfx/sfx_yuan_ult_blue_slash_04.wav",
  "assets/audio/sfx/sfx_yuan_ult_blue_slash_05.wav",
  "assets/audio/sfx/sfx_yuan_ult_blue_slash_06.wav",
  "assets/audio/sfx/sfx_yuan_ult_blue_slash_07.wav",
  "assets/audio/sfx/sfx_yuan_ult_red_drop_01.wav",
  "assets/audio/sfx/sfx_yuan_ult_red_impact_01.wav",
  "assets/ui/bg_start_menu_yuan_face_v2.png",
  "assets/ui/bg_start_menu_yuan_face_clean_1920.png",
  "assets/ui/main_menu_concept_01.png",
  "assets/ui/portrait_yuan_stage_01.png",
  "assets/ui/icon_initial_dagger.png",
  "assets/pixel/background/lab/bg_rebirth_lab_1920.png",
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
  "assets/pixel/background/city/bg_city_route_panel_01.png",
  "assets/pixel/background/city/bg_city_route_panel_02.png",
  "assets/pixel/background/city/bg_city_route_panel_03.png",
  "assets/pixel/background/city/bg_city_route_panel_04.png",
  "resources/characters/player_stats.tres",
  "resources/characters/player_yuan_early_clone_frames.tres",
  "resources/characters/player_yuan_runtime_frames.tres",
  "resources/weapons/initial_dagger.tres",
  "resources/weapons/initial_fists.tres",
  "resources/attacks/dagger_cut_1.tres",
  "resources/attacks/dagger_cut_2.tres",
  "resources/attacks/dagger_cut_3.tres",
  "resources/attacks/dagger_flash_step.tres",
  "resources/attacks/fist_jab_1.tres",
  "resources/attacks/fist_cross_2.tres",
  "resources/attacks/fist_breaker_3.tres",
  "resources/attacks/fist_drive_step.tres",
  "resources/attacks/yuan_ult_blue_slash_01.tres",
  "resources/attacks/yuan_ult_blue_slash_02.tres",
  "resources/attacks/yuan_ult_blue_slash_03.tres",
  "resources/attacks/yuan_ult_blue_slash_04.tres",
  "resources/attacks/yuan_ult_blue_slash_05.tres",
  "resources/attacks/yuan_ult_blue_slash_06.tres",
  "resources/attacks/yuan_ult_blue_slash_07.tres",
  "resources/attacks/yuan_ult_red_slam.tres",
  "resources/attacks/player_slash_1.tres",
  "resources/vfx/vfx_catalog.tres",
  "docs/GAME_FRAMEWORK.md",
  "docs/PLAYER_ANIMATION_SPEC.md",
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
  "docs/FIST_ANIMATION_PRODUCTION_PACK.md",
  "docs/PLAYER_FIST_STRIP_EXPORT_SPEC.md",
  "docs/PLAYER_FIST_REDRAW_TASKS.md",
  "docs/PLAYER_FIST_REDRAW_BATCH_01.md",
  "docs/PLAYER_FIST_BATCH_01_REPLACE_CHECKLIST.md",
  "docs/VFX_PROMPT_GUIDE.md",
  "docs/AI_ASSET_POLICY.md",
  "tools/build_player_yuan_runtime_from_fist_pass.py",
  "tools/deploy_player_yuan_fist_pass.ps1",
  "tools/derive_fist_pass_from_legacy.py",
  "tools/build_player_yuan_fist_keyframe_boards.py",
  "tools/apply_player_yuan_redraw_batch_01.py",
  "tools/generate_player_yuan_fist_templates.py",
  "tools/generate_player_yuan_fist_paintover_guides.py",
  "tools/run_game_local.ps1"
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

$mainScenePath = Join-Path $root "scenes/main/Main.tscn"
$mainScene = Get-Content -LiteralPath $mainScenePath -Raw
$staticGameplayNodes = [regex]::Matches($mainScene, '\[node name="(DemoLevel|Hud|VfxSpawner)"[^\]]*\]')
if ($staticGameplayNodes.Count -gt 0) {
  Write-Host "Main.tscn must not instantiate gameplay nodes before Start:" -ForegroundColor Red
  $staticGameplayNodes | ForEach-Object { Write-Host "  $($_.Value)" -ForegroundColor Red }
  exit 1
}

$projectSettings = Get-Content -LiteralPath (Join-Path $root "project.godot") -Raw
$requiredSettings = @(
  'window/size/viewport_width=1920',
  'window/size/viewport_height=1080',
  'window/stretch/mode="canvas_items"'
)
foreach ($setting in $requiredSettings) {
  if (-not $projectSettings.Contains($setting)) {
    Write-Host "Missing required 1080p clarity setting: $setting" -ForegroundColor Red
    exit 1
  }
}

if ($mainScene.Contains("bg_start_menu_yuan_face_v2.png")) {
  Write-Host "Main.tscn must use the clean componentized title background, not the baked-text menu art." -ForegroundColor Red
  exit 1
}

if (-not $mainScene.Contains("MenuRoot")) {
  Write-Host "Main.tscn must expose componentized menu controls under TitleLayer/MenuRoot." -ForegroundColor Red
  exit 1
}

function Assert-PngSize {
  param(
    [string]$RelativePath,
    [int]$ExpectedWidth,
    [int]$ExpectedHeight
  )

  $fullPath = Join-Path $root $RelativePath
  $bytes = [IO.File]::ReadAllBytes($fullPath)
  if ($bytes.Length -lt 24) {
    Write-Host "PNG is too small to read dimensions: $RelativePath" -ForegroundColor Red
    exit 1
  }

  $width = ([int]$bytes[16] -shl 24) -bor ([int]$bytes[17] -shl 16) -bor ([int]$bytes[18] -shl 8) -bor [int]$bytes[19]
  $height = ([int]$bytes[20] -shl 24) -bor ([int]$bytes[21] -shl 16) -bor ([int]$bytes[22] -shl 8) -bor [int]$bytes[23]
  if ($width -ne $ExpectedWidth -or $height -ne $ExpectedHeight) {
    Write-Host "Unexpected PNG size for $RelativePath`: ${width}x${height}, expected ${ExpectedWidth}x${ExpectedHeight}" -ForegroundColor Red
    exit 1
  }
}

Assert-PngSize "assets/ui/bg_start_menu_yuan_face_clean_1920.png" 1920 1080
Assert-PngSize "assets/pixel/background/lab/bg_rebirth_lab_1920.png" 1920 1080
Assert-PngSize "assets/pixel/background/city/bg_city_route_panel_01.png" 1920 1080
Assert-PngSize "assets/pixel/background/city/bg_city_route_panel_02.png" 1920 1080
Assert-PngSize "assets/pixel/background/city/bg_city_route_panel_03.png" 1920 1080
Assert-PngSize "assets/pixel/background/city/bg_city_route_panel_04.png" 1920 1080
Assert-PngSize "assets/pixel/characters/player_yuan_early_clone/spr_player_yuan_ultimate_slam.png" 768 96
Assert-PngSize "assets/pixel/vfx/yuan_ultimate/vfx_yuan_ult_afterimage.png" 672 96
Assert-PngSize "assets/pixel/vfx/yuan_ultimate/vfx_yuan_ult_blue_slash_01.png" 1536 128
Assert-PngSize "assets/pixel/vfx/yuan_ultimate/vfx_yuan_ult_blue_slash_02.png" 1536 128
Assert-PngSize "assets/pixel/vfx/yuan_ultimate/vfx_yuan_ult_blue_slash_03.png" 1536 128
Assert-PngSize "assets/pixel/vfx/yuan_ultimate/vfx_yuan_ult_blue_slash_04.png" 1536 128
Assert-PngSize "assets/pixel/vfx/yuan_ultimate/vfx_yuan_ult_blue_slash_05.png" 1536 128
Assert-PngSize "assets/pixel/vfx/yuan_ultimate/vfx_yuan_ult_blue_slash_06.png" 1536 128
Assert-PngSize "assets/pixel/vfx/yuan_ultimate/vfx_yuan_ult_blue_slash_07.png" 1536 128
Assert-PngSize "assets/pixel/vfx/yuan_ultimate/vfx_yuan_ult_red_slam_arc.png" 1536 128
Assert-PngSize "assets/pixel/vfx/yuan_ultimate/vfx_yuan_ult_red_impact.png" 1536 128

Write-Host "Project skeleton validation passed." -ForegroundColor Green
