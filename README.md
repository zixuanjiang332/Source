# Neon Machine Demo

赛博朋克智械危机题材的 2D 像素动作 Demo 骨架。目标是在 2026-08-15 前提交 Windows 可执行包和高质量演示视频。

## Quick Start

1. 安装 Godot 4.6.x stable。
2. 安装 Git LFS：`git lfs install`。
3. 用 Godot 打开本目录 `C:\Users\PC\OneDrive\桌面\Game`。
4. 运行主场景 `scenes/main/Main.tscn`。

Godot 和 Aseprite 当前未在本机 PATH 中检测到；项目文件已经准备好，安装后即可打开。

## Controls

- Start: 点击主菜单里的“开始游戏”，或按 `J` / `Space` / `E`
- Move: `A/D` 或方向键
- Jump: `Space`
- Dash: `Shift`
- Attack: 鼠标左键
- Skill: 鼠标右键
- Reload: `R`
- Weapon Slots: `1` / `2` / `3`
- Previous Weapon: `Q`
- Drop Weapon: `G`
- Restart: `F`
- Pause: `Esc`

## Project Shape

- `scenes/`: Godot 场景，包含主场景、关卡、玩家、敌人、UI 和 VFX。
- `scripts/`: GDScript 代码，按 core/combat/player/enemies/items/vfx/ui/resources 分组。
- `resources/`: Godot `.tres` 数据资源，角色数值、攻击、道具、VFX 目录。
- `assets/`: 导入 Godot 的最终素材。
- `art_src/`: Aseprite 或其他源工程文件。
- `docs/`: 策划、协作、排期、美术和音频规范。

## Current Slice

当前骨架提供可跑的灰盒切片：赛博主题标题菜单、全新玩家动作帧、移动、跳跃、冲刺、初始拳头三段攻击、Demo 能量技 `Flash Step`、Hitbox/Hurtbox、敌人受击/死亡、掉落道具、镜头震动、大视距相机、地图边界、武器/能量/连段 HUD、已接入的赛博拳手主角/HUD/武器视觉资源、重生点 -> 作坊 -> 主关卡流程、实验室动态背景、赛博朋克城市占位段、命中特效和动态背景 props 框架。当前玩家运行时已全量重置为从零生成的 `combat_* / punch_*` 拳头动作集，不再使用旧角色、几何占位或看板裁剪素材。

## Team Docs

先读这几份：

- [程序开发规范](docs/PROGRAMMING_STANDARDS.md)
- [程序协同开发文档](docs/PROGRAMMER_COLLABORATION.md)
- [文档治理规范](docs/DOCUMENTATION_GOVERNANCE.md)
- [进度记录](docs/PROGRESS_LOG.md)
- [更改日志](docs/CHANGELOG.md)
- [决策记录](docs/DECISION_LOG.md)
- [素材交付规范](docs/ASSET_HANDOFF.md)
- [像素图生成规范提示词](docs/PIXEL_ART_PROMPT_GUIDE.md)
- [玩家动作规范](docs/PLAYER_ANIMATION_SPEC.md)
- [拳头视觉参考](docs/PLAYER_FIST_VISUAL_REFERENCES.md)
- [特效生成规范提示词](docs/VFX_PROMPT_GUIDE.md)
- [AI 辅助素材使用规则](docs/AI_ASSET_POLICY.md)
- [美术规格](docs/ART_BIBLE.md)
- [GitHub 工作流](docs/GITHUB_WORKFLOW.md)
- [里程碑](docs/MILESTONES.md)
