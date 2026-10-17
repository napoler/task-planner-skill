# Task Plan: 新增 Rule 92 产出文件尺寸纪律与优先拆分
<!-- ===== frontmatter 头（Rule 16 选模板 + Rule 34.1 门控 + Rule 38.7 执行通道分级）===== -->
template_type: general
plan_tier: standard
execution_lane: L1

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「我希望就是向当前项目补充一个原则，就是说尽量减少单个文件、过大文件的……就是尽量避免单个文件过大」<sub>（[手段]）</sub>
- **R2**: 「我期望……可以优先拆分文件，就是做任务的时候，优先将文件拆分为多个，避免单个过大文件的产出」<sub>（[手段]）</sub>
- **R3**: 「尤其比如说写入代码之类的。因为代码之类的是非常容易的，可以拆分的。按照按照引用之类都可以拆分」<sub>（[手段]）</sub>
- **R4**: 「其他的也可以，其他文件也是类似的情况」<sub>（[手段]）</sub>
- **R5**: 「建议垂直化的拆分」<sub>（[手段]）</sub>
- **R6**: 「这样的话可以减少单个文件过大导致的负担」<sub>（[手段]）</sub>
- **R7**: 「我希望你就是添加相关条目，就是在要求就是规范要求在产出文件或者说产出写入的时候尽量避免单个文件过大」<sub>（[手段]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2 | 规则正文在位（grep 标题=1）且含「尽量避免单个文件过大」语义条款（92.1） |
| R2 | VC-1, VC-2 | 92.1/92.2 含「优先拆分」条款与触发参考线 |
| R3 | VC-2 | 92.3 代码拆分子条在位（含「引用」关键词） |
| R4 | VC-2 | 92.4 非代码文件子条在位 |
| R5 | VC-2 | 92.5 垂直化拆分边界子条在位（含「垂直」） |
| R6 | VC-1 | 建制段（Why）在位，承载「负担」理由 |
| R7 | VC-3 | 全集索引级联 1-92 完成（规范条款进入技能路由面） |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
- **专档路径**：`plans/task-v185-file-split-discipline/user-session-log.md`
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

不适用（非结果级需求）——R1-R7 均为「添加规则条目」的单点制度动作（手段型），无「确保 X 质量/性能/可靠」类结果级诉求，无生产管线工序链可审计。

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3）
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | Goal；VC 表；R1-R7 原文；落点卫星=task-discipline；编号=92；L0-T 零新增守护脚本/零新 config 键 | 本计划各节 |
| 🔀 可变量 | 规则子条款措辞细节、S-unit 编辑顺序、selftest 断裂锚的最小修复方式、派发批次编排 | - |
| 📈 学得量 | 级联锚实测结果、既有口径漂移清单、并行指针竞态实况 → findings.md | findings.md |

## Goal

