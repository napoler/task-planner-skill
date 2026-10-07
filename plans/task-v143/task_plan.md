# Task Plan: 新增 Rule 58 — 调研分析证据纪律与核心目标达成门控

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「比如说我让它调研，就是分析内容存在的问题，为什么会存在这种问题？就是内容质量对比，就是对内容进行评估。为什么没有能获得很好的流量？但它实际上，然后就在乱分析」
- **R2**: 「分析过一控之后，就解决了，就就就停止了，在没解决的情况就停止了。它连最基本的去分析对竞争对手做竞品分析，竞争对手的能力都没有做任何分析，然后就下了结论」
- **R3**: 「这种结果是让人没有任何的信服可言。完全违背了有理有据，所谓的都依赖于依赖于证据。这种情况是严重违背了违背了真实性以及有依据的原则」
- **R4**: 「这是严重的缺陷，必须纠正，确保后期执行任何任务的时候都不会偏移，就是用户核心任务」
- **R5**: 「除了偏移核心任务这一点之外，还有就是一定要解决问题，别特么的不解决问题，再乱七八糟绕弯消耗资源」

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2 | 证据面清单条款+对标取证强制条款存在于 critical-rules.md（grep 锚命中） |
| R2 | VC-2, VC-5 | 对标取证条款+完成裁决门条款存在（竞品没分析不许下结论；没解决不许 COMPLETE） |
| R3 | VC-3 | 结论-证据锚定与反证检查条款存在（每结论必引证据锚） |
| R4 | VC-6, VC-9 | 模板双区块注入（每次 init 自带=任务级强制）+SKILL 摘要与合规清单项 |
| R5 | VC-4, VC-5 | 手段/目标二分+因果链条款（防绕弯）+三态裁决门（solved/partial/not-solved） |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 需求采集 | 手段型/目标型需求不二分——「解决流量问题」（目标）被「做分析」（手段）顶替，VC 只定义报告完成 | Rule 58.4 二分条款+模板需求区 [手段]/[目标] 标注 | VC-4, VC-6 |
| 调研执行 | 证据面无清单无强制取证——竞品对照/数据源交叉验证被整面跳过 | Rule 58.1 证据面清单+58.2 对标取证强制+模板「🔍 证据面清单」区块 | VC-1, VC-2, VC-6 |
| 结论产出 | 结论无证据锚无反证检查，推测包装成结论 | Rule 58.3 结论-证据锚定 | VC-3 |
| 完成裁决 | 交付物（报告）冒充问题解决，not-solved 也判 COMPLETE | Rule 58.5 完成裁决门（三态+禁冒充） | VC-5 |
| 活动取舍 | 分析活动与核心目标无因果链，绕弯消耗资源 | Rule 58.6 手段-目标因果链 | VC-4 |
| 机制守护 | 无静态守护脚本，条款可被无声破坏 | selftest-evidence-goal-gate.sh+TSV 登记 | VC-7 |
| 回归防线 | 新增条款可能破坏既有 53 脚本断言 | 全量 selftest 回归 | VC-8 |
| 部署一致性 | 仓改动未同步部署位（~/.zcode/skills/task-planner） | 五部署位 diff IDENTICAL | VC-10 |

## Goal

