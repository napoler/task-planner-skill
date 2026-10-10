---
template_type: rule-enhancement
new_rule: 67
interaction_mode: ask
plan_tier: standard
code_review: required
isolation: worktree
parallel_groups: [p3-core, p3-b, p3-fix]
session_id: 4ec328fb-b4fa-4c4d-b8aa-49ed84a9d2aa
---

# Task Plan: 主动上下文评估与优化机制（Rule 67 — 上下文压力主动评估与会话交接纪律）

<!--
  WHAT: This is your roadmap for the entire task. Think of it as your "working memory on disk."
  WHY: After 50+ tool calls, your original goals can get forgotten. This file keeps them fresh.
  WHEN: Create this FIRST, before starting any work. Update after each phase completes.
  [2026-10-09 task-v152] 本计划由 plan-writer 依 plan-brief.md（权威任务书）产出；覆盖 init-session 骨架重写。
-->

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：Rule 51.1 计划侧载体。R 行=用户原话逐条编号抄录；映射=每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉（51.1/51.2） -->
<!-- 2026-10-07 task-v143：Rule 58.4 手段/目标二分——每条 R 行末尾标注 [手段] 或 [目标]；[目标] 行必须映射 ≥1 条「问题解决判据」VC（核心问题的可观察解决证据，非手段产物完成）；目标型任务终验必填「🎯 核心目标达成裁决」区块（58.5） -->

- **R1**: 「优化当前的技能，加入一个，就是说主动，在遇到上下文过长，或者说出现就是出现混乱的时候，我希望可以进行主动地进行压缩，或者说是整理优化。就是类似的方式。」<sub>（[目标]）</sub>
- **R2**: 「如果实在是解决不了，也可以撰写交接文档，要求在新的会话中开启。」<sub>（[目标]）</sub>
- **R3**: 「核心就是主动评估、主动优化。」<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2, VC-4 | 新 Rule 条款含主动评估触发+PRESSURE 压缩动作原文（grep 锚）；评估三态 verdict 定义在位；hook 节奏提醒实弹可见 |
| R2 | VC-3, VC-4 | templates/session-handoff.md 五段模板在位+条款规定穷尽后必写+新会话恢复链指引；CONFUSED→交接路径条款原文 |
| R3 | VC-1, VC-5 | 「主动评估」「主动优化」关键词入条款；全 selftest 回归 FAIL=0 基线零新增 |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 结果级需求（R3「主动评估、主动优化」=结果级：确保长任务执行中的上下文健康）必须分解生产管线逐工序审计缺陷面 -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 触发工序（何时评估） | 既有 Rule 29 触发仅三档（Phase complete 每 2 个/会话恢复/用户显式），全事件驱动——「上下文过长/混乱/重复失败」无任何信号触发（critical-rules.md:294） | S1 Rule 67.1 主动评估三档触发（节奏档/事件档/高危信号档）+ S4 hook 节奏承载 | VC-1, VC-4 |
| 评估工序（判什么态） | check-context-hygiene.sh 4 项检查全为行数/结构代理指标，不读真实上下文状态，且无「继续/压缩/交接」态判定（check-context-hygiene.sh:46,56） | S1 Rule 67.2 三态 verdict（HEALTHY/PRESSURE/CONFUSED）+ 自评信号清单 | VC-2 |
| 优化工序（PRESSURE 如何压缩） | 既有 Rule 29.2/29.3 压缩 SOP 仅 Phase complete 触发，无「命中即执行」语义（critical-rules.md:295-296） | S1 Rule 67.3 PRESSURE→复用 29.2/29.3 SOP，语义升级为「不等 Phase complete，命中即执行」 | VC-2 |
| 兜底工序（CONFUSED 如何交接） | 全仓无会话级交接文档模板/机制（templates/ 10 主模板无 handoff 类；grep「会话交接/交接文档」零命中） | S1 Rule 67.4 CONFUSED→交接文档条款 + S3 新建 templates/session-handoff.md 五段模板 | VC-3 |
| 承载工序（主动性靠什么兜底） | Rule 65 周期性回顾自述 hook 未接；posttooluse 仅有 drift-rhythm（Rule 64.3，N=10）——纯 LLM 自律不可靠（zcode-posttooluse.sh:46-107,321-344） | S1 Rule 67.5 hook 承载条款 + S4 zcode-posttooluse.sh 节奏块内单行提醒（env 降档，零新 config 键） | VC-4 |
| 回归面（计数锚/钉值） | 新增条款/模板/脚本撞四类钉：① SKILL「1-65」三处计数+行数钉≤510（现 509）② 6 selftest 活断言标签 `Critical Rules 1-65`/`40-65` ③ 3 索引文档（skill README/CLAUDE/README_zh）`Rules 1-65` 标签+WO-10 四文档计数 ④ registry 63 行/properties=42 | **S2 SKILL 级联 + S8-S13 锚级联批（12 文件：3 索引文档+DCS+8 selftest 含 skill-split 钉 510→实测上调）** + S5 selftest+registry 加行 + S6 全量回归对基线；`^66\.` 前向防线零触碰（66=v151 预留在途） | VC-5 |

<!-- plan_tier: standard -->
## Goal
<!--
  WHAT: One clear sentence describing what you're trying to achieve.
  WHY: This is your north star. Re-reading this keeps you focused on the end state.
-->
task-planner 技能新增 Rule 67「上下文压力主动评估与会话交接纪律」：执行中按三档信号主动评估上下文压力（HEALTHY/PRESSURE/CONFUSED 三态），PRESSURE 命中即主动压缩整理（复用 Rule 29.2/29.3 SOP、不等 Phase complete），CONFUSED 兜底撰写会话交接文档转新会话；全链落地=critical-rules 条款+新模板 session-handoff.md+posttooluse hook 节奏承载（env 降档、零新 config 键）+新 selftest+registry 登记+SKILL 计数级联 1-67+三部署位同步。

## 🔍 Code Review 配置

<!--
  默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：rule-enhancement 属代码组 → required；显式声明优先。
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（实现类多文件变更：条款/模板/hook/selftest，重 diff 全量多轮 CR） |
| `session_id` | `4ec328fb-b4fa-4c4d-b8aa-49ed84a9d2aa`（哨兵 sidkey 口径；env sid=de2c5bba 为 Bash 侧源，双 sid 指针已对齐，见 Decisions） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/v152-proactive-context`（Phase 2 从 master 创建） |
| `scope_files` | `skills/task-planner/references/critical-rules.md, skills/task-planner/SKILL.md, skills/task-planner/templates/session-handoff.md(新), skills/task-planner/scripts/zcode-posttooluse.sh, skills/task-planner/scripts/selftest-context-pressure.sh(新), skills/task-planner/scripts/selftest-registry.tsv` + **B 类扩展（2026-10-09 20:3x，VC-5 回归门发现锚级联面）**：`skills/task-planner/README.md, CLAUDE.md, README_zh.md, CHANGELOG.md(仅 Phase 6 条目), skills/task-planner/scripts/selftest-research-first.sh, selftest-lane-advancement.sh, selftest-workflow-orchestration.sh, selftest-self-resolution.sh, selftest-tool-selection.sh, selftest-requirement-coverage.sh, selftest-drift-check-subagent.sh, selftest-skill-split.sh` |
| `interaction_mode` | `ask`（D1 批准前按 28.2.1 口头复述执行思路；D2/D3 为方案选择点） |
| `对齐审查` | `[登记]` 任务完成前对全部产出跑 alignment-review（42.6.2 标准收尾流程）；文档更新前跑版本一致性校验 |
| `自动超时默认项` | `[D1: 默认=批准计划+worktree 隔离 / 超时 5min；D2: 默认=新 Rule 67 形态（vs 扩展 Rule 29 子条）/ 超时 5min；D3: 默认=hook 接线纳入本期（vs 纯规则层、hook 推后）/ 超时 5min]` |
| `new_rule`（Rule 20.6：attest 自动预留+查重；账本最高 landed=65，66 被并行 task-v151 声明在途，67 空闲——避撞号） | `67` |
| `质量审查工具` | `[code-reviewer 子代理（既有环境 agent，sonnet-1）——42.2 环境 agents 层命中，无缺口]` |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

<!--
  V-N: 每个 Phase 段（`### Phase N` 的 - **Status:** 行前）已补 `- **V-N:**` 行（≥2 条，映射已定义 VC 编号）。
  check-complete.sh 终验 VC-GATE 段机械校验（config.json vc_gate_enforce，默认 warn）。
-->

