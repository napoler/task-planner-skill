<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Task Plan: task-research-channels-20261126

- task_id: `task-research-channels-20261126`
- 时间: created_at=2026-11-26T01:01:08Z / updated_at=2026-11-26T09:27:11Z
plan_tier: standard
execution_lane: L2
schema_version: 1
- 顶层 tags: （无）
- 验收: awaiting

## 🎯 用户需求原文
- **R1（手段）** 用户新建独立调研技能承载本地调研方法论（五层：枚举/索引/检索/阅读/外部），机制零写死目录，目录数据归项目索引与注册表
- **R2（手段）** 通用源消费链去枚举化：维度=注册表开放标签，代码零新增枚举；未声明源项目行为逐字节不变
- **R3（手段）** git 修改面对账：diff --final 产 manifest，删除行命中声明源锚词须处置；零commit 无用户原话锚治理
- **R4（手段）** D类意图切换检查点交接+验收闭环（acceptance 字段+警告）
- **R5（手段）** 判别性验证：负控制必须 FAIL（删已声明源锚定内容拦/未声明源放）；全量回归 FAIL==基线；StoryLab 真数据回放拦截事故形态

## Requirements（用户需求）
| id | type | text | vc | tags |
|---|---|---|---|---|
| R1 | 手段 | 用户新建独立调研技能承载本地调研方法论（五层：枚举/索引/检索/阅读/外部），机制零写死目录，目录数据归项目索引与注册表 | VC-1, VC-2 |  |
| R2 | 手段 | 通用源消费链去枚举化：维度=注册表开放标签，代码零新增枚举；未声明源项目行为逐字节不变 | VC-3 |  |
| R3 | 手段 | git 修改面对账：diff --final 产 manifest，删除行命中声明源锚词须处置；零commit 无用户原话锚治理 | VC-5 |  |
| R4 | 手段 | D类意图切换检查点交接+验收闭环（acceptance 字段+警告） | VC-6 |  |
| R5 | 手段 | 判别性验证：负控制必须 FAIL（删已声明源锚定内容拦/未声明源放）；全量回归 FAIL==基线；StoryLab 真数据回放拦截事故形态 | VC-2, VC-4, VC-5 |  |

## Goals（目标单元）
| id | text | evidence | tags |
|---|---|---|---|
| G1 | 交付 research-channels 技能（方法论+索引脚本）与通用源消费链（注册表驱动零枚举+diff对账+D类检查点+验收闭环），负控制判别性验证通过，全量回归零新增，四位部署对账 |  |  |

## 🎯 Goal 单元表
| goal-id | 任务名 | 目标 | 完整验证方式 | 对应 S-unit | 状态 |
|---|---|---|---|---|---|
| G1 |  | 交付 research-channels 技能（方法论+索引脚本）与通用源消费链（注册表驱动零枚举+diff对账+D类检查点+验收闭环），负控制判别性验证通过，全量回归零新增，四位部署对账 | 见下方 ✅ Verification Contract 区块（VC 全集） | - | pending |

## Phases（阶段状态）
| id | status | s_units | v_checks | name | started | tags |
|---|---|---|---|---|---|---|
| P1 | complete |  |  | P1 新技能 research-channels | 2026-11-26T01:10:40Z |  |
| P2 | complete |  |  | P2 消费链去枚举化 |  |  |
| P3 | complete |  |  | P3 门与集成 |  |  |
| P4 | pending |  |  | P4 条款与模板 |  |  |
| P5 | complete |  |  | P5 验证 |  |  |
| P6 | complete |  |  | P6 收口 |  |  |

## R→VC 映射
| requirement | vcs |
|---|---|
| R1 | VC-1, VC-2 |
| R2 | VC-3 |
| R3 | VC-5 |
| R4 | VC-6 |
| R5 | VC-2, VC-4, VC-5 |
## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
| 工序 | 缺陷面 | 修复点 | VC |
|---|---|---|---|
| （root_causes 未登记） | 结果级需求须 planctl add --section root_causes 逐工序补登；非结果级任务在本行写「不适用（非结果级）」+定性理由 | - | - |

