<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Findings: task-cli-help-examples-20261122

- task_id: `task-cli-help-examples-20261122`
- 时间: created_at=2026-11-22T12:16:14Z / updated_at=2026-11-22T13:15:43Z

## Requirements
- CLI help（--help / 子命令 help）提供更完善可照抄示例：典型工作流、副作用、退出码、参数说明
- Skill 文档（SKILL.md + examples.md）提供更完善脚本使用示例与指示：命令选择决策表、端到端示例、正反例、常见误用，确保使用合理准确、避免反复用错
- 改动限文档/help 文本，不改脚本执行逻辑；源仓改动同步到四个一致部署位且 diff=0；回归 selftest 零新增 FAIL

## Findings
| id | text | source | tags |
|---|---|---|---|

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|---|---|---|---|
| （本任务暂无知识对齐记录） |  |  |  |

## Research Findings
- template-catalog.sh 主 parser @309 无 epilog/formatter；子命令 @312-328 无示例；头注释 @10-19 已有可复用 Usage/输出契约/exit code — Explore agent 5e87503c
- planctl.py 主 parser @1861-1869 epilog 仅一行；add_cmd @1871-1875 不传 formatter；19 子命令无示例；docstring @3-20 有可复用契约 — Explore agent 5e87503c
- SKILL.md 用法散落无端到端示例/正反例/决策表；examples.md 仅两条 phase-done+render；references/docs 无脚本文档 — Explore agent d934b87f
- 13 处 SKILL.md 副本仅源仓+~/.agents+~/.claude+~/.cursor+~/.zcode 五处三文件 md5 全一致 — Explore agent d934b87f

## Technical Decisions
| Decision | Rationale |
|---|---|
| 改源仓 skills/task-planner/ 后用文件级 cp 同步四个一致部署位（~/.zcode ~/.agents ~/.claude ~/.cursor），不动 opencode stub/归档/worktree 副本 | 勘察确认仅此四位与源仓 md5 全一致且含两脚本，其余为 stub/历史快照不属交付面 |
| help 增强用 argparse epilog+RawDescriptionHelpFormatter+参数 help 文案，不改任何 handler/业务逻辑 | 用户诉求是补充使用说明，P0 范围守恒——文本优先铁律禁升级为基建/逻辑改动 |
| 文档示例采用命令选择决策表+端到端可照抄示例+正反例+常见误用四件套，落点 SKILL.md L47-51/L310-328 + examples.md | 勘察确认两文件均无完整示例，references/docs 无脚本文档，examples.md 是已知用户入口 |
| opencode 安装位属不完整安装（无 scripts/两脚本，SKILL/examples 为旧 md5），本次不补齐；残留旧文档已登记 | INSTALL.md:33 虽列该位，但缺脚本且 md5 不同，补齐超范围（用户诉求是 help/示例，非安装修复） |
| VC 路径参数化：worktree 内验证（P4）用 worktree 绝对路径，合并后部署验证（P5/VC-5）用主树路径；顺序=合并→部署→VC-5 | 审计 I-6：原 VC 全指主树且 P4 早于 P5 合并，预合并验证天然失效 |
| 并行组：{S2,S3}=script-help 组（不同脚本文件无依赖）；{S4,S5}=doc-example 组（不同文档文件无依赖）；组内同消息并发派发 | Rule 96.3：≥2 无依赖 S-unit 须声明并行组；R2 W-11 补登记 |

## Issues Encountered
| Issue | Resolution |
|---|---|
| （本任务暂无问题记录） |  |

## Resources
- （本任务暂无资源引用）

## Visual/Browser Findings
- （本任务暂无多模态发现——未产生截图/PDF/网页证据）

---
## 本任务 tag 倒排引用
- （本任务暂无tag 引用）
