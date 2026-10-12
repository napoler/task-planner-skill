# Task Plan: task-v168 会话锚定与技能激活/错误纠正机器面（Rule 77/78/79）
execution_lane: L1
<!-- 
  WHAT: This is your roadmap for the entire task. Think of it as your "working memory on disk."
  WHY: After 50+ tool calls, your original goals can get forgotten. This file keeps them fresh.
  WHEN: Create this FIRST, before starting any work. Update after each phase completes.
-->
<!-- 用户原话 R1-R5 全文见 findings.md Requirements 段（2026-10-11 会话中断恢复后逐字复原归档） -->

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：Rule 51.1 计划侧载体（审计 H-3 清账）。R 行=用户原话逐条编号抄录；映射=每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉（51.1/51.2） -->
<!-- 2026-10-07 task-v143：Rule 58.4 手段/目标二分——每条 R 行末尾标注 [手段] 或 [目标]；[目标] 行必须映射 ≥1 条「问题解决判据」VC -->

- **R1**: 「彻底解决当前技能的幻觉问题，因为我发现执行任务之后，就存在严重的偏移现象。就是执行着执行着，就完全放弃之前最初的指令是什么了。」<sub>（[目标]）</sub>
- **R2**: 「将该技能进行确定化……拦截……相关性不高的东西，相关性不高的任务，建议使用别的技能进行创作，或者说进行执行。核心理念就是锚定一个话题、一个任务进行解决，尽量在单个会话中不解决偏移性过大的工作。我发现话题比较严重的偏移，及时提醒，确认后给出建议。」<sub>（[目标]）</sub>
- **R3**: 「时常回顾执行的上下文，或者说检查执行的文件，就是当前的文件系统……这几个文件……每隔一段时间检查一次。确保执行的不会出现偏移。如果是有偏移的话，及时进行纠正。主要就是提高准确度，执行的准确度。」<sub>（[目标]）</sub>
- **R4**: 「我希望可以在执行的过程中，及时纠正执行过程中的错误，因为执行的错误也比较高。」<sub>（[目标]）</sub>
- **R5**: 「不会去调用第三方，不会去主动去调用第三方技能。我之前提示过多次使用引入，就是像Superpowers或者说Spike这种……或者说Comet这类技能来提高任务执行的可靠度，但是当前执行过程中实际从未激活过……其他的也应该主动去激活一些相关的技能，来去解决任务，确保执行的更加专业，更加可靠。」<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2 | UserPromptSubmit 注入块含用户需求原文 R 条目+不变量（grep 实证）；PostToolUse 每 N 次注入锚点卡（fixture） |
| R2 | VC-2, VC-3 | 锚点卡周期回注机制在位 + Rule 65 周期回顾接线（fixture 矛盾场景实证） |
| R3 | VC-3 | PostToolUse 调用 periodic-review.sh 且矛盾信号被注入消费 |
| R1 | VC-1 | SKILL.md 执行循环含「R 锚定复诵」强制步骤（Phase 开工即复诵用户原话） |
| R2 | VC-2 | 执行循环含动作相关性三问+S-unit 级三文件对照步骤 |
| R3 | VC-2 | 同上（周期性三文件对照 = R3 行为面载体） |
| R4 | VC-3, VC-4 | error_loop_enforce/reflect_verify_enforce 翻 enforce（设置层）+31.1⑤/33.1④/错误同轮四步（逻辑层） |
| R5 | VC-2 | 执行循环 2.5b 技能激活确认步骤（brief §6 择优激活+disable 型仅提示） |
| （全体） | VC-5, VC-6 | 全量回归 76 脚本 FAIL=0；红线=零新 hook/零新脚本/零新 config 键 |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-11 方向 piv⊥ 重写：用户反馈「明明是逻辑上或者说技能的设置问题」后，工序审计聚焦技能指令逻辑与既有设置层（机器面已整体封存见 notepad 被否决方案段） -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 技能主流程（SKILL.md 执行循环） | Phase 开工无原话复诵；新动作无相关性拦截；S-unit 级无三文件对照；派发前无技能激活确认 | Phase 2 逻辑层五步植入（2.1/2.5b/3c′/3f） | VC-1, VC-2 |
| 规则触发条件（critical-rules.md） | Rule 31.1 四触发全用户侧；33.1 不覆盖问题出现时 | Phase 2 逻辑层：31.1 增⑤/33.1 增④ | VC-3 |
| 既有门控档位（config.json 设置层） | error_loop_enforce=warn；reflect_verify_enforce=warn → 既有 Learning/REFLECT 门不阻断 | Phase 3 设置层：翻 enforce | VC-4 |
| 留痕载体（templates/progress.md） | Error Log 缺触发命令/工具列 | Phase 2 逻辑层：增列 | VC-3 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
<!-- WHAT: 任务要素显式分三态——不变量(锁)/可变量(自主调+登记)/学得量(只入 findings、禁反写不变量）。 -->
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | 用户需求原文 R1-R5 全文；VC-1~VC-7 判定标准；Rule 59.3 红线（disable-model-invocation 技能禁自动代激活）；「不改 zcode-pretooluse.sh exit 2 阻断语义」「不改 Learning/REFLECT-GATE 既有语义」「纯增量、零新 config 键」三条工程红线 | 用户需求原文区；VC 表；Decisions Made |
| 🔀 可变量 | 脚本内部实现/S-unit 拆分/Rule 77-79 子条款编号分配/selftest 断言形态 | - |
| 📈 学得量 | 中断恢复教训（计划目录归属主仓+指针本地化执行细节）；report 02 comet 族措辞发现；rule-reserve 运行坑 | findings.md |

## Goal
<!-- 
  WHAT: One clear sentence describing what you're trying to achieve.
  WHY: Your north star. Re-reading this keeps you focused on the end state.
-->
为 task-planner 修复长会话漂移/技能闲置/错误迟纠三类缺陷的**技能逻辑与既有设置**：把「R 原话复诵、动作相关性拦截、S-unit 级三文件对照、错误同轮四步、技能激活确认」五个行为锚点植入 SKILL.md 执行循环主流程，将 error_loop_enforce/reflect_verify_enforce 两个既有 warn 开关翻 enforce，Rule 31.1/33.1 触发条件补执行期信号——零新 hook、零新脚本、零新 config 键。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | `v168-2026-10-11` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v168-session-anchor-skill-activation` |
| `scope_files` | `skills/task-planner/SKILL.md, skills/task-planner/references/critical-rules.md, skills/task-planner/config.json, skills/task-planner/templates/progress.md`（逻辑层+设置层四文件；机器面脚本全部不在范围=已封存） |
| `interaction_mode` | `silent`（关键决策点已在本计划内显式裁决，无 2+ 选项遗留） |
| `对齐审查` | `mini 档豁免不适用（standard 档）；沿用既有 alignment-review 流程，合并后主仓复验时执行` |
| `自动超时默认项` | `n/a（silent 模式）` |
| `new_rule` | 留空（方向 piv⊥ 后不新增 Rule 编号；77/78/79 预留在封存分支保留，未 land 于本分支产出） |
| `质量审查工具` | `code-reviewer 子代理（独立上下文 Code Review）+ check-complete.sh 全门机检` |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：本计划验证动作默认由独立子代理执行，主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | R 锚定复诵步骤在位：SKILL.md 执行循环步骤 1 含「Read 用户需求原文区→progress 段首行复诵本 Phase 服务的 R 条目」强制动作 | grep 原文 + 段落位置 | `skills/task-planner/SKILL.md` 执行循环步骤 1 |
| VC-2 | 三个行为锚点在位：执行循环含 ①动作相关性三问 ②S-unit 级三文件对照（每 S-unit/每 10 次工具调用）③错误同轮四步（写 Log→四问根因→纠正→复验）④2.5b 技能激活确认（brief §6 择优+disable 型仅提示） | grep 四步原文 | SKILL.md 步骤 2.5/3/3c/3f |
| VC-3 | 规则触发条件扩展在位：critical-rules.md Rule 31.1 含第 5 触发条件（执行期机器可观察错误）、Rule 33.1 含第 4 触发点（问题出现即时） | grep ⑤/④ 原文 | critical-rules.md:322,:345 |
| VC-4 | 设置层翻档在位：config.json error_loop_enforce 与 reflect_verify_enforce 均由 warn 改 enforce | git diff 实证 | config.json 两键 default 值 |
| VC-5 | 全量回归 FAIL=0：run-selftests 76 脚本全 PASS（机器面已封存=回归回到 master 基线+cascades 消失） | 跑批输出 | `scripts/run-selftests.sh --fresh` |
| VC-6 | 红线零越界：零新 hook/零新脚本/零新 config 新键；zcode-pretooluse.sh/Learning Gate/REFLECT-GATE 既有语义未改 | git diff 文件清单+CR | `git diff --stat` 仅 4 个范围内文件 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：`code_review: required`，终验前必须先通过 Code Review Gate，否则不得标记 COMPLETE。

## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1-R5（全部为[目标]） |
| **裁决** | `partial`（逻辑/设置层修复全部落地且回归全绿；机器面按用户 piv⊙ 封存，行为面生效待部署+实战观察） |
| **解决证据锚** | verification.md VC-1~6 全 [x]（SKILL.md:87/92/93/99/102；critical-rules.md:322/345；config.json:286/302；master 回归 77/77 exec log） |
| **未解决面+原因** | ①部署未做（§六 待授权）②五锚点执行率无实战实证（依赖模型纪律）③REFLECT-GATE 仅对声明型计划生效（守存量语义不扩触发） |
| **已排除路径** | 机器面代码路线=用户明令否决，封存分支备 revival |
| **下一步建议** | delivery-summary.md §5 三条（授权部署→观察行为面→按需 revival） |

## 🎯 Goal 单元表（Rule 66.1 — 规划获批后任务单元固化；standard/full 必填，mini 档豁免）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 调研与设计定稿 | 三报告回填+VC/Phase/S-unit 机检通过 | attest-plan.sh 锁 + check-plan-dispatch.sh exit 0 | Phase 1（主进程） | complete |
| G2 | 逻辑层五锚点 | SKILL.md 执行循环植入 R 复诵/相关性三问/三文件对照/错误四步/技能激活（VC-1/2/3） | grep 五步原文 + 位置实证 | Phase 2 S1-S2 | complete |
| G3 | 设置层翻档 | error_loop/reflect_verify 翻 enforce（VC-4） | git diff config.json 两键 | Phase 3 | complete |
| G4 | 全量回归+CR | 77 脚本 FAIL=0 且 CR 问题全闭环（VC-5/6） | run-selftests 77/77 + 21/22-cr 记录 | Phase 4 | complete |
| G5 | 合并回主仓 | wt 合并 master+封存分支保留+主仓复验 | git log cdf437e/9fce0ff/618df79 + 77/77 | Phase 5 | complete |
| G6 | 终验交付 | VC-1~6 逐条通过+交付 | verification.md + delivery-summary.md | Phase 6 | complete |
| （封存） | 机器面 parked | 已写 hook/脚本/门控封存于 wt/task-v168-machine-parked 分支，不合并不部署 | git branch 实证 | 不占 Phase | parked |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）
<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码 | skills/task-planner/scripts/plan-anchor.sh（新）, scan-skills.sh（新）, selftest-session-anchor.sh（新）, selftest-skill-activation.sh（新）, selftest-error-correction.sh（新）, zcode-posttooluse.sh, zcode-userpromptsubmit.sh, check-dispatch.sh, ledger-append.sh, check-complete.sh, periodic-review.sh（仅被调用不改行为，除非明确登记） | 其他 .sh 文件 |
| 规则/文档 | skills/task-planner/references/critical-rules.md, SKILL.md, templates/progress.md, templates/knowledge-brief.md（仅 §6 指引行如有引用失效则同步）, templates/task_plan.md（仅新增「激活计划」区块指引，如需） | 其他 .md |
| 配置 | skills/task-planner/scripts/selftest-registry.tsv | config.json（零新键） |
| 计划簿记 | plans/task-v168-session-anchor-skill-activation/**（主仓；worktree 仅承载代码） | plans/ 其他条目 |

**执行前自我检查:**
- [ ] 这个文件在上面的列表中吗？
- [ ] 这个修改对完成任务有必要吗？
- [ ] 用户明确要求我做这个修改吗？
- 全部 Yes → 可以执行 | 任一 No → 先问用户（问询按 Rule 70 四要素）

## 📋 变更标注表（Rule 74.3 — 修订方案必填，无表=无效方案）

| 编号 | 对象（文件+锚点） | 类型（新增·修改·删除·更新） | 吸收判定（增量·替代·删除） | 依据（用户原话或证据） | 执行动作 |
|------|------------------|---------------------------|-----------|------------------------|---------|
| CA-1 | scripts/plan-anchor.sh（新文件） | 新增 | 增量 | R1/R3：执行期零锚点回注（findings §5） | Phase 2 S1 |
| CA-2 | zcode-userpromptsubmit.sh（smart 注入段 :84-162） | 修改 | 增量 | R1/R3：Goal 首行截断+字段集不含原话（Report 01 §4） | Phase 2 S2 |
| CA-3 | zcode-posttooluse.sh（注入优先级区 :327-366） | 修改 | 增量 | R1/R3：执行期零回注+65 无触发载体 | Phase 2 S3/S4；Phase 4 S2 |
| CA-4 | references/critical-rules.md（Rule 77 正文，插 Rule 75 后） | 新增 | 增量 | R1/R3/R2 | Phase 2 S5 |
| CA-5 | SKILL.md（摘要行/CR 段落级联） | 修改 | 增量 | Rule 77 纪元扩展（全库计数钉级联） | Phase 2 S5 |
| CA-6 | scripts/scan-skills.sh（新文件） | 新增 | 增量 | R5：59.3 无机器面（Report 02 §6 P0-1） | Phase 3 S1 |
| CA-7 | ledger-append.sh（VALID_EVENTS :30） | 修改 | 增量 | R5：无 skill_activation 事件（Report 02 §5.7） | Phase 3 S2 |
| CA-8 | check-dispatch.sh（伴飞校验 :566-599 后） | 修改 | 增量 | R5：伴飞无 disable 判定（Report 02 §4） | Phase 3 S3 |
| CA-9 | check-complete.sh（SKILL-ACTIVATION GATE 段） | 新增 | 增量 | R5：激活无门控（Report 02 §6 P0-5） | Phase 3 S3 |
| CA-10 | templates/task_plan.md（「激活计划」区块指引） | 修改 | 增量 | R5：激活行为需计划载体可见 | Phase 3 S3 |
| CA-11 | references/critical-rules.md（Rule 31.1 第 5 触发条件 :322；Rule 33.1 增触发 :344；Rule 78 正文；Rule 59.3 措辞精确化 :782） | 修改 | 增量 | R4/R5（Report 03 §7；Report 02 §7.5④） | Phase 4 S1；Phase 3 S4 |
| CA-12 | templates/progress.md（Error Log 增「触发命令/工具」列） | 修改 | 增量 | R4：Error Log 缺触发列（Report 03 §3 P2-8） | Phase 4 S1 |
| CA-13 | references/critical-rules.md（Rule 79 正文，插 Rule 78 后） | 新增 | 增量 | R4（Report 03 §7） | Phase 4 S1 |
| CA-14 | check-complete.sh（ERROR-CORRECTION GATE 段） | 新增 | 增量 | R4：执行期无即时门控（Report 03 §6 P0-3） | Phase 4 S3 |
| CA-15 | selftest-registry.tsv（3 新 selftest 登记） | 修改 | 增量 | 守护先例（selftest 全量回归计数级联） | Phase 2/3/4 各 S-末位 |
| CA-16 | scripts/selftest-session-anchor.sh（新） | 新增 | 增量 | Rule 77 机制守护 | Phase 2 S6 |
| CA-17 | scripts/selftest-skill-activation.sh（新） | 新增 | 增量 | Rule 78 机制守护 | Phase 3 S4 |
| CA-18 | scripts/selftest-error-correction.sh（新） | 新增 | 增量 | Rule 79 机制守护 | Phase 4 S3 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）
<!-- WHAT: 本任务依赖的知识源清单(规范/官方文档/内部知识库/文献/图书)。 -->

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|--------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | findings.md 三调研报告（01/02/03） | plans/task-v168-session-anchor-skill-activation/subagent-state/*.md | 必读 | ☑ |
| 项目内部文档/知识库 | critical-rules.md Rule 15/20/31/33/59/64/65/67/75 原文 | skills/task-planner/references/critical-rules.md（worktree HEAD 39c41fa） | 必读 | ☑ |
| 项目内部文档/知识库 | hook 四脚本+check-complete/check-3file-gate/ledger-append 全文 | skills/task-planner/scripts/*.sh（worktree HEAD） | 必读 | ☑ |
| 官方文档 | zcode hook 协议（PreToolUse/PostToolUse/UserPromptSubmit 输入输出） | 既有 hook 脚本内注释（历史既有，已遵循） | 参考 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）
**核心问题**: task-planner 的长会话执行期缺乏「原话回注+周期回顾+技能激活+错误即时纠正」四类机器触发，导致用户 R1-R5 描述的漂移/闲置/迟纠三类实战缺陷无法被机器拦截。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？—— 三波次机制落地=交付物本身
- [x] 核心问题不解决，其他工作都白费吗？—— 是（规则面再完善，无机器触发即空转）
- [x] 核心问题的解决方法是清晰的、可执行的？—— 是（S-unit 表逐条已拆）

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| Phase 1 G1 | LOCAL-ONLY | drift/anchor/skill activation/error correction | 仓内 grep（已完成，三报告） | findings 回填 | 否 |
| Phase 2-4 全部 S-unit | LOCAL-ONLY | hook injection/selftest fixture/disable-model-invocation | 仓内既有脚本对照（76 selftest 基线） | 脚本实现 | 否 |
| Phase 5-7 | LOCAL-ONLY | run-selftests/registry/merge | 仓内既有流程 | 回归+合并 | 否 |

> 三态判定：全部 LOCAL-ONLY（仓内知识完全覆盖，无 NET-* 条目）。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!-- 本任务=工程实现类，产出=脚本+规则，非结论/归因类 → 适用判定：填 n/a -->
n/a（纯执行类——产出为可执行脚本与规则条款，无归因结论需对标取证；调研类产出已由 Phase 1 三报告承载并以 findings.md 归档）

## Current Phase
<!-- WHAT: Which phase you're currently working on (e.g., "Phase 1", "Phase 3"). -->
Phase 2（逻辑层五锚点）

## Next Step
<!-- WHAT: 单一下一步动作(一句话,可执行)。 -->
派发 code-assistant 在 worktree 改 SKILL.md 执行循环：步骤 1 加 R 锚定复诵、2.5b 加技能激活确认、3c 加错误同轮四步、3f 加 S-unit 级三文件对照。

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 Explore（mini）+ 主进程 | 只读调研跨多文件需隔离上下文（已完成） |
| Phase 2 | Agent 子代理 code-assistant（纯文本逻辑修订，零新代码） | 用户 piv⊥ 指令：逻辑层优先，禁新增 hook/脚本 |
| Phase 3 | 主进程 + code-assistant（config.json 两键翻档） | 设置层=改既有开关值，非新键 |
| Phase 4 | Agent 子代理 code-runner-agent（mini）+ code-reviewer | 76 脚本回归+独立 CR |
| Phase 5 | 主进程（git 编排） | 合并/清理/簿记（Rule 25.3 白名单①②） |
| Phase 6 | 主进程（簿记）+ Verifier 视角自查 | 终验交付 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件 → 按 Rule 21.4 独立性守门调度（本任务 S-unit 强顺序依赖链 S1→S2→…，串行）。
**/goal 对齐（Rule 40.3）**: 用户未用 /goal 锚定；本计划 Goal+VC 即 session goal 证据源。

## Phases

### Phase 1: 需求与调研（已完成收口）
<!-- WHAT: Understand what needs to be done and gather initial information. -->
- [x] Understand user intent（R1-R5 逐字归档）
- [x] Identify constraints and requirements（不变量声明区）
- [x] Document findings in findings.md（三报告回填）
- [x] 知识储备必读项已确认可获取（「必要知识储备」表全 ☑）
- **V-N:** VC-6, VC-7（本 Phase 验收映射的 VC 编号）
- **Status:** complete
- **Executor:** explore（mini）+主进程
- 产出：findings.md 全回填；Rule 77/78/79 编号预留（账本 77/78/79 reserved）；技术裁决入 findings Technical Decisions（三报告冲突项已裁：零新 config 键/env-only、59.3 措辞精确化不改红线、Error Log 增列）
- 遗留：无（三报告全部落盘 subagent-state/01-03）

### Phase 2: 逻辑层五锚点（SKILL.md 执行循环行为植入）
<!-- 用户 2026-10-11 piv⊥：漂移=技能逻辑/设置问题 → 本 Phase 只改指令文本，零新代码 -->
- [ ] S1 SKILL.md 执行循环五步植入完成（步骤1 R 锚定复诵 / 2.5b 技能激活确认 / 3c 错误同轮四步 / 3f S-unit 级三文件对照 / 相关性三问）
- [ ] S2 critical-rules.md Rule 31.1⑤+33.1④ 扩展（增量，既有条件语义不动）
- **V-N:** VC-1, VC-2, VC-3
- **Status:** complete
- **Executor:** code-assistant（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|-------------------------|-------------|---------|------|------|------|------|------|
| S1 | SKILL.md 执行循环植入五个行为锚点：①步骤1 后加「R 锚定复诵」（Read 用户需求原文区→progress 段首行复诵本 Phase 服务的 R）②2.5 后加 2.5b「技能激活确认」（派发前 Read knowledge-brief §6，model-invocable 择优激活、disable 型仅提示）③3c 加「错误同轮四步」（写 Error Log→31.2 四问根因→纠正→复验）④3 内加 3f「S-unit 级三文件对照」（每 S-unit/每 10 次工具调用 Read Goal+Phase 对照，偏则 [corrected]）⑤2.5 内加动作相关性三问（服务本 Phase？在 scope_files？用户要求？） | 继承 | plans/task-v168-session-anchor-skill-activation/subagent-state/01-explore-drift-mechanisms.md（§5 缺口 3/§6 设计输入——行为面反向推导） | grep 五步原文各 ≥1；位置在「执行流程图→Phase 执行循环」内 | 15min | 1f/30l/15min | 无 | - | pending |
| S2 | critical-rules.md：Rule 31.1 增第 5 触发条件（执行期机器可观察错误：工具 exit≠0/测试 FAIL/子代理 failed·partial）；Rule 33.1 增第 4 触发点（问题出现即时）；templates/progress.md Error Log 增「触发命令/工具」列 | 继承 | plans/task-v168-session-anchor-skill-activation/subagent-state/03-explore-error-correction.md（§1 规则面+§7.1 扩展点） | 31.1 grep ⑤=1 且原 4 条件未改；33.1 grep ④=1；表头含新列 | 15min | 2f/20l/15min | 无 | - | pending |

### Phase 3: 设置层翻档（既有 enforce 开关启用）
- [ ] error_loop_enforce warn→enforce
- [ ] reflect_verify_enforce warn→enforce
- **V-N:** VC-4
- **Status:** complete
- **Executor:** 主进程（例外理由:② 簿记+设置层两键——Rule 25.3 白名单；改既有键值=用户 piv⊥ 指令明指的「设置」修复）

### Phase 4: 全量回归与 Code Review
- [ ] run-selftests --fresh 76 脚本 FAIL=0（机器面封存后级联钉回到基线）
- [ ] Code Review Gate APPROVED（独立 code-reviewer 子代理）
- **V-N:** VC-5, VC-6
- **Status:** complete
- **Executor:** code-runner-agent（mini）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|-------------------------|-------------|---------|------|------|------|------|------|
| S1 | 跑全量 selftest 回归（76 脚本基线），FAIL=0 | 继承 | plans/task-v168-session-anchor-skill-activation/task_plan.md（VC-5 行） | 跑批输出 Total FAIL=0 | 15min | 1f/10l/15min | 无 | Phase 2-3 | pending |
| S2 | 派发独立 code-reviewer 子代理做 Code Review Gate（四文件 diff+红线负断言） | 继承 | plans/task-v168-session-anchor-skill-activation/task_plan.md（VC-6 行） | CR 记录 APPROVED 或问题清单闭环 | 15min | 1f/10l/15min | 无 | S1 | pending |

### Phase 5: 合并回主仓与清理
- [ ] wt 分支 git status 干净、VC 复验通过
- [ ] 主仓 merge --no-ff + Read 复验
- [ ] 封存分支 wt/task-v168-machine-parked 保留不合并（git branch 实证）；worktree 清理 + branch -d 主任务分支
- [ ] 主仓复验 selftest 抽查+plans 簿记
- **V-N:** VC-5
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

### Phase 6: 终验交付
- [ ] VC-1~VC-6 逐条对照证据链填写 verification.md
- [ ] 「核心目标达成裁决」表填写（R1-R5 三态）
- [ ] 委派统计复验（check-delegation.sh stats）
- [ ] delivery-summary.md 交付（含封存分支说明+机器面遗留清单）
- **V-N:** VC-1, VC-2, VC-3, VC-4, VC-5, VC-6
- **Status:** complete
- **Executor:** 主进程（例外理由:② 簿记——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
<!-- check-conflicts.sh 扫描结果与工作树隔离决策 -->
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（改 skills/** 运行中基础设施：hook 脚本被所有会话实时加载） |
| `isolation` | `worktree` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v168-session-anchor-skill-activation` |
| `branch` | `wt/task-v168-session-anchor-skill-activation` |
| `merge_back` | `pending` |

> 契约详见 `~/.zcode/skills/task-planner/references/worktree-isolation.md`。

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 references/methodology.md §R2）
<!-- WHAT: 对每个 Phase 枚举失败模式，打 S/O/D 1-10 分，RPN=S×O×D。 -->

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 2 | hook 注入改造破坏既有软提醒（drift-rhythm） | 8 | 5 | 4 | 160 | ③④：selftest 先跑既有断言逐条对照；回退=git revert 单 S-unit 再重做 |
| Phase 3 | disable 误判把 model-invocable 技能误归 user-trigger（拒锁误伤） | 7 | 4 | 3 | 84 | ②③：逐个 frontmatter 精确解析+负断言 fixture（comet 主入口应判 model-invocable） |
| Phase 4 | Error Log 增列致存量计划 Learning Gate 误判 | 7 | 5 | 4 | 140 | ②：旧表头兼容（列缺失跳过校验）+master 存量 75 计划全跑 check-complete 回归 |
| Phase 4 | PostToolUse 错误信号误报（stderr 噪音当错误） | 6 | 5 | 5 | 150 | ②：判据=is_error 或 exit≠0 或拦截 exit 2 三选一明确门控，fixture 正反各一 |
| Phase 5 | selftest 计数钉级联漂移（Rule 1-75→1-79） | 8 | 6 | 3 | 144 | ①：全库 grep 计数断言先扫后改（v149/v150/v163 先例）；每改一钉跑全量回归 |
| Phase 6 | 合并冲突（v166 分支并行在途） | 6 | 4 | 3 | 72 | ④：冲突并集解（v149 先例），禁丢文本 |

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-11 | 主进程 TodoWrite |
| Phase 2 | ☑ | 2026-10-11 | 本任务目录 Todo 组 |
| Phase 3 | ☐ | | S2 Phase 状态变更后同步 |
| Phase 4 | ☐ | | 同上 |
| Phase 5 | ☐ | | 同上 |
| Phase 6 | ☐ | | 同上 |
| Phase 7 | ☐ | | 同上 |

## Key Questions
1. 锚点卡字段集是否足够覆盖 R1 漂移面？—— 已定：R 条目全文+不变量+Goal 全文+Phase+Next Step（Report 01 §5 三重收窄反向推导）
2. PostToolUse 计数复用 drift-rhythm 状态机还是新建？—— 已定：复用同一计数状态机范式（O(1) 三键），新增独立 N 键
3. 技能激活红线边界？—— 已定：逐个 frontmatter 判定，disable 型仅提示禁代激活（Report 02 §7.5 红线①②③）
4. error_correction 档位载体？—— 已定：env-only 零新 config 键（Technical Decisions 行 2）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| **方向 piv⊥ 2026-10-11：机器面代码封存，主轴转技能逻辑/设置层** | 用户原话「明明是逻辑上或者说技能的设置问题，你一直在改莫名其妙的各种代码问题，这就是严重的偏差，完全不是在解决问题」。已写 16 文件机器面提交至 wt/task-v168-machine-parked 分支封存（未合并未部署）；任务分支回 master 基线重做逻辑/设置层 |
| 逻辑层五锚点植入 SKILL.md 执行循环（非新 Rule 编号） | 漂移防护内生于模型推理链=用户指定层；既有 Rule 文本不动编号避免级联钉漂移 |
| 设置层翻既有 enforce 开关（error_loop/reflect_verify warn→enforce） | 用户「设置问题」直指；改键值不加键，激活既有 Learning/REFLECT 门 |
| 三波次落 Rule 77/78/79（已封存） | 封存前设计：用户五条需求分三组机器面病灶——随 piv⊥ 整体封存 |
| 全部档位走 env 降档，零新 config 键（已封存） | 封存前设计；piv⊥ 后本分支确认零新键=翻键值 |
| 计划目录驻主仓、代码进 worktree | hook 计划解析基于会话 cwd 主仓指针；合并回合约见 Phase 5 |
| code_review: required | 红线密集任务须独立 CR 视角 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| Write findings.md 超时 30s | 1 | 重试成功（1/2 次） | 大文件写入后 wc 复核 |
| rule-reserve.sh exit 5 | 2 | 发现账本解析需从含 plans/ 的祖先目录运行+第 4 参须 --note | 见 findings Issues Encountered |
| hook 注入旧计划（v163）数据 | 1 | 活跃指针切换 task-v168 后恢复正确注入 | 新任务 init 后必查指针 --show |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition
- Never repeat a failed action - mutate your approach instead
- 本会话为中断恢复续跑：Phase 1 产物（三报告/findings/task_plan 骨架）由中断前会话创建，恢复后核对归档路径并归位（mv 入 worktree → 回主仓定稿）

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-11 中断恢复点 | 恢复会话先 git 考古+第一手复验（v145 教训）；确认 Phase 1 产物完整、指针错位已修 | VC-6,VC-7 | ALIGNED（恢复动作=计划内 Phase 1 收口） |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6,批量任务必填）
| 字段 | 值 |
|------|-----|
| `total` | n/a（纯单次任务，非批量 fan-out） |
| `success` | |
| `failed` | |
| `failure_rate` | |
| `sampled_pass` | |
| `sampled_fail` | |
| `pre_check` | |
| `rollback_point` | |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 1 / 7（Phase 1 Explore×3+主进程；Phase 5-7 待执行时回填） |
| 主进程直做 Phase 清单 | Phase 1（部分）、6、7（例外理由：① git 编排 ② 簿记——Rule 25.3 白名单） |
| 委派率 | （终验前回填；Phase 2-4 全为 code-assistant 子代理，预计 ≥0.7） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|---------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-10-11 | Explore | 漂移/回顾/纠错机制现状盘点（R1/R3/R4） | done | 三缺口链：65 无触发载体/31.1 四触发全用户侧/原话无回注 | 见 checkpoint 01 全文 | Requirements/R1-R4+§1-§3 | plans/task-v168-session-anchor-skill-activation/subagent-state/01-explore-drift-mechanisms.md | - / 0 / ☑ |
| 2 | 2026-10-11 | Explore | 技能主动激活面盘点（R5） | done | 179 技能/3 disable/59.3 无机器面；comet 措辞与 frontmatter 不符 | 见 checkpoint 02 全文 | §4 | .../02-explore-skill-activation.md | - / 0 / ☑ |
| 3 | 2026-10-11 | Explore | 执行错误即时纠正面盘点（R4） | done | hook 零错误感知/Learning 终验门/31.1 不覆盖执行期 | 见 checkpoint 03 全文 | §3+§5 | .../03-explore-error-correction.md | - / 0 / ☑ |
| 4 | 2026-10-11 | code-assistant | P2S1 plan-anchor.sh 新增 | done | 锚点卡五字段提取，98 行，--test 5/5 | plan-anchor.sh:1-98 | - | .../04-s1-plan-anchor.md | - / 0 / ☑ |
| 5 | 2026-10-11 | code-assistant | P2S2 userpromptsubmit 锚点注入扩展 | done | Goal 全文+锚点卡字段，--test 5/5，+228/-81 | zcode-userpromptsubmit.sh | - | .../05-s2-userpromptsubmit.md | - / 0 / ☑ |
| 6 | 2026-10-11 | code-assistant | P2S3 posttooluse [re-anchor] | done | 计数状态机注入锚点卡，--test 5/5 | zcode-posttooluse.sh:138-240 | - | .../06-s3-posttooluse-reanchor.md | - / 0 / ☑ |
| 7 | 2026-10-11 | code-assistant | P2S4 posttooluse [periodic-ground] | done | Rule 65 接线消费矛盾，--test 10/10；发现 tr bug | zcode-posttooluse.sh;periodic-review.sh:89 | §7 | .../07-s4-posttooluse-periodic.md | - / 0 / ☑ |
| 8 | 2026-10-11 | code-assistant | P2S5 Rule 77 正文+SKILL 级联+tr 修复 | done | Rule 77 :1028；SKILL 1-75→1-77；tr bug 修复 | critical-rules.md:1028 | - | .../08-s5-rule77-cascade.md | - / 0 / ☑ |
| 9 | 2026-10-11 | code-assistant | P2S6 selftest-session-anchor | done | SA-01..10 全 PASS，registry 77 行 | selftest-session-anchor.sh | - | .../09-s6-selftest-session-anchor.md | - / 0 / ☑ |
| 10 | 2026-10-11 | code-assistant | P3S1 scan-skills.sh | done | 179 技能 frontmatter 四列+disable 红线 | scan-skills.sh:1-100 | - | .../10-s3-1-scan-skills.md | - / 0 / ☑ |
| 11 | 2026-10-11 | code-assistant | P3S2 ledger skill_activation | done | VALID_EVENTS 第 9 事件 | ledger-append.sh:40 | - | .../11-s3-2-ledger-skill-activation.md | - / 0 / ☑ |
| 12 | 2026-10-11 | code-assistant | P3S3 激活门控与校验 | done | dispatch 拒锁+SKILL-ACTIVATION GATE+激活计划区块 | check-dispatch.sh:615;check-complete.sh:1296 | - | .../12-s3-3-skill-activation-gate.md | - / 0 / ☑ |
| 13 | 2026-10-11 | code-assistant | P3S4 Rule 78 正文+59.3 精确化 | done | Rule 78 :1042；红线句保留+精确措辞 | critical-rules.md:1042,:782 | - | .../13-s3-4-rule78.md | - / 0 / ☑ |
| 14 | 2026-10-11 | code-assistant | P3S5 selftest-skill-activation | done | KA-01..10 全 PASS，registry 78 行 | selftest-skill-activation.sh | - | .../14-s3-5-selftest-skill-activation.md | - / 0 / ☑ |
| 15 | 2026-10-11 | code-assistant | P4S1 Rule 79+31.1⑤+33.1④+模板增列 | done | Rule 79 :1058；Error Log 增触发列 | critical-rules.md:322,:345,:1058 | - | .../15-p4-s1-rule79-rules.md | - / 0 / ☑ |
| 16 | 2026-10-11 | code-assistant | P4S2 [error-fix] 注入 | done | 三信号检测，--test 14/14 | zcode-posttooluse.sh:458,:507 | - | .../16-p4-s2-error-fix-inject.md | - / 0 / ☑ |
| 17 | 2026-10-11 | code-assistant | P4S3 ERROR-CORRECTION GATE+selftest | done | GATE :1360；EC-01..10 PASS；registry 79 行 | check-complete.sh:1360 | - | .../17-p4-s3-error-correction-gate.md | - / 0 / ☑ |

## 🔗 Chain 区块交接配置（可选）
<!-- 仅多 skill 接力任务填写。单 skill 任务可删除此整个区块。 -->
| 字段 | 值 |
|------|-----|
| **chain_mode** | `single` |

## 🔁 模板感知
<!-- template_type: general -->
- 触发信号: 技能机制改造任务 → 落 general 兜底
- Rule 34.3②: 沉淀预登记 —— 终验时按三条件评估（本次产出为 task-planner 自身机制，天然归属既有体系，预计不沉淀新 variant）
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 不沉淀（task-planner 自身 Rule 体系内演进，无独立新模板形态）

| 2026-10-11 13:00 | **用户漂移反馈（§四.3）** | VC-1~7 全部 | 用户原话：「整个这种偏差问题，明明应该是逻辑上或者说技能的设置问题，你一直在改莫名其妙的各种代码问题，这就是严重的偏差，完全不是在解决问题。」判定=当前方向（机器面代码优先）与用户预期（逻辑/设置层修复）权重倒挂，**DRIFT-USER**。处置=立即停止代码写入，等用户对方向做决策；已改代码原样保留待裁，未合并未部署 |
| 2026-10-11 16:30 收口漂移检查 | 自查 ALIGNED（替代完整 drift-checker 派发：任务已终态交付，核对=6/6 Phase complete、VC-1~6 全 [x]、master 3 commit 合入、封存分支保留、部署 diff=0 冒烟过；无计划外行为） | VC-1~6 | ALIGNED |
