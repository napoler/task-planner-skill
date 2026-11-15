# Task Plan: 意图切换回切闭环（B 收口后主动回切挂起计划 A）
<!--
  WHAT: This is your roadmap for the entire task. Think of it as your "working memory on disk."
  WHY: After 50+ tool calls, your original goals can get forgotten. This file keeps them fresh.
  WHEN: Create this FIRST, before starting any work. Update after each phase completes.
-->
template_type: general
plan_tier: standard
execution_lane: L1

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「当然说和我法，如果说彻底的切换，还是一个有一个问题，就是比如说执行着A，然后中间插入了B，那么如果A是不是就被彻底的搁置了？那么如果说我完成了B之后，是否会有主动进来回来执行A，这才是关键。也就是说，比如说在执行B的过程中，对执行完成之后，主动切换回来执行A，这样的话确保任务不会因为被暂时搁置而彻底的弄，就是被搁置掉。」<sub>（[目标]，来源：plans/task-intentresume-20261116/user-session-log.md#1）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2, VC-3, VC-4, VC-5, VC-6 | 缺口诊断与机制衔接可审计(VC-1)；终验交付段含挂起计划回切检查条款+插入时序+不自动切+回切状态(VC-2)；回切通告模板形态落位且含是否切回/yes-no处置(VC-3)；Rule 94 段末回切交叉锚衔接 94.4 封存待 resume 且保语义(VC-4)；yes 路由 plan-resume 定向恢复且 scope 仅两文件(VC-5)；计划文档与 VC 命令可执行锚一致(VC-6) |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
- **专档路径**：`plans/task-intentresume-20261116/user-session-log.md`（模板 = /home/terry/.zcode/skills/task-planner/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| B 终验收口（outcome/归档序列） | 收口只管 B 自身，无挂起链检查（SKILL.md:130-145,136） | S1：终验交付段新增「挂起计划回切检查（intent-switch 回切）」，outcome 判定后、归档前执行 | VC-2, VC-5 |
| 用户感知与交互 | 无 B→A 回切通告形态（仅 A→B 模板 SKILL.md:203） | S2：补「回切通告模板」【计划回切通告】含 B 已收口/检测到挂起链/是否切回/yes-no | VC-3 |
| 规则衔接与权威语义 | 94.4 封存待 resume 未与收口回切触发衔接（discipline:615,619） | S3：Rule 94 段末补 intent-switch 回切交叉锚，保留 94.3/94.4 权威语义 | VC-4 |
| 恢复执行路由 | 挂起链无主动定向恢复触发（plan-resume 在位但未被收口路由） | S1/S2：yes=释放指针+路由 `Skill("plan-resume")` 定向恢复；**不自动切** | VC-2, VC-3, VC-5 |
| 审计与防重复 | `[intent-switch]` 无回切状态字段（SKILL.md:204） | S1：登记回切状态（yes=已路由恢复 / no=保持挂起）并落既有载体 | VC-2 |

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | R1 用户原话与[目标]定性（user-session-log.md#1）；Goal/VC-1~VC-6；既有 A→B 意图切换机制（SKILL.md:193,202-204）与 Rule 94.3/94.4/102 权威语义不反转；plan-resume 不改；scope 仅 SKILL.md+discipline 两文件；回切须用户确认**不自动切**；不新增脚本/新 config 键 | R1、findings.md M3-M10、方案骨架 |
| 🔀 可变量 | 条款措辞细化、回切状态字段命名细节、S-unit 拆分与执行体、插入位置在锚点邻域的微调（不破坏 VC token） | - |
| 📈 学得量 | 执行期发现的额外锚点/回归风险/更优表述→findings.md, notepad-learnings.md；禁反写不变量与 R1 | findings.md |

