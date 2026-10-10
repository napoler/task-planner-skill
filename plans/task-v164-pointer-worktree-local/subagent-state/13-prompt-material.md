# S13 CR 材料（code-reviewer，2026-10-10）

## 审查对象
worktree `wt/v164-pointer-worktree-local`（HEAD=67ed84a）相对 master 的 diff：
```
cd /mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local
git diff master...HEAD --stat
git diff master...HEAD -- <逐文件>
```

## 任务背景（一句话）
task-planner 技能把活跃计划全局指针 `plans/.active_plan` 从 git 跟踪文件改为工作树内瞬态状态文件（用户 R1-R4：状态存工作数内/并行不再互顶漂移/合并时忽略该状态文件），并级联 28 文件引用面措辞（退役"移交/legacy"旧语义）+ selftest 锁步。

## 必查清单（按序）
1. **删除基线（Rule 36.3/36.4）**：全链唯一"删除"=`plans/.active_plan` 的 git 跟踪态移除（`git rm --cached`，工作区文件保留为瞬态）+ 措辞改述中的旧词替换——逐文件确认无内容净删（注释改述均带 [2026-10-10 task-v164] 原措辞注记=Rule 45 合规）
2. **Scope 符合性**：diff 文件集 ⊆ 计划执行范围限制表（.gitignore/两指针脚本/critical-rules/SKILL/README/INSTALL/8 hook 脚本/2 selftest/plans/task-v164/**）；越界即 NEEDS_FIXES
3. **行为零改动**：除 check-complete.sh:1346 一处 printf warn 消息字符串（「请移交」→「无需移交、请清理」，display-only，已在计划 Decisions 仲裁登记）外，所有 .sh/.cjs 代码区零改动（可用 `git diff master...HEAD -- '*.sh' '*.cjs' | grep '^[+-]' | grep -v '^[+-][[:space:]]*#' | grep -v printf行` 粗筛后人工核对）
4. **瞬态化正确性**：.gitignore:15 条目 + Why 注释；`git rm --cached` 语义（保留工作区）；critical-rules 新增「瞬态状态文件合并规则」段四要素
5. **解析链语义冻结**：resolve-plan-dir.sh/set-active-plan.sh 除头注释外零改动；selftest-pointer-lifecycle.sh 仅 PL-07 两行锁步（锚 指针移交→指针清理）
6. ** selftest 证据**：baseline-selftest.log（71 段 rc=0）vs regression-worktree.log（72 段 rc=0，唯一差集=decision-grading 新增且过）= 零增量；behavior-verification.log 双树隔离实证
7. **防幻觉抽查**：findings.md 各 [sub:N] 小节随机抽 ≥3 条，对照实际 diff/log 复核锚点真实性

## 输出
- 结论：APPROVED / NEEDS_FIXES（逐项列 file:line+问题+修法）
- 按 8 字段返回格式（见派发 prompt §7）
