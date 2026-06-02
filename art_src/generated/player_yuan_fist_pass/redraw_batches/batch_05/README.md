# Batch 05 Replacement Drop Folder

第五批用于把三段拳从“小框命中帧”里解放出来，直接替换 `punch_1 / punch_2 / punch_3` 的连续身体动作。

## 目录结构

```text
art_src/generated/player_yuan_fist_pass/redraw_batches/batch_05/
  punch_1/
    frame_01.png
    frame_02.png
    frame_03.png
    frame_04.png
    frame_05.png
  punch_2/
    frame_01.png
    frame_02.png
    frame_03.png
    frame_04.png
    frame_05.png
  punch_3/
    frame_01.png
    frame_02.png
    frame_03.png
    frame_04.png
    frame_05.png
    frame_06.png
    frame_07.png
```

## 固定要求

- 每张图必须是 `96x96`
- 背景透明
- 朝右
- 角色本体优先，特效只保留贴近拳头或落点的轻提示
- 主角只有右臂机械义体，左臂保持人类手臂

## 使用方式

```powershell
python .\tools\apply_player_yuan_redraw_batch_01.py --batch batch_05 --check
python .\tools\apply_player_yuan_redraw_batch_01.py --batch batch_05 --deploy
```
