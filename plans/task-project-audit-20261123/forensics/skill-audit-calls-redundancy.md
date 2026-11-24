# Skill Audit - Calls & Redundancy (S39/S39a + S79)

## 元信息

- 任务: `task-project-audit-20261123` / Phase 2b
- 审计时间: 2026-11-23 (Asia/Shanghai)
- 审计范围: 32 个正式技能（21 个 top-level + 11 个 task-planner/review-library）
- 审计模式: **只读**。未修改任何技能文件。
- 写入文件: `plans/task-project-audit-20261123/forensics/skill-audit-calls-redundancy.md`
- 授权状态: 用户在任务消息中明确授权本次只读审计与该检查点写入。

## 范围清单

| 类型 | 数量 | 路径 |
|---|---:|---|
| top-level 正式技能 | 21 | `skills/*/SKILL.md`（不含 .backup） |
| review-library 正式技能 | 11 | `skills/task-planner/review-library/*/SKILL.md` |
| 合计 | 32 | - |

## 任务1: S39/S39a 调用方式层

### 审计方法

1. 优先使用 skill-fix 官方审计器：`bun /home/terry/.zcode/skills/skill-fix/tools/subagent_skill_auditor.ts <32个skill目录>`
2. 审计器版本/环境：`bun 1.4.0`，工具路径 `/home/terry/.zcode/skills/skill-fix/tools/subagent_skill_auditor.ts`
3. 审计器逻辑：提取 `Agent(subagent_type=..., prompt="""...""")` 块，仅检查 SUB-AGENT prompt 内 `Skill()`、`WebSearch()`、`DuckDuckGo`、`agent-browser`、`playwright`、`google-search`、`bing-search`、curl搜索引擎、WebFetch搜索模式；`Skill()` 额外检查 agent frontmatter 是否包含 `Skill` tool。
4. 降级/补充扫描：`grep` 全量扫描 32 个正式技能的 SKILL.md + references（排除 `.backup`）中的 `WebSearch(`、`DuckDuckGo`、`mcp__`、`agent-browser`、`playwright`、`google-search`、`bing-search`，人工按“是否在 SUB-AGENT prompt 指令中”分类，避免误报。

### 执行证据

```bash
bun /home/terry/.zcode/skills/skill-fix/tools/subagent_skill_auditor.ts \
  skills/context-corrector ... skills/workflow-model-tiers \
  skills/task-planner/review-library/{alignment,code-quality,content-quality,data-quality,documentation,general,image,release,security,test-quality,ui-quality}-review
# EXIT=0
# 扫描文件数: 3259
# 发现问题数: 0
```

> 说明：扫描文件数 3259 包含传入目录下递归到的 md 文件（含 references 与嵌套目录）；审计器仅对 Agent prompt 块应用 S39/S39a 规则。

### S39a 报告表（SUB-AGENT 滥用命中）

| 调用方(skill/file:line) | 子代理/块 | 被调用/模式 | 调用方式 | 严重度 | 建议 | 证据 |
|---|---|---|---|---|---|---|
| （无） | - | - | - | - | 无需修复 | auditor EXIT=0, 发现问题数=0 |

### Grep 补充审查（非违规/误报排除）

以下命中经上下文审查，**不属于 SUB-AGENT prompt 内滥用**，记录以防复核遗漏：

