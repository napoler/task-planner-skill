# P7 S1 检查点 — executor（critical-rules.md 条款标注）

status: done

## 里程碑
- [2026-09-16] S1 落盘：critical-rules.md 五处行尾标注完成（diff 仅增不删，+5/-5 全为「原行 → 原行+行尾标注」）
  - 21.1b（:114）行尾追加「（机器校验已生效：check-plan-dispatch.sh attest 时逐行校验时长 NNmin≤step_max_minutes/输入 token≤step_max_files，超限拒绝；不可解析 SKIPPED 显式化）」
  - 21.4（:117）行尾追加「（机器守护：check-dispatch.sh 串行槽+打包检测）」
  - 22.4（:127）行尾追加「（机器校验已生效：check-dispatch.sh 校验 prompt 字符数 vs prompt_max_chars 与多 S-unit 打包，挂 dispatch_contract_enforce 档位）」
  - 22.6（:132）行尾追加「（机器校验已生效：check-plan-dispatch.sh 校验执行体列+S-unit 数值门控）」
  - 25.1（:169）行尾追加「（attest 门控范围 2026-09-16 起=S-unit 表+执行体+数值门控；fmea_enforce 消费方=attest-plan.sh+check-complete.sh 双点）」
  - 证据：`git diff --stat` = 10 +++++-----（5 insertions/5 deletions，删除行均为被扩写原行的完整前缀，语义零删改）；`grep -c "机器校验已生效\|机器守护"` 新增 4 处命中
- 锚定级联预检：`grep -rn "Rules 1-" scripts/ | head` = 命中 3 脚本（selftest-reflect-verify RV-10 / selftest-error-loop EL-11 / selftest-veto VT-10），断言均为 `grep -q 'Rules 1-34'` 或 `grep -qE 'Rules 1-3[1-4]'` 宽容锚，不绑定 SKILL.md 具体锚行号——S2 行内标注不破坏

- [2026-09-16] S2 落盘：SKILL.md 四处行尾标注完成（diff +4/-4，全为行内扩写，零删改语义）
  - §超时与失败兜底 节引言行（:397）行尾追加 22.4 机器化标注「（22.4 上下文预算=prompt 长度/打包检测已机器化：check-dispatch.sh 校验 prompt 字符数 vs prompt_max_chars 与多 S-unit 打包，挂 dispatch_contract_enforce 档位）」
  - Rule 21 摘要行（:287）追加「（21.1b 数值门控已入 check-plan-dispatch）」
  - Rule 25 摘要行（:291）追加「（fmea_enforce 消费已兑现：attest+check-complete）」
  - Methodology 指针行（:294）追加「（fmea_enforce 消费方已落地：attest-plan.sh FMEA 门控段 + check-complete.sh 终验双点消费，三档 warn/enforce/off 分化 2026-09-16 生效）」
  - 证据：`wc -l SKILL.md` 改前 535 → 改后 535（全为行内扩写，未触 T2b ≤540 断言）；git diff --stat = 4 insertions/4 deletions（删除行均为被扩写原行完整前缀）
- [2026-09-16] 验证双 selftest 全绿
  - `bash scripts/selftest-knowledge-brief.sh` → `Total: 16  PASS=16  FAIL=0`
  - `bash scripts/selftest-template-lifecycle.sh` → `Total: 17 PASS=17 FAIL=0`

## 终验 V5 字面 grep 门回修（主进程指令，2026-09-16）
- SKILL.md 三处标注措辞改为含「机器校验已生效」字面（V5 字面 grep 门要求）：
  - :287 Rule 21 行 → 「（21.1b 数值门控机器校验已生效：check-plan-dispatch.sh）」
  - :291 Rule 25 行 → 「（fmea_enforce 消费机器校验已生效：attest+check-complete）」
  - :294 Methodology 指针行 → 「（机器校验已生效：attest-plan.sh FMEA 门控段 + check-complete.sh 终验双点，三档 warn/enforce/off）」
- 复验：`wc -l SKILL.md` = 535（不变）；`grep -c "机器校验已生效\|机械校验" SKILL.md` = 3；`bash scripts/selftest-knowledge-brief.sh` = `Total: 16  PASS=16  FAIL=0`

## 最终结论
status: complete
acceptance: ① critical-rules.md 五处标注（21.1b:114 / 21.4:117 / 22.4:127 / 22.6:132 / 25.1:169，diff +5/-5 仅增不删）② SKILL.md 四处标注（§超时兜底引言:397 / Rule 21 行:287 / Rule 25 行:291 / Methodology 指针:294，diff +4/-4 行内扩写）③ wc -l 前后值 535→535（≤540 T2b 通过）
files: /mnt/data/dev/task-planner-skill-worktrees/task-v075-fine-grain-methodology/skills/task-planner/{references/critical-rules.md, SKILL.md}
evidence: git diff 全量核对 + selftest-knowledge-brief Total 16/0 + selftest-template-lifecycle Total 17/0
blockers: none
confidence: HIGH
