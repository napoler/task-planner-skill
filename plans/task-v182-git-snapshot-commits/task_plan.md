# Task Plan: [Brief Description]
<!-- ===== frontmatter 头（Rule 16 选模板 + Rule 34.1 门控 + Rule 38.7 执行通道分级）=====
  选定 variant 后 template_type 填所选类型名（白名单=${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/templates/variant/*-type.md 动态派生，见 check-template-type.sh）；general=通用回退（恒合法，Rule 34.1）
  plan_tier ∈ {standard, mini}（Rule 38.1，mini 四条件机器判定）；execution_lane ∈ {L0, L1, L2}（Rule 38.7，缺省 L1；L0 禁滥用见 38.7 末段）
  check-template-type.sh 三形态之一：行首 `^template_type:`（本块）/ 表格行 / HTML 注释；本块用行首形态 -->
template_type: general
plan_tier: standard
execution_lane: L1
<!-- 
  WHAT: This is your roadmap for the entire task. Think of it as your "working memory on disk."
  WHY: After 50+ tool calls, your original goals can get forgotten. This file keeps them fresh.
  WHEN: Create this FIRST, before starting any work. Update after each phase completes.
-->

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：Rule 51.1 计划侧载体（审计 H-3 清账）。R 行=用户原话逐条编号抄录；映射=每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉（51.1/51.2） -->
<!-- 2026-10-07 task-v143：Rule 58.4 手段/目标二分——每条 R 行末尾标注 [手段] 或 [目标]；[目标] 行必须映射 ≥1 条「问题解决判据」VC（核心问题的可观察解决证据，非手段产物完成）；目标型任务终验必填「🎯 核心目标达成裁决」区块（58.5） -->

- **R1**: 「优化当前项目  技能」<sub>（[手段]）</sub>
- **R2**: 「在使用前和使用后都需要使用Git进行备份备份版本，确保就是可恢复可控性」<sub>（[目标]）</sub>
- **R3**: 「也就是开始和结尾的时候分别使用两次，做两次Git提交」<sub>（[目标]）</sub>
- **R4**: 「以及就是合并的合并等等类似操作的合理性」<sub>（[目标]）</sub>
- **R5**: 「所有数据都所有需要管理的数据都可以有效的进行管理」<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2 | 条款文本在位（grep 锚计数）+ 索引级联一致 |
| R2 | VC-1, VC-6 | 90.1/90.2 首尾快照条款在位 + 本任务自身首尾提交可核 |
| R3 | VC-1, VC-6 | 同上（首尾各一次提交=90.1+90.2 双锚） |
| R4 | VC-1, VC-5 | 90.3 合并合理性条款在位 + 合并回 master 后 scope 干净 |
| R5 | VC-1, VC-3, VC-4 | 90.4 数据管理条款在位 + 全量回归绿 + 编号台账 land 行 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
<!-- 2026-10-11 task-v169（Rule 80 落地）：用户会话逐字记录专档指针区块——用户需求与对话内容逐字落档 plans/<task-id>/user-session-log.md（只写不改，append-only）；本区块纯静态（专档路径+铁律+恢复协议，禁条目计数/首末条目标记类需随记录更新的可变内容——改 task_plan.md 即 [PLAN TAMPERED] 与 attest 哈希锁冲突） -->
- **专档路径**：`plans/<task-id>/user-session-log.md`（模板 = ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-05 task-v131：Rule 53.1 载体。结果级需求（确保质量/性能/可靠类）必须分解生产管线逐工序审计缺陷面；
     非结果级（单点动作）任务须写「不适用（非结果级需求）」+ 一句定性理由（53.1 禁裸豁免，attest/终验可核；
     与 init-session.sh 注入版脚手架注释同口径） -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 需求→条款 | 只做一次性提交实践、未制度化=下次任务照样裸奔 | Rule 90 条款文本（90.1-90.6）落 discipline 文件 | VC-1 |
| 条款→索引 | 正文加了索引没跟=规则不可发现（v179 级联判例） | SKILL.md×2 + critical-rules.md 索引同步 1-90 | VC-2 |
| 索引→回归 | 纪元锚 `1-8[0-9]` 不匹配 `1-90`=selftest 假红（记忆判例：1-90 会再炸一次） | 全集实跑→按 FAIL 清单放宽锚→复跑 | VC-3 |
| 回归→台账 | 编号未 land=下次撞号（Rule 20.6） | rule-reserve land 90 | VC-4 |
| 收口→恢复 | 归档/INDEX 不入库=终点无档（用户 R2/R5 诉求本体） | 收口提交（归档+INDEX 刷新随行） | VC-5, VC-6 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
<!-- WHAT: 任务要素显式分三态——不变量(锁)/可变量(自主调+登记)/学得量(只入 findings、禁反写不变量)。
     WHY: 用户 R2「强化四文件，确保哪些不变/哪些可变/哪些学得」；无声明=执行期风格/范围漂移无对照物（R1 实证）。 -->
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | ①用户原话 R1-R5 逐字锚；②新增 Rule 编号=90（预留已查空闲）；③纯增量纪律——既有规则条目原文零改动（87/88/89 先例）；④零新增守护脚本/零新 config 键（L0-T 文本档，§四.6 文本优先铁律）；⑤落点文件=scope_files 白名单 | R 区/new_rule 字段/CA 表 |
| 🔀 可变量 | 子条编号切分（90.x 划法）/锚放宽的具体正则形态/提交消息措辞/S-unit 顺序 | - |
| 📈 学得量 | 纪元锚实跑 FAIL 清单与形态分布/在途任务协调事实→findings.md | findings.md |

## Goal
<!-- 
  WHAT: One clear sentence describing what you're trying to achieve.
  WHY: This is your north star. Re-reading this keeps you focused on the end state.
  EXAMPLE: "Create a Python CLI todo app with add, list, and delete functionality."
-->
把「任务执行开始前基线快照提交 + 结束后终态收口提交」（首尾双 Git 提交）制度化为 task-planner 技能增量条款 Rule 90，使任何任务的起点与终点都有可恢复、可追溯的版本锚，且合并与数据管理操作有章可循。

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
  默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（纯 .md 规则文本+索引+锚正则，无代码逻辑变更；回归面由 selftest 全集实跑承载） |
| `session_id` | `sess49c2c6f812c6402194bcfcb5c7a12ecc` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v182-git-snapshot-commits` |
| `scope_files` | `skills/task-discipline/references/critical-rules-discipline.md`; `skills/task-planner/SKILL.md`; `skills/task-discipline/SKILL.md`; `skills/task-planner/references/critical-rules.md`; 纪元锚放宽面=`skills/task-planner/scripts/selftest-*.sh`（仅含 `1-8[0-9]`/`1-8[0134]`/`'1-89'` 锚的脚本，实跑 FAIL 清单为准）；计划簿记=`plans/task-v182-git-snapshot-commits/**` + `plans/INDEX.md` + `plans/.rule-reservations.jsonl` |
| `interaction_mode` | `silent`（/goal 自主模式，用户不在线；静默决策清单随交付登记） |
| `对齐审查` | 收尾对 alignment-review 豁免登记：纯增量条款+索引行更新，对齐审查的版本一致性校验由 selftest 全集实跑承载（83 条既有锚即版本一致性机检）；如执行期扩展改动面则重新触发 |
| `自动超时默认项` | 无 2+ 选项询问点（单一落点=Rule 90 追加 discipline 文件；低区分度决策全部自主裁决并登记 Decisions Made） |
| `new_rule` | `90` |
| `质量审查工具` | 既有 selftest 全集（81 脚本）+ Verifier 子代理独立终验（Rule 33.3 验证独立性）；无新建需求 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

<!--
  WHAT: 任务执行完毕 ≠ 目标完成。此表确保每一步有可验证证据。
  RULE: 每个 phase 完成后对照 VC 编号复验；phase 全部 complete ≠ 通过终验。
  FORMAT: VC-N 是客观判定标准（可测试/可追溯/不依赖主观判断）。
  V-N: goal-gate.md 规定「≥5 条 VC + 每 phase ≥2 条 V-N（映射到 VC 编号）」；
       在每个 Phase 段（`### Phase N` 的 - **Status:** 行前）补 `- **V-N:**` 占位行，
       填写本 Phase 验收映射的 VC 编号（≥2 条，如 `VC-1, VC-2`；对应逐条验收记录在
       ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/templates/verification.md 的 `V-N.N` 项，映射目标须为已定义 VC 编号）。
       check-complete.sh 终验 VC-GATE 段机械校验（config.json vc_gate_enforce，默认 warn）。
-->

> **验证独立性**：本计划验证动作默认由独立子代理执行（Executor 字段可填 V-类执行体），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 90 条款在位且六子条齐（90.1 首快照/90.2 尾提交/90.3 合并合理性/90.4 数据管理/90.5 衔接分工/90.6 机制） | grep 锚计数 | `grep -c "^### 90 任务执行首尾" skills/task-discipline/references/critical-rules-discipline.md` ≥1 且 `grep -cE "^- \*\*90\.[1-6]" <同文件>` = 6 |
| VC-2 | 索引级联一致：三载体全部含 90 | grep | `grep -c "1-90" skills/task-planner/SKILL.md` ≥2 且 `grep -cE "88,89(,90)?|88/89(/90)?"` 于 SKILL.md×2+critical-rules.md 合计 ≥4 处含 90 |
| VC-3 | 全量 selftest 回归零 FAIL | 遍历实跑 | `for f in skills/task-planner/scripts/selftest-*.sh; do bash "$f" >/dev/null 2>&1 \|\| echo "FAIL $f"; done` 输出为空 |
| VC-4 | Rule 90 编号台账 land | grep 台账 | `grep '"rule":90,"status":"landed"' plans/.rule-reservations.jsonl` 命中 1 行 |
| VC-5 | 合并回后 scope 干净 | git porcelain | `git status --porcelain -- skills/task-discipline/references/critical-rules-discipline.md skills/task-planner/SKILL.md skills/task-discipline/SKILL.md skills/task-planner/references/critical-rules.md` 输出为空 |
| VC-6 | 本任务自身首尾提交在位（Rule 90 首次实践=dogfood 证据） | git log | `git log --oneline --grep "task-v182" \| wc -l` ≥3（首锚提交+feat/merge+收口归档提交）且最早一笔含"首锚"字样、最末一笔含"归档"字样 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：若 `code_review: required`，终验前必须先通过 Code Review Gate（详见 SKILL.md），否则不得标记 COMPLETE。

## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
<!--
  WHEN: 终验时填写;含 [目标] 标注需求（下方 R 行）的任务必须在交付前出三态裁决
  WHY: Rule 58.5 完成裁决门——「分析报告已交付」不等于「问题解决了」;not-solved/partial 禁止标 COMPLETE
  载体: 58.4 手段/目标二分在需求原文区逐条标注 [手段]/[目标];本区块回收目标型需求的解决状态
-->
| 字段 | 值 |
|------|-----|
| **目标型需求** | （R 行编号，如 R1/R3） |
| **裁决** | `solved` / `partial` / `not-solved`（三选一必填） |
| **解决证据锚** | （file#锚点/取证记录行；solved 必填） |
| **未解决面+原因** | （partial/not-solved 必填） |
| **已排除路径** | （not-solved 必填：试过什么+为何不行） |
| **下一步建议** | （not-solved 必填：可执行的下一步）（按 Rule 70：对象路径+看点+动作） |

> 纯手段型任务（用户只要动作/产物，无问题待解）可填 `n/a（纯手段型任务）`——须与需求区标注一致，禁裸豁免。

## 🎯 Goal 单元表（Rule 66.1 — 规划获批后任务单元固化；standard/full 必填，mini 档豁免）
<!--
  WHEN: attest 获批后立即填写（自动分解：S-unit/Phase → goal 单元映射）
  WHY: 用户 2026-10-09 裁决——任务分解后逐格固定为「任务名+目标+完整验证方式」，
       执行按 goal 逐个推进（66.3），/goal 目标模式完成审计的证据源（66.2 映射供料）
  列契约（66.1 六列）: goal-id(G1..) | 任务名(≤8字) | 目标(≤1句) | 完整验证方式(命令+判据/路径+关键行/diff形态,三选一必具其一) | 对应S-unit/Phase | 状态(pending/complete)
  状态机: pending → complete(仅 66.3 三证据齐备后翻格,同步 progress.md [goal:Gn] 证据行)
-->
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | Rule90 条款 | 90.1-90.6 六子条落 discipline 文件末段 | `grep -cE "^- \*\*90\.[1-6]" skills/task-discipline/references/critical-rules-discipline.md` = 6 | S1/Phase 1 | pending |
| G2 | 索引级联 | 三载体索引同步 1-90 + 卫星行含 90 | `grep -c "1-90" skills/task-planner/SKILL.md` ≥2 | S2,S3/Phase 1 | pending |
| G3 | 纪元锚绿 | 全集 selftest 实跑 FAIL=0 | 遍历 selftest-*.sh 输出无 FAIL 行 | S4-S7/Phase 1 | pending |
| G4 | 台账+收口 | land 90 + 合并回 + 归档 + INDEX + 收口提交 | `grep '"rule":90,"status":"landed"' plans/.rule-reservations.jsonl` + `git log --grep task-v182` ≥3 | S8-S10/Phase 1 | pending |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 技能规则正文 | `skills/task-discipline/references/critical-rules-discipline.md`（仅末段追加 90 条款） | 改动既有规则任何一行（87/88/89 原文冻结）；其他卫星 references |
| 技能索引 | `skills/task-planner/SKILL.md`、`skills/task-discipline/SKILL.md`、`skills/task-planner/references/critical-rules.md`（仅索引行数字/列表） | 索引行外的任何措辞改动 |
| 测试锚 | `skills/task-planner/scripts/selftest-*.sh` 中含纪元锚（`1-8[0-9]`/`1-8[0134]`/`'1-89'`）的行（以实跑 FAIL 清单为准） | 锚行以外的断言逻辑；新增 selftest 脚本；selftest-registry.tsv（无新脚本不登记） |
| 簿记 | `plans/task-v182-git-snapshot-commits/**`、`plans/INDEX.md`、`plans/.rule-reservations.jsonl` | 任何其他 plans/ 目录（含在途 task-defect-rrv13-dg12-false-pass/**——他域在途，禁碰） |

**执行前自我检查:**
- [ ] 这个文件在上面的列表中吗？
- [ ] 这个修改对完成任务有必要吗？
- [ ] 用户明确要求我做这个修改吗？
- 全部 Yes → 可以执行 | 任一 No → 先问用户（问询按 Rule 70 四要素）

## 📋 变更标注表（Rule 74.3 — 修订方案必填，无表=无效方案）

<!--
  WHAT: Rule 74.3 变更标注表 — 任何对既有文件/条目的变更，制定方案时逐条登记（编号/对象+锚点/类型/吸收判定/依据/执行动作）。
  WHY: 落实 74.2 三判门（增量默认·替代四条件·删除授权）留痕；无表=无效方案禁入执行（74.3b），表兼验收清单（74.3c）。
  WHEN: 制定修订方案时填写；用户新指令到达时先逐条转标注行再动任何文件（先标注后执行，74.3d）。
-->

任何对既有文件/条目的变更，制定方案时在此逐条登记；本表兼任验收清单（执行后逐行勾核，新增而产物缺失/增量而旧内容被改=FAIL）。用户新指令到达时先转标注行再动任何文件——先标注后执行。

| 编号 | 对象（文件+锚点） | 类型（新增·修改·删除·更新） | 吸收判定（增量·替代·删除） | 依据（用户原话或证据） | 执行动作 |
|------|------------------|---------------------------|-----------|------------------------|---------|
| CA-1 | critical-rules-discipline.md:562 文件末段（Rule 89 之后） | 新增 | 增量 | R2/R3「使用前和使用后…开始和结尾…两次Git提交」 | 追加 `### 90 任务执行首尾Git双提交纪律` + 90.1-90.6（~18 行），89 段原文零改动 |
| CA-2 | task-planner/SKILL.md:9（Rules 1-89 全集索引行） | 更新 | 增量（数字口径演进） | 级联判例 v179（73→75） | `1-89`→`1-90`、`其余 75 条`→`其余 76 条` |
| CA-3 | task-planner/SKILL.md:17 与 :162（卫星路由行×2） | 更新 | 增量 | 同上 | 列表追加 `90` |
| CA-4 | task-planner/SKILL.md:175（Critical Rules 指针段）与 :217（References 行） | 更新 | 增量 | 同上 | `1-89`→`1-90`、`75 条`→`76 条`、`85/86/87/88/89 纪律域`→含 90 |
| CA-5 | task-discipline/SKILL.md:24 与 :80 | 更新 | 增量 | 同上 | 规则列表追加 `90`；`41 条规则全文`→`42 条规则全文` |
| CA-6 | task-planner/references/critical-rules.md:182（卫星清单行） | 更新 | 增量 | 同上 | 列表追加 `90` |
| CA-7 | selftest-*.sh 纪元锚行（`1-8[0-9]`×52/`1-8[0134]`×21/`'1-89'`×1 分布于 20 脚本，实跑 FAIL 清单为准） | 更新 | 增量（锚放宽非断言收缩，v169 纪元扩展先例） | 记忆判例「1-90 会再炸一次」 | 逐 site 读注释契约→放宽正则含 9[0-9]→复跑绿；负样本契约不破坏 |
| CA-8 | plans/.rule-reservations.jsonl | 新增（attest 自动 reserve + 手动 land） | 增量 | Rule 20.6 | attest 登记 reserved；收口 `rule-reserve.sh land 90 task-v182-git-snapshot-commits` |
| CA-9 | plans/INDEX.md + plans/task-v182-*/（归档） | 更新/新增 | 增量 | Rule 81.1/81.4 | 归档后 INDEX 刷新，随收口提交入库 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

<!--
  WHAT: 本任务依赖的知识源清单(规范/官方文档/内部知识库/文献/图书)。
  WHY: 对齐任务知识库 — 凭记忆硬写是返工与造谣的首要来源;开工前确认知识源可获取。
  WHEN: 计划创建时填写;Phase 1 开工前逐项确认「已确认」列;必读项缺失 → STOP 记入 Errors Encountered。
-->
> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | 规则正文范式（85/86/87/88/89 五条先例：header 形态/建制段/子条/衔接/机制段） | skills/task-discipline/references/critical-rules-discipline.md:501-562 @master 84a67f8 | 必读 | ☑ |
| 项目内部文档/知识库 | Rule 27 Phase 级提交（新条款分工对象） | 同文件 :200-209 | 必读 | ☑ |
| 项目内部文档/知识库 | worktree-isolation 合并合约+§6.3 协调态提交纪律（衔接对象） | skills/task-planner/references/worktree-isolation.md:73-124 | 必读 | ☑ |
| 项目内部文档/知识库 | 纪元锚形态分布与演进判例 | selftest-absorption-discipline.sh:78-85（`1-8[0-9]`×52/`1-8[0134]`×21/`'1-89'`×1） | 必读 | ☑ |
| 项目内部文档/知识库 | 级联面清点（v181 先例=正文+SKILL 索引 2 文件；本次+critical-rules.md 卫星行） | git show 188050b --stat | 参考 | ☑ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

<!-- 
  在开始任何任务前，必须明确回答以下问题：
  1. 核心问题是什么？
  2. 解决这个问题后，结果能交付吗？
  3. 解决这个问题的方法是什么？
-->
**核心问题**: 技能流程只锚定「执行中逐 Phase 提交」（Rule 27）与「协调态收口随行」（worktree-isolation §6.3），任务级**开始前基线**与**结束后终态**两端无强制 Git 快照——长任务中断/计划文件截断（ENOSPC 实证判例）/误操作时，起点无恢复源、终点无归档锚，可恢复性与可控性断链。解决后结果能交付：Rule 90 条款把两端快照制度化，R2-R5 全覆盖。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（条款在位+回归绿+本任务 dogfood 首尾提交）
- [x] 核心问题不解决，其他工作都白费吗？（条款不落，Git 备份诉求仍靠会话自觉，下次任务照样裸奔）
- [x] 核心问题的解决方法是清晰的、可执行的？（87/88/89 五条先例范式+级联面已清点）

**如果无法回答核心问题，禁止开始任务！**

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）
<!-- Rule 75.1 载体：计划期为每个子目标/S-unit 强制标注调研三态之一。NET-* 条目必登记关键词+渠道+产出形态。
     豁免：mini 档任务整体豁免（Rule 38.3 区块白名单同口径）；纯机械 S-unit 默认 LOCAL-ONLY 无需逐行标注 -->

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| S1 条款撰写 | LOCAL-ONLY | 既有五条先例范式；Rule 27/81 分工锚 | 本仓 discipline 文件+worktree-isolation.md | Rule 90 条款文本 | 不适用 |
| S2-S3 索引级联 | LOCAL-ONLY | 1-89 索引行；85,86,87,88,89 列表行 | grep 主仓索引面 | 索引行更新 | 不适用 |
| S4-S7 纪元锚放宽 | LOCAL-ONLY | `1-8[0-9]` 锚形态；v169 纪元扩展先例 | 实跑 selftest 全集出 FAIL 清单 | 锚正则放宽+复跑绿 | 不适用 |
| S8-S10 收口 | LOCAL-ONLY | rule-reserve land；archive-plan.sh | 本仓 scripts | 台账 land 行+归档+INDEX | 不适用 |

> 三态判定：LOCAL-ONLY=本地数据可完全解决（纯机械/簿记/既定步骤）；NET-RESEARCH=需网络调研补充知识/方案/报错解法；NET-DATA-DEPENDENT=必须接入网络数据（实时信息/外部 API/媒体参考/现成实现）。无 NET-* 条目且无豁免声明=计划不完整（check-plan-dispatch 机器校验）。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!--
  WHEN: 计划创建时填写（适用判定:产出=结论/判断/建议/原因解释的任务）
  WHY: Rule 58.1 证据面清单——下结论前三类基线证据面缺一不可,防「无对标就下结论」(用户 2026-10-07 判例:竞品分析没做就归因流量问题)
  豁免: 纯执行类任务(单点动作)填 `n/a（纯执行类）`;对标面豁免仅限 58.2 两种登记理由,禁裸豁免
-->
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| n/a（纯执行类：制度文本落地任务，无调研/归因结论产出） | - | - | - | ☑ |

> 归因类结论（为什么没流量/为什么不如人）在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）。

## Current Phase
<!-- 
  WHAT: Which phase you're currently working on (e.g., "Phase 1", "Phase 3").
  WHY: Quick reference for where you are in the task. Update this as you progress.
-->
Phase 1（实施+验收合一，进行中）

## Next Step
<!-- 
  WHAT: 单一下一步动作(一句话,可执行)。
  WHY: 恢复会话/上下文压缩后无需推断"接下来干嘛";5Q 第 6 问的答案源;smart 注入块每轮携带本字段。
  WHEN: Phase 状态每次变更时同步刷新(Rule 20.4);完成一个动作后立即更新为再下一步。
  EXAMPLE: "派 code-assistant 修复 src/auth.ts 的 token 空值判断,然后跑 bun test"
-->
attest 锁定计划 → 首锚提交（计划入库，Rule 90 首次实践）→ 建 worktree 落地 S1-S3

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!--
  WHAT: 逐 Phase 登记命中的 harness 执行工具面与选择理由（Rule 40.1 六类: /workflow 动态工作流、/goal 会话目标、Agent 子代理、卫星技能、MCP/平台工具、机械守卫脚本）。
  WHY: 计划期显式选择最合适的执行工具,替代"默认只有串行 Agent 派发一条路"的隐式决策;记录工具选择的可追溯依据。
  WHEN: 计划创建时（plan-writer）填写;执行期工具变更时回填。
  定位声明: 本区块是 Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变）;本区块内禁止出现 Phase/Status/Executor 三形态伪行。mini 档豁免本区块（Rule 38.3 区块白名单）。机器校验边界见 Rule 40.5（LLM 行为面,selftest-tool-selection.sh 静态守护）。
-->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | 机械守卫脚本（selftest 全集）+ Agent 子代理 Verifier（独立终验）+ /goal 会话目标（用户已锚定） | 条款文本精修主进程承载（白名单②）；回归实跑走脚本；终验独立性走子代理 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件（单链纯文本级联+S-unit 间强依赖：条款→索引→锚→收口顺序执行，无可并行独立子任务）→ 串行推进。
**/goal 对齐（Rule 40.3）**: 用户已用 /goal 锚定本任务——本计划 Goal+VC 表即 session goal 证据源；R1-R5 与 /goal 目标指令逐字对应。

## Phases
<!-- 
  WHAT: Break your task into 3-7 logical phases. Each phase should be completable.
  WHY: Breaking work into phases prevents overwhelm and makes progress visible.
  WHEN: Update status after completing each phase: pending → in_progress → complete
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;选型按 SKILL.md §子代理路由与模型分级路由表;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3);S-unit 表「执行体」列:默认写"继承"(= Phase Executor),混用模型时逐行写具体 subagent_type(model);check-plan-dispatch.sh 在计划批准时校验(22.6/25.1)
-->

