# Verification Contract & Phase Gates

## Goal (1 sentence)

为 md-edit-ops 补齐普通 .md 编辑触发面：在 zcode-pretooluse.sh 增加结构化/批量 .md 编辑 advisory 提醒（A）并完成 task-discipline 语义接线 2 行（B），通过三正三负与 4 项 discipline 校验、5 位部署对账及运行位实弹验证后可交付。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.
> 每条 VC 的 **Verify command** 行=attest vc-gate 判据面——纯命令、禁占位/真空、引用本 VC 产出物。

- [x] VC-1 (P1/A): worktree 内 `zcode-pretooluse.sh` 的 `Write|Edit|ApplyPatch` 分支头部存在纯增量 advisory 块：限定 tool∈{Edit,Write}、file_path 以 `.md` 结尾且路径不含 `/plans/`，命中“Edit old/new 含换行”或“Edit old+new 合计≥200”或“Write content≥600”时 stdout 输出指定 `[md-edit-ops]` 提醒行；含 What+Why 注释；未改动既有阻断/委派逻辑。
  Evidence: `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-mdedit-trigger-20261116/skills/task-planner/scripts/zcode-pretooluse.sh`
  **Verify command**: `SRC=/mnt/data/dev/task-planner-skill; F="$SRC/skills/task-planner/scripts/zcode-pretooluse.sh"; grep -qF '[md-edit-ops] 提醒:' "$F" && grep -qF 'Rule 106.6' "$F" && grep -q 'Write|Edit|ApplyPatch' "$F" && grep -q '/plans/' "$F"`

- [x] VC-2 (P1/B): worktree 内 execution-recall-card §B「变更与范围」区末尾含指定 1 行；task-discipline SKILL 速查/原则区含同义 md-edit-ops 指针（Rule 106.6）且位置可锚定。
  Evidence: worktree 内 `execution-recall-card.md` 与 `task-discipline/SKILL.md`
  **Verify command**: `SRC=/mnt/data/dev/task-planner-skill; R="$SRC/skills/task-discipline/references/execution-recall-card.md"; S="$SRC/skills/task-discipline/SKILL.md"; grep -qF '批量/结构化 markdown 修改优先走 md-edit-ops 指令单（Rule 106.6；apply-report 记 [recheck]）；裸 sed/python 0 命中即 FAIL' "$R" && grep -q 'md-edit-ops' "$S" && grep -q 'Rule 106.6' "$S"`

- [x] VC-3 (P2/hook 三正三负): 对 worktree 脚本模拟 3 正 3 负输入，正例 stdout 含 `[md-edit-ops] 提醒:` 且 exit 0，负例 stdout 不含该提醒且 exit 0（含 /plans/ 路径、单行小改、短 Write 排除）。
  Evidence: P2 验收日志（命令输出落 `progress.md`/`findings.md`）
  **Verify command**: `bash -lc 'H="/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/zcode-pretooluse.sh"; p1=$(printf "%s" "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/x.md\",\"old_string\":\"a\nb\",\"new_string\":\"c\"}}" | bash "$H"); o=$(printf "a%.0s" {1..120}); p2=$(printf "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/y.md\",\"old_string\":\"x\",\"new_string\":\"%s\"}}" "$o$o" | bash "$H"); c=$(head -c 650 /dev/zero | tr "\0" "m"); p3=$(printf "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"/tmp/z.md\",\"content\":\"%s\"}}" "$c" | bash "$H"); n1=$(printf "%s" "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/plans/a.md\",\"old_string\":\"a\nb\",\"new_string\":\"c\"}}" | bash "$H"); n2=$(printf "%s" "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/a.md\",\"old_string\":\"hi\",\"new_string\":\"yo\"}}" | bash "$H"); n3=$(printf "%s" "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"/tmp/a.md\",\"content\":\"short\"}}" | bash "$H"); echo "$p1$p2$p3" | grep -q "md-edit-ops] 提醒:" && ! echo "$n1$n2$n3" | grep -q "md-edit-ops] 提醒:"'`

