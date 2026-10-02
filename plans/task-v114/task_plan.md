# Task Plan: task-v114 执行通道分级规范（L0/L1/L2 比例原则）
<!-- L0 轻量通道示范执行：本任务自身按 L0 跑（单 Phase/主进程直做/相关 selftest 子集/薄簿记） -->
<!-- template_type: rule-enhancement -->

## Goal
在 critical-rules.md Rule 38 后扩展「执行通道分级」（比例原则）：流程开销与变更体量成比例——L0 微变更（≤3 文件且 ≤20 行，纯文档/注释/定数级联/规范括注）走轻量通道（单 Phase/主进程直做白名单⑥扩展/相关 selftest 子集/精简交付），L1=现行 standard，L2=重大全量。消除「15 行变更跑 1 小时全量仪式」的流程膨胀。

## Verification Contract
| # | 判定标准 | 验证 |
|---|----------|------|
| VC-1 | Rule 38.7（执行通道分级）三档条款落地+白名单⑥引用 | grep |
| VC-2 | 全量 selftest 回归 0 FAIL（单波 fresh 终验） | 42 rc |
| VC-3 | memory 条目+交付报告按 v112 模板精简输出 | Read |

## 执行范围
critical-rules.md（Rule 38.7 新增子条）+SKILL.md（Rule 38 摘要行括注）——字面锚零改动（括注模式）。

## Phase
### Phase 1: 修订+回归+交付（L0 单 Phase）
- 主进程直做（白名单⑥+②：修订本体为规范文本 ≤30 行；worktree 隔离；相关 selftest（plan-tier/skill-split/knowledge-brief）+单波 fresh 全量终验；精简簿记）
- Status: in_progress
- Executor: 主进程（L0 通道：⑥ 扩展口径首次行使，登记于本行）
