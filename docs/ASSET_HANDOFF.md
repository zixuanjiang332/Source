# 素材交付规范

本文档定义人工美术和程序之间如何交付素材。重点是减少“图做好了但接不进去”的情况。

## 1. 基本原则

- 负责人确认最终风格，AI 生成图、动作帧和 spritesheet 可以直接作为 final 素材；具体规则见 `AI_ASSET_POLICY.md`。
- 源文件和导出文件分离。
- 每个素材都有负责人、状态和导出目标。
- 程序只接入 `assets/` 中的最终导出素材。

## 2. 交付路径

```text
art_src/       源文件：.aseprite, .ase, .psd, .kra
assets/pixel/ 运行时图片：.png
assets/audio/ 运行时音频：.wav, .ogg
docs/ASSET_MANIFEST.csv 素材清单
```

## 3. 像素角色交付

每个角色至少包含：

- 源文件。
- 导出 spritesheet。
- 帧宽、帧高。
- 动画标签。
- 每个动画帧数。
- 角色脚底基准线。
- 攻击帧的命中窗口说明。
- 如果是主角正式动作替换，还要附上逐动作的关键帧说明和审核结论。

示例：

```text
角色: player_neon_runner
画布: 96x96
脚底 Y: 92
动画: idle 6f, run 8f, dash 5f, atk_1 6f
命中窗口: atk_1 第 3-4 帧
导出: assets/pixel/spr_player_neon_runner.png
源文件: art_src/chr_player_neon_runner.aseprite
```

主角“源”的拳头开局动作第二轮出图，额外遵循：

- `PLAYER_ANIMATION_SPEC.md`
- `FIST_ANIMATION_PRODUCTION_PACK.md`

其中 `FIST_ANIMATION_PRODUCTION_PACK.md` 负责定义 `combat_idle`、`combat_run`、`punch_1`、`punch_2`、`punch_3`、`punch_skill` 的逐动作、逐关键帧和审核规则。
`PLAYER_FIST_STRIP_EXPORT_SPEC.md` 负责定义正式高质量拳头条带的文件名、尺寸、帧数和替换流程。
`PLAYER_FIST_REDRAW_TASKS.md` 负责定义当前过渡拳头 runtime 中优先重绘哪些帧、保留哪些节奏。
`PLAYER_FIST_REDRAW_BATCH_01.md` 负责把第一批 9 帧正式重绘任务进一步拆成逐帧目标。
`PLAYER_FIST_BATCH_01_REPLACE_CHECKLIST.md` 负责把 Batch 01 的重绘成品安全地压回当前 runtime 并重新部署。
`PLAYER_FIST_VISUAL_REFERENCES.md` 负责记录已经落地的拳头视觉参考图，供重绘前统一动作味道。
`art_src/generated/player_yuan_fist_pass/prompts/YUAN_APPEARANCE_LOCK.md` 负责锁定“源”的外貌设定，尤其是“只有右臂机械、左臂必须保持人类手臂”的硬约束。

如果要先统一拳头连段的单帧力量方向，再做逐帧重绘，可先参考：

- `art_src/generated/player_yuan_fist_pass/prompts/REDRAW_BATCH_01_VISUAL_REFERENCE_PROMPT.md`

如果要直接在正确格式上绘制正式拳头条带，可使用：

- `art_src/generated/player_yuan_fist_pass/templates/*.png`

如果要在当前过渡拳头动作上直接做 paintover，可使用：

- `art_src/generated/player_yuan_fist_pass/paintover_guides/*_guide.png`

推荐同时交付：

- `art_src/generated/player_yuan_fist_pass/prompts/KEYFRAME_PROMPTS.md`
- `art_src/generated/player_yuan_fist_pass/prompts/FRAME_BY_FRAME_PROMPTS.md`
- `art_src/generated/player_yuan_fist_pass/prompts/REVIEW_WORKSHEET.md`
- `art_src/generated/player_yuan_fist_pass/prompts/FRAME_SHOTLIST.csv`
- `art_src/generated/player_yuan_fist_pass/prompts/CONSISTENCY_LOCK.md`
- `art_src/generated/player_yuan_fist_pass/prompts/BATCH_01_FINAL_PROMPTS.md`

## 4. 特效交付

每个特效至少包含：

- 源文件。
- 导出 spritesheet。
- 帧宽、帧高。
- 帧数。
- 推荐 FPS。
- 触发点位置。
- 是否需要翻转。
- 是否会遮挡角色。

示例：

```text
特效: hit_spark_metal
画布: 64x64
帧数: 6
FPS: 18
触发点: center-left
可翻转: yes
导出: assets/pixel/vfx_hit_spark_metal_64_6f.png
源文件: art_src/vfx_hit_spark_metal.aseprite
```

## 5. 道具图标交付

- 32x32 主图标。
- 64x64 展示图标，如需要。
- 透明背景。
- 图标不带文字。
- 道具功能写入 `ItemData` 或策划表，不写在图片上。

## 6. 动态背景交付

动态背景只交付拆分后的 tiles 和 props，不交付整张全屏帧动画。

每个背景动画至少包含：

- 源文件。
- 导出 spritesheet。
- 单帧尺寸。
- 帧数。
- 推荐 FPS。
- 是否需要 Godot 侧移动循环。
- 推荐放置层：LabStaticTiles / LabAnimatedProps / CityFar / CityMid / CityAnimatedProps / CityForegroundDecor。

示例：

```text
素材: prop_city_traffic_a
画布: 64x32
帧数: 8
FPS: 8
移动: Godot scroll_velocity 控制
导出: assets/pixel/background/city/prop_city_traffic_a.png
源文件: art_src/background/city/prop_city_traffic_a.aseprite
```

AI final 背景素材可以使用 `art_src/generated_frames/background/` 保存逐帧 PNG，再输出 spritesheet 到 `assets/pixel/background/`。实验室批次使用 `python tools/stitch_spritesheet.py --process-lab --check` 生成并校验运行时 spritesheet。

## 7. 音效交付

- 短音效用 WAV。
- 环境和音乐循环用 OGG。
- 文件名必须描述来源和动作。
- 音频头尾清理静音。
- 需要循环的文件必须标注 loop。

## 8. 接入验收

程序接入后，美术负责人检查：

- 是否缩放正确。
- 是否有模糊或过滤。
- 是否帧序正确。
- 是否脚底漂移。
- 是否命中特效遮挡过多。
- 是否符合当前人工风格方向。
