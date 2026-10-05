# 12-executor 检查点 — task-v118 fix-phase selftest CR 发现修复

status: done
worktree: /home/terry/task-planner-skill-worktrees/task-v118 (branch wt/task-v118)

## 修复项落盘证据

### 修复项 1【SUGGESTION】RT-08 加白粒度 → 逐匹配
文件: skills/task-planner-skill-worktrees/task-v118/skills/task-planner/scripts/selftest-ask-default-timeout.sh
新管道（a/b 两处同改，L66-67 附近，注释注明 [task-v118 fix-phase CR finding 3]）:
```
a="$(printf '%s\n' "$S44" | grep -oE '1-4[0-9]' | grep -vE '^1-4[56]$' | wc -l)"
b="$(grep -oE '1-4[0-9]' "$SKILLMD" | grep -vE '^1-4[56]$' | wc -l)"
```
- grep -oE 每匹配独立成行；`grep -vE '^1-4[56]$'` 仅剔恰好等于 1-45/1-46 的匹配，
  同行 `1-46 1-47` 共现时 1-47 不再被 1-46 带着加白。
- 去掉旧管道尾部 `|| true`（管道末端 wc -l 恒成功，grep 中间无匹配 exit 1 不影响管道结果）。

### 修复项 2【NIT】头注释行号锚漂移 → 字面锚
文件: skills/task-planner-skill-worktrees/task-v118/skills/task-planner/scripts/selftest-dispatch-grain.sh
- 删除全部行号引用（原 L14-15 的「L474-483 / L48-53 / L304-327 / L264-277 / L85 / L17、L67」）。
- 改字面锚描述：②实现=「任务书检出」分支；④=count_step_markers tb 模式调用；
  提取器=extract_subagent_state_refs 共用函数；SKILL.md 委派检查点 2.5；
  templates/subagent_dispatch.md Rule 46.1 引导行。

### 修复项 3【NIT】GR-07 补全角形态正例 → 新增 GR-10
文件: 同上 selftest-dispatch-grain.sh
- 新增 GR-10：引用写法 `执行（任务书：<TB 路径>）`（全角括号+全角冒号，CR BLOCKER 盲区形态），
  任务书 taskbook-gr10.md 含 S3/S4 两个不同 S-id → 断言 enforce exit 2 且 stderr 含「任务书检出」。
- 头注释断言清单同步加 GR-10 行；Total 由 9 → 10（仅 Total/断言清单编号调整，GR-01..09 判定零改动）。

## 验证结果（全在修复后守卫 check-dispatch.sh F1 之上跑）

1. selftest-dispatch-grain.sh: `Total: 10 PASS=10 FAIL=0` RC=0（GR-10 全角形态 exit 2 + 任务书检出 PASS）
2. selftest-ask-default-timeout.sh: `Total: 9 PASS=9 FAIL=0` RC=0（RT-08 逐匹配粒度后 CRIT 44 节=0 / SKILL.md=0）
3. RT-08 负向自检（/tmp 最小文件单测 grep 管道，测毕 rm 无残留）:
   - 同行 `1-46 1-47`: 旧整行粒度=0（漏报）vs 新逐匹配粒度=1（拦截）✅
   - 纯合法 `1-46` 单行: 新粒度=0（不误伤）✅
4. selftest-registry.sh: `Total: 5 PASS=5 FAIL=0 (registry rows=43, actual selftest=43)` RC=0

## files_touched（仅 2 个 selftest，禁改约束遵守）
- skills/task-planner/scripts/selftest-ask-default-timeout.sh（7 行 diff）
- skills/task-planner/scripts/selftest-dispatch-grain.sh（24 行 diff）
- check-dispatch.sh 未再改（worktree 中其 M 状态为前置 F1 修复，非本次动刀）
- SKILL.md 未动

## notes
- 无负结果：未排除任何风险——旧粒度漏报已由负向自检直接实证（旧=0 新=1）。
- 未提交 git（按约定待合并回收前保持 worktree 内工作树 M 状态，由主进程合并回收）。
