---
template_type: general
interaction_mode: silent
parallel_groups: [audit-consistency, audit-docs, audit-alignment, audit-deploy, fix-wave1, fix-wave2, fix-wave3]
code_review: required
---

# Task Plan: task-v149 — task-planner 技能系统性审核与全量对齐修复

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「开始系统性的审核当前技能中的问题」<sub>（[目标]）</sub>
- **R2**: 「发现其中就是没有对齐的以及落后的内容全部帮我对齐」<sub>（[目标]）</sub>
- **R3**: 「修复其中的问题、错误以及不合理的地方，发现之后必解决」<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-2 | findings.md 审计发现清单（含证据锚）非空且覆盖 4 扫描面 |
| R2 | VC-3 | 已知遗留清单（memory 归集）+ 审计新发现逐项处置登记，处置率 100% |
| R3 | VC-2/VC-3/VC-4 | 修复提交入 worktree 分支 + 回归无新增 FAIL + 部署位 IDENTICAL |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 技能演进（多任务快速迭代） | 跨载体一致性无人盘点，遗留项散落 memory/delivery-summary 各处 | Phase 1 遗留归集 + Phase 2 四面扫描 | VC-2/VC-3 |
| 审计（发现面） | 扫描面遗漏=发现不全 | Phase 2 四子代理并行覆盖：一致性/文档滞后/三面对齐/部署位 | VC-2 |
| 修复（解决面） | 修复引入新 FAIL 或语义漂移 | Phase 3 worktree 隔离 + Phase 4 全量回归+CR+alignment | VC-1/VC-5 |
| 交付（生效面） | 修复只落仓未部署=运行位仍旧版 | Phase 5 部署位同步+IDENTICAL 对账 | VC-4 |

## Goal

系统性审核 task-planner 技能全部载体（SKILL.md/references/scripts/templates/companion/仓级文档/部署位），发现全部未对齐、过时、错误与不合理之处并修复入库——每个发现处置闭环（fixed 或登记理由），回归无新增 FAIL，部署位同步 IDENTICAL。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | 3b8a06afeac642d8a82e5140c75d8a7a |
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/task-v149-skill-alignment-audit |
| `scope_files` | `skills/task-planner/**`（SKILL.md/references/scripts/templates/companion/config.json）、仓级 `README_zh.md`/`INSTALL_zh.md`/`CHANGELOG.md`/`CLAUDE.md`/`CONTRIBUTING*.md`（如审计发现滞后）、`plans/INDEX.md`（陈旧状态行） |
| `interaction_mode` | `silent`（用户 /goal 自主会话 + 指令「发现之后必解决」= 概括授权修复；D6 硬停点仍停；静默决策清单随交付呈报） |
| `对齐审查` | alignment-review（终验前全产出对齐审查；版本一致性校验在文档更新前执行） |
| `自动超时默认项` | 全部询问点默认推荐项+5min 超时；本任务 silent 模式低区分度选择直接裁决登记 |
| `new_rule` | `65`（B 类重规划 2026-10-08：Rule 65=恢复 v142 周期性回顾条款——v141 撞号合并静默丢失文本，按 critical-rules.md:676 仲裁先例内容零改动重编号；考古证据 findings.md D5/D6） |
| `质量审查工具` | code-reviewer（agent，代码 diff 审查）+ alignment-review（skill，对齐审查）+ critic（方案挑刺，如需）；按 Rule 42.2 四级检测：项目级无专用 → 用户级 ~/.zcode/skills 有 alignment-review/code-quality-review → 环境 agents 有 code-reviewer/critic/alignment-reviewer → 登记 code-reviewer+alignment-review |
| `git_commit` | 逐 Phase 提交（Rule 27.1，worktree 内分支） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：回归验证由 code-runner-agent 子代理执行；CR 由 code-reviewer 子代理执行；主进程抽验证据（Rule 33.3 延伸）。

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 全量 selftest 回归无新增 FAIL：Phase 4 复跑结果与 Phase 1 实测基线对照，无基线外新增 FAIL（基线内已知 FAIL 逐条保持分类不恶化） | code-runner-agent 跑 62 个 selftest-*.sh，输出 FAIL 清单与基线 diff | plans/task-v149-skill-alignment-audit/progress.md Phase 4 段 + 回归输出 |
| VC-2 | 审计发现清单 100% 处置闭环：每个发现 = fixed（commit 锚）/ deferred（理由+后续建议）/ SKIP（理由）三态之一，无静默忽略 | Read findings.md 处置表逐行核对 | plans/task-v149-skill-alignment-audit/findings.md §审计发现处置表 |
| VC-3 | 已知遗留清单（memory 归集 ≥10 项）逐项核对并登记现状（已修/本任务修/仍遗留+理由） | Read findings.md 遗留核对表 | plans/task-v149-skill-alignment-audit/findings.md §遗留核对表 |
| VC-4 | 合并回 master 后，本次改动文件同步部署位 `~/.zcode/skills/task-planner`，逐文件 diff 为空（IDENTICAL） | `diff -r` 对改动文件清单逐个对账 | verification.md 部署对账段 |
| VC-5 | Code Review Gate 输出 APPROVED 且 alignment-review 输出 APPROVED（含 fix 闭环） | 审查结论行 + 检查点文件 | subagent-state/ 审查检查点 + findings.md |
| VC-6 | INDEX.md 状态与实际终态一致：无「实际已合并但标 in_progress/pending」的幽灵条目 | 对照 git log 合并记录逐条核对 INDEX 状态列 | plans/INDEX.md + git log |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> `code_review: required` → 终验前必须先通过 Code Review Gate，否则不得标 COMPLETE。

