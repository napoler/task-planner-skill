---
name: plan-resume
description: Scan for interrupted or stuck task-planner plans across a workspace, judge whether each is still actionable or has expired (by time decay / vanished code environment / already-superseded goal), and report candidates with actions. v0.5 (2026-09-05) 自主推进默认化: 在恢复触发点(会话启动无活跃计划/用户说"继续上次任务"类/当前计划交付终态后),模型自主分析打分选 1 个最值得推进的计划并立即续推至完成或用户决策点,不再等待用户抉择(config.json autonomous_resume,会话级说"不要自动续推"可关);当前计划执行中的被动扫描仍只报告不动手。Use when the user mentions "继续上次任务" / "接着推进" / "看看还有哪些没做完的计划" / "扫一下计划" / "resume plan" / "stale plans" / "task-planner 恢复" — even if they don't explicitly say "resume".
---

# plan-resume — 中断/过期计划扫描与续推决策

主动盘点工作区里中断未完成的 task-planner 计划,逐个判断"还能不能续 / 应不应该放弃"。**v0.5 双模式契约**(取代 v0.4"一律 dry-run"旧契约,依据用户 2026-09-05 明确指令"模型自主根据分析选择需要推进的任务进行完成,而不是等待用户抉择"):

| 模式 | 何时生效 | 行为 |
|------|---------|------|
| **自主推进(默认)** | 恢复触发点:① 会话启动且当前无活跃计划 ② 用户发出恢复类指令("继续上次任务"等) ③ 当前计划刚交付终态(COMPLETE/交付报告落盘) | 打分选 1 个最值得推进的计划 → 立即续推至交付或需用户决策点;选人理由必须报告(§7) |
| **只报告(dry-run)** | 当前计划执行中的被动扫描(task-planner Rule 24);或 `autonomous_resume: false`;或用户本轮说过"不要自动续推"/"只扫不动" | 只产出报告与推荐动作,不替用户 resume/archive/re-plan/drop |

守卫底线(两模式共同):跨仓/跨项目候选一律只报告不自动续推(宪法 §五 跨项目隔离 P0);BLOCKED / `[awaiting-user]` / `[hold]` / 熔断标记计划一律跳过;单次触发最多自主续推 1 个计划。详见 §7。

> 历史注: v0.4 的 smart-resume(cron `--auto-push` opt-in)已并入本 §7 自主推进模式,cron 场景复用同一路径;`--auto-push` flag 保留为显式覆盖开关。

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

- ❌ 本 skill 自身不会自动 `cd` 到 worktree / `git checkout` 分支 / `git merge`(自主续推时这些由**调用方**按 task-planner 协议执行,含其 worktree 合约)
- ❌ 不会自动 `mv plans/X plans/archive/`
- ❌ 不会自动删 task_plan.md
- ❌ 不会替用户改 Goal / Next Step(自主续推=接着干,发现 Goal 需变更即 STOP 写 `[awaiting-user]`)
- ❌ 不会调 task-planner 的 PreToolUse hook(那个 hook 阻断本 skill 不在的写入,本 skill 只读)
- ❌ 不会扫 `.zcode/plans/**` 之外的所有 markdown(只看"计划三件套")
- ❌ 自主模式下不会扫仓外/全局计划位置,不会一次续推多个计划

## 工作流(六步)

### 1. 定位所有计划目录

按用户当前工作目录(`pwd`)的 git 仓根扫描。优先用 `scripts/scan-plans.sh <repo-root>`(已写好并发扫描),或主进程直接:

```bash
# 标准 task-planner 计划位置
ls -la plans/*/task_plan.md 2>/dev/null                          # plans/<task-id>/
ls -la plans/task-*/task_plan.md 2>/dev/null                     # 命名任务
ls -la .zcode/plans/plan-sess_*.md 2>/dev/null                   # session-scoped
ls -la skills/*/plans/task-*/task_plan.md 2>/dev/null            # skill 内计划

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
| "用默认" / 无声明 | `scan-plans.sh $(pwd)` (默认 7 天阈值) |

> **报告里必含「实际生效阈值」段**(见 §5.1),避免用户事后忘记自己声明过什么。

### 2. 提取每份计划的元数据

每个 task_plan.md 用 `Read` 提取以下五字段(grep 模式,见 `scripts/extract-meta.sh`):

| 字段 | 来源 | 用途 |
|------|------|------|
| `task_id` | 目录名 / `plan-sess_*` 文件名 | 报告主键 |
| `goal` | `## Goal` 段首句(到第一个 `.` / 换行) | 过期判定③(目标对比) |
| `current_phase` | `## Current Phase` 段内容 | 是否已完成 |
| `next_step` | `## Next Step` 段首句 | 续推动作提示 |
| `phase_status_map` | `### Phase N: ...` 下 `- **Status:** <s>` 列表 | 进度摘要 |
| `last_update` | `git log -1 --format=%ct plans/<id>/task_plan.md` 或 `stat -c %Y` | 过期判定①(时间) |

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

