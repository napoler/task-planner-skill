# P3-S2 executor checkpoint（主 SKILL.md 三处联动）

worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v096-template-auto-record
目标文件: skills/task-planner/SKILL.md

## 改前快照
- wc -l SKILL.md = 429（429 行）
- grep 基线（改前）：
  - `模板生命周期门控与沉淀` = 1（L262）
  - `| C22 |` = 1（L186）
  - `knowledge-brief` = 2（L300 索引行、L429 卫星段）
  - `Rules 1-3` = 2（L238 `（Rules 1-39）`、L291 `Critical Rules 1-39`）
  - `Rule 34` = 5
  - `模板选取门控与沉淀` = 1（L214 段标题，TL-15 锚）

三行原文（逐字符）：
- L186（C22 行）：`| C22 | attest 前 template_type 已过 check-template-type.sh 门控（逃生须披露，机器门承载）；命中 34.3 沉淀触发时已按 34.4 沉淀或登记不沉淀理由（沉淀判定人工） | ☐ |`
- L214（指针段）：`**模板选取门控与沉淀（Rule 34 — task-v074）**：attest 锁定前 check-template-type.sh 校验 template_type ∈ 白名单（variant/ 动态派生+general）；终验时命中 34.3 沉淀触发（同类第 2 次/类型空缺可泛化/用户点名）→ 按 34.4 提炼新 variant 模板入库+四点同步，防滥用见 34.5。完整条款见 \`references/critical-rules.md\` Rule 34。`
- L262（Rule 34 摘要行）：`- **Rule 34（P0）模板生命周期门控与沉淀**：选取门控(34.1)/四点同步(34.2)/沉淀触发(34.3)/沉淀流程(34.4)/防滥用(34.5)/机制(34.6)——attest 前 check-template-type.sh 校验 template_type ∈ 白名单（variant/ 动态派生+general）；命中沉淀触发→提炼新 variant 模板+四点同步；开关键 \`config.json#template_gate_enforce\`（默认 warn，详见 references/critical-rules.md Rule 34）`

## selftest-template-lifecycle.sh 锚通读结果
- L76: TL-14 `grep -q '^| C22 '` → 行首 `| C22 ` 格式必保
- L78: TL-15 `grep -q '模板选取门控与沉淀'` → L214 段标题必保
- L41: TL-01 断 critical-rules `^### 34 模板生命周期`（本 S-unit 不动）
- L80: TL-16 断 template-mapping.md（不动）
- 其他 selftest（task-boundary/knowledge-brief/batch-pilot）grep 无 C22 / Rule 34 摘要行锚（已核，0 命中）

## 34.7 条款对齐（WT/skills/task-planner/references/critical-rules.md）
- 34.7 已在 L319 落 WT（P3-S1 产出），三时点激活+全自动生成合约，执行侧=生成侧强制 34.5 双闸门。本 S-unit 联动表述与其一致。

## 改动执行（已完成）
1. L262 Rule 34 摘要行：`机制(34.6)` 后插入 `/模板感知(34.7 三时点激活+全自动生成)`；子串 `Rule 34（P0）模板生命周期门控与沉淀` 逐字符保全（改后 grep -cF = 1）
2. L186 C22 行：后半句改为 `命中 34.3 沉淀触发时已按 34.7 全自动生成（34.5 双闸门内置生成侧）沉淀或登记不沉淀理由（check-complete warn 兜底）`；行首 `^| C22 ` grep -c = 1（TL-14 锚在位），前半句 `template_type 已过 check-template-type.sh 门控（逃生须披露，机器门承载）` 逐字符保全
3. L215（新增行，原 L214 段后）：`**模板感知（task-v096）**：遇新类型任务时三时点主动激活（init-session [template-sense] 提示+计划区块预登记 → 终验全自动生成，34.7 全自动合约+34.5 闸门内置生成侧）；卫星 SOP 见 plan-template-kit。`

## 自验结果（改后）
- wc -l：429 → 430，净增 +1 ≤ 3 ✅
- 锚差集对账（改前→改后）：
  - `| C22 |` 1→1；`^| C22 ` 1→1；`模板选取门控与沉淀` 1→1；`knowledge-brief` 2→2；`Rules 1-3` 2→2；`Rule 34` 5→5；`模板生命周期门控与沉淀` 1→1 ✅ 零丢失
  - 新增锚：`机制(34.6)/模板感知(34.7…)` = 1、`模板感知（task-v096）` = 1 ✅
- selftest 抽跑（全部 0 FAIL）：
  - selftest-template-lifecycle: Total 18 PASS=18 FAIL=0（TL-14/15 在位）
  - selftest-task-boundary: Total 11 PASS=11 FAIL=0（TB-11 PASS）
  - selftest-knowledge-brief: Total 16 PASS=16 FAIL=0
  - selftest-batch-pilot: Total 10 PASS=10 FAIL=0（BP-09 宽容锚子串保护 PASS）
- 仅动 1 文件（WT/skills/task-planner/SKILL.md）；未用 git；未触网
