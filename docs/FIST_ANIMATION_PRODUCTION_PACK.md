# Fist Animation Production Pack

本文档用于把“源”的初始拳头动作出图工作变成可直接执行的生产包。目标不是只写风格方向，而是让美术、VFX 或 AI 出图流程能按同一套标准快速产出、筛选、替换运行时动作帧。

当前运行时目标标签：

- `combat_idle`
- `combat_run`
- `punch_1`
- `punch_2`
- `punch_3`
- `punch_skill`

当前代码已经优先接线到这些标签；兼容层仍保留旧 `atk_* / skill` 别名映射用于旧资源回放，但当前活跃拳头 runtime 不再依赖旧终结技动作链。

## 1. 本轮交付目标

本轮只解决一件事：让主角“拳头开局”的动作更有力量感、更流畅、更适合录 Demo。

交付范围：

- 1 套空手战斗待机 `combat_idle`
- 1 套空手追击跑 `combat_run`
- 3 段拳系普攻 `punch_1 / punch_2 / punch_3`
- 1 段拳系位移技 `punch_skill`

不在本轮解决：

- 枪械动作
- 受击和死亡重绘
- 终结技重做
- 多角色共享动作系统

## 2. 文件与导出约定

源文件与导出路径固定如下：

```text
art_src/generated/player_yuan_fist_pass/
  prompts/
  frames/
  strips/

assets/pixel/characters/player_yuan_runtime/frames/
assets/pixel/spr_player_yuan_runtime.png
resources/characters/player_yuan_runtime_frames.tres
```

推荐命名：

```text
art_src/generated/player_yuan_fist_pass/frames/punch_1/frame_01.png
art_src/generated/player_yuan_fist_pass/frames/punch_1/frame_02.png
art_src/generated/player_yuan_fist_pass/frames/punch_1/frame_03.png
```

其中可直接复制的关键帧提示词放在：

```text
art_src/generated/player_yuan_fist_pass/prompts/KEYFRAME_PROMPTS.md
```

逐帧补帧提示词放在：

```text
art_src/generated/player_yuan_fist_pass/prompts/FRAME_BY_FRAME_PROMPTS.md
```

筛图审核表放在：

```text
art_src/generated/player_yuan_fist_pass/prompts/REVIEW_WORKSHEET.md
```

逐帧生产追踪表放在：

```text
art_src/generated/player_yuan_fist_pass/prompts/FRAME_SHOTLIST.csv
```

导出固定规格：

- 单帧画布：`96x96`
- 朝向：只画朝右
- 脚底基准线：`Y = 92`
- 角色中心线：`X = 48`
- 背景：透明
- 缩放：Nearest

## 3. 核心动作原则

### 3.1 力量感

- 每段拳击都必须有蓄力，不允许从站姿直接跳到命中姿势。
- 命中帧必须是轮廓最大的一帧，而不是最乱的一帧。
- 力量来源要从脚、髋、胸腔、肩膀一路送到拳头，而不是只有手臂在动。

### 3.2 流畅度

- 相邻帧重心变化要连续，避免突然上浮或脚底乱跳。
- 收招要能看出惯性被拉住，而不是命中后直接回正。
- 同一个动作里，头部和骨盆的位移方向不能互相打架。

### 3.3 可读性

- 任意抽一帧，都要看得出拳头方向、身体朝向、主受力腿。
- 不允许出现多余手臂、双拳重复、拳头粘在躯干上的问题。
- 残影只能辅助，不得代替本体动作。

### 3.4 角色人格

- “源”的拳系近战不是拳击台规则运动，而是赛博改造体的压迫式近身突入。
- 他不是轻巧花哨路线，重点是前压、逼近、贯穿、压地。

## 4. 推荐出图顺序

建议不要一次性把 70 张全量帧图全生出来，而是按下面顺序推进：

1. `combat_idle` 关键姿势
2. `combat_run` 全套循环
3. `punch_1`
4. `punch_2`
5. `punch_3`
6. `punch_skill`

原因：

- 待机和跑步会先固定角色比例、脚底基准线和拳架高度。
- 三段普攻可以在同一拳架上逐步加大发力。
- 技能动作最后做，最容易吸收前面确定下来的体态语言。

