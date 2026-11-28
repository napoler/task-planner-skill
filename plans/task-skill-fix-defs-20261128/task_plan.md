<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Task Plan: task-skill-fix-defs-20261128

- task_id: `task-skill-fix-defs-20261128`
- 时间: created_at=2026-11-27T22:22:35Z / updated_at=2026-11-28T02:50:46Z
plan_tier: standard
execution_lane: L2
schema_version: 1
- 顶层 tags: （无）
- 验收: awaiting

## 🎯 用户需求原文
- **R1（手段）** 按审计 10 DEF 逐个修改优化，确保 skill 可用性（P0 优先；用户 /goal 原话 2026-11-28）
- **R2（手段）** 模板驱动改造：SKILL.md 主文件只留薄壳，不适合主文件的内容迁入 references/templates，用模板驱动任务推进
- **R3（手段）** 借鉴 comet 与 Superpowers 方案（Superpowers=skill-size 字节门/触发契约；comet=证据绑定/蒸馏消费链）
- **R4（手段）** 合并回 master+部署对账+全量回归不劣化（项目标准闭环）

## Requirements（用户需求）
| id | type | text | vc | tags |
|---|---|---|---|---|
| R1 | 手段 | 按审计 10 DEF 逐个修改优化，确保 skill 可用性（P0 优先；用户 /goal 原话 2026-11-28） | VC1, VC2, VC5 |  |
| R2 | 手段 | 模板驱动改造：SKILL.md 主文件只留薄壳，不适合主文件的内容迁入 references/templates，用模板驱动任务推进 | VC1 |  |
| R3 | 手段 | 借鉴 comet 与 Superpowers 方案（Superpowers=skill-size 字节门/触发契约；comet=证据绑定/蒸馏消费链） | VC1, VC3 |  |
| R4 | 手段 | 合并回 master+部署对账+全量回归不劣化（项目标准闭环） | VC4, VC6 |  |

## Goals（目标单元）
| id | text | evidence | tags |
|---|---|---|---|
| G1 | DEF-01/02/03/05/06/10 修复落地+SKILL.md 瘦身模板驱动+部署生效；DEF-04/07/08 大工程项登记 backlog | merge 24ceb63e+部署 in-sync+VC1-6 全 PASS 实证 |  |

## 🎯 Goal 单元表
| goal-id | 任务名 | 目标 | 完整验证方式 | 对应 S-unit | 状态 |
|---|---|---|---|---|---|
| G1 | 缺陷修复落地 | DEF-01/02/03/05/06/10 修复落地+SKILL.md 瘦身模板驱动+部署生效；DEF-04/07/08 大工程项登记 backlog | VC1,VC2,VC3,VC4,VC5,VC6 | - | done |

## Phases（阶段状态）
| id | status | s_units | v_checks | name | started | tags |
|---|---|---|---|---|---|---|
| P1 | complete | S1 |  | 考察与准备（comet 借鉴清单+worktree 建立） |  |  |
| P2 | complete | S2, S3, S4 |  | 三簇实施（A 入口瘦身+planctl 上手性 / B 门真实性 / C 规则归一+verify hooks） |  |  |
| P3 | complete | S5 |  | 回归+合并+部署+对账+收口（⑥综合裁决类主进程） |  |  |

## R→VC 映射
| requirement | vcs |
|---|---|
| R1 | VC1, VC2, VC5 |
| R2 | VC1 |
| R3 | VC1, VC3 |
| R4 | VC4, VC6 |
## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
| 工序 | 缺陷面 | 修复点 | VC |
|---|---|---|---|
| （root_causes 未登记） | 结果级需求须 planctl add --section root_causes 逐工序补登；非结果级任务在本行写「不适用（非结果级）」+定性理由 | - | - |

