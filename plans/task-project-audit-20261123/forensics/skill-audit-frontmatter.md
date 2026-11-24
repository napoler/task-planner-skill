# [FM-LINT] Frontmatter Mechanical Audit

- Task: `task-project-audit-20261123` / Phase 2a
- Scope: 31 SKILL.md (21 top-level + 10 review-library subskills requested; `ui-quality-review` included as 11th review-library file present)
- Rules: R1 required fields, R2 name==dir, R3 model format, R4 tools vs body, R5 description vs body
- Method: read-only Python YAML-frontmatter parse + regex heuristics; no skill files modified

## Findings

- [ERROR] `skills/context-corrector/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description, model` | fix: 补齐缺失字段: tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/context-corrector/SKILL.md:1` R4 — evidence: `正文提及工具: Read` | fix: 补充 tools 字段或确认该技能契约不声明 tools
- [ERROR] `skills/error-fix-prompt-forge/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description` | fix: 补齐缺失字段: model, tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/error-fix-prompt-forge/SKILL.md:1` R4 — evidence: `正文提及工具: Read` | fix: 补充 tools 字段或确认该技能契约不声明 tools
- [ERROR] `skills/iterative-optimizer/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description` | fix: 补齐缺失字段: model, tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/iterative-optimizer/SKILL.md:1` R4 — evidence: `正文提及工具: Read` | fix: 补充 tools 字段或确认该技能契约不声明 tools
- [ERROR] `skills/longform-continuity/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description` | fix: 补齐缺失字段: model, tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/longform-continuity/SKILL.md:1` R4 — evidence: `正文提及工具: Read` | fix: 补充 tools 字段或确认该技能契约不声明 tools
- [ERROR] `skills/md-edit-ops/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description` | fix: 补齐缺失字段: model, tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/md-edit-ops/SKILL.md:1` R4 — evidence: `正文提及工具: Edit` | fix: 补充 tools 字段或确认该技能契约不声明 tools
- [ERROR] `skills/media-planner/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description, allowed-tools` | fix: 补齐缺失字段: model, tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/media-planner/SKILL.md:1` R4 — evidence: `正文提及工具: Read` | fix: 补充 tools 字段或确认该技能契约不声明 tools
- [ERROR] `skills/plan-collab-router/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description` | fix: 补齐缺失字段: model, tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/plan-collab-router/SKILL.md:1` R4 — evidence: `正文提及工具: Read, Skill` | fix: 补充 tools 字段或确认该技能契约不声明 tools
- [ERROR] `skills/plan-cost-guard/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description` | fix: 补齐缺失字段: model, tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/plan-cost-guard/SKILL.md:1` R4 — evidence: `正文提及工具: AskUserQuestion, Read, Skill` | fix: 补充 tools 字段或确认该技能契约不声明 tools
- [ERROR] `skills/plan-history-recall/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, model, description` | fix: 补齐缺失字段: tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/plan-history-recall/SKILL.md:1` R4 — evidence: `正文提及工具: Task` | fix: 补充 tools 字段或确认该技能契约不声明 tools
- [ERROR] `skills/plan-research-router/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description` | fix: 补齐缺失字段: model, tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/plan-research-router/SKILL.md:1` R4 — evidence: `正文提及工具: Read, Skill, WebSearch` | fix: 补充 tools 字段或确认该技能契约不声明 tools
- [ERROR] `skills/plan-resume/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, model, description` | fix: 补齐缺失字段: tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/plan-resume/SKILL.md:1` R4 — evidence: `正文提及工具: Read, Task` | fix: 补充 tools 字段或确认该技能契约不声明 tools
- [ERROR] `skills/plan-template-advisor/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description` | fix: 补齐缺失字段: model, tools；review stub 若契约允许可在文档说明豁免
- [ERROR] `skills/plan-template-kit/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description` | fix: 补齐缺失字段: model, tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/plan-template-kit/SKILL.md:1` R4 — evidence: `正文提及工具: Read, Skill` | fix: 补充 tools 字段或确认该技能契约不声明 tools
- [ERROR] `skills/progress-tracker/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description, model` | fix: 补齐缺失字段: tools；review stub 若契约允许可在文档说明豁免
- [ERROR] `skills/task-discipline/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description, allowed-tools` | fix: 补齐缺失字段: model, tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/task-discipline/SKILL.md:1` R4 — evidence: `正文提及工具: Read` | fix: 补充 tools 字段或确认该技能契约不声明 tools
- [ERROR] `skills/task-dispatch/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description, allowed-tools` | fix: 补齐缺失字段: model, tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/task-dispatch/SKILL.md:1` R4 — evidence: `正文提及工具: Read` | fix: 补充 tools 字段或确认该技能契约不声明 tools
- [ERROR] `skills/task-drift-guard/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description, model` | fix: 补齐缺失字段: tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/task-drift-guard/SKILL.md:1` R4 — evidence: `正文提及工具: Read, Task` | fix: 补充 tools 字段或确认该技能契约不声明 tools
- [ERROR] `skills/task-planner/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, agent, description, allowed-tools, user-invocable, references, model` | fix: 补齐缺失字段: tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/task-planner/SKILL.md:1` R4 — evidence: `正文提及工具: Edit, Read, Skill, Write` | fix: 补充 tools 字段或确认该技能契约不声明 tools
- [ERROR] `skills/todo-skill/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description, allowed-tools, model` | fix: 补齐缺失字段: tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/todo-skill/SKILL.md:1` R4 — evidence: `正文提及工具: Skill` | fix: 补充 tools 字段或确认该技能契约不声明 tools
- [ERROR] `skills/verification-gate/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description, model, allowed-tools` | fix: 补齐缺失字段: tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/verification-gate/SKILL.md:1` R4 — evidence: `正文提及工具: Read` | fix: 补充 tools 字段或确认该技能契约不声明 tools
- [ERROR] `skills/workflow-model-tiers/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description, trigger` | fix: 补齐缺失字段: model, tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/workflow-model-tiers/SKILL.md:1` R4 — evidence: `正文提及工具: Task` | fix: 补充 tools 字段或确认该技能契约不声明 tools
- [WARN] `skills/task-planner/review-library/alignment-review/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description` | fix: 补齐缺失字段: model, tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/task-planner/review-library/alignment-review/SKILL.md:1` R4 — evidence: `review stub 正文提及工具: Read` | fix: 若为 stub 契约可忽略；否则声明 tools 字段
- [WARN] `skills/task-planner/review-library/code-quality-review/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description` | fix: 补齐缺失字段: model, tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/task-planner/review-library/code-quality-review/SKILL.md:1` R4 — evidence: `review stub 正文提及工具: Read` | fix: 若为 stub 契约可忽略；否则声明 tools 字段
- [WARN] `skills/task-planner/review-library/content-quality-review/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description` | fix: 补齐缺失字段: model, tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/task-planner/review-library/content-quality-review/SKILL.md:1` R4 — evidence: `review stub 正文提及工具: Read` | fix: 若为 stub 契约可忽略；否则声明 tools 字段
- [WARN] `skills/task-planner/review-library/data-quality-review/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description` | fix: 补齐缺失字段: model, tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/task-planner/review-library/data-quality-review/SKILL.md:1` R4 — evidence: `review stub 正文提及工具: Read` | fix: 若为 stub 契约可忽略；否则声明 tools 字段
- [WARN] `skills/task-planner/review-library/documentation-review/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description` | fix: 补齐缺失字段: model, tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/task-planner/review-library/documentation-review/SKILL.md:1` R4 — evidence: `review stub 正文提及工具: Read` | fix: 若为 stub 契约可忽略；否则声明 tools 字段
- [WARN] `skills/task-planner/review-library/general-review/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description` | fix: 补齐缺失字段: model, tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/task-planner/review-library/general-review/SKILL.md:1` R4 — evidence: `review stub 正文提及工具: Read` | fix: 若为 stub 契约可忽略；否则声明 tools 字段
- [WARN] `skills/task-planner/review-library/image-review/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description` | fix: 补齐缺失字段: model, tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/task-planner/review-library/image-review/SKILL.md:1` R4 — evidence: `review stub 正文提及工具: Read` | fix: 若为 stub 契约可忽略；否则声明 tools 字段
- [WARN] `skills/task-planner/review-library/release-review/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description` | fix: 补齐缺失字段: model, tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/task-planner/review-library/release-review/SKILL.md:1` R4 — evidence: `review stub 正文提及工具: Read` | fix: 若为 stub 契约可忽略；否则声明 tools 字段
- [WARN] `skills/task-planner/review-library/security-review/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description` | fix: 补齐缺失字段: model, tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/task-planner/review-library/security-review/SKILL.md:1` R4 — evidence: `review stub 正文提及工具: Read` | fix: 若为 stub 契约可忽略；否则声明 tools 字段
- [WARN] `skills/task-planner/review-library/test-quality-review/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description` | fix: 补齐缺失字段: model, tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/task-planner/review-library/test-quality-review/SKILL.md:1` R4 — evidence: `review stub 正文提及工具: Read` | fix: 若为 stub 契约可忽略；否则声明 tools 字段
- [WARN] `skills/task-planner/review-library/ui-quality-review/SKILL.md:1` R1 — evidence: `--- frontmatter keys: name, description` | fix: 补齐缺失字段: model, tools；review stub 若契约允许可在文档说明豁免
- [WARN] `skills/task-planner/review-library/ui-quality-review/SKILL.md:1` R4 — evidence: `review stub 正文提及工具: Read` | fix: 若为 stub 契约可忽略；否则声明 tools 字段

## Per-skill Checklist

| 技能名 | 路径 | ERROR数 | WARN数 | 结论 |
|---|---|---:|---:|---|
| context-corrector | `skills/context-corrector/SKILL.md` | 1 | 1 | FAIL |
| error-fix-prompt-forge | `skills/error-fix-prompt-forge/SKILL.md` | 1 | 1 | FAIL |
| iterative-optimizer | `skills/iterative-optimizer/SKILL.md` | 1 | 1 | FAIL |
| longform-continuity | `skills/longform-continuity/SKILL.md` | 1 | 1 | FAIL |
| md-edit-ops | `skills/md-edit-ops/SKILL.md` | 1 | 1 | FAIL |
| media-planner | `skills/media-planner/SKILL.md` | 1 | 1 | FAIL |
| plan-collab-router | `skills/plan-collab-router/SKILL.md` | 1 | 1 | FAIL |
| plan-cost-guard | `skills/plan-cost-guard/SKILL.md` | 1 | 1 | FAIL |
| plan-history-recall | `skills/plan-history-recall/SKILL.md` | 1 | 1 | FAIL |
| plan-research-router | `skills/plan-research-router/SKILL.md` | 1 | 1 | FAIL |
| plan-resume | `skills/plan-resume/SKILL.md` | 1 | 1 | FAIL |
| plan-template-advisor | `skills/plan-template-advisor/SKILL.md` | 1 | 0 | FAIL |
| plan-template-kit | `skills/plan-template-kit/SKILL.md` | 1 | 1 | FAIL |
| progress-tracker | `skills/progress-tracker/SKILL.md` | 1 | 0 | FAIL |
| task-discipline | `skills/task-discipline/SKILL.md` | 1 | 1 | FAIL |
| task-dispatch | `skills/task-dispatch/SKILL.md` | 1 | 1 | FAIL |
| task-drift-guard | `skills/task-drift-guard/SKILL.md` | 1 | 1 | FAIL |
| task-planner | `skills/task-planner/SKILL.md` | 1 | 1 | FAIL |
| todo-skill | `skills/todo-skill/SKILL.md` | 1 | 1 | FAIL |
| verification-gate | `skills/verification-gate/SKILL.md` | 1 | 1 | FAIL |
| workflow-model-tiers | `skills/workflow-model-tiers/SKILL.md` | 1 | 1 | FAIL |
| alignment-review | `skills/task-planner/review-library/alignment-review/SKILL.md` | 0 | 2 | WARN |
| code-quality-review | `skills/task-planner/review-library/code-quality-review/SKILL.md` | 0 | 2 | WARN |
| content-quality-review | `skills/task-planner/review-library/content-quality-review/SKILL.md` | 0 | 2 | WARN |
| data-quality-review | `skills/task-planner/review-library/data-quality-review/SKILL.md` | 0 | 2 | WARN |
| documentation-review | `skills/task-planner/review-library/documentation-review/SKILL.md` | 0 | 2 | WARN |
| general-review | `skills/task-planner/review-library/general-review/SKILL.md` | 0 | 2 | WARN |
| image-review | `skills/task-planner/review-library/image-review/SKILL.md` | 0 | 2 | WARN |
| release-review | `skills/task-planner/review-library/release-review/SKILL.md` | 0 | 2 | WARN |
| security-review | `skills/task-planner/review-library/security-review/SKILL.md` | 0 | 2 | WARN |
| test-quality-review | `skills/task-planner/review-library/test-quality-review/SKILL.md` | 0 | 2 | WARN |
| ui-quality-review | `skills/task-planner/review-library/ui-quality-review/SKILL.md` | 0 | 2 | WARN |

## Summary

- 文件数: 32
- ERROR数: 21
- WARN数: 41
- 通过数: 0

## Notes

- Review-library 子技能按 stub 契约判定：缺少 model/tools 时，若为 review stub 形态记为 R1 WARN（不误报 ERROR）。
- R4/R5 为启发式一致性检查；仅在有明确正文证据时报告。
- 本报告未修改任何 SKILL.md。
