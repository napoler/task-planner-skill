# Verification Contract & Phase Gates

## Goal (1 sentence)

使 task-planner 在同会话 D 类意图切换/新计划 init 场景下一次完成 side 指针切换（通告清晰、无误导性 skip/--force 循环），并保持防沿袭互踩与既有 fail-open 基线不回退。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> 每条 VC 的 **Verify command** 行=attest vc-gate 判据面（可执行纯命令，禁占位、禁真空，须引用本 VC 产出物；判据=退出码）。

- [x] VC-1: 场景重现——伪造旧计划 `in_progress` + `.session-owner` 占用同 sid，在 /tmp 隔离 plans 根创建新计划目录并执行 worktree 版 `init-session.sh`；side 指针一次写入新计划、输出含旧 claimant 与挂起/恢复提示通告、无 `skip 写入`/无需 `--force`。另补断言：同会话旧 owner 残留时 `set-active-plan.sh set` 对另一 in_progress 计划输出「指针未切换」（对齐 I-3 边界）。
  Evidence: VC-1 命令 stdout/stderr 摘录 + `/tmp` 夹具内 `<plans>/.active_plan_side/<sid>.active_plan` 内容=新计划 task-id；set 夹具输出含「指针未切换」。
  **Verify command**: bash -lc 'set -euo pipefail; WT="/mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120"; INIT="$WT/skills/task-planner/scripts/init-session.sh"; SET="$WT/skills/task-planner/scripts/set-active-plan.sh"; test -x "$INIT"; test -f "$SET"; TMP="$(mktemp -d)"; trap "rm -rf \"$TMP\"" EXIT; SID="ptswt$RANDOM"; export CLAUDE_CODE_SESSION_ID="$SID"; mkdir -p "$TMP/plans/old-claimant" "$TMP/plans/new-switch-task" "$TMP/plans/third-inprog"; printf "### Phase 1\n- **Status:** in_progress\n" > "$TMP/plans/old-claimant/task_plan.md"; printf "### Phase 1\n- **Status:** in_progress\n" > "$TMP/plans/third-inprog/task_plan.md"; printf "sess%s\n" "$SID" > "$TMP/plans/old-claimant/.session-owner"; (cd "$TMP/plans/new-switch-task" && bash "$INIT" >"$TMP/out.txt" 2>"$TMP/err.txt"); SIDE="$TMP/plans/.active_plan_side/${SID}.active_plan"; test -f "$SIDE"; grep -qx "new-switch-task" "$SIDE"; ! grep -q "skip 写入" "$TMP/out.txt" "$TMP/err.txt"; grep -q "old-claimant" "$TMP/out.txt" "$TMP/err.txt"; grep -Eq "挂起|恢复|session-owner|回切" "$TMP/out.txt" "$TMP/err.txt"; (cd "$TMP" && bash "$SET" set third-inprog --sid "$SID" "$TMP" >"$TMP/set_out.txt" 2>"$TMP/set_err.txt" || true); grep -q "指针未切换" "$TMP/set_out.txt" "$TMP/set_err.txt"'

- [x] VC-2: `set-active-plan.sh set` 在同 sid 被在途 claimant 拦截且未带 `--force` 时，输出明确包含「指针未切换」前缀（不再可误读为成功）；调用点评估已记录（默认保持 exit 0，除非评估通过后另行改码）。
  Evidence: worktree 脚本 skip 分支文案锚点 + 行为夹具输出；`findings.md`/`progress.md` 记录 `set-active-plan.sh` 调用点评估结论。
  **Verify command**: bash -lc 'set -euo pipefail; WT="/mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120"; SET="$WT/skills/task-planner/scripts/set-active-plan.sh"; test -f "$SET"; grep -n "指针未切换" "$SET" >/dev/null; TMP="$(mktemp -d)"; trap "rm -rf \"$TMP\"" EXIT; SID="ptset$RANDOM"; mkdir -p "$TMP/proj/plans/claimant-task" "$TMP/proj/plans/my-task"; printf "### Phase 1\n- **Status:** in_progress\n" > "$TMP/proj/plans/claimant-task/task_plan.md"; printf "### Phase 1\n- **Status:** in_progress\n" > "$TMP/proj/plans/my-task/task_plan.md"; printf "sess%s\n" "$SID" > "$TMP/proj/plans/claimant-task/.session-owner"; set +e; (cd "$TMP/proj" && bash "$SET" set my-task --sid "$SID" "$TMP/proj" >"$TMP/out.txt" 2>"$TMP/err.txt"); rc=$?; set -e; grep -q "指针未切换" "$TMP/out.txt" "$TMP/err.txt"; test "$rc" -eq 0; test ! -f "$TMP/proj/plans/.active_plan_side/${SID}.active_plan" -o "$(cat "$TMP/proj/plans/.active_plan_side/${SID}.active_plan" 2>/dev/null)" != "my-task"'

