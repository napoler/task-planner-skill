# Fix Round 4b Checkpoint — task-auditgate-machine-20261116

## 轮次与范围（动工前登记）

| 字段 | 值 |
|------|-----|
| 轮次 | 微修轮 4b（输入=修复轮 4 风险披露 #1：VC-6 回归判据与存量基线确定性冲突） |
| 开始时间 | 2026-11-17（本 agent 会话；UTC 2026-11-16T18:53Z 起） |
| 执行体 | plan-writer（Plan Writer） |
| 工作目录 | /mnt/data/dev/task-planner-skill |
| 允许修改 | `plans/task-auditgate-machine-20261116/{task_plan.md,verification.md,progress.md,findings.md,knowledge-brief.md,notepad-learnings.md}` + 本 checkpoint |
| 禁止 | `skills/**`（保护区）、其他计划目录、新建仓库脚本、改 `user-session-log.md` |
| 三约束 | ① R1-R3 逐字锚 task_plan.md:16-18 未动 ② user-session-log.md 全文未动 ③ 无 APPROVED 预写 |
| 唯一主题 | VC-6「全量 selftest --fresh 0 FAIL」→「同集零增量（Failed: 集合==冻结基线）」 |

## 逐项处置（全部实际 Edit 落盘）

- [x] 实测基线：`run-selftests.sh --fresh` → `Total: 99 PASS=92 FAIL=7 (run=99 reused=0)` + 7 名单（脚本 rc=1）
- [x] task_plan.md Phase 1：新增 checkbox `:230` + 「selftest 基线冻结」块 `:241-253`（Total/Failed 行原文逐字、冻结日期 2026-11-17、归属说明、判据语义、基线漂移条款）
- [x] task_plan.md 口径同步：R→VC 映射 `:24`、VC-6 `:83`、G5 `:120`、Phase 5 S1 步骤 `:294`、S1 S-unit 验收 `:305`、Notes `:408`
- [x] verification.md：VC-6 判据 `:35`、Evidence `:36`（含基线漂移凭据）、Verify command `:37`（FAIL=0 → `FAIL=7` 精确 + `Failed:` 行整行等值；单次 --fresh 落 mktemp 后双 grep）、Goal Gate `:182`
- [x] 基线漂移条款三落点：task_plan `:253`、task_plan `:408`、verification `:36`
- [x] 正反态 dry-run 8 项真实执行（见下）
- [x] 三约束自证 + 八机械门真实 rc
- [x] 附带簿记：task_plan `:205` Current Phase / `:209` Next Step 事实同步（R1-R4 已修复、R4b 完成、待 R5）
- [x] progress.md / findings.md / knowledge-brief.md / notepad-learnings.md 追加

## 实测记录（真实输出）

### 真实基线（2026-11-17）

```
Total: 99 PASS=92 FAIL=7 (run=99 reused=0)
Failed: selftest-active-plan selftest-batch-pilot selftest-enumerate-first selftest-execution-stability selftest-registry selftest-self-resolution selftest-summary-readability
real_rc=1
```
task_plan 冻结块与真实输出 **diff rc=0 逐字一致**（Total 行 / Failed 行各一次）。

### 正反态 dry-run

```
TC-A  正向：新判据 vs 真实基线                                  rc=0
TC-B1 负向：真实基线 + 假 FAIL 名 selftest-fake-new 且 FAIL=8    rc=1
TC-B2 负向：计数仍 FAIL=7 但名单被换（self-resolution→fake-swap）rc=1
TC-C  旧判据 FAIL=0 vs 当前真实基线（冲突确证）                  rc=1
TC-D  端到端 VC-6 Verify command（P→/tmp 副本 + 注入 [scope-check]） rc=0
TC-E  端到端负向（run-selftests 换 mock，输出含假 FAIL 名）       rc=1
TC-F  端到端负向（副本 progress.md 缺 [scope-check] 留痕）        rc=1
TC-G  端到端对照（恢复留痕后同命令）                             rc=0
```

### 八机械门（真实 rc）

```
check-rvc-coverage.sh      rc=0  ✓ R=3 VC=6 映射行=3
check-vc-nonvacuous.sh     rc=0  ✓ 6 条 VC 无真空命令
check-tier-consistency.sh  rc=0  ✓ standard/L1; lines=477 phases=5 vc=6 sunit=0 scope=4
check-plan-dispatch.sh     rc=0  2 非阻断 WARN（plan-tier 提示 / p1-baseline 执行体同质）+ ✓ 4 个派发型 Phase 均有带执行体 S-unit 表
check-delegation.sh stats  rc=0  rate=0.800 violations=[] verdict=ok
check-template-type.sh     rc=0  OK: template_type=rule-enhancement
check-step-placeholders.sh rc=0  ✓ 扫描 22 行（原 21 + 新增 1）
check-goal-cjk.sh          rc=0  ✓ 16 个 CJK 词
check-complete.sh <plan>/task_plan.md  rc=1（Rule 27.3 porcelain：plan-dir 整体 untracked，计划期既有状态，非本轮引入）
```

### 三约束

```
① sed -n '16,18p' task_plan.md → R1/R2/R3 三行逐字未动
② user-session-log.md mtime = 2026-11-16 23:39:23.409788871 +0800（本轮零触碰）
③ grep -n '结论: \*\*APPROVED\*\*' progress.md → 4 行均为规则说明/「仍无…预写」声明/本条自述；[plan-audit-R1..R4] 四段结论均 REJECTED
```

## 风险/遗留

- 基线硬编码 `FAIL=7` + 7 名单：若他任务收口使基线合法变化，须 `[baseline-shift]` 留痕 + 同步更新冻结块与 VC-6 字面量（条款已在三处落地，禁静默放宽）。
- `check-complete.sh` rc=1 为 plan-dir untracked 所致，属计划期状态；Phase 5 提交/合并后复跑方有意义。
