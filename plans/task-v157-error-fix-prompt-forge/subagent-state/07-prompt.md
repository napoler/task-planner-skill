# Subagent Dispatch Prompt — task-v157 Phase 5 Code Review Gate（code-reviewer）

## 1. 目标
对 task-v157 新增的 selftest 脚本做单轮轻量代码审查（轻 diff=1 个代码文件），输出 APPROVED / CHANGES_REQUESTED。审查对象 = /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge/skills/task-planner/scripts/selftest-error-fix-prompt-forge.sh（82 行，FP-01..08 静态断言）。
> 本会话只执行本 S-unit（Rule 46.1）。

- **需求锚（Rule 51.1a）**: R1:「创建一个skill」R2:「对错误排查调研 将排查结果 并且生成提供专业的提示词 用于后期的修正」

## 2. 输入(只读)
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/task_plan.md — 只读(了解 VC 与 scope)
- findings: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/findings.md — 只读([sub:06] 级联修复记录=位置平移与路径修正背景)
- progress: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/progress.md — 只读(Round 1-4 回归记录)
- 被审脚本: worktree/skills/task-planner/scripts/selftest-error-fix-prompt-forge.sh(上条绝对路径)
- 断言对象(核对断言是否真实有效): worktree/skills/error-fix-prompt-forge/SKILL.md + templates/fix-prompt-template.md + task-planner/scripts/selftest-registry.tsv + task-planner/config.json
- 范式基准: worktree/skills/task-planner/scripts/selftest-iterative-optimizer.sh(同目录既有范式)

## 3. 验收标准
- [ ] 逐 hunk 审查:路径解析健壮性(set -u/SCRIPT_DIR 模式/无写死路径)/断言语义与 FP-01..08 定义一致/边界(空文件、grep 退出码在 set -u 下的行为)/exit 语义
- [ ] 试跑验证:在 worktree 内 bash 被审脚本,确认 exit 0 与 Total 行(如实记录命令+输出)
- [ ] 对照范式基准挑差异(有理由的差异可接受,无理由的漂移要指出)
- [ ] 结论二值+问题清单(每条 P0/P1/P2+file:line+建议修法)

## 4. Scope 禁改清单
- 禁止修改任何文件(只读审查+可 bash 试跑)| 禁止: git 写操作、网络、改动被审对象

## 5. 工作路径
- worktree 绝对路径: /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge；绝对路径操作不切 CWD

## 6. 时长预算
- 单轮审查 → 15 分钟;超限返回 partial

## 7. 返回格式(严格 8 字段,之后不得有任何内容)
```
status: done | partial | failed | timeout
acceptance: <n>/<total> pass — [1:PASS ...]
files: none
evidence: <file:line 或 命令→关键输出行>; ...
checkpoint: <绝对路径> (status: done|failed)
findings_written: none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```
另在 checkpoint 最终结论段附:REVIEW: <APPROVED|CHANGES_REQUESTED> | 问题清单(或「无」)

## 8. checkpoint 落盘路径(强制)
- 检查点文件: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/subagent-state/07-code-reviewer.md
- 纪律: 审查进展→追加里程碑行;T5 结束→「最终结论」段(=§7 8 字段块+REVIEW 行)置 status: done

## 9. 上下文预算
只读 §2 路径;结论先落 checkpoint 再返回

**执行步骤(3 步)**:
Step 1: Read 被审脚本+范式基准+断言对象(SKILL.md/模板),逐 hunk 审
Step 2: worktree 内 bash 试跑被审脚本,记录命令+输出;核对 FP-01..08 断言与实际文件状态的对应关系
Step 3: 写 checkpoint(问题清单+REVIEW 二值结论)→ 返回 8 字段
