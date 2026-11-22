<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Task Plan: task-template-json-compat-20261122

- task_id: `task-template-json-compat-20261122`
- 时间: created_at=2026-11-21T23:24:11Z / updated_at=2026-11-22T00:16:06Z
plan_tier: standard
execution_lane: L1
schema_version: 1
- 顶层 tags: （无）

## 🎯 用户需求原文
- **R1（目标）** 评估旧模板体系（4 基础模板 + 29 variant）与 JSON 体系兼容性，判定不兼容面
- **R2（目标）** 对不兼容面按用户选定档（领域段 JSON 承载 + 修门）做适应升级：schema 加可选字段承载 variant 领域段原文，render 附录吐出；修 VC-GATE 假绿 + V-N 真断
- **R3（手段）** 守住兼容红线：不动存量计划、不加 PreToolUse 硬门、软堵 render 全量覆盖不变、不改门的正当判据、不新增脚本/机器门

## Requirements（用户需求）
| id | type | text | vc | tags |
|---|---|---|---|---|
| R1 | 目标 | 评估旧模板体系（4 基础模板 + 29 variant）与 JSON 体系兼容性，判定不兼容面 | VC-1 | compat |
| R2 | 目标 | 对不兼容面按用户选定档（领域段 JSON 承载 + 修门）做适应升级：schema 加可选字段承载 variant 领域段原文，render 附录吐出；修 VC-GATE 假绿 + V-N 真断 | VC-2, VC-3, VC-4 | upgrade |
| R3 | 手段 | 守住兼容红线：不动存量计划、不加 PreToolUse 硬门、软堵 render 全量覆盖不变、不改门的正当判据、不新增脚本/机器门 | VC-5, VC-6 | redline |

## Goals（目标单元）
| id | text | evidence | tags |
|---|---|---|---|
| G1 | 完成旧模板体系与 JSON 体系三路取证并给出部分兼容结论与断裂清单 | findings.md 三路审计结论 |  |
| G2 | schema/planctl/init/render 全链支持 template_body 可选字段：init 写入 variant 领域段原文，render 以标题降级附录吐出 | tmp fixture 实测 |  |
| G3 | 修 VC-GATE 表格计数假绿 + V-N 映射真断；全量 selftest 零新增 FAIL + 四位部署 diff=0 + 存量 fixture 行为不变 | W6/W7 实弹 |  |

## 🎯 Goal 单元表
| goal-id | 任务名 | 目标 | 完整验证方式 | 对应 S-unit | 状态 |
|---|---|---|---|---|---|
| G1 | 兼容诊断 | 完成旧模板体系与 JSON 体系三路取证并给出部分兼容结论与断裂清单 | grep -c 'VC-1\\|VC-2\\|VC-3' verification.md（VC 表） + findings.md 取证结论行 | S1, S2 | in_progress |
| G2 | 领域段 JSON 承载 | schema/planctl/init/render 全链支持 template_body 可选字段：init 写入 variant 领域段原文，render 以标题降级附录吐出 | tmp 全链 init --template-body-from → render → grep 附录标题降级 + 权威锚未误判 | S3, S4, S5 | pending |
| G3 | 门控格式对齐 + 回归部署 | 修 VC-GATE 表格计数假绿 + V-N 映射真断；全量 selftest 零新增 FAIL + 四位部署 diff=0 + 存量 fixture 行为不变 | attest VC-GATE 正确计数 + check-complete 不拒锁 + selftest 双跑 + 四位 diff=0 | S6, S7, S8 | pending |

## Phases（阶段状态）
| id | status | s_units | v_checks | name | started | tags |
|---|---|---|---|---|---|---|
| P1 | complete | S1, S2 | VC-1 | 兼容诊断与计划 |  |  |
| P2 | complete | S3, S4, S5 | VC-2 | 领域段 JSON 承载实现 |  |  |
| P3 | complete | S6, S7 | VC-3, VC-4, VC-5 | 门控修复与回归验证 |  |  |
| P4 | complete | S8 | VC-6 | 收口部署 |  |  |

## R→VC 映射
| requirement | vcs |
|---|---|
| R1 | VC-1 |
| R2 | VC-2, VC-3, VC-4 |
| R3 | VC-5, VC-6 |
## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
| 工序 | 缺陷面 | 修复点 | VC |
|---|---|---|---|
| 本任务为机制兼容审计+升级 | 不适用（非结果级需求链；断裂面按 P0/P1 分级列 findings） | 按用户选定档逐项修复 | VC-2,VC-4 |

