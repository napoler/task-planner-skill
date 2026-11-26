---
name: plan-resume
model: sonnet
description: Scan for interrupted or stuck task-planner plans across a workspace, judge whether each is still actionable or has expired (by time decay / vanished code environment / already-superseded goal), and report candidates with actions. v0.6 (2026-09-06) 决策自主化: 在恢复触发点(会话启动无活跃计划/用户说"继续上次任务"类/当前计划交付终态后),模型自主分析打分选 1 个最值得推进的计划并立即续推至交付,途中执行级决策点(待你决策/二选一/[awaiting-user])按 §7.10 四项测试自主裁决并记录,不停车等用户(config.json autonomous_resume,会话级说"不要自动续推"可关);当前计划执行中的被动扫描仍只报告不动手。Use when the user mentions "继续上次任务" / "接着推进" / "看看还有哪些没做完的计划" / "扫一下计划" / "resume plan" / "stale plans" / "task-planner 恢复" — even if they don't explicitly say "resume".
---

# plan-resume — 中断/过期计划扫描与续推决策

主动盘点工作区里中断未完成的 task-planner 计划,逐个判断"还能不能续 / 应不应该放弃"。**v0.6 决策自主化契约**(v0.4 dry-run → v0.5 恢复场景默认自主 → v0.6 决策点自主裁决,不停车):

| 模式 | 何时生效 | 行为 |
|------|---------|------|
| **自主推进(默认)** | 恢复触发点:① 会话启动且无活跃计划 ② 用户恢复类指令("继续上次任务"等) ③ 当前计划交付终态(COMPLETE/交付报告落盘) | 打分选 1 个最值得推进的计划 → 续推**至交付**;途中执行级决策点按 §7.10 四项测试自主裁决并记录,不停车;选人理由必须报告(§7) |
| **只报告(dry-run)** | 当前计划执行中的被动扫描(task-planner Rule 24);或 `autonomous_resume: false`;或用户本轮说"不要自动续推"/"只扫不动" | 只产出报告与推荐动作,不替用户 resume/archive/re-plan/drop |

守卫底线(两模式共同):跨仓/跨项目候选一律只报告(宪法 §五 P0);`[blocked]`/`[hold]`/`[user-vetoed]`/熔断标记跳过(`[awaiting-user]` **不跳过**——决策点是自主裁决对象,§7.10);单次触发最多自主续推 1 个计划。详见 `references/autonomous-resume-detail.md`（自主续推详细配置/打分/过滤/纪律/框架）；触发：需要配置或理解自主续推细则、打分过滤或决策框架时；关键词：autonomous-resume, 打分, 续推配置, 决策框架。

## 何时触发

| 用户原话(中/英) | 触发 |
|-----------------|------|
| "继续上次任务"/"接着推进"/"扫一下还有什么没做完的"/"看看 plan 有没有过期的"/"resume plan"/"stale plans"/"task-planner 恢复"/"/plan-resume"/"任务卡住了怎么办" | ✅ |
| 用户明示开启新一轮工作但未指明 | ✅(预防忘记未完成) |
| 用户直接给单个具体任务("修这个 bug")/只是想看某个文件 | ❌ |

## 不做的事

- ❌ 不自动 `cd` worktree / `git checkout` / `git merge`(自主续推由调用方按 task-planner/worktree 合约执行)
- ❌ 不删 `task_plan.md`、不物理删除计划；归档(`mv` 到 `plans/archive/`)仅限已交付(PARTIAL/COMPLETE)或真模板垃圾脚手架,逐条判据记录后执行；非交付计划只推荐不移动
- ❌ 不改 Goal/Next Step；Goal 需变更即 STOP 写 `[awaiting-user]`(§7.10 合法停点)
- ❌ 不调 task-planner PreToolUse hook(本 skill 只读)；不扫三件套以外 markdown；自主模式不扫仓外/全局、不一次续推多个

## 工作流(六步)

### 1. 定位计划目录 [M]
按 `pwd` 的 git 仓根扫描。优先 `scripts/scan-plans.sh <repo-root>`，或:
```bash
ls -la plans/*/task_plan.md 2>/dev/null
ls -la plans/task-*/task_plan.md 2>/dev/null
ls -la .zcode/plans/plan-sess_*.md 2>/dev/null
ls -la skills/*/plans/task-*/task_plan.md 2>/dev/null
git worktree list
```
路径不存在跳过。用户参数映射: "30 天阈值"→`--time-threshold 2592000`；"只看 X"→`--only 'X'`；"只扫 plans/"→传 `<root>/plans`；默认 7 天。报告必含实际生效阈值(§5)。

