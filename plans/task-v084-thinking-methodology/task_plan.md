<!-- template_type: rule-enhancement -->
<!-- 沉淀出处: task-v074（Rule 34.3① 同类任务续用）; 本轮 task-v084 实例化 -->

# Task Plan: task-v084 思维方法论（methodology §思维方法论 T1-T5 — 问题先行/解构四问/金字塔原理/逐步推导）

## Goal
落地用户 2026-09-18 思维纪律「解决问题前先思考问题：问题是什么→本质是什么（5 Whys ≥5 层）→解决方案是什么→执行方案是什么，配金字塔原理与逐步推导剖析」：methodology.md 新增 §思维方法论（T1-T5，五字段范式，纯增量零新键）+ SKILL.md 三处指针联动（净增 ≤2 行）+ plan-writer 契约行 + selftest-methodology 扩展（M-12..M-16）+ CHANGELOG；Code Review Gate 过后全量 selftest 0 FAIL，合并回 master、部署 3 实体位并 push。

## ⚙️ 计划配置
| 键 | 值 |
|----|-----|
| template_type | rule-enhancement |
| chain_mode | single |
| interaction_mode | silent（自主环境+用户显式指令在案+v079/v081/v082/v083 先例；交付附静默决策清单） |
| git_commit | per-phase（Rule 27） |
| reflect_verify | required |

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含 .sh：selftest-methodology.sh 扩展；v083 曾声明未执行=合规缺口，本轮必须实际执行：优先派 Code Reviewer agent，不可启动则主进程结构化自审+登记） |
| `session_id` | 24186384601742f588108376ad77319e（active_plan side 指针存在 subagent sid 残留绑定异常，全程显式路径传参缓解） |
| `worktree_path` | /home/terry/task-planner-skill-worktrees/task-v084-thinking-methodology |
| `scope_files` | skills/task-planner/references/methodology.md, skills/task-planner/SKILL.md, skills/task-planner/companion/agents/plan-writer.md, skills/task-planner/scripts/selftest-methodology.sh, CHANGELOG.md |
| `interaction_mode` | silent（同计划配置表） |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | methodology.md：§思维方法论章在位，T1 问题先行/T2 问题解构四问（含 5 Whys ≥5 层+与 31.2/R4 同法不同时交叉引用）/T3 金字塔原理（Minto 出处）/T4 逐步推导剖析/T5 消费点五条，五字段齐全纯追加；机械联动 6 处（定位声明 9 条→14 条×2/指针入口/开关键注记/关系表落点行/防护行），git diff 证实零语义删除 | Read + grep 锚 + git diff | findings/progress |
| VC-2 | SKILL.md 三处：Poka-Yoke 行内指针扩为 §R1/R2/§思维方法论、计划确认后新增思维解构 bullet（净增 ≤2 行，wc ≤548）、Methodology 指针行（L297 区）内含思维方法论 5 条 | grep + wc -l | progress P2 |
| VC-3 | plan-writer.md 产出契约表新增 T2 四问契约行（落 task_plan 核心问题定义+knowledge-brief §1） | grep | progress P3 |
| VC-4 | selftest-methodology.sh 扩展 M-12..M-16 全 PASS；Code Review Gate APPROVED（或主进程结构化自审+登记）；worktree 全量 0 FAIL 且合并后 master 全量 0 FAIL（主进程逐 Total 亲算） | 脚本实跑+求和+审查结论 | progress Selftest Log |
| VC-5 | 仓库根 CHANGELOG.md 条目在位 | Read | CHANGELOG.md |
| VC-6 | 3 实体位 diff -r IDENTICAL 主进程亲验；origin/master push；worktree/分支清理 | diff -r 三位 + git 实查 | 终验输出 |

