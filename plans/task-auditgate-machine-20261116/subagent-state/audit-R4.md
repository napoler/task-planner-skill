# Audit R4 — task-auditgate-machine-20261116

- 轮次: R4（增量简版复审，第 4 轮）
- 审计体: critic（独立挑刺审查 agent）
- 开始时间: 2026-11-17（本地时区）
- 复审范围（仅三面，禁重审全计划）:
  1. R3 四项发现修复闭环质量（I1 verification.md:37 VC-6 fail-closed 形态逃逸性；I1 task_plan.md:281/:291/:372 范围断言留痕契约与 progress.md:74-76 占位互洽；W1 task_plan.md:284 V-N 分段；N7 verification.md:21 rm -f 负例缓存清理；N8 verification.md:15 rc2 措辞）
  2. 修复是否引入新缺陷（独立复核 R1-R3 逐字锚未动、user-session-log.md #1 原文未动、progress.md 无预写 APPROVED 段）
  3. 上轮 W/Q/NIT 遗留是否需升级 C/I（无新论据则留档）
- 约束: 除本检查点外全仓只读

## 裁决与发现清单

### 裁决: REJECTED（1 CRITICAL / 1 IMPORTANT / 2 WARNING / 2 NIT）

### CRITICAL

**C-1** `verification.md:37` — VC-6 尾部 config 断言恒失败（rc=2），VC-6 永不可 PASS
- 原文: `test "$(grep -c "\"audit" .../config.json || echo 0)" -eq 0`
- 推理: `grep -c` 无命中时**已输出 "0" 且 exit 1**，`|| echo 0` 再追加一个 0 → 变量值 "0\n0" → `test ... -eq 0` 报 "integer expression expected" rc=2；config.json 现 0 命中（实测 grep_rc=1），故完整命令 rc≠0 → run-verification 记 FAIL → 终验 outcome 禁 COMPLETE
- 实测: `bash -c 'set -u; grep -q "^> 三、未完成项与风险 1 授权 2 测试$" .../user-session-log.md && test "$(grep -c "\"audit" .../config.json || echo 0)" -eq 0'` → `bash: line 1: test: 0\n0: integer expression expected`，TAIL_RC=2
- 修复建议: 改 `test "$(grep -c '"audit' "$CFG" || true)" -eq 0"`（`grep -c` 本身已打印 0）或 `! grep -q '"audit' "$CFG"`
- 置信度: HIGH

### IMPORTANT

**I-1** `verification.md:37` + `task_plan.md:281/291` — fail-closed 头与「强制清理 worktree」互斥：VC-6 在标准终验流程下确定性 FAIL（W1 升级）
- 原文: `test -d "$WT" || { echo "[audit-gate] FAIL: worktree 缺失"; exit 1; }`
- 推理: §11.3 与 Phase 5 S2 均要求 merge-back 后 `worktree/分支清理`，Goal Gate 在所有 phase complete 后由独立 verifier 跑 `run-verification.sh`（SKILL.md:151 / verification.md:193），此时 worktree 已不存在 → rc=1 → run-verification `if [ "$rc" -ne 0 ] … fail++ / exit 1`（脚本 :96-:130）→ VC-6 必 FAIL；R3 把「真空放行」换成「确定性阻断」，W1 的时点互斥只是文案分段、机器面未落地。附带 `task_plan.md:269` 仍写「VC-6 时点=全部 Phase 完成后的终验复验」，与 :284/:372 的两段式矛盾
- 实测: `eval "$(sed -n '37p' verification.md 去前缀)"` → `[audit-gate] FAIL: worktree 缺失`，FULL_VC6_RC=1（当前 worktree 状态=清理后状态，`git worktree list` 仅主仓）
- 修复建议: 终验命令改为断言**已留痕证据**（`grep -q '\[scope-check\]' progress.md` 且行内非空），live `git diff/ls-files` 断言限定在 Phase 5 S2 pre-merge 执行（并在 VC 面注明「清理后不可复跑」）；同步删除 task_plan.md:269 陈旧括注
- 置信度: HIGH

### WARNING

