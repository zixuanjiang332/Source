# Audio Pipeline

## Folder Rules

- Final audio: `assets/audio/`
- Draft exports or project files: `art_src/audio/` if needed

## Naming

- `sfx_player_dash_01.wav`
- `sfx_player_slash_light_01.wav`
- `sfx_hit_metal_light_01.wav`
- `sfx_hit_metal_heavy_01.wav`
- `sfx_enemy_swipe_01.wav`
- `amb_foundry_loop_01.ogg`

## Demo Priority

1. Player dash
2. Player slash light/heavy
3. Metal hit light/heavy
4. Enemy attack warning
5. Item pickup
6. Boss impact
7. Low industrial ambience

## Legacy Ultimate SFX Pack

这组 `Overdrive Sever` 终结技 WAV 仍保留在仓库中作为历史占位资产，但当前活跃武器链不再依赖它：

- `sfx_yuan_ult_charge_01.wav`
- `sfx_yuan_ult_afterimage_01.wav`
- `sfx_yuan_ult_blue_slash_01.wav` 到 `sfx_yuan_ult_blue_slash_07.wav`
- `sfx_yuan_ult_red_drop_01.wav`
- `sfx_yuan_ult_red_impact_01.wav`

这些文件由 `tools/generate_yuan_ultimate_assets.py` 合成。后续如果恢复终结技路线，可复用相同 `sfx_id`，否则视作历史保留资源。

## Tooling

临时音效可以用 jsfxr/ChipTone。最终统一用 Audacity 修剪静音、淡入淡出和响度。短音效用 WAV，环境循环用 OGG。