- [x] VC-3: `init-session.sh` 与 `set-active-plan.sh` 的 claimant in_progress 判定锚定状态控制行，兼容非加粗形态 `[-*]\s*(\*\*)?Status:(\*\*)?\s*in_progress`，避免模板注释/散文/说明字样误命中。规范修复前红、修复后绿（行为夹具判别，不绑定实现正则字面拼写；夹具 A/B/C 独立目录防 claimant glob 首命中互扰）。
  Evidence: 行为夹具输出：夹具 A（误命中回归：claimant 仅注释含字样无状态行 → set 应成功写入不被误拦，side=目标计划）；夹具 B（漏判回归：claimant 非加粗状态行 → set 应被拦且输出「指针未切换」、side≠目标）；夹具 C（散文误命中回归：claimant 含模板散文行 `- Update phase status as you progress: pending → in_progress → complete` 且状态行为 complete → set 应成功写入，堵松散行首锚定绕过）；静态反向断言（剥注释后无裸 `grep -qi 'Status.*in_progress'` 带引号字面）。
  **Verify command**: bash -lc 'set -euo pipefail; WT="/mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120"; INIT="$WT/skills/task-planner/scripts/init-session.sh"; SET="$WT/skills/task-planner/scripts/set-active-plan.sh"; test -f "$INIT"; test -f "$SET"; TA="$(mktemp -d)"; TB="$(mktemp -d)"; TC="$(mktemp -d)"; trap "rm -rf \"$TA\" \"$TB\" \"$TC\"" EXIT; SIDA="pta$RANDOM"; mkdir -p "$TA/plans/comment-only" "$TA/plans/target-a"; printf "<!-- 历史注释 Status: in_progress 仅说明 -->\n" > "$TA/plans/comment-only/task_plan.md"; printf "sess%s\n" "$SIDA" > "$TA/plans/comment-only/.session-owner"; printf "### Phase 1\n- **Status:** pending\n" > "$TA/plans/target-a/task_plan.md"; (cd "$TA" && bash "$SET" set target-a --sid "$SIDA" "$TA" >"$TA/a_out.txt" 2>"$TA/a_err.txt"); grep -qx "target-a" "$TA/plans/.active_plan_side/${SIDA}.active_plan"; SIDB="ptb$RANDOM"; mkdir -p "$TB/plans/nonbold-claimant" "$TB/plans/target-b"; printf -- "- Status: in_progress\n" > "$TB/plans/nonbold-claimant/task_plan.md"; printf "sess%s\n" "$SIDB" > "$TB/plans/nonbold-claimant/.session-owner"; printf "### Phase 1\n- **Status:** pending\n" > "$TB/plans/target-b/task_plan.md"; (cd "$TB" && bash "$SET" set target-b --sid "$SIDB" "$TB" >"$TB/b_out.txt" 2>"$TB/b_err.txt" || true); grep -q "指针未切换" "$TB/b_out.txt" "$TB/b_err.txt"; test ! -f "$TB/plans/.active_plan_side/${SIDB}.active_plan" -o "$(cat "$TB/plans/.active_plan_side/${SIDB}.active_plan" 2>/dev/null)" != "target-b"; SIDC="ptc$RANDOM"; mkdir -p "$TC/plans/prose-complete" "$TC/plans/target-c"; printf -- "- Update phase status as you progress: pending → in_progress → complete\n- **Status:** complete\n" > "$TC/plans/prose-complete/task_plan.md"; printf "sess%s\n" "$SIDC" > "$TC/plans/prose-complete/.session-owner"; printf "### Phase 1\n- **Status:** pending\n" > "$TC/plans/target-c/task_plan.md"; (cd "$TC" && bash "$SET" set target-c --sid "$SIDC" "$TC" >"$TC/c_out.txt" 2>"$TC/c_err.txt"); grep -qx "target-c" "$TC/plans/.active_plan_side/${SIDC}.active_plan"; ! { grep -v "^[[:space:]]*#" "$INIT"; grep -v "^[[:space:]]*#" "$SET"; } | grep -Eq "grep -qi .Status.\*in_progress."'

