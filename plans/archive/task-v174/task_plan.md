# Task Plan: 排查并修正 test-quality-review 技能缺陷
<!-- ===== frontmatter 头 =====
   L0 微变更通道：≤3 文件 ∧ ≤20 行净变更 ∧ 变更性质=规范文本修订（Rule 38.7）
   技能文件=保护区 → 修正必须派子代理（mini/L0 直做通道对保护区永不放行）
   worktree 隔离不变（§十一） -->
template_type: general
plan_tier: standard
execution_lane: L0

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录）
- **R1**: 「排查质量检测技能中存在的缺陷」<sub>（[手段]）</sub>
- **R2**: 「主动分析其错误」<sub>（[手段]）</sub>
- **R3**: 「然后并进行修正」<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2）
| R | 映射 VC | 覆盖判据 |
|---|---------|---------|
| R1 | VC-1, VC-2 | description 与清单一致 + Rule 70① 在位 |
| R2 | VC-1, VC-2 | 同上 |
| R3 | VC-1~VC-5 | 全部 VC 通过 |

### 🗣️ 用户会话逐字记录（Rule 80）
- **专档路径**：`plans/task-v174/user-session-log.md`
- **只写不改铁律**：条目 append-only
- **恢复协议**：会话恢复先读专档

## 🧮 根源覆盖表（Rule 53.1）
| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 技能定义 | description 声称"十维度"但实际清单 14 条（遗漏越界自检/套件健康/覆盖度量/断言独立性） | 更新 description 使其与清单一致 | VC-1 |
| 技能定义 | 缺少 Rule 70① 审查对象总清单（general-review/code-quality-review/alignment-review 都有） | 添加审查对象总清单条目 | VC-2 |

## 🔒 不变量声明区（Rule 73.3）
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | Goal/VC 表/用户需求原文 R 条目 | task_plan.md |
| 🔀 可变量 | 执行细节/工序排期/S-unit 拆分 | - |
| 📈 学得量 | 执行期新事实/教训→findings.md | findings.md |

