# s5-composite-review-editspec（task-v172 CA-7 复合审查 = 用户原话锚）— 供 code-assistant 精确执行

worktree 根目录：`/home/terry/task-planner-skill-worktrees/task-v172-skill-efficiency-opt`
背景：用户 R4/R5——纠偏/复合审查必须拿 user-session-log.md 的用户多轮原始对话（权威原话源）与当前执行步骤对照查偏移，偏移即打回；纠偏由独立子代理（drift-checker）执行。本轮把「用户原话锚」接入 drift-checker 主体路径。逐条 Edit，old_string 必须精确匹配（先 Read 目标文件确认）。

---

## E1 文件：skills/task-planner/companion/agents/drift-checker.md

old_string:
```
1. **读计划**：Read 派发 prompt 中的 task_plan.md 绝对路径（需要时辅读 findings.md/progress.md）——提取 Goal、VC 条目、执行范围限制、当前 Phase
```
new_string:
```
1. **读计划+原话**：Read 派发 prompt 中的 task_plan.md 绝对路径（需要时辅读 findings.md/progress.md）——提取 Goal、VC 条目、执行范围限制、当前 Phase；**[task-v172 CA-7] 必读 user-session-log.md 全部原话条目（多轮，含纠正/追加/否决）——它是用户意图权威源（Rule 80），每个三态判定都必须与其对照。判定口径升级=当前执行/产出与用户原话不一致才算 DRIFT，而非仅与 task_plan R 条目不一致（R 条目可能是主进程转译，转译与原话冲突时以原话为准，Rule 80.4）**
```

## E2 文件：skills/task-planner/companion/agents/drift-checker.md

old_string:
```
- 判定输入三锚（Rule 64.4）：任务书必须内嵌 ① Goal 原文锚 ② progress.md 尾部动作清单锚 ③ scope 文件集锚；判定必须逐锚引用证据写检查点；无证据锚的 ALIGNED 判定无效=按未执行处理。
```
new_string:
```
- 判定输入三锚（Rule 64.4，[task-v172 CA-7] 复合审查强化）：任务书必须内嵌 ① 用户原话锚=user-session-log.md 全部原话条目+task_plan.md R 条目双源（原话优先；转译 R 与原话冲突以原话为准，Rule 80.4）② progress.md 尾部动作清单锚 ③ scope 文件集锚；判定必须逐锚引用证据写检查点；无证据锚的 ALIGNED 判定无效=按未执行处理。
```

## E3 文件：skills/task-planner/scripts/zcode-posttooluse.sh

在含 `[drift-rhythm]` 的 emit 提醒文案内追加复合审查指引。先 Read 该文件找到 `emit "[drift-rhythm]"` 行（约 370 行），把该 emit 字符串末尾（`...ledger-append.sh drift_check` 附近 `Rule 64.1 留痕三件套` 之后）追加：
`（复合审查=读 user-session-log.md 全原话对照当前执行，偏移→打回重做/修正，Rule 80.4/61）`
只追加字符串内容，不改 emit 结构与变量；确保引号转义正确（该字符串内用的是中文标点），bash -n 通过。

## E4 文件：skills/task-planner/scripts/selftest-drift-check-subagent.sh

1. 先 Read 全文，定位头部断言计数注释（含「20 断言全 PASS」字样）与末尾汇总逻辑（PASS/FAIL 打印）。
2. 在末尾汇总逻辑之前新增一条断言（编号顺延现有最大 DCS 号+1）：
   ```
   if grep -q 'user-session-log' "$DRIFT_MD"; then ok <NN> "CA-7: drift-checker.md 含 user-session-log 用户原话锚（复合审查输入在位）"; else bad <NN> "CA-7: drift-checker.md 缺 user-session-log 用户原话锚"; fi
   ```
   （$DRIFT_MD=该脚本已有的 drift-checker.md 路径变量；若变量名不同，用脚本内既有的指向 companion/agents/drift-checker.md 的变量。）
3. 同步把头部计数字注释的 20→21（若该数字确为 20）。

---

## E5 文件：skills/task-planner/scripts/check-complete.sh（CA-8：终验 DRIFT-GATE，env 开关默认 warn）

