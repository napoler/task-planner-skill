# 12 critic — Code Review Gate 终审（commit 02d90e2）

- 时间戳：2026-11-13T01:48:31+08:00
- 审查对象：/mnt/data/dev/task-planner-skill commit 02d90e2（merge wt/task-docmod-recheck-20261112，5 文件 44+/16-）
- 审查方式：只读；git show --first-parent 全量 diff + 目标文件 Read + grep 复现 + 4 个 selftest 实跑

## 维度结论

| 维度 | 结论 |
|------|------|
| ① 正确性 | 主体与声称意图一致（5 文件无越界、EN-06 未弱化）；但漏 1 处卫星索引锚 + 1 处计数随动 → 存在漏改 |
| ② 可维护性 | 条款措辞可执行；todo-sync 新增块把 S1–S5 表切成两张表；106 标题风格偏离邻条 |
| ③ 风险 | EN-06 改动=纯纪元语义，无业务断言弱化（PASS）；SKILL 表格（4 列 / 11 卫星行）未被破坏；todo-sync 表被拆 |
| ④ 一致性 | 与 S7 APPROVED 有 3 处需升级点（域边界陈述失实 / in_progress 唯一性硬冲突被降级 / 索引与计数未覆盖） |

## 裁决：CHANGES_REQUESTED

### IMPORTANT
- **I-1** `skills/task-planner/references/todo-sync.md:20` vs `:32` + `critical-rules-discipline.md:732`：`同时只允许一条 in_progress` 与 `B1 持续项（开启即 in_progress…）` 硬冲突（S1 建组后 = 2 条并发 in_progress，无调和文字）。建议：显式豁免基线组（「Phase 组唯一 in_progress；基线组单列不计入该约束」）。
- **I-2** `skills/verification-gate/references/critical-rules-verification.md:56`：`本域 84.x 仅覆盖终验期` 与同文件 `:3`（执行期 V-N / 84.4 执行期子代理复核）及 `:22`（84.3③ phase 间门控）矛盾。建议改「84.x 管验证链（计划期 VC / 执行期 V-N / 终验复验），106 仅管『文档修改后的跨字段一致性回读』，二者交集以 84.4 产出复核为准」。
- **I-3** `skills/task-planner/SKILL.md:9` 与 `:223`：`其余 88 条` 未随上界 1-106 累加（14 核心 + 88 + 3 废弃 = 105 ≠ 106；前次 Rule 105 落地时 87→88 有先例）。建议改 89（selftest 断言用 `8[0-9]` 宽窗，改后不破）。
- **I-4** `skills/task-discipline/SKILL.md:84`（索引末行=105，无 106 行）+ `:15`/`:86`/`:97`（`53 条` 未变）：Rule 106 落在该卫星规则文件却未进该卫星索引，从卫星入口按编号检索会落空；前次 Rule 105 级联清单明确含此锚。建议 +1 行 + 53→54。

### WARNING
- **W-1** `skills/task-planner/references/todo-sync.md:26-38`：新块插入 S1 行与 S2 行之间并重复表头，单表被拆为「1 行表 + 4 行表」，第二张表无标题。建议移到 S5 行之后（表外）。
- **W-2** `skills/task-planner/scripts/selftest-enumerate-first.sh:102-107`：EN-07 负断言仍锁 `1-104`，真正陈旧字面已变成 `1-105`；当前残留=0（潜在缺口，非现网缺陷）。

### NIT
- **N-1** `critical-rules-discipline.md:721`：106 标题缺 `P0` 与日期（邻条 105 有）。
- **N-2** 同处：标题 `文档修改复检纪律` 未覆盖 106.5（todo 驱动对齐），与 `SKILL.md:223` 口径不一致。
- **N-3** `critical-rules-verification.md:56`：作为 84.7.5 后同级 bullet，被读作 84.7 子条，实际声明全域边界（MEDIUM 置信）。
- **N-4** `SKILL.md:105` 3i 摘要只提 106.1/106.3，漏 106.2/106.4 两条 P0（有「细则→Rule 106」兜底，低风险）。

## 已验证 / 排除
- 已验证：selftest-enumerate-first.sh 7/7 PASS exit 0；selftest-verification-gate.sh 13/13 PASS；全仓 `Rules 1-105` 残留=0（plans/ 除外）；SKILL.md `1-106`=3 处、`,106` 路由在位；卫星表 11 行 / 4 列完好。
- 未发现但已排查：discipline 规则编号冲突（106 唯一）、verification-gate 84.5/84.14 引用有效性、todo-sync S2–S5 行内容未改、critical-rules.md 无 1-105/106 锚（与 CA-8 登记一致）。

