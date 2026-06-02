# Yuan Fist Pass Keyframe Prompts

这些提示词用于先生成关键姿势候选，再决定是否补完整中间帧。默认画布统一为 `96x96`，透明背景，角色朝右。

通用要求默认追加：

```text
2D side-view pixel art playable character animation frame, cyberpunk machine-crisis action game, 96x96 canvas, Yuan early clone, dark combat outfit, cyan energy accents, exactly one cybernetic right forearm and right hand, left arm fully human, no handheld weapon, transparent background, readable silhouette, clean pixels, no text, no watermark, no extra limbs, no duplicate fists, no second mechanical arm, no robotic left arm, no blurry pixels, no painterly anti-aliased edges.
```

## combat_idle

### idle_a

```text
Create a combat idle keyframe for Yuan early clone.
He is in an aggressive unarmed combat stance, slightly leaning forward, front shoulder raised, rear hand guarding the jaw, asymmetrical fists, stable planted feet, subtle torso twist, ready to pressure forward, premium action-game readability.
```

### idle_b

```text
Create a second combat idle keyframe for Yuan early clone.
Shift the weight slightly toward the back leg while keeping the upper body ready to spring forward, fists still raised, shoulders compressed, hips and shoulders subtly counter-rotated, not a neutral standing pose.
```

## combat_run

### run_contact

```text
Create a combat run contact frame for Yuan early clone.
This is not a normal jogging frame; it is a chase-forward combat run with the torso angled forward, compact fist guard, one foot planted firmly on the ground, the body driving ahead with pressure and intent.
```

### run_push

```text
Create a combat run push-off frame for Yuan early clone.
The rear leg is driving the body forward, hips pushing ahead, upper body still in a controlled fight-ready posture, fists compact, head stable, no exaggerated sports-running arm swing.
```

## punch_1

### punch_1_load

```text
Create the load-up keyframe for punch_1, the first jab of Yuan's three-hit fist combo.
The lead shoulder tucks in, the body compresses slightly, the rear foot loads force, the lead fist pulls back just enough to feel like a fast short jab is about to fire.
```

### punch_1_contact

```text
Create the impact keyframe for punch_1, the first jab of Yuan's three-hit fist combo.
The lead fist snaps forward in a clean straight line, the shoulder drives the punch, the torso rotates just enough for force, the silhouette is extended and clean, fast short accurate aggressive punch.
```

## punch_2

### punch_2_load

```text
Create the load-up keyframe for punch_2, the second hit of Yuan's three-hit fist combo.
This attack is heavier than punch_1, with the rear shoulder pulled back, hips coiled, front hand guarding, torso visibly twisted and storing rotational force.
```

### punch_2_contact

```text
Create the impact keyframe for punch_2, the second hit of Yuan's three-hit fist combo.
The rear hand drives through with strong torso rotation, hips and shoulders unwinding together, the punch feels heavier and more committed than the first jab, clear direction, clean silhouette, strong body-driven force.
```

## punch_3

### punch_3_load

```text
Create the load-up keyframe for punch_3, the finisher of Yuan's three-hit fist combo.
This pose must signal a heavy final blow: deeper compression, stronger forward pressure, one leg clearly bearing force, shoulders loaded for a committed finishing strike.
```

### punch_3_contact

```text
Create the impact keyframe for punch_3, the finisher of Yuan's three-hit fist combo.
This is the heaviest punch in the combo, with maximum pressure, strong forward drive, powerful committed body mechanics, the most forceful silhouette in the chain, readable impact, no floaty posing.
```

### punch_3_recovery

```text
Create the recovery keyframe for punch_3, the finisher of Yuan's three-hit fist combo.
The strike has landed hard and the body is catching its own momentum, feet still grounded, shoulders settling, posture still dangerous instead of relaxed, readable heavy follow-through.
```

## punch_skill

### punch_skill_start

```text
Create the startup keyframe for punch_skill, Yuan's dash-in fist skill.
He is lowering his center of gravity and preparing to burst forward, both fists tight, aggressive forward intent, visible stored momentum, powerful anticipation.
```

### punch_skill_dash

```text
Create the dash phase keyframe for punch_skill, Yuan's dash-in fist skill.
The body is stretched into explosive forward movement, fast and sharp, blue afterimage support is allowed but the main body must remain readable, strong forward momentum, premium action-game speed.
```

### punch_skill_contact

```text
Create the contact keyframe for punch_skill, Yuan's dash-in fist skill.
The movement resolves into a heavy close-range strike, emphasizing collision weight and body impact, not just speed, clean silhouette, clear torso and pelvis rotation, strong hit readability.
```

## 使用建议

建议流程：

1. 每个动作先生成 `load/contact` 或 `contact/recovery` 两到三种候选。
2. 选出同一条比例、拳架、脚底基准线最稳定的路线。
3. 再围绕选中的关键帧补中间帧。
4. 最后统一导出到 `strips/` 并接 Godot。
