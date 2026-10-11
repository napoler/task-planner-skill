# T-4 checkpoint (V-12 平台一致性 + V-11②③ 迁移性修复)

status: done
commit: f175210
worktree: /home/terry/task-planner-skill-worktrees/task-v065-subagent-failure-rescue

## 变更明细 (5 files, 10 ins / 9 del)

| 文件 | 修改 |
|------|------|
| SKILL.md | :66 兜底路径改为 `{platform-home}/skills/...`（`~/.zcode` 或 `~/.claude`） |
| references/template-guide.md | :12 优先级 1 行补充 `.zcode/plan-templates/`（ZCode）双平台写法 |
| references/template-mapping.md | :102/:104 双 `.claude` 叠加 → 单 `.zcode` 示例 + 注释标注 Claude Code 侧对应 `.claude/plan-templates/` |
| companion/agents/plan-writer.md | :95 默认 cwd `/home/terry/.zcode` → `$HOME/.zcode` |
| references/worktree-isolation.md | :42 新增 `${REPO_PARENT}` 说明行; :50/:57/:58/:64 四处路径参数化 |

## 验收结果

- A1 `grep -rn "/home/terry" worktree-isolation.md plan-writer.md` → 仅剩 :35 散文示例行（豁免，已标注"按部署环境代入"）
- A2 无双 `.claude/.claude` 叠加；SKILL.md:66 无单平台硬写
- A3 SKILL.md:22-23（`model: opus` 行）未被改动（diff 仅 :66 1 行）
- A4 `git diff --stat` 仅覆盖允许清单 5 文件

## 证据 (before→after verbatim)

1. SKILL.md:66
   - before: `兜底：~/.zcode/skills/task-planner/templates/{filename}（内置 5 模板）`
   - after: `兜底：{platform-home}/skills/task-planner/templates/{filename}（~/.zcode 或 ~/.claude，内置 5 模板）`

2. template-mapping.md:102
   - before: `mkdir -p ~/.claude/skills/skill-fix/.claude/plan-templates/`
   - after: `mkdir -p ~/.zcode/skills/skill-fix/.zcode/plan-templates/`

3. plan-writer.md:95
   - before: `默认 /home/terry/.zcode`
   - after: `默认 $HOME/.zcode`

4. worktree-isolation.md:49
   - before: `git worktree add /home/terry/<repo>-worktrees/<task-id> -b wt/<task-id> main`
   - after: `git worktree add ${REPO_PARENT}/<repo>-worktrees/<task-id> -b wt/<task-id> main`

## risks
- worktree-isolation.md:35 仍保留 `/home/terry/.zcode-worktrees/` 作为散文示例（非命令模板），判定为环境示例豁免
- template-mapping.md 示例改为 `.zcode` 单平台，若用户实际部署为 Claude Code 需自行换回 `.claude`（已在注释标注对应关系）

## next_step
V-12-1 的 SKILL.md:68 "定制入口" 行仍写 `.claude/plan-templates/`（原 :67 现 :69），属同一 V-12 发现但不在本批允许修改清单内，建议 T-4b 或 T-5 跟进
