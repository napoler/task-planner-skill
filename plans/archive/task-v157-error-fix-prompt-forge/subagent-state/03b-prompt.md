# Subagent Dispatch Prompt — task-v157 Phase 3 S3（code-assistant 编写 selftest + registry）

## 1. 目标
在 worktree 内新建 `skills/error-fix-prompt-forge/scripts/selftest-error-fix-prompt-forge.sh`（≤90 行，断言 FP-01..08，可执行 exit 0），并在 `skills/task-planner/scripts/selftest-registry.tsv` 末尾追加 1 行登记。
> 本会话只执行本 S-unit（Rule 46.1）；只许追加 registry 末行，禁改既有行。

- **需求锚（Rule 51.1a）**: R1:「创建一个skill」R2:「对错误排查调研 将排查结果 并且生成提供专业的提示词 用于后期的修正」

## 2. 输入
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/task_plan.md — 只读
- findings: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/findings.md — 可读;可写=仅追加 `#### [sub:03b-code-assistant] selftest+registry 落盘记录`
- progress: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/progress.md — 可读;可写=仅在 Phase 3 段「Actions taken」下追加 `  - [sub:03b] selftest+registry 落盘,自跑PASS`
- knowledge-brief: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/knowledge-brief.md — 只读;必读 §5 设计定稿详述的 selftest 段（FP-01..08 定义）与 registry 追加行格式段
- 范例: /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge/skills/iterative-optimizer/scripts/selftest-iterative-optimizer.sh — 只读（断言编号风格+相对路径解析范式,禁写死 /home/terry）
- registry: /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge/skills/task-planner/scripts/selftest-registry.tsv — 只读既有 66 行;仅末行追加
- config.json: /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge/skills/task-planner/config.json — 只读（FP-08 零新键断言对象）

## 3. 验收标准
- [ ] 脚本存在: worktree/skills/error-fix-prompt-forge/scripts/selftest-error-fix-prompt-forge.sh,`bash <脚本>` exit 0
- [ ] 断言 FP-01..08 全覆盖: ①SKILL.md 存在+name=目录名+description 非空 ②六区块锚(触发条件/输入契约/执行流程/门控铁律/输出合约/反模式) ③fail-closed:BLOCKED 与「根因未定位」共现 ④QC-FP ≥6 条+机器可检查条款 ⑤模板九槽位锚 ⑥模板与 SKILL Step1 槽位词互现 ≥5 ⑦registry 末行含 error-fix-prompt-forge ⑧config.json 零新键(grep error-fix-prompt-forge config.json=0)
- [ ] `wc -l` ≤90 行;相对路径解析(基于脚本自身目录),无写死路径
- [ ] registry 仅末行追加,既有 66 行零改动(diff 校验)

## 4. Scope 禁改清单
- 禁止修改: worktree 内除上述 2 文件外任何文件| 禁止: git 写操作、rm、网络、主仓越界写

## 5. 工作路径
- worktree 绝对路径: /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge；绝对路径操作不切 CWD

## 6. 时长预算
- 脚本编写+自跑 → 15 分钟;超限返回 partial

## 7. 返回格式(严格 8 字段,之后不得有任何内容)
```
status: done | partial | failed | timeout
acceptance: <n>/<total> pass — [1:PASS ...]
files: <绝对路径>(+N/-M); ... | none
evidence: <file:line 或 命令→关键输出行>; ...
checkpoint: <绝对路径> (status: done|failed)
findings_written: <#### [sub:03b-code-assistant] 锚点> | none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```

## 8. checkpoint 落盘路径(强制)
- 检查点文件: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/subagent-state/03b-code-assistant.md
- 纪律: 每完成一文件 Write→追加里程碑行;自跑 exit 0 记录命令+输出;T5 结束→「最终结论」段(=§7 8 字段块)置 status: done

## 9. 上下文预算
只读 §2 路径;结论先落 checkpoint 再返回

**执行步骤(3 步)**:
Step 1: Read knowledge-brief §5 selftest 段+registry 格式段 + 范例脚本(风格范式)
Step 2: 写 selftest 脚本(FP-01..08)+追加 registry 末行到指定绝对路径
Step 3: 自跑 `bash selftest-error-fix-prompt-forge.sh` 至 exit 0 + diff 校验 registry 仅 +1 行 → 按 §2 契约追加 findings/progress → 写 checkpoint → 返回 8 字段
