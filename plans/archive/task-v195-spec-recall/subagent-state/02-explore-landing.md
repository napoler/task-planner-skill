# Explore 侦察检查点 — task-v195 落点与级联面（只读侦察）

status: done | 仓库=/mnt/data/dev/task-planner-skill

## §1 规则编号现状
- 账本 plans/.rule-reservations.jsonl：末行 `{"rule":92,"status":"landed",...}`（2026-10-17 task-v185）。最高 landed=92，无 reserved/contested 93 → **next=93**。
- 无任何脚本 pin 精确字面 "1-92"/"1-93"（`grep -rn "1-92" skills/*/scripts/*.sh` = 0 命中）。
- SKILL.md 说法核验：line 9/209/251 均写 "Rules 1-92"；line 209 "核心在位 14 条（1,2,3,5,19,20,26,51,62,66,80,81,82,83）" = 计数 14 ✓。其余 73 条归 11 卫星。
- 纪元锚家族（live 行）：`1-[89][0-9]`（覆盖 90-99，故 1-93 仍命中，不破）。

## §2 核心规则文件结构
- skills/task-planner/references/critical-rules.md = 193 行。核心 14 条：1,2,3,5,19,20,26,51,62,66,80,81,82,83（line 9..171）。
- 分层说明块=line 5-8；卫星路由索引=line 181-193（11 卫星，line 184 = task-discipline 行，列 Rule 4..92）。
- Rule 82 格式样例=line 163-169（`### 82 标题（P0 — task-vXXX，目标：…；判定面=…；衔接…，既有条款原文零改动）` + 建制/边界/回归防线段）。
- skills/task-discipline/references/critical-rules-discipline.md = 588 行；末条=Rule 92 @ line 577-588；条目格式样例=Rule 88 @ line 541（`### 88 标题（P0 — task-v180，…）` + 子条 `**88.N …**`）。
- **逐字双载**：非 core↔satellite（Rule 82 line 167 明禁核心留镜像副本）；指跨域规则在**两卫星**各载全文——判例 Rule 38.7：plan-template-kit/references/critical-rules-template.md:45 + task-discipline/references/critical-rules-discipline.md:195（SKILL.md:188 明文「逐字双载」）。core↔discipline 标题交集=空（无重复）。

## §3 selftest 基线
- selftest-*.sh ≈ 100 个；统一 runner=scripts/run-selftests.sh（--fresh/--only/--status，指纹缓存）；registry=scripts/selftest-registry.tsv（93 行=表头+92 行；列=`script<TAB>domain<TAB>trigger_scenarios<TAB>dep_anchors`）。
- selftest-registry.sh：T02 每个 selftest-*.sh 必须登记（新增脚本未登记=FAIL）；T03 无孤儿行；T05 恰 4 字段。
- 纪元/编号上界断言（live）：context-pressure.sh:109-110/115、decision-drift.sh:117、execution-honesty.sh:104/106、drift-check-subagent.sh:93、requirement-coverage.sh:145-146、capability-persistence.sh:93/95、reliability-institution.sh:96/98、requirement-grading.sh:96-97、research-first.sh:86、plan-tier.sh:96、iteration-persistence.sh:163-164、lane-advancement.sh:129/131/140、root-resolution.sh:126/129/199-200、tool-selection.sh:85、self-resolution.sh:100、session-log.sh:69-71、conclusion-discipline.sh:90-95/110-112、parallel-scheduling.sh:121-122、skill-split.sh:89、reflect-verify.sh:66、error-loop.sh:75、veto.sh:62-63、batch-pilot.sh:69、workflow-orchestration.sh:83/87-89。
- AD-12 pin（硬约束）：selftest-absorption-discipline.sh:85-91 要求 5 脚本保留精确字面 `grep -cE '1-[89][0-9]'`（tool-selection/requirement-coverage/lane-advancement/self-resolution/source-anchor-discipline）+ 6 脚本宽容族。
- 上界动态对照：parallel-scheduling.sh:121-122（skill_max vs 核心 `^### 82 `）。

## §4 模板与 init 链
- init-session.sh：copy_template 从 `../templates/`（built-in）或项目 `.claude/plan-templates/`；7 文件=task_plan.md, findings.md, progress.md, notepad-learnings.md, verification.md, knowledge-brief.md, user-session-log.md（line 565/567 分流；line 627 task_plan；line 646 user-session-log）。
- templates/task_plan.md = 555 行；Phase 3 Implementation=line 304-330（S-unit 派发表 327-330）——「每 3 个 S-unit 重读规范摘要」宜插 line 309-311 checklist 或 317-326 注释块。
- progress.md 模板=templates/progress.md（非内建，init 复制）；Phase 段格式 `- **Status:**`/`- **Started:**`/Actions taken/Files/Test Results 表（line 12-35）。
- config.json：interaction_mode default=ask（line 52-59）；delegation_rate_floor default=0.7（line 36-41）；44→46 properties 键（80.6 记）。

## §5 部署与合并惯例
- ~/.zcode/skills/ 已部署 15 task-planner 族技能（+ 各卫星）。
- 部署位 vs 仓：task-planner/SKILL.md 部署 261 行 vs 仓 267 行（**滞后 6 行**）；critical-rules.md 193=193（同步）；discipline 588=588（同步）。
- 授权惯例：部署到 ~/.zcode/skills/** 属 §六 保护区，**需用户显式授权**——v192/task_plan:32「用户 R1『完成部署并推送』= 显式授权」；v191/delivery-summary:28,31「未同步（需用户单独授权重新部署，本仓改动未自动生效）」；v193/task_plan:25,48「不做：部署位同步（需用户裁决）」。

## 四问结论
① next Rule = 93
② 级联：宽锚 `1-[89][0-9]` 覆盖 93 不破；级联面=文档一致性（SKILL.md:9/209/251 + README_zh.md:136/229 + CLAUDE.md:33 + README.md + 核心路由索引 critical-rules.md:184）+（若新增 selftest-*.sh）registry.tsv 登记 + AD-12 pin +（若新增 references/*.md）doc-script-paths 扫描
③ 逐字双载仅适用跨域规则（如 38.7）；默认新规则=1 处卫星全文 + 1 处核心路由索引行
④ 部署位同步需用户显式授权，仓内改动不自动生效
