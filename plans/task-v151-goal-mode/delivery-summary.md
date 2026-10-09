# Delivery Summary — task-v151 goal 单元固化与 /goal 驱动推进纪律（Rule 66）

## 1. 说明
用户 2026-10-09 三次澄清定稿方向：规划之后的任务单元固化为「任务名+目标+完整验证方式」，用 ZCode 内置 /goal 目标模式逐个推进，确保后期执行可靠性。落地=task-planner 技能新增 Rule 66 全链（条款+模板+双守卫+新 selftest+部署位同步）。执行过程含一次方向纠正（初版「自建机制」被用户否决回炉，见 Errors 登记）。

## 2. 产出清单
| 产出 | 位置 | 说明 |
|------|------|------|
| Rule 66 六子条 | /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md 行 848-860 | 66.1 goal 单元固化（六列契约）/66.2 内置 /goal 口径（不可代调·映射供料）/66.3 逐 goal 验证通过门/66.4 分解→调度→逐个解决推进序/66.5 模板承载+档位三分支（S4b 主进程 D2 裁决）/66.6 机制 |
| 🎯 Goal 单元表模板区块 | 仓内 skills/task-planner/templates/task_plan.md 行 104 起 | 六列表头+注释+示例行；standard/full 必填、mini 豁免、无标记缺省跳过 |
| 66.5 attest 门 | 仓内 scripts/check-plan-dispatch.sh 行 314 起 + attest-plan.sh --skip-goal-check 接线（CR F1） | 显式 standard/full 缺区块拒锁；四态实测 |
| [goal-gate] 终验对照 | 仓内 scripts/check-complete.sh 行 1212 起（档位口径 CR F2 后统一） | complete 行无 [goal:Gn] 证据行→exit 1；pending 行→PARTIAL 提示 |
| 新 selftest | 仓内 scripts/selftest-goal-unit-goal-mode.sh（G-01..G-09）+ selftest-registry.tsv 65 行 | exit 0 全 PASS |
| SKILL.md 级联 | 仓内 SKILL.md（1-66 三处计数+Rule 66 摘要行+C45 合规行） | 钉值级联 9 脚本随行 |
| 提交 | master ebb5fba（merge）← 101475f（feat）+ 6cf8cd7（CR F1-F3 修复） | git -C /mnt/data/dev/task-planner-skill log --oneline -3 |
| 部署位 | /home/terry/.zcode/skills/task-planner + /home/terry/.cursor/skills/task-planner + /home/terry/.claude/skills/task-planner | 8 核心文件 cmp 全 OK；SKILL.md 平台前缀差异=install 固有定制面（三平台各自正常） |
| 审计 | plans/task-v151-goal-mode/subagent-state/02-audit-full.md | 7 面全量：0 P0/P1；5 P2 全定性 |

## 3. 审查信息
- CR 对象：worktree commit 101475f（16 文件 +354/-35）
- CR 执行体：Code Reviewer 子代理（sonnet-1），检查点 /mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/subagent-state/11-code-reviewer-S6.md
- 结论：首轮 CHANGES_REQUESTED（V2 一致性 FAIL：F1 逃生口未接线 attest / F2 goal-gate 档位口径与 66.5 分叉 / F3 死变量）→ fix-phase commit 6cf8cd7 三态复测全过 → 修复面 8 字段 4/4 pass（检查点 13-executor-S6fix.md）
- 对齐/回归面：修复后全量 64 selftest ΣFAIL=0（plans/task-v151-goal-mode/final-regression.log「scripts=64 ΣFAIL=0」行）
- 独立审计：Explore 全仓审计（检查点 02-audit-full.md）——机械锚 20+ 条/条款引用 48 脚本+20 config 键/C1-C45/registry 64=64/部署位 diff/守卫误报面试跑，全部通过
- 第二轮重 CR（官方文档对照）：检查点 15-code-reviewer-S9.md，必须修 0/建议增强 2（66.2 补单目标约束消歧+plan 模式冲突提示）→ 增强已落地 7fa66ac

## 需求覆盖核对表（Rule 51.1a 终验载体）

| R | 状态 | 证据路径 |
|---|------|---------|
| R1 | covered | plans/task-v151-goal-mode/subagent-state/03-executor-S1.md（Rule 66 六子条 848-860 落地验证行） |
| R2 | covered | plans/task-v151-goal-mode/subagent-state/10-executor-S4b.md（POST-FIX ΣFAIL=0 行）+ 15-code-reviewer-S9.md（V1-e 官方写法要点对齐） |
| R3 | covered | plans/task-v151-goal-mode/subagent-state/00-goal-empirical.md（/goal 无程序化触达面实证 3 处）+ 09-goal-official-docs.md（官方 4 页定位=内置命令） |
| R4 | covered | skills/task-planner/references/critical-rules.md 行 856（66.4 推进序）+ subagent-state/04-executor-S2.md（attest 门 66.5 段） |
| R5 | covered | plans/task-v151-goal-mode/task_plan.md Errors Encountered 表 + Decisions veto 行 + ledger-main.jsonl error 事件 |

## 4. 风险点
1. ~~**仓内扫描路径遗留 .backup**~~ 已处置（2026-10-10）：`skills/task-planner/.backup/claude-stub-20261009-222907/`（11MB）已移至 `~/skill-deploy-backups-task-v151-claude-stub-20261009-222907`（v146 判例惯例位置）；仓内 .backup 目录已清空（gitignored 空壳保留无害）。
2. **部署位 SKILL.md 平台前缀差异为固有设计**（zcode/cursor/claude 各自 install 定制 frontmatter），对账时按「8 核心文件 cmp」口径判定，勿按全文 diff 误报。
3. **本计划 G5/G6 证据行补齐于 Rule 66 落地后**（机制首实例的合法缺口，progress.md Phase 4/5 段已补 [goal:G5]/[goal:G6]）。
4. **同会话多目标观测面未定界**（用户 2026-10-10 裁决跳过）：db.sqlite session_target 实证=每会话仅 1 个目标对象（75/75 会话，状态分布 active 10/complete 43/paused 22），用户观测的「同会话多目标」最可能为迭代桶面板（collectGoalIterationBuckets）视觉呈现——留作观察项，不阻塞本任务；Rule 66.2 现行口径（单目标约束引官方文档）在定界前不动。
5. 无其他：CR/审计均无 P0/P1 残留；check-complete Rule 27.3 提示（plans/ 未入库）为仓约定正常面。

## 5. 下一步建议
1. ~~对象=仓内 .backup → 动作=外移~~（已完成，见风险点 1 删除线）
2. 行为面冒烟：新会话开一个 plan_tier: standard 计划实跑 attest，验证 66.5 硬门真入口生效（本机 hook 从部署位跑，部署已含新守卫；含 /goal 目标模式配合观察）——需用户新开会话。
3. 宪法 §一 同步：/goal 目标模式纳入用户级 AGENTS.md 执行纪律（保护区文件，须用户显式授权）。
4. v152/v153 worktree（vt/v152-proactive-context、vt/v153-parallel-scheduling 在 /mnt/data/dev/task-planner-skill-worktrees/）为并行任务面，各自合并时注意 skills/ 范围冲突（本任务 worktree 已清）。
