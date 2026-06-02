# Yuan Fist Batch 01 Visual Reference Prompt

这份提示词用于生成一张 3x3 的拳头连段视觉参考板。它不直接替代逐帧动画条带，但很适合在正式重绘前统一“这一版拳头到底要打成什么味道”。

建议用途：

- 对齐 `punch_1 / punch_2 / punch_3` 的重量层级
- 统一角色比例、拳架、肩髋联动
- 给逐帧重绘前做一张风格和力量方向参考

```text
A clean 3x3 sprite reference sheet for a 2D side-view cyberpunk pixel art fighter named Yuan early clone, all facing right, transparent or dark neutral background, consistent character proportions across all nine panels. Show nine key poses for a fist combo sequence with strong weight and fluid motion: row 1 = punch_1 anticipation, punch_1 impact, punch_1 aggressive recovery; row 2 = punch_2 anticipation, punch_2 heavy impact, punch_2 braking recovery; row 3 = punch_3 deep anticipation, punch_3 finisher impact, punch_3 heavy grounded recovery. Character design: messy short black hair, dark cropped combat jacket, dark pants, short boots, exactly one cybernetic right forearm and right hand, fully human left arm, cyan energy accents, no weapon. Emphasize planted feet, hip and shoulder rotation, readable silhouette, premium action-game punch force, not a knife slash. No second mechanical arm, no robotic left arm, no text, no watermark.
```

## 使用建议

不要把这张参考板直接当动画帧来切。更好的用法是：

1. 先看 9 宫格里的重量层级是否成立
2. 再回到 `PLAYER_FIST_REDRAW_BATCH_01.md` 对照逐帧任务
3. 最后用 `REDRAW_BATCH_01_FINAL_PROMPTS.md` 逐帧出图

这样更容易既保住动画时序，又把单帧力量感拉高。