> **验证独立性**：本计划验证动作由独立子代理执行（Phase 4 = code-runner-agent，Phase 5 = code-reviewer），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | critical-rules.md 文末新增 Rule 67 六子条（67.1 触发三档 / 67.2 三态 verdict / 67.3 PRESSURE 压缩 / 67.4 CONFUSED 交接 / 67.5 hook 承载 / 67.6 机制守护），条款含「主动评估」「主动优化」关键词原文；既有 Rule 1-65 正文零改动 | grep 锚 + Read 复核 + git diff | worktree `grep -cE '^67\.[1-6] ' skills/task-planner/references/critical-rules.md` =6；`grep -c '主动评估\|主动优化'` ≥2；`git diff master -- critical-rules.md` 仅文末追加 |
| VC-2 | 三态 verdict 定义在位（HEALTHY 继续 / PRESSURE 触发主动压缩整理 / CONFUSED 触发交接兜底，三态各含触发动作）；PRESSURE 动作=复用 Rule 29.2/29.3 SOP 且语义升级为「命中即执行、不等 Phase complete」 | grep 锚 + Read 复核 | `grep -c 'HEALTHY\|PRESSURE\|CONFUSED'` ≥3；`grep -n '不等 Phase complete'` 命中；Rule 67.3 段内 `grep -n '29.2'` 命中 |
| VC-3 | templates/session-handoff.md 五段模板在位（目标锚 / 已完成与证据 / 当前断点 / 未决问题 / 新会话恢复指令）；Rule 67.4 规定 22.3 五档穷尽仍失败或无法确定状态时必写；模板含新会话恢复链指引 | 文件 Read + grep | `[ -f ]` 文件在位；五段标题逐段 `grep` 命中；`grep -n 'session-catchup\|62.1\|plan-resume\|24.5' templates/session-handoff.md` 命中 |
| VC-4 | hook 承载实弹：zcode-posttooluse.sh 既有 drift-rhythm 节奏块内新增单行主动评估提醒（env 降档 `TASK_PLANNER_CONTEXT_PRESSURE_*`，零新 config 键），既有计数变量零改动；实弹冒烟触发一次提醒输出 | bash -n + 冒烟观测 + diff + jq | `bash -n scripts/zcode-posttooluse.sh` 通过；`grep -c 'TASK_PLANNER_CONTEXT_PRESSURE'` ≥1；冒烟输出记录于 subagent-state；`git diff` 显示既有 drift-rhythm 变量零改动；`jq '.properties|length' config.json` =42 |
| VC-5 | 无回归破坏：新 selftest-context-pressure.sh 全 PASS exit 0 + registry.tsv 加 1 行（4 列）+ SKILL.md 三处计数级联到位（**时点口径**：任务交付态=整串 `Critical Rules 1-67` ≥2 + 短串 `1-67` =3；并行 v153/v154/v155/v158 相继演进至 1-71 后，主仓 CP-07 由 task-v158 承接演进为 `1-(69|71)` 宽容锚（RF-06 范式）且主仓实跑 9/9 PASS——本任务侧无需再改；核心锚 67 子条/三态/五段/env/C49 全程未弱化）+ 全量 selftest 回归 FAIL 计数=该时点基线（零新增）+ 三部署位 diff=0（时点=a7b1619 部署刻） | 跑批 + grep + diff 对账 | `bash scripts/selftest-context-pressure.sh` exit 0（交付态 9/9，主仓演进后仍 9/9=v158 实证）；回归日志 FAIL=0（终态 69/69/0）；部署对账 3 处 diff 空（a7b1619 刻；v158 后的部署同步归其收尾） |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：`code_review: required` → 终验前必须先通过 Code Review Gate（Phase 5），否则不得标记 COMPLETE。

## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
<!-- WHEN: 终验（Phase 6）时填写；本任务 R1/R2/R3 均标 [目标] → 交付前必须出三态裁决 -->
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1, R2, R3（三条均 [目标]） |
| **裁决** | `solved` |
| **解决证据锚** | R1=critical-rules.md:847-876（`### 67`六子条+67.3 PRESSURE 即压缩）+posttooluse 冒烟双态（subagent-state/7-code-runner-S6-run1/2.out）；R2=templates/session-handoff.md 五段+67.4 恢复链（session-catchup/62.1/plan-resume）；R3=67.1 三档主动触发+67.2 [assess] 留痕+「主动评估/主动优化」关键词 grep≥2；五方并集回归 69/69/0（regression-final.log）+三部署位 IDENTICAL（master a7b1619） |
| **未解决面+原因** | 无 |
| **已排除路径** | 不适用 |
| **下一步建议** | 并行会话 v151/v153/v154/v155 相继落地引发的五方并集已由本任务三轮合并解净；建议后续 parallel-scheduling 类任务把「编号让位链」（C 编号/锚标签）列入 68.1 依赖分析输出项（已进 v156 需求背景） |

## 🎯 Goal 单元表（Rule 66.1 — 规划获批后任务单元固化；standard/full 必填，mini 档豁免）
<!-- 2026-10-10 02:4x 补录：v151 Rule 66.5 已部署 attest 链（master 前进所致），按 66.1 六列契约回填；G1-G4 为已达成事实（证据行同步 progress.md [goal:Gn]），G5-G6 在途 -->
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 设计定稿 | Rule 67 六子条+五段模板+hook 方案+钉值清单定稿 | Read design-draft.md §1-§4 四段齐 + drift ALIGNED（Drift Log 首行） | Phase 1 | complete |
| G2 | 基线隔离 | worktree 隔离区建立+零回归基线快照 | baseline-selftest.log `grep -c 'FAIL=0'`=63 + git worktree list 含 wt/v152 | Phase 2 | complete |
| G3 | 单元实施 | 13+4 单元落地产物=17 文件恰=scope | worktree `git status --short`=17 行且全在范围表 + 九脚本单跑全绿 | Phase 3 | complete |
| G4 | 独立验证 | 全量回归零新增+hook 冒烟双态 | regression-worktree.log `grep -cE 'rc=[1-9]'`=0 + run1/run2.out 双 PASS | Phase 4 | complete |
| G5 | 审查闭环 | CR round2 APPROVED（fix-wave 后） | subagent-state/8-code-reviewer-S7-round2.md 首行=APPROVED | Phase 5 | pending |
| G6 | 交付合并 | 合并回 master+部署对账+Rule 67 land | smart-merge-back no-ff 对账+三部署位 IDENTICAL+账本 landed=67+check-complete exit 0 | Phase 6 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!--
  🚫 禁止发散规则：只操作本列表中明确列出的文件；未在列表中的文件一律不碰；如需扩展范围，必须获得用户授权。
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 技能条款 | `skills/task-planner/references/critical-rules.md`（仅文末追加 Rule 67） | 既有 Rule 1-65 正文改写 |
| 技能登记 | `skills/task-planner/SKILL.md`（Rule 67 登记行 + 「Critical Rules 1-65」三处→1-67 + 合规清单新条目 C45 + 行数钉值随动） | 其他章节 |
| 模板 | `skills/task-planner/templates/session-handoff.md`（新） | 其他主模板与 `variant/` |
| hook 脚本 | `skills/task-planner/scripts/zcode-posttooluse.sh`（drift-rhythm 块内单行追加） | 既有计数/其他 hook 脚本；`/home/terry/.zcode/cli/config.json`（禁止改动） |
| 守卫脚本 | `skills/task-planner/scripts/selftest-context-pressure.sh`（新）、`selftest-registry.tsv`（追加 1 行）、B 类扩展锚演进 8 脚本（research-first/lane-advancement/workflow-orchestration/self-resolution/tool-selection/requirement-coverage/drift-check-subagent/skill-split——仅限 1-65→1-67 标签与行数钉，`^66\.` 负断言防线零触碰） | 其他 `scripts/`；与钉值无关的 selftest |
| 索引文档 | `skills/task-planner/README.md:72`、`CLAUDE.md:33`、`README_zh.md:136,229`（`Rules 1-65`→`1-67` 标签级联，v149 对齐注先例）；`CHANGELOG.md`（仅 Phase 6 追加 v152 条目） | 上述文档正文其他改动；仓根其他文档 |
| 计划系统 | `plans/task-v152-proactive-context/**`（簿记/design-draft/baseline） | 其他任务 plans；`plans/task-v151-goal-mode/**` |

**执行前自我检查:**
- [ ] 这个文件在上面的列表中吗？
- [ ] 这个修改对完成任务有必要吗？
- [ ] 用户明确要求我做这个修改吗？
- 全部 Yes → 可以执行 | 任一 No → 先问用户

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

