# Game Framework

## Demo Direction

本 Demo 是赛博朋克智械危机题材的 2D 像素动作垂直切片。目标不是先做完整肉鸽，而是先完成一条可以录出高质量演示的战斗路线。

具体游戏内容、像素图风格和特效设计由团队人工策划与绘制。本仓库先提供可协作的开发骨架、数据接口和文档规范。

## Runtime Architecture

- `GameEvents`: 全局事件总线，负责生命/能量、VFX、SFX、镜头震动、敌人死亡和重开请求。
- `InputBootstrap`: 启动时注册默认输入，避免空项目缺少 InputMap。
- `CharacterStats`: 角色数值 Resource，玩家、普通敌人、Boss 共用。
- `AttackData`: 攻击数据 Resource，统一伤害、击退、命中停顿、VFX、SFX。
- `WeaponData`: 当前武器数据 Resource，保存武器 ID、显示名、普攻链、Demo 技能攻击和 HUD 名称。
- `Hitbox` / `Hurtbox`: 所有攻击命中都走这两个 Area2D。
- `VfxCatalog`: 通过 `vfx_id` 查找特效场景，便于后续替换为正式帧动画或粒子效果。

## Current Scene Flow

`Main.tscn` 加载 `DemoLevel.tscn`、`Hud.tscn` 和 `VfxSpawner`。玩家相机跟随主角，关卡内放置侦察机、重装机体和 Boss 展示单位。

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
