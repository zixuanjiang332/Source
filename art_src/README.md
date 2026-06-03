# Art Source

这里保存 Aseprite、Krita、PSD 或其他源工程文件。源文件通过 Git LFS 管理。

## Naming

- `chr_player_neon_runner.aseprite`
- `enm_scout_drone.aseprite`
- `enm_riot_frame.aseprite`
- `boss_foundry_warden.aseprite`
- `vfx_hit_spark_metal.aseprite`
- `tiles_foundry_lab.aseprite`

导出到 Godot 的 PNG 放入 `assets/pixel/`，不要直接让 Godot 引用 `art_src/`。

`art_src/generated/` 可同时保存 AI 出图使用的提示词、审核表和逐帧源图；这类生产文件也应登记到 `docs/ASSET_MANIFEST.csv`，便于团队同步当前素材生产状态。
