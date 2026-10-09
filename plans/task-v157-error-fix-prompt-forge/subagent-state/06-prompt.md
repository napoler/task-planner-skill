# Subagent Dispatch Prompt — task-v157 级联修复（Phase 4 S3 提前执行：selftest 位置平移）

## 1. 目标
把 `selftest-error-fix-prompt-forge.sh` 从 `skills/error-fix-prompt-forge/scripts/` 平移到 `skills/task-planner/scripts/`（仓库惯例：全部 selftest 集中于 task-planner/scripts，iterative-optimizer 先例），并按新位置修正路径解析，使 selftest-registry.sh T03 与 selftest-self-resolution.sh SR-12 两条级联断言恢复 PASS，且本脚本自跑仍 8/8 exit 0。
> 本会话只执行本 S-unit（Rule 46.1）。这是 Phase 4 S3 条件性级联修复的提前执行（回归已作为 Phase 3 对齐证据先行跑出，FAIL 清单已知=本任务书输入）。

- **需求锚（Rule 51.1a）**: R1:「创建一个skill」R2:「对错误排查调研 将排查结果 并且生成提供专业的提示词 用于后期的修正」

## 2. 输入
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/task_plan.md — 只读
- findings: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/findings.md — 可读;可写=仅追加 `#### [sub:06-code-assistant] 级联修复:selftest 位置平移`
- progress: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/progress.md — 可读;可写=仅在 Phase 3 段「Actions taken」下追加 `  - [sub:06] 级联修复:selftest 平移至 task-planner/scripts,3 脚本回归 PASS`
- knowledge-brief: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/knowledge-brief.md — 只读
- 被移脚本(worktree 内): /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge/skills/error-fix-prompt-forge/scripts/selftest-error-fix-prompt-forge.sh
- 范式参考(同目录惯例): /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge/skills/task-planner/scripts/selftest-iterative-optimizer.sh — 只读(路径解析范式:SCRIPT_DIR→SKILL_ROOT=脚本目录/.. → TARGET=SKILL_ROOT/../<skill-name>/SKILL.md)
- 级联 FAIL 清单(已由主进程回归实证): selftest-registry.sh T03 孤儿行(新脚本不在 task-planner/scripts 计数的 actual 集)+ selftest-self-resolution.sh SR-12(总行数 67≠脚本数65+表头=66)

## 3. 验收标准
- [ ] 新位置存在: /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge/skills/task-planner/scripts/selftest-error-fix-prompt-forge.sh;旧位置不存在(空 scripts/ 目录一并移除)
- [ ] 路径解析按 iterative-optimizer 惯例修正(SKILL=$SKILL_ROOT/../error-fix-prompt-forge/SKILL.md;TPL 同理;REG=$SCRIPT_DIR/selftest-registry.tsv;CFG=$SCRIPT_DIR/../config.json),无写死绝对路径
- [ ] 三个脚本全 PASS: bash selftest-error-fix-prompt-forge.sh(8/8)+ bash selftest-registry.sh(T01-05 全 PASS)+ bash selftest-self-resolution.sh(SR-12 PASS)
- [ ] 脚本除路径块/头注释外断言逻辑零改动(FP-01..08 语义不变)

## 4. Scope 禁改清单
- 禁止修改: 除被移脚本自身外的任何文件(registry.tsv/其他 selftest/SKILL.md/模板 全禁)| 禁止: git 写操作、rm -rf(空目录 rmdir 可)、网络、主仓越界写

## 5. 工作路径
- worktree 绝对路径: /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge；绝对路径操作不切 CWD

## 6. 时长预算
- 机械修复+回归 → 15 分钟;超限返回 partial

## 7. 返回格式(严格 8 字段,之后不得有任何内容)
```
status: done | partial | failed | timeout
acceptance: <n>/<total> pass — [1:PASS ...]
files: <绝对路径>(+N/-M); ... | none
evidence: <命令→关键输出行>; ...
checkpoint: <绝对路径> (status: done|failed)
findings_written: <#### [sub:06-code-assistant] 锚点> | none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```

## 8. checkpoint 落盘路径(强制)
- 检查点文件: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/subagent-state/06-code-assistant.md
- 纪律: 每完成一文件操作→追加里程碑行;三脚本回归逐条记录(命令+输出关键行);T5 结束→「最终结论」段(=§7 8 字段块)置 status: done

## 9. 上下文预算
只读 §2 路径;结论先落 checkpoint 再返回

**执行步骤(3 步)**:
Step 1: Read 被移脚本 + 范式参考脚本路径块;mv 到 task-planner/scripts 并修正路径解析(头注释补位置说明)
Step 2: 依次跑三个脚本(self/registry/self-resolution),记录每条关键输出
Step 3: 按 §2 契约追加 findings/progress → 写 checkpoint → 返回 8 字段
