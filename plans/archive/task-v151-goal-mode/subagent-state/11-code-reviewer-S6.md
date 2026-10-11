# S6 Code Review 检查点 — task-v151 全量 CR（commit 101475f）

<!--
  WHAT: task-v151 Rule 66 goal 单元固化全链的全量 CR 过程与结论（只读审查）。
  WHY: 任务书 12-brief-S6.md §8 要求的断点落盘；审查对象=worktree 101475f 16 文件 +354/-35。
  SCOPE: 只读；禁改审查对象、禁 git 写操作。本文件=审查产出（非审查对象）。
-->

## 审查对象与基准
- 审查对象: worktree /mnt/data/dev/task-planner-skill-worktrees/v151-goal-mode，commit 101475f（16 文件 +354/-35）
- 设计基准: plans/task-v151-goal-mode/design-draft.md（§2 六子条/§4 守卫伪码/§5 钉值清单）
- 需求锚: R2「任务分解固化为 goal 单元（任务名+目标+完整验证），用 /goal 驱动推进保可靠性」

## V1 正确性 — PASS
证据命令与关键输出：
1. `bash scripts/check-plan-dispatch.sh <合成夹具>` 四态行为级验证（/tmp 夹具，不碰仓库）：
   - 显式 standard 缺「🎯 Goal 单元表」区块 → `✗ Phase N/A: Rule 66.5: 缺「🎯 Goal 单元表」区块（standard/full 档必填）` rc=1（硬拒锁）✔
   - 显式 mini → `WARN Rule 66.5: mini 档豁免，Goal 单元表区块缺失（不拒锁）` rc=0 ✔
   - 无 plan_tier 标记 → `[goal-check] 无 plan_tier 标记，66.5 goal 门缺省跳过（legacy/无档位兼容口径）` rc=0 ✔
   - standard 占位符+序号跳号 → rc=1，两条违规：`goal G1 完整验证方式列为占位符（< 起头）` + `goal-id 序号不连续（期望 G2，实际 G3）` ✔
   - standard 合规样本 → rc=0 ✔
   → 四态（standard/full 硬门 / mini 豁免 / 无标记缺省跳过 + 数据行校验）全覆盖，无漏档。
2. awk 状态机 `/{f=1;next} /^##[[:space:]]/{f=0} f`：`next` 置于块首行，无区间 next 坍缩；与 check-plan-dispatch.sh:92-94 既有范式一致 ✔
3. check-complete [goal-gate] 三语义（隔离微测，复制段逻辑到 /tmp/s6-micro.sh 实跑）：
   - complete 无证据 → `[goal-gate] ✗ G1 complete 无 [goal:G1] 证据行` exit 1 ✔
   - 有证据 + 另存 pending → `[goal-gate] ⚠ 有 goal 未 complete (G2)` exit 0（降级提示不阻断）✔
   - 缺区块 → `[goal-gate] SKIPPED` 不 exit ✔
   → 与 66.3「status=complete 无 [goal:Gn]=exit 1（与 64.2 同档）；有 goal 未 complete=终态最高 PARTIAL」条款一致。
   - PLAN_DIR_GUESS 在 check-complete.sh:111 于 python_rc=0 块内赋值，goal-gate 段（1221-1256）同块同缩进，变量可用；exit 1 在 python_rc=0 前置下可达 ✔

## V2 一致性 — FAIL（2 条）
- 通过面（口径全对）：
  - 六列契约 critical-rules 66.1 ↔ 模板表头 ↔ check-plan-dispatch 表头六关键词 ↔ check-complete `$7=状态`：无矛盾 ✔
  - 黑名单词「检查没问题」：66.1 与 check-plan-dispatch.sh:397 一致 ✔
  - `[goal:Gn]` 行格式：66.3 ↔ check-complete grep `\[goal:${gid}\]` ↔ 正样本 progress.md L46-49 实际 `[goal:G1]..[goal:G4]` ✔
  - SKILL.md 摘要行 + C45 合规行 + 三处 1-65→1-66 计数级联（`grep -c '1-65'`=0，`1-66`=3）✔
