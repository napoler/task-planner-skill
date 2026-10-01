# Task Plan: task-v108 模板体系整理更新（对齐最新规范+验证独立子代理化）
<!-- 整理重构型模板 — 模板文件全量对齐修正与制度化 -->

<!-- template_type: refactor -->
<!-- plan_tier: standard -->

## Goal

整理更新模板体系全部文件（主技能 templates/ 全部 .md + variant/ 16 个 + 卫星 template-mapping/template-guide），对齐最新规范（Rule 1-44 / v107 审查结论 / 验证独立性原则制度化），**全部验证动作由全新独立子代理执行**（不受主代理上下文影响），worktree 隔离实施后合并回。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（本任务修改面=模板 .md 与卫星文档，无代码功能变更；脚本面仅 selftest 锚断言级联，由全量回归+独立子代理验证兜底） |
| `session_id` | `subagentagenta4176274e408429dae9ddbf` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v108`（§11.2 集中目录） |
| `scope_files` | `skills/task-planner/templates/**`（含 variant/）、`skills/plan-template-kit/references/{template-mapping,template-guide}.md`、联动面 `skills/task-planner/scripts/selftest-template-lifecycle.sh`（锚断言级联）与 SKILL.md 模板注册行（仅计数联动时）；写入面含 `plans/task-v108/*` |
| `interaction_mode` | `ask` |
| `对齐审查` | 完成前由**独立子代理**按 alignment-review 对全部模板变更跑对齐审查（42.6.2）；变更记录三要素随交付落盘（42.6.3）；模板写入前版本一致性校验（42.6.1） |
| `自动超时默认项` | D1 计划批准：默认=批准执行，超时 5 分钟（Rule 44.3，非 D6）；执行中低区分度选项按 44.2 直接裁决登记；D6（功能性删除/语义改写确认）不适用自动超时 |
| `质量审查工具` | Rule 42.2 检测：用户级 review-library 池命中 **alignment-review**（对齐收尾，独立子代理执行）+ **documentation-review**（模板文档面）；环境 agents frontmatter-linter（template_type/frontmatter 机械面抽查，独立子代理执行）；无需补建 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 模板修复后全量 42 selftest 回归 0 FAIL（**独立子代理执行**，逐脚本 rc 逐项回报） | fresh 子代理运行并按 8 字段回报原文 | progress.md Phase 4 段 + checkpoint |
| VC-2 | 模板声明形态统一：16/16 variant 含 `<!-- template_type: X -->` 注释声明，内置模板形态合规 | **独立子代理** grep 实测回报 | findings.md + checkpoint |
| VC-3 | 模板-规范对齐审查通过：**独立子代理**按 alignment-review 四要素审查，CHANGES_REQUESTED 项全处置 | checkpoint + findings 处置记录 | subagent-state/ 对齐审查 checkpoint |
| VC-4 | 干净上下文实测：**全新子代理**用更新后模板走 init-session 建临时计划目录全流程成功（不受主代理上下文影响的直接实证） | fresh 子代理执行+8 字段回报 | checkpoint（临时目录用后清理） |
| VC-5 | worktree 合并回成功（smart-merge-back）+ 三部署位对账结论明确 + 主仓 scope 无未提交变更 | 合并输出+diff 对账+porcelain 空 | progress.md Phase 5 段 |
| VC-6 | 修复清单逐项闭环（v1 普查清单→逐项 done/deferred+理由）+ 变更记录三要素（42.6.3）落盘 | 变更记录 Read 核对 | plans/task-v108/ 变更记录 |

**终验规则**：全部 VC 通过 → **COMPLETE**；有已知遗留 → PARTIAL（列出）；≥1 VC 三次重试失败 → BLOCKED。

> **验证独立性铁律（用户指令 P0）**：本任务所有验证动作（回归/形态检查/对齐审查/干净上下文实测/终验核查）一律由**全新独立子代理**执行——主进程仅编排、簿记、Read 结论，禁止以主进程既有上下文自测替代验收（对齐 2026-09-26 用户裁决：subagent-clean-context-testing）。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 模板本体（worktree 内修改） | `skills/task-planner/templates/**`（task_plan/knowledge-brief/shared-tracker/subagent_dispatch/batch_report/verification 等内置 + variant/ 16 个） | templates/ 外的 references 改写 |
| 模板卫星文档 | `skills/plan-template-kit/references/{template-mapping,template-guide}.md` | 该卫星其他文件 |
| 联动面（仅级联时） | `skills/task-planner/scripts/selftest-template-lifecycle.sh`（锚断言数值级联）、SKILL.md 模板注册计数行（仅计数联动） | SKILL.md 其他段落；Rule 36.4 功能性删除/语义改写须逐项确认 |
| 计划系统文件 | `plans/task-v108/*` | 其他 plan 目录 |
| 明确排除 | v107 R 系列非模板项（R-01/R-06/R-08/R-09~R-14 等 SKILL/references/根目录/卫星非模板面） | 未授权扩围 |

**执行前自我检查:**
- [x] 用户指令「整理更新所有的模板文件」= 模板面修改显式授权；超出对齐范畴的功能性删除仍 D6 停
- [x] 全部修改在 worktree 内进行，验证后 smart-merge-back 合并

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|-----------|------|---------|--------|
| 项目内部文档 | v107 审查报告：模板类结论（R-02/R-03/R-04/R-15 模板部分/T-1/T-2/P2-6/C-P3/C-P4） | `plans/task-v107/report.md` §3.3/§3.4/§4 | 必读 | ☑ |
| 项目内部文档 | Rule 34.2 四点同步合约 + Rule 38.3 mini-lite 豁免五锚点 + Rule 44.1 模板「自动超时默认项」行 | `skills/task-planner/references/critical-rules.md` Rule 34/38/44 | 必读 | ☑ |
| 项目内部文档 | 验证独立性裁决（2026-09-26）：技能/上下文敏感改动后必须派全新子代理验证 | memory subagent-clean-context-testing | 必读 | ☑ |
| 项目内部文档 | check-template-type 白名单动态派生（去 -type 后缀）+ 三形态声明 | `skills/task-planner/scripts/check-template-type.sh` | 参考 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 模板体系经多轮任务沉淀存在计数锚过期/声明形态不齐/区块缺失/旧约定残留（v107 已证 8 项），且「验证由独立子代理执行」的用户裁决尚未制度化进模板——需要一次系统性整理，使模板体系与最新规范（Rule 1-44）完全对齐且验证面独立可信。

**核心问题判断**:
- [x] 解决后能交付吗？——能：模板修复清单逐项闭环 + 独立子代理验证链完整 = 可交付
- [x] 不解决其他工作白费吗？——是：模板是每个新任务的起点，过期锚/缺区块直接传播到后续所有计划
- [x] 方法清晰可执行？——是：普查→清单→worktree 修复→独立子代理验证→合并回，全链已有机制承载

## Current Phase

（全部 Phase complete — 终验 COMPLETE）

## Next Step

交付报告；部署同步（claude/opencode 全量 23 文件/zcode 待 videop1 裁决）待用户指令

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 executor(sonnet-1) | 模板普查为判断型只读审查；21.4 串行 |
| Phase 2 | 主进程（② 计划系统文件维护） | 普查结论并入计划=白名单② |
| Phase 3 | Agent 子代理 executor(sonnet-1) + worktree | 模板修复判断型，隔离区内实施 |
| Phase 4 | Agent 子代理 executor(sonnet-1)/code-runner(mini→失败④接管豁免) **全新会话** + 卫星技能 alignment-review | 用户 P0：验证全部独立子代理；干净上下文实测 |
| Phase 5 | Agent 子代理 executor(部署对账) + 主进程（① git 编排+② 簿记） | smart-merge-back 主进程编排为白名单①；对账 diff 派子代理 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件——普查→修复→验证为串行依赖链，维持 Rule 21.4 串行
**/goal 对齐（Rule 40.3）**: 用户未使用 /goal；Goal+VC 即目标锚

