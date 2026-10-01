# Task Plan: task-v107 项目深度审查对齐（内容质量/稳定性/执行）
<!-- 诊断型模板 — skill 全仓审计与对齐 -->

<!-- template_type: diagnostic -->
<!-- plan_tier: standard -->

## Goal

对 task-planner 项目（/mnt/data/dev/task-planner-skill）完成三维深度审查对齐——内容质量（文档一致性）、稳定性（脚本与守卫回归）、执行（部署位一致性）——产出分级问题清单，授权修复项落地闭环，交付可验证审查报告。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（本任务以只读审查+条件修复为主；Phase 5 修复为轻 diff 由回归+selftest 兜底，报告类产出非代码） |
| `session_id` | `0ab0afaded5e4ad8a4d685e36cf9419b` |
| `worktree_path` | 仅 Phase 5 修复时创建 `/mnt/data/dev/task-planner-skill-worktrees/task-v107`（§11.2 集中目录规范） |
| `scope_files` | 只读审查面：`skills/**`、根目录 `*.md`、三部署位 skills 目录；写入面：`plans/task-v107/*`、（授权后）`skills/**` 修复 |
| `interaction_mode` | `ask`（默认；Rule 44 询问点自动超时默认项已登记） |
| `对齐审查` | 产出 report.md 与（如有）修复变更，完成前跑 alignment-review 对齐审查（42.6.2）；文档更新前跑版本一致性校验（42.6.1 未经校验不追加）；变更记录三要素随报告落盘（42.6.3） |
| `自动超时默认项` | D1 计划批准：默认=批准执行，超时 5 分钟（Rule 44.1/44.3，非 D6 硬停点）；执行中 D2-D5 询问点如出现，逐个登记默认项+超时 5 分钟；低区分度选项按 44.2 直接裁决登记 |
| `质量审查工具` | Rule 42.2 四级检测：①项目级无注册 ②用户级命中 review-library 池（alignment-review/documentation-review/code-quality-review）③环境 agents 命中 frontmatter-linter/agent-quality-auditor ④内置兜底池在位。**实际消费（sub:10 对齐审查如实修正）**：alignment-review 独立执行（Phase 6 sub:10，结论 CHANGES_REQUESTED 已处置）；documentation-review/code-quality-review 未独立调用——四波文档审查（sub:3~6）与脚本机械回归（Phase 1）按等效四维/机械清单消费，覆盖面等效但非池技能本体，如实披露；frontmatter-linter 未消费（本任务无 frontmatter 变更面）。无需补建（缺口=无） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 全量 42 个 selftest 回归 0 FAIL（与 v106 基线 660/0 对齐或差异已解释） | 逐脚本运行汇总 Total 行 | progress.md Phase 1 段 + verification.md V-1.2 |
| VC-2 | 审查报告 `plans/task-v107/report.md` 落盘，覆盖内容质量/稳定性/执行三维，问题条目含 file:line 锚点与 P0/P1/P2 分级 | Read 报告核结构 | plans/task-v107/report.md |
| VC-3 | 报告问题清单抽查 ≥3 条可复现（锚点实存、断言成立） | 主进程 Read 锚点核实 | verification.md V-4.1 抽查记录 |
| VC-4 | 三部署位一致性结论明确（IDENTICAL 或差异逐条披露） | diff -r 输出留痕 | findings.md Resources + progress.md Phase 3 段 |
| VC-5 | 修复项处置闭环：用户授权项修复后全量回归 0 FAIL 且变更记录三要素输出；未授权项留在待裁决清单 | 回归输出+报告待裁决段 | verification.md V-5.1 / report.md |
| VC-6 | 全部审查结论经 alignment-review 对齐审查收尾（42.6.2），无未处置对齐冲突 | 对齐审查记录 | findings.md 对齐审查段 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 只读审查 | `skills/**`（10 个 skill 全部文档与脚本）、根目录 `*.md` | 任何写入 |
| 部署位只读 diff | `~/.zcode/skills/**`、`~/.claude/skills/**`、`~/.opencode` 对应 skills 位 | 部署位写入（差异只记录不修改） |
| 计划系统文件 | `plans/task-v107/*`（三件套/report.md/verification.md/notepad） | 其他 plan 目录 |
| 修复写入（Phase 5，逐项授权后） | 授权清单内 `skills/**` 文件 | 清单外任何文件；未授权时零写入 |