- [x] VC-4 (P2/discipline 4 项 RC=0): discipline 接线 4 项校验全部通过（召回卡指定行、SKILL 指针含 md-edit-ops、SKILL 指针含 Rule 106.6、召回卡仍含 §B 锚点不破坏结构）。
  Evidence: worktree 文件 + P2 命令输出
  **Verify command**: `bash -lc 'SRC=/mnt/data/dev/task-planner-skill; R="$SRC/skills/task-discipline/references/execution-recall-card.md"; S="$SRC/skills/task-discipline/SKILL.md"; test -f "$R" && test -f "$S" && grep -qF "批量/结构化 markdown 修改优先走 md-edit-ops 指令单（Rule 106.6；apply-report 记 [recheck]）；裸 sed/python 0 命中即 FAIL" "$R" && grep -q "## B. 变更与范围" "$R" && grep -q "md-edit-ops" "$S" && grep -q "Rule 106.6" "$S"'`

- [x] VC-5 (P3/部署 5 位+对账): A/B 变更已部署到 5 位技能位（zcode/claude/cursor/agents/opencode 对应 task-planner hook 与 task-discipline 接线文件的实际存在位），各位目标文件与 worktree 合并后源一致（或与批准源一致）且对账无差异。
  Evidence: P3 对账 diff 输出（`diff -u`/`cmp` 结果）记录于 progress/findings
  **Verify command**: `bash -lc 'S=/mnt/data/dev/task-planner-skill/skills; h=0; d=0; for base in "$HOME/.zcode" "$HOME/.claude" "$HOME/.cursor" "$HOME/.agents" "$HOME/.config/opencode"; do cmp -s "$S/task-planner/scripts/zcode-pretooluse.sh" "$base/skills/task-planner/scripts/zcode-pretooluse.sh" && h=$((h+1)); if [ -d "$base/skills/task-discipline" ]; then cmp -s "$S/task-discipline/references/execution-recall-card.md" "$base/skills/task-discipline/references/execution-recall-card.md" && cmp -s "$S/task-discipline/SKILL.md" "$base/skills/task-discipline/SKILL.md" && d=$((d+1)); fi; done; test "$h" -eq 5 -a "$d" -eq 4'`

- [x] VC-6 (P3/运行位实弹): 在至少 1 个已部署运行位上对 hook 执行一正一负实弹，正例输出 `[md-edit-ops] 提醒:` 且 exit 0，负例不输出该提醒且 exit 0。
  Evidence: 运行位命令与输出摘录（含路径）
  **Verify command**: `bash -lc 'H="$HOME/.zcode/skills/task-planner/scripts/zcode-pretooluse.sh"; test -x "$H" || test -f "$H"; p=$(printf "%s" "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/x.md\",\"old_string\":\"a\\nb\",\"new_string\":\"c\"}}" | bash "$H"); echo "$p"|grep -q "\[md-edit-ops\] 提醒:"; n=$(printf "%s" "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/plans/x.md\",\"old_string\":\"a\\nb\",\"new_string\":\"c\"}}" | bash "$H"); echo "$n"|grep -q "\[md-edit-ops\] 提醒:" && exit 1 || exit 0'`

---

## Phase Gates

### Phase 1: Worktree 实施 A+B

**Goal**: 在隔离 worktree 中完成 hook advisory（A）与 discipline 语义接线 2 行（B），不改既有阻断/委派逻辑。

**Depends on**: none

**Done when**:
- [ ] worktree `tmp/worktrees/task-mdedit-trigger-20261116` 创建且含目标文件副本
- [ ] Scope A/B 变更在 worktree 内落地并自检通过

