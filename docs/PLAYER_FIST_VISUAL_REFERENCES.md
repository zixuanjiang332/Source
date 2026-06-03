# Player Fist Visual References

这份文档记录当前项目里已经落地的“拳头正式重绘参考图”。这些图不是直接切进 runtime 的动画条带，而是用于统一力量方向、姿态层级和终结拳气质。

## 当前参考图

### 1. 拳头连段 9 宫格

文件：

`art_src/generated/player_yuan_fist_pass/visual_refs/yuan_punch_combo_reference_board_v1.png`

用途：

- 对齐 `punch_1 / punch_2 / punch_3` 的重量递进
- 看三段拳的读招、命中、回收层级
- 给 Batch 01 的逐帧重绘提供单帧方向参考

注意：

- 这张图偏“力量概念参考”，不能直接拆成动画帧
- 蓝色能量爆点可以参考冲击感，但正式拳头帧不应让能量特效盖过角色本体

### 2. 终结重拳 1x4

文件：

`art_src/generated/player_yuan_fist_pass/visual_refs/yuan_punch_finisher_reference_strip_v1.png`

用途：

- 强化 `punch_3` 的下沉、爆发、命中、重收势
- 给 `punch_3_02 / 05 / 07` 提供更重的下盘和肩髋联动参考

注意：

- 这张图更适合看终结拳逻辑，不适合直接拿来做 `punch_1` 或 `punch_2`
- 正式 runtime 替换时仍以 `PLAYER_FIST_REDRAW_BATCH_01.md` 的逐帧职责为准

## 推荐使用方式

1. 先看视觉参考图，统一“这一版拳头到底要有多重”
2. 再看 `PLAYER_FIST_REDRAW_BATCH_01.md`，明确要改哪 9 帧
3. 再用 `REDRAW_BATCH_01_FINAL_PROMPTS.md` 逐帧出图
4. 完成后投放到 `redraw_batches/batch_01/`，用替换脚本压回 runtime
