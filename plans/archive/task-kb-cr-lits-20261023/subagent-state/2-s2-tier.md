# S2 checkpoint — L-2 定点缺陷修复（check-tier-consistency.sh LANE 解析）

- task: task-kb-cr-lits-20261023 / Phase 1 S-unit S2
- 分支: wt/task-kb-cr-lits-20261023 (基 master 923aa54)
- 修改文件（唯一受管文件改动）: `skills/task-planner/scripts/check-tier-consistency.sh`

## diff 摘要（改了哪几行 + 理由）

1. **L60-62 LANE 精确 token 解析（L-2 根因修复）**
   - 原: `LANE="$(grep -m1 -E '^execution_lane:' "$PLAN_FILE" | grep -oE 'L[012]' | head -n 1)"`
   - 新: `grep -oE 'L[012]([_-][A-Za-z0-9]+)*'`
   - 理由: 原 `grep -oE 'L[012]'` 把 `L0-E`/`L0-T` 前缀截成 `L0` → L0-E 计划被误判为纯 L0 进入 L0 复核 → 2-Phase 的 L0-E 计划 false FAIL（实测 exit 1）。改为精确 token 解析后 `L0-E`/`L0-T` 原样保留，不再截断。小写声明不命中 → LANE 空 = 无 lane 判定面，走既有 SKIP fail-open。

2. **L127 L0 检查族条件改为精确族匹配**
   - 原: `if [ "$LANE" = "L0" ]; then`
   - 新: `if [ "$LANE" = "L0" ] || [ "$LANE" = "L0-T" ]; then`
   - 理由: 让 L0-T 也进入体量复核块（沿用 L0 族），CAP 经 `IS_L0T` 逻辑取 `L0T_MAX_FILES`（纯文本档 cap ≤12）。L0-E 不在此族内 → 自动豁免。

3. **L0-E 豁免注释（新增 1 行，裁决要求）**
   - 新增: `# L0-E 豁免: 纯执行档（权重 0 口径: 零受管变更 ∧ 产物落 gitignore 区, SKILL.md:187）, 套 L0 单 Phase cap 与其定义冲突 → 不进入本复核块`
   - 理由: 说明 L0-E 为何不走单 Phase cap（纯执行档权重 0，套 cap 与其定义冲突），落点依据 SKILL.md:187 L0-E 条款。

4. **单 Phase cap 仅对纯 L0 生效（L128 条件收窄）**
   - 原: `if [ "$PHASES" -gt "$L0_MAX_PHASES" ]; then`
   - 新: `if [ "$LANE" = "L0" ] && [ "$PHASES" -gt "$L0_MAX_PHASES" ]; then`
   - 理由: 38.7「L0=单 Phase 执行」；L0-T 纯文本档放宽面=文件数（cap ≤12），不限单 Phase——否则 2-Phase L0-T 计划 false FAIL。此收窄为 l0t 夹具期望 exit 0 所必需。

5. **printf 文案参数化（L129-137 三条指标行）**
   - `execution_lane=L0` → `execution_lane=%s` "$LANE`，多文件行补传 `"$LANE"` 位置参数。
   - 理由: L0-T 也进入本块后，输出应反映真实 LANE（L0 / L0-T），避免 L0-T 被印成 "L0"。

## 三夹具 exit code 实测输出

夹具（`<worktree>/tmp/vc2-{l0e,l0,l0t}/task_plan.md`，各含 `execution_lane:` 行 + 2 个 `### Phase N:` 标题行）：

| 夹具 | LANE | 期望 exit | 实测 exit | 输出关键行 |
|------|------|-----------|-----------|------------|
| vc2-l0e | L0-E | 0 | **0** | `✓ 档位声明与体量一致（plan_tier=<无> execution_lane=L0-E; lines=8 phases=2 vc=0 sunit=0 scope=0）` |
| vc2-l0  | L0   | 1 | **1** | `✗ 声明 execution_lane=L0 但形态超出轻量通道: 多 Phase（Phase 数=2, L0 应单 Phase 执行）` |
| vc2-l0t | L0-T | 0 | **0** | `✓ 档位声明与体量一致（plan_tier=<无> execution_lane=L0-T; lines=8 phases=2 vc=0 sunit=0 scope=0）` |

- `bash -n` → SYNTAX_OK（修改后复跑确认）
- `selftest-tier-consistency.sh` → Total: PASS=8 FAIL=0（存量基线无回归）
- l0=1 证明 L0 多 Phase 守卫不回退；l0e/l0t=0 证明 L0-E 豁免 + L0-T cap 路径生效。

## 遗留 / 风险

1. **tmp/ 实际非 gitignore 区**：`.gitignore` 未列出 `tmp/`，`git check-ignore tmp` rc=1。夹具落在 untracked 区而非 gitignore 区。已按"不 commit"口径处理（仅 `git add` 受管脚本，`tmp/` 保持 untracked，主进程提交时勿 `git add tmp/`）。
2. **checkpoint 文件本身**（本文件 `plans/.../subagent-state/2-s2-tier.md`）也是新增 untracked，同属"不 commit / 主进程决定"范围。
3. **工作树含多个其他 S-unit 的既有 `M` 文件**（README.md / docs/ARCHITECTURE.md / check-scope.sh / check-delegation.sh / selftest-requirement-coverage.sh / task-plan-init.cjs / templates/task_plan.md，合计 64+/27-）——本次 S2 未触碰任何一个（我的改动严格限于 check-tier-consistency.sh，numstat 12+/7-）。这是共享任务 worktree，多 S-unit 并行写入；主进程统一提交时须逐文件确认归属，勿把其他 S-unit 的改动混入 L-2 提交。
4. **L1/L2 lane 行为不变**：L1/L2 原不进入 L0 块，修改后 LANE 精确化后仍不进入（非 L0/L0-T），无回归。
5. **L0-T "多文件/重门控" 两项仍生效**：本修复只把"单 Phase"cap 收窄到纯 L0；L0-T 的 scope>12 与 sunit≥3 检查照常触发（符合 38.7 L0-T 文件 cap 口径）。若后续要求 L0-T 也豁免多文件/重门控，需另行裁决，非本 S2 范围。

