# S2 General-Purpose 检查点 (task-v184 P-08 接线 + 键批)

## M1 键批+级联 完成 (2026-10-17)
- config.json: vc_nonvacuous_enforce 块后依序加 5 键（enum 均 enforce/warn/off）：
  rvc_coverage_enforce(enforce) / step_placeholder_enforce(enforce) / tier_consistency_enforce(enforce) /
  goal_cjk_enforce(warn) / claim_match_enforce(warn)。+50 行纯新增。
- `jq '.properties|length'`=53；`jq empty` rc=0。
- 级联 48→53：14 selftest 文件 16 行（iteration-persistence/capability-persistence 各 2 行，其余 12 各 1 行）。
  规则沿用 S1：比较值 "48"→"53" / 键数 48→53 / 应 48→53 / expect=48→53 / 键数=48→53；
  历史注释（46→47·44→46·40→42→46）保留不动。
- 验证：`grep -rn '"48"' selftest-*.sh` 零命中(rc=1)；新断言 53 行数=16；历史注释文件=19(保留)。

## M2 P-08 接线双点 完成 (2026-10-17)
- 契约复核 check-rvc-coverage.sh 头注：`bash check-rvc-coverage.sh <plan-dir>` 读 task_plan.md R 行+
  R→VC 映射段；exit 0=覆盖完整(含 SKIP)/1=缺口/2=输入缺失；前缀 [rvc-coverage]。与任务书预期一致。
- attest-plan.sh: P-02 块(line 249-281)后插入同构 P-08 块(282 起)，+33 行纯新增；
  替换: check-vc-nonvacuous.sh→check-rvc-coverage.sh / vnv_→rvc_ / TASK_PLANNER_VC_NONVACUOUS_ENFORCE→
  TASK_PLANNER_RVC_COVERAGE_ENFORCE / vc_nonvacuous_enforce→rvc_coverage_enforce / [vc-nonvacuous]→[rvc-coverage] /
  失败文案→「R→VC 映射缺口（存在未被任何 VC 覆盖的 R 行或 VC 无 R 溯源）」。P-02 块 git diff 零删改。
- check-complete.sh: resolve_rvc_coverage_tier()+RVC_COVERAGE_TIER+run_rvc_coverage() 克隆 run_vc_nonvacuous
  范式(+46 行纯新增，PASS stdout/FAIL stderr/enforce exit1 fail-open 三态)；调用点在 run_vc_nonvacuous
  行后加 `run_rvc_coverage` + 一行注释「[2026-10-17 task-v184-S2/P-08] 同点位接线」(line 1032)。
- 两文件 `bash -n` rc=0；函数/调用点 grep 各 1 处。

## M3 验收逐条实测 完成 (2026-10-17)
- 验收1 config: `jq '.properties|length'`=53；`jq empty` rc=0。
- 验收2 夹具A(.fixture-s2a，3 R 行无 R→VC 映射段+5 VC 真实命令+findings/progress 各≥3 实质行):
  `check-complete.sh` rc=1，stderr 含 `[rvc-coverage] ✗ R1/R2/R3 无 VC 覆盖` + `RVC-COVERAGE FAILED (P-08/task-v184,
  rvc_coverage_enforce=enforce)`。✓
- 验收3 夹具B(.fixture-s2b，同构+完整「### R→VC 映射」表 R1/R2/R3 各≥1 VC): `check-complete.sh` rc=0，
  stdout 含 `[rvc-coverage] ✓ R→VC 双向覆盖完整（R=3 VC=5 映射行=3）`。✓
- 验收4 selftests: vc-gate rc=0(PASS=11 FAIL=0) / state-consistency rc=0(PASS=5 FAIL=0) /
  ask-default-timeout rc=0(PASS=11 FAIL=0)。三项全 PASS。✓
- 验收5 清理: `rm -rf plans/.fixture-s2a plans/.fixture-s2b` 完成；全程零 git 写(仅 git status/diff 只读)。✓
- 附加(全量 selftest, run=90 reused=3): Total 82 PASS/8 FAIL。归因见下「交互回归+既有红」节。

## 交互回归（本投引入，需后续处置 — 不在本任务书 scope）
新 RVC 门(enforce 默认)先于 R-COVERAGE/EVIDENCE-ANCHOR/FINAL-GATE 拦截「有 R 行但缺 R→VC 映射」的
旧夹具，致 3 个既有 selftest 夹具先被 RVC 拦(不再落到被测门):
- selftest-requirement-coverage RC-19/RC-20（stderr 由 [rcov-gate] 变 [rvc-coverage]）
- selftest-evidence-anchor EA-16/EA-19（端到端负例 stderr 被 RVC 抢先）
- selftest-final-gate-hash（夹具 R1 无映射 → RVC exit1 → SKIP-BY-HASH 四元键全失）
处置建议(后续 S-批): 三夹具补「### R→VC 映射」表或对该 selftest 设 TASK_PLANNER_RVC_COVERAGE_ENFORCE=off。

## 既有红（非本投引入，S1 遗留级联缺口）
4 个 selftest 键数断言仍写 47（不在 S1 14 文件级联清单内，config 从 47→48→53 均未同步）:
- selftest-four-file-dataflow FF-15(=47) / selftest-session-log SL-09(=47) /
  selftest-channel-fast-fail CF-03(=47) / selftest-context-pressure CP-09(=47)
- selftest-summary-readability SRV-12(9 级联脚本 pass=7 fail=2, 元检, 反映上述 2 个 stale 失败)
本投未触碰这 5 文件（git diff 确认），config=48(S1 末态) 时 48≠47 即已红 = 既有。是否并入 53 级联 = 后续裁决。

## 结论
键批+级联+P-08 双点接线全部落地，M3 验收 5 条逐条实测通过。引入 3 个 RVC 门交互回归(需后续夹具/档位处置) +
既有 4 个 stale-47 键数断言(S1 级联缺口, 非本投引入)。