## ✅ Verification Contract（VC 状态与判据）
| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|---|---|---|
| VC-1 | 三路取证结论落 findings：旧模板体系与 JSON 部分兼容，三类断裂（variant 领域段丢失/VC-GATE 假绿/V-N 真断）逐条附证据行号 | grep -c 'P0\\|R-1\\|VC-GATE' /mnt/data/dev/task-planner-skill/plans/task-template-json-compat-20261122/findings.md | findings.md |
| VC-2 | schema+planctl+init+render 四处 template_body 链路打通，init --template-body-from 写入、render 标题降级附录吐出 | grep -c template_body /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/planctl.py /mnt/data/dev/task-planner-skill/skills/task-planner/schemas/plan-state.schema.json | worktree 4 文件 |
| VC-3 | tmp 全链实弹 5 项：4 MD GENERATED_HEADER + 领域附录标题降级 + VC-GATE 正确计数 + check-complete 不因 V-N 拒锁 + 51.1/66.5 未误判 | test -f /tmp/tjcompat-smoke/plans/task-smoke-001/task_plan.md && grep -c '勿直接编辑' /tmp/tjcompat-smoke/plans/task-smoke-001/task_plan.md | tmp smoke |
| VC-4 | attest VC-GATE 增认 render 表格行且保留旧 checklist 识别（存量红线）；V-N 由 phases[].v_checks 派生吐出 | grep -c 'VC-[0-9]' /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/attest-plan.sh | attest-plan.sh:313-328 |
| VC-5 | 全量 selftest 双跑（master vs worktree）FAIL 集零新增（基线 8 集） | bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/run-selftests.sh --fresh 2>&1 \| tail -3 | selftest 输出 |
| VC-6 | 四位部署逐文件 diff=0（base=家目录根，禁双重嵌套）+ 存量 fixture 行为不变 | cd /mnt/data/dev/task-planner-skill && git ls-files skills/task-planner \| while read f; do for base in /home/terry/.zcode/skills /home/terry/.agents/skills /home/terry/.claude/skills /home/terry/.cursor/skills; do cmp -s "$f" "$base/$f" \|\| { echo DIFF-$base/$f; exit 1; }; done; done && echo DEPLOY-DIFF-0 | 四位 cmp |

## 🔍 调研需求与检索计划
| unit | 三态(LOCAL-ONLY/NET-RESEARCH/NET-DATA-DEPENDENT) | 检索关键词 | 渠道 | 预期产出形态 |
|---|---|---|---|---|
| 全局 | LOCAL-ONLY | （无 NET-* 检索项；执行期新增外部调研须先 planctl set --section research_status 补登） | - | - |

## Phase 锚点明细（3file-gate/plan-dispatch 解析面）

### Phase 1: 兼容诊断与计划
- **Status:** complete
- **Started:** 
- **Executor:** general-purpose(sonnet)、main
- [x] V-1.1: VC-1（Phase 1 验证契约映射）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S1 | [P1] 三路取证结论汇总（三路取证结论汇总） | general-purpose(sonnet) | skills/task-planner | 实弹 exit 0 | 10min | single-file | 无 | - | pending |
| S2 | [P1] 计划目录 init + 专档逐字登记（计划目录 init + 专档逐字登记） | main | skills/task-planner | 实弹 exit 0 | 10min | single-file | 无 | - | pending |

### Phase 2: 领域段 JSON 承载实现
- **Status:** complete
- **Started:** 
- **Executor:** code-assistant(sonnet)
- [x] V-2.1: VC-2（Phase 2 验证契约映射）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S3 | [P2] schema+planctl template_body 字段（schema+planctl template_body 字段） | code-assistant(sonnet) | skills/task-planner | 实弹 exit 0 | 10min | single-file | 无 | - | pending |
| S4 | [P2] init-session 传参 + fmea 指引（init-session 传参 + fmea 指引） | code-assistant(sonnet) | skills/task-planner | 实弹 exit 0 | 10min | single-file | 无 | - | pending |
| S5 | [P2] render 领域附录 + V-N 映射（render 领域附录 + V-N 映射） | code-assistant(sonnet) | skills/task-planner | 实弹 exit 0 | 10min | single-file | 无 | - | pending |

### Phase 3: 门控修复与回归验证
- **Status:** complete
- **Started:** 
- **Executor:** code-assistant(sonnet)、general-purpose(sonnet)
- [x] V-3.1: VC-3（Phase 3 验证契约映射）
- [x] V-3.2: VC-4（Phase 3 验证契约映射）
- [x] V-3.3: VC-5（Phase 3 验证契约映射）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S6 | [P3] attest VC-GATE 表格计数（attest VC-GATE 表格计数） | code-assistant(sonnet) | skills/task-planner | 实弹 exit 0 | 10min | single-file | 无 | - | pending |
| S7 | [P3] 回归 selftest + tmp 全链 + 存量 fixture（回归 selftest + tmp 全链 + 存量 fixture） | general-purpose(sonnet) | skills/task-planner | 实弹 exit 0 | 10min | single-file | 无 | - | pending |

### Phase 4: 收口部署
- **Status:** complete
- **Started:** 
- **Executor:** general-ops(sonnet)
- [x] V-4.1: VC-6（Phase 4 验证契约映射）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S8 | [P4] merge + 四位部署 + 簿记（merge + 四位部署 + 簿记） | general-ops(sonnet) | skills/task-planner | 实弹 exit 0 | 10min | single-file | 无 | - | pending |

## 🧮 根源覆盖表
| 工序 | 缺陷面 | 修复点 | VC |
|---|---|---|---|
| 本任务为机制兼容审计+升级 | 不适用（非结果级需求链；断裂面按 P0/P1 分级列 findings） | 按用户选定档逐项修复 | VC-2,VC-4 |

## Decisions Made
| Decision | Rationale |
|---|---|
| 升级范围=领域段 JSON 承载 + 修门档（用户 AskUserQuestion 答复）；不采用骨架保留/系统级重建 | 破坏面 1-2 人日+守红线，符合文本优先铁律；领域段含门禁判据，纯文本附录只保文案不保机器语义（用户已知悉） |
| FMEA 真断甄别为数据缺口下的正当拒锁，非兼容缺陷；不改门，只在 init 指引补 fmea 登记提示 | 改门/开逃生口违反文本优先铁律与门判据不可降权原则 |
| 旧计划已终锁 feed8dbc+complete，hook 催回填不予执行；session-owner 用 mv 隔离释放 | 写入会破坏终锁（P0 反作弊）；新任务 dogfood 簿记全落新计划目录 |
