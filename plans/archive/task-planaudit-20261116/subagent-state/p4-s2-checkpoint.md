# p4-s2-checkpoint (Phase 4 索引联动)

- status: in_progress
- scope: SKILL.md (:9,:258,:302) + references/critical-rules.md (:180) 计数/索引同步（Rule 109 已落地，联动载体一致性）
- worktree: /mnt/data/dev/task-planner-skill/tmp/worktrees/task-planaudit-20261116
- started: 2026-11-16

## 计划改动
1. `references/critical-rules.md:180`：`14 条：...82,83）`→`15 条：...82,83,109）`；`SKILL.md:9/175「核心在位 14 条」`→`SKILL.md:9/258「核心在位 15 条」`
2. `SKILL.md:9`：`1-108`→`1-109`，核心清单追加 `,109`，追加 ` + Rule 109 独立审计门`，`91 条`→`90 条`
3. `SKILL.md:258`：`1-108`→`1-109`，`14 条`→`15 条`，核心清单追加 `,109`，`91 条`→`90 条`（两处），末段追加 `、Rule 109 独立审计门（audit-before-delivery，核心在位）`
4. `SKILL.md:302`：`1-108`→`1-109`

## 约束
- 仅 4 行 5 处计数措辞改动，零增删行；不触 Rule 109 条款本体与 Rule 80-83。
- 计数口径：核心 14→15，全集 1-108→1-109，其余 91→90，核心清单追加 109。

## 自审（收尾）
- status: done
- 改动范围：仅 4 行 5 处计数措辞更新（SKILL.md :9,:258,:302；critical-rules.md :180），零增删行，未触 Rule 109 条款本体与 Rule 80-83。
- 自验结果：
  - `grep -n "1-109" SKILL.md` => :9,:258,:302 命中
  - `grep -n "15 条" SKILL.md critical-rules.md` => SKILL.md:258, SKILL.md:302, critical-rules.md:180（计数行各在位；含索引描述“15 条核心全文”）
  - `grep -n "90 条" SKILL.md` => :9,:258
  - `grep -c "1-108|91 条|核心在位 14 条"` => SKILL.md:0, critical-rules.md:0
  - `grep -c "^### 109 "` critical-rules.md => 1
  - `wc -l` => SKILL.md 318, critical-rules.md 227 (total 545)
- 风险/偏差：none
