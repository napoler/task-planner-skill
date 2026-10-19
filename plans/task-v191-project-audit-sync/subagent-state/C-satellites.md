# C 卫星技能交叉引用一致性审计 — 检查点（子代理 C-satellites）

仓根=/mnt/data/dev/task-planner-skill；11 卫星=skills/ 下 task-dispatch, task-discipline, verification-gate, media-planner, plan-collab-router, plan-research-router, plan-resume, plan-template-kit, plan-cost-guard, progress-tracker, task-drift-guard。
审计=复核 2026-10-19 审计报告 F4/F6/F7/F8/P2-1/P2-3/P2-4 现状 + 四类错误全量扫描。全部第一手验证（grep/ls/jq 实跑）。

## 一、指定项逐条判定（F4/F6/F7/F8/P2-1/P2-3/P2-4）

### F4 — task-planner 侧 `skills/卫星/`→`../卫星/`（S64 同内混用）——【已修】
- 位置：skills/task-planner/SKILL.md:158；references/critical-rules.md:183-193；references/completion-gate.md:5；references/goal-gate.md:5
- 证据（现行，已改 ../ 或 ../../）：
  - SKILL.md:158 `现权威位置=../plan-template-kit/references/critical-rules-template.md:45 + ../task-discipline/references/critical-rules-discipline.md:191`（SKILL.md 在 skills/task-planner/ 一级，../ 正确）
  - critical-rules.md:183 `../../task-dispatch/references/critical-rules-dispatch.md`（references/ 二级，../../ 正确；183-193 十一行全为 ../../卫星/）
  - completion-gate.md:5 / goal-gate.md:5 `../../verification-gate/references/critical-rules-verification.md`
- 判定：原「SKILL.md:158 写 skills/plan-template-kit/...」已消除，四文件均改对 → 已修。

### F6 — task-dispatch/task-discipline 规则全文指向 task-planner 缺前缀（S64，40+ 处）——【部分修】
- 现状：两 references/ 文件对 task-planner 的 scripts/ 多数已加 `../../task-planner/scripts/`（实测 task-discipline/references/critical-rules-discipline.md `../../task-planner/`=36 处；task-dispatch/references/critical-rules-dispatch.md `../../task-planner/`=16 处，含 :8 `../../task-planner/references/worktree-isolation.md`、:3 来源行），F6 原举的 `:8 合约见 references/worktree-isolation.md`、`:29 scripts/selftest-error-loop.sh` 裸名已改前缀。
- 未修残留（裸名仍指 task-planner 侧，实测目标均存在于 task-planner/）：
  - critical-rules-dispatch.md：`config.json#...` 裸 @ :21,51,52,53,58,62,106,142；`templates/knowledge-brief.md`@:22、`templates/subagent_dispatch.md`@:23,41,60,61,96,119、`templates/task_plan.md`@:175（均 task-planner/templates/，缺 ../../task-planner/ 前缀）
  - critical-rules-discipline.md：`config.json#...` 裸 @ :26,50,63,66,80,92,103,109,339,359；`templates/{delivery-summary,deprecated,notepad-learnings,progress,session-handoff,subagent_dispatch,task_plan}.md` 裸 @ :80,92,213,221,375,394,430,468,472,485；`scripts/selftest-*` 仍有裸残留 @ :21(selftest-task-boundary),125(selftest-registry.tsv) 等（36 处带前缀，但同文件另有裸 selftest 名）
- 判定：scripts 类已修、config.json# 与 templates/ 及少量 selftest 裸名未修 → 部分修。

### F7 — verification-gate 对 selftest-verification-gate.sh 位置描述矛盾（S40/S64）——【已修】
- 位置：verification-gate/references/critical-rules-verification.md:44 vs SKILL.md:74
- 证据：:44 `selftest-verification-gate.sh（task-planner/scripts/，机械层留守主技能）`（原写「本卫星 scripts/」已改）；SKILL.md:74 `selftest-verification-gate.sh | 静态守护（Rule 84 锚，机械层留守主技能） | ../task-planner/scripts/`。两处一致。
- 实测：verification-gate/scripts/ 仅 run-verification.sh；selftest-verification-gate.sh 存在于 task-planner/scripts/（ls 证实）→ 已修。