**W-1** `verification.md:37` — 白名单正则无行尾锚，同级兄弟文件名可静默越界（fail-open 残留）
- 原文: `grep -vE "^(skills/task-planner/scripts/(attest-plan\.sh|…)|skills/task-planner/SKILL\.md|…)"`
- 推理: 各分支均无 `$`，`SKILL.md.bak` / `SKILL.md~` / `attest-plan.sh.new` 这类真实编辑器副产物命中前缀即被过滤；`plans/…-backup/` 因带 `/` 被正确拦截，说明缺陷只在文件级分支
- 实测: 合成 master+worktree（`/tmp/r4git`），仅加 `skills/task-planner/SKILL.md.bak` → `OUT=[] SCOPE-OK RC=0`；同 fixture 加 `scripts/outside.sh` + `…-backup/task_plan.md` → 正常报 `越界文件` RC=1（控制组有效）
- 修复建议: 每个分支补 `$`（或改用 `grep -vxF -f <白名单文件>`）；selftest 增负例「`SKILL.md.bak` 必须判 FAIL」
- 置信度: HIGH

**W-2** `progress.md:63-72`（Phase 5 段） — 「唯一权威证据」`[scope-check]` 行无模板槽位、无机器断言
- 原文: `- Actions taken:` / `（待执行）… merge back --deploy + push；**merge-back 后…自举实测…**`
- 推理: task_plan.md:281/291 与 verification.md:36 均要求 merge-back **前**写入 `[scope-check]` 完整输出，但 progress 的 Phase 5 段只有通用「待执行」条目，且全文仅 :139 处置回执提到 `[scope-check]`（grep 无占位行）；漏写后终验无任何命令能发现（`[scope-check]` 仅影响完整性，不影响安全）
- 实测: `grep -n "scope-check" progress.md` → 仅 :139
- 修复建议: Phase 5 段增 `[scope-check]（merge-back 前写入）: （待填充）` 占位；并在 VC-6 命令加 `grep -q '^\[scope-check\]' progress.md`
- 置信度: HIGH

### NIT

**N-1** `verification.md:37` — `|| true` 保留 grep rc=2 fail-open 通道；白名单硬编码与 `scope_files` 声明双源
- 原文: `out=$(cat "$D" "$U" | grep -vE "…" || true)`
- 推理: 正则若有误（rc=2）同样落到空输出 → 放行；且白名单是 task_plan.md:64 `scope_files` 的手抄副本，改一处不改另一处会静默漂移（当前两份内容等价）
- 修复建议: `grep … >"$O"; rc=$?; [ "$rc" -le 1 ] || exit 1`；白名单改从 `scope_files` 单源生成
- 置信度: MEDIUM

**N-2** `verification.md:15` — N8 措辞仍略欠完整（未覆盖 r2）
- 原文: `rc 0/1 本命令实测（r3=rc0 正向/r1=rc1 负向），rc2 fail-open 语义见 VC-3 selftest`
- 推理: 命令实际有三态断言（含 `test "$r2" -eq 1` 的 mini×L1 冲突负向），描述漏 r2，读者无法据文案核验第三条
- 修复建议: 补 `r2=rc1（mini×L1 冲突按最严必审）`
- 置信度: MEDIUM

### 反向报告（预期问题但未发现 / 已排除）

- R1-R3 逐字锚 `task_plan.md:16-18` 与 :14 原文行未动（读原文逐字比对通过）
- `user-session-log.md` 未改：mtime 2026-11-16 23:39（其余计划文件 01:35-01:38）；#1 行逐字等于 `> 三、未完成项与风险 1 授权 2 测试`（grep -c=1）；sha256=d12cd51f86…a050714
- `progress.md` 无预写 APPROVED：仅 :75/:129 为「占位说明」文本，唯一 `[plan-audit-R1]` 段为 REJECTED
- N7 已闭合：`rm -f /tmp/attest-cache-*.result` 在 r1 之前，且 glob 与 attest-plan.sh:89 `/tmp/attest-cache-${cksum}.result` 精确匹配
- W1 的 :284 分段文案在位，与 verification.md:35-36、task_plan.md:372 互洽（仅 :269 残留，见 I-1）
- 排除项：checker/selftest 实现面（Phase 3 未执行，脚本尚不存在）、V-5.2 部署位 diff（终验执行期项）、全计划设计重审（不在 R4 范围）

### 验证摘要

总发现 6 / 已盘上复现 6 / 通过率 100%（每条均含命令+输出锚；W-2、I-1、W-1、C-1 为实跑或实读，N-1/N-2 为原文+逻辑复核）