向 task-planner 技能补充 Rule 92「产出文件尺寸纪律与优先拆分」（落 task-discipline 卫星，L0-T 文本优先、零新增守护脚本），并完成全集索引 1-91→1-92 编号级联与全量回归零破坏、合并回 master。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required`（技能文件修改，谨慎胜过速度 §十三；轻量单轮） |
| `session_id` | `fae73c58a87848799b51ae47a36810ea` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v185-file-split-discipline` |
| `scope_files` | worktree: skills/task-discipline/references/critical-rules-discipline.md, skills/task-discipline/SKILL.md, skills/task-planner/SKILL.md, skills/task-planner/references/critical-rules.md, skills/task-planner/README.md（±selftest 断裂锚最小修复）；主仓: plans/task-v185-file-split-discipline/**, plans/INDEX.md, plans/.rule-reservations.jsonl |
| `interaction_mode` | `silent`（自主会话；用户指令原文=授权锚 user-session-log #1；D6 硬停点两模式一致不受影响） |
| `对齐审查` | `[登记]` alignment-review 单轮（终验前，纯文本小 diff 轻量档） |
| `自动超时默认项` | 本任务无 2+ 选项询问点（silent 自主）；若触发，默认=推荐项、超时 5min（Rule 44 默认） |
| `new_rule` | `92` |
| `质量审查工具` | Code Reviewer agent（CR 门）+ alignment-review（收尾对齐）+ drift-checker（Phase 2 后）；review-library 池覆盖，无缺口（Rule 42.2 四级检测结论） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：终验核查由 Verifier 子代理执行（Phase 5），主进程仅编排与簿记（Rule 33.3）。

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 92 正文在位：标题 1 处+七子条（92.1-92.7） | grep 计数 | `grep -c "^### 92 产出文件尺寸纪律与优先拆分" skills/task-discipline/references/critical-rules-discipline.md` 输出 1；`grep -cE "\*\*92\.[1-7]" 同文件` ≥7 |
| VC-2 | 内容覆盖 R2-R5：优先拆分/代码按引用拆/其他文件/垂直化 四语义各有条款承载 | grep 关键词 | Rule 92 段内「优先拆分」≥2、「引用」≥1、「垂直」≥2、92.4 非代码条款在位 |
| VC-3 | 编号级联完成：全集口径 1-92、旧口径零残留、两处清单含 92 | grep 双向 | `grep -cE "(Rules )?1-92" skills/task-planner/SKILL.md`≥3；`grep -c "1-91" skills/task-planner/SKILL.md skills/task-planner/README.md` 均 0；task-discipline/SKILL.md 与核心 critical-rules.md 的 task-discipline 清单含 ",92" |
| VC-4 | 全量回归零破坏 | 跑套件 | `bash skills/task-planner/scripts/run-selftests.sh --fresh`（worktree）末行 `FAIL=0` |
| VC-5 | 编号账本 landed | 台账查询 | `bash skills/task-planner/scripts/rule-reserve.sh check 92` 显示 task-v185-file-split-discipline 持有（landed） |
| VC-6 | 合并收口干净：主仓 scope 零未提交+worktree 已清理 | git | `git status --short` scope 零残留；`git worktree list` 无 task-v185 路径 |

**终验规则**：全部 VC 通过 → COMPLETE；有已知遗留 → PARTIAL（列出）；≥1 VC 三次重试无效 → BLOCKED。

## 🎯 核心目标达成裁决（Rule 58.5）

n/a（纯手段型任务）——R1-R7 全部标注 [手段]（用户只要「添加规则条目」动作与产物，无问题待解的结果级诉求），与本需求区标注一致，禁裸豁免。

## 🎯 Goal 单元表（Rule 66.1）

| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 规则落地 | Rule 92 全文入 discipline 规则文件 | `grep -c "^### 92 产出文件尺寸纪律" skills/task-discipline/references/critical-rules-discipline.md`=1 且 92.1-92.7=7 | S1/Phase 2 | pending |
| G2 | 级联完成 | 全集索引口径升 1-92 且旧字面零残留 | `grep -c "1-92" skills/task-planner/SKILL.md`≥3 ∧ `grep -rc "1-91" SKILL.md README.md`=0 | S2,S3/Phase 2 | pending |
| G3 | 回归绿 | 全量 selftest FAIL=0 | worktree 内 `run-selftests.sh --fresh` 末行 FAIL=0 | S4/Phase 3 | pending |
| G4 | 合并收口 | --no-ff 合并回 master+worktree 清理+台账 land | `git log --oneline -3` 含 merge commit ∧ `git worktree list` 无本任务 ∧ check 92=landed | Phase 4-5 | pending |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 技能规则/索引（worktree 内） | skills/task-discipline/references/critical-rules-discipline.md、skills/task-discipline/SKILL.md、skills/task-planner/SKILL.md、skills/task-planner/references/critical-rules.md、skills/task-planner/README.md | 其他技能文件；既有规则条目正文（零改动）；部署位（~/.zcode/skills/**） |
| selftest（如回归断裂） | 断裂锚所在 selftest-*.sh 的最小口径修复 | 新增 selftest/registry（L0-T 禁） |
| 主仓簿记 | plans/task-v185-file-split-discipline/**、plans/INDEX.md、plans/.rule-reservations.jsonl | 他人计划目录；task-v184 目录；根 CHANGELOG/progress.md |
| git | worktree 分支 wt/task-v185-file-split-discipline、master --no-ff 合并 | 遗留分支 wt/task-v168-machine-parked（他域，禁碰）；git 手术（reset/clean） |

**执行前自我检查**：本表全部列出 ✓；改动均服务 R1-R7 ✓；用户指令明确要求 ✓。

## 📋 变更标注表（Rule 74.3）

| 编号 | 对象（文件+锚点） | 类型 | 吸收判定 | 依据 | 执行动作 |
|------|------------------|------|---------|------|---------|
| CA-1 | worktree skills/task-discipline/references/critical-rules-discipline.md 文件末尾 | 新增 | 增量 | R1-R7 | 追加 Rule 92 全文（草稿=findings.md §Rule 92 草稿，逐字） |
| CA-2 | worktree skills/task-discipline/SKILL.md :24 规则清单、:28 规则索引表、:26 调用条件 | 更新 | 增量 | R7 | 清单+92；索引表+行 92；调用条件+「产出文件尺寸/拆分」关键词 |
| CA-3 | worktree skills/task-planner/SKILL.md :9/:17/:166/:179/:221 | 更新 | 增量 | R7 | 1-91→1-92（3 处）；两处 discipline 清单+92；:179 「其余 73 条」措辞不改（漂移只登记） |
| CA-4 | worktree skills/task-planner/references/critical-rules.md :182 task-discipline 路由行 | 更新 | 增量 | R7 | 清单+92 |
| CA-5 | worktree skills/task-planner/README.md :36/:81/:123 | 更新 | 增量 | R7 | 1-91→1-92（3 处字面） |
| CA-6 | selftest-*.sh（如有断裂锚） | 更新 | 增量 | VC-4 | 仅断裂锚最小口径扩展（非回退），逐处登记 |
| CA-7 | plans/.rule-reservations.jsonl | 新增 | 增量 | Rule 20.6 | attest 自动 reserve 92 + 终验 land 92 |
| CA-8 | plans/INDEX.md | 更新 | 增量 | 簿记 | sync-todos --index 刷新 |

## 📚 必要知识储备（开工前必填）

| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|-----------|------|---------|--------|
| 项目内部文档 | Rule 88/89/90 落位范式（标题格式/子条结构/L0-T 机制条） | skills/task-discipline/references/critical-rules-discipline.md 尾部 | 必读 | ☑ |
| 项目内部文档 | 级联面现状（1-91 字面分布/discipline 清单/路由表） | skills/task-planner/SKILL.md :9,:17,:166,:179,:221 + README :36,:81,:123 + 核心 critical-rules.md :182 | 必读 | ☑ |
| 项目内部文档 | 编号台账（91 已占用、92 空闲） | plans/.rule-reservations.jsonl + rule-reserve.sh next 实跑 | 必读 | ☑ |
| 规范/标准 | 用户宪法 §九 单文件尺寸口径 | ~/.zcode/AGENTS.md §九（≤5K 推荐/100K 绝对；代码>300 行/文档>500 行必拆） | 参考 | ☑ |

## ⚠️ 核心问题定义

**核心问题**: 任务产出物缺文件尺寸纪律，大单文件（读写/上下文/冲突/维护负担）无制度约束——解决=Rule 92 制度化+级联+回归绿，即可交付。

**核心问题判断**:
- [x] 核心问题解决后，结果能交付（规则在位+索引一致+回归零破坏）
- [x] 核心问题不解决，用户诉求（R1-R7）未被满足
- [x] 解决方法清晰可执行（落点/编号/级联面/范式均已考证）

## 🔍 调研需求与检索计划（Rule 75.1）

| S-unit/子目标 | 三态 | 检索关键词 | 检索渠道 | 预期产出形态 | 网络解难评估 |
|---------------|------|-----------|----------|--------------|--------------|
| S1 规则正文 | LOCAL-ONLY | Rule 88-90 范式、尺寸口径 | 本仓 Read（已完成，findings §草稿） | 规则草稿文本 | 否 |
| S2/S3 级联 | LOCAL-ONLY | "1-91"、rule 清单字面 | 本仓 grep（已完成，CA 表） | 编辑点清单 | 否 |
| S4 回归 | LOCAL-ONLY | run-selftests | 本地脚本 | 回归汇总行 | 否 |
| S5 终验 | LOCAL-ONLY | VC 命令 | 本地 grep/git | PASS 表 | 否 |

> 全 LOCAL-ONLY：计划期侦察已完成（编号台账/级联面/范式均第一手实跑取证），无网络依赖。

## 🔍 证据面清单（Rule 58.1）

n/a（纯执行类）——本任务产出=规则文本+索引级联，非结论/判断/归因类。

## Current Phase

Phase 4

## Next Step

主仓干净核对→merge --no-ff wt/task-v185-file-split-discipline→Read 复验→清理 worktree→CR Gate。

## 🧰 工具选择与编排（Rule 40）

| Phase | 命中工具面 | 选择理由 |
|-------|-----------|---------|
| Phase 1 | 机械守卫脚本（check-conflicts/attest/set-active-plan/plan-created） | 计划簿记+指针锚定（② 白名单） |
| Phase 2 | Agent 子代理 executor(sonnet-1)×3 | 技能文件默认派子代理（25.3 路由：>3 文件→executor） |
| Phase 3 | Agent 子代理 code-runner-agent(mini) | 测试跑批专用执行体（宪法 §十二 固化结论） |
| Phase 4 | 机械守卫脚本（smart-merge-back/git） | git 编排（① 白名单） |
| Phase 5 | Agent 子代理 Verifier(mini)+Code Reviewer+drift-checker+alignment-review | 独立终验（33.3）+CR 门+偏移检查+对齐审查 |

**workflow 编排判定**: 未命中编排条件（线性 5 步、无独立并行子任务、用户未点名 /workflow）→ 按 Rule 21.4 串行调度（S2/S3 同 Phase 串行派发）。
**/goal 对齐**: 用户未使用 /goal；Goal 单元表=完成审计证据源。

