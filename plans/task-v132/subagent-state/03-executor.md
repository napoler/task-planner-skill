# Checkpoint — 03-executor（task-v132 Phase 2 S2: R-COVERAGE 门）

写入时间：2026-10-05；状态：本 S-unit 完成，未 commit（任务书要求）。

## 已完成步骤
1. Read 计划三文件 + knowledge-brief + worktree 中 check-complete.sh 全貌（VC-GATE 段 :612-781、档位 resolve_vc_gate_tier :621-631、既有各门范式）
2. 在 worktree `skills/task-planner/scripts/check-complete.sh` VC-GATE 块后（:782 起）新增 R-COVERAGE 段，净增 136 行（git diff --stat 确认仅此 1 文件改动；另有 Phase 1 遗留 M critical-rules.md + ?? check-window-consistency.sh 非本单元产物）
3. `bash -n` 语法通过
4. 实测 a-d 四例 + e/f 两边缘（夹具 /tmp/v132-rcov/，基础=v131 计划 7 R 行 + 含「需求覆盖核对」的 delivery-summary）
5. 零回归：plan-a 既有各门输出与主仓基线逐行恒同（剔除新增 rcov-gate 行）；v132 自身计划基线 vs 新版 stdout/stderr 逐字节一致

## 门实现要点（Rule 45 注释已随代码落盘）
- 锚字面量 `rcov-gate`，grep 计数=5 行: :809/:814/:903/:907/:913（worktree 文件行号）
- 触发：计划「🎯 用户需求原文」区块 `- **R<n>**` 行 ≥1；无区块/R 行=0 → SKIPPED INFO（:809）；mini（PLAN_TIER_MINI=1）整段豁免；档位 off 整段豁免
- 校验对象：`<plan-dir>/delivery-summary.md`「需求覆盖核对」区块数据行（首列 R<n>）：
  ① R 编号双向对齐计划 R 集合（缺行/多行=违规）
  ② 状态 ∈ covered/partial/uncovered（状态列缺失=违规）
  ③ covered/partial 证据区判定=非空 ∧ ∉{无,—,N/A}（原「含 / 或 . 字面」口径经 v131 R7「同 R3」式引用实测误伤，已放宽并注释）
  ④ partial/uncovered 且计划 Decisions Made 无对应让步登记（Decisions 区块内同时含该 R 编号+让步/uncovered/partial 关键词行）→ 违规；已登记让步 → 不阻断，PARTIAL 语义提示（enforce 亦 exit 0，文案「完成状态只可 PARTIAL」）
- 档位：复用既有 `VC_GATE_TIER`（env TASK_PLANNER_VC_GATE_ENFORCE > config.json vc_gate_enforce > 默认 warn），零新 config 键
- delivery-summary.md 不存在 → SKIPPED fail-open INFO（FMEA F1 兜底，:814）
- 插入位在 C-2 四元键③哈希锚区间（:478 sed 至 :502 行）之外，键哈希零扰动

## 实测结果（原文在 /tmp/v132-rcov/outputs/，摘要在 /tmp/v132-rcov/results.md）
| 例 | 夹具 | warn | enforce |
|----|------|------|---------|
| a) 7/7 covered 带证据 | plan-a | exit=0 无 rcov-gate 行（PASS 静默） | exit=0 PASS 静默 |
| b) 缺 R5/R6 | plan-b | WARNING「缺口: R5(核对表缺行) R6(核对表缺行)」exit=0 | FAILED exit=1「拒 COMPLETE 只可 PARTIAL」 |
| c) 裸 R8 uncovered 无让步 | plan-c | WARNING「R8(uncovered 且 Decisions 无让步登记)」exit=0 | FAILED exit=1 |
| d) R8 uncovered+Decisions 让步 | plan-d | PARTIAL 提示 exit=0 | PARTIAL 提示 exit=0（不拒） |
| e) 无 delivery-summary | plan-e | SKIPPED fail-open INFO | 同 |
| f) 无🎯区块 | plan-f | SKIPPED INFO | 同 |

零回归证据：
- plan-a baseline(主仓原脚本) vs 新版：剔除 rcov-gate 行后 STDERR-IDENTICAL、STDOUT-IDENTICAL（warn/enforce 双档）
- v132 自身计划：基线 vs 新版 stdout/stderr 逐字节一致，均 exit=1（3-File Gate findings.md stub=既有判定，非本门引入）

## 遗留 / 交棒
- 本 S-unit 负例 selftest（RC 锚 + 缺行/裸 uncovered 用例）按任务书由下一 S-unit（S3）落入 selftest-requirement-coverage.sh RC-16..20
- 未 commit；worktree 内当前 git status：` M references/critical-rules.md`（Phase 1 产物）、` M scripts/check-complete.sh`（本单元）、`?? scripts/check-window-consistency.sh`（Phase 2 S1 产物）
