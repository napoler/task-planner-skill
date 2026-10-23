# Task Plan: Rule 94 部署位同步（task-planner+task-discipline → zcode/cursor）
<!-- frontmatter（Rule 16/34.1/38.7） -->
template_type: deployment
plan_tier: standard
execution_lane: L1

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「1」<sub>（[目标]）</sub>——对上任务交付总结「下一步建议①部署位同步」的序号授权（语义授权=执行同步；原话上下文锚=plans/archive/task-focus-plan-split-20261023/delivery 与 user-session-log）

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2, VC-3 | 14 文件 diff=0+部署位 Rule 94 锚在位+运行态零触碰 |

### 🗣️ 用户会话逐字记录（Rule 80 — 专档指针）
- **专档路径**：`plans/task-deploy-rule94-20261023/user-session-log.md`（#1 已落，append-only）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

不适用（非结果级需求）：R1 为单点机械部署动作（同步已 CR 的既成产物），无「确保质量/性能/可靠」类结果级诉求需分解工序审计；质量由 diff=0 与 grep 锚（VC-1/2/3）直接承载。

## Goal
将 dev 仓 master（c9d709a）中 task-planner 与 task-discipline 的 7 个本任务改动文件同步到 ~/.zcode/skills 与 ~/.cursor/skills 两个部署位（用户显式授权「1」），部署位 Rule 94 生效且运行态文件零触碰；cursor 既有 6 文件漂移（task-v187 遗留）不在射程、只报告。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（机械部署+diff=0 机器验证） |
| `session_id` | `deploy-rule94-b2c4` |
| `worktree_path` | n/a（部署写=仓外保护区，用户已显式授权；dev 仓零代码变更，无需 §十一 worktree） |
| `scope_files` | `~/.zcode/skills/{task-planner,task-discipline}/ 下 7 文件、~/.cursor/skills/{task-planner,task-discipline}/ 下 7 文件` |
| `interaction_mode` | `ask` |
| `对齐审查` | n/a（部署同步无文档创作） |
| `自动超时默认项` | `[询问点: 无新增分叉点]` |
| `new_rule` | 留空 |
| `质量审查工具` | diff -rq + grep 锚（既有工具） |

## ✅ Verification Contract（目标完成判定标准）

> **验证独立性**：部署 diff 验证为机器 diff（非主进程自测口径）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 7 文件 ×2 部署位与 dev 仓 master 逐字一致 | diff 逐文件 | `for f in <7文件>: diff -q src dst` 全部静默（diff=0） |
| VC-2 | 部署位 Rule 94 锚在位（两位置） | grep | `grep -c "^### 94 任务专注性与计划隔离" <部署位>/references/critical-rules-discipline.md`=1（×2）；`grep -c "确认切换后的处置（Rule 94" <部署位>/task-planner/SKILL.md`=1（×2） |
| VC-3 | 部署位运行态与射程外文件零触碰 | diff -rq 全目录 | zcode 剩余差异=0 条；cursor 剩余差异=既有 6 文件+运行态目录（数量不多不少） |
| VC-4 | 计划归档完成 | archive 目录 | `plans/archive/task-deploy-rule94-20261023/` 在位 |

**终验规则**：全部 VC 通过 → COMPLETE；任一失败 3 次重试无效 → BLOCKED。

## 🎯 核心目标达成裁决（Rule 58.5）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1 |
| **裁决** | 终验填（预期 solved） |
| **解决证据锚** | 终验填 |
| **未解决面+原因** | — |
| **已排除路径** | — |
| **下一步建议** | cursor 既有 6 文件漂移全量对齐（另行授权） |

## 🎯 Goal 单元表（Rule 66.1）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式 | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|----------------|------------------|------|
| G1 | 漂移预检 | 部署位漂移清单定界（7+6 文件） | diff -rq 输出落 findings | S1/Phase 1 | complete |
| G2 | 同步执行 | 7×2=14 文件 cp 同步 | cp 命令清单+退出码 | S2/Phase 2 | complete（CP_RC=0+diff=0） |
| G3 | 验证收口 | VC-1/2/3 全 PASS+归档 | diff/grep 证据+archive 在位 | S3/Phase 3 | complete（0/0/6/0+4 锚） |

