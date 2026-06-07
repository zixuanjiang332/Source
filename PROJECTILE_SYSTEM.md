# 子弹系统实现说明

## 概述

实现了基于实体投射物（Projectile）的子弹系统，替代原有的 hitscan 即时命中机制。子弹以小方块作为视觉表现，不同武器有不同颜色。

## 新增文件

### 1. `scripts/combat/Projectile.gd`
子弹投射物核心逻辑：
- 飞行：沿 facing 方向以恒定速度移动
- 命中检测：通过 Area2D 监听 hurtbox 碰撞
- 穿透：支持 `pierce_count` 参数控制穿透目标数
- 生命周期：`lifetime` 后自动销毁
- 碰撞墙壁：撞到 world/obstacles 组的实体后销毁
- `set_projectile_color()` — 设置子弹颜色

### 2. `scenes/combat/Projectile.tscn`
子弹场景：Area2D + CollisionShape2D（12×6 矩形）+ ColorRect（可变色小方块）

## 修改文件

### `scripts/resources/WeaponData.gd`
新增 4 个 export 字段：
- `projectile_speed: float = 800.0` — 子弹飞行速度
- `projectile_lifetime: float = 1.5` — 子弹最大存活时间
- `projectile_texture: Texture2D` — 自定义子弹纹理（可选，当前未使用）
- `projectile_color: Color = Color(1, 1, 0, 1)` — 子弹颜色

### `scripts/player/PlayerController.gd`
- 新增 `_auto_fire_timer` 和 `_auto_firing` 变量，支持长按自动开火
- 新增 `_weapon_uses_projectile()` 判断是否使用投射物模式
- 修改 `_try_ranged_attack()` 根据攻击模式分发到 hitscan 或 projectile
- 新增 `_fire_projectile_attack()` 实例化并发射子弹（含颜色设置）
- 新增 `_on_projectile_hit_target()` 处理子弹命中后的能量回复和被动效果
- 新增 `_weapon_projectile_speed()` 和 `_weapon_projectile_lifetime()` 辅助方法
- 新增 `_tick_auto_fire()` 实现长按连射
- 新增 `_get_weapon_fire_interval()` 根据武器攻速计算射击间隔

### `resources/weapons/pistol.tres`
- `attack_mode` 从 `hitscan` 改为 `projectile`
- 添加 `projectile_speed = 650.0`
- 添加 `projectile_lifetime = 1.2`
- 添加 `projectile_color = Color(1, 1, 0.3, 1)`（淡黄色）

### `resources/weapons/next_gen.tres`
- `attack_mode` 从 `hitscan` 改为 `projectile`
- 添加 `projectile_speed = 900.0`
- 添加 `projectile_lifetime = 1.0`
- 添加 `projectile_color = Color(0.4, 0.8, 1, 1)`（雷属性蓝色）

### `resources/weapons/surge.tres`
- `attack_mode` 从 `hitscan` 改为 `projectile`
- 添加 `projectile_speed = 700.0`
- 添加 `projectile_lifetime = 1.3`
- 添加 `projectile_color = Color(0.2, 0.6, 1, 1)`（水属性深蓝色）

### `docs/PROGRAMMING_STANDARDS.md`
- 碰撞层新增 Layer 32: Projectile（子弹/投射物）

## 使用方法

### 让武器使用子弹系统

1. 在 WeaponData 资源中设置 `attack_mode = &"projectile"`
2. 配置 `projectile_speed`（推荐 600-900）
3. 配置 `projectile_lifetime`（推荐 1.0-1.5）
4. 配置 `projectile_color` 区分不同武器（默认黄色）

### 长按自动开火

- 对远程武器（`weapon_type = &"ranged"` 或 `attack_mode = &"projectile"`），长按鼠标左键会自动连续射击
- 射击间隔由武器的 `attack_speed_rating` 和 `attack_speed_scale` 决定
- 近战武器（拳头、匕首等）不触发自动开火

### 为攻击数据添加特殊效果

AttackData 的字段（vfx_id, sfx_id, screen_shake 等）在子弹命中时同样生效。

## 技术细节

- 子弹碰撞层使用 Layer 32，只检测 Layer 4（Hurtbox）
- 子弹命中后通过 signal 通知 PlayerController，保证能量回复、被动效果等逻辑正确触发
- 穿透逻辑：每命中一个目标计数+1，达到 `pierce_count` 后销毁
- 冲击波弹（empowered shot）临时提升穿透数到 5
- 自动开火在 `_tick_auto_fire()` 中实现，每帧检测是否满足开火条件

## 武器区分

| 武器 | 子弹颜色 | 速度 | 特点 |
|------|----------|------|------|
| 手枪 | 淡黄 `#FFFF4D` | 650 | 高射速，低伤害 |
| 次世代 | 雷蓝 `#66CCFF` | 900 | 最快，冲击波弹 |
| 澎湃 | 水蓝 `#3399FF` | 700 | 穿甲，血量百分比伤害 |

## 待办事项

- [ ] 添加子弹拖尾特效（不同颜色粒子）
- [ ] 为次世代冲击波弹添加特殊视觉效果（更大、发光）
- [ ] 为澎湃穿甲弹添加穿透视觉反馈
- [ ] 考虑为不同武器添加不同大小的子弹
