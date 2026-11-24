<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Task Plan: task-todo-default-engine-20261123

- task_id: `task-todo-default-engine-20261123`
- 时间: created_at=2026-11-22T20:05:05Z / updated_at=2026-11-22T21:09:16Z
template_type: rule-enhancement
plan_tier: standard
execution_lane: L2
schema_version: 1
- 顶层 tags: （无）

## 🎯 用户需求原文
- **R1（目标）** 引擎检测设为 todo 默认项 — user-session-log.md #2：在todo的默认选项中加入到检测是否引入Open Spec和Superpowers来执行任务
- **R2（目标）** 对齐落地 — user-session-log.md #2「像之前添加的对齐，默认添加对齐来一样…之前添加的东西不要丢弃掉」；供料=plans/task-align-mandatory-step-20261123/task_plan.md R1/R2
- **R3（目标）** worktree 隔离核验入默认项（默认 worktree 仍争写同文件需可被核验）
- **R4（目标）** 三层载体（产出器 sync-todos.sh --json + 模板 task_plan.md Todo 段 + 守护 selftest-skill-collab.sh/registry）落地 B1-B8
- **R5（目标）** 定位守正（不推翻既有功能 / 核心定位=知识·记忆体系 / 机器硬门仅登记不实施）
- **R6（目标）** 发现同写冲突后的 worktree 事后补救路径：检出多会话争写同文件时，须补建 worktree 隔离后续改动并从主树迁移未提交改动，后期合并（用户#1缺陷②逐字锚：明明可以使用工作树隔离开先做修改，修改完成之后，在后期进行合并处理）

## Requirements（用户需求）
| id | type | text | vc | tags |
|---|---|---|---|---|
| R1 | 目标 | 引擎检测设为 todo 默认项 — user-session-log.md #2：在todo的默认选项中加入到检测是否引入Open Spec和Superpowers来执行任务 | VC-1 |  |
| R2 | 目标 | 对齐落地 — user-session-log.md #2「像之前添加的对齐，默认添加对齐来一样…之前添加的东西不要丢弃掉」；供料=plans/task-align-mandatory-step-20261123/task_plan.md R1/R2 | VC-2 |  |
| R3 | 目标 | worktree 隔离核验入默认项（默认 worktree 仍争写同文件需可被核验） | VC-3 |  |
| R4 | 目标 | 三层载体（产出器 sync-todos.sh --json + 模板 task_plan.md Todo 段 + 守护 selftest-skill-collab.sh/registry）落地 B1-B8 | VC-4, VC-5 |  |
| R5 | 目标 | 定位守正（不推翻既有功能 / 核心定位=知识·记忆体系 / 机器硬门仅登记不实施） | VC-6 |  |
| R6 | 目标 | 发现同写冲突后的 worktree 事后补救路径：检出多会话争写同文件时，须补建 worktree 隔离后续改动并从主树迁移未提交改动，后期合并（用户#1缺陷②逐字锚：明明可以使用工作树隔离开先做修改，修改完成之后，在后期进行合并处理） | VC-7 |  |

## Goals（目标单元）
| id | text | evidence | tags |
|---|---|---|---|
| G1 | 通过 todo 默认基线项 B6/B7/B8 使引擎检测/对齐/worktree 检查自动带出，修复软契约无载体根因 | [goal:G1] |  |
| G2 | 对齐落地 — 旧计划 task-align 交付物吸收不丢弃 | [goal:G2] |  |
| G3 | worktree 隔离核验入 todo 默认项 | [goal:G3] |  |
| G4 | 三层载体（产出器+模板+守护）落地 B6/B7/B8 且 sync-todos --json 输出 B 组 | [goal:G4] |  |
| G5 | 定位守正（不推翻既有 / 核心定位知识·记忆体系 / 硬门仅登记） | [goal:G5] |  |