## 🎯 核心目标达成裁决（Rule 58.5 — 终验必填）

| 字段 | 值 |
|------|-----|
| **目标型需求** | R1/R2/R3 |
| **裁决** | solved（R1 审计=四面扫描 57 项发现；R2 对齐=D1-D40 处置闭环 100%（fixed/销账/SKIP 全登记）；R3 修复必解决=全量回归 ΣFAIL 4→0+部署四位 IDENTICAL） |
| **解决证据锚** | master 0ff54bd（5+2 commit）；最终回归 /tmp/v149-final2-*.log 62 份 Total FAIL=0；部署对账 smart-merge-back 输出+cursor diff=0 |
| **未解决面+原因** | （终验填写） |
| **已排除路径** | n/a |
| **下一步建议** | （终验填写） |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 技能本体 | `skills/task-planner/**`（SKILL.md、references/、scripts/、templates/、companion/、config.json） | 范围外任何 skills/（其他技能如 task-drift-guard 仅在联动审计发现时先登记再改） |
| 仓级文档 | `README_zh.md`、`INSTALL_zh.md`、`CHANGELOG.md`、`CLAUDE.md`、`CONTRIBUTING*.md`、`examples/*.md`（2026-10-09 drift 整改补录：full-workflow.md 实位于 examples/ 非 docs/，S10 修正经授权）、`skills/task-planner/INSTALL.md`、`skills/task-planner/MIGRATION.md`、`skills/task-planner/docs/ARCHITECTURE.md`、`skills/task-planner/README.md`（仅审计发现滞后处） | 其他仓根文件 |
| 计划系统 | `plans/INDEX.md`（状态行修正）、`plans/task-v149-skill-alignment-audit/**`、`plans/.rule-reservations.jsonl`（如需） | 其他任务计划目录（只读） |
| 部署位 | `~/.zcode/skills/task-planner/**`（仅合并回后的同步部署，install.sh 通道） | 部署位内容的手工散改 |

**执行前自我检查:** 用户指令「全部帮我对齐，发现之后必解决」= 修复授权已给出；功能性删除/语义改写逐项登记清单随交付呈报（Rule 36.4，D6 概括授权已由 R3 给出）。

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部 | 已知遗留清单（memory 归集，带验证戳） | ~/.zcode/cli/memories/projects/task-planner-skill-fba311568bf6d7b3/memory/（v144/v145/v146/v147/v148 等 12+ 条目） | 必读 | ☑ |
| 项目内部 | 技能本体与守卫面 | /mnt/data/dev/task-planner-skill/skills/task-planner/（master 21f7e6b） | 必读 | ☑ |
| 项目内部 | selftest 守护套件 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-*.sh（62 个） | 必读 | ☑ |
| 项目内部 | 部署拓扑 | skills/task-planner/INSTALL.md + memory task-planner-repo-deploy-flow | 参考 | ☑ |
| 项目内部 | worktree 隔离 SOP | skills/task-planner/references/worktree-isolation.md + 宪法 §十一 | 必读 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 技能经 v118→v148 高频演进后，跨载体一致性（规则编号/计数断言/行号锚/互引/部署位/文档）无全面盘点，已知遗留 ≥10 项散落 memory，未知漂移存量不明——「落后内容未对齐」持续累积。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？——能：技能全载体对齐+遗留闭环+回归绿+部署同步
- [x] 核心问题不解决，其他工作都白费吗？——是：后续任务继续在漂移基线上叠加
- [x] 核心问题的解决方法是清晰的、可执行的？——是：归集→四面审计→worktree 修复→回归→部署

