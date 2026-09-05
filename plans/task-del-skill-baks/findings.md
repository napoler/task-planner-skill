# Findings & Decisions
## Requirements
用户指令(2026-09-04):删除上一任务保留的两个 .bak 备份——备份在技能扫描第一层会被识别为重复技能,"只改目录名没用,内部 SKILL.md 还在"。
## Research Findings
- 实证:本会话可用技能列表出现 `task-planner.bak-20260904` 重复项(用户判断正确,非误忧)
- 加载器只扫 skills 目录第一层,凡含 SKILL.md 的一级目录都入列;`.bak-` 命名不豁免
- 删除后全库扫描:仅剩 ~/.agents/skills/plan-resume.bak-20260904(其他任务产物,未授权不动,已报告)
## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 删除而非移出目录外保存 | 移到非扫描位置(如 ~/bak/)也可行,但用户明示"删除";副本均为陈旧 clone,canonical 即完整事实源 |
## Issues Encountered
| Issue | Resolution |
|-------|------------|
| 无 | — |
## Resources
- 回滚方式:install.sh 重装或 git clone(canonical= /mnt/data/dev/task-planner-skill)
- 收编记录:register-hooks-cj.ts 已在 canonical(56a4337),删除副本零内容损失