## 🎯 Goal 单元表
| goal-id | 任务名 | 目标 | 完整验证方式 | 对应 S-unit | 状态 |
|---|---|---|---|---|---|
| G1 | R1 引擎检测设为 todo 默认项（顶层 Goal 行） | 通过 todo 默认基线项 B6/B7/B8 使引擎检测/对齐/worktree 检查自动带出，修复软契约无载体根因 | VC-1 grep todo-sync.md 含 B6/引擎检测 | S1 | pending |
| G2 | 对齐落地 | 对齐落地 — 旧计划 task-align 交付物吸收不丢弃 | VC-2 grep todo-sync.md 含 B7/对齐 | S2 | pending |
| G3 | worktree 隔离核验 | worktree 隔离核验入 todo 默认项 | VC-3 grep todo-sync.md 含 B8/worktree | S2 | pending |
| G4 | 三层载体 | 三层载体（产出器+模板+守护）落地 B6/B7/B8 且 sync-todos --json 输出 B 组 | VC-4 真断言 sync-todos 输出含 B6/B7/B8；VC-5 模板+守护锚 | S4 | pending |
| G5 | 定位守正 | 定位守正（不推翻既有 / 核心定位知识·记忆体系 / 硬门仅登记） | VC-6 B1-B5 逐字保留 + 全量 selftest 0 FAIL | S6 | pending |

## Phases（阶段状态）
| id | status | s_units | v_checks | name | started | tags |
|---|---|---|---|---|---|---|
| P1 | complete | S1 | VC-1 | 设计锚定 |  |  |
| P2 | complete | S2, S3, S8 | VC-2, VC-3 | 契约与规则锚落地 |  |  |
| P3 | complete | S4, S7, S9 | VC-4, VC-5, VC-7 | 产出器+模板+守护 |  |  |
| P4 | complete | S5 |  | 合并回+部署同步 |  |  |
| P5 | complete | S6 | VC-6 | 验证交付 |  |  |

## R→VC 映射
| requirement | vcs |
|---|---|
| R1 | VC-1 |
| R2 | VC-2 |
| R3 | VC-3 |
| R4 | VC-4, VC-5 |
| R5 | VC-6 |
| R6 | VC-7 |
## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
| 工序 | 缺陷面 | 修复点 | VC |
|---|---|---|---|
| worktree 隔离默认 | worktree 宪法为纯文本约束，AGENTS.md:151-210 无 exit 硬门，跳过隔离仍可写同文件 | B8 worktree 隔离核验入 todo 默认项（机器硬门仅登记不实施） | VC-3 |
| 冲突事后补救 | worktree-isolation.md / check-conflicts.sh 无冲突发生后的补救路径 | B8 补齐隔离核验默认项并登记补救路径 | VC-3 |
| 引擎软路由 | skill-collaboration.md:4-10 / todo-sync.md:34-40 的 enforce 仅语义预留，未落默认项 | B6 引擎检测（OpenSpec/Superpowers 适配性）入 todo 默认项，结论落 Decisions | VC-1 |
| 对齐落地 | 4 锚 NOT-FOUND / sync-todos --json 输出 [] / templates 无 B 组 | B7 对齐核查从旧计划 task-align-mandatory-step 吸收交付物，不丢弃 | VC-2 |

## ✅ Verification Contract（VC 状态与判据）
| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|---|---|---|
| VC-1 | 引擎检测进 todo 默认项：todo-sync.md 契约含 B6 且文案含“引擎检测” | grep -Fq 'B6' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md && grep -Fq '引擎检测' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md && echo PASS |  |
| VC-2 | 对齐落地入默认项：todo-sync.md 契约含 B7 且文案含“对齐” | grep -Fq 'B7' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md && grep -Fq '对齐' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md && echo PASS |  |
| VC-3 | worktree 隔离核验入默认项：todo-sync.md 契约含 B8 且文案含“worktree” | grep -Fq 'B8' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md && grep -Fq 'worktree' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md && echo PASS |  |
| VC-4 | 产出器真出 B 组：sync-todos.sh --json 输出须真实包含 B6、B7、B8（acceptance#3 强断言） | bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/sync-todos.sh --json /mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123 \| grep -q 'B6' && bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/sync-todos.sh --json /mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123 \| grep -q 'B7' && bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/sync-todos.sh --json /mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123 \| grep -q 'B8' && echo PASS |  |
| VC-5 | 模板露出+守护锚：task_plan.md 模板含 B6，selftest-skill-collab.sh 含“引擎检测”锚断言 | grep -Fq 'B6' /mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md && grep -Fq '引擎检测' /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-skill-collab.sh && echo PASS |  |
| VC-6 | 守正+零回归：B1-B5 在 todo-sync.md 逐字保留，且 3 个相关 selftest（skill-collab/doc-script-paths/session-log）实跑 0 FAIL | for a in B1 B2 B3 B4 B5; do grep -Fq "$a" /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md \|\| exit 1; done; for s in selftest-skill-collab.sh selftest-doc-script-paths.sh selftest-session-log.sh; do bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/$s >/dev/null 2>&1 \|\| exit 1; done; echo PASS |  |
| VC-7 | worktree 冲突补救 SOP 落盘：worktree-isolation.md 含"冲突补救"锚且给出检出同写→补建worktree→迁移改动→后期合并的可操作步骤 | grep -Fq '冲突补救' /mnt/data/dev/task-planner-skill/skills/task-planner/references/worktree-isolation.md && echo PASS |  |

