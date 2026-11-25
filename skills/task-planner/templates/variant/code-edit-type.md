<!-- template_type: code-edit -->
<!-- template_meta: {"type": "code-edit", "name": "代码编辑", "summary": "单文件/多文件代码编辑（明确单次编辑任务），编辑指定文件的代码段并验证效果。", "scenarios": ["单文件代码编辑", "多文件代码编辑", "函数实现/新增", "代码增删", "代码加注释"], "features": ["Code Review 配置", "Verification Contract", "执行范围限制", "Phases", "隔离决策"]} -->
<!-- JSON 模板源(task-json-template-20261125)：skills/task-planner/templates/json/code-edit.template.json — 本 MD 为教学/临时视图；权威源=plan-state.json 的 template_doc/template_checks；勾选请用 planctl set --section template_checks ... -->
<!-- 适用场景: 单文件/多文件代码编辑(明确单次编辑任务) -->
<!-- 触发关键词: 修改/编辑/实现/新增/添加/删除/写函数/加注释/改 bug -->
<!-- 推荐 subagent: code-assistant (≤3 文件) / executor (>3 文件) -->

# Task Plan: [代码编辑任务名称]
<!-- template-lineage: level=derived parent=../task_plan.md base=../task_plan.md spec_version=1 pruned="用户需求原文,根源覆盖表,不变量声明区,规范基线,进度产出基线,双轮质检与同步完整性声明,核心目标达成裁决,变更标注表,核心问题定义,调研需求与检索计划,证据面清单,NextStep,防倒退终检,收尾回读梳理记录,收尾对齐与清理,FMEA预演,Chain区块交接配置" pruned_reason="variant=领域裁剪全文，裁剪面以本清单显式登记（Rule 34.5 派生登记）" -->
<!-- planctl 派生口径(task-planctl-exec-surface-20261122)：本骨架数据经 planctl add/set 写入 plan-state.json 后 render 派生 task_plan.md 视图；直接填写会在首次 render 被覆盖 -->

<!-- plan_tier: standard -->
## Goal
[一句话:编辑哪个文件的哪段代码,达成什么效果]

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `对齐审查` | `[登记]` | Rule 42.6 消费：完成前跑 alignment-review;变更记录随交付落盘;mini 豁免 |
| `自动超时默认项` | `[询问点: 默认选项/超时值]` | Rule 44 消费：默认项+超时 5 分钟;低区分度 44.2 直接裁决;mini 豁免 |
| `质量审查工具` | `[检测结论]` | Rule 42 消费：42.2 四级检测登记;执行期用登记工具;mini 豁免 |

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

- **现成方案检索（Rule 75.3/75.4）**：代码编辑前必须先 GitHub 检索现成实现（gh CLI 搜仓库/issues）+官方文档——检索到现成实现评估借鉴/适配，未检索就自研=违规

## Current Phase
Phase 1

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
逐 Phase 登记工具面与理由;Executor 字段仍是委派门控机器事实源;mini 豁免
| Phase | 命中工具面 | 选择理由 |
|-------|----------|---------|
| Phase 1 | [如: Agent 子代理 executor(sonnet-1)] | [一句话理由] |

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
- [ ] 调用 `Skill("code-quality-review")` 上下文隔离审查
- [ ] APPROVED → 进入 Phase 5;CHANGES_REQUESTED → 回到 Phase 2 修复
- **Status:** pending
- **Executor:** 主进程（例外理由:编排与交付属主进程白名单）