| 文件:行 | 模式 | 上下文 | 判定 | 原因 |
|---|---:|---|---|---|
| `skills/plan-collab-router/SKILL.md:3` | `Skill(` | description text | 非违规 | frontmatter description 描述路由触发方式，非 SUB-AGENT prompt 内指令 |
| `skills/plan-collab-router/SKILL.md:35` | `Skill(` | 触发方式说明 | 非违规 | 主路由触发说明，非子代理 prompt |
| `skills/plan-cost-guard/SKILL.md:3` | `Skill(` | description text | 非违规 | frontmatter 描述，非子代理 prompt |
| `skills/plan-cost-guard/SKILL.md:34` | `Skill(` | 触发方式说明 | 非违规 | 主路由触发说明 |
| `skills/plan-research-router/SKILL.md:3` | `Skill(` | description text | 非违规 | frontmatter 描述 |
| `skills/plan-research-router/SKILL.md:34` | `Skill(` | 触发方式说明 | 非违规 | 主路由触发说明 |
| `skills/plan-template-kit/SKILL.md:3` | `Skill(` | description text | 非违规 | frontmatter 描述 |
| `skills/plan-template-kit/SKILL.md:37` | `Skill(` | 触发方式说明 | 非违规 | 主路由触发说明 |
| `skills/task-planner/SKILL.md:106` | `Skill(` | 主进程计划步骤 | 非违规 | 主进程可选前置步骤，非 Agent prompt 块 |
| `skills/task-planner/SKILL.md:113` | `Skill(` | 主进程计划步骤 | 非违规 | 主进程路由说明 |
| `skills/task-planner/SKILL.md:130` | `Skill(` | 主进程计划步骤 | 非违规 | 主进程 SOP 引用 |
| `skills/task-planner/SKILL.md:148` | `Skill(` | 主进程计划步骤 | 非违规 | 主进程检查点 |
| `skills/task-planner/SKILL.md:193` | `Skill(` | 主进程执行步骤 | 非违规 | 主进程 Code Review Gate |
| `skills/task-planner/SKILL.md:211` | `Skill(` | 主进程意图切换 | 非违规 | 主进程回切路由 |
| `skills/task-planner/SKILL.md:267` | `Skill(` | 主进程矛盾处理 | 非违规 | 主进程分流说明 |
| `skills/task-planner/SKILL.md:274` | `Skill(` | 主进程规则说明 | 非违规 | 主进程行为规则文本 |
| `skills/task-planner/SKILL.md:287` | `Skill(` | 主进程通道探测 | 非违规 | 主进程探测，非子代理 prompt |
| `skills/task-planner/SKILL.md:340` | `Skill(` | 主进程参考说明 | 非违规 | 文档引用说明 |
| `skills/task-planner/SKILL.md:440` | `Skill(` | 外部 skill/agent 表 | 非违规 | 能力清单表格，非子代理 prompt 指令 |
| `skills/plan-collab-router/references/skill-collaboration.md:64` | `mcp__node_repl__js` | browser-use 嵌入说明 | 非违规 | 描述 browser-use 控制通道，非要求子代理调用 mcp__node_repl__js；无 Agent prompt 块 |
| `skills/plan-research-router/references/research-routing.md:9` | `mcp__node_repl__js` | 调研通道阶段说明 | 非违规 | 通道能力描述，非子代理 prompt |
| `skills/plan-research-router/references/research-routing.md:10` | `mcp__/playwright` | 平台适配优先说明 | 非违规 | 明确禁止假设 playwright 等不存在 MCP，是防误用说明 |
| `skills/plan-research-router/references/critical-rules-research.md:56` | `agent-browser` | 外部工具强制规则 | 非违规 | 主进程/计划期工具可用性规则，非子代理 prompt |
| `skills/plan-research-router/references/critical-rules-research.md:72` | `mcp__node_repl__js` | 调研降级链规则 | 非违规 | 规则文本说明 ZCode 浏览器通道，非子代理滥用指令；审计器未在 Agent prompt 块命中 |
| `skills/task-discipline/references/critical-rules-discipline.md:301` | `agent-browser` | Rule 60 判例注释 | 非违规 | 判例背景注释 |
| `skills/task-discipline/references/critical-rules-discipline.md:305` | `agent-browser` | Rule 60 正文 | 非违规 | 行为原则说明替代工具，非子代理 prompt |
| `skills/task-discipline/references/critical-rules-discipline.md:310` | `agent-browser` | Rule 60 枚举 | 非违规 | 替代方案枚举 |
| `skills/task-discipline/references/critical-rules-discipline.md:316` | `agent-browser` | Rule 60 排序 | 非违规 | 替代方案排序 |
| `skills/todo-skill/WORKFLOW.md:59` | `agent-browser` | electron skill 描述 | 非违规 | 工作流目录描述，不是 SUB-AGENT prompt 指令 |

### S39/S39a 判定

- **S39/S39a 违规数: 0 (P0=0, P1=0, P2=0, UNKNOWN=0)**
- 证据等级: 高（官方审计器 + grep 补充人工分类）。

## 任务2: S79 冗余/漂移层

### R1 镜像机检（repo vs ~/.zcode/skills vs ~/.agents/skills）

比较对象：32 个正式技能的 `SKILL.md` sha256。