**终验规则**: 全部 VC 通过且 Code Review Gate 过 → COMPLETE；回归 FAIL 无法定位 → PARTIAL；证据不实 → BLOCKED

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 方法论 | `skills/task-planner/references/methodology.md`（§思维方法论追加+机械联动） | R1-R4/Q1-Q5 任何既有条款改写 |
| SKILL | `skills/task-planner/SKILL.md`（两处行内+一处新增 bullet，净增 ≤2） | 其他行 |
| 契约 | `skills/task-planner/companion/agents/plan-writer.md`（产出契约表 +1 行） | 其他行 |
| selftest | `skills/task-planner/scripts/selftest-methodology.sh`（追加 M-12..M-16） | 既有 M-01..M-11 改写 |
| 文档 | 仓库根 `CHANGELOG.md`（追加条目） | 其他文档 |
| 计划文件 | `plans/task-v084-thinking-methodology/` 三件套+knowledge-brief | 其他 plans/ 目录 |

**强制约束**:
- **纯增量（Rule 36.5）**：不新增 Rule 编号、不动 critical-rules.md 一行（T 系列全部住 methodology.md——其定位声明即"不改 Rule 语义、冲突以 critical-rules 为准"）；"9 条→14 条"字样属机械联动
- 零新 config 键（M-01/M-02/M-07 断言不触）
- T2 的 5 Whys 与 Rule 31.2/R4 为**同法不同时**（问题侧前置 vs 错误侧归因），条款内交叉引用禁重复定义
- T3 惩罚映射显式登记为例外（提醒级不进 Rule 26 硬门——风格类无客观判据，硬门伪报），写入 methodology 定位声明注记
- SKILL.md 净增 ≤2 行（三处 ≤548 断言余量充足）
- plans/task-v082-minimal-probe、task-v083-batch-pilot-first 两并行/已交付计划禁碰；v082/v083 worktree 残留位不清理（属主自处）
- 派发契约：prompt 必含计划三文件绝对路径+8 字段标签；文件编辑单件串行逐件验证（18.9 自证）

## 📚 必要知识储备

| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|-----------|------|---------|--------|
| 项目内部文档/知识库 | methodology.md 全文 177 行（R1-R4+Q1-Q5 五字段范式） | skills/task-planner/references/methodology.md @e0dd940 | 必读 | ☑ |
| 项目内部文档/知识库 | selftest-methodology.sh 11 断言 hermetic 范式 | scripts/selftest-methodology.sh | 必读 | ☑ |
| 项目内部文档/知识库 | Rule 31.2 五 Whys 错误侧原文 + SKILL L81/L297 指针行 | critical-rules.md:256 / SKILL.md | 必读 | ☑ |
| 项目内部文档/知识库 | plan-writer 产出契约表（knowledge_brief 行 L116） | companion/agents/plan-writer.md | 必读 | ☑ |
| 外部文献 | 金字塔原理=Minto《The Pyramid Principle》(1987)；5 Whys=大野耐一（R4 已引）；Polya《How to Solve It》 | 公开出版文献 | 参考 | ☑ |

## ⚠️ 核心问题定义（T2 四问自证作答 — 本任务即方法论首次消费）

**问题是什么**: 用户反复遭遇"上来就改/跳过思考直接执行→返工走弯路"；技能现有方法论 R 系列（可靠性）与 Q 系列（内容质量）无思维过程条款，思考质量不受约束。

**本质是什么（5 Whys）**: ①为何走弯路？→ 动手前未想清问题本质与方案取舍 ②为何未想清？→ 缺强制的前置解构动作与落盘载体 ③为何缺？→ v063 建方法论层时聚焦可靠性/内容质量两类当时痛点 ④为何当时未覆盖思维过程？→ 思维质量难机器度量，被归入"LLM 自觉" ⑤本质=**思维过程无显式条款、无消费点、无守护**——解法=把思维纪律条款化（T1-T5）+挂载消费点（计划创建/方案候选/Phase 执行前）+selftest 守护文本在位。

**解决方案是什么**: methodology.md §思维方法论 T1-T5（备选 A：critical-rules 新开 Rule 37——否，思维是方法论非硬门控，且 critical-rules 已 36 条避免膨胀；备选 B：改 13 个 variant 模板全量——否，级联重收益低）。

