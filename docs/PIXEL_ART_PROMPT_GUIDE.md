# 像素图生成规范提示词

本文档只定义“如何写提示词”和“交付规格”。具体角色长相、服装、配色、武器、场景风格由团队成员人工决定。

AI 生成图只能作为参考、草稿、灵感或占位，不直接代表最终美术风格。最终可用素材必须由美术负责人手工整理、重绘、修帧和导出。

## 1. 使用原则

- 先由人定义设计意图，再让 AI 辅助出草稿。
- 每次生成只解决一个对象，不同时生成角色、背景、特效和 UI。
- 提示词必须包含画布尺寸、视角、透明背景、帧数或用途。
- 不要求 AI 生成最终 spritesheet 时，必须明确“单张概念参考”。
- 不接受带文字、水印、伪 UI、复杂渐变背景的输出。

## 2. 通用变量

写提示词前先填这些变量：

```text
对象类型: 主角 / 小怪 / Boss / 道具 / 场景瓦片 / UI 图标
用途: 概念参考 / 单帧立绘 / 动画关键帧 / spritesheet 草稿
画布: 32x32 / 64x64 / 96x96 / 128x128 / 192x192
视角: 2D side-view
题材关键词: 赛博朋克 / 智械危机 / 机械 / 全息 / 能量装置
人工指定外观: 由负责人填写
动作或状态: idle / run / dash / attack / hit / death
背景: transparent background
限制: no text, no watermark, no photorealism
```

## 3. 通用提示词模板

```text
Create a 2D side-view pixel art [对象类型] for a cyberpunk machine-crisis action game.
Purpose: [用途].
Canvas target: [画布].
Character or object design notes: [人工指定外观].
Pose or animation state: [动作或状态].
Style constraints: crisp pixel art, readable silhouette, strong shape language, limited but expressive palette, clean clusters, no soft airbrush.
Lighting: high-contrast cyberpunk rim light, controlled neon accents, readable on a dark industrial background.
Background: transparent background.
Do not include text, watermark, UI frame, mockup sheet labels, photorealistic rendering, blurry pixels, or anti-aliased painterly edges.
```

## 4. 主角提示词模板

```text
Create a 2D side-view pixel art playable character for a cyberpunk machine-crisis action game.
Canvas target: 96x96.
Body readability target: about 48x72 pixels inside the canvas.
Role: agile melee fighter with dash-focused combat.
Human-defined design notes: [由美术负责人填写，例如发型、面具、外套、武器、义体部位].
Animation state: [idle/run/jump/fall/dash/atk_1/atk_2/atk_3/skill/hit/death].
Silhouette priority: readable head, torso, weapon direction, and legs.
Color priority: player-friendly cyan or blue energy accents, dark outfit base, one small high-saturation highlight color.
Output: single clean pixel art frame, transparent background, no text, no watermark.
```

## 5. 敌人提示词模板

```text
Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game.
Canvas target: [96x96 or 128x128].
Enemy role: [侦察型 / 重装型 / 远程型 / 自爆型 / Boss 部件].
Human-defined design notes: [由策划和美术填写].
Animation state: [idle/walk/attack/hit/death].
Readability: hostile silhouette, mechanical joints, clear attack direction, red or orange danger accent.
Material direction: steel, ceramic armor, exposed cables, holographic sensor, industrial wear.
Output: single clean pixel art frame, transparent background, no text, no watermark.
```

## 6. Boss 提示词模板

```text
Create a 2D side-view pixel art boss concept frame for a cyberpunk machine-crisis action game.
Canvas target: 192x192.
Boss role: [人工填写].
Human-defined design notes: [体型、核心弱点、武器、机械结构、标志性轮廓].
Readability: large readable silhouette, visible weak point, clear frontal attack parts, strong contrast against dark foundry background.
Mood: intimidating industrial machine, premium demo showcase quality.
Output: single pixel art concept frame, transparent background, no text, no watermark.
```

## 7. 道具图标提示词模板

```text
Create a 2D pixel art item icon for a cyberpunk roguelite action demo.
Canvas target: 32x32, also readable when scaled to 64x64.
Item function: [伤害提升 / 回复 / 冲刺冷却 / 能量核心 / 其他].
Human-defined design notes: [由策划或美术填写].
Readability: clear silhouette, centered object, no tiny unreadable details.
Palette: dark metal base, one neon accent color, strong highlight.
Output: isolated icon, transparent background, no text, no watermark.
```

## 8. 场景瓦片提示词模板

```text
Create pixel art tile concepts for a cyberpunk industrial foundry level.
Tile size: 32x32.
Tile type: [floor / wall / platform / pipe / cable / hologram panel / warning light].
Human-defined design notes: [由场景美术填写].
Constraints: tileable edges where needed, readable collision surface, limited palette, no perspective mismatch.
Output: isolated tile or small tile cluster preview, transparent background if possible, no text, no watermark.
```

## 9. 负面提示词

按需要追加：

```text
no text, no watermark, no logo, no fake game screenshot, no UI mockup, no background, no realistic rendering, no 3D render, no soft brush, no heavy blur, no noisy dithering, no over-detailed unreadable pixels, no inconsistent outline, no extra limbs, no cropped weapon, no isometric view, no top-down view
```

## 10. 人工整理清单

AI 草稿进入项目之前必须人工处理：

- 修正轮廓和比例。
- 统一调色板。
- 清理半透明脏边。
- 对齐脚底和武器方向。
- 拆分动画帧并补中间帧。
- 导出 PNG 到 `assets/pixel/`。
- 源文件保存到 `art_src/`。
- 在 `docs/ASSET_MANIFEST.csv` 更新状态。