## 🔍 证据面清单（Rule 58.1）

| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | 本仓 62 selftest + 全仓 grep + 部署位 diff | 机械命令+子代理扫描 | findings.md §审计发现 | ☐ |
| ② 对标样本（58.2 强制） | v147/v148 交付态=健康参照（三位 IDENTICAL+ΣFAIL 基线 4） | git log + v148 delivery-summary 部署对账段 | findings.md §遗留核对表 | ☐ |
| ③ 外部约束 | 宪法 §六保护区/§十一 worktree 强制/Rule 36 技能修改保守化 | 用户级 AGENTS.md + critical-rules.md | task_plan.md 执行范围 | ☑ |

## Current Phase

Phase 5（合并回+部署+簿记交付）

## Next Step

smart-merge-back 合并五 commit 至 master → 三位部署+cursor 重同步+备份外移 → 簿记交付

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | 机械守卫脚本（selftest 全量）+ Agent 子代理 code-runner-agent | 62 脚本跑批属长耗时机械验证，子代理隔离跑，主进程只收 FAIL 清单 |
| Phase 2 | Agent 子代理 ×4（Explore/general-purpose，只读扫描）+ 声明并行组 | 四扫描面文件集互不相交（只读），独立性四问通过→组内并行 |
| Phase 3 | Agent 子代理 executor/code-assistant（worktree 内写） | 技能文件修改一律子代理，白名单外主进程写被 hook 拦 |
| Phase 4 | Agent 子代理 code-runner-agent + code-reviewer + Skill(alignment-review) | 验证与审查独立性（Rule 33.3/42.6.2） |
| Phase 5 | 机械命令（git/deploy/diff）+ 主进程簿记 | 白名单①② |

**workflow 编排判定（Rule 40.4)**: 未命中编排条件（无用户点名 /workflow；Phase 2 四扫描虽并行但为一次性只读 fan-out，Agent 派发组已覆盖）→ 按 Rule 21.4 独立性守门调度。
**/goal 对齐（Rule 40.3)**: 用户已用 /goal 锚定本任务——Goal+VC 即 session goal 证据源；/goal 为用户侧命令，技能层不代调。

## Phases

### Phase 1: 基线自检与遗留清单归集
- [x] code-runner-agent 跑全量 62 个 selftest-*.sh 基线：ΣFAIL=4（全部 periodic，检查点 01）——后被本任务 Rule 65 恢复清零
- [x] memory 遗留归集 16 项（L1-L16）→ findings.md §遗留核对表
- [x] knowledge-brief.md 审计种子（§2 五条已验证事实+§4 易错点）
- [x] 知识储备必读项确认（memory/技能本体/selftest 面/部署拓扑/worktree SOP）
- **V-N:** VC-1, VC-3
- **Status:** complete（2026-10-09 补翻：基线跑批+遗留归集+kb 种子全部完成于 10-08，状态行漏翻由 check-complete 4/5 提示发现）
- **Executor:** code-runner-agent（mini）

### Phase 2: 系统性审计扫描（4 面并行）
- [ ] S1 一致性扫描：规则编号 1-64 连续性、SKILL 计数断言、行号锚、互引完整性（Rule/文件引用悬空）
- [ ] S2 文档滞后扫描：README/INSTALL/CHANGELOG/CLAUDE/CONTRIBUTING vs 实态（部署位清单/Rule 集合/功能描述）
- [ ] S3 三面对齐扫描：SKILL.md↔critical-rules.md↔scripts/templates/companion 相互引用与措辞分叉
- [ ] S4 部署位对账：三部署位拓扑确认+diff+cursor 位缺失核实+DCS-20 部署债核实
- [ ] 四面发现汇总 findings.md §审计发现清单（每条带证据锚 file:line）
- **V-N:** VC-2, VC-3
- **Status:** complete（2026-10-08 22:58：四面审计 57 项发现→处置表 36 项闭环登记；drift-check=ALIGNED 三件套齐（06 检查点/ledger tick4/Drift Log 行）；整改两条已执行）
- **Executor:** Explore（mini）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|
| S1 | 一致性扫描：编号/计数/锚/互引 | explore（mini） | /mnt/data/dev/task-planner-skill/skills/task-planner/（master 21f7e6b；只读） | 发现清单带 file:line 锚 | 15min | 0f/0l/15min | 无 | pending |
| S2 | 仓级文档滞后扫描 | explore（mini） | 仓根 README_zh/INSTALL_zh/CHANGELOG/CLAUDE/CONTRIBUTING*（只读） | 滞后点清单带行锚 | 15min | 0f/0l/15min | 无 | pending |
| S3 | SKILL↔CR↔scripts/templates/companion 三面对齐 | explore（mini） | skills/task-planner/ 全载体（只读） | 措辞分叉/引用断链清单 | 15min | 0f/0l/15min | 无 | pending |
| S4 | 部署位对账+cursor 位+DCS-20 核实 | general-purpose（sonnet-1） | 部署位 ~/.zcode/skills/task-planner + INSTALL.md 部署表 + v148 delivery-summary（只读） | 部署拓扑事实+diff 清单 | 15min | 0f/0l/15min | 无 | pending |

