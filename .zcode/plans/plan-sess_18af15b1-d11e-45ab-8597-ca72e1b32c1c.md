# 修复计划：goal 模式「无人值守与续推幂等协议」（Rule 28.9）

## Context

示例会话 `sess_df5b8b4a` 是一次 `/goal` 任务：真实用户消息只有 2 条（`/goal`、最后的「授权」），宿主 Completion verifier 续推 14 轮，`AskUserQuestion` 9 次无人应答，部署决策翻转 3 次，最后你回的「授权」被丢弃（模型回复「目标已由运行时关闭…不再制造任何工具调用」）。

11-18 的 Rule 28.8 修法无效，且**不是部署漂移**：运行位与源仓逐文件 diff=0，规则文本加载了照样空转。病因在规则设计——skill 没有「用户不在场」和「宿主会自动续推」这两个前提下的行为定义。

### 根因（均有第一手证据）

1. 28.8 规定「硬门→首次阻塞说明后停止迭代」，但 `/goal` 下是否继续由宿主控制；skill 无任何条款定义「收到续推指令怎么办」→ 每轮续推被当成新工作（`critical-rules-discipline.md:64`）。14 轮里前 10 轮是这种空转。
2. 所有升级路径终点都是「问用户」（`critical-rules-verification.md:24,39`、`critical-rules.md:204`、`critical-rules-discipline.md:28,395`、`critical-rules-dispatch.md:53,225`），只有 28.8 说别问；「不可越权硬门」是开放集合 → 无法自主确认。
3. 无决策冻结 / 翻转预算。
4. 「确保」类目标词无合法出口：`84.5` 的 PARTIAL 要求 VC 全 PASS，改判据又被反作弊第 9 条禁（`skills/verification-gate/SKILL.md:95-99`）。
5. 无「授权消息到达→命中待授权清单→立即执行预案」规则。
6. `decision-arbiter` 源 frontmatter 为 `GLM-5.3 + thoughtLevel: enabled`，当前宿主不可用 → 独立仲裁拖到第 10 轮。

## 方案

纯文本条款，**零新脚本 / 零新门 / 零 hook / 零新 selftest**（遵守文本优先铁律）。

### A. 新增 Rule 28.9（`skills/task-discipline/references/critical-rules-discipline.md`，紧随 28.8）

- **① 无人值守公理**：goal 语境 = 用户不在场；`AskUserQuestion` 视为不可用；工具返回「未作答 / use best judgment」视同 44.3 超时，按②矩阵默认裁决并登记。
- **② 授权预算矩阵**（取代开放硬门）：
  - 预算内：D1-D5 选择点、worktree 与合并、本仓源码修改与 selftest、**部署**（你已裁决预授权：仅限已合并进 master 且相关 selftest 通过的 `skills/` 内容，逐位 diff 判向、禁整文件覆盖、先备份、部署后 verify 对账）。
  - 预算外（永不自动）：D6 类不可逆/破坏性/对外发布/花钱、改宪法与 AGENTS.md、agent 定义的 model/frontmatter、推翻你的显式否决项、超 28.8④ 上界的范围扩张。
  - 预算外项**不询问**：登记「待授权清单」（项/理由/一键预案命令/可逆性）后继续做其余可执行项。
- **③ 续推指令识别与效力**：`goal_verify` 类消息 = 差距线索，不是用户裁决、不是授权；其中「向用户取得授权/确认」步骤不可执行，转④。
- **④ 首次续推 = 差异归因（仅此一次）**：A 预算内→执行；B 预算外→登记清单；C 语义保证型判据→判「判据上限」（机器可验拆分项 + 残余风险清单，一次独立仲裁确认）；D 已完成/误判→给证据锚不返工。
- **⑤ 固定点应答**：续推理由集合 ⊆ 已登记集合 = 固定点；此后每轮只回 ≤10 行「终态不变」，零工具调用；豁免 Rule 95/64/103 及 hook 提醒触发的派发。
- **⑥ 决策冻结**：终态仅可被「新用户消息 / 新外部证据 / 独立仲裁」之一推翻，每个决策翻转上限 1 次；meta-corrector 禁自翻转。
- **⑦ 授权到达即执行**：用户消息命中待授权清单 = 对应门放行，立即执行预案并验证；禁再索要更精确措辞；goal 被运行时关闭不清空清单。
- **⑧ 终点覆盖**：goal 语境下凡以「升级用户 / AskUser / 等待答复」为终点的条款，终点一律改按③④⑤；判定条件与轮次上限不变。

### B. 改措辞 + 指针（就地增量，既有语义不反转）