| Skill | Repo SHA256(12) | ~/.zcode/skills | ~/.agents/skills | 判定 |
|---|---|---|---|---|
| `context-corrector` | `b12d9fc6a552` | OK b12d9fc6a552 | OK b12d9fc6a552 | OK |
| `error-fix-prompt-forge` | `37e61d3a8d30` | OK 37e61d3a8d30 | OK 37e61d3a8d30 | OK |
| `iterative-optimizer` | `dc933c6d25c4` | OK dc933c6d25c4 | OK dc933c6d25c4 | OK |
| `longform-continuity` | `114a9d82f063` | OK 114a9d82f063 | OK 114a9d82f063 | OK |
| `md-edit-ops` | `ca5eec9ae56a` | OK ca5eec9ae56a | OK ca5eec9ae56a | OK |
| `media-planner` | `974e588ccc0d` | OK 974e588ccc0d | OK 974e588ccc0d | OK |
| `plan-collab-router` | `5511531c46f7` | OK 5511531c46f7 | OK 5511531c46f7 | OK |
| `plan-cost-guard` | `1019cd4a03c5` | OK 1019cd4a03c5 | OK 1019cd4a03c5 | OK |
| `plan-history-recall` | `cf0aad7e56e2` | OK cf0aad7e56e2 | OK cf0aad7e56e2 | OK |
| `plan-research-router` | `9d33e8ce0f94` | OK 9d33e8ce0f94 | OK 9d33e8ce0f94 | OK |
| `plan-resume` | `7f59da603b63` | OK 7f59da603b63 | OK 7f59da603b63 | OK |
| `plan-template-advisor` | `b067e472f280` | OK b067e472f280 | OK b067e472f280 | OK |
| `plan-template-kit` | `eb1a900a5ca6` | OK eb1a900a5ca6 | OK eb1a900a5ca6 | OK |
| `progress-tracker` | `ec572245f6fa` | OK ec572245f6fa | OK ec572245f6fa | OK |
| `task-discipline` | `8c3cdd2baacf` | OK 8c3cdd2baacf | OK 8c3cdd2baacf | OK |
| `task-dispatch` | `c0fc4f03870e` | OK c0fc4f03870e | OK c0fc4f03870e | OK |
| `task-drift-guard` | `9592b6e140a6` | OK 9592b6e140a6 | OK 9592b6e140a6 | OK |
| `task-planner` | `7a97aa7d69ae` | OK 7a97aa7d69ae | DRIFT 0bf7f3963679 | DRIFT/MISSING |
| `todo-skill` | `5b4e254476e9` | OK 5b4e254476e9 | OK 5b4e254476e9 | OK |
| `verification-gate` | `c5ba49440ee1` | OK c5ba49440ee1 | OK c5ba49440ee1 | OK |
| `workflow-model-tiers` | `ef658224e661` | OK ef658224e661 | OK ef658224e661 | OK |
| `alignment-review` | `ce0512aa6153` | OK ce0512aa6153 | OK ce0512aa6153 | OK |
| `code-quality-review` | `91d9158c2806` | OK 91d9158c2806 | OK 91d9158c2806 | OK |
| `content-quality-review` | `c6119a0a74d4` | OK c6119a0a74d4 | OK c6119a0a74d4 | OK |
| `data-quality-review` | `538b56507961` | OK 538b56507961 | OK 538b56507961 | OK |
| `documentation-review` | `21e06b3659b6` | OK 21e06b3659b6 | OK 21e06b3659b6 | OK |
| `general-review` | `73390a9d106f` | OK 73390a9d106f | OK 73390a9d106f | OK |
| `image-review` | `ff83192deced` | OK ff83192deced | OK ff83192deced | OK |
| `release-review` | `6e6d855a5076` | OK 6e6d855a5076 | OK 6e6d855a5076 | OK |
| `security-review` | `93bcaed6c869` | OK 93bcaed6c869 | OK 93bcaed6c869 | OK |
| `test-quality-review` | `99ac4145f5f3` | OK 99ac4145f5f3 | OK 99ac4145f5f3 | OK |
| `ui-quality-review` | `6b7c49809cc8` | OK 6b7c49809cc8 | OK 6b7c49809cc8 | OK |

- R1 漂移/缺失数: **1 / 32**
- 漂移清单:
  - `task-planner`: AGENTS_DRIFT (repo=7a97aa7d69ae, zcode=7a97aa7d69ae, agents=0bf7f3963679)
    - 证据: repo 与 ~/.zcode 相同(83297B)，~/.agents 为 83009B；diff 显示 agents 侧缺少 Rule 27/96.7/103.8b 的“方向根本错误→§4.6 弃旧开新”补充段。

