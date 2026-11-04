# Agent C Spec — Rule 101 条款落盘 + 纪元级联（1-100→1-101 / 83→84 条 / 50→51 条）+ worktree-isolation §4/§5 语义翻转

## 背景（自包含）
- 仓库：/mnt/data/dev/task-planner-skill（task-planner 技能源仓，主进程 cwd）
- 任务 task-crossprojauth-20261104 R3（2026-11-04 用户第三指令）：「加强git的使用 就是 开始任务 使用 git固定提交原始数据 处理后主动动合并git工作树解决所有冲突」→ 新 Rule 101「git 使用加强纪律（起点原始数据固定提交 + 终点工作树主动合并解冲突）」并入纪律域；冲突语义翻转：冲突=收口义务（41.1 消解链全解+复验），仅消解配额耗尽才真门 STOP；「不乱解」守卫保留。
- 执行纪律：先 Read 目标文件 → 确认 old 原文存在且唯一 → Edit；old 不匹配时该处停止并登记「失配」，禁止猜测改写。只编辑本 spec 列出的 7 个文件（材料包只读、检查点只追加）；禁 git 操作；禁碰 AGENTS.md；纪元字面替换只动 spec 列出的行，SKILL.md 中 Rule 100/99 提及等其他语境不动。
- 注意：本 spec 的 old 字面是 **Rule 100 级联完成后** 的磁盘现状（1-100/83 条/50 条），先 grep 复核再 Edit。

## 编辑清单（7 文件）

### F1. skills/task-discipline/references/critical-rules-discipline.md（追加 1 段）
Read 材料包 /mnt/data/dev/task-planner-skill/plans/task-crossprojauth-20261104/subagent-state/rule101-section.md（完整 `### 101` 段，101.0–101.4），逐字追加到 discipline 文件**末尾**（当前末行=100.5 段最后一行「…判例锚=用户 2026-11-04 R3 指令（plans/task-crossprojauth-20261104/task_plan.md R3 用户原话行）。」），追加前留一空行。材料包内容逐字照搬。

### F2. skills/task-discipline/SKILL.md（5 处）
1. L15 old 片段：`跨项目/跨目录操作授权纪律、临时目录统一与工作树内放纪律等共 50 条（全文见规则索引）。`
   → new：`跨项目/跨目录操作授权纪律、临时目录统一与工作树内放纪律、git 使用加强纪律等共 51 条（全文见规则索引）。`
2. L24 old 尾片段：`95,97,98,99,100）。` → new：`95,97,98,99,100,101）。`
3. L81 表行 `| 100 | 临时目录统一与工作树内放纪律 | \`references/critical-rules-discipline.md\` \`### 100\` 段 |` 之后插入：
   `| 101 | git 使用加强纪律 | \`references/critical-rules-discipline.md\` \`### 101\` 段 |`
4. L82 old 片段：`与 Rule 100（task-crossprojauth-20261104-R2 临时目录统一与工作树内放纪律）已后补落盘——本索引现共 50 条全文可消费。`
   → new：`与 Rule 100（task-crossprojauth-20261104-R2 临时目录统一与工作树内放纪律）与 Rule 101（task-crossprojauth-20261104-R3 git 使用加强纪律——起点原始数据固定提交+终点主动合并解冲突）已后补落盘——本索引现共 51 条全文可消费。`
5. L93 old：`— 50 条规则全文（含后补落盘的 Rule 85/86/87/88/89/90/92/93/94/95/97/98/99/100）`
   → new：`— 51 条规则全文（含后补落盘的 Rule 85/86/87/88/89/90/92/93/94/95/97/98/99/100/101）`

### F3. skills/task-planner/SKILL.md（5 处）
1. L9 old 片段：`Rules 1-100 全集索引（核心在位 1,2,3,5,19,20,26,51,62,66,80,81,82,83，含 Rule 82 分层纪律 + Rule 83 通道快速失败；其余 83 条按域归 11 卫星`
   → new：`Rules 1-101 全集索引（核心在位 1,2,3,5,19,20,26,51,62,66,80,81,82,83，含 Rule 82 分层纪律 + Rule 83 通道快速失败；其余 84 条按域归 11 卫星`
