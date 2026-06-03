# Player Fist Batch 04 Replace Checklist

这份清单用于把第四批“干净命中帧”压进当前 runtime。

## 替换范围

- `punch_1`: `frame_04`
- `punch_2`: `frame_04`
- `punch_3`: `frame_05`
- `punch_skill`: `frame_06`

## 目标

1. 修掉命中动作像被固定框裁断的感觉
2. 让角色本体动作比特效更清楚
3. 让打击轮廓先成立，再由独立 VFX 补足命中反馈

## 执行命令

```powershell
python .\tools\apply_player_yuan_redraw_batch_01.py --batch batch_04 --check
python .\tools\apply_player_yuan_redraw_batch_01.py --batch batch_04 --deploy
```
