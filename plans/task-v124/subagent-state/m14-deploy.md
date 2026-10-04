# m14 检查点（task-v124 部署收尾 — [sub:deploy]）
status: done

## 编辑摘要
- /home/terry/.zcode/skills/skill-agent-router/SKILL.md（+7 行）: 在「## general-purpose 合法使用场景」前插入「### 九、内容与媒体类」节（image/video-generation-executor 两行三列表，逐字照抄任务书内容）
- /home/terry/.claude/skills/skill-agent-router/SKILL.md（+7 行）: 同上一致插入；未重复 complex-planner 行（主进程已补入）
- install-companion.sh 双目标真跑（dry-run 先行复核）:
  - 目标 1（.zcode）: 2 install（image/video-generation-executor）+ 2 update（plan-writer.md、plan-template-kit/references/template-mapping.md）+ 42 skip
  - 目标 2（.claude）: 2 install + 3 update（+ complex-planner.md）+ 41 skip
- findings.md「## Research Findings」段末追加 `#### [sub:deploy] m14 部署收尾` 段
- progress.md Phase 5「Actions taken」追加 `  - [sub:deploy] m14 部署收尾` 行

## install-companion 双目标 summary（原文行）
- dry-run（.zcode 目标）: `[companion] summary: 2 installed, 2 updated, 42 skipped (dry_run=1)`
- 目标 1 真跑: `[companion] summary: 2 installed, 2 updated, 42 skipped (dry_run=0)`
- 目标 2 真跑: `[companion] summary: 2 installed, 3 updated, 41 skipped (dry_run=0)`（target root: /home/terry/.claude）

## 核对表
| 检查项 | 命令 | 结果 |
|--------|------|------|
| 两 router 九节在位 | `grep -n '九、内容与媒体类'` 双文件 | 各 1 命中，均 :103 |
| router 媒体两行 | `grep -c 'image-generation-executor\|video-generation-executor'` | .zcode=2 / .claude=2（≥2 达标） |
| .claude 位 complex-planner 行 | `grep -c 'complex-planner'` | =1（恰 1 处，未重复） |
| .zcode 位 agent diff | `diff ~/.zcode/agents/{image,video}-generation-executor.md <主仓同名>` | 均 IDENTICAL |
| .claude 位 agent diff | 同上（vs 主仓） | 仅 :4 model 行差异 |
| model 行 adapt | `grep '^model:'` | .claude 位两文件均 `model: sonnet`（不含 `custom:`）；主仓/.zcode 位 `model: "custom:9e221f47-3040-4ea7-b742-20b813fb79aa:sonnet-1"` |

## 最终结论（8 字段块）
status: done
acceptance: 3/3 pass — ① 两 router 九节在位（:103 各 1 命中）② 双目标 agents 核对通过（.zcode diff IDENTICAL / .claude 仅 model 行 adapt=sonnet）③ install summary（.zcode 2i/2u/42s；.claude 2i/3u/41s）
files: /home/terry/.zcode/skills/skill-agent-router/SKILL.md(+7); /home/terry/.claude/skills/skill-agent-router/SKILL.md(+7); /home/terry/.zcode/agents/{image,video}-generation-executor.md(install); /home/terry/.claude/agents/{image,video}-generation-executor.md(install); /home/terry/.claude/agents/complex-planner.md(update); 双目标 plan-writer.md 与 plan-template-kit/references/template-mapping.md(update); plans/task-v124/findings.md(+8); plans/task-v124/progress.md(+1)
evidence: grep 双位 :103 命中 / diff 双目标 4 组 / install-companion 双 summary 原文（见上）
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v124/subagent-state/m14-deploy.md (status: done)
findings_written: findings.md `#### [sub:deploy] m14 部署收尾`（## Research Findings 段末）
blockers: none
confidence: HIGH
