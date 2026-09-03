---
name: plan-resume
description: Scan for interrupted or stuck task-planner plans across a workspace, judge whether each is still actionable or has expired (by time decay / vanished code environment / already-superseded goal), and report candidates to the user with recommended actions. Use when the user mentions "继续上次任务" / "接着推进" / "看看还有哪些没做完的计划" / "扫一下计划" / "resume plan" / "stale plans" / "task-planner 恢复" — even if they don't explicitly say "resume". Does NOT silently resume or archive plans; the user always decides per plan.
---

# plan-resume — 中断/过期计划扫描与续推决策

主动盘点工作区里中断未完成的 task-planner 计划,逐个判断"还能不能续 / 应不应该放弃",然后输出报告让用户决策。**本 skill 只产出报告与推荐动作,绝不替用户 resume/archive/re-plan/drop** — 这是宪法 §四(用户意图优先)+ §一(主上下文是稀缺资源,大量读取派子代理)的硬约束。

## 何时触发

| 用户原话(中/英) | 触发 |
|-----------------|------|
| "继续上次任务" / "接着推进" / "扫一下还有什么没做完的" | ✅ |
| "看看 plan 里有没有过期的" / "stale plans" | ✅ |
| "/plan-resume" | ✅(user-invocable) |
| "任务卡住了怎么办" | ✅(排查卡点) |
| 用户明示开启新一轮工作但未指明 | ✅(预防"忘记还有未完成") |
| 用户直接给单个具体任务 ("修这个 bug") | ❌(用 task-planner) |
| 用户只是想看仓库某个文件 | ❌ |

## 不做的事

- ❌ 不会自动 `cd` 到 worktree / `git checkout` 分支 / `git merge`
- ❌ 不会自动 `mv plans/X plans/archive/`
- ❌ 不会自动删 task_plan.md
- ❌ 不会替用户改 Goal / Next Step
- ❌ 不会调 task-planner 的 PreToolUse hook(那个 hook 阻断本 skill 不在的写入,本 skill 只读)
- ❌ 不会扫 `.zcode/plans/**` 之外的所有 markdown(只看"计划三件套")

## 工作流(六步)

### 1. 定位所有计划目录

按用户当前工作目录(`pwd`)的 git 仓根扫描。优先用 `scripts/scan-plans.sh <repo-root>`(已写好并发扫描),或主进程直接:

```bash
# 标准 task-planner 计划位置
ls -la plans/*/task_plan.md 2>/dev/null                          # plans/<task-id>/
ls -la plans/task-*/task_plan.md 2>/dev/null                     # 命名任务
ls -la .zcode/plans/plan-sess_*.md 2>/dev/null                   # session-scoped
ls -la skills/*/plans/task-*/task_plan.md 2>/dev/null            # skill 内计划

# openspec 计划位置(本机已验证: /home/terry/openspec/)
ls -la openspec/changes/*/tasks.md 2>/dev/null                   # openspec active change
ls -la openspec/changes/archive/*/tasks.md 2>/dev/null           # openspec archived(默认跳过)

# spec-kit 计划位置(实验性:本机未见过真样例,基于官方模板约定)
ls -la specs/*/tasks.md 2>/dev/null                              # spec-kit feature tasks
ls -la specs/*/spec.md 2>/dev/null                               # spec-kit feature spec
ls -la .specify/specs/*/tasks.md 2>/dev/null                     # spec-kit 旧约定

# worktree 残留(过期判定维度②依赖)
git worktree list
```

> 路径不存在 ≠ 报错;跳过即可。

#### 1.1 用户参数(自然语言声明 → 脚本调用映射)

skill 接收用户在 prompt 中以自然语言声明的过滤/阈值条件,主进程负责转译成脚本参数:

| 用户原话 | 脚本调用 |
|---------|---------|
| "用 30 天阈值" / "30 天以上的才算过期" | `scan-plans.sh --time-threshold 2592000` (30 × 86400) |
| "只看 ts-migration 或 fix 任务" | `scan-plans.sh --only 'ts-migration\|fix'` |
| "只扫 plans/ 子目录" | `scan-plans.sh <root>/plans` |
| "包含已归档的 openspec" | `scan-plans.sh --include-archived` |
| "用默认" / 无声明 | `scan-plans.sh $(pwd)` (默认 7 天阈值,openspec 默认跳过 archive) |

> **报告里必含「实际生效阈值」段**(见 §5.1),避免用户事后忘记自己声明过什么。

### 2. 提取每份计划的元数据

每个计划文件用 `Read` 提取以下字段(自动按格式分派后端,见 §2.1):

