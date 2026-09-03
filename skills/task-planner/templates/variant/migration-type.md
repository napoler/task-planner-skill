<!-- template_type: migration -->
<!-- 适用场景: Python→TS/Bun 迁移、框架升级、CLI 重写、单语言→多语言、Shebang 切换、API 协议迁移 -->
<!-- 触发关键词: 迁移/升级/重写/切换/转换/兼容 -->
<!-- 推荐 subagent: executor (sonnet-1,跨步骤协调) + code-assistant + Skill("cli-tool-builder") -->

# Task Plan: [迁移任务名称]

## Goal
[一句话:从哪种实现迁移到哪种实现,达成什么效果(行为等价/性能提升)]

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required` |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|----------|
| VC-1 | 旧实现已备份/锁定(不能丢) | `git tag` 基线 tag + 旧代码归档路径 | `git tag --list "migration-baseline-*"` + 归档目录 |
| VC-2 | 新实现功能等价(逐 case 对照) | diff 行为对照表(≥90% 用例等价) | `tmp/migration-parity.md` |
| VC-3 | 双跑回归结果一致 | 新旧版本并行跑同一输入,输出 diff ≤X% | `tmp/dual-run-diff.txt` |
| VC-4 | 旧入口已下线/路由切换 | 旧脚本加 deprecation warning 或删除 | `grep -r "deprecated" 旧路径` |
| VC-5 | 文档/RUNBOOK 已更新 | `README.md` / `INSTALL.md` 指向新入口 | git diff 文档 |

**终验规则**:
- 全部 VC 通过 → COMPLETE
- VC-2/VC-3 失败 → 行为漂移 = BLOCKED 升级用户
- VC-4 失败 = 旧入口未下线 = PARTIAL

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 旧实现 | [明确列出,如 src/legacy.py] | 其他无关文件 |
| 新实现 | [明确列出,如 src/new.ts] | 其他 |
| 路由/入口 | [如 package.json shebang / cli.sh] | 其他 |
| 文档 | [如 README.md / INSTALL.md / MIGRATION.md] | 其他 |

**强制约束**:
- 旧实现归档后才能进入切流阶段
- 旧入口下线必须含 deprecation 过渡期(除非用户显式说直接删除)

## Current Phase
Phase 1

## Phases

### Phase 1: 旧实现基线锁定
- [ ] 派 `Agent(subagent_type: executor)` 扫描旧实现范围 + 依赖
- [ ] 创建 `git tag migration-baseline-<commit>`
- [ ] 旧代码归档到 `archive/legacy-<date>/`
- [ ] 记录基线行为快照(测试输出/接口签名)到 `tmp/baseline-snapshot.json`
- **Status:** pending
- **Executor:** executor（sonnet-1）

### Phase 2: 新实现开发
- [ ] 派 `Agent(subagent_type: code-assistant)` 单文件改写
- [ ] 派 `Agent(subagent_type: executor)` 跨文件协调(>3 文件时)
- [ ] 每步保持基线行为不漂移(对照 snapshot)
- [ ] 记录新实现决策到 Decisions Made
- **Status:** pending
- **Executor:** executor（sonnet-1）

### Phase 3: 双跑回归对照
- [ ] 写双跑脚本 `tmp/dual-run.sh` 并行执行新旧实现
- [ ] 派 `code-runner-agent` 输出 `tmp/dual-run-diff.txt`
- [ ] diff ≤5% → 进入切流;否则修复新实现直到等价
- **Status:** pending
- **Executor:** executor（sonnet-1）

### Phase 4: 切流/路由切换
- [ ] 新实现主路径生效(默认调用新入口)
- [ ] 旧入口加 deprecation warning(过渡期)
- [ ] 派 `Skill("cli-tool-builder")` 检查 CLI 入口(若 CLI 迁移)
- **Status:** pending
- **Executor:** executor（sonnet-1）

### Phase 5: 文档更新 + 旧入口归档
- [ ] 更新 README.md / INSTALL.md / MIGRATION.md
- [ ] 记录迁移决策到 Decisions Made + commit 引用
- [ ] 跑 `Skill("task-drift-guard")` 终验
- **Status:** pending
- **Executor:** executor（sonnet-1）

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe` / `risk` |
| `isolation` | `worktree`(默认 — 涉及多文件实现) |
| `worktree_path` | `<repo-parent>/<repo>-worktrees/<task-id>` |
| `branch` | `wt/<task-id>` |
| `merge_back` | `pending` → `merged(<commit>)` |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | 基线锁定 |
| Phase 2 | ☐ |  | 新实现开发 |
| Phase 3 | ☐ |  | 双跑回归 |
| Phase 4 | ☐ |  | 切流 |
| Phase 5 | ☐ |  | 文档归档 |

## Key Questions

1. 旧实现的"行为快照"如何采样才能覆盖关键路径?
2. 双跑 diff 阈值定多少(X%)(建议 5%)?
3. deprecation 过渡期多长(建议 ≥1 个 release)?
4. 是否需要保留旧入口作为紧急回退?

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 新实现语言/框架 | ... |
| 行为等价性度量 | ... |
| 双跑策略 | ... |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
|       | 1       |            |

## Notes

- **铁律**:旧实现必须先归档,否则禁止切流(防丢代码)
- 双跑 diff >5% → 修复新实现,不允许"凑合切流"
- 修改必须派子代理,主进程不直接 Edit
- 每 2-3 个 Phase 完成 → 跑 `Skill("task-drift-guard")`
