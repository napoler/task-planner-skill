# 3-executor checkpoint — task-v128 S3（attest-plan.sh 规则编号查重段）
status: done

## 里程碑
- M1 读取 D3 契约 + rule-reserve.sh 语义 + attest-plan.sh 现状：DONE
- M2 追加段实现（既有 gate 段之后、attestation 写入之前，仅 attest 模式）：DONE
- M3 bash -n + git diff 仅新增 64 行 / 0 删除：DONE
- M4 四态 fixture 实跑（/tmp/rr-s3-F4-PXszbt，账本 RULE_RESERVE_LEDGER=/tmp 临时，未写真账本）：DONE
- M5 SKIPPED 缺失态实测（临时改名 rule-reserve.sh → 打印 SKIPPED 并继续，exit 0）：DONE

## 实现要点
- 追加位置：attest-plan.sh FMEA 门控段之后、`hash=...` attestation 写入之前；case "attest" 分支内，--show/--verify/--clear 零影响。
- new_rule 解析两形态（对齐 check-template-type.sh 三形态先例）：① `<!-- new_rule: <N> -->` ② `| `new_rule` | <N> |`；值 none/缺失 → 零输出（F4 硬门）。
- 语义映射 D3：空闲→reserve 自动登记+INFO；被他人持有/contested→WARN+next 建议（默认不阻断，rc=0）；STRICT=1→exit 2 且未写 attestation；本任务已持有（含在 claimants）→INFO 已登记（幂等）。
- fail-open：脚本缺失 / check 非 0/3 异常 / 登记失败 → SKIPPED 并继续锁定。
- Rule 45 注释 What+Why 双层齐备（task-v128 D3 锚注）。

## 产出清单
- 修改：skills/task-planner/scripts/attest-plan.sh（+64/-0，git diff 统计）
- 测试环境：/tmp/rr-s3-F4-PXszbt（new/old 双结构 + plans fixture + ledger.jsonl + f2/f3/f4 输出留档）

## 验证证据
- bash -n SYNTAX_OK；git diff --stat = `1 file changed, 64 insertions(+)`，`^-` 行=0
- F1: `[rule-reserve] INFO: rule 60 空闲 → 自动登记 (task=task-v128...)` EXIT=0；账本追加 `{"rule":60,"status":"reserved","task_id":"task-v128"...}`
- F1b 幂等: `[rule-reserve] INFO: rule 60 已由本任务登记/持有 (rule 60 held by task-v128 (reserved)...)`
- F2: `[rule-reserve] WARN: rule 50 contested: [contested[task-v125 task-v127]] (task=task-v999; 建议改号 next=52; 默认不阻断...)` EXIT=0（next=52 与 D4b 种子后期望一致；此前 2 条 mini 种子环境 next=51 亦正确）
- F3: 同 F2 + `TASK_PLANNER_RULE_RESERVE_STRICT=1` → `[attest] ✗ Rule 编号冲突: new_rule=50 ... 拒绝锁定` F3_EXIT=2，未写 attestation
- F4: 旧版=`git show HEAD:...attest-plan.sh`，同结构环境 old/ vs new/ 跑同一 legacy 计划（无 new_rule）→ 归一化运行目录后 diff 零；严格复核同名 sed 归一 `run/` 后 F4_STRICT_DIFF=ZERO，rule-reserve 输出行数=0
- SKIPPED: `mv rule-reserve.sh rule-reserve.sh.bak` 实测 → `[rule-reserve] SKIPPED (rule-reserve.sh 缺失, fail-open 继续, Rule 20.6)` F5_EXIT=0
- 仅改 1 文件（git status --short = M attest-plan.sh）；禁改清单零触碰

## 最终结论
```
status: done
acceptance: 5/5 pass — F1（new_rule=60 空闲 → 自动登记 + `INFO: rule 60 空闲 → 自动登记 (task=task-v128)` exit 0，账本追加 reserved 行；再 attest → `INFO: rule 60 已由本任务登记/持有`）；F2（contested 50 种子 → `WARN: rule 50 contested: [contested[task-v125 task-v127]] (建议改号 next=52; 默认不阻断...)` exit 0，与改前门控行为一致）；F3（同 F2 + TASK_PLANNER_RULE_RESERVE_STRICT=1 → `✗ ... 拒绝锁定` exit 2，未写 attestation）；F4（未声明 new_rule 的 legacy 计划：旧版 git show HEAD vs 新版，同结构环境归一化后 diff 零、rule-reserve 输出 0 行、rc 均 0）；SKIPPED（rule-reserve.sh 临时改名 → `SKIPPED (rule-reserve.sh 缺失, fail-open 继续)` 且 exit 0 继续锁定）
files: /mnt/data/dev/task-planner-skill-worktrees/task-v128/skills/task-planner/scripts/attest-plan.sh (+64/-0)
evidence: bash -n → SYNTAX_OK；git diff --stat → `attest-plan.sh | 64 +++++... 1 file changed, 64 insertions(+)`（^- 行=0）；git status --short → 仅 M attest-plan.sh；F2/F3/F4 输出与 exit 码原文见上「验证证据」节
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v128/subagent-state/3-executor.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
```
