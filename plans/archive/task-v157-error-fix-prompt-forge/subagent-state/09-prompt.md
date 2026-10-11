# Subagent Dispatch Prompt — task-v157 合并级联修复（code-assistant FP-07 含口径化）

## 1. 目标
把 `/mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge/skills/task-planner/scripts/selftest-error-fix-prompt-forge.sh` 的 FP-07 从「registry 末行口径」改为「含口径」（数据行出现 ≥1 即 PASS），防止跨任务追加登记行互相打破末行断言（G-07 范式）。
> 本会话只执行本 S-unit（Rule 46.1）。这是合并 master（v155 的 selftest-report-reviewability.sh 追加行与本脚本登记行冲突解并集）后的级联修复。

- **需求锚（Rule 51.1a）**: R1:「创建一个skill」R2:「对错误排查调研 将排查结果 并且生成提供专业的提示词 用于后期的修正」

## 2. 输入
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/task_plan.md — 只读
- findings: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/findings.md — 可读;可写=仅追加 `#### [sub:09-code-assistant] 合并级联修复:FP-07 含口径化`
- progress: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/progress.md — 可读;可写=仅在 Phase 5 段「Actions taken」下追加 `  - [sub:09] FP-07 含口径化,回归 PASS`
- 被修脚本: worktree/skills/task-planner/scripts/selftest-error-fix-prompt-forge.sh（只读现状,当前 FP-07 在 :74-79 末行口径段）
- 范式基准: worktree/skills/task-planner/scripts/selftest-goal-unit-goal-mode.sh — 只读（G-07 含口径写法, :105 附近）
- registry(已解冲突): worktree/skills/task-planner/scripts/selftest-registry.tsv — 只读（末两行=report-reviewability+error-fix-prompt-forge,共 69 行）

## 3. 验收标准
- [ ] FP-07 改为含口径: `n="$(grep -c 'error-fix-prompt-forge' "$REG" 2>/dev/null || true)"` + `[ "$n" -ge 1 ]` 判定;PASS/FAIL 消息带 $n 诊断;头注释 FP-07 行同步改「含口径登记」并注记本次合并级联原因
- [ ] 其余断言（FP-01..06/08）零改动;bash -n 语法 OK;行数仍 ≤90
- [ ] 自跑 exit 0: bash selftest-error-fix-prompt-forge.sh → Total: 8 PASS=8 FAIL=0
- [ ] 连带复跑 exit 0: selftest-registry.sh（T01-05）+ selftest-self-resolution.sh（SR-12 动态口径,registry 69 行=脚本 68+表头）+ selftest-report-reviewability.sh（v155 脚本,不受本改动影响但须复跑确认）

## 4. Scope 禁改清单
- 禁止修改: 除被修脚本 FP-07 段+头注释对应行外任何内容（registry/其他 selftest/SKILL.md/模板 全禁）| 禁止: git 写操作（提交由主进程做）、网络、主仓越界写

## 5. 工作路径
- worktree 绝对路径: /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge；绝对路径操作不切 CWD

## 6. 时长预算
- 小修+复跑 → 10 分钟;超限返回 partial

## 7. 返回格式(严格 8 字段,之后不得有任何内容)
```
status: done | partial | failed | timeout
acceptance: <n>/<total> pass — [1:PASS ...]
files: <绝对路径>(+N/-M); ... | none
evidence: <命令→关键输出行>; ...
checkpoint: <绝对路径> (status: done|failed)
findings_written: <#### [sub:09-code-assistant] 锚点> | none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```

## 8. checkpoint 落盘路径(强制)
- 检查点文件: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/subagent-state/09-code-assistant.md
- 纪律: 修改→追加里程碑行;四脚本复跑逐条记命令+输出;T5 结束→「最终结论」段(=§7 8 字段块)置 status: done

## 9. 上下文预算
只读 §2 路径;结论先落 checkpoint 再返回

**执行步骤(2 步)**:
Step 1: Edit FP-07 段+头注释（按 §3 验收措辞）
Step 2: 四脚本复跑+wc -l+bash -n → 按 §2 契约追加 findings/progress → 写 checkpoint → 返回 8 字段
