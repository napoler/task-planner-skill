# 07b-code-assistant checkpoint — task-v064-smart-merge-back / Phase 5 修复轮 2
status: done
commit: 583305c (wt/task-v064-smart-merge-back, worktree /mnt/data/dev/task-planner-skill-worktrees/task-v064-smart-merge-back)
files: skills/task-planner/scripts/smart-merge-back.sh +16/-4, selftest-smart-merge.sh +57/-11 (diff --stat 583305c~1..583305c: 71 insertions, 13 deletions, 仅 2 文件)

## 改动摘要
1. smart-merge-back.sh validate_slot(洞②): 内部方向检查后新增祖先方向守卫
   `case "$gn/" in "$norm"/*) echo "[DEPLOY] REJECTED: $slot (是受保护路径 $g 的祖先 — 危险路径)"; return 1 ;; esac`
2. smart-merge-back.sh GUARDS(洞①): 移除失效的 "/" 条目 → GUARDS="$HOME|$SKILL_ROOT|$WT_PATH|$MAIN_REPO";
   注释说明洞①(gn=/ 时模式退化为 // /* 永不命中)+ 根场景由 norm=/ 显式拒绝 + 双向守卫覆盖
3. 头注释 slot 安全段: 补记 2026-09-12 洞①②修复轮(祖先守卫 + GUARDS 无 "/" 原因)
4. selftest SM-10: 夹具等价构造 — $T10/main 内 worktree 置于 $T10/ancestor/task-test(目录名=task-id
   过 V1 双校验), GUARDS.WT_PATH=$T10/ancestor/task-test, slot=$T10/ancestor → 祖先守卫 REJECTED exit 6;
   断言: REJECTED 行 + 含"的祖先" + slot/真实仓(SELFTEST_SM10_WT 注入时) md5 前后一致(零改动)。
   Total 统计 9→10 断言行。
   坑记录: ① git 2.43 无 `worktree remove -q`(rc 129 静默失败→分支残留), 改 `2>/dev/null || true`;
   ② 第二个 worktree add 需 `-c core.hooksPath=/dev/null`(全局 hooksPath 指向真实工作区 scripts);
   ③ V1 双校验要求 worktree 目录 basename=task-id, 故 shadow 目录名须为 task-test 而非 shadow。
   ④ 真实仓 MASTER_AHEAD(V5): 实证命令须带 --force(本仓分支领先 master 1 commit, 属预期, 非回归)。

## 验收 5/5
- bash -n 两文件 OK
- selftest(带/不带 SELFTEST_SM10_WT 均): Total: 10 PASS=10 FAIL=0 EXIT=0, 连跑 3 遍一致
- 祖先守卫真实实证: TASK_PLANNER_DEPLOY_SLOTS=/mnt/data/dev/task-planner-skill-worktrees bash smart-merge-back.sh $WT --deploy --force
  → rc=6, REJECTED 行: "是受保护路径 <wt>/skills/task-planner/scripts/.. 的祖先 — 危险路径"
  md5 对照: 父目录 ls|md5 before=0fae78dea80073cb18945aa4b968ac9c = after; worktree 清单 before=f9ff97386ade80cc10688c05f5e5a7d5 = after;
  脚本 md5 before=0f870441a3fe578384a544f4c6279a2e = after(零改动)
- git diff 仅 2 文件(见上); 未触碰 Scope 外文件(git status 干净)

## blockers / 残留
- 验收#3 原命令无 --force 时止步于 V5 MASTER_AHEAD rc=5(本仓分支领先 master 的固有限制);
  加 --force 后走完整 deploy 链路实证祖先守卫 rc=6 — 语义等价, 建议主进程记录该口径。
