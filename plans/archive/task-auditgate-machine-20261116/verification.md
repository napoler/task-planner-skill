# Verification Contract & Phase Gates — task-auditgate-machine-20261116

## Goal (1 sentence)

在 task-planner 落地计划审计门机器强门（attest `[audit-gate]` 锁定前对 L1+ 校验 APPROVED、轻量档 `[plan-audit-skip]` 放行、独立 checker + selftest 正负例），并以 Phase 5 merge-back 后由主进程用主仓新 attest 对本 plan-dir 实跑 rc=0 并断言 `[audit-gate]` 输出（自举实测）验证机器门行为有效。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.
> 每条 VC 的 **Verify command** 行=attest vc-gate 判据面；命令纯命令无反引号、非真空、引用本 VC 产出物。

- [ ] VC-1: checker `check-plan-audit-gate.sh` 判别正确——lane 优先（L1/L2 必审，mini×L1 按最严）、显式 standard/full 必审、无声明输出 `[audit-gate] SKIP legacy-no-decl`（该分支有 fixture 承重：无 `plan_tier`/`execution_lane` 声明 → rc0 且输出含该 token，见 VC-3）、轻量档 skip 放行而 L1+ skip 拒锁、末段 APPROVED 须含 `审计体:`+`轮次:`+`问题清单` 最小形态（**`问题清单` 容忍全角/半角括注后接冒号**——判据正则 `^- 问题清单([（(][^）)]*[）)])?:`（ERE）；`审计体:`/`轮次:` 维持字面（真实段无括注，r7 fixture 覆盖；**判定粒度=段内子串出现即可，不要求独立行/行首**——r3 内联形态与 r7 独立行两正例并存即隐含此口径，R8 Q-1 钉死）；R7 I-1：唯一 APPROVED 段真实字节形态为 `- 问题清单（留档，不阻断）:`，按字面连写冒号判据会使 checker 对本 plan-dir 恒 rc1）（**聚合边界止于下一个 H2 `## ` 行**——含修复轮块/留痕占位等任何 H2，防吞后随块的反引号元引用；**该边界仅认 `^## `（H2）**，故审计段后随块**必须用 H2 标题**——写作规范依赖：后随块若用 H3/粗体标题，边界不生效、约束静默退化，checker 注释须登记该前提；**结论行用 ERE 行首结构锚定** `^- 轮次: R[0-9]+ \| 审计体: .+ \| 结论: \*\*APPROVED\*\*`，禁匹配反引号内/行中元引用）；**两约束各自独立承重**：① 聚合边界（止 H2）由 fixture b 独立承重（仅边界实现 → r6 抓住）② 结论行锚定由 fixture a 独立承重（仅锚定实现 → r5 抓住）；两约束全缺由 r4 抓住；rc 0/1 本命令实测（r1=rc1 无留痕负向（progress.md **存在但空**）/ r2=rc1 mini×L1 冲突负向 / r3=rc0 规范示意形态正向（`- 问题清单: 无`）/ **r4=rc1 中间态假阳性负向**——REJECTED 审计段 + 后随含反引号 APPROVED 元引用的修复轮块；主进程 2026-11-17 /tmp 实测该形态下未加固判据 rc=0 假 PASS / **r5=rc1 fixture a 负向**——REJECTED 段内裸文 `结论: **APPROVED**` 意见文本，仅锚定实现（无边界）会假 PASS / **r6=rc1 fixture b 负向**——后随 H2 块内含正规锚定 APPROVED 行，仅边界实现（无锚定）会假 PASS / **r7=rc0 真实生产形态正向**——R6 段字节形态（结论行括注 + `- 问题清单（留档，不阻断）:` + `- 审计体: critic`））；**rc2 语义（R7 Q-2）**：`progress.md` **文件缺失/不可读 = rc2**（fail-open + 显式 `[audit-gate] WARN 判定器输入异常`）、**存在但空 = 无留痕 rc1**，rc2 行为用例见 VC-3
  Evidence: `skills/task-planner/scripts/check-plan-audit-gate.sh`；fixture 正负例 stdout/stderr 与 rc 记录（progress.md / 终验日志）；**fixture 七例**：规范示意形态（r3）与真实生产形态（r7）两正例、中间态（r4）、两单约束假 PASS 路径（r5=仅锚定/fixture a、r6=仅边界/fixture b）、mini×L1 冲突（r2）、无留痕（r1）；rc2（文件缺失）/legacy SKIP 行为由 VC-3 selftest 承重
  **Verify command**: bash -c 'set -u; P=/mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116; C=/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-plan-audit-gate.sh; T=$(mktemp -d); cp -r "$P"/. "$T"/; cp /dev/null "$T"/progress.md; bash "$C" "$T" >/dev/null 2>&1; r1=$?; sed -i "s/^plan_tier: standard$/plan_tier: mini/" "$T"/task_plan.md; bash "$C" "$T" >/dev/null 2>&1; r2=$?; sed -i "s/^plan_tier: mini$/plan_tier: standard/" "$T"/task_plan.md; awk "BEGIN{print \"## [plan-audit-R1] fixture\"; print \"- 轮次: R1 | 审计体: critic | 结论: **APPROVED**\"; print \"- 问题清单: 无\"}" > "$T"/progress.md; bash "$C" "$T" >/dev/null 2>&1; r3=$?; awk "BEGIN{print \"## [plan-audit-R1] fixture\"; print \"- 轮次: R1 | 审计体: critic | 结论: **REJECTED**\"; print \"- 问题清单: C-1\"; print \"## 2026-11-17 R1 修复轮\"; print \"- 自证: 无审计段级 \" sprintf(\"%c\",96) \"结论: **APPROVED**\" sprintf(\"%c\",96) \" 预写\"}" > "$T"/progress.md; bash "$C" "$T" >/dev/null 2>&1; r4=$?; awk "BEGIN{print \"## [plan-audit-R1] fixture\"; print \"- 轮次: R1 | 审计体: critic | 结论: **REJECTED**\"; print \"- 问题清单: C-1\"; print \"- 意见: 缺少 结论: **APPROVED** 行，不满足 0C/0I\"}" > "$T"/progress.md; bash "$C" "$T" >/dev/null 2>&1; r5=$?; awk "BEGIN{print \"## [plan-audit-R1] fixture\"; print \"- 轮次: R1 | 审计体: critic | 结论: **REJECTED**\"; print \"- 问题清单: C-1\"; print \"## 2026-11-17 R9 修复轮\"; print \"- 轮次: R9 | 审计体: critic | 结论: **APPROVED**\"; print \"- 问题清单: 无\"}" > "$T"/progress.md; bash "$C" "$T" >/dev/null 2>&1; r6=$?; awk "BEGIN{print \"## [plan-audit-R6] 2026-11-17 计划独立审计第 6 轮\"; print \"- 轮次: R6 | 审计体: critic | 结论: **APPROVED**（0 CRITICAL / 0 IMPORTANT；残留 1W+3N 留档不阻断）\"; print \"- 问题清单（留档，不阻断）:\"; print \"  - W-1[W] 5-Question 块滞后一档\"; print \"- 审计体: critic\"}" > "$T"/progress.md; bash "$C" "$T" >/dev/null 2>&1; r7=$?; rm -rf "$T"; test "$r1" -eq 1 && test "$r2" -eq 1 && test "$r3" -eq 0 && test "$r4" -eq 1 && test "$r5" -eq 1 && test "$r6" -eq 1 && test "$r7" -eq 0'

