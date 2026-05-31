# Game Framework

## Demo Direction

本 Demo 是赛博朋克智械危机题材的 2D 像素动作垂直切片。目标不是先做完整肉鸽，而是先完成一条可以录出高质量演示的战斗路线。

具体游戏内容、像素图风格和特效设计由团队策划与确认；素材可以由人工绘制，也可以由 AI 生成图或动作帧直接作为 final 接入。本仓库先提供可协作的开发骨架、数据接口和文档规范。

## Runtime Architecture

- `GameEvents`: 全局事件总线，负责生命/能量、VFX、SFX、镜头震动、敌人死亡和重开请求。
- `InputBootstrap`: 启动时注册默认输入，避免空项目缺少 InputMap。
- `CharacterStats`: 角色数值 Resource，玩家、普通敌人、Boss 共用。
- `AttackData`: 攻击数据 Resource，统一伤害、击退、命中停顿、VFX、SFX，并可通过 `animation_id` 映射角色攻击动画。
- `WeaponData`: 当前武器数据 Resource，保存武器 ID、显示名、普攻链、Demo 技能攻击和 HUD 名称。
- `Hitbox` / `Hurtbox`: 所有攻击命中都走这两个 Area2D。
- `VfxCatalog`: 通过 `vfx_id` 查找特效场景，便于后续替换为正式帧动画或粒子效果。
- `PlayerAnimationController`: 玩家动画桥接层，正式 spritesheet 缺失或动画标签缺失时回退到灰盒视觉。

## Current Scene Flow

`Main.tscn` 启动时只显示标题菜单和空 `GameRoot`。标题菜单使用脸部主题 AI final 图，点击“开始游戏”后才动态创建 `VfxSpawner`、`Hud.tscn` 和 `DemoLevel.tscn`，进入实验室到城市的演示路线。这样标题页不会提前显示正式关卡、HUD、玩家或动态背景。

当前“源”的概念图已全量导出到 `assets/pixel/characters/yuan/`。运行时玩家使用 `assets/pixel/spr_player_yuan_early_clone.png` 和 `resources/characters/player_yuan_early_clone_frames.tres` 播放 `idle/run/jump/fall/dash/atk_1/atk_2/atk_3/skill/hit/death`。HUD 使用 `portrait_yuan_stage_01.png`，初始匕首 HUD 图标使用 `icon_initial_dagger.png`。

玩家视觉缩放为 70%，相机 `zoom` 为 `0.65`，用于大幅放宽录屏视距。Demo 关卡使用不可见边界限制玩家离开路线，并通过相机 `limit_*` 避免显示明显地图外空白。

## Dynamic Background

背景使用全拆 tiles/props 的结构，不做全屏帧序列。`DemoLevel.tscn` 内的背景层固定为：

- `Background/LabStaticTiles`
- `Background/LabAnimatedProps`
- `Background/CityFar`
- `Background/CityMid`
- `Background/CityAnimatedProps`
- `Background/CityForegroundDecor`

所有循环背景动画挂 `AnimatedBackgroundProp`。该脚本只更新 Sprite2D 的 `region_rect`、位置循环和帧序，不参与碰撞、交互、战斗或关卡目标逻辑。正式美术导出后，替换节点 texture 并按素材规格填写 `frame_size`、`frame_count`、`fps` 和 `columns`。

当前实验室段已切换到 `assets/pixel/background/lab/` 的 AI final 背景 tiles/props，用来验证动态背景管线和运行时接入。城市高架段仍保留 placeholder sheet，等待后续同流程替换。

## Current Combat Slice

当前玩法只精修第一把近战武器“匕首”。`resources/weapons/initial_dagger.tres` 绑定三段普攻和一个 Demo 能量技：

- `dagger_cut_1`: 快速起手，用来接近和确认命中。
- `dagger_cut_2`: 反手追击，延续短硬直。
- `dagger_cut_3`: 连段收尾，击退和停顿更明显。
- `dagger_flash_step`: Demo 用能量突进斩，用于展示位移收尾和 HUD 技能状态。

玩家 HUD 通过 `GameEvents.player_weapon_changed`、`player_energy_changed` 和 `player_combo_changed` 显示武器名、能量、技能状态和连段。UI 只监听事件，不驱动战斗逻辑。

本阶段不做 1/2/3 武器槽、`Q` 切换、远程武器或正式多武器主技能框架。等初始匕首路线稳定并接入正式动画后，再抽象完整武器系统。

## What Not To Build Yet

- 不做完整随机地图生成。
- 不做永久存档和复杂元成长。
- 不做多主角、多武器库。
- 不做多武器槽、快速切换和远程武器框架。
- 不做完整商店、NPC 和剧情系统。

这些都等 8 月 15 日 Demo 稳定后再扩展。
