# 素材交付规范

本文档定义人工美术和程序之间如何交付素材。重点是减少“图做好了但接不进去”的情况。

## 1. 基本原则

- 人工设计最终风格，AI 只做草稿或参考。
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

## 6. 音效交付

- 短音效用 WAV。
- 环境和音乐循环用 OGG。
- 文件名必须描述来源和动作。
- 音频头尾清理静音。
- 需要循环的文件必须标注 loop。

## 7. 接入验收

程序接入后，美术负责人检查：

- 是否缩放正确。
- 是否有模糊或过滤。
- 是否帧序正确。
- 是否脚底漂移。
- 是否命中特效遮挡过多。
- 是否符合当前人工风格方向。

