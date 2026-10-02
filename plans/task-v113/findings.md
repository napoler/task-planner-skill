# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
-

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
-

#### [sub:1-executor] 消解链普查
（task-v113 Phase 1 S1 普查结论，全文见 `plans/task-v113/subagent-state/1-executor.md`）

**第一部分 现行链拆解**：Rule 22.3 五档（critical-rules.md:158）=① 改派（类型不匹配）② 拆细（触 21.1b 上限，限 1 次，不改模型档位）③ 降档（实为模型升档 haiku→sonnet）④ 主进程接管（单文件 ≤300 行+25.3 白名单⑤）⑤ AskUserQuestion；retry_limit=2 达限必 AskUser。子条边界：22.3.1（:159 行首）provider 失败 Scaling（①-fb 零消耗改派，不计 retry）；22.3.2（:159 行内）provider 全灭→拆细到每片 ≤300 行逐片 ④ 接管、残余降级交付禁裸 BLOCKED；22.3.3（:160）位于 ④ 与 ⑤ 之间的技能族接管评估（comet/openspec/superpowers，CLI 探针前置）。Rule 41.1 消解链（:415）=① 重读三文件 ② 22.3 ①-④ 全试 ③ 最小探针（35.6）④ 问题拆细 ⑤ 替代路径检索（35.2 三关，仅本地接口面）；41.4（:418）升级前置清单=同 41.1 五步+「已尝试清单」必填，D6 硬停点不弱化。Rule 7 三击（:23-24 → reference.md:226-233）：1 次诊断修复/2 次换方法/3 次全局重想/3 次后升级；既有换道语义分布三处（21.4:149 子任务 ≥2 次禁同法、22.7:167 连续失败 ≥2 次换档重试、22.7.1:168 STOP 6 字段）——新换道义务必须引用化不重复定义。

**第二部分 引用面（grep 实测，13 文件含 22.3/41.1/五档）**：硬锚（selftest/verify 断言）=selftest-skill-collab.sh:44-48（T4 行号序 ^22.3.1<^22.3.3<^22.4 + T5 22.7 行文案）、selftest-fallback.sh:125/137（T10a/T11c hint 精确串「①改派(换类型)→②拆细→③降档→④主进程接管→22.3.3 技能族接管评估→⑤AskUser」、tier_order 6 项）、selftest-reflect-verify.sh:40（^33.4 含 Rule 22.3）、selftest-methodology.sh:160（夹具「按 22.3② 拆细重派」）、verify.sh:248（provider_fallback 断言文案）、subagent-fallback.sh:266/273/288（hint 串源头）；「41.1」字面仅 critical-rules.md:415 本体 + SKILL.md:278 摘要行；「五档」字面=SKILL.md:385、templates/task_plan.md:261、critical-rules.md:413、selftest-conclusion-discipline.sh:11/68（注释级，断言本体不含「五档」）。selftest-rescue-chain.sh 无 22.3 字面断言（check-rescue-chain.sh:5 注释「五机械档+22.3.3 评估档」为历史注释）。dispatch-examples.md:33 与 critical-rules.md:168（22.7.1 ②字段）同为「22.3 ①-④ 与 22.3.3 逐档」文案，需同步。

**第三部分 宪法落差**：AGENTS.md:127「遇到问题第一动作是上网查资料…穷尽 ≥3 种策略」+ §七 路由表（报错→搜网络/官方文档→Doc Search Agent）vs skill 22.3/41.1 全链无任何「查官方文档/网络现成方案」动作档（35.2 三关仅本地接口面通读，35.6 仅最小探针）——机制缺位实证「网络查资料兴趣低」，且与宪法「第一动作」优先级冲突。

