# 文档治理规范

本文档定义每次改动后必须同步哪些文档。目标是让团队知道项目为什么变、哪里变、谁负责、下一步是什么。

## 1. 基本规则

- 每个 PR 都要检查文档影响。
- 有玩家可见变化、团队流程变化、素材变化、接口变化时，必须同步对应文档。
- 如果确认不需要同步文档，PR 描述里的 `Docs` 项必须写明 `Not needed` 和原因。
- 文档改动要和代码/素材改动放在同一个 PR，除非是单独的规范整理。
- 不确定是否要更新时，优先更新 `PROGRESS_LOG.md` 或在 PR 里说明。

## 2. 改动类型与必改文档

| 改动类型 | 必须同步 | 视情况同步 |
|---|---|---|
| 新增玩法/系统 | `CHANGELOG.md`, `PROGRESS_LOG.md` | `GAME_FRAMEWORK.md`, `PROGRAMMING_STANDARDS.md` |
| 修改接口/事件/Resource | `GAME_FRAMEWORK.md` 或 `PROGRAMMING_STANDARDS.md` | `DECISION_LOG.md` |
| 修复 Bug | `CHANGELOG.md` 的 `Fixed` | `PROGRESS_LOG.md` |
| 删除/重命名文件、节点、接口 | `CHANGELOG.md` 的 `Removed` 或 `Changed` | 所有引用该名称的文档 |
| 新增或替换像素素材 | `ASSET_MANIFEST.csv`, `PROGRESS_LOG.md` | `ART_BIBLE.md`, `ASSET_HANDOFF.md` |
| 新增或替换 VFX | `ASSET_MANIFEST.csv`, `PROGRESS_LOG.md` | `VFX_PROMPT_GUIDE.md`, `GAME_FRAMEWORK.md` |
| 新增或替换音频 | `ASSET_MANIFEST.csv`, `PROGRESS_LOG.md` | `AUDIO_PIPELINE.md` |
| 修改 Git/GitHub 流程 | `GITHUB_WORKFLOW.md`, `CHANGELOG.md` | `SETUP.md`, `PROGRAMMER_COLLABORATION.md` |
| 修改团队分工/流程 | `TEAM_ROLES.md` 或 `PROGRAMMER_COLLABORATION.md` | `PROGRESS_LOG.md` |
| 关键设计取舍 | `DECISION_LOG.md` | `GAME_FRAMEWORK.md`, `ART_BIBLE.md` |
| 版本发布/可演示节点 | `CHANGELOG.md`, `PROGRESS_LOG.md` | `MILESTONES.md` |

## 3. PR 文档检查项

每个 PR 描述必须包含：

```md
## Docs
- Updated:
- Not needed because:
```

示例：

```md
## Docs
- Updated: docs/CHANGELOG.md, docs/PROGRESS_LOG.md
- Not needed because: no public API or asset pipeline changed
```

如果 `Updated` 为空，必须填写 `Not needed because`。

## 4. CHANGELOG 维护规则

`CHANGELOG.md` 记录对玩家、团队或项目结构有意义的变化。

需要记录：

- 新增玩法、系统、关卡、敌人、道具、素材管线。
- 修改核心手感、接口、目录结构、协作流程。
- 修复会影响运行、导出、合并、素材接入的问题。
- 删除或重命名重要文件、系统、素材 ID。

不需要记录：

- 纯错别字。
- 没有行为变化的微小格式调整。
- 临时本地实验但未进入 PR 的内容。

## 5. PROGRESS_LOG 维护规则

`PROGRESS_LOG.md` 记录团队推进状态，不做每日流水账。

每周至少更新一次：

- 本周目标。
- 已完成内容。
- 当前阻塞。
- 下周计划。
- 任务板状态。

如果某个 PR 完成了阶段性任务，也可以在当周条目下追加一行。

## 6. DECISION_LOG 维护规则

`DECISION_LOG.md` 记录影响后续开发的关键取舍。

需要记录：

- 引擎、分辨率、像素规格、目录结构。
- 玩法范围收缩或扩张。
- 美术风格、特效方向、命名规范。
- GitHub 分支模型、发布策略。

每条决策必须包含：日期、决策、原因、影响范围、后续复盘条件。

## 7. Definition of Done

一个 PR 完成时必须满足：

- 功能、素材或文档本身已经完成当前目标。
- `tools/validate_project.ps1` 通过。
- PR 描述写清楚测试方式。
- 文档同步矩阵已检查。
- 需要同步的文档已经更新。
- 不需要同步的文档已经在 PR 描述中说明原因。

