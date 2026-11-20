# Checkpoint: S1 — init-session.sh claimant 守卫修复（G1 直写 + fallback 门控 + G3 锚定）

- task_id: task-pointer-switch-defect-20261120 / Phase 1 S1
- status: done
- 时间: 2026-11-20
- 执行区: `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120/skills/task-planner/scripts/init-session.sh`（分支 `wt/task-pointer-switch-defect-20261120`，基线 f4dc96b）

## 改动点（最终行号锚）
1. `:1176-1182` — 新增 fallback 身份状态标志 `_sid_fallback=0`（What+Why 注释：现象=反复 --force，根因=身份未定时直写覆写他会话 side 键，修法=门控）；`_sidmap_checked=0` 为既有初始化，编辑中曾误删、F4 夹具捕获后恢复（`:1182` 行尾注明勿删）。
2. `:1213-1217` — freshness fallback 抢用他会话哨兵 sid 成功分支置 `_sid_fallback=1`，注释说明该 sid 属他会话命名空间（D3 路径），守卫须保留 skip。
3. `:1244-1265` — claimant 守卫重构：判定由不锚定全文匹配改为状态控制行锚定 `^[[:space:]]*[-*][[:space:]]*(\*\*)?Status:(\*\*)?[[:space:]]*in_progress`（`:1255`，兼容加粗/非加粗）；`_sid_fallback=1` 走 skip+WARN（文案「会话 id 未确定（freshness fallback）…skip 写入防覆盖他会话 side 键」，`:1258`）；身份确定走两行 NOTICE（含 claimant 名、挂起/释放 .session-owner、plan-resume 恢复，`:1262-1263`）后直接写 side 指针，不再置 `SKIP_SIDE_WRITE=1`；fail-open 分支原样保留。全部注释行首 `#` 且带 2026-11-20/task-id/现象/根因/修法，无行尾复述旧 grep 字面。

## 自验证据（/tmp mktemp 隔离夹具，四处场景 + 静态 + 语法）
- F1 加粗 `- **Status:** in_progress` 在途 claimant → side=`new-task`，stdout 含 `NOTICE` + `old-claimant` + 挂起/session-owner/恢复，无 `skip 写入`。PASS（5 断言）
- F2 非加粗 `- Status: in_progress` → 同样命中 NOTICE + side=`new-task`，未漏判落 fail-open。PASS（2 断言）
- F3 仅注释 `<!-- Status: in_progress -->` + 散文 `…pending → in_progress → complete` + `- **Status:** complete` → 不误拦，走 fail-open 写入 side=`new-task`，无 NOTICE。PASS（3 断言）
- F4（额外，G1 门控）伪造新鲜哨兵触发 fallback 抢用 → WARN 含「会话 id 未确定（freshness fallback）」+「skip 写入」，借用的 sid 未写 side；无 integer-expression 报错。PASS（4 断言）
- VC-3 静态反向（`grep -v "^[[:space:]]*#"` 剥注释后查裸 `grep -qi 'Status.*in_progress'`）→ clean。PASS
- `bash -n init-session.sh` → OK。锚定 grep 落 `:1255`。PASS
- 合计 16/16 断言通过，fail=0。

## diff 与范围
- `git status --porcelain --untracked-files=all` → 仅 ` M skills/task-planner/scripts/init-session.sh`
- `git diff --numstat` → `30	4	skills/task-planner/scripts/init-session.sh`（1 file changed）
- 无新增脚本/文件，无 worktree 外改动，无同目录其他脚本改动。

## 自检与回归记录
- 首轮自验发现 `line 1194: [: : integer expression expected`，根因=编辑 A 误删既有 `_sidmap_checked=0` 初始化（old_string 包含了该行但 new_string 漏写），导致 fallback 分支永不进入、F4 失败；已恢复该行并重跑，F4 与 integer-expr 报错均消失。此为本次执行中自查捕获并修复的回归，非既有缺陷。
- VC-1 完整命令含 `set-active-plan.sh set` 输出「指针未切换」断言，属 S2 范围（未修复、pending），本 checkpoint 不声称该部分通过；init 侧全部判据已过。

## 遗留风险
1. S2 未修 `set-active-plan.sh` 的 claimant 判定与 skip 文案前，VC-1/VC-2/VC-3 全量命令中的 set 部分仍红，属计划内后续单元。
2. 通告文案/正则细节为可变量（task_plan 不变量区允许语义等价实现），Phase 3 selftest（S4）扩展时应复用 F1-F4 夹具判据。
3. 部署位 `~/.zcode` 同步与合并回属 S5，未在本单元处理。

## handoff
checkpoint 已写 = yes。本文件为本单元最终回传物；主进程复核请对照上述行号锚与 diff numstat。
