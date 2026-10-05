# checkpoint 12 — executor（task-v131 Phase 3 critic 吸收修订 第二 S-unit：P1-3 对称性修复）

- 2026-10-05 | worktree=/home/terry/task-planner-skill-worktrees/task-v131 (branch wt/task-v131) | 未 commit
- 只动 2 文件：scripts/attest-plan.sh、scripts/init-session.sh；测试全在 /tmp/v131-p3b/；禁触其他文件/worktree ✓

## 1. attest-plan.sh — 51.1 门扩展第 4 锚
- 修改位置：attest-plan.sh:13（文件头说明行「三锚→四锚」）+ :121-151（51.1 需求区块门段）
- 内容：
  - 注释 What 扩为四锚：51.1 三锚（标题/R 行/R→VC 映射）+ 第 4 锚「🧮 根源覆盖表」（Rule 53.1 载体，critic P1-3 对称性修复）；Why 注明堵 53.1 侧同入口；「不适用+定性理由」声明亦算在位（锚级 grep，语义合规由 53.1 条文侧把关）
  - 新增行（:145）：`grep -q '根源覆盖表' "$plan_file" 2>/dev/null || req_msgs="${req_msgs} · 「🧮 根源覆盖表」缺失（第 4 锚, Rule 53.1 载体；非结果级须写「不适用（非结果级）」+定性理由, 该声明亦算在位）"`
  - ✗ 文案（:147）对齐既有 ✗ 行风格并注明「第 4 锚（Rule 53.1 载体）」；OK 行（:151）改「Rule 51.1 三锚 + 第 4 锚共四锚在位」
  - mini 豁免沿用既有 `tier_flag` 分支，零改动；fail-closed 无 --skip 逃生口不变

## 2. init-session.sh — inject_requirement_block 双区块独立注入
- 修改位置：init-session.sh:90-234（函数头注释 + 函数体）
- 内容：
  - Gate 1 改双锚独立判断：inja=缺「## 🎯 用户需求原文」、injb=缺「根源覆盖表」（grep 字样）；双在位→INFO 跳过；缺一个只注入缺的；双缺=🎯 在前 🧮 紧随（空行分隔）
  - 🧮 脚手架格式对齐 templates/task_plan.md:19-25：标题行 + HTML 注释（含「不适用须写理由」，53.1 禁裸豁免/attest 可核说明）+ 四列表（工序/缺陷面/修复点/VC）+ 占位行
  - mini 豁免（Gate 2）沿用既有判定 ①②，双区块同豁免；幂等保持（各锚独立 grep，已含者永不重复插入）
  - 成功行按 inja/injb 组合三分支 echo；fail-open（awk/写回失败仅 WARN）保持
- 附注：templates/task_plan.md 工作区已含 🧮 区块（Phase 2 S1 改动未提交，非本 S-unit 产出，未触碰）

## 3. 验证证据（全部实测第一手）
| 检查 | 结果 | 证据 |
|------|------|------|
| bash -n attest-plan.sh | OK | `attest bash -n OK` |
| bash -n init-session.sh | OK | `init-session bash -n OK` |
| a) 无锚计划 init | PASS | a_rc=0；标题锚=1、R 行=1、映射=1、🧮 区块标题行=1（raw 字样=2 因注释提及，README 已说明口径） |
| b) 仅需求原文区块 | PASS | req 标题 1→1 原样；🧮 0→1；INFO「🧮 根源覆盖表 脚手架已插入」 |
| c) 前三锚齐缺第 4 锚 attest | PASS | rc=1；「✗ 缺失锚: · 「🧮 根源覆盖表」缺失（第 4 锚, Rule 53.1 载体...）」；.plan-attestation=ABSENT |
| d) 四锚齐 attest | PASS | rc=0；「[requirement-gate] OK (Rule 51.1 三锚 + 第 4 锚共四锚在位)」+.plan-attestation EXISTS |
| b-rerun 幂等 | PASS | INFO「双区块…注入跳过」，锚数不变 |
| e) 补测：「不适用（非结果级：…）+定性理由」声明形态 | PASS | rc=0, requirement-gate OK（证明声明亦算在位） |

- 留档：/tmp/v131-p3b/{run-tests.sh, summary.log, a-init.log, b-init.log, b-rerun.log, c-attest.log, d-attest.log, e-attest.log, README.md, plans/*, b-plan-pre-init.md}
- git diff --stat（仅本 S-unit 2 文件）：attest-plan.sh 22 行变更 / init-session.sh 83 行变更（合计 74 insertions, 31 deletions 含既有未提交 Phase 2 基线差异）

## 4. 负结果排查（无异常项）
- 未发现注入破坏既有 markdown 结构：a/b 现场计划 Goal/Phase 区块位置正常
- 未发现 mini 分支回归：Gate 2 判定逻辑逐字节未改，仅文案更新
- attest 负例确认无 .plan-attestation 产生（fail-closed 语义保持，「先哈希后写」纪律未破坏）

## 5. 遗留/交接
- 未 commit（任务要求）；worktree 内 Phase 2 的 4 个已改文件（SKILL.md/critical-rules.md/subagent_dispatch.md/task_plan.md）仍在工作区，属前序 S-unit 遗留，本 S-unit 未触碰
- 下一步（主进程）：verifier 复验 → 合并回合约（§11.3 六条）
