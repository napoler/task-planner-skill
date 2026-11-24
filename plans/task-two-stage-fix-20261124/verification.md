<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Verification: task-two-stage-fix-20261124

- task_id: `task-two-stage-fix-20261124`
- 时间: created_at=2026-11-23T21:21:14Z / updated_at=2026-11-24T01:16:39Z

## Goal (1 sentence)
- 把修复类请求的两阶段拆分（阶段一快修表层+根因线索包+立即合并→阶段二新 worktree 独立根治、不阻塞主线）写进 SKILL.md 调度入口、plan-writer agent、拆分模式库 P13 与 bugfix 模板 Phase 2。
- 通过 sync-todos.sh 基线组 B12 + todo-sync.md 契约（登记驱动），以及 check-evidence-anchor.sh/check-complete.sh 的 --source=rootcause-followup 消费门（校验驱动），让线索包+后续登记成为修复类任务的必选动作。
- 全程不改具体 bug 现场、不改部署位、不新增 schema 字段；改动集合严格落在逐文件改动清单内；合并预案明确。

---
## Verification Contract（VC 状态与判据）
| id | status | criterion | command | evidence | tags |
|---|---|---|---|---|---|
| VC-1 | pass | B12 进 sync-todos.sh --json 基线组且 B1-B8 逐字保留、不占用 B9-B11；合并并线后若脚本已含 B9-B11 则其全部仍在（W3）；B12 subject 按 D1'=根因/风险线索包已落盘+后续任务已登记（Q1）。 | cd /mnt/data/dev/task-planner-skill && OUT=$(bash skills/task-planner/scripts/sync-todos.sh --json plans) && for b in B1 B2 B3 B4 B5 B6 B7 B8 B12; do echo "$OUT" \| grep -Fq "\"task_id\":\"$b\"" \|\| { echo MISSING-$b; exit 1; }; done && echo "$OUT" \| grep -Fq '线索包' && for b in B9 B10 B11; do if grep -Fq "\"task_id\":\"$b\"" skills/task-planner/scripts/sync-todos.sh; then echo "$OUT" \| grep -Fq "\"task_id\":\"$b\"" \|\| { echo LOST-$b; exit 1; }; fi; done && echo PASS | skills/task-planner/scripts/sync-todos.sh:207-214 |  |
| VC-2 | pass | todo-sync.md S1 两组结构契约含 B12 与根因/风险线索包，固定清单唯一事实源措辞保留；明文 B12 在 mini/L0 口径=N/A 也要有证据，修复类 L0/mini/trivial 升 L1 复核（I6）。 | grep -Fq 'B12' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md && grep -Fq '线索包' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md && grep -Fq '固定清单唯一事实源' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md && grep -Fq 'N/A' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md && grep -Eq '升 L1\|升L1\|L1 复核' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md && echo PASS | skills/task-planner/references/todo-sync.md:34-40 |  |
| VC-3 | pass | 调度入口 SKILL.md 与 plan-writer.md 均含修复类两段式拆分判定锚。 | grep -Fq '两段式' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && grep -Fq '修复类' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && grep -Fq '两段式' /mnt/data/dev/task-planner-skill/skills/task-planner/companion/agents/plan-writer.md && echo PASS | SKILL.md:98-107; companion/agents/plan-writer.md:37-47 |  |
| VC-4 | pass | split-pattern-library.md 新增 P13 两段式修复模式；bugfix-type.md Phase 2 根因定位含线索包/后续登记交付物。 | grep -Fq 'P13' /mnt/data/dev/task-planner-skill/skills/task-dispatch/references/split-pattern-library.md && grep -Fq '阶段一' /mnt/data/dev/task-planner-skill/skills/task-dispatch/references/split-pattern-library.md && grep -Fq '根因线索包' /mnt/data/dev/task-planner-skill/skills/task-planner/templates/variant/bugfix-type.md && grep -Fq '后续任务已登记' /mnt/data/dev/task-planner-skill/skills/task-planner/templates/variant/bugfix-type.md && echo PASS | split-pattern-library.md:110-120; bugfix-type.md:85-91 |  |
| VC-5 | pass | --source=rootcause-followup 消费门 POS/NEG 双向实跑：①带标记+finding+真 planctl tag-add 倒排登记(tags-index 在 <plan-dir>/../)的 POS fixture rc=0；②无标记 NEG fixture rc=1（防 arg-case-only 零逻辑 NO-OP 门）；③真实 mode 分支(rootcause mode/dispatch)在位；④调用点在 run_evidence_anchor() 函数体之外且受 guard(VC_GATE_TIER/mini)保护，门序/哈希锚不变。标记契约=findings 内 [rootcause-followup:PASS] 或 [rootcause-followup:N/A]+理由 + tag-add 登记；fixture 用真 planctl 生成，禁空 {} 假索引。 | cd /mnt/data/dev/task-planner-skill; S=skills/task-planner/scripts; CTL=$S/planctl.py; grep -Fq -- '--source=rootcause-followup' $S/check-evidence-anchor.sh \|\| { echo NO-SOURCE-PARSE; exit 1; }; grep -Fq 'rootcause' $S/check-evidence-anchor.sh && grep -Ec 'run_source[[:space:]]+rootcause\|mode == "rootcause"' $S/check-evidence-anchor.sh \| grep -qv '^0$' \|\| { echo NO-REAL-MODE; exit 1; }; bash -n $S/check-evidence-anchor.sh \|\| exit 1; bash -n $S/check-complete.sh \|\| exit 1; FSTART=$(grep -n '^    run_evidence_anchor() {' $S/check-complete.sh \| cut -d: -f1); FEND=$(awk -v s=$FSTART 'NR>=s && /^    \}/{print NR; exit}' $S/check-complete.sh); CN=$(grep -n 'run_evidence_anchor rootcause-followup' $S/check-complete.sh \| cut -d: -f1); [ -n "$CN" ] && [ "$CN" -gt "$FEND" ] \|\| { echo CALL-INSIDE-FUNCTION-BODY; exit 1; }; grep -B3 'run_evidence_anchor rootcause-followup' $S/check-complete.sh \| grep -Eq 'VC_GATE_TIER\|plan_tier\|mini' \|\| { echo NO-GUARD; exit 1; }; echo "position: func=$FSTART-$FEND call=$CN (outside body + guarded)"; R=$(mktemp -d); mkdir -p $R/a/pos $R/b/neg; python3 -I $CTL init --plan-dir $R/a/pos --task-id FIX-POS --tier standard --lane L2 >/dev/null \|\| exit 1; python3 -I $CTL add --plan-dir $R/a/pos --section findings --json '{"id":"F1","text":"marker","source":"t"}' >/dev/null \|\| exit 1; python3 -I $CTL tag-add --plan-dir $R/a/pos --section findings --id F1 --tag 'rootcause-followup:fix-pos-rc' >/dev/null \|\| exit 1; printf '## Findings\n- [rootcause-followup:PASS] 线索包已落盘\n' > $R/a/pos/findings.md; python3 -I $CTL init --plan-dir $R/b/neg --task-id FIX-NEG --tier standard --lane L2 >/dev/null \|\| exit 1; printf '## Findings\n- 无标记\n' > $R/b/neg/findings.md; test -f $R/a/.tags-index.json && echo 'POS index present'; test ! -f $R/b/.tags-index.json && echo 'NEG index isolated'; bash $S/check-evidence-anchor.sh $R/a/pos --source=rootcause-followup >/dev/null 2>&1; PRC=$?; bash $S/check-evidence-anchor.sh $R/b/neg --source=rootcause-followup >/dev/null 2>&1; NRC=$?; rm -rf $R; echo "POS=$PRC NEG=$NRC"; [ "$PRC" -eq 0 ] && [ "$NRC" -eq 1 ] \|\| { echo BI-DIRECTIONAL-FAIL; exit 1; }; echo PASS | check-evidence-anchor.sh:112-125/509-531; check-complete.sh:761-795/1063-1065/1839-1841; planctl.py:757-758/1055 |  |
| VC-6 | pass | Rule 31.8② 交叉引用消歧句在位（实例层不擅自升规则，阶段二为用户授权独立任务）。 | grep -Fq '两段式' /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md && grep -Fq '31.8' /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md && echo PASS | critical-rules-discipline.md:91 |  |
| VC-7 | pass | 语法检查与 plan-state.json schema 校验通过。 | cd /mnt/data/dev/task-planner-skill && for f in skills/task-planner/scripts/sync-todos.sh skills/task-planner/scripts/check-evidence-anchor.sh skills/task-planner/scripts/check-complete.sh; do bash -n "$f" \|\| exit 1; done && python3 -I skills/task-planner/scripts/planctl.py validate --plan-dir plans/task-two-stage-fix-20261124 && echo PASS | planctl validate stdout; bash -n rc=0 |  |
| VC-8 | pass | 全量 selftest 回归 0 FAIL（逐脚本 Total 行求和，禁采信子代理自报）。 | cd /mnt/data/dev/task-planner-skill && OUT=$(bash skills/task-planner/scripts/run-selftests.sh --fresh 2>&1); printf '%s\n' "$OUT" \| tail -8; printf '%s\n' "$OUT" \| grep -Fq 'FAIL=0' && ! printf '%s\n' "$OUT" \| grep -Eq 'FAIL=[1-9]' && echo PASS | progress.md Selftest Log; run-selftests.sh stdout |  |
| VC-9 | pass | 改动集合 ⊆ 逐文件改动清单 CHG-1..CHG-11（git diff --name-only 与允许集求差集，非空 fail）；不改 schema 文件。部署位(~/.zcode\|~/.claude\|~/.config/opencode\|~/.cursor\|~/.agents)/skills 属仓外——不可机器验证，靠人工核对 5 路径 mtime，不以恒真命令冒充证据（I2）。 | cd /mnt/data/dev/task-planner-skill; ALLOW='skills/task-planner/scripts/sync-todos.sh skills/task-planner/references/todo-sync.md skills/task-planner/SKILL.md skills/task-planner/companion/agents/plan-writer.md skills/task-dispatch/references/split-pattern-library.md skills/task-planner/templates/variant/bugfix-type.md skills/task-planner/scripts/check-evidence-anchor.sh skills/task-planner/scripts/check-complete.sh skills/task-discipline/references/critical-rules-discipline.md skills/task-planner/scripts/selftest-evidence-anchor.sh'; CHANGED=$( { git diff --name-only master; git diff --name-only; git ls-files --others --exclude-standard; } 2>/dev/null \| grep -E '^skills/' \| sort -u); EXTRA=$(for f in $CHANGED; do printf '%s\n' "$ALLOW" \| grep -Fqx "$f" \|\| printf '%s\n' "$f"; done); if [ -n "$EXTRA" ]; then echo "OUT-OF-SCOPE: $EXTRA"; exit 1; fi; echo 'diff-set OK; 部署位不可机器验证-人工核对5路径mtime'; echo PASS | git diff --name-only; CHG-1..CHG-11; 部署位人工核对清单(5路径 mtime) |  |
| VC-10 | pass | 机制文本同时含四锚：①立即合并回 master（阶段一完成后合并不阻塞下游）；②新 worktree 命令 --base master / git worktree add <root>/tmp/worktrees/<A-id>-rc -b wt/<A-id>-rc master；③不阻塞/pending（阶段二失败只留 pending，不改阶段一 outcome）；④两独立 task-id 双向 tag（followup-of: / rootcause-followup:）。覆盖 R6/R7 的「立即合并/新分支新工作树并行/拆两个独立任务」语义（Q1 全覆盖）。 | cd /mnt/data/dev/task-planner-skill && T=$(cat skills/task-planner/SKILL.md skills/task-dispatch/references/split-pattern-library.md skills/task-planner/companion/agents/plan-writer.md skills/task-planner/templates/variant/bugfix-type.md) && printf '%s' "$T" \| grep -Fq '合并回 master' && printf '%s' "$T" \| grep -Fq -- '--base master' && printf '%s' "$T" \| grep -Eq '不阻塞\|pending' && printf '%s' "$T" \| grep -Fq 'followup-of:' && printf '%s' "$T" \| grep -Fq 'rootcause-followup:' && echo PASS | SKILL.md(两段式判定段); split-pattern-library.md(P13); plan-writer.md; bugfix-type.md; D5 |  |
| VC-11 | pass | selftest-evidence-anchor.sh 含 rootcause POS(带标记+真 tag-add rc=0)/NEG(无标记 rc=1) 常驻用例 + B12 断言，且全量 selftest 0 FAIL。 | cd /mnt/data/dev/task-planner-skill && F=skills/task-planner/scripts/selftest-evidence-anchor.sh && grep -Fq 'EA-21' $F && grep -Fq 'EA-22' $F && grep -Fq 'EA-23' $F && grep -Fq 'rootcause-followup' $F && grep -Fq 'B12' $F && OUT=$(bash $F 2>&1); printf '%s\n' "$OUT" \| grep -Fq 'FAIL=0' && ! printf '%s\n' "$OUT" \| grep -Eq 'FAIL=[1-9]' && echo PASS | selftest-evidence-anchor.sh:2-39 + EA-21/EA-22/EA-23; progress.md Selftest Log |  |

## Phase Gates
| Goal | Depends on | Done when | Checks | Status |
|---|---|---|---|---|
| （本任务暂无Phase Gates 记录） |  |  |  |  |

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|---|---|---|
| （本任务暂无知识符合性记录） |  |  |

## 委派统计复验（Rule 25.4）
- （本任务暂无委派复验记录）

## 质量门控统计（Rule 26）
- （本任务暂无质量门控记录）

## Goal Gate (终验，所有 phase complete 后执行)
- （本任务暂无Goal Gate 记录）

---
## 交叉验证记录（Rule 108）
| 验证对象 | 机械面路径（命令+结果） | 语义面路径（复检体+结论） | 判定（一致/分歧→108.4 处置） |
|---|---|---|---|
| （本任务暂无交叉验证记录） |  |  |  |

## 5-Question Reboot Check
| # | Question | Answer (fill on resume) |
|---|---|---|
| （本任务暂无5Q 记录） |  |  |
