# report-ex2 — B簇(门真实性) DEF-01/DEF-02

## 1. attest-plan.sh SOFT_ONLY warn→fail-closed (DEF-01)
- 文件: `skills/task-planner/scripts/attest-plan.sh` 入口段(:87附近，mode分派/门链/缓存前)
- 改动: 空壳命中(plan-state.json 业务数组全空 && task_plan.md>2048B) + attest模式 + 默认env → `exit 1`，输出 `[attest] ✗ SOFT_ONLY 空壳计划拒绝锁定...`；`TASK_PLANNER_SOFT_ONLY_ENFORCE=off` → WARN不阻断；非attest模式仅WARN。
- 注释: What/Why 含 2026-11-28 task-skill-fix-defs-20261128、判例 sess_1d7e33d6、原行为 2026-11-22 warn-only、依据用户 /goal 逐个修改授权。
- 缓存: 检查位于入口段、cache lookup 之前，缓存命中不绕过。
- 传播面: `grep -rn "SOFT_ONLY" skills/task-planner/scripts/selftest-*.sh skills/task-planner/scripts/check-*.sh` 命中=0（改前无自测/检查锚）；新增 `selftest-softonly-gate.sh` 承载三向断言。

## 2. check-dispatch.sh 契约语义校验 (DEF-02 最小机器化)
- 文件: `skills/task-planner/scripts/check-dispatch.sh`
- 新增 `scan_dispatch_semantic_anchors()`：证据锚=`证据|验收|VC[0-9]|V-[0-9]`；范围锚=`禁改|只读|范围|不得修改|不要改|禁止改|不可改|只允许修改|仅限`；缺失返回缺项名，走既有缺项管线(exit 2/1)。
- 接入: `scan_missing()` 尾部追加；legacy 计划(task_plan.md 无 `- **Executor:**`)跳过新增门（与 check-plan-dispatch legacy 一致）；plan-dir 不可读保守 fail-closed 执行语义锚检查。
- 兼容: VC编号引用纳入证据锚，避免历史 `VC1/VC2` 无“证据”字样误伤。
- 备选落点 check-plan-dispatch.sh 未使用（契约文本面可查），已在本报告说明。

## 3. 自测/夹具锚同改
- `selftest-dispatch.sh`: mk_prompt/T10/tscl_prompt/fgc_prompt/DX-04 补 `验收证据: VC1` + `范围: 禁改...` 语义锚关键词；清理 `/tmp/task-planner-agent-count-t|${SID}` 防 Rule 96.7 计数跨跑误拦(hermetic)。
- `selftest-dispatch-grain.sh`: mk_prompt 补同款语义锚关键词。
- 新建 `selftest-softonly-gate.sh`（三向夹具）。

## 4. 三向断言实测 (VC2)
| # | 条件 | rc | 关键文案/证据 |
|---|------|---:|---------------|
| ① | 空壳夹具 + 默认env | 1 | `[attest] ✗ SOFT_ONLY 空壳计划拒绝锁定...legacy 逃生阀 TASK_PLANNER_SOFT_ONLY_ENFORCE=off` |
| ② | 空壳夹具 + `TASK_PLANNER_SOFT_ONLY_ENFORCE=off` | 1 | 含 `WARN: ...SOFT_ONLY 信号；TASK_PLANNER_SOFT_ONLY_ENFORCE=off 降级 warn 不阻断`（rc 可能 1，判 WARN 文案） |
| ③ | 正常夹具(业务数组非空, mini, 跳过无关门) | 0 | `SO-03 PASS 正常夹具(业务数组非空) -> rc=0` |

命令: `bash skills/task-planner/scripts/selftest-softonly-gate.sh` → `SOFTONLY_TOTAL: 3 PASS=3 FAIL=0`。

## 5. 回归自测
- `bash skills/task-planner/scripts/selftest-dispatch.sh` → `Total: 31 PASS=31 FAIL=0`（首跑 T10 因环境 96.7 计数污染失败，已加 hermetic 清理后复跑全绿）
- `bash skills/task-planner/scripts/selftest-dispatch-grain.sh` → `Total: 10 PASS=10 FAIL=0`
- `bash skills/task-planner/scripts/selftest-softonly-gate.sh` → `3/3 PASS`

## 6. 语法检查
- `bash -n skills/task-planner/scripts/attest-plan.sh check-dispatch.sh selftest-softonly-gate.sh selftest-dispatch.sh selftest-dispatch-grain.sh` → rc=0
