# Subagent Dispatch Prompt — task-v157 drift-check（Phase 1 完成态偏移检查）

## 1. 目标
对 task-v157-error-fix-prompt-forge Phase 1 完成态做只读偏移检查，产出 ALIGNED/DRIFT/BLOCKED 单行判定+检查点。
> 本会话只执行本 S-unit；你是只读检测执行体（Rule 61），发现 BLOCKED 必须等用户明确决策，主进程无权代放行。

- **需求锚**: R1:「创建一个skill」R2:「对错误排查调研 将排查结果 并且生成提供专业的提示词 用于后期的修正」

## 2. 输入(只读)
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/task_plan.md — 只读(Goal 段+Phase 1 段+用户需求原文区)
- findings: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/findings.md — 只读([sub:01-explore] 小节=Phase 1 产出)
- progress: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/progress.md — 只读(Phase 1 段=近期动作,Started 2026-10-10 04:30)
- 三锚契约(Rule 64.4):判定输入=① Goal 原文 ② 用户需求 R1/R2 原文 ③ 近期动作+scope 文件集(plans/task-v157-error-fix-prompt-forge/**,skills/ 下尚无新建);无锚判定=ALIGNED 无效
- 禁写:除本检查点外任何文件;禁 git 写操作;禁 Network

## 3. 验收标准
- [ ] 检查点含三锚逐项比对过程+最终判定
- [ ] 判定三态之一明确(ALIGNED/DRIFT/BLOCKED),每态附 file:line 证据
- [ ] 无越权写操作记录

## 4. Scope 禁改清单
禁止修改三文件与任何仓内文件;唯一可写=/mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/subagent-state/drift-01.md

## 5. 工作路径
只读用绝对路径;不切换 CWD

## 6. 时长预算
只读检查 → 超时阈值 8 分钟;超限返回 partial

## 7. 返回格式(严格 — 8 字段,之后不得有任何内容)
```
status: done | partial | failed | timeout
acceptance: <n>/<total> pass — [1:PASS ...]
files: none
evidence: <file:line>
checkpoint: <绝对路径> (status: done|failed)
findings_written: none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```
外加单行判定(写在 blockers 前? 不——放在 evidence 之后的单行,格式): DRIFT_CHECK: <ALIGNED|DRIFT|BLOCKED> | 锚1Goal:<符合/偏离+一句> | 锚2需求:<符合/偏离+一句> | 锚3scope:<符合/偏离+一句> | 证据:<file:line>

## 8. checkpoint 落盘路径(强制)
- 检查点文件: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/subagent-state/drift-01.md
- 格式:头部 status 行+比对过程+最终结论(含 §7 的 8 字段块+DRIFT_CHECK 单行);纯 markdown 无 frontmatter

## 9. 上下文预算
只读 §2 列出路径;判定先行落 checkpoint 再返回
