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
- **Status:** complete
- Executor: 主进程（L0 通道：⑥ 扩展口径首次行使，登记于本行）

### Phase 2: B 类扩展（2026-10-02 用户裁决「1,2」）：部署同步+videop1 归属
- **执行**（授权后即时）：claude/opencode 全量同步（部署后 diff=0 七批全收敛）；zcode 合入式（排除 videop1 面）
- **videop1 归属裁决**：双轨保留——zcode 位 videop1 资产（variant 28 体系+guide/mapping/plan-writer 3 分叉文件）不覆盖（其项目运行态）；主仓 17 体系继续演进；回流收编列专项建议（需 videop1 侧共同确认）
- **对账**：claude/opencode vs 主仓 0 差异；zcode 差异 28 项全部落在预期保护面（variant+2 分叉文件），其余 8 skill 零差异；池软链健康；Rule 45/22.3.0/38.7/delivery-summary 探针三宿主全中
- **备份**：/tmp/deploy-backup-20261002-1803/（三宿主 tar，回滚可用）
- **Status:** complete
