# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1 [目标] 机械占位符（模板ID/日期/路径）不再依赖模型自主识别修正 → 产物即开即用
- R2 [手段] 脚本阶段变量替换/模板引擎式渲染（init-session.sh 渲染层）
- R3 [手段] 变量传参：脚本吃参数（task-id/任务名/日期/路径）直接产出适配产物
- R4 [目标] 消除后续无谓路径检索（产物内路径已展开为真实值）
- R5 [目标] 确定性收益：脚本传参比模型处理更稳定/准确/省时

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **[2026-10-24 Phase 3 五单元执行结果]**（检查点 subagent-state/06-10）：
  - S6 task_plan.md：+1 注释+14 处替换（ROOT×9/标题×1/task-id×5）；语义占位全保留
  - S7 user-session-log+notepad-learnings：+2 注释+4 处替换；#N/YYYY-MM-DD 示例逐字保留（计数 +1 偏差=新注释行自身含字样，内容级 diff IDENTICAL）
  - S8 progress+findings：+4/-1；[DATE]/[DATETIME] 各 1 处；findings 无机械占位仅加注释
  - S9 verification+knowledge-brief：+2 替换 ROOT×2+task-id×1；{Name}/{evidence}/<plan-dir> 语义面保留
  - S10 项目级 knowledge-brief：+2/-1，{task-id}×1+注释；与内建版 §1-6 逐行一致仅注释文字差异
- **[2026-10-24 跨单元冲突判例（重要教训）]**：主进程派发契约要求各模板加注释行含字面 `{{VAR}}` 示例，与 S4 残留校验正则 `\{\{[A-Z_][A-Z_0-9]*\}\}` 冲突 → init fail-closed exit 1，7 模板全中招（三个子代理独立发现上报）。**裁决=B 方案**：残留扫描跳过 HTML 注释区间（awk /<!--/,/-->/），非注释行严格度不放松。教训：**派发契约中的文档示例文本要与机器校验正则互斥设计**（示例词应选不匹配校验形态的写法，或校验器显式声明文档豁免边界）
- **[2026-10-24 S1 变量契约定稿]（三清单，执行期唯一甄别依据）**：
  **① {{VAR}} 变量表（渲染层主形态，核心 7+项目级模板使用）**：
  | 变量 | 来源（脚本内确定性可得） | 说明 |
  |------|------|------|
  | {{TASK_ID}} | 计划目录名（`basename "$PWD"`，init L56 守卫已保证在 plans/<task-id>/ 内） | 如 task-tplrender-20261024 |
  | {{TASK_NAME}} | `$1` 任务名参数（缺省回落 TASK_ID） | 人类可读名，替代 'project' 兜底 |
  | {{DATE}} | `date +%Y-%m-%d`（复用既有 L479 $DATE，激活其 0 使用状态） | 创建日期 |
  | {{DATETIME}} | `date '+%Y-%m-%d %H:%M'` | 创建时间戳 |
  | {{TASK_PLANNER_ROOT}} | 脚本自身定位的技能根绝对路径（既有 root 解析逻辑输出） | 替代 markdown 死串 |
  | {{PLAN_DIR}} | `$PWD`（计划目录绝对路径） | 产物内路径引用 |
  **② 兼容映射表（旧形态→值，渲染层顺带替换；覆盖 variant 29 文件与未迁移模板，文本零迁移）**：
  | 旧形态 | 替换为 |
  |--------|--------|
  | `{task-id}` | {{TASK_ID}} 值 |
  | `<task-id>` | {{TASK_ID}} 值 |
  | `<task>` | {{TASK_ID}} 值（去 task- 前缀风险：variant 中 `plans/<task>/` 语境按整 id 替换，S5 实弹核对） |
  | `{task-name}` | {{TASK_NAME}} 值 |
  | `[Brief Description]` | {{TASK_NAME}} 值（调查确认仅 task_plan.md 标题 1 处） |
  | `[DATE]` | {{DATE}} 值 |
  | `[YYYY-MM-DD HH:MM]` | {{DATETIME}} 值 |
  | `${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}` | {{TASK_PLANNER_ROOT}} 值（27 处死串 bug 顺带修复） |
  **③ 语义保留清单（禁替换，模型填写面）**：`<用户原话…>`/`<按需增行>`/`<判据…>`/`<工序 N>`/`<修复 S-unit/Phase>` 等尖括号**中文**形态；`#N` 序号（写入时递增）；裸 `YYYY-MM-DD`（格式示例行教学用，非填充位）；`{placeholder}`（subagent_dispatch 派发时填）；`填写`/`占位` 类指示文字
  **边界判据**：ASCII token/日期形态/尖括号纯 ASCII 短横线串=脚本渲染；尖括号含 CJK 或含空格=模型填写。
