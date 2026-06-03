# Player Fist Batch 03 Replace Checklist

这份清单用于把 Batch 03 的无武器拳头帧压进当前过渡 runtime，并重新部署测试。

## 替换范围

- `combat_idle`: `frame_00 / frame_03 / frame_06`
- `combat_run`: `frame_00 / frame_02 / frame_04 / frame_06`
- `punch_1`: `frame_04`
- `punch_2`: `frame_04`
- `punch_3`: `frame_05`

## 目标

1. 去掉主角身上的佩刀感和持刀残留
2. 让默认站姿和跑姿更像空手近战角色
3. 让三段拳的主命中帧更清楚、更有冲击

## 前置检查

1. 每张替换帧都是 `96x96`
2. 背景透明
3. 主角只有右臂机械义体
4. 左臂保持人类手臂
5. 不出现刀、刀鞘、背刀轮廓

## 执行命令

先检查批次是否齐：

```powershell
python .\tools\apply_player_yuan_redraw_batch_01.py --batch batch_03 --check
```

通过后，直接替换并部署：

```powershell
python .\tools\apply_player_yuan_redraw_batch_01.py --batch batch_03 --deploy
```
