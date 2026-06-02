# Batch 02 Replacement Drop Folder

把第二批正式重绘好的技能帧放到这里，替换当前过渡拳头技能条带。

## 目录结构

```text
art_src/generated/player_yuan_fist_pass/redraw_batches/batch_02/
  punch_skill/
    frame_01.png
    frame_03.png
    frame_06.png
    frame_08.png
```

## 固定要求

- 每张图必须是 `96x96`
- 背景透明
- 朝右
- 脚底基准线保持和模板一致
- 角色必须遵守 `YUAN_APPEARANCE_LOCK.md`

## 使用方式

先检查：

```powershell
python .\tools\apply_player_yuan_redraw_batch_01.py --batch batch_02 --check
```

替换并部署：

```powershell
python .\tools\apply_player_yuan_redraw_batch_01.py --batch batch_02 --deploy
```