## 候选清单(按推荐动作排序)

### ✅ 推荐 resume — 1 项
| Task ID | Goal(摘要) | Current Phase | Last Update | 备注 |
|---------|------------|---------------|-------------|------|
| `task-cext-ts-migration` | content-extractor Python→TS 迁移 | Phase 3 in_progress | 5 天前 | [fresh] |

### ⚠️ 推荐用户判断 — 1 项
| Task ID | Goal | Current Phase | Last Update | 维度 |
|---------|------|---------------|-------------|------|
| `task-X` | ... | ... | 12 天前 | ① [stale] |

### 🚫 推荐 archive — 2 项
| Task ID | Goal | 触发维度 | 证据 |
|---------|------|----------|------|
| `task-Y` | ... | ①② | worktree 已删;scope 50% 不存在 |
| `task-Z` | ... | ① | 18 天未动 |

### ❌ 推荐 drop — 1 项
| Task ID | Goal | 触发维度 | 证据 |
|---------|------|----------|------|
| `task-W` | ... | ②③ | commits 已包含目标 |

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

### 6. 决策路由(v0.5:默认自主推进,不再等用户抉择)

报告输出后,按当前生效模式路由:

**自主推进模式(触发点①②③ + `autonomous_resume: true`)**:不停止、不等用户选择——按 §7 打分选 Top 1,报告"选了哪个 + 为什么(score 细节) + 下一步动作",然后**调用方立即续推该计划**:Read 其三文件(task_plan/progress/findings)→ 定位下一 pending Phase → 按 task-planner 协议执行(含其 worktree 合约与 Executor 派发规则)→ 推进至交付或需用户决策点。续推期间每 Phase complete 后仍走 task-planner 的 DRIFT CHECK / plan-resume 被动扫描(此时为只报告)。

**只报告模式(执行中扫描 / `autonomous_resume: false` / 用户本轮逃生)**:报告输出后**停止**,等用户响应:

| 用户响应 | skill 后续动作 |
|---------|---------------|
| "按推荐全部执行" | 主进程(或派 code-assistant)按推荐动作执行 — 但**仍需逐项确认** |
| "把 task-Y archive,task-Z 再等等" | 主进程 mv 到 plans/archive/,改 task-Z 的 Next Step 加 `[hold]` 标签 |
| "重新规划 task-W" | 主进程调 task-planner 新建 task_plan.md 覆盖 |
| "再看看 task-X 的 progress.md" | 主进程 Read 该任务 progress.md 提供更多上下文 |
| "续推 task-X" / 不回应 / 忽略 | 只报告模式下:用户点名才动;不回应=什么都不做(不强推) |

**用户否决权(两模式恒有效)**:用户本轮任何时点说"不要自动续推"/"停下"/"换一个",立即中止当前自主推进并回到只报告;被否决的计划写 `[hold]` 标记,本轮不再自动选中。

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

- **恢复场景自主、执行场景克制**(v0.5):用户 2026-09-05 明确要求"自主选任务推进,不等用户抉择"——恢复触发点的等待被认定为体验缺陷;但执行中被动扫描仍只报告,防打断进行中工作(§四 漂移防护在续推计划自身的 Rule 24/guard 链路中保留)
- **多维度而非单时间**:单一时间维度误杀多(短任务快过期 / 长任务正常推进都可能被错杀),组合判定更稳
- **报告先写文件再打印摘要**:主上下文只承担摘要,明细落盘让用户可 Read 可 grep 可分享(顺带实现 §一"主上下文是稀缺资源")
- **不调 task-planner 的 hooks**:`check-scope.sh` 会阻断 PreToolUse 写入;本 skill 只读不写,绕开

## 参考

- `scripts/scan-plans.sh` — 并发扫描所有计划位置(发到 `<plan-resume>/scripts/` 同步)
- `scripts/extract-meta.sh` — 单文件元数据提取(grep 实现,不依赖 jq/python)
- `scripts/score-plans.py` — 综合加权打分(out_degree 50% + git_hits 30% + 失败反比 20%;v0.4 引入)
- `scripts/select-and-resume.sh` — 自主推进编排(v0.5: config 驱动,默认自主;`--dry-run`/`--auto-push` 显式覆盖)
- `config.json` — **v0.5 新增** 自主推进开关与守卫阈值(§7.2)
- 用户宪法 `~/.zcode/AGENTS.md` §一(子代理优先)、§四(用户意图优先与防漂移)、§五(安全底线/跨项目隔离)、§十一(worktree 隔离)

---

## §7 自主推进模式(2026-09-05 v0.5;由 v0.4 smart-resume 升级)

