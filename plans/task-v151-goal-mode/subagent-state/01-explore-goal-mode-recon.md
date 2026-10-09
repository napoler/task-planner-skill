# 01-explore-goal-mode-recon.md — Rule 66 goal 单元固化机制侦察报告

> 只读侦察，为 task-planner 技能 Rule 66（goal 单元固化与 goal 驱动推进）规划提供精确插入点。
> 所有路径为绝对路径，行号基于 2026-10-09 仓内状态。

---

## Q1 仓布局与部署位

- **技能源码根路径**：`/mnt/data/dev/task-planner-skill/skills/task-planner/`（仓根不是技能根；`skills/` 下含 11 个技能，task-planner 是其中之一）。
- **部署脚本**：
  - 主安装：`/mnt/data/dev/task-planner-skill/skills/task-planner/install.sh`（行 5 用法注释：`bash install.sh [--canonical <path>] [--tools claude,zcode,opencode,...]`）。
  - 伴随同步：`/mnt/data/dev/task-planner-skill/skills/task-planner/lib/install-companion.sh`（行 5-6 注释：`companion/agents/*.md → ~/.zcode/agents/`；`<repo>/skills/{task-drift-guard,plan-resume,todo-skill}/* → ~/.zcode/skills/<name>/`）。
  - 反向同步：`/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/sync-companion.sh`。
- **部署目标路径清单**：
  - 默认目标根：`~/.zcode`（install-companion.sh 行 54-55：`if [ -d "$HOME/.zcode" ]; then TARGET_ROOT="$HOME/.zcode"`）。
  - 回退目标根：`~/.claude`（行 56-57）。
  - Claude Code 钩子：`~/.claude/settings.local.json`（install.sh 行 158-159：`patching ~/.claude/settings.local.json via register-hooks-cj.ts`）。
  - zcode/opencode/cursor/continue 共用：install.sh 行 170 `zcode|opencode|cursor|continue)` 分支。
- **部署位与仓内一致性**：`/home/terry/.zcode/skills/task-planner/references/critical-rules.md` 与 `SKILL.md` 均与仓内 `diff -q` 无差异（完全一致）。

---

## Q2 critical-rules.md 结构

- **文件**：`/mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md`
- **总行数**：846 行。
- **文件头 docblock**：无总数声明。仅 2 行：
  - 行 1：`# Critical Rules — 核心执行规则`
  - 行 2：`> 以下为 task-planner 的强制行为约束。详见 § 十-6 安全执行原则。`
- **Rule 64**：
  - 标题行 798：`### 64 偏移检查留痕强制与节奏化触发纪律（P0, 2026-10-08 task-v148，...）`
  - 子条结构：64.1（行 802）、64.2（行 804）、64.3（行 806）、64.4（行 808）、64.5（行 810）、64.6（行 812）。
  - 子条样式：`64.N **标题（英文括注）**：正文...`
- **Rule 65**：
  - 标题行 816：`### 65 周期性回顾与前后对照（P0 — task-v142，...）`
  - 子条结构：65.1（行 822）、65.2（行 824）、65.3（行 831）、65.4（行 835）、65.5（行 840）、65.6（行 842）、65.7（行 844）、65.8（行 846）。
  - 文件尾 = Rule 65.8（行 846 即最后一行）。
- **「1-65」出现行号**：仅 1 次，行 840（65.5 正文中 `65.1-65.5` 子串命中 `1-65`）。
- **Rule 66 插入点**：行 846 之后（文件尾追加），保持 `### 66 ...` 标题 + `66.N **...**` 子条样式。

---

## Q3 SKILL.md 结构

- **文件**：`/mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md`
- **总行数**：509 行。
- **「1-65」出现行号**：3 次
  - 行 9：References 区 critical-rules.md 描述行（`Critical Rules 全集 1-65（...）`）。
  - 行 280：Critical Rules 区块总述行（`详见 references/critical-rules.md（Critical Rules 1-65（含 Rule 40-65 全集，...））`）。
  - 行 360：References 表 critical-rules.md 行（`| references/critical-rules.md | Critical Rules 1-65（...） |`）。
