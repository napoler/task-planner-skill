# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
- **R1 [目标]**（plans/task-intentresume-20261116/user-session-log.md#1, 理解镜像 :15-19，逐字锚）：A 执行中被 B 插入挂起后，A 不能被彻底搁置；**B 执行完成（收口）后系统应主动切回 A 继续执行**（“主动进来回来执行 A”=主动回切触发/显性通告，非依赖用户手动恢复或会话重启扫描）。验收期望：B 收口序列中存在「挂起计划回切检查」→ 有挂起链即显性通告（是否切回）→ 确认后恢复 A。
- 上承：task-intentswitch-20261116 已归档（plans/archive/task-intentswitch-20261116/{task_plan,findings}.md），已交付 A→B 意图切换快速判定卡、执行清单①-④、【计划切换通告】、`[intent-switch]` 登记最小字段、hook 锚句、Rule 94/102 交叉锚（skills/task-planner/SKILL.md:193,202-204；skills/task-discipline/references/critical-rules-discipline.md:619,708）。
- 范围硬约束（本任务 scope）：仅修改 `skills/task-planner/SKILL.md`、`skills/task-discipline/references/critical-rules-discipline.md`。**禁改** /home/terry/.zcode/skills/plan-resume/SKILL.md、主仓 skills/plan-resume/SKILL.md 及其他受管文件；plan-resume 仅作只读参照。

## Research Findings

### 现有机制全景与锚点（实测，2026-11-16）

| # | 机制/载体 | 文件:行号（实测） | 现状 | 回切相关结论 |
|---|-----------|-------------------|------|--------------|
| M1 | 终验交付 — 机械子动作（3-File Gate→合并回→git提交核验→Read产出→check-complete→计划归档） | skills/task-planner/SKILL.md:130-136 | :136 “check-complete exit 0 后运行 `bash scripts/archive-plan.sh <task-id>`…”；无挂起链检查/回切动作 | **R-1 缺口**：B 收口可直接归档，未扫描挂起痕迹 |
| M2 | 终验交付 — 智能子动作（VC复验/outcome判定/84.14收尾回读/103/质量门控/委派率/交付五要素） | skills/task-planner/SKILL.md:138-145 | :138 outcome 判定，:140 84.14“全部 Phase complete 后、outcome 判定前…”全文档收尾回读；无回切分支 | outcome 判定后无“检测挂起 A→通告→切回”分支 |
| M3 | 意图切换快速判定卡（A→B 入口） | skills/task-planner/SKILL.md:193 | 三要素零交集→D 类，按「意图切换执行清单」处置；E 类先确认 | 前向切换识别已在位 |
| M4 | 意图切换执行清单（D 类定案后①-④） | skills/task-planner/SKILL.md:202 | ①旧计划挂起登记（progress 追加 `[intent-switch]`+断点）→②新计划init→③显性通告→④切换登记 | 仅前向闭环，无反向回切步骤 |
| M5 | 显性通告模板（A→B 切换） | skills/task-planner/SKILL.md:203 | `【计划切换通告】旧计划 <old-task-id> 已挂起（断点=其 progress.md [intent-switch] 行）→ 新计划 <new-task-id> 已激活…旧计划可用 plan-resume 恢复。` | **R-2 缺口**：无 B 收口后回切通告形态 |
| M6 | 切换登记最小字段 | skills/task-planner/SKILL.md:204 | `[intent-switch] 旧=<id> 新=<id> 触发=原话#N 判定=D/E 确认=yes\|44.3自动 时间=<ISO8601>`（复用既有载体，不新建文件） | **R-4 缺口**：缺回切处置状态字段（切回=yes/no） |
| M7 | Rule 94 任务专注性与计划隔离（封存待 resume） | skills/task-discipline/references/critical-rules-discipline.md:607,615 | 94.4①“旧计划原样封存…待 plan-resume”；②新目标独立 init；③禁交叉写入；④混写补救 | “待 resume”语义在位但未与 B 收口主动回切触发衔接 |
| M8 | Rule 94 既有 intent-switch 交叉锚 | skills/task-discipline/references/critical-rules-discipline.md:619 | `> 交叉锚（intent-switch 单入口，2026-11-16）：D 类切换的执行步骤清单与显性通告模板由 task-planner SKILL.md「用户新指令处理」单入口承载；本条保留「询问门（94.3）+ 隔离处置（94.4）」权威语义。` | 前向切换锚已落；**R-3** 需补回切衔接 |
| M9 | Rule 102 交叉锚（判定侧） | skills/task-discipline/references/critical-rules-discipline.md:708 | 指向 SKILL.md 单入口（判定五问+先落盘后执行） | 回切属收口侧，102 权威语义本任务不改 |
| M10 | plan-resume 恢复机制（只读参照，禁改） | /home/terry/.zcode/skills/plan-resume/SKILL.md:15,33,65-69 | 触发点③“当前计划交付终态(COMPLETE/交付报告落盘)”自主推进；恢复触发点自主选 Top 1 续推；旧计划封存待 resume；执行中被动扫描只报告；跨项目候选只报告 | 恢复能力已在位，可作回切 yes 分支定向路由 `Skill("plan-resume")`，无需改实现 |
| M11 | 挂起计划数据源 | plans/INDEX.md:8-57；各计划 progress.md/Decisions `[intent-switch]` 行 | 切换时 B 计划载体记录 `[intent-switch] 旧=<id>…`；INDEX 待处理区列 in_progress/pending（如 task-history-recall-20261116 in_progress） | 双源定位：登记链给出旧计划 id，INDEX 佐证待处理态 |
| M12 | 上承归档证据 | plans/archive/task-intentswitch-20261116/task_plan.md, findings.md | 意图切换显性度增强已交付（判定卡/清单/通告/登记/hook/交叉锚） | 本任务补“B 收口→主动回切 A”闭环 |

