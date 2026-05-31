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
- One mechanical forearm, small magenta warning accents only where needed.
- Keep the silhouette brighter than dark industrial backgrounds.

Avoid text, watermark, fake UI, soft painterly edges, photoreal rendering, extra limbs, unreadable weapon silhouettes, and inconsistent foot placement.

## Runtime Animation Tags

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
- `Player.tscn` references `resources/characters/player_yuan_early_clone_frames.tres`.
- If the runtime spritesheet or an animation tag is missing, the existing Polygon2D graybox fallback remains visible.
- `AttackData.animation_id` maps combat resources to animation tags without changing damage, knockback, cooldown, or Hitbox timing.
- Current runtime wiring covers melee chain, short skill, and Demo ultimate: `atk_1`, `atk_2`, `atk_3`, `skill`, and `ultimate_slam`.
- During the first seven Overdrive Sever blue slashes, `PlayerController` hides `VisualRoot` and shows VFX afterimages instead of a character animation.