### F8 — plan-cost-guard/plan-template-kit 双重拼接 + 缺 ../task-planner/ 前缀（S64）——【部分修】
- 双重拼接（`../自身/...`）：全仓 grep `../plan-cost-guard/ ../plan-template-kit/ ...` 已 0 命中（原 cost.md:9 自指双拼已除，现 cost.md:9 `详见 cost-control.md` 裸名同目录正确）。
- 缺 `../task-planner/` 前缀（references/ 二级需 ../../task-planner/）：
  - task-drift-guard/references/critical-rules-drift.md:55 `bash ../task-planner/scripts/ledger-append.sh` —— 用了一级 `../`，相对 references/ 会解析到 skills/task-drift-guard/task-planner/（不存在），正确应为 `../../task-planner/scripts/ledger-append.sh`（与 dispatch/discipline 的 ../../ 约定不一致；ledger-append.sh 实测存在于 task-planner/scripts/）→ 未修
  - plan-template-kit/references/critical-rules-template.md:15,20,21 `scripts/check-template-type.sh`、:16,20,21 `scripts/selftest-template-lifecycle.sh`、:50 `scripts/lane-detect.sh`、:31 `scripts/selftest-mechanism-profile.sh`、:43 `scripts/selftest-plan-tier.sh`、:20/31/43 `config.json#...`、:15/18/21/40 `templates/variant` 均裸名（无 ../../task-planner/ 前缀；目标全在 task-planner 侧存在）→ 未修
  - plan-template-kit/references/template-guide.md:265,314-317 `scripts/{check-complete,init-session,check-scope,sync-todos}.sh` 裸；template-mapping.md:248 `scripts/check-complete.sh` 裸；billing.md(plan-cost-guard):16,40,57 `scripts/session-catchup.ts` 裸 → 未修
- 已修面：task-drift-guard/SKILL.md:90,91 已带 `../task-planner/references/critical-rules.md`、`../task-planner/scripts/selftest-drift-check-subagent.sh`（SKILL.md 一级 ../ 正确）；plan-template-kit/SKILL.md:17,24 `../task-planner/templates/variant/`、`../task-planner/scripts/selftest-template-lifecycle.sh` 正确。
- 判定：SKILL.md 一级已修；references/ 二级 critical-rules-*/guide/mapping/billing 仍大量裸名 + drift critical-rules 一级深度错 → 部分修（残留为主）。

### P2-1 — task-discipline 索引表漏 Rule 85-90 + 计数不一致——【未修】
- 位置：task-discipline/SKILL.md
- 证据：规则索引表（:32-68）实测仅 37 行，末行 `| 92 | 产出文件尺寸纪律与优先拆分 |`，无 85/86/87/88/89/90 六行（grep `^| 85 `..`=0`）。:15「共 43 条」、:70「本索引现共 43 条全文可消费」、:81「43 条规则全文（含后补落盘的 Rule 85/86/87/88/89/90/92）」均写 43。计数 41/42 互斥已消除（统一 43），但索引表 37 行 ≠ 43，缺 85-90 六行仍在 → 未修（计数统一了，表仍缺行）。
- 佐证：critical-rules-discipline.md 实有 55 个 `### ` 锚（含 70.x/72.x 子节），主 Rule 4,6,7,8,9,10,18,28,29,31,...,76,85,86,87,88,89,90,92 均在（:503=85,:515=86,:527=87,:541=88,:553=89,:565=90,:577=92）。

### P2-3 — 三卫星 frontmatter 风格分裂（tools: vs allowed-tools:、缺 model、verification-gate 缺 Bash）——【已修】
- 证据（现行 frontmatter）：
  - task-dispatch/SKILL.md:4 `allowed-tools: "Read, Write, Edit, Bash, Grep, Glob"`（原 `tools:` 已改 allowed-tools）
  - task-discipline/SKILL.md:4 `allowed-tools: "Read, Write, Edit, Bash, Grep, Glob"`（同上）
  - verification-gate/SKILL.md:5-6 `model: haiku` + `allowed-tools: "Read, Bash, Grep, Glob"`（原无 tools 已补，含 Bash）