### 关键证据摘录
- SKILL.md:130 `- [ ] [M] **终验交付 — 机械子动作**：跑终验门脚本/合并回/提交核验/Read 产出/归档`
- SKILL.md:136 `- **计划归档（Rule 81.1）**：check-complete exit 0 后运行 \`bash scripts/archive-plan.sh <task-id>\` 将完成任务目录移入 plans/archive/…`
- SKILL.md:138 `- [ ] [A] **终验交付 — 智能子动作**：VC 复验判定、质量门控与委派率核查、outcome 判定`
- SKILL.md:140 `- **全文档收尾回读梳理（Rule 84.14，P0 迭代门）**：全部 Phase complete 后、outcome 判定前…`
- SKILL.md:202-204 意图切换执行清单①-④ / `【计划切换通告】` / `[intent-switch] 旧=<id> 新=<id> 触发=原话#N 判定=D/E 确认=yes|44.3自动 时间=<ISO8601>`
- discipline:615 `94.4 隔离处置…① **旧计划原样封存**：状态/三文件/索引按 plan-resume 语义保留…待 plan-resume；`
- discipline:619 既有 intent-switch 单入口交叉锚（前向）
- plan-resume:15 触发点③交付终态；:65-69 恢复触发点自主选 Top 1 续推/执行中只报告

## 缺口诊断与根因

| 编号 | 缺口 | 证据 | 根因 |
|------|------|------|------|
| R-1 | B 收口序列无挂起计划回切检查 | SKILL.md:130-145 全段无 `回切`/`挂起计划回切`；:136 直接归档 | 终验交付只覆盖 B 自身闭环，未读取 A 的 `[intent-switch]` 登记链/INDEX 待处理区 |
| R-2 | 无回切通告形态 | SKILL.md:203 仅前向【计划切换通告】；:202 无回切步骤 | A→B 有模板但 B→A 缺对称“B 已收口→检测到挂起链 A→是否切回”交互面 |
| R-3 | 挂起链无主动恢复触发衔接 | discipline:615 “封存待 resume”；:619 前向锚未提回切触发；plan-resume:15 有能力但未被收口流程显式路由 | 处置权威与恢复工具分离，缺收口侧主动触发与定向恢复指引 |
| R-4 | 登记无回切状态字段 | SKILL.md:204 字段无回切结果 | 无法审计/防重复提示（yes 已路由恢复 vs no 保持挂起） |