**执行前自我检查:**
- [x] 只读面 Phase 1-4 不产生任何仓库写入（报告只进 plans/task-v107/）
- [x] Phase 5 修复 = D6 级：未获用户逐项授权零写入
- [x] 部署位差异只记录不修改（修复走主仓+统一部署流程）

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档 | v106 基线：42 selftest 660/0、三部署位 IDENTICAL、iterative-optimizer 已交付 | plans/INDEX.md + memory task-v106-iterative-optimizer | 必读 | ☑ |
| 项目内部文档 | review-library 池 11 技能清单与 alignment-review 四要素清单 | `~/.zcode/skills/alignment-review/SKILL.md` | 必读 | ☑ |
| 项目内部文档 | 审查锚点清单：SKILL 文档索引面（v103 教训 :246/:304 两处）、计数锚、RL/R 系列守卫 | `skills/task-planner/references/critical-rules.md` | 必读 | ☑ |
| 项目内部文档 | 部署合约：install-companion（三宿主分发）+ smart-merge-back | `skills/task-planner/lib/install-companion.sh`（v107-S1 审查修正：lib/ 非 scripts/） | 参考 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 项目经 106 轮迭代，文档计数锚/引用/索引与脚本守卫之间可能存在漂移，三宿主部署位可能与主仓不同步——需要一次系统性审查确认并收敛，使「内容质量、稳定性、执行可靠性」三者可验证。

**核心问题判断**:
- [x] 核心问题解决后，结果能交付吗？——能：三维审查结论 + 分级清单 + 授权修复闭环 = 可交付
- [x] 核心问题不解决，其他工作都白费吗？——是：漂移锚若沉淀进 selftest 断言会误导后续所有任务；部署位漂移使各宿主执行旧版规则
- [x] 核心问题的解决方法是清晰的、可执行的？——是：机械回归（selftest）+ 文档面锚点审查 + 部署位 diff，全部可机器佐证

## Current Phase

（全部 Phase complete — 终验 COMPLETE）

## Next Step

交付报告；R-01~R-15 待用户授权后可开修复轮（单独任务）

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 code-runner-agent(mini) + 机械守卫脚本 | selftest 回归/语法扫描属机械 IO，mini 档；输出可控 |
| Phase 2 | Agent 子代理 executor(sonnet-1) ×4 串行 | 文档一致性为判断型审查，sonnet 档；21.4 串行铁律 |
| Phase 3 | Agent 子代理 executor(sonnet-1) + 机械 diff 命令 | diff -r 只读机械比对 + executor 汇总差异清单 |
| Phase 4 | Agent 子代理 executor(sonnet-1) | 报告汇总撰写为判断型 |
| Phase 5 | Agent 子代理 executor(sonnet-1) + 机械守卫脚本 | 条件修复（授权后）+ 全量回归 |
| Phase 6 | 卫星技能 alignment-review + 机械守卫脚本（check-complete/attest） | 对齐收尾标准流程（42.6.2） |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件——审查波次为串行依赖链（基线→审查→汇总→修复），无可并行独立子任务（21.4 串行铁律不豁免）→ 维持 Rule 21.4 串行派发
**/goal 对齐（Rule 40.3）**: 用户未使用 /goal；本计划 Goal+VC 表即会话目标证据源，/goal 为用户侧 harness 命令技能层不可代调

## Phases