- 判定：原「task-dispatch/task-discipline 用 tools:、verification-gate 无 tools」三处分裂已消除，键名统一 allowed-tools、verification-gate 补 Bash → 已修。
- 残留（P2，非原 P2-3 三卫星级别）：media-planner/SKILL.md:4 仍 `tools: [Read, Write, Edit, Bash, Grep, Glob]`（未统一 allowed-tools）；progress-tracker/task-drift-guard 仅 `model: haiku` 无 tools；5 个 plan-*/knowledge 卫星（plan-collab-router/plan-research-router/plan-resume/plan-template-kit/plan-cost-guard）frontmatter 无 model 无 tools。属同类风格分裂残留。

### P2-4 — S25 触发词交叠未划界（「返回校验」「调研」）——【已修】
- 证据（现行 description）：
  - task-dispatch/SKILL.md:3 `返回格式与段结构归本技能，返回内容正确性与 Read 复核归 verification-gate`（「返回」边界已声明）
  - verification-gate/SKILL.md:3 `子代理返回内容复核归本技能，返回格式/段结构校验归 task-dispatch`（对偶声明）
  - task-discipline/SKILL.md:3 含「调研」；task-dispatch/SKILL.md 全文 grep「调研」=0 命中（「调研」交叠已除，调研归属 plan-research-router/discipline）
- 判定：两处交叠均已加边界声明 → 已修。

## 二、全量扫描新发现（第一手验证）

### N1 [P1] 双宿主跨技能引用 `../卫星/` 在 references/ 二级深度不足
- task-drift-guard/references/critical-rules-drift.md:55 `bash ../task-planner/scripts/ledger-append.sh` —— 相对本文件目录（skills/task-drift-guard/references/）应上两级 `../../task-planner/`，现 `../task-planner/` 解析到 skills/task-drift-guard/task-planner/（不存在）。同侧 critical-rules-progress.md:16 `../plan-collab-router/references/skill-collabelation.md`、batch-quality-gate.md:141 `../plan-cost-guard/references/cost-control.md` 同深度错误。
- 对照：dispatch/discipline 的 references/ 均已用 `../../task-planner/`（36/16 处），说明仓内已采纳「references/ 二级=../../」约定 → 上述三处为漏改。
- 建议：三处 references/ 二级跨技能引用统一改 `../../<sat>/`。

### N2 [P1] critical-rules-dispatch.md:57 残留双拼路径（F8 同型）
- task-dispatch/references/critical-rules-dispatch.md:57 `../plan-collab-router/../../plan-collabelation.md`（`../plan-collab-router/../../plan-collab-router/references/skill-collabelation.md` 双拼，虽能解析但为 F8 双拼残留，应改 `../../plan-collabelation.md`）。

### N3 [P2] config.json# 键引用裸名（缺 ../../task-planner/ 前缀）集中在 critical-rules
- critical-rules-discipline.md（:26,50,63,66,80,92,103,109,339,359）与 critical-rules-dispatch.md（:21,51,52,53,58,62,106,142）、critical-rules-template.md（:20,31,43）共 21 处 `config.json#...` 裸名指 task-planner/config.json（键实测均存在于 task-planner/config.json properties，jq 验证）→ 缺前缀。
- 对照同文件 scripts/ 已加前缀 → 同类未修。

