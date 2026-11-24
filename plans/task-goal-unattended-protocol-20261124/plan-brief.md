# 任务简报 — task-goal-unattended-protocol-20261124

> 本文件 = 已批准计划（§A 逐字）+ 计划编码说明（§B）。它是 Plan Writer、执行体、审计体共同的唯一材料源；派发 prompt 只放本文件路径。
> 修订 R1（2026-11-24，响应计划审计 R1 的 I-1/W-1/W-2/W-8/Q-1/Q-2）：仅修编码说明与基线口径；§A 已批准计划正文未改。

## A. 已批准计划（逐字；D1=yes，见 user-session-log.md #3）

# 修复计划：goal 模式「无人值守与续推幂等协议」（Rule 28.9）

### Context

示例会话 `sess_df5b8b4a` 是一次 `/goal` 任务：真实用户消息只有 2 条（`/goal`、最后的「授权」），宿主 Completion verifier 续推 14 轮，`AskUserQuestion` 9 次无人应答，部署决策翻转 3 次，最后你回的「授权」被丢弃（模型回复「目标已由运行时关闭…不再制造任何工具调用」）。

11-18 的 Rule 28.8 修法无效，且**不是部署漂移**：运行位与源仓逐文件 diff=0，规则文本加载了照样空转。病因在规则设计——skill 没有「用户不在场」和「宿主会自动续推」这两个前提下的行为定义。

根因（均有第一手证据）：

1. 28.8 规定「硬门→首次阻塞说明后停止迭代」，但 `/goal` 下是否继续由宿主控制；skill 无任何条款定义「收到续推指令怎么办」→ 每轮续推被当成新工作。14 轮里前 10 轮是这种空转。
2. 所有升级路径终点都是「问用户」（`critical-rules-verification.md:24,39`、`critical-rules.md:204`、`critical-rules-discipline.md:28,395`、`critical-rules-dispatch.md:53,225`），只有 28.8 说别问；「不可越权硬门」是开放集合 → 无法自主确认。
3. 无决策冻结 / 翻转预算。
4. 「确保」类目标词无合法出口：`84.5` 的 PARTIAL 要求 VC 全 PASS，改判据又被反作弊第 9 条禁（`skills/verification-gate/SKILL.md:95-99`）。
5. 无「授权消息到达→命中待授权清单→立即执行预案」规则。
6. `decision-arbiter` 源 frontmatter 为 `GLM-5.3 + thoughtLevel: enabled`，当前宿主不可用 → 独立仲裁拖到第 10 轮。

### 方案

纯文本条款，**零新脚本 / 零新门 / 零 hook / 零新 selftest**（遵守文本优先铁律）。

A. 新增 Rule 28.9（`skills/task-discipline/references/critical-rules-discipline.md`，紧随 28.8），八子条：① 无人值守公理；② 授权预算矩阵（取代开放硬门；部署=预算内，护栏=仅已合并 master 且 selftest 通过、逐位 diff、禁整文件覆盖、先备份、后 verify）；③ 续推指令识别与效力（差距线索，不是裁决/授权）；④ 首次续推=差异归因（A/B/C/D 四分类，仅此一次）；⑤ 固定点应答（≤10 行、零工具调用，豁免 95/64/103 及 hook 提醒派发）；⑥ 决策冻结（翻转上限 1 次）；⑦ 授权到达即执行；⑧ 终点覆盖。

B. 改措辞 + 指针（就地增量，既有语义不反转）：

| 文件 | 位置 | 改动 |
|---|---|---|
| `critical-rules-discipline.md` | `:64` 28.8②③ | 「单次阻塞降级收口」后加「收到续推按 28.9③-⑤，不停表等待」 |
| 同上 | `:28` `:55` `:183` `:186` `:395` | 各加一句 goal 分支指针（28.9⑧） |
| `skills/task-planner/SKILL.md` | `:119` `:123-124` `:132-134` `:136` `:268` `:346` | 「仅单次降级收口停止」→「预算外硬门按 28.9② 登记后继续」；审计/升级出口加 goal 指针 |
| `skills/task-planner/references/critical-rules.md` | `:134` 66.2、`:204` 109.2 | 同上指针 |
| `skills/verification-gate/references/critical-rules-verification.md` | `:24` 84.3⑤、`:40` 84.5 | goal 指针 + **判据拆分条款**：语义保证型 VC 的 PASS 判据 = 计划期登记的机器可验拆分项全 PASS → PARTIAL（附残余风险清单） |
| `skills/verification-gate/SKILL.md` | `:68`、反作弊第 9 条 | 同步拆分条款；注明「计划期（attest 锁定前）拆分不属中途改判据」 |
| `skills/task-dispatch/references/critical-rules-dispatch.md` | `:53` `:225` | goal 指针 |

