# GitHub 协同开发规范

本文档定义团队使用 GitHub 协作的日常流程。核心原则：**开始改动前先同步，完成改动后小步提交，合并前必须验证。**

## 1. 分支职责

- `main`: 稳定演示基线，只放确认可运行的版本。
- `develop`: 日常集成分支，所有功能先合并到这里。
- `feature/<name>`: 程序功能分支，例如 `feature/player-combat`。
- `fix/<name>`: Bug 修复分支，例如 `fix/hurtbox-mask`。
- `art/<name>`: 美术素材分支，例如 `art/player-first-pass`。
- `docs/<name>`: 文档分支，例如 `docs/github-workflow`。

禁止直接在 `main` 上开发。除非团队明确约定，否则也不要直接在 `develop` 上写代码。

## 2. 每次开始工作前

开始做任何改动前，先确认自己没有未保存或未提交的重要修改：

```powershell
git status
```

如果当前没有本地改动，先拉取最新代码：

```powershell
git switch develop
git pull --rebase origin develop
```

然后从最新 `develop` 创建自己的分支：

```powershell
git switch -c feature/your-task-name
```

如果已经在自己的功能分支上继续开发，也要先同步 `develop`：

```powershell
git fetch origin
git switch develop
git pull --rebase origin develop
git switch feature/your-task-name
git rebase develop
```

如果 rebase 出现冲突，不要硬推或乱选版本；先解决冲突，运行项目，再继续。

## 3. 有本地改动时如何拉取最新代码

如果 `git status` 显示有本地修改，先判断这些修改是否要保留。

需要保留且已经完成一个小阶段：

```powershell
git add .
git commit -m "feat: describe current work"
git fetch origin
git rebase origin/develop
```

需要保留但还不适合提交：

```powershell
git stash push -m "wip: describe temporary work"
git switch develop
git pull --rebase origin develop
git switch feature/your-task-name
git rebase develop
git stash pop
```

不需要保留时，不要自己随手删除大量文件；先确认改动范围，再处理。

## 4. 日常开发循环

推荐每次任务按这个节奏：

1. `git status` 检查工作区。
2. 同步最新 `develop`。
3. 创建或切换到自己的分支。
4. 做小范围改动。
5. 本地运行或校验。
6. 小步提交。
7. 推送分支。
8. 开 Pull Request。

常用命令：

```powershell
git status
git add .
git commit -m "feat: add player dash cooldown"
git push -u origin feature/your-task-name
```

提交要小而清楚。不要等三天后一次性提交几十个不相关文件。

## 5. Commit 规范

推荐格式：

```text
<type>: <short description>
```

常用 type：

- `feat`: 新功能。
- `fix`: Bug 修复。
- `art`: 美术素材。
- `vfx`: 特效素材或特效接入。
- `audio`: 音效或音乐。
- `docs`: 文档。
- `tune`: 数值和手感调整。
- `refactor`: 不改变行为的代码整理。
- `chore`: 工具、配置、仓库维护。

示例：

- `feat: add player slash chain`
- `fix: prevent dead enemy from receiving hits`
- `art: add scout drone first pass`
- `vfx: add metal hit spark draft`
- `docs: expand github workflow`

## 6. Pull Request 规范

PR 标题格式和 commit 类似：

```text
feat: add first combat slice
```

PR 描述必须包含：

```md
## What
- 这次改了什么

## Why
- 为什么需要这次改动

## Test
- 如何验证
- 是否运行 `.\tools\validate_project.ps1`

## Docs
- Updated:
- Not needed because:

## Assets
- 是否新增或替换素材
- 源文件和导出文件路径

## Risk
- 可能影响哪些系统
- 是否有临时实现
```

程序 PR 至少 1 人 Review 后合并。冻结期或影响主流程的 PR 需要 2 人确认。

## 7. 合并前检查

合并 PR 前必须完成：

```powershell
git status
.\tools\validate_project.ps1
```

Godot 手动检查：

- 主场景能打开。
- 控制台没有红色报错。
- 玩家能移动、跳跃、冲刺、攻击。
- 至少能命中一个敌人。
- `R` 可以重开当前场景。
- 新增素材没有 Missing Resource。