先 Read 该文件，定位 DELEGATION GATE 段（约 413-492 行，含 `l0_gate_open "DELEGATION GATE ..."` 与 `printf '[plan] DELEGATION GATE PASSED ...'`）及其收尾逻辑。在该 gate 段之后（或文件收尾 exit 之前）新增一个**自包含、默认 warn 不拦**的 DRIFT-GATE 块，遵循既有 gate 范式：

- 触发条件：当前计划目录含 ≥1 个标记为 complete 的多 Phase（≥2 个 `### Phase` 段有 `**Status:** complete`）**且** `subagent-state/` 下无任何文件名匹配 `*drift*`（drift-checker 检查点缺失）
- 行为：默认输出 `[DRIFT-GATE] ⚠️ 已完成多 Phase 但无 drift-checker 纠偏检查点（v146 Rule 61 载体；建议复盘是否漏派，Rule 64.1 留痕三件套）` 到 stderr（warn，**不改 exit 码**）；若环境变量 `TASK_PLANNER_DRIFT_GATE_ENFORCE=enforce` 且当前 outcome 非 BLOCKED → 追加一行并**不阻断**（保持 exit 不变，enforce 仅升级文案措辞为「⛔ 应返工补派 drift-checker」，仍不 hard-fail，避免破坏既有 77/77 基线）
- 约束：不得新增 config.json 键（用 env var，避免 17 文件键数锚级联）；L0/mini 档（`l0_gate_open` 命中或 plan_tier=mini）跳过本块；fail-open（变量缺失/目录不可读→静默跳过）
- 加注释 `[task-v172 CA-8] 纠偏子代理执行率机器可观测（R5 实证：drift-checker 检查点 v160 后 10 任务零执行）`

（说明：本 gate 默认 warn 是为了机器可观测纠偏执行率而不破坏现有 77/77 回归；enforce 默认 off，由用户在需要时设 env 收紧。这是安全交付。）

## E6 文件：skills/task-planner/scripts/selftest-check-drift.sh（CA-8 守护）

1. Read 该文件定位断言区与末尾汇总。
2. 新增 1 条断言（编号顺延）：`check-complete.sh` 含 `DRIFT-GATE` 字面 ∧ 含 `TASK_PLANNER_DRIFT_GATE_ENFORCE` env 开关锚（在位=CA-8 机器守护）：
   ```
   if grep -q 'DRIFT-GATE' "$CHECK_COMPLETE" && grep -q 'TASK_PLANNER_DRIFT_GATE_ENFORCE' "$CHECK_COMPLETE"; then ok <NN> "CA-8: check-complete 含 DRIFT-GATE + env 开关（纠偏执行率机器可观测）"; else bad <NN> "CA-8: check-complete DRIFT-GATE 缺失"; fi
   ```
   （$CHECK_COMPLETE=该脚本指向 check-complete.sh 的既有变量；若脚本用不同变量名或路径写法，用其既有指向 check-complete.sh 的变量。）

---

## 完成后自检（命令原文+结果写入检查点）
1. `bash -n /home/terry/task-planner-skill-worktrees/task-v172-skill-efficiency-opt/skills/task-planner/scripts/zcode-posttooluse.sh && echo SYNTAX_OK_PTU`
2. `bash -n /home/terry/task-planner-skill-worktrees/task-v172-skill-efficiency-opt/skills/task-planner/scripts/check-complete.sh && echo SYNTAX_OK_CC`
3. `cd /home/terry/task-planner-skill-worktrees/task-v172-skill-efficiency-opt && bash skills/task-planner/scripts/selftest-drift-check-subagent.sh 2>&1 | tail -3`（期望 FAIL=0）
4. `bash skills/task-planner/scripts/selftest-check-drift.sh 2>&1 | tail -3`（期望 FAIL=0）
5. `bash skills/task-planner/scripts/run-selftests.sh 2>&1 | tail -3`（期望 Total: 77 PASS=77 FAIL=0；若有 FAIL，逐个定位并把新失败+根因写入检查点「错误与受阻」段，禁止改断言以外的东西）