（执行期全量字面面复核补出的载体：`critical-rules.md:10` 索引行同含旧措辞，一并处理。）

C. `decision-arbiter` 源配置对齐（用户已裁决）：`skills/task-planner/companion/agents/decision-arbiter.md:4-5`：`model` → `account:zai-individual-coding-plan/GLM-5.4`，`thoughtLevel` → `max`；description 同步；按 Rule 45 补 What+Why 注释。**运行位那份不动**。

D. 项目 `AGENTS.md` §2 加一条 goal 例外：「`/goal` 任务中为使目标生效而部署已合并且 selftest 通过的 `skills/` 内容属预授权（护栏见 28.9②）；agent 定义 model/frontmatter 不在此列。」

### 执行步骤

0. 前置检查（已完成：主仓目标文件无他会话未提交改动；仅 `AGENTS.md` 为未跟踪文件，在主仓直接改）。两条基线分开记：**selftest 基线** = `baseline-selftest.log`（干净 master 上 fresh 全量：104 PASS / 0 FAIL）；**部署对账基线** = `baseline-verify.log`（`verify.sh`：23 pass / 3 fail，预存漂移 = claude/opencode/cursor 三位的 `SKILL.md` 与源不一致）。
1. 建计划（本步骤）；批准本计划即 D1 通过；Rule 109 计划审计照跑。
2. worktree：`/mnt/data/dev/task-planner-skill/tmp/worktrees/task-goal-unattended-protocol-20261124`（分支 `wt/task-goal-unattended-protocol-20261124`，基于 master `9e42c0b`，已建、干净）。
3. 编辑：顺序 discipline → SKILL.md → critical-rules → verification → dispatch → decision-arbiter → AGENTS.md；每处 Edit 前 Read、Edit 后锚回读。
4. 验证 V1-V3。
5. 独立审查：critic 审条款文本。
6. 合并：`smart-merge-back.sh <worktree>`（不带 `--deploy`）→ 清理 worktree 与分支。
7. 部署 5 位：逐文件逐位 diff 判向——位 == 旧源 → 备份后替换；位有自有内容 → 该位就地锚定增量。备份至 `tmp/deploy-backups/…`。**不用** `smart-merge-back --deploy` / `install.sh` 整槽覆盖。某位缺该 skill 目录 → 跳过并报告，不新建安装。
8. 冒烟：decision-arbiter 派发 1 次；新会话行为演练（V6/VC-8）。
9. 收尾：记忆（一事一文件）+ 台账 + 归档计划 + 清哨兵。

### 不做的事与已知边界

- 不改 `~/.zcode/commands/goal.md`（8 月遗留文件，ZCode 交互面被内置 `/goal` 撞名过滤，非本次主因；保护区且无仓库源，需另行授权）。
- 不执行示例会话遗留的待授权项（C 类假绿门机器强化等）。
- 不控宿主 verifier 的续推次数与判定。
- 行为演练用的是模拟续推指令；真实 `/goal` 的端到端效果以用户下一次真实运行为准。若新会话卡在权限审批，退回本会话演练并在交付里标注。
- `~/.zcode/agents/decision-arbiter.md` 运行位缺 `tools` 字段（与源不同），保留并报告，不擅改。

## B. 计划编码说明（供 Plan Writer 落 plan-state.json；全部内容已定，不得增删语义）

### B1 基本字段

- task_id：`task-goal-unattended-protocol-20261124`；plan_tier：standard；template_type：rule-enhancement；execution_lane 保持 init 值。
- **new_rule：无新增顶级编号**（28.9 是 Rule 28 的子条，先例=28.8；不触发纪元级联、不占用 rule-reserve）。
- core_question：goal 语境下「用户不在场」且「宿主会自动续推」时，skill 如何做到零提问、零停表、续推幂等、授权到达即执行？
- 隔离决策：worktree 隔离（实现类、改运行行为的受管文件）。路径见 §A 步骤 2。`AGENTS.md` 是未跟踪文件，不随 worktree，经用户批准计划授权在主仓直接编辑。

