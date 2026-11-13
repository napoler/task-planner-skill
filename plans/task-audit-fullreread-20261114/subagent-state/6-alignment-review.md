# Alignment Review — task-audit-fullreread-20261114 (收尾对齐审查)

verdict: CHANGES_REQUESTED

## 审查对象清单
- 任务: task-audit-fullreread-20261114（收尾对齐/同步一致性审查，Rule 42.7 CR 面）
- 需求锚: R2「…最重要的是在审核阶段，我希望可以在审核阶段去做这部分内容，在单独的子代理中进行。」(plans/task-audit-fullreread-20261114/user-session-log.md #1，Rule 51.1a 双锚)
- 计划四文件(只读): plans/task-audit-fullreread-20261114/task_plan.md, findings.md, progress.md, knowledge-brief.md
- 变更集: merge commit 5d52eb4834c4eca6fe2862a72535cb58540e7422 (Merge branch 'wt/task-audit-fullreread-20261114', parents 631af7a 83b3388), diff 基线 631af7a..5d52eb4
- 变更意图基准: task_plan.md CA-1~CA-7 (L188-L195)；越界基准: scope_files (task_plan.md:76) + git diff --name-only
- 部署副本: /home/terry/.zcode/skills/{相对路径} 与 /home/terry/.claude/skills/{相对路径}（同路径族，12 对）

## 逐项证据与结论

### 1. 逐对副本同步（主仓 / zcode / claude 同路径 12 对）— PASS
- 证据命令: `cd /mnt/data/dev/task-planner-skill && git diff --name-only 631af7a..5d52eb4 | sort` → 6 files only:
  - skills/task-discipline/references/critical-rules-discipline.md
  - skills/task-dispatch/references/critical-rules-dispatch.md
  - skills/task-planner/SKILL.md
  - skills/task-planner/templates/subagent_dispatch.md
  - skills/task-planner/templates/task_plan.md
  - skills/verification-gate/references/critical-rules-verification.md
- 证据命令: `for f in <6 files>; do diff -q /mnt/data/dev/task-planner-skill/$f /home/terry/.zcode/skills/${f#skills/}; diff -q /mnt/data/dev/task-planner-skill/$f /home/terry/.claude/skills/${f#skills/}; done` → 无任何输出（12 对 diff 均为空，即内容一致）。
- 证据文件: plans/task-audit-fullreread-20261114/checkpoints/deploy-diff.txt → 12 行 `DEPLOYED-SAME`（zcode 6 + claude 6），覆盖上述 6 文件同路径。
- 结论: 任一差异=P0 条件未触发，12/12 同步一致。

### 2. 引用完整性（103.3a / 106.1b / 103.5⑤ / 3h 目标段逐一验在位）— PASS
- 103.3a 定义与引用（`grep -n '103\.3a'` on scope 6 files）:
  - skills/task-dispatch/references/critical-rules-dispatch.md:232 — `**103.3a 全文回读与整体分析义务（审核阶段，P0，2026-11-14 task-audit-fullreread-20261114）**：...完整回读被修改文件的全文（分页读完，非 diff/非片段）...整体分析四维——①结构完整性②修改落点正确性③交叉引用一致性④语义连贯；复检回执必须附全文回读证据...`
  - skills/task-dispatch/references/critical-rules-dispatch.md:236 — 103.5⑤引用 `...整体分析四维（103.3a）...`
  - skills/task-planner/SKILL.md:104 — `...复检体全文回读被改文件并整体分析（103.3a 义务，2026-11-14 task-audit-fullreread-20261114）。`
  - skills/task-discipline/references/critical-rules-discipline.md:727 — 106.1b 引用 `（Rule 103.3a 独立复检）`
  - skills/task-planner/templates/subagent_dispatch.md:59 — `- **第二轮·全文回读要素（103.3a，2026-11-14 task-audit-fullreread-20261114）**：...完整回读全文...整体分析四维...回执附读取范围证据；缺证据=复检无效。`
  - skills/task-planner/templates/task_plan.md — 无 103.3a 字面（预期：模板措辞同步 CA-6 仅改「四要素」→「五要素」）
  - skills/verification-gate/references/critical-rules-verification.md — 无 103.3a 字面（预期：CA-7 仅措辞同步）
- 106.1b 定义（`grep -n '106\.1b'`）:
  - skills/task-discipline/references/critical-rules-discipline.md:727 — `**106.1b 审核阶段全文回读分工（P1，指针，2026-11-14 task-audit-fullreread-20261114）**：...审核阶段（Rule 103.3a 独立复检）...106.1/106.1a/106.3 管过程期即时拦截...互补不互代...`
- 103.5⑤（`grep -n '103\.5'` + 内容核验）:
  - skills/task-dispatch/references/critical-rules-dispatch.md:236 — 标题 `103.5 **复检任务书简洁直接五要素（低资源约束）**`，含 `①对象...②验收标准...③判定口径...④禁令...；⑤全文回读要求=任务书须声明被修改文件绝对路径清单并要求复检体完整回读全文+整体分析四维（103.3a）、回执附读取范围证据。`
  - skills/task-planner/templates/subagent_dispatch.md:58 — `复检任务书只含五要素：①...②...③...④...`；:59 — 独立 bullet 承载全文回读要素（语义对应 ⑤，见 checklist 4 备注）。
  - skills/task-planner/templates/task_plan.md:113 — `复检任务书简洁五要素 103.5`
  - skills/verification-gate/references/critical-rules-verification.md:55 — `103.5 复检任务书简洁五要素/103.6 同步核对清单`
- 3h 指针: skills/task-planner/SKILL.md:104 — 3h 行含 103.2/103.3/103.4/103.5/103.6 引用及 103.3a 义务追加。
- 结论: 目标段/锚点均在位且互引链可达。

### 3. 术语一致性（五要素落点 vs 四要素残留；103.3a 互引一致）— FAIL
- 103.3a 互引一致: PASS（见 checklist 2，103.3a 定义于 dispatch:232，被 dispatch:236/discipline:727/SKILL:104/template_dispatch:59 引用，链路闭合）。
- 103.5「四要素→五要素」在 scope 6 文件中的残留（`grep -n '四要素' <6 scope files>`，排除 Rule 70 等无关上下文）:
  - **IN-SCOPE 残留（103.5 上下文）**: skills/task-planner/SKILL.md:104 — `派全新复检体（103.3，升档 103.4/简洁四要素 103.5）→复检回执落 checkpoint`。同文件已被 CA-3 修改（句尾追加 103.3a 义务），但 103.5 的计数标签未由「四要素」同步为「五要素」。对照已同步位：dispatch:236 标题为「简洁直接五要素」、template_dispatch:58 为「只含五要素」、template_plan:113 为「简洁五要素」、verification-gate:55 为「简洁五要素」。
  - scope 内其他「四要素」命中均为 Rule 70 呈报四要素等不同语义（SKILL.md:56、template_plan.md:169/415、discipline.md 多处 Rule 45.3/54.4/57.2/70.x/99.5/101 等）— 非 103.5 上下文，非本次变更残留。
- 全仓（archive 豁免）103.5 上下文「四要素」残留（`grep -rn '简洁四要素 103\.5|只含四要素.*103\.' --exclude-dir=.git`）:
  - plans/archive/task-dualqc-20261104/findings.md:77、plans/archive/task-*-2026110*/task_plan.md（多份历史计划模板注释）— 历史归档/历史计划实例，预期保留历史原文。
  - plans/task-audit-fullreread-20261114/checkpoints/cascade-surface.raw:4,7,9,10,12 — 预变更捕获快照（证据文件）。
  - plans/task-audit-fullreread-20261114/subagent-state/3-s1-material.md,3-s3-material.md — 派发材料（描述待改旧态→新态）。
  - plans/task-audit-fullreread-20261114/checkpoints/audit-report.md:33 — 审计引用旧态原文（E8 证据）。
  - plans/task-audit-fullreread-20261114/task_plan.md:116 — 计划实例注释仍为「简洁四要素 103.5」（CA-6 记录了对模板 task_plan.md:113 的同步，但计划实例自身该注释未同步；计划目录非 git diff 变更集内）。
  - plans/task-audit-fullreread-20261114/task_plan.md:194 — CA-6 变更记录行描述「"四要素"→"五要素"」为动作记录（非残留语句）。
- 结论: 103.3a 互引一致 PASS；但 scope 内 SKILL.md:104 存在 103.5 计数标签未同步的真实残留（MAJOR）。

### 4. 计数枚举（103.5 段枚举项计数 ①-⑤=5 项 与标题「五要素」一致）— PASS（附备注）
- 规则正本 103.5 段（skills/task-dispatch/references/critical-rules-dispatch.md:236，`sed -n '236p'`）: 标题 `103.5 **复检任务书简洁直接五要素（低资源约束）**`，同段内显式枚举 ①对象 ②验收标准 ③判定口径 ④禁令 ⑤全文回读要求 = 5 项，与「五要素」一致。PASS。
- 备注（INFO）：skills/task-planner/templates/subagent_dispatch.md:58 声明「只含五要素」并内联 ①-④；:59 以独立 bullet `- **第二轮·全文回读要素（103.3a...）**` 承载第 5 要素（无「⑤」字面前缀）。语义上 5 要素齐备且与 103.5/103.3a 对齐，但枚举呈现形式与正本 103.5 段的 ①-⑤ 内联样式不同。非阻塞。

### 5. 越界自检（git show --name-only 5d52eb4 / 631af7a..5d52eb4 与 scope_files 对账）— PASS
- 证据: `git diff --name-only 631af7a..5d52eb4` → 仅上述 6 个 skills 文件；`git diff --stat 631af7a..5d52eb4` → `6 files changed, 10 insertions(+), 5 deletions(-)`；`grep '^plans/'` on diff names → `NO_PLANS_IN_DIFF`。
- scope_files（task_plan.md:76）声明: skills/task-dispatch/references/critical-rules-dispatch.md, skills/task-discipline/references/critical-rules-discipline.md, skills/task-planner/SKILL.md, skills/task-planner/templates/subagent_dispatch.md, skills/task-planner/templates/task_plan.md, skills/verification-gate/references/critical-rules-verification.md, 以及条件性 selftest-*.sh（仅断言适配时）。
- 对账: 实际变更集 = 声明 6 文件子集，selftest 未改动（符合「仅断言适配时」条件未触发）；无越界文件。

### 6. 守卫锚级联（selftest 脚本 103.3/103.5 锚命中）— PASS
- 证据: `grep -rln '103\.3\|103\.5' skills/task-planner/scripts/selftest-*.sh` → `NO_MATCHES`。无断言面锚需级联修改。

### 7. 索引联动（无新 Rule 编号/新文件，rule-reservations 无悬空登记）— PASS
- 本变更未新增 Rule 编号：103.3a 为 Rule 103 子条（执行面细化），106.1b 为 Rule 106 子条（分工指针）；103/106 已在 plans/.rule-reservations.jsonl 中 reserved+landed（行含 `"rule":103,"status":"landed","task_id":"task-dualqc-20261104"`、`"rule":106,"status":"landed","task_id":"task-docmod-recheck-20261112"`），无新条目、无悬空 reservation。
- 无新文件引入（6 文件均为修改 M）。

## 变更记录
- 审查执行: 只读审查（git diff/show/grep/sed/cat/diff -q/Read），未修改任何被审查产物。
- 检查范围: merge 5d52eb4 对 631af7a 的有效变更 6 文件 + zcode/claude 部署副本 12 对 + 103.3a/106.1b/103.5⑤/3h 引用链 + 全仓「四要素」残留（archive 豁免）+ 103.5 枚举计数 + 越界 + selftest 锚 + reservations。
- 结论: CHANGES_REQUESTED（1 项 MAJOR 需修复后方可 APPROVED）。

## 意见清单（按 BLOCKER > MAJOR > MINOR > INFO）

### [MAJOR] M1 — SKILL.md 3h 行 103.5 计数标签未同步「四要素→五要素」
- 位置: skills/task-planner/SKILL.md:104
- 问题: 3h 步骤中仍写 `派全新复检体（103.3，升档 103.4/简洁四要素 103.5）`，与同次变更已同步的正本/模板措辞不一致（dispatch:236「简洁直接五要素」、subagent_dispatch:58「只含五要素」、task_plan 模板:113「简洁五要素」、verification-gate:55「简洁五要素」）。CA-3 仅追加句尾 103.3a 义务，遗漏括号内计数词同步。
- 证据:
  - 命令: `sed -n '104p' skills/task-planner/SKILL.md` → `  - **3h 双轮质检（Rule 103）**：...派全新复检体（103.3，升档 103.4/简洁四要素 103.5）→...复检体全文回读被改文件并整体分析（103.3a 义务，2026-11-14 task-audit-fullreread-20261114）。`
  - 对照: `sed -n '236p' skills/task-dispatch/references/critical-rules-dispatch.md` → `103.5 **复检任务书简洁直接五要素（低资源约束）**：①...②...③...④...⑤全文回读要求...`
  - 对照: `sed -n '113p' skills/task-planner/templates/task_plan.md` → `...复检任务书简洁五要素 103.5...`
- 修法: 将 skills/task-planner/SKILL.md:104 中 `简洁四要素 103.5` 改为 `简洁五要素 103.5`（保持其余文本不变），并同步部署位 /home/terry/.zcode/skills/task-planner/SKILL.md 与 /home/terry/.claude/skills/task-planner/SKILL.md（diff -q 验证 3 处一致）。

### [INFO] I1 — subagent_dispatch 模板第 5 要素呈现为独立 bullet（非 ①-⑤ 内联）
- 位置: skills/task-planner/templates/subagent_dispatch.md:58-59
- 说明: :58 声明「只含五要素」并内联 ①-④；:59 以独立 bullet 承载全文回读要素（引用 103.3a），未使用「⑤」前缀。语义与 103.5 正本一致、证据要求明确；仅枚举样式与 dispatch:236 的 ①-⑤ 内联不同。非阻塞，可选统一样式。

### [INFO] I2 — 计划实例 task_plan.md:116 保留「四要素」字样（非变更集/非 scope 文件）
- 位置: plans/task-audit-fullreread-20261114/task_plan.md:116
- 说明: 该计划实例的双轮质检声明注释仍写「简洁四要素 103.5」，而模板已同步（CA-6 scope 为模板文件）。CA-6 变更记录在 :194 记述了同步动作。计划目录未在 git diff 中；若追求计划文档与最终模板完全对齐可一并修订，但不影响本次 scope 代码/技能文件交付。

## 总评
- 6/7 审查项 PASS，1 项 FAIL（术语一致性，scope 内 SKILL.md:104 103.5 标签未同步）。引用链（103.3a/106.1b/103.5⑤/3h）完整、103.5 正本枚举 ①-⑤ 与标题一致、12 对部署副本同步、变更集无越界、无 selftest 锚级联、无 reservations 悬空。
- 修复 M1 并同步两部署位后可复核为 APPROVED。
