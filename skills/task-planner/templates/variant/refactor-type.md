<!-- template_type: refactor -->
<!-- 适用场景: 代码重构/瘦身/性能优化 -->
<!-- 触发关键词: 重构/瘦身/简化/优化性能/清理死代码/降低复杂度 -->
<!-- 推荐 subagent: code-simplifier(瘦身) / executor(大型重构) -->

# Task Plan: [重构任务名称]

## Goal
[一句话:对哪段代码做何种重构,达成什么度量(行数↓/复杂度↓/性能↑/可读性↑)]

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required` |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 重构前基线测试全绿 | `bun test` 记录基线通过数 N | 测试输出 |
| VC-2 | 重构后行为不变 | `bun test` 通过数 ≥ N(无回归) | 测试输出 |
| VC-3 | 复杂度下降 | 圈复杂度/LOC/认知复杂度对比 | `tools/complexity-report.json` |
| VC-4 | 公共 API 不变 | `git diff` 仅实现层,签名零变化 | `git diff` 输出 |
| VC-5 | 性能不退化(若涉及) | benchmark 对比 ±5% | `tmp/perf-before.txt` vs `tmp/perf-after.txt` |

**终验规则**:
- 全部 VC 通过 → COMPLETE
- VC-2 失败 = 行为改变 = 直接 BLOCKED 升级用户(重构不允许行为变化)
- VC-3 不下降 = 标记 PARTIAL,需说明理由

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码 | [明确列出,如 src/foo.ts] | 其他 |
| 测试 | [允许新增,禁止删除/改动既有断言] | 改既有断言(应改 plan) |
| 配置 | [若有] | 其他 |
| 文档 | [允许新增] | 删既有文档 |

**强制约束**:
- 既有测试用例禁止删除(测试是行为契约)
- 公共 API 签名禁止修改(导出函数/类型/常量名)

## Current Phase
Phase 1

## Phases

### Phase 1: 重构前置分析
- [ ] 派 `Agent(subagent_type: codebase-analyzer)` 产出重构目标报告(复杂度热点/重复代码/死代码)
- [ ] 跑基线测试 `bun test`,记录通过数 N
- [ ] 锁定重构范围(具体函数/类/模块)
- **Status:** pending

### Phase 2: 重构方案设计
- [ ] 设计具体重构手法(extract function/inline/rename/合并类/拆分模块)
- [ ] 评估每步对 API 的影响
- [ ] 写 Decisions Made 表
- **Status:** pending

### Phase 3: 实施重构
- [ ] 派 `Agent(subagent_type: code-simplifier)` 或 `executor` 执行
- [ ] 每步保持测试绿(测试失败立即回滚该步)
- [ ] 记录每步 diff 到 progress.md
- **Status:** pending

### Phase 4: 验证行为不变 + 复杂度下降
- [ ] 派 `Agent(subagent_type: code-runner-agent)` 跑 `bun test`
- [ ] 派 `Agent(subagent_type: codebase-analyzer)` 重测复杂度
- [ ] 对比基线:测试通过数 ≥ N + 复杂度下降 ≥ 10%
- **Status:** pending

### Phase 5: Code Review Gate + 提交
- [ ] 调用 `Skill("code-review")` 审查(重点:行为是否真不变 + API 兼容性)
- [ ] APPROVED → commit;CHANGES_REQUESTED → 回到 Phase 3
- [ ] `Skill("task-drift-guard")` 终验
- **Status:** pending

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe` / `risk` |
| `isolation` | `worktree`(默认) |
| `worktree_path` | `<repo-parent>/<repo>-worktrees/<task-id>` |
| `branch` | `wt/<task-id>` |
| `merge_back` | `pending` → `merged(<commit>)` |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | 前置分析 |
| Phase 2 | ☐ |  | 方案设计 |
| Phase 3 | ☐ |  | 实施 |
| Phase 4 | ☐ |  | 验证 |
| Phase 5 | ☐ |  | Review + commit |

## Key Questions

1. 重构的复杂度度量标准是什么(LOC/圈复杂度/认知复杂度)?
2. 是否有现成 benchmark 覆盖这块代码?
3. 重构后是否需要更新文档/示例?

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 重构手法 | ... |
| 范围限定 | ... |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
|       | 1       |            |

## Notes

- 重构 = 行为不变,任何测试失败 = 立即回滚
- 复杂度报告用 codebase-analyzer 子代理,主进程不直接读源码
- 每 2-3 个 Phase 完成 → 跑一次 `Skill("task-drift-guard")`