### B2 Goal

- G1：修复 Skill 家族在 goal 模式下不能自主确认推进、无效多次循环的缺陷（Rule 28.9 + 载体级联）。
- G2：修复在全部运行位生效（合并 + 部署 5 位）。
- G3：独立裁决体 decision-arbiter 在当前宿主可派发（源配置对齐见 VC-6；派发冒烟见 VC-9）。

### B3 需求锚 R（R→VC 映射）

| R | 原文/裁决 | 类型 | 映射 |
|---|---|---|---|
| R1 | 用户原话（user-session-log #1 逐字）：「当前  skill子啊  goal 模式下导致不能自主确认推进 ,导致无效多次循环是严重的缺陷  没有达到自主角色目标  sess_df5b8b4a-8536-4c7e-87ac-fd85024635eb 会话就是示例 必须对skill缺陷进行解决」 | 结果 | VC-1, VC-2, VC-3, VC-8 |
| R2 | user-session-log #2 裁决一：goal 模式部署预授权+护栏 | 手段 | VC-2, VC-7 |
| R3 | user-session-log #2 裁决二：本次部署到全部运行位 | 手段 | VC-4, VC-5 |
| R4 | user-session-log #2 裁决三：decision-arbiter 对齐 GLM-5.4 + max | 手段 | VC-6, VC-9 |

### B4 Verification Contract（9 条；命令从任意 cwd 可执行；判据=命令输出的判别性结果）

- **VC-1** 条款锚在位且旧措辞清零。
  - 判据：6 个载体文件逐一打印的「28.9」计数均 ≥1；`old-wording-in-SKILL=0`。（改前：6 个计数全为 0、old=2——具判别性）
  - 命令：`cd /mnt/data/dev/task-planner-skill && for f in skills/task-discipline/references/critical-rules-discipline.md skills/task-planner/SKILL.md skills/task-planner/references/critical-rules.md skills/verification-gate/references/critical-rules-verification.md skills/verification-gate/SKILL.md skills/task-dispatch/references/critical-rules-dispatch.md; do echo "$(grep -c '28\.9' "$f") $f"; done; echo "old-wording-in-SKILL=$(grep -c '仅单次降级收口停止' skills/task-planner/SKILL.md)"`
- **VC-2** Rule 28.9 本体在位：条款行 =1，八个子条标记 ①-⑧ 齐全，且含部署护栏原文。
  - 判据：第一数 =1；第二数 =8；第三数 ≥3。
  - 命令：`cd /mnt/data/dev/task-planner-skill && F=skills/task-discipline/references/critical-rules-discipline.md; grep -c '^28\.9 ' $F; sed -n '/^28\.9 /p' $F | grep -o '[①②③④⑤⑥⑦⑧]' | sort -u | wc -l; sed -n '/^28\.9 /p' $F | grep -o -E '逐位 diff 判向|禁整文件覆盖|部署前备份|verify 对账' | wc -l`
- **VC-3** 语法与 selftest 回归不破基线（selftest 基线 = `baseline-selftest.log`：104 PASS / 0 FAIL）。
  - 判据：输出 `SYNTAX_OK`；fresh selftest 汇总行 FAIL 数 =0 且 PASS 数 =104（与基线相同）。
  - 命令：`cd /mnt/data/dev/task-planner-skill && bash -n skills/task-planner/scripts/*.sh && echo SYNTAX_OK; bash skills/task-planner/scripts/run-selftests.sh --fresh 2>&1 | tail -4`
- **VC-4** 合并进 master 且隔离区已清理。
  - 判据：第一数 ≥1；第二数 =0；第三数 =0。
  - 命令：`cd /mnt/data/dev/task-planner-skill && git log --oneline -6 | grep -c 'task-goal-unattended-protocol-20261124'; git worktree list | grep -c 'task-goal-unattended-protocol-20261124'; git branch --list 'wt/task-goal-unattended-protocol-20261124' | wc -l`