## Phases

### Phase 1: 模板全量普查（只读）
- [ ] 盘点模板体系全名单：主技能 templates/ 全部 .md（含 variant/ 16）+ 卫星 mapping/guide
- [ ] 新规范基线核对：v107 模板类结论逐项核实（R-02 计数/R-03 worktree 新约定/R-04 mapping-guide 清单/R-15 模板部分 4 variant 注释/T-1 示例脚本注脚方案/T-2 八个 13 节 variant 缺 3 区块）+ Rule 34.2 四点同步面 + Rule 38.3 mini-lite 五锚点豁免核实 + Rule 44.1「自动超时默认项」行在位性 + 验证独立性原则落点评估
- [x] 产出修复清单 v1（逐项：锚点/修法/修改性质[修正|增量]/影响联动面）——M-01~M-13 全文见 subagent-state/1-executor.md
- **V-N:** VC-6, VC-2
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | 模板体系普查出修复清单 v1 | 继承 | templates/ 全部+mapping/guide+v107 report §3.3/3.4（只读核对） | 清单 v1 逐项锚点+修法+性质 | ≤15min | pending |

### Phase 2: 修复方案定稿与计划增补
- [x] 普查清单 v1（M-01~M-13，全文见 subagent-state/1-executor.md + findings [sub:1-executor]）并入本计划：Phase 3 改三批次实施
- [x] 三项裁决：M-11 不镜像委派统计节到 variant task_plan（Rule 25.4 机器落点=verification.md，variant 共用已覆盖；避免模板膨胀）；M-12 补齐 3 行+🧰 区块（Rule 40.2/C28 standard 档语义，variant 补区块为唯一自洽选项，40.2 表述不改）；M-13 落点 A+B 双写（verification.md Goal Gate 段+task_plan.md VC 段头部；不升 Rule——33.3 已有语义锚；不加 selftest 新断言——全量回归+对齐审查兜底）
- [x] D6 核查：清单全部为修正（过期值/旧约定纠正）或增量（补缺失区块/注释/行），无功能性删除无语义改写 → 不触发 D6
- **V-N:** VC-6
- **Status:** complete
- **Executor:** 主进程（例外理由：② 计划系统文件维护——Rule 25.3 白名单）

