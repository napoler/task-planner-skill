# 8b-cr-critic — Rule 96 落地对抗审查（挑刺视角，只读+本检查点）

- status: done
- date: 2026-10-24
- 审查对象：worktree `/mnt/data/dev/task-planner-skill-worktrees/task-subagent-boost-20261023`（分支 wt/task-subagent-boost-20261023，HEAD=886f060 零新 commit）全部未提交变更（7 M + 1 ??）
- 对照基准：draft-rule96.md（§2 全文/§3 六编辑/§4 selftest 设计/§5 开放点）+ 检查点 1/2（+5/6 实现态）
- 取证：`git status --short`、`git diff`（180 行全读）、`diff <(sed -n '46,74p' draft) <(sed -n '186,214p' dispatch.md)`=空、24 个涉改文件 selftest 串行实跑、被引条款原文逐条 sed 实读

## 一、铁律逐条核验（全部 PASS，本会话实跑）

| 铁律 | 结论 | 证据 |
|------|------|------|
| 增量立法（禁改写 21.4/22/46/52 语义） | ✅ | dispatch.md diff=纯追加（:4 头注枚举 + :186-214 Rule 96 段，`diff` 逐字节=草稿 §2）；21.3（:24 haiku-1/sonnet-1）/21.4（:25-32）/25.2（:104）/46.1（:116）/52/59.4/68.2（:175）/68.5（:181）原文逐条实读未动；96.4 对 25.2「逐 S-unit 派发」的「澄清」与 25.2 原文括注「每次派发对应 22.6 表一行」同义，非改写 |
| 编号合规（96 预留、95 禁用） | ✅ | 主仓 `plans/.rule-reservations.jsonl` 尾三行：94 landed / 95 reserved(task-nopause) / 96 reserved(task-subagent-boost)；worktree 内无 95 字样规则 |
| 禁 commit | ✅ | worktree `git log` HEAD=886f060（=分支点，无新提交） |
| 禁碰其他 plans/ 目录 | ✅ | worktree `git status --short` 仅 skills/ 下 7 M + 1 ??，零 plans/ 变更 |
| 6 处编辑全部落地 | ✅ | 编辑1（verbatim+头注）/2（核心 :193 枚举）/3a-f（SKILL.md 1-96×3、78 条×2、枚举 ,96×2、:245 指针句）/4a-b（模板 :327+:495-497）/5（subagent_dispatch :34）/6（run-selftests 注释+新脚本+registry）逐处 grep/diff 实证 |
| 新 selftest | ✅ | 实跑 `bash selftest-subagent-activation.sh` → Total 15 PASS=15 FAIL=0 exit 0；`selftest-registry.sh` → 5 PASS（rows=93/actual=93 配平） |
| 行数钉 BP-08 | ✅ | `wc -l SKILL.md`=268 ≤275；`selftest-batch-pilot.sh` 实跑 10 PASS |
| 零新机器门（防过度工程） | ✅ | 96.3/96.4 判定面=LLM 行为+既有 check-plan-dispatch H3/W1/W2（:425/:439-441/:618-622 锚实读在位）+零新 config 键——方向与宪法 §四.6 文本优先一致，未犯「添一句升级基建」病 |

## 二、selftest 回归实测（24 个，全部 rc=0）

- 本会话实跑（worktree 内，单进程串行）：subagent-activation 15P / registry 5P / batch-pilot 10P / parallel-scheduling 9P / verification-gate 13P / plan-tier 32P / workflow-orchestration 22P / absorption-discipline 16P / root-resolution 17P / requirement-coverage 28P / execution-honesty 14P / subagent-granularity-skill-escort 23P / input-consistency 5P / knowledge-brief 16P / conclusion-discipline 24P / agent-coverage 9P / subagent-return 12P / fine-grain-steps 11P / dispatch-grain 10P / split-pattern-library 13P / media-dispatch 9P / self-resolution 13P / skill-collab 25P / dispatch 31P
- **未跑**：`run-selftests.sh --fresh` 全量（93 脚本 ≈8-18min，S7 lane 既定归属）；如实注明非本 ask 射程
- **FG-02 首跑 FAIL 溯源（重要，非回归）**：首次 7 测试并行批中我把主仓与 worktree 两份 selftest-dispatch.sh **同消息并行**运行，二者共享固定路径计数文件 `FGC_WF=${TMPDIR:-/tmp}/task-planner-dispatch-warn-${SID}`（selftest-dispatch.sh:238），互删致 `grep '细粒度检测' "$FGC_WF"` 落空；干净复跑 ×2 全 PASS、主仓单跑 31P——**本次变更零回归**，暴露的是既有测试隔离债（共享 /tmp 固定路径），检查点 6「15/15 全绿」结论与单进程实况相符