### N4 [P2] templates/ 资源裸名（缺 ../../task-planner/ 前缀）
- critical-rules-template.md:15,18,21,40 `templates/variant`；critical-rules-template.md 与 template-guide/template-mapping 内 `templates/task_plan.md`（:40,48,98,120,142,165 等）；critical-rules-dispatch.md:22,23,41,60,61,96,119,175 `templates/{knowledge-brief,subagent_dispatch,task_plan}.md`；critical-rules-discipline.md:80,92,213,221,375,394,430,468,472,485 `templates/*.md`。目标均存在 task-planner/templates/（ls 证实）→ 缺前缀（F6/F8 未修残留）。
- 注：部分 templates/task_plan.md 为「产出物模板」语义（指 plans/ 内生成的 task_plan.md 或占位），需逐处甄别；但 `templates/variant`、`templates/knowledge-brief/subagent_dispatch` 等明确指 task-planner/templates/ 资源（task-planner/templates/ ls 证实存在）。
- plan-resume/SKILL.md:246 `scripts/session-catchup.ts` 裸名指 task-planner/scripts/session-catchup.ts（存在）→ 缺前缀，同类未修。
- verification-gate/templates/verification.md:97,101 `scripts/check-delegation.sh` + :110 `config.json#delegation_rate_floor` 裸名缺 `../../task-planner/` 前缀（目标均存在 task-planner 侧）。

### N5 [P2] 跨技能 `../卫星/references` 在 references/ 二级深度不足（N1 同型扩展）
- 除 N1 三处外，`../../<sat>/` 形式已用于 progress-tracker→plan-collab-router（N1 提到 critical-rules-progress.md:16 用了 ../，非 ../../）。建议统一。

### N6 [P2] 脚本注释内 skills/<sat>/ 路径（F4 同型，脚本侧未清）
- task-planner/scripts/*.sh 注释内大量 `skills/task-planner/...`、`skills/task-dispatch/...`（grep `skills/task- skills/plan- skills/media- skills/progress- skills/verification-` 命中 70 个 .sh）。属 F4「skills/卫星/」形式残留（注释/引用说明），非可执行路径，S64 歧义（须从仓根解析）。例：selftest-evidence-goal-gate.sh:71、selftest-reflect-verify.sh:24、subagent-granularity-skill-escort.sh:51。
- 判定：F4 主体（SKILL.md/references/）已修，但 scripts/ 注释面未清 → 残留。

### N9 [P3] verification-gate/SKILL.md:39 示例命令 `bash scripts/check-x.sh <plan>` 为占位虚构脚本名（仓内不存在 check-x.sh）
- 属 84.1 三选一示例（「如」字示意），低风险；但与其他真实脚本名混排易被 grep 锚误认。建议改真脚本名或加「示例」字样。

### N7 [P3] task-planner 注释引用 satellite scripts 旧路径 `$SCRIPT_DIR/../task-dispatch`（F9 类注释）
- selftest-subagent-granularity-skill-escort.sh:59 / selftest-skill-collab.sh:15 / selftest-subagent-return.sh:11 注释「旧写法 $SCRIPT_DIR/../task-dispatch 少一级」——为历史根因说明（已迁移注），非活引用，低风险。

### N8 [P2] media-planner frontmatter 用 `tools:` 未统一 `allowed-tools:`（P2-3 残留）
- media-planner/SKILL.md:4 `tools: [Read, Write, Edit, Bash, Grep, Glob]`（列表式 tools:），与 dispatch/discipline/verification-gate 的字符串式 `allowed-tools:` 分裂 → 未统一。

## 三、负结果（搜过未发现）
- 双拼 `../<自身>/` 全仓 0 命中（F8 自指双拼已除；仅 critical-rules-dispatch.md:57 跨技能双拼 N2 一处残留）。
- plan-resume 本地脚本引用无误：scan-plans.sh/extract-meta.sh/score-plans.py/select-and-resume.sh 均在 plan-resume/scripts/ 本地存在；config.json#autonomous_resume 键在本地 plan-resume/config.json 存在（jq 证实）；tests/smoke.sh:298 `$SKILL_DIR/../plan-resume/SKILL.md` 中 SKILL_DIR=tests/ 上级（plan-resume 技能根）→ 解析正确。唯 SKILL.md:246 `scripts/session-catchup.ts` 为 task-planner 侧裸名（见 N4）。
- verification-gate/SKILL.md:82 `scripts/run-verification.sh`、:57 `bash <skill>/scripts/run-verification.sh` 指本卫星本地脚本（存在）→ 非跨技能，无误。
- 各卫星 name=目录名（frontmatter name 与目录逐一核对 11/11 一致）→ 未发现错位。
