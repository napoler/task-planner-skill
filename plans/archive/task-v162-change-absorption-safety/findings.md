# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
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

### §吸收现状审计（Phase 1 / S0，Explore(mini) 子代理产出，2026-10-10；子代理只读模式未落盘，主进程回填）

**A1. 吸收触点清单（13 处，精确到 file:line）**

| # | 触点名 | file:line | 现有处置语义 |
|---|--------|-----------|-------------|
| 1 | D/A/B/C 四分类表 | SKILL.md:238-262 | D=开新计划(:244)；A=照常执行不改计划(:245)；B=先重规划再执行(:246)；C=停止写入+更新被推翻部分(:247) |
| 2 | 判定顺序 | SKILL.md:249 | 先 D（任务边界）再 A/B/C；仅当存在进行中的活跃计划时 D 类适用 |
| 3 | 稳定性铁律 | SKILL.md:251 | 禁止口头接受新指令、计划文档与 Todo 不动 |
| 4 | Rule 8.1 新任务边界判定 | critical-rules.md:29 | D 先于 A/B/C；判定依据=当前 task_plan.md 三要素（Goal + scope_files/执行范围 + 交付物）；无活跃计划时 D 类 N/A |
| 5 | Rule 56 用户指令优先 | critical-rules.md:638-652 | 56.1 默认自动执行；56.2 人工审查触发条件；56.3 禁止自行添加人工审查；56.4 用户说"不要人工审查"必须遵守；56.5 机制=LLM 行为+selftest 静态断言 |
| 6 | Rule 51.1 需求原文锚定 | critical-rules.md:578 | 计划创建与重规划时必须设「🎯 用户需求原文」区块；逐条编号抄录用户原话（R1..Rn；禁转译/缩写/合并）；51.1a 载体双机制（init 注入+attest 校验） |
| 7 | Rule 51.7 纠正=回锚重译 | critical-rules.md:586 | 用户纠正/补充指令时，纠正原话追加为新 R 行（禁改写/合并既有 R 行——改写旧行=销毁锚点=事故直接成因） |
| 8 | Rule 36 技能修改保守化 | critical-rules.md:366-377 | 36.1 适用范围；36.2 归因前置门；36.3 修改前基线；36.4 删除=高危确认门；36.5 保守化修改纪律（默认纯增量） |
| 9 | Rule 69.1 判断裁决 T1 | critical-rules.md:896 | 六触发点矩阵 T1-T6；管辖二分：判断类裁决出口唯一=decision-arbiter |
| 10 | Rule 71 无源不写 | critical-rules.md:928-942 | 71.1 事实单元三态判定；71.2 写入前五问自检；71.3 模板空段显式占位；71.4 溯源审计 SOP；71.5 派发防幻觉契约行 |
| 11 | 合规清单 C48 | SKILL.md:230 | 用户呈报可审批性（Rule 70） |
| 12 | 合规清单 C49 | SKILL.md:231 | 上下文压力主动评估（Rule 67） |
| 13 | 合规清单 C50 | SKILL.md:232 | 无源不写与空段占位（Rule 71） |

**A2. 现有吸收语义默认值（四类场景通道）**

| 场景 | 通道 | file:line | 语义 |
|------|------|-----------|------|
| 补充条目 | B 类扩展 | SKILL.md:246 | 「先重规划再执行：Edit task_plan.md（新增/修改 Phase、VC、执行范围表，注明来源指令与时间）→ 紧邻同步原生 Todo（S5）→ 向用户复述计划变更 → 再执行」 |
| 修订 | C 类矛盾 | SKILL.md:247 | 「停止当前写入：更新计划中被推翻部分（标注 superseded + 新内容）→ 同步 Todo（改/删对应条目）→ 展示新旧对比获确认后执行」 |
| 合并冲突 | v149/v155 并集解判例 | plans/task-v155 并集解 findings.md:297 | 「逐 hunk 并集保三方条文+重跑全量回归；禁 rebase 强推」 |
| 子代理产出并入 | Rule 19.1/22.5 | SKILL.md:92 | 「每次子代理返回后，紧邻一次 Edit findings.md 写入结论摘要 + 证据路径」 |

