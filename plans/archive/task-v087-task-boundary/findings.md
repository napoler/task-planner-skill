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

## 勘察结论（2026-09-21，Phase 1）

**用户原始需求**：task-planner 技能补一个「自动分析是否属于新任务；如是则开新 task_plan.md，避免不相干内容混在一起」。

**现行三分类（Rule 8 / SKILL.md L210-217）**：A 无影响（与当前计划无关→照常执行）/ B 扩展（新需求加范围→更新当前计划）/ C 矛盾（推翻已确认内容）。D 类缺失：「无关新任务」会被误判 A（照常执行，但执行落在旧计划上下文里=混入）或 B（扩旧计划范围=混入）。

**4 处插入点确认（worktree HEAD=c340219）**：
1. `references/critical-rules.md` L26-28：`### 8 新请求强制重新规划（三分类判定）` 段后、`### 9` 前可纯追加 `8.1`（纯追加避 v082 插入级联教训；Rule 编号 1-38 已有，8.1 为 Rule 8 族子条不占新号）。
2. `SKILL.md` L210-217 用户新指令表（加 D 行）+ L219-231 特判段（加「新增任务边界判定（Rule 8.1）」行）+ L188 C12 检查项（扩 A/B/C/D）+ L518 触发时机行（A/B/C→A/B/C/D 提法保持兼容）。
3. `scripts/zcode-userpromptsubmit.sh` L130 `[plan-note]` 文案一行扩写（加 D 类指引）。
4. `references/todo-sync.md` L46 S5 说明加 D 类分支（开新计划目录，旧计划 Todo 映射保留）。

**基线**：全量 selftest（25 脚本）= 430 PASS / 0 FAIL（worktree 亲跑循环求和实证，与 v086 账本记录一致）。

**新增 selftest-task-boundary.sh**：静态守护范式对齐 selftest-veto.sh（断言：8.1 条款在位且含 D 类语义 / 8 原文未改 / SKILL D 行 / C12 含 D / hook note 含 D / todo-sync D 分支）。预计 7-9 断言。

**部署拓扑**（memory 实证）：三位 = `~/.zcode/skills/task-planner`、`~/.claude/skills/task-planner`、`~/.config/opencode/skills/task-planner`；合并后用主仓副本 `bash skills/task-planner/scripts/smart-merge-back.sh <worktree> --deploy`，部署后主进程 `diff -r` 亲验三位（v077 根因修复后 sm-rc=0）。
