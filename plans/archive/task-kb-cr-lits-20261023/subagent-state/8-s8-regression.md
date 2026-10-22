# S8 全量回归检查点（Phase 2 / 只执行不改码）

- 任务: task-kb-cr-lits-20261023 Phase 2 S8
- worktree: `/mnt/data/dev/task-planner-skill-worktrees/task-kb-cr-lits-20261023`
- 分支: `wt/task-kb-cr-lits-20261023` HEAD=`3544076`（L-5）
- 基线: master `923aa54`（= 本分支 merge base，主仓 `/mnt/data/dev/task-planner-skill`）
- 执行时间: 2026-10-23

## 1. 全量 selftest（--fresh）

命令:
```
cd <worktree>/skills/task-planner/scripts && bash run-selftests.sh --fresh
```

输出原文（末 3 行）:
```
[run]    selftest-veto (rc=0 PASS=13 FAIL=0)
[run]    selftest-workflow-orchestration (rc=0 PASS=22 FAIL=0)
Total: 92 PASS=92 FAIL=0 (run=92 reused=0)
```

- 退出码: 0（后台作业 exit code 0）
- 计数: 92 脚本全跑（reused=0 确认无缓存粉饰），断言级 PASS 合计 1271
- FAIL 扫描: `grep -nE 'FAIL=[1-9]|rc=[1-9]|\[FAIL\]'` 结果 `NONE`（零命中）
- 与 L 项相关脚本逐一 rc=0 / FAIL=0：selftest-delegation(38)、selftest-plan-tier(32)、selftest-registry(5)、selftest-rule23-conflict-scan(3)、selftest-rule-reserve-pairing(3)、selftest-rule-reserve(10)、selftest-template-lifecycle(24)、selftest-template-sense(8)、selftest-tier-b(18)、selftest-tier-consistency(8)

## 2. tier 五夹具复跑

命令:
```
for f in tmp/vc2-l0e tmp/vc2-l0 tmp/vc2-l0t tmp/vc2-l0-scope12 tmp/vc2-l0t2ph; do
  bash skills/task-planner/scripts/check-tier-consistency.sh "$f"; echo exit=$?
done
```

| 夹具 | 期望 | 实测 | 输出要点 |
|------|------|------|----------|
| vc2-l0e | 0 | 0 | `✓ 档位声明与体量一致（execution_lane=L0-E; lines=8 phases=2 ...）` |
| vc2-l0 | 1 | 1 | `✗ 声明 execution_lane=L0 但形态超出轻量通道: 多 Phase（Phase 数=2 ...）` |
| vc2-l0t | 0 | 0 | `✓ ...（execution_lane=L0-T; lines=21 phases=1 ... scope=12）` |
| vc2-l0-scope12 | 1 | 1 | `✗ 声明 execution_lane=L0 但形态超出轻量通道: 多文件（scope 表文件数=12 > cap 3）` |
| vc2-l0t2ph | 1 | 1 | `✗ 声明 execution_lane=L0-T 但形态超出轻量通道: 多 Phase（Phase 数=2 ...）` |

结论: 0/1/0/1/1 与期望完全一致；印证 L-2（LANE 精确 token 解析）语义——L0-E 豁免三检查，
L0 与 L0-T 族继承 L0 三检查（L0-T 不豁免 phase 上限，仅后缀不参与 token 前缀匹配）。

## 3. check-scope 行为自测

`<worktree>/tmp/scope-selftest/` 不存在（S3 场景未落盘），按预案自建最小场景：
临时 git 仓（`mktemp -d`，`git init` + `.gitignore=build/ tmp/ output/`）+ 会话侧哨兵
`plans/.plan_required_side/S8TEST1.plan_required`（created_epoch 取未来时间，确保 D10' 仲裁不触发）。
脚本落 `/tmp/s8-scope-selftest.sh`（仓外，含 trap 清理），**未写入 worktree**。

结果原文:
```
[PASS] T1 tmp/ 机械产物区（无轻量标记）   expect=0 got=0
[PASS] T2 output/ 机械产物区                     expect=0 got=0
[PASS] T3 build/ gitignore 区                        expect=0 got=0
[PASS] T4 src/ 受管文件（无轻量标记）      expect=1 got=1
[PASS] T5 tmp/ 轻量标记 + 机械产物区         expect=0 got=0
[PASS] T6 src/ 轻量标记 + 受管文件（须拦） expect=1 got=1
[PASS] T7 root 级受管文件 README（须拦）     expect=1 got=1
[PASS] T8 放行留痕不在 stdout（stderr 承载）
SCOPE-SELFTEST Total: PASS=8 FAIL=0
EXIT=0
```

留痕文案核验（L-7 抽函数后文案子区标签未漂移 + L-8② 改 stderr）:
- T1 `[PLAN-GUARD] ✅ 机械产物区放行（.../tmp/a.txt 不构成仓库受管文件变更）`（stderr）
- T3 `[PLAN-GUARD] ✅ gitignore 区放行（.../build/c.o 不构成仓库受管文件变更）`（stderr）
- T5 `[PLAN-GUARD] ✅ 轻量档放行（会话级标记 S8TEST1.plan_lightweight + 机械产物区 .../tmp/d.txt）`
- T6 `[PLAN-GUARD] ⚠ 轻量档标记存在但目标非机械产物区（.../src/app.py）→ 按仓库受管文件拦截`

即：口径①（轻量标记）严格不放开受管文件写入（T6 拦截），两口径共用同一判定函数且文案分区正确。

## 4. check-delegation stats 冒烟

命令:
```
bash skills/task-planner/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-kb-cr-lits-20261023
```
退出码: 1；输出（JSON 正常生成）:
```json
{"phases_total":4,"phases_delegated":2,"main_direct_count":1,"delegation_rate":0.667,
 "main_direct":[{"phase":"4 收口（合并/部署/推送/归档）","executor":"主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）",...}],
 "violations":[{"type":"unverified_delegation","phase":"3 CR 门控","executor":"Code Reviewer（S9）∥ alignment-review skill（S10）","reason":"Executor 含未登记子代理类型:CodeReviewer"}],
 "verdict":"violation"}
```
判定: 冒烟 PASS（JSON 结构完整、字段齐全、stats 子命令可跑通）。exit=1 与
`unverified_delegation` 计数属**本 plan 自身已知面**（任务书明示非回归项），非本次 L 修复引入。

## 分类结论

| 分类 | 条目数 |
|------|--------|
| 新增 FAIL（由 923aa54..HEAD 七次 L 修复引入） | 0 |
| 存量 FAIL（master 基线同现） | 0 |
| 已知非回归面（plan 自身 delegation violation） | 1（stats exit=1，预期内） |

因全量 92/92 PASS 且零 FAIL，无需跑 master 基线对照（无 FAIL 可归属）。

## 结论

**REGRESSION PASS** — 全量 92 脚本 92 PASS / 0 FAIL（--fresh，reused=0）；
tier 五夹具 0/1/0/1/1 全中期望；check-scope 机械区/受管文件/轻量标记三面 8/8 PASS；
check-delegation stats 冒烟通过。未修改任何受管文件（`git status --short` 仅 `?? plans/` `?? tmp/`，
与执行前一致）。唯一 FAIL 观测位来自自身 plan 的 delegation 统计（已知面，非回归）。

## 反造谣声明

- 所有输出均为工具调用的原文摘录（见上），未推断、未补写。
- 负结果（明确未发现）：`grep FAIL=[1-9]|rc=[1-9]|\[FAIL\]` 在全量日志零命中；
  check-scope 无"放行受管文件写入"的回归缺口。
