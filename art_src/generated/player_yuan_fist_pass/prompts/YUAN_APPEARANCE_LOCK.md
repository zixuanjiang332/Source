# Yuan Appearance Lock

本文档专门锁定主角“源”在拳头开局动作中的外貌、体型和机械改造位置。

当前最重要的修正点只有一个：

- 源不是双机械臂角色
- 只有右臂前臂和右手是机械义体
- 左臂必须保持正常人类手臂外观

如果 AI 把左臂也画成机械臂，或者把两只手都画成金属拳套，这张图默认判定为不合格。

## 1. 中文主提示词

```text
2D 横版侧视像素动作游戏角色单帧，96x96 画布，主角“源” early clone，严格朝右，黑色凌乱短发，偏瘦但有爆发力的青年男性体型，窄脸，深色短款战斗外套，深色长裤，短靴，少量青蓝色能量点缀，右臂前臂和右手是机械义体，左臂必须保持正常人类手臂，空手格斗姿态，没有武器，没有第二只机械臂，没有双机械拳套，脚底基准线稳定，轮廓清晰，可直接用于动作游戏角色帧。
```

## 2. English Master Prompt

```text
2D side-view pixel art playable character animation frame, 96x96 canvas, Yuan early clone, facing right only, messy short black hair, lean young male fighter build, narrow face, dark cropped combat jacket, dark pants, short boots, restrained cyan accent lights, exactly one cybernetic right forearm and right hand, left arm fully human, unarmed close-range combat stance, no weapon, no second mechanical arm, no twin robotic fists, stable planted foot baseline, clean readable silhouette, crisp pixel art, no text, no watermark.
```

## 3. 强制补充句

每次出图建议把下面这句一起附加：

```text
The right forearm and right hand are mechanical. The left arm is fully human. Do not turn the left arm into metal, armor, or a second cybernetic limb.
```

## 4. 负面提示词

```text
No second mechanical arm, no robotic left arm, no symmetrical metal gauntlets, no twin cybernetic fists, no full-body armor conversion, no shoulder-mounted weapons, no sword, no gun, no long coat, no cape, no extra limbs, no duplicate fists, no three-quarter view, no front view, no painterly rendering, no blurry pixels.
```

## 5. 外观锚点

- 发型：黑色、凌乱、短发、尖锐轮廓
- 体型：轻量、敏捷、不是重甲壮汉
- 脸部：年轻、冷峻、不要大叔脸
- 外套：短款，不是风衣，不拖地
- 机械改造：仅右前臂和右手
- 左臂：正常人类手臂，允许手套，但不能金属化
- 配色：深灰黑主体，青蓝点缀，少量洋红警示色

## 6. 审核红线

出现以下任意一种，直接返修：

- 左臂也变成机械臂
- 两只手都像金属拳套
- 机械臂从右边变到左边
- 外套变成长风衣或披风
- 体型突然变成重甲角色
- 侧视变成斜视角

## 7. 推荐搭配

本文件应与以下文件一起使用：

- `CONSISTENCY_LOCK.md`
- `KEYFRAME_PROMPTS.md`
- `FRAME_BY_FRAME_PROMPTS.md`
- `REDRAW_BATCH_01_FINAL_PROMPTS.md`

