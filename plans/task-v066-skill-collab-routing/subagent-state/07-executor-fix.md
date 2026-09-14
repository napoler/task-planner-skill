# [sub:07-executor] T5 微修产出 checkpoint

- seq: 07, agent_type: executor
- worktree: /home/terry/task-planner-skill-worktrees/task-v066-skill-collab-routing
- working file: skills/task-planner/scripts/selftest-skill-collab.sh (仅 1 文件, +14/-2)
- 状态: T5 complete

## 8 字段返回块（最终结论）

status: done
acceptance: 19/19 pass
  - ① 本机 bash 跑: T1a-T10 全 PASS (python3 路径), exit 0
  - ② bash -n: SYNTAX-OK
  - ③ no-python3 模拟 (PATH=/tmp/nopy3bin2 无 python3): T7 走 grep-fallback PASS, 19/19 exit 0
  - ④ git diff --numstat: 仅 1 文件 +14/-2
files: /home/terry/task-planner-skill-worktrees/task-v066-skill-collab-routing/skills/task-planner/scripts/selftest-skill-collab.sh +14/-2
evidence:
  - file:55 (头部注释 "10 组用例 T1-T10，共 19 断言" 已写入)
  - file:56-70 (T7 双路径: python3 探测 + grep-fallback)
  - 命令 `bash scripts/selftest-skill-collab.sh` → "Total: 19  PASS=19  FAIL=0" exit 0
  - 命令 `env PATH=/tmp/nopy3bin2 bash scripts/selftest-skill-collab.sh` → "[PASS] T7 config skill_collab_enforce=warn (grep-fallback)" 19/19 exit 0
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v066-skill-collab-routing/subagent-state/07-executor-fix.md + T5 complete
findings_written: `#### [sub:07-executor] 微修产出`
blockers: none
confidence: HIGH

## 踩坑记录（T7 grep-fallback）

- 第一版：键块文本 `c=$(sed ...)` 跨 shell 边界 + 嵌套 `bash -c` 双引号 → `\"` 在外层被剥单引号语义，内层 grep pattern 缺引号 → grep 失败 → FAIL
- 第二版：改用外层双引号 + 内层 `'\''` 单引号转义 → 仍失败（转义组合未真正消除跨边界引号剥离）
- 最终版：`$CONFIG` 在脚本层展开为字面路径（单引号安全），sed/grep 均在 t() 派生的 bash -c 内执行，键块文本不跨 shell 边界；断言用 test 式 `[ $(grep -c ...) -ge 1 ]` 而非裸 grep -c 串联（grep -c 在 0 命中时退出码 1，"命中"≠"成功"）
- 验证: no-python3 模拟 19/19 PASS exit 0
