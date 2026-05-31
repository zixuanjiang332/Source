# 特效生成规范提示词

本文档规定特效提示词结构和交付标准。具体特效形状、节奏、颜色、爆点由团队成员决定。

AI 生成特效图、动作帧和 spritesheet 可以直接作为最终特效素材。负责人需要在 Godot 中调试播放速度、遮挡、首帧冲击和命中可读性；后续要改为人工重绘时再单独提出。

## 1. 特效设计优先级

1. 命中点清楚。
2. 攻击方向清楚。
3. 玩家和敌人不被长时间遮挡。
4. 首帧冲击强。
5. 余辉短而干净。
6. 华丽度服务录屏，不牺牲操作可读性。

## 2. 通用变量

```text
特效类型: 命中火花 / 刀光 / 冲刺残影 / 电弧 / 爆炸 / 全息闪烁 / 道具拾取
用途: 最终成品 / 概念参考 / 单帧 / spritesheet
画布: 64x64 / 96x96 / 128x128
帧数: 4 / 6 / 8 / 12
方向: left-to-right / right-to-left / radial / upward
主色: cyan / magenta / red-orange / electric blue
背景: transparent background
人工设计说明: 由 VFX 负责人填写
```

## 3. 通用提示词模板

```text
Create a 2D pixel art VFX [特效类型] for a cyberpunk melee action game.
Purpose: [用途].
Canvas target: [画布].
Frame target: [帧数] frames if making a sprite animation reference.
Direction: [方向].
Human-defined VFX notes: [人工设计说明].
Style constraints: crisp pixel art, strong first-frame impact, clean readable silhouette, limited palette, no smoky realistic particles.
Color direction: [主色] neon energy with small white-hot core highlights.
Background: transparent background.
Do not include text, watermark, UI frame, character body, weapon sprite, photorealistic smoke, blurry glow, or full scene background.
```

## 4. 命中火花模板

```text
Create a 2D pixel art metal hit spark VFX for a cyberpunk action game.
Canvas target: 64x64 or 96x96.
Frame target: 4 to 6 frames.
Impact point: center-left, burst moving outward to the right.
Human-defined notes: [火花形状、大小、颜色比例].
Visual language: metal shards, electric arc fragments, short cyan and red-orange sparks, white-hot center.
Timing: frame 1 strongest, frame 2 expands, frame 3 breaks into fragments, final frames fade quickly.
Background: transparent background.
No text, no character, no weapon, no realistic smoke, no blurry glow.
```

## 5. 刀光模板

```text
Create a 2D pixel art slash trail VFX for a cyberpunk energy blade.
Canvas target: 128x128.
Frame target: 6 to 8 frames.
Direction: [left-to-right / right-to-left / upward arc / downward arc].
Human-defined arc shape: [由 VFX 负责人填写].
Visual language: bright cyan energy edge, magenta secondary rim, broken pixel fragments, sharp readable arc.
Timing: anticipation glow, main slash arc, trailing fragments, quick fade.
Background: transparent background.
No text, no character body, no full weapon sprite, no painterly smear, no soft airbrush.
```

## 6. 冲刺残影模板

```text
Create a 2D pixel art dash burst VFX for an agile cyberpunk melee character.
Canvas target: 96x96.
Frame target: 5 to 7 frames.
Direction: horizontal movement.
Human-defined notes: [残影宽度、速度感、颜色].
Visual language: thin neon speed lines, broken holographic afterimage fragments, short-lived cyan glow.
Readability: should not cover the player silhouette for more than one frame.
Background: transparent background.
No text, no full character, no realistic motion blur, no smoke cloud.
```

## 7. 电弧模板

```text
Create a 2D pixel art electric arc VFX for a machine-crisis cyberpunk game.
Canvas target: 64x64 or 96x96.
Frame target: 4 to 8 frames.
Direction: [radial / chain lightning / downward strike].
Human-defined notes: [电弧密度、形状、是否围绕机械核心].
Visual language: jagged pixel lightning, white core, cyan outer glow, tiny magenta interference pixels.
Timing: flicker on, branch split, snap fade.
Background: transparent background.
No text, no background, no realistic volumetric lightning, no excessive glow.
```

## 8. 爆炸/破碎模板

```text
Create a 2D pixel art mechanical destruction burst VFX.
Canvas target: 128x128.
Frame target: 8 to 12 frames.
Human-defined notes: [爆点大小、碎片方向、是否有能量核心].
Visual language: metal fragments, red-orange internal heat, cyan energy leak, short smoke pixels only if readable.
Timing: flash, fragment burst, energy leak, fast fade.
Background: transparent background.
No text, no character, no full environment, no realistic smoke simulation.
```

## 9. 全息设备闪烁模板

```text
Create a 2D pixel art hologram flicker VFX for cyberpunk environment props.
Canvas target: 64x64 or 96x96.
Frame target: 6 to 10 frames.
Human-defined notes: [全息形状、图案、颜色].
Visual language: transparent cyan panels, scanline gaps, pixel glitch offsets, subtle magenta noise.
Timing: stable frame, offset glitch, scanline break, recover.
Background: transparent background.
No readable text, no logo, no UI mockup, no full scene.
```

## 10. Sprite Sheet 交付要求

正式导出时：

- 背景透明。
- 所有帧同尺寸。
- 原点和命中点一致。
- 文件名：`vfx_<name>_<size>_<frames>f.png`。
- 源文件：`art_src/vfx_<name>.aseprite`，或 `art_src/generated_frames/vfx/<name>/` 中的 AI 源图和逐帧 PNG。
- Godot 导入后测试：播放速度、遮挡、首帧冲击、结束残留。

## 11. Godot 接入清单

- 在 `VfxCatalog` 中登记 VFX ID。
- 命中类特效由 `AttackData.vfx_id` 调用。
- 移动类特效由玩家/敌人状态调用。
- 环境类特效放关卡场景。
- 强特效必须测试低配 60 FPS。

## 12. 终结技特效包实例

当前 `Overdrive Sever` 使用以下规格作为 Demo 终结技基准：

- 蓝色多段斩：`vfx_yuan_ult_blue_slash_01` 到 `07`，`256x128`，`6f`，电子蓝主色，少量 magenta glitch。
- 残影：`vfx_yuan_ult_afterimage`，`96x96`，`7f`，角色本体隐藏时用于提示位移轨迹。
- 红色重击：`vfx_yuan_ult_red_slam_arc` 与 `vfx_yuan_ult_red_impact`，`256x128`，`6f`，用于最后坠落斩和落点爆发。
- 角色动作：`spr_player_yuan_ultimate_slam`，`96x96`，`8f`，只在最终红色重击阶段显示。

提示词方向：前 7 段强调“蓝色全息横向/斜向刀痕、角色消失、空间切割”；最后一段强调“红色下坠重击、双手持刀、落点爆发”。运行时必须保证前 7 段不长时间遮挡敌人轮廓，最后红色爆点允许短暂遮挡以制造高潮。