新增 Rule 58（7 子条：58.1 证据面清单 / 58.2 对标取证强制 / 58.3 结论-证据锚定与反证 / 58.4 手段-目标二分与解决判据 / 58.5 完成裁决门 / 58.6 手段-目标因果链 / 58.7 机制），计划模板注入「🔍 证据面清单」+「🎯 核心目标达成裁决」双区块，selftest 静态守护——根治调研/分析类任务「无据结论」与「不解决问题即停」双缺陷。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | `afd0b28ec78a4e8ca9f0acde60eeaaf7` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v143` |
| `scope_files` | `skills/task-planner/references/critical-rules.md, skills/task-planner/templates/task_plan.md, skills/task-planner/SKILL.md, skills/task-planner/scripts/selftest-evidence-goal-gate.sh, skills/task-planner/scripts/selftest-registry.tsv` |
| `interaction_mode` | `silent` |
| `new_rule` | `58` |
| `质量审查工具` | `code-quality-review agent`（既有池成员；条款+脚本改动走代码质量审查面） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：本计划验证动作默认由独立子代理执行（Executor 字段可填 V-类执行体），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 58 条款存在且含证据面清单子条（58.1） | grep 锚断言 | `grep -c '### 58 ' skills/task-planner/references/critical-rules.md` ≥1 且 `grep -c '58\.1' 同文件` ≥1 |
| VC-2 | 58.2 对标取证强制条款存在，含「竞品/对标」强制取证语与「无对照禁归因」禁令 | grep 锚断言 | `grep -n '58\.2' critical-rules.md` 命中且含对标取证关键词 |
| VC-3 | 58.3 结论-证据锚定与反证检查条款存在（每结论必引证据锚+无据标推测） | grep 锚断言 | `grep -n '58\.3' critical-rules.md` 命中 |
| VC-4 | 58.4 手段/目标二分与 58.6 手段-目标因果链条款存在（防绕弯消耗） | grep 锚断言 | `grep -n '58\.4\|58\.6' critical-rules.md` 双命中 |
| VC-5 | 58.5 完成裁决门条款存在：solved/partial/not-solved 三态显式裁决+禁「交付物冒充问题解决」+not-solved/partial 禁 COMPLETE | grep 锚断言 | `grep -n '58\.5' critical-rules.md` 命中且含三态关键词 |
| VC-6 | 计划模板含「🔍 证据面清单」+「🎯 核心目标达成裁决」双区块 | grep 模板文件+init 冒烟 | `grep -c '证据面清单\|核心目标达成裁决' skills/task-planner/templates/task_plan.md` ≥2 |
| VC-7 | selftest-evidence-goal-gate.sh 存在、执行 PASS、登记 TSV | 运行脚本+grep TSV | `bash skills/task-planner/scripts/selftest-evidence-goal-gate.sh` exit 0 |
| VC-8 | 全量 selftest 无回归（基线以 Phase 4 开跑时 master 实测为准，逐脚本 FAIL=0） | 全量回归 | Phase 4 记录基线数+复测数 |
| VC-9 | SKILL.md 含 Rule 58 摘要行+合规检查清单项 | grep 断言 | `grep -c 'Rule 58' skills/task-planner/SKILL.md` ≥2 |
| VC-10 | 部署位同步 IDENTICAL（diff=0） | diff 仓版 vs 部署位 | `diff -r` 关键 5 文件 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：`code_review: required`，终验前必须先通过 Code Review Gate，否则不得标记 COMPLETE。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则文档 | `skills/task-planner/references/critical-rules.md`（仅追加 Rule 58 段） | 改既有 Rule 1-57 原文 |
| 模板 | `skills/task-planner/templates/task_plan.md`（仅追加双区块） | 改既有区块结构 |
| 主技能 | `skills/task-planner/SKILL.md`（仅追加摘要行+合规清单项） | 改既有段落 |
| 脚本 | `skills/task-planner/scripts/selftest-evidence-goal-gate.sh`（新增）、`skills/task-planner/scripts/selftest-iteration-persistence.sh`（仅 IP-14 负断言 58.x→59.x 合并级联演进——Rule 58 合法落地使 57 块尾负断言过期，task-v127 RC-15 演进同范式）、`skills/task-planner/scripts/init-session.sh`（仅 CR-fix F-1：新增 inject_evidence_goal_block 兜底注入函数+调用行，纯增量镜像 51.1 注入范式，既有函数零改动） | 其他 .sh 文件 |
| 登记 | `skills/task-planner/scripts/selftest-registry.tsv`（追加 1 行） | 改既有行 |
| 簿记 | `plans/task-v143/**`、`plans/.rule-reservations.jsonl`（land 58 一行） | 其他 plans 目录 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | critical-rules.md Rule 50-55 条款格式惯例（标题行四要素：P0/日期/task 号/目标+判定面+衔接声明） | `/mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md:538-652` | 必读 | ☑ |
| 项目内部文档/知识库 | Explore 缺口侦察报告（Q1-Q7 证据行号） | 本会话 2026-10-07 侦察产出（findings.md 已落盘） | 必读 | ☑ |
| 项目内部文档/知识库 | 模板双区块注入点与 init-session.sh 注入机制 | `skills/task-planner/templates/task_plan.md` + `scripts/init-session.sh:92-138` | 必读 | ☑ |
| 项目内部文档/知识库 | selftest 脚本模式（断言函数+TSV 注册） | `scripts/selftest-execution-honesty.sh`（Rule 54 先例） | 必读 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 技能对调研/分析类任务缺两道门——①下结论前无证据面强制（竞品对照可整面跳过）→无据结论；②完成判据只看需求条目覆盖（报告写完=covered）→不解决问题即停。本任务补这两道门后，同类任务产出结论必有据、完成必以「用户核心问题解决状态」裁决。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（调研/分析类任务产出可信+问题导向）
- [x] 核心问题不解决，其他工作都白费吗？（规则条款写得再多，不堵这两口就是无效产出）
- [x] 核心问题的解决方法是清晰的、可执行的？（条款+模板+selftest 三载体，历史 Rule 50-57 同构先例）

## Current Phase

Phase 5（全部 complete，outcome COMPLETE）

## Next Step

（无——任务完成；遗留行动项见 delivery-summary.md 第四节）

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | 机械守卫脚本（rule-reserve 已用）+主进程 | 条款撰写依赖会话记忆中的条款格式惯例，主进程直做（25.3② 白名单） |
| Phase 2-3 | 主进程 | 模板/SKILL 增量小且格式敏感（25.3②） |
| Phase 4 | 机械守卫脚本 + Agent 子代理 code-runner-agent | selftest 新脚本主进程写，全量回归派 code-runner-agent 隔离跑 |
| Phase 5 | Agent 子代理 code-quality-review + 主进程 git 编排 | CR 派审查 agent（42 池），合并/部署主进程（①白名单） |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件 → 按 Rule 21.4 独立性守门调度（本任务 Phase 1-4 串行强依赖：条款→模板→摘要→守护，文件集重叠 critical-rules/SKILL 面，声明全串行）

## Phases

### Phase 1: Rule 58 条款撰写（critical-rules.md 追加）
- [ ] 7 子条条款全文撰写（58.1-58.7），标题行四要素齐全（P0/日期/task-v143/目标+判定面+衔接）
- [ ] 衔接声明：衔接 Rule 51.3（完成对照门）/54.0（有依据）/53.1（根源审计）/22.3（换道），既有 Rules 原文零改动
- [ ] findings.md 回填条款锚行号
- **V-N:** VC-1, VC-2, VC-3, VC-4, VC-5
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单；条款措辞质量依赖 82 任务会话记忆，同 task-v136/v141 先例）
- **Started:** 2026-10-07

### Phase 2: 模板双区块注入（templates/task_plan.md）
- [ ] 「🔍 证据面清单」区块（适用判定+三基线面：自身样本/对标样本/外部约束+每面取证记录列）
- [ ] 「🎯 核心目标达成裁决」区块（手段/目标标注+solved/partial/not-solved 三态+证据锚列）
- [ ] 不破坏既有区块（check-3file-gate 兼容）
- **V-N:** VC-6
- **Status:** pending
- **Executor:** 主进程（例外理由:② 同上）

### Phase 3: SKILL.md 摘要行+合规清单项
- [ ] Critical Rules 摘要区追加 Rule 58 一行（对齐 Rule 57 行格式）
- [ ] 合规检查清单追加 C 项（编号接现行最大值，Phase 3 查证）
- **V-N:** VC-9
- **Status:** pending
- **Executor:** 主进程（例外理由:② 同上）

### Phase 4: selftest 守护脚本+全量回归
- [x] selftest-evidence-goal-gate.sh 撰写（EG-01..EG-20 静态断言）——20/20 PASS
- [x] selftest-registry.tsv 登记（+1 行，56 行）
- [x] IP-14 负断言合并级联演进（58.x→59.x，scope 已补登记）
- [x] 全量 selftest 回归（master 基线 FAIL 面与 worktree 完全一致+IP-14 改善，零新增回归；检查点 subagent-state/04-regression.md）
- [x] init 冒烟：临时目录 init 产物含双区块（证据面清单/达成裁决 grep=2）+[手段]/[目标] 引导=3
- **V-N:** VC-7, VC-8
- **Status:** complete
- **Executor:** 主进程（例外理由:② 同上；code-runner-agent 派发 provider 失败 1 次，22.3① 改道主进程，记录于检查点）
- **Started:** 2026-10-07
- **Ended:** 2026-10-07

### Phase 5: CR Gate+合并回+部署同步+簿记
- [ ] Code Review（code-quality-review agent，REQUIRED）
- [ ] CR 发现清零后合并回 master（--no-ff）+worktree 清理
- [ ] 部署位同步（~/.zcode/skills/task-planner 等）+diff IDENTICAL 验证
- [ ] 簿记：progress/verification/delivery-summary/rule-reserve land 58/INDEX
- **V-N:** VC-9, VC-10
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）
- **Started/Ended:** 2026-10-07
- 补记: CR APPROVED-WITH-NOTES→F1-F7 闭环；合并撞号仲裁 58/60（v142 强占）；96c474c；部署 7 文件 IDENTICAL

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（task-v142 今日刚预留 Rule 57 且 scope_files 含 critical-rules.md/SKILL.md，存在同文件并行写入风险；对策=追加式改动（文件尾/行内追加）+合并前重扫主仓） |
| `isolation` | `worktree` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v143` |
| `branch` | `wt/task-v143` |
| `merge_back` | `merged(96c474c)` |

## 📊 FMEA 预演（规划期）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 1 | 既有 selftest 断言锚被新增行号/计数破坏（历史级联教训） | 7 | 5 | 3 | 105 | Phase 4 全量回归必跑；FAIL 时按「口径扩展非回退」范式同步守卫锚（22.3④ 主进程接管） |
| Phase 5 | task-v142 并行会话同窗合并冲突 critical-rules.md | 7 | 4 | 2 | 56 | 合并前 git status 重扫；冲突时基点 rebase 解冲突后合并 |
| Phase 5 | worktree 从 master 建后文件与主仓不同步（task-v135/141 教训） | 6 | 4 | 2 | 48 | 建树后先 diff 关键 5 文件确认一致再动工 |

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-07 | 计划批准时建 |
| Phase 2 | ☑ | 2026-10-07 | 同上 |
| Phase 3 | ☑ | 2026-10-07 | 同上 |
| Phase 4 | ☑ | 2026-10-07 | 同上 |
| Phase 5 | ☑ | 2026-10-07 | 同上 |

## Key Questions

1. Rule 58 的适用面边界？→ 调研/分析/评估/归因/优化类任务（计划期能机械识别的触发词面），纯执行类不适用（避免过度门控拖慢 L0/L1 微任务）
2. 三态裁决门与 Rule 51.3 covered/partial/uncovered 的关系？→ 正交且叠加：51.3 管「需求条目覆盖」，58.5 管「目标型需求的核心问题解决状态」；目标型需求两者都必须出表
3. 对标取证强制的豁免面？→ 用户明确豁免对照/任务无对标对象可取（须登记理由，禁裸豁免，对齐 53.1 反裸豁免惯例）

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 单一 Rule 58 承载双缺陷（7 子条），不拆 Rule 58+59 | 两缺陷同根=完成判定链条缺「用户核心目标」锚；历史 Rule 51（6 子条）/54（7 子条）先例支持单 Rule 多子条 |
| 模板双区块为主要强制载体 | 用户 R4「确保后期执行任何任务」→ 模板随 init 全任务注入=每次任务强制携带；条款只管行为面，模板管载体面 |
| Rule 56 跳号不回填 | 账本无 56 记录、正文无 56 条款，跳号既有事实不动（编号连续性非 P0） |
| task-v142 撞号 57 问题只记录不修 | 非本任务范围（§四 范围纪律）；land 58 时在 note 附带登记提醒 |

## Errors Encountered

| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
|       | 1       |            | → progress.md Error Log   |

## Notes

- Rule 57 已被 task-v141 landed（迭代测试轮次落盘），task-v142 的 57 预留疑似撞号——本任务不消费 57，预留时已验证 58 free
- v142 scope 与本任务重叠 critical-rules.md/SKILL.md——合并前必须重扫主仓（FMEA Phase 5 行）

## 🔁 模板感知（终验处置）
- 处置登记: **不沉淀 variant**——本任务产物即模板层增量（Rule 58 双区块+标注引导已入主模板与 init 兜底注入），非新任务类型方法论；34.3 三条件之"可复用新类型"不成立。
