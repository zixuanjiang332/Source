# Player Animation Spec - Yuan Early Clone

本规格定义主角“源”早期克隆体第一轮正式像素动画交付要求。本轮使用 AI 生成帧作为 `final` 运行时素材接入，并保留原始条带和逐帧 PNG 便于后续人工精修或替换。

## Asset Targets

- Source strips: `art_src/generated/player_yuan_early_clone/strips/`
- Runtime export: `assets/pixel/spr_player_yuan_early_clone.png`
- Runtime frames: `assets/pixel/characters/player_yuan_early_clone/frames/`
- Godot SpriteFrames: `resources/characters/player_yuan_early_clone_frames.tres`
- Canvas: `96x96` per frame
- Facing: draw facing right only; Godot flips `VisualRoot.scale.x`
- Origin guide: character center `X=48`, foot baseline `Y=92`
- Background: transparent
- Godot import: nearest-neighbor pixel art, no filtering

## Character Direction

- Early clone body of Yuan.
- Black messy short hair, short dark combat jacket, dark pants and boots.
- Cyan-blue glowing collar/trim and readable player-friendly energy accents.
- Exactly one cybernetic right forearm and right hand. The left arm must stay fully human.
- Small magenta warning accents only where needed.
- Keep the silhouette brighter than dark industrial backgrounds.

Avoid text, watermark, fake UI, soft painterly edges, photoreal rendering, extra limbs, unreadable weapon silhouettes, and inconsistent foot placement.

## Motion Goals

后续所有主角动作帧都优先追求这四件事：

- 力量感：每段攻击必须有清楚的预备、接触和收招，不要从站姿直接瞬移到命中姿势。
- 流畅度：相邻帧的重心、肩线、髋线和脚底位置要连续，避免抖动式“抽帧感”。
- 命中可读性：命中帧必须是轮廓最大、方向最明确、肢体最舒展的一帧。
- 角色人格：源的近战不是轻飘飘的小刀划线，而是带前压、带身体驱动的近身爆发。

## Current Runtime Animation Tags

| Tag | Frames | FPS | Loop | Notes |
|---|---:|---:|---|---|
| `idle` | 6 | 8 | yes | Subtle breathing; weapon held low. |
| `run` | 8 | 12 | yes | Stable foot baseline; readable forward lean. |
| `jump` | 3 | 10 | no | Takeoff / rising pose; hold final frame in air if needed. |
| `fall` | 3 | 10 | yes | Downward pose with coat trailing upward. |
| `dash` | 5 | 18 | no | Cyan motion emphasis; body compressed forward. |
| `atk_1` | 6 | 18 | no | Light melee cut; hit frame 3. |
| `atk_2` | 6 | 18 | no | Reverse cut; hit frames 3-4. |
| `atk_3` | 8 | 16 | no | Heavy breaker cut; hit frames 4-5. |
| `skill` | 10 | 14 | no | Energy cleave; hit frames 5-7. |
| `ultimate_slam` | 8 | 16 | no | Red two-hand downward slam; only visible for final hit of Overdrive Sever. |
| `hit` | 3 | 12 | no | Short recoil; preserve silhouette. |
| `death` | 8 | 10 | no | Collapse/offline; hold final frame. |

## Fist Pass Targets

这是下一轮优先生成并替换到运行时的拳头版动作标签。当前代码已经接线完成；在这些新标签缺失前，会自动回退到旧的 `atk_*` / `skill` 动画，保证项目可运行。

逐动作的生产顺序、逐帧职责、提示词附加语和审核清单，统一以 `FIST_ANIMATION_PRODUCTION_PACK.md` 为准。

| Tag | Frames | FPS | Loop | Intent |
|---|---:|---:|---|---|
| `combat_idle` | 8 | 8 | yes | 空手战斗架势，肩膀前顶，双拳不对称，随时能压上去。 |
| `combat_run` | 10 | 12 | yes | 保持上身前倾和拳架，不是普通跑步，要有追击感。 |
| `punch_1` | 12 | 18 | no | 快速前手刺拳；1-3 帧预备，6 帧命中，9-12 帧回收。 |
| `punch_2` | 12 | 18 | no | 后手直拳或摆拳；躯干旋转更大，命中时肩髋联动明显。 |
| `punch_3` | 14 | 16 | no | 重拳收尾；允许更大前压和更长收招，命中帧要最有重量。 |
| `punch_skill` | 14 | 16 | no | 位移接重击的拳系技能，可做冲步炮拳或肘膝爆发。 |

## Fist Pass Frame Rules

- `punch_1`: 手短、快、狠。不要画成刀砍路线，重点是肩膀送拳和拳头穿透。
- `punch_2`: 与第一段方向不同，避免“同一拳复制三次”。最好有明显转髋和反向拉扯。
- `punch_3`: 作为收尾，允许更重的压地、踏步、下砸或勾拳爆发，但脚底仍要稳定。
- `punch_skill`: 必须同时解决位移和打击。前半段给速度，后半段给接触重量。
- 每段攻击至少要有 1 帧明显的 stretch / extension，和 1 帧明显的 settle / recovery。
- 命中帧不要糊成一团，拳头、前臂、头部朝向和胸腔扭转必须读得出来。
- 如果加入残影，只能辅助速度感，不能替代角色本体动作本身。
- 不要用简单复制帧来凑帧数；新增帧必须补出真实的重心、肩线、髋线或接触变化。

## Pistol Animation Reservations

These tags are reserved for a future handgun pass and are not wired to runtime gameplay in this round.

| Tag | Frames | Notes |
|---|---:|---|
| `pistol_idle` | 6 | Standing aim-ready pose. |
| `pistol_run` | 8 | Run with pistol controlled near torso. |
| `pistol_jump` | 3 | Airborne pistol-ready pose. |
| `pistol_fall` | 3 | Falling pistol-ready pose. |
| `pistol_dash` | 5 | Dash with pistol tucked close. |
| `pistol_shoot` | 5 | Ground muzzle flash pose; no projectile art in this round. |
| `pistol_air_shoot` | 5 | Air shooting pose; no projectile art in this round. |

## Runtime Notes

- `PlayerAnimationController` plays the tags above through `AnimatedSprite2D`.
- `Player.tscn` now references `resources/characters/player_yuan_runtime_frames.tres`.
- If the runtime spritesheet or an animation tag is missing, the existing Polygon2D graybox fallback remains visible.
- `AttackData.animation_id` maps combat resources to animation tags without changing damage, knockback, cooldown, or Hitbox timing.
- Current runtime wiring now targets fist-first combat tags `punch_1`, `punch_2`, `punch_3`, and `punch_skill`. `PlayerAnimationController` now prefers real `combat_* / punch_*` animations and only falls back to `idle/run/atk_*/skill` if a new tag is missing.
- During the first seven Overdrive Sever blue slashes, `PlayerController` hides `VisualRoot` and shows VFX afterimages instead of a character animation.