> 并行组声明：见 frontmatter `parallel_groups`（四扫描面只读、文件集互不相交、输入无依赖、验收独立——独立性四问全 no，组内并行）；各子代理检查点 `subagent-state/{seq}-{agent}.md`。

### Phase 3: 修复实施（worktree 隔离）
- [ ] worktree 创建：/mnt/data/dev/task-planner-skill-worktrees/task-v149-skill-alignment-audit（分支 wt/task-v149-skill-alignment-audit，基点 master）
- [ ] 按 P2 发现清单分批修复（S-unit 表=B 类重规划后具体批次，2026-10-08）
- [ ] 执行依赖序：S5/S6/S8/S9(文档版次外)/S10(计数外)/S11/S12 可并行起步；S7（Rule 65）先落 → S16/S17-S20（SKILL 与守卫级联）→ S9/S10 的 Rule 集合与计数终值（1-65）复核
- [ ] plans/INDEX.md 幽灵条目修正
- **V-N:** VC-2, VC-3
- **Status:** complete（2026-10-09：16 S-unit 全验收，worktree 三 commit a234369/fca4f40/aa06dde；drift-check=DRIFT 低危行政面 4 项整改全消解——scope 表补录 examples/与技能 INSTALL/MIGRATION/ARCHITECTURE、S8 检查点主进程代写补齐、registry:61 残留修正、本状态行翻 complete）
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|
| S5 | INDEX.md 八行幽灵状态行修正（D1，终态事实已核实） | executor（sonnet-1） | plans/INDEX.md + findings.md L1 行（git merge-base 实证摘要） | INDEX 状态列与 git log 一致 | 10min | 1f/30l/10min | 无 | complete |
| S6 | SKILL.md 面修正：check-drift.sh 头注补降级佐证定位（D22）+61 括注预备 | executor（sonnet-1） | skills/task-planner/scripts/check-drift.sh 头注段 | grep 新头注在位 | 10min | 1f/15l/10min | 无 | pending |
| S7 | Rule 65 恢复：critical-rules.md 尾部追加 65 块（57.x→65.x 改号+仲裁注）+selftest-periodic-review.sh 文本锚 57→65 重接（D6/D7） | executor（sonnet-1） | git show 1a92ef3 原文（findings 考古段）+ critical-rules.md:676 先例注 | 该 selftest PASS；65 块 grep 在位 | 15min | 2f/100l/15min | 无 | pending |
| S8 | 行号锚批：registry:50 锚修正+init-session.sh:380+selftest-plan-dispatch.sh:37+selftest-self-resolution.sh:15,76+selftest-reliability-institution.sh:14,80（D9-D12） | executor（sonnet-1） | findings.md D9-D12 行锚 | 逐锚 sed -n 验证内容匹配 | 15min | 2f/40l/15min | 无 | pending |
| S9 | 仓级文档批 1：README_zh.md:136,229+CLAUDE.md:33+skills/task-planner/README.md:72 Rule 集合改 1-65（D14/D15，S7 后执行） | executor（sonnet-1） | findings.md D14/D15+三文件行锚 | grep「1-45\|1-39」=0 命中 | 10min | 3f/15l/10min | 无 | pending |
| S10 | 仓级文档批 2：INSTALL_zh.md 计数+docs/ARCHITECTURE.md+full-workflow.md 路径+D28 口径+D36 验证+M/L 计数项（D16-D19/D28/D36） | executor（sonnet-1） | subagent-state/03-explore-s2.md 发现清单 | 逐项 grep/ls 验证 | 15min | 2f/60l/15min | 无 | pending |
| S11 | 机制批：DCS-20 扫描根收窄（D24）+check-doc-sync.sh 键考证（D13）+v129 deferred 五项核对销账（D35） | executor（sonnet-1） | findings.md D24/D13/D35+selftest-drift-enforcement.sh DCS-20 段 | DCS-20 在部署位 PASS；键引用一致 | 15min | 2f/60l/15min | 无 | pending |
| S12 | 部署准备批：install-companion.sh 备份根外移+COMPAANION_DIR 拼考（D25）+agent-coverage video-fix-executor 修正（D20）+complex-planner 档位统一（D23）+模板面裁定（D21） | executor（sonnet-1） | findings.md D20/D21/D23/D25+lib/install-companion.sh:63,118 | cursor 部署后备份落扫描路径外；登记面一致 | 15min | 2f/60l/15min | 无 | pending |
| S16 | SKILL.md Rule 65 演进包：frontmatter:9（61 未落地修正+1-65）+61 括注+摘要列表补 45/46/48/56/60/65 bullet+C39 行恢复+References 行（D2-D5，S7 后执行） | executor（sonnet-1） | findings.md D2-D5+SKILL.md 行锚 | grep 六 bullet+C39 在位；「1-64」全集行更新 | 15min | 1f/60l/15min | 无 | pending |
| S17 | 守卫级联批 1：selftest-lane-advancement.sh(LA-12)+selftest-requirement-coverage.sh(RC-11) 1-64→1-65+负断言（D8） | executor（sonnet-1） | v147 先例 commit bd7a31c diff 模式 | 两脚本 FAIL=0 | 10min | 2f/10l/10min | 无 | pending |
| S18 | 守卫级联批 2：selftest-self-resolution.sh(SR-07)+selftest-tool-selection.sh(TS-05) 同上演进 | executor（sonnet-1） | 同 D8 模式 | 两脚本 FAIL=0 | 10min | 2f/10l/10min | 无 | pending |
| S19 | 守卫级联批 3：selftest-workflow-orchestration.sh(WF-10)+selftest-drift-check-subagent.sh(DCS-11) 同上演进 | executor（sonnet-1） | 同 D8 模式 | 两脚本 FAIL=0 | 10min | 2f/10l/10min | 无 | pending |
| S20 | 守卫级联批 4：selftest-research-first.sh(RF-06/07/10)+selftest-registry.tsv 行更新+DCE 行措辞核对（L4）+grep「1-64\|\^65」余量清点 | executor（sonnet-1） | S7 返回的级联面清单（10 脚本） | grep 余量=0 或逐项登记 | 15min | 2f/30l/15min | 无 | pending |
| S21 | 守卫级联批 5：selftest-four-file-dataflow.sh(FF-16)+selftest-evidence-goal-gate.sh(EG-16) 负断言 ^65\.→^66\. 演进（S7 实测新增面） | executor（sonnet-1） | S7 返回级联清单第 7/8 项 | 两脚本 FAIL=0 | 10min | 2f/10l/10min | 无 | pending |
| S22 | 守卫级联批 6：selftest-iteration-persistence.sh(IP-14) 负断言演进+全量 selftest 受影响面复跑核对（S7 实测新增面） | executor（sonnet-1） | S7 返回级联清单第 9 项 | IP 脚本 FAIL=0 | 10min | 2f/20l/10min | 无 | pending |
| S23 | 守卫级联批 7：selftest-skill-split.sh:44 SKILL.md 行数断言 ≤500→≤510（S16 实测 505 行，S16 返回新增面） | executor（sonnet-1） | S16 返回异常段 | 该断言 PASS | 5min | 1f/5l/5min | 无 | complete |
| S24 | CR 修复批A：periodic-review.sh:2 头注 Rule 57→65（M-1）+check-doc-sync.sh:14 考证注释改事实陈述（M-3） | executor（sonnet-1） | S14 返回 M-1/M-3 项+检查点 25 | grep 65 在位；注释与 git 事实一致 | 10min | 2f/10l/10min | 无 | pending |
| S25 | CR 修复批B：selftest-requirement-coverage.sh RC-15 块头注/WhatWhy ^65→^66、63.→66.（M-5）+lib/install-companion.sh:20 注释左值 COMPAANION_DIR（L-1） | executor（sonnet-1） | S14 返回 M-5/L-1 项 | RC-15 块内三处一致 ^66 | 10min | 2f/10l/10min | 无 | pending |
| S26 | CR 修复批C：scripts/sync-companion.sh:16 COMPAANION 拼写（L-2）+selftest-registry.tsv 10 行 config properties=40→42（L-3） | executor（sonnet-1） | S14 返回 L-2/L-3 项 | 拼写 0 残留；42 行数一致 | 10min | 2f/15l/10min | 无 | pending |
| S27 | CR 修复批D：docs/ARCHITECTURE.md:17,64 计数口径统一（M-2，106=ls 含 2 子目录或 104 文件如实）+INSTALL_zh.md:290 config 键 40→42（M-4a） | executor（sonnet-1） | S14 返回 M-2/M-4 项 | 文内口径一致 | 10min | 2f/10l/10min | 无 | pending |
| S28 | CR 修复批E：skills/task-planner/README.md:69 config 键 40→42（M-4b） | executor（sonnet-1） | S14 返回 M-4 项 | grep 42 在位 | 5min | 1f/3l/5min | 无 | pending |

