# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Neon Machine Demo — 赛博朋克智械危机题材的 2D 像素动作垂直切片。Godot 4.6.x + GDScript，目标 2026-08-15 前提交 Windows 可执行包和演示视频。当前为可运行灰盒骨架阶段。

## Build & Run

- 引擎：Godot 4.6.x stable（需本地安装）
- 主场景：`scenes/main/Main.tscn`
- 导出配置：`export_presets.cfg` → Windows Desktop，输出 `builds/windows/NeonMachineDemo.exe`
- 项目校验：`.\tools\validate_project.ps1`（检查必需文件和 res:// 引用完整性）
- Git LFS：`git lfs install`（首次克隆后必须执行）

## Architecture

### Autoload 单例

- `GameEvents`（全局事件总线）：所有跨系统通信走这里——生命/能量变化、VFX/SFX 请求、镜头震动、敌人死亡、重开。不直接实例化特效或驱动战斗逻辑。
- `InputBootstrap`：启动时注册默认 InputMap，避免空项目缺输入。

### 核心数据流

```
AttackData (.tres) → Hitbox.activate() → area_entered → Hurtbox.receive_hit() → receiver.apply_hit()
```

- `Hitbox`：激活后监听 `area_entered`，通过 `Hurtbox` 接口传递攻击数据，自动防重复命中（`_targets_hit` token 机制），命中后通过 `GameEvents` 请求 VFX/SFX/镜头震动。
- `Hurtbox`：通过 `receiver_path` 找到宿主，调用其 `apply_hit()` 方法。任何可受击节点必须实现 `apply_hit(attack_data, source, hit_position, facing)`。

### Resource 数据层

数值不硬编码在脚本里，统一放 `.tres`：

- `CharacterStats`：生命、速度、冲刺、重力、接触伤害。运行时通过 `runtime_copy()` 复制，避免修改原始资源。
- `AttackData`：伤害、击退、主动帧、冷却、命中停顿、屏幕震动、VFX/SFX ID。
- `WeaponData`：当前武器 ID、显示名、三段普攻、Demo 技能攻击和 HUD 技能名。当前只服务初始匕首切片。
- `ItemData`：道具 ID、效果 ID（`damage_multiplier`/`heal`/`dash_cooldown`/`max_health`）、倍率。
- `VfxCatalog`：`vfx_id` → PackedScene 映射，`VfxSpawner` 查表实例化。

### 场景结构

`Main.tscn` 加载 `DemoLevel.tscn` + `Hud.tscn` + `VfxSpawner`。`Main.gd` 处理暂停和重开（`PROCESS_MODE_ALWAYS`）。

### 碰撞层

- Layer 1: World
- Layer 2: Actor body
- Layer 4: Hurtbox
- Layer 8: Hitbox
- Layer 16: Pickup

新增层前必须更新 `docs/PROGRAMMING_STANDARDS.md`。

## Coding Conventions

### GDScript 文件顺序

class_name → extends → signal → enum → const → @export var → 成员变量 → @onready var → _ready() → _process()/_physics_process() → Godot 回调 → 公开方法 → 私有方法

### 命名

- 类名：PascalCase；函数/变量：snake_case；私有：`_` 前缀；常量：UPPER_SNAKE_CASE
- 信号：过去式或状态变化，如 `hit_landed`、`player_health_changed`
- 场景文件：PascalCase（`Player.tscn`）；资源/素材：snake_case（`player_slash_1.tres`）

### 关键规则

- 数值放 `.tres` 或 `@export`，不硬编码在 `_physics_process()` 里
- UI 只监听事件/读状态，不驱动战斗逻辑
- 特效/音效通过 `GameEvents` 请求，不直接实例化
- 当前玩法分支只实现初始匕首切片，不加入多武器槽、数字键切换或 `Q` 切换
- 脚本超 250 行需在 PR 说明原因
- 代码不引用 `art_src/`，运行时只引用 `assets/`、`resources/`、`scenes/`、`scripts/`

## Git Workflow

- `main`：稳定基线，禁止直接 push
- `develop`：日常集成，当前默认分支
- 分支命名：`feature/<name>`、`fix/<name>`、`art/<name>`、`docs/<name>`
- Commit 格式：`<type>: <short description>`，type 包括 feat/fix/art/vfx/audio/docs/tune/refactor/chore
- PR 需至少 1 人 Review，冻结期需 2 人
- 二进制素材（.aseprite/.png/.wav/.ogg 等）走 Git LFS，.aseprite/.psd/.kra 可 lock
- force push 只允许对自己的功能分支用 `--force-with-lease`

## Input Actions

`move_left`、`move_right`、`jump`、`dash`、`attack`、`skill`、`restart`、`pause`

## Rendering

- 内部分辨率 480×270，整数缩放到 1920×1080
- 渲染器：gl_compatibility
- 像素完美：canvas texture filter=0，snap 2D transforms/vertices to pixel
- 默认清屏色：`Color(0.018, 0.021, 0.033, 1)`（深蓝黑）
