# Findings & Decisions
<!-- 
  WHAT: Your knowledge base for the task. Stores everything you discover and decide.
  WHY: Context windows are limited. This file is your "external memory" - persistent and unlimited.
  WHEN: Update after ANY discovery, especially after 2 view/browser/search operations (2-Action Rule).
-->

## Requirements
<!-- 
  WHAT: What the user asked for, broken down into specific requirements.
  WHY: Keeps requirements visible so you don't forget what you're building.
  WHEN: Fill this in during Phase 1 (Requirements & Discovery).
  EXAMPLE:
    - Command-line interface
    - Add tasks
    - List all tasks
    - Delete tasks
    - Python implementation
-->
<!-- Captured from user request -->
- 用户原话（2026-09-05）："我发当前 skill的 findings.md 和 progress.md 没有得到有效的利用 只停留在模板 完全没有使用 比如 plans/task-plan-resume-v05 只有原始文件完全是没有使用 必须修改该skill 的相关条目 确保可以有效使用该文件"
- R-1 交付物 = task-planner skill 的条目修改（文本契约 + 支撑机制），效果标准 = findings/progress 执行中被真实使用，非"看起来有制度"
- R-2 范围限定 task-planner skill 本体（SKILL.md/critical-rules.md/scripts/templates/config）；部署端 8 位仅在合并后同步（D7 实体副本模型）
- R-3 原活跃计划 task-plan-resume-v05 让位暂停（其 task_plan.md D8 + progress 暂停检查点已落盘）

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!--
  WHAT: 对齐任务知识库 — 记录计划「必要知识储备」中各知识源的实际消费情况。
  WHEN: 消费一个知识源后立即登记;结论落点到对应段落。
-->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 
  WHAT: Key discoveries from web searches, documentation reading, or exploration.
  WHY: Multimodal content (images, browser results) doesn't persist. Write it down immediately.
  WHEN: After EVERY 2 view/browser/search operations, update this section (2-Action Rule).
  ⚠️ Rule 19.1: 子代理(Explore/web-search/doc-search/research-assistant 等)返回的结论写这里 —
     返回后紧邻一次 Edit,含结论摘要 + 证据路径(URL/file:line);禁止只留会话记忆。
  EXAMPLE:
    - Python's argparse module supports subcommands for clean CLI design
    - JSON module handles file persistence easily
    - Standard pattern: python script.py <command> [args]
-->
<!-- Key discoveries during exploration; subagent returns land here (Rule 19.1) -->

## Research Findings (2026-09-05 Phase 3 实施)
- **3c 完成（code-assistant,Handoff#1）**：config.json:82-87 新增 compass_escalate_after(integer,default 2);zcode-posttooluse.sh 升级为 state 9 字段（`<count> <epoch> <cd_left> <cd_findings> <cd_progress> <f_last> <p_last> <f_miss> <p_miss>`,旧 5 字段向后兼容补 0）,findings/progress 双链路加升级判定（mtime 早于上次提醒 → miss+1 → 达 esc_after 输出"🚨 升级警告…Rule 26.3…最高 PARTIAL"并重置计数）。主进程核验:git diff 仅 2 文件、jq 解析过、bash -n 过、L112-130 升级链路抽查逻辑正确。证据:zcode-posttooluse.sh:48-160 / config.json:82-87
- **3a 完成（主进程）**：templates/findings.md 107→50 行、templates/progress.md 132→62 行;段落锚名全保持（findings 6 段;progress Phase 段 Status/Started/Actions/Files/Test Results,Test Results 并入 Phase 段与 19.2 条款三件套对齐）;Started 字段注释标明=check-3file-gate.sh mtime 锚点
- **已知局限（记录不修）**：模板瘦身后,历史计划（旧模板生成）的注释续行不再被 stub 判定的模板行集合覆盖,若对历史计划重跑 check-complete 会把旧注释续行误算实质行（方向=变松）。历史计划已终结/暂停,影响面≈0;活跃计划不受影响（新文件用新模板）。写入 CHANGELOG 说明