## 裁决符合性自检（对照已裁决方向逐条）

- [x] LANE 改精确 token 解析 `grep -oE 'L[012]([_-][A-Za-z0-9]+)*'`（得 L0 / L0-T / L0-E / L1 / L2 原样）
- [x] L0 检查族条件改为精确族匹配：LANE 为 L0 或 L0-T 时进入 :127 体量复核块
- [x] L0-T 时 cap 取 L0T_MAX_FILES（沿用 :128-129 IS_L0T 逻辑，IS_L0T 本身 :63 全文件 grep 'L0-T' 判文本档行为保持未删）
- [x] L0-E 豁免该体量复核块 + 加一行注释说明豁免理由（权重 0 口径，锚 SKILL.md:187）
- [x] 三夹具 exit：l0e=0 / l0=1 / l0t=0 实测全部命中
- [x] `bash -n` 通过；存量 selftest 8/8 无回归

confidence: HIGH

---

## 修正轮（2026-10-23，主进程裁决）— 本轮覆盖上文单 Phase 收窄段

**裁决依据**：上轮 HIGH 风险标记被主进程采信。L-2 登记方向仅点名 L0-E 与 L0 的前缀碰撞；我把单 Phase cap 收窄至纯 L0（让 L0-T 免单 Phase 检查）属超出最小修射程的语义扩展。裁决：**L0-T 全量继承 L0 三项检查（单 Phase / cap 取 L0T_MAX_FILES / S-unit cap），仅 L0-E 整体豁免**。

### 修正后 diff 摘要（check-tier-consistency.sh，numstat 10+/6-）

1. **移除 :135 单 Phase cap 收窄**：`if [ "$LANE" = "L0" ] && [ "$PHASES" -gt "$L0_MAX_PHASES" ]` 改回 `if [ "$PHASES" -gt "$L0_MAX_PHASES" ]`（单 Phase 检查对 L0 ∨ L0-T 族整体生效，与文件数/S-unit 检查同族）。
2. **删除上轮"单 Phase cap 仅纯 L0"注释**，改注：`L0-T 全量继承 L0 三项检查（单 Phase / cap 取 L0T_MAX_FILES / S-unit cap）; 仅 L0-E 整体豁免（修正轮 2026-10-23: L0-T 单 Phase cap 不回退, 主进程裁决）`。
3. **保留不动**：L63 LANE 精确 token 解析、L0-E 豁免注释（:129）、:131 族入口 `if [ "$LANE" = "L0" ] || [ "$LANE" = "L0-T" ]`、:132 CAP=IS_L0T→L0T_MAX_FILES。

### 五夹具实测 exit code（全部命中期望）

| 夹具 | lane | 形态 | 期望 | 实测 | 输出关键行 |
|------|------|------|------|------|------------|
| vc2-l0e | L0-E | 2 Phase | 0 | **0** | `✓ …execution_lane=L0-E; phases=2 scope=0` |
| vc2-l0 | L0 | 2 Phase | 1 | **1** | `✗ …多 Phase（Phase 数=2, L0 应单 Phase 执行）` |
| vc2-l0t | L0-T | 单 Phase + scope 表 12 行 | 0 | **0** | `✓ …execution_lane=L0-T; phases=1 scope=12`（12 未超 L0T cap 12）|
| vc2-l0-scope12（对照）| L0 | 单 Phase + scope 表 12 行 | 1 | **1** | `✗ …多文件（scope 表文件数=12 > cap 3）`（同形态 L0 cap=3 → 证 L0T cap=12 放宽生效）|
| vc2-l0t2ph | L0-T | 2 Phase | 1 | **1** | `✗ …execution_lane=L0-T…多 Phase（Phase 数=2）`（单 Phase cap 对 L0-T 不回退）|

- `bash -n` → SYNTAX_OK（修正后复跑）
- `selftest-tier-consistency.sh` → Total: PASS=8 FAIL=0（存量基线无回归）

### 修正轮遗留/风险

- tmp/ 仍非 .gitignore 区（untracked），提交时勿 `git add tmp/`。
- 共享 worktree 其他 S-unit 的 M 文件（64+/27-）仍未触碰，L-2 提交须逐文件确认归属。
- 小写 lane 声明仍走 SKIP fail-open（已知边界）。
- vc2-l0-scope12 为对照夹具（证 cap 差值），非 L-2 原登记必需项；保留供复审。

### 修正轮自检（对照裁决）

- [x] 单 Phase 检查恢复对 L0-T 生效（L0 ∨ L0-T 族包裹，与文件数/S-unit 同族）
- [x] 豁免仅限 L0-E（豁免注释保留在 L0-E 判定处 :129）
- [x] L0-T 全量继承 L0 三项检查（单 Phase / cap L0T_MAX_FILES / S-unit cap）
- [x] 五夹具 exit：l0e=0 / l0=1 / l0t=0 / l0-scope12=1 / l0t2ph=1 全命中
- [x] bash -n + 存量 selftest 8/8 无回归

confidence: HIGH