**Verification** (run before moving on):
- [ ] V-1.1: VC-1（hook advisory 块与条件/文案/注释在位，既有逻辑保留）
  **Verify command**: `SRC=/mnt/data/dev/task-planner-skill; F="$SRC/skills/task-planner/scripts/zcode-pretooluse.sh"; grep -qF '[md-edit-ops] 提醒:' "$F" && grep -qF 'Rule 106.6' "$F" && grep -q '/plans/' "$F" && grep -q 'What' "$F" && grep -q 'Why' "$F"`
- [ ] V-1.2: VC-2（recall-card 指定行 + SKILL 同义指针在位）
  **Verify command**: `SRC=/mnt/data/dev/task-planner-skill; R="$SRC/skills/task-discipline/references/execution-recall-card.md"; S="$SRC/skills/task-discipline/SKILL.md"; grep -qF '批量/结构化 markdown 修改优先走 md-edit-ops 指令单（Rule 106.6；apply-report 记 [recheck]）；裸 sed/python 0 命中即 FAIL' "$R" && grep -q 'md-edit-ops' "$S" && grep -q 'Rule 106.6' "$S"`

Status: `pending`  Last verified: —

---

### Phase 2: 模拟验收

**Goal**: 在 worktree 产物上完成 hook 三正三负与 discipline 4 项校验，全部 RC=0/判据通过。

**Depends on**: Phase 1

**Done when**:
- [ ] 三正三负场景输出与退出码符合预期
- [ ] discipline 接线 4 项检查通过并留证据

**Verification**:
- [ ] V-2.1: VC-3（hook 三正三负，advisory 仅命中场景触发且 fail-open exit 0）
  **Verify command**: `bash -lc 'SRC=/mnt/data/dev/task-planner-skill; H="$SRC/skills/task-planner/scripts/zcode-pretooluse.sh"; set -e; for case in 1 2 3; do :; done; p1=$(printf "%s" "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/x.md\",\"old_string\":\"a\\nb\",\"new_string\":\"c\"}}" | bash "$H"); echo "$p1"|grep -q "\[md-edit-ops\] 提醒:"; p2=$(python3 -c "import json;print(json.dumps({\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/y.md\",\"old_string\":\"x\",\"new_string\":\"a\"*250}}))" | bash "$H"); echo "$p2"|grep -q "\[md-edit-ops\] 提醒:"; p3=$(python3 -c "import json;print(json.dumps({\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"/tmp/z.md\",\"content\":\"m\"*700}}))" | bash "$H"); echo "$p3"|grep -q "\[md-edit-ops\] 提醒:"; n1=$(printf "%s" "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/plans/a.md\",\"old_string\":\"a\\nb\",\"new_string\":\"c\"}}" | bash "$H"); echo "$n1"|grep -q "\[md-edit-ops\] 提醒:" && exit 1 || true; n2=$(printf "%s" "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/a.md\",\"old_string\":\"hi\",\"new_string\":\"yo\"}}" | bash "$H"); echo "$n2"|grep -q "\[md-edit-ops\] 提醒:" && exit 1 || true; n3=$(printf "%s" "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"/tmp/a.md\",\"content\":\"short\"}}" | bash "$H"); echo "$n3"|grep -q "\[md-edit-ops\] 提醒:" && exit 1 || true'`
- [ ] V-2.2: VC-4（discipline 关联 4 项 RC=0）
  **Verify command**: `bash -lc 'SRC=/mnt/data/dev/task-planner-skill; R="$SRC/skills/task-discipline/references/execution-recall-card.md"; S="$SRC/skills/task-discipline/SKILL.md"; test -f "$R" && test -f "$S" && grep -qF "批量/结构化 markdown 修改优先走 md-edit-ops 指令单（Rule 106.6；apply-report 记 [recheck]）；裸 sed/python 0 命中即 FAIL" "$R" && grep -q "## B. 变更与范围" "$R" && grep -q "md-edit-ops" "$S" && grep -q "Rule 106.6" "$S"'`

Status: `pending`  Last verified: —

---

### Phase 3: 部署 5 位+对账+运行位实弹+收口

**Goal**: 将 A+B 变更部署至 5 位技能位并完成对账与运行位实弹验证，按体量完成收口（归档/kb 视体量）。