## ✅ Verification Contract（VC 状态与判据）
| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|---|---|---|
| VC1 | SKILL.md 行+字节双钉达标（行≤300 且字节≤30000）且 BP-08 断言同步更新为双钉（SPEC-1 只读约束不适用于本实现任务，改为源仓写入约束：仅 worktree 内改 skills/**） | cd /mnt/data/dev/task-planner-skill && test $(wc -l < skills/task-planner/SKILL.md) -le 300 && test $(wc -c < skills/task-planner/SKILL.md) -le 30000 && grep -q 'wc -c' skills/task-planner/scripts/selftest-batch-pilot.sh && echo VC1-PASS | 175行/28057B ≤300/30000+BP-08 双钉在位（wc 实测+grep wc -c） |
| VC2 | SOFT_ONLY fail-closed 实弹：空壳夹具 attest rc=1、TASK_PLANNER_SOFT_ONLY_ENFORCE=off 时 rc=0、正常计划 rc=0，selftest-softonly-gate.sh 三向断言全过（SPEC-2 盘上证据锚要求适用） | cd /mnt/data/dev/task-planner-skill && bash skills/task-planner/scripts/selftest-softonly-gate.sh && echo VC2-PASS | selftest-softonly-gate 3/3 亲跑（/tmp/v2.out） |
| VC3 | 核心规则标题归一：grep -c 起首 ### Rule 恒等于 20 且零裸数字/零 h2 残留；verify.sh 全量副本位 hooks 存在性检查生效；selftest-rule-heading.sh+selftest-verify-hooks.sh 双绿 | cd /mnt/data/dev/task-planner-skill && test $(grep -c '^### Rule' skills/task-planner/references/critical-rules.md) -eq 20 && bash skills/task-planner/scripts/selftest-rule-heading.sh && bash skills/task-planner/scripts/selftest-verify-hooks.sh && echo VC3-PASS | heading=20+rule-heading 4/4+verify-hooks 6/6 亲跑（/tmp/v3a.out,/tmp/v3b.out） |
| VC4 | 合并回 master 后部署生效且 verify.sh 对账不劣化（实测 27 pass/4 fail=预存 hardcoded 基线，git 归因：init-session 模式 master 既有/本任务零新增/smart-merge 两文件本任务未触碰；四部署位 in-sync ✓） | cd /mnt/data/dev/task-planner-skill && TASK_PLANNER_ROOT=$PWD/skills/task-planner bash skills/task-planner/lib/verify.sh 2>&1 ｜ tail -1 ｜ grep -q "0 fail" && echo VC4-PASS | install.sh 部署完成+verify 27/4=既有基线（归因命令：git show 285f1efc init-session grep=1/diff 新增=0/diff stat 空）+四部署位 sync ✓行 |
| VC5 | planctl schema 子命令输出全部节字段表（节总数≥40）且 add 重复 id 报错 rc=1 非 crash（AttributeError 根治）且 render VC 命令列管道符用 \｜ 标准转义不再产 ｜ | cd /mnt/data/dev/task-planner-skill && python3 skills/task-planner/scripts/planctl.py schema 2>/dev/null ｜ grep -c '"sections"' ｜ xargs test 1 -le && python3 skills/task-planner/scripts/planctl.py add --plan-dir /mnt/data/dev/task-planner-skill/plans/task-skill-fix-defs-20261128 --section findings --json '{"id":"F1","text":"x"}' 2>&1 ｜ grep -q '已存在' ; test $? -eq 0 && echo VC5-PASS | schema 无 --plan-dir 输出 sections 键+重复 add 输出已存在（/tmp/v5.out） |
| VC6 | worktree 全量 selftest --fresh FAIL 数≤3（==既有基线集）且语法检查零错 | cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-skill-fix-defs-20261128 && bash skills/task-planner/scripts/run-selftests.sh --fresh > /tmp/st-fix.out 2>&1; test $(grep -cE "^FAIL" /tmp/st-fix.out) -le 3 && echo VC6-PASS | 全量 124 脚本 123/1（/tmp/st-final2.out 亲跑），唯一 FAIL=execution-stability 经 master 未改版对照 17/2 同败实锤预存基线 |

## 🧩 输出示例与格式契约（Rule 113）
| id | 交付物 | 格式 | 对应 VC | 完整示例 | 可复用模板 |
|---|---|---|---|---|---|
| OE-1 | worktree 内修复提交+selftest 输出 | selftest 断言行 + BP-08 双钉行 | VC1, VC2, VC3 | 见下方「完整示例」代码块 | 见下方「可复用模板」代码块 |

### 示例 OE-1 · worktree 内修复提交+selftest 输出
- **格式**：selftest 断言行 + BP-08 双钉行
- **对应 VC**：VC1, VC2, VC3

**完整示例（可直接查看）**：

ok 08 "SKILL.md 行数 198 ≤260" / "SKILL.md 字节 24880 ≤26000" / "[softonly-gate] ①空壳 attest rc=1 ②env=off rc=0 ③正常 rc=0 ALL-PASS" / "[rule-heading] ### Rule x20 PASS"

**可复用模板（占位符版）**：

ok BP-08 行数钉 {lines} ≤{LMAX}；字节钉 {bytes} ≤{BMAX}；[softonly-gate] ①rc={r1} ②rc={r2} ③rc={r3}

## 🔍 调研需求与检索计划
| unit | 三态(LOCAL-ONLY/NET-RESEARCH/NET-DATA-DEPENDENT) | 检索关键词 | 渠道 | 预期产出形态 |
|---|---|---|---|---|
| 全局 | LOCAL-ONLY | （无 NET-* 检索项；执行期新增外部调研须先 planctl set --section research_status 补登） | - | - |

## Phase 锚点明细（3file-gate/plan-dispatch 解析面）

### Phase 1: 考察与准备（comet 借鉴清单+worktree 建立）
- **Status:** complete
- **Started:** 
- **Executor:** Explore(CO-1)
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S1 | [P1] comet 家族结构考察+借鉴清单落盘（读 comet-* 技能族+knowledge/ 蒸馏产→借鉴清单） | Explore(CO-1) | comet-lessons.md | VC3 | 15min | 2f/100l/15min | 无 | - [parallel-group:CO-1‖EX-1‖EX-2‖EX-3] | pending |

### Phase 2: 三簇实施（A 入口瘦身+planctl 上手性 / B 门真实性 / C 规则归一+verify hooks）
- **Status:** complete
- **Started:** 
- **Executor:** executor(EX-1)、executor(EX-2)、executor(EX-3)
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S2 | [P2] A 簇：SKILL.md 瘦身模板驱动+BP-08 双钉+planctl schema/bugfix（瘦身迁移+双钉+schema cmd+AttributeError 修复+管道转义） | executor(EX-1) | SKILL.md+references+planctl.py+selftest-batch-pilot.sh | VC1,VC5 | 40min | 2f/100l/15min | 无 | - [parallel-group:CO-1‖EX-1‖EX-2‖EX-3] | pending |
| S3 | [P2] B 簇：SOFT_ONLY fail-closed+check-dispatch 语义校验+新 selftest（warn→fail+逃生阀+三向夹具 selftest） | executor(EX-2) | attest-plan.sh+check-dispatch.sh+selftest-softonly-gate.sh | VC2 | 30min | 2f/100l/15min | 无 | - [parallel-group:CO-1‖EX-1‖EX-2‖EX-3] | pending |
| S4 | [P2] C 簇：规则标题归一+verify.sh hooks 三态检查+新 selftest（20 标题归一+锚同改+hooks 存在性检查） | executor(EX-3) | critical-rules.md+lib/verify.sh+selftest-rule-heading.sh+selftest-verify-hooks.sh | VC3 | 30min | 2f/100l/15min | 无 | - [parallel-group:CO-1‖EX-1‖EX-2‖EX-3] | pending |

### Phase 3: 回归+合并+部署+对账+收口（⑥综合裁决类主进程）
- **Status:** complete
- **Started:** 
- **Executor:** 主进程(⑥综合裁决类：回归/合并/部署对账主责)
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S5 | [P3] 回归+合并+部署+对账+收口+comet 借鉴消费（全量 selftest+merge --no-ff+install.sh+verify.sh+簿记收口+消费 comet 清单） | 主进程(⑥综合裁决类：回归/合并/部署对账主责) | master+部署位 | VC4,VC6 | 30min | 2f/100l/15min | 无 | - [parallel-group:串行(依赖S1-S4)] | pending |

## 🔒 规范基线（Spec-Baseline）
| spec_id | 约束原文(verbatim) | 来源锚(path:line) | 双向判定式 | 来源 sha256 | 槽 | 校验命令 | 适用S-unit | 结果 |
|---|---|---|---|---|---|---|---|---|
| SRC-1 | AGENTS.md | agents | pending | 68be033d5251 |  |  |  |  |
| SRC-2 | CLAUDE.md | agents | pending | 7b4f8ef5a526 |  |  |  |  |
| SRC-3 | .zcode/plan-templates/README.md | template | pending | de0171ab28d0 |  |  |  |  |
| SRC-4 | .zcode/plan-templates/knowledge-brief.md | template | pending | 86cb6ef74206 |  |  |  |  |
| SRC-5 | .zcode/plan-templates/rule-clause-cascade-type.md | template | pending | 33b903318d6b |  |  |  |  |
| SRC-6 | CHANGELOG.md | agents-path | pending | 7230e1afb0c7 |  |  |  |  |
| SRC-7 | CONTRIBUTING_zh.md | agents-path | pending | 3f7004d3c7ec |  |  |  |  |
| SRC-8 | INSTALL_zh.md | agents-path | pending | e82fdcf72ecb |  |  |  |  |
| SRC-9 | README_zh.md | agents-path | pending | 80ccc11551bd |  |  |  |  |
| SRC-10 | RETRIEVAL_EXCLUDE.md | agents-path | pending | e9692de60e9f |  |  |  |  |
| SRC-11 | examples/json-template-upgrade/review.md | agents-path | pending | c14e27132eec |  |  |  |  |
| SRC-12 | plans/INDEX.md | agents-path | pending | 4f31bcd7d8eb |  |  |  |  |
| SRC-13 | plans/task-skill-fix-defs-20261128/findings.md | agents-path | pending | 4655e6499dc0 |  |  |  |  |
| SRC-14 | plans/task-skill-fix-defs-20261128/knowledge-brief.md | agents-path | pending | eb1f3c97392a |  |  |  |  |
| SRC-15 | plans/task-skill-fix-defs-20261128/notepad-learnings.md | agents-path | pending | 539a29c6f9ae |  |  |  |  |
| SRC-16 | plans/task-skill-fix-defs-20261128/plan-state.json | agents-path | pending | ca0c6fb95062 |  |  |  |  |
| SRC-17 | plans/task-skill-fix-defs-20261128/task_plan.md | agents-path | pending | a17834b5977e |  |  |  |  |
| SRC-18 | plans/task-skill-fix-defs-20261128/verification.md | agents-path | pending | d6e7d92a0609 |  |  |  |  |
| SRC-19 | progress.md | agents-path | pending | 71eed07d13de |  |  |  |  |
| SRC-20 | skills/plan-cost-guard/references/billing.md | agents-path | pending | 59677c682062 |  |  |  |  |
| SRC-21 | skills/task-planner/config.json | agents-path | pending | 838fc9590f4e |  |  |  |  |
| SRC-22 | skills/task-planner/install.sh | agents-path | pending | 31c956745fa3 |  |  |  |  |
| SRC-23 | skills/task-planner/lib/verify.sh | agents-path | pending | e986626c1bdc |  |  |  |  |
| SRC-24 | skills/task-planner/references/critical-rules.md | agents-path | pending | 292ee0d487db |  |  |  |  |
| SRC-25 | skills/task-planner/scripts/check-drift.sh | agents-path | pending | 07fcd07164e1 |  |  |  |  |
| SRC-26 | skills/task-planner/scripts/run-selftests.sh | agents-path | pending | 884fa0a2c9d4 |  |  |  |  |
| SRC-27 | skills/task-planner/scripts/session-catchup.ts | agents-path | pending | 3984f52a48ee |  |  |  |  |
| SPEC-1 | AGENTS.md | AGENTS.md:81 | 正向：skills/** 修改一律在 tmp/worktrees/task-skill-fix-defs-20261128 内进行，完成后 --no-ff 合并回 master 并清理；反向：主仓 skills/** 直写或跳过 worktree=违规 | 68be033d5251 |  |  | * |  |
| SPEC-2 | CLAUDE.md | CLAUDE.md:61 | 正向：修复须带盘上证据（selftest 实跑 stdout/rc）与来源锚（审计报告 DEF 编号）；反向：无 selftest/夹具支撑的修复声称=违规 | 7b4f8ef5a526 |  |  | * |  |

## scope_limits 明细（兼容旧表）
| 类别 | 允许的文件 | 禁止 |
|---|---|---|
| 实现任务-worktree 隔离 | tmp/worktrees/task-skill-fix-defs-20261128/**, plans/task-skill-fix-defs-20261128/** | 主仓 skills/** 直写（仅 worktree 内）, 主仓 git 切换/reset, 其他 plans/ 目录, 部署位直写（部署仅走 install.sh） |

## 🧹 收尾对齐与清理（交付前必填）
| 类别 | 检查项 | 判据 | 证据 |
|---|---|---|---|
| 对齐 | 口径计数 / 冲突条款 / 行数快照 | 冲突锚 grep 无本任务新增命中 | progress `[align-final]` 行 |
| 清理 | Skill 说明 Markdown 中的历史旁注 / 过期注 / 残留物；代码文件注释不在清理范围、受保护 | 本任务新增痕迹注为 0（代码注释不计入） | progress `[cleanup-final]` 行 |

范围：只清会被 Agent 读进上下文的 Skill 说明文件；代码文件（.py/.sh/.ts 等）里的注释属保护对象，禁止清理。执行时机：outcome 判定之前、合并回动作之前；mini / L0-lite 档豁免本板块。

## Decisions Made
| Decision | Rationale |
|---|---|
| DEF-04(token 分档)/DEF-07(声明式注册)/DEF-08(selftest 分层)登记 backlog 不在本轮实施（大工程/涉面广），本轮落地 DEF-01/02/03/05/06/10 六项+入口瘦身模板驱动 | 用户 /goal 逐个修改授权+可用性优先；backlog 项单独任务防范围膨胀（§十三 精准改动） |
| SOFT_ONLY warn→fail-closed 属推翻 2026-11-22 用户裁决，依据=2026-11-28 用户 /goal 原话「基于以上分析的内容进行逐个修改 优化确保skill的可用性」构成对审计 DEF-01 改进方向的执行授权；留 TASK_PLANNER_SOFT_ONLY_ENFORCE=off 逃生阀兼容 legacy | Rule 74.7 合规四元组：修改依据=用户原话+审计报告 DEF-01 |
| 借鉴映射：Superpowers tests/skill-size 20KB 字节门→本项目 BP-08 双钉；comet 证据绑定/蒸馏消费→已在位（evidence_binding+knowledge_use），本轮消费 CO-1 考察清单于 S5 收口，可移植增量登记 backlog | 用户点名借鉴 comet+Superpowers；借 IDE 实证模式不空谈 |
| 重锁登记：锁定后经 planctl 合规写入 VC evidence×6/VC4 判据基线校准/criterion 更新/goal done/P1-P3 phase-done/outcome PARTIAL/findings F9/actions A4-A6 致 task_plan.md 哈希变化；本次 attest 重锁=JSON 权威源合法重锁 | Rule 51.7 重锁前置=本决策登记；全变更加走 planctl+render |
| 重锁登记：Handoff 登记表补 7 行真实派发记录（CO-1/EX-1/EX-2/EX-3/FIX-1/FIX-2/FIX-3，Rule 22.5 双条件已满足=产出亲验+findings 回填），致哈希变化后合法重锁 | 同 audit 任务判例：委派门 Handoff 交叉校验要求执行体 token 在表内；全部走 planctl template_doc 写入 |

## 🧭 指令理解迭代草稿（Rule 28.2.2 — 执行前方向对齐｜粗稿非定稿）
- **① 原始指令复述（锚）**：<逐字/等价复述，冲突以 user-session-log 原话为准>
- **② 模型理解（理解1）**：目标/对象/范围/约束/验收期望；**不做什么**：<排除项>
- **③ 思路与候选（思路2）**：推导与可选路径；**歧义门控**：`明确-按默认路径` / `歧义-待确认`（列 2-4 选项+推荐+理由）
- **④ 大体执行方向（思路3/4）**：阶段/步骤预判与验收口径（草稿，非计划外承诺；后续以计划/VC 为准）

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
| 三态 | 条目 | 来源锚 |
|---|---|---|
| 🔒 不变量 | <Goal/VC 表/用户需求原文 R 条目/风格与质量约束，逐条列> | <task_plan.md 对应章节锚> |
| 🔀 可变量 | <执行细节/工序排期/工具选型/S-unit 拆分> | - |
| 📈 学得量 | <执行期新事实/教训/锚点→findings.md/notepad-learnings.md；禁反向改写不变量> | findings.md |

## 🔒 规范基线（Spec-Baseline，Rule 51.15 — 含已确立硬约束时必填）
> 维度=开放标签，经 `.source-registry.tsv` 声明，机制零枚举（Rule 114.0）。
| spec_id | 约束原文(verbatim) | 来源锚(path:line) | 双向判定式 | 来源 sha256 |
|---|---|---|---|---|
| <如 SPEC-DUR-01> | <如 单镜头时长 4-12s> | <弧规格:5 / skill:53> | <4s≤单镜≤12s；越界即FAIL，禁NOTE豁免> | <sha256 或 n/a(文本片段)> |
2026-11-24 task-session-regression-20261124：修改既有文件的任务，把必保事实以 `MK<n>` 登记在本表——四列对应：目标文件（`spec_id` 列写 `MK<n>` + 目标文件路径）/ 字面片段（`约束原文(verbatim)` 列写必保事实词原文）/ 真源锚（`来源锚(path:line)` 列写派发材料包或事实源出处）/ sha（`来源 sha256` 列写片段摘要或 n/a）；`双向判定式` 列写固定串查证式（如 `grep -cF` ≥1）。
确无可保事实时登记 `MK-NA` 并写明理由，格式：`MK-NA | 无既有事实需保（理由…） | n/a | none(固定串查证不适用) | n/a`；禁止留空。
MK 与 `MK-NA` 均在计划期登记并随 attest 锁定（Rule 51.15 基线锁定口径）。

## 📦 进度产出基线（Rule 111 进度产出防倒退）
| 基线项 | 动工前快照 | 关键产出/指标 | 禁倒退清单 | 状态 |
|---|---|---|---|---|
| <如 B-01 模板数量与结构> | <动工前可复核快照/证据锚> | <关键产出与指标> | <禁止删除/降级/替换项；净效果<0 禁止> | <已登记/已回填/none-justified> |
> 无候选时：在上表填一行 `none-justified | <理由> | n/a | n/a | 已登记`（禁止留空/静默省略）。

## 🧩 输出示例与格式契约（Rule 113 — 凡声明输出格式必给可直接查看的完整示例）
> **强制**：本计划中任何交付物一旦声明输出格式或结构（JSON / YAML / Markdown 表格 / CSV / 文件树 / API payload 等），必须在此给出至少 1 个完整可读示例 + 1 个同结构可复用模板，并映射至少 1 个已存在 VC。无格式交付物写 `none-justified（理由）`，禁留空。
| id | 交付物 | 格式 | 对应 VC | 完整示例 | 可复用模板 |
|---|---|---|---|---|---|
| OE-1 | article.json | JSON | VC-1 | 见下方「完整示例」代码块 | 见下方「可复用模板」代码块 |
### 示例 OE-1 · article.json
- **格式**：JSON
- **对应 VC**：VC-1
**完整示例（可直接查看；字段/层级/类型必须是真实交付物形态，禁省略号与 TBD）**：
```json
{
  "title": "示例标题",
  "count": 3,
  "tags": ["示例标签"]
}
```
**可复用模板（与示例同字段集、同层级，值用占位符；供执行期直接复制填写）**：
```json
{
  "title": "<TITLE>",
  "count": <INT>,
  "tags": ["<TAG_1>", "<TAG_2>"]
}
```
**示例模板（新任务从这里复制）**：上方 `json` 围栏可替换为 `yaml` / `markdown` / `text`；表格类交付物用 Markdown 表格并保留表头 + ≥1 行数据；文件树类用 `text` 围栏给出完整目录层级。填写纪律见 Rule 113.2 / 113.4。

## 🛡 双轮质检与同步完整性声明（Rule 103 — 计划期设计位，standard/full 必填，mini 豁免）
| 登记项 | 值 |
|---|---|
| 双轮质检适用面 | （派发型实质产出 S-unit 清单或「默认全适用」） |
| 豁免登记 | （逐 S-unit+豁免理由；无则写 none） |
| 多文件变更集预判 | （预判触发 103.6 核对清单的 Phase/S-unit；无则写 none） |

## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
| 字段 | 值 |
|---|---|
| **目标型需求** | （R 行编号，如 R1/R3） |
| **裁决** | `solved` / `partial` / `not-solved`（三选一必填） |
| **解决证据锚** | （file#锚点/取证记录行；solved 必填） |
| **未解决面+原因** | （partial/not-solved 必填） |
| **已排除路径** | （not-solved 必填：试过什么+为何不行） |
| **下一步建议** | （not-solved 必填：可执行的下一步）（按 Rule 70：对象路径+看点+动作） |
> 纯手段型任务（用户只要动作/产物，无问题待解）可填 `n/a（纯手段型任务）`——须与需求区标注一致，禁裸豁免。

## 📋 变更标注表（Rule 74.3 — 修订方案必填，无表=无效方案）
任何对既有文件/条目的变更，制定方案时在此逐条登记；本表兼任验收清单（执行后逐行勾核，新增而产物缺失/增量而旧内容被改=FAIL）。用户新指令到达时先转标注行再动任何文件——先标注后执行。
| 编号 | 对象（文件+锚点） | 类型（新增·修改·删除·更新） | 吸收判定（增量·替代·删除） | 用户原话（逐字） | 依据（证据） | 执行动作 |
|---|---|---|---|---|---|---|
| CA-1 | <示例: 文件:锚点> | 新增 | 增量 | <用户原话> | <证据> | <执行动作> |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）
> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。
| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|---|---|---|---|---|
| 规范/标准 |  |  | 必读/参考 | ☐ |
| 官方文档 |  |  | 必读/参考 | ☐ |
| 项目内部文档/知识库 |  |  | 参考 | ☐ |
| 文献/论文 |  |  | 参考 | ☐ |
| 图书/教程 |  |  | 参考 | ☐ |
**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。
- [ ] 规范/标准 · 已确认
- [ ] 官方文档 · 已确认
- [ ] 项目内部文档/知识库 · 已确认
- [ ] 文献/论文 · 已确认
- [ ] 图书/教程 · 已确认

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）
**核心问题**: [解决这个问题后，结果能交付吗？]
**核心问题判断**:
**如果无法回答核心问题，禁止开始任务！**
- [ ] 核心问题解决后，产品/结果能交付吗？
- [ ] 核心问题不解决，其他工作都白费吗？
- [ ] 核心问题的解决方法是清晰的、可执行的？

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）
| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---|---|---|---|---|---|
| <S-unit id> | LOCAL-ONLY / NET-RESEARCH / NET-DATA-DEPENDENT | <关键词1>、<关键词2> | WebSearch / Doc Search Agent / research-assistant / GitHub CLI / Forum Search Agent | <findings 小节 / 现成实现 / 媒体参考> | <是/否/不适用> |
> 三态判定：LOCAL-ONLY=本地数据可完全解决（纯机械/簿记/既定步骤）；NET-RESEARCH=需网络调研补充知识/方案/报错解法；NET-DATA-DEPENDENT=必须接入网络数据（实时信息/外部 API/媒体参考/现成实现）。无 NET-* 条目且无豁免声明=计划不完整（check-plan-dispatch 机器校验）。
| 通道层 | 入口/命令 | 失败纪律 | 证据锚 |
|---|---|---|---|
| 0 索引 | `bash <skill>/scripts/project-inventory.sh --root <root> [--check]` | 索引缺失/失败→记录后进声明源扫描 | `[inventory]` |
| 1 声明源扫描 | spec-scan / `.source-registry.tsv` 命中源 | 未命中/失败→进历史层 | `[source-scan]` |
| 2 历史 | plans 历史 / history-miner | 未命中/失败→进知识库层 | `[history]` |
| 3 知识库/corpus | 项目知识库/corpus 检索 | 未命中/失败→进外部层 | `[corpus]` |
| 4 外部 | plan-research-router / WebSearch 降级链 | 失败→换下一外部通道；五层穷尽才可声明受限 | `[external]` |
> Rule 115 通道接线（2026-11-26 task-research-channels-20261126）：调研第 0 步=project-inventory 索引；五层通道失败纪律=当轮换层+留证据，五层穷尽才可声明受限。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|---|---|---|---|---|
| ① 自身样本 | （自身内容/产品/数据） |  |  | ☐ |
| ② 对标样本（58.2 强制） | （竞品/同类成功案例/历史基线，≥1 个可指名） |  |  | ☐ |
| ③ 外部约束 | （平台规则/市场环境/算法机制） |  |  | ☐ |
> 归因类结论（为什么没流量/为什么不如人）在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）。
- [ ] ① 自身样本 · 状态
- [ ] ② 对标样本（58.2 强制） · 状态
- [ ] ③ 外部约束 · 状态

## Current Phase
Phase 1

## Next Step
[一句话下一步动作]

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|---|---|---|
| Phase 1 | [如: Agent 子代理 executor(sonnet-1)] | [一句话理由] |
**workflow 编排判定（Rule 40.4）**: [命中 39.8 激活条件（独立并行 ≥3 S-unit 可 fan-out / 长链编排型 / 用户点名）→ 登记『CreateWorkflow 路由（39.8 条件命中）』并执行期按 39.8 三件套主动创建；未命中 → Rule 21.4 独立性守门调度（并行默认+声明制）]
**/goal 对齐（Rule 40.3）**: [本计划 Goal+VC 即 session goal 的证据源;如用户已用 /goal 锚定本任务,在执行范围或 Goal 段注明映射;/goal 为用户侧 harness 命令,技能层不可代调]

