# Task Plan: 删除技能目录内的 task-planner .bak 备份
## Goal
按用户指令删除 ~/.zcode/skills/task-planner.bak-20260904 与 ~/.claude/skills/task-planner.bak-20260904——.bak 目录在技能扫描第一层会被识别为重复技能（本会话技能列表已实证出现重复项）。
## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据 |
|---|----------|----------|------|
| VC-1 | 两 .bak 目录已不存在 | ls 报 No such file | 命令输出 |
| VC-2 | 正主软链未受影响 | readlink 双路径仍指向 canonical | 命令输出 |
## ⚠️ 执行范围限制
| 类别 | 允许 | 禁止 |
|------|------|------|
| 删除 | 仅上述两个 .bak 目录（rm -rf,用户明示授权） | 其他任何 .bak（如 ~/.agents/skills/plan-resume.bak-20260904 属其他任务,仅报告） |
## Current Phase
Phase 1
## Phases
### Phase 1: 删除 + 验证 + 记忆更新
- [x] 删前身份复核（确为目录非软链）→ rm -rf → VC-1/VC-2 → 更新部署记忆
- **Status:** complete
- **Executor:** 主进程（例外理由:用户直接指令的单点删除,主进程白名单）