## Research Findings (2026-09-05 立项侦察)
- **失效实证**（plans/task-plan-resume-v05）：findings.md 前 107 行纯模板未动，实质内容仅末尾 7 条启动期调研；启动回填后 42+ 分钟停更（PostToolUse hook [plan-compass] 亲自触发证实）；progress.md 前 132 行模板占位符原封，实际动作以自由格式追加在文件末尾——模板段落体系被整体绕过
- **同类现象普遍**：plans/ 下 9 个历史计划的 findings/progress 均呈"模板主体+末尾少量追加"形态（有效行 12-164 不等,含模板表头占位行）
- **R1 findings 无执行中硬门控**：Rule 19.2 回填门控只管 progress.md；19.5 终验 3-File Gate 只查"非 stub"（check-complete.sh L197-220：扣除模板行集合后实质行 ≥3 即通过）——启动时填一次即永久通过,之后停更无任何拦截
- **R2 hook 提醒无后果**：zcode-posttooluse.sh compass 实现（L95-113）= mtime 检测 → emit 提醒 → 写 state 文件进冷却 → 冷却结束再提醒;模型无视提醒零代价,无升级、无惩罚、无违规登记
- **R3 模板高摩擦**：templates/findings.md 114 行/progress.md 167 行,主体为 HTML 注释说明+EXAMPLE 占位;填充要理解 6 段结构,视觉上"这是模板"而非活文档;实际用法退化为末尾追加,5Q 恢复读到的仍是占位符
- **R4 子代理回填无绑定**：Handoff 登记表 verify_done 只绑"Read 实际产出"（22.5）,findings 回填不在勾选条件内——19.1"紧邻 Edit"纯靠自律
- **stub 检测机制**（利好）：check-complete.sh L198-202 动态读 templates/{findings,progress}.md 生成模板行集合——**模板瘦身自动适应,门控反而更敏锐**;无需改判定逻辑（Phase 4 回归用例证实）
- **knowledge reserve 消费**：SKILL.md 全文精读✅ / critical-rules.md Rule 19 段✅ / check-complete.sh 关键段✅ / posttooluse compass 段✅ —— 结论即本段落;待 Phase 1 补: userpromptsubmit 链路/init-session 复制逻辑/variant 覆盖/smoke.sh 用例

## Technical Decisions
<!-- 
  WHAT: Architecture and implementation choices you've made, with reasoning.
  WHY: You'll forget why you chose a technology or approach. This table preserves that knowledge.
  WHEN: Update whenever you make a significant technical choice.
  EXAMPLE:
    | Use JSON for storage | Simple, human-readable, built-in Python support |
    | argparse with subcommands | Clean CLI: python todo.py add "task" |
-->
<!-- Decisions made with rationale -->
| Decision | Rationale |
|----------|-----------|
| **M1** SKILL.md 执行循环第 4 步（L118-119）：19.2 门控升级为双条件——① progress.md Phase 段已回填 ② findings.md 本 Phase 期间有增量（mtime 晚于 Phase 开始锚点）；翻转 complete 前运行 `check-3file-gate.sh <plan-dir>`,exit 1 → 禁止翻转 | findings 执行中零拦截是失效核心;双条件把两文件都纳入 Phase 级硬门控 |
| **M2** critical-rules.md：19.2 重写（双条件+脚本+mtime 锚点判定+退化阈值）;19.1 追加 verify_done 绑定;22.5 追加"verify_done = Read 产出 ✓ + findings 回填 ✓"双条件与 findings 落点列 | 契约文本与机制一一对应,防止文本与脚本漂移 |
| **M3** 新建 scripts/check-3file-gate.sh（bash+stat+grep,~70 行,无 python 依赖）：① 定位 plan 目录,两文件缺失→exit 1 ② 锚点=progress.md 当前 in_progress Phase 段的 `**Started:**` 时间戳,缺失退化用 config stale 阈值 ③ findings/progress mtime 必须晚于锚点,违规打印文件名+回填指令→exit 1 | mtime 代理指标可执行性强;锚点字段模板已有（progress.md Phase 段 Started）;设计取向"宁可误报逼一次回填,不可漏报"写入脚本头注释 |
| **M4** 模板瘦身：templates/findings.md 114→≤60 行、templates/progress.md 167→≤80 行;段落锚名（Requirements/Research Findings/Technical Decisions/Issues Encountered/Resources/Visual;Phase 段 Status/Started/Actions/Files/Test Results）全部保持;每段注释压缩 ≤2 行,长 EXAMPLE 删除 | 降填充摩擦=提高真实使用率;锚名保持因产出落盘映射表按锚名路由（D3）;stub 检测动态读模板自动适应 |
| **M5** zcode-posttooluse.sh compass 分级：state 文件记录上次提醒时间戳;再次触发时若 mtime 仍早于上次提醒 → 升级文案（二次未响应=违反 Rule 19.7,按 Rule 26.3 处置:终验 outcome 最高 PARTIAL,要求写入 progress.md Error Log）;config.json 新增 compass_escalate_after(默认 2) | R2 根因=提醒无后果;升级机制让无视产生可判定代价,复用 Rule 26 既有惩罚通道 |
| **M6** SKILL.md C16 收紧为可验证条款（gate exit 0 证据）;L438 22.5 摘要加双条件;L298 Rule 19 摘要加执行中门控;templates/task_plan.md Handoff 登记表加"findings 落点"列 | 检查项从自查句改为机制证据;模板列与 22.5 绑定配套 |
| **M7** CHANGELOG.md 新增条目 | 仓惯例（v05 计划 D5 前例:v0.4 补记） |
| **D-详查** compass 仅 PostToolUse 链路;variant 仅路由 task_plan.md（findings/progress 恒用内置模板,改 2 个模板文件全局生效）;smoke.sh 无既有 3-File 用例(直接新增);stub 判定=非空+非`<!--`行+不在模板行集合,<3 行判 stub | Phase 1 详查结论,修改面据此收敛 |
| **D-T** Phase 4 测试设计：T1 门控脚本正反用例(tmp plan+touch 伪造 mtime)/T2 check-complete.sh stub 回归/T3 posttooluse 升级文案触发/T4 grep 四处一致性/T5 smoke.sh 追加全绿 | VC-1~VC-6 的可执行验证路径 |

