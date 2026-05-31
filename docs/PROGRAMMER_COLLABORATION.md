# 程序协同开发文档

本文档面向程序成员，重点解决“多人如何不互相踩代码”的问题。

## 1. 分支模型

- `main`: 稳定演示基线，只合并已验证内容。
- `develop`: 日常集成分支。
- `feature/<system>`: 功能分支，例如 `feature/player-combat`。
- `fix/<bug>`: 修复分支，例如 `fix/hurtbox-mask`。
- `art/<asset>`: 美术素材分支，例如 `art/player-first-pass`。

开发从 `develop` 拉新分支，完成后 PR 回 `develop`。每周演示稳定后再从 `develop` 合并到 `main`。

## 2. 工作拆分原则

一次 PR 只解决一个明确目标：

- 好：`feat: add player dash cooldown`
- 好：`fix: prevent enemy hitting dead player`
- 不好：玩家、敌人、UI、关卡、美术素材全部混在一个 PR

任务粒度建议控制在 0.5 到 2 天内能完成。超过 2 天的任务拆成灰盒、接入、打磨三个阶段。

## 3. 所有权边界

推荐初始分工：

- 程序 A: `scripts/player/`、玩家相关场景、输入手感。
- 程序 B: `scripts/enemies/`、`scripts/vfx/`、关卡接入、导出。
- 策划: `resources/items/`、`resources/attacks/` 的数值建议和文档。
- 美术/VFX: `art_src/`、`assets/pixel/`、`docs/ART_BIBLE.md`。

跨目录改动可以做，但 PR 描述必须说明原因，并通知对应负责人。

## 4. 每日同步格式

每人每天用 3 行同步：

```text
Yesterday: 完成了什么
Today: 今天要推进什么
Blocked: 卡在哪里，需要谁帮忙
```

如果同一个阻塞超过 24 小时，立刻缩小目标或换临时方案。

## 5. PR 描述模板

```md
## What
- 本 PR 做了什么

## Why
- 为什么现在需要它

## Test
- 如何验证
- 是否运行 `tools/validate_project.ps1`

## Risk
- 可能影响哪些系统
- 是否有临时实现
```

## 6. Code Review 重点

Review 不追求挑刺，优先看：

- 有没有破坏主场景运行。
- 有没有硬编码本该放 Resource 的数值。
- 有没有新增缺失引用。
- 有没有混入无关改动。
- 有没有影响别人负责的目录。
- 命名是否能让后续成员读懂。

## 7. 合并规则

- 至少 1 人 Review 后合并。
- 冻结期需要 2 人确认。
- 合并前先从 `develop` 更新分支并解决冲突。
- 冲突如果涉及 `.tscn` 或 `.tres`，必须打开 Godot 检查场景是否仍能加载。

## 8. 冲突处理

文本脚本冲突：

1. 保留双方必要逻辑。
2. 运行主场景。
3. 在 PR 描述里说明冲突怎么解的。

场景/资源冲突：

1. 不要盲目接受一边。
2. 对比节点名、ext_resource、sub_resource。
3. 优先让最后编辑该场景的人处理。
4. 必要时回到 Godot 编辑器重新保存。

美术源文件冲突：

1. 原则上避免。
2. 使用 Git LFS lock 或在群里声明锁定。
3. 如果已经冲突，由素材负责人手动合并或选择版本。

## 9. Definition of Done

功能完成必须满足：

- 主场景能打开并运行。
- 功能能被玩家实际操作看到。
- 没有控制台红色报错。
- 相关数值可以通过 Resource 或 export 调。
- PR 描述有测试方式。
- 文档或清单已同步更新。

美术接入完成必须满足：

- 源文件在 `art_src/`。
- 导出图在 `assets/pixel/`。
- Godot 引用的是导出图，不是源文件。
- 动画名符合规范。
- 替换后没有错位、裁切或透明边异常。

