# Agent B Spec — Rule 100 条款落盘 + 纪元级联（1-99→1-100 / 82→83 条 / 49→50 条）

## 背景（自包含）
- 仓库：/mnt/data/dev/task-planner-skill（task-planner 技能源仓，主进程 cwd）
- 任务 task-crossprojauth-20261104 R2（2026-11-04 用户指令）：新增 Rule 100「临时目录统一与工作树内放纪律」并入纪律域，触发纪元级联：task-planner/SKILL.md `1-99`→`1-100`（3 处）、`其余 82 条`→`其余 83 条`（2 处）；task-discipline/SKILL.md `49 条`→`50 条`（3 处）+ 规则枚举 +100；两 selftest 脚本断言锚随动。
- 执行纪律：先 Read 目标文件 → 确认 old 原文存在且唯一 → Edit；old 不匹配时该处立即停止并在回报中登记「失配」，禁止猜测改写。只编辑本 spec 列出的 6 个文件；禁 git 操作；禁碰 AGENTS.md；**不改 SKILL.md 中 1-99 之外的任何规则内容**（最小写入）。

## 编辑清单（6 文件，逐项 old→new）

### F1. skills/task-discipline/references/critical-rules-discipline.md（追加 1 段）
Read 材料包 /mnt/data/dev/task-planner-skill/plans/task-crossprojauth-20261104/subagent-state/rule100-section.md（完整 `### 100` 段，100.0–100.5 子条）。
将该内容追加到 discipline 文件**末尾**（文件当前末行=99.6 段最后一行 `…判例锚=2026-11-04 用户指令（plans/task-crossprojauth-20261104/task_plan.md 用户原话行）。`），追加前保证空行分隔（末行后空一行再接 `### 100 …` 段头）。材料包内容逐字照搬，禁改写。

### F2. skills/task-discipline/SKILL.md（5 处）
1. L15 片段 old：`跨项目/跨目录操作授权纪律等共 49 条（全文见规则索引）。`
   → new：`跨项目/跨目录操作授权纪律、临时目录统一与工作树内放纪律等共 50 条（全文见规则索引）。`
2. L24 old 尾片段：`95,97,98,99）。`
   → new：`95,97,98,99,100）。`
3. L80 表行（`| 99 | 跨项目/跨目录操作授权纪律 | \`references/critical-rules-discipline.md\` \`### 99\` 段 |`）之后插入新行：
   `| 100 | 临时目录统一与工作树内放纪律 | \`references/critical-rules-discipline.md\` \`### 100\` 段 |`
4. L82 old 片段：`与 Rule 99（task-crossprojauth-20261104 跨项目/跨目录操作授权纪律）已后补落盘——本索引现共 49 条全文可消费。`
   → new：`与 Rule 99（task-crossprojauth-20261104 跨项目/跨目录操作授权纪律）与 Rule 100（task-crossprojauth-20261104-R2 临时目录统一与工作树内放纪律）已后补落盘——本索引现共 50 条全文可消费。`
5. L93 old：`— 49 条规则全文（含后补落盘的 Rule 85/86/87/88/89/90/92/93/94/95/97/98/99）`
   → new：`— 50 条规则全文（含后补落盘的 Rule 85/86/87/88/89/90/92/93/94/95/97/98/99/100）`

### F3. skills/task-planner/SKILL.md（5 处）
1. L9 old 片段：`Rules 1-99 全集索引（核心在位 1,2,3,5,19,20,26,51,62,66,80,81,82,83，含 Rule 82 分层纪律 + Rule 83 通道快速失败；其余 82 条按域归 11 卫星`
   → new：`Rules 1-100 全集索引（核心在位 1,2,3,5,19,20,26,51,62,66,80,81,82,83，含 Rule 82 分层纪律 + Rule 83 通道快速失败；其余 83 条按域归 11 卫星`
2. L197 old 片段：`变更吸收/跨项目跨目录操作授权（Rule 4,6,7,8,9,10,18,27,28,29,31,32,33,35,36,41-45,48,53-57,60,65,67,69-74,76,85,86,87,88,89,90,92,93,94,95,97,98,99）`
   → new：`变更吸收/跨项目跨目录操作授权/临时目录统一与工作树内放（Rule 4,6,7,8,9,10,18,27,28,29,31,32,33,35,36,41-45,48,53-57,60,65,67,69-74,76,85,86,87,88,89,90,92,93,94,95,97,98,99,100）`
3. L210 两处：old `Rules 1-99 全集索引：**核心在位 14 条**` → new `Rules 1-100 全集索引：**核心在位 14 条**`；old `其余 82 条已按域迁至上表 11 卫星（含 Rule 84 验证域、Rule 85/86/87/88/89/90/92/93/94/95/97/98/99 纪律域）` → new `其余 83 条已按域迁至上表 11 卫星（含 Rule 84 验证域、Rule 85/86/87/88/89/90/92/93/94/95/97/98/99/100 纪律域）`
4. L243 old 片段：`/上下文记录整理触发（Rule 98）/跨项目跨目录操作授权（Rule 99）**`
   → new：`/上下文记录整理触发（Rule 98）/跨项目跨目录操作授权（Rule 99）/临时目录统一与工作树内放（Rule 100）**`