---

# 复审（fix-phase 闭环）— commit 36b9e65 / merge b61a656

- 复审时间戳：2026-11-13T01:58:00+08:00
- 审查对象：`git show 36b9e65`（6 文件 21+/23-），HEAD=b61a656
- 方式：diff 全量 + 文件 Read + grep 复现 + 5 个 selftest 实跑

## 逐项处置核验

| 项 | 状态 | 证据 |
|----|------|------|
| I-1 in_progress 豁免 | 已修（残留排版 NIT） | `todo-sync.md:36` 追加「基线组独立计数：B1 持续 in_progress 不受『同时只允许一条 in_progress』约束（该唯一性约束限任务组/Phase 映射条目）」；与 `:20` 不变量不再冲突；但前句「B5 收尾。」后接「；」→ `。；` 双标点 |
| I-2 域边界纠偏 | 已修 | `verification-gate/references/critical-rules-verification.md:56` 改「84.x 管验证链全周期（计划期 VC 可执行化/执行期 V-N 84.3/产出复核 84.4/终验复验 84.5-84.14）…交集=84.4 产出复核，禁互吞」，与同文件 `:3`/`:22` 自洽，原失实表述已消失 |
| I-3 计数 89 | 已修 | `task-planner/SKILL.md:9`、`:223` 均「其余 89 条」；106−14−3=89 自洽；`selftest-anti-deferral.sh`/`selftest-dual-qc.sh`/`selftest-subagent-activation.sh` 宽窗 `8[0-9]` 断言全绿（12/12、14/14、20/20） |
| I-4 卫星索引 | 已修 | `task-discipline/SKILL.md` 新增 `\| 106 \| 文档修改复检与 todo 驱动对齐纪律（…B1-B5）· task-docmod-recheck-20261112 \| …### 106 段 \|`（3 列与邻行一致）；索引数据行实测=54，三处「共 54 条」齐备，全文件无「53 条」残留 |
| W-1 表格拆分 | 已修 | `todo-sync.md:26-34` 恢复单表单 5 行（S1-S5）；两组块移至表后、`## 4` 前；重复表头已删 |
| W-2 EN-07 纪元 | 已修 | `selftest-enumerate-first.sh:10/16/102-109` 全量 1-104→1-105（含 VC-4 自指注）；`grep -c '1-105' SKILL.md`=0，实跑 7/7 PASS EXIT=0；FAIL 分支仍留旧注解「S3 级联依赖，当前态预期 FAIL」（NIT，仅诊断文案） |
| N-1/N-2 标题 | 已修 | `critical-rules-discipline.md:721` =「### 106 文档修改复检与 todo 驱动对齐纪律（P0 — task-docmod-recheck-20261112，2026-11-13；判例=sess_1378b365「G22-05a …」）」，含 P0/日期/主题对齐 `SKILL.md:223` |
| N-4 3i 摘要 | 已修 | `SKILL.md:105`「跨字段不变量（106.1-106.4）」 |
| N-3 互指行位置 | 登记接受（未处置） | 承认为 MEDIUM 排版位，语义已由 I-2 修复，不再阻塞 |

## 新增/残留问题（均 NIT，不阻塞）

- `skills/task-planner/references/todo-sync.md:36`：`B5 收尾。；基线组独立计数` — 句读重复，建议去「。」或改「；」
- `skills/task-planner/scripts/selftest-enumerate-first.sh:107`：FAIL 分支文案仍含「S3 级联依赖，当前态预期 FAIL」— 纪元已完成，该注解过时（不影响断言逻辑）

## 无回归确认

- `Rules 1-105` 全仓（skills/）残留=0；`1-104` 在 SKILL.md=0；`1-106`=3 处、`,106` 路由在位
- 5 个相关 selftest：enumerate-first 7/7、verification-gate 13/13、anti-deferral 12/12、subagent-activation 20/20、dual-qc 14/14 全 EXIT=0
- 变更文件集 6 个全在修复范围，无越界

## 终审裁决：APPROVED

I-1~I-4 / W-1 / W-2 / N-1 / N-2 / N-4 全部修复到位且无新引入语义问题；2 条残留 NIT 为排版/诊断文案级，可随手修，不构成放行障碍。N-3 登记接受。
