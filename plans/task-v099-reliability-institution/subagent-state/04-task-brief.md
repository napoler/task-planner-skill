# P2-S2 任务书: SKILL.md 三锚联动 + 行数级联（task-v099）

任务: worktree 内 SKILL.md 三锚联动 Rule 42/43 + selftest-skill-split.sh:41 行数断言级联。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md: /mnt/data/dev/task-planner-skill/plans/task-v099-reliability-institution/task_plan.md（只读: VC-2 判定标准）
- findings.md: /mnt/data/dev/task-planner-skill/plans/task-v099-reliability-institution/findings.md（只读）
- progress.md: /mnt/data/dev/task-planner-skill/plans/task-v099-reliability-institution/progress.md（子代理禁写）

## 目标文件（worktree /mnt/data/dev/task-planner-skill-worktrees/task-v099-reliability-institution 下）
1. skills/task-planner/SKILL.md（当前 435 行）
2. skills/task-planner/scripts/selftest-skill-split.sh（仅 :41 断言行）

## 硬约束
- 「Rules 1-39」字面 2 处（:242/:297 区）本体不动,只允许括注扩写;全文禁止出现「1-40」「1-41」等越界数字字面（v097 对策 b 锁,完成后 `grep -nE '1-4[0-9]' SKILL.md` 必须 =0）。
- 既有锚子串逐字保全: 「| C29 |」（:194 行首）、「Rule 41（问题自主消解与升级纪律 — task-v098）」（:273）、Rule 40 摘要行、References 表既有枚举——只增不改。
- 零新 config 键;不动其他任何文件。

## 三锚操作（行号以内容锚定位,±3 漂移正常）
1. **C29 行（含「| C29 |」的表行）之后追加 C30+C31 两行**:
`| C30 | 质量审查工具检测与登记（Rule 42）：本任务涉及质量审查面（内容组=发布前质量审计/代码组=Code Review）时已按 42.2 三级顺序检测（项目级→用户级→环境既有 agents），检测结论（技能名/既有 agent 名/待补充 S-unit 指针）已登记计划「质量审查工具」行；缺口已按 42.3 补充合约处置（补建动作作为 S-unit 登记进计划，禁无登记私建技能）；执行期质量审查动作已用登记工具（未检测=违规，Rule 26 降质面）（机器面=selftest-reliability-institution 静态断言，检测过程人工核查；mini 档 42.5 豁免） | ☐ |`
`| C31 | 执行可靠性制度化（Rule 43）：交付物重要声称（已完成/正确/通过）已附机器可复现验证证据（命令+关键输出/Read 路径+关键行/diff 行号），未验证内容已以「未验证」显式登记（43.1）；S-unit 表逐行标注建议档位且取最小可承载档（43.2，失败先 22.3 升档非默认大模型）；推荐/选项化呈报前已枚举 ≥2 候选并过最轻验证后按候选对比表选已验证最优（43.3），验证成本过高时降级假设清单+验证顺序（机器面=selftest-reliability-institution 静态断言，证据核查人工） | ☐ |`
2. **Rule 41 摘要行（含「Rule 41（问题自主消解与升级纪律 — task-v098）」的行）之后追加两行摘要**:
`- **Rule 42（质量审查技能主动检测与补充 — task-v099）**：任务涉及质量审查面时按三级顺序检测（42.1/42.2 项目级→用户级→环境 agents，均未命中=缺口）；缺口按补充合约处置——该任务项目级补建专用质量审查技能且补建动作作为 S-unit 登记进计划，禁无登记私建技能（42.3）；计划「质量审查工具」行登记检测结论，执行期必须用登记工具（42.4）；零新 config 键+mini 档豁免（42.5）`
`- **Rule 43（执行可靠性制度化 — task-v099）**：证据先行反幻觉——重要声称必附机器可复现验证证据，未验证内容只能以「未验证」显式登记，子代理 8 字段 evidence 无证据=该项未完成（43.1）；模型档位经济性路由——S-unit 逐行标注建议档位，取最小可承载档，失败先 22.3 升档（43.2）；方案预验证与最优选择——呈报前枚举 ≥2 候选各过最轻验证，候选对比表裁决，验证成本过高降级假设清单（43.3）；C30/C31 消费+零新 config 键+selftest-reliability-institution.sh 守护（43.4）`
3. **:242 索引行「（Rules 1-39（含 Rule 40/41）」** 括注扩写为「（Rules 1-39（含 Rule 40/41/42/43）」（行数 +0）;若 :297 附近 References 表 critical-rules.md 行枚举含「/ Rule 41 问题自主消解与升级纪律」,枚举末尾追加「 / Rule 42 质量审查技能主动检测与补充 / Rule 43 执行可靠性制度化」（行数 +0）。

## 行数级联
三锚完成后 `wc -l SKILL.md` 实测 N（预期 435→439,净增 4）,把 selftest-skill-split.sh:41 的 `-le 435` 改为 `-le N`,label 改为「T-主 行数 ≤N（task-v099 Rule 42/43 联动 435→N）且 ≤558 上限」——级联值一律以 wc 实测为准禁手估（v098 教训）,同函数内 `-le 558` 不动。

## acceptance: 验收标准
1) `grep -c 'Rule 42' SKILL.md` ≥2 且 `grep -c 'Rule 43' SKILL.md` ≥2;`grep -c '| C30 |'`=1 且 `'| C31 |'`=1
2) `grep -c 'Rules 1-39' SKILL.md` =2（字面保留）;`grep -c '1-40' SKILL.md`=0 且 `grep -c '1-41' SKILL.md`=0 且 `grep -nE '1-4[0-9]' SKILL.md` 无命中
3) 既有锚保全: `grep -c '| C29 |'`=1;`grep -c 'Rule 41（问题自主消解与升级纪律'` ≥1;「含 Rule 40/41」旧字面被括注扩写取代后 `grep -c '含 Rule 40/41/42/43'` ≥1
4) 级联: skill-split.sh:41 `-le N`（N=wc 实测）且 label 含 task-v099
5) worktree scripts/ 复跑 4 脚本 0 FAIL: selftest-skill-split/selftest-workflow-orchestration/selftest-knowledge-brief/selftest-skill-collab（Total 行原文记检查点）
6) `git -C <wt> diff --stat` 累计=3 文件（critical-rules.md 为 S1 存量,本步恰 2 文件）

## checkpoint
完成前把结论与命令实际输出写入 /mnt/data/dev/task-planner-skill/plans/task-v099-reliability-institution/subagent-state/04-executor-p2s2.md。禁 git commit/add。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P2-S2
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