## ⚠️ 执行范围限制（强制）
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 部署位写入 | ~/.zcode/skills/{task-planner,task-discipline}/ 与 ~/.cursor/skills/{task-planner,task-discipline}/ 下指定 7 文件 | 部署位其他文件（.drift-rhythm、install.log、既有 6 漂移文件）；~/.agents/skills（无此二者，不创建） |
| dev 仓 | plans/task-deploy-rule94-20261023/ | dev 仓其他文件（skills/ 零改动——部署源只读） |

## 📋 变更标注表（Rule 74.3）
| 编号 | 对象（文件+锚点） | 类型 | 吸收判定 | 用户原话（逐字） | 依据 | 执行动作 |
|------|------------------|------|---------|----------------|------|---------|
| CA-1 | ~/.zcode/skills/task-planner/{SKILL.md,references/critical-rules.md,README.md,docs/ARCHITECTURE.md} | 更新 | 替代（部署位旧版被已 CR 的 master 版覆盖；替代四条件：master 已 CR APPROVED+覆盖完整+同步前 diff 已 Read 报告+selftest 已绿） | 「1」 | 侦察 diff 清单（findings §1） | cp 覆盖 |
| CA-2 | ~/.zcode/skills/task-discipline/{SKILL.md,references/critical-rules-discipline.md,references/execution-recall-card.md} | 更新 | 替代（同上） | 「1」 | 同上 | cp 覆盖 |
| CA-3 | ~/.cursor/skills/ 下同 7 文件 | 更新 | 替代（同上） | 「1」 | 侦察 diff 清单 | cp 覆盖 |

## 📚 必要知识储备（任务知识库对齐）
| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|-----------|------|---------|--------|
| 项目内部 | 判例 task-kb-deploy-20261022（部署 SOP+混合状态只补不覆盖） | plans/archive/task-kb-deploy-20261022/ | 参考 | ☑ |
| 项目内部 | 漂移侦察结论 | 本计划 findings §1 | 必读 | ☑ |

## ⚠️ 核心问题定义
**核心问题**: dev 仓 Rule 94 成果未生效于部署位——同步后部署位即与 master 一致，新会话加载即生效。三问：交付吗（是，diff=0 可验）/不解决则白费（是）/方法清晰（是，机械 cp+diff）。

## 🔍 调研需求与检索计划（Rule 75.1）
| S-unit | 三态 | 检索关键词 | 渠道 | 预期产出 | 网络解难评估 |
|--------|------|-----------|------|---------|--------------|
| S1 漂移预检 | LOCAL-ONLY | diff -rq 部署位 | 本机 diff | findings §1 | 不适用 |
| S2-S3 | LOCAL-ONLY | cp/diff/grep | 本机 | 文件+证据 | 不适用 |

## 🔍 证据面清单（Rule 58.1）
n/a（纯执行类——机械部署，无归因/评估结论产出）。

## Current Phase
全部 Phase complete（终验交付）

## Next Step
漂移预检落 findings → attest 锁定 → 同步 14 文件 → diff 验证 → 归档

## 🧰 工具选择与编排（Rule 40）
| Phase | 命中工具面 | 选择理由 |
|-------|-----------|---------|
| Phase 1 | 主进程（侦察+计划） | 机械 diff 判读+计划编排 |
| Phase 2 | 主进程（git 编排/部署白名单①——机械 cp 14 文件派发开销>收益，Rule 25.3①） | 机械复制+退出码验证 |
| Phase 3 | 主进程（簿记②） | diff/grep 证据+归档 |

## Phases

### Phase 1: 漂移预检（侦察+计划定稿）
- [x] 部署位布局侦察（zcode/cursor 各含两技能；~/.agents/skills 无）
- [x] 漂移面定界（zcode 7 文件+运行态；cursor 7+既有 6 文件）
- [x] 计划定稿+用户授权逐字落盘（#1）
- **V-N:** VC-3（预检基线=cursor 既有 6 文件记录）, VC-1（预检清单）
- **Status:** complete
- **Executor:** 主进程（侦察+规划，白名单② 簿记）

| ID | 目标(≤1 句) | 执行体 | 输入 | 验收 | 预估时长 | 粒度 | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|--------|------|------|---------|------|------|------|------|
| S1 | 部署位漂移清单定界 | 主进程（白名单②） | 两部署位 diff -rq 输出 | findings §1 含 7+6 清单 | 10min | 0f/0l/10min | 无 | - | done |

