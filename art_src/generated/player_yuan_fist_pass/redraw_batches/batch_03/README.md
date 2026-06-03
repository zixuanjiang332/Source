# Batch 03 Replacement Drop Folder

把第三批正式重绘好的无武器拳头帧放到这里，替换当前过渡 runtime 的待机、跑动和关键命中帧。

## 目录结构

```text
art_src/generated/player_yuan_fist_pass/redraw_batches/batch_03/
  combat_idle/
    frame_00.png
    frame_03.png
    frame_06.png
  combat_run/
    frame_00.png
    frame_02.png
    frame_04.png
    frame_06.png
  punch_1/
    frame_04.png
  punch_2/
    frame_04.png
  punch_3/
    frame_05.png
```

## 固定要求

- 每张图必须是 `96x96`
- 背景透明
- 朝右
- 不允许出现佩刀、背刀、刀鞘轮廓或持刀语言
- 主角只有右臂机械义体，左臂保持人类手臂

## 使用方式

先检查：

```powershell
python .\tools\apply_player_yuan_redraw_batch_01.py --batch batch_03 --check
```

替换并部署：

```powershell
python .\tools\apply_player_yuan_redraw_batch_01.py --batch batch_03 --deploy
```