> 目的：对齐任务知识库。Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档 | 既有相邻机制（Rule 29 上下文维护 / Rule 64.5-64.6 env 降档先例 / Rule 65 周期回顾） | `skills/task-planner/references/critical-rules.md:290-299,816-846`；`scripts/check-context-hygiene.sh:1-145` | 必读 | ☑ |
| 项目内部文档 | hook 节奏块与挂载表（四事件；posttooluse drift-rhythm N=10） | `skills/task-planner/scripts/zcode-posttooluse.sh:46-107,321-344`；`/home/terry/.zcode/cli/config.json` `hooks.events` | 必读 | ☑ |
| 项目内部文档 | 钉值/登记面（SKILL 三处 1-65；registry 4 列 63 行；config properties=42） | `skills/task-planner/SKILL.md:9,280,360`；`scripts/selftest-registry.tsv`；`scripts/selftest-research-first.sh` 等 | 必读 | ☑ |
| 项目内部文档 | 会话恢复链既有件（Rule 19.3 恢复读序 / Rule 24.5 plan-resume / Rule 62.1 四文件 / session-catchup） | `critical-rules.md:114,216-226,745`；`SKILL.md:57` | 必读 | ☑ |
| 项目内部文档 | 编号账本与并行 v151 撞号对照 | `plans/.rule-reservations.jsonl:33`；`plans/task-v151-goal-mode/task_plan.md`（new_rule:66） | 必读 | ☑ |
| 用户宪法 | §一 子代理优先 / §六 保护区 / §十一 worktree 隔离 | `/home/terry/.zcode/AGENTS.md` | 参考 | ☑ |

**填写规则**：① `定位` 可唯一定位；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 执行期上下文过长或出现混乱时，task-planner 无主动评估触发、无 PRESSURE 主动压缩、无会话级交接文档兜底——用户要求「主动评估、主动优化」（R3），而既有 Rule 29/65 全为事件驱动且 hook 未接，主动性缺位。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（能：Rule 67 条款+五段模板+hook 承载+selftest 落仓+三部署位同步）
- [x] 核心问题不解决，其他工作都白费吗？（是：无主动机制则长任务上下文压力/混乱仍累积漂移）
- [x] 核心问题的解决方法是清晰的、可执行的？（是：六子条+五段模板+单行 hook 接线+静态 selftest，落点已 recon 定稿）

**如果无法回答核心问题，禁止开始任务！**

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!-- 适用判定:产出=结论/判断/建议/原因解释。本任务产出=条款/模板/守卫脚本（实现类），但机制设计依赖现状取证，故按三面如实登记（禁裸豁免） -->
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | 既有 Rule 29 触发三档 + check-context-hygiene.sh 4 项代理指标 + Rule 65 hook 未接 | Read + Explore 侦察（agent_9c951ea4） | findings.md Research Findings A/B；`skills/task-planner/references/critical-rules.md:290-299` | ☑ |
| ② 对标样本（58.2） | 相邻机制范式：Rule 64.5/64.6 env 降档零新键先例 + Rule 65 未接 hook 对照面 | Read critical-rules.md Rule 64.5/64.6 + zcode-posttooluse.sh:46-107 | findings.md Technical Decisions 表 | ☑ |
| ③ 外部约束 | ZCode hook 四事件挂载表（只改技能侧脚本，不改 config.json）+ config properties=42 多 selftest 钉值 | Read `/home/terry/.zcode/cli/config.json` `hooks.events` + 多 selftest grep | findings.md Research Findings D 节 | ☑ |

## Current Phase
<!-- WHAT: Which phase you're currently working on. WHY: Quick reference. -->
Phase 5

## Next Step
<!-- WHAT: 单一下一步动作。WHEN: Phase 状态每次变更时同步刷新。 -->
Phase 5：派 code-reviewer（S7）对 worktree 全量 diff（17 文件，重 diff）做 Code Review——条款语义正确性+hook 零副作用+selftest 断言有效性；APPROVED 才进终验，CHANGES_REQUESTED 走 fix-phase（≤3 轮）

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!-- 逐 Phase 登记命中的 harness 执行工具面（Rule 40.1 六类）；本区块是 Executor 字段的上游分析记录，不替代其委派门控机器事实源地位。 -->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | 主进程（白名单② 计划系统文件维护） | design-draft.md 属 `plans/` 计划系统文件；设计定稿=计划系统文件维护 |
| Phase 2 | 主进程（白名单① git/worktree 编排 + ② 计划系统文件维护） | `git worktree add` 编排 + baseline-selftest.log 落 plans/ |
| Phase 3 | Agent 子代理 executor（sonnet-1）逐 S-unit + 机械验证（grep/bash -n） | 实现类必委派（Rule 25）；S-unit 粒度三值内；组内并行按 Rule 21.4 声明制 |
| Phase 4 | Agent 子代理 code-runner-agent（mini） | 跑批全量 selftest 回归 + hook 冒烟（独立执行体，Rule 33.3） |
| Phase 5 | Agent 子代理 code-reviewer（sonnet-1） | `code_review: required` 重 diff 全量多轮 CR |
| Phase 6 | 主进程（白名单① git 编排 + ② 簿记）+ 机械守卫（install 对账 diff） | 合并回/清理/部署对账=git 编排；交付总结/账本/attest=簿记 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件（Phase 3 组内并行 = Rule 21.4 独立性守门调度，非独立子任务 fan-out；无长链多 skill 接力；用户未点名 /workflow——39.1 红线）→ 按 Rule 21.4 声明组调度：`parallel_groups: [p3-core]`，组内 S1-S4 同消息并行派发（派发 prompt 须含 `[parallel-group:p3-core]` 标记，check-dispatch.sh:280-281 双条件放行槽锁），S5-S7 串行。
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 的证据源；本任务用户未使用 /goal（该能力为并行 task-v151 专项），不涉 /goal 映射供料；/goal 为用户侧 harness 命令，技能层不可代调。

## Phases
<!-- Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写白名单例外理由;Executor≠主进程的 Phase 必附 S-unit 表(22.6);check-plan-dispatch.sh 在计划批准时校验 -->

### Phase 1: 设计定稿（条款文本草案 + 模板草案 + hook 接线方案）
- [x] Read 既有相邻机制全文（Rule 29 / Rule 64.5-64.6 / Rule 65 主进程逐行 Read；check-context-hygiene.sh 与 posttooluse drift-rhythm 块经 Explore 侦察 A/B 节覆盖，施工锚标「实施日重验」由 S4 执行体重读），确认插入位与可复用面
- [x] 写 `plans/task-v152-proactive-context/design-draft.md`：Rule 67 六子条草案全文（67.1-67.6）+ session-handoff.md 五段模板草案 + hook 接线方案（插入位 + env 变量名）+ 钉值级联清单（SKILL 三处 1-67 / C45 / skill-split 行数钉值 / registry +1）
- [x] 过 C24/C36 自审（Rule 36 删除基线=纯增量零删除；术语语义锚定 P11：PRESSURE/CONFUSED 逐词回写）——结论见 design-draft.md §1 尾自审块
- [x] 向用户呈示设计 + 28.2.1 思路复述，等 D1/D2/D3 批准（默认项见 Code Review 配置表）——28.2.1 复述已呈示；D1-D3 按 Rule 44.3 超时自动裁决登记（20:05 三行五要素）；design-draft 全文随本轮交付消息呈示
- [x] 知识储备必读项已确认可获取（「必要知识储备」表 5 行必读全 ☑）
- **V-N:** VC-1, VC-2（条款草案是 VC-1/VC-2 的素材源；缺草案则实施无据）
- **Status:** complete（2026-10-09 20:16；3-File Gate PASS+drift ALIGNED+Drift Log/ledger 双痕）
- **Executor:** 主进程（例外理由:② 计划系统文件维护——design-draft.md 属 `plans/` 计划系统文件——Rule 25.3 白名单）

### Phase 2: worktree 创建与基线快照
- [x] 创建 worktree：`git worktree add /mnt/data/dev/task-planner-skill-worktrees/v152-proactive-context -b wt/v152-proactive-context master`（HEAD=dbc635a，20:16）
- [x] worktree 关键文件与 master/部署位一致性核对（v150 教训：worktree 分支可能与部署位不同步）——四文件 `git diff master` 空 + `diff -q` vs ~/.zcode 部署 = IDENTICAL ×4
- [x] 记录全量 selftest 基线 FAIL 计数快照 → `plans/task-v152-proactive-context/baseline-selftest.log`（63 脚本 pass=63 fail=0）
- [x] 登记 worktree 创建事件（`ledger-main.jsonl` tick5 + drift_check tick6）
- **V-N:** VC-4, VC-5（一致性核对=hook/条款落点前置；基线快照=零回归对照面）
- **Status:** complete（2026-10-09 20:22；3-File Gate exit 0+drift ALIGNED tick6/Drift Log 双痕）
- **Executor:** 主进程（例外理由:① git/worktree 编排 + ② 计划系统文件维护（baseline-selftest.log 落 plans/）——Rule 25.3 白名单）