### Phase 1: 实施+验收合一（L0-T 纯文本档 · worktree 隔离）
<!-- 单 Phase 合一（v181 先例 188050b）：条款文本+索引级联+锚回归+收口全部在一个 Phase 内串行闭环，S-unit 间强依赖无并行面 -->
- [ ] S1 Rule 90 条款文本落地（discipline 文件末段追加 90.1-90.6）
- [ ] S2-S3 索引级联（三载体 8 处索引行同步含 90）
- [ ] S4-S7 纪元锚：基线跑→FAIL 清单→批式放宽→全集复跑绿
- [ ] S8-S9 台账 land 90 + 合并回 master + 归档 + INDEX 刷新 + 收口提交
- [ ] S10 Verifier 子代理独立终验（VC-1..VC-6 全量复核）
- [ ] 知识储备必读项已确认可获取(勾选「必要知识储备」表"已确认"列)
- **V-N:** VC-1, VC-2, VC-3, VC-4, VC-5, VC-6
- **Status:** in_progress
- **Executor:** 主进程（例外理由: Rule 25.3 白名单② 计划系统文件维护——本任务域=task-planner 技能自身规则文本+级联锚精修，多文件级联需逐处 grep 验证，v181 先例同判；S5 独立终验派发 Verifier 子代理保证验证独立性）
<!-- 
  STATUS VALUES:
  - pending: Not started yet
  - in_progress: Currently working on this
  - complete: Finished this phase
