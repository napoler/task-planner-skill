# 02-executor checkpoint — task-v059-active-plan-race Phase 2

## P2-S1 完成 (2026-09-10)
worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v059-active-plan-race
4 selftest 在 worktree 内直接 `bash skills/task-planner/scripts/<t>` 运行，无需额外环境变量（脚本自定位 SCRIPT_DIR）。
结果（两次复跑一致）：
- selftest-dispatch.sh      EXIT=0  Total: 12 PASS=12 FAIL=0
- selftest-delegation.sh   EXIT=0  Total: 38 PASS=38 FAIL=0（含 T_RATE_OK/T_RATE_LOW 白名单相关 22 用例，T17/T17b/T18/T18b PASS）
- selftest-plan-dispatch.sh EXIT=0  Total: 6  PASS=6  FAIL=0
- selftest-fallback.sh     EXIT=0  Total: 21 PASS=21 FAIL=0（输出含 jq 语法警告 2 行，属该脚本既有 T06e 用例行为，不影响 exit/PASS 计数）
VC-2 通过。注意：selftest-delegation 的 T_RATE_LOW「rate<floor exit1」既有用例仍 PASS，说明 25.4 白名单块未破坏主流程判定。

## P2-S2 进行中
下一步: Read check-complete.sh 定位 whitelist_exempt 段 → /tmp/v059-vctest/ 构造 3 用例。

## P2-S2 完成 (2026-09-10)
### 输入来源弄清（check-complete.sh）
- 判定入口: `bash <worktree>/skills/task-planner/scripts/check-complete.sh <plan-dir>/task_plan.md`（Stop-hook 全链路入口；白名单块在 :407-421）
- 统计来源: :372 调 `check-delegation.sh stats "$PLAN_DIR_GUESS"`（PLAN_DIR_GUESS=plan 文件所在目录, :102）,stdout 单行 JSON;字段 delegation_rate / main_direct[].reason / verdict / violations
- floor: :112 从 config.json `delegation_rate_floor.default` 读,当前 = 0.7
- jq 缺失: :389 grep 正则兜底解析 + :415 `command -v jq` 判定 → 无 jq 时白名单豁免分支不生效（fail-closed）
- 判定命令三用例:
  - case1: `bash $CC /tmp/v059-vctest/case1/plan/task_plan.md`（reason 含「白名单①: git 编排…」）→ exit 0 + 输出 `DELEGATION RATE WHITELIST-EXEMPT` + `DELEGATION GATE PASSED`
  - case2: `bash $CC /tmp/v059-vctest/case2/plan/task_plan.md`（reason「实现登录功能」）→ exit 1 + `DELEGATION GATE FAILED (verdict=violation)`（self_declared_reason violation, 无 EXEMPT 行）
  - case3: `env PATH=/tmp/v059-vctest/nojq-bin bash $CC /tmp/v059-vctest/case1/plan/task_plan.md`（nojq-bin=符号链接 /usr/bin 全部命令但 rm jq;python3/awk/grep 保留）→ exit 1 + `DELEGATION GATE FAILED (verdict=ok rate=0.000 floor=0.7)`,无 EXEMPT 行 = fail-closed 正确
- 判定原理复核: case1 stats rate=0.000<0.7 → rate_ok=0 → main_direct=1 条 reason 命中 grep 白名单关键词 → wl_match>=count → exempt 放行; case2 白名单关键词未命中保持 rate_ok=0,且 reason 无白名单编号 → self_declared_reason violation → verdict=violation 直接 FAILED; case3 无 jq 时 :415 分支跳过 → whitelist_exempt=0 → 保持 FAILED
- 用例与检查文件均在 /tmp/v059-vctest/（case1/plan/*, case2/plan/*, nojq-bin/）,未污染 worktree
VC-7 通过。

## Phase 2 完成 + 回填 (2026-09-10)
- findings.md 新增「Phase 2 Findings」段；progress.md 新增 Phase 2 段（7 条 Test Results 全 PASS）；task_plan.md Phase 2 状态→complete、Current Phase→3、Next Step 更新
- worktree git status 仅 10 文件 M + plans/ 计划目录（Phase 1 遗留），executor 未新增任何 worktree 文件
- 全部 4 S-unit complete；无异常；checkpoint 终稿