**关键缺陷**：B 类扩展的「Edit task_plan.md（新增/修改 Phase、VC、执行范围表）」语义为「新增/修改」，**未显式区分「追加」与「替代」**——当用户补充条目被后续条目覆盖时，既有条目被静默替换。Rule 51.7 已有「纠正=回锚重译（追加新 R 行，禁改写旧行）」先例，但该约束仅限需求原文区，未上升为通用吸收语义门。

**A3. Pinning selftest 锚清单（11 处，精确到 file:line——Phase 6 级联清账消费）**

精确 'Critical Rules 1-71' 锚（5 处）：
| # | file:line | 锚形态 | 用途 |
|---|-----------|--------|------|
| 1 | scripts/selftest-lane-advancement.sh:135 | `grep -c 'Critical Rules 1-71'` | SKILL.md 主锚 >=1 |
| 2 | scripts/selftest-self-resolution.sh:81 | `grep -c 'Critical Rules 1-71'` | SKILL.md 主锚 >=1 |
| 3 | scripts/selftest-tool-selection.sh:64 | `grep -c 'Critical Rules 1-71'` | SKILL.md 主锚 >=1 |
| 4 | scripts/selftest-requirement-coverage.sh:131 | `grep -c 'Critical Rules 1-71'` | SKILL.md 主锚 >=1 |
| 5 | scripts/selftest-source-anchor-discipline.sh:39 | `grep -cF '1-71'` 计数 >=2 | Rule 71 bullet + C50 行 |

宽容/变体锚（6 处）：
| # | file:line | 锚形态 | 用途 |
|---|-----------|--------|------|
| 6 | scripts/selftest-research-first.sh:75 | `cnt '1-[67][0-9]'` 计数 >=3 | RF-06 宽容锚（1-74 自然覆盖） |
| 7 | scripts/selftest-context-pressure.sh:99 | `1-(69\|71)` 宽容化 | CP-07 短串计数 |
| 8 | scripts/selftest-workflow-orchestration.sh:70 | `Critical Rules 1-68/1-71` 变体族 | 4 索引文档变体族命中总和 >=3 |
| 9 | scripts/selftest-conclusion-discipline.sh:16 | `Rules 1-6[0-9]\|1-3[5-9]` 宽容锚 | CD-18 README.md 宽容锚 |
| 10 | scripts/selftest-skill-split.sh:80 | `1-(3[0-9]\|[4-7][0-9])` 宽容正则 | 7x 纪元再扩 |
| 11 | scripts/selftest-source-anchor-discipline.sh:27 | `^71\.[1-7]` 七子条号锚 | SA-01 条款标题+子条号锚（Rule 74 落地后自然扩展为 71-74 族） |

**B. 三对标判例取证**

B1. v149/v155 并集解判例（合并冲突=增量优先先例）：证据锚 plans/task-v155 并集解 findings.md:297「逐 hunk 并集保三方条文+重跑全量回归；禁 rebase 强推」；findings.md:240「SKILL.md：3 冲突块并集解」；findings.md:245-253「selftest-registry.tsv + selftest-research-first.sh + selftest-skill-split.sh + selftest-goal-unit-goal-mode.sh 四处并集解」。

B2. v131 锚级联 5 犯判例（新增行撞定数断言）：证据锚 plans/task-v131 task_plan.md:208「F2 锚级联漏改→回归 FAIL（历史第 3 次教训）」；task_plan.md:92「锚级联前 grep -rn "Rules 1-\|≤461\|≤475\|1-51\|1-52" scripts/ 全扫一次修齐」；plans/round-retrospective-2026-10-04.md:13「v121 三锚预扩 1-4[5-9]→47/48 落地零级联」。

