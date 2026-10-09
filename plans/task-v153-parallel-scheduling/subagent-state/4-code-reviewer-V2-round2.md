
#### [sub:CR2] 审查单元 V2 第二轮（fix-phase 复审）— 终局 APPROVED（2026-10-09）

**范围**：复核第一轮八项发现修复质量（修复A=check-plan-dispatch.sh / selftest-parallel-scheduling.sh / critical-rules.md；修复B=SKILL.md 枚举 / selftest-workflow-orchestration.sh / 三文档计数行）。审查基准=design-rule68.md；worktree 根=/mnt/data/dev/task-planner-skill-worktrees/v153-parallel-scheduling。

**客观验证（本轮亲跑，非转述）**：
- `bash -n` 守卫与 selftest 均 exit 0；全量 selftest 套件（scripts/selftest-*.sh）逐脚本 rc 检查 → 0 个非零退出。
- 真实计划（plans/task-v153-parallel-scheduling/task_plan.md，含 plan_tier: standard，S-unit 表含「并行组」列）跑守卫 → 零 Rule 68 violation，exit 0。
- 独立夹具正/负例复现（/tmp/cr2fixtures、/tmp/cr2neg）：见逐条结论。
- 未提交 diff 规模与两修复检查点声称一致：守卫 85+/15-、selftest-parallel 60 行变更、critical-rules 1+/1-、SKILL/CLAUDE/README_zh/skills-README/WF-selftest 各计数行。

**八项发现逐条复核（全部 fixed）**：
1. 原 MAJOR（组标记消费口径不一致）→ fixed。新增注解形态兜底 `rule68_g="${rule68_ann_grp[...]}"`（check-plan-dispatch.sh:584；解析器 520-556）；规则=行内标记>「并行组」列>注解。夹具 /tmp/cr2fixtures/f1.md（无「并行组」列 + 注解行 `[parallel-group:gA] = 甲, 乙`，乙依赖甲）实测触发 `Rule 68.2: 依赖-同组矛盾…（hard H4）` exit 1；真实计划注解形态（task_plan.md:221）经映射后无假 H4。
2. 原 MINOR（awk 列位陈旧）→ fixed。遇非 S-unit 表头（^| ID | 无「执行体」）与空行即复位列位（check-plan-dispatch.sh:487、491）。夹具 /tmp/cr2fixtures/f2.md（S-unit 表紧接 Goal 表无空行）实测无假 H2。
3. 原 MINOR（P-04/P-09 双层 SOFT 自指）→ fixed。收敛硬断言（selftest-parallel-scheduling.sh:96、144）；`soft()` 助手已删且零残留引用。负例（删 SPL 的 P12 锚）实测 P-09 FAIL、Total 9/8/1、exit 1。
4. 原 MINOR（探针命中注释头）→ fixed。探针改锚可执行行（:91 `add_violation.*依赖-同组矛盾`；:92 `(echo|add_violation).*组内(全同|成员执行体全部为)`）。负例（保留注释头、删可执行代码行）实测 P-04 FAIL（hard 串 0 / advisory 串 0）。
5. 原 MINOR（悬空缩写 SK.md）→ fixed。critical-rules.md:872 现为 `dynamic-workflows SKILL.md:321-345`；grep `SK\.md` 零残留。
6. 原 MINOR（SKILL 枚举漏 66）→ fixed。SKILL.md:9 补入「66 goal 单元固化与 /goal 驱动推进纪律」（67 按 v152 在途预留不列名，符合 design §四）。
7. 原 MINOR（WF-10 计数锚钉 1-65）→ fixed。selftest-workflow-orchestration.sh WF-10 锚族改 1-68；实跑 WF-10 PASS（命中总和 10 ≥3，旧 1-39/1-45 残留 0），Total 16/16/0。
8. 原 MINOR（design §二 H2 裸管道承诺未落地）→ fixed。新增 F8 列数漂移检测（check-plan-dispatch.sh:502 `if (hdr_nf>0 && NF!=hdr_nf) drift=1`；:577 生成 hard F8 violation）。夹具 /tmp/cr2fixtures/f8.md 实测触发 `Rule 68.1: 行 … 列数漂移…（格式漂移/裸管道，hard F8）` exit 1。

**新 diff 增量发现（3 MINOR，无 BLOCKER/MAJOR）**：
- MINOR `skills/task-planner/scripts/check-plan-dispatch.sh:502` — F8 对合法转义管道误报。原文：`if (hdr_nf>0 && NF!=hdr_nf) drift=1`。awk `-F'|'` 不分「裸管道」与「转义管道 `\|`」，合法 markdown 转义 `\|` 仍被切分 → NF 虚增 → 误报 hard F8；design §二 H2 措辞仅指「裸管道」。夹具 /tmp/cr2fixtures/f8b.md（单元格 `a\|b` 转义形态）实测被误报 exit 1。建议：数据行切分前先剔除 `\|`（或统计前把 `\|` 归一为转义占位），仅对真裸管道报 violation。置信度：机制 HIGH / 实际影响 MEDIUM（本仓约定禁一切管道，暂无真实误伤）。注：该 awk 列位切分限制在 F8 之前已存在，F8 仅将其显式化。
- MINOR `skills/task-planner/scripts/selftest-registry.tsv:66` — 陈旧描述未随 fix A 同步。原文：`68 守卫段两段串（硬锚未落位 SOFT 降级）`（同段尾「模式库 P12 依赖分批并行（硬锚未落位 SOFT 降级）」同为陈旧）。fix A 已将 P-04/P-09 收敛为硬断言并删 `soft()`，registry 描述仍写 SOFT 降级。建议：两处「（硬锚未落位 SOFT 降级）」改为「（硬断言，2026-10-09 收敛）」。置信度 HIGH。
- MINOR `subagent-state/4-code-assistant-crfixB.md`（修复B检查点自述）— 验收声称与产物不符。原文：`grep -rn '1-65' CLAUDE.md README_zh.md skills/task-planner/README.md → 0 命中`。实跑 worktree 根同命令命中 skills/task-planner/README.md:72（该行由 fix B 自身新增，含演进注解「计数 1-65→1-68」，属描述性文字而非计数锚）。功能性无碍（计数锚已正确 1-68），仅检查点证据与产物不一致。建议：将 0 命中口径改为「计数锚 0 残留（演进注解含旧数属预期）」。置信度 HIGH。

**负结果**：未发现安全面问题（无注入/路径遍历/凭据）；无 API 破坏；无数据丢失/竞态（守卫只读解析，仅 standard/full 档执行，mini/legacy/无表整体跳过）；既有回归零失败（全量 selftest 非零退出=0）；F1 注解解析未在本计划引入假组归属（真实计划零误报）。

**终局 verdict：APPROVED**（八项发现全部 fixed，新 diff 仅 3 处 MINOR 文档/边界收口项，无 BLOCKER/MAJOR）。