**第四部分 修订方案（三件）**：
- 资料档草案「资料先行档」=新增 22.3.0（插入 :158 与 :159 之间）：触发=工具持续报错或同法/同档失败 ≥2 次；动作序=本地帮助面（--help 全文/man/官方文档/README，35.2① 适用）→ 网络现成方案（research-assistant/Doc Search Agent/web-search，GitHub issue/PR 优先）→ 评估借鉴后回入既有档位；与宪法 §七 衔接声明+与 35.2/35.6 分工声明；22.3.1/.2/.3 引用化「已评估资料档」不重述动作。
- 换道义务草案（22.3.0b 或 22.3 行尾指针）：同法失败 ≥2 次=Rule 7 第 2 击强制换道，评估顺序=现成方案（22.3.0）→ 子代理隔离（改派/Debugger/Explore 隔离上下文）→ 拆解逐个击破（22.3 ②/21.1）；连续 3 次失败=禁第 4 次同法+强制登记换道理由（rescue 列+[switch-path] Error Log 行）；Rule 7 本体不动，21.4:149/22.7:167/41.1:415/41.4:418 加指针。
- 插入位推荐=方案 A（22.3.0 前置独立行，五机械档 ①-⑤ 序号不变，「五档」字面加演进注）：selftest T4 只比 22.3.1/22.3.3/22.4 相对序，22.3.0 无既有断言引用→零硬锚冲突；资料档=LLM 行为面动作不进 subagent-fallback.sh tier_order（6 项机械串保持全绿）；方案 B 重排编号需 15+ 处 ①-⑤ 字面重映射+T10a 精确断言改写+历史计划 rescue 留痕语义漂移→否决。级联清单 14 项（critical-rules 7 处/SKILL.md 4 处/templates 1 处/dispatch-examples 1 处断言面新增 2-3 条静态锚；不动清单=subagent-fallback.sh/check-rescue-chain.sh/selftest-rescue-chain.sh/verify.sh:248/README:143/completion-gate:30/Rule 42-43 历史声明）——逐处 file:line 全文见 checkpoint `plans/task-v113/subagent-state/1-executor.md` 第四部分。

#### [sub:2-executor] 扩档级联
（task-v113 Phase 2 扩档级联执行结论，全文见 `plans/task-v113/subagent-state/2-executor.md`）

**落地（按 1-executor 方案 A，全行号内容锚定位，实测无偏移）**：critical-rules.md —— 21.4（:149）行尾加换道评估顺序指针（现成方案 22.3.0→子代理隔离→拆解逐个击破 22.3.0b）；22.3（:158）行尾加「任一档位连续失败 ≥2 次 → 先走 22.3.0 资料先行档评估换道（task-v113）」；:158 与 :159 之间插入 22.3.0 资料先行档全文（本地帮助面 --help 全文/man/官方文档 README→网络现成方案 research-assistant/Doc Search Agent/web-search，宪法 §七 衔接声明+35.2/35.6 分工声明，前置评估动作档不占机械档序号）+22.3.0b 换道义务（≥2 次强制换道、换道评估顺序 ①现成方案 ②子代理隔离 ③拆解逐个击破、连续 3 次失败禁第 4 次同法+强制登记 [switch-path] 换道理由）；22.7（:167）穷尽集合扩「①-④（含 22.3.0 评估）」；22.7.1（:168）②字段同步「含 22.3.0 评估记录」；41.1（:415）⑤ 扩「替代路径检索（Rule 22.3.0 资料先行档：官方文档/网络现成方案 + Rule 35.2 三关）」；41.4（:418）清单②⑤同步指针；413 五档字面加六档语义演进注。SKILL.md —— :385 五档标题行加 22.3.0 资料先行前置评估演进注（并入标题行控行数，表体 387-393 不动）；:278 Rule 41 摘要行「替代路径」扩「（含 22.3.0 官方文档/网络现成方案）」；:406 反模式行追加 22.3.0b 换道义务反模式（并入既有行）。templates/task_plan.md:261 WHY 注加「task-v113 后含 22.3.0 资料先行档」；references/dispatch-examples.md:33 已尝试档位清单同步 22.7.1 ②字段口径。

**断言面（项 14）**：selftest-self-resolution.sh 新增 SR-13（^22.3.0 行存在 + 资料先行/换道评估顺序/官方文档 关键词各 ≥1，零新 config 键维持 properties=40 由既有 SR-09 守护）；header SR-01..SR-12 更新为 SR-01..SR-13。

**偏差披露（2 处，均超 14 项清单边界、属基线修复）**：① 基线 f549958 上 selftest-self-resolution.sh SR-11 已 FAIL（clean HEAD 树实测复现：selftest-skill-split.sh label 已演进至 task-v112，宽容正则 task-v10[0-9] 不匹配）——修 SR-11 正则扩 `task-v1[0-1][0-9]`，断言语义不变（沿用 SR-11 既有宽容化先例注释）；② 方案 8 的 22.3.0 说明行原为表上独立行（+2 行）会突破 selftest-skill-split.sh T-主 硬锚「SKILL.md ≤444 行」（基线 444 行，加 2 行=446 即 FAIL）——把演进注并入 :385 标题行、反模式行并入 :406 既有行，净 0 行，T-主 恢复 PASS。零改动清单（subagent-fallback.sh hint 串/tier_order、selftest-skill-collab T4-T5、selftest-fallback T10a、selftest-rescue-chain、check-rescue-chain、verify.sh:248、README:143、completion-gate:30、Rule 42-43 历史声明）全部未触碰，实测保持全绿。