### Phase 3: 实施（worktree 内，逐 S-unit 派发）
- [x] 按 S-unit 表派发 executor：**A 批** S1-S4 声明并行组 `p3-core` 同消息派发 → 三证据验收；**B 批** `p3-b`={S5,S8,S9,S13} 同消息派发 → 验收；**C 批** `p3-b`={S10,S11,S12} 同消息派发 → 验收（S13 前置=S2 实测行数；批间串行、批内并行）——13/13 单元全部完成
- [x] 逐 S-unit 验收（22.5 三证据）+ 回填 findings/progress + ledger（Handoff 14 行 verify_done 全勾；A/B/C 批验收段；ledger tick8）
- [x] worktree 内 `git status --short` 核对改动集 = scope_files（无越界文件）——实测恰 17 文件=18 scope 减 CHANGELOG（Phase 6），零越界
- **V-N:** VC-1, VC-2, VC-3, VC-4（条款/SKILL 级联/模板/hook 四件落地）
- **Status:** complete（2026-10-09 23:58；3-File Gate PASS+drift ALIGNED tick9/Drift Log 三行）
- **Executor:** executor（sonnet-1）

<!-- S-unit 派发单元表(Rule 22.6 — 每行 = 一次 Agent() 派发;单步 ≤step_max_files(2) 文件 / ≤step_max_lines(100) 行 / ≤step_max_minutes(15) 分钟;ID 纯数字;粒度三值 Nf/Nl/Nmin 逐行校验;「伴飞技能」列非「无」→ 校验 SKILL.md 路径存在(Rule 59.2)) -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|
| S1 | critical-rules.md 文末追加 Rule 67 六子条（67.1 触发三档/67.2 三态 verdict/67.3 PRESSURE 压缩/67.4 CONFUSED 交接/67.5 hook 承载/67.6 机制守护） | executor（sonnet-1） | ① plans/task-v152-proactive-context/design-draft.md（Rule 67 草案全文）② 部署位 references/critical-rules.md 行 846 后追加位（Rule 65 之后） | `grep -cE '^67\.[1-6] '` =6 且含「主动评估/主动优化/HEALTHY/PRESSURE/CONFUSED」；既有 Rule 1-65 正文 `git diff` 零改动（仅文末追加） | 15min | 1f/90l/15min | writing-skills | done |
| S2 | SKILL.md 级联：Rule 67 登记行 + 「Critical Rules 1-65」三处(:9,:280,:360)→1-67 + 合规清单新条目 C45 + 钉值级联清单逐项（skill-split 行数钉值随动） | executor（sonnet-1） | ① design-draft.md（钉值级联清单）② 部署位 SKILL.md 行 9/280/360 及 C44 条目位 | 短串 `grep -c '1-67'` =3（RF-06 口径）；整串 `Critical Rules 1-67` ≥2（纠正-3，原 =3 误设）；`C45` ≥1；`1-65`=0；行数记录供行数钉单元 | 15min | 1f/25l/15min | writing-skills | done |
| S3 | 新建 templates/session-handoff.md 五段模板（目标锚/已完成与证据/当前断点/未决问题/新会话恢复指令） | executor（sonnet-1） | ① design-draft.md（五段模板草案 + 恢复链指引）② 部署位 templates/ 目录（无同类模板，纯新增） | 文件在位且五段标题逐段 grep 命中；含恢复链 session-catchup→四文件读序(62.1)→plan-resume(24.5) | 15min | 1f/60l/15min | writing-skills | done |
| S4 | zcode-posttooluse.sh drift-rhythm 节奏块内追加单行主动评估提醒（env 降档 TASK_PLANNER_CONTEXT_PRESSURE_*，默认开可关），既有计数变量零改动 | executor（sonnet-1） | ① design-draft.md（hook 接线方案：插入位 :46-107/:321-344 + env 名）② 部署位 scripts/zcode-posttooluse.sh | `grep -c 'TASK_PLANNER_CONTEXT_PRESSURE'` ≥1；`bash -n` 语法通过；既有 drift-rhythm 变量 `git diff` 零改动 | 15min | 1f/12l/15min | 无 | done |
| S5 | 新建 scripts/selftest-context-pressure.sh（静态锚：67 子条/三态 verdict/session-handoff 五段/hook env 锚/registry 行）+ selftest-registry.tsv 加 1 行 | executor（sonnet-1） | ① design-draft.md（selftest 断言清单）② 部署位 selftest-registry.tsv（4 列表头+63 行基线） | 新 selftest exit 0 全 PASS；`tail -1 registry.tsv` 含新行且 4 列；SR-12 动态行数断言（=ls+1）通过 | 15min | 2f/80l/15min | 无 | done |
| S8 | 索引文档标签级联：skills `README.md:72` + 仓根 `CLAUDE.md:33` 的 `Rules 1-65`→`Rules 1-67`（补 67 描述，v149 对齐注先例） | executor（sonnet-1） | ① design-draft.md §4#5 ② worktree 内两文件锚行 | 两文件 `grep -c '1-67'` 各 ≥1 且 `1-65`=0；改动行带 task-v152 对齐注 | 10min | 2f/8l/10min | 无 | done |
| S9 | 仓根 `README_zh.md:136,229` 两处 + `scripts/selftest-drift-check-subagent.sh` DCS-11(:59 `Rule 40-65 全集`→`Rule 40-67 全集`) 标签级联 | executor（sonnet-1） | ① design-draft.md §4 ② 三处锚行 | 三处 grep 新标签命中且旧标签=0；`bash -n` DCS 通过 | 10min | 2f/8l/10min | 无 | done |
| S10 | `selftest-research-first.sh` RF-06/RF-07(:72-73) + `selftest-lane-advancement.sh` LA-12(:131,133) 锚演进 1-65→1-67、40-65→40-67 | executor（sonnet-1） | ① design-draft.md §4#5 ② v149 同构判例 plans/task-v149-skill-alignment-audit/subagent-state/12-executor-S18.md | 两脚本单跑 exit 0；演进注释按 v149 范式追加 | 15min | 2f/14l/15min | 无 | done |
| S11 | `selftest-self-resolution.sh` SR-07(:74,76+注:15,76) + `selftest-tool-selection.sh` TS-05(:60,62) 锚演进 | executor（sonnet-1） | ① 同 S10 判例 ② 两脚本锚行 | 两脚本单跑 exit 0；SR-12 行数断言不受损 | 10min | 2f/10l/10min | 无 | done |
| S12 | `selftest-requirement-coverage.sh` RC-11(:127-131) + `selftest-workflow-orchestration.sh` WF-10(:70-73) 锚演进（**RC-15/FF-16/EG-16/IP-14 的 `^66\.` 前向防线与 WO 演进注释链零破坏**） | executor（sonnet-1） | ① 同 S10 判例 ② 两脚本锚行 | 两脚本单跑 exit 0；`git diff` 显示 `^66\.` 断言行零改动 | 15min | 2f/16l/15min | 无 | done |
| S13 | `selftest-skill-split.sh` 行数钉 510→按 S2 后 `wc -l` 实测+余量上调（带 task-v152 演进注释，先例 :44-46；≤558 总上限不动）——**S2 验收后才可执行** | executor（sonnet-1） | ① S2 完成后实测 `wc -l <worktree>/skills/task-planner/SKILL.md` ② skill-split:44-46 注释链 | 单跑 exit 0；钉值 ≥实测；演进注释含 task-v152 | 10min | 1f/8l/10min | 无 | done |
| S14 | fix-wave：posttooluse `_cpn` 除零防护（MAJOR-1）+ rhythm_n 钳位移出 `_cp` 块（MINOR-3） | executor（sonnet-1） | CR checkpoint subagent-state/8-code-reviewer-S7.md MAJOR-1/MINOR-3 段 | `bash -n` 过；fixture `TASK_PLANNER_CONTEXT_PRESSURE_N=0` 直调无 division-by-0 且单行 JSON 仍在；drift 文案不随新开关变化 | 10min | 1f/6l/10min | 无 | done |
| S15 | fix-wave：selftest-context-pressure CP-06 去 git 依赖固化常量（MAJOR-2）+ CP-03 增 hook 交叉断言（MINOR-2）+ CP-07 C45→C46 断言（MAJOR-3 联动） | executor（sonnet-1） | CR checkpoint 同上 + SKILL C46 已就位（前置=本表 S16 完成） | 脚本 exit 0 全 PASS；`grep -c 'git show'`=0 | 10min | 1f/10l/10min | 无 | done |
| S16 | fix-wave：SKILL C45 行→C46（goal 行 C45 保留属 master）+ critical-rules 67.6 措辞 C45→C46（MAJOR-3） | executor（sonnet-1） | CR checkpoint 同上 MAJOR-3 段 | SKILL `grep -c C46`≥1 且 C45=goal 行（grep C45 上下文核）；critical-rules 67.6 含 C46 | 10min | 2f/4l/10min | 无 | done |
| S17 | fix-wave：skills README templates 计数 10→11 两行+对齐注（MINOR-1） | executor（sonnet-1） | CR checkpoint 同上 MINOR-1 段 | `grep -c '11 核心'`≥1；diff 仅该文件 | 5min | 1f/4l/5min | 无 | done |

