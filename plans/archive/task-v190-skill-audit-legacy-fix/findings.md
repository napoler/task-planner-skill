# Findings & Decisions

## Research Findings
- **2026-10-19/20（执行轮）**：3 项 legacy 修复（register-hooks-cj.ts L98 process.unlinkSync→fs.unlinkSync / split-pattern-library SP-03 伴飞表路径硬编码→~ 波浪号化 / tier-b TB-02 mini 保护区放行收紧），worktree 执行 merge 3b50e02，delivery-summary=e52b88d
- **2026-10-26（收口轮）**：误判纠正——本计划曾被误判「v189 幽灵副本」拟删（仅比对 progress.md 单文件所致）；实况核查（delivery-summary 差异+git 链 f6593e8/3b50e02/e52b88d+复验 unlinkSync 与 13/13+18/18）证实为真实完成工作 → 改收口归档，outcome=PARTIAL（Phase 3 历史直改如实登记）
- **复验证据**：skills/task-planner/scripts/register-hooks-cj.ts:21,98；/tmp/selftest-final2-20261026.log（split-pattern-library 13/13、tier-b 18/18——v189 交付时 2 项 pre-existing FAIL 已由本计划清零）
