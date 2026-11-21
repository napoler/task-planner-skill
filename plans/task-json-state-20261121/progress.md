# Progress — task-json-state-20261121

## [P1] 定义 schema + 模板 — complete
- 新增 schemas/plan-state.schema.json（145行，draft-07）、templates/plan-state.json（16行）
- Verify: 文件存在 + selftest init 往返 PASS（2026-11-21 实跑）

## [P2] 实现 planctl.py — complete
- 新增 scripts/planctl.py（1069行）：init/get/status/validate/set/add/update/delete/phase-done/vc-pass/vc-fail/audit-add/tag-add/tag-search/render/backup/restore/history/check 共 18 子命令
- 写入安全：临时文件→fsync→os.replace 原子替换；写前备份到 .history/（保留20版）；写前后 validate 失败回滚
- tags 倒排索引：<plan-dir>/../.tags-index.json
- Verify: `python3 skills/task-planner/scripts/selftest-planctl.py` → TOTAL 14 PASS 14 FAIL 0，EXIT=0（主进程 2026-11-21 亲自复跑）

## [P3+P4] 机器门 shim + init-session + SKILL.md SOP — complete
- check-vc-nonvacuous.sh / check-rvc-coverage.sh / check-plan-audit-gate.sh：双读 shim（plan-state.json 存在→planctl check，否则原正则 fallback），外契约 stdout 前缀/rc 0/1/2 不变
- check-evidence-anchor.sh：仅加迁移注释，判定零改（语义不等价，待 planctl 补 source/claim 模型）
- attest-plan.sh：缓存键纳入 plan-state.json sha256（无该文件键逐字不变）
- init-session.sh：6/6 verified 后幂等调 planctl init（已存在跳过，fail-open），打印 `[init] plan-state.json initialized (JSON mode)`
- SKILL.md:302 新增 `## 结构化状态操作 SOP（JSON 权威源）`（302–318），锚行保留未吞段
- 新增 selftest-planctl-shim.sh（SHIM-01..15）+ 登记 selftest-registry.tsv
- Verify: shim selftest 15/15 PASS；planctl 14/14 PASS；定向回归 vc13/rvc9/audit19/evidence26/gate11/final22/antiregress9 全绿（主进程亲自复跑 2026-11-21）
- 全量 selftest（子代理实跑）：改造前 103 PASS=95 FAIL=8；改造后 104 PASS=96 FAIL=8（FAIL 数不增，失败清单一致：active-plan/batch-pilot/enumerate-first/execution-stability/registry/rule-reserve-pairing/self-resolution/summary-readability，均为基线预存）

## [P6] 全量回归 + 端到端试点 — pending
## [P7] 合并 + 部署同步 — pending

## Error Log
- 无本次引入错误。基线预存 8 FAIL 非本任务范围。
