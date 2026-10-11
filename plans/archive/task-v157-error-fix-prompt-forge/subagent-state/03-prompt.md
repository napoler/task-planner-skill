# Subagent Dispatch Prompt — task-v157 Phase 3 S2（code-assistant 编写 fix-prompt 模板）

## 1. 目标
在 worktree 内新建 `skills/error-fix-prompt-forge/templates/fix-prompt-template.md`（≤60 行）：fix prompt 的九槽位渲染模板，槽位与已落盘 SKILL.md 的 Step 1 槽位表/Step 4 自检项一一对齐。
> 本会话只执行本 S-unit（Rule 46.1）。

- **需求锚（Rule 51.1a）**: R1:「创建一个skill」R2:「对错误排查调研 将排查结果 并且生成提供专业的提示词 用于后期的修正」

## 2. 输入
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/task_plan.md — 只读
- findings: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/findings.md — 可读;可写=仅追加 `#### [sub:03-code-assistant] 模板编写记录` 到 `## Research Findings` 段末
- progress: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/progress.md — 可读;可写=仅在 Phase 3 段「Actions taken」下追加 `  - [sub:03] 模板落盘:N行`
- knowledge-brief: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/knowledge-brief.md — 只读;必读 §5「设计定稿详述」的 fix-prompt-template.md 结构段（九槽位顺序=编写依据）
- SKILL.md: /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge/skills/error-fix-prompt-forge/SKILL.md — 只读（槽位对齐源:Step 1 槽位表 :44、QC-FP-1..6 :53-58、派发纪律 :46）

## 3. 验收标准
- [ ] 文件存在: /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge/skills/error-fix-prompt-forge/templates/fix-prompt-template.md
- [ ] `wc -l` ≤60 行
- [ ] 九槽位锚齐全（各 ≥1 处）: 任务/范围、背景与根因/证据锚、复现、禁改区、执行步骤、验收判据、验证命令、回滚、未验证假设区
- [ ] 「定义完成(DoD)」行存在
- [ ] 每槽位配 1 行 What+Why 填写注释（Rule 45 双层注释）
- [ ] 槽位命名与 SKILL.md Step 1 槽位表用词一致（问题陈述/根因+证据/影响面/复现/禁改区/验证判据/回滚/参考材料 ≥5 个词在模板中出现）

## 4. Scope 禁改清单
- 禁止修改: worktree 内除本模板外任何文件（SKILL.md/scripts/registry 禁碰）| 禁止: git 写操作、rm、网络、主仓越界写

## 5. 工作路径
- worktree 绝对路径: /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge；绝对路径操作不切 CWD

## 6. 时长预算
- 文档编写 → 15 分钟;超限返回 partial

## 7. 返回格式(严格 8 字段,之后不得有任何内容)
```
status: done | partial | failed | timeout
acceptance: <n>/<total> pass — [1:PASS ...]
files: <绝对路径>(+N/-M); ... | none
evidence: <file:line 或 命令→关键输出行>; ...
checkpoint: <绝对路径> (status: done|failed)
findings_written: <#### [sub:03-code-assistant] 锚点> | none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```

## 8. checkpoint 落盘路径(强制)
- 检查点文件: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/subagent-state/03-code-assistant.md
- 纪律: 每完成一文件 Write→追加里程碑行;T5 结束→「最终结论」段(=§7 8 字段块)置 status: done

## 9. 上下文预算
只读 §2 路径;结论先落 checkpoint 再返回

**执行步骤(3 步)**:
Step 1: Read knowledge-brief §5 模板结构段 + SKILL.md :41-58（流程与自检对齐源）
Step 2: 写模板到指定绝对路径（≤60 行,九槽位+DoD+What/Why 注释）
Step 3: 自跑验收(wc -l+grep 槽位锚+槽位词互现)→ 按 §2 契约追加 findings/progress → 写 checkpoint → 返回 8 字段