B3. Rule 36.5/v079 保守化修改先例（默认纯增量）：证据锚 critical-rules.md:374「36.5 保守化修改纪律：默认纯增量追加；既有条款语义变更须同时 ① 计划「执行范围限制」表逐行登记 ② progress.md 记录旧语义→新语义对照；禁止以「重构/顺手整理/清理」名义触碰未授权区域」；critical-rules.md:368「③默认纯增量——语义变更须逐行登记（36.5），杜绝功能静默丢失」。

**C. 5 Whys 归因（根因=规则覆盖缺口+守卫缺失）**

| 层级 | 问题 | 证据锚 |
|------|------|--------|
| 现象 | 用户补充条目被后续条目整体替代 | SKILL.md:246 B 类扩展语义为「新增/修改」，未区分「追加」与「替代」 |
| Why 1（直接原因） | B 类扩展通道的「Edit task_plan.md（新增/修改 Phase、VC、执行范围表）」语义未显式区分「追加」与「替代」 | SKILL.md:246 |
| Why 2 | Rule 51.1/51.7 的「纠正=回锚重译（追加新 R 行，禁改写旧行）」约束仅限需求原文区，未上升为通用吸收语义门 | critical-rules.md:578,586 |
| Why 3 | Rule 36.5「默认纯增量追加」仅适用于技能文件修改，未覆盖用户指令吸收场景 | critical-rules.md:374 |
| Why 4 | Rule 69.1 六触发点矩阵 T1-T6 未覆盖「补充条目 vs 既有条目」的语义冲突场景——主进程无明确裁决出口 | critical-rules.md:896 |
| Why 5（根因） | 技能缺乏「变更吸收三判纪律」——对四类吸收场景的吸收语义无统一判据+无机器门守护，模型在 B 类扩展时自由选择「追加」或「替代」 | 综合上述证据 |

**类别**：规则覆盖缺口（系统性设计缺陷）+ 守卫缺失（无机器校验）。
**根治判据**：Rule 74 三支柱——74.2 三判门（条文）+74.3 变更标注表（模板+计划自检）+74.4 定稿可行性判别门（机制）+selftest 静态守护（机器面）。

## §S11 定稿可行性判别门结论（Rule 74.4 dogfood — 2026-10-10）

**verdict: PASS-WITH-RISKS**（判别者=general-purpose(sonnet-1) 独立子代理；证据锚=subagent-state/11-feasibility.md）
- 可执行性 PASS：8 Phase S-unit 九列全填无空段，材料包 T1-T7/CA-1..14/AD-01..14 逐字在位；簿记漂移 R2=Phase 6/7/8 V-N 列与 VC 定义错位（VC-7/5/8 应分别落 Phase 6/7/8），活动实体不缺。
- 相容性 PASS：引用锚 grep 一手全真（74.x=6/标题 1 且 EOF Rule 71 后；8.1/36.5/56.1/51.1/69.1(L896)/71.1(L930)/38.3/43.2 均存在）；36.5↔74.2/56↔74.2 关系表述双向一致；三触点纯追加旧文零动；config.json 零改动；R3=74.3(b) 机器边界措辞微过claim（AD-06 只护模板锚/AD-13 只护本计划）。
- 风险性 PASS-WITH-RISKS：爆炸半径=21 文件（worktree 15+plans 6），运行中基础设施权重高；回滚两段路径存在（合并前 restore+worktree remove；合并后 revert merge commit）；R1=4 个同源活跃 worktree（v156/v161/v163/v164）合并冲突暴露（FMEA RPN=84 已有并集解兜底）；R4=v158 部署债务待用户授权门（CA-14 deferred）。
- 独立复验（区别于子代理自报）：全量 selftest 72/72 rc=0；AD 脚本 14 PASS exit 0。

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
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
