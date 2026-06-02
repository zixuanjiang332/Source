# Batch 01 Replacement Drop Folder

把第一批正式重绘好的 9 帧放到这里，替换当前过渡拳头条带。

## 目录结构

```text
art_src/generated/player_yuan_fist_pass/redraw_batches/batch_01/
  punch_1/
    frame_01.png
    frame_03.png
    frame_05.png
  punch_2/
    frame_01.png
    frame_03.png
    frame_05.png
  punch_3/
    frame_02.png
    frame_05.png
    frame_07.png
```

## 固定要求

- 每张图必须是 `96x96`
- 背景透明
- 朝右
- 脚底基准线保持和模板一致

## 使用方式

先检查：

```powershell
python .\tools\apply_player_yuan_redraw_batch_01.py --check
```

替换并部署：

```powershell
python .\tools\apply_player_yuan_redraw_batch_01.py --deploy
```

这会：

1. 检查 9 帧是否齐全
2. 备份当前 `punch_1 / punch_2 / punch_3` 条带
3. 把新帧压进现有 strip
4. 自动重建 runtime 资源
5. 自动执行部署脚本
