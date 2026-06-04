# Player Fist Strip Export Spec

本文档定义“源”拳头开局动作的正式导出规格。目标是让后续更高质量动作帧可以直接替换当前活跃 runtime 资源，而不用再改代码或手动重接节点。

## 1. 当前状态

当前项目已经实装并接入一版活跃拳头 runtime：

- `assets/pixel/spr_player_yuan_runtime.png`
- `resources/characters/player_yuan_runtime_frames.tres`

其中 `idle/run/jump/fall/dash/hit/death` 和 `combat_* / punch_*` 全部来自当前 `player_yuan_fist_pass` 条带。

后续正式高质量拳头动作，只需要替换条带输入，不要改运行时文件名和标签名。

## 2. 固定目录

正式导出条带时，统一覆盖到：

```text
art_src/generated/player_yuan_fist_pass/strips/
```

绘制时可以直接参考或覆盖这些模板：

```text
art_src/generated/player_yuan_fist_pass/templates/
```

如果想在当前活跃拳头动作上直接重绘，而不是从空白模板起稿，可使用：

```text
art_src/generated/player_yuan_fist_pass/paintover_guides/
```

这组 guide 会保留当前运行时拳头帧的体块、节奏和脚底基准线，适合快速做正式版本覆盖。

运行这条命令后会自动重建并更新运行时资源：

```powershell
python .\tools\build_player_yuan_runtime_from_fist_pass.py
.\tools\deploy_player_yuan_fist_pass.ps1
```

## 3. 固定文件名

必须使用这些名字：

```text
idle.png
run.png
jump.png
fall.png
dash.png
hit.png
death.png
combat_idle.png
combat_run.png
punch_1.png
punch_2.png
punch_3.png
punch_skill.png
```

说明：

- `idle/run/jump/fall/dash/hit/death` 是无武器运行时基础动作
- `combat_idle/combat_run/punch_*` 是拳头战斗态动作
- 名字不能改，否则构建脚本不会自动接上

## 4. 单帧规格

- 画布：`96x96`
- 朝向：朝右
- 背景：透明
- 脚底基准线：`Y = 92`
- 角色中心：尽量围绕 `X = 48`
- 导出：Nearest，不要线性过滤

## 5. 每张条带的帧数与顺序

| 文件 | 帧数 | FPS | 说明 |
|---|---:|---:|---|
| `idle.png` | 12 | 8 | 无武器基础站立 |
| `run.png` | 8 | 12 | 无武器基础跑动 |
| `jump.png` | 3 | 10 | 无武器跳跃 |
| `fall.png` | 3 | 10 | 无武器下落 |
| `dash.png` | 5 | 18 | 无武器冲刺 |
| `hit.png` | 3 | 12 | 无武器受击 |
| `death.png` | 8 | 10 | 无武器死亡 |
| `combat_idle.png` | 12 | 8 | 拳架待机 |
| `combat_run.png` | 10 | 12 | 拳架追击跑 |
| `punch_1.png` | 12 | 18 | 前手快拳 |
| `punch_2.png` | 12 | 18 | 后手重拳 |
| `punch_3.png` | 14 | 16 | 连段收尾重拳 |
| `punch_skill.png` | 14 | 16 | 冲刺接重击 |

条带顺序要求：

- 横向排列
- 从左到右递增
- 不要留空列
- 每格都必须是 `96x96`

## 6. 导出尺寸

| 文件 | 宽 x 高 |
|---|---|
| `idle.png` | `1152 x 96` |
| `run.png` | `768 x 96` |
| `jump.png` | `288 x 96` |
| `fall.png` | `288 x 96` |
| `dash.png` | `480 x 96` |
| `hit.png` | `288 x 96` |
| `death.png` | `768 x 96` |
| `combat_idle.png` | `1152 x 96` |
| `combat_run.png` | `960 x 96` |
| `punch_1.png` | `1152 x 96` |
| `punch_2.png` | `1152 x 96` |
| `punch_3.png` | `1344 x 96` |
| `punch_skill.png` | `1344 x 96` |

## 7. 正式替换流程

当更高质量正式帧已经导出后，按这个顺序替换：

1. 覆盖 `art_src/generated/player_yuan_fist_pass/strips/`
2. 运行：

```powershell
python .\tools\build_player_yuan_runtime_from_fist_pass.py --check
python .\tools\build_player_yuan_runtime_from_fist_pass.py
.\tools\deploy_player_yuan_fist_pass.ps1
```

3. 测试：

```powershell
.\tools\run_game_local.ps1
```

## 8. 验收要点

正式拳头条带替换当前运行时资源时，至少确认：

1. 待机和跑步不再带旧光刀轮廓
2. `punch_1 / punch_2 / punch_3` 力量层级明显递增
3. `punch_skill` 是“突进接重击”，不是刀式挥斩
4. 玩家轮廓、脚底基准线、头身比稳定
5. 进入游戏后可正常移动、跳跃、冲刺、普攻和技能

## 9. 与当前目标的关系

这份规格的作用不是替代美术设计，而是保证：

- 你继续生成更优秀的帧图时，不会再卡在接入层
- 删除旧废弃帧后，新的正式帧能直接接管 runtime
- 游戏测试可以反复快速迭代，而不是每次重新拼工程
