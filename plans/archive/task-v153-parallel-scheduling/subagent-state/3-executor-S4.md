# checkpoint — 守卫单元（executor）: check-plan-dispatch.sh Rule 68 校验段

> 组域写隔离（Rule 68.4）：本单元只写本检查点 + scope 文件
> `skills/task-planner/scripts/check-plan-dispatch.sh`；计划三文件由主进程按组串行回写。

## 里程碑 0 — 上下文读取（完成）
- 施工图 §二 六校验点清单（hard H1-H4 / advisory W1-W2）+ 档位接线口径已读。
- brief §2/§3/§4：目标脚本 66.5 段=worktree 实测 314-412（brief 记 314-406，以 worktree 为准）；
  段头 `# ── [2026-10-09 task-v151 S2] Rule 66.5 Goal 单元表校验段 ──`；
  插入位=66.5 段收尾 `fi`（行 412）之后、`# ── 输出`（行 414）之前。
- add_violation 定义=行 181-183（`violation_list="${violation_list}[plan-dispatch] ✗ Phase $1: $2"`）。
- 真实计划 S-unit 表列位：前置依赖=$10、并行组=$11（12 列，动态列位定位，不硬编码）。
- 档位回归风险：既有夹具（selftest-plan-dispatch / plan-tier PT-22 / tier-b）均无显式
  `plan_tier: standard|full` → 段整体跳过，零回归（对齐 66.5 D2 裁决先例）。

## 里程碑 1 — 段骨架 + H1/H2（进行中）
- 新增段头注释 `# ── [2026-10-09 task-v153 S4] Rule 68 依赖与并行分组校验段 ──`。
- awk flag 状态机抽各 S-unit 表头列位 + 数据行四列 + 行内组标记（\037 分隔，非空白不坍缩）。
- H1=表头缺「前置依赖」列 → add_violation；H2=数据行前置依赖单元格空 → add_violation。

## 里程碑 2 — H3/H4（完成）
- H3=frontmatter parallel_groups 每个声明组须有计划内 `[parallel-group:<组名>]` 标记（全计划 grep
  标记集），无成员 → add_violation。
- H4=行 R 前置依赖（顿号分隔 + 同前缀区间展开 S1-S6）含单元 D 且 R 与 D 同组 → add_violation
  （id→组 映射用 `declare -A`）。

## 里程碑 3 — W1/W2（完成）
- W1=同组执行体集合大小=1 且组员 ≥2 → echo WARN「组内全同」；W2=同组成员执行体全为「继承」→
  echo WARN（W2 优先，二者互斥避免重复告警）；均不拒锁。

## 里程碑 4 — 夹具实测（完成，/tmp 不入库）
- 依赖-同组矛盾夹具 → rc=1，stdout 含 `Rule 68.2: 依赖-同组矛盾——行 S2 前置依赖含 S1…`（hard）。
- 组内全同夹具（--skip-goal-check）→ rc=0，stdout 含 `WARN Rule 68.3: 并行组「g1」组内全同执行体…`。
- 补测：H1 缺列 → rc=1 违规；H2 空单元格 → rc=1 违规；H3 声明组无标记 → rc=1 违规；
  W2 全「继承」→ rc=0 WARN。六校验点全数覆盖。
- 真实计划 task_plan.md 实测 rc=0，无任何 Rule 68 违规行（H4 无误报：S4 依赖条款单元、跨组）。

## 里程碑 5 — 自证 + 回归（完成）
- `bash -n` exit 0；grep 计数：依赖-同组=4、组内全同=2、前置依赖=13。
- `git diff --stat master -- …/check-plan-dispatch.sh` = 1 file changed, 163 insertions(+)（仅本 scope 文件）。
- 回归 selftest（6 个消费本脚本的用例）全 PASS；唯一 FAIL=goal-unit 用例 G-07（registry 末行断言，
  因兄弟守卫单元追加新 selftest 行而失效，与本单元改动无关，属跨单元/主进程处置项）。
- open_issues：G-07 registry 末行断言 brittleness（新 selftest 行必然破坏，需主进程裁决）。
