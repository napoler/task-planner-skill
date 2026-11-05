# task-skillfix-20261105 · P1-3 修复（L0-lite mini）
plan_tier: mini
- **Goal**: plan-resume/SKILL.md frontmatter 补 `model: haiku`（本仓唯一未配 model 的技能，对齐 4 个配 haiku 的惯例值），worktree 隔离 + 部署 3 位防漂移
- **VC-1**: worktree 内 plan-resume frontmatter 含 `model: haiku` 行；部署 3 位（zcode/claude/cursor）plan-resume diff=0；全量 selftest 零回归
- **scope**: 1 文件 1 行（`skills/plan-resume/SKILL.md`）。P1-1（register-hooks 无锁）经全文核实已 PID 隔离 tmp+幂等 canonical+一次性场景，判定不修；P1-2（引用前缀）经源文件核对命中全为 sibling/尖括号占位符误报，判定不修
- **状态**: 第二轮 COMPLETE（2026-11-05）— ① P1-2 逐条核对终局：validator 22 非 OK（21 ambiguous+1 missing）全部为子串提取误报，源文件已带正确 sibling 前缀/尖括号占位符，**该改=0 零文件改动**，终局判定区+21 条证据档案落盘 subagent-state/04-p12-refaudit.md（1133 行）② P1-3 sonnet：master merge b6f3581，部署 3 位 diff=0（zcode a1cbddc 只 commit 不 push/ahead 7 跨任务隔离；claude 17fed7d 已 push；cursor 落盘）。selftest 如实口径=93/95 全绿+2 FAIL（active-plan/execution-stability 的 T11b 负例类）经主仓 master 基线对照证实为预存环境态失败与改动无关。worktree wt/task-skillfix-p1 已清（a52a909 并入 b6f3581）
- **Goal(第二轮)**: ① 逐条核对 task-planner 的 21 references+1 scripts validator 命中，只修真缺 `../` 前缀的可执行引用（已正确/占位符/sibling 固有歧义→记录不改）② plan-resume frontmatter model haiku→sonnet
- **VC-2**: worktree 内 P1-2 该改项全改+已保留项有记录；plan-resume model=sonnet；selftest 95/95；部署 3 位 diff=0
- **scope(第二轮)**: skills/task-planner/{SKILL.md,README.md,docs/,references/} 中真缺前缀的引用（由核对子代理清单定）+ skills/plan-resume/SKILL.md(model 值 1 字符)
