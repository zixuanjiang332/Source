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
- 新增“源”主角运行时 sprite、HUD 头像、初始匕首图标和主菜单背景接入资源。
- 新增脸部主题主菜单背景 `bg_start_menu_yuan_face_v2.png`。
- 新增“源”早期克隆体 66 帧动作 spritesheet、逐帧 PNG、动画规格文档和玩家动画控制器。
- 新增 1920x1080 清洁版主菜单背景、重生实验室背景和 4 张连续城市主关卡背景。
- 新增 `RebirthLevel.tscn` 与 `MainCityLevel.tscn`，通过关卡切换事件分离重生段和主战斗段。

### Changed

- 将 PR 文档同步要求纳入团队协作流程。
- 当前玩法切片聚焦初始匕首，不实现多武器槽、数字键切换或 `Q` 切换。
- 关卡目标会随敌人击杀推进，便于录制冲刺、连段、技能收尾路线。
- 将关卡背景拆为实验室静态层、实验室动画层、城市远景、中景、动画层和前景装饰层。
- 背景动画从 `DemoLevel.gd` 的硬编码逻辑迁移到各个 `AnimatedBackgroundProp` 节点。
- 实验室背景从 placeholder sheet 切换到 `assets/pixel/background/lab/` 的 final 运行时素材。
- AI 使用规则改为允许 AI 生成图、动作帧和 spritesheet 直接作为 final 素材接入。
- 主场景接入标题菜单，玩家场景从几何占位角色切换为“源”运行时 sprite，HUD 接入头像和武器图标。
- 玩家控制器的兜底攻击资源对齐 `initial_dagger.tres` 使用的 `dagger_cut_*` 和 `dagger_flash_step`。
- 主菜单按钮改为贴合背景中文字的透明点击区域，未开放选项只显示提示。
- 玩家显示从静态图切换为 `AnimatedSprite2D` 动作帧，并把匕首三段与技能映射到 `atk_1/atk_2/atk_3/skill`。
- 玩家视觉缩放到 70%，相机视距大幅拉远，并为 Demo 地图添加不可见边界和相机限制。
- `AttackData` 增加可选 `animation_id` 字段，用于将攻击数据映射到角色动画标签。
- 项目渲染基准从 `480x270 viewport` 改为 `1920x1080 canvas_items`，避免菜单、HUD 和背景被低分辨率压缩后放大。
- 主菜单从背景图烘焙文字和透明热区改为独立蓝色中文按钮组件，支持鼠标悬停高亮放大。
- HUD 重新布局为 1080p 尺寸和大字号组件，提升正式游戏内文字清晰度。
- 城市主关卡背景改为 4 张 1920x1080 连续大图拼接，不再依赖单张暗色重复远景。

### Fixed

- 避免 Godot 导入 `art_src/` 源稿和 `docs/` 文档时生成无关 `.import` 噪声。
- 修复标题页打开时已经加载正式关卡、HUD、动态背景并允许角色移动的问题。
- 加固主场景校验，防止 `Main.tscn` 再次静态实例化正式 gameplay 节点。
- 修复主菜单与正式游戏在 480p 内部分辨率下整体发糊的问题。

### Removed

- 暂无。

### Docs

- 新增 `DOCUMENTATION_GOVERNANCE.md`、`PROGRESS_LOG.md`、`DECISION_LOG.md`。
- 同步初始匕首切片的框架、程序规范、进度和设计决策记录。
- 同步动态背景交付路径、素材清单、框架和程序规范。
- 同步 AI final 素材政策、像素图/VFX 提示词规范和 GitHub 禁止事项。
- 同步全量美术资源接入后的素材清单、进度记录和框架说明。
- 同步玩家动作帧规格、素材清单、框架说明和进度记录。

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
