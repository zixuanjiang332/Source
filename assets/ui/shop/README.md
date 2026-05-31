# Shop UI Assets

商店模块的图片资源目录。

## 对接说明

美术同学请将以下素材放入此目录：

- `icon_neon_edge.png` — 伤害增幅图标（16×16 像素，赛博朋克风格）
- `icon_dash_core.png` — 冲刺核心图标（16×16 像素）
- `icon_repair_cell.png` — 修复单元图标（16×16 像素）
- `icon_credits.png` — 货币图标（8×8 像素，菱形/六边形）
- `shop_panel_frame.png` — 商店面板边框装饰（可选，当前使用程序化 Line2D）

## 当前状态

当前商店 UI 使用程序化绘制（Polygon2D / Line2D / ColorRect），不依赖纹理。
图标位置已预留，美术素材到位后替换即可。

## 引用方式

在 `ItemData.tres` 的 `icon_id` 字段中填写图标 ID（如 `&"icon_neon_edge"`），
`ShopController.gd` 的 `_build_slot_content()` 方法中根据 `icon_id` 加载对应纹理。
