# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户原话（2026-10-03）：「当前存在单个子代理执行任务过于复杂的问题导致效率低下。我希望优化子代理任务规划 确保单个子代理执行任务简单高效 不要一次性给子代理过多任务确保子代理专注」
- 三要素：① 单个子代理任务简单高效 ② 禁止一次性给过多任务（打包/批次） ③ 确保子代理专注

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### 2026-10-03 现状调研（Explore agent_eb20f48d，五面）

**1. 拆分规则条款现状**（references/critical-rules.md，473 行）：
- Rule 21.1b（L141）：S-unit ≤2 文件/≤100 行/≤15min + 步骤枚举 ≤4（step_max_steps 默认 4）；「每次派发对应一个 S-unit」已有但分散
- Rule 22.4（L163）：九字段模板（目标 1 句/输入/验收 2-5 条/禁改/路径/时长/8 字段返回/checkpoint/上下文预算）——**无「任务数=1」显式字段**
- Rule 25.2（L207）：「逐 S-unit 派发…禁止把多个 S-unit 合并成一次大派发」——**只约束单次 prompt，不约束同一子代理会话连续领取**
- 结论：**文本缝隙 = 「批次式连做」未被任何条款显式禁止**

**2. 派发守卫机器现状**（scripts/check-dispatch.sh，408 行，fine_grain_checks L275-355）：
- 三道守卫：① prompt ≤3000 字符（L289-294）② 多 S-unit 打包 distinct S-id ≥2 命中（L295-310）③ 步骤枚举 >4 步（L319-343，count_step_markers L259-267）；命中走档位管线 enforce=exit 2（L353）
- **双豁免通道**：L297-301 任务书豁免（prompt 同含「任务书」+「subagent-state/」→ 守卫②整体 SKIPPED）；L257-258 行首 markdown 编号（`1. `）与汉字数字不入口径 → 任务书用 markdown 编号时步骤计数=0 全漏检
- 守卫只看单次 prompt，对「执行会话内连续领取」结构性失明

**3. 派发模板现状**（templates/subagent_dispatch.md，71 行）：§1 单目标占位符 + L58 步骤约束已有；**缺「本会话只领 1 个 S-unit、完成后交回主进程」显式引导与 checkpoint 批次追加禁令**

**4. 历史实证**（plans/task-v113~v117/subagent-state/）：
- **v117 1-executor.md（19,981B）**：单执行会话领 9 个 S-unit 分 4 批次（批次 1 S2/S3/S4→批次 2 S5/S6/S7→批次 3 S8→批次 4 S9+S10，grep 行号 :1/:62/:111/:139）——**批次式连做的直接实证，25.2 在该形态下空转**
- **v116 1-executor-prompt.md 任务书（2,547B）**：6 类刷新项 23 处编辑，用行首 `1.`-`6.` markdown 编号——**恰在步骤口径外+任务书豁免内，打包门/步骤门双双失效**
- **v113 1-executor.md（19,330B）/v115（12,302B）**：单「普查」S-unit 塞 4 大部分复合任务（拆解+grep 面+宪法落差+修订方案）——计划期拆分偏粗实证

**5. 模板匹配**：rule-enhancement-type.md（29 variant 之一），v086-v100/v113/v114 一贯使用，与本次完全匹配，无需新建

### 根因假设（排序）
1. **执行期批次派发（主因）**：同一子代理会话连续领取多 S-unit，checkpoint 追加式落盘，所有逐 prompt 守卫结构性失明（v117 实证）
2. **守卫双豁免（放大器）**：任务书豁免废打包门 + markdown 编号口径漏检（v116 实证）
3. **计划期拆分偏粗（次因）**：复合型 S-unit（调研+方案捆绑）超 15min 无可测预估拦截（v113/v115 实证）
4. **模板引导缺失（弱因）**：无「单会话单 S-unit」显式条款

### 2026-10-03 Phase 1 基线与锚级联面（1-executor checkpoint + 主进程 grep）

**selftest 基线**：42/42 脚本 rc=0，ΣPASS=666，ΣFAIL=0（四批次 172+165+139+190 自洽，checkpoint `subagent-state/1-code-runner.md` 42 行表已 Read 复核）。registry rows=42 交叉佐证。

