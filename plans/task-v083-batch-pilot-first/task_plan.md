<!-- template_type: rule-enhancement -->
<!-- 沉淀出处: task-v074（Rule 34.3① 同类任务续用）; 本轮 task-v083 实例化 -->

# Task Plan: task-v083 批量试点先行硬门（Rule 18 族增补 — 单件未验证禁批量）

## Goal
落地用户 2026-09-18 训诫「单个处理都做不好还恶意批量处理=投毒；无十足把握禁批量；宁慢勿错」：Rule 18 族末尾纯追加 18.9（试点先行硬门）/18.10（单件失败禁批量=投毒红线）/18.11（宁慢勿错）三条款 + batch-quality-gate.md 详解增补 + SKILL.md Rule 18 摘要行行内联动（净增 0 行）+ 新建 selftest-batch-pilot.sh 守护 + CHANGELOG 条目；全量 selftest 0 FAIL 后合并回 master、部署 3 实体位并 push。

## ⚙️ 计划配置
| 键 | 值 |
|----|-----|
| template_type | rule-enhancement |
| chain_mode | single |
| interaction_mode | silent（自主环境+用户显式指令在案+v079/v081/v082 先例；交付报告附静默决策清单） |
| git_commit | per-phase（Rule 27，禁攒批） |
| reflect_verify | required |

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含 .sh 脚本：selftest-batch-pilot.sh 新建） |
| `session_id` | 24186384601742f588108376ad77319e |
| `worktree_path` | /home/terry/task-planner-skill-worktrees/task-v083-batch-pilot-first |
| `scope_files` | skills/task-planner/references/critical-rules.md, skills/task-planner/references/batch-quality-gate.md, skills/task-planner/SKILL.md, skills/task-planner/scripts/selftest-batch-pilot.sh, CHANGELOG.md |
| `interaction_mode` | silent（同计划配置表） |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | critical-rules.md：Rule 18 族末尾在位 18.9 试点先行硬门（含批量定义≥2 同构对象+试点证据落 progress.md+十足把握四构成）、18.10 投毒红线（单件失败未修复禁批量+P0 定性+中止盘点回滚归因）、18.11 宁慢勿错（速度理由无效+用户明示在案）；git diff 对照分支点证实纯追加零删除零改写 | Read + grep 三锚 + git diff | findings.md/progress.md |
| VC-2 | batch-quality-gate.md：§二表增 18.9-18.11 三行、"八条款"字样两处联动改"十一条款"、新增试点先行硬门详解段（含批量定义/试点流程/红线处置/把握构成/宁慢勿错）、版本号 v2.2→v2.3；原有内容零删除 | Read + grep + git diff | progress.md P2 段 |
| VC-3 | SKILL.md：Rule 18 摘要行含「试点先行」引用（行内原位改，净增 0 行，wc -l 仍=543，不触 ≤548 断言） | grep + wc -l | progress.md P3 段 |
| VC-4 | selftest-batch-pilot.sh 新建（≥8 断言：18.9/18.10/18.11 三锚+SKILL 行联动+详解段+编号连续性 18.1-18.11 无重复+行数回归钉+CHANGELOG 锚）且全 PASS；worktree 全量 selftest 0 FAIL 且合并后 master 全量 0 FAIL（**总数=主进程逐 Total 行求和，禁采信子代理自报**） | 脚本实跑 + for f in selftest-*.sh 求和 | progress.md Selftest Log |
| VC-5 | 仓库根 CHANGELOG.md 条目在位（含试点先行硬门一句摘要） | Read | CHANGELOG.md |
| VC-6 | 3 实体位（~/.zcode、~/.claude、~/.config/opencode 的 skills/task-planner）diff -r IDENTICAL 主进程亲验；origin/master push 完成；worktree/分支已清理 | diff -r 三位 + git 实查 | 终验输出 |

