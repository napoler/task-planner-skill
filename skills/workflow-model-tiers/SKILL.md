---
name: workflow-model-tiers
description: 工作流模型分档（Rule 91 对齐）— 在 dynamic-workflow 脚本内按任务力度为子代理分配 CCR 四档（opus/sonnet/fast/haiku）；须遵守 Rule 91.2 矛盾披露、91.5 可执行验证前置、91.6 编译期 literal、91.7 禁悄悄降档；run 级 subagent_model 仅作退化兜底
trigger: 工作流分档 / workflow 模型 / 子代理模型 / 模型力度 / CCR 分档 / dynamic-workflow 模型 / 重任务轻任务 / model tiers / 工作流省 token / 工作流模型选择 / Rule 91
---

# 工作流模型分档（workflow-model-tiers，Rule 91 对齐版）

> 解决痛点：`CreateWorkflow` 的工作流若不显式指定档位，子代理易落到同一默认档位，分诊/格式化与架构规划同价。  
> 本技能给出：CCR 四档映射 + 脚本写法 + **与 Rule 91 一致的矛盾披露/验证/退化纪律**。  
> **权威规则**：`plan-collab-router/references/critical-rules-collab.md` **Rule 91**（91.1-91.12）。本技能是用法载体，不得弱化 Rule 91。

## 0) 先读：矛盾披露与可执行验证（P0，Rule 91.2/91.5）

- **91.2 官方文档矛盾披露（不得删改结论）**：bundled dynamic-workflows 的 SKILL 描述曾表述 “there is no per-subagent tool profile or model choice”，且不存在所谓官方 “§2 Per-subagent model / patterns.md #13” 的可证章节；`AgentPersona.model` / `model()` 虽在 facade 类型层存在，但 **“类型层存在 ≠ 当前 harness 运行期生效/被接受”**。因此 per-subagent 模型分档在本仓按 **用户级脚本约定** 对待，**禁止盲目背书为已被官方保证生效**。
- **91.5 验证前置门（分通道、可执行）**：首次使用 `model()` / `agent(name,{model})` 前必须做**可执行验证并留痕**（日期 + 工具 + 结论 + 失败退化动作）。
  - **`EvalWorkflowSnippet` 不能验证 per-agent model**：其 snippet facade 含 `args/run/log/files/git/world.run/channel/future`，**不含** `agent()/report()/artifact.*/hole()/phase`，亦**不含 `model()`**（bundled SKILL §16.6）。EvalWorkflowSnippet 仅可验非 agent 逻辑/`world.run`。
  - **per-agent model 的生效验证**：走 `CreateWorkflow` **最小烟雾 run**（脚本内用 compile-time literal 的 `model()` + `agent(...,{model})` 最小调用），以 **编译/启动通过 + 运行结果或可观测产出** 为证据；遵守 CreateWorkflow 确认/动态工作流契约。
  - **验证不通过 / harness 拒绝 / 运行期不生效**：**禁止悄悄降档、禁止假装生效**（91.7）。退化为 run 级 `subagent_model`（全 run 统一档位，见 91.3）并在 plan/progress 留痕。
- **91.6 编译期约束**：`model()` 参数必须是 **compile-time string literal**，禁止变量/拼接（`model(PREFIX + "/opus-1")` 会失败）。
- **91.7**：运行中模型不可用不许 try/catch 悄悄降档；按 Rule 22.3/model-routing 重试/报告，保持用户批准的拓扑或显式记录退化。
- **91.10 跨机器迁移**：CCR provider UUID/前缀是**本机特定**；迁移前用 `ListModels` 核实本机 `opus-1/sonnet-1/fast/haiku-1` 的完整 id，必要时以一次小规模 smoke 确认后再跑大流。**下表 ID 仅为“本机会话实测存在的示例”，不得跨机盲抄。**

## 1) 四档映射（CCR，示例 id — 使用前 ListModels 核实 91.10）

| 力度 | 角色示例 | 本机会话可见示例 id（compile-time literal，迁移必核实） |
|------|----------|--------------------------------------------------------|
| heavy（重） | 规划/架构/综合/深度分析/最终质量兜底 | `9e221f47-3040-4ea7-b742-20b813fb79aa/opus-1` |
| medium（中） | 开发/调试/评审/测试/常规撰写 | `9e221f47-3040-4ea7-b742-20b813fb79aa/sonnet-1` |
| light（轻） | 查找/提取/格式化/模板填充 | `9e221f47-3040-4ea7-b742-20b813fb79aa/fast` |
| minimal（最轻） | 分诊/路由/二元判断/格式校验 | `9e221f47-3040-4ea7-b742-20b813fb79aa/haiku-1` |