2. L197 old 片段：`临时目录统一与工作树内放（Rule 4,6,7,8,9,10,18,27,28,29,31,32,33,35,36,41-45,48,53-57,60,65,67,69-74,76,85,86,87,88,89,90,92,93,94,95,97,98,99,100）`
   → new：`临时目录统一与工作树内放/git 使用加强（Rule 4,6,7,8,9,10,18,27,28,29,31,32,33,35,36,41-45,48,53-57,60,65,67,69-74,76,85,86,87,88,89,90,92,93,94,95,97,98,99,100,101）`
3. L210 两处：old `Rules 1-100 全集索引：**核心在位 14 条**` → new `Rules 1-101 全集索引：**核心在位 14 条**`；old `其余 83 条已按域迁至上表 11 卫星（含 Rule 84 验证域、Rule 85/86/87/88/89/90/92/93/94/95/97/98/99/100 纪律域）` → new `其余 84 条已按域迁至上表 11 卫星（含 Rule 84 验证域、Rule 85/86/87/88/89/90/92/93/94/95/97/98/99/100/101 纪律域）`
4. L243 old 片段：`/临时目录统一与工作树内放（Rule 100）**` → new：`/临时目录统一与工作树内放（Rule 100）/git 使用加强（Rule 101）**`
5. L253 old：`Critical Rules 核心域 1-100 全集索引（14 条核心全文+分层架构说明+卫星路由索引）` → new：`Critical Rules 核心域 1-101 全集索引（14 条核心全文+分层架构说明+卫星路由索引）`

### F4. skills/task-planner/references/critical-rules.md（L194 行 2 处）
1. old 片段：`95,97,98,99,100）；调用条件` → new：`95,97,98,99,100,101）；调用条件`
2. old 行尾片段：`/临时目录统一与工作树内放相关时。` → new：`/临时目录统一与工作树内放/git 使用加强相关时。`

### F5. skills/task-planner/scripts/selftest-anti-deferral.sh（断言+注释随动）
- L13 old：`#   AD-09 SKILL.md 纪元字面 '1-100' ≥3（line9 指针行/line210 全集索引/line253 References 表）` → new：`#   AD-09 SKILL.md 纪元字面 '1-101' ≥3（line9 指针行/line210 全集索引/line253 References 表）`
- L14 old：`#   AD-10 SKILL.md '其余 83 条' ≥2（line9+line210；79→80 计数级联随动，Rule 97 并入后全集计数上移；80→81：2026-11-03 task-ctxcorrect-20261103 Rule 98 并入纪律域；81→82：2026-11-04 task-crossprojauth-20261104 Rule 99 并入纪律域；82→83：2026-11-04 task-crossprojauth-20261104-R2 Rule 100 并入纪律域）`
  → new：同尾追加 `；83→84：2026-11-04 task-crossprojauth-20261104-R3 Rule 101 并入纪律域`，行首 `'其余 83 条'` 改 `'其余 84 条'`
- L85 old：`# AD-09 SKILL.md 纪元字面 1-100 ≥3` → new：`# AD-09 SKILL.md 纪元字面 1-101 ≥3`
- L86 old：`ad09="$(cnt '1-100' "$SKILLMD")"` → new：`ad09="$(cnt '1-101' "$SKILLMD")"`
- L87 old：`if [ "${ad09:-0}" -ge 3 ]; then ok 09 "SKILL.md 纪元字面 1-100=${ad09:-0} 处（≥3）"; else bad 09 "SKILL.md 纪元字面 1-100 仅 ${ad09:-0} 处（需 ≥3: 指针行/全集索引/References 表）"; fi`
  → new：`if [ "${ad09:-0}" -ge 3 ]; then ok 09 "SKILL.md 纪元字面 1-101=${ad09:-0} 处（≥3）"; else bad 09 "SKILL.md 纪元字面 1-101 仅 ${ad09:-0} 处（需 ≥3: 指针行/全集索引/References 表）"; fi`
- L88 old：`# AD-10 SKILL.md 其余 83 条 ≥2` → new：`# AD-10 SKILL.md 其余 84 条 ≥2`
- L89 old：`ad10="$(cnt '其余 83 条' "$SKILLMD")"` → new：`ad10="$(cnt '其余 84 条' "$SKILLMD")"`
- L90 old：`if [ "${ad10:-0}" -ge 2 ]; then ok 10 "SKILL.md 计数级联 其余 83 条=${ad10:-0} 处（≥2）"; else bad 10 "SKILL.md 计数级联缺失（其余 83 条=${ad10:-0}，需 ≥2）"; fi`
  → new：`if [ "${ad10:-0}" -ge 2 ]; then ok 10 "SKILL.md 计数级联 其余 84 条=${ad10:-0} 处（≥2）"; else bad 10 "SKILL.md 计数级联缺失（其余 84 条=${ad10:-0}，需 ≥2）"; fi`

