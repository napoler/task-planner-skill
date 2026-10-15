# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
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
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->

## Research Findings
### S1 落点调研（Explore，2026-10-15）— 全文 subagent-state/1-explore.md
- Rule 44 现状：只管选择点呈现契约（默认项+超时），禁问面真正总纲=Rule 72（72.3 C级禁问/72.4 质检禁代审）+44.2 接缝（:170-171）
- 触点 10 处：有推荐约束 2 处（28.3/41.5）；裸上抛 8 处——含**3 个 variant 模板正是投诉模式**：image-type.md:73/81/88「选定 vs 重抽仍呈用户选」、video-fix-type.md:45「用户三选项裁决」、cost/billing 17.5、drift-guard 继续/缩批/熔断无推荐
- media SOP 缺位：critical-rules-media.md 无任何迭代取优条款；插入点=47.5（需顺延 47.4 措辞+selftest-media-dispatch 锚级联）或保守=86 本体在 discipline+media 尾加消费锚
- 索引级联 4 处：core critical-rules.md:182（,85→,86）；task-planner SKILL.md:17/:162+「Rules 1-84」三处陈旧（含 85 欠账）一并刷 1-86；discipline SKILL.md:24/:30-67/:15/:69/:80（计数 36→38）；media SKILL.md:32-34/:36-42/:46
- Rule 86 编号已自动预留（rule-reservations.jsonl 末行 reserved task-v177）
- 正先例：character-design-type.md:42「机器 QC 后主进程 Read 亲检择优」——Rule 86 的媒体侧样板
- 负结果：C 编号体系已退役（G 表），Rule 86 机制行禁引 C 号

## Rule 86 草稿（Phase 2 主进程稿，Phase 3 land）
**Rule 86 可测问题禁问与无推荐禁上抛**（task-discipline 域，用户 2026-10-15 裁决）
- 86.1 分类闸（总纲）：遇 2+ 选项/多方案分歧先过可测性三问——① 能否通过生成-比对-量化/脚本执行选出更优？② 候选差异是否可用可观察证据判别？③ 验证成本是否 < 上抛成本（用户决策+返工）？三问皆是=可测问题：模型必须自主验证并按数据决策，只交付结果+淘汰记录，禁任何形式上抛
- 86.2 负面清单：禁把「重抽 vs 换词」「参数档位」「候选排序」「有明确验证判据时的技术路径」包装成选项抛用户；违者按 Rule 26 类违规（自缩水+责任转移）处置
- 86.3 允许上抛四类（穷尽）：① 偏好与价值取舍（无优劣判据）② 不可逆/高破坏性动作 ③ 预算与配额追加 ④ 合规边界模糊
- 86.4 三件套：确需上抛必须带「我的推荐+依据+验证方式」，缺一=无效上抛；接收方可直接按推荐执行或显式改判
- 86.5 媒体链默认循环（→media 47.5）：生成不满意→模型自主迭代 N 轮（重抽/换词/调参取舍权在模型，每轮记命中判据+淘汰理由）→ 达验收线才交付；「换词 vs 重抽」二选一呈用户=违规（用户无抽卡分布数据）
- 86.6 零缺陷不免责：Constraint 27 类怕出错的正解=自主多测，禁以零缺陷为由上抛本可自验问题
- 86.7 机器面：selftest-rule86-autonomous-decision.sh（规则锚+反例断言）+media 47.5 消费锚
配套：media 47.5「生成不满意自主迭代环」（N 轮默认 3，每轮换一维，耗尽才可带数据上抛预算追加=③类）；variant 模板 photo:image-type.md:73/81/88 与 video-fix-type.md:45 改「主进程按判据自选定+留痕」范式

## 落地纪要（2026-10-16 收口）
- **S1 行号漂移解密**：explore 报的 image-type:73/81/88 在主仓文件对不上——那些行号属于前置会话 wt/task-v177 worktree 内的**未提交版本**；worktree 版 variant 三处修法质量优于主进程初版，已逐字收割进主仓（Phase 3R）。worktree 本体=被「文本优先」裁决取代的旧重型实施（含新建 selftest+registry），处置待用户授权。
- **锚级联实录**：索引 1-84→1-86 触发 23 个 selftest 红（HEAD 基线 stash 对照实证全为本次引发）；形态=`1-8[0134]` 字符类天花板（只认 80/81/83/84）×13 处+字面 `Rules 1-84` 提取式×2+AD-12 跨脚本钉×4+P-05 钉值；修法=类放宽 `8[0-9]`（8x 纪元全覆盖）+提取式动态化+负样本随迁——这是用户「无限升级」投诉的机制本体，38.7 L0-T 档「宽容锚」约定即为此立。
- 38.7 双副本修订后文本一致性：discipline 与 template-kit 两份 L0-T 段逐字同（VC-2 过）。