- **Critical Rules 逐条一行清单**：
  - 区块标题行 278：`## Critical Rules`
  - 总述行 280。
  - 逐条清单起止：行 289（Rule 20）至行 335（Rule 65）。
  - 行 336-337：空行。
  - 行 338：`## Completion Gate`（下一区块）。
- **Rule 66 一行插入点**：行 335（Rule 65 摘要）之后、行 338（`## Completion Gate`）之前，即插在行 336 位置（空行前）。
- **References 表**：
  - 区块标题行 355：`## References`
  - critical-rules.md 描述行：行 360。
  - 行 360 需同步将 `1-65` 改为 `1-66` 并追加 Rule 66 关键词。

---

## Q4 S-unit 表列契约

- **Rule 22.6 表列序原文**（critical-rules.md 行 187）：
  `| ID | 目标(≤1 句) | 执行体(subagent_type(model),可写"继承"=Phase Executor,或逐行如 explore(mini)/executor(sonnet-1)) | 输入(路径 + ≤10 行摘要,计划期预写材料包) | 验收(可观察) | 预估时长 | 状态 |`
  → 7 列：ID / 目标 / 执行体 / 输入 / 验收 / 预估时长 / 状态。
- **模板 S-unit 表表头原文**（templates/task_plan.md 行 266）：
  `| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |`
  → 9 列：ID / 目标 / 执行体 / 输入 / 验收 / 预估时长 / 粒度(三值) / 伴飞技能 / 状态。
- **check-plan-dispatch.sh 按列号解析**（`/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-plan-dispatch.sh`）：
  - 行 246：`col4="$(printf '%s' "$line" | awk -F'|' '{print $4}')"` → 执行体列非空检查。
  - 行 252：`col5="$(printf '%s' "$line" | awk -F'|' '{print $5}')"` → 输入列路径 token 计数。
  - 行 253：`col7="$(printf '%s' "$line" | awk -F'|' '{print $7}')"` → 预估时长列 `NNmin` 匹配。
  - 行 270：`col8="$(printf '%s' "$line" | awk -F'|' '{print $8}')"` → 粒度三值列 `Nf/Nl/Nmin` 匹配。
  - 行 282：`col3="$(printf '%s' "$line" | awk -F'|' '{print $3}')"` → 目标列步骤枚举计数。
  - 文件头注释行 27：`awk -F'|' 下 $5=输入列、$7=预估时长列`。
  - **注意**：$6（验收列）与 $9（伴飞技能列）无脚本解析；$10（状态列）亦无解析。
- **check-dispatch.sh**：不按 S-unit 表列号解析，只对派发 prompt 文本做 S-unit ID 计数（行 43/51-52/424/434-439：`grep -oE 'S[0-9]+' | sort -u | wc -l`）。
- **结论——安全插入位**：
  - awk -F'|' 下 $1=空、$2=ID、$3=目标、$4=执行体、$5=输入、$6=验收、$7=预估时长、$8=粒度三值、$9=伴飞技能、$10=状态、$11=空。
  - 现有解析只触及 $3/$4/$5/$7/$8。
  - **最安全插入位 = $10（状态列）之后追加为 $11**（不影响任何现有列号解析）。
  - 次选 = $8（粒度三值）与 $9（伴飞技能）之间插入（$9/$10 列号后移，但无脚本解析 $9/$10，实际安全；但会改变模板列序语义，不推荐）。
  - 若新增「goal id/验证方式」列，建议追加为 $11，表头 `| ... | 状态 | goal id/验证方式 |`。

---

## Q5 既有 goal 相邻机制清单（防重复设计）