### R4 双树同名 / 备份镜像差异

检查 `skills/task-planner/.backup/**/SKILL.md` 中与 32 个正式技能同名项的内容差异（只登记，不建议合并/删除）。

| 正式技能 | backup 同名副本数 | same | diff | 处理建议(只建议) |
|---|---:|---:|---:|---|
| `alignment-review` | 24 | 4 | 20 | 保留为历史备份；若清理需单独授权并先确认无引用依赖 |
| `code-quality-review` | 24 | 4 | 20 | 保留为历史备份；若清理需单独授权并先确认无引用依赖 |
| `content-quality-review` | 24 | 4 | 20 | 保留为历史备份；若清理需单独授权并先确认无引用依赖 |
| `data-quality-review` | 24 | 4 | 20 | 保留为历史备份；若清理需单独授权并先确认无引用依赖 |
| `documentation-review` | 24 | 4 | 20 | 保留为历史备份；若清理需单独授权并先确认无引用依赖 |
| `general-review` | 24 | 4 | 20 | 保留为历史备份；若清理需单独授权并先确认无引用依赖 |
| `image-review` | 24 | 4 | 20 | 保留为历史备份；若清理需单独授权并先确认无引用依赖 |
| `release-review` | 24 | 4 | 20 | 保留为历史备份；若清理需单独授权并先确认无引用依赖 |
| `security-review` | 24 | 4 | 20 | 保留为历史备份；若清理需单独授权并先确认无引用依赖 |
| `test-quality-review` | 24 | 4 | 20 | 保留为历史备份；若清理需单独授权并先确认无引用依赖 |
| `ui-quality-review` | 24 | 4 | 20 | 保留为历史备份；若清理需单独授权并先确认无引用依赖 |
| 其他 21 个 top-level 正式技能 | 0（未发现同名 .backup/SKILL.md） | - | - | 无 |

观察：11 个 review-library 正式技能均有 24 个同名备份副本，其中 20 个与正式版不同、4 个相同；差异集中在 `.backup/claude-stub-*` 历史快照树，属于历史镜像漂移，不等同于当前正式技能缺陷。

### R5 游离/备份统计

| 项目 | 数量 | 证据命令/观察 |
|---|---:|---|
| `skills/**/.backup` 目录数 | 10 | `find skills -type d -name .backup` |
| `skills/**/.backup/**/SKILL.md` 文件数 | 288 | `find skills/task-planner -path "*/.backup/*/SKILL.md" | wc -l` = 288 |
| `plans/` 子目录数 | 56 | `plans` 下一级目录计数 |
| `plans/**/SKILL.md` 文件数 | 3 | 复核量级，非 288 |
| worktree 镜像候选 | 0 | 未发现 `.worktrees/*` 或 `*task-planner-skill-wt-*` |

> R5 复核：backup SKILL.md=288 与探索值一致；“plans 归档副本数 5”未直接复现为同口径指标，本次可确认 plans 下 SKILL.md=3、plans 子目录=56，建议后续明确“归档副本”口径。

## S79 判定

- R1: **1 个部署漂移**（`task-planner` 在 `~/.agents/skills/task-planner/SKILL.md` 与 repo/zcode 不一致）。
- R4: **11 个 review-library 技能存在历史 backup 同名差异**（共 264 个同名备份副本，220 个 diff / 44 个 same）；不建议自动合并。
- R5: **备份体量高**（288 个 backup SKILL.md，10 个 backup 目录）；plans SKILL.md 仅 3。

## 风险与建议（只建议，不执行）

1. **P1 建议**：复核 `~/.agents/skills/task-planner/SKILL.md` 是否应同步 repo 的 Rule 27/§4.6 弃旧开新补充；先确认该漂移是否为有意平台差异。
2. **P2 建议**：为 `.backup` 建立保留策略（保留最近 N 个快照或压缩归档），避免 288 份历史 SKILL.md 持续膨胀。
3. **P2 建议**：将 R5 “plans 归档副本数”口径写入审计规范，避免 288/5 类数字不可复现。
4. **不建议**：不自动删除/合并任何 `.backup`、plans、worktree 镜像；共享 lib/纯模板/注释示例不纳入冗余清理。

## 结论

- S39/S39a: **PASS（0 违规）**。
- S79: **WARN**（存在 1 个部署漂移 + 大量历史备份镜像差异；无证据表明正式技能被 backup 覆盖）。