## ✅ Verification Contract（VC 状态与判据）
| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|---|---|---|
| VC-1 | 三文件在位且 bash -n rc=0（规范基线 SPEC-3 判定式同门复核） | bash -n skills/research-channels/scripts/project-inventory.sh && test -s skills/research-channels/SKILL.md && test -s skills/research-channels/references/research-channels.md && echo VC1-PASS |  |
| VC-2 | Total 行 FAIL=0 | bash skills/task-planner/scripts/selftest-research-channels.sh ｜ tail -1 |  |
| VC-3 | Total 行 FAIL=0（词表数据化等价） | bash skills/task-planner/scripts/selftest-spec-baseline.sh ｜ tail -1 |  |
| VC-4 | FAIL 集==既有基线零新增 | bash skills/task-planner/scripts/run-selftests.sh --fresh ｜ tail -5 |  |
| VC-5 | bible:10/:161 候选出各自扎营/自主选点；episode-map:46 形态被拦；rc=0 | bash plans/task-research-channels-20261126/subagent-state/vc5-replay.sh |  |
| VC-6 | summary fail=0 rc=0 且四位 diff=0 | TASK_PLANNER_ROOT=$PWD/skills/task-planner bash skills/task-planner/lib/verify.sh ｜ tail -1 |  |

## 🧩 输出示例与格式契约（Rule 113）
| id | 交付物 | 格式 | 对应 VC | 完整示例 | 可复用模板 |
|---|---|---|---|---|---|
| EX-1 | skills/research-channels/{SKILL.md,references/research-channels.md,scripts/project-inventory.sh} + 通用源消费门 | TSV 四列声明文件+门 stdout 带 tag/rc | VC-1, VC-2 | 见下方「完整示例」代码块 | 见下方「可复用模板」代码块 |

### 示例 EX-1 · skills/research-channels/{SKILL.md,references/research-channels.md,scripts/project-inventory.sh} + 通用源消费门
- **格式**：TSV 四列声明文件+门 stdout 带 tag/rc
- **对应 VC**：VC-1, VC-2

**完整示例（可直接查看）**：

.spec-registry.tsv 三源类型声明：bible.md\tsetting\t各自扎营|自主选点\tcontent-creation ／ config/render-pipeline.json\tconfig-key\tframe_rate|resolution\trender ／ agnes-api-notes.md\tlibrary-doc\tupload_url|rate_limit\tvideo-generation。门输出：[source-gate] FAILED: ①声明源通道 NA/空（注册表命中 3 源未扫描）; rc=1 ／ [diff-audit] FAILED: 删除行命中声明源锚 无处置行; rc=1

**可复用模板（占位符版）**：

<source_path>\t<spec_kind>\t<anchors_keywords>\t<scope_tags>；<gate-tag> FAILED/OK: <对象> <判据>; rc=<n>

## 🔍 调研需求与检索计划
| unit | 三态(LOCAL-ONLY/NET-RESEARCH/NET-DATA-DEPENDENT) | 检索关键词 | 渠道 | 预期产出形态 |
|---|---|---|---|---|
| 全局 | LOCAL-ONLY | （无 NET-* 检索项；执行期新增外部调研须先 planctl set --section research_status 补登） | - | - |

## Phase 锚点明细（3file-gate/plan-dispatch 解析面）

### Phase 1: P1 新技能 research-channels
- **Status:** complete
- **Started:** 2026-11-26T01:10:40Z
- **Executor:** executor
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S1 | [P1] research-channels 三件套创建 | executor |  |  |  |  | 无 | - | complete |
| S-P1 | [P1] P1 交付实施（真实执行=executor 子代理派发+主进程亲验）（实施+验证） | executor | 见 A-1~A-6 台账 | 对应 VC |  |  | 无 | - | complete |

### Phase 2: P2 消费链去枚举化
- **Status:** complete
- **Started:** 
- **Executor:** executor
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S-P2 | [P2] P2 交付实施（真实执行=executor 子代理派发+主进程亲验）（实施+验证） | executor | 见 A-1~A-6 台账 | 对应 VC |  |  | 无 | - | complete |

### Phase 3: P3 门与集成
- **Status:** complete
- **Started:** 
- **Executor:** executor
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S-P3 | [P3] P3 交付实施（真实执行=executor 子代理派发+主进程亲验）（实施+验证） | executor | 见 A-1~A-6 台账 | 对应 VC |  |  | 无 | - | complete |