### 2. 提取元数据 [M]
每个 `task_plan.md` 提取(grep/`scripts/extract-meta.sh`,>500 行派 `Explore`;多为 5-12KB 可 Read 头 100 行): `task_id`/`goal`(`## Goal` 首句)/`current_phase`/`next_step`/`phase_status_map`(`Status:`)/`last_update`(`git log -1 --format=%ct` 或 `stat -c %Y`)。

### 3. 判断完成度 [M]
全部 complete→跳过(仅汇总)；含 in_progress→过期判定(可能慢)；含 pending→中断/未开始,过期判定(核心)；Goal/Next Step 缺失→`[corrupt]`。

### 4. 三维过期判定(仅未完成) [A]
任一命中=触发过期推荐:
- **① 时间衰减**: ≤3d `[fresh]`续推；3-7d `[stale-warn]`续推前确认上下文；7-30d `[stale]`默认 drop；>30d `[expired]`默认 archive(阈值可覆盖)。
- **② 环境失效**: 提取 `## ⚠️ 执行范围限制` 路径；`wt/<id>` 分支+worktree 路径不存在→`[env-vanished] archive`；Scope 源文件 >50% 不存在→`drop/re-plan`；全部存在→`[env-ok]`。
- **③ 目标已取代**: `git log --since=<last_update>` 与 Goal 关键字粗判重叠 ≥70%→`[superseded] drop+commit`；30-70%→`[possibly-superseded]`用户判断；<30%/无命中→`[unique]`续推(①②已覆盖 80% 场景,无命中可跳过)。

### 5. 输出报告 [M]
写 `<cwd>/.zcode/plans/plan-resume-report.md`(存在则覆写)+主上下文摘要。

**报告必含**: 工作区/扫描源/阈值(实际生效值+用户声明参数)/汇总表(总/完成/未完成/resume/archive/drop/损坏)/候选清单(按推荐动作: ✅resume/⚠️判断/🚫archive/❌drop/损坏,含 Task ID+Goal+Phase+Last Update+维度+证据)/元信息(ISO 时间/源路径/fs+commit 检查开关/报告路径)。

**主上下文(≤5 行摘要+报告路径)**: 仅 dry-run 模式末句问"要不要继续?";自主推进模式不问,直接按 §7 续推至交付。

### 6. 决策路由 [A]
- **自主推进**(触发点①②③+config 开): 不停不等——§7 打分选 Top 1,报告"选了谁+为什么(score)+下一步",调用方立即续推: Read 三文件→下一 pending Phase→按 task-planner/worktree/Executor 执行→**推进至交付**;途中决策点按 §7.10 自主裁决并记录。续推期每 Phase complete 仍走 DRIFT CHECK/被动扫描(只报告)。
- **只报告**(执行中/`autonomous_resume:false`/逃生): 停止等用户("按推荐全部执行"仍需逐项确认/"archive X"/"重新规划"/"看看 progress"/"续推 task-X"点名才动,不回应=不动)。

**否决权恒有效**: 用户说"不要自动续推"/"停下"/"换一个"→中止并回到只报告;被否决计划记 `[hold]`,本轮不再选中。

## 失败兜底
plans/ 不存在→报告无计划并结束；task_plan 损坏/缺 frontmatter→`[corrupt]`单列不删；worktree list 失败→跳过② worktree 检查；commit grep 无命中→③ `[unique]`；单文件 Read 失败→跳过记日志不阻断。

## 与其他 skill 的关系
`task-planner`(只读,续推调其新建) / `task-drift-guard`(执行中漂移 vs 中断后盘点,互补) / `task-planner scripts/session-catchup.ts`(扫 session jsonl vs 扫文件系统,互补) / `todo-skill`(轻量 todo) / `memory-cleanup`(扫→判→报告结构类似)。

## 设计权衡(决策记录)
恢复场景自主、执行场景克制(v0.5,用户 2026-09-05)；多维度判定(非单时间)；报告落盘+主上下文摘要(§一)；不调 task-planner hooks(只读)。