## Phases

### Phase 1: 计划与隔离基线
- [x] init 7 文件+side 指针锚定（sid=fae73c58…，全局指针存在 task-v184 并行竞态）
- [x] 侦察与编号考证（落点/级联面/台账，结论落 findings.md）
- [x] attest 锁定（SHA-256 194e4889…，六门全绿，rule 92 自动预留）+哨兵清除（plan-created.cjs）
- [x] worktree 创建+开工锚（Rule 90.1 首快照：主仓 HEAD=16951ff 即基线）+resolve 复验 ✓
- **V-N:** VC-5, VC-6
- **Status:** complete
- **Executor:** 主进程（例外理由:① 纯 git/worktree 编排 ② 计划系统文件维护——Rule 25.3 白名单①②）

### Phase 2: Rule 92 正文与编号级联（worktree 内）
- [x] S1 规则正文逐字落位（576→588 行，5/5 自验+主进程亲验）
- [x] S2 卫星 SKILL+主 SKILL 级联（7 处；VC-3 判据校准上报处置完毕）
- [x] S3 核心路由+README 级联（1+3 处）
- [x] 主进程 Read 复核产物+findings 回填+drift-checker 派发（ALIGNED，检查点+ledger tick2+Drift Log 行）
- **V-N:** VC-1 ✓(1/7), VC-2 ✓(3/4/6/1), VC-3 ✓(worktree 8 grep)
- **Status:** complete
- **Executor:** executor（sonnet-1）
<!-- S-unit 派发单元表（Rule 22.6） -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | Rule 92 全文逐字追加至 discipline 规则文件末尾 | executor(sonnet-1) | <plan>/rule92-draft.md（Rule 92 全文草稿，逐字转写）；<worktree>/skills/task-discipline/references/critical-rules-discipline.md（576 行，追加到末尾） | grep "^### 92 产出文件尺寸"=1 ∧ 92.[1-7]=7 | 15min | 1f/60l/15min | 无 | - | pending |
| S2 | 卫星与主 SKILL 编号级联 | executor(sonnet-1) | <worktree>/skills/task-discipline/SKILL.md（:24 清单+:26 调用条件+索引表）；<worktree>/skills/task-planner/SKILL.md（:9,:17,:166,:179,:221 五处） | 两文件 ",92" 命中且 1-92≥3、1-91=0 | 15min | 2f/15l/15min | 无 | S1 | pending |
| S3 | 核心路由与 README 级联 | executor(sonnet-1) | <worktree>/skills/task-planner/references/critical-rules.md（:182 一处+92）；<worktree>/skills/task-planner/README.md（:36,:81,:123 三处 1-91→1-92） | 两文件改点 grep 命中 | 15min | 2f/6l/15min | 无 | S1 | pending |

