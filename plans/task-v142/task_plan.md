# Task Plan: 新增 Rule 57 — 周期性回顾与前后对照

## 🎯 用户需求原文（Rule 51.1）

- **R1**: 「周期性地回顾一下这些信息，梳理一下这些信息。当然说梳理信息也是有好处的，有可能会你在后面发现做着做着，哎，前面哪里做错了，可以回去就是回去那回去嘛」
- **R2**: 「通过回顾的方式，然后去反向的，然后去发现第二步做错了，然后去反向的反推出来再确定，然后再纠正，然后再回去」
- **R3**: 「别让太多的那些乱七八糟的杂志，就是说各种噪声的引入，导致整个的任务的偏移太严重」
- **R4**: 「前后对照，确保有问题」

### R→VC 映射（Rule 51.2）
| R | 映射 VC | 覆盖判据 |
|---|---------|---------|
| R1 | VC-1 | Rule 57 条款存在且含周期性回顾触发机制 |
| R2 | VC-2 | 前后对照检查维度存在且含反向纠正机制 |
| R3 | VC-3 | 开关键存在且默认 warn |
| R4 | VC-4 | selftest 脚本存在且守护 Rule 57 条款 |

## 🧮 根源覆盖表（Rule 53.1）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 规则定义 | 现有 Rule 11/15 是事件驱动，缺少周期性强制回顾 | 新增 Rule 57 定义 | VC-1 |
| 脚本实现 | 缺少前后结论一致性检查脚本 | 新增 periodic-review.sh | VC-2 |
| 守护脚本 | 缺少 Rule 57 的 selftest 守护 | 新增 selftest-periodic-review.sh | VC-4 |
| 配置 | 缺少开关键控制 | config.json 新增 2 个开关键 | VC-3 |

## Goal

为 task-planner 技能新增 Rule 57 — 周期性回顾与前后对照机制，实现长任务执行中的周期性强制回顾、前后结论一致性检查和自动纠正。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a` |
| `session_id` | `afd0b28ec78a4e8ca9f0acde60eeaaf7` |
| `worktree_path` | n/a |
| `scope_files` | `skills/task-planner/references/critical-rules.md, skills/task-planner/scripts/periodic-review.sh, skills/task-planner/scripts/selftest-periodic-review.sh, skills/task-planner/config.json, skills/task-planner/SKILL.md, skills/task-planner/scripts/selftest-registry.tsv` |
| `interaction_mode` | `silent` |
| `new_rule` | `57` |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 57 条款存在且含周期性回顾触发机制 | `grep -c '### 57' critical-rules.md` | `skills/task-planner/references/critical-rules.md` |
| VC-2 | 前后对照检查维度存在且含反向纠正机制 | `grep -c '前后对照' critical-rules.md` | `skills/task-planner/references/critical-rules.md` |
| VC-3 | 开关键存在且默认 warn | `jq '.properties.periodic_review_enforce.default' config.json` | `skills/task-planner/config.json` |
| VC-4 | selftest 脚本存在且守护 Rule 57 条款 | `bash selftest-periodic-review.sh` | `skills/task-planner/scripts/selftest-periodic-review.sh` |
| VC-5 | 无回归破坏 | `bash check-complete.sh plans/task-v142` | `skills/task-planner/scripts/check-complete.sh` |

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 文档 | `skills/task-planner/references/critical-rules.md` | 其他 .md 文件 |
| 脚本 | `skills/task-planner/scripts/periodic-review.sh`, `skills/task-planner/scripts/selftest-periodic-review.sh` | 其他 .sh 文件 |
| 配置 | `skills/task-planner/config.json` | 其他配置文件 |
| 文档 | `skills/task-planner/SKILL.md` | 其他 .md 文件 |
| 配置 | `skills/task-planner/scripts/selftest-registry.tsv` | 其他配置文件 |

## 📚 必要知识储备

| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|-----------|------|---------|--------|
| 项目内部文档 | critical-rules.md Rule 11/15/33 | `skills/task-planner/references/critical-rules.md` | 必读 | ☐ |
| 项目内部文档 | task-drift-guard SKILL.md | `skills/task-drift-guard/SKILL.md` | 参考 | ☐ |
| 项目内部文档 | selftest-reflect-verify.sh | `skills/task-planner/scripts/selftest-reflect-verify.sh` | 参考 | ☐ |

## ⚠️ 核心问题定义

**核心问题**: 长任务执行中缺少周期性回顾和前后对照机制，导致错误累积无法及时发现和纠正。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？— 是，Rule 57 落地后长任务可周期性回顾
- [x] 核心问题不解决，其他工作都白费吗？— 是，错误结论会累积导致后续全部偏离
- [x] 核心问题的解决方法是清晰的、可执行的？— 是，新增 Rule 57 + 脚本 + selftest

## Current Phase

Phase 1

## Next Step

编写 Rule 57 完整条款并追加到 critical-rules.md 末尾

## 🧰 工具选择与编排

| Phase | 命中工具面 | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 code-assistant(haiku-1) | 单文件追加，≤300 行 |
| Phase 2 | Agent 子代理 code-assistant(haiku-1) | 单文件创建，≤300 行 |
| Phase 3 | Agent 子代理 code-assistant(haiku-1) | 单文件创建，≤300 行 |
| Phase 4 | Agent 子代理 code-assistant(haiku-1) | 单文件修改，≤300 行 |
| Phase 5 | 主进程（例外理由:① git 编排+② 簿记） | 验证和交付 |

## Phases

### Phase 1: 新增 Rule 57 到 critical-rules.md
- [ ] 在 Rule 56 之后追加 Rule 57 完整条款
- [ ] 确认条款含触发时机、执行步骤、前后对照检查维度、自动纠正机制、开关键
- **V-N:** VC-1, VC-2
- **Status:** in_progress
- **Executor:** code-assistant（haiku-1）

### Phase 2: 新增 periodic-review.sh 脚本
- [ ] 创建脚本，实现结论一致性检测
- [ ] 输出结构化报告（JSON）
- **V-N:** VC-2, VC-4
- **Status:** pending
- **Executor:** code-assistant（haiku-1）

### Phase 3: 新增 selftest-periodic-review.sh 守护脚本
- [ ] 创建守护脚本，断言 Rule 57 条款完整性
- [ ] 注册到 selftest-registry.tsv
- **V-N:** VC-4, VC-5
- **Status:** pending
- **Executor:** code-assistant（haiku-1）

### Phase 4: 修改 config.json 和 SKILL.md
- [ ] config.json 新增 periodic_review_enforce 和 periodic_review_interval_calls
- [ ] SKILL.md 新增 C39 引用
- **V-N:** VC-3, VC-5
- **Status:** pending
- **Executor:** code-assistant（haiku-1）

### Phase 5: 验证与交付
- [ ] 运行 selftest-periodic-review.sh 确认所有断言通过
- [ ] 运行 check-complete.sh 确认无回归
- [ ] 交付总结
- **V-N:** VC-1, VC-2, VC-3, VC-4, VC-5
- **Status:** pending
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe` |
| `isolation` | `direct`（纯文档/脚本修改，不涉及运行中基础设施） |
| `worktree_path` | n/a |
| `branch` | n/a |
| `merge_back` | n/a |