- [x] VC-4: `SKILL.md` D 类意图切换执行清单①包含删除旧计划 `.session-owner`（挂起释占用、回切时 hook 自动重建）及回切 attest 口径；E 类/Rule 94 隔离处置段同步补对应释放占用口径。
  Evidence: `SKILL.md` D 类块（意图切换执行清单→回切通告模板）文本锚点命中 `.session-owner` 与 `attest-plan.sh`；E 类/Rule 94 块（「目标切换判定（E 类」起至下一个 `###` 标题）命中 `.session-owner`。
  **Verify command**: bash -lc 'set -euo pipefail; WT="/mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120"; SK="$WT/skills/task-planner/SKILL.md"; grep -n "意图切换执行清单" "$SK" >/dev/null; DBLOCK="$(awk "/意图切换执行清单/{flag=1} flag{print} /回切通告模板/{exit}" "$SK")"; printf "%s\n" "$DBLOCK" | grep -q ".session-owner"; printf "%s\n" "$DBLOCK" | grep -q "attest-plan.sh"; awk "/目标切换判定（E 类/{flag=1; print; next} flag&&/^### /{exit} flag{print}" "$SK" | grep -q ".session-owner"'

- [x] VC-5: 无新增脚本/守护基建文件；`selftest-pointer-lifecycle.sh` 既有 PL-01..PL-10 语义保留且通过，新增场景断言（PL-11+，含 init 一次切换/通告/fallback 门控/非加粗不漏判）存在且通过；worktree 全部改动（含已提交态，防 commit 绕过）限 scope_files。
  Evidence: selftest 完整输出（Total/PASS/FAIL 含 PL-11+ 行）；scope 判别输出（BAD 列表应为空）。红绿判别方向：修复完成前红（PL-11+ 断言缺失或 selftest FAIL>0 或非 scope 变更/新增脚本存在），修复完成后绿。
  Scope 允许清单：`skills/task-planner/scripts/init-session.sh`, `skills/task-planner/scripts/set-active-plan.sh`, `skills/task-planner/scripts/selftest-pointer-lifecycle.sh`, `skills/task-planner/SKILL.md`。
  **Verify command**: bash -lc 'set -euo pipefail; WT="/mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120"; SELF="$WT/skills/task-planner/scripts/selftest-pointer-lifecycle.sh"; test -f "$SELF"; grep -Eq "PL-1[1-9]" "$SELF"; bash "$SELF" >/tmp/pts_pl_selftest.out 2>&1; grep -q "FAIL=0" /tmp/pts_pl_selftest.out; test "$(grep -cE "^PASS PL-(0[1-9]|10)" /tmp/pts_pl_selftest.out)" -ge 10; test "$(grep -cE "^PASS PL-1[1-9]" /tmp/pts_pl_selftest.out)" -ge 4; ALL="$( { git -C "$WT" status --porcelain --untracked-files=all | sed "s/^...//"; git -C "$WT" diff --name-only f4dc96b; git -C "$WT" diff --cached --name-only f4dc96b; } | grep -v "^$" | grep -v " -> " | sort -u )"; test -n "$ALL"; BAD="$(printf "%s\n" "$ALL" | grep -Ev "^skills/task-planner/(scripts/(init-session|set-active-plan|selftest-pointer-lifecycle)\.sh|SKILL\.md)$" || true)"; test -z "$BAD"'


---

## Phase Gates

### Phase 1: 脚本修复（G1 + G3 + G4）

**Goal**: 在 worktree 中完成 init/set-active-plan 的 claimant 守卫修复与 skip 语义澄清，为一次切换提供脚本层基础。

**Depends on**: none

**Done when**:
- [ ] S1/S2 完成且 diff 仅限 scope_files 中对应脚本
- [ ] init 同 sid 在途 claimant 分支改为通告+直写（G1），in_progress 判定锚定（G3）
- [ ] set-active-plan skip 输出含「指针未切换」（G4）且调用点评估留痕

**Verification** (run before moving on):
- [ ] V-1.1: VC-2 静态+行为夹具通过（set-active-plan 提示明确）
  **Verify command**: bash -lc 'set -euo pipefail; WT="/mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120"; SET="$WT/skills/task-planner/scripts/set-active-plan.sh"; grep -n "指针未切换" "$SET" >/dev/null'
