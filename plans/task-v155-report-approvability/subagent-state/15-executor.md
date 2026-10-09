# S15 checkpoint — registry 登记 + RRV-06/07 翻硬档 + 全仓计数钉核查（executor）

- 任务: ① registry.tsv 追加 selftest-report-reviewability.sh 登记行；② selftest-report-reviewability.sh RRV-06/07 WARN→常驻 FAIL；③ 全仓 selftest 计数钉核查（64→65 口径）
- worktree: /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability
- 时间: 2026-10-10

## 动作
- ① `skills/task-planner/scripts/selftest-registry.tsv` 末行纯追加 `selftest-report-reviewability.sh` 登记行（tab 4 列：script/domain/trigger_scenarios/dep_anchors，逐字采用 S15 材料包 §①）。既有 65 行零改动。
- ② `selftest-report-reviewability.sh`: RRV-06/07 由 WARN 宽限档改常驻 FAIL 档——移除 `STRICT="${RRVV_REGISTRY_STRICT:-0}"` 与 env 分支（3 处），registry 登记行缺失 / report-lint 段缺失一律 `bad` FAIL；头部注释与段注释更新为「登记行与 lint 段已落位（S14/S15），2026-10-10 翻硬档」。净 -9 行，删除行仅限 STRICT/WARN 分支及其注释。
- ③ 全仓计数钉核查：见下「计数钉结论」。未修改任何既有脚本（scope 第三面零改动）。

## 验证证据
- ① `awk -F'\t' '$1=="selftest-report-reviewability.sh"{print "NF="NF}'` → `NF=4`；`wc -l`=66（表头+65 脚本）；数据行 65 = `ls selftest-*.sh | wc -l`=65
- ② `bash selftest-report-reviewability.sh` exit 0，末行 `Total: PASS=13 FAIL=0 WARN=0`；`bash -n` rc=0
- ③ `RRVV_REGISTRY_STRICT=1 bash 同脚本` exit 0，`diff` 普通跑 vs STRICT 跑 → IDENTICAL
- `selftest-registry.sh` T01-T05 全 PASS（`registry rows=65, actual selftest=65`），新登记行不破双向核对
- 附带发现: `selftest-self-resolution.sh` SR-01 FAIL（`grep -c '^41\.'`=7 应 6）=Rule 70.5 首行「41.5…」(critical-rules.md:883) 被 SR-01 正则误计，S1 引入，非本单元

## 计数钉结论（③）
- 无静态脚本总数钉，动态口径。全仓 `grep -rn "64" scripts/*.sh SKILL.md` 经 selftest/count/total 过滤后逐条排查，命中均为误报（`\{64\}` 十六进制 / Rule 64 条款锚 / 「1-64→1-65」历史演进注释），**未发现把 selftest 脚本总数钉死为 64（或任何定数）的静态断言**。
- 唯二脚本数比对守卫均动态：`selftest-registry.sh` T02/T03（`ls selftest-*.sh`+`comm` 双向）、`selftest-self-resolution.sh` SR-12（`expected=$(ls selftest-*.sh|wc -l)+1`）。新增脚本自动纳入，无需改数 → 未改既有脚本。

## 最终结论
```
status: done
acceptance: 5/5 pass — [1:PASS awk -F'\t' 抽新行 NF=4 | 2:PASS bash selftest exit 0 Total PASS=13 FAIL=0 WARN=0 | 3:PASS STRICT=1 与普通跑 diff IDENTICAL | 4:PASS 计数钉结论写入 findings 追加段 | 5:PASS 删除行仅限 STRICT/WARN 逻辑（净 -9 行）]
files: /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability/skills/task-planner/scripts/selftest-registry.tsv (+1/-0); /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability/skills/task-planner/scripts/selftest-report-reviewability.sh (+?/-9 net; WARN 逻辑改造)
evidence: selftest-registry.tsv:66 → `selftest-report-reviewability.sh<TAB>Rule 70 用户呈报可审批性纪律守护 RRV-01..13（task-v155）<TAB>...`；selftest-report-reviewability.sh:131-146 RRV-06 常驻 FAIL / :148-155 RRV-07 常驻 FAIL；运行 `Total: PASS=13 FAIL=0 WARN=0`；`selftest-registry.sh` → `Total: 5 PASS=5 FAIL=0 (registry rows=65, actual selftest=65)`
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v155-report-approvability/subagent-state/15-executor.md (status: done)
findings_written: #### [sub:15-executor] registry 登记 + RRV-06/07 翻硬档 + 全仓计数钉核查（S15 机械单元）
blockers: none
confidence: HIGH
```
