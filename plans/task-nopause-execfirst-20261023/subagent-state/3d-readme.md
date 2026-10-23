# S4 检查点 — 文档纪元级联 1-95（README.md 5 处 + README_zh.md 2 处）

agent: general-coder (sonnet-1) | 任务: task-nopause-execfirst-20261023 S4
worktree: /mnt/data/dev/task-planner-skill-worktrees/task-nopause-execfirst-20261023

## 路径勘误（重要）
派发路径 `<wt>/README.md` 不存在（worktree 内无顶层 README.md；master 已删除，仅 main 分支存旧版无目标 token）。
依计划冻结清单（task_plan.md:204 CA-7 / 1-explore.md:93-97 / 1-explore.md:167 源=skills/task-planner/{SKILL.md,references/critical-rules.md,README.md,docs/ARCHITECTURE.md}）
确认目标文件 = `<wt>/skills/task-planner/README.md`：5 处 token 精确落在派发所述行号 4/36/81/123/127，逐字匹配。
故本检查点中「README.md」= `<wt>/skills/task-planner/README.md`。

## 逐处变更（7 行）

### README.md（= skills/task-planner/README.md）
1. L4 `77 条非核心规则` → `78 条非核心规则`（同 77→78）
   附：同行尾注释 `dedup=76（+Rule 94 → 77）（全集…` → `dedup=76（+Rule 94 → 77，+Rule 95 → 78）（全集…`（最小追加；`（全集 14+77=91…）` 历史值按指令未动）
2. L36 `│ Rules 1-94 全集索引：核心在位 14 条` → `│ Rules 1-95 全集索引：核心在位 14 条`（边框对齐空格保留）
3. L81 `Rules 1-94 全集索引：**核心在位 14 条**` → `Rules 1-95 …`；同句 `其余 77 条` → `其余 78 条`
   注：同行 dedup 注释 `dedup=76（+Rule 94 → 77）` 属冻结清单未列项（1-explore.md:95 仅记 2 token）→ 未动
4. L123 `核心域 14 条规则全文+Rules 1-94 全集索引` → `…Rules 1-95 全集索引`
5. L127 `[critical-rules-discipline 等 77 条非核心规则 → …]` → `等 78 条非核心规则`

### README_zh.md（= <wt>/README_zh.md）
6. L136 `← Rules 1-94 核心执行约束` → `← Rules 1-95 核心执行约束`（尾随历史演进链 `…Rules 1-93→1-94` 一字未动）
7. L229 `| … | Rules 1-94 —— 自定义前必读` → `Rules 1-95 —— 自定义前必读`（尾随历史演进链一字未动）

## 自验（命令 + 关键输出）
- `grep -n "1-94" skills/task-planner/README.md` → 无输出，exit=1（live 残留=0）
- `grep -n "1-94" README_zh.md` → L136、L229 各 1 处，均位于历史注释链 `Rules 1-93→1-94`（历史；按硬约束③零改动）→ live 残留=0
- `grep -c "1-95" skills/task-planner/README.md` = 3（L36/L81/L123，≥3 PASS）
- `grep -c "1-95" README_zh.md` = 2（L136/L229，≥2 PASS）
- `grep -n "78 条" skills/task-planner/README.md` = 3（L4/L81/L127，≥2 PASS）
- `git diff --stat README_zh.md skills/task-planner/README.md` → README_zh.md 4 ++--；skills/task-planner/README.md 10 +++++----；合计 7 insertions/7 deletions（=7 目标行，零越界改动）
- `git status --short` → 本任务仅触及 README_zh.md、skills/task-planner/README.md（其余 M=SKILL.md/CLAUDE.md/companion agents 系并行子代理产出，非本 agent 范围）

## 遗留风险
1. README.md L4 注释 `（全集 14+77=91，77/78/79 废弃不计）` 未随动（指令要求最小追加）；如父级要求算式自洽需再改该片段（当前 14+78=92）。
2. README.md L81 同行 dedup 注释保持 `+Rule 94 → 77`，与 L4 已更新的 `+Rule 95 → 78` 存在同文档不一致；冻结清单未列故未动，供父级裁决。
3. 未 git add/commit（遵指令）。
