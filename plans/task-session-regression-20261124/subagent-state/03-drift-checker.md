# Drift Check 03 | 2026-11-24（只读偏移检查）
- 触发点: 用户发出本次偏移检查请求（Rule 15/61 派发）；上下文：计划在途（P1 pending, P2 in_progress, P3-P6 pending，VC 全 pending）
- 判定: **ALIGNED**（结论：当前实施方向与原始诉求对齐；存在进行中工作但未见偏离）
- 证据锚（逐锚引用，Rule 64.4）:
  1) 用户原话锚（权威，Rule 80）
     - user-session-log.md #1-#8（全部原话/理解镜像已读）。关键原话要点：#1 倒退式删除/投毒→可靠性崩坏（R1）；#2 强制 Git 三件套（开始前备份/修改后备份/完成后差异+可还原）+ 调查归因+规避（R2/R2a-c/R2d）；#3 归因=技能缺陷、禁推诿执行方、需脚本/门驱动（R3/R3a）；#4 Git 必须作为必选 todo 步骤（R4/R4a）；#6 压缩后必须主动重读计划/本地文档，建议钩子机制（R5/R5a-c）；#7 明确禁止以“计划在根目录、实施在工作树”作为压缩后读取不畅理由；禁止停留审计循环、要求进入实施并以草稿仓复演/全量 selftest/独立复核作为质量门；#8 “继续”无新增。
  2) task_plan.md 锚
     - Goals/Requirements：G1 覆盖 B9-B11 必选 todo 与脚本/门控；R→VC 映射含 VC-1..VC-18（见 task_plan.md “Requirements/R→VC 映射/Goal 单元表/Verification Contract”）。
     - 当前状态：Phase P2 in_progress（started 2026-11-23T21:08:01Z），S-unit 表内大量 Sx 状态为 pending（P2 列表含进行中项的记录性描述），P1/P3-P6 pending；与 progress.md“Phase 2 in_progress”一致。
     - 设计裁决片段（节选）：D18 明确“停做 critic 审计轮次…质量门=草稿仓复演事故+全量 selftest 不增 FAIL + 一次独立复核”；D19 明确 repo 解析顺序 --repo>env>TASK_GIT_BASELINE_ROOT>worktree_path>CWD 并禁止从 plan-dir 推导。execution_lane=L1、template_type=bugfix、scope 列表与 18 项文件级改动约束可核对。
     - 用户 #7 相关要求在计划文档中被体现为“停止审计循环/进入实施”的裁决（D18）；“不得以工作树作为压缩后读取不畅理由”的口径在 D18/D19 的定位与历史漂移记录中有对应表述（F19/F21 亦有记录）。
  3) progress.md 锚
     - Phase 1 Actions：完成本任务自身 A1 基线快照（refs/task-baseline/task-session-regression-20261124=1bef5ea…），并记录还原口径；符合 #2/#4“开始前备份”方向。
     - Phase 2 Actions：已提交多个实施提交（5d0f030a/c171e262/d64f59ec/0a4cde86/552cc595/c0490005 等，见 progress 片段）、对齐 B9-B11 实跑与修复、并记录“已进入实施”（F19/F20/F21/F22/F23）。与 #7“停止停留审计、推进实施”一致。
     - F19（主进程自查）结论 ALIGNED；F21（02-drift-checker）结论 ALIGNED；F23 记录主仓终验时的 preexisting 脏树噪声问题（已开 worktree 处理 anchor-preexisting 方向），属于实现/验证阶段发现，非方向漂移。
  4) findings.md/verification.md/plan-state.json 锚
     - findings.md 记录事故链、缺口（驱动点缺失）、F19/F21/F23 等；与“归因=技能缺陷、需机器驱动”主线一致。
     - verification.md：VC-1..VC-18 全为 pending，Goal verdict pending，next=执行 P1-P6；与当前 in_progress/未收口状态一致。
     - plan-state.json：phases 中 P2 in_progress，其余 pending；vcs 全 pending；与上述一致。
  5) git/工作区锚（仓库 /mnt/data/dev/task-planner-skill）
     - `git log --oneline -5`：包含 `1acf0cff merge(task-session-regression): Git 基线防倒退机制 + 必选 todo B9-B11 + 压缩恢复包（task-session-regression-20261124）` 等，说明该任务相关变更已进入主线历史（合并节点存在）。
     - 主仓 `git status --short` / `git diff --stat` 显示存在大量与本任务 scope 外的未提交/未跟踪改动（例如 .zcode/*、plans/task-cli-help-examples-*、docs/frontmatter-linter-skill-tier-proposal.md、skills/task-planner/scripts/attest-plan.sh|init-session.sh|planctl.py|task-plan-init.cjs 的修改、以及多个其它 task 目录与临时文件）。这些不在 task-session-regression-20261124 的 scope（见 task_plan.md “执行范围限制”仅列该任务相关 skills/scripts/docs/templates 等），需注意避免误改/误混入；当前未见对 scope 外受保护区（~/.zcode/skills|agents|commands|AGENTS.md 等全局保护区）在主仓被改动的证据（主仓改动集中在仓内文件）。
     - 本任务隔离 worktree 路径 `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-session-regression-20261124` 已不存在（ls 报 No such file），与 progress 中“合并回 master 与清理”等记录相符（P2 有相关动作记录）；这与“进入实施/已推进”的轨迹一致。

- 三态判定: **ALIGNED**
  - 理由（≤40 字）：
    - 方向/手段/范围与 #1-#8 及 plan 决策一致：B9-B11 必选 todo、git-baseline+两门、SessionStart 压缩恢复包、停审计转实施、repo 解析锚定修改树（D18/D19）；未发现改写未授权保护区或偏离用户原话的实施动作。
  - 说明（不作为判定主依据，仅补充）：
    - 质量门/VC 尚未全绿、P3-P6 未完成（verification 全 pending、phases 多 pending），属进行中状态，不构成 DRIFT；主仓存在大量无关脏改动属环境噪声，需在后续操作中严格按 scope 与 worktree 纪律执行，避免混入。

- 建议（执行侧）：
  - 继续推进 P2 剩余未完成 S-unit 与后续 P3-P6，按 D18 质量门（草稿仓复演+全量 selftest 不增 FAIL+独立复核）收口。
  - 操作受管文件/skills 相关改动时遵守 scope 与 §11：在合适隔离区内进行，避免将主仓其它任务脏改动一并提交；对 plan-state/渲染类产物仅通过 planctl/render 路径维护。
  - 如需对“anchor-preexisting/主仓脏树导致终验噪声”继续处置，需保持与本任务目标（防倒退、可识别/可还原）一致，不扩大范围。

- 检查点文件（本次写入，绝对路径）:
  - /mnt/data/dev/task-planner-skill/plans/task-session-regression-20261124/subagent-state/03-drift-checker.md