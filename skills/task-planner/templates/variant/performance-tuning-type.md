<!-- template_type: performance-tuning -->
<!-- 适用场景: 性能瓶颈定位、慢查询优化、索引设计、缓存策略、benchmark、bundle 优化、Core Web Vitals -->
<!-- 触发关键词: 性能/瓶颈/慢/压测/benchmark/P95/Core Web Vitals -->
<!-- 推荐 subagent: performance-optimizer (sonnet-1) + database-optimizer (sonnet-1,若涉及 SQL) + debugger -->

# Task Plan: [性能优化任务名称]

## Goal
[一句话:优化哪个模块/接口的性能,达成什么指标(P95 下降 X%/TPS 提升 Y%)]

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required` |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 基线 benchmark 已记录 | `tmp/perf-before.json` 含 P50/P95/P99 | baseline JSON |
| VC-2 | 优化后 P95 下降 ≥X%(目标 ≥30%) | `tmp/perf-after.json` 对比 | diff 输出 |
| VC-3 | 无功能回归(测试全绿) | `bun test` 全量通过 | 测试输出 |
| VC-4 | 资源占用未恶化(CPU/内存) | `top`/`ps` 采样对比 | `tmp/resource-before.txt` vs `after.txt` |
| VC-5 | 优化可复现(记录改了什么) | `Decisions Made` 表 + commit 引用 | git log |

**终验规则**:
- 全部 VC 通过 → COMPLETE
- VC-2 不达标(<30%) → 标记 PARTIAL,记录提升幅度
- VC-3 失败 = 引入回归 = BLOCKED 升级用户

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 性能热点代码 | [如 src/hot-path.ts / src/db-query.ts] | 其他无关文件 |
| 索引/配置 | [如 migrations/xxx.sql / cache config] | 其他 |
| 测试(基准) | [如 bench/*.bench.ts] | 其他 |
| 文档 | [如 docs/perf-notes.md] | 其他 |

**强制约束**:
- 必须先记录基线 benchmark 才允许优化
- 优化必须可复现 — 每条决策写明"改了什么 + 为什么"
- 不得以牺牲可读性为代价的"极致优化"(如内联 5 层函数)

## Current Phase
Phase 1

## Phases

### Phase 1: 瓶颈定位(profiling)
- [ ] 派 `Agent(subagent_type: performance-optimizer)` profile 目标接口/查询
- [ ] 输出热点清单到 `tmp/hot-spots.md`(函数 + 调用次数 + 耗时占比)
- [ ] 若涉及 SQL → 派 `database-optimizer` 慢查询分析
- **Status:** pending

### Phase 2: 基线 benchmark
- [ ] 写基准脚本 `bench/perf-baseline.bench.ts`(或 ab/wrk/k6)
- [ ] 跑基线,记录 P50/P95/P99/QPS → `tmp/perf-before.json`
- [ ] 记录资源基线(CPU/内存)→ `tmp/resource-before.txt`
- **Status:** pending

### Phase 3: 优化实施
- [ ] 按热点清单逐项优化(索引 / 缓存 / 算法 / 并发 / bundle)
- [ ] 每步保持功能不变(用基线测试断言)
- [ ] 派 `code-assistant` 单文件改 / `executor` 跨文件
- [ ] 记录每步决策到 Decisions Made
- **Status:** pending

### Phase 4: 验证 benchmark + 测试
- [ ] 派 `code-runner-agent` 跑同一 benchmark → `tmp/perf-after.json`
- [ ] 对比: P95 下降 ≥30%(或用户指定)
- [ ] 跑 `bun test` 确认无功能回归(VC-3)
- [ ] 跑 `top`/`ps` 记录资源 → `tmp/resource-after.txt`
- **Status:** pending

### Phase 5: 复现性归档 + 文档
- [ ] commit 引用 + benchmark 脚本入库
- [ ] docs/perf-notes.md 更新(优化了什么 + 为什么)
- [ ] `Skill("task-drift-guard")` 终验
- **Status:** pending

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe` / `risk` |
| `isolation` | `worktree`(默认 — 涉及核心路径改动) |
| `worktree_path` | `<repo-parent>/<repo>-worktrees/<task-id>` |
| `branch` | `wt/<task-id>` |
| `merge_back` | `pending` → `merged(<commit>)` |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | 瓶颈定位 |
| Phase 2 | ☐ |  | 基线 |
| Phase 3 | ☐ |  | 优化实施 |
| Phase 4 | ☐ |  | 验证 |
| Phase 5 | ☐ |  | 归档 |

## Key Questions

1. 性能指标是 P95 还是 P99?目标降幅多少?
2. 测试环境 vs 生产环境差异(数据量/网络/缓存命中率)?
3. 优化预算(允许 1 周/2 周)?
4. 是否需要前端 bundle 优化(若涉及)?

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 优化策略(索引/缓存/算法/并发) | ... |
| 目标降幅 | ... |
| 复现性脚本 | ... |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
|       | 1       |            |

## Notes

- **铁律**:无基线 benchmark → 禁止优化(VC-1 门控)
- 优化不是 refactor,允许功能+性能共同变化(但不允许引入回归)
- 修改必须派子代理,主进程不直接 Edit
- 每 2-3 个 Phase 完成 → 跑 `Skill("task-drift-guard")`
