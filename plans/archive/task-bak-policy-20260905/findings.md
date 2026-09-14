# Findings & Decisions

## Requirements
- 用户指令（2026-09-05 原话要义）：不要用 .bak 改名方式在技能目录留备份——检索机制依旧能检测到，等于没用；要删就彻底删，或彻底移除技能目录
- 对象：上一任务报告的遗留项 `~/.agents/skills/plan-resume.bak-20260904`

## Research Findings
- **核查结果（2026-09-05，ls+grep bak/backup/old/orig 全景）**：四平台技能目录（~/.zcode/skills、~/.claude/skills、~/.agents/skills、~/.config/opencode/skills）顶层**均无 bak 类残留**。plan-resume.bak-20260904 已在此前会话删除（记忆记录过时，非本次删除）
- `~/skill-deploy-backups-20260904/` 集中备份含 6 个子目录（claude-plan-resume、claude-task-drift-guard、claude-todo-skill、opencode-stub-internal、zcode-task-drift-guard、zcode-todo-skill），位于加载器扫描路径外、命名规范——符合用户"彻底移除技能目录"的合规形态，保留
- ~/.agents/skills 顶层 48 个技能目录全部为正常命名

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 政策固化为 feedback 记忆而非仅修正 deploy-flow | 这是用户对工作方式的普适纠正（备份规范），未来所有 skill 部署任务都会遇到，需独立可召回 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| 记忆 deploy-flow 含过时遗留行（.bak 待授权），实际已删 | 已修正为"四平台核查清零 + 备份政策"行 |

## Resources
- 政策记忆：memory/skill-backup-no-rename-in-scan-path.md（含用户原话与 How to apply）
- 合规备份目录范式：~/skill-deploy-backups-20260904/
