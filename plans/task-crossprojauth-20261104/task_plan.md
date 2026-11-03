# task-crossprojauth-20261104 — 跨项目/跨目录操作授权纪律（Rule 99，L0-T 文本优先档）

plan_tier: mini
execution_lane: L0-T
new_rule: 99

**Goal**：在 task-discipline 纪律域落 Rule 99「跨项目/跨目录操作授权纪律」——跨项目/跨目录写操作必须先询问用户并获授权才可推进，非授权严禁越权；级联面（48→49 计数、1-98→1-99 纪元字面、卫星索引、selftest 纪元锚）随动零回归。
**用户原话**（append-only）：「对技能进行跨目录 约束 要求跨项目操作时候 需要进行询问用户 授权才可以推进 非授权 严禁恶意越权 在当前项目的skill中添加限制确保后期不会违反」。
**scope_files**（源仓 6 文件）：`skills/task-discipline/references/critical-rules-discipline.md`（追加 ### 99 段）/`skills/task-discipline/SKILL.md`（L15/24/79/81/92 计数与索引）/`skills/task-planner/SKILL.md`（L9/197/210/243/253 纪元+索引+指针）/`skills/task-planner/references/critical-rules.md`（L194 卫星索引行）/`scripts/selftest-anti-deferral.sh`（AD-09/AD-10 纪元锚）/`scripts/selftest-subagent-activation.sh`（SA-11 纪元锚）。
**收口**：run-selftests 零回归（与基线持平）→ `rule-reserve.sh land 99` → 源仓 pathspec 提交 → 部署位 zcode/claude/cursor 3 位各 6 文件同步 diff=0（zcode/claude 配置仓提交，cursor 非 git 仅落盘）→ 簿记 commit。
**VC**：① `grep -c '^### 99' skills/task-discipline/references/critical-rules-discipline.md`=1；② `grep -c '1-99' skills/task-planner/SKILL.md`≥3 且 `grep -c '其余 82 条'`=2；③ `bash skills/task-planner/scripts/run-selftests.sh` 末行 Total FAIL=0 且 PASS 数=基线；④ 部署位对源仓 `diff -r` 6 文件=0；⑤ `rule-reserve.sh check 99` 末条=landed。
**D1 自动裁决记录**（Rule 44.3）：超时值=5min（44.1 默认）；触发时间=2026-11-04 本会话；裁决理由=完成性指令+§四.6 文本优先铁律（L0-T 纯文本档，94.6/98 同范式，守护机器化 opt-in 未获授权不建）；推荐项=按本计划执行；被覆盖的未决选项=无（无真分叉/无 D6 破坏性动作）。
**Decisions Made**：L0-T 主仓直改（无 worktree）=11-03 用户裁决 L0-lite 最小 stub 先例（零新脚本零 attest）；部署位同步=本任务「确保后期不会违反」的生效条件（技能加载位=部署位），属用户原话射程内闭环节点，非越权；新编号 99 经 rule-reserve 账本 reserve→land。
