# Knowledge Brief — task-v119（任务知识简略要点）
<!--
  模板说明（复制后随正文保留至文件头部注释区，执行期可删除）:
  - 本模板由 scripts/init-session.sh 复制到 plans/<task-id>/knowledge-brief.md（第 6 计划文件）
  - 填写主体：计划期 plan-writer/主进程；执行期各 S-unit 完成后持续回填 §2/§3
  - 定位一句话：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；
    计划期产出，执行期回填
  - 与三文件罗盘关系：本文件=知识维（knowledge），不替代 findings（决策维）/ progress（进度维）/ task_plan（目标维）
  - 注意：本模板不含任务计划主模板的知识章节标题，templates/ 全库该标题 grep 锚计数维持 35（task-v115 videop1 回流 12 类后实测，template-guide.md 计数口径，验收以 guide §2.4 统一 grep 锚为准，不引行号）
-->
<!-- 填写指引 Why（task-v115 线C 补强，Rule 45.2/45.4）:
  ① 何时用: init-session.sh 建 plans/<task-id>/knowledge-brief.md 后即按 §1-§5 填写；
     计划期填 §1/§4/§5 骨架，§2/§3 执行期每个 S-unit 完成后持续回填（新事实/新锚点当日入账）。
  ② 为何设计成五段: 子代理 prompt 只能带「路径 + 摘要」（Rule 22.4 §9 上下文预算），
     五段=小模型可消费的知识最小集——§1 对齐术语、§2 只放已验证事实（带证据锚点，
     未验证推测禁入=防把假设当事实注入）、§3 定位文件（禁凭记忆改文件）、§4 提前
     排雷（历史教训+FMEA 兜底指针）、§5 把「S-unit → 该读哪节」互链到 S-unit 表。
  ③ 为何独立于三文件: 知识维与决策维(findings)/进度维(progress)/目标维(task_plan)
     分账存放——执行期重读任务时只读本文件即可恢复知识底座，不翻全会话/全 findings。 -->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer/主进程产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：新建 complex-planner agent（GLM5.3 完整版/Opus 级）作为高复杂度任务的解决规划备用方案，canonical 入库 + 部署 2 位 + 路由表登记。
