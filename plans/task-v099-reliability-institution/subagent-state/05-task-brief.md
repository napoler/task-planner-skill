# P3 任务书: 模板行 + plan-writer 义务行 + 新 selftest + registry（task-v099）

任务: worktree 内四个小改——① general 模板配置表加「质量审查工具」行 ② mini-lite 豁免行 ③ plan-writer.md 义务行 ④ 新建 selftest-reliability-institution.sh（R-01..R-12）+ selftest-registry.tsv +1 行。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md: /mnt/data/dev/task-planner-skill/plans/task-v099-reliability-institution/task_plan.md（只读: VC-3/VC-4/VC-5 判定标准）
- findings.md: /mnt/data/dev/task-planner-skill/plans/task-v099-reliability-institution/findings.md（只读）
- progress.md: /mnt/data/dev/task-planner-skill/plans/task-v099-reliability-institution/progress.md（子代理禁写）

## 目标文件（worktree /mnt/data/dev/task-planner-skill-worktrees/task-v099-reliability-institution 下）
1. skills/task-planner/templates/task_plan.md（配置表 :25-30 区,5 行表 `code_review/session_id/worktree_path/scope_files/interaction_mode` 附近）
2. skills/task-planner/templates/variant/mini-lite-type.md（头部注释区,既有 :7 Rule 40.2 豁免行形态范式）
3. skills/task-planner/companion/agents/plan-writer.md（「掌握的技能/撰写义务」区 :40-45 附近,先 Read 定位）
4. 新建 skills/task-planner/scripts/selftest-reliability-institution.sh
5. skills/task-planner/scripts/selftest-registry.tsv（当前 39 行,追加 1 行）

## 操作内容
### ① 模板配置表 +1 行（插 `interaction_mode` 行之后,表内纯增）
`| \`质量审查工具\` | \`[检测结论]\` | Rule 42 消费登记（42.4）：任务涉及质量审查面时按 42.2 三级检测,填 技能名/既有 agent 名/待补充 S-unit 指针;缺口按 42.3 补建并登记 S-unit;执行期必须用登记工具;mini 档豁免（42.5） |`
### ② mini-lite 豁免行（头部注释区追加 1 行,对齐既有豁免行形态）
`<!-- Rule 42.5 豁免声明（task-v099）: mini 档不含「质量审查工具」配置行——Rule 38.3 轻量模板契约的自然延伸（同 40.2 豁免行范式） -->`
### ③ plan-writer.md 义务行（「掌握的技能/撰写义务」bullet 区追加 1 行,先 Read 定位该区;禁动既有 bullet 与既有锚子串「问题解构四问」「纯数字」）
`- 质量审查工具检测登记与可靠性义务（task-v099, Rule 42/43）: standard/full 档计划配置表必填「质量审查工具」行（42.4 三级检测结论）;S-unit 表逐行标注「建议档位」（43.2 最小可承载档）;推荐/选项呈报前登记候选对比表或假设清单（43.3）;交付声称附可复现证据,未验证内容显式标「未验证」（43.1）;mini 档豁免全部四项`
### ④ 新建 selftest（先 Read 范式）
- 范式源: skills/task-planner/scripts/selftest-self-resolution.sh（SR-01..12 全貌:SCRIPT_DIR/SKILL_ROOT 路径解析+ok()/bad()+编号断言+`Total: N PASS=x FAIL=y` 结尾,照同构写）
- R 断言 12 条: R-01 critical-rules `grep -c '^42\.'`=5;R-02 `'^43\.'`=4;R-03 42.2 含「均未命中=缺口」;R-04 42.3 含「S-unit 登记」字样（grep「S-unit」在 ^42.3 行）;R-05 43.1 含「未验证」;R-06 43.2 含「最小档位」;R-07 43.3 含「候选对比表」;R-08 SKILL `grep -c '| C30 |'`=1 且 `'| C31 |'`=1;R-09 SKILL `grep -c '含 Rule 40/41/42/43'` ≥1 且 `grep -c '1-40'`=0;R-10 模板 `grep -c '质量审查工具' templates/task_plan.md` ≥1;R-11 mini-lite `grep -c 'Rule 42.5 豁免' variant/mini-lite-type.md` ≥1;R-12 config.json properties 键数=40（零新键,同 WF-12 口径——先看 selftest-workflow-orchestration.sh WF-12 怎么写的照抄口径）;plan-writer 义务行断言并入 R-11 或 R-10（12 条总数不变,内容你裁,但 12 条总数与编号必须齐）
- 脚本纯静态只读（grep/wc）,零仓库写入,bash -n 通过
### ⑤ registry +1 行（对齐 tsv 既有四列格式,先 head -3 看表头）
script=selftest-reliability-institution.sh / domain=Rule 42/43 质量审查检测+执行可靠性制度化 / trigger_scenarios=「Rule 42 质量审查工具检测登记;Rule 43 证据先行/档位经济/候选预验证;C30/C31;SKILL 三锚;零新 config 键」 / dep_anchors=「critical-rules.md ^42/^43 锚;SKILL.md C30/C31+摘要行;templates 质量审查工具行;config properties=40」

## acceptance: 验收标准
1) `bash scripts/selftest-reliability-institution.sh` Total 行 12/0（R-01..12 全 PASS）
2) `bash -n` rc=0
3) `bash scripts/selftest-registry.sh` Total 0 FAIL 且 rows=actual=39
4) tsv `wc -l`=40
5) plan-writer.md 既有锚保全: `grep -c '问题解构四问'`=改前值、`grep -c '纯数字'`=改前值（改前先记录）
6) 4 模板/契约文件 grep 命中: 质量审查工具=1（模板）/Rule 42.5 豁免=1（mini-lite）/「质量审查工具检测登记」=1（plan-writer）
7) `git -C <wt> diff --stat` 本步面=5 文件（templates×2+plan-writer+新脚本+tsv）;critical-rules.md/SKILL.md/skill-split 为 P2 已提交存量不重复出现

## checkpoint
完成前把结论与命令实际输出写入 /mnt/data/dev/task-planner-skill/plans/task-v099-reliability-institution/subagent-state/05-executor-p3.md。禁 git commit/add。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P3
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