### Phase 3: 全量回归（worktree 内）
- [x] run-selftests --fresh 全绿：Total: 91 PASS=91 FAIL=0（run=91 reused=0，约 60s）
- **V-N:** VC-4 ✓(FAIL=0), VC-3 ✓（回归面同时复验级联未破坏）
- **Status:** complete
- **Executor:** code-runner-agent（mini）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S4 | worktree 全量 selftest 回归 | code-runner-agent(mini) | <worktree>/（git 工作树）；命令 bash skills/task-planner/scripts/run-selftests.sh --fresh | 末行 Total: N PASS=x FAIL=0；FAIL>0 时回传失败脚本名+断言行 | 15min | 1f/0l/15min | 无 | S2,S3 | pending |

### Phase 4: 合并回主仓
- [ ] 主仓干净核对（脏则 STOP 排队，Rule 88.4 禁 git 手术）→ merge --no-ff → Read 复验 → worktree+分支清理
- **V-N:** VC-6, VC-1
- **Status:** in_progress
- **Executor:** 主进程（例外理由:① 纯 git/worktree 编排——Rule 25.3 白名单①）

### Phase 5: 终验与交付
- [ ] CR Gate：Code Reviewer 单轮（APPROVED 才可终验）
- [ ] S5 Verifier 独立 VC 复验（主仓合并后终态）
- [ ] alignment-review 单轮（对齐审查登记项）
- [ ] rule-reserve land 92+INDEX 刷新+归档尝试（Rule 81.1，守卫拒绝则登记）+delivery-summary 五要素
- **V-N:** VC-5, VC-6
- **Status:** pending
- **Executor:** Verifier（mini）（终验核查子代理；主进程簿记走白名单②）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S5 | 独立复验六项 VC 出 PASS 表 | Verifier(mini) | <plan>/（VC 表+verification.md）；主仓根（合并后终态） | 六项 VC 逐条命令实跑+PASS/FAIL 表 | 15min | 1f/0l/15min | 无 | Phase 4 | pending |

