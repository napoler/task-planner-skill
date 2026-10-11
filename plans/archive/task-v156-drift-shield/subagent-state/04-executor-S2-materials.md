# S2 单元材料包（Rule 35.3 落盘补救 — prompt 超限拆分）

> 本文件=task-v156 Phase 3 第二单元（SKILL 接线+模板 🔒 区块）的逐字采用源。执行体第一步 Read 本文件+design-draft.md §3/§6。

## A. templates/task_plan.md「🔒 不变量声明区」区块（逐字采用，插在「## 🧮 根源覆盖表」段后、「## Goal」段前）

```markdown
## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
<!-- WHAT: 任务要素显式分三态——不变量(锁)/可变量(自主调+登记)/学得量(只入 findings、禁反写不变量)。
     WHY: 用户 R2「强化四文件，确保哪些不变/哪些可变/哪些学得」；无声明=执行期风格/范围漂移无对照物（R1 实证）。 -->
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | <Goal/VC 表/用户需求原文 R 条目/风格与质量约束，逐条列> | <task_plan.md 对应章节锚> |
| 🔀 可变量 | <执行细节/工序排期/工具选型/S-unit 拆分> | - |
| 📈 学得量 | <执行期新事实/教训/锚点→findings.md/notepad-learnings.md；禁反向改写不变量> | findings.md |
```

## B. SKILL.md K1-K6 接线明细（master 现实态锚，均以内容 grep 定位、禁按行号盲改）

- **K1（:9 计数行，修存量漏改）**：现文「Critical Rules 全集 1-69+70（67-70 均经并行任务合流落地）」→ 改「Critical Rules 全集 1-71+73（67-71+73 均经并行任务合流落地）」。禁写「1-73」（v160 在途占 72，未合入）。
- **K2（:295 详见行）**：「Critical Rules 1-71（含 Rule 40-71 全集」→「Critical Rules 1-71+73（含 Rule 40-71+73 全集」，全集列举尾部补「、73 执行期决策对齐与不变量纪律」。
- **K3（:355 Rule 71 摘要 bullet 后新增一行，同款格式）**：
  `- **Rule 73（执行期决策对齐与不变量纪律 — task-v156）**：变更型决策点定义=改风格/范围/新需求/推翻结论/收口声称五类动手前必过对齐三问（73.1/73.2，[align] 留痕 progress.md）；三态标注=🔒不变量/🔀可变量/📈学得量+计划模板「🔒 不变量声明区」（73.3）；强制评判点=变更决策后/Phase complete 前/合并回前各一次 [judge] 留痕（73.4，check-complete [judge-gate]+posttooluse 节奏注入承载）；废弃只入不出=deprecated.md 隔离区+正常四文件禁混放（73.5）；消歧义=歧义词带解释层（73.6）；零新 config 键（env TASK_PLANNER_DECISION_JUDGE 降档）+selftest-decision-drift.sh 守护+C51 合规行（73.7）`
- **K4（:381 References 表 critical-rules 行）**：行首「Critical Rules 1-71（含…」→「Critical Rules 1-71+73（含…」，末部补「+Rule 73 执行期决策对齐与不变量纪律」。
- **K5（C 清单 :231 C50 行后新增 C51 行，同款表格格式）**：
  `| C51 | 执行期决策对齐自查（Rule 73）：变更型决策点已过 73.1 分类判定+73.2 对齐三问并留 [align] 行；Phase complete 前/合并回前已留 [judge] 评判行；🔒 不变量声明区块在位且三态分明；改动前已查 deprecated.md+notepad 双源（机器面=selftest-decision-drift.sh 静态断言+check-complete [judge-gate]，对齐过程人工核查；mini 档豁免） | ☐ |`
- **K6（两处一行引用）**：① SKILL.md「委派检查点（强制 — Rule 25）」段末加一行「- 变更型决策点（改风格/范围/新需求/推翻结论/收口声称）按 Rule 73.1 判定、73.2 对齐三问后再派发」；②「🆕 用户新指令处理（计划影响判定 — 强制）」段 D 类表格后加一行「- B/C 类变更执行前按 Rule 73.2 对齐三问（回读 🔒 不变量声明区+用户需求原文）并留 [align] 行」。

## C. 验收命令（完成后逐条跑，原文贴 evidence）

```bash
cd /mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment
grep -c "Rule 73" skills/task-planner/SKILL.md            # 预期 ≥4
grep -c "C51" skills/task-planner/SKILL.md                # 预期 ≥1
grep -c "1-71+73" skills/task-planner/SKILL.md            # 预期 ≥1
grep -n "🔒 不变量声明区" skills/task-planner/templates/task_plan.md  # 预期 ≥1
grep -c -e 不变量 -e 可变量 -e 学得量 skills/task-planner/templates/task_plan.md  # 三个关键词各 ≥1（分次 grep）
git diff --numstat                                        # 仅 SKILL.md+templates/task_plan.md，无既有行删除
```