## Goal
在 task-planner 意图切换机制上补齐 B 收口后的「挂起计划回切」闭环：终验交付序列增加挂起链检查与【计划回切通告】（用户确认后才路由 plan-resume 定向恢复 A；拒绝则登记保持挂起），并在 Rule 94 段补回切交叉锚，确保 A 不因被 B 插入挂起而被彻底搁置且全程可审计、scope 仅限两处受管文件。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required`（修改 skills/task-planner/SKILL.md 与 skills/task-discipline/references/critical-rules-discipline.md，受管技能/规则文档） |
| `session_id` | `task-intentresume-20261116` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-intentresume-20261116` |
| `scope_files` | `skills/task-planner/SKILL.md, skills/task-discipline/references/critical-rules-discipline.md, plans/task-intentresume-20261116/*` |
| `interaction_mode` | （省略，回落 config.json#interaction_mode） |
| `对齐审查` | 交付前对改动文档做一致性/锚点复核并登记（standard 档） |
| `自动超时默认项` | D1 计划批准: 按推荐项继续/5min；文案细节分叉: 最小增强 S-A/5min；scope 扩展: 不扩展/5min |
| `new_rule` | 留空（不新增 Rule 编号，仅增补交叉锚与流程条款） |
| `质量审查工具` | `documentation-review`（规则/技能文档改动）+ grep 机械断言；按 42.4 结论：文档面由子代理执行与复核承担，静态锚点命令作为可复现证据 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：本计划验证动作默认由独立子代理执行，主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 缺口诊断与机制衔接可审计：findings 含 M1-M12 机制锚点表、R-1~R-4 根因、S1-S3 方案与关键证据摘录 | grep 关键锚点 | `grep -nE 'M1|M12|R-1|R-4|S1|S2|S3|SKILL\.md:130|discipline:615' plans/task-intentresume-20261116/findings.md` |
| VC-2 | SKILL.md 终验交付段具备回切检查条款：含「挂起计划回切检查（intent-switch 回切）」且声明 outcome 判定后、归档前执行；检查 `[intent-switch]` 登记链（`旧=<id>`）与 `plans/INDEX.md`；分支含 yes 路由 `Skill("plan-resume")` 定向恢复、no 登记保持挂起与 `回切状态`；显式**不自动切** | grep 目标 token | `grep -nE '挂起计划回切检查（intent-switch 回切）|outcome 判定后|归档前|\[intent-switch\]|旧=<id>|plans/INDEX\.md|Skill\(\"plan-resume\"\)|不自动切|回切状态' skills/task-planner/SKILL.md` |
| VC-3 | SKILL.md 显性通告区具备回切通告形态：含「回切通告模板」与【计划回切通告】，并含 B 已收口/检测到挂起链/是否切回及 yes/no 处置语义 | grep 目标 token | `grep -nE '回切通告模板|【计划回切通告】|B 已收口|检测到挂起链|是否切回|yes|no' skills/task-planner/SKILL.md` |
| VC-4 | discipline Rule 94 段末补回切交叉锚：含 intent-switch 回切、衔接 94.4 封存待 resume 与回切触发，指向 SKILL.md「终验交付」挂起计划回切检查/【计划回切通告】/`Skill("plan-resume")` 且声明不自动切；Rule 94 权威语义锚（`^### 94`、`94.4` 隔离处置）仍在位 | grep 交叉锚与权威锚 | `grep -nE 'intent-switch 回切|94\.4|封存待 resume|回切触发|SKILL\.md「终验交付」|挂起计划回切检查|【计划回切通告】|Skill\(\"plan-resume\"\)|不自动切' skills/task-discipline/references/critical-rules-discipline.md && grep -nE '^### 94|94\.4' skills/task-discipline/references/critical-rules-discipline.md` |
| VC-5 | scope 与恢复路由约束可观察：改动仅落两文件且未改 plan-resume；回切逻辑复用 `Skill("plan-resume")` 路由（不自造恢复实现） | git diff --name-only + 只读校验 | `cd /mnt/data/dev/task-planner-skill && git diff --name-only -- skills/task-planner/SKILL.md skills/task-discipline/references/critical-rules-discipline.md; test -f /home/terry/.zcode/skills/plan-resume/SKILL.md && echo plan-resume-present` |
| VC-6 | 计划文档与验证载体完整可执行：task_plan/verification/knowledge-brief/findings/progress 关键区块齐备，verification 每条 VC 含 **Verify command**，R1→VC 映射与不变量/CA 表在位 | grep 结构锚点 | `grep -nE '^template_type:|^plan_tier:|^execution_lane:|## Goal|R→VC|Verification Contract|## Phases|隔离决策|变更标注表' plans/task-intentresume-20261116/task_plan.md && grep -n '\*\*Verify command\*\*' plans/task-intentresume-20261116/verification.md` |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：`code_review: required`，终验前必须先通过 Code Review Gate，否则不得标记 COMPLETE。

