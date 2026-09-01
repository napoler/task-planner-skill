<!-- template_type: bugfix -->
<!-- 适用场景: bug 修复/根因定位 -->
<!-- 触发关键词: 修 bug/修复/报错/失败/异常/崩溃/不工作 -->
<!-- 推荐 subagent: debugger + Skill("systematic-debugging") -->

# Task Plan: [bug 修复任务名称]

## Goal
[一句话:修复什么 bug(具体症状),达成什么效果(回归测试通过)]

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required` |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | bug 可稳定复现 | 最小复现脚本输出报错信息 | `tmp/repro-output.txt` |
| VC-2 | 根因已定位(非症状修复) | 根因含证据:日志/堆栈/调用链 | `findings.md` 根因节 |
| VC-3 | 修复后 bug 不复现 | 跑最小复现脚本 → 无报错 | `tmp/repro-after.txt` |
| VC-4 | 回归测试全绿 | `bun test` 通过数 ≥ 基线 | 测试输出 |
| VC-5 | 新增回归测试覆盖此 bug | 测试文件中可见针对此 bug 的断言 | git diff 测试文件 |

**终验规则**:
- 全部 VC 通过 → COMPLETE
- VC-2 失败 = 根因未明 → BLOCKED 升级用户(禁止猜根因后修)
- VC-4 失败 = 修复引入回归 → 回到 Phase 3 重做

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码 | [明确列出,如 src/bug-area/*.ts] | 其他文件 |
| 测试 | [明确列出,允许新增回归测试] | 改既有无关测试 |
| 配置 | [若有] | 其他 |
| 文档 | [若有,允许新增 changelog] | 改既有文档 |

**强制约束**:
- 必须新增回归测试覆盖此 bug(VC-5)
- 修复必须基于根因,不允许"症状性修复"(try/catch 吞错、改全局忽略等)

## Current Phase
Phase 1

## Phases

### Phase 1: bug 复现
- [ ] 派 `Agent(subagent_type: explore)` 定位相关代码
- [ ] 写最小复现脚本(`tmp/repro.ts`),记录报错信息
- [ ] 输出复现步骤到 findings.md
- **Status:** pending

### Phase 2: 根因定位
- [ ] 调用 `Skill("systematic-debugging")` 5 步根因分析
- [ ] 派 `Agent(subagent_type: debugger)` 协助深挖
- [ ] 根因含证据链:日志/堆栈/最小复现/调用链
- [ ] 写 findings.md「根因」节
- **Status:** pending

### Phase 3: 修复方案设计
- [ ] 设计修复方案(至少 2 个备选 + 推荐)
- [ ] 评估副作用:是否影响其他模块
- [ ] 用户确认 → 进入实施
- **Status:** pending

### Phase 4: 实施修复
- [ ] 派 `Agent(subagent_type: code-assistant)` 实施修复
- [ ] 同步新增回归测试(覆盖此 bug)
- [ ] 记录修复前后 diff 到 progress.md
- **Status:** pending

### Phase 5: 验证 + Code Review + 提交
- [ ] 跑最小复现脚本 → 无报错
- [ ] 派 `code-runner-agent` 跑 `bun test` 全量回归
- [ ] 调用 `Skill("code-review")`(重点:根因是否真解决 + 是否有副作用)
- [ ] APPROVED → commit;CHANGES_REQUESTED → 回到 Phase 4
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
| Phase 1 | ☐ |  | 复现 |
| Phase 2 | ☐ |  | 根因 |
| Phase 3 | ☐ |  | 方案 |
| Phase 4 | ☐ |  | 修复 |
| Phase 5 | ☐ |  | 验证 |

## Key Questions

1. bug 是稳定复现还是偶发?
2. 影响范围多大(单用户/全量/特定条件)?
3. 是否有相关最近改动引入(`git log` + `git blame`)?
4. 根因是数据问题/逻辑问题/环境问题?

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 根因: ... | 证据: ... |
| 修复方案: ... | 备选: ... |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
|       | 1       |            |

## Notes

- **铁律**:根因未明禁止进入修复(VC-2 门控)
- 修复必须新增回归测试(VC-5 强制)
- 修代码必须派 `code-assistant`,主进程不直接 Edit
- 每 2-3 个 Phase 完成 → 跑 `Skill("task-drift-guard")`
