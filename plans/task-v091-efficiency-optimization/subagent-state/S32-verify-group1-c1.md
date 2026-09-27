# S32 组1：C-1 hook 热路径六子项干净上下文独立验证

- 验证方：全新子代理（clean context，不信任既有验证结论）
- 日期：2026-09-27
- 被验对象：worktree /mnt/data/dev/task-planner-skill-worktrees/task-v091（HEAD=a05bd5e）
- 判定：**组1 PASS（a-f 六子项全过，0 FAIL）**
- 约束遵守：worktree/主仓零写入（仅 git show 只读）；夹具全部 /tmp 自建自清（c1g1-a/b/c/c2 已 rm）；/tmp 节流 flag（task-planner-warn/observe-*）已清理

## a) C-1a① stdin .cwd 修复（zcode-pretooluse.sh）

**方法**：/tmp 脚本副本集（git show 6e79257^ 取旧版 zcode-pretooluse.sh + fb67f3a^ 取旧版 check-delegation.sh）；同一 stdin JSON 夹具（`{"session_id":"sess-c1g1-a","cwd":"/tmp","tool_name":"Write","tool_input":{"file_path":"<真实仓 scripts/check-conflicts.sh>"}}`），宿主 PWD=真实 worktree 仓根，xtrace 对比扫描目标。

**实测证据（xtrace 原文节选）**：
- 新版 `bash -x zcode-pretooluse.sh`（宿主 PWD=仓根，stdin .cwd=/tmp）：
  - `84:+ CWD=/tmp`、`85:+ CWD=/tmp`（jq .cwd 取值+兜底链）、`86:+ '[' -d /tmp/plans ']'` → /tmp 无 plans → `for other_plan in $(ls -t ...)` 循环体 0 次执行（xtrace 无循环行）
- 旧版同输入：
  - `75:+ CWD=/mnt/data/dev/task-planner-skill-worktrees/task-v091`（$PWD 直接赋值，.cwd 被忽略）
  - `78:++ ls -t .../plans/task-v055-scheduler-enforce/task_plan.md ... task-v090-workflow-auto-activation/task_plan.md`（实扫 41 个真实计划）
  - `79:+ plan=.../plans/task-v090-workflow-auto-activation/task_plan.md`

**判定**：PASS。新版扫描目标 = stdin .cwd（/tmp），不误扫真实仓；旧版对照实证「宿主 PWD 误扫」缺陷（xtrace 级证据——因旧版 C-1a② 正则缺陷即使误扫 stdout 也不产出 [conflict]，两版 stdout 均只有 skill-modify-warn 一行，故 stdout 非区分证据，xtrace 才是）。

## b) C-1a②③ 完结豁免+正则修复+awk 合并

**selftest 实跑**（worktree 内直接 `bash skills/task-planner/scripts/selftest-rule23-conflict-scan.sh`）：
```
R23-01 PASS 在途第二计划命中 scope → 报 [conflict]
R23-02 PASS 完结计划被豁免
R23-03 PASS 无指针过期在途计划仍被扫到
Total: 3 PASS=3 FAIL=0
rc=0
```

**独立夹具（不依赖 S14 夹具）**：/tmp/c1g1-b，形态 = task_plan.md 无 outcome 行（status: in_progress）+ scope `src/main.py` 命中被写文件，COMPLETE 只落盘于 **verification.md**（`- outcome: COMPLETE`，对齐 zcode-posttooluse.sh:103-105 本仓先例）：
- stdout（rc=0）：`{"additionalContext": "[delegation-observe] .session-owner 未初始化(plan_dir=task-cur,sid=sessc1g1b);..."}` → **无 [conflict]，verification.md 的 COMPLETE 兜底豁免生效**
- 反证对照：同结构把 verification.md 改 `outcome: PARTIAL` → stdout：`{"additionalContext": "[conflict] 文件 /tmp/c1g1-b/src/main.py 可能与其他 plan(task-verify, session=sess-verify)冲突,请确认 scope"}` → 非 COMPLETE 不豁免，检测集语义正确

**判定**：PASS。

## c) C-1b config 双层路径（顶层覆盖键）

**方法**：/tmp/c1g1-c2 临时 config.json = `jq '. + {delegation_enforce:"warn"}' <worktree config.json>`（实测顶层="warn"、`.properties.delegation_enforce.default`="enforce" 双值并存）+ plans/task-act/{task_plan.md,.session-owner=sessc1g1c2} + src/main.c（白名单外、非 trivial、无 allow-direct）。

**实测**：
- NEW（worktree check-delegation.sh，pretool 直跑）：rc=0，stdout：
  `{"additionalContext": "[delegation-warn] ⚠️ 主进程直做尝试拦截(09:59:14,本次会话第 1 次): file=/tmp/c1g1-c/src/main.c ...（30 分钟窗口;会被 ledger 记录并在终验展示）"}`（顶层 warn 生效）
