<!-- template_type: schema-migration -->
<!-- 适用场景: 数据库 schema 变更、migration 脚本、索引重建、数据回填、在线 DDL -->
<!-- 触发关键词: 数据库/schema/migration/索引/在线 DDL/回填 -->
<!-- 推荐 subagent: database-optimizer (sonnet-1) -->

# Task Plan: [schema 迁移任务名称]

## Goal
[一句话:对哪个表/字段做何种 schema 变更(加列/加索引/分表/分库),达成什么目标]

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required` |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | migration 可逆(up/down 双向脚本) | `migrate up && migrate down` 后 schema 一致 | staging 表结构对比 |
| VC-2 | staging 库执行成功 | staging 表结构 + 数据 row count 一致 | staging 输出 |
| VC-3 | 数据零丢失(行数/字段 diff) | `SELECT COUNT(*)` 对比 + 关键字段校验 | `tmp/data-diff.txt` |
| VC-4 | 在线切换无锁等待(若生产) | `pg_stat_activity` 无 long lock / `pt-online-schema-change` 验证 | DB 监控 |
| VC-5 | 回滚预案就绪(migration down 已演练) | 演练记录 + down 脚本就位 | `tmp/rollback-drill.md` |

**终验规则**:
- 全部 VC 通过 → COMPLETE
- VC-1 失败 = migration 不可逆 = BLOCKED 升级用户(高危)
- VC-3 失败 = 数据丢失 = BLOCKED 紧急回滚

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| Migration | [如 migrations/001_add_xxx.sql] | 其他无关 migration |
| 回填脚本 | [如 scripts/backfill-xxx.ts] | 其他 |
| Schema | [如 prisma/schema.prisma / db/schema.sql] | 其他 |
| 文档 | [如 docs/schema-changelog.md] | 其他 |

**强制约束**:
- 必须有 up + down 双向脚本(单方向 migration 禁止)
- 禁止 DROP COLUMN 前未备份数据
- 禁止生产环境直接跑未经演练的 migration
- 涉及大表 schema 变更必须用在线工具(pt-online-schema-change / gh-ost / pg_repack)

## Current Phase
Phase 1

## Phases

### Phase 1: schema 变更设计(可逆性)
- [ ] 派 `Agent(subagent_type: database-optimizer)` 设计 up + down 双向脚本
- [ ] 评估锁等待风险:大表 → 强制在线 DDL
- [ ] 输出 `tmp/migration-design.md`(变更清单 + 可逆性 + 风险)
- **Status:** pending

### Phase 2: 编写 up/down 脚本
- [ ] 派 `code-assistant` 写 up + down SQL 脚本
- [ ] 包含数据回填逻辑(若新增非空字段)
- [ ] 加 IF NOT EXISTS / IF EXISTS 兼容已部分应用情况
- **Status:** pending

### Phase 3: staging 演练
- [ ] 备份 staging 库
- [ ] 跑 up + 验证 + 跑 down + 验证 schema 一致(VC-1)
- [ ] 跑数据回填脚本 → 校验行数/字段
- **Status:** pending

### Phase 4: 生产执行
- [ ] 备份生产库(mysqldump / pg_dump + 校验)
- [ ] 维护窗口:低峰期执行(若锁表)
- [ ] 大表用在线工具:`pt-online-schema-change` / `gh-ost`
- [ ] 监控 `pg_stat_activity` / `SHOW PROCESSLIST`
- **Status:** pending

### Phase 5: 回滚预案确认 + 文档
- [ ] down 脚本演练记录入档
- [ ] docs/schema-changelog.md 更新
- [ ] RUNBOOK.md 更新(紧急回滚 SOP)
- [ ] `Skill("task-drift-guard")` 终验
- **Status:** pending

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe` / `risk` |
| `isolation` | `worktree`(默认 — 涉及数据库 schema,§十一 P0) |
| `worktree_path` | `<repo-parent>/<repo>-worktrees/<task-id>` |
| `branch` | `wt/<task-id>` |
| `merge_back` | `pending` → `merged(<commit>)` |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | 设计 |
| Phase 2 | ☐ |  | 写脚本 |
| Phase 3 | ☐ |  | staging 演练 |
| Phase 4 | ☐ |  | 生产执行 |
| Phase 5 | ☐ |  | 预案归档 |

## Key Questions

1. 涉及表的数据量(决定是否需要在线 DDL)?
2. 是否需要回填数据(若是,数据来源)?
3. 应用层是否需要配合改代码(若新增字段)?
4. 维护窗口多久?回滚 SLA 是多少?

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 是否用在线 DDL | ... |
| 回填策略 | ... |
| 回滚 SLA | ... |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
|       | 1       |            |

## Notes

- **铁律**:up/down 双向脚本必须成对(VC-1 门控)
- 无 staging 演练 → 禁止生产(VC-2 门控)
- 数据库 migration 主进程不直接写 SQL — 派 database-optimizer / code-assistant
- 每 2-3 个 Phase 完成 → 跑 `Skill("task-drift-guard")`
- 数据库属 §十一 P0 必 worktree 范围