### F6. skills/task-planner/scripts/selftest-subagent-activation.sh（断言+注释随动）
- L14 old 片段：`#   SA-11 SKILL.md 纪元字面 1-100 ≥3 处（宽容正则 1-100([^0-9]|$);` → new：`#   SA-11 SKILL.md 纪元字面 1-101 ≥3 处（宽容正则 1-101([^0-9]|$);`
  L14 尾 old：`[2026-11-04 task-crossprojauth-20261104-R2 纪元 1-99→1-100 随动]）` → new：`[2026-11-04 task-crossprojauth-20261104-R2 纪元 1-99→1-100 随动][2026-11-04 task-crossprojauth-20261104-R3 纪元 1-100→1-101 随动]）`
- L15 old 片段：`∧ 其余 83 条 ≥2 处（` → new：`∧ 其余 84 条 ≥2 处（`；L15 尾 old `82→83：2026-11-04 task-crossprojauth-20261104-R2 Rule 100 并入纪律域）` → new `82→83：2026-11-04 task-crossprojauth-20261104-R2 Rule 100 并入纪律域；83→84：2026-11-04 task-crossprojauth-20261104-R3 Rule 101 并入纪律域）`
- L64 old：`# SA-11 SKILL.md 纪元字面 1-100 ≥3` → new：`# SA-11 SKILL.md 纪元字面 1-101 ≥3`
- L65 old：`sa11="$(cntE '1-100([^0-9]|$)' "$SKILLMD")"` → new：`sa11="$(cntE '1-101([^0-9]|$)' "$SKILLMD")"`
- L66 old：`if [ "${sa11:-0}" -ge 3 ]; then ok 11 "SKILL.md 纪元字面 1-100=${sa11:-0} 处（≥3）"; else bad 11 "SKILL.md 纪元字面 1-100 仅 ${sa11:-0} 处（需 ≥3: frontmatter/正文/References）"; fi`
  → new：`if [ "${sa11:-0}" -ge 3 ]; then ok 11 "SKILL.md 纪元字面 1-101=${sa11:-0} 处（≥3）"; else bad 11 "SKILL.md 纪元字面 1-101 仅 ${sa11:-0} 处（需 ≥3: frontmatter/正文/References）"; fi`
- L67 old：`# SA-12 卫星枚举 ,96 + 其余 83 条（各 ≥2）[...；2026-11-04 task-crossprojauth-20261104-R2 82→83，Rule 100 并入纪律域]`
  → new：`# SA-12 卫星枚举 ,96 + 其余 84 条（各 ≥2）[...；2026-11-04 task-crossprojauth-20261104-R2 82→83，Rule 100 并入纪律域；2026-11-04 task-crossprojauth-20261104-R3 83→84，Rule 101 并入纪律域]`（中间 `[...]` 部分原文保持，只在 `83 条（各 ≥2）` 与尾部随动）
- L68 old：`sa12a="$(cnt '52,59,68,96' "$SKILLMD")"; sa12b="$(cnt '其余 83 条' "$SKILLMD")"` → new：`sa12a="$(cnt '52,59,68,96' "$SKILLMD")"; sa12b="$(cnt '其余 84 条' "$SKILLMD")"`
- L69 old：`if [ "${sa12a:-0}" -ge 2 ] && [ "${sa12b:-0}" -ge 2 ]; then ok 12 "SKILL.md 卫星枚举 ,96=${sa12a:-0} ∧ 其余 83 条=${sa12b:-0}（各 ≥2）"; else bad 12 "SKILL.md 级联随动缺失（,96=${sa12a:-0}/83 条=${sa12b:-0}, 各需 ≥2）"; fi`
  → new：`if [ "${sa12a:-0}" -ge 2 ] && [ "${sa12b:-0}" -ge 2 ]; then ok 12 "SKILL.md 卫星枚举 ,96=${sa12a:-0} ∧ 其余 84 条=${sa12b:-0}（各 ≥2）"; else bad 12 "SKILL.md 级联随动缺失（,96=${sa12a:-0}/84 条=${sa12b:-0}, 各需 ≥2）"; fi`

