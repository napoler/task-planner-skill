# checkpoint: task-v065 Phase 4 T-5 (V-13 @configurable 登记 + V-14 账本锁统一)

- agent: executor T-5 | status: done | commit: 39dc8b9
- worktree: /home/terry/task-planner-skill-worktrees/task-v065-subagent-failure-rescue (branch wt/task-v065-subagent-failure-rescue)

## 已完成步骤

1. V-13: 3 个 .ts 顶部插入 @configurable 登记块（参数全部 grep 自代码，无臆造）
   - register-hooks-cj.ts +7 行: settingsPath(~/.claude/settings.local.json, flag --settings) / TASK_PLANNER_ROOT 或 $HOME/dev/task-planner (env TASK_PLANNER_ROOT, flag --canonical) | 并行安全: tmp+rename 原子回写
   - session-catchup.ts +8 行: 会话扫描根 ~/.claude/projects/<sanitize> (flag [project-path], 缺省 cwd) / OPENCODE_DATA_DIR / PLANNING_FILES+SKIP_PREFIXES 静态常量(迁移需改常量) | 纯只读无写路径
   - sync-ide-folders.ts +8 行: CANONICAL="skills/task-planner"(相对 cwd) / IDE_MANIFESTS 13 平台映射表 / TEMPLATES/REFERENCES/SCRIPTS 清单 | 逐文件 copyFileSync 整写
2. V-14: 两条无锁追加套 flock（对齐 ledger-append.sh:125-140 的 `( flock -w 5 9 ... ) 9>lock` 范式, else fail-open 原语句）
   - check-delegation.sh +16/-2 (原 :195-196 附近): lockfile = $plan_dir/${LEDGER_FILE}.lock (即 ledger-delegation.jsonl.lock)
   - allow-direct.sh +15/-2 (原 :117-118 附近): lockfile = $plan_dir/ledger-delegation.jsonl.lock
   - 子壳内变量作用域保持（( ) 子壳继承父函数 local 变量,追加内容/字段/顺序零变化）
   - flock 获取失败/lockfile 不可创建 → `|| true` fail-open, PreToolUse 高频路径正常立即返回

## 验收证据

1. `bash -n scripts/check-delegation.sh scripts/allow-direct.sh` → SYNTAX_OK (exit 0)
2. `bun build --no-bundle` × 3 (register-hooks-cj/session-catchup/sync-ide-folders) → 全部 exit 0 (bun=/home/terry/.bun/bin/bun)
3. `grep -L "@configurable" scripts/*.ts` → 零输出 (grep -L 无命中文件, exit 1)
4. `bash scripts/selftest-delegation.sh` → Total: 38 PASS=38 FAIL=0 (T09/T09b/T22a-c 覆盖 bypass+allow_direct_on 追加路径, 改后全绿)
5. 行为回归: tmp plan-dir 实跑
   - allow-direct on: `{"ts":"2026-09-13T10:12:04Z","event":"allow_direct_on","sid":"fmtsid","expires_at":1789296124,"user_requested":true}` — 与 git HEAD 原语句模板逐字节同构
   - check-delegation T09-replica (owner=main-sid + 有效 .allow-direct): `{"ts":"2026-09-13T10:13:47Z","event":"bypass","sid":"main-sid","trigger":"pretool","remain_sec":1800}` — 与改前模板逐字节同构
   - 并发 10 个 check-delegation bypass 追加 → ledger 恰好 10 行 bypass, 无交错/丢行
   - lockfile `ledger-delegation.jsonl.lock` 在 plan-dir 实际创建

## files_changed (5, +50/-4)
- skills/task-planner/scripts/allow-direct.sh
- skills/task-planner/scripts/check-delegation.sh
- skills/task-planner/scripts/register-hooks-cj.ts
- skills/task-planner/scripts/session-catchup.ts
- skills/task-planner/scripts/sync-ide-folders.ts

## risks
- ledger-append.sh 自身 lockfile 名是 `.ledger_lock`（非 `<ledger>.lock`），三条路径锁名不完全一致（check-delegation/allow-direct 用 `ledger-delegation.jsonl.lock`，ledger-append 用 `.ledger_lock`）—— 不同 lockfile 不互斥，仅防同脚本自身并发；若要三路径全互斥需统一锁名，超出本任务最小 diff 范围，留待后续
- flock 无 `-w 5` 等待上限以外的超时语义: 极端竞争 >5s 时 `|| exit 0` 静默跳过追加（ledger 可能少 1 条），与 ledger-append.sh 口径一致（同为 `flock -w 5 9 || true`）

## 最终结论
T-5 done。V-13/V-14 全部验收通过，提交 39dc8b9，5 文件最小 diff，selftest 38/38 无回退。