- [ ] VC-2: `attest-plan.sh` 接入 `[audit-gate]`（`--skip-audit-check`、`_attest_cksum` 同时含 `skip_audit`+`TASK_PLANNER_AUDIT_GATE_ENFORCE`+`sha256(progress.md)`、window-lint 后 hash 前调用 checker），无留痕 L1+ fixture 调 attest 时 exit≠0 且不写 `.plan-attestation`，输出含 `[audit-gate]`
  Evidence: `skills/task-planner/scripts/attest-plan.sh` diff；fixture 负例输出与锁文件状态；**断言捕获时点**：负例断言紧贴 `r1` 捕获（在正例 fixture 写入与正例执行**之前**——正例会在同一 `$T` 建 `.plan-attestation`，晚求值 `test ! -f` 必假），正例断言紧贴 `r2` 捕获（R5 C-1）
  **Verify command**: bash -c 'set -u; P=/mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116; A=/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/attest-plan.sh; T=$(mktemp -d); cp -r "$P"/. "$T"/; rm -f "$T"/.plan-attestation; cp /dev/null "$T"/progress.md; rm -f /tmp/attest-cache-*.result; TASK_PLANNER_AUDIT_GATE_ENFORCE=enforce bash "$A" "$T"/task_plan.md >"$T"/o1 2>&1; r1=$?; test "$r1" -ne 0 && test ! -f "$T"/.plan-attestation && grep -q "audit-gate" "$T"/o1; n=$?; awk "BEGIN{print \"## [plan-audit-R1] fixture\"; print \"- 轮次: R1 | 审计体: critic | 结论: **APPROVED**\"; print \"- 问题清单: 无\"}" > "$T"/progress.md; rm -f /tmp/attest-cache-*.result; TASK_PLANNER_AUDIT_GATE_ENFORCE=enforce bash "$A" "$T"/task_plan.md >"$T"/o2 2>&1; r2=$?; test "$r2" -eq 0 && test -f "$T"/.plan-attestation && grep -q "audit-gate" "$T"/o2; p=$?; rm -rf "$T"; test "$n" -eq 0 && test "$p" -eq 0'

