# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户指令（2026-09-17）：「逐个分析解决发现的问题」——对象=v076 交付报告登记的 4 项：①smart-merge-back 部署对账假 IDENTICAL（根因待修）②skills/task-planner/README.md:67 与 batch-quality-gate.md:130 滞后 `Rules 1-27` ③plan-writer 契约缺 S-unit ID=纯数字 ④子代理自报汇总总数算术错（基线 253/回归 313，真值 313/330）。逐个根因分析后修复+守护+回归+部署 push。

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **①假 IDENTICAL 根因（主进程一手 Read，2026-09-17）**：smart-merge-back.sh L348 `SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"`（脚本运行处）；L498 重部署 cp 与 L524 对账 diff 均以 SKILL_ROOT 为源/基准。从 ~/.zcode 部署位运行时：.zcode 位=SKILL_ROOT 本身被自保护拒绝；.claude/.opencode 位从陈旧 .zcode 拷贝重部署、再与同一陈旧源 diff → 假 IDENTICAL。v076 当时的 sm-rc=0 是被管道 tail 吞掉的假象（脚本实际 exit 6）。
- **Explore 考古（01-explore-v077，2026-09-17）**：MAIN_REPO 推导=L195-218（可靠）；ALREADY_MERGED 分支也执行 --deploy（L305-308/L345）；SKILL_ROOT 部署路径仅 L498/L524 两处；selftest-smart-merge 418 行 SM-01..13，fixture mk_fixture L63-85，⚠️SM-06 L209 自测侧 SKILL_ROOT 是独立定义（fixture 预置源）；`Rules 1-27` 活跃命中仅 skills/task-planner/README.md:67 + batch-quality-gate.md:130（根目录只有 README_zh.md）；plan-writer.md 269 行契约表 L106-116（S-unit 行 L111/knowledge_brief 样板 L116）；task_plan 模板 S-unit 注释块 L182-187（现有 ①②③，④ 空位）；subagent_dispatch §7=L51-73（acceptance 行 L54，8 字段无 notes）；critical-rules 22.4b=L129（acceptance 锚后行内追加）；CD selftest 变量区 L21-26、CD-17=L60-61、头注释 L4-15/L17 计数需同步；IDENTICAL 语义文档点=脚本 L41/L81/L525/L535/L538+selftest SM-06 L198/L219-220，无外部文档。完整锚点表+设计裁决=subagent-state/01-explore-v077.md。
- **plan-writer 空响应事故与恢复（02-plan-writer，2026-09-17）**：首派返回空轮次；Rule 22.8 落盘核查发现 task_plan.md 已完整写出（主进程 Read 复核通过：VC-1..5/FMEA 含 RPN120 兜底/Decisions ①-⑦/纯数字 S-unit 齐备），knowledge-brief 与检查点缺失→主进程白名单②补写（依 01-explore 实核锚）。未重派。
- **P1 基线（p1-baseline，2026-09-17）**：worktree 8d62d3b（当前 master HEAD）就绪；20 脚本全 rc=0；主进程 awk 求和 = **330 PASS/0 FAIL**（与 v076 P4 定数一致）。逐行=可知识 brief §5 求和口径第一次在子代理侧正确引用（本轮子代理自报 330 恰好正确，但仍以主进程 awk 为准）。
- **P2-S3 完成（p2-s3，2026-09-17，主进程已复核）**：smart-merge-back.sh 部署源/对账基准换 DEPLOY_SRC="$MAIN_REPO/skills/task-planner"（grep 10 处；cp L528/diff L555 换源；fail-closed 判定置于 DRIFT 初始化后防吞标志；自位 REJECTED 消息加指引；头尾注释同步）。执行者自纠 2 处回归（skip 位置吃掉 REJECTED 诊断→移 validate_slot 后；初版判定吞 DRIFT→上移）。主进程复核：bash -n 过、守卫 SKILL_ROOT 保留、selftest-smart-merge 13/14（唯一 FAIL=SM-06 fixture 类，属 S4 范围）、手工冒烟三条全过（真源部署/源缺失 fail-closed rc=6/自位 REJECTED 带指引）。新行号锚：cp=L528、diff=L555、fail-closed=L367-371、推导=L354-357。
- **P2-S4..S7 完成（2026-09-17，主进程逐一复核）**：S4=selftest-smart-merge fixture 建主仓 skills/task-planner/SKILL_MARKER(v077-canonical)+SM-06 预置源改指主仓+SM-14 陈旧副本回归钉子（15/15 PASS，slotB 终态=canonical 非 stale）；S5=README:67/batch-gate:130 → Rules 1-35（全扫 0 残留）；S6=plan-writer.md L117 s_unit_id 契约行+task_plan 模板 L187 ④ 注释（执行者合理偏离：正则管道符改散文防破表，已披露）；S7=subagent_dispatch L55（§7 代码块内 acceptance 行后）+critical-rules L129 行内禁自报汇总子句（22.4b 保持单行）。P2 worktree 提交 496b8b0（8 文件 +101/-24）。经验：派发守卫把契约条文中的示例 ID（S2a 等）计为打包→任务书落盘引用（35.3 范式第二次实战）。

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
