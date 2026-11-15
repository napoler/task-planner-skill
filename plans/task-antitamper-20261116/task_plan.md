# Task Plan: task-antitamper-20261116（验证载体防中途篡改条款 — mini stub，L0-lite，零新脚本）
<!-- plan_tier: mini | execution_lane: L1-lite（纯文档条款增量 §11.5②；主进程编排+code-assistant 落段） -->
<!-- 背景：用户 2026-11-16 追问「执行过程中已锁定的验证机制被模型/agent 中途恶意篡改如何遏制」；实测发现 attest 锁面仅覆盖 task_plan.md，verification.md 的 Verify command 行未入哈希锁 -->

## Goal
verification-gate SKILL.md 反作弊规约段增补：严禁清单 #9/#10（中途改判据/改守卫同罪）+「判据冻结协议」段（状态行与判据行分离：回填合法、判据行冻结）——把「执行期篡改验证机制」从行为禁令升格为事件级处置协议（STOP→用户授权→Decisions 登记→attest 重锁）。

## 用户需求锚（Rule 51.1 节选逐字）
- R1 [目标]：「执行过程中就是已经锁定好的验证机制，在后期比如说嗯。模型或者AGENT执行的过程中，发现哎，这个东西解决不了了，那么我就把验证机制给改了吧。那么这样是不是这个事情是如何避免的？……如果在允许模型在中间过程中恶意篡改的话，就意味着前期做的东西，那么就无意义的，所以必须得想办法给遏制住他的篡改。」

## ✅ Verification Contract
| # | 判定 | 验证命令 |
|---|------|---------|
| VC-1 | 严禁 #9/#10 在位 | grep -q "严禁中途修改验证载体判据" skills/verification-gate/SKILL.md && grep -q "严禁修改验证机械层" skills/verification-gate/SKILL.md |
| VC-2 | 判据冻结协议段在位 | grep -q "判据冻结协议" skills/verification-gate/SKILL.md && grep -q "状态回填合法" skills/verification-gate/SKILL.md |
| VC-3 | 纯增量 | git diff numstat 删除行=0（EOF 规范化除外） |
| VC-4 | targeted 回归 | selftest-verification-gate.sh Total 13/0 |
| VC-5 | 全量回归 | run-selftests 与 98/93/5 基线同集零增量 |
| VC-6 | 部署同步 | verification-gate SKILL.md ×3 位 diff=0 |
| VC-7 | 无字形损坏 | 异常字形扫描（HEAD 对照甄别）=0 新增损坏 |

## Phases
- [x] P1 实测锁定面（attest-plan.sh:84,570 仅哈希 task_plan.md；verification.md 仅要求存在未入锁；zcode-userpromptsubmit.sh 每轮重算哈希触发 [PLAN TAMPERED]；当日两次实弹+对方三次合法重锁全 Decisions 登记）
- [ ] P2 SKILL.md 反作弊段增补（code-assistant 代理）
- [ ] P3 回归+部署+commit
- [ ] P4 簿记（含机械强化提案登记：verification.md 判据行入 attest 锁=待用户裁决，动 attest-plan.sh 属基础设施脚本须显式授权）

## 变更标注表（Rule 74.3 — 全增量）
| 编号 | 对象+锚点 | 类型 | 吸收 | 执行动作 |
|------|----------|------|------|---------|
| CA-1 | skills/verification-gate/SKILL.md（严禁清单第 8 条行后） | 新增（第 9/10 条+冻结协议段） | 增量 | 追加两条严禁+冻结协议块 |