**执行方案是什么**: P1 定稿基线→P2 worktree+methodology/SKILL 落地→P3 契约行+守护+CHANGELOG→P4 全量回归+Code Review Gate→P5 合并部署簿记；逐 Phase 三证据验证。

**核心问题判断**: [x]解决后可交付 [x]不解决则思维纪律无依托 [x]方法清晰可执行

## Current Phase
## Current Phase
终验（全 Phase complete，outcome=COMPLETE）

## Next Step
输出交付报告（含静默决策清单），无剩余执行动作

## Phases

### Phase 1: 调研定稿与基线
- [x] 冲突侦察 + methodology.md 177 行通读 + selftest-methodology 11 断言范式盘点 + plan-writer 契约表/SKILL 指针行/31.2 原文定位
- [x] v083 计划 TAMPERED 处置（自改→重锁 SHA 2f338d86，hook 处置路径 A）
- [x] T1-T5 条款文本定稿（五字段）落 findings + 机械联动清单
- [x] 共享账本认领登记（Rule 30.3）+ C20 禁令检查记录（无批量相关禁令；v083 两 veto 与本任务文件单件串行编辑兼容）
- **V-N:** VC-1, VC-2（定稿=验收基准）
- **Status:** complete
- **Executor:** 主进程（例外理由:③ 机械验证+② 计划系统文件簿记——Rule 25.3 白名单；定点读取非跨文件搜索）

### Phase 2: worktree 创建+条款落地
- [x] 创建 worktree（wt/task-v084-thinking-methodology，基点 master=6ba3aee，含 v082 簿记交错提交）
- [x] S1：methodology.md §思维方法论 T1-T5 追加+机械联动 7 处（章节 66 行+L3/L4/L5/L13/L170/L173/L174）
- [x] S2：SKILL.md 三处（L81 行内+新增 bullet+L297 行内，净增 2，545≤548）
- [x] git diff 零语义删除核对（删除行恰为 7 处机械联动）
- **V-N:** VC-1, VC-2
- **Status:** complete
- **Executor:** 主进程（22.3④ 兜底接管生效——code-assistant(haiku-1) 本会话 v083 已 2 连败 Provider server error 实证，不盲试；Rule 25.3 白名单⑤ 兜底接管，WHITELIST-EXEMPT 口径）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S1 | methodology.md §思维方法论 T1-T5+联动 7 处 | 主进程（④接管） | findings.md §条款定稿（T1-T5 全文+联动清单） | grep T 锚×5+零语义删除 | 15min | done |
| S2 | SKILL.md 三处指针联动 | 主进程（④接管） | findings.md §SKILL 联动（行内×2+bullet 全文） | grep 思维方法论×3+wc 545 | 15min | done |

### Phase 3: 契约行+守护+CHANGELOG
- [x] S3：plan-writer.md 契约表 +1 行
- [x] S4：selftest-methodology.sh 追加 M-12..M-16（hermetic 范式，fixture 补 cp plan-writer.md）
- [x] S5：CHANGELOG.md 追加条目
- [x] worktree 单跑 selftest-methodology 16/16 PASS
- **V-N:** VC-3, VC-4, VC-5
- **Status:** complete
- **Executor:** 主进程（22.3④ 兜底接管生效——同 P2，白名单⑤）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S3 | plan-writer 契约行 | 主进程（④接管） | findings.md §契约行 | grep 四问在 plan-writer | 15min | done |
| S4 | selftest 扩展 M-12..16 | 主进程（④接管） | findings.md §断言清单 | 单跑 16/16 PASS | 15min | done |
| S5 | CHANGELOG 条目 | 主进程（④接管） | findings.md §CHANGELOG 草稿 | Read 在位 | 15min | done |