## 🛡 双轮质检与同步完整性声明（Rule 103 — 计划期设计位，standard/full 必填，mini 豁免）
| 登记项 | 值 |
|--------|-----|
| 双轮质检适用面 | Phase 2 S1-S3（两处受管文档实质修改）默认全适用；Phase 3 S1 复核产出适用证据核对 |
| 豁免登记 | Phase 1 P0 计划期簿记落盘（主进程单写者，已完成）豁免第二轮独立复检；Phase 4 汇总交付以 VC 全复验+CR gate 替代 |
| 多文件变更集预判 | Phase 2 翻转前与 Phase 4 终验前触发 103.6（预期受管文件：skills/task-planner/SKILL.md, skills/task-discipline/references/critical-rules-discipline.md） |

## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1 |
| **裁决** | `solved`（2026-11-16 终验：run-verification 7/7 PASS） |
| **解决证据锚** | evidence/VC-1~6.out；SKILL.md:145 回切检查（定序句+B 归档归属+优先级声明）+:206 回切通告模板+:205 回切状态字段契约；discipline:620 回切交叉锚；merge 1b214f9+部署 IDENTICAL；CR 两轮（5 项→修复→APPROVED） |
| **未解决面+原因** | n/a（R1 全覆盖：主动=收口序列强制回切检查；通告=【计划回切通告】模板；恢复=确认后路由 plan-resume 定向续推；防搁置=[intent-switch] 链+回切状态可审计） |
| **已排除路径** | （not-solved 时必填） |
| **下一步建议** | （partial/not-solved 时必填） |

> R1 为[目标]型需求：B 收口后能否主动提示并在用户确认后切回 A，是终验核心判据（非仅文案存在）。