- [ ] V-1.2: VC-3 claimant 守卫行为夹具（误命中/漏判两向回归；A/B 独立目录防 claimant 互扰；目标计划须含 task_plan.md）+ 剥注释无裸全文匹配（规范修复前红/后绿）
  **Verify command**: bash -lc 'set -euo pipefail; WT="/mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120"; SET="$WT/skills/task-planner/scripts/set-active-plan.sh"; TA="$(mktemp -d)"; TB="$(mktemp -d)"; trap "rm -rf \"$TA\" \"$TB\"" EXIT; SIDA="pta$RANDOM"; mkdir -p "$TA/plans/comment-only" "$TA/plans/target-a"; printf "<!-- 历史注释 Status: in_progress 仅说明 -->\n" > "$TA/plans/comment-only/task_plan.md"; printf "sess%s\n" "$SIDA" > "$TA/plans/comment-only/.session-owner"; printf "### Phase 1\n- **Status:** pending\n" > "$TA/plans/target-a/task_plan.md"; (cd "$TA" && bash "$SET" set target-a --sid "$SIDA" "$TA" >"$TA/a_out.txt" 2>"$TA/a_err.txt"); grep -qx "target-a" "$TA/plans/.active_plan_side/${SIDA}.active_plan"; SIDB="ptb$RANDOM"; mkdir -p "$TB/plans/nonbold-claimant" "$TB/plans/target-b"; printf -- "- Status: in_progress\n" > "$TB/plans/nonbold-claimant/task_plan.md"; printf "sess%s\n" "$SIDB" > "$TB/plans/nonbold-claimant/.session-owner"; printf "### Phase 1\n- **Status:** pending\n" > "$TB/plans/target-b/task_plan.md"; (cd "$TB" && bash "$SET" set target-b --sid "$SIDB" "$TB" >"$TB/b_out.txt" 2>"$TB/b_err.txt" || true); grep -q "指针未切换" "$TB/b_out.txt" "$TB/b_err.txt"'

Status: `pending` Last verified: —

---

### Phase 2: SKILL 流程修复（G2）

**Goal**: 更新 D 类/E 类意图切换流程条款，确保挂起登记释放旧计划 `.session-owner` 占用，与脚本一次切换语义对齐。

**Depends on**: Phase 1

**Done when**:
- [ ] D 类清单①含删除旧 `.session-owner` 步骤与回切 hook 重建说明
- [ ] E 类/Rule 94 隔离处置段同步释放占用口径

**Verification**:
- [ ] V-2.1: VC-4 D 类块含 `.session-owner` 释放要求
  **Verify command**: bash -lc 'set -euo pipefail; WT="/mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120"; awk "/意图切换执行清单/{flag=1} flag{print} /回切通告模板/{exit}" "$WT/skills/task-planner/SKILL.md" | grep -q ".session-owner"'
- [ ] V-2.2: VC-4 E 类/Rule 94 段含 `.session-owner` 同步口径（段边界=「目标切换判定（E 类」至下一个 `###`）
  **Verify command**: bash -lc 'set -euo pipefail; WT="/mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120"; awk "/目标切换判定（E 类/{flag=1; print; next} flag&&/^### /{exit} flag{print}" "$WT/skills/task-planner/SKILL.md" | grep -q ".session-owner"'

Status: `pending` Last verified: —

---

### Phase 3: 自测与场景重现验证

**Goal**: 扩展既有 selftest 并执行 VC-1 场景重现，形成用户痛点“一次切换成功”的可复现证据。

**Depends on**: Phase 1, Phase 2

**Done when**:
- [ ] `selftest-pointer-lifecycle.sh` 新增场景断言通过且 PL-01..PL-10 无回退
- [ ] VC-1 bash 命令 exit 0 且指针文件内容正确、输出满足通告判据
- [ ] VC-2~VC-5 证据齐备并记录