### Phase 4: 回归验证 + CR + 对齐审查
- [x] 全量 selftest 复跑，与 Phase 1 基线 diff（VC-1）——62/62 per-log FAIL=0，ΣFAIL=0（基线 4→0）
- [x] Code Review Gate：CHANGES_REQUESTED M5+L3 → 修复 commit 88e6248
- [x] alignment-review：CHANGES_REQUESTED P1×3+P2×3 → 修复 commit 8b72435+簿记
- [x] 审查意见 fix 闭环（两轮各一轮收敛）
- **V-N:** VC-1, VC-5
- **Status:** complete（2026-10-09：drift-check 判 DRIFT 簿记面 2 项已整改——progress Phase 4 回填+本计划字段同步；回归口径勘误=per-log Total FAIL=0 为准，summary exit 列无效已登记）
- **Executor:** code-runner-agent（mini）+ code-reviewer（sonnet-1）+ general-purpose（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|
| S13 | 全量 selftest 复跑与基线 diff | code-runner-agent（mini） | skills/task-planner/scripts/selftest-*.sh（62 个）+ P1 基线清单 | 无基线外新增 FAIL | 15min | 0f/0l/15min | 无 | pending |
| S14 | Code Review：worktree 全 diff 代码文件审查 | code-reviewer（sonnet-1） | worktree 内 git diff master...HEAD 摘要 | APPROVED 或 fix 清单 | 15min | 0f/0l/15min | 无 | pending |
| S15 | alignment-review 对齐审查（42.6.2） | alignment-reviewer（sonnet-1） | 本次全部更新文档清单 | APPROVED 或 fix 清单 | 15min | 0f/0l/15min | 无 | pending |

