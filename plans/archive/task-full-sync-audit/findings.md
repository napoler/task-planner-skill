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

## 体检发现（Phase 1 行为层,主进程核查 2026-09-04）
### F1 verify.sh 未跟上软链模型（已修,worktree）
- 实跑 5 fail:薄壳<15KB 检查、硬编码路径检查、zcode hooks frontmatter 检查——均为 stub 模型逻辑,不适用软链部署
- 修法:stub_is_symlink_mode 判定,软链位改为校验"指向 canonical+经链可读";zcode hooks 改查 ~/.zcode/cli/config.json(实证机制,frontmatter 从未承载);opencode/cursor 保持 frontmatter 检查
- 修后模拟合并形态实跑:18 pass / 0 fail
### F2 "硬编码"两处均合法
- zcode-posttooluse.sh:39、detect-tools.sh:18-19 的 $HOME/.zcode|claude 路径是 env 覆盖+回退默认值,软链模型下正确,不改
### F3 opencode 部署架构裁决（重要）
- OpenCode hooks 机制 = SKILL.md frontmatter(薄壳内含 5 hooks,指向仓内脚本);canonical 全量 frontmatter 无 hooks 块 → **opencode 不能换全量软链,会断 hooks**
- detect-tools 认的 opencode 位 = ~/.opencode/skills/task-planner(薄壳 3107B,健康);~/.config/opencode/skills/task-planner 是另一处陈旧实体 clone(08-29,130 项差异,含 .git/.backup)——两者关系待查(哪个是 opencode 实际读取位)
- 正确同步方式 = 薄壳再生成(install_stub_for_tool),非软链
### F4 check-doc-sync.sh/check-complete.sh 均正常(exit 0/2)
### F5 20 个脚本 bash -n 全过
