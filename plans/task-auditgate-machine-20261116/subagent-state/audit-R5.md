# audit-R5 — 检查点

- 轮次: R5（复审增量轮）
- 审计体: critic（独立第三方挑刺）
- 开始时间: 2026-11-17T03:26:46+08:00
- 完成时间: 2026-11-17T03:5x+08:00
- 工作目录: /mnt/data/dev/task-planner-skill
- 任务书: plans/task-auditgate-machine-20261116/subagent-state/audit-R5-brief.md
- 复审范围（四面，禁重审全计划）: ①R4 六发现闭环 ②4b 同集零增量闭环+FAIL=0 残留 ③修复引入新缺陷 ④遗留升级必要性
- 只读约束遵守: 除本检查点外零写入；沙箱实测全部在 /tmp；审计前后 `git status --porcelain` 逐字一致（M CLAUDE.md/README_zh.md/skills:plan-resume,todo-skill,workflow-model-tiers/?? .zcode/plans/?? plans/task-auditgate-machine-20261116/）
- 状态: DONE

## 裁决

结论: **REJECTED**（8 发现：CRITICAL×1 / IMPORTANT×1 / WARNING×2 / QUESTION×1 / NIT×3；不满足 0C/0I）

## 发现清单

- **C-1 [CRITICAL]** `verification.md:21` — VC-2 Verify command 断言顺序污染，无任何 PASS 路径
  - 原文: `test "$r1" -ne 0 && test ! -f "$T"/.plan-attestation && grep -q "audit-gate" "$T"/o1; n=$?`
  - 推理: 该断言在正例（r2）已跑完并创建 `$T/.plan-attestation` 之后才求值 → `test ! -f` 恒假 → n=1 → 整条命令 rc=1；若正例未创建锁则 p=1 → 同样 FAIL。锁路径经 `attest-plan.sh:75` 确认为 `$plan_dir/.plan-attestation`。
  - 建议: 负例后立即捕获 `lockneg=$?`（或负/正例各用独立 `$T1/$T2` fixture），最终断言改用捕获值。
- **I-1 [IMPORTANT]** `task_plan.md:324` vs `verification.md:37` — S2 写入位置（EOF 追加）与 VC-6 段锚断言互不兼容
  - 原文: `echo "[scope-check] $(date -u +%Y-%m-%dT%H:%M:%SZ) SCOPE-OK diff=$diffn untracked=$untn" >> "$PROG"`
  - 推理: awk 只在 `### Phase 5:` 到下一个 `## ` 之间取行（progress.md 该区间止于 :73，:74 即 `## 审计留痕占位`）；按命令执行留痕落 EOF → awk 空输出 → 终验必 FAIL（实测）；S2 验收的 grep 位置不敏感 → 缺陷静默潜伏到 merge-back 之后。
  - 建议: S2 改为定位插入 Phase 5 段内（或 VC-6 awk 改全文件扫描+token 格式限定）；并在 progress.md Phase 5 段补 `[scope-check]` 槽位行（W-2 槽位项仍未补）。
- **W-1 [WARNING]** `task_plan.md:253` / `verification.md:36` — 基线漂移条款可被当作判据放宽通道
  - 原文: `若执行期该集合已因其他任务收口而变化（FAIL<7 或名单不同），由主进程重跑冻结新基线`
  - 推理: 仅需一行 `[baseline-shift]` 自述原因即可改判据字面量，本任务新引入的 FAIL 也能以"他任务收口"名义被吸收。
  - 建议: 漂移须逐名归因（每个新增 FAIL 名对应到他任务改动证据）+ 漂移后重走 critic 文本审计。
- **W-2 [WARNING]** `verification.md:203-212`、`:200` — 5-Question Reboot Check / 交叉验证记录仍停在 R1/R2
  - 原文: `Where am I? | Phase 1 in_progress（R1 审计 REJECTED，修复轮已落盘；R2 复审待跑）`
  - 推理: 4b 只同步了 `task_plan.md:205/:209`，verification.md 未同步；会话恢复读该块会拿到过期状态。
- **Q-1 [QUESTION]** `verification.md:54` — V-1.1 基线负断言与 Phase 3 产物天然互斥
  - 原文: `test "$(grep -c 'audit-gate' .../attest-plan.sh)" -eq 0 && test ! -f .../check-plan-audit-gate.sh`
  - 推理: Phase 3 落地后该命令必然为假；若终验复跑 Phase 1 gate 将误判 FAIL（当前无证据表明终验复跑 Phase gate，故列为 QUESTION）。
- **N-1 [NIT]** `verification.md:37` — config 断言在 grep rc=2 时 fail-open
  - 原文: `test -f .../config.json && ! grep -q "\"audit" .../config.json`
  - 推理: 文件存在但不可读 → grep rc=2 → `!` 翻转成功（实测 rc=0）；常量恒败已消除，仅余此理论放行面。
- **N-2 [NIT]** `progress.md:176` — W-2 处置引用的 task_plan 行号 stale（写 :281/:291，实际 :296/:306）。
- **N-3 [NIT]** `progress.md:195` — R4 历史段仍写「VC-6 要求全量 FAIL=0」，可加一句 superseded 指针（历史段不建议改写）。

## 已核验通过的闭环项（负结果报告）

- C-1 原缺陷（grep -c 双零恒败）已消除：真实 config 态 rc=0、注入 `"audit` 键 rc=1、缺文件 rc=1（fail-closed）。
- I-1 时点互斥已消除：VC-6 Verify 无 live worktree/git 依赖；task_plan 无「终验复验」残留（grep rc=1）。
- W-1 `$` 尾锚到位：`.bak/.orig/.md~/swp/.old/...X/` 全部 BLOCK，7 条合法路径全 ALLOW。
- W-2 token 格式在 task_plan:284/:296/:306/:310、verification:35/:36 一致。
- N-1 rc 显式捕获语义正确（rc 0/1 续行、rc≥2 exit 1；`bash -n` rc=0）。
- N-2 VC-1 措辞含 r2；VC-1 Verify command 三段纯 rc 比较无状态污染。
- 4b 基线真实：selftest-*.sh=99，7 名单脚本全部存在且单跑 rc=1（active-plan/batch-pilot/enumerate-first/execution-stability/registry/self-resolution/summary-readability），汇总格式与 `run-selftests.sh:166-167` 逐字一致。
- FAIL=0 残留仅存合法上下文（task_plan:277 新 selftest 自跑 + 历史段），无矛盾判据。
- 三约束：逐字锚 :16-18 未动；user-session-log mtime 仍 2026-11-16 23:39:23；progress.md 无审计段级 APPROVED 预写（四段均 REJECTED）。

## 验证摘要

总发现 8 / 已验证 8 / 通过率 100%