## 参考
`scripts/scan-plans.sh` / `scripts/extract-meta.sh` / `scripts/score-plans.py` / `scripts/select-and-resume.sh`；`config.json`(§7.2 真源)；`references/critical-rules-resume.md`（Rule 24；触发：查阅计划续推/自主推进触发时机、守卫与降级契约时；关键词：critical-rules-resume Rule24 续推 触发时机）`；`references/autonomous-resume-detail.md`(§7 详细配置/打分/过滤/纪律/框架/兼容/风险)；宪法 `~/.zcode/AGENTS.md` §一/§四/§五/§十一。

---

## §7 自主推进模式(摘要,详见 `references/autonomous-resume-detail.md`；触发：配置/排查自主续推行为、打分或熔断策略时；关键词：autonomous_resume, 打分, 熔断, 续推策略)

> v0.5:恢复触发点默认自主(config `autonomous_resume`+逃生)。v0.6:决策点按 §7.10 自主裁决不停车；仅宪法 P0/Goal 重定义/circuit-break/用户喊停四类合法停点。

### 7.1 触发与授权
触发点①②③(会话启动无活跃/恢复指令/交付终态)→自主；Rule 24 执行中被动扫描→只报告；cron `--auto-push` 沿用。优先级:用户本轮口头 > `--dry-run`/`--auto-push` flag > `config.json`。

### 7.2-7.6 机制要点
配置见 `config.json`/参考文档(`cross_project_auto_resume` 禁 true)。打分: `0.5*out_degree + 0.3*git_keyword_hits + 0.2*failure反比`。过滤: age≤阈值、未全完成、无 blocked/hold/user-vetoed、非脚手架垃圾、失败<上限、仓内、防重入/熔断、Goal 存在；`[awaiting-user]` 不排除。纪律: 单次≤1、推进前 Read 头 30 行确认 Goal、写 `[auto-pushed-by-cron]`、调用方立即续推至交付、途中决策点 §7.10 裁决；circuit-break(连续失败≥2/30min 无产物/P0 投毒/Goal 被改向)→写 `[circuit-break-by-cron]` 停。报告: `.zcode/plans/plan-resume-report-<YYYYMMDD-HHMM>.md` 含 score/结果/自主裁决清单。

### 7.10 自主决策框架(v0.6)
遇「待你决策/待你授权/二选一/`[awaiting-user]`」**不停车**。四项测试全 PASS 才裁决执行并记录: **T1 可逆性**(有回滚路径,一票否决)/ **T2 范围**(在计划允许清单内且服务 Goal)/ **T3 宪法 P0**(不写保护区/不涉凭据/不跨项目,技能无法自授权)/ **T4 先例一致性**。优先级:用户先例→数据判据→保守可逆。三处落盘(Decisions Made+progress+报告裁决清单)。合法停点仅四类(P0/Goal 重定义/circuit-break/用户喊停),停时交付已完成裁决清单+最小决策请求,**禁止**把可判定决策包装成待确认。

### 7.11 执行后证据字段（S82 验证完备最小模板）
<!-- [2026-11-23 task-fix-all-20261123] 补最小可照抄证据字段模板，强化 S82 验证完备；SOP/守卫不变，仅增格式示例 -->
自主续推每次执行关键动作后，在 progress 或报告裁决清单按下列最小字段留证（缺字段=证据不完备，补齐后再声称完成）：

```yaml
evidence:
  action: "<本次执行动作，如 resume/phase-complete/decision>"
  target: "<plan-id 或 phase/path>"
  result: "<PASS/FAIL/BLOCKED + 一句结论>"
  evidence_path: "<绝对路径:行号 或 命令输出锚点>"
  timestamp: "<YYYY-MM-DDTHH:MM:SS±TZ>"
  verifier: "<执行者/复核者，如 main-agent/drift-checker>"
```

## 卫星路由：plan-resume — 域=计划续推(Rule 24)
规则全文见 `references/critical-rules-resume.md`（Phase complete/drift-checker 前/交付终态/会话恢复触发时机、执行中只报告/恢复点自主续推 Top 1、守卫与降级）；触发：涉及触发时机判定、续推/只报告模式选择、守卫与降级契约时 Read 该文件；关键词：critical-rules-resume Rule24 计划续推 守卫。