> **单元组标记（Rule 21.4 声明制）**：`[parallel-group:p3-core]` = S1, S2, S3, S4（文件集互斥：critical-rules.md / SKILL.md / session-handoff.md / zcode-posttooluse.sh；输入各自独立、验收独立——独立性四问全否 → 组内并行）；**`[parallel-group:p3-b]` = S5, S8, S9, S10, S11, S12, S13**（文件集互斥且全部依赖 S2 已落的 SKILL 新标签为验收前提——组间序=先 p3-core 后 p3-b；组内分批：B 批={S5,S8,S9,S13}、C 批={S10,S11,S12}，每批 ≤4 在飞，批间等验收；S13 前置=S2 验收后的实测行数）；**`[parallel-group:p3-fix]` = S14, S15, S16, S17**（fix-wave：文件集互斥 posttooluse/selftest-context-pressure/SKILL+条款/README；S15 前置=SKILL C46 就位（S16 完成）→ 先派 S14+S16+S17 再 S15）。**派发 prompt 必须含对应 `[parallel-group:...]` 标记**（check-dispatch.sh:280-281 计划声明 + prompt 标记双条件放行槽锁；缺标记 → 槽锁拦截/告警）。组内各 = 独立 Agent 会话领 1 行（Rule 46.1 合规）。

### Phase 4: 验证（独立执行体）
- [x] worktree 内跑新 selftest-context-pressure.sh（exit 0 全 PASS）——9/9 两轮（S5+主进程+S6）
- [x] worktree 内全量 selftest 回归 + 与 baseline-selftest.log 对比（FAIL 计数=基线，零新增）——64/64/0 vs 基线 63/63/0，新增恰=1，rc≠0=0（regression-worktree.log）
- [x] hook cadence 实弹冒烟：构造一次 PostToolUse 触发，观测主动评估提醒输出（记录 subagent-state）——run1 单行 JSON 含双段 / run2 off 开关正确，SMOKE PASS（7-code-runner-S6-smoke.sh 可复跑）
- [x] config properties 断言复核（`jq '.properties|length' config.json` =42，零新键）——42 ✓ 且 worktree config diff 空
- **V-N:** VC-4, VC-5（hook 冒烟=VC-4 实弹；回归对基线=VC-5 零回归）
- **Status:** complete（2026-10-10 02:01；3-File Gate PASS+drift ALIGNED tick12/Drift Log 四行）
- **Executor:** code-runner-agent（mini）

<!-- S-unit 派发单元表(Rule 22.6) -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|
| S6 | worktree 内全量 selftest 回归 + 基线对比 + 新 selftest 复跑 + hook cadence 实弹冒烟 | code-runner-agent（mini） | ① plans/task-v152-proactive-context/baseline-selftest.log（Phase 2 快照）② worktree skills/task-planner/scripts/selftest-context-pressure.sh | 回归 FAIL 计数=基线（对比日志）；新 selftest exit 0；冒烟输出含提醒行（记录 subagent-state） | 15min | 0f/20l/15min | 无 | done |

### Phase 5: Code Review Gate
- [x] 收集 worktree diff 改动文件清单 → 过滤代码文件（条款/模板/hook/selftest）——CR round1 已完成（17 文件，剔除 master 前进面后真实对象=git diff HEAD + 2 新文件）
- [x] 派 code-reviewer（sonnet-1）重 diff 全量多轮 CR（条款语义正确性 + hook 零副作用 + selftest 断言有效性）——round1 返回 CHANGES_REQUESTED（0B/3M/3m）
- [x] APPROVED → 进终验；CHANGES_REQUESTED → fix-phase（≤3 轮，Rule 22.3）——**round2 APPROVED**（0B/0M/1 非阻断 MINOR 折叠 Phase 6）；证据=8-code-reviewer-S7-round2.md 首行
- **V-N:** VC-1, VC-5（CR 覆盖条款语义正确性；返工面=零回归）
- **Status:** complete（2026-10-10 03:2x；3-File Gate PASS+drift ALIGNED tick16/Drift Log 五行）
- **Executor:** code-reviewer（sonnet-1）

<!-- S-unit 派发单元表(Rule 22.6) -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|
| S7 | 全量 CR：worktree `git diff master --stat` 覆盖 6 文件，逐条给出 APPROVED / CHANGES_REQUESTED | code-reviewer（sonnet-1） | ① worktree 6 变更文件 diff ② design-draft.md（设计意图对照） | CR 结论=APPROVED（或逐条 CHANGES_REQUESTED 落 subagent-state） | 15min | 0f/100l/15min | 无 | done |

