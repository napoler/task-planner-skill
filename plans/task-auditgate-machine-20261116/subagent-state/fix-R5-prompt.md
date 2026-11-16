# 修复轮 5 任务书 — task-auditgate-machine-20261116

你是本计划的 Plan Writer（修复轮 5）。工作目录 /mnt/data/dev/task-planner-skill。只修改计划文档（plans/task-auditgate-machine-20261116/ 六文件+检查点），禁碰 skills/** 与其他目录，禁创建仓库脚本。

## 背景（自包含）

- 用户需求逐字锚（plans/task-auditgate-machine-20261116/user-session-log.md #1）：「三、未完成项与风险 1 授权 2 测试」。计划需求锚 R1=「1 授权」R2=「2 测试」R3=「三、未完成项与风险」。任务=计划审计门机器强门（checker+attest 接线+selftest）+测试。plan_tier=standard / execution_lane=L1。
- 历轮：R1 REJECTED 14→修复；R2 REJECTED 6→修复；R3 REJECTED 1+3N→修复；R4 REJECTED 6→修复轮 4+微修 4b；**R5 REJECTED（8 发现，主进程已登记 progress.md [plan-audit-R5] 段——动工前必读该段获取完整描述与主进程复核证据）**。

## 修复指令（逐项，全部实际 Edit 落盘）

### C-1[CRITICAL] verification.md:21 VC-2 断言顺序污染（无 PASS 路径）

现状：负例（r1，无留痕 → attest 拒锁不建锁文件）跑完后才写 fixture APPROVED progress.md，再跑正例（r2，建锁 `$T/.plan-attestation`）；负例断言组 `test "$r1" -ne 0 && test ! -f "$T"/.plan-attestation && grep -q "audit-gate" "$T"/o1` 在正例之后执行 → 锁文件已被正例创建 → `test ! -f` 恒假 → n=1 → 整命令 rc=1。

**修复（推荐形态：负例断言紧跟负例执行，正例断言紧跟正例执行）**：
```
... bash "$A" "$T"/task_plan.md >"$T"/o1 2>&1; r1=$?
test "$r1" -ne 0 && test ! -f "$T"/.plan-attestation && grep -q "audit-gate" "$T"/o1; n=$?
awk ... > "$T"/progress.md; rm -f /tmp/attest-cache-*.result
... bash "$A" "$T"/task_plan.md >"$T"/o2 2>&1; r2=$?
test "$r2" -eq 0 && test -f "$T"/.plan-attestation && grep -q "audit-gate" "$T"/o2; p=$?
rm -rf "$T"; test "$n" -eq 0 && test "$p" -eq 0
```
（注意保持原有元素完整：前置 `rm -f /tmp/attest-cache-*.result` 在负例前、awk fixture、`TASK_PLANNER_AUDIT_GATE_ENFORCE=enforce`、`rm -rf "$T"` 收尾；形态可微调但**断言捕获时点必须紧跟各自用例**。）

**实测收据（真实输出）**：改后整链 dry-run——因 attest 本体尚未实现（Phase 3 产物），用 critic 同法：/tmp mock 实现（替换 `A=` 路径为 mock 脚本，命令正文其余逐字取自计划）跑通：负例 rc≠0 无锁 → n=0；正例 rc=0 建锁 → p=0；整链 rc=0；再做一个破坏变体（如 mock 让正例不建锁）→ rc≠0。贴真实输出。

### I-1[IMPORTANT] S2 留痕 EOF 追加 ↔ VC-6 段锚不兼容（终验必 FAIL）

现状：task_plan.md:324（S2 内嵌命令）`echo "[scope-check] ..." >> "$PROG"` 追加到 progress.md 文件末尾；verification.md:37 VC-6 用 awk 只在 `### Phase 5:` 段（:63-73，止于 :74 `## 审计留痕占位`）内找 `[scope-check]` 行 → EOF 追加永远段外 → 终验必 FAIL；S2 验收是位置不敏感 grep 查不出。

**修复（推荐：VC-6 改全文件严格 token 正则，S2 追加形态保持不变）**：
1. verification.md:37 VC-6 Verify command 首段：删 awk 段锚，改
   `grep -qE "^\[scope-check\] [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z SCOPE-OK diff=[0-9]+ untracked=[0-9]+$" "$P"/progress.md`
   （全文件扫描+严格 token 形态；与 S2 产出 `[scope-check] <UTC ISO8601> SCOPE-OK diff=N untracked=N` 逐字对应）。
2. verification.md VC-6 判据/Evidence 行同步口径（「Phase 5 段内」措辞改「progress.md 全文件严格 token 匹配」或保持留痕归属 Phase 5 段的语义说明）。
3. progress.md Phase 5 段（:63-73 区间内）补一行**槽位说明**（非 SCOPE-OK 行本身，不构成预写）：如 `- （执行期 S2 在此段追加 [scope-check] 行——VC-6 唯一权威证据；文件级追加亦可被全文件 token 匹配，段内追加为推荐形态）`。
4. task_plan.md S2 验收/Notes 中与段锚相关的措辞同步（如有）。

**实测收据**：/tmp 副本 progress.md 三态——①Phase 5 段内追加 → rc=0；②EOF 追加 → rc=0（全文件形态下合法）；③无 [scope-check] 或 token 畸形（如缺 SCOPE-OK/diff=N）→ rc≠0。贴真实输出。

### W-1[W] 基线漂移条款加防滥用闸

task_plan.md:253（冻结块）+verification.md:36（Evidence）漂移条款补两条：①**逐名归因**——每个集合变化的新名单条目（新增或消失）须在 `[baseline-shift]` 行内指认对应他任务/提交锚（如 `task-mdedit-reliability-20261116 收口`），无法指认的新增 FAIL 不得吸收；②漂移后**重走 critic 文本审计**（对判据字面量变更做简版复审）而非主进程自裁。

### W-2[W] verification.md 会话恢复块同步

verification.md:200-212（5-Question/会话恢复块）stale 项同步为当前实态：`Where am I?` 等行改为「R1-R4 均已逐轮修复、微修 4b 完成、R5 REJECTED 修复轮 5 进行中（或按届时实态）」；与本块其他行一致性顺带核查。

### Q-1[QUESTION] V-1.1 时点注记

verification.md:54 V-1.1 行尾加注「（仅 Phase 1 时点执行——基线快照；Phase 3 落地后本断言自然失效，终验不复跑本 gate）」。

### N-1[NIT] config 断言 rc=2 fail-open 收口

verification.md:37 尾段 `test -f X && ! grep -q "\"audit" X` 改显式 rc 捕获：
```
grc=0; grep -q "\"audit" /mnt/data/dev/task-planner-skill/skills/task-planner/config.json 2>/dev/null || grc=$?; test "$grc" -eq 1
```
（found→0→test 败；not found→1→过；error/不可读→2→败=fail-closed；前置 `test -f` 保留。）/tmp 三态实测：含键→rc≠0；无键→rc=0；不可读（chmod 000，非 root）→rc≠0。

### N-2[NIT] progress.md:176 stale 行号

历史段不改写，在该行行尾追加括注 `（行号后移：实际落点现为 task_plan.md:296/:306——R4 内嵌命令块插入所致）`。

### N-3[NIT] progress.md:195 历史段指针

同法，行尾追加 `（已由 R4b 处置：改同集零增量+基线冻结，见 [plan-audit-R5] 前的 R4b 段）`。

## acceptance:

- 每项修复实际 Edit 落盘，收据含 grep -n 锚定位+真实实测输出，禁「应落点/待执行」措辞
- C-1/I-1/N-1 的 /tmp 模拟正反态实测真实执行并贴输出
- 三约束保持并自证：R1-R3 逐字锚 task_plan.md:16-18 未动、user-session-log.md 全文未动、progress.md 无审计段级 `结论: **APPROVED**` 预写
- 机械门重跑贴真实 rc（八门全跑：check-plan-dispatch / check-delegation stats / check-rvc-coverage / check-vc-nonvacuous / check-template-type / check-tier-consistency / check-step-placeholders / check-goal-cjk，均在 /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/）

## checkpoint:

/mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/subagent-state/fix-R5.md — 动工前写（轮次/范围/开始时间），完成后追加处置与实测输出。

## 输入材料（绝对路径）

- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/task_plan.md
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/verification.md
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/progress.md（[plan-audit-R5] 段=本轮修复输入）
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/findings.md
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/knowledge-brief.md
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/notepad-learnings.md
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/subagent-state/audit-R5.md（R5 检查点，含 critic 完整发现与实测）

## 完成后追加

1. progress.md 末尾「## 2026-11-17 R5 修复轮（REJECTED → 增量修订，C-1/I-1/W-1/W-2/Q-1/N-1/N-2/N-3）」段。
2. findings.md 补本轮处置对照。
3. knowledge-brief.md 补教训（VC 断言捕获时点必须紧跟各自用例——共享 fixture 顺序污染；产出物写入位置必须与其消费断言的定位方式互洽——EOF 追加 vs 段锚；漂移条款需逐名归因+独立复核双闸）。
4. notepad-learnings.md 同步。

## 输出格式（8 字段返回模板）

- status: COMPLETE/FAILED
- result: 八项处置摘要与机械门结果
- evidence: 每项落点 grep -n+实测输出
- files_modified: 清单
- verification_results: /tmp 模拟实测真实输出
- learnings: 新教训
- next_steps: 无
- risks: 风险披露（无则"无"）
