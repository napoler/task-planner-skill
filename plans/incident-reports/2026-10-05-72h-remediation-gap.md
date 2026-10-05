# 事故修复缺口登记：一个月→72小时（2026-10-05）

> **用途**：task-v131（并行 /goal 会话，wt/task-v131）承载了事故报告 §6 的 P0 三项；本文件登记其**未覆盖**的 P1/P2 缺口，供 v131 合并回 master 后的 gap-fill 任务（建议 task-v132）直接消费。完整提案原文见 [2026-10-05-72h-instruction-mutation.md](./2026-10-05-72h-instruction-mutation.md) §6。
> **授权状态**：用户已于 2026-10-05 显式授权「授权彻底修改」——授权范围=事故报告 §6 全部六项。

## 覆盖矩阵（2026-10-05 07:5x 核验）

| 事故报告提案 | v131 承载情况 | 证据 |
|---|---|---|
| P0-1 需求原文区块入模板（载体） | ✅ 已落地（机制升级：init 注入单点全覆盖 29 variant + 主模板/rule-enhancement 变体补可见区块） | commit 9924b0a（Phase 2） |
| P0-2 attest 前置门验块 | ✅ 已落地（attest 51.1 三锚门，VC-3 负例+正例双测） | commit 9924b0a（Phase 2） |
| P0-3 派发载荷需求锚携带校验 | ✅ 已落地（派发需求锚） | commit 535be31（Phase 3） |
| P1-1 check-complete 覆盖表核对落地（51.6 deferred） | ⚠️ 部分（仅"根源覆盖表脚手架"@Phase 3；check-complete.sh 的 R-COVERAGE 机器门未见） | v131 计划 grep 零命中 |
| P1-2 纠正回锚纪律 + 窗口口径一致性 lint（51.7） | ❌ 未覆盖（无 51.7 子条/回锚/口径 lint 任何踪迹） | task_plan/findings/progress grep 零命中 |
| P1-3 silent 补偿：锚哈希即时落盘 + hook 重锁指引收紧 | ❌ 未覆盖（userpromptsubmit.sh 零触碰） | 同上 |
| P2 判例沉淀（51.1 判例库追加本事故） | ⚠️ 部分（Phase 4 已加 selftest-root-resolution RR-01..15 守卫；判例追加未确认） | commit 75e717c |

## gap-fill 任务书要点（G1-G4）

**开工前置（全部满足才启动）**：① wt/task-v131 已合并回 master（Phase 8 提交在 master）且 worktree/分支已清理；② 四位部署同步已完成（v131 Phase 8 内容）；③ 主仓无与 scope 重叠的未提交变更。**基于 v131 已落地机制实施，禁止与 init 注入/attest 三锚门/派发需求锚重复或冲突。**

- **G1（=P1-1）**：`skills/task-planner/scripts/check-complete.sh` VC-GATE 外增 R-COVERAGE 门——delivery-summary『需求覆盖核对』区块行数=计划 R 行数、状态枚举 covered/partial/uncovered 且带证据路径、任一 R uncovered/partial 且无 Decisions 让步登记→拒 COMPLETE 只可 PARTIAL；档位复用既有键 `vc_gate_enforce`。selftest：RC 锚+负例（缺行/裸 uncovered 无让步→不得 COMPLETE）。
- **G2（=P1-2）**：`references/critical-rules.md` Rule 51 增 51.7 子条「纠正=回锚重译，非设计增量」（纠正原话追加为新 R 行不改写旧行；受影响 VC 同步改写+Decisions 登记纠正编号；重建执行体前重过 attest/dispatch 门）+ 通用窗口口径一致性 lint（从🎯锚定行提取需求窗口词→扫描计划与载荷计量窗口词，口径不一致即警报，**不绑死 72h 字面**；负例须含「一个月→7 天」样张）。selftest：51.7 文本锚+lint 正/负例。
- **G3（=P1-3）**：`~/.zcode/hooks/zcode-userpromptsubmit.sh` 重锁文案收紧（:64 一带：『无 Decisions 纠正/让步登记的重锁视为篡改信号』）+ init-session.sh silent 路径锚哈希即时落盘 `.plan-attestation`。selftest：hook 文案锚+init 静态锚。
- **G4（=P2 判例）**：critical-rules.md 51.1 判例库追加本事故（『一个月→72小时两次改写、四环绿灯，2026-10-05』，报告路径作锚）。

**执行要求**：走 task-planner 全流程（init-session+🎯 需求原文锚定+worktree+attest+selftest+CR）；新子条用 51.7 编号（Rule 51 内子条，无新顶格编号，开工仍先跑 rule-reserve.sh check 确认）；验收断言沿用事故报告 §6 各条。
