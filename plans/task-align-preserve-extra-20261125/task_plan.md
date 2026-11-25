<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Task Plan: task-align-preserve-extra-20261125

- task_id: `task-align-preserve-extra-20261125`
- 时间: created_at=2026-11-24T23:58:46Z / updated_at=2026-11-25T00:08:10Z
plan_tier: standard
execution_lane: L1
schema_version: 1
- 顶层 tags: （无）

## 🎯 用户需求原文
- **R1（目标）** 用户原话：对齐女钓手规范时小说层被恶意丢弃；当前skill重大缺陷必须纠正
- **R2（手段）** 新增 Rule 114 对齐任务内容保真铁律（参照规范非内容白名单/差异三分型/保留资产零丢失VC）+ selftest 静态断言

## Requirements（用户需求）
| id | type | text | vc | tags |
|---|---|---|---|---|
| R1 | 目标 | 用户原话：对齐女钓手规范时小说层被恶意丢弃；当前skill重大缺陷必须纠正 |  |  |
| R2 | 手段 | 新增 Rule 114 对齐任务内容保真铁律（参照规范非内容白名单/差异三分型/保留资产零丢失VC）+ selftest 静态断言 |  |  |

## Goals（目标单元）
| id | text | evidence | tags |
|---|---|---|---|

## 🎯 Goal 单元表
| goal-id | 任务名 | 目标 | 完整验证方式 | 对应 S-unit | 状态 |
|---|---|---|---|---|---|

## Phases（阶段状态）
| id | status | s_units | v_checks | name | started | tags |
|---|---|---|---|---|---|---|

## R→VC 映射
| requirement | vcs |
|---|---|
| R1 |  |
| R2 |  |
## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
| 工序 | 缺陷面 | 修复点 | VC |
|---|---|---|---|
| （root_causes 未登记） | 结果级需求须 planctl add --section root_causes 逐工序补登；非结果级任务在本行写「不适用（非结果级）」+定性理由 | - | - |

## ✅ Verification Contract（VC 状态与判据）
| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|---|---|---|
| VC1 | 新断言 selftest-alignment-preserve.sh 全部 PASS | bash skills/task-planner/scripts/selftest-alignment-preserve.sh |  |
| VC2 | 全量 selftest 零新增 FAIL | bash skills/task-planner/scripts/run-selftests.sh --fresh |  |
| VC3 | verify.sh 0 fail | TASK_PLANNER_ROOT=$PWD/skills/task-planner bash skills/task-planner/lib/verify.sh |  |

## 🧩 输出示例与格式契约（Rule 113）
（尚未登记 output_examples —— Rule 113.1：凡声明输出格式的交付物必须给出完整示例+可复用模板，经 `planctl add --section output_examples` 登记；无格式交付物须显式写 none-justified 并附理由）

## 🔍 调研需求与检索计划
| unit | 三态(LOCAL-ONLY/NET-RESEARCH/NET-DATA-DEPENDENT) | 检索关键词 | 渠道 | 预期产出形态 |
|---|---|---|---|---|
| 全局 | LOCAL-ONLY | （无 NET-* 检索项；执行期新增外部调研须先 planctl set --section research_status 补登） | - | - |

## Next Step
全量回归 + 合并回 master + 清理 worktree

## 🧹 收尾对齐与清理（交付前必填）
| 类别 | 检查项 | 判据 | 证据 |
|---|---|---|---|
| 对齐 | 口径计数 / 冲突条款 / 行数快照 | 冲突锚 grep 无本任务新增命中 | progress `[align-final]` 行 |
| 清理 | Skill 说明 Markdown 中的历史旁注 / 过期注 / 残留物；代码文件注释不在清理范围、受保护 | 本任务新增痕迹注为 0（代码注释不计入） | progress `[cleanup-final]` 行 |

范围：只清会被 Agent 读进上下文的 Skill 说明文件；代码文件（.py/.sh/.ts 等）里的注释属保护对象，禁止清理。执行时机：outcome 判定之前、合并回动作之前；mini / L0-lite 档豁免本板块。