## 方案骨架（S-A 最小增强，scope 内两文件）

- **S1（SKILL.md 终验交付段，:130-145 插入锚）**：在 outcome 判定后、归档前（兼容 :136 Rule 81.1）新增「挂起计划回切检查（intent-switch 回切）」条款——查本计划 progress/Decisions 的 `[intent-switch]` 登记链（`旧=<id>`）与 `plans/INDEX.md` 待处理区 → 存在挂起计划 → 会话面输出【计划回切通告】（B 已收口→检测到挂起链 A→是否切回）→ 用户 yes=释放指针+路由 `Skill("plan-resume")` 定向恢复该计划续推；no=登记保持挂起（更新 `回切状态`）。**不自动切**。
- **S2（SKILL.md 显性通告区，:202-204 邻近）**：补「回切通告模板」形态（含“B 已收口”“检测到挂起链”“是否切回”及 yes/no 处置语义），与前向【计划切换通告】/:203 对称。
- **S3（discipline Rule 94 段末，:619 之后）**：补 intent-switch 回切交叉锚——衔接 94.4 封存待 resume 与回切触发，指向 SKILL.md「终验交付」挂起计划回切检查/【计划回切通告】/`Skill("plan-resume")`，声明**不自动切**；保留 Rule 94 权威语义不改。

**设计决策**：回切=目标/执行上下文变更，必须用户确认（yes 才释放指针+定向恢复），禁止自动切回；对齐 E 类/Rule 94.3 确认精神与 R1“是否切回”。no 分支登记“保持挂起”并写回切状态，保留可恢复性且避免反复打扰。

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 回切检查插入点=outcome 判定后、归档前（终验交付段） | 归档前可读本计划载体与 INDEX，且 B 已收口语义确定；与 Rule 81.1 顺序兼容（S1 条款先于执行 :136 归档动作判定/提示） |
| 挂起链发现源=本计划 `[intent-switch]` 登记链（`旧=<id>`）+ `plans/INDEX.md` 待处理区 | 双源互补：登记链精确指向旧计划，INDEX 佐证待处理/中断态 |
| yes 分支=释放指针+路由 `Skill("plan-resume")` 定向恢复；no=登记保持挂起 | 复用 plan-resume 恢复能力（M10，只读），最小改动；不自动切满足确认口径 |
| scope=SKILL.md + discipline 两文件，worktree 隔离 | 用户硬约束+受管技能改动；明确排除 plan-resume（并行未提交改动） |
| VC 判据命令先实测锚形态再写，并锁定将插入的关键 token | 规避判例“判据与产物形态错配”；discipline 用 `^### 94` 裸编号，既有交叉锚/切换 token 已实测 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| 主仓 skills/plan-resume/SKILL.md 并行未提交改动（434→94 行方向） | scope/CA/VC 全面排除，仅读 /home/terry/.zcode 部署位参照 |
| 计划期 VC 命令需可执行但实现前会失败 | verification.md 中 Verify command 写为对目标文件的可执行 grep；实施后应全绿，计划期仅作为规范锚 |

## Resources
- plans/archive/task-intentswitch-20261116/task_plan.md, plans/archive/task-intentswitch-20261116/findings.md
- skills/task-planner/SKILL.md:123,130-145,191-210,202-204
- skills/task-discipline/references/critical-rules-discipline.md:607-620 (94.4:615, 交叉锚:619, :708)
- /home/terry/.zcode/skills/plan-resume/SKILL.md:15,33,65-69（只读）
- plans/INDEX.md:8-57
- plans/task-intentresume-20261116/user-session-log.md#1

## Visual/Browser Findings
- （本任务暂无多模态发现——未产生截图/PDF/网页证据）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7) -->