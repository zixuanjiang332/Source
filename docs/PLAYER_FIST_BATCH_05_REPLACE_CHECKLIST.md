# Player Fist Batch 05 Replace Checklist

这份清单用于把“完整身体动作”版本压进三段拳，优先解决攻击被缩在小框里、动作前后衔接不足、视觉上只像两段动作的问题。

## 替换范围

- `punch_1`: `frame_01 / frame_02 / frame_03 / frame_04 / frame_05`
- `punch_2`: `frame_01 / frame_02 / frame_03 / frame_04 / frame_05`
- `punch_3`: `frame_01 / frame_02 / frame_03 / frame_04 / frame_05 / frame_06 / frame_07`

## 参考来源

- `yuan_punch_1_body_strip_v2.png`: 预备 -> 发力 -> 命中 -> 回收
- `yuan_punch_2_body_strip_v2.png`: 预备 -> 发力 -> 命中 -> 回收
- `yuan_punch_3_body_strip_v2.png`: 压低 -> 推进 -> 下砸 -> 跪地回收

## 验证重点

1. 三段拳是否能读出连续的蓄力、发力、命中、回收。
2. 命中帧是否不再像被单独塞进小框。
3. `punch_1 / punch_2 / punch_3` 是否有清楚层级，而不是只看到两种动作。
4. 左臂不能金属化，右机械臂不能变成双机械臂。
5. `punch_3` 的下砸必须是整套连段里最重的一拳。