**终验规则**: 全部 VC 通过 → COMPLETE；回归 FAIL 无法定位 → 记录后 PARTIAL；证据不实 → BLOCKED

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 条款 | `skills/task-planner/references/critical-rules.md`（Rule 18 族末尾追加 18.9-18.11，仅此） | 其他 Rule/条款语义；任何重编号 |
| 详解 | `skills/task-planner/references/batch-quality-gate.md`（§二表+新详解段+八条款字样联动+v2.3） | 既有条款行改写 |
| SKILL | `skills/task-planner/SKILL.md`（Rule 18 摘要行行内原位改，净增 0） | 大段新增/其他行 |
| selftest | `skills/task-planner/scripts/selftest-batch-pilot.sh`（新建） | 其他 selftest |
| 文档 | 仓库根 `CHANGELOG.md`（追加条目） | 其他文档 |
| 计划文件 | `plans/task-v083-batch-pilot-first/` 三件套+knowledge-brief | 其他 plans/ 目录 |

**强制约束**:
- **纯增量（Rule 36.5）**：不新增 Rule 编号（Rule 18 族内追加）、不动 "Rules 1-36" 字样 → 无锚定级联；"八条款→十一条款"属机械联动（36.1 明文不算功能删除，登记即可）
- SKILL.md 净增 0 行 → 三处行数断言（knowledge-brief T2b / skill-collab T10 / execution-stability T8b，现值 ≤548）不扩围；**兼容并行 v082 VC-2 的 wc=543 预期**
- **零新 config 键**（Rule 18 现无 config 键，文本纪律+selftest 静态守护，同 Rule 35/task-v076 先例）
- Rule 36 合规：P1 建删除基线（分支点 c10e8f2 的 git 快照），终验 git diff 对照证实零语义删除（C24）
- **plans/task-v082-minimal-probe/ 与 worktrees/task-v082-minimal-probe/ 属并行会话活跃任务（in_progress，已报 TAMPERED 属主会话自处），全程禁碰**（含不清理、不重锁、不 resume、不代为 attest）
- 派发契约：prompt 必含计划三文件绝对路径 + status:/acceptance:/checkpoint: 等 8 字段标签（check-dispatch.sh 逐字校验）；本任务自身文件编辑按 18.9 示范=单件串行、逐件验证，禁多文件打包批量改

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | Rule 18 现状八条款 18.1-18.8 | skills/task-planner/references/critical-rules.md L76-83 @c10e8f2 | 必读 | ☑ |
| 项目内部文档/知识库 | Rule 18 详解 v2.2（134 行全文） | skills/task-planner/references/batch-quality-gate.md @c10e8f2 | 必读 | ☑ |
| 项目内部文档/知识库 | SKILL.md Rule 18 摘要行+行数断言三处 | skills/task-planner/SKILL.md；selftest-{knowledge-brief,skill-collab,execution-stability}.sh | 必读 | ☑ |
| 项目内部文档/知识库 | 并行 v082 范围（Rule 35 族，同文件异区） | plans/task-v082-minimal-probe/task_plan.md（只读） | 参考 | ☑ |
| 项目内部文档/知识库 | CHANGELOG 条目格式（v081/v080 先例） | 仓库根 CHANGELOG.md ## [Unreleased] ### 新增 | 参考 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 批量操作缺「单件先行验证」前置硬门——18.1-18.8 只管批中/批后（抽检/熔断/Batch Report），单件尚不可靠时启动批量无门禁，爆炸半径失控（用户定性=投毒）。

**核心问题判断**:
- [x] 核心问题解决后，结果能交付吗？（Rule 18 族补齐前置门，批量纪律闭环）
- [x] 核心问题不解决，其他工作都白费吗？（批量质量门控存在前置空洞）
- [x] 核心问题的解决方法是清晰的、可执行的？（纯追加三条款+详解+守护，先例充分）

## Current Phase
## Current Phase
终验（全 Phase complete，outcome=COMPLETE）

## Next Step
输出交付报告（含静默决策清单），无剩余执行动作

## Phases

### Phase 1: 调研定稿与基线（Requirements & Discovery）
- [x] 冲突侦察（v082 并行范围/禁碰清单/信号①-④ 摘要）
- [x] Rule 18 现状盘点（18.1-18.8 + batch-quality-gate.md 134 行通读 + 行数断言三处定位）
- [x] 联动审计：全仓 grep "八条款"/"18\.8"/batch-quality-gate 引用面 + critical-rules.md 行数断言排查（变更联动审计铁律）
- [x] 条款文本定稿（18.9/18.10/18.11 全文+§二表行+详解段大纲）落 findings.md
- [x] 共享账本认领登记（Rule 30.3，.zcode/ledger/ task-planner-maintenance）
- [x] 禁令检查 C20 记录 + veto 登记（「单件未验证即批量」入 notepad 被否决方案段）
- **V-N:** VC-1, VC-2（条款文本定稿是 VC-1/VC-2 的验收基准）
- **Status:** complete
- **Executor:** 主进程（例外理由:③ 机械验证命令只读+② 计划系统文件簿记——Rule 25.3 白名单；定点读取非跨文件搜索）

