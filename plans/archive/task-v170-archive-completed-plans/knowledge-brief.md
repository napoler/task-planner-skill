# Knowledge Brief — task-v170-archive-completed-plans（任务知识简略要点）

> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识。

## §1 任务速览与核心概念
- 任务一句话：给 task-planner 技能加「计划完成后归档」机制（archive-plan.sh + 完成流程接线 + Rule 81 + selftest），并把存量约 110 个 completed 计划全部归档进 plans/archive/。
- 背景/动机：用户发现完成任务后缺归档步骤，plans/ 根目录堆积 110+ 目录。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 归档 | git mv plans/<task-id>/ → plans/archive/<task-id>/，目录内容不动，可 revert |
| 守卫 | active 指针/.session-owner/Status≠complete 三类目标禁归档（fail-closed exit 1） |
| dry-run | --batch --dry-run 只列候选与跳过理由不动盘；实做需双采样预检通过 |
| session-owner | 计划目录内的会话活标记文件，在场=该计划有活会话，禁归档 |
| Rule 20.6 | 新 Rule 编号须在计划声明 new_rule 并由 attest 自动查重登记 |

## §2 已验证关键事实

| 事实 | 证据 file:line | 影响 |
|------|----------------|------|
| 完成流程（SKILL.md 终验交付段 L165-184）无归档步骤 | plans/task-v170.../findings.md §1；SKILL.md:165-184 | 接入点=check-complete 行后插 ≤6 行 |
| plans/ 任务目录全 git 跟踪 | `git ls-files plans/` 输出（task-v155 等目录内文件在列） | git mv 可 revert；批量失败可回滚 |
| archive 已有 21 目录先例（commit 714c93b，plan-hygiene.sh --execute） | git log --oneline -- plans/archive/ | 形态沿用，不追溯 attestation 缺失 |
| plan-created.cjs 已有 archive 前缀跳过 | skills/task-planner/scripts/plan-created.cjs:10,122 | 跳过模式有先例，扩展三脚本同模式 |
| Rule 编号现状：77/78/79 封存于 wt/task-v168-machine-parked 未 land；80 被 task-v169 预留 | plans/.rule-reservations.jsonl；task-v168 计划 L71 | new_rule=81；禁占用 77-80 |
| 主仓 plans/INDEX.md 有并行会话未提交变更 | check-conflicts.sh 信号① | 存量 data 面改动推迟到合并回后主仓执行 |
| 交互模式先例：v168/v169 计划均声明 silent | 各自 task_plan.md L68/L68 | 本计划 silent 有先例 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要 |
|------|------|-----------|
| /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md | :165-184 | 终验交付段：Read verification.md→VC 复验→委派率→3-File Gate→质量门控→合并回→编号账本→交付结论→delivery-summary→退出前 check-complete.sh（归档插入位=check-complete 行之后） |
| /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md | :Rule 76 正文之后 | Rule 81 插入点（最大 landed=76；77-79 封存不计） |
| /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/plan-hygiene.sh | 全文 | 既有 plans 卫生脚本，archive-plan.sh 风格参照 |
| /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/set-active-plan.sh | :3-233 | 指针管理（gc 扫 .plan_required_side + plans/*/.session-owner） |
| /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/sync-todos.sh | :7-163 | 扫 plans/*/task_plan.md 生成 INDEX.md |
| /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/resolve-plan-dir.sh | :9-23 | 活跃计划解析（side→fallback→mtime 最新） |
| worktree（实现区） | /mnt/data/dev/task-planner-skill-worktrees/task-v170-archive-completed-plans | 全部机制实现在此；主仓 CWD 不动 |

## §4 易错点与禁止假设清单
1. 禁止归档在途：v168/v169/v162 是活会话计划（.session-owner/未跟踪 untracked），守卫必须 fail-closed；试点目录只能选确定 complete 且无 owner 的（候选=task-v055-scheduler-enforce，Phase 1 确认）
2. 禁止改 config.json（零新键铁律）；禁改 check-complete.sh 既有 exit 语义（ARCHIVE-GATE 恒 exit 0）
3. SKILL.md 行号引用级联=历史高危面（v166/v168  precedents）：插入行后必须 grep 全部 SKILL.md:NNN 引用与行数钉并同步演进；'1-76' epoch 字面量同样级联（先 grep -cE '1-7[0-9]' 后改）
4. 禁止把 plans/ data 面（INDEX 重生/批量 mv）放进 worktree 合并——主仓 INDEX.md 未提交变更会撞车
5. 新 selftest 必须登记 registry（先例：v125 教训：漏登记=机器账缺失）
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「Phase 4 S3 SKILL.md 行号引用级联漏改」行（RPN 210）与「Phase 3 S2 守卫漏判」行（RPN 108）

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1 | §2+§3 | /mnt/data/dev/task-planner-skill/plans/task-v170-archive-completed-plans/findings.md |
| S2（archive-plan.sh） | §1+§2+§3+§4 | /mnt/data/dev/task-planner-skill/plans/task-v170-archive-completed-plans/task_plan.md；skills/task-planner/scripts/plan-hygiene.sh |
| S3-S6（接线） | §3+§4 | worktree 绝对路径（prompt 附） |
| S7-S8（守护/级联） | §4 | worktree 绝对路径（prompt 附） |
| S9-S11（测试） | §2+§4 | worktree 绝对路径（prompt 附） |
| S13（批量） | §2+§4 | /mnt/data/dev/task-planner-skill/plans/（主仓） |

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| code-review（内置 review-library 池） | 见 ~/.zcode/skills/task-planner/review-library | Phase 6 CR Gate 代码组审查 | 子代理 prompt 挂载（code-reviewer agent 自带） |
| task-planner（本技能） | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md | 全流程协议载体 | 主进程已激活使用中 |
| using-git-worktrees | /home/terry/.zcode/skills/using-git-worktrees/SKILL.md | Phase 7 worktree 合并清理 | 主进程参考（smart-merge-back 已封装） |
| brainstorming | /home/terry/.agents/skills/brainstorming/SKILL.md | 设计期（已完成） | 已激活（本轮会话） |
