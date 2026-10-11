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
### 执行期关键结论（2026-10-10）
- F5 实弹=D4 修复的直接验收：smart-merge-back --deploy 输出 [DEPLOY] OK: 全部部署位 post-verify 零差异 + OK: 全部部署位 IDENTICAL，exit 0；三 slot 与仓内 diff -q IDENTICAL。04:4x 的删后写中断窗由 staging+swap+post-verify 三段化闭合。
- F1 两轮 CR 才收敛：初版 Status.*complete 误清在途计划（BLOCKER）→ 反向判据又撞模板固定行 pending → in_progress → complete（B1）→ 终版=锚定真实状态行两子句（has_complete 且 no_active，:184-185）。教训：状态判定必须锚定真实状态行，模板行不是状态。
- F3 guard 与 init 同语义：.session-owner 双形态（sess 前缀/裸 uuid）匹配；claimant in_progress→不写该键+WARN；--force 覆盖。
- D4 事故事实（04:45-04:49）：~/.claude slot 04:45:38 写入、~/.zcode slot 04:49:07 被删后中断→技能全局停摆；主进程从仓内源原子恢复（diff 0）——已作为 F5 存在理由与回归项固化。
- NIT 登记：中文「- **状态:** complete」标签计划（task-v146）不命中 has_complete（非回归）；旧位置参数 set 模式 scope 外不改。