- 矛盾面（见 F1/F2）：
  - F1：--skip-goal-check 逃生口声明「对齐 --skip-dispatch-check 惯例」，但未接线到 attest-plan.sh 真入口。
  - F2：check-complete goal-gate 档位判定（`PLAN_TIER_MINI != 1`）与 check-plan-dispatch（仅显式 standard/full）口径分叉。

## V3 零回归/纯增量 — PASS
- `git show 101475f --numstat`：critical-rules.md = 14 增 / 0 删 → 既有 1-65 正文零改写，纯追加 ✔
- 9 个钉值级联脚本实跑全 PASS：skill-split 41/0、evidence-goal-gate 21/0、lane-advancement 14/0、self-resolution 13/0、tool-selection 12/0、requirement-coverage 23/0、research-first 12/0、iteration-persistence 18/0、four-file-dataflow 18/0 ✔
- 受 CPD 影响脚本：selftest-plan-dispatch 12/0、selftest-final-gate-hash 22/0、selftest-registry 5/0 ✔
- 正样本计划 check-plan-dispatch rc 在 worktree 与 master 一致（皆 rc=1，触发源=Phase 4 缺 S-unit，非本任务引入）✔

## V4 可维护性 — PASS（含 1 条 Nit → F3）
- 注释 What+Why 完整（Rule 45）：check-plan-dispatch.sh:313-321、check-complete.sh:1210-1219、新 selftest 头部 What/Why 段齐备 ✔
- 新 selftest 骨架与 selftest-evidence-goal-gate.sh 范式一致（ok/bad + 编号 + Total 行 + exit 码）✔
- registry 行列齐：65 行 = 表头 + 64 脚本，全 4 列（`awk -F'\t' '{print NF}'` 全 =4）；selftest-registry.sh T01-T05 全 PASS ✔

## V5 运行面 — PASS
原文输出：
```
$ bash scripts/selftest-goal-unit-goal-mode.sh ; echo exit=$?
G-01 PASS critical-rules.md '### 66 ' 标题锚 =1
G-02 PASS critical-rules.md '66.x ' 六子条锚 =6
G-03 PASS templates/task_plan.md Goal 单元表区块=1 + 六列表头=1 + 插入位语义（L87<L104<L116）
G-04 PASS SKILL.md 'Rule 66' 计数=2（≥2）+ C45 合规行=1（=1）
G-05 PASS check-plan-dispatch.sh 'Goal 单元表' 锚=10（≥1）+ '--skip-goal-check' 锚=5（≥1）
G-06 PASS check-complete.sh 'goal-gate' 锚=7（≥1）+ '[goal:G' grep 锚=3（≥1）
G-07 PASS selftest-registry.tsv 末行含 selftest-goal-unit-goal-mode.sh
G-08 PASS config.json properties 键名 goal[_-](unit|gate|advance) =0（零新键）
G-09 PASS SKILL.md 行数=511 ≤515（D1 上调后上限）
Total: 9 PASS=9 FAIL=0
exit=0
```
```
$ bash -n check-plan-dispatch.sh   → CPD syntax OK
$ bash -n check-complete.sh        → CC syntax OK
$ bash -n selftest-goal-unit-goal-mode.sh → GUS syntax OK
```
```
$ bash scripts/check-plan-dispatch.sh <正样本 task_plan.md> 2>&1 | grep -c '66.5'
0      ← 正样本 66.5 违规=0（grep 命中的 2 行系 Phase-4 非-S-unit 违规，与本任务无关）
```
- 只读约束遵守：审查全程 `git status --short` 空，未写 worktree；合成夹具全部落 /tmp。

