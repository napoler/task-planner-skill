# Findings & Decisions — task-v132

## Requirements（解释——原文锚定见 task_plan.md 🎯 区块）
- G1-G4=72h 事故修复提案 §6 的 P1/P2 缺口（授权链=gap 文档头注）；R5=与 v131 机制零冲突约束

## Research Findings
- **权威解析器事实**：scripts/resolve-interaction-mode.sh 四级口径 env→计划配置表→mini 缺省→config.json；init 原 silent 判定仅 env=偏离（ALIGN-P1b，已修）
- **级联第 5 变体判例**：负断言裸子串（'1-51'）被新合法文案（「51.1-51.7」）误触——负断言必须语境锚定
- **R 行提取口径**：交叉引用（「另见 R9」「(R3 重申)」）不得计为需求编号——行首锚定提取（CR-P1 修复实证）

## 锚清单（VC-1 证据）
- critical-rules.md:567 `51.7 **纠正=回锚重译`=1；:559 判例+报告路径=1；51.6 七子条锚+R-COVERAGE 已落地同步=1

## 机器面（VC-2/3 证据）
- check-window-consistency.sh：六边界用例+attest 接线 warn 级实测（[window-lint] 行+锁成功）
- check-complete.sh rcov-gate：三态六例+v131 计划输出逐字节零回归

## G3（VC-4 证据）
- hook :74 文案锚=1；init 两级落锁三路径（env/resolver/ask 零落锁）实测；四锚硬门不可被 --skip 绕过

## Issues Encountered
- CR 首轮 P0 状态异常：worktree check-complete.sh 被未暂存删除（归属未明）→ git restore+复核在位
- 复审链：3×P1+4×P2 全处置；P2 余项=resolver 占位行遮蔽（deferred）+修复批范围扩权（Decisions 补登记）

## Resources
- 事故报告：plans/incident-reports/2026-10-05-72h-instruction-mutation.md；缺口：同目录 *-remediation-gap.md
- 检查点：subagent-state/01-08；审查：06-code-reviewer.md 两轮