> **核心变更**: v0.4 旧契约"只扫描不执行,smart-resume 需显式 opt-in"在恢复场景下升级为**默认自主**: 恢复触发点命中即自动选 1 个最值得推进的计划 + 写 `[auto-pushed-by-cron]` 标记 + 调用方立即续推。授权来源从"每次调用方 prompt 显式声明"改为 **config.json `autonomous_resume`(默认 true)+ 会话级逃生**。

### 7.1 触发条件与授权模型

| 触发方 | 触发方式 | 生效模式 |
|--------|----------|----------|
| 会话启动无活跃计划(触发点①) | 初始化流程扫到中断计划且当前无 in_progress 计划 | 自主(config 开) |
| 用户恢复类指令(触发点②) | "继续上次任务"/"接着推进"等,未指明具体任务 | 自主(config 开) |
| 当前计划交付终态后(触发点③) | task-planner 终验交付 COMPLETE 后 | 自主(config 开) |
| task-planner Rule 24 执行中被动扫描 | 当前计划 Phase complete 后 | **只报告**(防打断进行中工作) |
| cron automation | `select-and-resume.sh --auto-push`(显式 flag,沿用) | 自主 |
| 显式 `--dry-run` flag / `autonomous_resume: false` / 用户说"不要自动续推" | — | 强制只报告 |

**授权优先级**: 用户本轮口头指令 > `--dry-run`/`--auto-push` flag > config.json 默认。

### 7.2 配置(config.json,与本 SKILL.md 同目录)

```json
{
  "autonomous_resume": true,
  "max_auto_plans_per_trigger": 1,
  "cross_project_auto_resume": false,
  "skip_states": ["blocked", "awaiting-user", "hold"],
  "fresh_threshold_days": 7,
  "max_failure_count": 3
}
```

| 键 | 默认 | 说明 |
|----|------|------|
| `autonomous_resume` | `true` | 自主推进总开关(v0.5 核心变更;false=退回 v0.4 全 dry-run 行为) |
| `max_auto_plans_per_trigger` | `1` | 单次触发自主续推上限,禁止调大(防上下文耗尽) |
| `cross_project_auto_resume` | `false` | **禁止改 true**——跨仓候选永远只报告(宪法 §五 跨项目隔离 P0),此键仅为显式表达禁令存在 |
| `skip_states` | blocked/awaiting-user/hold | 计划内出现这些状态标记(Phase Status/Next Step 标签)即硬排除,不参与打分 |
| `fresh_threshold_days` | `7` | 沿用 §7.4 过滤的 age 上限 |
| `max_failure_count` | `3` | Error Log 失败数上限,≥N 过滤 |

脚本读取:`select-and-resume.sh` 启动时解析同目录 `config.json`(缺文件/缺键用上表默认值,不报错)。

### 7.3 智能打分公式(用户 2026-09-04 拍板,v0.5 沿用)

```
importance_score(plan) =
    0.5 × normalize(out_degree(plan), 0..max)
  + 0.3 × normalize(git_keyword_hits(plan), 0..max)
  + 0.2 × normalize(max(0, 5 - failure_count) / 5)
```

- **out_degree(50%)** — plan 的 `block_id`(若无则用 task_id)被其他 plan 的 `depends_on` 引用次数。阻塞越多越重要。
- **git_keyword_hits(30%)** — plan Goal 段前 5 关键词在最近 7d `git log --oneline -i` 中的命中数。用户最近关注度。
- **failure 反比(20%)** — `failure_count` 来自 progress.md Error Log 段。失败越多分越低,≥3 次直接过滤。

### 7.4 候选过滤(必须全部满足)

| 条件 | 来源 | 不通过动作 |
|------|------|-----------|
| 真实 age ≤ `fresh_threshold_days`(默认 7d) | `git log -1 --format=%ct`,untracked 用 mtime | 跳过 |
| `all_complete = 0` | 含 `pending` 或 `in_progress` phase | 跳过 |
| 无 `skip_states` 状态标记 | phase `Status: blocked` / `[awaiting-user]` / `[hold]` 标签 | **硬排除**(v0.5 新增:等用户决策的计划不许自动续推) |
| `failure_count < max_failure_count` | progress.md Error Log 条目 | 跳过 |
| 计划位于 `--repo-root` 仓内 | scan-plans.sh 扫描源本就仓内相对 | 硬排除(跨项目候选只报告,v0.5 显式化) |
| 无 `[auto-pushed-by-cron]` | 防重入 | 跳过 |
| 无 `[circuit-break-by-cron]` | 防已熔断 | 跳过 |
| `## Goal` 段存在 | Read 头 30 行验证 | CIRCUIT-BREAK |

### 7.5 推进纪律(circuit-break 一律熔断)