- [ ] VC-3: 新增 `selftest-plan-audit-gate.sh`（19 断言） 覆盖静态断言与行为断言（**规范示意形态 APPROVED 通过**（`- 问题清单: 无`）、**真实生产形态 APPROVED 通过**（R6 段字节形态：结论行带括注 + `- 问题清单（留档，不阻断）:`——R7 I-1，防 spec 与生产形态脱钩）、无留痕 L1+ 拒锁、**无声明 legacy → rc0 且输出含 `[audit-gate] SKIP legacy-no-decl`**（R7 W-2）、轻量档 skip 放行、L1+ skip 拒锁、mini 跳过、mini×L1 冲突必审、APPROVED 形态残缺 FAIL、**中间态假阳性（REJECTED 审计段 + 后随含反引号 APPROVED 元引用的修复轮块 → 必 FAIL）**、**仅锚定假 PASS 路径（fixture a：REJECTED 段内裸文 `结论: **APPROVED**` 意见文本 → 必 FAIL；R7 I-2）**、**仅边界假 PASS 路径（fixture b：后随 H2 块内含正规锚定 APPROVED 行 → 必 FAIL；R7 I-2）**、rc2 输入缺失（**删除 progress.md 文件**，非清空——空文件归无留痕 rc1，R7 Q-2）、缓存隔离），fixture 隔离于 `/tmp`、正负例各用独立 task_plan 内容或每例清理 `/tmp/attest-cache-*`，且脚本 exit 0；**两约束由独立 fixture 分别承重（R7 I-2）**：① 聚合边界（止下一个 H2）由 fixture b 独立承重（仅边界实现 → fixture b 抓住）② 结论行 ERE 行首锚定由 fixture a 独立承重（仅锚定实现 → fixture a 抓住）；两约束全缺由「中间态假阳性」负例抓住——**只做其一 = 约束未测**
  Evidence: `skills/task-planner/scripts/selftest-plan-audit-gate.sh`；`selftest-registry.tsv` 对应行；selftest stdout 含 `Total: PASS=`
  **Verify command**: bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-plan-audit-gate.sh && grep -q 'selftest-plan-audit-gate.sh' /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-registry.tsv

