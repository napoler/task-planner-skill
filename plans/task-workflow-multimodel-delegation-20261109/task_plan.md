---
template_type: l0-lite
plan_tier: mini
task_id: task-workflow-multimodel-delegation-20261109
status: done
---
# Goal
对齐 workflow 多模型分档使其生效 + 压缩主代理工作量（委派优先）。
范围：验证 dynamic-workflows per-subagent model 实效（EvalWorkflowSnippet/Rule 91.5）；修正 workflow-model-tiers 技能与 Rule 91 矛盾并同步源/部署位；给出现有 workflow 脚本采纳路径。
# VC-1
grep/Read 复验：Rule 91 矛盾披露/91.5 在位；workflow-model-tiers 不再声称官方支持且含验证前置；EvalWorkflowSnippet 证据记录。
# Scope
skills/workflow-model-tiers、plan-collab-router/Rule 91 引用面、workflow drafts 采纳说明；不改 workflow 引擎代码。
# 豁免
L0-lite：VC≥2 表/3-file 回填/G-gates/归档 按需最小化；主代理仅编排+最小授权改动。

## Done (2026-11-09)
- 91.5 smoke: dwfrun-bd46e936 completed (ok/tier fast, fast$enabled).
- 源/4 平台(~/.zcode,~/.agents,~/.claude,~/.cursor skills)已同步 5 文件；origin/master=9126c3c。
- 试水 1 draft 未运行/未推广/未 SaveWorkflow。