### Phase 3: worktree 隔离修复实施
- [x] 创建 worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v108`（branch wt/task-v108 @ac82371）
- [x] 修复清单三批次全部完成（批次一 M-01/02/03/05/06/10 八文件；批次二 M-04/09 四文件含 §一 回填 rule-enhancement 偏差披露；批次三 M-07/08/12/13 十七文件），总计 23 文件 +333/-8，TL 18/18+plan-tier 32/32 PASS
- [x] worktree 内 commit + git status 干净（Rule 27）
- **V-N:** VC-6, VC-2
- **Status:** complete
- **Executor:** executor（sonnet-1）（修复实施）+ 主进程（worktree 生命周期①）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | 批次一：计数锚与声明形态面（M-01 主模板 worktree 约定/M-02 Rule12 同源/M-03 knowledge-brief 20→22/M-05 guide 26→25+23/26→22/25/M-06 四 variant 注释/M-10 T-1 注脚） | 继承 | 修复清单 M-01..03,05,06,10+worktree 模板路径 | diff 逐项对应+git status 干净 | ≤15min | pending |
| S2 | 批次二：16 variant 四点同步面（M-04 mapping §一/§六/§九+M-09 plan-writer/SKILL:274/critical-rules:348,361 13→16） | 继承 | 修复清单 M-04/M-09+四点同步面清单 | diff 逐项对应+TL 断言健康 | ≤15min | pending |
| S3 | 批次三：区块补齐与制度化面（M-07 九 variant Drift Log+M-08 十五 variant Handoff 节+M-12 十五 variant 3 行+🧰 区块+M-13 验证独立性 A+B 落点） | 继承 | 修复清单 M-07/08/12/13+主模板范式锚 | diff 逐项对应+区块计数 | ≤15min | pending |

### Phase 4: 独立子代理验证（用户 P0 — 全部全新会话）
- [ ] 全量 42 selftest 回归（**fresh 子代理**在 worktree 内执行，逐脚本 rc 回报）
- [ ] 模板声明形态机械核查（**fresh 子代理** grep 实测 16/16）
- [ ] 干净上下文实测：**fresh 子代理**用更新后模板在临时目录走 init-session 全流程（建 6 文件+template_type 门通过），临时目录用后清理
- [ ] alignment-review 对齐审查（**fresh 子代理**按池技能四要素审查模板变更），CHANGES_REQUESTED 项处置
- **V-N:** VC-1, VC-2, VC-3, VC-4
- **Status:** complete
- **Executor:** executor（sonnet-1）/code-runner-agent（mini，失败 22.3 接管豁免登记）——全部全新会话派发；验证一 660/0+验证二 16/16+干净上下文 6/6+验证三对齐审查（P2×1 已由主进程白名单⑥ 一字接管处置）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | 全量 selftest 回归（worktree） | 继承 | worktree scripts/selftest-*.sh 42 个 | 逐脚本 rc 原文，0 FAIL | ≤15min | pending |
| S2 | 形态核查+干净上下文 init-session 实测 | 继承 | worktree templates/+临时目录路径 | 16/16 声明+6 文件建成+gate OK | ≤15min | pending |
| S3 | alignment-review 对齐审查（模板变更面） | 继承 | worktree 模板 diff+alignment-review SKILL | 四要素结论+发现分级 | ≤15min | pending |

### Phase 5: 合并回与终验簿记
- [x] worktree 全 VC 复验 → smart-merge-back 合并回主仓（MERGED 5a30382）→ worktree/分支已清理
- [x] 部署位对账（fresh 子代理 sub:9）：claude/opencode 纯落后 23 文件可全量同步；zcode 落后 20+videop1 独立迭代 3 文件+独有 12 variant → 部署待用户裁决（本任务未写部署位）
- [x] 终验：verification.md 全量填写（6/6 PASS）+ 终验回归（fresh sub:8 主仓 660/0 无漂移）+ check-complete + 簿记 commit + INDEX
- **V-N:** VC-5, VC-6
- **Status:** complete
- **Executor:** 主进程（例外理由：① git/worktree 编排 + ② 簿记——Rule 25.3 白名单；验证子动作已全部下沉独立子代理）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（信号①：v107 簿记+本计划目录未提交，属预期；无②-⑤） |
| `isolation` | `worktree`（修改技能文件=保护区 §11.1.1，强制隔离） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v108` |
| `branch` | wt/task-v108 |
| `merge_back` | pending |