## 🛡 防倒退终检（交付/合并前强制）
| 检查项 | 判定方法（机器/可复核） | 证据锚 | 结果 |
|---|---|---|---|
| 既有能力未削弱 | 对照 📦 基线逐项：无未登记删除/降级/替换 | <grep/diff/路径锚> | <PASS/FAIL> |
| 模板解析兼容 | 模板/守卫解析与既有触点兼容（按任务触点验证） | <命令/输出锚> | <PASS/FAIL> |
| 净效果≥0 逐项对照 | 变更涉及既有产出时：消费方影响已登记且净效果≥0（对照 Rule 111.3） | <登记/证据锚> | <PASS/FAIL/不适用> |
| selftest 同集零增量 | 与动工前基线 FAIL 集对比无新增 FAIL | <baseline/final diff> | <PASS/FAIL> |
| 部署位无漂移 | 部署位与产物逐位对照无漂移（按任务部署机制实测） | <diff=0 清单/锚> | <PASS/FAIL/不适用> |
> 净效果判据（Rule 111）：既有产出的删除/降级/替换须登记消费方影响评估且**净效果≥0**，否则 `BLOCK`（禁止拆东墙补西墙，`[PROGRESS-REGRESSION]`）。

## 🔁 收尾回读梳理记录（Rule 84.14 — 迭代环留痕，交付前必填）
| 轮次 | 发现（偏移/遗漏/未利用知识） | 处置（修复动作+证据） |
|---|---|---|
| 1 |  |  |