**验证**：4 个验收 selftest 全 PASS（fallback 31/31、rescue-chain 11/11、self-resolution 13/13 含新 SR-13、skill-collab 25/25）+ selftest-skill-split 41/41；grep -c "22\.3\.0" critical-rules.md = 9 ≥2；diff --stat 5 文件 = critical-rules.md/SKILL.md/dispatch-examples.md/selftest-self-resolution.sh/task_plan.md，与级联清单 14 项文件集一致。

#### [sub:3-executor] 回归验证
（task-v113 Phase 3 S1 全量回归执行结论，fresh 独立子代理；日志全文见 `plans/task-v113/subagent-state/logs/*.log`，checkpoint 见 `plans/task-v113/subagent-state/3-executor.md`）

**环境**：worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v113`（含 22.3.0 资料先行档 + 22.3.0b 换道义务落地），42 个 selftest-*.sh 逐个 `timeout 90 bash` 运行，42/42 rc=0，无超时、无 SKIP 吞失败（registry.tsv 非脚本未纳入运行，符合预期）。合计 666 PASS / 0 FAIL / 0 rc 非零。

**42 行逐项原文（脚本名 | rc | Total 行原文）**：
- selftest-active-plan.sh rc=0 | Total: 19 PASS=19 FAIL=0
- selftest-ask-default-timeout.sh rc=0 | Total: 9 PASS=9 FAIL=0
- selftest-batch-pilot.sh rc=0 | Total: 10 PASS=10 FAIL=0
- selftest-check-conflicts.sh rc=0 | Total: 7 PASS=7 FAIL=0
- selftest-check-drift.sh rc=0 | Total: 6 PASS=6 FAIL=0
- selftest-conclusion-discipline.sh rc=0 | Total: 24 PASS=24 FAIL=0
- selftest-context-hygiene.sh rc=0 | Total: 12 PASS=12 FAIL=0
- selftest-delegation.sh rc=0 | Total: 38    PASS=38  FAIL=0
- selftest-dispatch.sh rc=0 | Total: 31 PASS=31 FAIL=0
- selftest-error-loop.sh rc=0 | Total: 16 PASS=16 FAIL=0
- selftest-execution-stability.sh rc=0 | Total: 19  PASS=19  FAIL=0
- selftest-fallback.sh rc=0 | Total: 31  PASS=31  FAIL=0
- selftest-final-gate-hash.sh rc=0 | ==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====
- selftest-fine-grain-steps.sh rc=0 | Total: 11 PASS=11 FAIL=0
- selftest-interaction.sh rc=0 | Total: 11 PASS=11 FAIL=0
- selftest-iterative-optimizer.sh rc=0 | Total: 8 PASS=8 FAIL=0
- selftest-knowledge-brief.sh rc=0 | Total: 16  PASS=16  FAIL=0
- selftest-mechanism-profile.sh rc=0 | Total: 19 PASS=19 FAIL=0
- selftest-methodology.sh rc=0 | Total: 16 PASS=16 FAIL=0
- selftest-plan-dispatch.sh rc=0 | Total: 12 PASS=12 FAIL=0
- selftest-plan-tier.sh rc=0 | Total: 32 PASS=32 FAIL=0
- selftest-reflect-verify.sh rc=0 | Total: 12 PASS=12 FAIL=0
- selftest-registry.sh rc=0 | Total: 5 PASS=5 FAIL=0 (registry rows=42, actual selftest=42)
- selftest-reliability-institution.sh rc=0 | Total: 12 PASS=12 FAIL=0
- selftest-rescue-chain.sh rc=0 | Total: 11 PASS=11 FAIL=0
- selftest-review-library.sh rc=0 | Total: 15 PASS=15 FAIL=0
- selftest-rule23-conflict-scan.sh rc=0 | Total: 3 PASS=3 FAIL=0
- selftest-self-resolution.sh rc=0 | Total: 13 PASS=13 FAIL=0
- selftest-shared-tracker.sh rc=0 | Total: 11 PASS=11 FAIL=0
- selftest-skill-collab.sh rc=0 | Total: 25  PASS=25  FAIL=0
- selftest-skill-modify.sh rc=0 | Total: 9 PASS=9 FAIL=0 (SKIP=0)
- selftest-skill-split.sh rc=0 | Total: 41  PASS=41  FAIL=0
- selftest-smart-merge.sh rc=0 | Total: 17 PASS=17 FAIL=0
- selftest-sync-index.sh rc=0 | Total: 13 PASS=13 FAIL=0
- selftest-task-boundary.sh rc=0 | Total: 11 PASS=11 FAIL=0
- selftest-template-lifecycle.sh rc=0 | Total: 21 PASS=21 FAIL=0
- selftest-template-sense.sh rc=0 | Total: 8 PASS=8 FAIL=0
- selftest-tier-b.sh rc=0 | Total: 18 PASS=18 FAIL=0
- selftest-tool-selection.sh rc=0 | Total: 12 PASS=12 FAIL=0
- selftest-vc-gate.sh rc=0 | Total: 11 PASS=11 FAIL=0
- selftest-veto.sh rc=0 | Total: 13 PASS=13 FAIL=0
- selftest-workflow-orchestration.sh rc=0 | Total: 16 PASS=16 FAIL=0

**失败断言**：无（rc≠0 与 FAIL>0 均为 0，无失败根因条目）。

**验收锚专项核对（Phase 2 断言面）**：selftest-fallback 31/31（T10a hint 串级联后仍全序匹配）、selftest-rescue-chain 11/11、selftest-self-resolution 13/13（含新 SR-13：^22.3.0 行存在+资料先行/换道评估顺序/官方文档关键词各 ≥1）、selftest-skill-collab 25/25、selftest-skill-split 41/41（T-主 SKILL.md ≤444 行净 0 行控未被本次变更破坏）——全部 PASS。registry 登记一致性（rows=42, actual=42）PASS。

**负结果报告**：检查了 42/42 个 .sh 脚本的 rc、FAIL 计数与 Total 行；未发现任何失败断言；排除了 22.3.0/22.3.0b 扩档对既有 selftest 断言面（fallback/rescue-chain/self-resolution/skill-collab/skill-split 及全部 37 个非验收脚本）的回归风险；唯一非 Total 行格式的 final-gate-hash 已单独核对其末行 `结果: PASS=22 FAIL=0`，确认非异常。

#### [sub:4-executor] 推演与对齐
（task-v113 Phase 3 S2 语义推演自证 + alignment-review 对齐审查，fresh 独立子代理；全文见 `plans/task-v113/subagent-state/4-executor.md`。规范文件行号=worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v113` critical-rules.md 实测行号）

