<!-- template_type: rule-enhancement -->
<!-- 适用场景: 技能增强——新增 companion 媒体专业 agent（图片/视频生成执行体）+ Rule 47.2 联动 + 文档同步 + selftest 守护 -->
<!-- 沉淀出处: task-v074 沉淀 variant；本任务承接 task-v122 D2 候选 B 的用户转正 -->

# Task Plan: 新增图片/视频生成专业 agent（companion 执行体 + Rule 47.2 联动）

<!-- plan_tier: standard -->
<!-- execution_lane: L1（新机制资产=agent 定义+守护，38.7 不适用 L0） -->

## Goal
新增两个 companion 专业执行体（`image-generation-executor` 图片生成执行体 + `video-generation-executor` 视频生成执行体，各含 agnes 调用/工序门控/三检-QC/证据纪律的完整 SOP），联动 SKILL.md 路由表媒体两行与 template-mapping.md 两处指向新 agent（在位优先、缺位回退，净增 0 行），同步 4 处文档计数/表格，新建 selftest-media-agents.sh 守护并登记 registry，全量 selftest 0 FAIL 后合并回 master、部署双位（~/.zcode/agents + ~/.claude/agents）+ skill-agent-router 路由表加 2 行。

**解决的用户诉求（原话）**：「还有就是没有专门的处理图片和视频生成相关专业agent可以同步补充 确保后期更加专业的处理任务」

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含新建 .sh 守护脚本） |
| `session_id` | `afd0b28ec78a4e8ca9f0acde60eeaaf7` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v124` |
| `scope_files` | `skills/task-planner/companion/agents/image-generation-executor.md`, `skills/task-planner/companion/agents/video-generation-executor.md`, `skills/task-planner/SKILL.md`, `skills/plan-template-kit/references/template-mapping.md`, `skills/task-planner/scripts/selftest-media-agents.sh`, `skills/task-planner/scripts/selftest-registry.tsv`, `README_zh.md`, `INSTALL_zh.md`, `INSTALL.md`, `skills/task-planner/install.sh` |
| `interaction_mode` | `ask` |
| `对齐审查` | Phase 4 S9 全部产出过 alignment-review（42.6.2）；变更记录落 verification.md |
| `自动超时默认项` | D2 model 行选型：默认项=候选 A（`custom:…:sonnet-1`），超时 5 分钟（Rule 44.1）；其余无询问点 |
| `质量审查工具` | Rule 42.2 四级检测：① alignment-review（池，文档面 S9）② code-quality-review（池，.sh 面 Code Review Gate）③ **frontmatter-linter**（环境既有 agent，agent frontmatter 机械校验 S10）——三工具执行期必用 |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 两 agent 文件在位且格式规范：frontmatter name=文件名 / description 含 MUST BE USED+触发词段 / model 行在位；正文含 掌握技能/输出模板/前置检查(HARD_BLOCK)/Workflow/禁止行为/证据要求 六节 | grep 锚逐项 + frontmatter-linter 无 BLOCK | `companion/agents/{image,video}-generation-executor.md` |
| VC-2 | 联动在位：SKILL.md 两媒体行含两 agent 名；template-mapping.md §九注+§十行含两 agent 名；SKILL/mapping **净增 0 行**（行内替换） | grep 锚 + `git diff --numstat` 显 1 增 1 删/文件 | SKILL.md / template-mapping.md |
| VC-3 | 文档同步：README_zh/INSTALL_zh 计数=6 个口径；INSTALL.md 表格含 3 行（complex-planner 欠账+2 新）；install.sh:179 注释含两 agent 名 | grep 锚逐项 | 4 文档 |
| VC-4 | 守护与回归：selftest-media-agents.sh 全绿（MA-01..10）；registry 45=45；全量 0 FAIL（fresh 独立复跑，总数=逐 Total 求和） | 跑新 selftest + 全量循环 | progress.md / subagent-state |
| VC-5 | 部署与审查：merge+双位部署（两 agent 文件内容一致，claude 位 model 行经 adapt 为 `sonnet`）；skill-agent-router 路由表含 2 新行；alignment-review + code-quality-review 双 APPROVED；零新 config 键 | 部署对账输出 + 审查结论 + `jq '.properties\|length'`=40 | verification.md |

**终验规则**: 全部 VC 通过 → COMPLETE；回归 FAIL 无法定位 → 记录后 PARTIAL；证据不实 → BLOCKED

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| agent 新增 | `companion/agents/image-generation-executor.md`、`video-generation-executor.md`（新建） | 改既有 4 个 companion agent |
| SKILL | `SKILL.md`（媒体两行**行内替换**，净增 0 行；禁动其他行） | 大段新增/行数变化 |
| 文档 | `plan-template-kit/references/template-mapping.md`（两处行内替换）、`README_zh.md`、`INSTALL_zh.md`、`INSTALL.md`（计数/表格） | 改其他文档 |
| 脚本 | `scripts/selftest-media-agents.sh`（新建）、`selftest-registry.tsv`（+1 行）、`install.sh`（:179 注释行） | 改其他脚本逻辑 |
| 配置 | （不动 config.json——零新键） | 动任何既有键 |
| 部署面（仓外，用户已授权） | `~/.zcode/agents/{两文件}`、`~/.claude/agents/{两文件}`、`~/.zcode/skills/skill-agent-router/SKILL.md`（+2 行）+ 同技能其他存在部署位 | 其他仓外文件 |

**强制约束**:
- 既有 4 companion agent / config.json / 其他 selftest 零改动（Rule 36.5 纯增量）
- SKILL/mapping 行内替换改前先 grep 核原文；行数净增 0 → 无行数锚级联（skill-split 447 锚不受影响）
- 派发契约：8 字段 + 单会话单 S-unit（Rule 46.1）；禁多个 S-ID 字面量与圈码 >4（dispatch-guard 纪律）
- 部署面改动=用户显式授权范围（本计划批准即授权），执行时先展示 diff；禁触碰 task-v123 他会话 worktree/plans

**执行前自我检查:**
- [x] 文件在范围内列表中
- [x] 修改对完成任务必要
- [x] 用户显式要求（2026-10-03 原话）

## 📚 必要知识储备

| 类别 | 名称 | 定位 | 必读 | 已确认 |
|------|------|------|------|--------|
| 项目内部 | companion agent 范式 4 文件 | skills/task-planner/companion/agents/*.md | 必读 | ☑ research-a |
| 项目内部 | agent 正文骨架范式 | ~/.zcode/agents/article-writer.md:1-15 | 必读 | ☑ research-b |
| 项目内部 | install-companion 链路 | skills/task-planner/lib/install-companion.sh（glob:163/adapt:52-90） | 必读 | ☑ research-a |
| 项目内部 | v119 部署先例 | plans/task-v119/progress.md:81 + verification.md:21-22 | 参考 | ☑ research-a |
| 外部技能 | agnes-ai-generation-skill | ~/.zcode/skills/agnes-ai-generation-skill/SKILL.md | 参考 | ☑ research-b |
| 项目内部 | 工序模板纪律 | templates/variant/{image,video,qc-defect,...}-type.md | 参考 | ☑ research-b（纪律引用） |
| 用户宪法 | §六 保护区/§十一 worktree | ~/.zcode/AGENTS.md | 必读 | ☑ |

## ⚠️ 核心问题定义

**核心问题**: 媒体任务（Rule 47 已具名路由）缺「专业执行体」——现有路由指向 executor+模板 SOP 的通用兜底，无携带 agnes 调用契约/三检-QC/放行门控的专用 agent；用户要求补两个专业执行体使其处理专业化。

**核心问题判断**:
- [x] 核心问题解决后，媒体任务可路由到专业执行体（若 agent 缺位回退不退化）
- [x] 不解决则媒体任务持续走通用兜底（专业化诉求不满足）
- [x] 方法清晰：纯增量新增（零机制改动，research-a 实证）+ 行内联动 + 新守护

## Current Phase
交付终态（Phase 1-5 全 complete；VC-1..5 全 PASS；outcome=COMPLETE）

## Next Step
输出交付总结（五要素）+ 记忆沉淀 + 计划档案簿记提交；随后 task-v125（Rule 52 待改号预留）执行

## 🧰 工具选择与编排（Rule 40）
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | 机械守卫脚本（基线）+ git 编排 | 白名单①；基线定数主进程留痕 |
| Phase 2 | Agent 子代理 executor(sonnet-1) ×5（声明并行组） | 五成员文件集全不相交（2 新文件+SKILL/mapping+文档对×2） |
| Phase 3 | executor(sonnet-1) + executor（回归） | 守护脚本编写与全量回归 |
| Phase 4 | executor(fresh)×3（回归/对齐/前端 lint） | 验证独立性（Rule 33.3） |
| Phase 5 | executor（CR Gate）+ 主进程（merge/deploy/簿记） | CR 隔离审查；部署=白名单①②+用户授权仓外面 |

**workflow 编排判定（Rule 40.4）**: 未命中——串行为主，Phase 2 组内并行足够
**/goal 对齐（Rule 40.3）**: 用户未 /goal 锚定；本计划 Goal+VC 即目标证据源

## Phases

### Phase 1: 隔离与基线
- worktree 建立（`/mnt/data/dev/task-planner-skill-worktrees/task-v124` -b wt/task-v124 master）+ 全量 selftest 基线（44 脚本、685 用例期望）+ config 基线（properties=40）+ 行内替换锚预核（SKILL:356-357 两行原文 / mapping:298/308 原文 / 四文档计数行原文 grep 快照入 progress）
- **V-N:** VC-5（部署面基线）, VC-4（回归基线）
- **Status:** complete
- **Executor:** 主进程（白名单①）+ executor（基线运行）
- **Evidence:** worktree @0f077ae；基线 44/44 rc=0、主进程求和 688 用例 FAIL=0（progress.md Phase 1 段 + subagent-state/baseline-run.log）；config=40；锚快照见 progress；INSTALL 路径修正登记
- **checkpoint**: plans/task-v124/subagent-state/1-baseline-executor.md

### Phase 2: 双 agent 落盘 + 联动（并行组 G124）
- 五成员文件集全不相交；输入=findings 材料包（只读）；验收各自独立 → Rule 21.4 四问通过，声明并行组
- **V-N:** VC-1, VC-2, VC-3
- **Status:** complete
- **Executor:** executor（sonnet-1）
- **Evidence:** commit fe31267（8 文件：2 新 agent + 6 同步）；锚复核 SKILL:356/357、mapping:298/308、README_zh:114、INSTALL_zh:305、INSTALL.md:140-142、install.sh:179；逐字 diff D1/D2 IDENTICAL；（备注：Phase 开启时 in_progress 翻转遗漏，pending→complete 直接翻转，已在 progress 登记）
<!-- parallel_groups: [S1,S2,S3,S4,S5]（Rule 21.4 声明制；各=独立会话领单行） -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | 落盘 image-generation-executor.md（草案 1 全文） | 继承 | plans/task-v124/findings.md（§agent 草案 1）；companion/agents/（新增） | 文件在位；name/触发词/model 行 grep 命中；六节齐全 | 10min | done |
| S2 | 落盘 video-generation-executor.md（草案 2 全文） | 继承 | plans/task-v124/findings.md（§agent 草案 2）；companion/agents/（新增） | 同上 | 10min | done |
| S3 | SKILL 媒体两行 + mapping 两处行内替换（净增 0） | 继承 | plans/task-v124/findings.md（§联动草案 1/2）；SKILL.md + template-mapping.md | 五锚 grep 命中；numstat 各 2/2（净增 0） | 12min | done |
| S4 | README_zh + INSTALL_zh 计数 3→6 与清单补全 | 继承 | plans/task-v124/findings.md（§联动草案 3 前两条）；README_zh.md + INSTALL_zh.md | 两文件「6 个」口径 + 两 agent 名 grep 命中 | 10min | done |
| S5 | INSTALL.md 表格补 3 行 + install.sh:179 注释补全 | 继承 | plans/task-v124/findings.md（§联动草案 3 后两条）；skills/task-planner/INSTALL.md + skills/task-planner/install.sh | INSTALL.md 含 3 行（complex-planner+2 新）；install.sh:179 含两 agent 名 | 10min | done |

### Phase 3: selftest 守护 + 全量回归
- **V-N:** VC-4, VC-1
- **Status:** complete
- **Executor:** executor（sonnet-1）
- **Evidence:** commit cc95adc；media-agents 10/10、registry 45=45；全量 45/45 rc=0 求和 698 用例 FAIL=0（m7-executor.md + m7-run.log）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S6 | 新建 selftest-media-agents.sh（MA-01..10）+ registry 登记 | executor(sonnet-1) | plans/task-v124/findings.md（§selftest 清单）；selftest-reliability-institution.sh（范式） | 本脚本全 PASS；registry 45=45 | 15min | done |
| S7 | 全量回归（45 脚本），与基线对比 | executor(sonnet-1) | plans/task-v124/progress.md（基线段）；scripts/selftest-*.sh | 总 FAIL=0；逐脚本 rc/Total 原文 | 15min | done |

### Phase 4: fresh 独立终验（验证独立性）
- **V-N:** VC-4, VC-1, VC-3
- **Status:** complete
- **Executor:** executor（fresh）×3
- **Evidence:** S8 fresh 45/45 rc=0 求和 698（m8-executor.md）；S9 alignment APPROVED（verification.md:120-147）；S10 六文件 PASS 无 BLOCK（m10-executor.md）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S8 | fresh 全量 45 脚本独立复跑（不信自报） | executor(sonnet-1) | verification.md（VC 表）；scripts/selftest-*.sh | 45/45 rc=0 FAIL=0 留痕 | 15min | done |
| S9 | alignment-review 对齐审查 + 变更记录 | executor(sonnet-1) | verification.md；10 个 scope 产出 | APPROVED + 变更记录落盘 | 12min | done |
| S10 | frontmatter-linter 机械校验两 agent + 既有 4 companion agent 零回归 | executor(sonnet-1) | companion/agents/ 全部 6 文件 | 无 BLOCK；既有 4 份零新告警 | 10min | done |

### Phase 5: CR Gate + 合并回 + 部署双位 + 簿记
- **V-N:** VC-5, VC-2
- **Status:** complete
- **Executor:** executor（CR Gate）+ 主进程（白名单①② + 仓外部署面=用户授权）
- **Evidence:** CR APPROVED（verification.md:156-187）；merge 0a82262；3 技能位 IDENTICAL；companion 双目标安装（claude model=sonnet）；router 双位九节 :103；主仓终态 49/PASS_SUM=744；worktree 清理完成（VC 全 PASS → COMPLETE）；（备注：Phase 开启时 in_progress 翻转遗漏，pending→complete 直接翻转，同 Phase 2 已登记）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S11 | Code Review Gate：新 .sh 隔离审查（code-quality-review） | executor(sonnet-1) | verification.md；selftest-media-agents.sh | APPROVED（P0/P1=0） | 12min | done |
- 主进程：smart-merge-back --deploy → install-companion 双位分发（claude 位 model adapt 复核）→ skill-agent-router 两行（展示 diff 后写）→ worktree 清理 → 簿记

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`——信号②③④ 均指向**他会话 task-v123**（活跃 worktree wt/task-v123 + 未完成任务在册）；信号① 仅 plans/ 簿记。**重叠面评估**: v123 触碰 SKILL.md 终验段（~:246-260）与本任务媒体行（:356-357）hunk 距离 >90 行，行内替换互不覆盖；master 前进由 smart-merge-back V5 检测处理 |
| `isolation` | `worktree`（技能文件=保护区 + §十一） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v124` |
| `branch` | `wt/task-v124` |
| `merge_back` | `merged(0a82262)`（三轮 V5 合流 v126/v129/v127/v128 后合并） |

## 📊 FMEA 预演

| Phase | 失败模式 | S | O | D | RPN | 预设兜底动作 |
|-------|---------|---|---|---|-----|-------------|
| Phase 2 | 行内替换锚漂移（v123 先合并改 SKILL 致行号移动） | 4 | 3 | 2 | 24 | 替换前 grep 核原文（不依赖行号）；锚不匹配 → 报 BLOCKED 不猜测 |
| Phase 3 | custom provider 拒单导致派发失败 | 5 | 4 | 2 | 40 | 22.3① 改派 executor（本会话 9/9）；连续 ≥2 拒 → 22.3.1 fallback bind |
| Phase 5 | install-companion 双位分发异常（claude 位 adapt 落 default 分支） | 6 | 2 | 2 | 24 | 对账双位内容+model 行；异常 → 定向 cp+sed（v119 先例）；备份语义先核 |
| Phase 5 | skill-agent-router 部署位遗漏 | 4 | 3 | 3 | 36 | 先 find 全部存在位再逐位写；展示 diff；写后 grep 复核 |

（全部 RPN ≤100，兜底已预登记）

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-03 计划创建 | S1 映射 |
| Phase 2 | ☑ | 2026-10-03 计划创建 | |
| Phase 3 | ☑ | 2026-10-03 计划创建 | |
| Phase 4 | ☑ | 2026-10-03 计划创建 | |
| Phase 5 | ☑ | 2026-10-03 计划创建 | |

## Key Questions
1. model 行选型？→ D2：A `custom:9e221f47…:sonnet-1`（推荐，约定+adapt）vs B `9a69b164…/agnes-3.0-flash`（今日健康，需手工适配 claude 位）
2. 是否绑定项目侧资产？→ 否：工序纪律引用 + 内置 SOP 兜底（research-b 可用性标注）
3. 既有 4 companion agent 改动？→ 零（纯增量，Rule 36.5）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 两 agent 用 kebab 名（image/video-generation-executor） | article 系一致；触发词可 grep；路由表点名 |
| SKILL/mapping 行内替换（净增 0 行） | 消除行数锚级联（v122 教训）；媒体行是 v122 新增行、语义扩展归属本任务 |
| 新守护 MA-01..10 入 registry（45=45） | T02 硬门；SR-12 动态口径免级联 |
| 部署面（~/.zcode/agents 等仓外）列入 scope | 用户指令授权（「同步补充」）；v119 同款先例 |
| D2 默认 A（超时 5 分钟，Rule 44） | 约定一致 + claude 位自动适配 |
| 共享追踪不适用 | 无可枚举共享资源部分认领（Rule 30.1 未命中） |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| （本任务=用户补强指令，承接 v122 D2；执行期错误记 progress Error Log） | — | — | → progress.md |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-04 02:00 | ✅ ALIGNED | — | Phase 1 后：worktree@0f077ae 干净，主仓计划内 |
| 2026-10-04 02:30 | ✅ ALIGNED | VC-1/2/3 | Phase 2 后：8 文件（2 新 agent+6 同步）commit fe31267 精确 |
| 2026-10-04 03:00 | ✅ ALIGNED | VC-4 | Phase 3 后：cc95adc 守护+registry；回归 698/0 |
| 2026-10-04 03:35 | ✅ ALIGNED | VC-1/4 | Phase 4 后：三路终验全过；worktree 零改动 |
| 2026-10-04 04:20 | ✅ ALIGNED | 全 VC | Phase 5 终局：merge 0a82262+双位部署+清理；check-complete exit 0 |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 5（check-delegation stats：delegation_rate=0.600） |
| 主进程直做 Phase 清单 | Phase 1（白名单① git/基线留痕）、Phase 5（白名单①② + 用户授权仓外部署面） |
| 委派率 | 0.6 < 0.7 → **WHITELIST-EXEMPT 放行**（violations=[] verdict=ok；先例同构） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-10-03 | executor（原派 explore×2 被 provider 拒） | research-a companion 机制调研 | done | 零机制改动；文档 stale 3 处；部署双位先例；无断言级联 | subagent-state/1-research-a.md | Research Findings §[sub:research-a] | subagent-state/1-research-a.md | rescue: explore provider 拒 → 22.3① 改派 executor / 0 / ☑ |
| 2 | 2026-10-03 | executor（原派 explore 被 21.4 串行锁拦） | research-b 媒体生成能力盘点 | done | agnes 调用面/工序门控/骨架范式/可用性标注六项 | subagent-state/2-research-b.md | Research Findings §[sub:research-b] | subagent-state/2-research-b.md | rescue: 补 [readonly-parallel] 标记重派 / 0 / ☑ |
| 3 | 2026-10-04 | executor | S1 image agent 落盘 | done | 67 行；逐字 diff 空；六节锚齐 | companion/agents/image-generation-executor.md | Research Findings `#### [sub:S1]` | subagent-state/m1-executor.md | - / 0 / ☑ |
| 4 | 2026-10-04 | executor | S2 video agent 落盘 | done | 68 行；逐字 diff 空；HARD_BLOCK=5 | companion/agents/video-generation-executor.md | Research Findings `#### [sub:S2]` | subagent-state/m2-executor.md | - / 0 / ☑ |
| 5 | 2026-10-04 | executor | S3 SKILL+mapping 行内替换 | done | 4 处替换；numstat 各 2/2；净增 0 | SKILL.md:356-357 / mapping:298,308 | Research Findings `#### [sub:S3]` | subagent-state/m3-executor.md | - / 0 / ☑ |
| 6 | 2026-10-04 | executor | S4 文档计数两件 | done | README_zh 1/1、INSTALL_zh 4/2；零残留 | README_zh.md:114 / INSTALL_zh.md:305 | Research Findings `#### [sub:S4]` | subagent-state/m4-executor.md | - / 0 / ☑ |
| 7 | 2026-10-04 | executor | S5 INSTALL+install.sh 两件 | done | INSTALL.md +3 行；install.sh 注释 6 名 | INSTALL.md:140-142 / install.sh:179 | Research Findings `#### [sub:S5]` | subagent-state/m5-executor.md | - / 0 / ☑ |
| 8 | 2026-10-04 | executor | S6 守护新建+registry | done | 151 行 MA-01..10 全 PASS；registry 45=45 | scripts/selftest-media-agents.sh | Research Findings `#### [sub:S6]` | subagent-state/m6-executor.md | - / 0 / ☑ |
| 9 | 2026-10-04 | executor | S7 全量回归（45 脚本） | done | 45/45 rc=0；求和 698 用例 FAIL=0；registry 45=45 | subagent-state/m7-run.log | Research Findings `#### [sub:S7]` | subagent-state/m7-executor.md | 主进程复跑 media-agents 10/10 / 0 / ☑ |
| 9 | | executor | S7 全量回归 | queued | | | | subagent-state/m7-executor.md | - / 0 / ☐ |
| 10 | 2026-10-04 | executor（fresh） | S8 fresh 全量 45 脚本独立复跑 | done | 45/45 rc=0；求和 698 FAIL=0（独立复跑） | subagent-state/m8-fullrun.log | Research Findings `#### [sub:S8]` | subagent-state/m8-executor.md | - / 0 / ☑ |
| 11 | 2026-10-04 | executor（fresh） | S9 alignment-review 对齐审查+变更记录 | done | APPROVED（P0/P1=0，P2×2 不阻断） | verification.md:120-147 | Research Findings `#### [sub:S9]` | subagent-state/m9-executor.md | - / 0 / ☑ |
| 12 | 2026-10-04 | executor（原派 frontmatter-linter） | S10 六 companion agent 机械校验 | done | 全 PASS 无 BLOCK（2 WARN 非阻断）；既有 4 零新告警 | subagent-state/m10-executor.md | Research Findings `#### [sub:S10]` | subagent-state/m10-executor.md | rescue: frontmatter-linter provider 拒 → 22.3① 改派 executor 按其清单执行 / 0 / ☑ |
| 12 | 2026-10-04 | executor | Phase 1 全量 selftest 基线（worktree 内 44 脚本） | done | 44/44 rc=0；主进程求和 688 用例 FAIL=0 | subagent-state/baseline-run.log | Research Findings `#### [sub:baseline]` | subagent-state/1-baseline-executor.md | 主进程复核（44 rc 行/日志） / 0 / ☑ |
| 13 | 2026-10-04 | executor（fresh，Code Review Gate） | S11 CR：selftest-media-agents.sh 隔离审查（code-quality-review） | done | **APPROVED**（15 维 P0/P1=0，P2×2 不阻断） | verification.md:156-187 | Research Findings `#### [sub:S11]` | subagent-state/m11-executor.md | - / 0 / ☑ |
| 14 | 2026-10-04 | executor（fresh） | merge 后全量回归（master 合入 643e61e；预期 47 脚本 727/0） | done | 47/47 rc=0；727 用例 FAIL=0 | subagent-state/m12-postmerge.md | Research Findings `#### [sub:postmerge]` | subagent-state/m12-postmerge.md | master 前进 V5（v126/v129/v127 三轮合流）→ worktree merge + registry/SKILL 并集解冲突 / 0 / ☑ |
| 15 | 2026-10-04 | executor（部署收尾） | router 双位九节补齐 + install-companion 双目标分发 | running | | | | subagent-state/m14-deploy.md | 主进程直写被委派守卫拦（仓外技能文件）→ 改派；merge=0a82262 / 0 / ☐ |
