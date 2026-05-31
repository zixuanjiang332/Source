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

## Current Ultimate SFX Pack

`Overdrive Sever` 终结技已接入一组电子锋利风格 WAV：

- `sfx_yuan_ult_charge_01.wav`
- `sfx_yuan_ult_afterimage_01.wav`
- `sfx_yuan_ult_blue_slash_01.wav` 到 `sfx_yuan_ult_blue_slash_07.wav`
- `sfx_yuan_ult_red_drop_01.wav`
- `sfx_yuan_ult_red_impact_01.wav`

这些文件由 `tools/generate_yuan_ultimate_assets.py` 合成，作为可直接运行的 final placeholder。后续如果重制音频，应保留相同 `sfx_id` 或同步更新 `resources/vfx/vfx_catalog.tres`。

## Tooling

临时音效可以用 jsfxr/ChipTone。最终统一用 Audacity 修剪静音、淡入淡出和响度。短音效用 WAV，环境循环用 OGG。