## 5. 动作逐项生产规格

## 5.1 combat_idle

目标：看起来不是普通站立，而是“随时会往前压”的空手战斗架势。

- 帧数：`12`
- FPS：`8`
- 循环：`yes`
- 关键词：呼吸、压肩、前倾、拳架不对称、轻微重心切换

逐帧要求：

当前运行时用 `12` 帧承载这个循环，建议以上面 `8` 个关键姿势为骨架，在姿势切换之间补 4 个缓冲停顿帧，避免呼吸感过快。

| 帧 | 目的 | 动作要求 |
|---|---|---|
| 1 | 主姿势 A | 前脚承重，前手略高，后手收在下巴附近。 |
| 2 | 呼吸下沉 | 肩线轻微下压，胸腔收一格。 |
| 3 | 回弹 | 身体略抬，前拳微前送。 |
| 4 | 主姿势 B | 重心稍向后腿，后肩露出更明显。 |
| 5 | 呼吸下沉 | 骨盆轻压，脚底不能飘。 |
| 6 | 回弹 | 拳架回正，但仍保留攻击性。 |
| 7 | 微前压 | 头部和前肩再轻微前顶。 |
| 8 | 回环 | 回到第一帧前的缓冲状态。 |

验收重点：

- 不要画成发呆站桩。
- 前手后手不能完全对称。
- 髋线和肩线要有轻微反向扭转。

## 5.2 combat_run

目标：这是“追击跑”而不是普通赶路跑，上身仍保持拳架和压迫感。

- 帧数：`10`
- FPS：`12`
- 循环：`yes`
- 关键词：前压、追击、短步频、拳架稳定、头部不乱飘

逐帧节奏：

| 帧段 | 目的 | 动作要求 |
|---|---|---|
| 1-2 | 落地承重 | 前脚先抓地，身体前压，前手别甩丢。 |
| 3-4 | 推进跨步 | 后腿发力送身，骨盆前推。 |
| 5-6 | 另一侧承重 | 左右腿交换，但上身仍维持战斗感。 |
| 7-8 | 回环推进 | 为下一循环保留前冲势能。 |

验收重点：

- 手臂摆动不能大到像田径冲刺。
- 头部上下跳动不能过大。
- 跑步时拳架不能完全散掉。

## 5.3 punch_1

目标：前手刺拳。快、短、准，用来开连段。

- 帧数：`12`
- FPS：`18`
- 关键词：快启快收、短促穿透、前肩送拳

逐帧分工：

| 帧 | 目的 | 动作要求 |
|---|---|---|
| 1 | 起手 | 继承 `combat_idle` 拳架。 |
| 2 | 预备 | 前肩内扣，后脚压地，拳头略收。 |
| 3 | 发力 | 前肩顶出，髋部轻送，前拳开始直线穿出。 |
| 4 | 命中 | 拳头最远、轮廓最干净、胸腔转向最明确。 |
| 5 | 穿透 | 保留半帧延伸感，不能立刻缩回。 |
| 6 | 回收 | 前拳回拉，后手重新回护。 |
| 7 | 收招 | 重心拉回可继续连第二拳的位置。 |
| 8-10 | 回收 | 拳头收回，肩线回落，但身体仍保持前压。 |
| 11-12 | 结束 | 回到可衔接 `punch_2` 的拳架。 |

禁止项：

- 不要画成刀砍角度。
- 不要只动前臂，肩和胸必须参与。
- 命中帧不要缩成一团。

## 5.4 punch_2

目标：后手重直拳或短摆拳，明显比第一段更重。

- 帧数：`12`
- FPS：`18`
- 关键词：转髋、反拉、后手贯穿、躯干扭转

逐帧分工：

| 帧 | 目的 | 动作要求 |
|---|---|---|
| 1 | 接续 | 从 `punch_1` 收招后直接接上。 |
| 2 | 蓄力 | 后肩后拉，前手略收，骨盆反向拧紧。 |
| 3 | 启动 | 后脚蹬地，髋线开始回转。 |
| 4 | 主命中 | 后拳穿出，肩髋联动最强。 |
| 5 | 延伸 | 保留冲透感，拳头方向清晰。 |
| 6 | 制动 | 上身被惯性带前，随后开始刹住。 |
| 7 | 回架 | 后手回护，准备接第三段。 |
| 8-10 | 回收 | 肩髋继续回正，脚下仍有向第三拳压进的趋势。 |
| 11-12 | 过渡 | 重心压到适合重拳收尾的位置。 |