| 文件 | 位置 | 改动 |
|---|---|---|
| `critical-rules-discipline.md` | `:64` 28.8②③ | 「单次阻塞降级收口」后加「收到续推按 28.9③-⑤，不停表等待」 |
| 同上 | `:28` `:55` `:183` `:186` `:395` | 各加一句 goal 分支指针（28.9⑧） |
| `skills/task-planner/SKILL.md` | `:119` `:123-124` `:132-134` `:136` `:268` `:346` | 「仅单次降级收口停止」→「预算外硬门按 28.9② 登记后继续」；审计/升级出口加 goal 指针 |
| `skills/task-planner/references/critical-rules.md` | `:134` 66.2、`:204` 109.2 | 同上指针 |
| `skills/verification-gate/references/critical-rules-verification.md` | `:24` 84.3⑤、`:40` 84.5 | goal 指针 + **判据拆分条款**：语义保证型 VC 的 PASS 判据 = 计划期登记的机器可验拆分项全 PASS → PARTIAL（附残余风险清单） |
| `skills/verification-gate/SKILL.md` | `:68`、反作弊第 9 条 | 同步拆分条款；注明「计划期（attest 锁定前）拆分不属中途改判据」 |
| `skills/task-dispatch/references/critical-rules-dispatch.md` | `:53` `:225` | goal 指针 |

### C. `decision-arbiter` 源配置对齐（你已裁决）

`skills/task-planner/companion/agents/decision-arbiter.md:4-5`：`model` → `account:zai-individual-coding-plan/GLM-5.4`，`thoughtLevel` → `max`；description 同步；按 Rule 45 补 What+Why 注释。**运行位那份不动**（已是目标配置）。

### D. 项目 `AGENTS.md` §2 加一条 goal 例外

「`/goal` 任务中为使目标生效而部署已合并且 selftest 通过的 `skills/` 内容属预授权（护栏见 28.9②）；agent 定义 model/frontmatter 不在此列。」

## 执行步骤

0. **前置检查**：主仓 `git status` 与目标文件重叠检查（有重叠即 STOP 报告）；在干净 master 上记录基线：`run-selftests.sh --fresh` 的 FAIL 集 + `verify.sh` 结果。
1. **建计划**：按项目流程 `Skill(task-planner)` → `plans/task-goal-unattended-protocol-20261124/`。**你批准本计划即 D1 通过**，登记确认锚，执行中不再二次确认；Rule 109 计划审计照跑，有 CRITICAL/IMPORTANT 就地修正后继续。
2. **worktree**：`tmp/worktrees/task-goal-unattended-protocol-20261124`（`wt/` 分支，基于 `master`）。
3. **编辑**：顺序 discipline → SKILL.md → critical-rules → verification → dispatch → decision-arbiter → AGENTS.md；每处 Edit 前 Read、Edit 后锚回读。
4. **验证 V1-V3**（见下）。
5. **独立审查**：critic 审条款文本（子条互斥、自洽、与既有规则无新冲突）。
6. **合并**：`smart-merge-back.sh <worktree>`（不带 `--deploy`）过 V1-V6 → 清理 worktree 与分支。
7. **部署 5 位**（`~/.zcode` `~/.agents` `~/.claude` `~/.config/opencode` `~/.cursor`）：逐文件逐位 diff 判向——位 == 旧源 → 备份后替换；位有自有内容 → 该位就地锚定增量。备份至 `tmp/deploy-backups/…`。**不用** `smart-merge-back --deploy` / `install.sh` 整槽覆盖（会抹掉 claude/opencode/cursor 位的自有增量）。某位缺该 skill 目录 → 跳过并报告，不新建安装。
8. **冒烟**：decision-arbiter 派发 1 次；新会话行为演练（见 V6）。
9. **收尾**：记忆（一事一文件）+ 台账 + 归档计划 + 清哨兵。

## 验证

| # | 内容 | 判据 |
|---|---|---|
| V1 | 锚在位 | 每个载体 `grep -c "28.9"` ≥1；SKILL.md 中「仅单次降级收口停止」= 0 |
| V2 | 语法 | `bash -n skills/task-planner/scripts/*.sh` 通过（未改脚本，按惯例跑） |
| V3 | 回归 | worktree 内 `run-selftests.sh --fresh` 的 FAIL 集 == 基线（后台跑，慢盘）；若仅因行数触发现有钉值，按「实值+25」先例调整并登记 |
| V4 | 合并 | smart-merge-back V1-V6 全过，`git log` 复核 |
| V5 | 部署 | 5 位逐文件新锚 =1；`verify.sh` 结果不差于基线；备份齐全 |
| V6 | 行为演练 | 新会话发模拟 goal 指令（含一个「需授权区」写入 + 一个「确保…」目标词），再发 3 轮模拟 verifier 续推，最后发「授权」。判据：全程无「请选择/请确认/是否」类等待式文本；终态后每轮应答 ≤10 行且无工具调用步骤；决策不翻转；「授权」当轮即执行待授权预案 |

## 不做的事与已知边界

- **不改** `~/.zcode/commands/goal.md`：8 月遗留文件，在 ZCode 交互面被内置 `/goal` 撞名过滤，不是本次主因；属保护区且无仓库源，需你另行授权。
- **不执行**示例会话遗留的待授权项（C 类假绿门机器强化等）。
- **不控**宿主 verifier 的续推次数与判定：它在 上限内仍会续推；本修复保证的是不提问、预算内不停顿、终态后每轮近乎零成本、授权到达即执行。
- 行为演练用的是**模拟续推指令**；真实 `/goal` 的端到端效果以你下一次真实运行为准。若新会话卡在权限审批，退回本会话演练并在交付里标注。
- `~/.zcode/agents/decision-arbiter.md` 运行位缺 `tools` 字段（与源不同），保留并报告，不擅改。