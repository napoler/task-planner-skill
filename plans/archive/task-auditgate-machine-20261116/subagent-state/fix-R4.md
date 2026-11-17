# Fix Round 4 Checkpoint — task-auditgate-machine-20261116

## 轮次与范围（动工前登记）

| 字段 | 值 |
|------|-----|
| 轮次 | 修复轮 4（输入=critic R4 REJECTED，6 发现：C-1/I-1/W-1/W-2/N-1/N-2） |
| 开始时间 | 2026-11-17（本 agent 会话） |
| 执行体 | plan-writer（Plan Writer） |
| 工作目录 | /mnt/data/dev/task-planner-skill |
| 允许修改 | `plans/task-auditgate-machine-20261116/{task_plan.md,verification.md,progress.md,findings.md,knowledge-brief.md,notepad-learnings.md}` + 本 checkpoint |
| 禁止 | `skills/**`（保护区）、其他计划目录、新建仓库脚本、改 `user-session-log.md` |
| 三约束 | ① R1-R3 逐字锚 task_plan.md:16-18 未动 ② user-session-log.md 全文未动 ③ 无 APPROVED 预写 |

## 逐项处置（已完成）

- [x] C-1 verification.md:37 尾部 config 断言重写为 `test -f <config.json> && ! grep -q "\"audit" <config.json>`
- [x] I-1 VC-6 两段式：删 live worktree 断言 → 段锚 awk + `SCOPE-OK` 留痕断言；live 复跑部分保留；范围断言下沉 task_plan Phase 5「S2 内嵌命令」；:269 残留矛盾清理；Evidence/Notes 同步
- [x] W-1 白名单六个文件级分支补 `$` 尾锚（目录分支保持尾 `/`）
- [x] W-2 `[scope-check] <ISO8601> SCOPE-OK diff=N untracked=N` 落 :281 与 :291
- [x] N-1 `|| true` → `rc=0; out=$(...) || rc=$?` + 仅 0/1 合法；S2 验收/VC-6 Evidence 增白名单与 `scope_files` 一致性核对
- [x] N-2 verification.md:15 VC-1 补 r2（mini×L1 冲突负向）

## 实测记录（真实输出）

### C-1 双态（/tmp fixture + 真实 config）

```
现状复现（原断言）：bash: line 1: test: 0\n0: integer expression expected   rc=2
新断言·真实 config.json（无键）：rc=0
新断言·含 "audit 键 fixture：rc=1
新断言·缺文件 fixture（fail-closed）：rc=1
grep -c '"audit' config.json → 打印 0 且 rc=1（双零陷阱根因）
```

### W-1 合成仓（git init + worktree，master/wt 两目录）

```
控制组（白名单内 SKILL.md 修改 + check-plan-audit-gate.sh + plans/... 新增）：rc=0，留痕 [scope-check] 2026-11-16T18:24:39Z SCOPE-OK diff=1 untracked=2
变异组 SKILL.md.bak：rc=1  → [audit-gate] FAIL: 越界文件: skills/task-planner/SKILL.md.bak
变异组 attest-plan.sh.bak：rc=1 → [audit-gate] FAIL: 越界文件: skills/task-planner/scripts/attest-plan.sh.bak
变异组 other-script.sh：rc=1 → [audit-gate] FAIL: 越界文件: skills/task-planner/scripts/other-script.sh
旧正则（无 $ 锚）对照：out=[skills/task-planner/scripts/other-script.sh]（SKILL.md.bak 被放行 → W-1 缺陷确证）
新正则对照：out=[SKILL.md.bak, other-script.sh]（两者均被拦截）
```

### N-1 rc 捕获

```
非法正则 → grep_rc=2 → [audit-gate] FAIL: grep 异常 rc=2 → exit 1
|| true 形态 → masked_out=[] → test -z 放行 rc=0（掩蔽实证）
rc=1（零命中）→ 合法续行 rc=0
```

### I-1 段锚 awk 正反态

```
Phase 5 段内含 token → grep_rc=0
token 仅在 Phase 5 之后的 `##` 段 → grep_rc=1（不误判）
token 仅在后续 `### Phase 6` 段 → grep_rc=1（不误判）
真实 progress.md（尚未留痕）→ 整链 rc=1（Phase 5 执行后应转 0）
```

### 八机械门（真实 rc，均 0）

```
check-plan-dispatch.sh rc=0（2 非阻断 WARN + ✓ 4 个派发型 Phase 均有带执行体 S-unit 表）
check-delegation.sh stats rc=0 {"phases_total":5,"phases_delegated":4,"main_direct_count":1,"delegation_rate":0.800,"violations":[],"verdict":"ok"}
check-rvc-coverage.sh rc=0 ✓ R=3 VC=6 映射行=3
check-vc-nonvacuous.sh rc=0 ✓ 6 条 VC 无真空命令
check-template-type.sh rc=0 rule-enhancement
check-tier-consistency.sh rc=0 standard/L1 lines=461 phases=5 vc=6 sunit=0 scope=4
check-step-placeholders.sh rc=0 扫描 checkbox 步骤 21 行
check-goal-cjk.sh rc=0 抽出 16 个 CJK 词
```

### 三约束

```
① sed -n '16,18p' task_plan.md → R1/R2/R3 三行逐字未动
② ls -l --time-style=full-iso → user-session-log.md 2026-11-16 23:39:23（本轮未触碰）
③ grep -n '结论: \*\*APPROVED\*\*' progress.md → 仅 :75 规则说明 / :129 「仍无预写」声明
```

## 存量风险（非本轮引入，已登记）

`run-selftests.sh --fresh` 实测 `Total: 99 PASS=92 FAIL=7`（active-plan / batch-pilot / enumerate-first / execution-stability / registry / self-resolution / summary-readability）。VC-6 要求 FAIL=0，Phase 5 前须由主进程授权处置（属 skills/** 保护区）。
