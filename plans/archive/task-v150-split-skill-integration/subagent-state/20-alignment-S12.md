# 20-alignment-S12 · alignment-review 对齐审查（task-v150 产出）

VERDICT: ISSUES_FOUND

- 伴飞技能模式：Rule 59.2 —— 首动作 Read `/home/terry/.zcode/skills/alignment-review/SKILL.md`（存在，按标准执行）
- 审查对象（只读）：worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v150-split-skill-integration` `git diff master...HEAD` 文档改动
- 审查日期：2026-10-09

## status
完成（结论 ISSUES_FOUND，附逐条问题清单）

## acceptance（结论 + 逐条）

**结论：ISSUES_FOUND（等价 alignment-review CHANGES_REQUESTED：存在 P1）**

逐条问题（file:line — 问题 — 建议修法）：

- [P1] `skills/task-planner/references/critical-rules.md:161` — Rule 21.6 导语写「10 模式+伴飞映射库」，但 `references/split-pattern-library.md` 实际有 11 个 `### P` 章节（P1-P11），`scripts/selftest-registry.tsv:64` 与 `selftest-split-pattern-library.sh` SP-02 均冻结为 11 — 将「10 模式」改为「11 模式」，与库/守卫对齐。
- [P1] `skills/task-planner/SKILL.md:354` — References 表新行写「10 模式+伴飞映射表」，同上与库实际 11 模式不符 — 改「11 模式」。
- [P1] `plans/task-v150-split-skill-integration/task_plan.md:49,95` — scope_files 与「执行范围」均声明 `CHANGELOG.md`（追加 1 条目）为交付物，但 worktree diff 无 CHANGELOG 改动、两仓 CHANGELOG 均无 task-v150/split-pattern 条目，Phase 6 簿记清单亦未列 CHANGELOG — 合并前补 CHANGELOG 条目，或从 scope_files 移除并登记豁免理由。（注：此项超出本次指定的 4 文档 diff 范围，属计划声明面，可能计划于 Phase 6 处理）
- [P2] `skills/task-planner/SKILL.md:215` — 新增合规行 `| C43a | 拆分前已查模式库 split-pattern-library | ☐ |` 与同表 C30-C44 行格式不一致（缺「（Rule 21.6）」引用、缺「机器面=…；mini 档豁免」结构），且 C43a 子编号无先例（无 C41a/C42a）— 补齐 Rule 21.6 引用+机器面锚（selftest-split-pattern-library.sh）+mini 档豁免，或并入 C43。
- [P2] `skills/task-planner/scripts/selftest-registry.tsv:64` + `scripts/selftest-split-pattern-library.sh:41` — registry 描述「critical-rules 21.6 五子条」，但条款实际为 21.6.1-21.6.6（六子条）；SP-04 仅断言 `21\.6\.[1-5]`，21.6.6 无守护（仓库惯例 RF-02/CP-02 均锁全子条）— registry 改「21.6.1-21.6.6」或注明「核心五子条+21.6.6 扩展未锁」；如需守护 21.6.6 则将 SP-04 扩为 [1-6]。
- [P2] `skills/task-planner/references/split-pattern-library.md`（末行 + :120-121）— (a) 文件无结尾换行（git 报 `\ No newline at end of file`）；(b) 伴飞映射表末行（:120）与 `## 未吸收登记`（:121）之间缺空行，仓库其他 references/*.md 表格后接标题均留空行 — 补尾换行 + 补空行。

## files
只读 none（未修改任何审查对象文件）

## evidence
- 路径存在性：伴飞映射表 7 条 SKILL.md 绝对路径 `[ -f ]` 全部 OK（writing-plans/dispatching-parallel-agents/brainstorming/subagent-driven-development/sub-agent-protocol/writing-skills/alignment-review）；来源技能总表 8 条亦全 OK；SKILL.md References 新行目标 `references/split-pattern-library.md` 存在。
- 计数：`grep -c '^### P' references/split-pattern-library.md` = 11；`grep -rn '10 模式'` 命中 `critical-rules.md:161` + `SKILL.md:354`（2 处）；`grep '11 模式'` 命中 `selftest-registry.tsv:64`。
- 规则互引：59.2=技能伴飞（伴飞注入任务书 §2+首动作 Read，语义匹配 21.6.5）；59.3=执行前技能扫描（语义匹配 21.6.5「先查库表再全池」）；63.2=检索优先四步链（语义匹配 21.6.6「四步检索链」）——三编号均存在且语义匹配。
- 死引用扫描：`scripts/selftest-split-pattern-library.sh` 在 worktree 存在；`templates/subagent_dispatch.md` §2/§3 存在；kb §5④/⑤ 指向 plans/task-v150…/knowledge-brief.md §5 ④/⑤（存在）。无死引用。
- 新 selftest 实跑：`bash scripts/selftest-split-pattern-library.sh` → `Total: 13 PASS=13 FAIL=0`（exit 0）。
- 文风：`awk` 扫描 references/*.md 表格→标题缺空行仅命中 split-pattern-library.md:121；`tail -c 1` 末字节非换行。

## checkpoint
本文件 `/mnt/data/dev/task-planner-skill/plans/task-v150-split-skill-integration/subagent-state/20-alignment-S12.md`

## findings_written
已追加 `#### [sub:20-alignment-S12]` 2 行至 `plans/task-v150-split-skill-integration/findings.md` 末尾

## blockers
无

## confidence
高（跨载体一致性/引用有效性/规则互引/死引用四维均以机器可复现命令取证；P1 计数漂移与 CHANGELOG 缺失为第一手证据）
