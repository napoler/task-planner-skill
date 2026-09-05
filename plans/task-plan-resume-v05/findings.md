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
-

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
-

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
|          |           |

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

## Research Findings (2026-09-05 任务启动调研)
- **记忆证伪**：「plan-resume v0.5 合并待立项」不成立——部署端 ~/.agents/skills/plan-resume 与仓内 skills/plan-resume 均为 v0.4 (2026-09-04)，7 文件 1272 行零漂移；v0.4 已由 commit dcfa55b 收编。v0.5 从未存在=本次要建的版本。证据：Explore agent 全文逐行比对 + .git refs/reflog 解析
- **现状契约**：plan-resume 默认 dry-run"只产出报告绝不替用户 resume/archive"(SKILL.md:8)；§6"等用户决策(不替用户动)"(L205-207)；Rule 24.5(critical-rules.md:149)"用户必须明确说续推 task-X 才会动 plan-X"。v0.4 §7 smart-resume 仅 cron 显式 --auto-push 授权可用，且只"选+标记"，单次最多 1 计划，已有 [circuit-break-by-cron] 熔断
- **选择算法现成**：score-plans.py 加权打分(out_degree 50%+git_hits 30%+失败反比 20%)+select-and-resume.sh head -1 选 Top1——自主模式可复用，缺的是 config 驱动授权与 skip_states 硬排除
- **顺带发现的漂移**：①Rule 24.3 (critical-rules.md:147) 混入 CHANGELOG 术语"phase_status_map 已在 [Unreleased] 段跟踪"=编辑事故句；②扫描顺序三处不一(SKILL.md:126"DRIFT CHECK 之前"/critical-rules.md:143/CHANGELOG:30"后")；③v0.4 无 CHANGELOG 条目；④plan-resume README 声称分发到 ~/.zcode/skills/ 但该路径实际不存在(仅 .agents 端)
- **session-catchup.ts** (267 行)：纯 stderr 信息输出+4 步 RECOMMENDED 建议，不选择不续推——属当前会话上下文恢复工具，与本任务正交，不改
- **部署端性质未定**：~/.agents/skills/plan-resume 软链或实体副本未能确证(Explore 无 Bash)——Phase 5 用 readlink 核实，实体则 sync-companion.sh 同步

## 插入任务发现: 部署软链→真实文件转换 (2026-09-05, D7)
- **部署清单实测**: 8 条目录级软链 = ~/.zcode/skills{task-planner,todo-skill,task-drift-guard} + ~/.claude/skills{task-planner,todo-skill,plan-resume,task-drift-guard} + ~/.agents/skills/plan-resume，全部指向 canonical skills/；canonical 内部零软链零硬链，cp -rL 安全。四技能体积 0.9MB 合计
- **verify.sh 两态判定缺口**: lib/verify.sh `stub_is_symlink_mode()` 只认「软链全量 / 实体薄壳<15KB」两态；实体副本模型（本次转换后）走薄壳分支，第 3/4 项检查会对全量副本（task-planner 772K）误报。三态适配属 repo 开发须走 worktree，未立项。证据: skills/task-planner/lib/verify.sh L35-98
- **哨兵重武装 bug（新）**: plan-created.cjs 清除 .plan-required 后（ls 确认删除），下一工具调用窗口内哨兵被未知源重建（birth 01:33:25）；attest-plan.sh 锁定计划也无法阻止 PreToolUse 拦截 plans/ 外写入。check-scope.sh/plan-created.cjs 只读不写哨兵，zcode-{userpromptsubmit,posttooluse}.sh 无 plan-required 写入逻辑——重武装源在上述脚本之外（疑 config.json 其他 hook 或平台行为）。影响: Write/Edit 工具对 plans/ 外路径全被误拦（本会话有效计划+attest 锁定仍被拦），memory 写入被迫改走 Bash heredoc。**对用户价值: task-planner hook 体系待排查项**
- **VC-7 兼容性**: 计划原文"部署端软链状态核实（实体副本则同步）"天然覆盖本次转换，Phase 5 措辞已更新为显式 cp 重新同步

## Technical Decisions (Phase 4 补充)
- **outside-repo 守卫死代码修复**(code-assistant agent_b2bdd15d 二次派发):原实现以 `$REPO_ROOT/plans/<tid>/task_plan.md` 重构路径致 `case` 前缀判断恒真;修复=按扫描顺序探测实际来源路径(plans/ → .zcode/plans/ → skills/*/plans/)并 `readlink -f` 物理解析后判断,符号链接指向仓外的候选可真实触发 `skip: outside-repo`;REPO_ROOT 归一改 `pwd -P` 同口径。证据:smoke v0.5-d 符号链接用例 5 断言锁定
- **smoke.sh 8 条陈旧断言证实改前即红**:git archive 导出 HEAD 版跑同脚本得完全相同 8 失败;根因 v0.4 重构移除 extract-meta 的 format=/task_completion_pct 输出、scan-plans 不扫 openspec/spec-kit tasks.md、--help 无 --include-archived;等量替换为当前真实行为断言。证据:子代理对照实验+主进程 39/39 重跑
- **Resources**: worktree commit 42c31b7;agent 编号 agent_5b70d1b3(脚本 v0.5)/agent_b2bdd15d(smoke+守卫)