## Issues Encountered
<!-- 
  WHAT: Problems you ran into and how you solved them.
  WHY: Similar to errors in task_plan.md, but focused on broader issues (not just code errors).
  WHEN: Document when you encounter blockers or unexpected challenges.
  EXAMPLE:
    | Empty file causes JSONDecodeError | Added explicit empty file check before json.load() |
-->
<!-- Errors and how they were resolved -->
| Issue | Resolution |
|-------|------------|
| check-3file-gate.sh 初版锚点提取跨段匹配:grep -A6 窗口撞到其他 Phase 标题行的日期,mtime 比较静默失真(用例 2 陈旧文件却 PASS) | 分步调试定位→改 awk 段内定位+Started 行过滤,七用例全绿 |
| 会话内 2 次 Edit 事故:以"## N 段标题"为 old_string 锚点插入新段,new_string 未保留原标题→标题被吞(progress.md 的 Test Results 标题、Phase 3 标题) | 均当场发现修复;**模式教训:以标题行做插入锚点时 new_string 必须含原标题**——正是本任务主题"回填破坏模板结构"的现身说法 |
| CHANGELOG 插入新条目时 old_string 消费了"### 新增"标题,旧条目错位到"### 变更"下 | grep 标题结构发现→补 Edit 恢复,grep 复验结构正确 |
|       |            |

## Resources
<!-- 
  WHAT: URLs, file paths, API references, documentation links you've found useful.
  WHY: Easy reference for later. Don't lose important links in context.
  WHEN: Add as you discover useful resources.
  EXAMPLE:
    - Python argparse docs: https://docs.python.org/3/library/argparse.html
    - Project structure: src/main.py, src/utils.py
-->
<!-- URLs, file paths, API references -->
-

## Visual/Browser Findings
<!-- 
  WHAT: Information you learned from viewing images, PDFs, or browser results.
  WHY: CRITICAL - Visual/multimodal content doesn't persist in context. Must be captured as text.
  WHEN: IMMEDIATELY after viewing images or browser results. Don't wait!
  EXAMPLE:
    - Screenshot shows login form has email and password fields
    - Browser shows API returns JSON with "status" and "data" keys
-->
<!-- CRITICAL: Update after every 2 view/browser operations -->
<!-- Multimodal content must be captured as text immediately -->
-

---
<!-- 
  REMINDER: The 2-Action Rule
  After every 2 view/browser/search operations, you MUST update this file.
  This prevents visual information from being lost when context resets.
-->
*Update this file after every 2 view/browser/search operations*
*This prevents visual information from being lost*