- **Rule 58**（critical-rules.md）：
  - 行号范围：670-686（标题行 670，子条 58.1-58.7 至行 686）。
  - 七个子条标题：
    - 58.1（行 674）：适用判定与证据面清单（evidence-surface inventory）
    - 58.2（行 676）：对标取证强制（benchmark-evidence mandate）
    - 58.3（行 678）：结论-证据锚定与反证检查（claim-evidence anchoring）
    - 58.4（行 680）：手段/目标二分与解决判据（means-goal bifurcation）
    - 58.5（行 682）：完成裁决门（goal-achievement verdict gate）
    - 58.6（行 684）：手段-目标因果链（means-goal causal chain）
    - 58.7（行 686）：机制（零新 config 键）
- **references/goal-gate.md**（`/mnt/data/dev/task-planner-skill/skills/task-planner/references/goal-gate.md`）：
  - 总行数 18 行。
  - 结构：行 1 标题 `# Goal Gate — 目标完成判定`；行 3 VC 契约声明；行 5 `## VC 规则`（5 条：≥5 条 VC / 每 phase ≥2 条 V-N / phase 间门控 / 终验必做 / 升级阈值）；行 13 `## 退出标准`（COMPLETE/PARTIAL/BLOCKED 三态 + VC 分级语义）。
- **check-complete.sh 中 58.5 相关**：
  - 无直接 58.5 校验（grep `58.5|核心目标达成裁决|三态裁决` 无命中）。
  - 51.1 相关：行 795（R 行集合提取注释）、行 806（awk 状态机 `/^##[[:space:]].*🎯 用户需求原文/`）、行 819（SKIPPED 提示）。
  - 58.5 目前无机器门控，仅靠 selftest 静态锚 + LLM 行为。
- **selftest-evidence-goal-gate.sh 断言面**（`/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-evidence-goal-gate.sh`）：
  - 共 21 条编号断言 EG-01..EG-21。
  - 钉的文本锚：
    - EG-01..EG-09：critical-rules.md Rule 58 条款本体（`^### 58 ` 标题、`^58\.[1-7] ` 七子条、各子条标题锚 + 语义内核）。
    - EG-10：模板 `证据面清单（Rule 58.1` 区块 + 三基线面（① 自身样本 / ② 对标样本 / ③ 外部约束）。
    - EG-11：模板 `核心目标达成裁决（Rule 58.5` 区块 + 三态裁决行（solved/partial/not-solved）。
    - EG-12：需求区 [手段]/[目标] 标注引导。
    - EG-13..EG-15：SKILL.md `Rule 58` 计数 ≥2、`^\| C41 ` 合规行 =1、`selftest-evidence-goal-gate.sh` 机器面指称。
    - EG-16：critical-rules.md 58 块尾 `^66\.[0-9] ` =0（前向防线）。
    - EG-18：config.json `evidence[_-](goal|surface|verdict)` =0（零新键负断言）。
    - EG-21：init-session.sh `inject_evidence_goal_block()` 定义 =1 且调用行 =1。
- **templates/task_plan.md 中 goal 相邻区块行号**：
  - `## 🎯 用户需求原文`：行 8。
  - `## 🧮 根源覆盖表`：行 20。
  - `## 🎯 核心目标达成裁决`：行 87。
  - `## 🔍 证据面清单`：行 161。

---

## Q6 selftest 约定

- **selftest-*.sh 文件总数**：63（`ls /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-*.sh | wc -l` = 63）。
- **注册表文件**：`/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-registry.tsv`
  - 总行数 64（63 脚本 + 1 表头）。
  - 列头（4 列）：`script` / `domain` / `trigger_scenarios` / `dep_anchors`。
  - 行 58 已登记 `selftest-evidence-goal-gate.sh`（Rule 58 守护）。