- **单次触发最多 `max_auto_plans_per_trigger`(=1) 个 plan** — 用户 2026-09-04 拍板
- **推进前 Read 头 30 行** — 确认 Goal 不变(防 plan 已被人工改向)
- **推进 = 在 plan 头部写 `<!-- [auto-pushed-by-cron: <ts> mode=auto-resume score=<N>] -->` 标记**(标记 token 沿用 v0.4,防旧过滤逻辑失效)
- **选中后调用方立即续推**(v0.5 变更,取代 v0.4"只选+标记"):Read 该计划三文件 → 下一 pending Phase → 按 task-planner 协议执行;plan-resume 自身仍不直接改计划正文以外的文件
- **续推是"接着干",不是"重新决定"**:不得改 Goal/VC/范围;发现 Goal 需变更 = STOP 写 `[awaiting-user]` 交回用户
- **circuit-break 触发**(任一):
  - Phase 推进连续失败 ≥2 次
  - 子代理 30min 无产物
  - P0 投毒哨兵触发
  - 推进时检测到 plan Goal 已被人工改向
  → 立即停止,写 `[circuit-break-by-cron: <reason>]` 标记
- **不做的事**:
  - 不替用户 archive/drop plan(只标记候选)
  - 不读 / 改 /tmp、config/、.env* 等非 plans/ 文件
  - 不在自主续推里二次自主开新计划(交付后回到触发点③重新评估)

### 7.6 报告输出(每次都写)

`.zcode/plans/plan-resume-report-<YYYYMMDD-HHMM>.md` 包含:
- 扫描总数 / 候选数 / Top 1 score
- 候选 Top 列表(完整 score 细节)
- 推进模式(dry-run / auto-push)
- 推进结果(标记写入 / 跳过原因 / circuit-break)

### 7.7 与旧契约的兼容性

| 调用方 | 默认行为 | v0.5 影响 |
|--------|----------|------|
| task-planner Rule 24 执行中被动扫描 | **dry-run** | 不变(防打断进行中工作) |
| 会话启动/恢复指令/交付终态后 | **自主续推 Top 1**(config 开) | **变更**:旧版此处也 dry-run 等用户点名 |
| 用户在主会话调 Skill("plan-resume") 且指明"只扫不动" | dry-run + 报告 | 不变 |
| cron `automation-ae80e75d` | **auto-push**(cron prompt 显式 flag) | 沿用,内部复用同一自主路径 |
| 显式 `bash select-and-resume.sh --auto-push` / `--dry-run` | flag 显式覆盖 config | 手动触发保留 |
| `autonomous_resume: false` | 全场景 dry-run | 等效 v0.4 行为 |

→ **恢复场景自主化是默认**,执行中扫描保持只报告;`config.json` 一个开关可整体退回 v0.4。

### 7.8 已知风险与缓解

| 风险 | 缓解 |
|------|------|
| 误推 stale plan(mtime 不可信) | 用 `git log` 真实时间;untracked 用 mtime 但已记录 |
| 推进与 article-update cron 抢 plan | 推进前 Read 头 30 行 + `[auto-pushed-by-cron]` 标记防重入 |
| 自主续推接管了用户故意搁置的计划 | `skip_states` 硬排除 blocked/[awaiting-user]/[hold];用户口头"不要自动续推"会话级逃生 |
| 用户撤回"auto-push"授权 | 删 plan 头部的 `[auto-pushed-by-cron]` 标记即可让下次 cron 重新评估;或 config 关总开关 |
| score-plans.py 选错 plan | 单次最多推 1 个,失败 circuit-break,下次重新评估 |
| 自主续推中途需要用户决策(计划本身 BLOCKED 点) | 推进至 `[awaiting-user]` 点即停,写标记交回用户,不硬闯 |
| 推进后 plan 长期挂 [auto-pushed] 标记 | Phase complete 时由调用方清理标记 |

### 7.9 用户决策记录

| 决策 | 选择 | 理由 |
|------|------|------|
| 修改层级 | 改 skill 文件 | 用户明确说"当前技能文件存在严重的问题" |
| 选择策略 | 重要度优先(综合加权) | 比单维度更稳 |
| 执行边界 | 单次 ≤ 1 个 plan | 防上下文耗尽 |
| 安全护栏 | circuit-break 一律熔断 | 漂移防护,避免连环错误 |
| 打分公式 | out_degree 50% + git_hits 30% + 失败反比 20% | 综合三项关键信号 |
| **v0.5 自主化**(2026-09-05) | 恢复触发点默认自主续推,执行中扫描保持只报告 | 用户明确指令"模型自主根据分析选择需要推进的任务进行完成,而不是等待用户抉择";守卫(跨仓只报告/BLOCKED 跳过/单次 1 个/否决权)对冲自主风险 |