- NEW pretooluse 全链 + 同 config：rc=0，stdout 同样 [delegation-warn]，stderr 0 条 delegation-block
- OLD（fb67f3a^ check-delegation.sh，`.properties.delegation_enforce.default // "enforce"` 单层路径）：同 config 直跑 pretool **rc=2**，pretooluse 全链 stderr：`🚫 主进程直做拦截 — file=/tmp/c1g1-c2/src/main.c`

**判定**：PASS。顶层覆盖键 warn 读中生效；旧版对照实锤单层路径读 schema enforce 拦截（顶层覆盖静默失效）。

## d) C-1c/d scope 提取 lib 化 + check-scope realpath 化

**实测**（worktree 只读 grep）：
- `skills/task-planner/scripts/lib/plan-parse.sh` 存在（2803B），L30 定义 `plan_parse_scope()`
- `sync-todos.sh:20`：`. "$SCRIPT_DIR/lib/plan-parse.sh"`（L16 注释锚 S17 C-1c，L19 shellcheck source）
- `check-conflicts.sh:21`：`. "$SCRIPT_DIR/lib/plan-parse.sh"`（L17 注释锚 S16 C-1c；L139/L166 两处消费 `plan_parse_scope`）
- `check-scope.sh`：`grep -n python3` 仅 1 命中 = L51 注释行（`# ...S17 C-1d] python3 abspath → realpath -m: 去除每次调用 fork python`，改法说明），**可执行 python3 命中 0**；L58 `abs_path="$(realpath -m -- "$FILE_PATH" 2>/dev/null || echo "$FILE_PATH")"` 在位

**判定**：PASS。

## e) C-1e UPS 单 awk

**实测**（zcode-userpromptsubmit.sh）：
- L72 注释锚在位：`# [2026-09-27 task-v091 C-1e] 原实现为 6 组独立字段提取(1 sed 剥注释 + 3 个单行字段 awk +`
- L81 单一 awk 调用：`_ups_fields="$(awk -v plan="$plan" '`（双遍扫描一次产出 5 字段，L87 注释 `# decisions 走原始行(原 :79 awk 直读 $plan...)`）
- L125-131 字段拆分结构在位：`_ups_us=$'\x1e'` + goal/next_step/current/ip/decisions 逐段切出 + `unset -v _ups_fields _ups_us`

**判定**：PASS。

## f) C-1f check-conflicts git 调用合并

**实测**（可执行行 grep，排除注释行）：
- NEW（HEAD）：6 处 = L34(`command -v git`)、L35(`git rev-parse --is-inside-work-tree`)、L49(`CC_WT_LIST="$(git worktree list)"`)、L60(`git status --porcelain`)、L87(`git branch --list 'wt/*'`)、L203(runtime 段 `git status --porcelain`)
- OLD（24e6609^）：9 处 = L34、L35、L43、L57、L62、L66、L70、L179、L182（worktree/branch 各拆 计数+列表 两次独立调用，合并后单次 CC_WT_LIST/wt_branches 派生）

**selftest 实跑**（`bash skills/task-planner/scripts/selftest-check-conflicts.sh`）：
```
CC-01 PASS 未提交变更计数+porcelain 列表+基础设施子信号, rc=1
CC-02 PASS 额外 worktree 计数+路径列表, rc=1
CC-03 PASS 遗留 wt/* 分支计数+列表, rc=1
CC-04 PASS 待处理区在册任务计数=2, rc=1
CC-05 PASS 无冲突基线全绿输出, rc=0
CC-06 PASS runtime 同文件冲突 A 报警+交集文件, rc=1
Total: 6 PASS=6 FAIL=0
rc=0
```

**判定**：PASS。

## 负结果/残留面记录（如实，不包装）

1. a) 项两版 stdout 均 0 [conflict]——非缺陷遗漏：旧版 stdout 无 [conflict] 恰是其 C-1a② 正则缺陷的基线表现（selftest-rule23-conflict-scan.sh 头注 L13-15 已锚定），「不误扫真实仓」的区分证据在 xtrace 扫描目标层（41 个真实 task_plan.md vs /tmp/plans 探测 0 循环），非 stdout 层。
2. f) 项 git 调用 6 处含 L34 `command -v git`（可用性探测）——「9→6」计数口径=可执行 git 相关行全量 grep 排除注释（与 S18 提案口径一致）；纯 `git <subcommand>` 调用为 5 处（L35/49/60/87/203）。
3. b) 项独立夹具中 check-delegation 输出 delegation-observe 行（.session-owner 缺失观察模式）与 [conflict] 无冲突——grep -F '[conflict]' 判定不受该额外 stdout 行干扰。

## 最终判定

**组1 PASS（6/6 子项：a b c d e f 全过，0 FAIL）**