- **VC-5** 5 个运行位逐文件新锚在位（30 个位文件计数均 ≥1、无 MISSING），且部署对账不差于基线（`verify.sh` 基线 23 pass / 3 fail）。
  - 判据：输出 `site-files-bad=0`；summary 行 pass ≥23 且 fail ≤3。
  - 命令：`cd /mnt/data/dev/task-planner-skill && for s in /home/terry/.zcode /home/terry/.agents /home/terry/.claude /home/terry/.config/opencode /home/terry/.cursor; do for f in skills/task-discipline/references/critical-rules-discipline.md skills/task-planner/SKILL.md skills/task-planner/references/critical-rules.md skills/verification-gate/references/critical-rules-verification.md skills/verification-gate/SKILL.md skills/task-dispatch/references/critical-rules-dispatch.md; do t="$s/$f"; if [ -f "$t" ]; then grep -c '28\.9' "$t"; else echo MISSING; fi; done; done | awk '{ if ($1=="MISSING" || $1+0<1) bad++ } END { print "site-files-bad=" bad+0 }'; TASK_PLANNER_ROOT=/mnt/data/dev/task-planner-skill/skills/task-planner bash skills/task-planner/lib/verify.sh 2>&1 | grep summary`
- **VC-6** decision-arbiter 源配置对齐。
  - 判据：=2（model 行与 thoughtLevel 行各 1）。
  - 命令：`cd /mnt/data/dev/task-planner-skill && sed -n '1,12p' skills/task-planner/companion/agents/decision-arbiter.md | grep -cE '^model: "account:zai-individual-coding-plan/GLM-5\.4"$|^thoughtLevel: max$'`
- **VC-7** 项目 AGENTS.md 含 goal 部署预授权例外。
  - 判据：≥1（改前 =0）。
  - 命令：`grep -c 'goal 模式部署预授权' /mnt/data/dev/task-planner-skill/AGENTS.md`
- **VC-8** 新会话行为演练四判据全 PASS（D1 零等待式提问；D2 首轮即产出预算内成果并登记待授权清单与判据上限；D3 其后 3 轮模拟续推每轮 ≤10 行、无工具调用步骤、决策不翻转；D4「授权」当轮即执行待授权预案并验证）。
  - 判据：第一数 =4；第二行 `skeleton-ok`。报告行严格按模板「- D<n> 判据 <名称>：PASS|FAIL」每条一行；原始证据骨架 `drill-skeleton.txt`（主进程从演练会话记录抽取的逐消息骨架）非空，D1-D4 由主进程对照骨架判定并在报告中引用骨架行号。
  - 命令：`grep -cE '^- (D[1-4]) 判据[^:]*：PASS' /mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/drill-report.md; test -s /mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/drill-skeleton.txt && echo skeleton-ok`
- **VC-9** decision-arbiter 派发冒烟成功（S15）：裁决体在当前宿主正常返回并落 checkpoint。
  - 判据：≥1（checkpoint 缺失时命令失败 = FAIL，具判别性）。
  - 命令：`grep -c '^status: done' /mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/subagent-state/12-decision-arbiter.md`

### B5 Phase / S-unit / Executor（串行，无并行组；S-unit 为整数编号）

| Phase | 内容 | Executor | S-unit | S-unit 执行体 | 时长 |
|---|---|---|---|---|---|
| P1 | 计划建立与独立审计 | plan-writer | S1 计划文档编码 | plan-writer | 15min |
| | | | S2 计划独立审计（Rule 109） | critic | 10min |
| P2 | 源码条款落地（worktree） | executor | S3 discipline：E1a、E1b、E2、E3-E7 | executor | 15min |
| | | | S4 SKILL.md：E8-E13 | executor | 15min |
| | | | S5 critical-rules.md：E14-E16 | executor | 10min |
| | | | S6 verification-gate 两文件：E17-E20 | executor | 15min |
| | | | S7 dispatch：E21-E22 | executor | 10min |
| | | | S8 decision-arbiter：E23-E24 | executor | 10min |
| | | | S9 主仓 AGENTS.md：E25 | executor | 5min |
| P3 | 验证与独立审查 | critic | S10 VC-1/VC-2/VC-3 机械验证（selftest 基线 = baseline-selftest.log 104/0） | 主进程（白名单③ 机械验证命令） | 15min |
| | | | S11 条款文本独立审查 | critic | 15min |
| P4 | 合并 | 主进程（例外理由：① 纯 git/worktree 编排） | S12 smart-merge-back（不带 --deploy）+ 清理 worktree/分支 | 主进程（①） | 10min |
| P5 | 部署 5 位 | general-ops | S13 逐位 diff 判向 + 备份 + 精确增量同步 | general-ops | 15min |
| | | | S14 verify.sh 对比部署对账基线（baseline-verify.log 23/3） | 主进程（③） | 5min |
| P6 | 冒烟与收尾 | decision-arbiter | S15 decision-arbiter 派发冒烟（checkpoint：subagent-state/12-decision-arbiter.md） | decision-arbiter | 5min |
| | | | S16 新会话 goal 行为演练 + drill-report.md + drill-skeleton.txt | 主进程（② 计划文件维护 / ③ 只读回读） | 15min |
| | | | S17 记忆 / 台账 / 归档 / 清哨兵 | 主进程（②） | 10min |