### F7. skills/task-planner/references/worktree-isolation.md（§4 L86 句翻转 + §5 L94 行收窄，2 处）
1. L86 old：`**失败处理**：merge 冲突 → STOP 报告用户(不自动解决)；worktree 内验证失败 → 修到通过才合并，3 次失败升级用户。〔Rule 97.6 仲裁〕主进程消费首冲突 STOP 前先走 41.1 消解链尝试配额（①git 三方合并/并集解 ②手动解冲突→复验 ③分叉重基），仍失败才升级用户；「不自动乱解/报告用户」语义保持（§5 反模式不变），配额仅许手动解+复验。`
   → new：`**失败处理（2026-11-04 Rule 101.2 语义翻转）**：merge 冲突=收口义务（Rule 101.2）：逐条走 41.1 消解链配额（①git 三方合并/并集解 ②手动解冲突→复验 ③分叉重基）**解决所有冲突**，解后 VC 复验过才合并；仅**消解配额耗尽仍冲突**为真门（Rule 95.5）→ STOP 报告用户（Rule 70 四要素+冲突 hunk 看点）并在 progress 登记 `[conflict-unresolved]`；**不乱解守卫保留**：解冲突必带复验（VC/selftest/Read 对照），无复验的解=假收口（Rule 54），并集解仅限两侧增量场景、判为语义冲突处必须手动解+复验。worktree 内验证失败 → 修到通过才合并，3 次失败升级用户。`
2. L94 old：`- ❌ 合并冲突自动乱解不报告`
   → new：`- ❌ 解冲突不复验/留冲突给用户（冲突=收口义务，Rule 101.2：主动解决所有冲突+复验门；「不乱解」守卫保留——仅配额耗尽才真门）`

### F8. 守卫预检（只读，结果入回报，不改文件）
`grep -rn '不自动解决\|自动乱解\|冲突 → STOP\|冲突→STOP' skills/task-planner/scripts/*.sh skills/task-planner/scripts/ | head -20`
若某 selftest 守卫断言了 F7 的旧措辞（`不自动解决`/`自动乱解不报告`）：**不改该守卫**，在回报失配登记中列出命中行（主进程裁决是否需第三轮随动）；若零命中，回报「无旧措辞守卫」。

## 验收（全部跑通后才可回报完成；仓根 /mnt/data/dev/task-planner-skill）
1. `grep -c '^### 101' skills/task-discipline/references/critical-rules-discipline.md` = 1
2. `grep -c '1-101' skills/task-planner/SKILL.md` ≥ 3 且 `grep -c '1-100' skills/task-planner/SKILL.md` = 0
3. `grep -c '其余 84 条' skills/task-planner/SKILL.md` = 2 且 `grep -c '其余 83 条' skills/task-planner/SKILL.md` = 0
4. `grep -c '共 51 条' skills/task-discipline/SKILL.md` ≥ 1 且 `grep -c '51 条' skills/task-discipline/SKILL.md` ≥ 3（L15/L82/L93）且 `grep -c '共 50 条' skills/task-discipline/SKILL.md` = 0
5. `grep -c '^| 101 |' skills/task-discipline/SKILL.md` = 1 且 `grep -c ',99,100,101' skills/task-discipline/SKILL.md` = 1（L24）
6. `grep -c ',100,101' skills/task-planner/SKILL.md` ≥ 2（L197+L210）且 `grep -c ',101' skills/task-planner/references/critical-rules.md` = 1
7. `grep -c '冲突=收口义务' skills/task-planner/references/worktree-isolation.md` ≥ 1 且 `grep -c '自动乱解不报告' skills/task-planner/references/worktree-isolation.md` = 0 且 `grep -c 'merge 冲突 → STOP 报告用户(不自动解决)' skills/task-planner/references/worktree-isolation.md` = 0
8. `bash -n` 双 selftest exit 0
9. F8 守卫预检结果登记
10. 未编辑 spec 外文件

## 里程碑与回报
- F1 完成后向 /mnt/data/dev/task-planner-skill/plans/task-crossprojauth-20261104/subagent-state/03-executor-rule101.md 追加「F1 完成」
- 全部完成后追加验收 1–10 原始输出 + 失配登记 + 最终结论。
- 返回消息=逐文件 edit 计数 + 验收 grep/命令原始输出 + 检查点路径 + 失配登记。不要跑全量回归（主进程统一执行）。
