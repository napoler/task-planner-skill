# 15f-cp-ip 检查点 | 2 selftest 宽容锚 40-[56][0-9]→40-[567][0-9]

status: complete | 2026-10-10

## 实态锚（改动前核实）
- SKILL.md:288 = `Critical Rules 1-71（含 Rule 40-71 全集...` —— 全集声明实态 `40-71`（锚 grep -n "40-71" SKILL.md → L288）
- 旧宽容锚 `40-[56][0-9]` 在 SKILL.md 命中=0（grep -n 无输出）；新锚 `40-[567][0-9]` 命中=1（grep -cE → 1），`Rule 40-[567][0-9]` 命中=1
- 新锚覆盖 40-50..40-79，后续合法扩号不触发，语义强度不降（同范式再演进先例：task-v136 EH-09 / task-v144 级联）

## 改动（仅 2 文件）
### skills/task-planner/scripts/selftest-capability-persistence.sh
- L7（头部清单）：`40-[56][0-9]`（宽容, 当前声明=40-62）→ `40-[567][0-9]`（宽容, 当前声明=40-71）
- L78-83（CP-05 断言）：注释头 + grep 正则 + 同行 ok/bad 文案 全部 `40-[56][0-9]`→`40-[567][0-9]`，追加 [2026-10-10 task-v158 S-unit 级联] 演进说明；ok 文案 40-5x/6x→40-5x/6x/7x
- 负断言 CP-06（40-5[3-9]=0）不动（旧纪元对象，不受本次影响）

### skills/task-planner/scripts/selftest-iteration-persistence.sh
- L15（头部清单）：IP-12 宽容锚 `Rule 40-[56][0-9]`→`Rule 40-[567][0-9]`
- L143-150（IP-12 断言）：注释头 + grep 正则 + 同行 ok/bad 文案 全部替换，追加 [2026-10-10 task-v158 S-unit 级联] 演进说明（保留 L1447 行 task-v144 历史说明作为演进链）

## 验收证据
- bash -n 双过（SYNTAX-OK ×2）
- bash selftest-capability-persistence.sh → `CP-05 PASS SKILL.md '40-5x/6x/7x' 全集声明（宽容 40-[567][0-9]）=1`，`Total: 20 PASS=20 FAIL=0`，exit 0
- bash selftest-iteration-persistence.sh → `IP-12 PASS SKILL.md 全集声明「Rule 40-[567][0-9]」宽容锚 ≥1（1）`，`Total: 18 PASS=18 FAIL=0`
- git diff --stat 仅这两文件（plans/ 下两文件改动为 S-unit 前置既有状态，未纳入本次提交）

## 残余风险
- 无。`40-[567][0-9]` 若未来全集声明扩至 40-80+ 需再次随动（宽容正则先例已写入注释防钉死）。