**Depends on**: Phase 2

**Done when**:
- [ ] 5 位目标位（zcode/claude/cursor/agents/opencode）对应文件已部署且对账一致
- [ ] 运行位实弹一正一负通过
- [ ] 收尾记录（归档/kb 决策与证据）完成

**Verification**:
- [ ] V-3.1: VC-5（5 位部署存在且对账命令可执行并记录结果）
  **Verify command**: `bash -lc 'ok=0; for base in "$HOME/.zcode" "$HOME/.claude" "$HOME/.cursor" "$HOME/.agents" "$HOME/.config/opencode"; do [ -d "$base/skills/task-planner" ] && [ -d "$base/skills/task-discipline" ] && ok=$((ok+1)); done; echo "present=$ok"; test "$ok" -ge 5'`
- [ ] V-3.2: VC-6（运行位实弹一正一负）
  **Verify command**: `bash -lc 'H="$HOME/.zcode/skills/task-planner/scripts/zcode-pretooluse.sh"; p=$(printf "%s" "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/x.md\",\"old_string\":\"a\\nb\",\"new_string\":\"c\"}}" | bash "$H"); echo "$p"|grep -q "\[md-edit-ops\] 提醒:"; n=$(printf "%s" "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/plans/x.md\",\"old_string\":\"a\\nb\",\"new_string\":\"c\"}}" | bash "$H"); echo "$n"|grep -q "\[md-edit-ops\] 提醒:" && exit 1 || exit 0'`

Status: `pending`  Last verified: —

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| `plans/archive/task-mdedit-reliability-20261116/knowledge-brief.md` §2/§3 | A/B 设计与 md-edit-ops/Rule 106.6 事实一致 | 待终验 |
| `skills/task-planner/scripts/zcode-pretooluse.sh` | advisory 插入点与 fail-open/不破坏阻断链 | 待终验 |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据。

```bash
# 证据（粘贴以下 JSON 原文）
bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats <plan-dir>
```

JSON 输出：
```json
{待执行期填充}
```

- [ ] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单）
- [ ] 委派率达标或已登记例外

## 质量门控统计（Rule 26）
- [ ] Q1-Q6 逐项核查完成:触发 __ 项,豁免 __ 项,未处置 __ 项
- [ ] Evidence 抽查 ≥3 条:路径可 Read、结论可复现,抽查记录 __
- [ ] 豁免登记:项号/范围/理由/日期 __
- [ ] 存在未处置违规 → outcome 已按 Rule 26.3 降级

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — md-edit-ops 触发面封堵（A+B）
对照 Verification Contract 逐条复验：
- [x] VC-1: hook advisory 在位且不破坏既有逻辑 → PASS/FAIL
- [x] VC-2: discipline 语义接线 2 行在位 → PASS/FAIL
- [x] VC-3: hook 三正三负通过 → PASS/FAIL
- [x] VC-4: discipline 4 项 RC=0 → PASS/FAIL
- [x] VC-5: 5 位部署+对账通过 → PASS/FAIL
- [x] VC-6: 运行位实弹一正一负通过 → PASS/FAIL

 outcome: COMPLETE / PARTIAL / BLOCKED
```

## 交叉验证记录（Rule 108）
| 验证对象 | 机械面路径（命令+结果） | 语义面路径（复检体+结论） | 判定（一致/分歧→108.4 处置） |
|----------|------------------------|--------------------------|------------------------------|
| 未触发（紧凑补丁，按实际执行判定） | — | — | — |

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase 1（计划完成，待实施） |
| 2 | Where am I going? | P1→P2→P3 |
| 3 | What's the goal? | 封堵 md-edit-ops 触发面缺口（A+B），验收三正三负/4 项/5 位对账+实弹 |
| 4 | What have I learned? | See findings.md / knowledge-brief.md |
| 5 | What have I done? | 计划 5 文件实质填充 + user-session-log #1 |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