## 🔀 隔离决策（冲突分析）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号① 本计划目录未跟踪=预期；信号③ 遗留分支 wt/task-v168-machine-parked=他域遗留不碰；信号④ INDEX 2 个未完成任务=并行会话在册，全局指针有竞态——已设 side 指针 sid=fae73c58…） |
| `isolation` | `worktree`（技能文件=保护区+运行中基础设施，§十一 铁律） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v185-file-split-discipline` |
| `branch` | `wt/task-v185-file-split-discipline` |
| `merge_back` | `pending` |

## 📊 FMEA 预演

| Phase | 失败模式 | S | O | D | RPN | 预设兜底动作 |
|-------|---------|---|---|---|-----|--------------|
| Phase 2 | 派发转写漂移/锚点错位 | 5 | 3 | 2 | 30 | 逐字转写+grep 验收门（VC-1）；FAIL 回炉改派（22.3①） |
| Phase 2/3 | 级联漏面（旧字面残留） | 4 | 4 | 2 | 32 | grep 双向断言（VC-3）；漏面补 S-unit |
| Phase 3 | selftest 纪元锚断裂 | 6 | 3 | 2 | 36 | 断裂锚最小口径扩展（非回退）；>3 处 STOP 评估 |
| Phase 4 | 合并冲突（并行会话在途） | 7 | 3 | 3 | 63 | 主仓脏→STOP 排队登记（Rule 88.4 禁 git 手术） |

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-17 | S1 完成 |
| Phase 2 | ☑ | 2026-10-17 | S1 完成 |
| Phase 3 | ☑ | 2026-10-17 | S1 完成 |
| Phase 4 | ☑ | 2026-10-17 | S1 完成 |
| Phase 5 | ☑ | 2026-10-17 | S1 完成 |

## Key Questions

1. 新规则编号与落点？→ 92 / task-discipline 卫星（rule-reserve next=92；91 已被 plan-collab-router Rule 91 占用——grep 实证 findings.md）
2. 级联面全集？→ 6 文件 9 处编辑点（grep 实证，见变更标注表 CA-2..CA-5）
3. 回归会否因纪元锚断裂？→ error-loop/context-pressure 宽容锚已扩 9[0-9]（selftest 源码实证），预期绿；以 S4 实跑为准

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 计划推进重锁 #2（纠正登记） | VC-3 可执行命令校准：「Rules 1-92」→「(Rules )?1-92」——SKILL.md:221 字面为「核心域 1-92」无 Rules 前缀，原模式物理上限 2 处（S2 上报+主进程 8 项 grep 亲验全过）；覆盖语义不变非缩水（Rule 51.7 纠正=回锚） |
| 计划推进重锁 #1 | Phase 1→complete、Phase 2→in_progress 状态翻转，重跑 attest 更新锁定（Rule 20.1 授权路径；非纠正/让步） |
| silent: 编号取 92 | rule-reserve.sh next=92、check 92=free；91 已被 Rule 91（workflow 模型分档，plan-collab-router）占用 |
| silent: 落点=task-discipline 卫星 | 域=执行纪律/工作产物维护；task-dispatch 管任务/子代理拆分，非文件产出尺寸，域不合 |
| silent: 优先级 P1（非 P0） | 用户措辞「尽量避免」=默认拆分+显式例外通道（92.6），非一刀切禁令；对齐 §四.6 比例原则 |
| silent: L0-T 文本优先机制 | Rule 38.7+宪法 §四.6：零新增守护脚本/零新 config 键；selftest/registry 机器化 opt-in，对齐 86.7/89.6/90.6 范式 |
| silent: 交互模式 silent | 自主会话（用户不在线值守）；授权锚=用户指令原文 user-session-log #1；D6 硬停点不受影响 |
| silent: 既有漂移只登记不修 | Rule 88.2③：discipline 索引表缺 85-90 行+计数 41/42/43 三口径不一致；README「其余 71 条」vs SKILL「73 条」；路由清单合计 89 vs 实存编号 88——均登记 findings，待用户裁决 |
| silent: CR=required 单轮+alignment-review 单轮 | 技能文件谨慎胜过速度（§十三）；纯文本小 diff 轻量档，避免双重审查仪式（§四.6） |
| 全局指针竞态登记 | init 设的全局指针数分钟内被并行会话改回 task-v184（resolve 实证）；本会话已设 side 指针 sid=fae73c58…（v180 判例复用），不碰他域指针 |

## Errors Encountered

| Error | Attempt | Resolution | Prevention |
|-------|---------|------------|------------|
| （暂无） | 1 | - | - |

## Notes

- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - help avoid repetition

## 🚨 Drift Log（漂移检测记录）

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-17 15:32 | ALIGNED（drift-checker，检查点 2-drift-checker.md+ledger tick2） | VC-1/2/3 | 5 文件全在射程 CA-1..5；既有规则正文零改；R1-R7 语义全承载 |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 5（Phase 2 executor、Phase 3 code-runner-agent、Phase 5 Verifier） |
| 主进程直做 Phase 清单 | Phase 1（① git/worktree 编排+② 计划系统文件维护）、Phase 4（① git 编排）——Rule 25.3 白名单内，v184 判例同口径豁免 |
| 委派率 | 0.6（<0.7；主进程直做两项均白名单①②内，机器 stats=事实源，终验粘贴 JSON 复核） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 15:11 | executor | S1 Rule 92 正文逐字落位 | done | 5/5 PASS；576→588 行；尾部 diff 草稿 rc=0 | worktree critical-rules-discipline.md:577-588 | findings §S1 执行回执 | plans/task-v185-file-split-discipline/subagent-state/2-s1-executor.md | - / 0 / ☑ |
| 2 | 15:28 | executor | S2 卫星+主 SKILL 级联 | done | 7 处落位；VC-3 判据校准上报（未猜改，处置=Decisions #2） | 主进程 8 grep 亲验（findings §S2） | findings §S2 执行回执 | plans/task-v185-file-split-discipline/subagent-state/2-s2-executor.md | - / 0 / ☑ |
| 3 | 15:25 | executor | S3 核心路由+README 级联 | done | 1+3 处；4 grep 全过 | worktree critical-rules.md:182 | findings §S3 执行回执 | plans/task-v185-file-split-discipline/subagent-state/2-s3-executor.md | - / 0 / ☑ |
| 4 | | code-runner-agent | S4 worktree 全量回归 | queued | | | | plans/task-v185-file-split-discipline/subagent-state/3-s4-code-runner-agent.md | - / 0 / ☐ |
| 5 | 15:32 | drift-checker | Phase 2 后偏移检查 | done | ALIGNED；5 文件全在射程；R1-R7 语义全承载 | 检查点+ledger tick2 | findings §Drift check #1 | plans/task-v185-file-split-discipline/subagent-state/2-drift-checker.md | - / 0 / ☑ |
| 6 | | Code Reviewer | CR 门单轮审查 | queued | | | | plans/task-v185-file-split-discipline/subagent-state/5-code-reviewer.md | - / 0 / ☐ |
| 7 | | Verifier | S5 独立 VC 复验 | queued | | | | plans/task-v185-file-split-discipline/subagent-state/5-s5-verifier.md | - / 0 / ☐ |

## 🔁 模板感知

- 触发信号: 任务类型空缺 → 落 general 兜底
- Rule 34.3②: 终验时按三条件评估沉淀——预登记「不沉淀」倾向：单条规则文本新增，无新模板信号（复用 general 全区块）
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 不沉淀理由=纯规则文本新增无新结构信号（终验确认）
