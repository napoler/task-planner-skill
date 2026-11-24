# Task Learnings: 会话执行回退既有设定缺陷取证与根治
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；#N 序号与 YYYY-MM-DD 示例=模型填写面，脚本禁碰 -->

## New Requests
<!-- Log user-injected requests here. Each entry: timestamp + request + implied scope + plan impact. -->
- 2026-11-24 user-session-log #3：归因口径更正——Git 未执行是技能缺陷，不得推给执行方；交付标准=确保执行方可以正确执行。计划影响：D5 作废 D4 rationale 的「文本条款被跳过」表述，改走脚本+门驱动。
- 2026-11-24 user-session-log #4：解决方案形态定案——Git 操作做成必选 todo 步骤。计划影响：D6 收窄为 B9/B10/B11 纳入原生基线组，不做泛化框架。
- 2026-11-24 协调员补充：①plan-created.cjs 清哨兵前加 B9 校验（首写早于基线的漏洞）；②B11 处置加 retained（换讲法保留）四态机械校验；③现状口径更正（531KB=多会话在途未提交，非回退体量）。计划影响：scope 13 项、VC-11/VC-12、S22/S23、F13/D9/D10。
- 2026-11-24 user-session-log #6（B 类扩展，D12/D13）：压缩后主动重读本地计划文档（钩子或其他方式），避免被带偏。计划影响：三件套（A MK 必保清单复用 spec_baseline / B 改造 zcode-sessionstart.sh 注入 [compact-recovery] / C git-baseline.sh diff 逐条查证）、VC-13..16、S23-S35、scope 17 项、FM8-FM12、约束(a)(b)(c)(d)。
- 2026-11-24 协调员补充约束(d)：01:45:12 压缩注入原文含 [task-resume] 兜售 25 个无关任务标「中断恢复首选」= 被带偏来源；命中在途计划时该段同样不得注入。计划影响：VC-13 判据加 ! [task-resume]、FM11（441）。F17 措辞由主进程补全，计划侧不重复。

## What Worked
- 非侵入快照：真实 index 副本做种子（`cp $(git rev-parse --git-path index)`）→ `GIT_INDEX_FILE` 指工作树外 → `git add -A` → `write-tree` → `commit-tree -p HEAD` → `update-ref`；本仓（约 4800 文件、脏仓、残留嵌套 .git）实测生成树 0.77s、差异 0.03s，不碰真实 index/HEAD/工作树。
- 取证先于归因：先读 R1/R3 材料包 + 11 条 VC command 一手核实，才落 F1/F2；避免凭记忆编造。

## What Didn't Work
<!-- [task-v072 Rule 31.4] 结构化条目 = 错误描述 + 类别标签（信息缺失/假设未验/规则缺位/数据源过时/执行偏差） -->
- `IDX=$(mktemp)` 做临时索引 → `fatal: index file smaller than expected`（类别=假设未验；修法=`mktemp -d` 拼不存在路径）。
- 空索引起步 `GIT_INDEX_FILE=<空> git add -A` → `skills/task-planner/ does not have a commit checked out`（类别=信息缺失：残留嵌套 .git；修法=真实索引副本种子）。
- 把 Git 备份寄托在 SKILL 文字条款（`git stash push -u`）→ 事故中零执行（类别=规则缺位：无脚本/门驱动点；修法=B9-B11 进基线组+脚本登记+门读产物）。

