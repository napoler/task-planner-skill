# S11 检查点 — task-v149 Phase 3 机制批修正（D13/D24/D35）

- 执行体：executor（sonnet-1）
- 时间：2026-10-08
- 工作区：/mnt/data/dev/task-planner-skill-worktrees/task-v149-skill-alignment-audit
- 状态：DONE

## 任务一（D24）：DCS-20 扫描根收窄

### 修改文件
- `skills/task-planner/scripts/selftest-drift-check-subagent.sh`（第 86-91 行）

### 修改内容
- 扫描根从 `SKILLS_ROOT`（全 skills 树）收窄到 `SKILL_ROOT`（本技能目录自身）
- 注释注明：2026-10-08 task-v149 D24：扫描根过宽致环境敏感伪失败
- 排除自身：`grep -v 'selftest-drift-check-subagent.sh'`（断言文本含该字符串）

### 设计意图保持
- 原意图：防本技能部署位残留旧载体文案 `Skill("task-drift-guard")`
- 收窄后：仍防本技能目录内残留，不再误伤其他技能合法引用

### 自验结果
- 修改前（worktree 内）：`Total: 20 PASS=20 FAIL=0`（worktree skills/ 树仅 task-planner 族）
- 修改前（部署位）：`Total: 20 PASS=19 FAIL=1`（DCS-20 FAIL 伪失败）
- 修改后（worktree 内）：`Total: 20 PASS=20 FAIL=0`（DCS-20 PASS）
- 修改后（部署位）：仍 FAIL（部署位是旧副本，Phase 5 同步后生效）

### 证据
- 修改位置：selftest-drift-check-subagent.sh:86-91
- 基线对比：worktree 内 PASS=20 FAIL=0（前后一致）

## 任务二（D13）：check-doc-sync.sh 键考证

### 考证结论
- `sync_interval_calls` 在 commit 2337ce0 中被重命名为 `todo_sync_interval_calls`（语义相同）
- 但 check-doc-sync.sh 实际代码引用的是 `plan_update_interval_minutes`（时间间隔阈值），与 `todo_sync_interval_calls`（调用次数阈值）语义不同
- 注释（第 12 行）错误引用了不存在的 `sync_interval_calls`

### 修改文件
- `skills/task-planner/scripts/check-doc-sync.sh`（第 12 行）

### 修改内容
- 注释从 `config.json#sync_interval_calls` 改为 `config.json#plan_update_interval_minutes`
- 注释注明考证结论

### 自验结果
- `bash -n` 语法检查通过

### 证据
- 修改位置：check-doc-sync.sh:12-15
- git log -S 考证：commit 2337ce0

## 任务三（D35）：v129 deferred 五项核对

### 核对表

| # | 遗留项 | 现状 | 证据 |
|---|--------|------|------|
| 1 | check-complete 机器深化 | **已被后续任务消化** | selftest-requirement-coverage.sh 已存在（RC-01~RC-23）；check-complete.sh:819/824/1044/1059/1063/1099/1116 有 rcov-gate SKIPPED 分支 |
| 2 | PT-08 口径债 | **仍存在** | selftest-plan-tier.sh:79 锚为 `1-4[5-9]\|1-5[0-9]`，未覆盖 1-65（SKILL.md 现值 1-65） |
| 3 | 并行声明格式 | **已被后续任务消化** | check-dispatch.sh:280-281/294-295/602/624 已实现 parallel_groups 解析+放行（task-v110） |
| 4 | RC 注释漂移 | **已被后续任务消化** | selftest-requirement-coverage.sh 各断言注释随版本演进更新（如 RC-13 含 task-v144 级联注释） |
| 5 | SKIPPED 求和口径 | **仍存在** | check-complete.sh 多处 SKIPPED 分支（469/792/819/824/1044/1059/1063/1099/1116），但 Total 求和口径未见统一 |

### 仍存在项详情
- **PT-08 口径债**：selftest-plan-tier.sh:79 断言 `Critical Rules 全集 1-4[5-9]|1-5[0-9]`，但 SKILL.md frontmatter 现为 `1-65`，锚未覆盖 1-61/1-62/1-63/1-64/1-65
- **SKIPPED 求和口径**：check-complete.sh 的 SKIPPED 行（如 rcov-gate/reflect-gate/skill-modify-gate）未纳入 Total 求和，可能导致终验统计口径不完整

## 异常
- 无

## 未验证项
- 部署位 DCS-20 修改后效果（需 Phase 5 同步后验证）
