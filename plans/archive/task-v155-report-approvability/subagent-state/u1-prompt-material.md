# U1 材料包：SKILL.md + critical-rules.md 合并冲突并集解细则

## 背景
worktree `/mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability` 处于 `git merge master` 冲突态。master 含并行任务 v152(Rule 67)/v153(Rule 68)/v154(Rule 69) 的落地。本单元只解两文件冲突块，其余 4 个冲突文件（registry/research-first/skill-split/goal-unit）禁碰。禁止 git add/commit。

## SKILL.md（3 冲突块）
1. **合规清单表**（约 :227）：并集排列=master 侧 C46(Rule 68 行)、C47(Rule 69 行)在前，本任务(HEAD)C46 行**改号为 C48**（内容=Rule 70 呈报可审批性）在后。三行表格 `|` 列数一致。
2. **「## Critical Rules」段首行**（约 :296）「详见 `references/critical-rules.md`（…）」：并集文本为
   `详见 \`references/critical-rules.md\`（Critical Rules 1-69+70（含 Rule 40-69 全集 + Rule 70 用户呈报可审批性纪律，67-69 已由并行任务落位）`
   （把原「67-69 并行任务预留」改为落位表述；该行后续规则名列表原文保持不动）
3. **Rule 摘要 bullets**（Rule 66 行后）：master 的 Rule 68、Rule 69 两 bullet 在前，本任务 Rule 70 bullet 在后。
4. **同文件另两处索引口径**（非冲突但需同步）：:9 顶部 references 索引行与 :369 References 表行的「1-66+70」→「1-69+70」（其余文字不动）。

## critical-rules.md（1 冲突块，66.x 段后）
- 并集顺序：master 侧（### 68 …、### 69 … 及各自子条块）在前，本任务侧（`## Rule 70（用户呈报可审批性纪律 — task-v155）` 整块，含 70.1-70.6）在后，形成 66.x → 68.x → 69.x → Rule 70 数值升序。
- 先 Read 确认 Rule 67 是否已在文件内（master 已落地 v152 时两卷可能已同含，无冲突即无需动）。
- 移除全部冲突标记（`<<<<<<<` / `=======` / `>>>>>>>`），两侧正文一字不改。

## 验收
- 两文件 grep `^<<<<<<<` 均 0；
- SKILL.md `1-69+70` ≥3；`| C46 |`/`| C47 |`/`| C48 |` 各 =1；Rule 68/69/70 摘要 bullet 各 ≥1；
- critical-rules.md `^### 68 `、`^### 69 `、`## Rule 70` 均 ≥1，70.1-70.6 六子条完整；
- git status 这两文件脱离 U 状态（其余 4 个冲突文件保持原状禁动）。