**Verification**:
- [ ] V-3.1: VC-1 场景重现命令通过（含同会话旧 owner 残留时 set 输出「指针未切换」边界断言）
  **Verify command**: bash -lc 'set -euo pipefail; WT="/mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120"; INIT="$WT/skills/task-planner/scripts/init-session.sh"; SET="$WT/skills/task-planner/scripts/set-active-plan.sh"; TMP="$(mktemp -d)"; trap "rm -rf \"$TMP\"" EXIT; SID="ptswt$RANDOM"; export CLAUDE_CODE_SESSION_ID="$SID"; mkdir -p "$TMP/plans/old-claimant" "$TMP/plans/new-switch-task" "$TMP/plans/third-inprog"; printf "### Phase 1\n- **Status:** in_progress\n" > "$TMP/plans/old-claimant/task_plan.md"; printf "### Phase 1\n- **Status:** in_progress\n" > "$TMP/plans/third-inprog/task_plan.md"; printf "sess%s\n" "$SID" > "$TMP/plans/old-claimant/.session-owner"; (cd "$TMP/plans/new-switch-task" && bash "$INIT" >"$TMP/out.txt" 2>"$TMP/err.txt"); grep -qx "new-switch-task" "$TMP/plans/.active_plan_side/${SID}.active_plan"; ! grep -q "skip 写入" "$TMP/out.txt" "$TMP/err.txt"; grep -q "old-claimant" "$TMP/out.txt" "$TMP/err.txt"; (cd "$TMP" && bash "$SET" set third-inprog --sid "$SID" "$TMP" >"$TMP/set_out.txt" 2>"$TMP/set_err.txt" || true); grep -q "指针未切换" "$TMP/set_out.txt" "$TMP/set_err.txt"'
- [ ] V-3.2: VC-5 selftest 全通过且无新增 FAIL
  **Verify command**: bash -lc 'set -euo pipefail; WT="/mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120"; bash "$WT/skills/task-planner/scripts/selftest-pointer-lifecycle.sh"'

Status: `pending` Last verified: —

---

### Phase 4: 部署同步、合并回与交付

**Goal**: 将 worktree 修复安全合并回主仓并完成部署同步与防倒退终检，形成可交付状态。

**Depends on**: Phase 3

**Done when**:
- [ ] scope_files 外无意外改动；VC-1~VC-5 全绿
- [ ] 合并回主仓并清理 worktree/分支；部署位同步有证据
- [ ] 防倒退终检与收尾回读梳理收敛

**Verification**:
- [ ] V-4.1: VC-5 scope 与 selftest 证据通过（含 PL-11+ 断言存在性+基线 diff 防 commit 绕过）
  **Verify command**: bash -lc 'set -euo pipefail; WT="/mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120"; SELF="$WT/skills/task-planner/scripts/selftest-pointer-lifecycle.sh"; grep -Eq "PL-1[1-9]" "$SELF"; bash "$SELF" >/tmp/pts_pl_selftest.out 2>&1; grep -q "FAIL=0" /tmp/pts_pl_selftest.out; ALL="$( { git -C "$WT" status --porcelain --untracked-files=all | sed "s/^...//"; git -C "$WT" diff --name-only f4dc96b; git -C "$WT" diff --cached --name-only f4dc96b; } | grep -v "^$" | grep -v " -> " | sort -u )"; test -n "$ALL"; BAD="$(printf "%s\n" "$ALL" | grep -Ev "^skills/task-planner/(scripts/(init-session|set-active-plan|selftest-pointer-lifecycle)\.sh|SKILL\.md)$" || true)"; test -z "$BAD"'
- [ ] V-4.2: VC-1 场景命令在最终代码上可重复通过
  **Verify command**: bash -lc 'set -euo pipefail; WT="/mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120"; INIT="$WT/skills/task-planner/scripts/init-session.sh"; TMP="$(mktemp -d)"; trap "rm -rf \"$TMP\"" EXIT; SID="ptswt$RANDOM"; export CLAUDE_CODE_SESSION_ID="$SID"; mkdir -p "$TMP/plans/old-claimant" "$TMP/plans/new-switch-task"; printf "### Phase 1\n- **Status:** in_progress\n" > "$TMP/plans/old-claimant/task_plan.md"; printf "sess%s\n" "$SID" > "$TMP/plans/old-claimant/.session-owner"; (cd "$TMP/plans/new-switch-task" && bash "$INIT" >/tmp/pts_vc1.out 2>/tmp/pts_vc1.err); grep -qx "new-switch-task" "$TMP/plans/.active_plan_side/${SID}.active_plan"'

