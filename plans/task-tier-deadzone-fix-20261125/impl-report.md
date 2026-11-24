# impl-report: task-tier-deadzone-fix-20261125

## Scope
- Worktree: `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-tier-deadzone-fix-20261125` (branch `wt/task-tier-deadzone-fix-20261125`, base master)
- Task: tier 升级链三死角修复（#1 跨工具/#2 幂等粒度/#3 半升级静默）+ #5 完结守卫对象兼容

## Files Changed

| File | Change |
|---|---:|
| `skills/task-planner/scripts/lib/tier-upgrade-lib.sh` | +139 (new) |
| `skills/task-planner/scripts/tier-upgrade-check.sh` | +38 (new, chmod +x) |
| `skills/task-planner/scripts/zcode-posttooluse.sh` | +13 / -92 (tier block replaced by lib source; #5 object-compat) |
| `skills/task-planner/lib/install-stub.sh` | +11 / -2 (claude/opencode-cursor/config-example PostToolUse + tier-upgrade-check.sh) |
| `skills/task-planner/SKILL.md` | +2 / -1 (:51 no-hook self-check bullet; :173 mini note) |
| `skills/task-planner/scripts/selftest-context-pressure.sh` | +3 / -2 (emit baseline 13→14) |

`git diff --stat` (tracked):
```
 skills/task-planner/SKILL.md                       |   3 +-
 skills/task-planner/lib/install-stub.sh            |  11 ++-
 .../scripts/selftest-context-pressure.sh           |   5 +-
 skills/task-planner/scripts/zcode-posttooluse.sh   | 104 ++-------------------
 4 files changed, 24 insertions(+), 99 deletions(-)
```
Untracked (new): `skills/task-planner/scripts/lib/tier-upgrade-lib.sh`, `skills/task-planner/scripts/tier-upgrade-check.sh`.

## Key Implementation Notes

- **#1 跨工具单一事实源**: `tier_upgrade_check()` lives only in `scripts/lib/tier-upgrade-lib.sh`; zcode host sources it with `tier_emit(){ emit "$1"; }` JSON wrapper and exits on `TIER_UPGRADED=1` (F9 single-JSON). `tier-upgrade-check.sh` is plain-text host for claude/cursor/opencode PostToolUse.
- **#2 幂等粒度**: state file `plans_root/.tier_state/${sid}_${taskkey}.state`, taskkey sanitized `[a-zA-Z0-9_-]` from task_id/basename. Legacy `<sid>.state` left as harmless orphan.
- **#3 state-first + repair**: fresh upgrade writes `upgrading=1` before mutating plan; on interrupted state (file exists, not `upgraded=1`) repair branch retries set/TU-1-precheck-add/render/rm stale lock, flips `upgraded=1`, emits repair notice. Each step failure emits `[tier-upgrade] FAIL: <step>（下轮自动补偿）`, returns 0 (fail-open, no block).
- **#5 outcome object compat**: completion guard uses `(.outcome // "") | (if type == "object" then (.result // "") else . end) | test("^(COMPLETE|BLOCKED)$")` in both lib and zcode-posttooluse.sh main guard.
- **init-standard not hijacked**: state absent + tier!=mini returns 0 (no fake TU-1).
- **install-stub**: claude JSON PostToolUse now has Write|Edit + `*` tier check; opencode/cursor frontmatter appended `*` tier check; config example chained with `;`; zcode-frontmatter template left untouched (real registration in user cli/config.json needs auth).

## Self-checks

- `bash -n` (4 files): PASS (`lib/tier-upgrade-lib.sh`, `tier-upgrade-check.sh`, `zcode-posttooluse.sh`, `lib/install-stub.sh`)
- G1 single source: `grep -rn "tier_upgrade_check()" skills/task-planner/scripts/ | grep -v lib/tier-upgrade-lib.sh` = empty (PASS)
- G2 install-stub registration: `grep -c "tier-upgrade-check.sh" skills/task-planner/lib/install-stub.sh` = `3` (PASS)
- G3 no hardcoded home path in new files: `grep -n '$HOME/.zcode|$HOME/.claude' lib/tier-upgrade-lib.sh tier-upgrade-check.sh` = NONE (PASS)
- G4 TIER_UPGRADED present in host+lib: zcode-posttooluse.sh:217,222; lib:14,68,137 (PASS)

## Emit Baseline

- `zcode-posttooluse.sh` emit count: `14` (was `13`). Delta: `+1` from `tier_emit() { emit "$1"; }` host adapter line; actual upgrade emit text moved into shared lib (counted by `emit ` grep in lib, not in zcode host). `selftest-context-pressure.sh` CP-06 baseline updated 13→14 with task-tagged comment (a865074b precedent).

## Risks / Residual

- **P3 selftest not run** (by constraint): `run-selftests.sh` / CP-06 runtime not executed here; main process should run at least `bash skills/task-planner/scripts/selftest-context-pressure.sh` and relevant tier selftests.
- **New files untracked**: lib and tier-upgrade-check.sh are `??` in worktree; main process must `git add` them before commit.
- **zcode real registration** not changed (intentional): user `~/.zcode` config requires auth; template unchanged, documented in lib comment.
- **Repair branch best-effort**: repair emits FAIL per step but continues remaining steps and flips `upgraded=1` to avoid infinite repair loops; next round re-enters only if state missing/corrupt. This trades "possibly incomplete repair marked upgraded" for bounded retry; FAIL emits provide operator visibility.
- **No py_compile needed**: no Python files changed.

## 夹具实跑结果

Fixture: `/mnt/data/dev/task-planner-skill/plans/task-tier-deadzone-fix-20261125/fixtures-tier.sh` (worktree-only, sandbox `/tmp/tierfx-$$`, cleanup on exit). Run command: `bash /mnt/data/dev/task-planner-skill/plans/task-tier-deadzone-fix-20261125/fixtures-tier.sh`.

| Case | Result | Coverage |
|---|---|---|
| T1 | PASS | #2 幂等粒度：同 sid 两计划 A/B 各自产生 `<sid>_<taskkey>.state` upgraded=1；legacy `<sid>.state` 保留不迁移；两次 emit 含“已运行” |
| T2 | PASS | #3 自愈：`upgrading=1` 中断 state + tier 已 standard → repair 补 TU-1/render/rm stale lock，state 翻 upgraded=1，emit 含“半升级自愈” |
| T3 | PASS | #3 FAIL 曝光+state-first：chmod 555 plan-dir 导致 set 失败，emit 含 `FAIL: set`，state 先落 `upgrading=1`，rc=0 fail-open |
| T4 | PASS | 静态注册面：单一事实源 grep、install-stub 3 处、无 $HOME/.zcode\|.claude、新 host+lib TIER_UPGRADED、SKILL.md 无hook条款、env 两键均 MINUTES、check 脚本可执行 |
| T5 | PASS | #5 对象兼容：outcome={"result":"COMPLETE"} 时守卫命中，tier 仍 mini，无 state/TU-1；表达式对 object COMPLETE/scalar COMPLETE=rc0、object PARTIAL=rc!=0 |
| T6 | PASS | 独立脚本端到端：stdin JSON -> tier-upgrade-check.sh -> fx-g 升 standard，`fx7_fx-g.state` upgraded=1，emit 含“已运行” |

Summary: `FIXTURES-DONE FAIL=0 TOTAL=6`, exit code 0.

Fixture bug fixed during authoring (not implementation change): state filenames used underscores where task ids contained hyphens (`fxsid_fxa.state` vs actual `fxsid_fx-a.state`); corrected in fixture only after diagnosing via manual trace. No lib/script code changed to satisfy tests.

## R2 返工（2026-11-25，critic R1=REJECTED：1 CRITICAL + 3 IMPORTANT + 2 WARNING + 2 NIT，均已实测复现）

Worktree: `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-tier-deadzone-fix-20261125-r2`（base master 403bfb78）。

### 逐项状态

| 项 | 状态 | 落点与要点 |
|---|---|---|
| F1 C-1 repair 假成功/永久死区 | DONE | lib repair 分支改为三条件门 `[tier=standard] ∧ [render rc=0] ∧ [TU-1 在位]` 才 `rm 旧锁 + 写 upgraded=1 + 发自愈完成 + TIER_UPGRADED=1`；否则保持 `upgrading=1`、只发 FAIL。set 后强制回读档位（rc=0≠已落盘）。fresh 分支同加回读门 + state 落盘失败即不发成功文案 |
| F2 I-2 repair 入口收紧 | DONE | 仅 `grep -q '^upgrading=1'` 进 repair；空文件/垃圾行/未知内容 → `rm -f "$sfile"` 视为脏键回落 fresh 判定；init-standard 仍静默（无 TU-1 伪造） |
| F3 I-1 F9 单轮单 JSON | DONE | 新增 `tier_note`（累加 `TIER_MSGS`）+ 唯一出口 `tier_flush`；`tier_upgrade_check` = 清缓冲 → `_tier_upgrade_body` → flush，结构上保证一轮至多一次 `tier_emit`。库内 `tier_emit "` 调用点=1（实测） |
| F4 N-1 原子写/口径/悬空形参 | DONE | `tier_write_state` 恢复 tmp+mv；planctl 缺失改 FAIL 曝光；`$p` 改为 plan-dir(/plans_root) 兜底来源，4 参调用方零破坏 |
| F5 N-2 手动跑挂起 | DONE | `[ -t 0 ] && input=""` 短路；顶部注明「有意不随 set -euo pipefail」及 fail-open 理由 |
| F6 I-3 register-hooks-cj.ts | DONE | PostToolUse 追加 `matcher:'*'` + `tier-upgrade-check.sh` 条目，形态与同文件既有条目一致（未改既有条目 schema）。`bun build --no-bundle` 通过 |
| F7 夹具重写 + T7/T8 | DONE | 见下 |
| F8 语法与自检 | DONE | bash -n ×3 + ts 构建；四项自检全过（见下） |
| 追加决定 | DEVIATION-1 | **zcode 宿主在 `TIER_EMITTED=1`（含 FAIL 轮）时 exit 0**，与任务书「FAIL 轮 return 后照旧走提醒链」不同：R1 实测 FAIL 轮 = tier 行 + plan-sync 行 2 条 JSON，只合并 tier 消息不足以满足 F9；提醒链顺延到下一轮（FAIL 每轮重试曝光，不丢信息）。若否决，删 `zcode-posttooluse.sh` 中 `TIER_EMITTED` 那一行即可回退 |

### F8 自检

- ① lib 内 `tier_emit "` 调用点 = 1（仅 `tier_flush`）：PASS
- ② repair 分支含 `'^upgrading=1'` 锚：PASS
- ③ `grep -c "tier-upgrade-check" register-hooks-cj.ts` = 1：PASS
- ④ fixtures `WT` 默认 = 主仓 `/mnt/data/dev/task-planner-skill`：PASS
- 附：hook `emit ` 行数仍 = 14 → `selftest-context-pressure.sh` CP-06 PASS（9/9）；`selftest-plan-tier` 32/32、`selftest-tier-b` 18/18、`selftest-tier-consistency` 8/8 全 PASS

### 夹具实跑（r2 worktree 实跑）

Run: `TIER_FX_WT=<r2 worktree> bash plans/task-tier-deadzone-fix-20261125/fixtures-tier.sh`

| Case | Result | 断言要点（均落在真实盘面） |
|---|---|---|
| T1 | PASS | legacy 键放真实旧位 `plans/.tier_state/fxsid.state` 且内容不变；A/B 各生成新键 upgraded=1；各含「已运行」；rc=0 |
| T2 | PASS | upgrading=1 + tier 已 standard → 补 TU-1、翻 upgraded=1、发「半升级自愈」、TIER_UPGRADED=1、emit 计数=1 |
| T3 | PASS | chmod 555 → 含 `FAIL: set`、state=upgrading=1、tier=mini、无成功文案、TIER_UPGRADED 未置、emit=1 |
| T4 | PASS | 单一事实源 / install-stub 3 处 / 无 $HOME 硬编码 / SKILL 条款 / env 两键 / register-hooks 含 tier / `tier_emit "` 唯一 / check 可执行 |
| T5 | PASS | object/scalar COMPLETE 命中、object PARTIAL 不命中；守卫命中时静默无 state/TU-1 |
| T6 | PASS | stdin JSON → tier-upgrade-check.sh → 升档 + 新键 upgraded=1 + 输出含「已运行」 |
| T7 | PASS | 半升级 + 持续失败两轮：均含 FAIL、state 恒 upgrading=1、tier 恒 mini、无 TU-1/无成功文案、emit=1；恢复权限第三轮真自愈（standard + TU-1 + upgraded=1 + 「自愈完成」+ TIER_UPGRADED=1） |
| T8 | PASS | 空 state / 垃圾 state 在 standard 计划上：无 TU-1 伪造、无输出、脏键被清；fresh 成功路径 emit=1 含「已运行」；zcode 宿主同场景输出严格 1 行 JSON |

Summary: `FIXTURES-DONE FAIL=0 TOTAL=8`。

### 遗留风险

1. **提醒链顺延**（DEVIATION-1 的代价）：tier 故障持续期间，同轮其他提醒（plan-sync/findings/progress/todo-sync/drift-rhythm）不投递；故障修复后自动恢复。若判为不可接受，可改为「tier 消息并入提醒缓冲」的重构（改动面大，未做）。
2. **claude 端点注册仍未生效**：register-hooks-cj.ts 已含 tier 条目，但现网 `~/.claude/settings.local.json` 未重跑注册脚本；需用户执行一次 `node --experimental-strip-types scripts/register-hooks-cj.ts`（写个人配置须授权）。install-stub 的 JSON 片段仍是 `{matcher,command}` 扁平形态（与本文件既有形态一致，未顺手改 schema；Claude Code 官方 schema 为 `{matcher,hooks:[{type,command}]}`）。
3. **taskkey 非 ASCII 退化**：task_id 全非 `[a-zA-Z0-9_-]` 时降为 `plan`，同会话两个无 ASCII id 计划会撞键。
4. 夹具 T1 的「legacy 不迁移」至此为真值断言（旧键位于代码会读的 state 目录内），但代码未来若主动清理旧键需同步该断言。

