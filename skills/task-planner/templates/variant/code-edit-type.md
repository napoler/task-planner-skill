<!-- template_type: code-edit -->
<!-- 适用场景: 单文件/多文件代码编辑(明确单次编辑任务) -->
<!-- 触发关键词: 修改/编辑/实现/新增/添加/删除/写函数/加注释/改 bug -->
<!-- 推荐 subagent: code-assistant (≤3 文件) / executor (>3 文件) -->

# Task Plan: [代码编辑任务名称]

## Goal
[一句话:编辑哪个文件的哪段代码,达成什么效果]

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required` |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 修改前已 Read 目标文件 | `Read {file}` 在工具调用记录中 | 工具调用记录 |
| VC-2 | 修改后 diff 符合预期 | `git diff {file}` 摘要与 plan 一致 | `git diff` 输出 |
| VC-3 | 编译/lint 通过 | `bun run lint` 或对应语言命令 | 命令输出 |
| VC-4 | 测试通过(若涉及) | `bun test` 或对应测试命令 | 测试输出 |
| VC-5 | 代码风格保持一致 | diff 行数 ≤300 / 文件数 ≤3 | 文件统计 |

**终验规则**:
- 全部 VC 通过 → COMPLETE
- 编译/lint 失败重试 3 次 → BLOCKED 升级用户

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码 | [明确列出,如 src/foo.ts] | 其他 .ts 文件 |
| 测试 | [明确列出,如 tests/foo.test.ts] | 其他测试 |
| 配置 | [若有,如 package.json] | 其他配置 |
| 文档 | [若有,如 docs/foo.md] | 其他文档 |

**强制约束**:不在允许列表中的文件一律不碰。

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 |  |  | 必读/参考 | ☐ |
| 官方文档 |  |  | 必读/参考 | ☐ |
| 项目内部文档/知识库 |  |  | 参考 | ☐ |
| 文献/论文 |  |  | 参考 | ☐ |
| 图书/教程 |  |  | 参考 | ☐ |
| 上游源码/release | 依赖库源码与 release notes | URL + commit SHA/tag | 必读 | ☐ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## Current Phase
Phase 1

## Phases

### Phase 1: 读现状 + 锁定变更点
- [ ] Read 目标文件全部相关代码段
- [ ] Read 上下游调用方(避免改坏调用链)
- [ ] 输出修改前代码片段到 progress.md
- [ ] 知识储备必读项已确认可获取(勾选「必要知识储备」表"已确认"列)
- **Status:** pending
- **Executor:** code-assistant（haiku-1）

### Phase 2: 实施修改
- [ ] 派 `Agent(subagent_type: code-assistant)`(≤3 文件)或 `executor` (>3 文件)执行修改
- [ ] 一次性提交,避免多次小改
- [ ] 记录修改前后关键 diff 到 progress.md
- **Status:** pending
- **Executor:** code-assistant（haiku-1）

### Phase 3: 验证编译与测试
- [ ] 派 `Agent(subagent_type: code-runner-agent)` 跑 `bun run lint` / `bun test`
- [ ] 失败 → 派 `Agent(subagent_type: build-error-resolver)` 修复
- [ ] 测试输出回写到 progress.md
- **Status:** pending
- **Executor:** code-runner-agent（mini）

### Phase 4: 触发 Code Review Gate
- [ ] 收集本次修改文件清单(`git diff --name-only`)
- [ ] 调用 `Skill("code-review")` 上下文隔离审查
- [ ] APPROVED → 进入 Phase 5;CHANGES_REQUESTED → 回到 Phase 2 修复
- **Status:** pending
- **Executor:** 主进程（例外理由:编排与交付属主进程白名单）

### Phase 5: 提交 + 收尾
- [ ] `git add` + `git commit` 修改文件(commit message 含 plan 引用)
- [ ] 更新 task_plan.md 全部 Phase → complete
- [ ] 运行 `Skill("task-drift-guard")` 终验
- **Status:** pending
- **Executor:** code-assistant（haiku-1）

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe` / `risk` |
| `isolation` | `worktree`(单仓)/ `direct`(用户明确说不用) |
| `worktree_path` | `<repo-parent>/<repo>-worktrees/<task-id>` |
| `branch` | `wt/<task-id>` |
| `merge_back` | `pending` → `merged(<commit>)` |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | 读现状 |
| Phase 2 | ☐ |  | 实施修改 |
| Phase 3 | ☐ |  | 编译测试 |
| Phase 4 | ☐ |  | Code Review |
| Phase 5 | ☐ |  | 提交收尾 |

## Key Questions

1. 修改涉及哪些上下游调用方?
2. 是否有现成的测试覆盖?
3. 是否需要更新文档?

## Decisions Made

| Decision | Rationale |
|----------|-----------|
|          |           |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
|       | 1       |            |

## Notes

- 每次 Phase 完成 → 调用 `Skill("task-drift-guard")`
- 修改必须派 `code-assistant`/`executor` 子代理,主进程不直接 Edit 业务代码