### Phase 2: worktree 创建+条款落地（Implementation I）
- [x] 创建 worktree /home/terry/task-planner-skill-worktrees/task-v083-batch-pilot-first（branch wt/task-v083-batch-pilot-first，基点 master）
- [x] S1：critical-rules.md Rule 18 族末尾追加 18.9/18.10/18.11（纯追加）
- [x] S2：batch-quality-gate.md（§二表 3 行+八条款→十一条款×2+新详解段+v2.3）
- [x] 删除基线核对：git diff 分支点证实零语义删除（S1=3增0删；S2 删除行仅 3 处机械联动）
- **V-N:** VC-1, VC-2
- **Status:** complete
- **Executor:** code-assistant（haiku-1）——**⚠️ 22.3④ 兜底接管已生效（2026-09-18 03:2x）**：code-assistant 连续 2 次派发 Provider server error（mini 探针 PASS=环境分档存活，haiku-1 档不可用，v081 同族症状）；主进程逐文件接管（每文件 ≤300 行，Rule 25.3 白名单⑤ 兜底接管，WHITELIST-EXEMPT 口径）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S1 | critical-rules.md 追加 18.9-18.11 | 主进程（④接管） | plans/task-v083-batch-pilot-first/findings.md §条款定稿（三条款全文+插入行号 L83 后） | grep 三锚在位+git diff 零删除 | 15min | done |
| S2 | batch-quality-gate.md 详解增补 | 主进程（④接管） | findings.md §详解段大纲（表 3 行+§八+字样联动+v2.3） | grep 18.9-18.11 表行+详解段锚+零删除 | 15min | done |

### Phase 3: SKILL 联动+selftest 守护（Implementation II）
- [x] S3：SKILL.md Rule 18 摘要行行内改（净增 0，wc=543 实测）
- [x] S4：CHANGELOG.md 追加 task-v083 条目
- [x] S5：新建 scripts/selftest-batch-pilot.sh（BP-01..10，house style ok/bad+Total 行）
- [x] worktree 内单跑 selftest-batch-pilot.sh 10/10 PASS（BP-10 路径修正一层后）
- **V-N:** VC-3, VC-4, VC-5
- **Status:** complete
- **Executor:** 主进程（22.3④ 接管生效——code-assistant 已 2 连败实证不可用，P3 不再重试派发，白名单⑤ WHITELIST-EXEMPT）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S3 | SKILL.md Rule 18 行联动 | 主进程（④接管） | findings.md §SKILL 联动（现文+改后文对照） | grep 试点先行在位+wc -l=543 | 15min | done |
| S4 | CHANGELOG 条目追加 | 主进程（④接管） | findings.md §CHANGELOG 草稿（v081 格式先例） | Read 首部条目在位 | 15min | done |
| S5 | selftest-batch-pilot.sh 新建 | 主进程（④接管） | findings.md §断言清单（BP-01..10 逐条） | 脚本实跑 10/10 PASS | 15min | done |

### Phase 4: worktree 全量回归（Testing & Verification）
- [x] worktree 内 for f in selftest-*.sh 全量跑，主进程逐 Total 行求和（23 脚本 376 PASS/0 FAIL=基线366+10）
- [x] FAIL 项二分定位修复（无 FAIL，N/A）
- **V-N:** VC-4（worktree 侧）
- **Status:** complete
- **Executor:** code-runner-agent（mini）——实际派发成功（mini 档存活），本次未触发接管