| 字段 | 来源 | 用途 |
|------|------|------|
| `task_id` | 目录名 / 文件名 | 报告主键 |
| `goal` | task-planner: `## Goal` 段首句;openspec: `.openspec.yaml` `goal` 字段(无则读 proposal.md `## Why` 段);spec-kit: spec.md `# Feature Specification:` 行 | 过期判定③ |
| `current_phase` | task-planner: `## Current Phase` 段;openspec: tasks.md `## N.` 分组;spec-kit: spec.md `**Status**` 字段或 tasks.md `## Phase N:` | 进度摘要 |
| `phase_status_map` | task-planner: `- **Status:** <s>` 列表 | 进度摘要(task-planner 专用) |
| `last_update` | 文件 mtime(`stat -c %Y`) | 过期判定① |
| `format` | task-planner / openspec / spec-kit | 报告分类列 |
| `task_completion_pct` | openspec + spec-kit: `- [x]` 计数 / `- [ ] + [x]` 总数 | 进度可视化 |
| `is_archived` | openspec archive/ 路径命中 → 1 | 报告默认 drop 标记 |

**主进程自己不要逐文件 Read 大段**(>500 行派 `Explore`;实际计划文件多在 5-12KB,可主进程 Read 头 100 行)。

### 3. 判断完成度(决定要不要进过期判定)

```
所有 phase.status == "complete"  → 已完成,跳过(只列汇总)
phase 含 in_progress              → 进行中,过期判定(可能只是慢)
phase 含 pending 且 ≥1 个         → 中断/未开始,过期判定(核心目标)
Goal 缺失 / Next Step 缺失        → 损坏,直接标 [corrupt]
```

### 4. 三维过期判定(只对未完成项)

每个未完成项跑三维度,**任一命中 = 触发过期推荐**:

#### 维度① 时间衰减(time decay)
| 信号 | 推荐动作 |
|------|---------|
| last_update ≤ 3 天 | `[fresh]` 续推 |
| 3 < last_update ≤ 7 天 | `[stale-warn]` 续推前用户确认上下文 |
| 7 < last_update ≤ 30 天 | `[stale]` 默认 drop,用户可 override |
| > 30 天 | `[expired]` 默认 archive,用户可 override 续推 |

> 阈值为 skill 默认值,用户可在触发时声明覆盖(如"用 30 天阈值")。

#### 维度② 代码环境失效(env vanish)
检查计划 Goal / Scope 里明确列出的路径,缺失率 > 阈值则视为环境失效:

```bash
# 提取计划中的允许文件列表(## ⚠️ 执行范围限制 表格)
grep -E "^\| .*\.(ts|js|py|sh|json|md) " plans/<id>/task_plan.md

# 任一关键文件 fs 不可达 + worktree 分支已删除 → 维度②命中
git worktree list | grep -q "<branch>"  # worktree 已清理
ls -la plans/<id>/task_plan.md 2>/dev/null  # 计划文件本身消失(已被 mv 到 archive)
```

| 信号 | 推荐动作 |
|------|---------|
| worktree 分支 `wt/<id>` 已删 + worktree_path 路径不存在 | `[env-vanished] archive` |
| Scope 列出的源文件 >50% 不存在 | `[env-vanished] drop 或 re-plan` |
| 全部存在 + worktree 在 | `[env-ok]` 不触发 |

#### 维度③ 目标已被取代(goal superseded)
```bash
# 最近 7 天 commits 涉及计划 Goal 关键字 → 可能已被顺便完成
git log --since="<last_update>" --oneline | grep -iE "<goal_keywords>"
```

| 信号 | 推荐动作 |
|------|---------|
| 最近 commits 与 Goal 重叠 ≥ 70%(粗判) | `[superseded] drop + 写明 commit` |
| commits 与 Goal 重叠 30-70% | `[possibly-superseded] 用户判断` |
| < 30% 或无 commits 涉及 | `[unique] 续推` |

> 维度③ 实现成本最高,**前两个维度已能覆盖 80% 场景**;第三维度若 grep 出 0 命中,直接跳过不深入。

### 5. 输出报告

#### 5.1 报告格式(强制)

写到 `<worktree-or-cwd>/.zcode/plans/plan-resume-report.md`(已存在则覆写),并在主上下文打印摘要。

```markdown
# plan-resume 报告 — <YYYY-MM-DD HH:MM>

> 工作区: <repo-root>
> 扫描源: <列举的位置,5 项最多>
> 阈值: time=[3d/7d/30d]

## 汇总

| 总计划 | 已完成 | 未完成 | 推荐 resume | 推荐 archive | 推荐 drop | 损坏 |
|--------|--------|--------|-------------|--------------|-----------|------|
| 12 | 8 | 4 | 1 | 2 | 1 | 0 |

> 格式覆盖: task-planner / openspec / spec-kit(实验性)

## 候选清单(按推荐动作排序)

### ✅ 推荐 resume — 1 项
| Task ID | Format | Goal(摘要) | Current Phase | Last Update | 完成度 | 备注 |
|---------|--------|------------|---------------|-------------|--------|------|
| `task-cext-ts-migration` | task-planner | content-extractor Python→TS 迁移 | Phase 3 in_progress | 5 天前 | n/a | [fresh] |
| `feature-101` | spec-kit | My Feature 101 | Draft | 7 天前 | 33% | [stale-warn] |

### ⚠️ 推荐用户判断 — 1 项
| Task ID | Format | Goal | Current Phase | Last Update | 维度 |
|---------|--------|------|---------------|-------------|------|
| `task-X` | task-planner | ... | ... | 12 天前 | ① [stale] |
| `proposal-y` | openspec | ... | 12/24 tasks | 18 天前 | ①③ |

### 🚫 推荐 archive — 2 项
| Task ID | Format | Goal | 触发维度 | 证据 |
|---------|--------|------|----------|------|
| `task-Y` | task-planner | ... | ①② | worktree 已删;scope 50% 不存在 |
| `archived-change` | openspec | ... | ①[archived] | 目录在 openspec/changes/archive/ |

### ❌ 推荐 drop — 1 项
| Task ID | Format | Goal | 触发维度 | 证据 |
|---------|--------|------|----------|------|
| `task-W` | task-planner | ... | ②③ | commits 已包含目标 |
| `proposal-Z` | openspec | ... | ③ | archived 且目标与近期 commits 重合 |

## 损坏项 — 0 项
(无)

## 报告元信息

- 扫描时间:<ISO 时间>
- 扫描源路径:<abs 路径列表>
- 维度①时间阈值:3/7/30 天(可覆盖)— **写入用户实际生效值**
- 维度② fs 检查:enabled
- 维度③ commit 关键词匹配:enabled
- 报告路径:<abs path>
- 用户声明的参数:(如有:阈值 N 天 / 仅扫描 X / 等)
```

