# Game Framework

## Demo Direction

本 Demo 是赛博朋克智械危机题材的 2D 像素动作垂直切片。目标不是先做完整肉鸽，而是先完成一条可以录出高质量演示的战斗路线。

具体游戏内容、像素图风格和特效设计由团队策划与确认；素材可以由人工绘制，也可以由 AI 生成图或动作帧直接作为 final 接入。本仓库先提供可协作的开发骨架、数据接口和文档规范。

## Runtime Architecture

- `GameEvents`: 全局事件总线，负责生命/能量、VFX、SFX、镜头震动、敌人死亡和重开请求。
- `InputBootstrap`: 启动时注册默认输入，避免空项目缺少 InputMap。
- `CharacterStats`: 角色数值 Resource，玩家、普通敌人、Boss 共用。
- `AttackData`: 攻击数据 Resource，统一伤害、击退、命中停顿、VFX、SFX，并可通过 `animation_id` 映射角色攻击动画。
- `WeaponData`: 当前武器数据 Resource，保存武器 ID、显示名、普攻链、Demo 技能攻击和 HUD 名称。
- `Hitbox` / `Hurtbox`: 所有攻击命中都走这两个 Area2D。
- `VfxCatalog`: 通过 `vfx_id` / `sfx_id` 查找特效和音效。旧特效可继续返回 PackedScene；spritesheet VFX 和 SFX 使用 `VfxEntry` / `SfxEntry` 登记。
- `PlayerAnimationController`: 玩家动画桥接层，正式 spritesheet 缺失或动画标签缺失时回退到灰盒视觉。
- `level_change_requested`: `GameEvents` 上的关卡切换事件，当前由重生段与作坊段的电梯触发，`Main.gd` 播放转场后加载对应关卡。

## Current Scene Flow

`Main.tscn` 启动时只显示标题菜单和空 `GameRoot`。标题菜单使用 1920x1080 清洁版脸部主题 AI final 图，菜单选项由 Godot 蓝色中文按钮组件显示，支持鼠标悬停高亮放大。点击“开始游戏”后才动态创建 `VfxSpawner`、`Hud.tscn` 和 `RebirthLevel.tscn`，因此标题页不会提前显示正式关卡、HUD、玩家或动态背景。

当前路线拆分为三个运行场景：

- `RebirthLevel.tscn`: 重生实验室段，负责醒来、Dr. Lin、终端、补给和通往作坊的电梯交互。
- `DemoLevel.tscn`: 作坊/维修间段，负责商店界面和通往主关卡的电梯交互。
- `MainCityLevel.tscn`: 城市高架主战斗段，负责训练敌人、Riot Frame、Foundry Warden 和 30-60 秒战斗录屏路线。

重生段电梯通过 `GameEvents.request_level_change(&"workshop")` 进入作坊段。作坊段电梯再通过 `GameEvents.request_level_change(&"main_city")` 进入主关卡。`Main.gd` 播放短暂蓝色扫描/淡出转场后卸载当前场景并加载对应关卡。

当前“源”的概念图已全量导出到 `assets/pixel/characters/yuan/`。运行时玩家使用 `assets/pixel/spr_player_yuan_early_clone.png` 和 `resources/characters/player_yuan_early_clone_frames.tres` 播放 `idle/run/jump/fall/dash/atk_1/atk_2/atk_3/skill/hit/death`。HUD 使用 `portrait_yuan_stage_01.png`，初始匕首 HUD 图标使用 `icon_initial_dagger.png`。

项目渲染基准为 1920x1080，Stretch 使用 `canvas_items`，避免菜单、HUD 和大背景被 480p 内部分辨率压缩后放大。玩家视觉缩放为 70%，相机默认 `zoom` 为 `2.0`，并关闭相机平滑以减少亚像素模糊；该设置在保持像素清晰的同时给出约 960x540 world units 的录屏视距。各关卡使用不可见边界限制玩家离开路线，并通过相机 `limit_*` 避免显示明显地图外空白。

## Dynamic Background

背景分为高清静态主图和少量动态 props。当前正式背景主图全部按 1920x1080 输出，运行时在世界中按 `0.5` 显示，使相机 `zoom = 2.0` 时最终画面保持 1:1 清晰度。

重生段使用 `assets/pixel/background/lab/bg_rebirth_lab_1920.png` 作为单屏实验室背景，并叠加终端、警示灯、电梯脉冲等局部动画。城市主关卡使用 4 张连续大背景拼接：

- `bg_city_route_panel_01.png`
- `bg_city_route_panel_02.png`
- `bg_city_route_panel_03.png`
- `bg_city_route_panel_04.png`

作坊段使用 `assets/pixel/background/shop/bg_initial_shop_workshop.png` 作为单屏维修间背景，并复用和重生段一致的 1920x1080 -> `0.5` 世界缩放策略，保证出生点与作坊在同一套设施尺度下切换。

所有循环背景动画挂 `AnimatedBackgroundProp`。该脚本只更新 Sprite2D 的 `region_rect`、位置循环和帧序，不参与碰撞、交互、战斗或关卡目标逻辑。正式美术导出后，替换节点 texture 并按素材规格填写 `frame_size`、`frame_count`、`fps` 和 `columns`。

当前实验室段已切换到 `assets/pixel/background/lab/` 的 AI final 背景 tiles/props，用来验证动态背景管线和运行时接入。城市高架主图已切换到连续 1920x1080 final 背景，局部动态车流、全息环和出口锁等 props 暂时继续使用 placeholder sheet，等待后续同流程替换为正式 spritesheet。

## Current Combat Slice

当前玩法只精修第一把近战武器“匕首”。`resources/weapons/initial_dagger.tres` 绑定三段普攻和一个 Demo 能量技：

- `dagger_cut_1`: 快速起手，用来接近和确认命中。
- `dagger_cut_2`: 反手追击，延续短硬直。
- `dagger_cut_3`: 连段收尾，击退和停顿更明显。
- `dagger_flash_step`: Demo 用能量突进斩，用于展示位移收尾和 HUD 技能状态。
- `Overdrive Sever`: 满能量长按 `K` 触发的 Demo 终结技。前 7 段为蓝色全息高速斩击，玩家本体隐藏，只留下残影和刀痕；第 8 段播放 `ultimate_slam`，角色双手持红色光刀下坠重击。

玩家 HUD 通过 `GameEvents.player_weapon_changed`、`player_energy_changed` 和 `player_combo_changed` 显示武器名、能量、技能状态和连段。UI 只监听事件，不驱动战斗逻辑。

终结技 HUD 通过 `GameEvents.player_ultimate_changed` 获取显示名、能量消耗和长按时间，并在能量满时显示 `HOLD K ... READY`。终结技仍复用当前玩家 Hitbox，但每一段会临时放大 hitbox 并在段落结束后恢复默认普攻尺寸。

本阶段不做 1/2/3 武器槽、`Q` 切换、远程武器或正式多武器主技能框架。等初始匕首路线稳定并接入正式动画后，再抽象完整武器系统。

## What Not To Build Yet

- 不做完整随机地图生成。
- 不做永久存档和复杂元成长。
- 不做多主角、多武器库。
- 不做多武器槽、快速切换和远程武器框架。
- 不做完整商店、NPC 和剧情系统。

这些都等 8 月 15 日 Demo 稳定后再扩展。