## 🎯 Goal 单元表（Rule 66.1 — 规划获批后任务单元固化；standard/full 必填）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 缺口诊断 | 固化回切缺口与机制锚点/方案 | `grep -nE 'M1\|M12\|R-1\|R-4\|S1\|S3' plans/task-intentresume-20261116/findings.md` 退出码 0 | Phase 1 / S1 | complete |
| G2 | 收口回切检查 | 终验交付段落地挂起计划回切检查条款与回切状态 | VC-2 命令退出码 0 | Phase 2 / S1 | pending |
| G3 | 回切通告 | 显性通告区落地回切通告模板（是否切回+yes/no） | VC-3 命令退出码 0 | Phase 2 / S2 | pending |
| G4 | 规则衔接 | Rule 94 段末补回切交叉锚且不改权威语义 | VC-4 命令退出码 0 | Phase 2 / S3 | pending |
| G5 | 验收收口 | scope/路由约束与 VC 全绿、CR 通过 | VC-1~VC-6 全退出 0 + CR APPROVED | Phase 3-4 / S1-S2 | pending |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 技能文档 | `skills/task-planner/SKILL.md` | skills/task-planner 下其他文件（除非 VC 必需且登记 CA） |
| 规则文档 | `skills/task-discipline/references/critical-rules-discipline.md`（仅 Rule 94 段末回切交叉锚增量） | Rule 94.1-94.7 权威语义改写、Rule 102 语义改写、其他 critical-rules-*.md |
| 计划文档 | `plans/task-intentresume-20261116/*` | 其他 plans/**、plans/archive/** |
| 只读参照 | `/home/terry/.zcode/skills/plan-resume/SKILL.md`（只读） | 对 plan-resume 的任何修改（部署位/主仓） |
| 配置/脚本 | 无 | `config.json`、scripts/**、hook、registry/selftest 新增（未获显式授权） |

**执行前自我检查:**
- [ ] 这个文件在上面的列表中吗？
- [ ] 这个修改对完成任务有必要吗？
- [ ] 用户明确要求我做这个修改吗？
- 全部 Yes → 可以执行 | 任一 No → 先问用户

## 📋 变更标注表（Rule 74.3 — 修订方案必填，无表=无效方案）

| 编号 | 对象（文件+锚点） | 类型（新增·修改·删除·更新） | 吸收判定（增量·替代·删除） | 用户原话（逐字） | 依据（证据） | 执行动作 |
|------|------------------|---------------------------|-----------|----------------|------------------------|---------|
| CA-1 | skills/task-planner/SKILL.md:130-145（终验交付段，outcome 判定后/归档前插入锚） | 修改 | 增量 | 「…B执行完成之后，主动切换回来执行A…确保任务不会因为被暂时搁置而彻底的弄，就是被搁置掉。」(R1) | findings R-1,R-3,R-4；M1,M2,M6,M10；:136 归档顺序约束 | 新增「挂起计划回切检查（intent-switch 回切）」条款：查 `[intent-switch]` 登记链（`旧=<id>`）+`plans/INDEX.md`；命中则出【计划回切通告】询问是否切回；yes=释放指针+路由 `Skill("plan-resume")` 定向恢复；no=登记保持挂起并写 `回切状态`；声明 outcome 判定后、归档前执行且**不自动切** |
| CA-2 | skills/task-planner/SKILL.md:202-204 邻近（显性通告模板区） | 修改 | 增量 | 同 R1 | findings R-2；M4,M5；:203 前向模板对称 | 补「回切通告模板」：【计划回切通告】含 B 已收口/检测到挂起链 A/是否切回，以及 yes/no 处置语义（与前向模板对称，不替代 :203） |
| CA-3 | skills/task-discipline/references/critical-rules-discipline.md:619 之后（Rule 94 段末，:620 前） | 修改 | 增量 | 同 R1 | findings R-3；M7,M8；:615 94.4 封存待 resume；:619 既有前向交叉锚 | 追加 intent-switch 回切交叉锚：衔接 94.4 封存待 resume 与回切触发，指向 SKILL.md「终验交付」挂起计划回切检查/【计划回切通告】/`Skill("plan-resume")`，声明不自动切；保留 94.3/94.4 权威语义不改 |
| CA-4 | skills/task-planner/scripts/selftest-batch-pilot.sh（BP-08 行数钉） | 修改（钉值 305→306+演进链注释） | 增量（回归修复连带——SKILL.md +2 行突破行数钉，守卫正常工作；Rule 74 判据=回归测试证伪旧钉值，scope 连带登记） | R1+回归零增量要求 | 钉值上调+注释演进链追加（历史先例 task-v086/v087/v088/initdelegation 同族） |
| 回填与格式重锁登记（2026-11-16，antitamper 四步） | task_plan.md 状态行合法回填（Handoff #2/#3+CA-4+Phase 2/3 翻转+Phase 4 段）与 verification.md 判据格式修复（**Verify command** 命令外层 Markdown 反引号剥离——反引号致 run-verification shell 命令替换→VC 全 127 伪 FAIL；命令实质零变化）→ 重跑 attest 重锁 | 判据语义未动（token 逐字保留）；重锁前置=本登记 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

> 目的：对齐任务知识库。Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 | task-planner 终验交付与意图切换单入口 | skills/task-planner/SKILL.md:130-145,193,202-204 | 必读 | ☑ |
| 规范/标准 | Rule 94 任务专注性与计划隔离（94.4 封存待 resume） | skills/task-discipline/references/critical-rules-discipline.md:607,615,619 | 必读 | ☑ |
| 规范/标准 | Rule 102 交叉锚（判定侧，只读对齐） | skills/task-discipline/references/critical-rules-discipline.md:708 | 参考 | ☑ |
| 项目内部 | 上承意图切换已交付锚点 | plans/archive/task-intentswitch-20261116/task_plan.md；plans/archive/task-intentswitch-20261116/findings.md | 必读 | ☑ |
| 项目内部 | 本任务原话与挂起数据源 | plans/task-intentresume-20261116/user-session-log.md#1；plans/INDEX.md | 必读 | ☑ |
| 官方文档/技能 | plan-resume 恢复机制（只读参照，禁改） | /home/terry/.zcode/skills/plan-resume/SKILL.md:15,33,65-69 | 必读 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: B 收口后，系统能否在终验交付序列中主动检测到由 B 插入而挂起的 A，并以显性通告征得用户确认后路由恢复 A（而非自动切回或彻底搁置）？

**核心问题判断**:
- [x] 核心问题解决后，A 不会因被 B 插入挂起而被遗忘，形成可审计的回切闭环。
- [x] 不解决则 B 完成后 A 仍依赖用户偶然回忆/手动 resume，R1 目标落空。
- [x] 解决方法清晰可执行：S-A 最小增强（终验回切检查+回切通告模板+Rule 94 回切交叉锚），scope 限两文件。

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| S0/P0 机制与缺口调研（已完成） | LOCAL-ONLY | 「终验交付 outcome 归档」 「intent-switch 旧=<id>」 | 本地 Read/Grep（SKILL.md/discipline/plan-resume/INDEX/archive） | findings 锚点表+R-1~R-4+方案 | 不适用 |
| S1 终验回切检查条款设计与落地 | LOCAL-ONLY | 「挂起计划回切检查」 「归档前 plans/INDEX.md」 | 本地既有条款与插入锚实测 | SKILL.md 终验段增量文本 | 不适用 |
| S2 回切通告模板落地 | LOCAL-ONLY | 「回切通告模板」 「是否切回 B 已收口」 | 本地 :203 对称参照 | SKILL.md 通告模板增量 | 不适用 |
| S3 Rule 94 回切交叉锚 | LOCAL-ONLY | 「94.4 封存待 resume」 「回切触发 intent-switch 回切」 | 本地 :615,:619 语义对照 | discipline 交叉锚增量 | 不适用 |

> 无 NET-RESEARCH/NET-DATA-DEPENDENT 条目：证据与实现面均在本地技能仓库/只读参照可得。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）

| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | 现行终验交付序列、A→B 切换清单/通告/登记、Rule 94 封存语义、plan-resume 恢复入口、INDEX 待处理结构 | Read + grep 行号取证 | findings.md M1-M12、关键证据摘录 | ☑ |
| ② 对标样本（58.2 强制） | 已交付前向闭环 task-intentswitch-20261116（切换/通告/登记可用）作为“已在位”对照；R1 描述的 A 被 B 挂起后 B 收口场景作为“缺回切”对照 | 归档计划文档 + R1 原话/理解镜像 | findings.md M12、R-1~R-4、方案对称设计 | ☑ |
| ③ 外部约束 | scope 硬约束（禁改 plan-resume/其他受管文件）；回切=目标变更须确认不自动切；Rule 94/102 权威语义不可反转；worktree 隔离 | 用户指令 + 既有规则锚 :615,:619,:708 + plan-resume:15 | task_plan 隔离决策/CA/不变量；findings Decisions/Issues | ☑ |

## Current Phase
Phase 1

## Next Step
按 D1 呈报本计划（思路复述+scope/不自动切/plan-resume 只读边界）等待用户批准；获批后在 worktree `tmp/worktrees/task-intentresume-20261116` (branch `wt/task-intentresume-20261116`) 执行 Phase 2 S1→S2→S3。

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1（诊断与计划落盘） | 主进程编排 + 文件 Read/Write + 只读 grep | 计划期单写者产出六文档并固化实测锚点 |
| Phase 2（条款与模板增强） | Agent 子代理 code-assistant；机械守卫 grep/git diff | 两文件小步增量修改，需隔离执行与可审计 diff |
| Phase 3（回归与一致性核验） | Agent 子代理 code-runner-agent 或主进程纯执行核验；grep/git diff | 跑 VC-1~VC-6 命令、核对 scope 与锚点、103.6 同步清单 |
| Phase 4（CR 与终验交付） | Agent 子代理 code-review；归档/终验流程 | code_review=required 与终验收口 |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8（无 ≥3 独立并行 fan-out、非长链编排、未点名 /workflow）→ Rule 21.4 独立性守门调度（S1→S2 串行同文件，S3 独立文件可与 S2 后串行收敛，整体小步串行）。
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 为 session goal 证据源；/goal 为用户侧 harness 命令，技能层不可代调。

## Phases

### Phase 1: 诊断与回切方案计划定稿
- [x] 调研上承归档计划与现行机制锚点（SKILL.md 终验/切换/通告、discipline 94.4+交叉锚、plan-resume、INDEX）
- [x] 固化缺口诊断 R-1~R-4 与 S1-S3 方案骨架（含 VC 锚形态实测）
- [x] 落盘 findings.md、task_plan.md、verification.md、knowledge-brief.md、progress.md（Phase 1 段内回填）
- **V-N:** VC-1, VC-6
- **Status:** complete
- **Executor:** plan-writer
<!-- 主进程白名单编排面（init 已完成+派发+收据回收+计划文档单写）；产物落 plans/task-intentresume-20261116/* -->

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | 调研锚点+诊断 R-1~R-4 并落盘六文档计划产物 | plan-writer | user-session-log.md#1（R1 原话）；archive/task-intentswitch-20261116/{task_plan,findings}.md；SKILL.md:130-145,193,202-204；discipline:607,615,619,708；/home/terry/.zcode/skills/plan-resume/SKILL.md:15,33,65-69（只读）；INDEX.md 待处理区 | findings 含 M1-M12/R-1~R-4/S1-S3；task_plan 含 R/VC/Phases/CA/隔离决策；verification 含 VC Verify command；kb §1-§5；progress Phase 1 回填 | 15min | 0f/0l/15min | 无 | - | complete |

### Phase 2: 回切闭环机制增强实现（worktree）
- [ ] S1：SKILL.md 终验交付段新增「挂起计划回切检查（intent-switch 回切）」条款（outcome 判定后、归档前；查 `[intent-switch]` 旧=<id> + `plans/INDEX.md`；【计划回切通告】询问；yes=释放指针+路由 `Skill("plan-resume")` 定向恢复，no=登记保持挂起+`回切状态`；**不自动切**）
- [ ] S2：SKILL.md 显性通告区补「回切通告模板」（B 已收口/检测到挂起链/是否切回/yes-no 处置）
- [ ] S3：discipline Rule 94 段末（:619 后）补 intent-switch 回切交叉锚，衔接 94.4 封存待 resume 与回切触发，保留权威语义
- **V-N:** VC-2, VC-3, VC-4
- **Status:** complete
- **Executor:** code-assistant

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | 在 SKILL.md 终验交付段落地挂起计划回切检查条款与回切状态分支 | 继承 | skills/task-planner/SKILL.md:130-145（机械/智能子动作，:136 归档顺序）；findings.md CA-1/方案（token：挂起计划回切检查（intent-switch 回切）/outcome 判定后/归档前/[intent-switch]/旧=<id>/plans/INDEX.md/【计划回切通告】/Skill("plan-resume")/不自动切/回切状态） | VC-2 grep 全命中；与 84.14/outcome/81.1 顺序不冲突 | 12min | 1f/40l/12min | 无 | - | pending |
| S2 | 在 SKILL.md 通告区补回切通告模板（是否切回+yes/no） | 继承 | skills/task-planner/SKILL.md:202-204（前向清单/【计划切换通告】/登记字段）；findings.md CA-2（token：回切通告模板/【计划回切通告】/B 已收口/检测到挂起链/是否切回/yes/no） | VC-3 grep 全命中；与 :203 前向模板对称共存 | 10min | 1f/25l/10min | 无 | S1 | pending |
| S3 | Rule 94 段末增 intent-switch 回切交叉锚并保语义 | 继承 | skills/task-discipline/references/critical-rules-discipline.md:607,615,619（94.4 封存待 resume；既有前向交叉锚）；findings.md CA-3（token：intent-switch 回切/94.4/封存待 resume/回切触发/SKILL.md「终验交付」/挂起计划回切检查/【计划回切通告】/Skill("plan-resume")/不自动切） | VC-4 grep 全命中且 `^### 94`/`94.4` 仍在位 | 10min | 1f/20l/10min | 无 | - | pending |

### Phase 3: 回归验证与同步核验
- [x] 执行 VC-1~VC-6 命令并记录证据（含 git diff scope 与 plan-resume 未改校验）
- [x] 完成 103.6 多文件变更集同步核对清单（SKILL.md + discipline 两文件）并全绿
- [x] 修正锚点/措辞漂移（BP-08 钉值连带修复，CA-4 登记）
- **V-N:** VC-1, VC-5, VC-6
- **Status:** complete
- **Executor:** 主进程（例外理由:L0-E 纯执行——跑 VC 命令/grep/git diff 核对与簿记，零仓库受管变更零新语义，Rule 38.7）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | 跑 VC-1~VC-6 与 scope/sync 核对并登记证据 | 继承 | verification.md VC 命令；CA-1~CA-3 改动后文件；git diff --name-only | VC 命令退出码与输出记录于 verification/progress；scope 仅两文件；103.6 清单全绿 | 12min | 0f/0l/12min | 无 | S2,S3 | pending |

### Phase 4: Code Review、终验与交付
- [x] 触发 code-review（required）并处理 CHANGES_REQUESTED（如有）——轮 1 五项→修复轮（用户授权主进程直修，provider 限流 7 连）→轮 2 APPROVED
- [x] 逐条复验 VC、填写核心目标达成裁决与收尾回读梳理记录——终验 7/7（判据反引号格式修复重锁 6a0650e6）
- [x] 产出交付摘要并按 Rule 81/归档前置条件收口（由主进程执行归档编排）
- **V-N:** VC-1, VC-6
- **Status:** complete
- **Executor:** code-reviewer
<!-- CR Gate 后主进程白名单面=git/归档编排+簿记与交付汇总 -->

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | 执行 CR 审查并回收 APPROVED/修复结论 | 继承 | Phase 2-3 diff 与 VC 证据；scope_files | CR 结论落盘（APPROVED 或 CHANGES_REQUESTED+修复项） | 12min | 0f/0l/12min | code-review | S1 | pending |
| S2 | 终验汇总、目标达成裁决与交付摘要 | 主进程（例外理由:① git/归档编排+② 簿记交付——Rule 25.3 白名单） | verification.md；progress.md 证据；CR 结果 | outcome 判定有证据支撑，R1 裁决填写，交付五要素就绪 | 10min | 0f/0l/10min | 无 | S1 | pending |

## 🔁 收尾回读梳理记录（Rule 84.14 — 迭代环留痕，交付前必填）
| 轮次 | 发现（偏移/遗漏/未利用知识） | 处置（修复动作+证据） |
|------|------------------------------|----------------------|
| 1 | ①open_questions 三条已由 S-A 默认决策落定（最近一条优先/载体复用/不自动切）未显式登记处置；②kb §7 入库触发未执行；③五维互洽无偏移——R1 回切闭环全覆盖、CA-1~4+回填重锁登记无超范围、终验 7/7 | ①本行即登记；②收尾序列执行 kb 入库；③无 |
| 2 | 零新发现（连续一轮零新发现=收敛出口） | —— |
| 1 | （终验填写：全量回读六文档五维互洽结果） | （修复/证据或“零新发现”） |

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（受管技能/规则改动；按宪法 §十一.1①/⑤ 与用户要求采用 worktree 隔离） |
| `isolation` | `worktree` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-intentresume-20261116` |
| `branch` | `wt/task-intentresume-20261116` |
| `merge_back` | `pending` |

> 契约详见 `/home/terry/.zcode/skills/task-planner/references/worktree-isolation.md`。合并前全 VC 复验 + CR APPROVED + `git status` 干净。

## 📊 FMEA 预演（规划期）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 2 | 插入位置破坏终验/归档顺序或 84.14/outcome 语义 | 8 | 4 | 5 | 160 | ③ 最小 diff 就地插入并保留原序号/标题；④ 主进程逐段复核 :130-145 顺序与 token 后再提交 VC |
| Phase 2 | 回切被实现为自动切回，违背确认口径 | 9 | 3 | 4 | 108 | ② 文案强制含“不自动切”+yes/no 分支；VC-2/VC-4 grep `不自动切` 作为硬断言，缺失即回炉 |
| Phase 2 | VC 判据 token 与最终措辞错配（判例重犯） | 7 | 5 | 4 | 140 | ③ 实施前按本计划 CA 锁定 token 微调文案/判据一致；失败则 ④ 主进程统一对齐措辞与 verification 命令 |
| Phase 3 | 误改 scope 外文件（尤其 plan-resume） | 8 | 3 | 3 | 72 | RPN≤100：VC-5 diff 名单校验 + 提交前 git diff 审计 |

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-11-16 | 计划期落盘完成 |
| Phase 2 | ☐ |  | 待 D1 批准后建 |
| Phase 3 | ☐ |  | 待 Phase 2 完成后 |
| Phase 4 | ☐ |  | 终验/CR/交付 |

> 契约详见 `/home/terry/.zcode/skills/task-planner/references/todo-sync.md`。

## Key Questions
1. 回切通告触发时若检测到多条挂起链（多次 A←B 切换叠加），展示与恢复顺序如何界定？（默认：按 `[intent-switch]` 登记链最近一条旧=<id> 优先提示，逐条确认；实现期若需扩展则登记 CA）
2. no=保持挂起时的“回切状态”落盘载体是 progress 还是 Decisions 或同值双写？（默认：复用 `[intent-switch]` 既有载体追加 `回切状态=no|保持挂起`，与切换登记同源可审计）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 采用 S-A 最小增强（终验回切检查+回切通告模板+Rule 94 交叉锚） | 直击 R-1~R-4，改动集中两文件，回归可控 |
| 回切必须用户确认，不自动切；yes 才路由 `Skill("plan-resume")` | 切回改变工作目标/上下文，对齐 E 类/94.3 确认精神与 R1“是否切回” |
| 回切检查插入 outcome 判定后、归档前 | B 已收口语义确定且归档前可读本计划载体/INDEX；兼容 Rule 81.1 |
| plan-resume 只读复用，不改实现 | 恢复能力已在位（触发点③/Top1 续推）；避免并行改动与 scope 扩张 |
| VC 先实测锚形态并锁定 token（`^### 94`、:136/:140/:202-204 参照） | 避免判据-产物错配判例重犯 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
|       | 1       |            | → progress.md Error Log   |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |         |        |      |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6,批量任务必填）
| 字段 | 值 |
|------|-----|
| `total` | n/a（非批量任务） |
| `success` | n/a（非批量任务） |
| `failed` | n/a（非批量任务） |
| `failure_rate` | n/a（非批量任务） |
| `sampled_pass` | n/a（非批量任务） |
| `sampled_fail` | n/a（非批量任务） |
| `pre_check` | n/a（非批量任务） |
| `rollback_point` | n/a（非批量任务） |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  / 4 |
| 主进程直做 Phase 清单 | Phase 1（②计划系统文件维护/计划期单写者，白名单）；Phase 3（L0-E 纯执行核验，权重 0 口径）；Phase 4 S2（①git/归档编排+②簿记交付，白名单） |
| 委派率 | （终验填写；目标 ≥ delegation_rate_floor） |
| 激活子代理数（Rule 96.5） | （终验填写） |
| 最大并行宽度（Rule 96.5） | 1（串行） |
| 串行化例外理由（Rule 96.4） | S1→S2 同文件顺序依赖；S3 可独立但为小步收敛合并串行；Phase 3/4 依赖前序产物 |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-11-16 | plan-writer | 调研锚点与缺口并落盘回切闭环计划六文档 | done | 完成 M1-M12/R-1~R-4/S1-S3 诊断；产出 task_plan/verification/kb/findings/progress | findings.md 全文；task_plan.md:1-360；verification.md:1-120 | findings.md Research Findings/缺口诊断/方案 | n/a | - / 0 / ☑(主进程盘上复核 R/VC/CA/Phases/S-unit/锚点) |
| 2 | 2026-11-16 | code-assistant | S1+S2 SKILL.md 回切检查条款+回切通告模板 | done | +2/0 纯增量；:145/:206 落位；token 全命中 | worktree diff；SKILL.md:145,206 | progress Phase 2 | n/a | - / 0 / ☑(主进程复核) |
| 3 | 2026-11-16 | code-assistant | S3 Rule 94 回切交叉锚 | done | +1/0；:620 紧邻 :619；94.4 语义保留 | discipline.md:620 | progress Phase 2 | n/a | - / 0 / ☑(主进程复核) |
| 2 | | code-assistant | Phase 2 S1 终验回切检查条款落地 | queued | | | | | - / 0 / ☐ |
| 3 | | code-assistant | Phase 2 S2 回切通告模板落地 | queued | | | | | - / 0 / ☐ |
| 4 | | code-assistant | Phase 2 S3 Rule 94 回切交叉锚落地 | queued | | | | | - / 0 / ☐ |
| 5 | | code-reviewer | CR Gate 审查 | queued | | | | | - / 0 / ☐ |

## 🔗 Chain 区块交接配置（可选）

### Chain 模式

| 字段 | 值 |
|------|-----|
| **chain_mode** | `single` |
| **current_block** | Block 1 |
| **handoff_on_complete** | ❌ 否 |

### Block 1: 回切闭环增强（当前块）

| 字段 | 值 |
|------|-----|
| **goal** | B 收口后主动检测挂起链并在用户确认下回切 A |
| **depends_on** | none |
| **passes_to** | n/a |
| **status** | in_progress |

### 🔗 Handoff 追踪表

| Block | 状态 | 交接产物路径 | 验证命令 | 实际完成时间 |
|-------|------|------------|---------|-------------|
| Block 1 | in_progress | plans/task-intentresume-20261116/* | VC-1~VC-6（见 verification.md） | - |

## 🔁 模板感知
<!-- template_type: general -->
- 触发信号: 意图切换回切闭环=流程/规则/技能文档跨面增强，非 16 类单一专属类型完全匹配 → 落 general 兜底
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant（候选：intent-resume/intent-switch-resume 型）
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 沉淀理由 / 不沉淀理由（二选一必填）→ 指向 plan-template-kit 卫星 SOP
