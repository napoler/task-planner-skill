<!-- template_type: rule-enhancement -->
<!-- 编号登记（Rule 20.6 / v128 账本）: new_rule: 52 —— rule-reserve.sh 已由本会话预留（check 52 = held by task-v125；三次改号 48→50→52 全程留痕） -->
<!-- 适用场景: 技能增强——Rule 52 执行体专业化优先 + 覆盖矩阵落仓 + 三登记面修复 + selftest 守护 -->
<!-- 沉淀出处: task-v074 沉淀 variant；本任务承接用户「总是用通用 Agent」系统层反馈（v122/v124 的机制收口） -->

# Task Plan: 执行体专业化优先与覆盖矩阵（Rule 52 + 三登记面修复）

<!-- plan_tier: standard -->
<!-- execution_lane: L1（新 Rule 条款+矩阵资产+守护，38.7 不适用 L0） -->
<!-- 执行顺序: 待用户批准后 v124（媒体 agent）先执行 → 本任务随后（基线含 v124 产物） -->

## Goal
审计实锤的三类缺口收口为机制：① 覆盖矩阵落仓（`references/agent-coverage.md`，类型族×专用体×登记状态 + C 类 41 实体纳入/豁免表 + 零专用体领域清单）② Rule 52「执行体专业化优先与覆盖矩阵维护」（52.1 选型顺序专用体优先 / 52.2 三类缺口禁新增 / 52.3 矩阵维护责任 / 52.4 零新键机制；编号经 rule-reserve 账本正式预留）③ 三登记面修复（SKILL 六族行+3 处行内修正+mapping 3 处行内修正+skill-agent-router 族行）④ selftest-agent-coverage.sh 守护（B 类实体存在性零容忍）+ registry 登记；全量 selftest 0 FAIL 后合并回 + 部署。

