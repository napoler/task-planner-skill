<!-- template_type: test-writing -->
<!-- 适用场景: 单元/集成/E2E 测试编写、测试框架搭建、覆盖率提升 -->
<!-- 触发关键词: 测试/覆盖率/单元测试/集成测试/E2E/pytest/vitest/bun test -->
<!-- 推荐 subagent: test-engineer (sonnet-1) -->

# Task Plan: [测试编写任务名称]

## Goal
[一句话:为哪个模块/功能编写什么类型的测试,达成什么覆盖率门槛]

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a` / `required` |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 测试用例数 ≥N(覆盖核心路径) | `grep -c "test\|it("` 统计 | 测试文件 |
| VC-2 | 覆盖率 ≥X%(行/分支,目标 ≥80%) | `bun test --coverage` 或 `coverage report` | `coverage/coverage-summary.json` |
| VC-3 | 测试独立可跑(无顺序依赖) | `bun test --random-order` 通过 | CI 输出 |
| VC-4 | CI 通过(若已配置) | CI 日志全绿 | CI dashboard |
| VC-5 | 关键边界 case 已覆盖(空值/极端/异常) | 测试文件含针对性断言 | `grep "edge\|null\|empty\|throw"` |

**终验规则**:
- 全部 VC 通过 → COMPLETE
- VC-2 不达标 → 标记 PARTIAL,需追加测试
- VC-3 失败 = 测试相互依赖 = 必须重构

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 测试源 | [明确列出,如 tests/foo.test.ts] | 其他测试文件 |
| 测试配置 | [如 vitest.config.ts / pytest.ini] | 其他配置 |
| 源(只读) | [被测目标,如 src/foo.ts](测试需要 Read,但不修改) | 改源码(应改 plan) |
| 文档 | [如 tests/README.md] | 其他 |

**强制约束**:
- 测试文件不得修改源码(被测代码应通过设计本身可测;若改源码需重新规划)
- 测试用例不得有 `beforeEach` 隐式依赖其他测试产物

## Current Phase
Phase 1

## Phases

### Phase 1: 测试目标分析
- [ ] Read 目标模块,识别核心函数/分支/边界
- [ ] 输出"测试目标清单"到 findings.md(每条含:函数名 + 入参类型 + 期望行为)
- [ ] 圈定覆盖率目标(行/分支)
- **Status:** pending

### Phase 2: 用例设计(等价类 + 边界值)
- [ ] 派 `Agent(subagent_type: test-engineer)` 设计用例矩阵
- [ ] 每函数至少 3 类用例:正常值 + 边界值 + 异常值
- [ ] 输出到 `tmp/test-cases.md`
- **Status:** pending

### Phase 3: 用例实现
- [ ] 派 `Agent(subagent_type: code-assistant)` 写测试代码
- [ ] 单一职责:每个 test() 只测一个行为
- [ ] 命名规范:`describe('X') + it('when Y should Z')`
- **Status:** pending

### Phase 4: 覆盖率验证
- [ ] 派 `code-runner-agent` 跑 `bun test --coverage`
- [ ] 覆盖率不达标 → 回到 Phase 3 补测试
- [ ] 输出 `coverage/coverage-summary.json` 留证
- **Status:** pending

### Phase 5: CI 集成
- [ ] CI 配置更新(`bun test` 加入 CI 流程)
- [ ] 随机顺序跑(`bun test --random-order`)确认无依赖
- [ ] `Skill("task-drift-guard")` 终验
- **Status:** pending

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe` / `risk` |
| `isolation` | `worktree`(默认 — 测试文件可能多) |
| `worktree_path` | `<repo-parent>/<repo>-worktrees/<task-id>` |
| `branch` | `wt/<task-id>` |
| `merge_back` | `pending` → `merged(<commit>)` |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | 目标分析 |
| Phase 2 | ☐ |  | 用例设计 |
| Phase 3 | ☐ |  | 用例实现 |
| Phase 4 | ☐ |  | 覆盖率验证 |
| Phase 5 | ☐ |  | CI 集成 |

## Key Questions

1. 覆盖率门槛定多少(行 ≥80% / 分支 ≥70%)?
2. 是否包含 E2E(若含,需 staging 环境)?
3. 测试运行性能要求(单测 <30s)?
4. mock 策略(全 mock / 部分 mock / 真实 DB)?

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 测试框架 | ... |
| 覆盖率门槛 | ... |
| mock 策略 | ... |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
|       | 1       |            |

## Notes

- **铁律**:覆盖率不达标禁止 CI 集成
- 测试文件主进程不直接 Edit — 派 code-assistant 子代理
- 每 2-3 个 Phase 完成 → 跑 `Skill("task-drift-guard")`
