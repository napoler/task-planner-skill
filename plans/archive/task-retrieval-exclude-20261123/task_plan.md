<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Task Plan: task-retrieval-exclude-20261123

- task_id: `task-retrieval-exclude-20261123`
- 时间: created_at=2026-11-22T19:45:57Z / updated_at=2026-11-22T19:52:14Z
plan_tier: standard
execution_lane: L2
schema_version: 1
- 顶层 tags: （无）

## 🎯 用户需求原文

## Requirements（用户需求）
| id | type | text | vc | tags |
|---|---|---|---|---|

## Goals（目标单元）
| id | text | evidence | tags |
|---|---|---|---|

## 🎯 Goal 单元表
| goal-id | 任务名 | 目标 | 完整验证方式 | 对应 S-unit | 状态 |
|---|---|---|---|---|---|

## Phases（阶段状态）
| id | status | s_units | v_checks | name | started | tags |
|---|---|---|---|---|---|---|
| P1 | complete |  | VC-1, VC-2, VC-3, VC-4 | 检索排除清单机制落地 |  |  |

## R→VC 映射
| requirement | vcs |
|---|---|
## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
| 工序 | 缺陷面 | 修复点 | VC |
|---|---|---|---|
| （root_causes 未登记） | 结果级需求须 planctl add --section root_causes 逐工序补登；非结果级任务在本行写「不适用（非结果级）」+定性理由 | - | - |

## ✅ Verification Contract（VC 状态与判据）
| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|---|---|---|
| VC-1 | 清单文档存在且含条件化表格(可排除/必须纳入两栏)+trash条目+维护日志 | test -f /mnt/data/dev/task-planner-skill/RETRIEVAL_EXCLUDE.md && grep -q 可排除场景 /mnt/data/dev/task-planner-skill/RETRIEVAL_EXCLUDE.md && grep -q 必须纳入场景 /mnt/data/dev/task-planner-skill/RETRIEVAL_EXCLUDE.md && grep -q trash /mnt/data/dev/task-planner-skill/RETRIEVAL_EXCLUDE.md && echo PASS |  |
| VC-2 | Rule 112 六子条全文在 critical-rules.md | f=/mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md; for n in 112.1 112.2 112.3 112.4 112.5 112.6; do grep -q "^$n " "$f" \|\| exit 1; done; echo PASS |  |
| VC-3 | SKILL.md 摘要含 Rule 112 指针且数字索引未改 | grep -q "检索排除清单纪律" /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && grep -q "Rules 1-110" /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && echo PASS |  |
| VC-4 | 5部署位 SKILL.md+critical-rules.md 全部含112锚且diff一致 | for d in /mnt/data/dev/task-planner-skill/skills/task-planner /home/terry/.zcode/skills/task-planner /home/terry/.claude/skills/task-planner /home/terry/.config/opencode/skills/task-planner /home/terry/.cursor/skills/task-planner /home/terry/.agents/skills/task-planner; do grep -q 检索排除清单纪律 "$d/SKILL.md" \|\| exit 1; grep -q "^112.1 " "$d/references/critical-rules.md" \|\| exit 1; done; echo PASS |  |

## 🔍 调研需求与检索计划
| unit | 三态(LOCAL-ONLY/NET-RESEARCH/NET-DATA-DEPENDENT) | 检索关键词 | 渠道 | 预期产出形态 |
|---|---|---|---|---|
| 全局 | LOCAL-ONLY | （无 NET-* 检索项；执行期新增外部调研须先 planctl set --section research_status 补登） | - | - |

## Phase 锚点明细（3file-gate/plan-dispatch 解析面）

### Phase 1: 检索排除清单机制落地
- **Status:** complete
- **Started:** 
- **Executor:** -
- [x] V-1.1: VC-1（Phase 1 验证契约映射）
- [x] V-1.2: VC-2（Phase 1 验证契约映射）
- [x] V-1.3: VC-3（Phase 1 验证契约映射）
- [x] V-1.4: VC-4（Phase 1 验证契约映射）

## Decisions Made
| Decision | Rationale |
|---|---|
| 范围=skill规则(全局)+当前项目清单文档 | 用户定案 |
| 初始排除项仅trash/(沿用Rule 100.6)，清单支持后续维护 | 用户定案 |
| 纯文本L0-T文本锚、零新脚本/hook/config | 用户定案+宪法§二文本优先铁律 |
| 规则落顶层Rule 112(跨多域每轮可见)，100.6原文不改 | 跨检索/调研/执行多域,Rule36.5纯增量 |
| 清单名RETRIEVAL_EXCLUDE.md置项目根 | 英文名便于grep,与.gitignore呼应 |
| worktree wt/task-retrieval-exclude-20261123基线master@579c59b | 宪法§十一保护区强制隔离 |
| 实测5部署位全同步(.zcode/.claude/.config-opencode/.cursor/.agents) | 纠正计划里3处说法,契合全局生效无漂移 |
| D类切换:旧计划task-align-mandatory-step Goal无关,挂起+释放owner+切指针 | Rule102.1 D类新任务边界 |