**一、推演自证（VC-3）**

案例一（code-runner-agent(mini) 连续 2 次 Provider rejected）：
- 触发判定（新链）：连续 2 次失败 = retry_limit 达限（22.3:158）→ 命中 22.3 行尾「任一档位连续失败 ≥2 次 → 先走 22.3.0 资料先行档评估换道（task-v113）」（:158）与 22.3.0 触发条件「工具持续报错或同一方法/档位连续失败（≥2 次）」（:159）。
- 旧链决策：22.3.1 ①-fb probe/next/bind 后，因「变体 agent 定义随会话启动固化——当前会话不可见」边界（:161），决策输出=④ 主进程接管（单文件 ≤300 行）或 ⑤ AskUser；链路中无任何「查文档/查网络」动作档。
- 新链推演（22.3.0 两步）：第一步本地帮助面——`subagent-fallback.sh` 完整接口面（实测 usage 在 :294、`-h|--help` 入口 :311）+ 22.3.1 登记的 `.task-planner-fallback-meta.json` 机制 → 确认通道健康状态与变体可见性边界；第二步网络现成方案——web-search「provider rejected/400 rejected」检索既有解法（平台状态页/GitHub issue/PR），评估「等通道恢复+新会话派发」是否优于「立即 ④ 接管」。
- 决策差异判定：存在实质差异——旧链决策输出=直接 ④ 接管/⑤；新链在 ④/22.3.3 之前插入资料先行评估，资料可改变「接管 vs 新会话派发」的选择（若检索证实通道短暂故障，最优动作=新会话起 `Agent(<type>-fb)` 而非 ④ 接管，保持子代理执行+主上下文清洁）。差异真实但边际强度=MEDIUM（22.3.1 已部分覆盖 provider 面，新增量=文档/网络信息驱动的选择依据）。