- 背景/动机：常规档（haiku/sonnet）agent 承载不了的高复杂度任务缺少专用大模型规划升级出口；用户要求仅在复杂度过高时启用。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| companion/agents/ | 本仓内 agent 定义的 canonical 目录（部署位是其实体副本快照） |
| 部署位 2 位 | `~/.zcode/agents/`（ZCode 加载）与 `~/.claude/agents/`（Claude 加载，model 行需适配） |
| custom: 式 model 行 | `model: "custom:<provider-uuid>:<slug>"`，ZCode 部署位主流格式（72 文件） |
| 裸式 model 行 | `model: <providerId>/<modelId>`，本任务 GLM 行采用的格式（executor.md 先例） |
| adapt_model_line | lib/install-companion.sh claude 位 model 行降级逻辑（custom:→纯档位名） |
| CPS | 既有 complex-problem-solver agent（sonnet 档失败升级+问题分解），本任务不改动它 |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| GLM-5.3 完整版在宿主模型清单 | ListModels 2026-10-03：`account:zai-individual-coding-plan/GLM-5.3` levels low/high/max | model 行直接引用此 id；默认 max reasoning=Opus 级同档 |
| 裸 providerId/modelId 式 model 行在用 | ~/.zcode/agents/executor.md:5 `model: 9a69b164-b20d-45d8-b424-97109ee483c2/agnes-3.0-flash` | 新 agent model 行格式同构此先例 |
| custom: 式适配链只认 ccr UUID | lib/install-companion.sh:74 `grep -q '^model:.*custom:[0-9a-fA-F-]*:'` | GLM 不在 ccr UUID 下 → 禁用 custom: 式；claude 位须手动 sed model 行 |
| selftest 对 companion agents 仅锚 plan-writer 单文件 | selftest-reliability-institution.sh:28 / selftest-conclusion-discipline.sh:39 / selftest-tool-selection.sh:32 / selftest-knowledge-brief.sh:18 / selftest-methodology.sh:54-55 | 新增 complex-planner.md 零 selftest 破坏；前提=不动 plan-writer.md |
| 路由表登记锚 | ~/.zcode/skills/skill-agent-router/SKILL.md:97（complex-problem-solver 行） | Phase 3 在该行后追加 1 行 |
| agent 类型列表会话启动固化 | memory task-v055-fallback 先例 | 本会话不可派发新 agent 做行为验证（D6） |
| 基线 selftest | master 06b31d8：42 脚本 660/0（v117 终验口径） | Phase 2 回归不降级判据 |
| 并行任务 v118 在跑 | conflict-scan 信号②：/home/terry/task-planner-skill-worktrees/task-v118 | 全程不触碰 wt/task-v118、critical-rules.md、templates/** |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/companion/agents/ | 目录 | 现有 3 文件（article-batch-publisher/article-field-fixer/plan-writer），complex-planner.md 新增于此 |
| ~/.zcode/agents/complex-problem-solver.md | :1-9 | frontmatter 结构先例：name/description/tools/model/thoughtLevel 五字段 |
| ~/.zcode/agents/executor.md | :5 | 裸 providerId/modelId model 行先例 |
| skills/task-planner/lib/install-companion.sh | :70-86 | adapt_model_line：仅 custom: 式降级（sonnet-1→sonnet/opus-1→opus/mini→mini），其余原样通过 |
| ~/.zcode/skills/skill-agent-router/SKILL.md | :97 | complex-problem-solver 路由行范式：`\| **complex-problem-solver** \| 复杂疑难问题…\| 常规任务 \|` |
| scripts/sync-companion.sh | :68-79 | claude_model_to_zcode 反向收编——部署后禁跑（防旧版回灌） |

## §4 易错点与禁止假设清单
1. 禁止用 `custom:9e221f47-…:GLM-5.3` 写 model 行——GLM 不在 ccr UUID provider 下，会解析失败（§2 行 3 证据）
2. 禁止改动 plan-writer.md / 既有 3 个 companion agent / task-planner SKILL.md / critical-rules.md / templates/**（scope 外 + v118 并行任务 scope 重叠风险）
3. 禁止跑 sync-companion.sh（反向回灌陷阱，memory 实锤 09-13）
4. 部署用定向单文件 cp，禁 `rm -rf` 整目录重部署（本任务只加 1 个新文件）
5. 禁止声称"GLM 行为级已验证"——本会话无法派发新 agent，只能结构验证（Rule 43.1 未验证显式登记）
6. description 必须含"仅高复杂度"门控语义——这是用户核心诉求，缺了=防滥用失效
- FMEA RPN>100 兜底指针：本计划 FMEA 最高 RPN=56（Phase 1 model 行格式），无 >100 项；兜底动作已逐行写入 task_plan.md FMEA 表

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1（Phase 1 executor） | §1 + §2 + §4 + §6（全文规格） | 无（规格在本文件 §6 内联） |
| S2（Phase 3 code-assistant） | §3（路由表锚行）+ §6.2（待写入行原文） | 无 |

## §6 交付物全文规格（S1 逐字撰写依据 / S2 行原文）

### §6.1 `skills/task-planner/companion/agents/complex-planner.md` 全文（执行体照此逐字写入，≈55 行）

```markdown
---
name: Complex Planner
description: 高复杂度任务的解决方案深度规划|GLM5.3(Opus级)专属备用方案|仅当任务复杂度过高(跨模块架构级/高不确定/常规档sonnet/haiku同法失败≥2次)才启用|产出可执行分步计划,不直接改代码。触发:complex planning|升级规划|备用方案|任务过于复杂|deep plan。禁用:常规/单文件/低复杂度任务(走 code-assistant/executor)
tools: Read, Grep, Glob, Bash, WebSearch, WebFetch, Agent, TodoWrite
model: "account:zai-individual-coding-plan/GLM-5.3"
thoughtLevel: enabled
---

# Complex Planner（高复杂度规划备用方案）

定位：任务解决的**最后一档规划升级出口**——仅当任务复杂度过高时启用，作为常规档执行体的备用方案；日常任务一律走常规档，禁止滥用。

## 触发门槛（满足任一才接单）
1. 任务本身复杂度过高：跨 ≥3 模块 / 需架构选型 / 约束相互冲突 / 高不确定性
2. 常规档升级链穷尽：haiku/sonnet 同法失败 ≥2 次、拆细后仍失败（五档兜底链②③档出口）
3. 用户显式点名要求大模型深度规划

## 禁用清单（命中任一直接拒单并建议改派）
- 单文件小改 / 机械批量 / 常规搜索 → code-assistant / executor / Explore
- 简单 bug 定位 → debugger（未穷尽五档兜底前不升级到本 agent）
- 任务描述不满 3 行且无依赖关系 → 常规档足够

## 规划产出契约（每次输出必含五段）
1. **问题解构**：核心问题一句话 + 约束/依赖枚举（≥3 层推导）
2. **方案候选**：≥2 个候选 + 对比表（成本/风险/可逆性）+ 推荐项及理由
3. **分步计划**：S-unit 化步骤（每步 ≤2 文件 / ≤100 行 / ≤15min，标注依赖与可并行性）
4. **风险与兜底**：每步失败模式 + 预设兜底动作（对齐五档兜底链）
5. **验收标准**：可观察的完成判定（命令 / 文件 / 输出三选一以上）

## 证据要求（强制）
每个发现/结论必须包含:
- **位置**: `file:line` 或 `URL` 或 `数据源`
- **原文**: 引用原文 ≥10 字符（或数据来源说明）
- **置信度**: HIGH/MEDIUM/LOW
输出前用工具复现关键发现，验证失败 = 删除该结论。

## 禁止行为
- ❌ 不直接 Edit/Write 业务代码（产出计划，执行交回常规档执行体）
- ❌ 不替代常规档做低复杂度任务（防滥用，触发门槛外一律拒单）
- ❌ 不跳过失败分析直接给方案
- ❌ 不虚构依赖/接口——不确定就标注"未验证"

## 输出模板
**[PLANNED/REJECTED]** — 任务一句话
- 复杂度判定: 命中哪条触发门槛 / 或拒单理由 + 建议执行体
- 方案: 推荐候选 + 一句话理由
- 计划: N 步 S-unit 清单（可交 plan-writer / task-orchestrator 直接消费）
- 置信度: HIGH/MEDIUM/LOW
```

### §6.2 Phase 3 路由表待写入行（插在 skill-agent-router SKILL.md:97 complex-problem-solver 行之后，列结构对齐该表）

```
| **complex-planner** | 高复杂度任务（跨模块架构级/高不确定）的解决方案规划、常规档反复失败后的升级规划、大模型深度规划请求 | 常规/低复杂度任务 |
```

（列语义对齐既有表：第 2 列=触发场景，第 3 列=不适用场景；写入前 Read 该表确认实际列数并跟随。）
