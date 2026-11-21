# Findings — task-json-state-20261121（调研与设计结论）

## F1 根因：正则抽取是病根之一（双会话实测）
- 会话 sess_336448d4（综艺设计）跨度 ~16h39m / 29 子代理，6 个 opus critic 在计划审计 R1→R9 烧 ~62min / 1270 万 token，问题全在 VC 正则假绿/误伤/漏匹配。
- 会话 sess_63ca5ece（一集剧本重构）墙钟 ~10h11m / 20 子代理，计划审计 R1/R2 两次 REJECTED；Phase3 首派零落盘重派、QC blocker 修正+双轨复审链。
- 结论：慢的主因是流程 overhead + 返工放大，正则从半结构化 MD 抽状态是返工的技术根因。

## F2 机器门契约（shim 设计依据）
- check-vc-nonvacuous.sh：调用 `bash ... <plan-dir>`，stdout 前缀 `[vc-nonvacuous]`，rc 0/1/2，被 attest-plan.sh:312 与 check-complete.sh:813 调用。
- check-rvc-coverage.sh：前缀 `[rvc-coverage]`，读 task_plan.md，被 attest:345 / check-complete:857 调用。
- check-plan-audit-gate.sh：前缀 `[audit-gate]`，含 lane/tier 预判与 `[plan-audit-skip]`/legacy-no-decl SKIP，被 attest:583 调用；progress 缺失 rc2 在 enforce 下拒锁。
- check-evidence-anchor.sh：coverage/goal 双源 + provenance + claim-mismatch，语义与 planctl evidence 不等价，1:1 替换会丢能力 → 迁移期不改。
- attest 缓存键含门 env + sha256(progress.md)，必须追加 plan-state.json hash 否则回放陈旧判定。
- init-session.sh 插入点：6/6 verified 后、silent attest 前（约 :1015-1135）。

## F3 设计决策
- 格式：用户裁决 JSON 权威 + MD 视图（Python 标准库零依赖、schema 可校验、无缩进/类型歧义）；脚本语言用户显式指定 Python（优先于默认 Bun+TS）。
- 兼容策略：外契约不变 + 双读 fallback——存量计划无 plan-state.json 走原正则，新计划走 planctl JSON 判定，零回归。
- 不迁内容：user-session-log.md（逐字 append-only）、knowledge-brief.md（自然语言知识）。

## F4 遗留风险（迁移期）
- JSON 模式仍要求 MD 视图在位（vc→verification.md/rvc→task_plan.md/audit→progress.md），纯 JSON 目录走 rc2；为保外契约有意保留。
- planctl rvc PASS reason 无"映射行"概念，shim 填 0。
- check-evidence-anchor 待 planctl 补 source/claim/provenance 模型后再切换。
