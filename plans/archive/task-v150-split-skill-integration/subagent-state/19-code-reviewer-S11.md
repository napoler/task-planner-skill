# 19-code-reviewer-S11 · Code Review（task-v150 worktree diff master...HEAD）

VERDICT: CHANGES_REQUESTED

## status
done

## acceptance
VERDICT: CHANGES_REQUESTED

逐条问题清单（文件:行 — 问题 — 建议修法）：

- [🟡 P1] `skills/task-planner/references/critical-rules.md:161` — Rule 21.6 导语写「10 模式+伴飞映射库」，但库实际 11 个 `### P`（P1-P11），registry:64 与 SP-02 均冻 11 — 改「11 模式」（或「P1-P11」）。
- [🟡 P1] `skills/task-planner/SKILL.md:354` — References 表新行「拆分模式库（Rule 21.6）：10 模式+伴飞映射表」同上不符 — 改「11 模式」。
- [🟡 P2] `skills/task-planner/scripts/selftest-split-pattern-library.sh:42`（SP-04）— 仅断言 `21\.6\.[1-5]`≥5，未锁 21.6.6；删 21.6.6 守卫仍 PASS（Phase-4 头号交付物无守护）— SP-04 扩为 `[1-6]`≥6，或新增 SP-14 专锁 21.6.6。
- [🟡 P2] `skills/task-planner/scripts/selftest-split-pattern-library.sh:28`（SP-03）— 守卫阈值 ≥7 严于条款 21.6.5「≥6 行」(critical-rules.md:166)，后续合规裁剪至 6 行会误报 FAIL — 阈值对齐 21.6.5 改 ≥6（或同步上调 21.6.5 文案）。
- [🟡 P2] `skills/task-planner/references/critical-rules.md:170` + `references/split-pattern-library.md:121` — 引「（53.3 二分）/（53.3 管辖二分）」，但 53.3=「决策管辖二分（反推诿）」，语义为用户 vs 代理决策管辖，非「Rule 21 vs Rule 22」规则域管辖 — 去 53.3 编号改直述边界，或改引他锚。
- [💬] `skills/task-planner/references/critical-rules.md:170` — 机制句「断言清单见 kb §5④」将永久条款指向 transient plan-dir 工件（kb 会归档）；59.6 惯例为内联断言清单 — 内联断言要点或指向脚本自身头注释。
- [💬] `skills/task-planner/SKILL.md:215` — 新增 `| C43a |` 行缺 Rule 引用与机器面/mini 豁免结构（C30-C44 均有），且 C43a 子编号无先例；21.6 亦未声明 C43a 为消费点 — 补齐 Rule 21.6.1 引用+机器面，或并入 C43。
- [💬] `skills/task-planner/references/split-pattern-library.md`（末行/:120-121）— (a) 文件无结尾换行（git `\ No newline at end of file`）；(b) 伴飞表末行(:120) 与 `## 未吸收登记`(:121) 之间缺空行 — 补尾换行+补空行。
- [💬] `skills/task-planner/references/split-pattern-library.md:96` — P10「模型四档路由」只枚举 3 个映射（机械/集成判断/架构设计），数与列不符 — 补第 4 档或改「模型分档路由」。
- [💬 跨面] `CHANGELOG.md` — task_plan.md:49/95 声明 CHANGELOG 追加 1 条目为交付物，但 worktree diff 与 CHANGELOG 均无 task-v150 条目（可能留待 Phase 6）— 合并前补条目或登记豁免。

通过项（负结果）：13/13 自测全 PASS exit 0；P1-P11 五要素格式逐条齐全（各 5 项）；伴飞表 7 路径 + 来源总表 8 路径 `[ -f ]` 全部存在；63 脚本全量回归仅 selftest-periodic-review.sh FAIL 且与 master 逐字一致（已知基线，与本 diff 无关）；无安全面（无 eval/无用户输入插值/无凭据）。

## files
none

## evidence
- 计数漂移：`grep -n '10 模式'` → critical-rules.md:161 + SKILL.md:354；`grep -n '11 模式'` → selftest-registry.tsv:64；`grep -c '^### P' references/split-pattern-library.md` = 11。
- 守卫缺口：`grep '21\.6\.6' scripts/selftest-split-pattern-library.sh` → 无命中；SP-04 行 42 用 `21\.6\.[1-5]`。
- 阈值不齐：critical-rules.md:166「（≥6 行,绝对路径）」vs selftest-split-pattern-library.sh:28「伴飞表 ≥7 数据行」。
- 引用语义：critical-rules.md:170「（53.3 二分）」；split-pattern-library.md:121「## 未吸收登记（53.3 管辖二分）」；critical-rules.md:605「53.3 **决策管辖二分（反推诿）**」。
- 机制句 transient 指针：critical-rules.md:170「断言清单见 kb §5④」。
- C43a 行：SKILL.md:215「| C43a | 拆分前已查模式库 split-pattern-library | ☐ |」。
- 尾字节/空行：`tail -c 1 ...split-pattern-library.md | xxd` → 0x93（无 LF）；`sed -n '119,122p' | cat -A` 显示 :120 表行紧接 :121 `## 未吸收登记`。
- P10 映射数：split-pattern-library.md:96「模型四档路由=机械任务→廉价模型 / 集成判断→标准模型 / 架构设计→最强模型」。
- 回归：`for s in scripts/selftest-*.sh; do bash $s; done` → 仅 periodic-review rc=1，master 同脚本同输出（diff 一致）。

## checkpoint
/mnt/data/dev/task-planner-skill/plans/task-v150-split-skill-integration/subagent-state/19-code-reviewer-S11.md

## findings_written
已追加 `#### [sub:19-code-reviewer-S11]` 2 行至 plans/task-v150-split-skill-integration/findings.md 末尾

## blockers
无（2 处计数漂移为 P1 级交付缺陷，但不阻断自测；建议合并前修复）

## confidence
高（跨载体计数/守卫阈值/引用语义/回归四维均以机器可复现 grep/实跑取证；P1 计数漂移为第一手证据；53.3 语义判定为文档语义判断）
