# UI and Weapon Concept Handoff

用途: reference / paintover_base
生成日期: 2026-05-31
负责人: Codex
是否进入正式素材: no, yes-after-redraw

## ui_main_menu_concept_01.png

- 设计来源: `World.md`, `docs/ART_BIBLE.md`, `docs/AREA_STYLE_GUIDE.md`, `assets/ui/README.md`
- 方向: Birth Lab 主界面视觉稿，左侧保留实验床、培养舱和源的背影，右侧为可交互菜单区。
- 调色: 深黑蓝与冷灰金属为主，cyan / electric blue 为主交互色，magenta 做异常信号，amber 做危险提示。
- 后续处理:
  - 需要人工重绘主标题，避免使用 AI 生成的伪文字。
  - 菜单图标、武器槽和角色状态框应拆成独立 UI 组件。
  - 如接入 Godot，应先输出到 `assets/ui/`，并保持 16:9 安全边界。

## weapon_concept_sheet_01.png

- 设计来源: `weapon.md`, `docs/ART_BIBLE.md`, `docs/PIXEL_ART_PROMPT_GUIDE.md`
- 覆盖武器: 匕首、反手充能太刀、三棱军刺、手枪、次世代、澎湃。
- 方向: 先以清晰轮廓区分功能，后续再由美术统一转成 32x32 / 64x64 图标或角色手持武器 sprites。
- 后续处理:
  - 武器图标不应带文字，名称和功能写入策划表或资源数据。
  - 充能太刀保留 cyan 能量刃；三棱军刺强化三角刺入轮廓；澎湃保留 amber 穿甲提示。
  - 枪械需在重绘时简化细节，避免缩小后糊成黑块。
