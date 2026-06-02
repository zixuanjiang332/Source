# Player Fist Batch 02 Replace Checklist

这份清单用于把 Batch 02 的 `punch_skill` 重绘结果压进当前过渡拳头 runtime，并重新部署测试。

## 替换范围

- `punch_skill`: `frame_01 / frame_03 / frame_06 / frame_08`

## 投放目录

```text
art_src/generated/player_yuan_fist_pass/redraw_batches/batch_02/
```

## 前置检查

1. 每张替换帧都是 `96x96`
2. 背景透明
3. 角色朝右
4. 主角只有右臂机械义体，左臂保持人类手臂
5. `punch_skill` 仍保留前冲 -> 接触 -> 制动三段结构

## 执行命令

先检查批次是否齐：

```powershell
python .\tools\apply_player_yuan_redraw_batch_01.py --batch batch_02 --check
```

通过后，直接替换并部署：

```powershell
python .\tools\apply_player_yuan_redraw_batch_01.py --batch batch_02 --deploy
```

## 替换后验证

至少检查：

1. 起手冲低姿态是否更锐利
2. 中段位移是否更干净
3. 命中是否有明确重量
4. 收势是否回到稳定拳架
5. 全程没有双机械臂或左臂金属化

