# 任务书：第二世代守卫锚演进（Rule 64 合入后，Handoff #11，executor 执行）

## 背景
master（18b281d，task-v148 的 Rule 64 偏移检查留痕强制）已并入本任务分支（merge c5ae31a）。critical-rules.md 现含 Rule 63（63.1-63.6）与 Rule 64（64.1-64.6）双块。由此产生两层必然级联：
- **SKILL.md 计数真值**：v148 条款 64.6 明文「SKILL 计数措辞本次不动（63 未落地避免计数失真）」——即 63 落地时由 63 侧统一演进。现 63+64 双落，SKILL 必须演进为 `Critical Rules 1-64` 与 `Rule 40-64 全集`，否则索引失真（Rule 54/51.8 同面）。
- **守卫字面锚随规则号演进**：v144 已立范式（各脚本内 `[task-v144 合并级联]` 注释即模板），本世代=第二世代（`1-63`→`1-64`、尾部负断言 `^64\.`→`^65\.`）。

## 需求锚
R4（有理有据）——计数与全集括注必须反映实际规则集；53.2 根治判据=守卫载体随规则演进同步。

## 计划三文件（22.4a 读写契约）
- /mnt/data/dev/task-planner-skill/plans/task-v147-research-first/task_plan.md —— 只读
- /mnt/data/dev/task-planner-skill/plans/task-v147-research-first/findings.md —— 可读+可写=仅追加你自己的小节 `#### [sub:11-executor] 第二世代锚演进回执` 到「## Research Findings」段末尾
- /mnt/data/dev/task-planner-skill/plans/task-v147-research-first/progress.md —— 可读+仅在 Phase 4 段「Actions taken」下追加 `[sub:11]` 子项
- /mnt/data/dev/task-planner-skill/plans/task-v147-research-first/knowledge-brief.md —— 只读；必读 §4 易错点

## 改动面（worktree /mnt/data/dev/task-planner-skill-worktrees/task-v147-research-first 内）
- **SKILL.md**（skills/task-planner/SKILL.md）：
  - `Critical Rules 1-63` → `Critical Rules 1-64`（三处：索引行/Critical Rules 头注/References 表行）
  - `Rule 40-63 全集` → `Rule 40-64 全集`（头注处）
  - Critical Rules bullet 列表 Rule 63 bullet 之后追加一行（逐字照抄）：
    `- **Rule 64（偏移检查留痕强制与节奏化触发纪律 — task-v148）**：留痕三件套=检查点+ledger drift_check+Drift Log 行（64.1）；Phase complete 第三条件门控=check-3file-gate 追加 drift_check 痕迹必查（64.2）；节奏提醒=posttooluse 每 ≥10 次工具调用注入单行提醒（64.3）；判定输入三锚=Goal 原文+近期动作+scope 文件集，无锚 ALIGNED 无效（64.4）；机制=selftest-drift-enforcement.sh+零新 config 键（env 降档，64.5/64.6）（详见 references/critical-rules.md Rule 64）`
  - References 表行 critical-rules 行内 `Rule 63 检索优先与反推诿纪律）` → `Rule 63 检索优先与反推诿纪律 / Rule 64 偏移检查留痕强制与节奏化触发纪律）`
- **六个守卫脚本字面锚 1-63→1-64**（scripts/ 下；注释行+断言行+ok/bad 文案同步；每处追加演进注 `[2026-10-08 task-v147 第二代级联] '1-63'→'1-64'：Rule 64 已由 task-v148 落地（64.1-64.6），锚同步演进`）：
  - selftest-lane-advancement.sh / selftest-requirement-coverage.sh / selftest-self-resolution.sh / selftest-tool-selection.sh（各 `'Critical Rules 1-63'` 锚）
  - selftest-workflow-orchestration.sh（族求和 `'Critical Rules 1-63'`+`'1-63'` 双模式）
  - selftest-drift-check-subagent.sh（DCS-11 `Rule 40-63 全集` → `Rule 40-64 全集`）
- **四个尾部负断言 `^64\.[0-9] ` → `^65\.[0-9] `**（同款演进注）：
  - selftest-four-file-dataflow.sh（FF-16 :27 注释+:108 断言）
  - selftest-evidence-goal-gate.sh（EG-16 各处）
  - selftest-iteration-persistence.sh（IP-14 各处）
  - selftest-requirement-coverage.sh（RC-15 各处）
- **本任务守护脚本** scripts/selftest-research-first.sh：
  - RF-06 断言 `1-63` → `1-64`；RF-07 第二锚 `Critical Rules 1-63（含 Rule 40-63 全集` → `Critical Rules 1-64（含 Rule 40-64 全集`；RF-10 `cntf '^64\.[0-9] '` → `'^65\.[0-9] '` 且残留检查 `^63\.[0-9] ` → `^64\.[0-9] `（头注释描述同步）
- **残留扫描**：`grep -rn '1-62\|1-63\|Rule 40-62\|Rule 40-63' scripts/*.sh` 与 `grep -rn '6[34]\\\\\.\[0-9\]' scripts/selftest-*.sh`（转义形态多变，用 grep -F 尝试 `^64\.[0-9] ` 与 `^63\.[0-9] ` 两种字面）——扫描出的**额外**锚演进点（预计含 v148 新增 selftest-drift-enforcement.sh 内同类锚，若有）逐个登记并同范式宽化；只登记+宽化，禁改任何断言语义结构/阈值。

## 验收标准（在 scripts/ 目录内运行，逐项回执）
- 全量 `for f in selftest-*.sh; do bash $f; done` 汇总：ΣFAIL=4 且 FAIL 全部来自 selftest-periodic-review.sh（基线预存 PR-03/04/05/10）
- bash selftest-research-first.sh → 12 PASS=12 FAIL=0
- bash selftest-drift-enforcement.sh（v148 新脚本，若断言面涉及 SKILL 则如实记录其结果——它断言的 SKILL 接线属 v148 未落地面，FAIL 不属于你的修复范围，登记即可）
- `git -C <worktree> diff --stat` 文件清单登记（预计 ≤14 文件）

## Scope 禁改清单
仅允许 Edit 上述 SKILL.md + 扫描命中的 selftest 脚本；禁止改 critical-rules.md/模板/业务脚本/其他文档；禁止任何 git add/commit；禁止改计划三文件既有内容；**禁止触碰 selftest-drift-enforcement.sh 的断言语义**（v148 财产，只登记其结果）。

## 工作路径 / 预算
- 工作路径：/mnt/data/dev/task-planner-skill-worktrees/task-v147-research-first
- 时长预算：15min；上下文预算：Grep 定位后局部 Read，禁通读全仓
- 检索优先契约（Rule 63 dogfood）：遇到不确定（锚形态/转义差异）→ 先 Read 源码定位（附 file:line），穷尽前禁止以「不知道」作答；无法解决→blockers+已检索清单，禁止编造

## 检查点（22.8，T1-T5）
/mnt/data/dev/task-planner-skill/plans/task-v147-research-first/subagent-state/11-executor.md —— 里程碑即落盘；T5 最终结论段=8 字段块置 status。

## 返回格式（严格，8 字段，字段后无内容）
status: done|partial|failed|timeout
acceptance: n/total 逐项 PASS/FAIL 及 ≤20 字原因
files: 绝对路径 +N/-M
evidence: file:line 或 命令→关键输出
checkpoint: 绝对路径 + status
findings_written: 小节锚点|none
blockers: none|一句话
confidence: HIGH|MED|LOW