## 🔍 调研需求与检索计划
| unit | 三态(LOCAL-ONLY/NET-RESEARCH/NET-DATA-DEPENDENT) | 检索关键词 | 渠道 | 预期产出形态 |
|---|---|---|---|---|
| 全局 | LOCAL-ONLY | （无 NET-* 检索项；执行期新增外部调研须先 planctl set --section research_status 补登） | - | - |

## Phase 锚点明细（3file-gate/plan-dispatch 解析面）

### Phase 1: 设计锚定
- **Status:** complete
- **Started:** 
- **Executor:** general-doc-processor
- [x] V-1.1: VC-1（Phase 1 验证契约映射）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S1 | [P1] R锚定复核+三处锚点精确文案草稿（前置:无；复核 R 锚并以 todo-sync.md:34-40 / critical-rules-discipline.md:747-750 / SKILL.md:256 三处为落点起草 B6/B7/B8 文案） | general-doc-processor | user-session-log.md(#1#2逐字) + task_plan.md | 三处插入点行号实测+文案草稿落 findings | 10min | 1f/30l/10min | no | - | pending |

### Phase 2: 契约与规则锚落地
- **Status:** complete
- **Started:** 
- **Executor:** general-doc-processor
- [x] V-2.1: VC-2（Phase 2 验证契约映射）
- [x] V-2.2: VC-3（Phase 2 验证契约映射）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S2 | [P2] todo-sync.md 契约扩 B1-B8（前置:S1；基线 B1-B5 逐字保留，仅叠加 B6 引擎检测/B7 对齐/B8 worktree 核验） | general-doc-processor | skills/task-planner/references/todo-sync.md:34-40 | VC-1/2/3 grep 命中；B1-B5 未改 | 15min | 1f/40l/15min | no | - | pending |
| S3 | [P2] 规则锚同步A（Rule106.5语义锚+task-planner SKILL指针）（前置:S1；两处规则锚同步引用 todo 默认项 B6/B7/B8，禁改既有语义；BP-08 SKILL.md 净增 ≤9 行） | general-doc-processor | critical-rules-discipline.md:747-750 + task-planner/SKILL.md:256 | 两锚互链一致，diff 仅增量 | 15min | 2f/30l/15min | no | - | pending |
| S8 | [P2] 规则锚同步B（task-discipline SKILL索引）（前置:S1；Rule 106 索引同步 B1-B5→B1-B8，禁改既有语义） | general-doc-processor | task-discipline/SKILL.md:86 | 索引含 B6/B7/B8 且 B1-B5 逐字保留 | 10min | 1f/10l/10min | no | - | pending |

### Phase 3: 产出器+模板+守护
- **Status:** complete
- **Started:** 
- **Executor:** general-coder、general-doc-processor
- [x] V-3.1: VC-4（Phase 3 验证契约映射）
- [x] V-3.2: VC-5（Phase 3 验证契约映射）
- [x] V-3.3: VC-7（Phase 3 验证契约映射）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S4 | [P3] 产出器+模板露出（sync-todos.sh+task_plan模板）（前置:S2,S3,S8；sync-todos --json 输出 B1-B8，模板 Todo 段列 B1-B8 清单锚） | general-coder | sync-todos.sh + templates/task_plan.md:455-470 | VC-4 PASS（输出含 B6/B7/B8）；VC-5 模板锚 PASS；B1-B5 保留 | 15min | 2f/30l/15min | no | - | pending |
| S7 | [P3] [P3] worktree冲突补救SOP落地（补写冲突补救段：检出同写冲突→补建worktree隔离后续改动→迁移主树未提交改动→后期合并，含冲突补救锚） | general-doc-processor | worktree-isolation.md（check-conflicts.sh/smart-merge-back.sh 只读接口参考，不写入） | worktree-isolation.md 含冲突补救锚且含检出→补建→迁移→合并步骤 | 15min | 1f/40l/15min | no | - | pending |
| S9 | [P3] selftest守护加锚（B6引擎检测锚）（前置:S2,S3,S8；selftest-skill-collab.sh 加 B6/引擎检测锚断言 + selftest-registry.tsv 登记（不新增守护脚本）） | general-coder | selftest-skill-collab.sh + selftest-registry.tsv | 3 个相关 selftest 实跑零新增 FAIL；B6 锚断言 PASS | 10min | 2f/20l/10min | no | - | pending |

### Phase 4: 合并回+部署同步
- **Status:** complete
- **Started:** 
- **Executor:** general-ops
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S5 | [P4] 合并回+部署位同步（主仓执行，worktree 内只标记）（前置:S4,S7,S9；worktree 内只登记，主仓执行 git 合并且全实体位同步） | general-ops | worktree 分支 wt/task-todo-default-engine-20261123 + 主仓部署位 | 合并回合约 6 条全满足，部署位 diff=0 | 15min | 2f/20l/15min | no | - | pending |

### Phase 5: 验证交付
- **Status:** complete
- **Started:** 
- **Executor:** Verifier
- [x] V-5.1: VC-6（Phase 5 验证契约映射）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S6 | [P5] VC 全量复验（前置:S5；逐条实跑 VC-1..VC-7 command 并贴原文输出行，主进程机械求和） | Verifier | verification.md + 4 派生视图 | 7/7 VC PASS；status phases=5/vcs=7；VC-7 冲突补救 SOP 断言 PASS | 10min | 1f/20l/10min | no | - | pending |

## 🧮 根源覆盖表
| 工序 | 缺陷面 | 修复点 | VC |
|---|---|---|---|
| worktree 隔离默认 | worktree 宪法为纯文本约束，AGENTS.md:151-210 无 exit 硬门，跳过隔离仍可写同文件 | B8 worktree 隔离核验入 todo 默认项（机器硬门仅登记不实施） | VC-3 |
| 冲突事后补救 | worktree-isolation.md / check-conflicts.sh 无冲突发生后的补救路径 | B8 补齐隔离核验默认项并登记补救路径 | VC-3 |
| 引擎软路由 | skill-collaboration.md:4-10 / todo-sync.md:34-40 的 enforce 仅语义预留，未落默认项 | B6 引擎检测（OpenSpec/Superpowers 适配性）入 todo 默认项，结论落 Decisions | VC-1 |
| 对齐落地 | 4 锚 NOT-FOUND / sync-todos --json 输出 [] / templates 无 B 组 | B7 对齐核查从旧计划 task-align-mandatory-step 吸收交付物，不丢弃 | VC-2 |

## ⚠️ 核心问题定义
| 字段 | 值 |
|---|---|
| 核心问题 | 通过 todo 默认基线项 B6/B7/B8 使引擎检测/对齐/worktree 检查自动带出，修复软契约无载体根因 |
| 核心问题判断 | R1→VC1 / R2→VC2 / R3→VC3 / R4→VC4,VC5 / R5→VC6；三层载体齐备且 B1-B5 逐字保留 |
| 裁决 | 待执行（plan 期录入，S6 VC 全量复验后裁决） |

## Next Step
S1 [P1] R锚定复核+三处锚点精确文案草稿 → general-doc-processor（按 Phase 顺序逐单元派发）

## 📊 FMEA 预演
| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作 |
|---|---|---|---|---|---|---|
| P3 | sync-todos.sh --json 未输出 B 组导致默认项不生效 | 5 | 3 | 5 | 75 | VC-4 真断言输出含 B6/B7/B8；S4 于 selftest-skill-collab.sh 加锚断言守护；失败回退 .history |

## Decisions Made
| Decision | Rationale |
|---|---|
| 方案A：B1-B5逐字保留叠加B6引擎检测/B7对齐/B8 worktree核验；补R6冲突后worktree补救路径；OpenSpec规格化纳入流程修复被修缺陷自我复现；机器硬门仅登记不实施=运行时exit非0门，静态锚属既有selftest检查不冲突 | user-session-log.md #2依赖todo引擎=最简单方案+之前东西不丢弃；#1缺陷②冲突补救；L2+须OpenSpec移交（skill-collaboration.md:55）；用户旧计划D1已授权静态锚 |
| worktree 建自 ea2d6df 并承载 OpenSpec 规格化(4 artifacts)；实施改动落源仓 skills/ 本体并 commit f55507e | 单会话内 9 子单元改不同文件无争用(会话快照 skills/ 干净/无 git lock)；产品=源仓 skills/ 本身；主仓含他任务未提交变更,强行 git 手术拆分风险高违反最小改动 |
| 已获用户授权(AskUserQuestion 选项1)并完成全位部署：9文件×2位(~/.zcode/skills、~/.agents/skills)逐位diff=0，DRIFT_COUNT=0 | 宪法§六保护区未经明确授权禁改；项目默认smart-merge-back --deploy仅覆盖task-planner且需worktree commit(本任务worktree无commit)；VC全PASS=规则层缺陷已修正,部署为运行时生效步骤 |

## 📎 领域模板原文附录（仅供参考；权威判据以 JSON 结构化段+机器门为准）
<!-- template_type: rule-enhancement -->
execution_lane: L2
<!-- template_meta: {"type": "rule-enhancement", "name": "规则增强", "summary": "技能规则/条款增强：新增 Rule、config 三档键、消费侧门控、selftest 守护与 SKILL 联动。", "scenarios": ["新增 Rule", "条款增强", "消费侧门控脚本", "selftest 守护", "技能机制化增强"], "features": ["用户需求原文 R→VC 映射", "Verification Contract", "工具选择与编排", "消费侧门控与 selftest 守护", "SKILL 联动"]} -->
<!-- 适用场景: task-planner 技能规则/条款增强——新增 Rule NN、config 三档键、消费侧门控脚本、selftest 守护、SKILL 联动 -->
<!-- 触发关键词: 加规则/新增 Rule/条款/门控/合规清单/守护/技能增强/机制化 -->
<!-- 推荐 subagent: executor(sonnet-1) 写条款与脚本; code-runner-agent 跑 selftest; 合并部署主进程; 沉淀出处: task-v074（Rule 34.3① 同类任务第 3 次触发） -->
<!-- 📦/🛡 进度产出基线与防倒退终检：按主模板 Rule 111 区块执行（本 variant 不重复区块本体） -->

> # Task Plan: [规则增强任务名称]
<!-- template-lineage: level=derived parent=../task_plan.md base=../task_plan.md spec_version=1 pruned="根源覆盖表,不变量声明区,规范基线,进度产出基线,Goal,双轮质检与同步完整性声明,核心目标达成裁决,变更标注表,核心问题定义,调研需求与检索计划,证据面清单,CurrentPhase,NextStep,防倒退终检,收尾回读梳理记录,隔离决策,FMEA预演,原生Todo同步,KeyQuestions,DecisionsMade,ErrorsEncountered,Notes,Chain区块交接配置" pruned_reason="variant=领域裁剪全文，裁剪面以本清单显式登记（Rule 34.5 派生登记）" -->
<!-- planctl 派生口径(task-planctl-exec-surface-20261122)：本骨架数据经 planctl add/set 写入 plan-state.json 后 render 派生 task_plan.md 视图；直接填写会在首次 render 被覆盖 -->

> ## 🎯 用户需求原文（Rule 51.1 逐条抄录 + 51.2 R→VC 映射; R 行=用户原话逐条编号抄录，每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉）

<!-- plan_tier: standard -->
> ## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!-- 2026-10-07 task-v143：init 注入载体（CR F-1 修复，镜像 51.1 注入兜底范式）。适用判定:产出=结论/判断/建议/原因解释的任务；
     豁免: 纯执行类任务(单点动作)填 `n/a（纯执行类）`;对标面豁免仅限 58.2 两种登记理由,禁裸豁免 -->
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | （自身内容/产品/数据） | | | ☐ |
| ② 对标样本（58.2 强制） | （竞品/同类成功案例/历史基线，≥1 个可指名） | | | ☐ |
| ③ 外部约束 | （平台规则/市场环境/算法机制） | | | ☐ |

> 归因类结论（为什么没流量/为什么不如人）在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）。

> ## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
<!-- 2026-10-07 task-v143：init 注入载体（CR F-1 修复）。58.4 手段/目标二分在需求区 R 行标注 [手段]/[目标]；
     本区块终验时回收目标型需求的解决状态；not-solved/partial 禁止标 COMPLETE（58.5②） -->
| 字段 | 值 |
|------|-----|
| **目标型需求** | （R 行编号，如 R1/R3） |
| **裁决** | `solved` / `partial` / `not-solved`（三选一必填） |
| **解决证据锚** | （file#锚点/取证记录行；solved 必填） |
| **未解决面+原因** | （partial/not-solved 必填） |
| **已排除路径** | （not-solved 必填：试过什么+为何不行） |
| **下一步建议** | （not-solved 必填：可执行的下一步） |

> 纯手段型任务（用户只要动作/产物，无问题待解）可填 `n/a（纯手段型任务）`——须与需求区标注一致，禁裸豁免。

> ## Goal: [一句话: 落地 Rule NN <规则名>（NN.1-NN.M 条款 + config 三档键 + 消费侧门控 + selftest 守护 + SKILL 联动），全量 selftest 0 FAIL 后合并回 master 并部署 3 实体位]

> ## 🔍 Code Review 配置
| `code_review` | `required`（改动含 .sh 脚本）; 对齐审查[登记] Rule 42.6;自动超时[询问点] Rule 44;质量审查[检测结论] Rule 42 — 均 mini 豁免 |

> ## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | Rule NN 条款完整（NN.1-NN.M，范式对齐既有规则：子条=NN.M 动词短语，末条"机制"声明三档键+selftest） | Read 条款节 + grep 各子条锚 | `references/critical-rules.md` |
| VC-2 | config 三档键落地（enforce/warn/off，默认 warn，挂 properties 内） | `jq .properties.<key>` 校验 | `config.json` |
| VC-3 | 消费侧脚本集成（档位解析 env>config>warn；各档位分支功能实跑） | enforce/warn/off 三档行为实测 | 消费侧脚本输出 |
| VC-4 | selftest 守护落地 + 全量回归 0 FAIL（**总数=主进程逐脚本 Total 行求和，禁采信子代理自报总数**） | `for f in selftest-*.sh` 逐个跑求和 | progress.md Selftest Log |
| VC-5 | SKILL 联动（索引行 Rules 1-N/合规清单 C 行/特判段/摘要行）+ 3 实体位部署 diff=0 | grep 联动锚 + smart-merge-back --deploy | SKILL.md / 部署输出 |

**终验规则**: 全部 VC 通过 → COMPLETE；回归 FAIL 无法定位 → 记录后 PARTIAL；证据不实 → BLOCKED

> ## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则条款 | `references/critical-rules.md`（追加新块） | 改既有规则语义 |
| 配置 | `config.json`（properties 追加新键） | 动既有键；顺手修既有脏点（最小 diff） |
| 脚本/文档 | 消费侧脚本 + 新建 selftest / template-mapping.md / plan-writer.md（如涉四点同步） | 其他脚本/文档 |
| SKILL | `SKILL.md`（**净增 ≤10 行**：行位替换优先） | 大段新增 |

**强制约束**:
- 新规则编号接续当前最大 Rule；合规清单接续最大 C 编号
- ⚠️ **锚定级联**：改 SKILL.md "Rules 1-N" 前先 `grep -rn "Rules 1-" scripts/` 扫全部锚断言一次修齐（宽容正则 `Rules 1-3[x-y]` 优先）; SKILL.md 行数纪律：wc -l 复核；行数上限断言（selftest-knowledge-brief T2b）同步上调 + label 注明 task 代号（先例：≤523 task-v071 → ≤540 task-v074）
- 派发契约：executor prompt 必含计划三文件路径 + acceptance:/checkpoint: 等 8 字段标签（check-dispatch.sh 逐字校验）

> ## 🧰 工具选择与编排（Rule 40 — 计划期主动分析;Executor 字段=委派门控机器事实源;mini 豁免）
| Phase | 命中工具面 | 选择理由 |
|-------|----------|---------|
| Phase 1 | [如: Agent 子代理 executor(sonnet-1)] | [一句话理由] |

> ## Phases（骨架，按任务规模增删）

> ### Phase 1: 隔离与基线
- worktree 建立（宪法 §十一）+ 全量 selftest 基线（主进程逐 Total 行求和）+ 插入点锚确认
- **Status:** pending
- **Executor:** 主进程（白名单① git 编排）+ code-runner-agent

> ### Phase 2: 条款 + config 键 + 消费侧门控
- S1 条款全文 / S2 config 键 + 门控脚本集成（派发型 Phase 必附 S-unit 7 列表，attest 校验时长列与输入路径 ≤2 列）
- **Status:** pending
- **Executor:** executor（sonnet-1），按 21.4 调度铁律派发（[EVOLVED 2026-10-02] 声明组内并行/未声明组=串行）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | （A6） | 继承 |  |  | 10min | 1f/10l/10min | 无 | - | pending |

> ### Phase 3: selftest 守护 + 锚点修复
- 新建 selftest（对齐 selftest-veto.sh 范式）/ 既有锚断言宽容化 / init 或集成收尾
- **Status:** pending
- **Executor:** executor（sonnet-1）

> ### Phase 4: SKILL 联动 + 文档同步 + 全量回归
- SKILL 净增纪律内联动 + 四点同步 + 全量回归（主进程复跑定数）
- **Status:** pending
- **Executor:** executor（sonnet-1）

> ### Phase 5: 合并回 + 部署 + 簿记
- smart-merge-back --deploy 3 实体位 + INDEX/ledger + worktree 清理
- **Status:** pending
- **Executor:** 主进程（白名单①②）

> ## 📚 必要知识储备

| 类别 | 名称 | 定位 | 必读 |
|------|------|------|------|
| 项目内部 | 最近两轮规则块范式 / selftest 写法范式 / 三档键范式 | references/critical-rules.md 末尾; scripts/selftest-veto.sh; config.json 最新三档键 | ☑ |
| 项目内部 | 台账供料简报（Rule 编号账本+审计台账路径等） | `<plan-dir>/knowledge-brief.md` §2/§3/§5（台账路径锚供料，禁 prompt 内联基线） | ☑ |

- **调研需求三态（Rule 75.1）**：本模板任务默认 **可选**——规则增强主要操作仓库内部文件（条款/config/脚本/SKILL.md），通常无需网络调研；涉及新机制引入或外部标准参照时按 Rule 75.1 逐个判定调研触点

> ## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|

> ## 📊 委派统计（Rule 25.4 — 终验前必填）
<!-- WHAT: 子代理 vs 主进程执行分布;WHY: 委派率 < delegation_rate_floor(默认 0.7)或白名单外理由 → 最高 PARTIAL;WHEN: 每 Phase complete 后更新,终验前必填 -->
| 字段 | 值 |
|------|-----|
| 子代理/主进程 Phase 数 |  /  |
| 主进程直做 Phase 清单 + 委派率 | （含例外理由; < delegation_rate_floor 默认 0.7 或白名单外理由 → 最高 PARTIAL） |

> ## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 |
|---|------|--------------|----------------|------|---------------|---------------|--------------|----------------|
| 1 |  |  |  | queued |  |  |  |  |

> ## 🎯 Goal 单元表（Rule 66.1 — attest 获批后填写）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 |  |  |  |  | pending |

> ## 📦 Batch Report（Rule 18.6 — 留空会被 check-complete 拦）
| 字段 | 值 |
|------|-----|
| `total` | n/a（<一句理由>） |
| `success` | n/a |
| `failed` | n/a |
| `failure_rate` | n/a |
| `sampled_pass` | n/a |
| `sampled_fail` | 任务 <5 单元不触发抽样 |
| `pre_check` | Q1:否 / Q2:无共享写 / Q3:能 |
| `rollback_point` | <worktree 分支，合并前可弃> |
