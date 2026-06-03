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

当前骨架提供可跑的灰盒切片：脸部主题标题菜单、玩家动作帧、移动、跳跃、冲刺、初始拳头三段攻击、Demo 能量技 `Flash Step`、Hitbox/Hurtbox、敌人受击/死亡、掉落道具、镜头震动、大视距相机、地图边界、武器/能量/连段 HUD、已接入的“源”主角/HUD/武器视觉资源、重生点 -> 作坊 -> 主关卡流程、实验室动态背景、赛博朋克城市占位段、命中特效和动态背景 props 框架。当前运行时已切到一版过渡拳头动作集：新 `combat_* / punch_*` 条带已实装，旧刀系战斗帧已从逐帧目录清理，后续继续用更高质量帧图替换这版过渡资源。

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
- [拳头动作生产包](docs/FIST_ANIMATION_PRODUCTION_PACK.md)
- [源主角外貌锁定提示词](art_src/generated/player_yuan_fist_pass/prompts/YUAN_APPEARANCE_LOCK.md)
- [拳头条带导出规格](docs/PLAYER_FIST_STRIP_EXPORT_SPEC.md)
- [拳头重绘任务单](docs/PLAYER_FIST_REDRAW_TASKS.md)
- [拳头重绘批次 01](docs/PLAYER_FIST_REDRAW_BATCH_01.md)
- [拳头批次 01 替换清单](docs/PLAYER_FIST_BATCH_01_REPLACE_CHECKLIST.md)
- [拳头批次 02 替换清单](docs/PLAYER_FIST_BATCH_02_REPLACE_CHECKLIST.md)
- [拳头批次 03 替换清单](docs/PLAYER_FIST_BATCH_03_REPLACE_CHECKLIST.md)
- [拳头批次 04 替换清单](docs/PLAYER_FIST_BATCH_04_REPLACE_CHECKLIST.md)
- [拳头视觉参考](docs/PLAYER_FIST_VISUAL_REFERENCES.md)
- [特效生成规范提示词](docs/VFX_PROMPT_GUIDE.md)
- [AI 辅助素材使用规则](docs/AI_ASSET_POLICY.md)
- [美术规格](docs/ART_BIBLE.md)
- [GitHub 工作流](docs/GITHUB_WORKFLOW.md)
- [里程碑](docs/MILESTONES.md)
