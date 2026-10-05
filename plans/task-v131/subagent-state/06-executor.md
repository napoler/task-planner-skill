# 06-executor 检查点 — task-v131 Phase 2 第三 S-unit（attest-plan.sh 锁定面 51.1 门）

status: SUCCESS | 时间: 2026-10-05

## 交付物
- worktree: /home/terry/task-planner-skill-worktrees/task-v131
- 改动文件（唯一）: skills/task-planner/scripts/attest-plan.sh（+31/-2，未 commit）
  - 新增 51.1 需求原文区块门（Rule 45 What+Why 双层注释位于调用点 :121-130）：
    调用点 = check-plan-dispatch 与 check-template-type 段之后、FMEA 门控之前（即锁定写入前，满足任务契约"check-template-type 通过后、锁定写入前"）；
    三锚校验：①标题 `^## 🎯 用户需求原文` ②R 行 `^- \*\*R[0-9]`（≥1，同时覆盖 `- **R1**:` 逐字行与宽松 **R1** 形态）③`R→VC 映射`；
    mini 豁免：全文 grep `plan_tier: mini`（与 FMEA mini 豁免 :177 同先例同口径）→ 打 `[requirement-gate] INFO` 跳过；
    fail-closed：三锚任一缺失 → `[attest] ✗ 缺 Rule 51.1 用户需求原文区块（标题/R 行/R→VC 映射三锚任一）；mini 档豁免——先回炉补区块再锁定` + exit 1；
    **未新增 --skip 参数**（契约"能不加就不加"）；help 文本 :13-14 登记该门为 fail-closed 硬门+mini 豁免口径，help sed 行 2,13p→2,14p 防截断。
  - 既有 :295 注释口径「三道前置门」→「四道前置门」同步修正。

## bash -n
- SYNTAX-OK（改动后两次复验均通过）

## VC-3 实测（全部 /tmp，禁触主仓原位；留档 /tmp/v131-attest-test/out-*.txt）
| 例 | 输入 | 结果 | 证据原文（摘录） |
|---|---|---|---|
| a 负例 | plan-negative.md（standard、无区块、既有门全过） | exit=1，无 .plan-attestation 产生 | `[attest] ✗ 缺 Rule 51.1 用户需求原文区块…` + `[attest] ✗ 缺失锚:· 标题…缺失 · R 需求行…缺失 · 「R→VC 映射」段缺失` |
| b 正例 | plan-positive.md（三锚齐全） | exit=0，成功锁定 | `[attest] [requirement-gate] OK (Rule 51.1 三锚在位)`；51.1 ✗ 行 grep 计数=0（无误伤） |
| c mini 豁免 | plan-mini.md（plan_tier: mini、无区块） | exit=0，成功锁定 | `[requirement-gate] INFO: plan_tier: mini 豁免(Rule 51.1 mini 档不要求需求原文区块, 同 FMEA mini 先例)` |
| d 回归 | /tmp/v131-regression（主仓 plans/task-v131 只读拷贝，真实 rule-enhancement 计划） | exit=0，成功锁定 | `[attest] [requirement-gate] OK (Rule 51.1 三锚在位)`；既有门行为零漂移（dispatch SKIPPED 时长 20 行/template OK/fmea OK/rule-reserve fail-open 路径解析说明均在原文留档） |

**51.1 门触发序实测（任务要求的如实记录）**：现有调用序 dispatch → template → **51.1** → fmea → rule-reserve → 写锁。
51.1 门可达性：前置两门对最小测试计划均为 exit 0 或 warn 不阻断（template 白名单含 general+rule-enhancement；dispatch 对派发行齐备计划 exit 0）→ 负例中 51.1 门实际触发并 exit 1，**无需调整调用序**。
若计划缺 template_type：默认 config template_gate_enforce=warn → [template-gate] WARNING 不阻断，51.1 门仍可达；仅 enforce 档且模板违规时 51.1 不可达（此时模板门先拦=正确语义，非缺陷）。

## issues / 登记
- mini 例输出含一行既有 `[plan-tier] MISMATCH: mini 判定条件不满足(Goal 行缺 ≤15min 预估时长字样) — 提示不阻断`（plan_tier_enforce=warn 既有门，非本单元引入；如实记录）。
- c/d 例 /tmp 下 rule-reserve 走「无法解析账本 fail-open」（CWD 无 plans/ 祖先且未设 RULE_RESERVE_LEDGER）——既有 fail-open 行为零变化。
- 负例构造时 dispatch 门先 exit 1 的场景未出现（测试计划 S-unit 表齐备 dispatch 通过），51.1 门触发证据完整。

## 恢复点
无断点，单元完成。后续（越界不归本单元）：commit 需协调前四单元未提交的 task_plan.md / rule-enhancement-type.md / init-session.sh 改动；VC-3 证据原文已备供主进程回填 progress.md Phase 2 段。