- [ ] VC-4: Rule 109 机器面授权表述与实施范围一致——109.7 原文保留，新增 109.8 限定已授权范围（attest [audit-gate]+checker+selftest；skip 仅轻量档、L1+ 唯一逃生=`--skip-audit-check`），SKILL.md 审计门补机器面一行，registry 登记同步
  Evidence: `skills/task-planner/references/critical-rules.md`（109.7 不变 + 109.8）、`skills/task-planner/SKILL.md` 审计门段、`selftest-registry.tsv`
  **Verify command**: grep -n '^### 109 ' /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md && grep -q '109.8' /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md && grep -q '\[audit-gate\]' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md

- [ ] VC-5: 机器门自举实测——Phase 5 merge-back 后由主进程用主仓新 attest 对本 plan-dir 实跑 `[audit-gate]` rc=0 且输出含 `[audit-gate]`（排除旧脚本/缓存回放假通过）；D1 本身走既有文本审计链路（bootstrap: gate-absent）
  Evidence: `plans/task-auditgate-machine-20261116/progress.md` Phase 5 实跑命令/输出；主仓 checker rc=0
  **Verify command**: bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-plan-audit-gate.sh /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116 && bash -c 'set -u; rm -f /tmp/attest-cache-*.result; O=$(mktemp); TASK_PLANNER_AUDIT_GATE_ENFORCE=enforce bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/attest-plan.sh /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/task_plan.md >"$O" 2>&1; r=$?; test "$r" -eq 0 && grep -q "\[audit-gate\]" "$O"; s=$?; rm -f "$O"; exit $s'

- [ ] VC-6: 无回归——全量 selftest `--fresh` **同集零增量**（`Total:` 行 `FAIL=7` 且 `Failed:` 行==task_plan.md Phase 1「selftest 基线冻结」7 名单，无新增 FAIL；断言面仍是全量回归，只冻结已知存量失败集合而非降低断言强度——绝对 `FAIL=0` 会被跨任务共享仓他任务在途债确定性击穿）；worktree 范围断言（merge-back 前，`git diff --name-only master` + `ls-files --others` 含 untracked，等效 `git add -N`）⊆ `scope_files`（**两段式**：断言本体由 Phase 5 S2 在 merge-back 前执行并留痕 `[scope-check] <ISO8601> SCOPE-OK diff=N untracked=N`；终验仅以**全文件严格 token 正则**复核该留痕（`^\[scope-check\] <ISO8601> SCOPE-OK diff=N untracked=N$`——与 S2 的 EOF 追加形态互洽，位置不敏感），不 live 依赖工作树——避免与 S2 强制清理互斥）；部署位 `diff -r` 零差异（merge-back 后由 V-5.2 验证）；`user-session-log.md` 未改、config.json 未新增键
  Evidence: `run-selftests.sh --fresh` 的 `Total:` 行（`FAIL=7`）与 `Failed:` 行（==冻结 7 名单；冻结块=task_plan.md Phase 1「selftest 基线冻结」，冻结日期 2026-11-17）；`progress.md` 全文件严格 token 匹配的 `[scope-check] <ISO8601> SCOPE-OK diff=N untracked=N` 行（merge-back 前由 S2 主进程追加写入——留痕归属 Phase 5 段，文件末尾追加亦被全文件 token 正则接受；唯一权威证据；V-N 复跑仅复核留痕；执行时核对白名单集合与 task_plan.md `scope_files` 一致）；V-5.2 三部署位 diff；**基线漂移凭据**=`progress.md` 的 `[baseline-shift] <ISO8601> <新 Total 行> | <新 Failed 行> | <逐名归因> | <重跑冻结依据> | <critic 简版复审结论>行`（仅当他任务收口使基线合法变化时存在；**防滥用双闸**：① 逐名归因——名单中每个新增或消失的条目必须在行内指认对应他任务/提交锚（如 `task-mdedit-reliability-20261116 收口`），**无法指认的新增 FAIL 不得吸收**；② 漂移后须重走 critic 文本审计（对本判据字面量变更做简版复审），禁主进程自裁；缺失该行或归因/复审不全而 `FAIL`/名单字面量与本 Verify command 不符 → 按冻结名单判 FAIL，禁静默放宽）
  **Verify command**: bash -c 'set -u; P=/mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116; O=$(mktemp); grep -qE "^\[scope-check\] [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z SCOPE-OK diff=[0-9]+ untracked=[0-9]+$" "$P"/progress.md || { rm -f "$O"; exit 1; }; bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/run-selftests.sh --fresh >"$O" 2>&1; grep -qE "^Total: [0-9]+ PASS=[0-9]+ FAIL=7 " "$O" && grep -q "^Failed: selftest-active-plan selftest-batch-pilot selftest-enumerate-first selftest-execution-stability selftest-registry selftest-self-resolution selftest-summary-readability$" "$O" || { rm -f "$O"; exit 1; }; rm -f "$O"; grep -q "^> 三、未完成项与风险 1 授权 2 测试$" "$P"/user-session-log.md && test -f /mnt/data/dev/task-planner-skill/skills/task-planner/config.json && { grc=0; grep -q "\"audit" /mnt/data/dev/task-planner-skill/skills/task-planner/config.json 2>/dev/null || grc=$?; test "$grc" -eq 1; }'

