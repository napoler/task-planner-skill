# Delivery Summary — task-v170 计划完成后归档机制（Rule 81+archive-plan.sh+存量全归档）

## 1. 任务说明

用户发现 task-planner 技能「执行完任务之后缺失归档步骤」——所有计划文档用完后不归档，plans/ 根目录堆积约 110 个已完成目录（严重缺陷）。本任务补齐「完成→归档」机制并把存量全部归档。用户原话三条（R1-R3）逐字见 `plans/task-v170-archive-completed-plans/task_plan.md`「🎯 用户需求原文」。

## 2. 产出清单

| # | 产出 | 位置（绝对路径） | 一句话说明 |
|---|------|------------------|------------|
| 1 | archive-plan.sh（新脚本 213 行） | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/archive-plan.sh | 归档执行体：单任务/--batch/--dry-run/--root；守卫 fail-closed（active 指针全局+side、.session-owner mtime<24h、Status 全 complete 且>0 行）、已在 archive 幂等放行；git mv/mv 兜底 |
| 2 | SKILL.md 终验段接线 | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md:185 | 完成流程末段（check-complete exit 0 后）新增「计划归档（Rule 81.1）」步骤，含幂等与守卫拒绝处置 |
| 3 | Rule 81 正文 | /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md:1049 | 六子条：触发点/命令形态/安全守卫/联动/存量治理/机制 |
| 4 | [ARCHIVE-GATE] | /mnt/data/dev/task-planner/skills/task-planner/scripts/check-complete.sh:1606-1660 | check-complete 新增 warn 段：completed 未归档计数提醒，恒 exit 0 不破坏既有语义 |
| 5 | 引用面适配 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/{sync-todos.sh:158, resolve-plan-dir.sh:129, set-active-plan.sh:239-243} | archive 子目录不进 INDEX/forward_sync/活跃解析/gc 扫描 |
| 6 | selftest-archive-plan.sh | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-archive-plan.sh | 16 断言守护（CLI/守卫五类/幂等/批量计数字/git mv 与 mv 双路径） |
| 7 | 存量归档（数据面） | /mnt/data/dev/task-planner-skill/plans/archive/（123 目录） | 本任务归档 102 个 completed 计划（试点 v055+批量 101），commit 1bd3d3d；根目录仅剩 14 个在途/异常目录 |
| 8 | 合并与部署 | master merge 41e62f6 | 三部署位（~/.zcode/~/.claude/opencode）与主仓 diff=0 IDENTICAL |

## 3. 审查信息

- **Code Review Gate**：code-reviewer 五维全量审查（034）→ CHANGES_REQUESTED×1 blocker（[ARCHIVE-GATE] `_ag_ptr_hit` 跨迭代泄漏致计数假阴性，复现 expected 2 got 0）→ fix-phase de1eed1（:1626 复位）→ 复评（036）4/4 **APPROVED**，复评员独立全量复跑 `Total: 78 PASS=78 FAIL=0`。
- **全量回归**：合并态终跑 `Total: 79 PASS=79 FAIL=0`（run=79 reused=0 纯实跑）+ smoke 17/0；期间 Round 1 曾 FAIL=15（epoch 级联族）经 g-cascade/g-cascade2 两轮共 18 个定点单元清零，全程有 base 快照对照实证归因。
- **漂移检查**：6 次 drift-check（003/005/033/039+过程级）全部 ALIGNED 或机械项当次修复，留痕三件套齐全（ledger tick 1-12）。
- **委派统计**：5/8=0.625，主进程直做三项全命中 Rule 25.3 白名单（②计划系统维护/①git 编排）→ WHITELIST-EXEMPT，stats verdict=ok。

## 4. 风险点（必须列举）

1. **epoch 级联面广**：Rule 81 落地触发 17+ 个 selftest 的纪元断言扩围（历史上第 N 次同类级联），本次两轮定点修完并负样本验证（82/90 不放开）；后续每落地新 Rule 仍会复现该级联面——已由 selftest 自登记机制部分缓解，但根 отеры未消除（仅登记不重构）。
2. **v152 归属判定**：task-v152-proactive-context 的 .session-owner 陈旧（>24h）+ Status complete + 无 active 指针，按守卫 TTL 设计归档；其 attestation 的并行会话未提交修改内容随 mv 保全于 archive 副本（delete+add 对已入 commit 1bd3d3d），如需回退可 git revert。
3. **v162/v166 归属**：v162（untracked、owner 35h 前、complete）与 v166（checkpoint 032 后 side 指针被其会话清除）按守卫成为候选并归档——若对应会话实际未结束，可 mv 回根目录（内容无损）。
4. **过程事故（已闭环）**：S2 探针未加 --dry-run 曾误归档主仓 task-v060，当次恢复并经主进程独立核验干净（git status 该目录零变更）；教训已入进度 Error Log 与 notepad 通用规则。
5. **本计划自身**：check-complete 终跑通过后本目录将自归档入 plans/archive/task-v170-archive-completed-plans/（机制自举实证），届时本总结随目录一并移入。

## 5. 下一步建议

1. 新会话冒烟验证「完成→归档」闭环：任一任务结束后确认 SKILL.md:185 步骤被执行（archive-plan.sh 输出 ARCHIVED/ALREADY_ARCHIVED），观察项=根目录 completed 数不再增长。对象：`bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/archive-plan.sh --batch --dry-run --root /mnt/data/dev/task-planner-skill/plans`（看点=候选应仅剩新完成任务）。
2. 向用户报告一件事（非本任务 scope）：`plans/task-v168-session-anchor-skill-activation/task_plan.md` 在 attest 锁定（a35c941f…，21:55:55）后约 7 分钟被改（现 dc600b0b…，22:02:47）且未重 attest——hook [PLAN TAMPERED] 判定准确；请该会话按 Rule 51.7 登记 Decisions 后重锁或回滚。证据：`sha256sum` 与 `.plan-attestation` 比对。
3. 遗留卫生债（非本次引入，仅登记）：并行会话未提交的 plans/INDEX.md、plans/.rule-reservations.jsonl、v152/v160 两个 .plan-attestation 变更仍在工作区未提交；以及 wt/task-v168-machine-parked 封存分支的最终去向待用户裁决。
