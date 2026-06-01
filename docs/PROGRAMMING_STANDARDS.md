# 程序开发规范

本文档定义 Godot/GDScript 侧的协作规范。目标是让四人团队在 Demo 阶段保持代码可读、可合并、可扩展，而不是追求复杂架构。

## 1. 技术基线

- 引擎：Godot 4.6.x stable。
- 脚本：GDScript。
- 平台：Windows 可执行包优先。
- 分辨率：内部 480x270，整数缩放到 1920x1080。
- Git：所有二进制素材通过 Git LFS。

项目当前已经有可运行骨架和基础目录。后续不要随意新增顶层目录，除非团队先在 PR 或群里确认。

## 2. 目录职责

- `scenes/`: Godot 场景，只放 `.tscn`。
- `scripts/`: GDScript 源码，按系统分层。
- `resources/`: `.tres` 数据资源，负责数值和配置。
- `assets/`: 导入 Godot 的最终图片、音频、字体。
- `art_src/`: Aseprite/Krita/PSD 等源文件。
- `docs/`: 策划、规范、排期和交付记录。
- `tools/`: 本地校验、导出、辅助脚本。

代码不要直接引用 `art_src/`；Godot 运行时只引用 `assets/`、`resources/`、`scenes/`、`scripts/`。

## 3. 命名规范

### 文件与目录

- 目录：小写 snake_case，例如 `player_combat/`。
- 场景：PascalCase，例如 `Player.tscn`、`DemoLevel.tscn`。
- 公开脚本类：当前项目采用 PascalCase 文件名，例如 `PlayerController.gd`。
- 资源：小写 snake_case，例如 `player_slash_1.tres`。
- 素材：小写 snake_case，例如 `spr_player_idle_96.png`。

### GDScript

- 类名：PascalCase，例如 `PlayerController`。
- 函数/变量：snake_case，例如 `apply_hit()`、`current_health`。
- 私有变量/函数：前缀 `_`，例如 `_dash_timer`、`_start_attack()`。
- 常量：UPPER_SNAKE_CASE，例如 `DEFAULT_STATS`。
- 信号：过去式或状态变化，例如 `hit_landed`、`player_health_changed`。

## 4. GDScript 文件顺序

每个脚本按以下顺序写：

1. `class_name`
2. `extends`
3. `signal`
4. `enum`
5. `const`
6. `@export var`
7. 普通成员变量
8. `@onready var`
9. `_ready()`
10. `_process()` / `_physics_process()`
11. Godot 回调函数
12. 公开方法
13. 私有方法

不要在同一个脚本里混放大量无关职责。一个脚本如果超过 250 行，需要在 PR 描述里说明为什么暂时不拆。

## 5. 场景与脚本职责

- 玩家输入只放在 `PlayerController` 或后续拆出的玩家状态机里。
- 敌人行为只放在敌人控制脚本，不直接改玩家内部变量。
- 攻击统一走 `Hitbox` / `Hurtbox`。
- 数值统一放在 `.tres`，不要把正式数值硬编码在脚本里。
- UI 只监听事件或读取公开状态，不直接驱动战斗逻辑。
- 特效和音效通过 `GameEvents` 请求，不让攻击脚本直接实例化一堆特效。
- 背景动画只通过 `AnimatedBackgroundProp` 或后续同职责脚本驱动，不写进关卡主流程逻辑。

## 6. Resource 数据约定

当前核心 Resource：

- `CharacterStats`: 生命、速度、冲刺、重力、接触伤害。
- `AttackData`: 伤害、击退、主动帧、冷却、命中停顿、VFX/SFX ID。
- `WeaponData`: 武器 ID、显示名、三段普攻、Demo 技能攻击和 HUD 技能名。
- `ItemData`: 道具 ID、描述、效果 ID、倍率。
- `VfxCatalog`: VFX ID 到场景的映射。

新增数据时优先扩展 Resource，而不是新增全局单例。只有跨系统事件才进入 `GameEvents`。

当前 `WeaponData` 只服务初始匕首切片。不要在本阶段加入武器栏、快速切换、背包或完整装备系统；如果后续确实需要扩展，先更新 `GAME_FRAMEWORK.md` 和 `DECISION_LOG.md`。

## 7. 输入与手感

- 输入动作名固定使用 `move_left`、`move_right`、`jump`、`dash`、`attack`、`skill`、`restart`、`pause`。
- 所有手感参数先从 Resource 或 export 变量暴露。
- 冲刺、攻击、受击、死亡这类状态必须互相排斥或明确优先级。
- 命中停顿和屏幕震动要短，先保证操作可读。
- 连段、能量和技能 UI 通过 `GameEvents` 广播，不允许 UI 直接调用玩家战斗方法。

## 8. 碰撞层约定

当前建议：

- Layer 1: World
- Layer 2: Actor body
- Layer 4: Hurtbox
- Layer 8: Hitbox
- Layer 16: Pickup

新增层之前先更新本文档，避免多人各自占用。

## 9. 动态背景约定

- 动态背景素材采用横向 spritesheet，所有帧等宽等高。
- `AnimatedBackgroundProp.frame_size` 必须等于单帧尺寸，`frame_count` 必须等于有效帧数。
- 交通、光条、全息牌等视觉循环可以使用 `scroll_velocity` 和 `wrap_min_x` / `wrap_max_x`，但不能影响玩法节点。
- 正式素材只放 `assets/pixel/background/`；源文件只放 `art_src/background/`。
- 背景亮度必须压低，不能抢过玩家、敌人、命中特效和交互提示。

## 10. PR 前自检

提交 PR 前至少做：

```powershell
.\tools\validate_project.ps1
```

人工检查：

- 主场景能运行。
- 控制台无红色报错。
- `R` 能重开当前 Demo。
- 玩家能攻击命中至少一个敌人。
- 新增素材没有缺失引用。
- 新增 `.png`、`.wav`、`.aseprite` 走 Git LFS。

## 11. 禁止事项

- 不在 Demo 阶段引入大型插件或复杂框架。
- 不把临时测试逻辑散落在多个正式脚本里。
- 不把正式玩法数值写死在 `_physics_process()`。
- 不在一个 PR 中同时做大规模重构和新功能。
- 不直接修改别人正在编辑的 `.aseprite` 源文件。
