# Checkpoint: S2 executor（Phase 1 取证 — check-drift 3a/3b/3c）

- 时间：2026-09-27；基线 master 0b2208b；本 S-unit 只读取证，仓内零源码修改（仅计划簿记三件：findings.md/progress.md/checkpoint）
- 状态：**done**（3a/3b/3c 根因三锁定，夹具 5 套正反对照，全程逐段实测输出为证）

## 最终结论（必入检查点）
1. **3a 初值误报根因**：check-drift.sh:122 `local prev_status="pending"` 初值虚构「虚拟 Phase 0=pending」→ :138 判定使扫描区间内**首个状态行=complete 即违约**。fixture-a（complete×3，ALIGNED 全完成）与 fixture-c（complete,in_progress,pending 正常推进）均误报 `[DRIFT-CRIT] PHASE-SKIP` rc=1/drift_score=3；fixture-b（pending,complete,pending 真越级）正常报警（报警路径存在）；fixture-d（pending,in_progress,complete）PHASE-ORDER INFO rc=0。缺陷面比登记宽：非仅「全 complete」，条件=首状态行 complete，误报文案与真越级无法区分。修复最小面=:122 一行初值改中性（或首状态行特判）。
2. **3b 双层叠加根因**：第一因=3c 区间 awk（表体永不进入管道，grep '|' 后恒 0 行）；第二因=:208 `sed 's/.*|//;s/|.*//'` 对标准竖线收尾行恒空（`s/.*|//` 贪婪吞至行尾竖线）。P8 探针隔离实证：竖线收尾两列→空、无尾竖线两列→正确取允许列、无尾竖线三列→取到禁止列（错列反向风险）。仅修区间不修 sed 则 SCOPE-NONE 依旧（竖线收尾表）/禁止项误当允许项（无尾竖线三列表）——两处必须同修。S32 登记「两列取不到允许列」真实机理=取空，非取错列。
3. **3c 区间 awk 根因（实测精确化登记）**：gawk 5.2.1 下 `/^## ⚠️ 执行范围限制/,/^## /` 起始行同配终止 → 区间闭合于起始行自身，输出恒为标题 1 行（非字面空；管道效果等同恒空）；scope 区置于 EOF 同样仅 1 行（P6，无任何文件形态可取到表体）；mawk 行为一致（跨实现语义，修复勿赌实现差异）；非重叠终止模式（P4）与状态机形（P5）均正常。仓内 4+ 处已状态机化（check-skill-modify.sh:69、check-plan-dispatch.sh:94、check-complete.sh:31/:954、selftest-plan-tier.sh:162）+ 3 处文字登记（check-rescue-chain.sh:33、check-plan-dispatch.sh:21、check-complete.sh:755）——check-drift.sh:205 为第 5 处漏网实锤。
4. plan_parse_scope 摘录已入 findings S2 节（S3 备料）：状态机宽松表头 + 表格行排除分隔行 + `-F'|'` 字段 3+ 点分路径整格输出不拆逗号 + fail-open rc=0；对拍种子 4 条：逗号拆分归属裁决、禁止列反向风险（字段 4 会被 lib 取为允许项）、字段 3=视觉列 2 的接轨基础、宽松 vs 严格表头匹配。

## 产物
- findings 小节：plans/task-v092-guard-quirk-fixes/findings.md `### S2 check-drift 取证`
- progress 行：plans/task-v092-guard-quirk-fixes/progress.md Phase 1 段（[2026-09-27 S2] 行）
- 夹具：/tmp/s2-fixtures/fixture-{a,b,c,d,e}（a=全 complete/b=真越级/c=P1完成P2进行中/d=渐进正常/e=两列表）
- 证据：/tmp/s2-evidence/{3a-runs.txt,3b-stages.txt,3c-probes.txt,3c-precedents.txt}

## 断点恢复
S2 无剩余子步。下一 S-unit=S3（plan_parse_scope 语义对拍+接库裁决，另一个 executor 会话；备料已入 findings S2 节末尾「S3 对拍种子」）。