- **新 selftest 注册方式**：在 selftest-registry.tsv 末尾追加一行，格式对齐既有行（script 文件名 / domain 描述 / trigger_scenarios / dep_anchors 分号分隔）。
- **钉值断言清单（新增内容后必须级联上调）**：
  - **selftest-self-resolution.sh 行 109**：`expected=$(( $(ls "$(dirname "$REGISTRY")"/selftest-*.sh 2>/dev/null | wc -l) + 1 ))` — 动态断言 registry 行数=脚本数+表头（非硬编码总数，新脚本注册后自动 +1，无需改此断言）。
  - **selftest-skill-split.sh 行 46**：`SKILL.md 行数 ≤510`（硬编码上限，当前 509 行；Rule 66 摘要行 +1 后 =510，恰好触顶，需上调至 ≥511）。
  - **selftest-batch-pilot.sh 行 55**：`SKILL.md 行数 ≤558`。
  - **selftest-drift-check-subagent.sh 行 84**：`SKILL.md 行数 ≤558`。
  - **selftest-knowledge-brief.sh 行 39**：`SKILL.md 行数 ≤558`。
  - **selftest-execution-stability.sh 行 72**：`SKILL.md 行数 ≤558`。
  - **selftest-skill-collab.sh 行 82**：`SKILL.md 行数 ≤558`。
  - **selftest-iterative-optimizer.sh 行 34**：`SKILL.md 行数 ∈ [90,120]`。
  - **selftest-dispatch-grain.sh 行 81**：`critical-rules.md 46.1..46.5 共 5 条`（子条计数，Rule 66 新增不影响）。
  - **selftest-ask-default-timeout.sh 行 83**：`critical-rules.md 44.5 条款行 = 1`（子条计数，Rule 66 新增不影响）。
  - **selftest-evidence-goal-gate.sh**：EG-16 `^66\.[0-9] =0` 前向防线——Rule 66 落地后此断言需同步演进（改为 `^66\.[0-9] =1` 或移除）。

---

## Q7 task_plan 模板

- **内置 templates/ 清单**（`/mnt/data/dev/task-planner-skill/skills/task-planner/templates/`）：
  - batch_report.md、delivery-summary.md、findings.md、knowledge-brief.md、notepad-learnings.md、progress.md、shared-tracker.md、subagent_dispatch.md、task_plan.md、verification.md（共 10 个文件）。
- **general 模板区块标题清单（顺序 + 行号）**：
  - 行 8：`## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）`
  - 行 15：`### R→VC 映射（Rule 51.2 验证机制先行）`
  - 行 20：`## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）`
  - 行 30：`## Goal`
  - 行 38：`## 🔍 Code Review 配置`
  - 行 57：`## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）`
  - 行 87：`## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）`
  - 行 104：`## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）`
  - 行 125：`## 📚 必要知识储备（任务知识库对齐 — 开工前必填）`
  - 行 144：`## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）`
  - 行 161：`## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）`
  - 行 175：`## Current Phase`
  - 行 182：`## Next Step`
  - 行 191：`## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）`
  - 行 205：`## Phases`
  - 行 213：`### Phase 1: Requirements & Discovery`
  - 行 232：`### Phase 2: Planning & Structure`
  - 行 244：`### Phase 3: Implementation`
  - 行 271：`### Phase 4: Testing & Verification`
  - 行 283：`### Phase 5: Delivery`
  - 行 295：`## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）`
  - 行 312：`## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 references/methodology.md §R2）`
  - 行 327：`## 🔁 原生 Todo 同步（S1–S5 强制）`
  - 行 343：`## Key Questions`
  - 行 354：`## Decisions Made`
  - 行 366：`## Errors Encountered`
  - 行 379：`## Notes`
  - 行 391：`## 🚨 Drift Log（漂移检测记录）`
  - 行 400：`## 📦 Batch Report（批量处理质量门控 — Rule 18.6,批量任务必填）`
  - 行 418：`## 📊 委派统计（Rule 25.4 — 终验前必填）`
  - 行 430：`## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）`
  - 行 446：`## 🔗 Chain 区块交接配置（可选）`
