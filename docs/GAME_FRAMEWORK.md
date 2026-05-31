# Game Framework

## Demo Direction

本 Demo 是赛博朋克智械危机题材的 2D 像素动作垂直切片。目标不是先做完整肉鸽，而是先完成一条可以录出高质量演示的战斗路线。

具体游戏内容、像素图风格和特效设计由团队人工策划与绘制。本仓库先提供可协作的开发骨架、数据接口和文档规范。

## Runtime Architecture

- `GameEvents`: 全局事件总线，负责生命/能量、VFX、SFX、镜头震动、敌人死亡和重开请求。
- `InputBootstrap`: 启动时注册默认输入，避免空项目缺少 InputMap。
- `CharacterStats`: 角色数值 Resource，玩家、普通敌人、Boss 共用。
- `AttackData`: 攻击数据 Resource，统一伤害、击退、命中停顿、VFX、SFX。
- `Hitbox` / `Hurtbox`: 所有攻击命中都走这两个 Area2D。
- `VfxCatalog`: 通过 `vfx_id` 查找特效场景，便于后续替换为正式帧动画或粒子效果。

## Current Scene Flow

`Main.tscn` 加载 `DemoLevel.tscn`、`Hud.tscn` 和 `VfxSpawner`。玩家相机跟随主角，关卡内放置侦察机、重装机体和 Boss 展示单位。

## What Not To Build Yet

- 不做完整随机地图生成。
- 不做永久存档和复杂元成长。
- 不做多主角、多武器库。
- 不做完整商店、NPC 和剧情系统。

这些都等 8 月 15 日 Demo 稳定后再扩展。
