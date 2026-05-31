# Assets

这里存放已经准备导入 Godot 的最终素材。源文件不要放在这里，源文件放到 `art_src/`。

## Folders

- `pixel/`: 角色、敌人、场景瓦片、道具图标、特效帧导出的 PNG。
- `audio/`: 最终导入 Godot 的 WAV/OGG。
- `ui/`: UI 图标、字体、标题图等。

## Import Rules

- 像素 PNG 统一关闭过滤，使用 nearest。
- 角色和特效 spritesheet 命名：`spr_<owner>_<anim>_<size>.png`。
- 音效命名：`sfx_<source>_<action>_<index>.wav`。
- 临时素材必须带 `_placeholder` 后缀，方便提交前清理。

