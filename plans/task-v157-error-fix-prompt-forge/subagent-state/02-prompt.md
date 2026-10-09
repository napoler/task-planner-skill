# Subagent Dispatch Prompt — task-v157 Phase 3 S1（code-assistant 编写 SKILL.md）

## 1. 目标
在 worktree 内新建 `skills/error-fix-prompt-forge/SKILL.md`（≤100 行）：把已定位根因的错误排查调研结果转化为可派发专业修正提示词的顶层执行型 skill，结构严格按本任务书 §2 引用的设计定稿详述。
> 本会话只执行本 S-unit（Rule 46.1）：模板、selftest、registry 由后续 S-unit 负责，禁止越权编写。

- **需求锚（Rule 51.1a）**: R1:「创建一个skill」R2:「对错误排查调研 将排查结果 并且生成提供专业的提示词 用于后期的修正」

## 2. 输入
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/task_plan.md — 只读
- findings: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/findings.md — 可读;可写=仅追加 `#### [sub:02-code-assistant] SKILL.md 编写记录` 到 `## Research Findings` 段末,禁改既有内容
- progress: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/progress.md — 可读;可写=仅在 Phase 3 段「Actions taken」下追加 `  - [sub:02] SKILL.md 落盘:N行`,禁改 Status/Started
- knowledge-brief: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/knowledge-brief.md — 只读;**必须先读 §5「设计定稿详述」的 SKILL.md 结构段（11 项结构清单=编写唯一依据）**
- 范式参考: /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge/skills/iterative-optimizer/SKILL.md — 只读(顶层 skill 结构与文风范式,97 行)
- findings 摘要: 侦察结论见 findings.md [sub:01-explore] 小节（边界 6 条=「不触发」内容来源）

## 3. 验收标准
- [ ] 文件存在于 worktree: /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge/skills/error-fix-prompt-forge/SKILL.md
- [ ] `wc -l` ≤100 行
- [ ] 六区块锚齐全: 「## 触发条件」「## 执行前输入契约」「## 执行流程」「## QC-FP」「## 门控铁律」「## 反模式」各出现 ≥1
- [ ] frontmatter: name: error-fix-prompt-forge（=目录名）+ description 含中英触发词且含「不触发」指向
- [ ] 五步流程 Step 0-4 与三态结论 READY/PARTIAL/BLOCKED、QC-FP-1..6 六条齐现
- [ ] 尾部注释锚 task-v157-error-fix-prompt-forge

## 4. Scope 禁改清单
- 禁止修改: worktree 内除上述 SKILL.md 外任何文件（尤其 templates/、scripts/、selftest-registry.tsv、其他 skill）| 禁止: git 写操作、rm、网络、编辑主仓 /mnt/data/dev/task-planner-skill 下任何文件

## 5. 工作路径
- worktree 绝对路径: /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge；所有读写用绝对路径,不切换 CWD；计划三文件在主仓 plans/ 下（绝对路径见 §2）

## 6. 时长预算
- 文档编写 → 超时阈值 15 分钟;超限立即返回 partial

## 7. 返回格式(严格 8 字段,之后不得有任何内容)
```
status: done | partial | failed | timeout
acceptance: <n>/<total> pass — [1:PASS ...]
files: <绝对路径>(+N/-M); ... | none
evidence: <file:line 或 命令→关键输出行>; ...
checkpoint: <绝对路径> (status: done|failed)
findings_written: <#### [sub:02-code-assistant] 锚点> | none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```

## 8. checkpoint 落盘路径(强制)
- 检查点文件: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/subagent-state/02-code-assistant.md
- 纪律: 每完成一文件 Write→追加里程碑行(带时间戳);T5 结束→「最终结论」段(=§7 同一 8 字段块)置 status: done

## 9. 上下文预算
只读 §2 列出路径;结论先落 checkpoint 再返回

**执行步骤(3 步)**:
Step 1: Read knowledge-brief.md §5 设计定稿详述(SKILL.md 结构 11 项)+ iterative-optimizer/SKILL.md 全文(范式)
Step 2: 按 11 项结构写 SKILL.md 到 §5 指定绝对路径(≤100 行,文风对齐 iterative-optimizer)
Step 3: 自跑验收(wc -l + grep 六区块锚)→ 按 §2 契约追加 findings/progress → 写 checkpoint → 返回 8 字段