Status: `pending` Last verified: —

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| `findings.md:48-75`（根因与 G1-G4） | 对照 P1-P4 S-unit 与 VC 覆盖三环缺陷+误伤面 | 待终验填写 |
| `init-session.sh:1229-1256` / `set-active-plan.sh:263-291` | diff 显示 claimant 守卫与 skip 语义按 CA-1~CA-3 落地 | 待终验填写 |
| `SKILL.md:220,227` | D/E 流程条款含 `.session-owner` 释放口径（VC-4） | 待终验填写 |
| `selftest-pointer-lifecycle.sh` (PL-01..PL-10) | VC-5 selftest 全通过且语义保留 | 待终验填写 |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

```bash
# 证据（粘贴以下 JSON 原文）
bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-pointer-switch-defect-20261120
```

JSON 输出：
```json
{粘贴 stats 命令原文输出}
```

- [ ] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单）
- [ ] 委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由或 stats verdict=violation → check-complete.sh `exit 1` 阻断交付,须按 violations 清单回炉补 plan 或转 PARTIAL 重跑

## 质量门控统计（Rule 26）
- [ ] Q1-Q6 逐项核查完成:触发 __ 项,豁免 __ 项,未处置 __ 项
- [ ] Evidence 抽查 ≥3 条:路径可 Read、结论可复现,抽查记录 __
- [ ] 豁免登记:项号/范围/理由/日期 __ (仅用户显式文字豁免;Q3 不适用)
- [ ] 存在未处置违规 → outcome 已按 Rule 26.3 降级;Q3 → BLOCKED + STOP

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 使同会话明确切换意图下一次完成 side 指针切换且流程释占用
对照 Verification Contract 逐条复验：
- [ ] VC-1: {evidence} → PASS/FAIL
- [ ] VC-2: {evidence} → PASS/FAIL
- [ ] VC-3: {evidence} → PASS/FAIL
- [ ] VC-4: {evidence} → PASS/FAIL
- [ ] VC-5: {evidence} → PASS/FAIL

 outcome: COMPLETE / PARTIAL / BLOCKED
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。

**PARTIAL**：VC 通过但存在已知遗留缺陷 → 列出 + 建议后续。

**BLOCKED**：≥1 VC 失败且 3 次重试无效 → 升级用户决策。

> **验证独立性**：终验核查动作（回归/抽查/对齐审查）由全新独立子代理执行，主进程仅编排与簿记——禁止以主进程既有上下文自测替代验收（Rule 33.3 独立验证延伸）

---

## 交叉验证记录（Rule 108）
| 验证对象 | 机械面路径（命令+结果） | 语义面路径（复检体+结论） | 判定（一致/分歧→108.4 处置） |
|----------|------------------------|--------------------------|------------------------------|
| {VC/交付物/产出} | {cmd + exit/摘录 + 证据路径} | {复检体/critic + 结论 + 证据路径} | 一致 PASS / 分歧→{第三方裁决+留痕} |

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase N |
| 2 | Where am I going? | Remaining phases |
| 3 | What's the goal? | 使同会话明确切换意图下一次完成 side 指针切换且流程释占用 |
| 4 | What have I learned? | See findings.md |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |

### ✅ 终验证据（2026-11-20 主进程批量实跑 /tmp/vc_all.log，13/13 PASS）
- VC-1: PASS（L14）——场景重现：旧计划在途占用同 sid → init 一次切换成功+通告无 skip；set 对 third-inprog 输出「指针未切换」
- VC-2: PASS（L18）——skip 前缀+exit 0+side≠my-task；调用点评估=progress.md:19（zcode-sessionstart:72 gc/selftest×2/plan-hygiene:123/plan-doctor:56 提示性，无 hook 依赖 set 退出码）
- VC-3: PASS（L22）——行为夹具 A（注释 fail-open）/B（非加粗拦截+新文案）/C（散文+complete fail-open）+静态反向（剥注释无裸 grep 字面）
- VC-4: PASS（L26）——D 块含 .session-owner+attest-plan.sh；E 块含 .session-owner（段落边界锚）
- VC-5: PASS（L31）——PL-11..14 各≥1 PASS（共 14 PASS/FAIL=0）+PL-01..10 无回退；scope=status∪diff(f4dc96b)∪cached 判别 BAD=[]（仅 4 个 scope 文件）
- Phase Gates: V-1.1(L51)/V-1.2(L53)/V-2.1(L71)/V-2.2(L73)/V-3.1(L92)/V-3.2(L94)/V-4.1(L113)/V-4.2(L115) 全 PASS