**解决的用户诉求（原话）**：「很多任务总是喜爱使用通用的Agent……希望确保后期再次拆分子代理执行任务的时候，可以使用更对应的专业代理进行执行」

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含新建 .sh 守护脚本） |
| `session_id` | `afd0b28ec78a4e8ca9f0acde60eeaaf7` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v125` |
| `scope_files` | `skills/task-planner/references/agent-coverage.md`, `skills/task-planner/references/critical-rules.md`, `skills/task-planner/SKILL.md`, `skills/plan-template-kit/references/template-mapping.md`, `skills/task-planner/scripts/selftest-agent-coverage.sh`, `skills/task-planner/scripts/selftest-registry.tsv`, `skills/task-planner/scripts/selftest-skill-split.sh` |
| `interaction_mode` | `ask` |
| `对齐审查` | Phase 4 S9 全部产出过 alignment-review（42.6.2）；变更记录落 verification.md |
| `自动超时默认项` | D2a 剧本双体（script-writer/script-auditor）处置：默认项=候选②「登记改兜底+列入增补候选」，超时 5 分钟（Rule 44.1） |
| `质量审查工具` | Rule 42.2 四级检测：① code-quality-review（池，.sh CR Gate）② alignment-review（池，文档面 S9）——执行期必用 |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 矩阵落仓完整：类型族表 + 三类缺口表 + C 类 41 行纳入/豁免 + 零专用体领域段 | grep 四段锚 + C 表行数=41 | `references/agent-coverage.md` |
| VC-2 | 登记面修复：B 类 5 条零残留（script-* 兜底化/research 双列标注/article-batch-publisher 改名/大小写修正）；SKILL 六族行在位 | grep 锚逐项 + B 类反证 grep=0 | SKILL.md / template-mapping.md |
| VC-3 | Rule 52 四子条 + SKILL 摘要 bullet + references 行尾追加；零新 config 键（properties=40） | `grep -c '^52\.'`≥4 + jq | critical-rules.md / SKILL.md / config.json |
| VC-4 | 守护与回归：selftest-agent-coverage.sh 全绿（AC-01..08，含实体存在性实跑）；registry N=N；全量 0 FAIL（fresh 独立复跑，逐 Total 求和） | 跑新 selftest + 全量循环 | progress.md / subagent-state |
| VC-5 | 部署与审查：merge + 3 位 IDENTICAL；skill-agent-router 各部署位族行在位（写后 grep 复核）；CR + alignment 双 APPROVED | 部署对账 + 审查结论 | verification.md |

**终验规则**: 全部 VC 通过 → COMPLETE；回归 FAIL 无法定位 → 记录后 PARTIAL；证据不实 → BLOCKED

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 矩阵新增 | `references/agent-coverage.md`（新建） | — |
| 条款 | `references/critical-rules.md`（文末追加 Rule 52 块） | 改既有规则 1-51 语义；动 49/50/51（v126/v127/v129 已 landed） |
| SKILL | `SKILL.md`（6 族行 +3 行内修正 +Rule 49 bullet +references 行尾；净增 ≤9 行） | 动媒体两行（v124 所有）；动其他行 |
| 文档 | `template-mapping.md`（3 处行内替换，净增 0） | 改其他行 |
| 脚本 | `selftest-agent-coverage.sh`（新建）、`selftest-registry.tsv`（+1）、`selftest-skill-split.sh`（锚演进 447→实际值，label 注明 task-v125） | 改其他脚本 |
| 配置 | （不动 config.json——零新键） | 动任何既有键 |
| 部署面（仓外，用户已授权） | `skill-agent-router` 各存在部署位 SKILL.md（族行 ≤8 行；v124 媒体两行已由 v124 加，本任务复核不重加） | 其他仓外文件 |

**强制约束**:
- 既有 Rules 1-51 原文零改动（Rule 36.5）；禁动 v124 媒体两行与 v123/v126/v127/v129 范围
- SKILL 增行→skill-split 锚演进按 v112/v122/v126/v127/v128 明文先例（S5 承接，label 注明 task-v125）；「Rule 52」/索引行字面锚先 grep 全量再同步（v121 扩窗先例；v127 已扩 PT-08/CD-11 至 1-5[0-9]）
- 派发契约：三文件绝对路径+brief 引用+8 字段+禁圈码 >4+禁多 S-ID 字面量；单会话单 S-unit（46.1）
- 执行顺序：v124 合并后本任务才进 Phase 1（基线含 v124 产物；矩阵含两媒体执行体登记=49.3 先例）

**执行前自我检查:**
- [x] 文件在范围内列表中
- [x] 修改对完成任务必要
- [x] 用户显式要求（2026-10-03 原话）

## 📚 必要知识储备

| 类别 | 名称 | 定位 | 必读 | 已确认 |
|------|------|------|------|--------|
| 项目内部 | 覆盖审计全文 | plans/task-v125/subagent-state/2-coverage.md | 必读 | ☑ |
| 项目内部 | 资产盘点全文 | plans/task-v125/subagent-state/1-inventory.md | 参考 | ☑ |
| 项目内部 | 三登记面锚 | SKILL.md:333-357 / skill-agent-router:25-101 / template-mapping.md:258-312 | 必读 | ☑ |
| 项目内部 | 规则尾部范式（46/47） | critical-rules.md:476-494 | 必读 | ☑ |
| 项目内部 | selftest 范式 | scripts/selftest-media-dispatch.sh | 必读 | ☑ |
| 用户宪法 | §一子代理路由/§六/§十一 | ~/.zcode/AGENTS.md | 必读 | ☑ |

## ⚠️ 核心问题定义

**核心问题**: 「总是用通用 Agent」的系统层根因=映射与登记三层脱节（41 有体不用/5 条指向不存在/媒体族无映射）+provider 可用性叠加——资产并不缺（87 agent/14 族），缺的是「选型时找得到、选中时有保障」的机制。

**核心问题判断**:
- [x] 解决后派发选型有单一事实源（矩阵）与机器守护（B 类零容忍）
- [x] 不解决则通用兜底持续发生（用户诉求不满足）
- [x] 方法清晰：矩阵落仓+条款+登记面修复+守护（材料包已备，S1-S9 草案全文在 findings）

## Current Phase
交付终态（Phase 1-5 全 complete；VC-1..5 全 PASS；outcome=COMPLETE）

## Next Step
交付总结（五要素+需求覆盖核对）+ 记忆 + 档案簿记提交 + plan-resume

## 🧰 工具选择与编排（Rule 40）
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | 机械守卫脚本（基线）+ git 编排 | 白名单①；基线留痕 |
| Phase 2 | Agent 子代理 executor(sonnet-1) ×4（声明并行组） | 四成员文件集不相交（矩阵/critical/SKILL/mapping） |
| Phase 3 | executor(sonnet-1) ×3（锚演进/守护/回归） | S5 依赖 S3 产物（串行链） |
| Phase 4 | executor(fresh) ×2（回归/对齐，readonly 并行） | 验证独立性 |
| Phase 5 | executor（CR Gate）+ 主进程（merge/deploy/router/簿记） | 仓外部署面=用户授权 |

**workflow 编排判定（Rule 40.4）**: 未命中——短链串行+组内并行足够
**/goal 对齐（Rule 40.3）**: 未锚定；Goal+VC 即目标证据源

## Phases

### Phase 1: 隔离与基线
- worktree 建立（`/mnt/data/dev/task-planner-skill-worktrees/task-v125` -b wt/task-v125 master；master 应已含 v124 merge）+ 全量 selftest 基线（执行时点实测脚本数，预期 v124 后 ≥46）+ config=40 + 编辑锚预核（SKILL 增行位/mapping 三行原文/registry 行数 grep 快照入 progress）
- **V-N:** VC-3（零键基线）, VC-4（回归基线）
- **Status:** complete
- **Executor:** 主进程（白名单①）+ executor（基线）
- **Evidence:** worktree wt/task-v125@2d65b5d；基线 49/49 rc=0（主进程口径 PASS 和=744）；锚预扫快照（progress Phase 1 段）；Rule 52 账本预留+attest 6bfa89f9→00b1441f（new_rule 声明后）
- **checkpoint**: plans/task-v125/subagent-state/1-baseline-executor.md

### Phase 2: 矩阵 + 条款 + 登记面（并行组 G125）
- 四成员文件集不相交；输入=findings 设计草案（只读）；验收独立 → 21.4 四问通过
- **V-N:** VC-1, VC-2, VC-3
- **Status:** complete
- **Executor:** executor（sonnet-1）
- **Evidence:** commit 0494007（4 文件：agent-coverage 128 行/Rule 52 +12/SKILL 461/mapping 3/3）；四段锚+C=41+六族行 :364-369+媒体行 :370 未动
<!-- parallel_groups: [S1,S2,S3,S4]（声明制；各=独立会话领单行） -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | 落盘 references/agent-coverage.md（设计 1 结构 + 审计底稿转写） | 继承 | plans/task-v125/findings.md（§设计 1）；subagent-state/2-coverage.md（底稿） | 四段锚在位；C 表 41 行 | 15min | done |
| S2 | critical-rules.md 文末追加 Rule 52 块（设计 3 全文） | 继承 | plans/task-v125/findings.md（§设计 3）; critical-rules.md（文末） | `^52\.`=4；标题锚；diff 仅追加 | 12min | done |
| S3 | SKILL 六族行+3 行内修正+Rule 52 bullet+references 行尾 | 继承 | plans/task-v125/findings.md（§设计 2）; SKILL.md | 六族行锚≥6；B 反证 grep=0；净增 ≤9 | 15min | done |
| S4 | template-mapping.md 3 处行内替换（B1/B2/B3/B4） | 继承 | plans/task-v125/findings.md（§设计 2）；template-mapping.md | 3 锚命中；`article-batch-publish`（无 er）零残留；净增 0 | 10min | done |

### Phase 3: 锚演进 + 守护 + 回归
- **V-N:** VC-4, VC-2
- **Status:** complete
- **Executor:** executor（sonnet-1）
- **Evidence:** commit cd3c116（4 文件）；skill-split 41/41、RC 15/15；agent-coverage 8/8；全量 50/50 求和 752 FAIL=0（m7-executor.md）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S5 | selftest-skill-split.sh 行数锚演进至实测 SKILL 行数（label 注明 task-v125，先例 v112/v122） | executor(sonnet-1) | plans/task-v125/progress.md（SKILL 实测行数）；selftest-skill-split.sh:41 | 41/41 PASS；numstat≤1增1删 | 8min | done |
| S6 | 新建 selftest-agent-coverage.sh（AC-01..08）+ registry 登记 | executor(sonnet-1) | plans/task-v125/findings.md（§设计 4）；selftest-media-dispatch.sh（范式） | 本脚本全 PASS；registry N=N | 15min | done |
| S7 | 全量回归（执行时点全集），与基线对比 | executor(sonnet-1) | plans/task-v125/progress.md（基线段）；scripts/selftest-*.sh | 总 FAIL=0；逐脚本原文 | 15min | done |

### Phase 4: fresh 独立终验（验证独立性）
- **V-N:** VC-4, VC-1
- **Status:** complete
- **Executor:** executor（fresh）×2（readonly 并行）
- **Evidence:** S8 fresh 50/50 rc=0 求和 752（m8-executor.md）；S9 alignment APPROVED（verification.md:133-160；P0/P1/P2=0）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S8 | fresh 全量独立复跑（不信自报） | executor(sonnet-1) | verification.md；scripts/selftest-*.sh | 全绿 rc=0 FAIL=0 留痕 | 15min | done |
| S9 | alignment-review 对齐审查 + 变更记录（含矩阵与登记面互引一致性） | executor(sonnet-1) | verification.md；7 个 scope 产出 + 矩阵 | APPROVED + 变更记录落盘 | 12min | done |

### Phase 5: CR Gate + 合并回 + 部署 + 簿记
- **V-N:** VC-5, VC-2
- **Status:** complete
- **Executor:** executor（CR Gate）+ 主进程（白名单①② + 仓外部署面=用户授权）
- **Evidence:** CR APPROVED（verification.md CR 段）；merge c38a5fc；3 技能位 IDENTICAL；router 双位六族行（145→151）；主仓终态 50/752/0 FAIL；worktree 清理；委派统计 verdict=ok（VC 全 PASS → COMPLETE）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S10 | Code Review Gate：新 .sh 隔离审查（code-quality-review） | executor(sonnet-1) | verification.md；selftest-agent-coverage.sh | APPROVED（P0/P1=0） | 12min | done |
- 主进程：smart-merge-back --deploy（3 位 IDENTICAL）→ skill-agent-router 各族行（先 find 全部存在位+展示 diff 后写→写后 grep 复核）→ worktree 清理 → 簿记/记忆/交付总结

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`——他会话 task-v123（wt/task-v123 活跃）触碰 SKILL.md 终验段（~:246-260）与本任务增行位（路由表尾 ~:350+/摘要 ~:282+）hunk 远；v124 先合并（媒体行由 v124 提供）。master 前进由 smart-merge-back V5 处理 |
| `isolation` | `worktree`（保护区+§十一） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v125` |
| `branch` | `wt/task-v125` |
| `merge_back` | `merged(c38a5fc)` |

## 📊 FMEA 预演

| Phase | 失败模式 | S | O | D | RPN | 预设兜底动作 |
|-------|---------|---|---|---|-----|-------------|
| Phase 3 | SKILL 行数锚级联（增行越 447） | 5 | 4 | 1 | 20 | 预登记锚演进（S5 承接，v112/v122 先例）；or 压缩增行 ≤0 不现实（内容价值优先） |
| Phase 2 | 行内替换锚漂移（v123/v124 先合并致文本差） | 4 | 3 | 2 | 24 | 替换前 grep 核原文；不匹配 → BLOCKED 上报 |
| Phase 5 | skill-agent-router 部署位遗漏/双写冲突 | 4 | 3 | 3 | 36 | find 全位先行；先展示 diff；写后逐位 grep 复核 |
| Phase 3 | provider 拒单 | 5 | 3 | 2 | 30 | 22.3① 改派 executor；22.3.1 fallback |

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
1. 剧本双体处置？→ D2a：候选②登记改兜底+增补候选（推荐/默认）vs 候选①本任务补 2 agent
2. Rule 编号？→ **52**（v128 编号账本 rule-reserve 已正式预留：46-51 全 landed，50=v127、51=v129；本任务第三次改号 48→50→52 全程账本留痕）——已裁决登记
3. 41 个 C 类全量登记？→ 六族行（找得到）+ 矩阵逐行（可追溯）+ 豁免一行理由（article-* 等）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 编号=52（rule-reserve 正式预留） | 48=v123/49=v126/50=v127/51=v129 全 landed；v128 账本落地后按「先登记先占」预留 52（三次改号全程留痕：48→50→52） |
| C 类族级登记（6 行）+ 矩阵逐行 | 路由表防膨胀；矩阵保可追溯 |
| 顺序 v124→v125 | v124 就绪且小；v125 基线/矩阵含 v124 产物（49.3 联动先例） |
| D2a 默认②（剧本双体登记兜底+候选） | 聚焦机制与登记修复；agent 增补另开 |
| 共享追踪不适用 | Rule 30.1 未命中 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| （本任务=用户系统层反馈机制化；执行期错误记 progress Error Log） | — | — | → progress.md |

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |         |        |      |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 5（delegation_rate=0.600） |
| 主进程直做 Phase 清单 | Phase 1（白名单① git/基线）、Phase 5（白名单①② + 用户授权仓外部署面） |
| 委派率 | 0.6 < 0.7 → **WHITELIST-EXEMPT 放行**（violations=[] verdict=ok；Executor 串已按 v124 先例补白名单括注） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-10-03 | executor | audit-coverage 覆盖交叉审计 | done | A/B/C 三类缺口实证（媒体 11 类无映射/5 条 B/41 条 C） | subagent-state/2-coverage.md | Research Findings §[sub:audit-coverage] | subagent-state/2-coverage.md | - / 0 / ☑ |
| 2 | 2026-10-03 | executor | audit-inventory 资产全量盘点 | done | 87 agent/14 族；9 大领域零专用体 | subagent-state/1-inventory.md | Research Findings §[sub:audit-inventory] | subagent-state/1-inventory.md | brief 引用缺失首派被拦 → 补引用重派 / 0 / ☑ |
| 3 | 2026-10-04 | executor | S1 覆盖矩阵落仓 | done | 128 行四段；C=41 全含处置；B 5 条 | references/agent-coverage.md | Research Findings `#### [sub:S1]` | subagent-state/m1-executor.md | - / 0 / ☑ |
| 4 | 2026-10-04 | executor | S2 Rule 52 条款落盘 | done | +12 逐字；^52.=4 | critical-rules.md 文末 | Research Findings `#### [sub:S2]` | subagent-state/m2-executor.md | - / 0 / ☑ |
| 5 | 2026-10-04 | executor | S3 SKILL 六族行+修正 | done | 454→461（+7）；六行 :364-369；反证 0 | SKILL.md | Research Findings `#### [sub:S3]` | subagent-state/m3-executor.md | - / 0 / ☑ |
| 6 | 2026-10-04 | executor | S4 mapping 三处行内替换 | done | 3/3 净 0；无 er 形 0 残留 | template-mapping.md | Research Findings `#### [sub:S4]` | subagent-state/m4-executor.md | - / 0 / ☑ |
| 7 | 2026-10-04 | executor | S5 锚演进批次 | done | 454→461 + RC-15 ^53；双双转绿 | selftest-skill-split.sh / selftest-requirement-coverage.sh | Research Findings `#### [sub:S5]` | subagent-state/m5-executor.md | - / 0 / ☑ |
| 8 | 2026-10-04 | executor | S6 守护新建+registry | done | 197 行 8/8；registry 50=50 | selftest-agent-coverage.sh | Research Findings `#### [sub:S6]` | subagent-state/m6-executor.md | - / 0 / ☑ |
| 9 | 2026-10-04 | executor | S7 全量回归 | done | 50/50；主进程口径 752/0 | subagent-state/m7-executor.md | Research Findings `#### [sub:S7]` | subagent-state/m7-executor.md | - / 0 / ☑ |
| 10 | 2026-10-04 | executor（fresh） | S8 fresh 全量 50 脚本独立复跑 | done | 50/50 rc=0；求和 752 FAIL=0 | subagent-state/m8-executor.md | Research Findings `#### [sub:S8]` | subagent-state/m8-executor.md | - / 0 / ☑ |
| 11 | 2026-10-04 | executor（fresh） | S9 alignment-review 对齐审查+变更记录 | done | APPROVED（P0/P1/P2=0） | verification.md:133-160 | Research Findings `#### [sub:S9]` | subagent-state/m9-executor.md | 首派零输出无效 → 重派成功 / 1 / ☑ |
| 12 | 2026-10-04 | executor（fresh，Code Review Gate） | S10 CR：3 个 .sh 隔离审查（agent-coverage 新+两锚演进） | done | **APPROVED**（P0/P1=0，P2×2 不阻断） | verification.md CR 段 | Research Findings `#### [sub:S10]` | subagent-state/m10-executor.md | - / 0 / ☑ |
| 13 | 2026-10-04 | executor | Phase 1 全量 selftest 基线（worktree 内 49 脚本） | done | 49/49 rc=0；主进程口径 744/0 | subagent-state/1-baseline-executor.md | Research Findings `#### [sub:baseline]` | subagent-state/1-baseline-executor.md | 自算和 574 无效已按自述排除 / 0 / ☑ |