### Phase 2: 同步执行（14 文件 cp）
- [x] 7 文件 ×2 位 cp 覆盖（源=dev 仓 master；CP_RC=0，14/14 diff=0）
- **V-N:** VC-1, VC-2
- **Status:** complete
- **Executor:** 主进程（① git 编排/部署白名单——机械 cp，派发开销>收益，例外登记）

| ID | 目标(≤1 句) | 执行体 | 输入 | 验收 | 预估时长 | 粒度 | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|--------|------|------|---------|------|------|------|------|
| S2 | 14 文件同步+即时 diff 验证 | 主进程（白名单①） | dev 仓 7 文件 ×2 位 | cp rc=0+diff=0 | 10min | 0f/0l/10min | 无 | S1 | pending |

### Phase 3: 验证收口+归档
- [x] VC-1/2/3 逐项验证+progress 回填（VC-2 锚 4/4；VC-3 残余 0/0/6/0 恰=基线）
- [x] check-complete+清指针+归档（本勾选随当轮执行）
- **V-N:** VC-2, VC-3, VC-4
- **Status:** complete
- **Executor:** 主进程（② 簿记白名单）

| ID | 目标(≤1 句) | 执行体 | 输入 | 验收 | 预估时长 | 粒度 | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|--------|------|------|---------|------|------|------|------|
| S3 | 验证+归档+交付 | 主进程（白名单②） | 部署位 | VC 全 PASS+archive 在位 | 10min | 0f/0l/10min | 无 | S2 | pending |

## 🔀 隔离决策
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（部署位写=用户显式授权的仓外操作；dev 仓零代码变更） |
| `isolation` | `direct`（部署同步无 dev 仓实现面变更；worktree 无意义） |
| `worktree_path` | n/a |
| `branch` | n/a |
| `merge_back` | n/a |

## 📊 FMEA 预演
| Phase | 失败模式 | S | O | D | RPN | 兜底 |
|-------|---------|---|---|---|-----|------|
| Phase 2 | cp 误覆盖运行态文件 | 6 | 2 | 2 | 24 | 白名单逐文件 cp（非目录级 cp -r），路径逐字核对 |
| Phase 3 | cursor 剩余差异计数对不上（误伤既有漂移） | 5 | 3 | 3 | 45 | 以侦察清单为基线对照（6 文件+运行态，不多不少） |

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-23 | S1 |
| Phase 2 | ☑ | 2026-10-23 | S1 |
| Phase 3 | ☑ | 2026-10-23 | S1 |

## Key Questions
1. cursor 既有 6 文件漂移是否顺手同步？→ 否（射程外；「1」授权语义=建议①即 Rule 94 文件面；混合状态只补不覆盖判例；另报待授权）
2. ~/.agents/skills 是否创建？→ 否（该位无此二技能，创建=范围扩张）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 只同步 7 文件不动 cursor 既有 6 漂移 | 用户授权射程=Rule 94 文件面；Rule 88 射程契约+「混合状态只补不覆盖」判例 |
| 文件级 cp 非目录级 | 保部署位运行态（.drift-rhythm/install.log）与本地独有文件 |
| D1 按 44.3 自动通过 | 用户已显式授权本动作（「1」）；机械部署无真分叉 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention |
|-------|---------|------------|-----------|
|      | 1       |            | → progress.md Error Log |

## Notes
- Update phase status as you progress; Log ALL errors

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |         |        |      |

## 📊 委派统计（Rule 25.4）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 0 / 3 |
| 主进程直做 Phase 清单 | Phase 1-3（例外理由：② 簿记侦察/① 机械 cp 部署编排/② 簿记验证——Rule 25.3 白名单；L0-E 口径=零 dev 仓受管变更，产物落仓外部署位） |
| 委派率 | 0（机械部署任务，全 Phase 命中白名单例外+纯执行口径；预期 stats 判定见终验） |

## 🔗 Subagent Handoff 登记表
| # | 时间 | subagent_type | 任务目标 | 状态 | 结论摘要 | 证据 | findings 落点 | checkpoint 路径 | 备注 |
|---|------|--------------|---------|------|---------|------|--------------|----------------|------|
| 1 | - | - | 无派发（全白名单直做） | - | - | - | - | - | - |

## 🔁 模板感知
<!-- template_type: deployment -->
- 触发信号: deployment 变体命中（部署同步任务）
- Rule 34.3②: 沉淀评估=deployment 变体既有在位，无需沉淀
- 处置登记处: 不沉淀理由=变体既有在位