- 委派率：子代理执行 Phase 5 / 总 6 = 0.83（≥0.7）。Executor 行格式 `subagent_type(model)`，model 取该 agent 定义 frontmatter 的 model 值；主进程直做行的例外理由必须落在 25.3 六项白名单内（①③②）。
- 每个 S-unit 时长写裸 `NNmin`。
- v_checks：P2=VC-1,VC-2,VC-6,VC-7；P3=VC-1,VC-2,VC-3；P4=VC-4；P5=VC-5；P6=VC-8,VC-9。

### B6 scope_files

`skills/task-discipline/references/critical-rules-discipline.md`、`skills/task-planner/SKILL.md`、`skills/task-planner/references/critical-rules.md`、`skills/verification-gate/references/critical-rules-verification.md`、`skills/verification-gate/SKILL.md`、`skills/task-dispatch/references/critical-rules-dispatch.md`、`skills/task-planner/companion/agents/decision-arbiter.md`、`AGENTS.md`（仓库根，未跟踪）、`plans/task-goal-unattended-protocol-20261124/**`、`tmp/deploy-backups/task-goal-unattended-protocol-20261124/**`；运行位同相对路径（仅 P5 部署写入：`~/.zcode` `~/.agents` `~/.claude` `~/.config/opencode` `~/.cursor`）。

### B7 变更标注表（Rule 74 三判门 + 74.7 合规四元组）

| 变更对象 | 类型 | 当前值原文 → 拟变更值 | 依据 | 影响评估 | 处置 |
|---|---|---|---|---|---|
| Rule 28.9（discipline，新增一条） | 增量 | — → 八子条全文（edit-spec.md E0） | 判例 sess_df5b8b4a + 用户批准计划（user-session-log #3） | 仅 goal 语境生效；非 goal 语义不变 | 新增 |
| 「仅单次降级收口停止 / 单次阻塞降级收口 / …并停止该目标迭代」类措辞（全仓字面面 9 处：SKILL.md:132/136/268、critical-rules.md:10/134、discipline:55/64/183/186）+ SKILL.md:133「不可越权硬门例外」 | **替代** | 停表等待 → 预算外硬门登记待授权清单后继续，续推按 28.9③-⑤ | 替代四条件：①既有内容被 sess_df5b8b4a 第一手记录证伪（停→续推→再停成环）且用户明示要求修复；②28.9②-⑦ 完整覆盖旧场景（硬门/不可自治项处置）；③已 Read 旧文全文；④改后 selftest 全绿 | goal 语境硬门处置方式改变；非 goal 不变 | 替代并保留 28.8 指针 |
| 84.5 终验判定 + 反作弊第 9 条 | 增量 | 增加「语义保证型判据拆分：仅计划期拆分（不属中途改判据）；执行期不新增判据行；拆分项全 PASS → PARTIAL，未全 PASS 或未拆分 → BLOCKED」 | 同上 | 终验 PARTIAL/BLOCKED 判定新增一类合法入口 | 增量 |
| decision-arbiter 源 frontmatter `model`/`thoughtLevel` | 替代 | `GLM-5.3` + `enabled` → `GLM-5.4` + `max` | 用户裁决（user-session-log #2 裁决三）；ListModels 实测该宿主 individual 计划仅 GLM-5.4 / GLM-5.3-Flash，GLM 系列档位 low/high/max | 裁决体从「派发必败」变为可派发；运行位不动 | 替代 |
| 项目 AGENTS.md §2 | 增量 | 新增「goal 模式部署预授权」一条 | 用户裁决（#2 裁决一） | 仅 /goal 语境的部署判定 | 增量 |

