# 派发指令：计划文档审计修正（R1 REJECTED 后修正轮）

只改计划文档（task_plan.md / verification.md / progress.md），不改技能源文件、不改 findings.md（背景参照读）、禁改 user-session-log.md。worktree=/mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120/（只读参照）。

## 需求锚（Rule 51.1a 逐字引用）
R1（task_plan.md 根源覆盖表）=「同 sid 在途 claimant 场景下 init 一次写入 side 指针且输出通告无 skip（VC-1）；set-active-plan skip 路径输出明确「指针未切换」且调用点影响评估留痕（VC-2）；in_progress 守卫锚定状态控制行不误命中模板字样（VC-3）；SKILL D/E 切换清单释放旧 .session-owner 口径落盘（VC-4）；既有 selftest 基线+新增场景断言通过且无新脚本文件（VC-5）」

## 修正清单（12 项，逐项落实；涉及代码行的先 Read worktree 对应文件核实再写锚）
1. **C-1（verification.md VC-3 命令重写）**：现行正判据对规范修复恒红。改为：①正向断言 init-session.sh 与 set-active-plan.sh 的 claimant 判定存在锚定正则调用（能命中含加粗兼容的锚定 grep 调用行）②反向断言（剥注释后）无裸 `grep -qi 'Status.*in_progress'`。命令对规范修复可转绿——写完自查正则逻辑。
2. **C-2（verification.md VC-5 命令重写）**：`test -s || test -z` 重言式。改为 porcelain+untracked-files=all 全量判别：非 scope 文件零变更+无新增 .sh/.cjs/.ts（scope 允许清单=skills/task-planner/{scripts/init-session.sh,scripts/set-active-plan.sh,scripts/selftest-pointer-lifecycle.sh,SKILL.md}）；写明红绿判别方向（修复完成前红/后绿）。
3. **I-1（task_plan.md CA-1+executor_notes 补 G1 门控）**：init-session.sh:1205-1207 freshness fallback 抢用他会话哨兵 sid（D3 事故路径）时直写会覆盖他会话 side 键。补：fallback 抢用分支置 `_sid_fallback=1`，G1 通告+直写仅在 SIDKEY 来自 env/sidmap（身份确定）时生效，fallback 时保留 skip+WARN（提示会话 id 未确定）；CA-6/selftest 扩展项补该夹具断言。
4. **I-2（task_plan.md CA-4 补口径+VC-4 锚点+FMEA 行）**：删旧 .session-owner 后回切首轮 Edit 不触发重锁（posttooluse:154-156 前置 owner==SID），下次 prompt 报 PLAN TAMPERED。CA-4 补「回切后首个工具动作前先 `bash attest-plan.sh`（或先触发一次 prompt 让 hook 重建 owner）再 Edit task_plan.md」；纳入 VC-4 文本锚点断言；FMEA 补一行。
5. **I-3（task_plan.md Goal 区/Decisions 补边界声明）**：「本任务保证 init 新计划与收口后回切一次成功；同会话多在途计划间手动切换（两计划皆 in_progress）依设计仍走 --force（VC-2 仅验收提示清晰）」；VC-2 措辞对齐。可选增强写入 CA-2：阻塞者选取从 glob 首命中改为 owner mtime 最新。
6. **I-4（progress.md 调用点评估重录）**：真实调用点=scripts/zcode-sessionstart.sh:72（gc）、scripts/selftest-active-plan.sh:16、scripts/selftest-pointer-lifecycle.sh:13、../task-discipline/scripts/plan-hygiene.sh:123（提示性）、plan-doctor.sh:56（提示性）；无 hook 调 set 子命令；结论=保持 exit 0 安全。替换原空真评估段（progress.md:21,83 附近）。
7. **W-1（task_plan.md G3 正则兼容）**：锚定正则兼容非加粗形态 `[-*]\s*(\*\*)?Status:(\*\*)?\s*in_progress`（真实样本 plans/task-goal-autonomous-20261117/task_plan.md:7 非加粗）；Key Question 2 补结论；补非加粗不漏判夹具断言。
8. **W-2（task_plan.md CA-3 锚点修正）**：set-active-plan.sh 锚点改 :259-278（守卫整体）/:265 skip 文案/:266 SKIP_SIDE_WRITE/:278 skip exit 0。
9. **W-3（verification.md VC-4 区间锚加固）**：E 块区间从 NR>260 硬编码改为「目标切换判定（E 类」起到下一个 `###` 标题的段落边界锚。
10. **W-4（verification.md VC-1 补断言）**：夹具补「同会话旧 owner 残留时 set 输出『指针未切换』」断言（对齐 I-3 边界）。
11. **Q-1（task_plan.md:27 措辞）**：「用户已确认」→「推断（理解镜像 #1，原话『同步开发的技能没有问题』）」。
12. **N-1（progress.md 簿记）**：Phase 标题 [Title] 占位清理为实际阶段名；Phase 状态与 task_plan.md 对齐（全 pending）。

## 步骤（4 步）
1. Read 四文件现状+worktree 关键源码段（init-session.sh:1195-1260 / set-active-plan.sh:255-280 / zcode-posttooluse.sh:150-160）核实锚点
2. 修 verification.md（C-1/C-2/W-3/W-4）
3. 修 task_plan.md（I-1/I-2/I-3/W-1/W-2/Q-1）
4. 修 progress.md（I-4/N-1）+ 末尾追加 `### [plan-audit-R1-fix] <ISO8601> 12 项修正完成 | 逐项：<一行摘要>` + 自查 {{ }} 残留/锚点与实读一致

## acceptance
- 12 项逐项落实，VC-3/VC-5 重写后红绿判别方向正确（对规范修复可绿、对未修复现状为红）
- 不引入新建脚本/hook 基建要求；锚点行号全部基于实读