## 审查明细（F 清单）
### F1 🟡 [一致性/可用性] skills/task-planner/scripts/check-plan-dispatch.sh:319（+ attest-plan.sh:69）
- 标题：--skip-goal-check 逃生口未接线到 attest 真入口，声称「对齐 --skip-dispatch-check 惯例」不成立
- 原文: "缺失=拒锁（59.1 硬门同档）；--skip-goal-check 逃生口对齐 --skip-dispatch-check 惯例"
- 原因: attest-plan.sh:69-74 调 check-plan-dispatch 时仅传 `bash "$cpl" "$plan_file"`，不转发任何 flag；attest-plan.sh 自身参数解析（:24-33）无 `--skip-goal-check` 分支，该参数落入 `*) plan_file="$arg"` 被静默吞掉。故经真入口 `attest-plan.sh` 无法触发逃生口（已验证：直调 `check-plan-dispatch.sh <plan> --skip-goal-check` rc=0 有效，但 attest 入口不可达）。--skip-dispatch-check 之所以生效是因 attest-plan 有专门分支「整段跳过调用」——声称的「对齐」未落实。
- 修复: attest-plan.sh 参数解析加 `--skip-goal-check) skip_goal=1 ;;`，并在调用处透传（`bash "$cpl" "$plan_file" $([ -n "$skip_goal" ] && echo --skip-goal-check)`）；或按 --skip-dispatch-check 范式「跳过整段调用」并在 LEDGER/Decisions 登记。
- 置信度: HIGH

### F2 🟡 [一致性] skills/task-planner/scripts/check-complete.sh:1221
- 标题：goal-gate 档位判定与 check-plan-dispatch 的 D2 缺省档口径分叉
- 原文: `if [ "${PLAN_TIER_MINI:-0}" != 1 ]; then`
- 原因: check-plan-dispatch 采用 D2 裁决「仅显式 plan_tier: standard|full 才硬门；无标记=缺省档跳过」。check-complete 此处用 `PLAN_TIER_MINI != 1`，即「无 plan_tier 标记」也会进入 goal-gate 段。于是无标记计划：attest 门跳过（放行），终验门却可能对「complete 无 [goal:Gn] 证据」exit 1 → 两门对同一计划口径不一致，可能出现「attest 通过但终验拒」。
- 修复: 与 check-plan-dispatch 对齐——`grep -qm1 -E 'plan_tier:[[:space:]]*(standard|full)' "$PLAN_FILE"` 才进入检查，无标记跳过；或在 66.3/66.5 条文显式定义终验门档位口径使二者一致。
- 置信度: MED（条款未明确 check-complete 档位判定，属设计空白；但行为分叉客观存在）

### F3 💬 [可维护性] skills/task-planner/scripts/selftest-iteration-persistence.sh:173
- 标题：死变量 last57line（赋值后无引用）
- 原文: `last57line="$(grep -nE '^### 57 ' "$CRIT" | head -1 | cut -d: -f1 || true)"`
- 原因: 该行替换了原 `57.x 末条行` 锚后，后续判断已改用 `block57`（awk 区块），last57line 再无任何引用（`grep -n last57line` 仅命中本行），为遗留死代码，易误导维护者认为仍以行号锚定。
- 修复: 删除该行；若有意保留行号锚用途则补注释。
- 置信度: HIGH

## 最终结论
```
status: done
acceptance: 4/5 pass — [V1:PASS V2:FAIL V3:PASS V4:PASS V5:PASS]
files: none（只读）
evidence: bash scripts/selftest-goal-unit-goal-mode.sh→G-01..G-09 全 PASS exit=0; 四态夹具 standard rc=1/mini rc=0/无标记 rc=0; 微测[goal-gate] complete-无证据→exit1, pending→提示; bash -n 三脚本 OK; 正样本 66.5 违规=0; 9 级联脚本 ΣFAIL=0 → 结论=CHANGES_REQUESTED(F1 check-plan-dispatch.sh:319 逃生口未接线attest; F2 check-complete.sh:1221 档位口径分叉)
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/subagent-state/11-code-reviewer-S6.md
findings_written: none
blockers: none
confidence: MED
```
