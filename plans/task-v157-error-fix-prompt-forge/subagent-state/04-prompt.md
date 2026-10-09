# Subagent Dispatch Prompt — task-v157 Phase 4 S1（executor 行为冒烟）

## 1. 目标
以「skill 操作者」身份实跑 `error-fix-prompt-forge` 五步流程：把 fixture（v153 幻觉补位事故排查产物 fix-prompts.md）当作已完成根因定位的排查结果包，产出一份可直接派发的 fix-prompt 样例 + QC-FP 自检表（机检项实际跑命令）。这是 Rule 43.5 要求的提示词类实际生成测试。
> 本会话只执行本 S-unit（Rule 46.1）。

- **需求锚（Rule 51.1a）**: R1:「创建一个skill」R2:「对错误排查调研 将排查结果 并且生成提供专业的提示词 用于后期的修正」

## 2. 输入
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/task_plan.md — 只读
- findings: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/findings.md — 可读;可写=仅追加 `#### [sub:04-executor] 行为冒烟记录`
- progress: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/progress.md — 可读;可写=仅在 Phase 4 段「Actions taken」下追加 `  - [sub:04] 冒烟产物+自检表落盘`
- knowledge-brief: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/knowledge-brief.md — 只读
- 被测 skill(worktree 内): /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge/skills/error-fix-prompt-forge/SKILL.md + 同目录 templates/fix-prompt-template.md — 只读,先读 SKILL.md 全文再按其五步执行
- fixture(排查结果包,主仓内): /mnt/data/dev/task-planner-skill/plans/task-v153-parallel-scheduling/fix-prompts.md — 只读（v153 幻觉补位事故:症状=模板空段被填无源内容;根因=写入前无自检关口;证据=该文件 :1-5 事故描述+预防机制段）

## 3. 验收标准
- [ ] 产物 1: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/subagent-state/04-executor/fix-prompt-sample.md，按模板九槽位渲染（任务/范围/背景根因+证据锚/复现/禁改区/执行步骤≤4/验收判据≥1 机器可检查/验证命令/回滚/未验证假设区+DoD）
- [ ] 产物 2: 同目录 qc-fp-selfcheck.md，QC-FP-1..6 逐条 PASS/FAIL+证据（机检项附命令与关键输出）
- [ ] 修正目标选择合理:从 fixture 的可执行修正项中选 1 个（如「把提示词 B 事前自检 5 问口径写入 findings.md/progress.md 模板注释」或「对指定 findings.md 跑提示词 A 溯源审计」），单 S-unit 不混多个修复
- [ ] 三态结论显式(READY/PARTIAL/BLOCKED)
- [ ] 严格遵守 skill 门控:无证据锚内容进「未验证假设区」;不得实际执行修复(只产任务书)

## 4. Scope 禁改清单
- 禁止修改: 被测 SKILL.md/模板、fixture、三文件契约外内容、worktree 内任何文件 | 禁止: git 写操作、实际执行修复动作(改 findings 模板/跑审计修改文件)、网络

## 5. 工作路径
- 读被测 skill 用 worktree 绝对路径(见 §2);读 fixture 与写产物用主仓 plans/ 绝对路径;不切换 CWD

## 6. 时长预算
- 生成+自检 → 15 分钟;超限返回 partial

## 7. 返回格式(严格 8 字段,之后不得有任何内容)
```
status: done | partial | failed | timeout
acceptance: <n>/<total> pass — [1:PASS ...]
files: <绝对路径>(+N/-M); ... | none
evidence: <file:line 或 命令→关键输出行>; ...
checkpoint: <绝对路径> (status: done|failed)
findings_written: <#### [sub:04-executor] 锚点> | none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```

## 8. checkpoint 落盘路径(强制)
- 检查点文件: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/subagent-state/04-executor/checkpoint.md
- 纪律: 每步(Step 0-4)完成→追加里程碑行;两产物落盘后各自记一行;T5 结束→「最终结论」段(=§7 8 字段块)置 status: done

## 9. 上下文预算
只读 §2 路径;产物先落盘再返回

**执行步骤(4 步,按序)**:
Step 0: Read SKILL.md 全文+模板,核 fixture 是否满足输入契约(症状/复现/根因/证据锚/已尝试方案)——不满足项登记,不足则不启动
Step 1-2: 结构化抽取+缺口分析:把 fixture 内容映射槽位;列阻断级/非阻断缺口
Step 3: 按模板渲染 fix-prompt-sample.md(选定的修正目标+九槽位)
Step 4: QC-FP-1..6 逐条自检写 qc-fp-selfcheck.md(机检项跑命令:绝对路径 grep/证据锚存在性/占位符 grep)→ 按 §2 契约追加 findings/progress → 写 checkpoint → 返回 8 字段