禁止项：

- 不要和 `punch_1` 只是镜像复制。
- 不要失去髋部旋转。
- 不要让两只手同时乱飞。

## 5.5 punch_3

目标：连段收尾重拳，最强重量感的一段。

- 帧数：`14`
- FPS：`16`
- 关键词：大前压、踏步、下砸或重勾、强收势

推荐路线：

- 可选 A：踏步重直拳
- 可选 B：压身下砸拳
- 可选 C：短距离上勾后下压收势

逐帧分工：

| 帧段 | 目的 | 动作要求 |
|---|---|---|
| 1-2 | 读招 | 明显收力，制造“要来重的”预感。 |
| 3-4 | 压步 | 身体前压或下沉，主受力腿确定。 |
| 5 | 启动 | 肩髋同时送出，手肘不要飘。 |
| 6 | 主命中 | 这是全套里最重的一帧，轮廓、压迫感、前压都要最大。 |
| 7 | 延迟 | 允许保留半拍压制感。 |
| 8-9 | 收势 | 身体把惯性吃住，脚底稳。 |
| 10-12 | 落地 | 肩线和骨盆缓慢回正，保留重拳后的压地感。 |
| 13-14 | 结束 | 回到可移动状态。 |

禁止项：

- 不要只有手臂挥大弧线。
- 不要命中后瞬间站直。
- 不要把脚底画飘。

## 5.6 punch_skill

目标：拳系位移技。前半段给速度，后半段给砸实感。

- 帧数：`14`
- FPS：`16`
- 关键词：突进、压近、爆发、残影辅助、本体清晰

推荐结构：

| 帧段 | 目的 | 动作要求 |
|---|---|---|
| 1-2 | 起势 | 压低重心，明显准备突入。 |
| 3-4 | 位移 | 身体拉长，前冲感最强，可配蓝色残影，但本体仍要清晰。 |
| 5-6 | 接触 | 突进接拳、肘击或肩撞，读得出接触点。 |
| 7 | 主命中 | 轮廓最大，打击结果最明确。 |
| 8-9 | 制动 | 把速度收住，不能直接瞬停。 |
| 10-12 | 回收 | 残影淡出，本体姿态重新变清楚。 |
| 13-14 | 回稳 | 回到可继续操作的姿态。 |

禁止项：

- 不要让残影盖住角色本体。
- 不要把技能做成普通跑步加出拳。
- 不要只有速度没有重量。

## 6. 可直接复用的提示词模板

## 6.1 通用主提示词

```text
Create a 2D side-view pixel art playable character animation frame for a cyberpunk machine-crisis action game.
Canvas target: 96x96.
Character: Yuan early clone, agile close-range melee fighter, dark combat outfit, cyan energy accents, one mechanical forearm, no handheld weapon, fists raised in a combat stance.
Animation tag: [combat_idle/combat_run/punch_1/punch_2/punch_3/punch_skill].
Frame index: [01-14].
Frame purpose: [startup/load/launch/contact/extension/recovery/loop].
Motion direction: strong anticipation, powerful body-driven force from legs hips torso shoulders into the fist, stable planted feet, readable torso twist, premium action-game readability, smooth weight transfer, no floaty motion.
Silhouette priority: clear fist direction, readable head torso pelvis rotation, clean contact pose, no duplicated limbs.
Background: transparent background.
Do not include text, watermark, motion-graphic overlays replacing the body, weapon silhouettes, blurry pixels, extra arms, duplicate fists, or painterly anti-aliased edges.
```

## 6.2 punch_1 附加语

```text
This frame belongs to the first jab of a three-hit fist combo.
The motion must feel fast, short, accurate, and aggressive.
The lead shoulder drives the punch forward.
Impact pose must be clean and extended, not cramped.
```

## 6.3 punch_2 附加语

