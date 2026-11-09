# progress — task-workflow-multimodel-delegation-20261109

## 2026-11-09 对齐执行（用户“全做”，L0-lite + §6 授权范围：workflow-model-tiers 部署位对齐已在对话中明确请求并获“全做”授权）

### 证据（已验证）
- `ListModels`：CCR 四档可见 `9e221f47-3040-4ea7-b742-20b813fb79aa/{opus-1,sonnet-1,fast,haiku-1,mini}`；current=`opencodego/iceman-contributor-free`。
- `selftest-workflow-orchestration.sh`：WF-17..22/全量 **22 PASS 0 FAIL**（修正 91.5 后复跑通过）。
- `EvalWorkflowSnippet`（已加载 dynamic-workflows）：最小 `return {facade:"snippet",ok:true}` **PASS 865ms**；含 `model(".../fast")+agent(...,{model}).ask()` 的 snippet **typecheck FAIL**：`Cannot find name 'model'/'agent'`（与 bundled SKILL §16.6 一致：snippet 不含 `model/agent/report/artifact/hole/phase`）。→ **EvalWorkflowSnippet 不能作为 per-agent model 生效验证**，Rule 91.5 已修正。
- Draft 采纳现状：`.zcode/workflows/task-v171-skill-specialization.dwf.ts` 等 `agent()` 仅 `{system}`，扫描 drafts/workflows **无 `model:`/`MODELS=` 分档采用**（0 采纳，历史记忆一致）。

### 落地（源仓，已完成）
- `skills/plan-collab-router/references/critical-rules-collab.md`：**91.5 修正**为分通道可执行验证（EvalSnippet 限制 + per-agent 走 CreateWorkflow 最小 smoke + 失败显式退化 run 级 `subagent_model`，禁悄悄降档 91.7）。
- `skills/task-planner/scripts/selftest-workflow-orchestration.sh`：**WF-20** 锚同步（含 91.5 头 + EvalSnippet 限制 + CreateWorkflow 路径）。
- `skills/workflow-model-tiers/SKILL.md`（**源仓真源新增**）：Rule 91 对齐版（91.2 矛盾披露、91.5 可执行验证、91.6 literal、91.7、91.10 ListModels、CreateWorkflow smoke + run 级退化、反模式；CCR UUID 标注“本机示例/迁移必核实”）。
- `skills/task-planner/companion/agents/plan-writer.md`：接线 Rule 91（run 级 `subagent_model` + A/B 分档策略 + 91.5 留痕 + 失败退化/91.6/91.10）。
- `skills/plan-template-kit/references/template-mapping.md`：§十 workflow 行 + Rule 91 接线说明块。

### 落地（部署位，§6）
- `~/.zcode/skills/workflow-model-tiers/SKILL.md`：已对齐为源仓版本（用户“全做”含第1项 §6 授权；变更=删除“官方 §2/patterns #13 已支持/UUID 直接复制”冲突表述，加入 91.2/91.5 可执行验证/退化/迁移/反模式）。若用户要求回滚可 `cp` 源仓前不适用（源仓此前无该文件；部署位旧版已被本次对齐覆盖，需从会话/备份恢复）。

### 待执行（受工具/UI/确认约束）
- **CreateWorkflow 最小 smoke（91.5 per-agent 生效验证）**：需发起真实 `CreateWorkflow`（会触发用户确认）。预期：编译/启动通过+返回 per-agent 结果即证据；失败/拒绝→记录并退化 `subagent_model`（91.7）。
- **1 个 draft 试水**：候选 `.zcode/workflow-drafts/项目缺陷审查与修复.设计缺陷审查方案.dwf.ts` 改为 `MODELS` 表 + compile-time literal + 最小可承载分档；仅在 smoke 结论明确后落盘/运行验证；不盲改 20+ drafts；`SaveWorkflow` 不执行（无显式要求）。


## 2026-11-09 C smoke（Rule 91.5 per-agent model，可执行证据）
- dynamic-workflows skill：本轮已加载（Skill tool）。
- CreateWorkflow 最小 smoke：`Rule91-per-agent-model-smoke`（run `dwfrun-bd46e936-0778-4f32-bcd2-da4ca30fcb83`）**已编译通过并后台启动**（2026-11-09，本会话 CreateWorkflow 返回）。脚本含 `model("9e221f47-3040-4ea7-b742-20b813fb79aa/fast")`(compile-time literal,91.6)+`agent(...,{model:light})`+可观测 JSON 输出。CreateWorkflow 回执：Models named `"9e221f47-3040-4ea7-b742-20b813fb79aa/fast" = 9e221f47-3040-4ea7-b742-20b813fb79aa/fast$enabled`。draft：`.zcode/workflow-drafts/Rule91-per-agent-model-smoke.dwf.ts`。
- **证据状态（91.5，已闭合）**：2026-11-09，CreateWorkflow run `dwfrun-bd46e936-0778-4f32-bcd2-da4ca30fcb83`（`Rule91-per-agent-model-smoke`，draft `.zcode/workflow-drafts/Rule91-per-agent-model-smoke.dwf.ts`）**completed**，可观测输出：`{"smoke":"rule91.5","modelSyntaxAccepted":true,"result":{"ok":true,"tier":"fast","echo":"rule91-smoke"}}`。CreateWorkflow 回执显示模型名解析/enabled：`9e221f47-3040-4ea7-b742-20b813fb79aa/fast$enabled`。结论：**本机/本会话证据表明** per-subagent `model()` + `agent(...,{model})` 的 CreateWorkflow 编译/启动/运行与可观测产出均通过（受限于单次 smoke；91.2 仍成立——类型层/单次生效≠跨机/长期“官方支持”保证）。跨机/他环境使用前仍须 `ListModels`+同法 smoke（91.10/91.5）。
- 试水 draft（1 个，未盲改其他）：`.zcode/workflow-drafts/rule91-multimodel-trial.设计缺陷审查方案-MODELS试水.dwf.ts`（MODELS 表 + light 并行确认；自包含 survey/hole；CCR id=本机示例 91.10）。待 smoke 结论后再决定是否以 CreateWorkflow 验证/推广；不 SaveWorkflow 未获同意。