## 📊 FMEA 预演

| Phase | 失败模式 | S | O | D | RPN | 预设兜底动作 |
|-------|---------|---|---|---|-----|-------------|
| Phase 1 | Rule 57 条款与现有 Rule 冲突 | 3 | 2 | 2 | 12 | 无 |
| Phase 2 | 脚本语法错误 | 4 | 2 | 1 | 8 | 无 |
| Phase 3 | selftest 断言失败 | 3 | 2 | 1 | 6 | 无 |
| Phase 4 | config.json JSON 格式错误 | 5 | 1 | 1 | 5 | 无 |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ | | |
| Phase 2 | ☐ | | |
| Phase 3 | ☐ | | |
| Phase 4 | ☐ | | |
| Phase 5 | ☐ | | |

## Key Questions

1. Rule 57 的触发频率默认值设为多少？— 默认 8 次工具调用
2. 前后对照检查的范围？— 结论一致性 + 假设一致性
3. 发现矛盾时的处理方式？— 自动纠正 + 报告用户

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 触发频率默认 8 次工具调用 | 与 Rule 15 的每 2-3 个 todo 互补，不过于频繁 |
| 前后对照检查结论一致性 | 用户明确选择 |
| 自动纠正 + 报告用户 | 用户明确选择 |
| 开关键默认 warn | 与其他 Rule 保持一致 |

## Errors Encountered

| Error | Attempt | Resolution | Prevention |
|-------|---------|------------|---------------------------|
| | 1 | | → progress.md Error Log |

## Notes

- 本任务为纯文档/脚本修改，不涉及运行中基础设施
- Rule 57 与现有 Rule 11/15/33 互补，不修改既有 Rules
- 开关键默认 warn，与其他 Rule 保持一致

## 🚨 Drift Log

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| | | | |

## 📦 Batch Report

| 字段 | 值 |
|------|-----|
| `total` | n/a |
| `success` | n/a |
| `failed` | n/a |
| `failure_rate` | n/a |
| `sampled_pass` | n/a |
| `sampled_fail` | n/a |
| `pre_check` | n/a |
| `rollback_point` | n/a |

## 📊 委派统计

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 4 / 5 |
| 主进程直做 Phase 清单 | Phase 5（例外理由:① git 编排+② 簿记） |
| 委派率 | 0.8 |

## 🔗 Subagent Handoff 登记表

| # | 时间 | subagent_type | 任务目标 | 状态 | 结论摘要 | 证据 | findings 落点 | checkpoint 路径 | 备注 |
|---|------|--------------|----------|------|----------|------|---------------|----------------|------|
| 1 | | code-assistant | 新增 Rule 57 到 critical-rules.md | queued | | | | | - / 0 / ☐ |
| 2 | | code-assistant | 新增 periodic-review.sh | queued | | | | | - / 0 / ☐ |
| 3 | | code-assistant | 新增 selftest-periodic-review.sh | queued | | | | | - / 0 / ☐ |
| 4 | | code-assistant | 修改 config.json 和 SKILL.md | queued | | | | | - / 0 / ☐ |

## 🔁 模板感知
<!-- template_type: general -->
- 触发信号: 任务类型空缺 → 落 general 兜底（非 16 类已知类型之一）
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 沉淀理由 / 不沉淀理由（二选一必填）→ 指向 plan-template-kit 卫星 SOP