### Phase 5: 提交 + 收尾
- [ ] `git add` + `git commit` 修改文件(commit message 含 plan 引用)
- [ ] 更新 task_plan.md 全部 Phase → complete
- [ ] 派发 `drift-checker` 子代理偏移检查（Rule 61 载体）终验
- **Status:** pending
- **Executor:** code-assistant（haiku-1）

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe` / `risk` |
| `isolation` | `worktree`(单仓)/ `direct`(用户明确说不用) |
| `worktree_path` | `<project-root>/tmp/worktrees/<task-id>`(Rule 100:临时产物统一当前项目 tmp/,tmp/ 入 .gitignore) |
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

- 每次 Phase 完成 → 派发 `drift-checker` 偏移检查（Rule 61 载体）
- 修改必须派 `code-assistant`/`executor` 子代理,主进程不直接 Edit 业务代码

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |          |        |      |

## 📊 委派统计（Rule 25.4 — 终验前必填）
<!-- 
  WHAT: 本计划子代理 vs 主进程的执行分布统计。
  WHY: 子代理占比需要可见反馈闭环;委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由 → outcome 最高 PARTIAL(白名单见 critical-rules.md Rule 25.3)。
  WHEN: 每个 Phase complete 后更新;终验交付前必须完整。
-->
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  /  |
| 主进程直做 Phase 清单 | （含例外理由） |
| 委派率 | （< delegation_rate_floor 默认 0.7,或含白名单外理由 → 最高 PARTIAL） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
每次 Agent() 派发前填一行;子代理返回后 Read 产出+findings 回填双条件才勾 verify_done(Rule 22.5)
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 |
|---|------|--------------|----------------|------|---------------|---------------|--------------|----------------|
| 1 |  |  |  | queued |  |  |  |  |

## 🎯 Goal 单元表（Rule 66.1 — attest 获批后填写）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 |  |  |  |  | pending |

## Phases 派发表骨架（S-unit 10 列固定列序——check-plan-dispatch.sh $4/$5/$7/$8 定位，禁增列/禁单元格管道转义；类别=目标列内（An）前缀）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | （A6） | 继承 |  |  | 10min | 1f/10l/10min | 无 | - | pending |

## 📦 Batch Report（Rule 18.6 — 留空会被 check-complete 拦）
| 字段 | 值 |
|------|-----|
| `total` | n/a（<一句理由>） |
| `success` | n/a |
| `failed` | n/a |
| `failure_rate` | n/a |
| `sampled_pass` | n/a |
| `sampled_fail` | 任务 <5 单元不触发抽样 |
| `pre_check` | Q1:否 / Q2:无共享写 / Q3:能 |
| `rollback_point` | <worktree 分支，合并前可弃> |

## 🧩 输出示例与格式契约（Rule 113）
> 必填：本类型计划中凡声明输出格式/结构的交付物，均须在 `plan-state.json.output_examples` 登记至少 1 条完整示例 + 1 个同结构可复用模板（经 `planctl add --section output_examples` 写入），由 `planctl render` 派生到 task_plan.md 同名区块。禁止只写「输出为 JSON」等无样例声明；禁「略/同上/TBD」。

| 交付物 | 格式 | 完整示例（fenced，见下方） | 可复用模板（占位符版，见下方） | 对应 VC |
|---|---|---|---|---|
| code-change-manifest.json | JSON | 见下方示例代码块 | 见下方模板代码块 | VC-2, VC-3 |

**完整示例（可直接查看、可比对）**：

```json
{
  "task": "配置解析器编辑",
  "changes": [
    {"file": "src/parser.ts", "symbol": "parseConfig", "change_type": "modify", "lines_added": 12, "lines_removed": 4}
  ],
  "vc_refs": ["VC-2", "VC-3"]
}
```

**可复用模板（占位符版，供执行期复制）**：

```json
{
  "task": "<PLACEHOLDER>",
  "changes": [
    {"file": "<PLACEHOLDER>", "symbol": "<PLACEHOLDER>", "change_type": "<PLACEHOLDER>", "lines_added": "<PLACEHOLDER>", "lines_removed": "<PLACEHOLDER>"}
  ],
  "vc_refs": ["<PLACEHOLDER>"]
}
```

填写纪律：① 示例与模板的字段集/层级必须一致；② 示例必须自包含可查看（JSON 须合法可解析、表格须有表头+≥1 行数据）；③ 无格式交付物时显式写 `none-justified（理由）`，禁留空；④ 示例的 `vc_refs` 至少映射 1 个已存在 VC（Rule 113.4）。