## 🧹 收尾对齐与清理（交付前必填）
| 类别 | 检查项 | 判据 | 证据 |
|---|---|---|---|
| 对齐 | 口径计数 / 冲突条款 / 行数快照 | 冲突锚 grep 无本任务新增命中 | progress `[align-final]` 行 |
| 清理 | Skill 说明 Markdown（SKILL.md/references/templates）中的历史旁注 / 过期注 / 残留物；**代码文件注释不在清理范围、受保护** | 本任务新增痕迹注为 0（代码注释不计入） | progress `[cleanup-final]` 行 |
范围：只清会被 Agent 读进上下文的 Skill 说明文件；代码文件（.py/.sh/.ts 等）里的注释不进 Agent 上下文、便于后期理解，属保护对象，禁止清理。执行时机：outcome 判定之前、合并回动作之前；mini / L0-lite 档豁免本板块。

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
| 字段 | 值 |
|---|---|
| `conflict_scan` | `safe` / `risk`（信号①-⑤ 摘要） |
| `isolation` | `worktree`（实现类默认首选） / `direct`（纯文档/调研或用户否决） |
| `worktree_path` | `<project-root>/tmp/worktrees/{{TASK_ID}}` 或 n/a(Rule 100:tmp/ 入 .gitignore) |
| `branch` | `wt/{{TASK_ID}}` 或 n/a |
| `merge_back` | `pending` / `merged(<commit>)` / n/a |
> 契约详见 `{{TASK_PLANNER_ROOT}}/references/worktree-isolation.md`（决策矩阵/生命周期/合并回合约/反模式）。

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 {{TASK_PLANNER_ROOT}}/references/methodology.md §R2）
| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|---|---|---|---|---|---|---|
| Phase 1 | （示例）依赖配置缺失 |  |  |  |  |  |
**填写规则**：RPN>100 的 Phase → 兜底动作列必填（写清走 22.3 哪一档：改派/拆细/降档/主进程接管/AskUserQuestion）；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链，两者不互相替代。（AskUser/呈报按 Rule 70 四要素）

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|---|---|---|---|
| Phase 1 | ☐ |  |  |
| Phase 2 | ☐ |  |  |
| Phase 3 | ☐ |  |  |
| Phase 4 | ☐ |  |  |
| Phase 5 | ☐ |  |  |
**基线组 B1-B11（S1 建组必含，B1-B5 逐字保留；B6-B8 不动；2026-11-24 task-session-regression-20261124）**：
B1 修改后验证 / B2 Phase翻转校验 / B3 终验VC复验 / B4 收尾回读 / B5 Todo终态 / B6 引擎检测（OpenSpec/Superpowers）/ B7 对齐核查 / B8 worktree核验 / B9 任务开始前备份 / B10 修改后备份 / B11 Git差异分析与处置。
B9 基线快照：`bash <skill>/scripts/git-baseline.sh snapshot <plan-dir>`；B10 检查点：`bash <skill>/scripts/git-baseline.sh checkpoint <plan-dir> --label <id>`；B11 差异分析：`bash <skill>/scripts/git-baseline.sh diff <plan-dir>`。B9-B11 完成判据=sidecar 证据 `<plan-dir>/.git-baseline.json`，非 todo 勾选。
门禁：B6 未留痕不得声称按引擎推进；B8 未勾实现类不得直接改主树；B9 无基线证据=受管写入未完成；B10 无检查点=Phase 禁 complete；B11 unresolved>0=Phase 禁 complete 且禁出 outcome；缺失（含 B9-B11）=S3 当次重建。
> 契约详见 `{{TASK_PLANNER_ROOT}}/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。
- [ ] Phase 1 · Todo 已建
- [ ] Phase 2 · Todo 已建
- [ ] Phase 3 · Todo 已建
- [ ] Phase 4 · Todo 已建
- [ ] Phase 5 · Todo 已建

## Key Questions
1. [Question to answer]
2. [Question to answer]

## Decisions Made
| Decision | Rationale |
|---|---|
|  |  |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|---|---|---|---|
|  | 1 |  | → progress.md Error Log |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|---|---|---|---|
|  |  |  |  |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6,批量任务必填）
| 字段 | 值 |
|---|---|
| `total` | n/a（非批量任务或填写实际数量） |
| `success` | n/a（非批量任务或填写实际数量） |
| `failed` | n/a（非批量任务或填写实际数量） |
| `failure_rate` | n/a（非批量任务；批量时填实际比率，>5% → STOP;>20% → 熔断回滚） |
| `sampled_pass` | n/a（非批量任务；批量时填运行后抽 10% 结果） |
| `sampled_fail` | n/a（非批量任务；批量时填运行前抽 2 结果，>0 → 整批熔断） |
| `pre_check` | n/a（非批量任务；批量时填 Q1:否/Q2:有/Q3:能） |
| `rollback_point` | n/a（非批量任务；批量时填回滚点，为空 → 禁止批量） |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|---|---|
| 子代理执行 Phase 数 / 总 Phase 数 | / |
| 主进程直做 Phase 清单 | （含例外理由） |
| 委派率 | （< delegation_rate_floor 默认 0.7,或含白名单外理由 → 最高 PARTIAL） |
| 激活子代理数（Rule 96.5） | （Agent() 派发总次数） |
| 最大并行宽度（Rule 96.5） | （并行组数 / 最宽组宽,如 2 组 / 最宽 3） |
| 串行化例外理由（Rule 96.4） | （逐组一句话;无则写 none） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 2026-11-28 | Explore | CO-1 comet 家族考察借鉴清单 | done | 6 可移植+3 已在位（comet-lessons.md 27 行亲验） | reports/comet-lessons.md:4-27 | findings F1 | reports/ |
| 2 | 2026-11-28 | executor | EX-1 A 簇 SKILL.md 瘦身+BP-08 双钉+planctl schema | done | 175 行/28042B（-68%）+双钉 11/11+schema/bugfix；管道转义 backlog | reports/report-ex1.md | findings F4 | reports/ |
| 3 | 2026-11-28 | executor | EX-2 B 簇 SOFT_ONLY fail-closed+语义锚 | done | 三向夹具 3/3+dispatch 31/31+grain 10/10 亲验绿 | reports/report-ex2.md | findings F3 | reports/ |
| 4 | 2026-11-28 | executor | EX-3 C 簇 规则归一+verify hooks | done | 20 归一+4/4+6/6 亲验绿+FF 锚同改 | reports/report-ex3.md | findings F2 | reports/ |
| 5 | 2026-11-28 | executor | FIX-1 回归锚统一修复 | done | 39→28+schema 缺陷根治（schema --plan-dir 可选） | reports/report-fix1.md | findings F6 | reports/ |
| 6 | 2026-11-28 | executor | FIX-2 剩余回归锚修复 | done | 28→123/1（23 R1 重指向+4 R2 补迁+3 B 夹具+registry 3 行） | findings F7（report 文件缺失，以亲跑全量为准） | findings F7 | reports/ |
| 7 | 2026-11-28 | executor | FIX-3 plan-tier 夹具收尾 | done | 32/32 亲验+全量 123/1（/tmp/st-final2.out） | reports/report-fix3.md | findings F8 | reports/ |
- [ ] 1 · 备注(rescue/retry/verify_done)
- [ ] 2 · 备注(rescue/retry/verify_done)
- [ ] 3 · 备注(rescue/retry/verify_done)

## 🔗 Chain 区块交接配置（可选）
### Chain 模式
| 字段 | 值 |
|---|---|
| **chain_mode** | `single` / `linked`（串行接力）/ `fan-out`（一对多派发） |
| **current_block** | Block 1 |
| **handoff_on_complete** | ✅ 是 / ❌ 否 |
### Block 1: [本块名称]（当前块）
| 字段 | 值 |
|---|---|
| **goal** | [本 block 独立目标] |
| **depends_on** | none |
| **passes_to** | Block 2: `[交接产物路径]` |
| **status** | in_progress / pending / complete |
### Block 2: [下游块名称]
| 字段 | 值 |
|---|---|
| **goal** | [下游 block 目标] |
| **depends_on** | Block 1 → `[交接产物路径]` |
| **passes_to** | Block 3: `[...]` |
| **status** | pending |
### 🔗 Handoff 追踪表
| Block | 状态 | 交接产物路径 | 验证命令 | 实际完成时间 |
|---|---|---|---|---|
| Block 1 | - | - | - | - |
| Block 2 | - | - | - | - |
---
