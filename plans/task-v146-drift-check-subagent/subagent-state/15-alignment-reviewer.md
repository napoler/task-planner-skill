# Checkpoint 15 — alignment-reviewer（消费 alignment-review skill）

status: FINAL
verdict: CHANGES_REQUESTED
range: worktree /mnt/data/dev/task-planner-skill-worktrees/task-v146 @ HEAD 8811a58, base da1f308
scope: 31 文件（提示词写 32，实测 31；登记为偏差）

## 结论
1 项 P1（合并前必须修复）+ 4 项 P2/QUESTION/NIT；P0=0。

## 发现
- [P1] skills/task-planner/scripts/selftest-agent-coverage.sh:6
  头部摘要注释仍写「矩阵行数锚（-le 128 上界」；同文件 :205 代码断言已改 `-le 129`，:196 明细注释亦为 129。
  本次改动把 AC-09 上界 128→129（同文件），却漏改文件自身头注 → 文件内自相矛盾（注释↔代码不同步）。
  证据: grep -n 'le 12[89]' → :6 128 / :196,:205 129。修法: line 6 改 129。
  （注: :199「矩阵 128 行锚此前无机器断言」为历史叙述，非缺陷，排除。）
- [P2] skills/task-planner/SKILL.md:9 frontmatter「Critical Rules 全集 1-58」与 :340 References 表尾（…Rule 55 可复用能力落盘纪律）未随索引 :271「Rule 40-61 全集」上推；
  三处上界（58/55/61）不一致（基线既有 58 vs 55 偏差被本次索引 40-55→40-61 放大）。Rule 59 由并行 v144/v145 预留。建议 Phase 5 簿记统一或显式 deferred。
- [P2] skills/plan-cost-guard/references/cost_log.md:18 档位标注「haiku」与同批 billing.md:15/cost-control.md:13「haiku-1」不一致（重命名当批未统一档位串）。
- [P2] CHANGELOG.md 未新增 [Unreleased] 条目；仓库惯例（v085-v090）每任务一条。scope 禁「changelog 历史行」但不含新增；Phase 5 簿记列 INDEX/ledger 未列 CHANGELOG。建议 Phase 5 补登。
- [QUESTION] skills/task-planner/SKILL.md:271「含 Rule 40-61 全集」而 critical-rules.md 无 ### 59（并行预留），「全集」措辞严格性存疑；沿用基线既有口径（40-55 全集 而 56-58 在位），非本次引入，不阻断。
- [NIT] 审查提示词称「32 文件」，实测 git diff --name-only = 31。

## 通过项（负结果/证据）
- 术语一致性: 全仓 `Skill("task-drift-guard")` 精确串仅存于 selftest 自身负断言 3 行 + plans/archive 历史；skills/ 实体面（SKILL/business/hook）残留=0。
- 引用完整性: companion/agents/drift-checker.md、references/critical-rules.md、scripts/selftest-drift-check-subagent.sh、../task-drift-guard/SKILL.md、references/agent-coverage.md 五路径 test -f 全 OK。
- 计数联动: 矩阵 wc -l=129=AC-09(:205)；registry.tsv +1 行（drift-check-subagent）在位；critical-rules 尾规=61。
- 守卫锚级联: 6 锚（CP-05/IP-12/R-09/SR-08/EH-09/RR-16）宽容化后 grep 命中 SKILL.md:271；6 脚本自跑 FAIL 集合 = 各自基线（SAME-FAILSET ×6）。
- 新 DCS: selftest-drift-check-subagent.sh 20/20 PASS。
- AC-04 FAIL = drift-checker 部署前暂态（VC-4 允许），AC-07 FAIL(properties=42) = 基线预存；基线 8P/1F → 现 7P/2F，差值仅 AC-04。
- 越界自检: 31 文件全部落在 scope 表（6 个锚脚本由 S7-S9 授权，task_plan.md:134-136）。
- 模板回溯: 9 variant + task_plan.md 全切；旧载体残留 grep exit=1（0）。
- 多副本/部署位: 本次 N/A（合并前无部署）→ 登记由 Phase 5 deploy 三位 diff 覆盖。
- i18n: INSTALL_zh.md 非 skills/task-planner/INSTALL.md 的 1:1 副本（内容/受众不同），其 task-drift-guard 提及属交互载体（保留），无需改。

## 变更记录三要素
- 变更范围: 审查实施体=只读全量核对 31 文件 + 计划三文件 + KB §2/§5.4；无写入（唯一写=本检查点）。
- 冲突处理结果: 无；未决残留=上述 1×P1 + 4×P2/QUESTION/NIT。
- 文档当前状态: 载体切换全链一致（drift-checker 子代理 = Rule 15/61 唯一流程载体，task-drift-guard skill = 交互载体，双载体三态一致），except 上述注释/枚举级次残留。

verdict 依据: alignment-review 输出合约——任一 P1 命中 → CHANGES_REQUESTED。