---

## Phase Gates

### Phase 1: 基线核实与负断言冻结

**Goal**: 冻结 attest/Rule109/SKILL/selftest/先例的基线锚点与可判别负断言，为机器门与测试提供对照面。

**Depends on**: none

**Done when**:
- [ ] 基线锚点与负断言写入 findings.md/knowledge-brief.md 且可复现

**Verification** (run before moving on):
- [ ] V-1.1: 基线负断言可复现（audit-gate/checker/selftest/registry 缺失）——**时点注记（R5 Q-1）**：仅 Phase 1 时点执行（基线快照）；Phase 3 落地后本断言自然失效（`attest-plan.sh` 含 `audit-gate`/checker 文件存在即属预期产物），**终验 Goal Gate 不复跑本 gate**
  **Verify command**: test "$(grep -c 'audit-gate' /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/attest-plan.sh)" -eq 0 && test ! -f /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-plan-audit-gate.sh
- [ ] V-1.2: 计划六文件结构完整（user-session-log 不动）
  **Verify command**: test -f /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/task_plan.md && test -f /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/findings.md && test -f /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/knowledge-brief.md

Status: `complete`  Last verified: 2026-11-17

---

### Phase 2: 设计冻结与计划走查

**Goal**: 冻结 checker/attest/selftest/109.8 设计并通过计划门控自检。

**Depends on**: Phase 1

**Done when**:
- [ ] 设计与 CA 变更表落盘，计划门控脚本可跑

**Verification**:
- [ ] V-2.1: task_plan 必填字段与 S-unit 粒度自洽
  **Verify command**: bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-plan-dispatch.sh /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/task_plan.md
- [ ] V-2.2: R↔VC 覆盖与 VC 非真空通过
  **Verify command**: bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-rvc-coverage.sh /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116 && bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-vc-nonvacuous.sh /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116

Status: `complete`  Last verified: 2026-11-17

---

### Phase 3: 机器强门实现（checker + attest 接线 + selftest）

**Goal**: 在 worktree 落地 checker、attest `[audit-gate]` 与 selftest 正负例。

**Depends on**: Phase 2

**Done when**:
- [ ] checker/attest/selftest 实现并自测通过

**Verification**:
- [ ] V-3.1: checker 与 selftest 语法/静态锚通过
  **Verify command**: bash -n /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-plan-audit-gate.sh && bash -n /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/attest-plan.sh && bash -n /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-plan-audit-gate.sh
- [ ] V-3.2: selftest-plan-audit-gate 行为用例全绿
  **Verify command**: bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-plan-audit-gate.sh

Status: `complete`  Last verified: 2026-11-17

---

### Phase 4: 文本条款与登记同步（109.8 + SKILL + registry）

**Goal**: 同步 109.8 授权条款、SKILL 机器面说明与 registry 登记。

**Depends on**: Phase 3