- **variant/ 目录**：29 个文件（audio-voice-type.md 至 writing-type.md）。
- **「🎯 Goal 单元表」新区块建议插入位**：
  - 依据区块语义排序：目标层区块（用户需求原文 → 根源覆盖表 → Goal → Verification Contract → 核心目标达成裁决）之后、执行层区块（执行范围限制）之前。
  - **建议插在「🎯 核心目标达成裁决」（行 87）之后、「⚠️ 执行范围限制」（行 104）之前**。
  - 理由：Goal 单元表是目标级固化区块，与核心目标达成裁决同属目标层；执行范围限制是执行层起点，Goal 单元表应在执行层之前固化。

---

## Q8 脚本感知面

- **硬编码引用模板区块标题的脚本**（新增「Goal 单元表」区块后需跟进）：
  - **attest-plan.sh**（`/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/attest-plan.sh`）：
    - 行 145：`grep -q '^## 🎯 用户需求原文' "$plan_file"` — 锁定门第 1 锚。
    - 行 157：`grep -qE '^##[^#].*根源覆盖表' "$plan_file"` — 锁定门第 4 锚。
    - 行 159：`echo "[attest] ✗ 缺 Rule 51.1 用户需求原文区块或第 4 锚「🧮 根源覆盖表」..."`。
    - **跟进**：若 Goal 单元表纳入锁定门，需追加第 5 锚 `grep -qE '^##[^#].*Goal 单元表'`。
  - **check-complete.sh**：
    - 行 806：`/^##[[:space:]].*🎯 用户需求原文/ {f=1; next}` — R 行集合提取 awk 状态机。
    - **跟进**：若 Goal 单元表需终验校验，需追加 awk 状态机抽区块。
  - **check-window-consistency.sh**（行 4 注释）：引用「🎯 用户需求原文」区块。
  - **init-session.sh**（`/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/init-session.sh`）：
    - 行 135：`grep -q '## 🎯 用户需求原文' "$file"` — 注入判定锚 A。
    - 行 136：`grep -q '根源覆盖表' "$file"` — 注入判定锚 B。
    - 行 283：`inject_evidence_goal_block()` 函数定义。
    - 行 634：`inject_evidence_goal_block` 主流程调用。
    - **跟进**：若 Goal 单元表需 init 注入，需追加 `inject_goal_unit_block()` 函数 + 主流程调用 + 注入判定锚 C。
  - **selftest 夹具**（selftest-execution-stability.sh 行 106/109/142/145、selftest-active-plan.sh 行 148/151、selftest-final-gate-hash.sh 行 100/106、selftest-methodology.sh 行 121/127）：
    - 夹具含 `## 🎯 用户需求原文` + `## 🧮 根源覆盖表` 双锚。
    - **跟进**：若 Goal 单元表纳入 attest 门，夹具需补 `## 🎯 Goal 单元表` 锚。
- **新增「Goal 单元表」区块后需跟进的脚本/门控**：
  1. **attest-plan.sh**：追加第 5 锚（可选，若纳入锁定门）。
  2. **init-session.sh**：追加 `inject_goal_unit_block()` 函数 + 主流程调用（若需 init 注入）。
  3. **check-plan-dispatch.sh**：若 Goal 单元表含 S-unit 列，需追加列解析（当前 S-unit 表解析 $3/$4/$5/$7/$8，Goal 单元表是独立区块，不影响）。
  4. **check-complete.sh**：若 Goal 单元表需终验校验，需追加 awk 状态机。
  5. **新 selftest**（selftest-goal-unit.sh 或同类）：静态守护 Goal 单元表区块锚 + Rule 66 子条锚 + SKILL 摘要行 + 注册表登记。
  6. **selftest-evidence-goal-gate.sh**：EG-16 `^66\.[0-9] =0` 前向防线需演进（Rule 66 落地后改为 =1 或移除）。
  7. **selftest-skill-split.sh 行 46**：SKILL.md 行数钉 ≤510 需上调（Rule 66 摘要行 +1 后 =510，触顶）。

---

## 检查点

- 报告已写入：`/mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/subagent-state/01-explore-goal-mode-recon.md`
- 8 问逐问答案完毕，所有路径为绝对路径，行号基于 2026-10-09 仓内状态。
