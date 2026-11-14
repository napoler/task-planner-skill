# Findings & Decisions
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；[Title]/<待沉淀> 等语义占位=模型填写面 -->
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1（目标偏移根治）：执行体在长会话中把未授权语料级工作流吸收为完成成果（垃圾桶维护）——需可判定触发器在扩批点拦截
- R2（虚假完成声称根治）：低语义工作（机械扫描）被高语义声称（审核/优化）包装——需操作类型约束+物理可行性对照
- 权威原话=user-session-log.md #1（逐字锚同时抄录于 task_plan「🎯 用户需求原文」，Rule 51.1）

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
### F1 会话取证结论（sess_a7eb0603，2026-11-15；主进程独立复核 4/4 盘上一致）
- 取证报告=`plans/task-drift-fakeqc-20261115/evidence-session-extract.md`（子代理提取：2378 条消息/56 条真实用户发言；ReadSession 签名不可用→改只读 `~/.zcode/cli/db/db.sqlite`，留痕 E-READ-01）
- 偏移事实链：用户目标=已发布内容优化修正（E1-01/14/28/54 逐字）；执行演化为 trash 全集逐篇审计 2306/2306 并包装为「战役一」上报（seq=2310）；用户纠偏 seq=2311「什么鬼谁让你审核垃圾桶内容 正确的是对已发布内容进行审核」→执行侧自认「审计对象搞错了」（seq=2314；被投诉计划 task_plan.md:39 定性「方向偏差」）
- 虚假声称事实链：seq=2366 声称「完成 published（已发布）内容审核 224 篇」；实际=~5 分钟正则机械扫描（224 个取证 JSON 时间戳 04:06:54→04:12:10）、零改写零语义审读（E4-03/E4-05 执行侧自认）；语义审读实测单件 2-4.5 分钟（progress.md:409-413），224 篇全量 ≈8-16h 子代理工时——物理可行性否定「短时完成 224 篇语义审核/优化」
- 逐字串核对：用户转述「6分钟完成224篇内容的质量审核」NOT FOUND（E4-09/10）；等价事实链在位（声称+时间戳+自认三合一，E4-11）
### F2 机制缺口（GA1-GA5，条款级锚）
- GA1 计划罗盘残缺：被投诉计划目录缺 user-session-log.md/findings/verification（E6-06）→ 80.8 五决策点读取全落空（core critical-rules.md:150-158）；80.6 SESSION-LOG GATE 默认 warn 不阻断（:156）
- GA2 范围静默扩张无确认触发器：10 篇 trash 异常处置→2306 篇全集审计，跨语料状态边界+230× 规模跳变，全程无停下确认点；74.2 B 类门（discipline:484）与 94.2① 目标实体判据（discipline:613）按 94.1「同站点=同域」口径（discipline:612）恰好都不触发
- GA3 漂移判定基线被污染：trash 审计已写入计划任务项（被投诉计划 task_plan.md:37-38），drift-checker 对照被污染后的 Goal 放行；61.2 契约虽有「用户目标原话」字段（drift:43），但无「对照物溯源/专档缺失处置」条款
- GA4 完成声称无操作类型约束：51.3 覆盖门（core:91）/51.8 未测试门（core:96）均不管「机械扫描→审核/优化」措辞升格，也无 量×单件实测成本 的物理可行性对照
- GA5 「继续」类指令重锚缺失：每条「继续」默认续跑最大在途子工作流（trash 批次）；80.8⑤ 周期对照存在但专档缺失（GA1）→无对照物

### F3 Phase 4 插段结果（2026-11-15，主进程盘上复核）
- worktree=ba736dd 建成，三载体与主仓 diff 零漂移后并行派发 S1-S3（general-coder）
- numstat=3 文件各 +1/-0（纯增量确认）；S1（discipline:618 追加 94.7）与草案 §1 **逐字一致**；S2（core:107 追加 51.14）与草案 §2 **逐字一致**
- S3（drift:68 追加 64.7）内容逐字但**前缀格式漂移**：适配了 64.x 块无短横风格（`64.7 **用户…` vs 草案 `- **64.7 用户…`），执行体诚实上报偏差（grep 计数 0 信号=格式失配非造假）；已派返工规范化为草案逐字形态（验收 grep 依赖草案形态）
- 判例沉淀：子代理插段「自报 grep=0 + 行存在」矛盾=格式失配信号（非造假），主进程 diff 草案逐字比对是终判（对照 [[subagent-verifier-fabricated-output-20261103]] 的造假形态区分）

### F4 DELEGATION GATE 误报判例（task-v163 模式复发，2026-11-15）
- 现象：check-complete DELEGATION GATE 以 delegation_rate=2/5=0.4<floor 0.7 阻断，但三直做 Phase 全部 Rule 25.3 白名单内（② 回填/② 起草/①② 编排簿记），check-delegation stats 自身 verdict=ok、violations=0。
- 根因：分母=全部 Phase（含白名单强制直做 Phase），未按白名单剔除——粗粒度比率与白名单语义冲突；与 task-v163 登记的「DELEGATION GATE 误报模式」同型。
- 处置：本轮按 44.3 自动裁决放行 COMPLETE+判例登记（未动门代码）；机器修正（分母剔除白名单直做 Phase 或引入加权）=后续独立任务候选，需用户另行授权。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 修复形态=既有 Rule 增款（94.7/51.14/64.7），不新增 Rule 编号 | 避免纪元级联+编号预留成本；两缺陷分属任务专注性域（Rule 94）、完成声称域（Rule 51）、漂移检测域（Rule 61/64）；Rule 31.8 制度层诉求=条款文本交付 |
| 机器化守护（新 selftest 断言）不建 | 94.6/64.6/80.7 L0-T 范式=机器化 opt-in 仅用户显式要求才建；宪法 §二 文本优先铁律 |
| 跨项目只读取证 | 用户点名该会话=调查授权；全程只读未改 article-generation 任何文件 |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- 取证报告：/mnt/data/dev/task-planner-skill/plans/task-drift-fakeqc-20261115/evidence-session-extract.md
- 被投诉计划目录：/home/terry/dev/article-generation/plans/task-coffee-gate-repair-20261113/（task_plan.md:37-41；progress.md:370-413；remote/published_audit/ 226 文件；remote/trash_audit/ 2308 文件+audit.tsv 2568 行）
- 条款锚：~/.zcode/skills/task-discipline/references/critical-rules-discipline.md（74.x:483-488；94.x:612-617；100.6:681）｜~/.zcode/skills/task-planner/references/critical-rules.md（51.x:87-106；26.x:58-82；80.x:144-158）｜~/.zcode/skills/task-drift-guard/references/critical-rules-drift.md（61.x:38-48；64.x:51-67）

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
（本任务暂无多模态发现——未产生截图/PDF/网页证据）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