-->

<!-- S-unit 派发单元表(Rule 22.6 — 主进程白名单直做+独立终验派发混合；机器契约: 预估时长 NNmin 格式/ID 纯数字/粒度三值/伴飞技能/前置依赖必填)

<!-- S-unit 派发单元表(Rule 22.6 — Executor≠主进程的 Phase 计划期必填;每行 = 一次 Agent() 派发;单步 ≤step_max_files(2) 文件 / ≤step_max_lines(100) 行 / ≤step_max_minutes(15) 分钟,超限再拆而非升档;「执行体」列可写"继承"或具体 subagent_type(model);「输入」列在计划期预写材料包 = 路径 + ≤10 行摘要,执行期照单派发)
  机器契约速记(check-plan-dispatch.sh attest 校验): 预估时长 NNmin 格式逐行数值校验（Rule 59.1）/输入列文件路径 token ≤2/ID 列纯数字禁字母后缀（task-v076 教训）/粒度三值 Nf/Nl/Nmin/伴飞技能非「无」校验 SKILL.md 路径存在（Rule 59.2）/前置依赖必填无则 -（Rule 68.1）；S1-S4 主进程白名单②直做行（粒度列为诚实记录供对照），S5 为唯一子代理派发行
-->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | Rule 90 六子条追加 discipline 末段 | 主进程(白名单②) | skills/task-discipline/references/critical-rules-discipline.md:551-562（89 段范式+追加锚） | `grep -cE "^- \*\*90\.[1-6]"`=6 | 10min | 1f/20l/10min | 无 | - | pending |
| S2 | 核心 SKILL.md 5 处索引同步 1-90/76 条 | 主进程(白名单②) | skills/task-planner/SKILL.md:9/17/162/175/217 | `grep -c "1-90"`≥2 | 10min | 1f/8l/10min | 无 | S1 | pending |
| S3 | 卫星索引 2 处+critical-rules.md 1 处含 90 | 主进程(白名单②) | skills/task-discipline/SKILL.md:24,80+skills/task-planner/references/critical-rules.md:182 | 含 90 计数 ≥3 | 10min | 2f/4l/10min | 无 | S2 | pending |
| S4 | 全集 selftest 基线跑出 FAIL 清单 | 主进程(白名单②) | skills/task-planner/scripts/selftest-*.sh（遍历） | FAIL 清单落 progress.md | 5min | 0f/2l/5min | 无 | S3 | pending |
| S5 | 锚放宽批次 1（FAIL 清单前 2 脚本） | 主进程(白名单②) | progress.md S4 FAIL 清单锚 | 批内脚本单跑 PASS | 10min | 2f/4l/10min | 无 | S4 | pending |
| S6 | 锚放宽批次 2+（批式重复至清单清零） | 主进程(白名单②) | progress.md FAIL 清单余量 | 批内脚本单跑 PASS | 10min | 2f/4l/10min | 无 | S5 | pending |
| S7 | 全集复跑零 FAIL 确认 | 主进程(白名单②) | skills/task-planner/scripts/selftest-*.sh（遍历） | 遍历输出无 FAIL 行 | 5min | 0f/2l/5min | 无 | S6 | pending |
| S8 | land 90+worktree 合并回 master | 主进程(白名单①) | worktree 产出+plans/.rule-reservations.jsonl | 台账 landed 行+merge commit | 10min | 2f/2l/10min | 无 | S7 | pending |
| S9 | 归档+INDEX 刷新+收口提交 | 主进程(白名单①+②) | scripts/archive-plan.sh+plans/INDEX.md | 归档成功+INDEX 刷新+收口 commit | 10min | 2f/3l/10min | 无 | S8 | pending |
| S10 | VC-1..VC-6 独立复核 | Verifier(haiku-1) | plans/task-v182-git-snapshot-commits/task_plan.md（VC 表） | 六 VC 逐条 PASS/FAIL 报告 | 10min | 0f/0l/10min | 无 | S9 | pending |

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
<!-- 
  WHAT: check-conflicts.sh 扫描结果与工作树隔离决策。
  WHY: 本仓多为运行中基础设施(skills/hooks/config 被所有会话实时使用),直接改动可能使功能工作期间半残;
       worktree 隔离 = 改动在副本上完成,验证后原子合并回原分支。
  WHEN: 计划创建时(init 后)运行 check-conflicts.sh 并填写;合并回后更新 merge_back。
