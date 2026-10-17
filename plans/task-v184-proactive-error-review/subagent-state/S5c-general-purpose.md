# S5c general-purpose 检查点（task-v184 Phase 2 收尾件：CA-7 汇聚注入 selftest+registry+cksum）

- 日期: 2026-10-17 | 执行体: general-purpose（Phase 2 收尾，跨 S1-S5 五门汇聚）
- 仓库: /mnt/data/dev/task-planner-skill
- 任务: 五门注入式行为回归（§5.1 修订 3 验收=「注入缺陷计划→走真实门链 exit 1」可反复重跑）+ registry 登记 + attest cksum 修复 + VG-02 文案顺手修

## M1 前置契约（Read 实录）

**范式源 selftest-goal-cjk.sh**（头 50 行学断言 idiom）: GI-NN 编号 / ok()/bad() 函数 / Total 行 /
`mktemp -d "${TMPDIR:-/tmp}/<nn>.XXXXXX"` 夹具自建即删 / `bash -n` 在位锚 / registry 自登记锚。
本脚本对齐：SCRIPT_DIR/SKILL_ROOT 定位 + PASS/FAIL 计数 + ok/bad + 末行 `Total: N PASS=x FAIL=y` +
全 PASS exit 0 任一 FAIL exit 1 + 夹具全 /tmp 自建自清理。

**夹具配方来源（各检查点已实证）**：
- vc-nonvacuous（GI-01/02/11）= S1 M4 配方：task_plan.md（1 Phase complete + 5 VC + V-N 各 ≥2）+
  verification.md（5 条 VC）+ findings.md/progress.md 各 ≥3 实质行。实测越 3-File/VC-GATE 抵达
  run_vc_nonvacuous（check-complete.sh:1030）；真空命令 `true` → rc=1 含 [vc-nonvacuous]；真实命令 → rc=0 ✓；
  env=off → rc=0（不阻断）。
- rvc-coverage（GI-03/04）= S2 M3 配方：3 R 行（🎯 用户需求原文 `- **Rn**:`）无映射段 → rc=1 含 [rvc-coverage]；
  补「### R→VC 映射」表（`| R1 | VC-1, VC-2 |...`）R3 各 ≥1 VC → rc=0 ✓。无 delivery-summary.md →
  R-COVERAGE fail-open 不阻断（既有豁免口径 F1）。
- step-placeholder（GI-05/06）= S34 M3 配方：判定器直测 `check-step-placeholders.sh <plan-dir>`（attest 侧
  无路径参数禁实测，attest 接线锚=静态 `grep -c 'task-v184-S3' attest-plan.sh`≥1 并入断言）。占位步骤
  「- [ ] 优化一下性能」→ rc=1；干净步骤（路径+ASCII 词锚）→ rc=0。
- tier-consistency（GI-07/08）= S34 M3 配方：`plan_tier: mini`+3 Phase → 判定器直测 rc=1 + attest 静态锚
  `grep -c 'task-v184-S4'`≥1；mini+2 Phase → rc=0。
- goal-cjk（GI-09/10）= S5 M4 配方：in_progress Phase（`- **Status:** in_progress`）+ 中文 Goal +
  progress「## Phase 1:」段 Started 锚 + 跑题内容。check-3file-gate.sh 条件 6（goal-cjk 段留痕）+ 条件 7
  （drift 门）——无 drift 痕迹 → rc=1 含 [goal-cjk] ✓ + [drift-gate] 阻断；补 ledger-*.jsonl
  event="drift_check" ts≥锚 → rc=0 [goal-cjk] ✓ 无 ✗/⚠。

## M2 落盘（4 文件）

1. **新建** `skills/task-planner/scripts/selftest-gate-injection.sh`（~470 行）：11 断言 GI-01..11，
   范式对齐 selftest-goal-cjk.sh；夹具 4 个 builder（make_vc_fixture/make_rvc_fixture/make_gcj_fixture
   + 内联 step/tier），全部 mktemp 于 /tmp/gi-selftest.*，每断言后 rm -rf，全局 trap 兜底清理。
   头注 What（五门注入式行为回归）/Why（§5.1 修订 3 检测器发货即死防线）/日期 2026-10-17/task-v184-S5c。
2. **追加** `skills/task-planner/scripts/selftest-registry.tsv` +1 行（4 列 TAB，script=
   selftest-gate-injection.sh；domain/trigger_scenarios/dep_anchors 照 P-02..P-09 行范式）。
3. **修** `skills/task-planner/scripts/attest-plan.sh`（:85 附近，+3 注释行 + printf 6→7 %s）：
   门结果缓存 cksum 输入串第 7 参数组纳入 5 个新门控 env（TASK_PLANNER_VC_NONVACUOUS_ENFORCE /
   RVC_COVERAGE_ENFORCE / STEP_PLACEHOLDER_ENFORCE / TIER_CONSISTENCY_ENFORCE / GOAL_CJK_ENFORCE），
   既有 6 参数组零改动（最小增量，防 enforce↔warn 档位翻转回放陈旧 PASS 缓存——S3/S4 遗留风险收口）。
