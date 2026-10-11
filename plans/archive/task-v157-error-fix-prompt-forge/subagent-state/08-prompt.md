# Subagent Dispatch Prompt — task-v157 CR 修复轮（code-assistant 加固 selftest 断言）

## 1. 目标
按 Code Reviewer 问题清单加固 `worktree/skills/task-planner/scripts/selftest-error-fix-prompt-forge.sh` 的 FP-04/05/06 断言强度+FP-01 措辞精度+FAIL 分支诊断（P1×3/P2×2/Nit×1），修后本脚本仍 8/8 PASS exit 0，且 selftest-registry.sh/selftest-self-resolution.sh 不受影响。
> 本会话只执行本 S-unit（Rule 46.1）。

- **需求锚（Rule 51.1a）**: R1:「创建一个skill」R2:「对错误排查调研 将排查结果 并且生成提供专业的提示词 用于后期的修正」

## 2. 输入
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/task_plan.md — 只读
- findings: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/findings.md — 可读;可写=仅追加 `#### [sub:08-code-assistant] CR 修复:断言加固`
- progress: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/progress.md — 可读;可写=仅在 Phase 5 段「Actions taken」下追加 `  - [sub:08] CR 修复:FP 断言加固,8/8 PASS`
- CR 问题清单(权威): /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/subagent-state/07-code-reviewer.md — 只读(第 9-14 行 P1×3/P2×2/Nit×1 全文照单修)
- 被修脚本: /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge/skills/task-planner/scripts/selftest-error-fix-prompt-forge.sh
- 断言对象(改后必须仍真实 PASS): worktree/skills/error-fix-prompt-forge/SKILL.md、templates/fix-prompt-template.md、task-planner/scripts/selftest-registry.tsv、config.json(均只读)
- 范式基准: worktree/skills/task-planner/scripts/selftest-iterative-optimizer.sh(FAIL 分支带数值诊断的写法)

## 3. 验收标准
- [ ] P1-1(FP-06:68): 槽位词互现改精确措辞——用 SKILL Step 1 实际槽位短语(问题陈述/根因+证据/复现/禁改区/验证判据/回滚/参考材料)逐词 grep -qF 互现计数,阈值 ≥5(候选 7 个);不再用短词子串前缀匹配
- [ ] P1-2(FP-05:60): 九槽位改逐词独立判定——8 个关键词(根因/复现/禁改区/验收/回滚/未验证假设区/DoD/验证命令)各 grep -q 命中才计数,要求 8/8(原来宽 OR 累计 ≥8 近似恒真已修);注释「九槽位」改「八槽位锚,逐词各 ≥1」口径(P2-2 三处注释一并改)
- [ ] P1-3(FP-04:52-54): 自检表条数锚定表行——`grep -c '^| QC-FP-' "$SKILL"` ≥6(实测=6),不再用全文出现次数
- [ ] P2-1: FP-05 FAIL 分支 $n 初始化可靠(n=0 兜底,模板缺失时也有诊断值);FP-07 FAIL 分支附 registry 末行内容摘要(tail -1 截断 60 字符)
- [ ] Nit-1(FP-01): 断言名副其实——name=目录名做实:比对 SKILL.md 所在目录 basename 与 head -5 内 name 值一致
- [ ] 修复后 bash 自跑 8/8 PASS exit 0;bash -n 语法 OK;行数仍 ≤90;断言逻辑以上述为限,禁扩大改动
- [ ] selftest-registry.sh 与 selftest-self-resolution.sh 复跑仍 PASS(本文件只改内部断言,不影响其对象)

## 4. Scope 禁改清单
- 禁止修改: 除被修脚本外任何文件(SKILL.md/模板/registry/config/其他 selftest 全禁)| 禁止: git 写操作、网络、主仓越界写

## 5. 工作路径
- worktree 绝对路径: /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge；绝对路径操作不切 CWD

## 6. 时长预算
- 加固+回归 → 15 分钟;超限返回 partial

## 7. 返回格式(严格 8 字段,之后不得有任何内容)
```
status: done | partial | failed | timeout
acceptance: <n>/<total> pass — [1:PASS ...]
files: <绝对路径>(+N/-M); ... | none
evidence: <命令→关键输出行>; ...
checkpoint: <绝对路径> (status: done|failed)
findings_written: <#### [sub:08-code-assistant] 锚点> | none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```

## 8. checkpoint 落盘路径(强制)
- 检查点文件: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/subagent-state/08-code-assistant.md
- 纪律: 每完成一处修复→追加里程碑行;三脚本复跑记录命令+输出;T5 结束→「最终结论」段(=§7 8 字段块)置 status: done

## 9. 上下文预算
只读 §2 路径;结论先落 checkpoint 再返回

**执行步骤(3 步)**:
Step 1: Read 被修脚本+CR 清单(07-code-reviewer.md:9-14)+范式基准 FAIL 分支写法
Step 2: 按 §3 六项逐处修复(小步 Edit,每处记里程碑)
Step 3: 三脚本复跑(fp/registry/self-resolution)+bash -n+wc -l → 按 §2 契约追加 findings/progress → 写 checkpoint → 返回 8 字段