## 📊 FMEA 预演（规划期 — 指针 references/methodology.md §R2）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填） |
|-------|---------|---------|---------|---------|-----------|-----------------------------|
| Phase 1 | 普查与 v107 结论口径漂移 | 5 | 3 | 3 | 45 | 以 report.md 原锚点为准+独立子代理复核 |
| Phase 3 | 修复越出模板面（联动面误伤） | 7 | 3 | 2 | 42 | S-unit 逐项锚点+修法固定；越面即停 |
| Phase 3 | selftest 锚断言级联漏改（TL-17 类） | 6 | 4 | 3 | 72 | 修复清单强制含联动面列；Phase 4 全量回归兜底 |
| Phase 4 | mini/code-runner provider rejected | 4 | 5 | 2 | 40 | 22.3① 改派 executor→④ 接管豁免登记（机械命令） |
| Phase 4 | 干净上下文实测残留临时目录 | 3 | 3 | 2 | 18 | 实测用 mktemp 固定前缀+验证后清理核查 |
| Phase 5 | 合并冲突（并行会话动模板） | 6 | 2 | 2 | 24 | 合并前 reflog/status 预检；冲突即 STOP 报告 |

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | S1 计划批准后建 |
| Phase 2 | ☐ |  |  |
| Phase 3 | ☐ |  |  |
| Phase 4 | ☐ |  |  |
| Phase 5 | ☐ |  |  |

## Key Questions