判定对齐 `model-routing`/Rule 43.2（最小可承载档位）。禁止全流统一强档（91.8），禁止分诊/格式化上 opus。

## 2) 用法 A：已知拓扑的固定分档（仅在 91.5 验证通过或已记录生效后）

```ts
// 每个 model() 参数必须是编译期 string literal（91.6）。ID 先经 ListModels 核实（91.10）。
phase("规划与执行分离");
const plan = await agent("规划员", {
  model: "9e221f47-3040-4ea7-b742-20b813fb79aa/opus-1",
}).ask<Plan>("分析需求，产出分步计划。");

const code = await agent("开发员", {
  model: "9e221f47-3040-4ea7-b742-20b813fb79aa/sonnet-1",
}).ask<Patch>("按计划实现：" + JSON.stringify(plan));

const tidy = await agent("格式整理员", {
  model: "9e221f47-3040-4ea7-b742-20b813fb79aa/fast",
}).ask<string>("把 patch 描述整理成三行摘要。");
```

## 3) 用法 B：MODELS 表 + 轻量分诊路由（多子代理/力度不定时）

```ts
// 声明一次，AmendWorkflow 改档只动表；字面量 id（91.6），迁移先 ListModels（91.10）
const MODELS = {
  heavy:   model("9e221f47-3040-4ea7-b742-20b813fb79aa/opus-1"),
  medium:  model("9e221f47-3040-4ea7-b742-20b813fb79aa/sonnet-1"),
  light:   model("9e221f47-3040-4ea7-b742-20b813fb79aa/fast"),
  minimal: model("9e221f47-3040-4ea7-b742-20b813fb79aa/haiku-1"),
};

interface Route { tier: "heavy" | "medium" | "light" | "minimal"; }
interface Task { id: string; brief: string; }
const tasks: Task[] = [/* world/args 提供 */];

phase("按力度分诊并执行");
const results = await Promise.all(
  tasks.map(async (task, index) => {
    const route = await agent(`分诊-${index + 1}`, { model: MODELS.minimal })
      .ask<Route>(`判断任务档位 heavy|medium|light|minimal：${task.brief}`);
    return agent(`执行员-${task.id}`, { model: MODELS[route.tier] })
      .ask<Result>(task.brief);
  }),
);
```

要点：分诊器用最轻档且只选已批准档位；fan-out 内禁止重复 `model()` 声明；遵守 dynamic-workflows 拓扑/phase/报告契约。

## 4) 退化路径（验证失败或运行期不生效时的唯一合规动作）

- **不在脚本内写 per-agent model**；改用 `CreateWorkflow`/`AmendWorkflow` 的 run 级 `subagent_model` 统一定档（91.3）。
- 在 plan `progress.md`/脚本注释记录：验证命令/工具、失败证据、退化为 `subagent_model=<id>`、日期。
- **禁止** try/catch 偷降档、禁止无证据声称“已分档生效”。

## 5) 反模式

| 反模式 | 处理 |
|--------|------|
| 声称“官方 §2/patterns #13 已支持”并跳过验证 | 违反 91.2/91.5，必须删改并补验证/退化 |
| 用 EvalWorkflowSnippet 验证 `model/agent` | 无效（facade 不含），改走 CreateWorkflow 最小 smoke |
| `model()` 变量拼接 | 违反 91.6，编译失败 |
| 失败后悄悄降档/无痕退化 | 违反 91.7，必须留痕显式退化 |
| 跨机盲抄 CCR UUID | 违反 91.10，先 `ListModels` |
| 未经用户同意 `SaveWorkflow`/盲改全部 drafts | 禁止；只做授权范围内的 1 个试水 + 确认后再推广 |

## 6) 与相邻规则

- `model-routing`：Agent() 层自检/降级禁令；本技能是 workflow 脚本层分档载体，重试/不可用仍按 model-routing/22.3。
- `dynamic-workflows`（bundled）：拓扑/phase/gate/artifact/hole/report 契约以其为准；本技能只覆盖 model 分档与 Rule 91 对齐。
- Rule 39（编排触发）/68.3（组内异构）/43.2（最小可承载）：见 Rule 91.9。