- **[2026-10-24 Explore 子代理调查] init/模板机制现状**（全文=subagent-state/01-explore-init-mechanism.md；Handoff#1）：
  1. **init 参数面**：`$1`=任务名（只进 L481 echo 不写文件，兜底词 `project`=${1:-project} L395）；`$2`/`$3`=template_type/plan_tier；auto-tier env 7 个（TASK_AUTO_TIER/TASK_EST_MINUTES/TASK_SCOPE_FILES/TASK_SCOPE_MODULES/TASK_TIER_EXCLUDE/TASK_SCOPE_FILE_LIST/TASK_EST_LINES）；TASK_TEMPLATE_DEFAULT/TASK_PLANNER_INTERACTION_MODE/TASK_LANE_BASE/CLAUDE_CODE_SESSION_ID（init-session.sh:9,395-403,457-478,862,918）
  2. **替换逻辑=零**：copy_template L83-97 纯 cp；全仓无 envsubst/perl 渲染；`DATE=$(date +%Y-%m-%d)` L479 定义后全文 0 处使用（日期从未注入）；仅 5 处条件行注入（awk/sed/heredoc：template_type/auto_tier/execution_lane/模板感知/requirement+evidence 脚手架）
  3. **占位符分布**：`${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}` markdown 死串 27 行/16 文件（永不展开=既存 bug，selftest-doc-script-paths.sh:33 有豁免条款包庇）；`{task-id}`/`{task-name}` ×8；`<task-id>`/`<task>` ×~35（命令示例态）；`[Brief Description]` ×1（task_plan.md 标题）；`[DATE]`/`[YYYY-MM-DD HH:MM]`/`YYYY-MM-DD` ×10；`#N` 序号（user-session-log 示例行）；语义占位保留面=`<用户原话…>`/`<按需增行>`/`<判据…>`/填写×47/占位×15
  4. **模型侧修正指示面**：SKILL.md:40,233（mkdir plans/{task-id} 纯模型自拟）；init-session.sh:110,116,259-263,379-383（「规划者填写后 attest」）；templates/user-session-log.md:10,17（#N 替换）；progress.md:16（Started 填真实时间）；subagent_dispatch.md:2,4（调用方替换占位——派发时才填，属语义保留）
  5. **selftest 级联面**：改 init 内容→selftest-{knowledge-brief(T3a/T3b),session-log(SL-07),execution-stability(T10b),plan-tier(PT-13/24),template-lifecycle(TL-11),active-plan(T08/T12a-c),evidence-goal-gate(EG-21),requirement-coverage}+check-complete:367,1376；改 templates→check-template-type+plan-tier L121 variant 计数；改 `${TASK_PLANNER_ROOT}` 字面→selftest-doc-script-paths.sh:33 豁免条款
  6. **渲染先例**：register-hooks-cj.ts:109-165 构建期字符串替换（仓内唯一「占位→真值」先例）
  7. **渲染时机无冲突**：init 在 attest SHA 锁定前完成，渲染放 init 内 copy_template 后即可
  8. **dogfood 实证**：本计划 init 时输出 "Initializing planning files for: project"（$1 未传实弹证据）；user-session-log.md 模板 `{task-id}`/`#N`/`YYYY-MM-DD` 全靠模型手工替换（第一手亲历）

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 方案 Y：{{VAR}} 显式 token（核心 7+项目级模板迁移）+ 渲染层兼容映射（variant 29 文件与其余模板旧形态直接替换、文本零迁移） | 备选 X（纯兼容层不迁移模板）省 diff 但旧形态无机械可判边界（漏替换不可检）；备选 Z（42 文件全迁移）diff 巨大且 selftest 内容断言级联爆炸。Y 取中：新契约形态 `{{` 仓内零占用、残留校验 fail-closed 可行、diff 收敛 90% |
| 渲染层实现=bash 纯串替换（sed 多表达式+转义；特殊字符高危串用 bash ${var//} 或 awk） | 零新依赖；register-hooks-cj.ts 先例=构建期替换同构；15min S-unit 粒度内可完成 |
| 语义占位边界判据：ASCII token/日期形态/尖括号 ASCII（task-id）=脚本渲染；尖括号中文（`<用户原话`）/#N 序号/`<按需增行>`/`填写`类=模型填写 | 机械可判（grep 形态可分）；S1 定稿后为执行期唯一甄别依据 |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- 源仓根：`/mnt/data/dev/task-planner-skill`（skill 源码在 `skills/task-planner/` 子目录）
- init-session.sh（1023 行）：`skills/task-planner/scripts/init-session.sh`
- 模板目录：`skills/task-planner/templates/`（根 13+variant 29=42 文件）+ 项目级 `.zcode/plan-templates/`（1 文件）
- 调查检查点：`plans/task-tplrender-20261024/subagent-state/01-explore-init-mechanism.md`
- 粒度硬约束：config.json:500-503（step_max_files=2/lines=100/minutes=15/steps=4）

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