### Phase 1: 基线与全面回归（机械层）
- [x] bash -n 全量语法扫描 `skills/*/scripts/*.sh`（75 脚本 0 FAIL）
- [x] 42 个 selftest 全量回归，逐脚本 Total 行汇总（660/0，与 v106 基线一致）
- [x] 三宿主部署位盘点：~/.zcode、~/.claude、~/.opencode 三位 10 skill+11 池全在位；⚠️ 发现 ~/.config/opencode/skills 第二套旧部署（缺 8 个新技能）→ 移交 Phase 3
- [x] 知识储备必读项已确认（上表 ☑）
- **V-N:** VC-1, VC-4（部署位盘点为 Phase 3 输入基线）
- **Status:** complete
- **Executor:** executor（sonnet-1）（S2 selftest 回归，22.3① 改派自 code-runner mini）+ 主进程接管 S1/S3（白名单③ 机械验证命令；mini provider rejected×2）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S1 | bash -n 全量语法扫描+异常退出码脚本清单 | 继承 | skills/（10 skill 的 scripts/*.sh 语法扫描,输出 FAIL 清单） | 语法 FAIL 清单或全绿结论 | ≤10min | pending |
| S2 | 42 selftest 全量回归汇总 | 继承 | skills/task-planner/scripts/selftest-*.sh（42 个,逐个运行取 Total 行,汇总 PASS/FAIL） | 汇总 N/N 0 FAIL 或 FAIL 清单 | ≤15min | pending |
| S3 | 三宿主部署位盘点 | 继承 | ~/.zcode/skills、~/.claude/skills、~/.opencode（盘点 16 个目标技能位的存在性与形态） | 部署位清单表（存在/缺失/软链/实体） | ≤10min | pending |

### Phase 2: 内容质量深度审查（文档面）
- [x] S1 主文档面：task-planner SKILL.md + references/critical-rules.md 一致性（Rules 1-44 编号连续✓/索引面覆盖✓/C1-C33 连续✓/计数锚 2 处 P1 过期/19 引用全实存）
- [x] S2 其余 references + templates/（P1×2：task_plan 模板旧 worktree 约定+knowledge-brief 计数 20≠22；P2×6；config 键 11 对拍全一致）
- [x] S3 卫星与配套技能（P1×1：cost-guard Rule 17.5 幽灵 STOP 档；P2×4；6 技能零问题）
- [x] S4 根目录文档（P1×2：根级 scripts 入口全失效+session-catchup.py 幽灵；P2×17 过期数字簇）
- **V-N:** VC-2, VC-3
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S1 | 主文档面一致性审查 | 继承 | skills/task-planner/SKILL.md + references/critical-rules.md（Rules 1-44 编号/索引面/计数锚） | 问题清单（每条附 grep 证据） | ≤15min | pending |
| S2 | references+templates 审查 | 继承 | skills/task-planner/references/（除 critical-rules 外）+ templates/（引用路径实存+锚点） | 问题清单（附证据） | ≤15min | pending |
| S3 | 卫星+配套技能文档审查 | 继承 | skills/ 其余 9 个 skill 的 SKILL.md+references（引用实存+registry 一致） | 问题清单（附证据） | ≤15min | pending |
| S4 | 根目录文档审查 | 继承 | 根目录 6 个 .md（数字面/目录引用/版本一致性） | 问题清单（附证据） | ≤10min | pending |

> 审查断言纪律（v106 P2-d 教训）：每条「文件/锚点不存在」类断言必须附 find/grep 第一手证据，禁止仅凭未命中推断。

### Phase 3: 部署一致性对齐审查
- [x] 主仓 skills/* vs 三宿主部署位逐 skill `diff -r`：.claude/.opencode 位 9/10 IDENTICAL（task-planner 仅主仓 backup 目录差异、plan-resume tests 不部署）；⚠️ .zcode 位双向漂移（task-planner：plan-writer/selftest-template-lifecycle/template-mapping differ + 部署位多 12 个 video 家族 variant=28 vs 主仓 16；plan-template-kit：guide/mapping differ）
- [x] 差异逐条记录（差异清单全文 subagent-state/7-executor.md），只记录未修改
- [x] ~/.config/opencode/skills 第二套部署角色核实：**误判证伪撤销**——~/.opencode 是 ~/.config/opencode 的软链（同 inode），单一活跃部署；Phase 1 S3 的「缺 8 技能」为主进程盘点 grep 模式差异所致，已在 findings 撤销登记
- **V-N:** VC-4
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S1 | 三宿主部署位 diff 对账 | 继承 | 主仓 skills/ vs Phase 1 部署位清单（diff -r 逐 skill,汇总差异表） | 差异清单或 IDENTICAL 结论 | ≤15min | pending |

### Phase 4: 审查报告汇总与问题分级
- [x] 三维结论汇总 → `plans/task-v107/report.md`（136 行）：执行摘要/三维分节/42 条问题总表（EX-1 执行维 P1-高 + P1×7 + P2×27 + 待复核×5 + 核验×2，口径=表格数据行，sub:10 对齐审查更正）/R-01~R-15 授权修复候选/待裁决清单/变更记录三要素
- [x] 每条问题附 file:line 锚点与证据出处（保留原 checkpoint 引用，同根因五链合并互引）
- **V-N:** VC-2, VC-3
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S1 | 汇总撰写 report.md | 继承 | plans/task-v107/findings.md（Phase 1-3 全部回填结论）+ task_plan.md | report.md 五段结构齐备 | ≤15min | pending |

### Phase 5: 授权修复与回归（条件 Phase — 用户裁决后）
- [x] 展示修复候选清单，逐项获用户授权（D6 级）——2026-10-02 AskUserQuestion 分组呈报（组A 技能文档面 9 项/组B 根目录 6 项/EX-1/待裁决 5 项），**用户超时未答复**
- [x] 授权处置：未获授权 → **零修复实施**（§六 P0 未授权禁写 + 28.4 D6 不可自动裁决）；R-01~R-15 全部留 report.md §4 待授权清单；EX-1 与待裁决 5 项留 §5
- [x] 未授权项待裁决清单完整（report.md §4/§5）→ 按 Phase 5 豁免路径判定
- **V-N:** VC-5, VC-1
- **Status:** complete（语义=skipped-未授权豁免路径：零修复，候选完整留档 report §4/§5；机器门三态要求 complete）
- **Executor:** executor（sonnet-1）（修复实施）+ 主进程（① git 编排+worktree 生命周期——Rule 25.3 白名单）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S1 | 授权项隔离修复 | executor(sonnet-1) | report.md 授权清单（逐项锚点+修法） | 修复 diff+回归 0 FAIL | ≤15min | pending |

> 若用户裁决「只审查不修复」→ 本 Phase 状态改 skipped（登记 Decisions Made），直接进 Phase 6；VC-5 按「未授权项待裁决清单完整」判定通过。

### Phase 6: 对齐终验与簿记
- [x] alignment-review 对齐审查收尾（42.6.2）+ 变更记录三要素（42.6.3）——sub:10 CHANGES_REQUESTED（1 P1+2 P2）三项全处置
- [x] VC 逐条复验（verification.md 全量填写，6/6 PASS）+ check-complete exit 0
- [x] 簿记：INDEX.md 更新 + 簿记 commit + sync-todos --index
- **V-N:** VC-6, VC-5
- **Status:** complete
- **Executor:** 主进程（例外理由：① git/worktree 编排 + ② 计划系统文件簿记——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（仅信号①：本计划目录未提交，属预期；无②-⑤信号） |
| `isolation` | `direct`（Phase 1-4 纯只读审查，§11.5.3 纯调研例外）+ `worktree`（Phase 5 修复时：`/mnt/data/dev/task-planner-skill-worktrees/task-v107`，branch `wt/task-v107`） |
| `worktree_path` | Phase 5 条件创建 |
| `branch` | wt/task-v107 |
| `merge_back` | pending（Phase 5 条件执行后更新） |

> 依据：本任务主体为只读审查（11.5 例外 3），修复阶段命中保护区（§11.5 无豁免）→ 必须走 worktree。

## 📊 FMEA 预演（规划期 — 指针 references/methodology.md §R2）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 1 | selftest 全量耗时长（hook 税教训 65.7s/轮） | 3 | 4 | 2 | 24 | 分批运行+预估放宽至 15min；超时走 22.3② 拆分 |
| Phase 2 | 审查者误报「文件不存在」（v106 P2-d 教训） | 6 | 4 | 3 | 72 | S-unit 验收强制附 find/grep 证据；主进程抽验 ≥3 条 |
| Phase 2 | 审查面过大单次溢出 | 5 | 3 | 3 | 45 | 已拆 S1-S4 四波串行；仍超限再拆（22.3②） |
| Phase 3 | 部署位路径假设错误 | 4 | 3 | 2 | 24 | 以 Phase 1 实测盘点清单为准，禁止假设路径 |
| Phase 5 | 修复触碰清单外文件 | 8 | 2 | 2 | 32 | D6 逐项授权前置硬门；worktree 隔离+范围外零写入 |

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | S1 计划批准后建 |
| Phase 2 | ☐ |  |  |
| Phase 3 | ☐ |  |  |
| Phase 4 | ☐ |  |  |
| Phase 5 | ☐ |  | 条件 Phase |
| Phase 6 | ☐ |  |  |

## Key Questions

1. 42 selftest 在当前 HEAD 是否仍 660/0 全绿？（Phase 1 回归回答）
2. 文档计数锚（Rules 1-44 / C1-C33 / 脚本数 / 池技能数）与实测值是否一致？（Phase 2 回答）
3. 三宿主部署位与主仓是否仍 IDENTICAL？（Phase 3 回答）
4. 发现的问题中哪些需要修复授权、哪些仅登记？（Phase 4/5 用户裁决）

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| template_type=diagnostic（诊断模板承载审查对齐任务） | variant 16 类中 diagnostic 语义最贴（skill 审计），白名单动态派生合法值（无 -type 后缀） |
| Phase 1-4 direct 只读、Phase 5 条件 worktree | §11.5.3 纯调研例外；修复命中保护区无豁免（11.5 未命中） |
| code_review=n/a | 本任务无代码功能变更；脚本修改（若有）以全量 selftest 回归兜底 |
| 思路复述已呈示 | 2026-10-02 计划展示时按 28.2.1 复述（ask 模式 C18） |
| silent: 自动裁决 D1 批准（Rule 44.3 五要素：超时 5min/默认项=批准执行/触发 2026-10-02/理由=自主会话用户无法实时响应且 Phase 1-4 纯只读可逆、直接源自用户指令/被覆盖选项=等显式 yes） | Phase 5 修复仍保持 D6 硬门停等用户逐项授权，不受本裁决影响 |

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
| 2026-10-02 01:20 | ✅ ALIGNED（Phase 1 complete 后） | VC-1, VC-4 | 75 脚本 0 语法 FAIL+42 selftest 660/0+三宿主盘点完成；仅动 plans/task-v107/；继续 Phase 2 |
| 2026-10-02 01:55 | ✅ ALIGNED（Phase 2 complete 后） | VC-2, VC-3 | 四波审查完成（计数口径后经 sub:10 更正为 42 条=P1×7/P2×27/待复核×5/核验×2），抽验全证实；仅动 plans/task-v107/；继续 Phase 3 |
| 2026-10-02 02:30 | ✅ ALIGNED（Phase 3 complete 后） | VC-4 | 部署对账完成（.zcode videop1 双向漂移为关键发现，.claude/.opencode 同步）；仅动 plans/task-v107/；继续 Phase 4 |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 6（Phase 2/3/4 executor 全承担；Phase 1 executor 承担 S2+主进程接管 S1/S3 白名单③；Phase 5 skipped 无工作；Phase 6 主进程白名单①②） |
| 主进程直做 Phase 清单 | Phase 1 接管 S1/S3（③ 机械验证命令）；Phase 5 skipped（D6 未授权零写入）；Phase 6（① git 编排+② 簿记） |
| 委派率 | 0.500（< floor 0.7，但 main_direct 全部命中 Rule 25.3 白名单 → **WHITELIST-EXEMPT 放行**；stats verdict=ok，violations=[]，verification.md 委派统计段有 JSON 原文） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | | code-runner-agent→主进程 | Phase 1 S1 bash -n 全量语法扫描 | done-接管 | mini provider rejected×1（22.3.1）；④主进程接管（白名单③ 机械验证命令） | | | plans/task-v107/subagent-state/1-code-runner.md | rescue=④接管 / 0 / ☐ |
| 2 | | code-runner→改派 | Phase 1 S2 42 selftest 全量回归 | queued-改派 | mini rejected×2 → 22.3① 改派 executor 承担 | | | plans/task-v107/subagent-state/2-code-runner.md | rescue=①改派 / 0 / ☐ |
| 9 | | code-runner-agent→主进程 | Phase 1 S3 三宿主部署位盘点 | done-接管 | mini 已 2 连拒不再探针；④接管（白名单③ 机械盘点） | | | plans/task-v107/subagent-state/9-code-runner.md | rescue=④接管 / 0 / ☐ |
| 3 | | executor | Phase 2 S1 主文档面审查 | done | 6 项问题（P1×2:SKILL:64 五文件过期锚+Rule16 锚 21≠22;P2×4）;主进程抽验 3 条全证实;P-4 为 v097 宽容锚设计权衡非缺陷 | findings.md [sub:3-executor] | findings.md | plans/task-v107/subagent-state/3-executor.md | rescue=- / 0 / ☑ || 4 | | executor | Phase 2 S2 references+templates 审查 | done | P1×2（task_plan:249 旧 worktree 约定+knowledge-brief:9 计数 20≠22 双过期）+P2×6+待复核×2;主进程抽验 P1 两条全证实 | findings.md [sub:4-executor] | findings.md | plans/task-v107/subagent-state/4-executor.md | rescue=- / 0 / ☑ |
| 5 | | executor | Phase 2 S3 卫星配套技能审查 | done | P1×1（cost-guard Rule17.5 幽灵 STOP 档,主侧 0 命中已证实）+P2×4+待复核×1;6 技能零问题 | findings.md [sub:5-executor] | findings.md | plans/task-v107/subagent-state/5-executor.md | rescue=- / 0 / ☑ |
| 6 | | executor | Phase 2 S4 根目录文档审查 | done | 19 项（P1×2:根级 scripts 入口全失效+session-catchup.py 幽灵;P2×17 数字/口径过期簇）;主进程抽验 2 条 P1 全证实 | findings.md [sub:6-executor] | findings.md | plans/task-v107/subagent-state/6-executor.md | rescue=- / 0 / ☑ |
| 7 | | executor | Phase 3 部署位 diff 对账 | done | ⚠️ .zcode 位被 videop1 项目线迭代（部署位 28 variant vs 主仓 16,双向漂移;.claude/.opencode 位与主仓同步）;「第二套部署」误判已证伪撤销（.opencode=.config 软链）;33/33 池软链健康 | findings.md [sub:7-executor] | findings.md | plans/task-v107/subagent-state/7-executor.md | rescue=- / 0 / ☑ |
| 8 | | executor | Phase 4 汇总撰写 report.md | done | report.md 六段齐备:42 条问题(EX-1×1+P1×7+P2×27+待复核×5+核验×2,sub:10 更正口径)+R-01~R-15 修复候选+待裁决清单;主进程 Read 复核结构完整 | plans/task-v107/report.md | （无新增,汇总以既有为准） | plans/task-v107/subagent-state/8-executor.md | rescue=- / 0 / ☑ |