### Phase 4: P4 条款与模板
- **Status:** pending
- **Started:** 
- **Executor:** executor
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S-P4 | [P4] P4 交付实施（真实执行=executor 子代理派发+主进程亲验）（实施+验证） | executor | 见 A-1~A-6 台账 | 对应 VC |  |  | 无 | - | complete |

### Phase 5: P5 验证
- **Status:** complete
- **Started:** 
- **Executor:** executor
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S-P5 | [P5] P5 交付实施（真实执行=executor 子代理派发+主进程亲验）（实施+验证） | executor | 见 A-1~A-6 台账 | 对应 VC |  |  | 无 | - | complete |

### Phase 6: P6 收口
- **Status:** complete
- **Started:** 
- **Executor:** executor
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S-P6 | [P6] P6 交付实施（真实执行=executor 子代理派发+主进程亲验）（实施+验证） | executor | 见 A-1~A-6 台账 | 对应 VC |  |  | 无 | - | complete |

## 🔒 规范基线（Spec-Baseline）
| spec_id | 约束原文(verbatim) | 来源锚(path:line) | 双向判定式 | 来源 sha256 | 槽 | 校验命令 | 适用S-unit | 结果 |
|---|---|---|---|---|---|---|---|---|
| SRC-1 | AGENTS.md | agents | pending | 8d5f3b56b1b2 |  |  |  |  |
| SRC-2 | CLAUDE.md | agents | pending | 7b4f8ef5a526 |  |  |  |  |
| SRC-3 | .zcode/plan-templates/README.md | template | pending | de0171ab28d0 |  |  |  |  |
| SRC-4 | .zcode/plan-templates/knowledge-brief.md | template | pending | 86cb6ef74206 |  |  |  |  |
| SRC-5 | .zcode/plan-templates/rule-clause-cascade-type.md | template | pending | 33b903318d6b |  |  |  |  |
| SRC-6 | CHANGELOG.md | agents-path | pending | 7230e1afb0c7 |  |  |  |  |
| SRC-7 | CONTRIBUTING_zh.md | agents-path | pending | 3f7004d3c7ec |  |  |  |  |
| SRC-8 | INSTALL_zh.md | agents-path | pending | e82fdcf72ecb |  |  |  |  |
| SRC-9 | README_zh.md | agents-path | pending | 1c563a6dc0df |  |  |  |  |
| SRC-10 | RETRIEVAL_EXCLUDE.md | agents-path | pending | e9692de60e9f |  |  |  |  |
| SRC-11 | examples/json-template-upgrade/review.md | agents-path | pending | c14e27132eec |  |  |  |  |
| SRC-12 | plans/INDEX.md | agents-path | pending | 1947043a2764 |  |  |  |  |
| SRC-13 | plans/task-research-channels-20261126/findings.md | agents-path | pending | 6463b7f97551 |  |  |  |  |
| SRC-14 | plans/task-research-channels-20261126/knowledge-brief.md | agents-path | pending | 1bf25fc59c26 |  |  |  |  |
| SRC-15 | plans/task-research-channels-20261126/notepad-learnings.md | agents-path | pending | 539a29c6f9ae |  |  |  |  |
| SRC-16 | plans/task-research-channels-20261126/plan-state.json | agents-path | pending | 7ac3dc93017c |  |  |  |  |
| SRC-17 | plans/task-research-channels-20261126/task_plan.md | agents-path | pending | 73227e006515 |  |  |  |  |
| SRC-18 | plans/task-research-channels-20261126/verification.md | agents-path | pending | 70ae75d5a15b |  |  |  |  |
| SRC-19 | progress.md | agents-path | pending | 71eed07d13de |  |  |  |  |
| SRC-20 | skills/plan-cost-guard/references/billing.md | agents-path | pending | fd4fdc3216ff |  |  |  |  |
| SRC-21 | skills/task-planner/config.json | agents-path | pending | 1000e69e8653 |  |  |  |  |
| SRC-22 | skills/task-planner/install.sh | agents-path | pending | 31c956745fa3 |  |  |  |  |
| SRC-23 | skills/task-planner/lib/verify.sh | agents-path | pending | e986626c1bdc |  |  |  |  |
| SRC-24 | skills/task-planner/references/critical-rules.md | agents-path | pending | 79b5071f4531 |  |  |  |  |
| SRC-25 | skills/task-planner/scripts/check-drift.sh | agents-path | pending | 07fcd07164e1 |  |  |  |  |
| SRC-26 | skills/task-planner/scripts/run-selftests.sh | agents-path | pending | c238ef9dbf86 |  |  |  |  |
| SRC-27 | skills/task-planner/scripts/session-catchup.ts | agents-path | pending | 3984f52a48ee |  |  |  |  |
| SPEC-3 | AGENTS.md | AGENTS.md:81 | bash skills/task-planner/scripts/selftest-research-channels.sh ｜ grep -c 'FAIL=0' >= 1 | 8d5f3b56b1b2 |  |  | S1-S6 |  |
| NA-2 | RETRIEVAL_EXCLUDE 类仓库配置锚，非本任务规范适用项 | agents | RETRIEVAL_EXCLUDE 类仓库配置锚，非本任务规范适用项 |  |  | n/a | S1-S9 | NA |

