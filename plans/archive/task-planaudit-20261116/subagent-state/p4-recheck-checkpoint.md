# P4 Recheck Checkpoint (2026-11-16, independent full re-read)

## Scope (read-only)
- worktree: /mnt/data/dev/task-planner-skill/tmp/worktrees/task-planaudit-20261116
- commit: 70e29b1 (diff vs HEAD~1)
- files changed (git diff --stat): `skills/task-planner/SKILL.md` (+6/-3 effective summary) and `skills/task-planner/references/critical-rules.md` (+22/-1), total 2 files, +24/-4.

## Verdict: **FAIL**

### Findings
1. **[CRITICAL] rule-reserve status not landed** (requirement: `bash skills/task-planner/scripts/rule-reserve.sh check 109` 状态=landed)
   - Evidence: `cd .../worktree && bash skills/task-planner/scripts/rule-reserve.sh check 109` => stdout `free`, RC=0. `rule-reserve.sh list | grep 109` => no entry. `rule-reserve.sh status 109` prints usage (no status subcommand). Actual state=free, not landed.

2. **[IMPORTANT] SKILL audit-gate 分档豁免措辞与 design §A 非逐字一致**
   - Evidence: `skills/task-planner/SKILL.md:70` 实际为 `...；L0-E 天然豁免`；design-p3-p4.md §A 围栏对应行为 `...；L0-E 豁免`（缺少“天然”二字）。逐行 diff 比对：该行实际 114 字符 vs 设计 112 字符，其余 9 行与 design §A 一致。语义未逆转但逐字偏离 design §A。

### PASS items (with evidence)
- **全文回读**: 读取 `skills/task-planner/SKILL.md` (318 行) 与 `skills/task-planner/references/critical-rules.md` (227 行) 全文。
- **Rule 109 区块 vs design §C 逐字一致**: critical-rules.md:194-212（`### 109 ...` 至 `## 卫星路由索引` 前）与 design-p3-p4.md §C 围栏提取文本 byte-for-byte 相等（Python 逐段比较 `RULE109_MATCH=True`）；109.1-109.7 子条编号连续、Why 行完整。
- **计数同步（§D 基准）**: SKILL.md:9 含 `Rules 1-109 全集索引（核心在位 1,2,3,5,19,20,26,51,62,66,80,81,82,83,109...其余 90 条）`；SKILL.md:258 含 `Rules 1-109 全集索引：**核心在位 15 条**（...109）...其余 90 条...Rule 109 独立审计门（audit-before-delivery，核心在位）`；SKILL.md:302 含 `1-109 全集索引（15 条核心全文+分层架构说明+卫星路由索引）`；critical-rules.md:180 含 `（15 条：1,2,3,5,19,20,26,51,62,66,80,81,82,83,109）...SKILL.md:9/258「核心在位 15 条」`。旧计数 `1-108`/`91 条`/`14 条` 在两文件 grep 均无命中。
- **`^### 109 ` 唯一=1**: `grep -rn "^### 109 " skills/` 仅命中 `skills/task-planner/references/critical-rules.md:194`；文件内 `grep -c "^### 109 "` = 1。
- **卫星路由索引**: critical-rules.md `## 卫星路由索引` 下 bullet 数=12（awk 统计）；verification-gate 行 `critical-rules.md:227` 未被本次 diff 修改（diff 无涉及该行），文本保留 `(Rule 84)`；结构未破坏。SKILL.md 卫星表 `SKILL.md:254` 含 `(Rule 84,108)` 未改。
- **Rule 80-83 条款本体**: git diff 仅改 critical-rules.md:180 计数句与 192 后追加 Rule 109 块，未触及 Rule 80/81/83 正文；Rule 82 正文仅计数列同步（符合增量同步）。SKILL.md diff -4 行均为计数行替换（:9,:258,:302），无 Rule 80-83 条款改动。
- **git diff --stat HEAD~1**: 仅 2 文件（见上）。
- **语义一致性**: SKILL.md:68-77 审计门区块与 critical-rules.md:194-212 (109.2-109.6) 在裁决映射(0C/0I⇒APPROVED/REJECTED)、分档、留痕 `[plan-audit-R<N>]`、44.3 不适用、103.3 边界、降级链、输入包等关键语义互洽；仅分档豁免末句措辞“天然”差异（见 Finding #2）。引用规则编号存在性抽查：Rule 103/84/108/69/70/38.7/51/80 在 SKILL.md 与 critical-rules.md 中均有命中（grep 证据见复检命令输出）。
- **回归命令**:
  - `bash skills/task-planner/scripts/check-plan-dispatch.sh /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/task_plan.md` => RC=0（WARN: Rule 68.3 并行组同执行体 advisory，非阻断）。
  - `bash skills/task-planner/scripts/rule-reserve.sh check 109` => `free`, RC=0（**与“状态=landed”要求不符，FAIL**）。

## Recommendation
- 将 Rule 109 在 rule-reserve 台账中登记/更新为 landed（按项目 rule-reserve.sh 流程），使 `check 109` 返回 landed 状态。
- 将 SKILL.md:70 `L0-E 天然豁免` 对齐为 design §A `L0-E 豁免`（或同步更新设计基准并全链一致）；当前为非阻断语义偏差但违反逐字对齐预期。