### Phase 5: 合并回 + 部署 + 簿记交付
- [x] master 先并入 worktree 解冲突（v150 并行已进 master：5 处冲突并集解决，合并态回归 ΣFAIL=0）→ smart-merge-back --deploy 合并（master=0ff54bd）+ worktree/分支清理
- [x] 主仓关键文件 Read 复验（SKILL 509 行/1-65/Rule 65 块在位/无「61 预留未落地」）+ 在役三位逐文件 IDENTICAL（claude/opencode 由 smart-merge-back 对账，zcode 手工 diff 复验）
- [x] cursor 位重同步 IDENTICAL（D26）+ companion/.backup-* 5 目录移出扫描路径至 ~/.task-planner-backups/relocated-cursor-companion-backup/（D27，移出非删除）
- [x] INDEX 状态翻 complete + rule-reserve land 65 + 簿记提交
- [x] delivery-summary 五要素交付 + memory 更新
- **V-N:** VC-4, VC-6
- **Status:** complete（2026-10-09）
- **Executor:** 主进程（例外理由：① 纯 git/worktree 编排 + ② 计划系统文件簿记——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（信号①=本任务自产计划文件 2 项，无他任务重叠；worktree list 仅主仓；无遗留 wt 分支；INDEX 待处理区 7 项均为已完结任务的陈旧状态行=本任务 F1 修复对象，非真实在途） |
| `isolation` | `worktree`（技能文件=保护区+运行中基础设施，§11.1.1 命中） |
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/task-v149-skill-alignment-audit |
| `branch` | wt/task-v149-skill-alignment-audit（基点 master=21f7e6b） |
| `merge_back` | merged(0ff54bd)（先 merge master 解 5 冲突并集 b59b90e，再 smart-merge-back --deploy） |

## 📊 FMEA 预演

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 2 | 子代理扫描漏报/误报 | 7 | 5 | 6 | 210 | 发现须附 file:line 锚，主进程抽验 ≥3 条（43.1）；漏报由 Phase 4 回归与终验抽验兜底（22.3④ 接管抽验） |
| Phase 3 | 修复引入新 selftest FAIL | 8 | 4 | 3 | 96 | 逐批修后跑受影响 selftest；Phase 4 全量回归最终兜底（22.3② 拆细回炉） |
| Phase 4 | 基线漂移误判（master 间隙前进） | 6 | 3 | 4 | 72 | 回归前重取 master 基点对照（v120 基线漂移一手复测范式） |
| Phase 5 | 部署位同步遗漏/半同步 | 7 | 3 | 2 | 42 | install 通道部署+逐文件 diff 对账（VC-4 硬门），禁手工散改 |

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-08 | S1 已建映射 |
| Phase 2 | ☑ | 2026-10-08 | S1 已建映射 |
| Phase 3 | ☑ | 2026-10-08 | S1 已建映射 |
| Phase 4 | ☑ | 2026-10-08 | S1 已建映射 |
| Phase 5 | ☑ | 2026-10-08 | S1 已建映射 |

