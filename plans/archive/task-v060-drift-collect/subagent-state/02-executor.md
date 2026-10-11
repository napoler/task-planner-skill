# 02-executor checkpoint — task-v060 Phase 2 S1+S2

## S1 — 10 文件收编 ✅ completed (commit e749017)

- 逐文件 cp（无通配/rsync）10/10: README.md SKILL.md scripts/{check-dispatch,check-scope}.sh scripts/plan-created.cjs scripts/resolve-plan-dir.sh scripts/set-active-plan.sh scripts/task-plan-init.cjs scripts/zcode-pretooluse.sh scripts/zcode-sessionstart.sh
- 证据 1: `git -C <worktree> status --porcelain -- skills/` 恰好 10 个 M 行，无多余
- 证据 2: `diff -q` 部署侧 vs worktree 逐文件 10/10 全部 OK
- 证据 3: `git diff | grep -E '^(old mode|new mode)'` 无输出（无 mode 变更，脚本执行位保留）
- commit: e749017 `feat(task-planner): task-v060/Phase 2 — 收编部署侧 10 文件（哨兵私有化套件+check-dispatch 三级解析+身份判定+sess canon）`（git add 仅 10 文件，非 -A）
- commit 后 scope 10 文件 `git status --porcelain` 为空

## S2a — selftest-dispatch 断言对齐 ✅ completed（无需改写）

- worktree 内（拷入新版 check-dispatch.sh 之后）`bash scripts/selftest-dispatch.sh`：
  改写前 = 改写后: `Total: 12 PASS=12 FAIL=0`, EXIT=0（含 T05 rc=0、T12 rc=0）
- 结论: 新脚本 warn 降级（stderr `[dispatch-guard] ⚠`）与文件身份判定语义下，既有断言全部兼容，selftest-dispatch.sh 未改，不纳入 S2 commit
- 终验（S2 commit 后）重跑: EXIT=0, `Total: 12 PASS=12 FAIL=0`

## S2b — critical-rules.md 措辞核对 ✅ completed (commit 7419e43)

最小修订 3 处（仅矛盾/机制缺失处，未重写章节）:
1. Rule 22.9 sidkey 规范化: 补"sid 以 `sess` 开头时再剥该前缀——sidkey=uuid core,与哨兵文件名 canon 四处对齐"（依据: resolve-plan-dir.sh D11 `norm_sid` sess 前缀剥离 + task-plan-init.cjs normSidkey）
2. Rule 22.9 gc 清扫范围: 补"gc 同语义扩展清扫 `plans/.plan_required_side/` 中 >24h 的 side 哨兵 `*.plan_required`"（依据: set-active-plan.sh L133-139）
3. Rule 22.4c: 补 warn 降级档位 + 身份判定语义——"三级解析: env 显式 / prompt 自声明锚定 → enforce;均未锚定 → resolve 链兜底降级 warn（stderr `[dispatch-guard] ⚠` + exit 0）;三文件缺项扫描按文件身份判定（stat device:inode / 目录 inode / realpath -m，bind mount 双拼写免疫）"（依据: check-dispatch.sh cmd_pretool + scan_missing 头部修改说明）

- commit: 7419e43 `docs(task-planner): task-v060/Phase 2 — Rule 22.9/22.4c 措辞联动（selftest 12/12 全过,未改 selftest-dispatch.sh,不纳入本 commit）`（仅 add critical-rules.md）
- commit 后 `git -C <worktree> status --porcelain` 全空（WORKTREE_CLEAN_EXIT=0）

## 终验（全部完成）

- scope 12 文件（10 收编 + critical-rules + selftest）`git status --porcelain` 为空 → 通过
- selftest-dispatch 终跑 EXIT=0 12/12
- 未触碰部署位（只读）、主仓、plans 目录任何文件;scope 外无发现
