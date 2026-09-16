# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户指令（2026-09-16 原话要点）：①「提示词文件过大」类问题的正确解法=把提示词落盘成文件、使用时读取即可，执行者却不懂 → 必须机器化为规则；②「无法查看单个计划任务内容」是荒谬结论——接口有创建/更新/列表/删除，查看必然存在，执行者没读完整 API 文档就断言不可能并以此结束任务 → 禁止；③ 总要求：主动解决这类问题，禁止把此类愚蠢结论当作任务结论收场。
- 交付形态：task-planner skill 新增 Rule 35 执行结论纪律（能力否定三关 + 大输入落盘引用补救）+ 机器提示与 selftest 守护。

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **Explore 考古（01-explore，2026-09-16）**：Rule 35 插入点=critical-rules.md L290 后（Rule 34 段止于此，全文 290 行）；无既有「能力否定查证」类条款，不重复立法。SKILL.md 535 行、净增预算 ≤5（selftest-knowledge-brief.sh:38 断言 ≤540）；需同步点=SKILL L9/L277/L325 三处 "Rules 1-34" + L196 后插 C23 + L301 后插 Rule 35 列表行 + L409 后插兜底注行（合计净增 3 行→538）。check-dispatch.sh L258 prompt 超限提示行是落盘补救指引挂点。subagent_dispatch.md L92 现行超限解法只有「拆细」无「落盘」表述。全量 selftest=19 脚本逐 Total 求和，基线 313/0。防回归级联：改 "Rules 1-34" 前 grep scripts/ 三处 selftest 锚一次修齐。完整锚点表=plans/task-v076-conclusion-discipline/subagent-state/01-explore.md。
- **plan-writer 产出（02-plan-writer，2026-09-16）**：task_plan.md（5 Phase/S-unit 9 行/VC-1..5）+ knowledge-brief.md（§1-§5，§2 12 条+§3 15 条全部本仓实核锚）。实核纠偏 2 处：① CHANGELOG.md 实际在仓根（skills/task-planner/ 下不存在）；② SKILL.md L9 写法是「Critical Rules 全集 1-34」而非「Rules 1-34」，纯 grep 'Rules 1-' 会漏 L9——S4 同步时需三写法分别处理（L9 全集 1-34 / L277 (Rules 1-34) / L325 Critical Rules 1-34）。
- **attest 拒锁根因（2026-09-16）**：check-plan-dispatch.sh L143 数据行正则 `^\|\s*S([0-9]+)\s*\|` 只认纯数字 S-unit ID；plan-writer 的 S2a/S2b 命名不被识别 → P2/P3（executor 派发型）被判"缺数据行"。已全表改名 S1-S10（全局唯一纯数字）并同步 checkbox/Handoff/Decisions 引用。经验：S-unit ID 契约=纯数字，后续应沉淀进模板注释（progress Error Log 已登记，P3 顺带落点）。
- **P1 基线（03-code-runner-baseline，2026-09-16）**：worktree a182aed 就绪；19 脚本全 rc=0。子代理自报总数 253 = 算术错（其表格逐行求和实为 313）；主进程逐 Total 行求和 = **313 PASS/0 FAIL**，与 v075 交付基线一致 → 基线成立。再次实证「总数只认主进程求和」条款（VC-4 口径）必要性。逐行数据=subagent-state/03-code-runner-baseline.md。
- **P2-S3 完成（04-executor-s3，2026-09-16，主进程已 Read 复核）**：critical-rules.md L292 新增 `### 35 执行结论纪律` + L294-299 六子条逐字在位（grep 7 锚全中）；L127 22.4 行末追加「超限补救=Rule 35.3 大输入落盘引用…禁止失败收场」；diff 仅该文件 +10/-1（末行重写接续），文件 299 行（计划 ≈310 为主进程排版误估，内容逐字合规）。S6 CD 断言可用锚：L292 `### 35 `、`^35\.[1-6] `、L127 `Rule 35.3`。
- **P2-S4 完成（05-executor-s4，2026-09-16，主进程已 Read 复核）**：SKILL.md 538 行（净增恰 3：C23=L197、Rule 35 列表行=L303、兜底注=L412）；三处 1-34→1-35（L9 frontmatter 引用清单项/L278/L327）零残留；notepad 被否决方案段 L19-20 两条 veto 带用户原话出处。过程缺陷（插入多一空行 539）已被执行者当场自修。锚更新：SKILL.md 现 538 行 → S6 行数断言若锚 ≤540 仍过；'1-34' 全消失可作为 CD 断言（`grep -c '1-34'`=0）。
- **P2-S5 完成（06-executor-s5，2026-09-16，主进程已 Read 复核）**：subagent_dispatch.md L93 落盘补救行（Rule 35.3 指引）；check-dispatch.sh L259 新增补救 echo，L258 原行一字未动；bash -n 通过；selftest-dispatch 22/22 PASS。**P2 整体**：worktree 提交 ee606b7（4 文件 +18/-4，porcelain 干净）。CD 断言可用锚补充：dispatch 脚本 `补救(Rule 35.3)`、模板行 `超限补救(Rule 35.3)`。
- **P3 完成（07/08-executor，2026-09-16，主进程已复跑复核）**：S6 新建 selftest-conclusion-discipline.sh（CD-01..17 全过，双 cwd 验证；头注释沉淀「S-unit ID=纯数字」契约=attest 拒锁教训的 Prevention 兑现）；S7 四脚本锚点一次修齐（veto VT-10 恢复 13/13；KB 行数上限 540→545）。主进程复跑 5 脚本全 FAIL=0 + grep 全扫无第 5 处残留。worktree 提交 e41be0e（5 文件 +71/-7）。**deferred 新登记**：README.md:67 与 references/batch-quality-gate.md:130 的 `Rules 1-27` 滞后描述（早于本任务存在，非锚断言，范围禁改 README → 留后续 housekeeping）。

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
