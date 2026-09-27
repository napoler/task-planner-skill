# S28 B-1 checkpoint（task-v091 派发模板压缩）
status: done（2026-09-27，executor subagent）

## 里程碑
- T1 进场核对：worktree HEAD=a243253 status clean ✅
- T2 提案 B-1（§三簇② L103-111）+122 行模板+22.4b:134 读取 ✅
- T3 实施 4 项：模板 122→67→60 行 / dispatch-examples.md 新建 41 行 / 22.4b 绑定修订 / selftest-dispatch DX-01..05b ✅
- T4 验收+commit ✅

## 产出文件
- skills/task-planner/templates/subagent_dispatch.md（60 行）
- skills/task-planner/references/dispatch-examples.md（41 行，新建）
- skills/task-planner/references/critical-rules.md（22.4b:134 绑定修订）
- skills/task-planner/scripts/selftest-dispatch.sh（DX-01..05b）
- skills/task-planner/scripts/selftest-registry.tsv（selftest-dispatch 行 dep_anchors 同步）

## commit
- 349d94e（4 文件绑定同 commit，首版 67 行）
- f8284d0（67→60 收紧 + registry 同步；首版 67 未达任务 ≤60 验收，补 commit）
- 消息：refactor(task-planner): task-v091/S28 B-1 — 派发模板压缩 122→≤60 行+样例外置+22.4b 绑定

## 最终结论（8 字段）
status: done
acceptance: 4/4 pass — [1:进场 rc=0 PASS 2:实施 4 文件 PASS 3:验收全项 PASS 4:commit 2 笔 PASS]
files: /mnt/data/dev/task-planner-skill-worktrees/task-v091/skills/task-planner/templates/subagent_dispatch.md(-62/-+... →60 行); /mnt/data/dev/task-planner-skill-worktrees/task-v091/skills/task-planner/references/dispatch-examples.md(+41 new); /mnt/data/dev/task-planner-skill-worktrees/task-v091/skills/task-planner/references/critical-rules.md(+1/-1); /mnt/data/dev/task-planner-skill-worktrees/task-v091/skills/task-planner/scripts/selftest-dispatch.sh(+31); /mnt/data/dev/task-planner-skill-worktrees/task-v091/skills/task-planner/scripts/selftest-registry.tsv(+1/-1)
evidence: wc -l subagent_dispatch.md → 60; 双向 rc GOOD check=0 / BAD check=1（缺项逐行点名 task_plan.md..subagent-state/）/ BAD pretool enforce=2 [dispatch-block]; selftest-dispatch Total: 29 PASS=29 FAIL=0（DX-01..05b 全 PASS）; conclusion-discipline 24/0, fine-grain-steps 11/0, knowledge-brief 16/0, registry 5/0（rows=32=actual 32）, delegation 38/0, plan-tier 32/0
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v091-efficiency-optimization/subagent-state/S28-dispatch-template.md (status: done)
findings_written: none
blockers: none
confidence: HIGH

## 零丢失核对对照表（关键锚 token，orig=122 行版 grep 计数 vs new=模板+examples 合计）
九字段=1/1, 目标=1/1, 验收标准=2/2, Scope 禁改清单=1/1, 工作路径=1/1, 时长预算=1/1, 返回格式=1/1, checkpoint 落盘路径=1/1, 上下文预算=1/1,
22.4a=1/1, 22.4b=1/3(绑定后引用增), 22.8=4/6, 22.8.5=1/1, 22.8.2 T5=1/1, 22.7.1=1/3, 22.8.4=1/3, 35.3=1/1, step_max_steps=1/1,
prompt_max_chars=1/1, 机械求和=1/1, knowledge-brief=1/1, subagent-state=3/3, 任务书=1/1, knowledge_brief=1/1,
Research Findings=1/1, Technical Decisions=1/1, Actions taken=1/1, Status/Started=1/1, append-only 带时间戳=1/1,
done|partial|failed|timeout=1/1, HIGH|MED|LOW=1/1, 防返回消息丢失=1/1, 无 frontmatter=1/1, 摆烂上报=1/1, 22.3.3=1/1,
git diff/status/log=1/1, 计划期预写=1/1, task-v081=1/1, 只填路径=1/1, 预算约束=1/1
两处「MISSING」为结构合并（语义保留）：
- 「材料包来源」（orig L23 独立行）→ 并入 §2 首行「材料包绝对路径/来源:取自 task_plan.md 该 Phase S-unit 表「输入」列」，「材料包绝对路径」「取自 task_plan.md 该 Phase S-unit 表」两锚各 1/1 在位
- 「输入」occurrences 4→3：orig L10「## 2. 输入」标题+L15「材料包绝对路径(取自 S-unit 表「输入」列)」+L96「只注入本 S-unit 所需材料」+L94「把输入拆成」；new 版 §2 标题(1)+「S-unit 表「输入」列」(1)+§9 两字面合并进一行(1)=3，所有语义保留
排除了的风险：CD-16/CD-22 模板锚（超限补救/机械求和）在位；SG-10 步骤枚举锚在位；T7 knowledge-brief 锚在位；registry 守护通过

## 备注（环境事件，非本任务引入）
- 执行窗口内主仓/同 worktree 并行会话提交 1b9437e（S29 B-2）与未提交 smart-merge-back.sh 改动——非 B-1 改动面，未触碰
- worktree 分支现 HEAD=f8284d0（wt/task-v091-efficiency-optimization）
