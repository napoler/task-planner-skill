# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
-->

## Requirements
- 用户指令（2026-09-05 原话）："在所有平台中重新部署最新版本。"
- 背景：上两任务（去重 5228d06 + Rule 27 9b167fe）合并后部署端停留 ad7900d,本任务补齐部署(遗留决策项①获得授权)。

## 📚 必要知识储备对齐记录
| 知识源 | 定位 | 是否已消费 | 结论落点 |
|--------|------|-----------|---------|
| 记忆 task-planner-repo-deploy-flow.md | ~/.zcode/cli/memories/.../memory/ | ☑ | §1 拓扑/SOP |
| 上次部署计划 plans/task-deploy-master-20260905/ | plans/ | ☑ | rm+cp+diff 范式/备份惯例 |
| git diff ad7900d..master | canonical | ☑ | §1 变更范围 |

## Research Findings

### §1 部署前诊断
- **变更范围**（git diff --name-status ad7900d..9b167fe）：8 files 全部在 `skills/task-planner/**`（7 M + WORKFLOW.md D）→ 兄弟 skill（todo-skill/task-drift-guard/plan-resume）canonical 无变化。
- **9 位拓扑**（memory 权威）：task-planner ×3（zcode/claude/opencode）+ todo-skill ×2 + task-drift-guard ×2 + plan-resume ×2。
- **预检**：6 个兄弟部署位 diff -rq 全部 IDENTICAL → 无需重部署,仅终验;3 个 task-planner 位落后（含 WORKFLOW.md 残影风险）。
- **删除同步陷阱**：`cp -rL` 覆盖不删除目标多余文件——WORKFLOW.md 已在 master 删除,必须 rm -rf 整目录替换（memory SOP 原生含 rm）。

### §2 执行结果
- 备份：3 位 ad7900d 快照 → `/tmp/deploy-backup-9b167fe/task-planner-3targets-ad7900d.tar.gz`（525K,扫描路径外合规）。
- 重部署：3 位逐一 `rm -rf && cp -rL`，即时 diff -rq 全 IDENTICAL,WORKFLOW.md 缺席确认 ✓。
- 9/9 终验（3 重部署 + 6 兄弟）：**全 IDENTICAL**。
- canonical 零改动：master HEAD 9b167fe,skills/ porcelain 空。
- Rule 27 生效抽查：部署位 SKILL.md "Rule 27" 提及 ×5（与 canonical 一致）。
- 记忆更新：task-planner-repo-deploy-flow.md 基线行 + MEMORY.md 索引行 → 9b167fe。

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 只重部署 3 个 task-planner 位 | 变更范围仅 task-planner;兄弟位预检 IDENTICAL;写入最小化 |
| rm -rf 整目录替换 | 同步 WORKFLOW.md 删除;cp 覆盖留残影 |
| direct 执行不走 worktree | 部署写入仓外部署位,canonical 零改动（上次部署同例） |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| （无） | — |

## Resources
- /tmp/deploy-backup-9b167fe/task-planner-3targets-ad7900d.tar.gz（回滚点）
- plans/task-deploy-master-20260905/（SOP 先例）

## Visual/Browser Findings
- （无多模态输入）
