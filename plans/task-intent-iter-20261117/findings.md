# Findings — task-intent-iter-20261117

## 现状与根因定位
- 判例对齐：用户明确“模板体系升级”却被带偏去无关调研，暴露指令理解/方向对齐在执行前不足（user-session-log #1）。
- 既有机制：80.7 理解镜像（落档配对，非对话展示）、D1 目标绑定复述（SKILL:83）、28.2.1 执行思路复述（计划摘要，≤5行，ask D1 前）、Plan Writer 计划期复述+需求分析（SKILL:50-59）。
- 缺口：无“原始指令→理解→思路/候选→大体方向”3-4轮渐进、用户可见、可早纠偏的制度化模块；且缺“明确任务免无价值确认、歧义/多候选才确认”的显式歧义门控（user-session-log #2/#3）。

## 改进落地（推荐方案 A）
- 新增 Rule 28.2.2（discipline）：3-4轮理解迭代草稿+歧义门控；明确免阻塞确认、歧义/多候选(典型3-4)或关键范围不明才选项确认（28.3）；silent/goal/44.3/mini 降级留痕与推荐项自决，D6/不可逆/真分叉硬停不豁免；与 28.2.1/80.7/51.1/109/反造谣边界明确。
- 接线：SKILL.md 新指令收口序列增加步骤③（理解迭代+模式分支）、计划确认增加“指令理解对齐(28.2.2)”与歧义门控说明、I/O 契约纳入；core critical-rules Rule 1 补充 28.2.2 前置。
- 承载与一致性：task_plan 模板新增“指令理解迭代草稿”区块；user-session-log 模板补 28.2.2 留痕提示；config interaction_mode 描述同步。
- 守护：selftest-interaction.sh 新增 TI-14（28.2.2 + 歧义门控/3-4轮/discipline+SKILL+core+config 锚）并通过（14/14 PASS）。

## 验证
- `bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-interaction.sh` → Total 14 PASS=14 FAIL=0 EXIT:0
- `python3 -m json.tool skills/task-planner/config.json` → JSON_OK
- 关键锚点 grep：28.2.2/歧义门控 在 discipline/SKILL/core 命中。