### Phase 6: 终验与交付合并回
- [x] 逐 VC 复验（VC-1..VC-5 全通过，对照本表证据列；verification.md Goal Gate outcome=COMPLETE）
- [x] 核心目标达成裁决（58.5）：solved——R1=67.3 PRESSURE 即压缩+冒烟双态、R2=五段模板+67.4 恢复链、R3=三档触发+[assess] 留痕
- [x] alignment-review 收尾（42.6.2）：CHANGES_REQUESTED→处置闭环（P0-1 CP-07 主仓已由 v158 演进为 1-(69|71) 且 9/9；P2-1 Drift Log 补录；P2-2 VC-5 时点口径注记）
- [x] 合并回+部署对账：smart-merge-back 入 master=a7b1619（no-ff）；~/.zcode 运行位自保护→staging+rm+mv 手动部署；三部署位 IDENTICAL（a7b1619 刻）
- [x] rule-reserve land 67（账本末行 `{"rule":67,"status":"landed","task_id":"task-v152-proactive-context"}`）
- [x] 交付总结五要素（delivery-summary.md）+委派统计（verdict=ok/WHITELIST-EXEMPT）+merge_back=merged(a7b1619)+本计划与 plans/ 收尾入库
- **V-N:** VC-3, VC-5（模板在部署位可见；合并对账 diff=0 即无回归）
- **Status:** complete（2026-10-10 07:5x；drift tick19 收口缺口已逐项补齐+alignment 闭环）
- **Executor:** 主进程（例外理由:① git 编排（合并/清理/部署对账）+ ② 簿记（交付总结/账本/attest）——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
<!-- WHAT: check-conflicts.sh 扫描结果与工作树隔离决策。WHEN: 计划创建时（init 后）运行并填写；合并回后更新 merge_back。 -->
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号① 未提交变更 3 文件：`M plans/.active_plan`、`?? plans/task-v151-goal-mode/`、`?? plans/task-v152-proactive-context/`；信号② 额外 worktree `/mnt/data/dev/task-planner-skill-worktrees/v151-goal-mode [wt/v151-goal-mode]`；信号③ 遗留 wt 分支 `wt/v151-goal-mode`；信号④/⑤ 无） |
| `isolation` | `worktree`（宪法 §十一 保护区命中：`skills/**` 属保护区，实现类必须隔离） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/v152-proactive-context`（Phase 2 从 master 创建） |
| `branch` | `wt/v152-proactive-context` |
| `merge_back` | `merged(a7b1619)`（no-ff；后随主仓 v158 演进） |

> 契约详见 `~/.zcode/skills/task-planner/references/worktree-isolation.md`（决策矩阵/生命周期/合并回合约/反模式）。
> 并行 v151 在 `wt/v151-goal-mode` 改同批文件（critical-rules/SKILL/registry）→ 本 worktree 从 master 建，合并冲突预期=文尾 Rule 追加点/SKILL 计数行并集解。

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 references/methodology.md §R2）

<!-- WHAT: 对每个 Phase 枚举失败模式，打 S/O/D 各 1-10 分，RPN=S×O×D。RPN>100 必须预先登记兜底动作（对齐 22.3 五档）。 -->

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 3 (S4) | hook 接线失败：drift-rhythm 块结构不匹配 / 误改既有计数逻辑（连带 Rule 64.3 行为回归） | 7 | 4 | 6 | 168 | 22.3 ④ 主进程接管单文件小改（≤3 行，白名单⑤；仅加单行不改既有变量）+ `bash -n` 复核；仍失败 → 22.3 ⑤ AskUserQuestion（hook 推后，纯规则层先落，D3 改判登记） |
| Phase 3 (S2) | SKILL 钉值级联漏网：1-65→1-67 三处 / 行数钉值 / C45 未同步 → 大面积 selftest 转红 | 6 | 5 | 7 | 210 | **已回炉拆细（B 类扩展 20:30）**：S2 只管 SKILL.md 本体；标签面拆 S8-S13 六单元（3 索引文档+DCS+7 selftest）分批执行；S13 行数钉实测上调；S5 静态锚兜底；回归红即对照 baseline 逐脚本回炉 |
| Phase 6 | 与并行 v151 合并冲突（critical-rules 文尾追加点 / SKILL 计数行） | 5 | 6 | 4 | 120 | 22.3 ④ 主进程接管并集解（文尾 Rule 66+67 双追加、SKILL 计数 1-67 并集）+ merge 前 `git status --short` 核对（§十一 合并回合约 3） |
| Phase 4 | 新 selftest 与 registry 行数断言（SR-12 动态 =ls+1）不匹配 | 4 | 4 | 5 | 80 | （≤100，留空） |
| Phase 6 | 部署位 diff≠0（漏同步） | 5 | 3 | 4 | 60 | （≤100，留空） |

**填写规则**：RPN>100 → 兜底动作列必填（写清走 22.3 哪一档）；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链。

## 🔁 原生 Todo 同步（S1–S5 强制）
<!-- WHAT: 计划文档 ↔ 原生 Todo 的同步状态追踪。WHEN: S1 计划创建后建映射 / S2 Phase 状态变更后紧邻同步 / S3 收到 [plan-sync] 提醒立即回写 / S4 会话结束前终态同步 / S5 用户新指令影响计划后先改计划再重映射 Todo。 -->
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  |  |
| Phase 2 | ☐ |  |  |
| Phase 3 | ☐ |  |  |
| Phase 4 | ☐ |  |  |
| Phase 5 | ☐ |  |  |
| Phase 6 | ☐ |  |  |

> 契约详见 `~/.zcode/skills/task-planner/references/todo-sync.md`。

## Key Questions
<!-- WHAT: Important questions you need to answer during the task. -->
1. hook 提醒单行能否在不改既有 drift-rhythm 计数变量的前提下插入？（S4 验收锚：既有变量 `git diff` 零改动 + `bash -n`）
2. 三态 verdict 的评估信号清单能否复用既有脚本 exit 码语义（check-context-hygiene.sh）？（Phase 1 设计定稿确认）
3. 与并行 v151 合并时，critical-rules 文尾 Rule 66/67 双追加与 SKILL 计数 1-67 并集能否无冲突解？（Phase 6 合并前核对）

## Decisions Made
<!-- WHAT: Technical and design decisions, with reasoning. WHEN: Update whenever you make a significant choice. -->
| Decision | Rationale |
|----------|-----------|
| 新增 Rule 67（避让并行 v151 的 66）而非扩展 Rule 29 子条 | 能力含评估 verdict + 压缩动作 + 交接升级三段，超出 Rule 29「多→退场」SOP 语义；账本最高 landed=65，66 被 v151 声明在途，67 空闲——避撞号（历史撞号教训 task-v143/v142） |
| 零新 config 键，开关走 env 降档（`TASK_PLANNER_CONTEXT_PRESSURE_*`） | config `properties=42` 被多 selftest 钉死（selftest-research-first/four-file-dataflow/execution-honesty）；先例=Rule 64.5/64.6 env 降档 |
| hook 承载纳入本期（D3 默认）：PostToolUse 既有 drift-rhythm 节奏块内追加单行 | 主动性若无 hook 承载=纯 LLM 自律，与 Rule 65 同空白；复用既有节奏状态免新计数器；只改技能侧 `zcode-posttooluse.sh`，不动 `/home/terry/.zcode/cli/config.json` |
| worktree 隔离（`/mnt/data/dev/task-planner-skill-worktrees/v152-proactive-context`） | 宪法 §十一 保护区命中（`skills/**`）；并行 v151 改同批文件，隔离避免踩踏 |
| 双 sid 指针对齐（plan `session_id`=哨兵 sidkey `4ec328fb-...`；env sid=`de2c5bba` 为 Bash 侧源） | init WARN：SessionStart 与 Bash env 的 sid 源分裂（RC-1 已知家族）；`set-active-plan` side 指针已按 env sid 落盘指向 v152，`plan-created.cjs` 确认可正常写入——不影响本任务 |
| 侦察走 Explore 子代理（agent_9c951ea4），结论经 findings.md + knowledge-brief 双落盘 | 跨多文件现状取证=宪法 §一 必委派；Explore 只读无检查点，故以返回消息蒸馏落盘（Rule 62.3 双落盘路径之一） |
| 会话级交接文档独立新模板 `templates/session-handoff.md`（非扩既有 Handoff） | 既有 Chain Handoff（block 间）/ Subagent Handoff（子代理级）均非会话级；全仓无会话级交接模板（grep 零命中）→ 纯新增 |
| Phase 3 声明并行组 `p3-core`={S1,S2,S3,S4} | 独立性四问全否（文件集互斥/输入独立/验收独立）；Rule 21.4 声明制，S5-S7 因依赖/验收相关串行 |
| 思路复述已呈示,2026-10-09 20:05 | 28.2.1 ≤5 行大体执行思路已随计划呈示（AskUserQuestion 前文本，Phase 序列/执行体/门控/隔离/交付五要素） |
| 自动裁决 D1=批准计划+worktree（Rule 44.3 五要素：超时值 5min / 推荐项=批准+worktree / 触发时间 2026-10-09 20:05 / 理由=用户原始指令明确要求本任务且默认项已随计划呈示 / 被覆盖选项=先调整计划、暂缓执行） | AskUserQuestion 未获答复，按 Code Review 配置表「自动超时默认项」D1 默认执行；harness 指示 continue best judgment，非拒绝 |
| 自动裁决 D2=新 Rule 67 形态（五要素：超时值 5min / 推荐项=新 Rule 67 / 触发时间 2026-10-09 20:05 / 理由=能力三段超 Rule 29 语义+67 空闲避让 v151 的 66 / 被覆盖选项=扩展 Rule 29 子条） | 同上 Rule 44.3 |
| 自动裁决 D3=hook 接线纳入本期（五要素：超时值 5min / 推荐项=纳入本期 / 触发时间 2026-10-09 20:05 / 理由=无 hook 承载=纯 LLM 自律不可靠（Rule 65 同款空白）/ 被覆盖选项=推后纯规则层先行） | 同上 Rule 44.3 |
| 纠正-1（2026-10-09 20:17）：首次 attest rule-reserve SKIPPED（配置表 new_rule 值格括注污染 awk $3 解析）→ 括注移入字段格、值格留纯 `67`，本登记后重锁 attest | Rule 51.7 重锁前置登记；attest-plan.sh:256 解析器只取值格去反引号后全文 |
| 纠正-2（2026-10-09 20:14）：时间戳失真修正——填写时未核钟，D1-D3 触发时间 20:15、Phase 1 开启 20:20 均为未来值，致 check-3file-gate 锚点失效 FAIL；按实锚改：决策=20:05（attested_at 20:06:09 前登记）、Phase 1 开启=20:09（ledger tick3 12:09:49Z）、drift=20:12（tick4） | 教训（Rule 33 反思）：时间戳必取实锚（attestation/ledger/date）禁估填；门控按「宁可误报」设计，未来锚点=全信号假阴性 |
| **B 类扩展（2026-10-09 20:30）**：scope +12 文件（3 索引文档 README/CLAUDE/README_zh + CHANGELOG 收尾条目 + 8 selftest 锚演进）+ S8-S13 六新单元 + parallel_groups 增 p3-b + 根源表/FMEA 级联更新 | 来源=Phase 3 派发前对 `1-65` 活断言面的全仓发现（LA-12/RF-06/RF-07/TS-05/SR-07/RC-11/WF-10/DCS-11/skill-split≤510 六类活钉，findings「级联面发现」段带证据行号）；不扩展则 VC-5「回归=基线」必 FAIL——属计划内 FMEA RPN=210 兜底动作②「拆细」的执行（非范围蔓延）；v149 同构判例=其 Wave2a 守卫级联批 |
| 设计细化-3（2026-10-09 20:55）：S4 hook 形态=单 emit 携带双行（`${_cp}` 后缀拼接），废弃「独立第二行 emit」与「emit 行零 hunks」原红线 | S4 首派实测发现 F9 单轮单 JSON 硬约束（zcode-posttooluse.sh:323 + DCE-19）——独立 emit 必双行违规；`jq -Rs` 允许消息内嵌 \n；实测全仓 selftest 对该 emit 行零断言（原红线为设计自设保守项）→ design-draft §3 已修订，证据 findings/progress 在案 |
| 纠正-3（2026-10-09 21:25）：VC-5 与 S2 行验收「整串 `Critical Rules 1-67` =3」口径作废，改为「整串 ≥2 + 短串 `1-67` =3」 | S2 实测上报偏差：SKILL:9 原文=「Critical Rules **全集** 1-65」，任何时点都不含整串 `Critical Rules 1-65`（改前整串本=2）——原 =3 系计划期误设；真实消费断言 RF-06 用短串 ≥3、LA-12/TS-05/SR-07/RC-11 用整串 ≥1，新口径全满足（主进程实测：短串=3/整串=2/RF-07 双锚=1） |
| **fix-wave（2026-10-10 02:40）**：CR round1 CHANGES_REQUESTED → 追加 S14-S17 四修复单元（posttooluse 除零+钳位 / selftest 去 git 依赖+交叉断言+C46 断言 / SKILL+条款 C45→C46 / README 模板计数）；**Phase 6 合并预案升级**＝先 `git merge master` 入 worktree 并集解（9 重叠文件标签并集取 1-67、skill-split 钉取 518、RC-15 `^66=6` 正钉保留、goal-unit 新 selftest 若钉 1-66 则随并集演进）再全量回归，然后 smart-merge-back --deploy | CR 实测证据（MAJOR-1 复现 division-by-0/MAJOR-2 部署位无 master/MAJOR-3 master C45=goal Rule 66）+ master 现实态核对（dbc635a..master 9 commit，v151 Rule 66 六子条+RC-15 `^66=6`+skill-split 钉 515+registry 64 selftest）——原「v151 在途」假设已失效，按已落地事实重订合并面 |
| attest 新门适配（2026-10-10 02:45）：补录「🎯 Goal 单元表」（66.1 六列，G1-G4 complete+G5/G6 pending）+ progress 四条 [goal:Gn] 证据行 + S16 单元格 `\|` 管道转义清除 | v151 已把 Rule 66.5（Goal 单元表硬门）与新版 check-plan-dispatch 部署到位（部署位=master 态）→ 旧计划 attest 被拒；S16 管道字符拆列=v149 S20 同款判例（单元格禁裸管道） |
| 重锁登记-1（2026-10-10 03:2x）：Phase 5 收尾期对 task_plan 的执行期簿记编辑（checklist 勾选/Status complete/S7 行 done/Drift Log 行/Current Phase→6 前状态）——非内容重规划，按 51.7 登记后重锁 | hook PLAN TAMPERED 触发=锁后编辑；执行期状态簿记为流程既定动作，登记编号备查 |
| 用户新指令判定（2026-10-10 03:3x）：用户三条 mid-turn 反馈（漂移愤怒案例+消歧义+废弃隔离）→ **D 类新任务**（Rule 8.1：与 v152 Goal 无关联）→ 开新计划独立承载，R1-R5 逐字归档于新计划「🎯 用户需求原文」；v152 原样保留不收编 | 用户原话三连发（调研 6 分钟假完成/视频剪纸风变 3D/正确错误混放混淆）；判定落 notepad；v152 继续 Phase 6 不留半成品 |

## Errors Encountered
<!-- WHAT: Every error you encounter, attempt number, and resolution. WHEN: Add immediately when an error occurs. -->
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| init WARN：哨兵 sidkey(4ec328f) 与 env sid(de2c5bba) 不一致 | 1 | 复用 RC-1 已知家族问题；set-active-plan side 指针已按 env sid 落盘指向 v152，plan-created.cjs 确认可写 | → findings.md Issues Encountered；→ progress.md Error Log |

## Notes
<!-- REMINDERS -->
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition
- 实现阶段禁止触碰 `/home/terry/.zcode/cli/config.json`（零新键）；禁止改动其他 worktree（§十一 11.4）
- 每 Phase complete 后同步刷新 Current Phase / Next Step / 原生 Todo 映射

## 🚨 Drift Log（漂移检测记录）
<!-- WHEN: 每次派发 drift-checker 偏移检查（Rule 61 载体）后追加一行记录。FORMAT: | timestamp | 结果 | VC条目 | 结论 | -->
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-09 20:12 | ALIGNED | VC-1, VC-2 | Phase 1 三锚证据齐（Goal:49-54 / progress Phase0-1 / scope 无越界），基线满足；建议翻 complete |
| 2026-10-09 20:21 | ALIGNED | VC-4, VC-5 | Phase 2 四要件独立核验（git worktree list/IDENTICAL×4/基线 63/63/0/log 63 行聚合）；风险注记=2 脚本空输出仅 rc 判定 |
| 2026-10-09 23:57 | ALIGNED | VC-1..VC-4 | Phase 3 三锚独立实测（13 单元三证据/17 文件恰=scope/九脚本绿/^66 防线完好）；注记=v153 第三方并行目录出现，Phase 6 合并前复核 |
| 2026-10-10 07:1x | DRIFT（收尾缺口） | VC-1..VC-5 | 三锚全过（a7b1619/三部署位 IDENTICAL/69-69-0）但 Phase 6 六勾选未满足：alignment-review 未跑+58.5 占位+land 67/check-complete 未跑+交付簿记未写+worktree 未清理；放行=6 项补齐后复核回 ALIGNED |
| 2026-10-10 03:2x | ALIGNED | VC-1, VC-5 | Phase 5 CR 门闭环（round1→fix-wave 六项→round2 APPROVED）；唯一 MINOR 折叠 Phase 6；worktree 零新增文件 |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6）
<!-- 本任务非批量同质操作（chain_mode=linked，7 个 S-unit 为串行/组内并行实现单元），字段填 n/a -->
| 字段 | 值 |
|------|-----|
| `total` | n/a（非批量同质操作） |
| `success` | n/a |
| `failed` | n/a |
| `failure_rate` | n/a |
| `sampled_pass` | n/a |
| `sampled_fail` | n/a |
| `pre_check` | n/a |
| `rollback_point` | n/a |

## 📊 委派统计（Rule 25.4 — 终验前必填）
<!-- WHAT: 本计划子代理 vs 主进程的执行分布统计。WHEN: 每个 Phase complete 后更新；终验交付前必须完整。 -->
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | `3 / 6`（P3 executor / P4 code-runner-agent / P5 code-reviewer） |
| 主进程直做 Phase 清单 | `P1（白名单② 计划系统文件维护）`、`P2（白名单① git/worktree 编排 + ② 计划系统文件维护）`、`P6（白名单① git 编排 + ② 簿记）`——全部理由命中 25.3 白名单 |
| 委派率 | `3/6 = 0.5`（< `delegation_rate_floor` 0.7）→ 主进程直做理由全命中白名单 → Rule 25.4a `DELEGATION RATE WHITELIST-EXEMPT` 放行，不降级（编排/簿记型 Phase 属正常形态） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
<!--
  WHEN: 每次 Agent() 派发前填一行；子代理返回 30s 内主进程必须 Read 实际产出 + 紧邻 Edit findings.md 回填结论（「findings 落点」列记段落锚点），两动作完成才在「备注」列勾 verify_done。
  状态枚举: queued/pending/running/done/partial/timeout/failed/blocked/scaling-redispatch；本表 pre-fill 计划期预计派发行。
  派发 prompt 八字段模板: templates/subagent_dispatch.md
-->
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-10-09 | explore（agentId=agent_9c951ea4-287a-406d-8460-ad58d36ecfcd） | 侦察 7 问 A-G（Rule 29/65 现状、hook/config 面、编号账本、selftest 约定、压缩面、会话交接空白） | done（=complete；模板枚举口径） | 三空白确认：主动触发/混乱压缩/会话交接文档均缺；Rule 65 hook 未接；Rule 67 空闲；config properties=42 钉死 | findings.md Research Findings A-G；kb §2 | Research Findings 段（A-G） | -（Explore 只读无检查点） | - / 0 / ☑ |
| 1b | 2026-10-09 | general-purpose（代 plan-writer 角色） | 产出 task_plan.md（386 行/6 Phase/7 S-unit） | done | 机器校验 check-plan-dispatch exit 0 + template-gate OK（主进程独立复跑，非采信自报） | task_plan.md 全文 Read 复核 | task_plan.md（产物即计划；Decisions Made 段） | subagent-state/1-plan-writer.md | sonnet-1 档 reasoning 缺失改派（22.3①）/ 0 / ☑ |
| 1c | 2026-10-09 | drift-checker（general-purpose 承载，22.3① haiku provider 拒） | Phase 1 偏移检查（64.4 三锚输入） | done | ALIGNED——三锚逐条证据齐（Goal:49-54 对照 design-draft §1-§4；progress 逐条为真；scope 无越界） | checkpoint:1c-drift-checker.md；Drift Log 首行；ledger drift_check | findings.md 设计定稿段尾行 | subagent-state/1c-drift-checker.md | provider 改派 / 0 / ☑ |
| 2 | 2026-10-09 21:1x | executor | S1 critical-rules.md 文末追加 Rule 67 六子条 | done | +15/-0；^67.[1-6]=6、主动评估=5（主进程 worktree 实测复验） | worktree diff --stat + checkpoint 1925B | findings「A 批验收」段 | subagent-state/2-executor-S1.md | - / 0 / ☑ |
| 3 | 2026-10-09 21:1x | executor | S2 SKILL 级联（1-67 三处 + Rule 67 bullet + C45） | done | 短串 1-67=3（RF-06 口径）/整串=2/1-65=0/C45=1/511 行；偏差①整串≠3=验收标准误设（第9行含「全集」）→VC-5 已纠正-3 | SKILL grep 实测 + checkpoint 4599B | findings「A 批验收」段 | subagent-state/3-executor-S2.md | 偏差上报诚实/0/☑ |
| 4 | 2026-10-09 21:1x | executor | S3 新建 templates/session-handoff.md 五段模板 | done | 五段标题各=1；纯新增（?? 状态）；session-catchup/plan-resume/62.1 锚自报=1×3 | 五段 grep 实测 + checkpoint 885B | findings「A 批验收」段 | subagent-state/4-executor-S3.md | - / 0 / ☑ |
| 5 | 2026-10-09 21:2x | executor | S4 zcode-posttooluse.sh 单 emit 接线（${_cp} 后缀） | done | bash -n OK；env 锚=3；emit 计数 12=12 未增；三键/F10 零改动；diff=+12/-1（emit 行后缀） | grep 实测 + checkpoint 1376B | findings「A 批验收」段 | subagent-state/5-executor-S4.md | 首派超限返工一次/0/☑ |
| 6 | 2026-10-09 22:4x | executor | S5 新建 selftest-context-pressure.sh + registry.tsv 加行 | done | 新脚本 9/9 PASS exit 0（主进程独立复跑）；registry 65 行 TAB 4 列 | 主进程复跑输出+checkpoint | findings「B/C 批验收」段 | subagent-state/6-executor-S5.md | 步骤枚举首拦改写后成/0/☑ |
| 7 | 2026-10-10 01:5x | code-runner-agent | S6 全量 selftest 回归 + 基线对比 + hook 冒烟 | done | 64/64/0 零新增（对基线恰 +1）；冒烟 run1 单行 JSON 双段 PASS/run2 off 开关 PASS；config=42；registry 64=64 | 主进程抽验：regression-worktree.log rc≠0=0+diff 新增恰 1+冒烟产物 4 件+config diff 空 | findings「Phase 4 验证」段 | subagent-state/7-code-runner-S6.md | 跨夜长跑/0/☑ |
| 8 | 2026-10-10 02:2x | code-reviewer | S7 全量 diff CR（17 文件重 diff） | done | **CHANGES_REQUESTED**（0 BLOCKER/3 MAJOR/3 MINOR）——R1/R2/R3 裁决全落实、990 PASS 全绿；MAJOR=_cpn 除零实测复现/CP-06 git 依赖部署位必挂/C45 与 master Rule 66 撞号；并发现 master 已前进 9 commit（v151 Rule 66 落地） | checkpoint 8-code-reviewer-S7.md（含负结果报告与实测复现） | findings「CR round1」段 | subagent-state/8-code-reviewer-S7.md | 审查含 master 现实态对照/0/☑ |
| 9 | 2026-10-09 22:3x | executor | S8 索引文档标签级联（skill README+CLAUDE） | done | 两文件 1-67 各=1、1-65=0（主进程复验）；带 v152 对齐注 | worktree grep 实测+checkpoint | findings「B/C 批验收」段 | subagent-state/9-executor-S8.md | - / 0 / ☑ |
| 10 | 2026-10-09 22:3x | executor | S9 README_zh 两处 + DCS-11 标签级联 | done | README_zh 1-67=2/1-65=0；DCS 活断言行 40-67、残留 2 处全在演进注（历史记录，v149 先例——验收口径修正同纠正-3 族）；bash -n OK | 主进程 grep 实测+checkpoint | findings「B/C 批验收」段 | subagent-state/10-executor-S9.md | 口径矛盾诚实上报/0/☑ |
| 11 | 2026-10-09 22:5x | executor | S10 RF/LA 锚演进 | done | RF 12/12 + LA 14/14 PASS；RF-08/RF-10/^66/^65 模式行零改动 | 脚本复跑+checkpoint | findings「B/C 批验收」段 | subagent-state/11-executor-S10.md | S18 路径字面首拦改写后成/0/☑ |
| 12 | 2026-10-09 23:0x | executor | S11 SR/TS 锚演进 | done | SR 13/13 + TS 12/12 PASS；SR-12/1-39 零改动 | 脚本复跑+checkpoint | findings「B/C 批验收」段 | subagent-state/12-executor-S11.md | - / 0 / ☑ |
| 13 | 2026-10-09 23:0x | executor | S12 RC/WF 锚演进（^66 防线零触碰） | done | RC 23/23 + WF 16/16 PASS；RC-15 :166/:179 逐行自证零改动 | 脚本复跑+checkpoint | findings「B/C 批验收」段 | subagent-state/13-executor-S12.md | - / 0 / ☑ |
| 14 | 2026-10-09 22:5x | executor | S13 skill-split 行数钉上调 | done | 41/41 PASS；510→518（-le ×2+注释）；首轮 provider 失败后文件已在目标态，复核确认零额外改动 | 脚本复跑+checkpoint | findings「B/C 批验收」段 | subagent-state/14-executor-S13.md | provider 失败重试/0/☑ |
| 15 | 2026-10-10 03:0x | executor | S14 fix：posttooluse 除零+钳位外移 | done | bash -n OK；N=0 fixture 无 division-by-0 且 SMOKE PASS（主进程复跑）；:336/:350 两防护行就位 | 主进程复跑+checkpoint | findings「fix-wave」段 | subagent-state/15-executor-S14.md | - / 0 / ☑ |
| 16 | 2026-10-10 03:0x | executor | S16 fix：C45→C46（SKILL+条款） | done | 双文件 C46=1/C45=0（主进程实测）；RF 12/12+LA 14/14 复跑绿 | 主进程 grep+checkpoint | findings「fix-wave」段 | subagent-state/16-executor-S16.md | - / 0 / ☑ |
| 17 | 2026-10-10 03:0x | executor | S17 fix：README 模板计数 10→11 | done | 11核心=2/10核心=0（主进程实测） | 主进程 grep+checkpoint | findings「fix-wave」段 | subagent-state/17-executor-S17.md | - / 0 / ☑ |
| 18 | 2026-10-10 03:0x | executor | S15 fix：selftest 常量锚+交叉断言+C46 | done | 9/9 PASS；git show=0；C46=4/C45=0（主进程复跑） | 主进程复跑+checkpoint | findings「fix-wave」段 | subagent-state/18-executor-S15.md | CP 计数 9=终态裁决/0/☑ |

## 🔗 Chain 区块交接配置（可选）
<!-- 单 skill 任务（task-planner 技能自增强），不涉多 skill 接力 → 不适用 -->
| 字段 | 值 |
|------|-----|
| **chain_mode** | `linked`（单 skill 内 S-unit 串行/组内并行接力，非多 skill 交接） |
| **current_block** | n/a（单 skill 任务，无跨 skill Block 交接） |
| **handoff_on_complete** | ❌ 否 |