**Done when**:
- [ ] 109.7 不变+109.8 新增，SKILL/registry 同步且自洽

**Verification**:
- [ ] V-4.1: Rule 109 定义唯一且 109.8 存在
  **Verify command**: test "$(grep -c '^### 109 ' /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md)" -eq 1 && grep -q '^109\.8 ' /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md
- [ ] V-4.2: SKILL 与 registry 含审计门机器面标记
  **Verify command**: grep -q '\[audit-gate\]' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && grep -q 'selftest-plan-audit-gate.sh' /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-registry.tsv

Status: `complete`  Last verified: 2026-11-17

---

### Phase 5: 回归、自举实测与合并部署

**Goal**: 跑全量回归；merge-back 并部署/推送后由主进程执行自举实测。

**Depends on**: Phase 4

**Done when**:
- [ ] selftest/回归通过、merge back 完成、merge 后主仓自举实测 rc=0 且输出含 `[audit-gate]`、check-complete exit 0
- [ ] 存量迁移说明登记（9 无声明 legacy +7 个 standard/L1 无留痕（未归档在途口径，含已 complete 未归档）；存量不重锁+首版 warn 起步建议）

**Verification**:
- [ ] V-5.1: 自举实测（merge-back 后主进程用主仓新 attest 对本 plan-dir 实跑 rc=0 且输出含 `[audit-gate]`）
  **Verify command**: bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-plan-audit-gate.sh /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116 && bash -c 'set -u; rm -f /tmp/attest-cache-*.result; O=$(mktemp); TASK_PLANNER_AUDIT_GATE_ENFORCE=enforce bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/attest-plan.sh /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/task_plan.md >"$O" 2>&1; r=$?; test "$r" -eq 0 && grep -q "\[audit-gate\]" "$O"; s=$?; rm -f "$O"; exit $s'
- [ ] V-5.2: 部署位 diff 与计划完成门控通过（merge-back 后）
  **Verify command**: diff -r /mnt/data/dev/task-planner-skill/skills/task-planner /home/terry/.zcode/skills/task-planner >/dev/null && diff -r /mnt/data/dev/task-planner-skill/skills/task-planner /home/terry/.claude/skills/task-planner >/dev/null && diff -r /mnt/data/dev/task-planner-skill/skills/task-planner /home/terry/.config/opencode/skills/task-planner >/dev/null && bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-complete.sh /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116

