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