### B8 FMEA（standard 档 attest 要求）

| 风险 | S | O | D | RPN | 预设兜底 |
|---|---|---|---|---|---|
| 新措辞与既有条款（28.8/44.3/95/109）冲突 | 6 | 4 | 3 | 72 | critic 独立审查 + 回读互检；冲突就地修正 |
| SKILL.md 行数触 581 钉（selftest G-09） | 3 | 3 | 1 | 9 | 当前 469 行，预计净增 ≤8；触顶按「实值+25」调钉并登记 |
| 改措辞击破 selftest 文本锚 | 7 | 2 | 2 | 28 | 实测脚本面对旧措辞零锚（grep=0）；fresh 全量对比基线 |
| 整文件覆盖抹掉运行位自有增量 | 8 | 3 | 2 | 48 | 逐位 diff 判向；位≠旧源→就地锚定增量；先备份到 tmp/deploy-backups |
| 合并与他会话改动冲突 | 6 | 3 | 2 | 36 | smart-merge-back V3/V5/V6；目标文件当前无未提交改动 |
| 新会话演练卡在权限审批 | 4 | 3 | 1 | 12 | 退回本会话演练并在交付标注 |

### B9 进度产出基线（Rule 111 📦，禁倒退清单）

1. Rule 28.9 八子条（discipline）×1
2. 载体措辞/指针：SKILL.md（132/133/136/268 措辞 + 123-124/346 指针）、discipline（28.8②③ + :28/:55/:183/:186/:395 指针）、critical-rules.md（:10 索引行 + 66.2 + 109.2）、verification-gate（84.3⑤/84.5 + SKILL.md 终验/反作弊第 9 条）、dispatch（retry_limit + 96.7）
3. decision-arbiter 源 frontmatter 修正 ×1
4. AGENTS.md goal 部署例外 ×1
5. 5 位部署同步 + 备份
6. 演练报告 drill-report.md + 证据骨架 drill-skeleton.txt ×1
7. 记忆条目 ×1

### B10 Decisions Made（计划期，已定）