#### 5.2 主上下文打印(用户看的那段)

**只打印表格摘要 + 报告路径**,不打印明细(明细在文件里,用户 Read 复核或 grep)。摘要模板:

```
[plan-resume] 扫到 12 个 task-planner 计划(4 个未完成)
  ✅ 1 个推荐 resume:task-cext-ts-migration (Phase 3 in_progress, 5 天前)
  ⚠️ 1 个待你判断:task-X (12 天未动)
  🚫 2 个推荐 archive:task-Y / task-Z
  ❌ 1 个推荐 drop:task-W
完整报告: <abs path>/.zcode/plans/plan-resume-report.md
要不要继续?(让我知道怎么处理每一个,或直接说"按推荐全部执行")
```

### 6. 等用户决策(不替用户动)

报告输出后**停止**。用户可能说:

| 用户响应 | skill 后续动作 |
|---------|---------------|
| "按推荐全部执行" | 主进程(或派 code-assistant)按推荐动作执行 — 但**仍需逐项确认** |
| "把 task-Y archive,task-Z 再等等" | 主进程 mv 到 plans/archive/,改 task-Z 的 Next Step 加 `[hold]` 标签 |
| "重新规划 task-W" | 主进程调 task-planner 新建 task_plan.md 覆盖 |
| "再看看 task-X 的 progress.md" | 主进程 Read 该任务 progress.md 提供更多上下文 |
| 不回应 / 忽略 | **什么都不做**(本 skill 不强推) |

## 失败兜底

| 现象 | 兜底 |
|------|------|
| plans/ 不存在 | 报告"工作区无 task-planner 计划",结束 |
| task_plan.md 损坏 / frontmatter 缺失 | 标 [corrupt],报告里单独列出,不替用户删 |
| git worktree list 调用失败 | 维度② 跳过 worktree 检查,只查 fs |
| commit log grep 无命中 | 维度③ 标 `[unique]`,默认续推 |
| 单个 Read 失败 | 跳过该文件,日志记一行,不阻断扫描 |

## 与其他 skill 的关系

| Skill | 关系 |
|-------|------|
| `task-planner` | 本 skill 只**读取** task-plan 文件,不修改/不触发它的 hooks。续推时调它新建计划 |
| `task-drift-guard` | drift-guard 是"执行中检测漂移",本 skill 是"中断后盘点过期"。**互不替代** |
| `session-catchup` | session-catchup 扫 Claude session jsonl 找上下文断点;本 skill 扫文件系统找任务断点。互补 |
| `todo-skill` | todo-skill 是 Claude 内的轻量 todo 列表;本 skill 处理 task-planner 的长期计划文件 |
| `memory-cleanup` | memory-cleanup 处理记忆系统;本 skill 处理任务系统。结构类似(扫 → 判断 → 报告) |
| `agent-browser` / `Browser Automation` | 不涉及 |

## 设计权衡(用户决策记录)

- **不替用户动手**:用户宪法 §四 P0 漂移防护;resume/archive 是用户意图边界,AI 替决 = 漂移温床
- **多维度而非单时间**:单一时间维度误杀多(短任务快过期 / 长任务正常推进都可能被错杀),组合判定更稳
- **报告先写文件再打印摘要**:主上下文只承担摘要,明细落盘让用户可 Read 可 grep 可分享(顺带实现 §一"主上下文是稀缺资源")
- **不调 task-planner 的 hooks**:`check-scope.sh` 会阻断 PreToolUse 写入;本 skill 只读不写,绕开

## 参考

- `scripts/scan-plans.sh` — 并发扫描所有计划位置(发到 `<plan-resume>/scripts/` 同步)
- `scripts/extract-meta.sh` — 单文件元数据提取(grep 实现,不依赖 jq/python)
- 用户宪法 `~/.zcode/AGENTS.md` §一(子代理优先)、§四(用户意图优先与防漂移)