```text
This frame belongs to the second hit of a three-hit fist combo.
It must feel heavier than the first jab, with stronger torso rotation and rear-hand commitment.
The hips and shoulders clearly counter-rotate before impact and unwind through the punch.
```

## 6.4 punch_3 附加语

```text
This frame belongs to the finisher of a three-hit fist combo.
It must feel heavy, oppressive, and committed, with a large forward drive and a strong recovery after impact.
The impact frame should be the most forceful silhouette in the whole combo.
```

## 6.5 punch_skill 附加语

```text
This frame belongs to a dash-in fist skill.
The early frames emphasize explosive forward movement.
The contact frames emphasize weight and collision, not only speed.
Blue afterimages may support speed, but the body must stay readable.
```

## 7. 出图审核清单

每个动作过审前，至少检查这 8 项：

1. 脚底基准线是否稳定。
2. 角色比例是否与现有待机帧一致。
3. 命中帧是否是整套里轮廓最强的一帧。
4. 相邻帧是否存在明显抖动、抽搐或肢体长度突变。
5. 前后手职责是否清楚，不会双手都像主攻手。
6. 是否有多余手臂、拳头复制、肩膀断裂、胯部错位。
7. 收招后是否能自然接下一个动作。
8. 单独抽一帧看，是否仍读得出“这是拳头动作而不是刀动作”。

## 8. 交付最低要求

一轮“可接入”的拳头动作交付，至少包含：

- 每个标签完整逐帧 PNG
- 合成后的 spritesheet
- 每个标签的帧数与 FPS 说明
- 命中帧说明
- 本轮是否通过审核的备注

推荐在 `docs/ASSET_MANIFEST.csv` 里把状态从 `planned` 更新为：

- `in_review`
- `final`

## 9. 与代码接入的关系

当前代码侧已经默认使用拳头武器资源：

- `resources/weapons/initial_fists.tres`
- `resources/attacks/fist_jab_1.tres`
- `resources/attacks/fist_cross_2.tres`
- `resources/attacks/fist_breaker_3.tres`
- `resources/attacks/fist_drive_step.tres`

动作帧继续迭代时，需要同步确认这几件事：

1. 将新条带覆盖到 `art_src/generated/player_yuan_fist_pass/strips/`
2. 重新构建 `assets/pixel/spr_player_yuan_runtime.png`
3. 更新 `resources/characters/player_yuan_runtime_frames.tres`
4. 保持 `punch_* / combat_*` 标签稳定，不再把旧终结技动作链当作当前拳头 runtime 依赖
5. 在 `CHANGELOG.md`、`PROGRESS_LOG.md`、`ASSET_MANIFEST.csv` 记录状态变更

## 10. 推荐执行方式

如果这轮要追求成功率，建议按以下节奏出图：

1. 先每个动作生成 2-3 张关键姿势候选。
2. 从候选里选出一条统一比例和统一拳架的路线。
3. 再补中间帧，而不是先暴力全量生成。
4. 每个动作先审关键帧，再审整套流畅度。
5. 通过后再进 Godot 实机替换测试。

这能显著减少“单帧好看，但整套动作一播就散掉”的情况。

## 11. 实装与清理管线

当新的拳头条带已经导出到：

```text
art_src/generated/player_yuan_fist_pass/strips/
```

按下面顺序执行：

1. 先检查素材是否齐：

```powershell
python .\tools\build_player_yuan_runtime_from_fist_pass.py --check
```

2. 构建新的运行时玩家条带与 SpriteFrames：

```powershell
python .\tools\build_player_yuan_runtime_from_fist_pass.py
```

3. 一键切换玩家场景并清理旧战斗帧：

```powershell
.\tools\deploy_player_yuan_fist_pass.ps1
```

4. 启动本地 Godot 测试：

```powershell
.\tools\run_game_local.ps1
```

说明：

- `deploy_player_yuan_fist_pass.ps1` 会确保玩家场景继续引用 `player_yuan_runtime_frames.tres`
- 新帧接入后，`PlayerAnimationController.gd` 会优先播放真正的 `punch_*` 和 `combat_*` 标签；旧别名只保留给历史资源兼容
