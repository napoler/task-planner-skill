# P4-S1 executor checkpoint — check-complete.sh template-sense warn 段

status: PASS
时间盒: 约 12 min（≤15min 内）
worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v096-template-auto-record（P3 收口 @ e00cdf9；本 S-unit 已提交 @ 6079c0b，coordinator 指令覆盖任务书「禁 git」，提交信息=task-v096 P4-S1 T3 template-sense warn 段，commit 后 git status 干净）

## 改动产出
- 文件: `skills/task-planner/scripts/check-complete.sh`（唯一写入文件，git diff = **+10 行纯新增**，无既有行改动）
- 插入点: fmea-gate 段收尾 `fi`（原 L559）之后、`[2026-09-27 task-v091 C-2] 两门全过` 注释行之前（新段位于 :561-570）
- 段内容（原文）:
  ```bash
  # [2026-09-29 task-v096 P4-S1 T3] template-sense warn 抽查段（Rule 34.7 全自动生成合约，
  # fmea-gate warn 范式：不阻断、零新 config 键）：
  # 计划含「🔁 模板感知」区块（init-session 运行时追加）且「处置登记处」未填写
  # （「沉淀理由/不沉淀理由」冒号后带实质内容, 或「已沉淀」登记; 占位行关键词后无冒号不命中）
  # → 单行 warn；已登记 → 零输出。
  if grep -q '🔁 模板感知' "$PLAN_FILE" 2>/dev/null \
     && ! grep -qE '不沉淀理由[[:space:]]*[:：][^[:space:]]|沉淀理由[[:space:]]*[:：][^[:space:]]|已沉淀' "$PLAN_FILE" 2>/dev/null; then
      echo '[template-sense] ⚠ 计划含模板感知区块但终验未登记沉淀/不沉淀理由（Rule 34.7 全自动生成合约）' >&2
  fi
  ```
- 硬约束核对: 仅新增 10 行（≤15）✅；退出码语义零变化（段内无 exit，末行仍 `exit $python_rc`）✅；零新 config 键 ✅；禁 git/网络/其他文件 ✅

## 判定逻辑（对齐 brief §3 A9 / §4 条 3 与 VC-3）
- 命中条件: 计划全文 `grep -q '🔁 模板感知'`（区块存在性，精确锚）
- 已登记判定（任一命中即零输出）:
  1. `不沉淀理由` + 全/半角冒号 + 冒号后首个非空白字符（实质内容）
  2. `沉淀理由` + 全/半角冒号 + 冒号后首个非空白字符（「不沉淀理由：xxx」亦命中此式——前缀含「沉淀理由」，双式冗余无害）
  3. `已沉淀` 任意出现
- 占位行免疫: init-session 追加区块的占位行「- 处置登记处: 沉淀理由 / 不沉淀理由（二选一必填）」中关键词后均为空格/斜杠（非冒号）→ 三式均不命中 → warn 正常触发（case a 实证）

## 自验证据（mktemp 沙箱，未写仓库）
| 用例 | 输入 | 期望 | 实测 | 结果 |
|------|------|------|------|------|
| a 正例 | 含「🔁 模板感知」区块 + 占位处置登记处（init-session 原样追加形态） | stderr 含 [template-sense] warn | stderr: `[template-sense] ⚠ 计划含模板感知区块但终验未登记沉淀/不沉淀理由（Rule 34.7 全自动生成合约）`；stdout 无；rc=0 | PASS |
| b 负例 | 无区块普通计划 | 零 template-sense 输出（stdout+stderr） | 双通道 grep 均 none；rc=0 | PASS |
| c 负例 | 含区块 + 「不沉淀理由：xxx」 | 零输出 | 双通道均 none；rc=0 | PASS |
| d 语法 | `bash -n check-complete.sh` | rc=0 | rc=0 | PASS |

补充: 额外跑「已沉淀」登记形态（含区块 + `- 处置登记处: 已沉淀 rule-enhancement 复用`）→ 零输出，PASS（第四例，超出任务书三例要求）。

## 回归抽跑（worktree 内，全部 rc=0）
- 任务书点名的 4 脚本:
  - selftest-final-gate-hash: PASS=22 FAIL=0（沙箱副本机制；键③ FMEA 段哈希 sed 区间 = /FMEA 门控终验点/,/失败挽救链路终验门控/p 即 L505-580）
  - **注意（修正初稿误判）**: 新段 L561-570 落在键③ sed 区间**之内** → 键③哈希必然变化 → 既有已 attest 计划的缓存 SKIP 状态下次终验时失效一轮（走一次全量重跑后 re-attest/自愈重锁）。这是提案「只增失效不漏失效」的 fail-safe 语义，无正确性回归；final-gate-hash ④f-1/④f-2 用例实证还原后自愈重锁。P7 全量复跑时预期首轮出现 PLAN-DISPATCH/FMEA GATE 全量（非 SKIP-BY-HASH），属正常。
  - selftest-reflect-verify: Total: 12 PASS=12 FAIL=0
  - selftest-error-loop: Total: 16 PASS=16 FAIL=0
  - selftest-vc-gate: Total: 11 PASS=11 FAIL=0
- 加跑全部引用 check-complete 的其余 4 脚本（超任务书要求，全 8 消费方覆盖）:
  - selftest-skill-modify: 9/0；selftest-delegation: 38/0；selftest-mechanism-profile: 19/0；selftest-plan-tier: 32/0

## 移交主进程/P7 项
1. C22 行措辞「check-complete warn 兜底」与本段输出标签 `[template-sense]` 一致性（任务书已声明 P7 复核）——实测标签即 `[template-sense]`，warn 单行、stderr 输出、不阻断
2. 新段在 C-2 键③哈希段（sed 区间 L505-580）**之内** → 键③哈希变化 → 既有 attest 计划的缓存 SKIP 状态失效一轮（终验走一次全量后自愈重锁；fail-safe「只增失效不漏失效」语义，无正确性回归）；含感知区块的新计划首轮仍走全量（正确语义）
3. 未登记理由判定为全文级 grep（非区块内截取）——计划其他位置出现「沉淀理由：」字样也会抑制 warn（宽判定，fail-open 风格，与 warn 兜底定位一致；P7/CR 可裁量）

## 风险/负结果声明
- 无回归 FAIL；8 个引用 check-complete 的 selftest 全绿
- 负结果检查: 对 b/c 两负例，`grep 'template-sense'` stdout 与 stderr 均零命中（非"未检查"）；排除误报面 = 普通计划（无区块）与已登记计划均静默
- 唯一未测面: 全量 36 脚本求和（P7 职责，本 S-unit 时间盒外）
