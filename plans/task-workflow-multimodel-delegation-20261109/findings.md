# findings — task-workflow-multimodel-delegation-20261109

## 根因：workflow 多模型“无效/不生效”的三类缺口
1. **验证门不可执行（P0）**：Rule 91.5 原要求用 `EvalWorkflowSnippet` 验 `model()/agent({model})`；但 bundled dynamic-workflows §16.6 snippet facade **不含 model/agent/report/artifact/hole/phase**。实测 snippet 报 `Cannot find name 'model'/'agent'`。→ 规则给出的门在 per-agent 场景不可达，作者无可靠生效路径。
2. **技能与规则冲突 + 真源缺失（P0）**：部署位 `workflow-model-tiers` 声称“官方 §2/patterns #13 支持、UUID 可直接复制”，与 Rule 91.2 矛盾披露冲突；源仓无该技能目录。→ 发现性差且易误导。
3. **采纳率 0（P1）**：扫描项目 workflows/drafts，`agent()` 仅 `{system}`，无 `MODELS`/`model:` 分档。仅有规则文本不足以改变脚本行为；plan-writer/template-mapping 缺 91.1/91.5 留痕/退化接线。

## 机制事实
- bundled facade 存在 `model(id: string): ModelRef`、`AgentPersona.model?: ModelRef|string`（类型层）；`model()` 参数须 compile-time literal。
- per-agent model 运行期生效仍需 harness 实证；失败时唯一合规路径=显式退化 run 级 `subagent_model` + 留痕（91.7），不得悄悄降档。
- CCR UUID 本机特定，迁移前 `ListModels`（91.10）。

## 已对齐
- 91.5 改为分通道可执行（EvalSnippet 仅非 agent 逻辑；per-agent→CreateWorkflow 最小 smoke）。
- WF-20/selftest、workflow-model-tiers 源真源+部署位、plan-writer、template-mapping 同步。
