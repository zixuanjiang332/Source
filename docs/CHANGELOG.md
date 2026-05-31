# Changelog

本文件记录对玩家、团队或项目结构有意义的变化。格式参考 Keep a Changelog，并按 Demo 阶段维护。

## [Unreleased]

### Added

- 添加文档治理规范，明确不同改动类型必须同步的文档。
- 添加周报式进度记录模板。
- 添加关键决策记录模板。
- 合入“源”主角、主菜单 UI 和武器轮廓概念参考，并登记到素材清单。
- 新增 `WeaponData` 资源和初始武器 `initial_dagger.tres`。
- 新增初始匕首三段普攻和 Demo 能量技 `Flash Step`。
- HUD 新增当前武器、能量、技能可用状态和连段提示。
- 新增通用 `AnimatedBackgroundProp`，支持背景帧动画和横向循环移动。
- 新增实验室/城市背景源文件和运行时导出目录。
- 登记实验室与城市完整动态背景氛围包的 tiles/props 交付清单。
- 新增实验室 AI final 背景 tiles/props 运行时素材和逐帧源文件。
- 新增 `tools/stitch_spritesheet.py`，用于从 AI 帧板生成单帧 PNG 与横向 spritesheet。
- 添加主角“源”早期克隆体动作帧规格，并接入玩家动画控制接口与近战动作动画映射。
- 生成并接入主角“源”早期克隆体 66 帧 AI 最终运行时 spritesheet。

### Changed

- 将 PR 文档同步要求纳入团队协作流程。
- 当前玩法切片聚焦初始匕首，不实现多武器槽、数字键切换或 `Q` 切换。
- 关卡目标会随敌人击杀推进，便于录制冲刺、连段、技能收尾路线。
- 将关卡背景拆为实验室静态层、实验室动画层、城市远景、中景、动画层和前景装饰层。
- 背景动画从 `DemoLevel.gd` 的硬编码逻辑迁移到各个 `AnimatedBackgroundProp` 节点。
- 实验室背景从 placeholder sheet 切换到 `assets/pixel/background/lab/` 的 final 运行时素材。
- AI 使用规则改为允许 AI 生成图、动作帧和 spritesheet 直接作为 final 素材接入。
- `AttackData` 增加可选 `animation_id` 字段，用于将攻击数据映射到角色动画标签。
- 允许经明确批准的 AI 素材作为 `final` 运行时素材接入，并要求保留来源标记。

### Fixed

- 避免 Godot 导入 `art_src/` 源稿和 `docs/` 文档时生成无关 `.import` 噪声。

### Removed

- 暂无。

### Docs

- 新增 `DOCUMENTATION_GOVERNANCE.md`、`PROGRESS_LOG.md`、`DECISION_LOG.md`。
- 同步初始匕首切片的框架、程序规范、进度和设计决策记录。
- 同步动态背景交付路径、素材清单、框架和程序规范。
- 同步 AI final 素材政策、像素图/VFX 提示词规范和 GitHub 禁止事项。

## [0.1.0] - 2026-05-31

### Added

- 初始化 Godot 4.6.x 赛博朋克 2D 像素动作 Demo 骨架。
- 添加玩家、敌人、Hitbox/Hurtbox、VFX、HUD、道具和资源模板。
- 添加程序规范、GitHub 协作流程、素材交付、像素图和特效提示词规范。
- 创建 GitHub 公开仓库 `zixuanjiang332/Source`。

### Changed

- 暂无。

### Fixed

- 暂无。

### Removed

- 暂无。

### Docs

- 建立 README、里程碑、美术、音频、AI 辅助素材和团队分工文档。

## 条目模板

```md
## [Unreleased]

### Added

- 

### Changed

- 

### Fixed

- 

### Removed

- 

### Docs

- 
```