## 🧹 收尾对齐与清理（交付前必填）
| 类别 | 检查项 | 判据 | 证据 |
|---|---|---|---|
| 对齐 | 口径计数 / 冲突条款 / 行数快照 | 冲突锚 grep 无本任务新增命中 | progress `[align-final]` 行 |
| 清理 | Skill 说明 Markdown 中的历史旁注 / 过期注 / 残留物；代码文件注释不在清理范围、受保护 | 本任务新增痕迹注为 0（代码注释不计入） | progress `[cleanup-final]` 行 |

范围：只清会被 Agent 读进上下文的 Skill 说明文件；代码文件（.py/.sh/.ts 等）里的注释属保护对象，禁止清理。执行时机：outcome 判定之前、合并回动作之前；mini / L0-lite 档豁免本板块。

## 🔀 隔离决策
| 字段 | 值 |
|---|---|
| merge_back | merged(b3b9c572) |

## 📊 FMEA 预演
| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作 |
|---|---|---|---|---|---|---|
| P5 | 负控制恒真（判据恒 PASS） | 9 | 4 | 3 | 108 | 夹具 T2/T5 删除已声明源锚定内容必须 FAIL；mutation 复演；门以 rc 判定禁恒真 |
| P2 | 词表数据化迁移丢失致夹具漂移 | 8 | 4 | 3 | 96 | 种子文件缺失回退内置行为；selftest-spec-baseline 既有断言全量重跑 |

## Decisions Made
| Decision | Rationale |
|---|---|
| P2 字面偏离已批准计划 M1 的“拆除词表枚举”条款：保留 check-spec-baseline 内置 fallback 词表 | 该 fallback 是 task-spec-registry-generalization 显式登记的 fail-safe 契约（种子缺失=现状逐字节），拆除违反向后兼容硬红线；通用性改由源注册表数据层实现（维度开放标签零新枚举），意图满足 M1 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|---|---|---|---|
| 并行派发事故：P3 执行体把 P2 未提交的 planctl.py 改动误判遗留而 git restore 还原 | 0 | P2 已重建改动；后续并行派发一律加禁 restore 条款 | 同 worktree 并行执行体的 prompt 必须显式列出 git 危险操作禁令 |
| P2 末轮回报异常：自称被要求 TEXT ONLY 0 验证（prompt 无此约束=末轮自我限制幻觉）且 acceptance 0/5 自报 | 0 | 主进程盘面亲验为准：Task A done/Task B 未做；派 P2-repair 专补 | executor 回报一律与盘面交叉验证；partial/0 自报不采信为终态 |
| dogfood 夹具 source-gate OK=0：template_type 直改 JSON 后未重 render，门读的是渲染视图旧 header | 0 | 夹具补 render；机制侧四态输出已被 P2-repair 夹具证明 | 改 template_type 后必须 render 再跑门 |

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
| 1 |  |  |  | queued |  |  |  |  | - / 0 / ☐ |
| 2 |  |  |  |  |  |  |  |  | - / 0 / ☐ |
| 3 |  |  |  |  |  |  |  |  | - / 0 / ☐ |
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