## 三、问题清单（均非 BLOCKER，按危害降序）

1. **run-selftests.sh 注释钉把已知失真值 +1 固化**（run-selftests.sh:11「77 脚本」/:79「73 脚本」；实测 `ls scripts/selftest-*.sh | wc -l`=93，并行口径其余应为 88）。基线即失真（76 vs 92），draft E21 未校正只 +1；注释无门、检查点 6 已如实披露，但在反造谣宪法下建议 S7 簿记改为实值 93/88 或去数字化。修法：一行 sed 或删数字。
2. **96.3 对「恰 2 个独立 S-unit」串行计划的例外通道失配**（dispatch.md:194 附近 96.3 段）：例外引用「未按 68.2 登记全串行论证」，而 68.2 论证义务明文门槛=「S-unit 总数 ≥3 且零声明」（dispatch.md:175）——2-unit 串行计划在 68.2 下无登记义务，「未按 68.2 登记=计划缺陷」存在歧义（96.6 层级条款可自愈为「68.2 无义务→非缺陷」，恰好架空用户点名的 2-unit 场景；或读作自愿按 68.2 格式登记）。修法建议一行：例外句扩为「未按 68.2 口径登记全串行论证（S-unit 总数 <3 时按同一三轴格式登记 Decisions Made）」。
3. **96.5 交付总结两项指标无模板承载槽**：dispatch.md Rule 96 96.5 要求交付总结「必须报告激活子代理数/最大并行宽度」，但 templates/delivery-summary.md:64 委派统计行仅引用 check-delegation stats JSON，无两指标字段；draft §3 六编辑未含 delivery-summary。指针式报告可勉强满足，建议 S7 补 2 行模板槽或在 96.5 注明「随委派统计引用承载」。
4. **README/docs 纪元级联欠账移交**：合并后仓内 SKILL.md=1-96/78 条/枚举+96，而 skills/task-planner/README.md:36/:68/:81/:123 与 docs/ARCHITECTURE.md:13/:42/:100/:113/:123/:135 仍为 1-94/77 条/旧枚举（主仓实测 grep；检查点 2 §8-E4 已列为部署位对齐面）。无 selftest 因此红（WF-10 变体族不受影响，workflow-orchestration 22P 实证），沿用 task-deploy-rule94 先例属既定 lane——但簿记必须登记此欠账，防自相矛盾窗口无限延长。
5. **流程摩擦记录**：draft §3 编辑 1 目标文件在 skills/task-dispatch/**，而 S5 执行者 ask 限 task-planner/** → 编辑 1 成孤儿面，经 owner 升级裁决扩射程补落（检查点 6 批次 E/F；逐字节 diff 我已复核=0）。处置合规，属工作流 ask 切分缺陷非代码缺陷，后续任务书应把「规则正文落点=卫星文件」写进执行者射程。
6. **（既有债，非本变更）selftest-dispatch.sh:238 共享 /tmp 固定路径计数文件**：多会话/跨仓并行跑同 suite 必互踩（本次实证），建议后续加 mktemp 隔离。

## 四、结论

实现与 draft/检查点 1/2/5/6 完全一致，铁律零违反，无过度工程（零新机器门/零新键/模板零结构变更），新 selftest 真实全绿。遗留项全部为 nit 级或既定 lane 移交项。

VERDICT: APPROVED
