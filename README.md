# Neon Machine Demo

赛博朋克智械危机题材的 2D 像素动作 Demo 骨架。目标是在 2026-08-15 前提交 Windows 可执行包和高质量演示视频。

## Quick Start

1. 安装 Godot 4.6.x stable。
2. 安装 Git LFS：`git lfs install`。
3. 用 Godot 打开本目录 `C:\Users\PC\OneDrive\桌面\Game`。
4. 运行主场景 `scenes/main/Main.tscn`。

Godot 和 Aseprite 当前未在本机 PATH 中检测到；项目文件已经准备好，安装后即可打开。

## Controls

- Move: `A/D` 或方向键
- Jump: `Space`
- Dash: `Shift`
- Attack: `J`
- Skill: `K`
- Restart: `R`
- Pause: `Esc`

## Project Shape

- `scenes/`: Godot 场景，包含主场景、关卡、玩家、敌人、UI 和 VFX。
- `scripts/`: GDScript 代码，按 core/combat/player/enemies/items/vfx/ui/resources 分组。
- `resources/`: Godot `.tres` 数据资源，角色数值、攻击、道具、VFX 目录。
- `assets/`: 导入 Godot 的最终素材。
- `art_src/`: Aseprite 或其他源工程文件。
- `docs/`: 策划、协作、排期、美术和音频规范。

## Current Slice

当前骨架提供可跑的灰盒切片：玩家移动、跳跃、冲刺、初始匕首三段攻击、Demo 能量技 `Flash Step`、Hitbox/Hurtbox、敌人受击/死亡、掉落道具、镜头震动、武器/能量/连段 HUD、赛博朋克占位关卡和命中特效。

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
- [特效生成规范提示词](docs/VFX_PROMPT_GUIDE.md)
- [AI 辅助素材使用规则](docs/AI_ASSET_POLICY.md)
- [美术规格](docs/ART_BIBLE.md)
- [GitHub 工作流](docs/GITHUB_WORKFLOW.md)
- [里程碑](docs/MILESTONES.md)