案例二（dispatch-guard 连续 3 次误拦：S 字样打包/knowledge-brief 未引用/步骤枚举超限）：
- 旧链实际行为：逐次改写 prompt 重试（试错式同法），「失败兜底链」旧文只有「≥2 次禁同法重试」但无换道评估序定义，行为退化为同类改写 n 次。
- 新链 22.3.0b 强制触发时点（:160）：第 2 次改写失败时（「同一方法/档位失败 ≥2 次 = Rule 7 三击第 2 击强制换道——禁止第 3 次同法」）；第 3 次改写失败时命中「连续 3 次失败 = 禁止第 4 次同法 + 强制登记 [switch-path] 换道理由」。
- 换道评估顺序推演：① 资料先行档现成方案——「官方文档等价物」=check-dispatch.sh 守卫源码 + dispatch-examples.md 方案集：S 字样误拦根因=`grep -oE 'S[0-9]+'` 字面匹配（check-dispatch.sh:286-297），且 :290 已有「prompt 引用落盘任务书(Rule 35.3 范式)→打包检测 SKIPPED」的官方豁免语义；brief 未引用=「计划含 knowledge-brief.md 但 prompt 未引用节锚点(brief/§)」告警（:304）；步骤枚举=「step_n > step_max_steps(4)」（:329）。三根因一次读源码全部拿到精确通过条件。② 子代理隔离不适用（失败面=prompt 文本非任务本身）；③ 拆解逐个击破=按精确触发条件改写/35.3 任务书落盘引用。
- 决策差异判定：存在实质差异且更优（HIGH）——旧链=O(n) 试错（每次 30s-1min+主上下文污染，且第 3 次仍同法）；新链=第 2 击即强制切换到「读守卫源码/示例方案集」权威对齐（O(1) 拿到 3 类检查点全部通过条件）+ [switch-path] 登记留痕。行为改变明确。

推演自证结论：合格——案例二 HIGH 实质决策差异，案例一 MEDIUM 实质决策差异，两案例新链均提供旧链没有的解决路径。

**二、alignment-review 对齐四要素（VC-4）**

1. **diff↔意图对应（抽 5 处）**：critical-rules.md:159（22.3.0 资料档=意图①）/:160（22.3.0b 换道=意图②）/:417（41.1⑤ 扩档=意图③ 消解链同步）；SKILL.md:385 五档标题行演进注+「五机械档 ①-⑤ 序号不变」（索引面同步）；selftest-self-resolution.sh SR-13 静态锚（断言面新增）——5/5 与 Goal 意图一一对应，无越界改动。
2. **语义联动**：「22.3.0」全库引用面 9 处（grep -c 实测）=21.4:149/22.3:158/22.3.0:159/22.3.0b:160/22.7:169「含 22.3.0 评估」/22.7.1:170「22.3.0 评估记录」/41.1:417/41.4:420 全链一致；「五档→六档」演进=41.1 本条前段:415「扩 22.3.0 资料先行档后为六档语义，五机械档 ①-⑤ 序号不变」+SKILL.md:385 同口径+templates/task_plan.md:261 WHY 注同步——演进口径三处一致。
3. **引用完整性**：新文本引用 Rule 号 35.2/35.6/19.1/Rule 7/21.1/21.4/22.3.1-22.3.3 全部实存（grep 命中）；`scripts/subagent-fallback.sh` 实存（usage:294）；卫星名 research-assistant/Doc Search Agent/web-search=宪法 §七 路由表外部实体（非本地文件，引用合法）。**P2 ×1**：selftest-conclusion-discipline.sh:11/68/69 CD-13 注释「五档兜底引用注」为陈旧措辞（六档后应更新），断言本体（SKILL.md:394「Rule 35.3 大输入落盘引用」串）不含「五档」不受影响——注释级，非阻断。
4. **守卫锚级联**：重跑 4 守卫锚全绿——selftest-fallback 31/31（T10a hint 全序串+tier_order 6 项含 22.3.3）、selftest-rescue-chain 11/11、selftest-self-resolution 13/13（SR-13 新锚 PASS：^22.3.0 行+资料先行/换道评估顺序/官方文档关键词）、selftest-skill-collab 25/25，均 rc=0 本会话复现。

对齐结论：APPROVED（P0/P1=0；P2 ×1=CD-13 注释措辞，建议下轮演进顺手更新，不阻断合并）。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