美术/音频改动还要检查：

- `.aseprite`、`.png`、`.wav`、`.ogg` 等是否被 Git LFS 管理。
- 源文件在 `art_src/`。
- 运行时导出素材在 `assets/`。
- `docs/ASSET_MANIFEST.csv` 已更新。

文档同步检查：

- 已按 `docs/DOCUMENTATION_GOVERNANCE.md` 的矩阵检查本次改动。
- 需要同步的 `CHANGELOG.md`、`PROGRESS_LOG.md`、`ASSET_MANIFEST.csv` 或其他规范文档已更新。
- 如果不需要同步文档，PR 描述中的 `Docs` 已写明原因。

## 8. Git LFS 与素材锁定

`.aseprite`, `.ase`, `.png`, `.wav`, `.ogg`, `.mp4` 已配置 Git LFS。

开始编辑大型源文件前，先在群里说明：

```text
我正在编辑 art_src/chr_player_neon_runner.aseprite，预计 21:00 前完成。
```

如果远程仓库启用了 LFS lock，可以使用：

```powershell
git lfs lock art_src/chr_player_neon_runner.aseprite
git lfs unlock art_src/chr_player_neon_runner.aseprite
```

同一个 `.aseprite`、`.psd`、`.kra` 文件同一时间只允许一个人编辑。二进制源文件冲突很难自动合并，要靠提前沟通避免。

## 9. 冲突处理

脚本冲突：

1. 阅读双方改动。
2. 保留必要逻辑。
3. 运行校验和主场景。
4. 在 PR 描述里说明冲突如何解决。

`.tscn` / `.tres` 冲突：

1. 不要盲目选择 ours/theirs。
2. 先看节点、资源 ID、路径引用。
3. 必要时在 Godot 中重新打开并保存场景。
4. 让最后编辑该场景的人参与解决。

素材源文件冲突：

1. 停止继续提交。
2. 找对应素材负责人确认版本。
3. 必要时保留两个版本，再人工合并。

## 10. 禁止事项

- 禁止直接 push 到 `main`。
- 禁止在未同步最新 `develop` 的情况下长期开发。
- 禁止把多个无关功能塞进一个 PR。
- 禁止提交 Godot 生成缓存 `.godot/`。
- 禁止提交导出包、录屏临时文件和本地工具索引。
- 禁止随意 `git push --force` 到公共分支。
- 禁止未经沟通覆盖别人的素材源文件。
- 禁止提交带水印、明显侵权、未登记来源或未通过负责人验收的 AI 素材。

如果确实需要 force push，只允许对自己的功能分支使用：

```powershell
git push --force-with-lease
```

不要使用普通 `git push --force`。

## 11. 推荐工作日节奏

每天开始：

```powershell
git switch develop
git pull --rebase origin develop
git switch feature/your-task-name
git rebase develop
```

每天结束：

```powershell
git status
.\tools\validate_project.ps1
git add .
git commit -m "type: describe completed slice"
git push
```

如果当天工作还没完成，也可以提交 WIP 到自己的分支：

```powershell
git commit -m "chore: wip player attack timing"
git push
```

WIP commit 在合并 PR 前可以整理；重点是不要让重要工作只留在本机。

## 12. Tag 与版本留档

每次可演示版本建议打 tag：

```powershell
git switch main
git pull --rebase origin main
git tag demo-2026-06-07
git push origin demo-2026-06-07
```

8 月 15 日提交版本建议使用：

```text
demo-2026-08-15-submission
```

## 13. 关联文档

- 程序协作细则：`docs/PROGRAMMER_COLLABORATION.md`
- 代码风格：`docs/PROGRAMMING_STANDARDS.md`
- 文档同步规则：`docs/DOCUMENTATION_GOVERNANCE.md`
- 进度记录：`docs/PROGRESS_LOG.md`
- 更改日志：`docs/CHANGELOG.md`
- 决策记录：`docs/DECISION_LOG.md`
- 素材交付：`docs/ASSET_HANDOFF.md`
- AI 素材规则：`docs/AI_ASSET_POLICY.md`