- D-1 goal 模式部署 = 预授权+护栏（用户裁决 2026-11-24，#2 裁决一）。
- D-2 本次修复部署 = 全部运行位（#2 裁决二）。
- D-3 decision-arbiter 源配置 = GLM-5.4 + max（#2 裁决三）。
- D-4 零新脚本 / 零新门 / 零 hook / 零新 selftest（文本优先铁律 + 用户批准计划）。
- D-5 部署方式 = 逐位 diff 判向 + 精确增量；禁 `smart-merge-back --deploy` / `install.sh` 整槽覆盖（二者为整槽替换，会抹掉 claude/opencode/cursor 位自有增量；verify 基线已显示三位 SKILL.md 与源不一致）。
- D-6 D1 = yes：用户于计划模式显式批准计划（user-session-log #3），执行中不二次确认。
- D-7 不改 `~/.zcode/commands/goal.md`；不执行示例会话遗留的待授权项。
- D-8（计划审计 R1 裁定，2026-11-24）C-1/I-1..I-6/W-1..W-6,W-8/Q-1,Q-2 全部采纳并在 edit-spec/plan-brief 修正；W-7（planctl render 硬编码 V-N 复选框为已勾）登记为已知局限——属既有渲染行为、不在本任务范围，依文本优先铁律不改渲染器，交付时如实披露。
- D-9（计划审计 R1 I-2 裁定）28.9② 的源码修改预授权收窄为「/goal 指令明示为任务对象的源码修改」；指令未明示的 skills/** 技能源码、agent 定义、指令文件修改仍属预算外。用户裁决（#2）只覆盖部署，不扩大。
- D-10（计划审计 R2 裁定，I-7）28.9 的预算外集合只拦 D6 类（含 72.1 A② 不可逆破坏、A③ 对外发布）；72.1 A①/A④（计划要素取舍、语义级目标分叉）在 goal 语境保持既有自治（28.8①、41.2 G4 silent、44.3 D2/D5 推荐项），不因 A 级名义转为预算外；⑦ 泛化授权只对 D6 类项要求逐项显式确认。R1 修正时把整个 A 级划为永不自动属矫枉过正。

### B11 已取证结论（→ findings / research；证据路径均为第一手）

- FR-1 示例会话形态：150 条消息；真实用户消息 2 条（`/goal`、`授权`）；宿主 verifier 续推 14 轮（消息 ID `msg_goal_verify_target_…_1..14`）；`AskUserQuestion` 9 次无应答；部署决策翻转 3 次；前 10 轮续推均触发实质动作；用户「授权」到达后模型未执行任何预案。AskUserQuestion 工具回执（会话内模型逐字引用，消息 `msg_mwsra1yz_df94866e-f364-4aba-a737-5d7b3a7dc141`）：「Continue using your best judgment; do not treat this as a rejection or invent a user preference」。来源：ReadSession 分页回读 + 落盘页 `~/.zcode/cli/artifacts/sess_18af15b1-d11e-45ab-8597-ca72e1b32c1c/call_1cb7005b66e9487f809f6713-tool-result-65480603-eed9-4f3f-8a19-08642e482f5f.json`；旁证 `plans/task-resource-utilization-20261123/REPORT.md` §7-§11、`task_plan.md`。
- FR-2 非部署漂移：`~/.zcode` 与 `~/.agents` 运行位的 goal 自治相关文件与源仓逐文件 diff=0（仅 `.agents/task-planner/SKILL.md` 落后 5 行，属他任务欠账）。
- FR-3 升级终点清单（均以「升级用户/AskUser」收尾）：`critical-rules-verification.md:24`（84.3⑤）、`:40`（84.5）；`critical-rules.md:204`（109.2）；`critical-rules-discipline.md:28`（escalation_threshold）、`:144`（41.5）、`:183`（44.3）、`:186`（44.5）、`:395`（69.3）、`:449`（72.1 A 级）、`:653`（97.5）；`critical-rules-dispatch.md:53`（retry_limit）、`:225`（96.7）；`SKILL.md:119/123-124/346`。
- FR-4 旧措辞全仓字面面 9 处（grep 实测）：见 B7 第 2 行。
- FR-5 `TASK_PLANNER_GOAL_MODE` 全仓无写入方（`resolve-interaction-mode.sh:52-58` 的 goal 分支运行时不可达）；goal 语境实际靠模型读语境判定，示例会话判定正确——识别不是病因。
- FR-6 28.8 无任何 selftest 文本锚（脚本面 grep「28.8 / 单次降级收口 / goal 自治 / 强制自治」仅 1 条注释命中）。
- FR-7 decision-arbiter：源 frontmatter `GLM-5.3 + thoughtLevel: enabled`；宿主 ListModels 显示 individual 计划下仅 `GLM-5.4`、`GLM-5.3-Flash`，GLM 系列档位 `low/high/max`；运行位 11-23 已为 `GLM-5.4 + max`。示例会话内两次派发失败：首轮（消息 `msg_mwsqaxy2_bc16e046-c10d-4221-951a-448c21068874`「裁决体因环境配置失败（Reasoning level unsupported，非限流）」）与第十轮（消息 `msg_mwssig10_3…`「decision-arbiter 因 reasoning level 不支持而失败」）；留痕 `plans/task-resource-utilization-20261123/.agent-failures/df5b8b4a85364c7e87acfd85024635eb.jsonl`。
- FR-8 `~/.zcode/commands/goal.md`（2026-08-26，143 行，引用 `~/.claude/skills/...`）通篇「等待确认/AskUserQuestion/升级用户/用户确认接受」；官方命令指南（zcode-guide `diagnosing-commands`）载明与内置命令撞名的本地命令在交互面被过滤——判为潜伏隐患、非本次主因。
- FR-9 运行位现状（部署前实测，`pre-deploy-site-state.log`）：5 位 × 6 文件全部存在、均为普通文件；`~/.zcode` 6/6 与源一致；其余位存在既有差异（agents SKILL.md 5 行；claude discipline 4 行 + SKILL.md 5 行；opencode 5 个文件 1-10 行；cursor discipline 4 行 + SKILL.md 10 行）——均为其他任务的历史欠账，部署必须原样保留。
- 证据边界（如实）：宿主 verifier 续推指令正文经 ReadSession 不展示，掌握的是模型对其的逐字引用；宿主 `/goal` 提示词原文不可读。
