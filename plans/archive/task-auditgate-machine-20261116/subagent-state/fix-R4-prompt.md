# 修复轮 4 任务书 — task-auditgate-machine-20261116

你是本计划的 Plan Writer（修复轮 4）。工作目录 /mnt/data/dev/task-planner-skill。只修改计划文档（plans/task-auditgate-machine-20261116/ 六文件），禁碰 skills/** 与其他目录，禁创建仓库脚本。

## 背景与需求锚

- 用户需求逐字锚（plans/task-auditgate-machine-20261116/user-session-log.md #1）：「三、未完成项与风险 1 授权 2 测试」。计划需求锚 R1=「1 授权」R2=「2 测试」R3=「三、未完成项与风险」。任务=为计划审计门加机器强门（新 checker check-plan-audit-gate.sh + attest [audit-gate] 接线 + selftest）并测试。plan_tier=standard / execution_lane=L1。
- 历轮审计：R1 REJECTED 14 发现→修复；R2 REJECTED 6（N1-N6）→修复；R3 REJECTED（I1 fail-open+W1/N7/N8）→修复（引入 fail-closed 形态）；**R4 REJECTED（6 发现）——完整发现清单已由主进程登记 progress.md [plan-audit-R4] 段，动工前必读**。

## 修复指令（逐项，全部实际 Edit 落盘）

### C-1[CRITICAL] verification.md:37 尾部 config 断言恒败

现状 `test "$(grep -c "\"audit" config.json || echo 0)" -eq 0` 恒 rc=2（`grep -c` 零命中时已打印 `0` 且 exit 1，`|| echo 0` 追加第二个 0 → 变量="0\n0" → integer expression error，主进程已盘上复现）。

改为：
```
test -f /mnt/data/dev/task-planner-skill/skills/task-planner/config.json && ! grep -q "\"audit" /mnt/data/dev/task-planner-skill/skills/task-planner/config.json
```
（`test -f` 守卫缺文件 fail-closed；`grep -q` rc1=无命中经 `!` 翻转为成功。）

改后 /tmp 双态实测：①临时 fixture 文件含 `"audit` 键 → 该断言 rc≠0；②真实 config.json（无键）→ rc=0。收据贴真实输出。

### I-1[IMPORTANT] VC-6 时点两段式（消灭终验必败）

R3 引入的 `test -d "$WT"` live 断言与 Phase 5 S2 强制 worktree 清理互斥（终验 run-verification 复跑时 worktree 已删 → rc=1 必 FAIL → outcome 禁 COMPLETE）。重构：

1. verification.md VC-6 的 Verify command **删除 live worktree 断言**，改为断言已留痕证据：progress.md Phase 5 段含 `[scope-check]` 行且含确定性 token `SCOPE-OK`。判据形态示例（须 Phase 5 段内锚定，可按需调整但须保持段锚+token）：
   ```
   awk '/^### Phase 5/{f=1} f&&/\[scope-check\]/{print; exit}' /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/progress.md | grep -q "SCOPE-OK"
   ```
2. VC-6 Verify command 保留可 live 复跑部分：`bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/run-selftests.sh --fresh 2>&1 | grep -qE "^Total: [0-9]+ PASS=[0-9]+ FAIL=0"` + user-session-log 逐字锚 grep + config 断言（按 C-1 重写）。
3. live 范围断言命令（`git -C "$WT" diff --name-only master` + `ls-files --others --exclude-standard` + fail-closed + W-1 的 `$` 锚修正 + N-1 的 rc 捕获修正）移入 task_plan.md Phase 5 S2（:281/:291 既有位置）作为 S2 内嵌命令/验收步骤：S2 merge-back **前**由主进程执行，通过后写 `[scope-check] <ISO8601> SCOPE-OK diff=N untracked=N` 行入 progress.md Phase 5 段；失败即停不写 PASS 行。
4. 清理 task_plan.md:269 残留矛盾「VC-6 时点=全部 Phase 完成后的终验复验」→ 改两段式口径（范围断言=S2 merge-back 前留痕；回归/部署位 diff=终验复验），与 :284/:372 一致。
5. verification.md VC-6 的 Evidence 行同步两段式口径。

### W-1[W] 白名单正则补 `$` 锚

verification.md:37 grep -vE 白名单文件级分支补尾锚（`attest-plan\.sh$`、`check-plan-audit-gate\.sh$`、`selftest-plan-audit-gate\.sh$`、`selftest-registry\.tsv$`、`SKILL\.md$`、`critical-rules\.md$`），目录分支 `plans/task-auditgate-machine-20261116/` 保持尾 `/`。

用 /tmp 合成仓（`git init` 模拟 master+worktree 两目录）复测：①变异组加 `skills/task-planner/SKILL.md.bak` → 拦截 rc=1；②控制组加白名单内文件 → 放行 rc=0。收据贴真实输出。

### W-2[W] `[scope-check]` 确定性 token 格式落 S2 验收

task_plan.md:281/:291 补 token 形态（`[scope-check] <ISO8601> SCOPE-OK diff=N untracked=N`），与 I-1 第 3 点互洽。

### N-1[NIT] 管道 rc 掩蔽

S2 内嵌范围断言中 `out=$(cat "$D" "$U" | grep -vE "...")` 的 `|| true` 改显式捕获：
```
rc=0; out=$(cat "$D" "$U" | grep -vE "...") || rc=$?
test "$rc" -eq 0 -o "$rc" -eq 1 || { echo "[audit-gate] FAIL: grep 异常 rc=$rc"; rm -f "$D" "$U"; exit 1; }
test -z "$out" || { echo "[audit-gate] FAIL: 越界文件: $out"; rm -f "$D" "$U"; exit 1; }
```
（grep rc=2=模式/读错误必须 exit 1，仅 rc=1 无匹配合法续行。）另：S2 验收或 VC-6 Evidence 增「执行时核对白名单集合与 task_plan.md scope_files 一致」一句（最小修复，不引入新脚本）。

### N-2[NIT] VC-1 措辞补 r2

verification.md:15「rc 0/1 本命令实测」枚举补 mini×L1 冲突负向（r2=rc1）。

## acceptance:

- 每项修复实际 Edit 落盘，收据含真实命令输出（grep -n 锚定位+实测 rc），禁「应落点/待执行」措辞
- C-1/W-1 的 /tmp 模拟正反态实测真实执行并贴输出
- 三约束保持并在收据自证：R1-R3 逐字锚 task_plan.md:16-18 未动、user-session-log.md 全文未动、无 APPROVED 预写
- 全部机械门重跑贴真实 rc：check-plan-dispatch.sh、check-delegation.sh stats、check-rvc-coverage.sh、check-vc-nonvacuous.sh、check-template-type.sh、check-tier-consistency.sh、check-step-placeholders.sh、check-goal-cjk.sh（均在 /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/ 下，入参=计划目录或 task_plan.md 按各脚本用法）

## checkpoint:

/mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/subagent-state/fix-R4.md — 动工前写（轮次/范围/开始时间），完成后追加逐项处置与实测输出。

## 输入材料（绝对路径）

- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/task_plan.md
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/verification.md
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/progress.md（[plan-audit-R4] 段=本轮修复输入）
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/findings.md
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/knowledge-brief.md
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/notepad-learnings.md
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/subagent-state/（checkpoint 与历轮审计检查点）

## 完成后追加

1. progress.md 末尾追加「## 2026-11-17 R4 修复轮（REJECTED → 增量修订，C-1/I-1/W-1/W-2/N-1/N-2）」段（处置/文件/未改/机械门重跑真实输出）。
2. findings.md 补本轮发现与教训。
3. knowledge-brief.md 新增教训（`grep -c || echo 0` 双零陷阱；fail-closed 须核对复跑时点资源存续；计划期 VC 应确定性干跑而非仅静态非真空判定）。
4. notepad-learnings.md 同步。

## 输出格式（8 字段返回模板）

- status: COMPLETE/FAILED
- result: 六项处置摘要与机械门结果
- evidence: 每项落点的 grep -n 定位+实测输出
- files_modified: 实际改动文件清单
- verification_results: /tmp 模拟实测（C-1 双态/W-1 合成仓）真实输出
- learnings: 新教训
- next_steps: 无（复审归主进程派发）
- risks: 风险披露（无则"无"）