## 🚫 被否决方案（User Rejected — Rule 32）
1. `git stash push -u` 作任务前备份：会动工作树、与并行会话/未提交混合态冲突；`stash create` 不含未跟踪文件。否决日期 2026-11-24（E F.1）。适用范围：本类脏仓基线。
2. 只靠 Rule 27/90 首尾双提交：事故中任务开始前整仓 14.5h 零提交，起点无 commit；用户明确要求脚本/门驱动。否决日期 2026-11-24（E F.2）。
3. 把 Git 状态塞进 planctl.py 新 section + 新 CHECK：冲突面大（planctl.py 有他人未提交改动）、schema additionalProperties:false、shell 禁调 Python。否决日期 2026-11-24（E F.3/D7）。
4. 只靠 VC 增加「保留既有事实」判据：R1→R3 改写发生在执行期，判据本身可被改写；11 条 VC 全绿是反例——降级为第二道线 vc-check，不作主防线。否决日期 2026-11-24（E F.4）。
5. 泛化「基线驱动链」框架 / 新增独立 hook 文件 / 改 StoryLab 项目：用户裁决不做（D6/D3）。否决日期 2026-11-24。
6. G.5 写入前拦截（PreToolUse exit 2 拦会让必保事实词消失的编辑）：默认不做——只覆盖 Write/Edit/ApplyPatch 三类漏面大、误报把合法中间态变停摆门（Rule 95）、B11 diff+restore 已全覆盖且可逐字节还原；仅用户点名才 env TASK_PLANNER_MUSTKEEP_PRETOOL=on opt-in。评估日期 2026-11-24（E G.5/D14）。
7. G2-11 zcode-userpromptsubmit.sh 并入全量必保清单：不改——UPS 每轮注入与压缩恢复包职责重叠、token 成本翻倍、双源漂移；如需可见性本轮也不做。评估日期 2026-11-24（E G2-11/D14）。

## Files Modified
- 本计划期仅写计划目录内：plan-state.json（经 planctl）、knowledge-brief.md、notepad-learnings.md；`task_plan.md/progress.md/verification.md/findings.md` 由 render 派生，未手工 Edit。
- 基线快照 `refs/task-baseline/task-session-regression-20261124`（A1，任务开始前，未改动）。

## Verification Results
- Verified: planctl validate / check vc-nonvacuous / render 结果见本计划 verification.md（执行期回填）。
- Verified: 6 处 B1-B8 命中、Rule 106.5:747、check-complete.sh:1442、4 脚本未提交改动——均本计划期 grep/git 一手核实。
- Failed: 无（本计划期未执行业务改动）。

## 📚 必要知识储备备注
- 本次新发现的知识源：E 设计文档（git-baseline 机制/B9-B11 文案/边界豁免/变异测试）、git 临时索引快照范式、shadow 嵌套 .git 坑。
- 值得入库的书目/文献：本次事故判例（R1→R3 事实改写致倒退、VC 存在性盲区、四态处置）。
- 待补齐的知识缺口：unborn HEAD 下 commit-tree 无 -p 分支未实跑；重命名/二进制差异判定待草稿仓校准；env 档位对存量计划的实际兼容面待 P4 验证。

## Notes for Next Time
<!-- [task-v072 Rule 31.4/31.5] 消费侧契约：条目格式 = 触发条件 + 防线一句话 -->
- 触发条件：任何「修改既有产物」任务（含 bugfix/refactor/文档改写）→ 防线：B9 前写基线快照 + B11 全量 diff 四态处置，缺一不得出 outcome。
- 触发条件：声称「VC 全绿/复审通过」时 → 防线：先问「有没有一条对照基线检查既有内容仍在」，没有则复审不可信（本次事故 11 VC 全绿反例）。
- 触发条件：设计 Git 自动化时 → 防线：机械操作（Git/plan/todo）必须有同等脚本+门+契约驱动链，文字条款不算驱动。
- 触发条件：变更标注时 → 防线：删除既有事实须区分 retained/authorized/restored/fixed，「文件在 scope 内」不等于授权。

## 通用规则（General Rules — Rule 31.7）
| 规则名称 | 适用条件 | 具体措施 |
|----------|----------|----------|
| 机械操作同驱动链原则 | 任何依赖「执行体正确调用」的安全步骤（Git/备份/隔离） | 脚本执行 + 门读登记产物 + todo 必选项，三件套缺一即视为无驱动；完成以证据为准非勾选 |
| 存在性 VC 不足以保全 | 修改型任务的 VC 集 | 至少一条对照基线检查既有内容仍在（B11 全局 diff 为主防线，vc-check 为第二道线） |
| 基线先于首写 | 有受管文件写入的计划 | 清哨兵前校验基线字段；缺基线拒写；无哨兵会话 late 标记披露 |
| 变更四态判别 | 修改既有文件产生删除行 | 逐项判 retained（事实词查当前文件）/authorized（用户授权锚）/restored/fixed；unresolved 清零方可出 outcome |
