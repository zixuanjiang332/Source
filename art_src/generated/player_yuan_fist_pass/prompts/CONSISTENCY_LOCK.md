# Yuan Fist Pass Consistency Lock

本文档用于锁定“源”在拳头开局动作中的统一外观。目标是减少 AI 出图时出现的这些问题：

- 同一个动作里脸型和发型每帧都变
- 机械臂左右乱换
- 肩宽、腿长、头身比漂移
- 待机、跑步、出拳看起来像三个不同角色

## 1. 角色固定设定

- 角色：源 early clone
- 视角：2D side-view，严格侧视
- 朝向：只画朝右
- 画布：`96x96`
- 身体可读区域：约 `48x72`
- 脚底基准线：`Y = 92`
- 头部中心大致落在 `Y = 26 ~ 30`

## 2. 外观锁定

- 黑色偏乱短发，轮廓尖锐，不要长发、马尾、披肩发
- 只有右臂前臂和右手是机械义体，左臂必须保持正常人类手臂
- 机械义体必须固定在右侧，不能一帧右边一帧左边
- 深色短款战斗外套，不能变成长风衣
- 深色裤装和短靴，腿部比例不要忽长忽短
- 青蓝色能量发光点只做点缀，不要扩成大面积荧光块
- 少量洋红警示色可以保留，但必须是辅色

## 3. 轮廓锁定

- 头部大小在所有动作中基本一致
- 肩宽和骨盆宽度比例稳定
- 前臂长度、上臂长度和小腿长度不允许每帧明显漂移
- 拳架高度保持在胸口到下巴区间，不要忽高忽低

## 4. 战斗姿态锁定

- 默认拳架是“前压型”，不是拳击比赛的大幅弹跳架势
- 待机、跑步、出拳都必须保留攻击性
- 前手负责试探和开路，后手负责保护和重击
- 任何动作都不能把手臂摆成持刀动作语言

## 5. 出图时建议固定加入的附加描述

```text
Keep the same character proportions, same hairstyle silhouette, the same cybernetic right forearm and right hand, the same fully human left arm, the same shoulder width, the same leg length, the same dark cropped combat jacket, the same cyan accent placement, and the same planted foot baseline as the rest of Yuan's fist animation set.
```

## 6. 负面约束

每次出图建议额外排除：

```text
Do not change the side of the mechanical arm, do not turn the left arm into metal, do not add a second mechanical arm, do not add a weapon, do not change the hairstyle, do not turn the jacket into a long coat, do not enlarge the head, do not shorten the legs, do not create duplicate fists, do not create extra arms, do not switch to a three-quarter view.
```

## 7. 审核时优先看什么

如果某张图动作很好看，但出现以下任意情况，优先判返修：

- 机械臂换边
- 左臂被画成机械臂
- 发型轮廓明显变了
- 身材比例与前一帧差太多
- 侧视变成了斜视角
- 拳架语言突然像拿刀或拿枪

## 8. 推荐搭配

本文件应与以下文件一起使用：

- `KEYFRAME_PROMPTS.md`
- `FRAME_BY_FRAME_PROMPTS.md`
- `FRAME_SHOTLIST.csv`
- `REVIEW_WORKSHEET.md`
- `YUAN_APPEARANCE_LOCK.md`

建议流程：

1. 先用 `YUAN_APPEARANCE_LOCK.md` 锁定右臂机械、左臂人类的硬设定。
2. 再用 `CONSISTENCY_LOCK.md` 锁人物比例和轮廓。
3. 再用关键帧或逐帧提示词生成动作。
4. 最后用审核表检查动作与外观是否同时成立。
