# 10-code-assistant checkpoint — task-v064-smart-merge-back / Phase 5 修复轮 5（Code Review Gate R4）
status: done
commit: 6664aa8 (wt/task-v064-smart-merge-back, worktree /mnt/data/dev/task-planner-skill-worktrees/task-v064-smart-merge-back)
files: skills/task-planner/scripts/smart-merge-back.sh, selftest-smart-merge.sh (diff --stat 6664aa8~1..6664aa8: 72 insertions, 19 deletions, 仅 2 文件)

## 修复逐项落点

### P0 · SMB:463 break 2→continue 2
- `case "$norm/" in "$r"/*|"$r") break 2 ;; esac` → `continue 2 ;;`
- 白名单命中只跳过 $HOME guard 自身剩余判断，继续 SKILL_ROOT/WT_PATH/MAIN_REPO 的 full 三向检查
- 实测：改后合法白名单位仍 IDENTICAL 放行；部署根内主仓场景 rc=6 REJECTED 且 .git 完好

### P3 · SIGKILL 措辞 ×4 处（SMB:51,71,372-373,492-493）
- 全部改为「正常退出/TERM/INT 由 EXIT trap 兜底恢复；SIGKILL 不可捕获，残留 slot.bak.$$ 需人工 mv 回」

### P3 · SMB:123 usage 补 --allow-home-slot
- usage 首行改 `Usage: smart-merge-back.sh <worktree-path> [--base master] [--deploy] [--force] [--allow-home-slot]`
- 补一行：`--allow-home-slot  $HOME 内部任意 slot 放行(默认关, 风险自担)`

### P3 · ST SKIP 口径统一（ST:331-333/347-351）
- 统计段注释改：口径 = 断言行总数 = PASS+FAIL，SKIP 单列不计入 Total
- `PASS_TOTAL=$((PASS + FAIL))`（原含 SKIPPED）；FRAMEWORK_BROKEN 自检同步
- SM-10 未注入时记 SKIP 行（不计 PASS/FAIL）

### P2 · 新增 SM-12/SM-13 + TOTAL_CASES 12→14
- SM-12：`env HOME="$T12/home" TASK_PLANNER_DEPLOY_SLOTS="$T12/home/.zcode"` → 期望 rc=6 且 $T12/home/.zcode 目录清单 md5 前后一致（$HOME 内部白名单外 REJECTED 回归）
- SM-13：夹具主仓 = 部署根内（预置 $T13/main/deployroot/task-planner），slot=$T13/main/deployroot/task-planner → 期望 rc=6（MAIN_REPO full 守卫命中）且主仓 .git 目录存活 + marker 文件 md5 不变
- 两用例全部 /tmp 夹具（mktemp -d），禁止真实路径
- TOTAL_CASES=14，PASS_TOTAL=$((PASS + FAIL))（SKIP 单列）

## 验收证据
1. `bash -n` 两文件过（SMB-SYNTAX-OK / ST-SYNTAX-OK）
2. selftest 连跑三遍一致：`Total: 14 PASS=14 FAIL=0` EXIT=0（差异仅 tmp 路径与 commit sha 尾注，非结果差异）
3. P0 实证（/tmp/p0evidence3 夹具）：
   - 场景 A：slot=$E/main（= MAIN_REPO）→ rc=6 REJECTED，主仓 .git alive，marker md5 不变
   - 场景 B：slot=$E/legit-slot（主仓外部预置 skill 内容）→ rc=0 IDENTICAL 放行
4. `git diff --stat 6664aa8~1..6664aa8` 仅 2 文件（smart-merge-back.sh +22/-, selftest-smart-merge.sh +69/-）
5. 未触碰 Scope 外文件（worktree-isolation.md、SKILL.md、README.md 均未改动）

## 遗留/风险
- 无
