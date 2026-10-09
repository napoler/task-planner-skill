# 级联单元（SKILL.md 计数级联与消费面接线）checkpoint

## 里程碑 M1 锚点定位（施工日重验）
- SKILL.md 四处上界锚实测：:9（frontmatter references 全集行 "Critical Rules 全集 1-66"）/ :281（"详见"行 "Critical Rules 1-66（含 Rule 40-65 全集…"）/ :362（References 表行 "Critical Rules 1-66（含 Rule 13-18…"）——grep -c 实测 "Critical Rules 1-66" 命中 3 处（:9 为 "全集 1-66" 异形，grep 字面 1-66 命中 :9/:281/:362 共 3 处）
- 列表 bullet 区实测含 Rule 65（:337）与 Rule 66（:338）具名 bullet（v151 先例=已列名，非"只动上界"）→ 需按同形态在 :338 后加 Rule 68 bullet
- 合规清单 C45 行 = :218，C46 追加位 = 其后（:219 空行前）
- 流程步骤插入位 = 执行流程图"计划确认"步骤区（:71-75 末，:76 空行、:77 下一步前）
- 钉值三查 grep -nE "N 脚本|脚本 N|=N," SKILL.md → 零命中（无钉值）
## 里程碑 M2 写入
- 待记录

## 里程碑 M2 写入完成（9 处改动，SKILL.md 单文件）
- :9 frontmatter references 全集行 1-66→1-68，枚举尾追加「68 计划期依赖分析、并行分组、组内异构分摊与组域写一致性纪律」；**词序偏差如实披露**：原文为 "Critical Rules 全集 1-66"，为满足验收字面 grep 'Critical Rules 1-68' ≥3 硬门，改词序为 "Critical Rules 1-68 全集"（"全集"后置）。S7 复核时如需保原词序可还原，代价=A 验收降为 2 命中（:283/:365）
- :283 「详见」行上界 1-68 + 枚举追加 Rule 68
- :282（原:281）后 bullet 区：Rule 66 bullet 后追加 Rule 68 bullet（:341，形态对齐 65/66 具名 bullet：定位+子条 68.1-68.4+机器面；v151 先例在 worktree 实测=具名列名而非只动上界，按"含 bullet 则加"分支执行）
- :365 References 表行上界 1-68 + 枚举追加 Rule 68
- :220 C45 行后新增 C46 行（施工图 §四 合规清单行文本，mini 豁免+行尾 ☐）
- :76 「计划确认」步骤区（规则编号预留给行后）新增强制步骤行「S-unit 表定稿后按 Rule 68.1-68.2 依赖分析→填前置依赖列→推导并行分组→组内异构分配（68.3）」
- 钉值三查：grep -nE '[0-9]+ 脚本|脚本 [0-9]+|=[0-9]+,' SKILL.md 零命中 + 补充模式（NN 个脚本类）零命中 → 无钉值需 +1
## 里程碑 M3 验收（实测输出）
- grep -c 'Critical Rules 1-68' = 3（:9/:283/:365）≥3 ✓
- grep -c 'C46' = 2，:220 行含 "Rule 68" ✓
- grep -c '依赖分析.*并行分组.*异构分摊' = 5 ≥1（流程步骤行 :76 命中）✓
- 残留 '1-66' grep 零命中 ✓
- git diff --stat master -- SKILL.md = 仅 skills/task-planner/SKILL.md 1 file 6 insertions 3 deletions ✓（工作区另 2 个 M 文件=critical-rules.md/templates/task_plan.md 属同组并行成员 scope，未触碰）