-->
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号① 3 个未提交 selftest 脚本=在途 task-defect-rrv13-dg12-false-pass 域，**落点零交集**已实证：3 文件不含纪元锚族；信号⑤ 同上 3 文件属运行基础设施；信号③ 遗留 wt/task-v168-machine-parked 分支=他域遗留，知悉不碰；§6.1 三查已完成） |
| `isolation` | `worktree`（技能文件=运行中基础设施；v180 D6 用户裁决先例：技能改动走 worktree） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v182-git-snapshot-commits` |
| `branch` | `wt/task-v182-git-snapshot-commits` |
| `merge_back` | `queued`（对端 dynamic-workflow 缺陷修复运行 06:49 活跃、其在途未提交改动与合并路径重叠——§6.2 排队续跑，恢复条件与续跑步骤见 progress.md 等待态登记；分支 cedb834 全量产出就绪待并） |
| `排队/协调前置` | 在途 task-defect-rrv13（今晨 05:44 后无动作，progress 缺失疑似中断）：持有 selftest-decision-grading/registry.tsv/report-reviewability 未提交改动——与本任务落点零交集（锚族 grep=0）；若其收口提交触碰本任务 scope 文件→合并时并集解；禁代管/禁代提交他域未提交改动（Rule 88.2①） |

> 契约详见 `${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/references/worktree-isolation.md`（决策矩阵/生命周期/合并回合约/反模式）。

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/references/methodology.md §R2）

<!--
  WHAT: 对每个 Phase 枚举失败模式，打 S(严重度)/O(频度)/D(探测难度) 各 1-10 分，RPN=S×O×D。
  WHY: RPN>100 的高风险 Phase 必须预先登记兜底动作（对齐 Rule 22.3 五档兜底链，task-v113 后含 22.3.0 资料先行档），避免执行期临时决策。
  WHEN: 计划创建时填写（高 RPN 项）；纯文档/调研类小任务可写 n/a。
  开关键: config.json#fmea_enforce（默认 warn；enforce 档下 RPN>100 无兜底登记 = 计划无效）。
-->

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 1 | 纪元锚放宽误伤负样本契约（v166 判例：锚演进有正/负样本双向语义） | 7 | 5 | 4 | 140 | 逐 site 先读锚行上方注释的负样本契约再改（③拆细）；改后全集实跑复验，FAIL 即回退单 site（⑤主进程接管）；仍不通→22.3.0 资料档查 v169 纪元扩展 commit 先例 |
| Phase 1 | 合并回时与在途 task-defect-rrv13 冲突（其 3 文件与本任务零交集，风险低但非零） | 6 | 2 | 2 | 24 | 合并前重跑 §6.1 三查；冲突→并集解（保留双方语义）+ 登记 |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填（写清走 22.3 哪一档：改派/拆细/降档/主进程接管/AskUserQuestion）；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链，两者不互相替代。（AskUser/呈报按 Rule 70 四要素）

## 🔁 原生 Todo 同步（S1–S5 强制）
<!-- 
  WHAT: 计划文档 ↔ 原生 Todo（TodoWrite / Task 系统）的同步状态追踪。
  WHY: 计划文档是唯一事实源，Todo 是执行视图；不同步 = 执行视图丢失目标。
  WHEN: S1 计划创建后建映射 / S2 Phase 状态变更后紧邻同步 / S3 收到 [plan-sync] 提醒立即回写 / S4 会话结束前终态同步 / S5 用户新指令影响计划后先改计划再重映射 Todo。
-->
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1（S1-S5 单 Phase） | ☑ | 2026-10-16（S1 建映射） | 单 Phase 合一，Todo 按 S-unit 建条 |

> 契约详见 `${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions
<!-- 
  WHAT: Important questions you need to answer during the task.
  WHY: These guide your research and decision-making. Answer them as you go.
  EXAMPLE: 
    1. Should tasks persist between sessions? (Yes - need file storage)
    2. What format for storing tasks? (JSON file)
-->
1. [Question to answer]
2. [Question to answer]

## Decisions Made
<!-- 
  WHAT: Technical and design decisions you've made, with the reasoning behind them.
  WHY: You'll forget why you made choices. This table helps you remember and justify decisions.
  WHEN: Update whenever you make a significant choice (technology, approach, structure).
  EXAMPLE:
    | Use JSON for storage | Simple, human-readable, built-in Python support |
-->
| Decision | Rationale |
|----------|-----------|
| D1 新规则编号=90（rule-reserve check 空闲+台账尾部 87/88/89 已 land） | Rule 20.6 first-come-first-served；`bash rule-reserve.sh check 90`→free 实证 |
| D2 落点=task-discipline 卫星 discipline 文件末段追加（非核心 critical-rules.md） | 87/88/89 三条同域先例全落此文件（执行纪律域）；核心域只留 14 条索引（Rule 82 分层纪律） |
| D3 L0-T 纯文本档：零新守护脚本/零新 config 键/零新 selftest 脚本；既有 selftest 纪元锚仅做「保绿」放宽 | §四.6 文本优先铁律+Rule 38.7：守护机器化=opt-in，用户未显式要求；纪元锚放宽=既有测试保绿义务非新增门 |
| D4 worktree 隔离（推翻「direct 直改」选项） | §十一.1 保护区+运行中基础设施；v180 D6 用户裁决先例；主仓有他域在途未提交改动（3 selftest 文件），worktree 天然隔离 |
| D5 本任务自身首尾提交即 Rule 90 dogfood 首实践（首锚提交=计划 attest 后入库；收口提交=归档+INDEX 随行） | 用户 R2/R3 诉求本体；VC-6 固化为验收 |
| D6 在途 task-defect-rrv13 处置=知悉不碰不排队（落点零交集实证） | §6.1 三查：3 未提交文件无纪元锚族；代管/代提交他域改动违反 Rule 88.2①（task-v180 判例） |

## Errors Encountered
<!-- 
  WHAT: Every error you encounter, what attempt number it was, and how you resolved it.
  WHY: Logging errors prevents repeating the same mistakes. This is critical for learning.
  WHEN: Add immediately when an error occurs, even if you fix it quickly.
  EXAMPLE:
    | FileNotFoundError | 1 | Check if file exists, create empty list if not |
    | JSONDecodeError | 2 | Handle empty file case explicitly |
-->
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
|       | 1       |            | → progress.md Error Log   |

## Notes
<!-- 
  REMINDERS:
  - Update phase status as you progress: pending → in_progress → complete
  - Re-read this plan before major decisions (attention manipulation)
  - Log ALL errors - they help avoid repetition
  - Never repeat a failed action - mutate your approach instead
-->
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition

## 🚨 Drift Log（漂移检测记录）
<!-- 
  WHEN: 每次派发 drift-checker 偏移检查（Rule 61 载体）后追加一行记录
  FORMAT: | timestamp | 结果 | VC条目 | 结论 |
-->
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |             |        |      |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6,批量任务必填）
<!-- 
  WHEN: chain_mode: fan-out 或 批量操作 ≥5 单元时必填;纯单次任务可删除整个区块
  WHY: 批量操作禁止以牺牲质量/准确性为代价(Rule 18);前置 3 问 + 双采样抽检 + 失败率熔断的落盘证据
  校验: failure_rate >5% → Phase 禁止 complete;sampled_fail >0 → 整批未验证;pre_check 缺项 → plan-writer 校验失败
  完整模板: ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/templates/batch_report.md | 规则详解: ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/references/batch-quality-gate.md
-->
| 字段 | 值 |
|------|-----|
| `total` |  |
| `success` |  |
| `failed` |  |
| `failure_rate` | （>5% → STOP;>20% → 熔断回滚） |
| `sampled_pass` | （运行后抽 10%） |
| `sampled_fail` | （运行前抽 2,>0 → 整批熔断） |
| `pre_check` | （Q1:否/Q2:有/Q3:能） |
| `rollback_point` | （为空 → 禁止批量） |

## 📊 委派统计（Rule 25.4 — 终验前必填）
<!-- 
  WHAT: 本计划子代理 vs 主进程的执行分布统计。
  WHY: 子代理占比需要可见反馈闭环;委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由 → outcome 最高 PARTIAL(白名单见 critical-rules.md Rule 25.3)。
  WHEN: 每个 Phase complete 后更新;终验交付前必须完整。
-->
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  /  |
| 主进程直做 Phase 清单 | （含例外理由） |
| 委派率 | （< delegation_rate_floor 默认 0.7,或含白名单外理由 → 最高 PARTIAL） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
<!--
  WHEN: 每次 Agent() 派发前填一行;子代理返回 30s 内主进程必须 Read 实际产出 + 紧邻 Edit findings.md 回填结论(「findings 落点」列记段落锚点),两动作完成才在「备注」列勾 verify_done;failed/timeout 行必须回填 checkpoint 路径列(Rule 22.8.4)
  WHY: 子代理规模限制 + 交接文件保障(Rule 22);findings 回填绑定(Rule 19.1/22.5)防止结论只留会话记忆
  状态枚举: queued/pending/running/done/partial/timeout/failed/blocked/scaling-redispatch(22.3.1 provider 失败改派)
  列说明: 备注列 = 低频列折叠单列(rescue 换档挽救记录 档位/结果/时间,failed|timeout 行必填,Rule 22.7;retry_count = 22.3 retry_limit 计数,初值 0,每次重试 +1;verify_done☐ = Read 产出 + findings 复核/回填双条件,Rule 22.5)——字段内容不删,仅列位折叠;verify_done 无机器消费(grep 实证 scripts/*.sh 除 selftest 零命中),为人工义务,不声称机器门
  派发 prompt 八字段模板: ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/templates/subagent_dispatch.md
  # [2026-09-27 task-v091 B-2] 单写者澄清+Handoff 低频列折叠（verify_done 无机器消费如实披露）
-->

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | | | | queued | | | | | - / 0 / ☐ |
| 2 | | | | | | | | | - / 0 / ☐ |
| 3 | | | | | | | | | - / 0 / ☐ |

## 🔗 Chain 区块交接配置（可选）

<!-- 仅多 skill 接力任务填写（如：调研→创作→发布）。单 skill 任务可删除此整个区块。 -->

### Chain 模式

| 字段 | 值 |
|------|-----|
| **chain_mode** | `single` / `linked`（串行接力）/ `fan-out`（一对多派发） |
| **current_block** | Block 1 |
| **handoff_on_complete** | ✅ 是 / ❌ 否 |

### Block 1: [本块名称]（当前块）

| 字段 | 值 |
|------|-----|
| **goal** | [本 block 独立目标] |
| **depends_on** | none |
| **passes_to** | Block 2: `[交接产物路径]` |
| **status** | in_progress / pending / complete |

### Block 2: [下游块名称]

| 字段 | 值 |
|------|-----|
| **goal** | [下游 block 目标] |
| **depends_on** | Block 1 → `[交接产物路径]` |
| **passes_to** | Block 3: `[...]` |
| **status** | pending |

<!-- 追加 Block N 时使用相同结构 -->

### 🔗 Handoff 追踪表

| Block | 状态 | 交接产物路径 | 验证命令 | 实际完成时间 |
|-------|------|------------|---------|-------------|
| Block 1 | - | - | - | - |
| Block 2 | - | - | - | - |

---
<!-- ★ Block 分隔符：每个独立交接区块下方用 --- 分隔，格式如下 -->
<!--
### Block 2: [名称]
## Goal
...
## Phases
...
（复制完整 task_plan 结构，仅包含本 block 的 Phase 和 VC）
-->

## 🔁 模板感知
<!-- template_type: general -->
<!-- task-v096 P2-S1: 运行时追加区块（非模板本体）; general=类型空缺兜底, 已知 16 类类型不产生本区块;
     上方注释行为 check-template-type 第三形态机读标记（general 恒合法, gate exit 0）, 同时完成 Rule 34.3② 预登记 -->
- 触发信号: 任务类型空缺 → 落 general 兜底（非 16 类已知类型之一）
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: **不沉淀**——理由：本任务=规则文本增量落地（v179/v180/v181 同族，走 critical-rules-discipline.md 正文通道），非可复用任务类型；无新模板形态产出