5. L253 old：`Critical Rules 核心域 1-99 全集索引（14 条核心全文+分层架构说明+卫星路由索引）`
   → new：`Critical Rules 核心域 1-100 全集索引（14 条核心全文+分层架构说明+卫星路由索引）`

### F4. skills/task-planner/references/critical-rules.md（L194 行 2 处）
1. old 片段：`95,97,98,99）；调用条件`
   → new：`95,97,98,99,100）；调用条件`
2. old 片段（该行尾）：`/跨项目跨目录操作授权相关时。`
   → new：`/跨项目跨目录操作授权/临时目录统一与工作树内放相关时。`

### F5. skills/task-planner/scripts/selftest-anti-deferral.sh（断言+注释随动，共 6 处）
1. L13 old：`#   AD-09 SKILL.md 纪元字面 '1-99' ≥3（line9 指针行/line210 全集索引/line253 References 表）`
   → new：`#   AD-09 SKILL.md 纪元字面 '1-100' ≥3（line9 指针行/line210 全集索引/line253 References 表）`
2. L14 old 尾片段：`81→82：2026-11-04 task-crossprojauth-20261104 Rule 99 并入纪律域）`
   → new：`81→82：2026-11-04 task-crossprojauth-20261104 Rule 99 并入纪律域；82→83：2026-11-04 task-crossprojauth-20261104-R2 Rule 100 并入纪律域）`
   （该行行首 `#   AD-10 SKILL.md '其余 82 条' ≥2` 同时改为 `#   AD-10 SKILL.md '其余 83 条' ≥2`）
3. L85 old：`# AD-09 SKILL.md 纪元字面 1-99 ≥3` → new：`# AD-09 SKILL.md 纪元字面 1-100 ≥3`
4. L86 old：`ad09="$(cnt '1-99' "$SKILLMD")"` → new：`ad09="$(cnt '1-100' "$SKILLMD")"`
5. L87 old：`if [ "${ad09:-0}" -ge 3 ]; then ok 09 "SKILL.md 纪元字面 1-99=${ad09:-0} 处（≥3）"; else bad 09 "SKILL.md 纪元字面 1-99 仅 ${ad09:-0} 处（需 ≥3: 指针行/全集索引/References 表）"; fi`
   → new：`if [ "${ad09:-0}" -ge 3 ]; then ok 09 "SKILL.md 纪元字面 1-100=${ad09:-0} 处（≥3）"; else bad 09 "SKILL.md 纪元字面 1-100 仅 ${ad09:-0} 处（需 ≥3: 指针行/全集索引/References 表）"; fi`
6. L88–L90 old：
   `# AD-10 SKILL.md 其余 82 条 ≥2` / `ad10="$(cnt '其余 82 条' "$SKILLMD")"` / `if [ "${ad10:-0}" -ge 2 ]; then ok 10 "SKILL.md 计数级联 其余 82 条=${ad10:-0} 处（≥2）"; else bad 10 "SKILL.md 计数级联缺失（其余 82 条=${ad10:-0}，需 ≥2）"; fi`
   → 三行中全部 `82 条` 改 `83 条`（`# AD-10 SKILL.md 其余 83 条 ≥2` / `ad10="$(cnt '其余 83 条' "$SKILLMD")"` / `if [ "${ad10:-0}" -ge 2 ]; then ok 10 "SKILL.md 计数级联 其余 83 条=${ad10:-0} 处（≥2）"; else bad 10 "SKILL.md 计数级联缺失（其余 83 条=${ad10:-0}，需 ≥2）"; fi`）

### F6. skills/task-planner/scripts/selftest-subagent-activation.sh（断言+注释随动，共 6 处）
1. L14 old 片段：`#   SA-11 SKILL.md 纪元字面 1-99 ≥3 处（宽容正则 1-99([^0-9]|$);`
   → new：`#   SA-11 SKILL.md 纪元字面 1-100 ≥3 处（宽容正则 1-100([^0-9]|$);`
   L14 尾 old：`[2026-11-04 task-crossprojauth-20261104 纪元 1-98→1-99 随动]）`
   → new：`[2026-11-04 task-crossprojauth-20261104 纪元 1-98→1-99 随动][2026-11-04 task-crossprojauth-20261104-R2 纪元 1-99→1-100 随动]）`