### Phase 5: 合并部署+簿记收尾（Delivery）
- [x] smart-merge-back 合并（首跑 V5 MASTER_AHEAD 正确中止[v082 已并入 master]→worktree merge master 解 CHANGELOG 冲突重跑全量 377/0→再合并 8fed498）
- [x] 3 实体位部署（--deploy 基准=主仓副本）+ diff -r 三位 IDENTICAL 主进程亲验
- [x] master 全量 selftest 重跑求和 377 PASS/0 FAIL（bc 机械求和）
- [x] worktree remove+branch -d 清理；origin push（c10e8f2..8fed498）
- [x] 簿记：INDEX 刷新/verification.md 逐 VC 复验 6/6/委派统计 WHITELIST-EXEMPT/notepad 沉淀/memory 写入
- **V-N:** VC-4（master 侧）, VC-6
- **Status:** complete
- **Executor:** 主进程（例外理由:① 纯 git/worktree 编排+部署+② 计划系统文件簿记——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号①未提交 3 项均 plans/类+②额外 worktree=task-v082-minimal-probe+③遗留 wt 分支=wt/task-v082-minimal-probe+④INDEX 在册 1 项=v082——全部属并行会话 v082，本任务禁碰；信号⑤无） |
| `isolation` | `worktree`（实现类默认首选；改动 skills/ 运行中基础设施） |
| `worktree_path` | /home/terry/task-planner-skill-worktrees/task-v083-batch-pilot-first |
| `branch` | wt/task-v083-batch-pilot-first |
| `merge_back` | merged(8fed4988e2c905c863c9b28b26d595ced4157cf2)——首跑 V5 MASTER_AHEAD 中止（v082 e120331 先并入）→worktree merge master+解 CHANGELOG 冲突+重跑全量 377/0→二跑合并成功 |

> 契约详见 `~/.zcode/skills/task-planner/references/worktree-isolation.md`。§11.4 约束：禁切主仓分支、禁 reset --hard/clean -fd、只读 git 查询可。

## 📊 FMEA 预演

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| P1 | 联动审计漏引用面（"八条款"残留在未扫文件） | 5 | 4 | 3 | 60 | 全仓 grep 三关键词（八条款/batch-quality-gate/18\.8）宽口径；findings 落定稿清单后 P2 照单执行 |
| P2/P3 | 子代理不可启动（v081/v082 同因 reasoning-level-missing） | 6 | 5 | 2 | 60 | mini 探针预检；失败即 22.3④ 主进程逐文件接管（≤300 行/文件，25.3⑤ 预登记 WHITELIST-EXEMPT） |
| P4 | 全量回归既有 selftest 被 SKILL 行内改破坏 | 6 | 3 | 2 | 36 | 二分定位 fix ≤3 轮；超限 STOP |
| P5 | v082 并行会话中途合并→CHANGELOG/critical-rules 冲突 | 6 | 4 | 3 | 72 | smart-merge-back 预检兜底；冲突则 rebase 本分支重跑 P4 全量再合并；合并后 master 全量重跑（不采信 worktree 期结果） |
| P5 | 部署对账假 IDENTICAL | 6 | 2 | 2 | 24 | v077 根因已修（部署源=主仓副本）；保留主进程 diff -r 三位亲验为 VC-6 硬条件 |

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-09-18 | S1 建立 |
| Phase 2 | ☑ | 2026-09-18 | S1 建立 |
| Phase 3 | ☑ | 2026-09-18 | S1 建立 |
| Phase 4 | ☑ | 2026-09-18 | S1 建立 |
| Phase 5 | ☑ | 2026-09-18 | S1 建立 |