## Key Questions

1. 62 个 selftest 在 master 当前的真实 FAIL 基线是多少？逐条属于已知基线还是新缺陷？（Phase 1 实测回答）
2. 三部署位拓扑实态：除 ~/.zcode 位外，cursor 位/opencode 位是否在役？DCS-20 部署债范围？（Phase 2 S4 回答）
3. 已知遗留 ≥10 项中哪些已被后续任务顺手修掉（避免重复修）？（Phase 1/2 逐项核对回答）

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| interaction_mode=silent | /goal 自主会话无实时用户；R3「发现之后必解决」= 概括授权；D6 硬停点仍停；静默决策清单随交付呈报 |
| 先簿记入库再开任务（21f7e6b） | v146/v148 完结簿记未提交会与新任务变更混杂；纯 plans/ 文档直提（§11.5.2 纯文档例外） |
| .drift-rhythm/ 入 gitignore | v148 hook 会话运行态计数器，同 .plan_required_side/ 类，不入库 |
| Phase 3 S-unit 表含种子批+占位批 | 已知遗留可计划期预填；审计新发现按 B 类重规划增行+重锁 attest（诚实路径，禁计划外执行） |
| 共享追踪不适用 | 本任务认领对象=技能本体全量对齐，无可枚举的部分认领共享资源（非「同类任务 ≥3 次部分认领」形态） |
| Phase 3 drift 整改重锁（2026-10-09，纠正编号 DRIFT-P3） | drift-check 判定 DRIFT 低危行政面 4 项：scope 表补录 examples/+技能文档、S8 检查点代写、registry:61 修正（commit aa06dde）、状态行对齐——随本次重锁登记 |
| S13 回归改主进程白名单③接管（2026-10-09，纠正编号 CR-S13） | code-runner 派发两次被会话环境取消（stream 恢复中断）；机械验证命令=Rule 25.3 白名单③，输出落 /tmp+检查点 |
| CR 修复批 S24-S28 增行（2026-10-09，纠正编号 CR-FIX） | S14 CHANGES_REQUESTED M×5+L×3 全为文本/注释级修正，按 ≤2f/行拆 5 行重锁承接 |
| S15 改派 general-purpose 执行 alignment-review skill（2026-10-09，纠正编号 ALIGN-S15） | alignment-reviewer 具名 agent 本会话 Agent 工具面不存在；按 Rule 42.2 四级检测回落=用户级 skill 通道 |

## Errors Encountered

| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
|       | 1       |            | → progress.md Error Log   |

## Notes

- 审计种子=memory 12+ 条遗留（带验证戳），Phase 1 归集入 findings.md 后以文件为准（54.5 决策依据落盘）
- 功能性删除/语义改写逐项登记清单随交付呈报（Rule 36.4；默认纯增量修正，过时内容=修正非删除）
- 用户否决禁令源：notepad-learnings.md「被否决方案」段+memory（执行期提方案前必查，Rule 32.2）

