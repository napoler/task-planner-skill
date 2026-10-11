# selftest 锁步材料（executor，2026-10-10）

## 任务（1 文件）
`selftest-pointer-lifecycle.sh` 的 PL-07 断言钉在旧措辞上，随 SKILL.md 改述后失效（FAIL），锁步同步到新措辞。**PL-06 不动**（check-complete 保留了「移交提醒」label 作废弃警示锚，实测 PASS）。

## 目标区段（以实施日实测为准）
- 文件：/mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local/skills/task-planner/scripts/selftest-pointer-lifecycle.sh
- PL-07 当前（约 :43-46）：
```
# PL-07: SKILL.md 含移交纪律行（指针移交 25 完成项）
[ "$(cnt '指针移交' "$SKILL")" -ge 1 ] && ok "PL-07 SKILL.md 含移交纪律行（指针移交锚在位）" || bad "PL-07" "SKILL.md 移交纪律行缺失"
```
- 改后（锚=新措辞「指针清理」）：
```
# PL-07: SKILL.md 含指针清理纪律行（指针清理 25 完成项）[2026-10-10 task-v164 锁步：原锚'指针移交'随 S5 改述退役，语义不变]
[ "$(cnt '指针清理' "$SKILL")" -ge 1 ] && ok "PL-07 SKILL.md 含指针清理纪律行（锚在位）" || bad "PL-07" "SKILL.md 指针清理纪律行缺失"
```

## 前置核对（必做）
- 先 `grep -n '指针移交\|移交' selftest-pointer-lifecycle.sh` 列全部命中，逐个判定：仅 PL-07 相关行需改（若 PL-06 块或其他注释含'移交提醒'等且与 check-complete 现措辞匹配则不动）
- `grep -n '移交提醒' check-complete.sh` 确认 PL-06 锚仍命中（label 保留）

## 保留纪律（Rule 45 — 必守）
- 除 PL-07 两行（注释+断言行）外禁改任何断言/逻辑；测试计数（Total）不得变
- 注释行注明改述原因/时间/原锚

## 验收（主进程将复跑）
- `bash selftest-pointer-lifecycle.sh` → `Total: 10 PASS=10 FAIL=0` rc=0
- `git diff` 仅 PL-07 注释行+断言行（+消息文案）；`bash -n` 过
- `grep -n '指针清理' selftest-pointer-lifecycle.sh SKILL.md` 双边命中

## 边界
- 只改该 selftest PL-07 两行；禁动其他文件；禁 git 写操作
