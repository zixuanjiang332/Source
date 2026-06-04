# Pixel Art Bible

本文件只定义统一规格和可读性约束，不决定最终角色长相。角色、敌人、场景、特效的具体设计由团队负责人确认；AI 生成图和动作帧可以直接作为最终素材接入，后续要重绘或替换时再单独提出。

## Visual Theme

关键词：赛博朋克、智械危机、实体钢铁、全息设备、能量刃、电弧、冷色霓虹和红色警戒光。

## Canvas Standards

- Tile: 32x32
- Player: 96x96 canvas, body about 48x72
- Normal enemy: 96x96 or 128x128
- Boss: 192x192
- Item icon: 32x32 and 64x64
- Hit VFX: 64x64 or 96x96
- Skill VFX: 128x128

## Animation Tags

固定标签：

`idle`, `run`, `jump`, `fall`, `dash`, `hit`, `death`, `combat_idle`, `combat_run`, `punch_1`, `punch_2`, `punch_3`, `punch_skill`

## First Asset List

- Player: idle, run, jump, fall, dash, hit, death, combat_idle, combat_run, punch_1, punch_2, punch_3, punch_skill
- Scout Drone: idle, walk, attack, hit, death
- Riot Frame: idle, walk, heavy_attack, hit, death
- Foundry Warden: idle, attack, hit, death
- VFX: hit spark, dash burst, energy cleave, death burst, item pickup
- Tiles: floor, wall, platform, pipe, cable, hologram panel, warning light

## Readability Rules

- 玩家轮廓永远比背景更亮。
- 敌方危险提示优先用红/橙。
- 玩家攻击和移动反馈优先用青蓝。
- 命中特效要短、亮、方向明确，不要持续遮挡敌人。