2. L15 old 片段：`∧ 其余 82 条 ≥2 处（` → new：`∧ 其余 83 条 ≥2 处（`；L15 尾 old `81→82：2026-11-04 task-crossprojauth-20261104 Rule 99 并入纪律域）` → new `81→82：2026-11-04 task-crossprojauth-20261104 Rule 99 并入纪律域；82→83：2026-11-04 task-crossprojauth-20261104-R2 Rule 100 并入纪律域）`
3. L64 old：`# SA-11 SKILL.md 纪元字面 1-99 ≥3` → new：`# SA-11 SKILL.md 纪元字面 1-100 ≥3`
4. L65 old：`sa11="$(cntE '1-99([^0-9]|$)' "$SKILLMD")"` → new：`sa11="$(cntE '1-100([^0-9]|$)' "$SKILLMD")"`
5. L66 old：`if [ "${sa11:-0}" -ge 3 ]; then ok 11 "SKILL.md 纪元字面 1-99=${sa11:-0} 处（≥3）"; else bad 11 "SKILL.md 纪元字面 1-99 仅 ${sa11:-0} 处（需 ≥3: frontmatter/正文/References）"; fi`
   → new：`if [ "${sa11:-0}" -ge 3 ]; then ok 11 "SKILL.md 纪元字面 1-100=${sa11:-0} 处（≥3）"; else bad 11 "SKILL.md 纪元字面 1-100 仅 ${sa11:-0} 处（需 ≥3: frontmatter/正文/References）"; fi`
6. L67 old：`# SA-12 卫星枚举 ,96 + 其余 82 条（各 ≥2）[2026-11-02 task-lazy-escalation-20261102 纪元级联随动：79→80，Rule 97 并入纪律域后全集计数上移；2026-11-03 task-ctxcorrect-20261103 80→81；2026-11-04 task-crossprojauth-20261104 81→82，Rule 99 并入纪律域]`
   → new：`# SA-12 卫星枚举 ,96 + 其余 83 条（各 ≥2）[2026-11-02 task-lazy-escalation-20261102 纪元级联随动：79→80，Rule 97 并入纪律域后全集计数上移；2026-11-03 task-ctxcorrect-20261103 80→81；2026-11-04 task-crossprojauth-20261104 81→82，Rule 99 并入纪律域；2026-11-04 task-crossprojauth-20261104-R2 82→83，Rule 100 并入纪律域]`
   L68 old：`sa12a="$(cnt '52,59,68,96' "$SKILLMD")"; sa12b="$(cnt '其余 82 条' "$SKILLMD")"`
   → new：`sa12a="$(cnt '52,59,68,96' "$SKILLMD")"; sa12b="$(cnt '其余 83 条' "$SKILLMD")"`
   L69 old：`if [ "${sa12a:-0}" -ge 2 ] && [ "${sa12b:-0}" -ge 2 ]; then ok 12 "SKILL.md 卫星枚举 ,96=${sa12a:-0} ∧ 其余 82 条=${sa12b:-0}（各 ≥2）"; else bad 12 "SKILL.md 级联随动缺失（,96=${sa12a:-0}/82 条=${sa12b:-0}, 各需 ≥2）"; fi`
   → new：`if [ "${sa12a:-0}" -ge 2 ] && [ "${sa12b:-0}" -ge 2 ]; then ok 12 "SKILL.md 卫星枚举 ,96=${sa12a:-0} ∧ 其余 83 条=${sa12b:-0}（各 ≥2）"; else bad 12 "SKILL.md 级联随动缺失（,96=${sa12a:-0}/83 条=${sa12b:-0}, 各需 ≥2）"; fi`

## 验收（全部跑通后才可回报完成；在仓根 /mnt/data/dev/task-planner-skill 下）
1. `grep -c '^### 100' skills/task-discipline/references/critical-rules-discipline.md` = 1
2. `grep -c '1-100' skills/task-planner/SKILL.md` ≥ 3 且 `grep -c '1-99' skills/task-planner/SKILL.md` = 0
3. `grep -c '其余 83 条' skills/task-planner/SKILL.md` = 2 且 `grep -c '其余 82 条' skills/task-planner/SKILL.md` = 0
4. `grep -c '共 50 条' skills/task-discipline/SKILL.md` ≥ 2（L15「共 50 条」+L82「现共 50 条」）且 `grep -c '49 条' skills/task-discipline/SKILL.md` = 0
5. `grep -c '^| 100 |' skills/task-discipline/SKILL.md` = 1
6. `grep -c ',99,100' skills/task-planner/SKILL.md` = 1（L197）且 `grep -c ',99,100' skills/task-planner/references/critical-rules.md` = 1
7. 两 selftest：`bash -n skills/task-planner/scripts/selftest-anti-deferral.sh` 与 `bash -n skills/task-planner/scripts/selftest-subagent-activation.sh` 均 exit 0（语法自检,不做断言运行——断言由主进程统一跑全量回归）
8. 未编辑 spec 外任何文件

## 里程碑与回报
- F1 完成后写检查点 /mnt/data/dev/task-planner-skill/plans/task-crossprojauth-20261104/subagent-state/02-executor-rule100.md（「F1 discipline 追加完成」+grep 证据）
- F2–F6 全部完成后：检查点追加验收 1–8 输出 + 失配登记（若有）+ 最终结论。
- 返回消息=每文件 edit 计数 + 验收 grep 原文 + 检查点路径（8 字段口径）。
