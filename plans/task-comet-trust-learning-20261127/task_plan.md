<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Task Plan: task-comet-trust-learning-20261127

- task_id: `task-comet-trust-learning-20261127`
- 时间: created_at=2026-11-26T22:41:31Z / updated_at=2026-11-27T04:30:23Z
plan_tier: standard
execution_lane: L2
schema_version: 1
- 顶层 tags: （无）
- 验收: awaiting

## 🎯 用户需求原文
- **R1（手段）** 从 Comet 提炼可信度机制并按地基→入口→出口融合进 task-planner
- **R2（手段）** 保住项目核心=长线会话记录的数据基础、长任务稳定性；底座不可拆
- **R3（手段）** 交付=设计spec+writing-plans实施计划；不改源码/不部署/不提交

## Requirements（用户需求）
| id | type | text | vc | tags |
|---|---|---|---|---|
| R1 | 手段 | 从 Comet 提炼可信度机制并按地基→入口→出口融合进 task-planner |  |  |
| R2 | 手段 | 保住项目核心=长线会话记录的数据基础、长任务稳定性；底座不可拆 |  |  |
| R3 | 手段 | 交付=设计spec+writing-plans实施计划；不改源码/不部署/不提交 |  |  |

## Goals（目标单元）
| id | text | evidence | tags |
|---|---|---|---|
| G1 | 产出 Comet 可信度学习设计 spec 并通过自审 |  |  |

## 🎯 Goal 单元表
| goal-id | 任务名 | 目标 | 完整验证方式 | 对应 S-unit | 状态 |
|---|---|---|---|---|---|
| G1 |  | 产出 Comet 可信度学习设计 spec 并通过自审 | 见下方 ✅ Verification Contract 区块（VC 全集） | - | pending |

## Phases（阶段状态）
| id | status | s_units | v_checks | name | started | tags |
|---|---|---|---|---|---|---|

## R→VC 映射
| requirement | vcs |
|---|---|
| R1 |  |
| R2 |  |
| R3 |  |
## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
| 工序 | 缺陷面 | 修复点 | VC |
|---|---|---|---|
| （root_causes 未登记） | 结果级需求须 planctl add --section root_causes 逐工序补登；非结果级任务在本行写「不适用（非结果级）」+定性理由 | - | - |

## ✅ Verification Contract（VC 状态与判据）
| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|---|---|---|

## 🧩 输出示例与格式契约（Rule 113）
（尚未登记 output_examples —— Rule 113.1：凡声明输出格式的交付物必须给出完整示例+可复用模板，经 `planctl add --section output_examples` 登记；无格式交付物须显式写 none-justified 并附理由）

## 🔍 调研需求与检索计划
| unit | 三态(LOCAL-ONLY/NET-RESEARCH/NET-DATA-DEPENDENT) | 检索关键词 | 渠道 | 预期产出形态 |
|---|---|---|---|---|
| 全局 | LOCAL-ONLY | （无 NET-* 检索项；执行期新增外部调研须先 planctl set --section research_status 补登） | - | - |

## 🧹 收尾对齐与清理（交付前必填）
| 类别 | 检查项 | 判据 | 证据 |
|---|---|---|---|
| 对齐 | 口径计数 / 冲突条款 / 行数快照 | 冲突锚 grep 无本任务新增命中 | progress `[align-final]` 行 |
| 清理 | Skill 说明 Markdown 中的历史旁注 / 过期注 / 残留物；代码文件注释不在清理范围、受保护 | 本任务新增痕迹注为 0（代码注释不计入） | progress `[cleanup-final]` 行 |

范围：只清会被 Agent 读进上下文的 Skill 说明文件；代码文件（.py/.sh/.ts 等）里的注释属保护对象，禁止清理。执行时机：outcome 判定之前、合并回动作之前；mini / L0-lite 档豁免本板块。

