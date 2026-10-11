# 02-explore-anchors（task-v129 · Explore B 锚点取证 · 只读）
> status: complete · 全程只读，本检查点为唯一写入豁免。取证时点 2026-10-04。

## 核查项1 — 并行撞号（v124/v125/v127 对照）
- **v125 占用 Rule 50**：/mnt/data/dev/task-planner-skill/plans/task-v125/task_plan.md:5 标题「执行体专业化优先与覆盖矩阵（Rule 50 + 三登记面修复）」；Goal（:12）=Rule 50 四子条（50.1-50.4）+ agent-coverage.md + selftest-agent-coverage.sh；worktree=task-v125。frontmatter :2 注「Rule 49 执行体专业化优先」与正文 Rule 50 表述不一致（模板注滞后）。
- **v127 也目标 Rule 50**：/mnt/data/dev/task-planner-skill/plans/task-v127/task_plan.md:136「派 plan-writer 按 rule-enhancement variant 撰写正式 task_plan.md（Rule 50 权重分级评级）」；progress.md:387 行 1 取证行「最后 Rule=48(:504)；…PT-08/CD-11/RT-08 三锚需为 Rule 50 扩口径」。
- v124：/mnt/data/dev/task-planner-skill/plans/task-v124/task_plan.md:11 Goal=媒体 agent 执行体（image/video-generation-executor）+ selftest-media-agents.sh，**不动 critical-rules.md 编号**（scope_files :21 无 critical-rules.md）。
- 仓内 master critical-rules.md 现有最大 Rule=49（### 49 @506）。**结论：Rule 50 不空闲——v125 与 v127 双占，v129 新条款应取 Rule 51（或待主进程裁决 50/51 归属后顺延）**。

## 核查项2 — 技能本体与部署对账
- 仓内本体：/mnt/data/dev/task-planner-skill/skills/task-planner/（SKILL.md、references/、scripts/、templates/、companion/、config.json 等）。
- `diff -q` 仓内 vs /home/terry/.zcode/skills/task-planner/：SKILL.md **IDENTICAL**、references/critical-rules.md **IDENTICAL**、templates/delivery-summary.md **IDENTICAL**（BOTH_IDENTICAL+TPL_IDENTICAL 全过）。
- 部署位脚本数：/home/terry/.zcode/skills/task-planner/scripts/selftest-*.sh = **45**（与仓内一致）。

## 核查项3 — critical-rules.md 锚点（仓内版）
- 总行数：**520**（wc -l）。
- 各 Rule 标题（`### N` 格式）：45 @455、46 @474、47 @484、48 @496、49 @506。
- 子条行号：47.1/47.2/47.3/47.4 @488/490/492/494；48.1-48.5 @500/501/502/503/504；49.1-49.5 @512/514/516/518/520。
- Rule 49 块（506-520）=**15 行**，为文件尾块，49.5 @520 即末行，Rule 49 后无内容。
- 新条款追加落点 = 521 行起（纯增量，Rule 36.5 范式）。

## 核查项4 — SKILL.md 锚点（仓内版）
- 总行数：**449**（wc -l，与 selftest 断言 449 一致）。
- frontmatter 全集「1-49」@**9**；Rule 47 bullet @**283**；Rule 49 bullet @**285**（Rule 48 无独立摘要 bullet——Rule 48 联动走交付总结段括注 @158，48.5 明示模板承载）；合规清单末项 **C34 @200**（Rule 49 消费，C33 @199）；`grep -n 'Rules 1-39'` 命中 2 处：**248**（`（Rules 1-39（含 Rule 40/41/42/43/44/45/46/47/48））`）与 **308**（References 表行尾括注，已含至 Rule 49 短语）。
- 行数定数断言：/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-skill-split.sh **:41** 原文：
  `t "T-主 行数 ≤449（task-v126 Rule 49 联动 +2;演进 440→442→444→447→449）且 ≤558 上限" bash -c "[ \"\$(wc -l < '$SKILL')\" -le 449 ] && [ \"\$(wc -l < '$SKILL')\" -le 558 ]"`
  → 本任务若给 SKILL.md 净增 ≥1 行，须将 :41 断言 449→450（演进链续写）；净增 0 行（行内替换）则不动。硬上限 558 不变。
