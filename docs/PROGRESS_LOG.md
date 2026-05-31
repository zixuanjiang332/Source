# 进度记录

本文档按周记录团队进展，不做每日流水账。每周例会或阶段合并后更新一次。

## 状态标记

- `Todo`: 尚未开始。
- `Doing`: 正在进行。
- `Blocked`: 被问题卡住。
- `Review`: 等待检查或合并。
- `Done`: 已完成并验证。

## 2026-05-31 to 2026-06-07

### 本周目标

- 初始化 Godot Demo 骨架。
- 建立 GitHub 远程仓库和协作规范。
- 确认美术与 VFX 前期工作流。
- 建立文档治理、进度记录和更改日志规则。
- 启动“源”初始匕首战斗切片。
- 启动全路线动态背景 props/tiles 拆分。

### 已完成

- 创建 Godot 4.6.x Demo 项目骨架。
- 建立 `main`、`develop`、`art/player-concept-pass` 分支。
- 创建公开仓库 `zixuanjiang332/Source`。
- 编写程序规范、GitHub 流程、素材交付、AI 辅助素材规则。
- 产出主角“源”三阶段 AI 概念草图及无武器版本，并登记到素材清单。
- 合入主菜单 UI 和武器轮廓概念参考。
- 完成初始匕首三段普攻、Demo 能量技、HUD 武器/能量/连段反馈和击杀目标推进。
- 搭建动态背景通用节点和实验室/城市背景分层结构。
- 登记完整动态背景氛围包的源文件路径、导出路径和规格。
- 完成实验室首批 AI final 背景 tiles/props，生成 58 张单帧 PNG 并拼接运行时 spritesheet。
- 更新 AI 素材规则，允许 AI 生成图、动作帧和 spritesheet 直接作为 final 素材接入。
- 将当前主角、主菜单 UI、武器概念图全量导出到 `assets/`，并接入主菜单、玩家显示、HUD 头像和匕首图标。
- 修复主菜单：切换到脸部主题图，点击开始前不加载关卡、HUD、VFX 或玩家。

### 当前阻塞

- 当前主角和武器已接入 AI final 运行时资源，但正式动作帧、敌人帧动画和特效 spritesheet 尚待补齐。
- 当前战斗切片仍需 Godot GUI 手动试玩确认手感。
- 城市动态背景仍使用 placeholder sheet 驱动，正式 tiles/props spritesheet 待后续处理。

### 下周计划

- 整理世界观和武器策划到 `docs/`。
- 产出主角轮廓草案、第一把武器草案、基础命中/冲刺特效方向。
- 确认第一版可录屏路线的场景节奏。
- 将正式像素动画和特效分批接入初始匕首切片。
- 将正式背景 tiles/props 分批替换到 `assets/pixel/background/`。

### 任务板

| 任务 | 负责人 | 状态 | 备注 |
|---|---|---|---|
| 项目骨架初始化 | Codex / 程序 | Done | 已推送远程仓库 |
| GitHub 协作流程 | Codex / 团队 | Done | `main` 已保护 |
| 文档治理规则 | Codex | Done | 已加入核心文档和校验 |
| 主角视觉草案 | 美术/VFX | Review | 已导出到 `assets/` 并接入玩家/HUD，待正式动作帧 |
| 武器视觉草案 | 策划 / 美术 | Review | 已导出到 `assets/` 并接入初始匕首 HUD 图标 |
| 初始匕首玩法切片 | Codex / 程序 | Review | 标题页不再提前运行关卡，待 GUI 手动试玩和手感微调 |
| 动态背景框架 | Codex / 程序 | Review | 通用动画节点已搭建，待 GUI 检查视觉节奏 |
| 实验室背景 AI final 素材 | Codex | Review | 已接入 Godot，待 GUI 视觉验收 |
| 城市背景 tiles/props 正式素材 | 美术/VFX | Todo | 依据 `ASSET_MANIFEST.csv` 的 city background 条目绘制 |
| 世界观文档整理 | 策划 | Todo | 建议新增 `WORLDVIEW.md` |

## 周报模板

复制以下模板新增到文件顶部最近日期下方：

```md
## YYYY-MM-DD to YYYY-MM-DD

### 本周目标

- 

### 已完成

- 

### 当前阻塞

- 

### 下周计划

- 

### 任务板

| 任务 | 负责人 | 状态 | 备注 |
|---|---|---|---|
|  |  | Todo |  |
```