### Phase 4: 全量回归+Code Review Gate
- [x] worktree 全量 selftest（code-runner-agent mini 派发成功）+主进程 bc 亲算 382/0（检查点表 23 行核对）
- [x] Code Review Gate：轮 1 CHANGES_REQUESTED(4 项)→fix 轮 1→轮 2 CHANGES_REQUESTED(3 残留)→fix 轮 2（M-12 标题锚处方）→**轮 3 APPROVED**（突变实测删 T3→M-12 红）
- [x] FAIL 修复 ≤3 轮（CR fix 两轮内收敛，Rule 33.4 合规）
- **V-N:** VC-4（worktree 侧）
- **Status:** complete
- **Executor:** code-runner-agent（mini）——S7 Code Review 由 Code Reviewer agent 三轮实派（见 Handoff 表与 S-unit 表，非本 Phase 主执行体字段）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S6 | worktree 全量 selftest 回归 | code-runner-agent（mini） | subagent-state/6-code-runner-agent.md（23 行 rc+Total 表） | 全部 rc=0，主进程 bc 亲算 0 FAIL | 15min | done |
| S7 | Code Review 审 worktree diff | Code Reviewer | 三轮检查点 7/7b/7c | 轮 3 APPROVED | 15min | done |

### Phase 5: 合并部署+簿记收尾
- [x] smart-merge-back（V1-V6 全过无竞态，871e71a）+ merge_back 回写
- [x] 3 实体位部署+diff -r 主进程亲验 IDENTICAL+master 全量重跑 bc 亲算 382/0
- [x] push+worktree/分支清理（push 经 pull 合并远端 v082 交错提交后完成）
- [x] 簿记：verification 6/6 VC/委派统计（Handoff 补填后 verdict=ok）/notepad/memory/check-complete
- **V-N:** VC-4（master 侧）, VC-6
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排部署+② 簿记——Rule 25.3 白名单）

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号①未提交=v083 attestation 重锁+本计划目录+plan-resume-report[他者]；②③无新增 worktree[当前仅主仓]；④v082/v083 均 delivered） |
| `isolation` | `worktree` |
| `worktree_path` | /home/terry/task-planner-skill-worktrees/task-v084-thinking-methodology |
| `branch` | wt/task-v084-thinking-methodology |
| `merge_back` | merged(871e71ae1c8c4767496dda9a08df4c214b42e48a)——V1-V6 全过无竞态；push 前 pull 合并远端 v082 交错提交（7b7d6fe） |

## 📊 FMEA 预演

| Phase | 失败模式 | S | O | D | RPN | 预设兜底动作 |
|-------|---------|---|---|---|-----|--------------|
| P1 | T2 与 31.2/R4 的 5 Whys 重复定义引发双权威源 | 6 | 3 | 2 | 36 | 条款内交叉引用"同法不同时"；P1 定稿时逐字段对照 |
| P2 | "9 条"字样机械联动漏改（残留自相矛盾） | 5 | 4 | 3 | 60 | 联动审计 grep "9 条" 全仓（methodology.md 4 处+selftest 注释 1 处） |
| P2/P3 | code-assistant 不可用 | 6 | 5 | 1 | 30 | 预登记 ④ 接管直接生效（v083 本会话 2 连败实证，不盲试） |
| P4 | Code Reviewer agent（sonnet 档）不可启动 | 5 | 4 | 2 | 40 | 主进程结构化自审（对照 VC+diff 逐文件）+登记例外理由 |
| P5 | 并行会话竞态合并 | 6 | 3 | 2 | 36 | V5 中止→merge master→解冲突→重跑全量→再合并（v083 实战预案） |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-09-18 | S1 建立 |
| Phase 2 | ☑ | 2026-09-18 | S1 建立 |
| Phase 3 | ☑ | 2026-09-18 | S1 建立 |
| Phase 4 | ☑ | 2026-09-18 | S1 建立 |
| Phase 5 | ☑ | 2026-09-18 | S1 建立 |