## 🚨 Drift Log（漂移检测记录）

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-08 22:56 | ALIGNED（检查点 subagent-state/06-drift-checker.md；drift-checker 档位 provider 拒→22.3① 改派 general-purpose） | VC-2/VC-3 | Phase 1-2 推进在 Goal 与 scope 内；整改两条（progress 回填+Error Log 补记）已执行后翻态 |
| 2026-10-09 | DRIFT 低危行政面（检查点 23-drift-checker-p3.md；改派 general-purpose） | VC-2/VC-3 | 4 项整改全消解：①scope 表补录 examples/+技能 INSTALL/MIGRATION/ARCHITECTURE（B 类重规划）②S8 检查点主进程代写补齐 ③registry:61 残留修正（aa06dde）④状态行对齐；4/4 抽查属实+无过度修复 |
| 2026-10-09 | DRIFT 簿记面 2 项（检查点 35-drift-checker-p4.md） | VC-1/VC-5 | 实质面全闭环（两轮 CHANGES_REQUESTED 8+6 项对应两 commit）；整改：progress Phase 4 回填+本计划 Current Phase/Next Step/Status 同步；回归判定口径勘误=per-log Total FAIL=0（summary exit 列因命令替换重置 $? 无效） |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 4 / 5（P1 code-runner 基线跑批+P2 四审计+P3 全部修复批+P4 CR/对齐审查；P5 主进程白名单①②） |
| 主进程直做 Phase 清单 | P5（① git/worktree 编排+② 簿记）、S13 回归接管（③ 机械验证，两次派发被环境取消，Decisions CR-S13）、S8 检查点代写（22.8 产出物采信）、CHANGELOG 条目（⑥ trivial ≤3 行）、簿记 P2 项（②）——全白名单 |
| 委派率 | 0.8（≥0.7 floor；直做清单全白名单内，WHITELIST 合规） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 10-08 21:5x | code-runner-agent | 全量 selftest 基线（后台） | done | 62 脚本 ΣFAIL=4 全 periodic | 01-code-runner-agent.md | §基线段 | subagent-state/01-code-runner-agent.md | provider 终错但检查点完整/0 / ☑ |
| 2 | 10-08 22:1x | Explore | 四面审计并行×3+部署面 general-purpose×1（一致性/文档/三面对齐/部署） | done | 57 项发现（H16/M22/L19） | 02-05 检查点 | §处置表 D1-D36 | 02/03/04/05-*.md | S1 无 Write 由主进程代写/0 / ☑ |
| 3 | 10-08 22:5x | general-purpose(改派) | Phase1-2 drift 检查 | done | ALIGNED+2 整改已执行 | 06-drift-checker.md | Drift Log | 06-drift-checker.md | haiku 拒改派 22.3①/0 / ☑ |
| 4 | 10-08 23:5x | executor | S7 Rule 65 恢复 | done | CR:802-834+PR 10 断言重接 | critical-rules:802 | D6/D7 | 07-executor-S7.md | ☑ |
| 5 | 10-09 00:1x | executor | S16 SKILL 对齐+S5 INDEX+S6 头注 | done | D2-D5/D1/D22 全 fixed | SKILL:9,210,278 | D1-D5/D22 | 08/09/10-*.md | 两次契约拦截后过/0 / ☑ |
| 6 | 10-09 00:3x | executor×7 | 守卫级联 LA/RC/SR/TS/WF/DCS/RF/FF/EG/IP/split | done | 各自验 FAIL=0 | 11-16+32 检查点 | D8 | 11-16,32-*.md | ☑ |
| 7 | 10-09 00:4x | executor×6 | 行号锚/文档/机制/部署准备/registry 批 | done | D9-D28 全 fixed | 17-22 检查点 | D9-D28 | 17-22-*.md | S8 返回死循环但产出完好已 diff 采信/0 / ☑ |
| 8 | 10-09 | general-purpose(改派) | Phase3 drift 检查 | done | DRIFT 低危 4 项整改全消解 | 23-drift-checker-p3.md | Drift Log | 23-*.md | commit aa06dde/0 / ☑ |
| 9 | 10-09 | executor×5 | CR 修复批 S24-S28 | done | M×5+L×3 全闭环 commit 88e6248 | 27-31 检查点 | CR 闭环 | 27-31-*.md | S14 判 CHANGES_REQUESTED 后修复/0 / ☑ |
| 10 | 10-09 | code-reviewer | S14 CR 审查 | done | CHANGES_REQUESTED M5+L3（已全修） | 25-code-reviewer-S14.md | D37-D39 | 25-*.md | ☑ |
| 11 | 10-09 | general-purpose | S15 对齐审查（skill 承载） | done | CHANGES_REQUESTED P1×3+P2×3（P1 已修，P2 簿记本表） | 26-alignment-reviewer-S15.md | D39 | 26-*.md | alignment-reviewer agent 缺位改派/0 / ☑ |
| 12 | 10-09 | 主进程(白名单③) | S13 回归两次派发被环境取消后接管 | done | 首轮 ΣFAIL=2（新引入）→F 批修复 | /tmp/v149-final-*.log | D38 | progress Phase 4 段 | Decisions CR-S13/0 / ☑ |
| 13 | 10-09 | executor×3 | 对齐修复批 F1/F2/F3 | done | 锚漏网+P1×3 全修 commit 8b72435 | 32-34 检查点 | D38/D39 | 32-34-*.md | ☑ |

## 🔁 模板感知

<!-- template_type: general -->
- 触发信号: 任务类型空缺 → 落 general 兜底
- Rule 34.3②: 沉淀预登记 —— 终验时按 34.3 三条件评估（本任务=审计修复类，16 类已有类型不含，评估沉淀价值）
- 处置登记处: 不沉淀——本任务为一次性全量审计修复，无可泛化的重复性流程模板（审计四面扫描法已在计划 S-unit 表与 kb §4 沉淀为易错点清单，后续同类任务可直接复用 kb）