- 参考插入点（v126 progress.md:73 先例）：SKILL:9 frontmatter 全集 / SKILL:285 后插新 bullet / SKILL:308 References 括号追加 / C34 后插 C35 @201 / 执行循环 2.5 @85 行尾括注。

## 核查项5 — selftest 体系
- 脚本数：**45**（ls scripts/selftest-*.sh | wc -l，仓内=部署位均 45）。
- 登记处：/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/**selftest-registry.tsv**（46 行=表头+45 脚本；`grep -rl 'selftest-lane-advancement'` 命中该文件 **:46** 行 + 脚本自身）。新 selftest 守卫须追加 1 行至此表。
- 全量回归：**无独立 run-all 入口脚本**——惯例=主进程 for 循环逐脚本跑并读 Total 行求和（v126 progress.md:75/100 实证口径）。scripts/ 下 run/all/regress 命名文件不存在（allow-direct.sh/subagent-fallback.sh 非回归入口）。
- 基线 688 出处：/mnt/data/dev/task-planner-skill/plans/task-v126/findings.md:77「基线真实 688=666+22 漏计，688+14 新增=702 自洽」；**当前 master 基线=45 脚本 702 PASS / 0 FAIL**（v126 verification.md:136 + progress.md:100）。新脚本入册后回归目标=702+新断言数。

## 核查项6 — 需求覆盖现状（部署位）
- grep '需求' /home/terry/.zcode/skills/task-planner/scripts/check-complete.sh：**零命中** → 终验门 check-complete.sh 目前**无需求覆盖门控**（无 R→VC 映射/covered 核对逻辑）。
- /home/terry/.zcode/skills/task-planner/templates/delivery-summary.md：wc -l=**67**；区块标题（grep '^#'）：# Delivery Summary @24；## 1. 任务说明 @28；## 2. 产出清单（文件级） @35；## 3. 审查信息 @42；## 4. 风险点 @52；## 5. 下一步建议 @60。需求覆盖核对区块可插在 1（任务说明）内或 2 与 3 之间（Rule 48.5 范式=模板承载+SKILL 括注）。

## 核查项7 — 备选挂靠点行号（仓内 critical-rules.md）
- 22.3 主体 @**158**（+22.3.0 @159 / 22.3.0b @160 / 22.3.1 @161 / 22.3.2 嵌 @161 / 22.3.3 @162）
- Rule 35 标题 @**330**（子条 35.1-35.7 @332-338）
- Rule 43 标题 @**439**（43.1-43.4 @443/444/445/446）
- Rule 47 标题 @**484**（47.1-47.4 @488-494）

## 特别回答速览
① Rule 50 **不空闲**（v125+v127 双占）；② SKILL 行数断言=scripts/selftest-skill-split.sh:41（≤449 且 ≤558）；③ 全量=主进程 for 循环（45 脚本，基线 702 PASS）+新脚本登记 selftest-registry.tsv；④ 仓内 vs 部署位 SKILL.md / critical-rules.md / delivery-summary.md 全部 IDENTICAL。

## 风险/开放项
- Rule 50 双占（v125/v127）：v129 新条款编号建议 **51**（或主进程裁决 50 归属后定）；若 v125/v127 任一先合并，51 仍安全。
- SKILL.md 净增行数触发 :41 断言级联（v126 已知 447→449 链）；若走 v124 式「净增 0 行」路线可免级联。
- check-dispatch KQ 系关键词（brief §4.3）：新条款若触碰派发契约需同步 check-dispatch.sh 检测词——本任务（完成声称门控）预期只动 check-complete.sh 面，低摩擦，执行期验证。
- 部署 3 位口径：仓内 + /home/terry/.zcode + claude 位（v125 VC-5 口径「merge + 3 位 IDENTICAL」），执行期对账。