Status: `complete`  Last verified: 2026-11-17

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| `attest-plan.sh` 门链/缓存 | 交付物含 `[audit-gate]` 且 `_attest_cksum` 同时含 `skip_audit`/`TASK_PLANNER_AUDIT_GATE_ENFORCE`/`sha256(progress.md)`；回放 WARN；位置在 window-lint 后 hash 前；失败不写锁 | **已核（2026-11-17）**：四处增量在位（grep 锚+enforce 真实链路实测拒锁不写锁/APPROVED 写锁）；evidence/VC-2.out |
| `critical-rules.md` Rule 109 | 109.7 原文保留、109.8 追加且范围限定（skip 仅轻量档、L1+ 唯一逃生=--skip-audit-check）；`^### 109` 唯一 | **已核**：`grep -c '^### 109 '`=1；109.7 行原样；109.8 六子项；VC-4 exit=0 |
| `check-plan-audit-gate.sh` 判定语义 | lane 优先（L1/L2 必审，mini×L1 最严）、无声明显式 `SKIP legacy-no-decl`（有 fixture 承重）、APPROVED 最小形态（审计体/轮次/`问题清单`——**`问题清单` 容忍全角/半角括注后接冒号**，真实段=<code>- 问题清单（留档，不阻断）:</code>）+ **末段聚合边界止下一个 H2 行（仅认 `^## `，后随块须用 H2 标题）/ 结论行 ERE 行首锚定**（防中间态反引号元引用假 PASS；两约束各有独立负例承重）、轻量 skip vs L1+ 拒锁、rc2 显式 WARN+fail-open（progress.md 缺失/不可读=rc2，存在但空=rc1） | **已核**：VC-1 七态 rc=0+VC-3 16/16+CR 抽测；evidence/VC-1.out VC-3.out |
| `SKILL.md:68-77` 审计门 | 审计门区块补机器面一行并保留 `[plan-audit-skip]`/`[plan-audit-R<N>]` 载体 | **已核**：SKILL.md:78 机器门行在位（grep=1） |
| `plans/archive/task-planaudit-20261116` 先例 | 末段 APPROVED awk 形态与 progress 留痕一致；selftest/attest 正负例可复现 | **已核（口径升级）**：先例命令中间态假阳性已被 R6a 加固两约束取代（kb:27）；本计划自 dir 即可复现（checker rc=0） |
| `knowledge/entries/task-planaudit-20261116.md` | 三教训落实：disk-verified receipts、Verify 非真空正负测、共享状态以主仓为准 | **已核**：三教训贯穿本计划（收据盘上复核/七态+16 断言正负实测/主仓权威核查） |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116`，粘贴 JSON 输出作为委派率依据。

```bash
# 证据（执行后粘贴以下 JSON 原文）
bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116
```

JSON 输出：
```json
{"phases_total":5,"phases_delegated":4,"main_direct_count":1,"delegation_rate":0.800,"violations":[],"verdict":"ok"}（2026-11-17 check-delegation.sh stats 真实输出；执行期 Phase1/3/4/5 主进程兜底以 Handoff 降级备注+Executor 白名单例外理由登记）
```

- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3：Phase 2=25.3② 计划系统文件维护；Phase 1/3/4/5=provider 限流降级兜底（§十降级链+task-v171 先例），Handoff #2/#3/#4/#5 降级备注+type 裸 token）
- [x] 委派率 verdict=ok（0.800≥0.7 floor；S-unit 表口径 stats rc=0；主进程直做经 25.3 例外+降级披露登记）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成:触发 3 项（skip 轻量档 109.3/legacy 迁移/CR Q-1 默认 warn 确认）,豁免 1 项（L0 比例不适用面）,未处置 0 项
- [x] Evidence 抽查 4 条:evidence/VC-1..VC-4.out 可 Read 且命令复现 exit=0（CR 终检亦独立复跑）
- [x] 豁免登记:CR Q-1 默认 warn=获批计划 R1 F12 迁移披露口径（2026-11-17；用户可 env 一行切 enforce）
- [x] 无未处置违规；outcome 不降级

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 在 task-planner 落地计划审计门机器强门并以 Phase 5 自举实测验证机器门行为有效
对照 Verification Contract 逐条复验：
- [x] VC-1: checker lane 优先/形态断言/skip 语义/rc 语义 → **PASS**（run-verification exit=0，evidence/VC-1.out；CR2 独立复核）
- [x] VC-2: attest [audit-gate]+skip+cksum(skip+enforce+progress)+拒锁行为 → **PASS**（run-verification exit=0，evidence/VC-2.out；CR2 独立复核）
- [x] VC-3: selftest-plan-audit-gate 正负例/冲突档/缓存隔离/registry → **PASS**（run-verification exit=0，evidence/VC-3.out；CR2 独立复核）
- [x] VC-4: 109.7 保留+109.8 追加+SKILL/registry 同步 → **PASS**（run-verification exit=0，evidence/VC-4.out；CR2 独立复核）
- [x] VC-5: Phase 5 自举实测 rc=0 + progress 留痕（D1 走既有文本链路） → **PASS**（run-verification exit=0，evidence/VC-5.out；CR2 独立复核）
- [x] VC-6: 全量 selftest **同集零增量**（`Failed:` 集合==Phase 1 冻结 7 名单，无新增 FAIL；非绝对 `FAIL=0`）+ 部署位 diff + git 范围 + user-session-log/config 未越界 → **PASS**（run-verification exit=0，evidence/VC-6.out；CR2 独立复核）

 outcome: **COMPLETE**（2026-11-17 run-verification PASS=6 FAIL=0+CR2 APPROVED 0C/0I）
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。

**PARTIAL**：VC 通过但存在已知遗留缺陷 → 列出 + 建议后续。

**BLOCKED**：≥1 VC 失败且 3 次重试无效 → 升级用户决策。

> **验证独立性**：终验核查动作（回归/抽查/对齐审查）由全新独立子代理执行，主进程仅编排与簿记——禁止以主进程既有上下文自测替代验收（Rule 33.3）。

---

## 交叉验证记录（Rule 108）
| 验证对象 | 机械面路径（命令+结果） | 语义面路径（复检体+结论） | 判定（一致/分歧→108.4 处置） |
|----------|------------------------|--------------------------|------------------------------|
| 计划文档定稿（本轮） | check-plan-dispatch/check-rvc-coverage/check-vc-nonvacuous/check-template-type/check-tier-consistency/check-delegation stats（修复轮 7 轮末重跑，rc 见 progress.md R7 修复轮段） | critic R1-R5 复审均 REJECTED 并逐轮修复；R6 APPROVED（0C/0I）；R6a 单点加固（聚合中间态假阳性）落盘；**R7 范围化复审 REJECTED（0C/2I/2W/2Q/2N）→ 修复轮 7 已逐项修订（I-1 容忍 token+真实形态 fixture、I-2 r5/r6 独立负例、W-2 legacy SKIP 用例、Q-1 H2 前提、Q-2 空文件 rc 口径），R8 APPROVED**；CR 终检 R1 REJECTED→修复（fix2 d6201f0）→CR2 APPROVED（0C/0I）；D1 走既有文本审计链路（bootstrap: gate-absent，SHA d1be4e66） | 2026-11-17 |
| 机器强门实现（执行期） | selftest-plan-audit-gate 19 断言+run-verification PASS=6 FAIL=0+attest 真实链路 | **已核（CR2 APPROVED 0C/0I）**：109.8 授权范围一致；mutation 判别终证；fix2 范围恰 4 文件 | 2026-11-17 |

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase 1 in_progress（基线已冻结含 selftest 存量基线；R1-R5 审计均 REJECTED 并逐轮修复收口、微修轮 4b 完成 VC-6 同集零增量对齐；R6 复审 APPROVED 0C/0I；R6a 单点加固已落盘；**R7 范围化复审 REJECTED（0C/2I/2W/2Q/2N）→ 修复轮 7 已逐项修订收口，待 R8 复审**） |
| 2 | Where am I going? | R8 复审（按 0C/0I 迭代）→ D1 → 既有 attest 锁定（bootstrap: gate-absent）→ Phase 1 执行 → Phase 3 实现 → Phase 4 文本/登记 → Phase 5 回归+自举实测+合并部署 |
| 3 | What's the goal? | 落地计划审计门机器强门（attest [audit-gate]+checker+selftest）并以 Phase 5 自举实测验证机器门行为有效 |
| 4 | What have I learned? | 见 findings.md / knowledge-brief.md（lane 优先、cksum 三项、progress 哈希、skip 仅轻量档、APPROVED 最小形态、**聚合边界止 H2（仅认 `^## `，后随块须 H2 标题）+ 结论行 ERE 行首锚定，两约束各配独立负例**、**`问题清单` 判据容忍括注形态（真实段 `- 问题清单（留档，不阻断）:`）**、**progress.md 缺失=rc2 / 空=rc1**、rc2 fail-open、bootstrap: gate-absent、VC 断言捕获时点、产出位置与消费断言的定位方式互洽） |
| 5 | What have I done? | 6 计划文件已写并按 R1-R7 各轮审计发现逐轮增量修订（含微修轮 4b、R6a 单点加固、修复轮 7 五项）；user-session-log 原样未改；机械门八门 rc=0（修复轮 7 末重跑）；D1 已过（44.3 完成性指令自动裁决+旧链锁定）；执行 Phase 1-5 complete；终验 PASS=6 FAIL=0；CR2 APPROVED——outcome COMPLETE |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区（按需检查） |