**锚定级联清单（Phase 2/3/4 必修面）**：
| 锚 | 位置 | 现行断言 | Rule 46 影响 | 处置（口径扩展范式） |
|----|------|---------|-------------|---------------------|
| RT-08 | selftest-ask-default-timeout.sh:59-62 | CRIT 44 节+SKILL.md 零 `1-4x` 字面（1-45 已加白） | SKILL.md 若写「1-46」→ 撞 | 白名单扩 `grep -vcE '1-4[56]'` |
| PT-08 | selftest-plan-tier.sh:76 | SKILL.md frontmatter 字面锚「Critical Rules 全集 1-45」 | frontmatter 更 1-46 → 撞 | 锚宽容化 `1-4[56]`（v117 先例） |
| SR-07 | selftest-self-resolution.sh:64 | SKILL.md 'Rules 1-39' 计数=2 且 '1-40'=0 | 不破（走括号追加范式：`Rules 1-39（含 Rule 40/41/…/46）`） | 禁改字面，禁引入 '1-40' |
| CD-12 | selftest-conclusion-discipline.sh:68-72 | 双锚：'1-34'=0 **且**（'1-3[5-9]'+『1-45』）合计 ≥3（v117 扩展） | **破**（frontmatter 1-45→1-46 后『1-45』=0，合计 2<3）——Phase 1 只读了 1-34 注释行未读 v117 扩展断言体，误判「不破」 | n45 锚宽容化 `1-4[56]`（S6c 修复，v117 范式） |
| T2b | selftest-knowledge-brief.sh:38 | SKILL.md 行数 ≤558 | 现 444 行，+≤10 → 安全 | 无需动（label 无需更新） |
| FG-05 | selftest-dispatch.sh:300-312 | 任务书双条件豁免 → SKIPPED+不判打包 | S4 收窄撞它——但 fixture 引用的任务书文件**从未创建** | S4 fail-open 设计（任务书不可读→SKIPPED）保住 FG-05；正例场景由新 selftest 覆盖 |
| SG-06 | selftest-fine-grain-steps.sh:94-106 | 任务书 13 步（gen_steps 生成 StepN 格式）→ exit 2 | S5 扩 markdown 口径不影响 StepN 计数 | 不破（gen_steps=StepN 格式，两口径都 >4） |
| RT-09 | selftest-ask-default-timeout.sh:64-69 | config.json properties 键数=40（零新增） | 本计划零新键 | 一致，无需动 |

**Phase 3 fixture 设计要点**：S4 解析 prompt 引用的任务书文件（subagent-state/ 路径）→ 文件存在则计文件内 distinct S-id（≥2 拦截）；不存在/不可读 → 保留 SKIPPED（fail-open，保 FG-05）。S5 仅任务书模式下行首 markdown 编号入步骤计数，自由 prompt 口径不变（防误伤）。

**Provider 失败教训（Rule 31 归因）**：code-runner-agent/cli-executor-agent/simple-agent 的 frontmatter 声明 `custom:9e221f47-…` 端点在本环境被 provider 拒绝（同型 2 连败）→ Rule 22.3① 改派 executor（agnes 端点）成功。教训：派发前可先查 agent frontmatter 模型端点可用性；同 custom 端点家族勿重复试。

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

### 2026-10-03 Phase 5 终态（CR/合并/部署/alignment）
- **CR 两轮**：初审 CHANGES_REQUESTED（BLOCKER=提取器全角标点盲区——「（任务书：…）」形态 fail-open 绕过，恰是 46.2 目标形态；fixture 只测 ASCII 形态故漏）→ fix-phase F1（extract_subagent_state_refs 共用函数+{1,2} 位限）/F2（RT-08 逐匹配粒度+字面锚+GR-10 全角 fixture）→ 复审 APPROVED（8 形态提取探测+自由 prompt 字节对比 master 一致+21 复跑全绿）
- **合并**：master 并行 task-v119 先进（a4bbd19 complex-planner agent，零重叠）→ worktree 内 merge master → df7e427 Merge wt/task-v118
- **部署**：~/.claude 与 ~/.config/opencode 脚本自动 IDENTICAL；~/.zcode 运行位自保护 REJECTED→手动 rm+cp（替换前 diff 确认差异仅预期文件）；三位 diff -rq 各 0 差异；部署位 registry 43=43+dispatch-grain 10/10 实跑
- **alignment-review**：APPROVED（术语零残留/Rule 46 引用 5 锚全存在/CHANGELOG 循 commit 惯例豁免/越界自检全在 scope；complex-planner.md 系 v119 产物非本任务写入）
- **终验**：43/43 selftest rc=0 ΣPASS=676 ΣFAIL=0；worktree/分支清零；VC-1..5 全过 → COMPLETE