## Decisions Made
| Decision | Rationale |
|---|---|
| 交付范围=方案+writing-plans；优先级=地基优先（状态/证据→验收→决策/断点）；第3-6节设计全部通过 | 用户 AskUserQuestion 三次选定；两侧根因调研独立收敛到消费侧门优先 |
| 用户追加要求：真正开始前先打 Git 阶段性 tag（大范围重构基线锚点）。tag 沿用既有轻量风格，命名 baseline-before-comet-trust-refactor-20261127-064717，指向当前 HEAD ced991e4 | 重构涉及面广需可追溯/可回退锚点；tag 只指向已提交 commit，不纳入 28 项未提交变更（含他任务杂物） |
| [tier-upgrade] 运行 59 分钟，触发原因：步骤门：findings/research（软阈值 15min / 硬阈值 45min），自动升级 standard 检查面 | 用户 2026-11-24/25 裁决：软阈值15min须联合步骤门(phase complete/findings/delegations) 或 硬阈值45min兜底，零主观判断 |
| 本阶段设计/计划文档（spec 措辞修正 + writing-plans 实施计划）在 docs/ 下产出，豁免 worktree 隔离 | 宪法 §11.5②纯文档非实现类 + 用户明确交付=方案+实施计划；本阶段不改任何 skills/ 源码、不部署、不提交；worktree 从 master checkout 看不到未提交的 spec 文档，隔离无意义 |
| worktree-required 门与 SOP §158（文档留主仓）冲突，经用户授权用 Bash heredoc 落盘设计过程文档；仅 docs/superpowers/ 两份，不动 skills/ 源码 | 门把过程文档误分类为 delivery=1；实现阶段（Task 0 Step3 起）仍严格在 worktree 内进行 |
| Task 4 为 2 个历史零断言 selftest（user-instruction-priority/verify-io）补真断言后再启用零断言 guard，保持回归 FAIL==基线2 | 用户裁决：避免破坏回归判据且真正消除假绿；基线实测 selftest 117/115/2、verify 27/4 |
| Task3 brief 插入位置与盘上控制流冲突：check-scope.sh 节② walk-up(:73-81)对 plans/ 祖先路径直接 exit 0，保护段插其后必失效；裁决采纳 implementer 选项0——把 abs_path 计算+派生MD保护段前移到节②(:71)之前，仅对4个派生MD收紧，其余 plans/ 放行语义不变 | controller 盘上复查证实(:71 abs_path、:73-81 早退、:90-92 basename豁免、:183 真锚点)；属执行细节技术修正非G门用户决策；负控rc=1唯一有效位置 |
| 终审 NEEDS FIX：3 必修（P0 check-verdict 取首个 outcome 致模板字面行假绿；P0 check-evidence-binding 不读 version/recorded_at 致旧 hash 放行；P1 run-selftests 缓存合成 0/0 致幻影 FAIL）；按 SDD 派 ONE fixer 一次性修复，保留 Minor 到后续独立任务 | 终审实测复现三缺陷；逐条派修复违反 SDD 单 fixer 规则；三项均不改 Total=121 |
| 部署对账范围按 install.sh 默认 4 位（zcode/claude/opencode/cursor）；~/.agents 位按 smart-merge-back.sh :615/:850 明示为全局保护区、需 TASK_PLANNER_DEPLOY_SLOTS env 显式覆盖，未经授权不直写，登记为已知边界 | 宪法 §六/项目 AGENTS §2：部署位只走 install.sh 官方链路；.agents 明确排除默认部署，避免越权投毒 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|---|---|---|---|
| 首次探查子代理因 ZCode 运行时进程意外退出(OOM)失败、无产出 | 0 | 核对交付物完好且代理只读未留改动后，重新派发同任务探查代理 | 探查 prompt 限制输出长度以控制内存 |

## 🔒 规范基线（Rule 51.15 — 全档位必填）
| spec_id | 约束原文(verbatim) | 来源锚(path:line) | 双向判定式 | 来源 sha256 |
|---|---|---|---|---|
| <SPEC-ID> | <约束原文> | <来源锚 path:line> | <上下界齐全的判定式，如 4s≤单镜≤12s> | <sha256 或 n/a(文本片段)> |
填写规则（全档位必填）：无候选写 `none-justified（理由）`，禁留空；区间型硬约束的双向判定式必须同时写上下界（如 `4s≤单镜≤12s`），禁单边；登记后任何放宽/删除须按 Rule 51.15 STOP→用户授权→Decisions Made 登记→重锁 attest。

## 🔗 Subagent Handoff 登记表（Rule 22.5）
| # | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要 | checkpoint 路径 |
|---|---|---|---|---|---|
| 1 | （派发时填写；全程主进程填「无」） |  | pending |  |  |

## 🧩 输出示例与格式契约（Rule 113 · 极简档）
> 本档至少 1 条：完整示例 + 同结构模板（字段可最小化，但结构必须真实可模仿）。
- 交付物 / 格式：article.json / JSON
- 完整示例：`{"title":"示例标题","count":3}`
- 可复用模板：`{"title":"<TITLE>","count":<INT>}`
- 对应 VC：VC-1