## Key Questions
1. 增补为新 Rule 37 还是 Rule 18 族内追加？→ **族内追加 18.9-18.11**：Rule 18 是批量权威源单点（batch-quality-gate.md 详解同源），新开 Rule 37 造成双权威源漂移；族内纯追加零重编号零级联
2. 是否加 config enforce 键？→ **不加**：Rule 18 现无 config 键，文本纪律+selftest 静态守护（同 Rule 35/task-v076 先例）；行为门控沿用既有 3-File/Batch Report 机器校验不扩权
3. 「试点」与既有 Q3 补救动作/18.2 双采样关系？→ 层次互补：18.9=批量启动前置门（任何批量），Q3 试点=不可回滚时补救动作（子集），18.2=批中抽检；详解段写明三者分层防误读

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| silent: 交互模式取 silent | 自主环境+用户显式指令在案（本任务即用户指令产物）+v079/v081/v082 同仓先例；交付报告附静默决策清单 |
| silent: Rule 18 族内追加而非新 Rule 37 | 批量权威源单点防漂移；纯追加零级联（对比 v082 插入式 35.6→35.7 需级联） |
| silent: SKILL.md 净增 0 行 | 保三处 ≤548 断言不扩围；兼容并行 v082 VC-2 的 wc=543 预期（并行会话友好） |
| silent: 零新 config 键 | Rule 18 无键先例+文本纪律 selftest 守护（Rule 35/task-v076 先例） |
| veto: 「单件未验证即启动批量」列为被否决操作方式 | 用户 2026-09-18 训诫原文在案（投毒定性+宁慢勿错）；已登记 notepad 被否决方案段 |
| silent: 条款命名对齐用户原话 | 18.9 试点先行硬门/18.10 投毒红线/18.11 宁慢勿错——用户词汇直接入条款便于溯源 |
| v082 耦合处置 | 同文件异条款区（Rule 35 vs Rule 18），合并顺序敏感→FMEA R-3(72) rebase 兜底；其 worktree/plan 全程禁碰 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| （暂无） | - | - | → progress.md Error Log |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition
- 本任务自身即 18.9 示范：文件编辑单件串行、逐件验证，禁打包批量改

## 🚨 Drift Log（漂移检测记录）

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-09-18 P1 后 | ALIGNED（check-drift --json drift_score=0） | VC-1/2 | 继续 P2 |
| 2026-09-18 P2/P3 后 | ALIGNED（自检：改动均在 scope 5 文件内，无计划外写入） | 全部 | 继续 |
| 2026-09-18 P5 合并期 | v082 抢先合并触发 V5 中止 → 走预登记兜底（非漂移） | VC-4/6 | 已收口 |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6）

不适用（无批量生成单元）——本任务为条款增补，文件编辑均为单件串行+逐件验证（恰为 18.9 示范），无 ≥5 单元批量操作。

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 1 / 5（P4 code-runner-agent mini 派发成功） |
| 主进程直做 Phase 清单 | P1=③②（机械验证+簿记）；P2/P3=⑤（22.3④ 接管，code-assistant 2 连败 Provider server error 实证，mini 探针对照）；P5=①②（git 编排部署+簿记） |
| 委派率 | 0.200（<0.7）——check-delegation stats verdict=ok，violations 空，全部直做理由命中 Rule 25.3 白名单 → **WHITELIST-EXEMPT 放行** |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | rescue(档位/结果/时间) | retry_count | verify_done |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|-------------|-------------|
| 1 | 03:22 | code-assistant | S1 critical-rules 追加 18.9-18.11 | failed | Provider server error（haiku-1 档不可用） | Agent 调用记录 | — | 未启动无检查点 | ④接管/生效/03:26 | 1 | ☑ |
| 2 | 03:25 | code-assistant | S1 重试 | failed | Provider server error 同因，停止重试 | Agent 调用记录 | — | 未启动无检查点 | ④接管/生效/03:26 | 2 | ☑ |
| 3 | 03:26 | mini 探针（code-runner-agent） | 子代理环境可用性探针 | done | mini 档存活（echo ok PASS） | 探针返回 evidence | — | none | — | 0 | ☑ |
| 4 | 03:2x | 主进程（22.3④ 接管） | S1+S2 条款落地 | done | S1 +3/-0、S2 +37/-3（3 处机械联动）全锚在位 | git diff numstat 实测 | §[sub:1]/§[sub:2] | subagent-state/1-code-assistant.md | — | 0 | ☑ |
| 5 | 03:4x | 主进程（22.3④ 接管） | S3/S4/S5（SKILL 联动+CHANGELOG+selftest） | done | wc=543 净增0；selftest 10/10 PASS | SKILL.md:287/CHANGELOG:12 | §[sub:3] | subagent-state/1-code-assistant.md（同段续记） | — | 0 | ☑ |
| 6 | 03:4x | code-runner-agent | P4 全量 selftest 回归 | done | 23 脚本 rc=0，主进程亲算 376/0 | subagent-state/4-code-runner-agent.md | §[sub:4] | subagent-state/4-code-runner-agent.md | — | 0 | ☑ |

## 🔗 Chain 区块交接配置

chain_mode: single（无 Chain 区块）