1. v107 模板类结论在当前 HEAD 是否仍成立？（Phase 1 普查核实）
2. 16 个 variant 的 template_type 声明与区块完整性差距全貌？（Phase 1 清单 v1）
3. 「验证独立性」制度化落到模板哪些段落最贴合消费点？（Phase 1 评估+Phase 3 落地）
4. 修复后独立子代理验证链是否全部 0 FAIL？（Phase 4）

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| template_type=refactor | 模板体系整理重构语义；白名单动态派生合法值 |
| M-11 不镜像委派统计节到 variant task_plan | Rule 25.4 机器落点=verification.md（variant 计划共用已覆盖）；避免模板膨胀与 38.3 白名单边界模糊 |
| M-12 补齐 3 行+🧰 区块（variant） | Rule 40.2/C28 standard 档计划须含区块——variant 生成的即 standard 档计划，补区块是唯一自洽选项；40.2 规范表述不弱化 |
| M-13 落点 A+B 双写，不升 Rule 不加 selftest 断言 | verification.md Goal Gate 段（终验判定面）+task_plan.md VC 段头部（计划期声明面）；Rule 33.3 已有「独立验证」语义锚；机器面由全量回归+对齐审查兜底 |
| D 类新任务开 task-v108 | 用户指令与 v107 审查任务 Goal/范围/交付物不同（Rule 8.1）；v107 原样保留已重锁终态 |
| 验证全部独立子代理（用户 P0） | 用户明示「确保所有的验证都是在独立子代理进行执行，确保不会受到主代理的上下文的影响」+ 9-26 裁决制度化 |
| R-01~R-15 非模板项不纳入 | v107 待授权清单仍在；本任务 scope=模板面（用户指令边界），扩围须再授权 |
| 思路复述已呈示 | 2026-10-02 计划展示时按 28.2.1 复述（ask 模式 C18） |
| silent: 自动裁决 D1 批准（Rule 44.3 五要素：超时 5min/默认项=批准执行/触发 2026-10-02/理由=用户刚发出明确执行指令（P0-1 当前指令优先），模板面修改已在指令中显式授权，修改全程 worktree 隔离+独立子代理验证兜底/被覆盖选项=等显式 yes） | D6（功能性删除/语义改写）不适用自动裁决，出现即停 |

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
|      |             |        |      |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 机器口径 1/5（rate 0.2）——实际执行面：Phase 1 普查/Phase 3 三批次修复/Phase 4 五波验证 全部 executor fresh 承担；混合 Executor 字段解析面局限（v099 教训：stats 只认纯 token） |
| 主进程直做 Phase 清单 | Phase 2（② 计划文件）；Phase 3 worktree 生命周期+抽验（①）；Phase 4 零直做（全子代理）+P2 一字接管（⑥ ≤3 行）；Phase 5（① git+② 簿记）——全部命中 Rule 25.3 白名单 |
| 委派率 | verdict=ok、violations=[]；rate 0.2 但直做面全白名单 → **WHITELIST-EXEMPT 放行**（先例 v099-v107）；验证独立性专项=五波验证 5 个 fresh 会话零主进程自测 |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | | executor | Phase 1 模板普查出修复清单 v1 | queued | | | | plans/task-v108/subagent-state/1-executor.md | - / 0 / ☐ |
| 2 | | executor | Phase 3 修复批次 1 | queued | | | | plans/task-v108/subagent-state/2-executor.md | - / 0 / ☐ |
| 3 | | executor | Phase 3 修复批次 2 | queued | | | | plans/task-v108/subagent-state/3-executor.md | - / 0 / ☐ |
| 4 | | executor | Phase 4 全量 selftest 回归 | queued | | | | plans/task-v108/subagent-state/4-executor.md | - / 0 / ☐ |
| 5 | | executor | Phase 4 形态核查+干净上下文实测 | queued | | | | plans/task-v108/subagent-state/5-executor.md | - / 0 / ☐ |
| 6 | | executor | Phase 4 对齐审查 | queued | | | | plans/task-v108/subagent-state/6-executor.md | - / 0 / ☐ |
| 7 | | executor | Phase 5 部署位对账 | queued | | | | plans/task-v108/subagent-state/7-executor.md | - / 0 / ☐ |