4. **修** `skills/task-planner/scripts/selftest-verification-gate.sh` VG-02 文案：「84.1-84.6 六子条」→
   「84.1-84.7 七子条」（4 处：标题注释/What/ok 行/bad 行），断言逻辑 `grep -cE '^84\.[0-9]' -ge 6`
   原样不动（S8 登记的 84.7 落地措辞漂移，阈值 ≥6 兼容 7 子条）。

## M3 验收证据（逐条命令 + rc）

```
$ bash skills/task-planner/scripts/selftest-gate-injection.sh
GI-01..GI-11 全 PASS（11 断言逐行）
Total: PASS=11 FAIL=0   rc=0   ✅ 验收 1

$ bash skills/task-planner/scripts/selftest-registry.sh
T01..T05 全 PASS
Total: 5 PASS=5 FAIL=0 (registry rows=91, actual selftest=91)   rc=0   ✅ 验收 2（91=91 双向）

$ bash skills/task-planner/scripts/run-selftests.sh --only verification-gate
[run] selftest-verification-gate (rc=0 PASS=13 FAIL=0)   ✅ 验收 3（VG-02 修后仍 13/13）

$ bash -n skills/task-planner/scripts/attest-plan.sh
rc=0   ✅ 验收 4（cksum 改动语法）
$ bash skills/task-planner/scripts/run-selftests.sh --only vc-gate
[run] selftest-vc-gate (rc=0 PASS=11 FAIL=0)   ✅ 验收 4（cksum 回归面 PASS）
```

- cksum printf `%s` 计数=7，与 7 实参对齐（grep 复核）；5 新 env 并入第 7 参数组，前 6 组逐字未动。
- 逐断言证据（自脚本输出）：GI-01 rc=1 [vc-nonvacuous]✗ / GI-02 rc=0 [vc-nonvacuous]✓ / GI-03 rc=1
  [rvc-coverage]✗ / GI-04 rc=0 [rvc-coverage]✓ / GI-05 rc=1+attest锚n=1 / GI-06 rc=0 / GI-07 rc=1+
  attest锚n=1 / GI-08 rc=0 / GI-09 rc=1 含 [goal-cjk] / GI-10 rc=0 无✗⚠ / GI-11 rc=0（1→0 转变）。
- 全程禁 git 写：仅 git status --short 只读复核（4 文件面）；零 add/commit/reset/clean。
- /tmp 残留检查：`ls /tmp/gi-*` 全部清理（自脚本 trap + 手工测试夹具显式 rm），无残留。

## 限制

- 判定器本体（check-vc-nonvacuous/check-rvc-coverage/check-step-placeholders/check-tier-consistency/
  check-goal-cjk）零改动，仅测试其门链消费面（check-complete.sh / check-3file-gate.sh 直接调用 +
  attest 静态锚）。
- GI-05/GI-07 的 attest 接线面为静态锚（attest-plan.sh 无 plan-dir 位置参数、不锁活跃计划，禁实测，
  与 S3/S4 同限）——占位/档位漂移负例走判定器直测，attest 侧仅锁接线锚在位。
- 未改 config.json / 未改各判定器本体 / 未做全量 run-selftests --fresh（收敛面=gate-injection+registry
  +verification-gate+vc-gate 4 个专属自测）。

## 未做事项

- selftest-verification-gate.sh 文件头 :4 行 What 注释仍写「Rule 84.1-84.6 子条文本锚」（非 VG-02 块，
  属全文件头描述，超出任务书「VG-02 注释」scope，未动；如需一并修可后续一行改）。
- 全量回归（run-selftests.sh 无参/--fresh）未跑——S5c 验收面按 dispatch 4 个专属自测全绿即可。
- 未做 git 写收口（提交/合并由主进程 S9 执行）。

## 风险

- cksum 增 5 env 后，历史 /tmp/attest-cache-*.result 缓存键全变（键串变→缓存必 miss 重跑门链），
  方向安全（仅首次多跑一次完整门链，无正确性风险）；非缓存路径行为零变。
- GI-02/GI-04/GI-10 正例依赖 check-complete.sh/check-3file-gate.sh 门链当前消费面全绿（judge-gate
  ✗/warn 不阻断 rc=0 的既有口径）——若后续门链新增 enforce 阻断门，正例夹具需同步补留痕行。

## checkpoint 路径
/mnt/data/dev/task-planner-skill/plans/task-v184-proactive-error-review/subagent-state/S5c-general-purpose.md
