# Player Fist Batch 01 Replace Checklist

这份清单用于把 Batch 01 的 9 帧正式重绘结果压进当前过渡拳头 runtime，并重新部署测试。

## 替换范围

- `punch_1`: `frame_01 / frame_03 / frame_05`
- `punch_2`: `frame_01 / frame_03 / frame_05`
- `punch_3`: `frame_02 / frame_05 / frame_07`

## 投放目录

```text
art_src/generated/player_yuan_fist_pass/redraw_batches/batch_01/
```

## 前置检查

1. 每张替换帧都是 `96x96`
2. 背景透明
3. 角色朝右
4. 文件名完全一致
5. `PLAYER_FIST_REDRAW_BATCH_01.md` 的逐帧目标已经过一遍

## 执行命令

先检查批次是否齐：

```powershell
python .\tools\apply_player_yuan_redraw_batch_01.py --check
```

通过后，直接替换并部署：

```powershell
python .\tools\apply_player_yuan_redraw_batch_01.py --deploy
```

## 脚本行为

`apply_player_yuan_redraw_batch_01.py --deploy` 会自动：

1. 检查 9 帧是否存在
2. 备份原条带到 `art_src/generated/player_yuan_fist_pass/backups/batch_01/`
3. 将重绘帧压进当前 `punch_1 / punch_2 / punch_3` 条带
4. 运行 `build_player_yuan_runtime_from_fist_pass.py`
5. 运行 `deploy_player_yuan_fist_pass.ps1`

## 替换后验证

至少检查：

1. `punch_1` 的快拳是否更短更狠
2. `punch_2` 是否明显比 `punch_1` 更重
3. `punch_3` 是否终于形成终结拳高潮
4. 连段播起来是否还顺
5. 玩家能正常移动、攻击、放技能、进终结技

## 回退方法

如果替换结果不满意，可用 `backups/batch_01/` 中备份的旧条带手动恢复，然后重新运行：

```powershell
python .\tools\build_player_yuan_runtime_from_fist_pass.py
.\tools\deploy_player_yuan_fist_pass.ps1
```