## Key Questions
1. 落点 methodology.md 还是 critical-rules 新 Rule？→ **methodology.md**（其定位声明即"新增机制层不改 Rule 语义"；思维纪律属方法论非硬门控；避免 critical-rules 膨胀）
2. T2 四问与 31.2 的 5 Whys 关系？→ **同法不同时**：31.2/R4=错误侧（失败后归因），T2=问题侧（动手前解构）；交叉引用不重复定义
3. 是否加 config enforce 键？→ **不加**（行为纪律+selftest 文本守护，v076/v083 先例；思维质量无机器判据，硬门会伪报）
4. 模板要不要加四问区块？→ **不改模板**（13 个 variant 级联重；消费点走 SKILL bullet+plan-writer 契约行+既有「核心问题定义」段承载）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| silent: 交互模式取 silent | 自主环境+用户显式指令在案+四轮同仓先例 |
| silent: 落点 methodology.md 新增 §思维方法论 | v063 机制层定位精确匹配；零 Rule 级联 |
| silent: T 系列五条=用户四层链+两方法+消费点 | T1 问题先行/T2 解构四问/T3 金字塔/T4 逐步推导/T5 消费点——用户原话全覆盖 |
| silent: 零新 config 键 | 行为纪律无机器判据，硬键会伪报；selftest 守护文本在位 |
| silent: T3 惩罚映射登记为 Rule 26.3 例外 | 风格类判据主观，硬门会伪报；显式例外优于假装硬门 |
| silent: SKILL 净增 ≤2 行 | 三处 ≤548 断言余量纪律 |
| Code Review 本轮实际执行（v083 缺口修正） | 声明 required 就必须跑；agent 不可用则结构化自审+登记 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| active_plan side 指针被 init 绑定到 subagent 残留哨兵 sid | 1 | 全程显式路径传参缓解；登记观察 | init 哨兵 fallback「最新哨兵」可能取到 subagent 残留（信息缺失）→ 后续轮可给 init 加 sid 归属校验 |

## Notes
- 本任务自身=T1/T2 首次消费示范（核心问题定义段按四问作答如上）
- v083 全套先例可复用：接管路由/hermetic selftest 扩展/委派门关键词口径/P5 簿记清单

## 🚨 Drift Log

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-09-18 P1 后 | ALIGNED | VC-1/2 | 继续 P2 |
| 2026-09-18 P2-P4 | ALIGNED（改动均在 scope 5 文件；skill-modify-warn 假阳性已登记） | 全部 | 继续 |
| 2026-09-18 P5 | push 非 fast-forward=远端 v082 交错提交（非漂移）→pull 合并后推送 | VC-6 | 已收口 |

## 📦 Batch Report

不适用（无批量生成单元）——文件编辑均单件串行+逐件验证（18.9 自证）。

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 1 / 5（P4=code-runner-agent mini + Code Reviewer 三轮，均实派成功） |
| 主进程直做 Phase 清单 | P1=③②；P2/P3=⑤（22.3④ 兜底接管，code-assistant 本会话 2 连败实证）；P5=①② |
| 委派率 | 0.200——check-delegation verdict=ok（violations 空）；初判 violation 根因=Handoff 表未填+Executor 复合描述，补填后放行（v081 教训复现：Executor/Handoff=机器事实源） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | rescue(档位/结果/时间) | retry_count | verify_done |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|-------------|-------------|
| 1 | 05:05 | code-runner-agent | P4/S6 worktree 全量 selftest 回归 | done | 23 脚本全 rc=0；主进程对检查点表 bc 亲算 382/0；子代理自报 21/348 算术错弃用且 findings 初写不合规范已由主进程改写 | subagent-state/6-code-runner-agent.md | §[sub:6] | subagent-state/6-code-runner-agent.md | — | 0 | ☑ |
| 2 | 05:15 | Code Reviewer | P4/S7 Code Review Gate 三轮审查 | done | 轮1 CR(4 项)/轮2 CR(3 残留)/轮3 APPROVED（突变实测删 T3→M-12 红 16=15+1）；fix 两轮 7 处全按处方 | subagent-state/7{,b,c}-code-reviewer-*.md | §[sub:7]/[sub:7b]/[sub:7c] | subagent-state/7c-code-reviewer-r3.md | — | 0 | ☑ |

## 🔗 Chain 区块交接配置

chain_mode: single（无 Chain 区块）