## Goal
排查 test-quality-review（测试质量审查技能）中存在的缺陷，主动分析其错误，然后进行修正。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（纯规范文本修订，L0 通道） |
| `session_id` | `sess_830b928c` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v174` |
| `scope_files` | `skills/task-planner/review-library/test-quality-review/SKILL.md` |
| `interaction_mode` | `silent` |
| `对齐审查` | `n/a`（L0 通道豁免 42.6.4） |
| `自动超时默认项` | `n/a`（L0 通道豁免 44.4） |
| `new_rule` | 留空 |
| `质量审查工具` | `n/a`（L0 通道豁免 42.5） |

## ✅ Verification Contract（目标完成判定标准）
| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | description 与实际清单一致（14 维度） | grep 检查 description 维度数与清单条数 | `grep -c '^- \[ \]' SKILL.md` = 14 且 description 含全部维度或"十四维度" |
| VC-2 | 包含 Rule 70① 审查对象总清单 | grep 检查 | `grep '审查对象总清单' SKILL.md` ≥1 |
| VC-3 | selftest-review-library.sh 全 PASS | 运行脚本 | `bash selftest-review-library.sh` exit 0（RL-01~RL-15） |
| VC-4 | 部署位与源一致 | diff | `diff 源 部署位` = 0 |
| VC-5 | 无回归（其他 review 技能不受影响） | 全仓 selftest | 无新增 FAIL |

**终验规则**：全部 VC 通过 → COMPLETE

## 🎯 核心目标达成裁决（Rule 58.5）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R3 |
| **裁决** | `solved` |
| **解决证据锚** | VC-1~VC-5 全通过 |
| **未解决面+原因** | n/a |
| **已排除路径** | n/a |
| **下一步建议** | n/a |

## 🎯 Goal 单元表（Rule 66.1）
| goal-id | 任务名 | 目标 | 完整验证方式 | 对应 S-unit/Phase | 状态 |
|---------|--------|------|-------------|------------------|------|
| G1 | 修正缺陷 | 更新 description + 添加 Rule 70① | grep 检查 + selftest | S1/Phase 1 | pending |

## ⚠️ 执行范围限制（强制）
| 类别 | 允许的文件 | 禁止 |
|------|-----------|------|
| 源码 | `skills/task-planner/review-library/test-quality-review/SKILL.md` | 其他文件 |
| 测试 | n/a | 其他测试 |
| 配置 | n/a | 其他配置 |
| 文档 | n/a | 其他文档 |

**执行前自我检查:**
- [x] 这个文件在上面的列表中吗？是
- [x] 这个修改对完成任务有必要吗？是
- [x] 用户明确要求我做这个修改吗？是

## 📋 变更标注表（Rule 74.3）
| 编号 | 对象（文件+锚点） | 类型 | 吸收判定 | 依据 | 执行动作 |
|------|------------------|------|---------|------|---------|
| CA-1 | test-quality-review/SKILL.md:3 (description) | 修改 | 替代 | 缺陷 1：description 与清单不一致 | 更新 description 使其与 14 条清单一致 |
| CA-2 | test-quality-review/SKILL.md:43-48 (输出合约) | 新增 | 增量 | 缺陷 2：缺少 Rule 70① | 添加审查对象总清单条目 |

## 📚 必要知识储备
| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|-----------|------|---------|--------|
| 规范/标准 | Rule 70① 审查对象总清单 | general-review/SKILL.md:45 | 必读 | ☑ |
| 项目内部文档 | test-quality-review 源文件 | skills/task-planner/review-library/test-quality-review/SKILL.md | 必读 | ☑ |
| 项目内部文档 | selftest-review-library.sh | skills/task-planner/scripts/selftest-review-library.sh | 参考 | ☑ |

## ⚠️ 核心问题定义
**核心问题**: test-quality-review 技能存在 2 个缺陷（description 与清单不一致 + 缺少 Rule 70①），修正后技能定义与实际清单一致且符合 review 族规范。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？是
- [x] 核心问题不解决，其他工作都白费吗？是（技能定义不一致会导致审查遗漏）
- [x] 核心问题的解决方法是清晰的、可执行的？是（更新 description + 添加 Rule 70①）

## 🔍 调研需求与检索计划（Rule 75.1）
| S-unit/子目标 | 三态 | 检索关键词 | 检索渠道 | 预期产出形态 | 网络解难评估 |
|---------------|------|-----------|---------|-------------|------------|
| S1 | LOCAL-ONLY | test-quality-review, Rule 70① | 本地文件 | findings 小节 | 否 |

## 🔍 证据面清单（Rule 58.1）
| 证据面 | 取证对象 | 取证方式 | 落盘锚 | 状态 |
|--------|---------|---------|--------|------|
| ① 自身样本 | test-quality-review/SKILL.md | Read | 已完成 | ☑ |
| ② 对标样本 | general-review/SKILL.md, code-quality-review/SKILL.md | Read | 已完成 | ☑ |
| ③ 外部约束 | Rule 70① | grep | 已完成 | ☑ |

## Current Phase
Phase 1

## Next Step
派 code-assistant 在 worktree 中修正 2 个缺陷（更新 description + 添加 Rule 70①）

## 🧰 工具选择与编排（Rule 40）
| Phase | 命中工具面 | 选择理由 |
|-------|-----------|---------|
| Phase 1 | Agent 子代理 code-assistant | 技能文件是保护区，必须派子代理 |

**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 的证据源

## Phases
### Phase 1: 缺陷修正与验证
- [x] 派 code-assistant 在 worktree 中修正 2 个缺陷
- [x] 运行 selftest-review-library.sh 验证
- [x] 部署并验证
- **V-N:** VC-1, VC-2, VC-3, VC-4, VC-5
- **Status:** complete
- **Executor:** code-assistant（haiku-1）

S-unit 派发单元表（Rule 22.6）:
| ID | 目标 | 执行体 | 输入 | 验收 | 预估时长 | 粒度 | 伴飞技能 | 前置依赖 | 状态 |
|----|------|--------|------|------|---------|------|---------|---------|------|
| S1 | 修正 description | 继承 | SKILL.md + 缺陷清单 | description 与清单一致 | ≤15min | 1f/10l/15min | 无 | - | pending |
| S2 | 添加 Rule 70① | 继承 | SKILL.md + general-review 参考 | Rule 70① 在位 | ≤15min | 1f/5l/15min | 无 | S1 | pending |
| S3 | 验证与部署 | 继承 | worktree 路径 | selftest PASS + 部署一致 | ≤15min | 1f/10l/15min | 无 | S2 | pending |

## 🔀 隔离决策（冲突分析）
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号①/③，不与任务范围重叠） |
| `isolation` | `worktree` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v174` |
| `branch` | `wt/task-v174` |
| `merge_back` | `pending` |

## 📊 FMEA 预演
| Phase | 失败模式 | S | O | D | RPN | 预设兜底动作 |
|-------|---------|---|---|---|-----|-------------|
| Phase 1 | 子代理修正错误 | 3 | 2 | 2 | 12 | 主进程 Read 复核 |

## 🔁 原生 Todo 同步（S1–S5）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|-------------|------|
| Phase 1 | ☐ | | |

## Key Questions
1. 缺陷清单是否完整？
2. 修正方案是否正确？

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 用 L0 通道 | ≤3 文件 ≤20 行，规范文本修订（Rule 38.7） |
| 派 code-assistant | 技能文件是保护区，必须派子代理 |
| worktree 隔离 | §十一 要求 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention |
|-------|---------|------------|------------|
| | 1 | | |

## Notes
- Update phase status as phases complete

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| | | | |
