# Findings: S77 机械/智能流程分治审查

## Research Findings

### §1 Inventory（Phase 1 产出 — 2026-10-19）

**盘点范围**：/mnt/data/dev/task-planner-skill/skills/ 下全部 26 个技能（15 核心 + 11 review-library）

| # | 技能名 | 类型 | 行数 | 步骤数 | 含Agent() | S77分类 | 备注 |
|---|--------|------|------|--------|-----------|---------|------|
| 1 | task-planner | 核心 | 237 | 8顶层+子步 | 是 | needs-review | 主流程技能；Agent派发drift-checker/decision-arbiter |
| 2 | iterative-optimizer | 核心 | 97 | 5 | 否 | needs-review | 循环型执行流，写状态文件，含Gate三态 |
| 3 | plan-template-kit | 核心 | 40 | 0 | 否 | exempt-query | 纯知识层卫星，"不执行任何机械动作" |
| 4 | plan-cost-guard | 核心 | 43 | 0 | 否 | exempt-query | 纯知识层，"不执行节流判定" |
| 5 | task-drift-guard | 核心 | 91 | 6 | 否 | needs-review | 6步骤流程；只读但§3可部分豁免 |
| 6 | progress-tracker | 核心 | 199 | 8 | 否 | needs-review | 写.zcode/ledger/ JSONL账本 |
| 7 | media-planner | 核心 | 47 | 0 | 否 | exempt-query | 纯路由索引卫星 |
| 8 | task-discipline | 核心 | 89 | 0 | 否 | exempt-query | 纯规则索引文档，无Phase/Step |
| 9 | todo-skill | 核心 | 117 | 6 | 是 | needs-review | 含Agent()派发；写session-kv+Todo |
| 10 | error-fix-prompt-forge | 核心 | 84 | 5 | 否 | needs-review | 写fix-prompt.md产物，含QC-FP六项机检 |
| 11 | verification-gate | 核心 | 83 | 3 | 否 | needs-review | 执行run-verification.sh/check-complete.sh |
| 12 | plan-research-router | 核心 | 45 | 0 | 否 | exempt-query | "只读路由决策，不代替调研工具执行" |
| 13 | task-dispatch | 核心 | 62 | 0 | 否 | exempt-query | 规则索引+脚本清单文档 |
| 14 | plan-resume | 核心 | 437 | 6 | 否 | needs-review | 最大文件；§7自主裁决框架含智能判断步骤 |
| 15 | alignment-review | review | 74 | 19 | 否 | needs-review | 唯一含写动作的review技能（闸门整理/归档） |
| 16 | test-quality-review | review | 51 | 14 | 否 | needs-review | 含执行面（跑测试套件记基线） |
| 17 | image-review | review | 51 | 11 | 否 | needs-review | 同族范式 |
| 18 | general-review | review | 51 | 15 | 否 | needs-review | 兜底池最大清单 |
| 19 | code-quality-review | review | 51 | 14 | 否 | needs-review | 同族范式 |
| 20 | ui-quality-review | review | 50 | 11 | 否 | needs-review | 同族范式 |
| 21 | security-review | review | 50 | 14 | 否 | needs-review | 同族范式 |
| 22 | release-review | review | 50 | 11 | 否 | needs-review | 同族范式 |
| 23 | documentation-review | review | 50 | 11 | 否 | needs-review | 同族范式 |
| 24 | data-quality-review | review | 50 | 11 | 否 | needs-review | 同族范式 |
| 25 | content-quality-review | review | 50 | 12 | 否 | needs-review | 同族范式 |

**汇总统计**：
- needs-review: **19 个**（核心 8 + review-library 11）
- exempt-query: **7 个**（核心 7：plan-template-kit/plan-cost-guard/media-planner/task-discipline/task-dispatch/plan-research-router/plan-collab-router）
- exempt-single: **0 个**

**S77 审查优先级提示**：
1. 最高优先级 = task-planner（8顶层步+Agent派发混合）、plan-resume（437行、§7自主裁决框架含典型智能判断步骤）
2. 11个review技能清单维度高度同构（触发→清单→证据→二值结论），可批量化套用同一S77分治模板
3. 7个exempt-query卫星可整批豁免§3，只需登记"无流程/纯知识"结论

### §2 核心 8 技能 S77 分治表（Phase 2 产出 — 2026-10-19）

**审查方法**：逐技能 Read SKILL.md + references/，grep 确认 77.1 标注，`[ -e ]` 确认锚点路径存在性

| 技能 | 77.1 | 77.2 | 77.3 | 77.4 | 77.5 | 77.6 | 判定 |
|------|------|------|------|------|------|------|------|
| task-planner | ❌ | ✅ | ✅ | ⚠️ | ✅ | ⚠️ | ⚠️ |
| iterative-optimizer | ❌ | ⚠️ | ⚠️ | ❌ | ✅ | N/A | ⚠️ |
| task-drift-guard | ❌ | ✅ | ⚠️ | ⚠️ | ✅ | N/A | ⚠️ |
| progress-tracker | ❌ | ✅ | ✅ | N/A | ✅ | ⚠️ | ⚠️ |
| todo-skill | ❌ | ⚠️ | ⚠️ | ❌ | ✅ | ⚠️ | ⚠️ |
| error-fix-prompt-forge | ❌ | ✅ | ✅ | ❌ | ✅ | N/A | ⚠️ |
| verification-gate | ❌ | ✅ | ✅ | ❌ | ✅ | ⚠️ | ⚠️ |
| plan-resume | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ |

**核心 8 汇总**：0✅ / 8⚠️ / 0❌
- 77.1: 8/8 ❌（全局缺失，P1 系统性）
- 77.2: 6✅ 2⚠️（锚点密集：scripts/ + templates/）
- 77.3: 5✅ 3⚠️（check-complete.sh/run-verification.sh 等可校验）
- 77.4: 1✅ 3⚠️ 4❌（仅 plan-resume 达标）
- 77.5: 8/8 ✅（智能步骤均自然语言描述，未过度脚本化）
- 77.6: 1✅ 2⚠️ 5N/A（仅 plan-resume 达标）

**P1 发现**：
- P1-1（77.1 全局缺失）：8/8 技能均未对任何 Phase/Step 标注 M/A/M+A 属性
- P1-2（77.4 智能思路缺失）：iterative-optimizer/todo-skill/error-fix-prompt-forge/verification-gate 四个技能的智能步骤仅描述单一路径

**P2 发现**：
- P2-1: iterative-optimizer 机械侧缺模板/脚本锚点
- P2-2: task-drift-guard 三态判定无脚本/jq 校验方式
- P2-3: task-planner 智能步骤指针外置至 references/methodology.md
- P2-4: todo-skill WORKFLOW.md 标注与 SKILL.md 不一致

### §3 review-library 11 技能 S77 分治表（Phase 3 产出 — 2026-10-19）

**审查方法**：静态读全文 + grep 复核；checklist 条目 = S77 意义的「步骤」

| 技能 | 步骤数 | 77.1 | 77.2 | 77.3 | 77.4 | 77.5 | 77.6 | 判定 |
|------|-------|------|------|------|------|------|------|------|
| alignment-review | 19 | ❌ | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ⚠️ |
| test-quality-review | 14 | ❌ | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ⚠️ |
| image-review | 11 | ❌ | ❌ | ⚠️ | ❌ | ✅ | ❌ | ❌ |
| general-review | 15 | ❌ | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ⚠️ |
| code-quality-review | 14 | ❌ | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ⚠️ |
| ui-quality-review | 11 | ❌ | ❌ | ⚠️ | ❌ | ✅ | ❌ | ❌ |
| security-review | 14 | ❌ | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ⚠️ |
| release-review | 11 | ❌ | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ⚠️ |
| documentation-review | 11 | ❌ | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ⚠️ |
| data-quality-review | 11 | ❌ | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ⚠️ |
| content-quality-review | 12 | ❌ | ❌ | ⚠️ | ❌ | ✅ | ❌ | ❌ |

**review-library 11 汇总**：0✅ / 8⚠️ / 3❌
- 77.1: 11/11 ❌（全局缺失，P1 系统性）
- 77.2: 8⚠️ 3❌（仅输出合约锚点；image/ui/content 无 SOP/脚本）
- 77.3: 11/11 ⚠️（仅最终二值结论可校验）
- 77.4: 11/11 ❌（全无 ≥2 思路+选择条件）
- 77.5: 11/11 ✅（未过度脚本化）
- 77.6: 11/11 ❌（混合步骤全未拆分）

**P1 发现**：
- P1-1（77.1 全局缺失）：11/11 技能均无 M/A/M+A 标注
- P1-2（77.4 智能思路缺失）：11/11 技能智能步骤均单一路径
- P1-3（77.6 混合未拆分）：11/11 技能混合步骤全未拆分
- P1-4（77.2 机械锚点缺失，3/11）：image-review/ui-quality-review/content-quality-review 审查法以目视/通读为主，无 SOP/脚本锚点

**P2 发现**：
- P2-1（77.2 部分，11/11）：机械锚点仅覆盖输出合约层，checklist 机械动作未固化为可复用 SOP 段/脚本
- P2-2（77.3 部分，11/11）：机械可校验仅覆盖最终二值结论，各步骤中间产出无 schema/字段校验

**❌ 缺失技能（3 个）**：image-review / ui-quality-review / content-quality-review — 审查法以定性目视/通读为核心，机械锚点与智能描述双缺

## Technical Decisions

| Decision | Rationale |
|----------|-----------|
| 纯只读审查 | 用户要求「审查」非「修复」；修复需 worktree 另开任务 |

## Issues Encountered

| Issue | Resolution | Prevention |
|-------|-----------|------------|

## Resources

- Skill Fix S77 规范: ~/.zcode/skills/skill-fix/references/mechanical-adaptive-split.md
- 诊断报告参考: plans/skill-audit-20261019/diagnostic-report.md
