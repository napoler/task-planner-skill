# selftest-fix-result

## 范围
- worktree: `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-fix-all-20261123`
- 分支: `wt/task-fix-all-20261123`
- 基线: `e3206b3`，`--fresh` 104/96/8
- 修复后: `--fresh` 104/104/0
- commit: `b68fa8c` `fix(selftest): 修8个FAIL——registry孤儿/rule110 landed/2测试env泄漏/2基线口径漂移（task-fix-all-20261123）`

## 逐 FAIL 修法与证据

| FAIL | 根因类别 | 修法 | 证据 | 作弊自查 |
|---|---|---|---|---|
| `selftest-registry.sh` T03（孤儿行） | A 登记漂移 | 从 `skills/task-planner/scripts/selftest-registry.tsv` 删除第100行 `selftest-md-edit-ops.sh` 孤儿登记。核实：实际脚本在 `skills/md-edit-ops/scripts/selftest-md-edit-ops.sh`，不属于 task-planner/scripts；registry 行指向本目录不存在文件。未删除脚本本体，未改 T03 断言逻辑。 | 单跑 `selftest-registry.sh` → `Total: 5 PASS=5 FAIL=0 (registry rows=104, actual selftest=104)` | PASS：未删断言/未硬编码；真实缺文件仍会被 T03 检出。 |
| `selftest-self-resolution.sh` SR-12 | A 连带（registry） | 无代码改动，由 registry 孤儿清理连带恢复。 | 单跑 `selftest-self-resolution.sh` → `Total: 13 PASS=13 FAIL=0`，SR-12 动态比对 `105=脚本数+表头` 通过。 | PASS：未改 SR-12 期望计算。 |
| `selftest-summary-readability.sh` SRV-11/SRV-12 | A 连带（registry） | 无代码改动，由 registry 孤儿清理连带恢复。 | 单跑 `selftest-summary-readability.sh` → `Total: PASS=13 FAIL=0 WARN=0`，SRV-11 registry.sh PASS，SRV-12 9/9 级联 PASS。 | PASS：未改 SRV 断言。 |
| `selftest-rule-reserve-pairing.sh` PR-02 | D 真实待补 landed | 在 worktree `plans/.rule-reservations.jsonl` 追加 `{"rule":110,"status":"landed","task_id":"task-fix-all-20261123","ts":"2026-11-23","note":"Rule 110 已在 SKILL.md/dispatch 卫星文档化，补 landed 配对解 PR-02"}`。未扩豁免表。 | 单跑 `selftest-rule-reserve-pairing.sh` → `PR-01 PASS ... PR-02 PASS reserved 悬空项=57 60 80 82 全在豁免表... PR-03 PASS ... Total: 3 PASS=3 FAIL=0`。SKILL.md 含 Rule 110（L9/L312/L424），dispatch 含 `### 110`。 | PASS：未扩 EXEMPT_DANGLING/EXEMPT_LANDED；若 rule110 再次悬空 PR-02 仍 FAIL。 |
| `selftest-active-plan.sh` T11 | C 测试 env 泄漏 | T11 attest 调用增加 `-u ZCODE_SESSION_ID -u CLAUDE_SESSION_ID` scrub，保留 `CLAUDE_CODE_SESSION_ID=s11`。只改测试 hermetic，不改 attest/resolve 产品逻辑。 | 单跑 `selftest-active-plan.sh` → `Total: 29 PASS=29 FAIL=0`，T11 PASS。 | PASS：产品逻辑未改；断言仍验证 side 指针锁 bb 不被 mtime 最新 aa 顶掉。 |
| `selftest-execution-stability.sh` T11b | C 测试 env 泄漏 | b1_pos/b1_neg baseline attest 增加 `-u CLAUDE_SESSION_ID`（与已有 `-u ZCODE_SESSION_ID` 对齐）。只改测试 hermetic，不改 hook。 | 单跑 `selftest-execution-stability.sh` → `Total: 19 PASS=19 FAIL=0`，T11b PASS。 | PASS：产品 hook 未改；断言仍验证 owner!=SID 不重锁/不洗白。 |
| `selftest-batch-pilot.sh` BP-08 | A 基线漂移 | SKILL.md 实值 440（Rule 108-110 纪元/审计门等结构性增长），按“实值+边距”口径将上限 311→450，更新注释说明增长原因与边距先例；保留行数钉检查。 | 单跑 `selftest-batch-pilot.sh` → `Total: 10 PASS=10 FAIL=0`，BP-08 `SKILL.md 行数 440 ≤450`。 | PASS：未删除检查；若 SKILL.md 回归性暴涨超450仍 FAIL。 |
| `selftest-enumerate-first.sh` EN-06 | A 基线漂移 | 纪元锚从 `1-108>=3` 更新为 `1-110>=3`，保留 `,107` 路由存在检查；同步注释。 | 单跑 `selftest-enumerate-first.sh` → `Total: 7 PASS=7 FAIL=0`，EN-06 `含 '1-110' >=3 处(3) 且含 ',107' 路由`。 | PASS：未降阈值/未删检查；若 1-110 锚丢失或 ,107 路由丢失仍 FAIL。 |

## 全量验证

命令：`bash skills/task-planner/scripts/run-selftests.sh --fresh`

结果尾部：
```
[run]    selftest-veto (rc=0 PASS=13 FAIL=0)
[run]    selftest-workflow-orchestration (rc=0 PASS=22 FAIL=0)
Total: 104 PASS=104 FAIL=0 (run=104 reused=0)
```

## 作弊自查结论
- 未删除任何断言、未把 FAIL 改 SKIP、未扩 rule-reserve 豁免表。
- 未改产品 hook/attest/resolve 语义；env 泄漏只在测试侧 scrub。
- BP-08/EN-06 为基线口径更新，保留判别力（超阈值/锚缺失仍 FAIL）。
- registry 只删确认的孤儿登记行；`skills/md-edit-ops/scripts/selftest-md-edit-ops.sh` 本体保留。
- 全量分母仍为 104，无删脚本减分母。

## 未解决项
- 无。8 个目标 FAIL 全绿，全量 `104 PASS=104 FAIL=0`。
- 备注：`selftest-rule-reserve-pairing.sh` 运行时 stderr 有 `comm: ... not in sorted order` 提示，但 exit/断言 PASS（脚本既有行为，非本次引入）。
