# executor-fix checkpoint — task-v055-fix-composite

## 时间
2026-09-07

## 任务背景
task-planner 技能新脚本 check-delegation.sh 的 stats 模式首次实战暴露解析缺陷：
复合 Executor（如「architect + critic（方案挑刺）」）被当成单一类型字符串去 Handoff 表
匹配，导致 unverified_delegation 误报。

## 工作目录（P0）
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v055-fix-composite
- 分支: wt/task-v055-fix-composite
- 基于 master 847f500
- 禁止触碰: 主仓 plans/task-v055-scheduler-enforce/tmp/ 与 subagent-state/ 除外、
  其他 worktree、~/.zcode/**、~/.claude/**

## 缺陷定位（已确认，直接修）
- 文件: skills/task-planner/scripts/check-delegation.sh
- 两处 Handoff 交叉校验点:
  1. line ~329 — ### Phase 头 flush (处理上一个 Phase)
  2. line ~399 — ## 顶层章节 flush (Plan 末尾 ## 段截断)
- 现状: type_hint 提取后整体 grep 匹配 Handoff 表
- 「architect + critic」→「architect+critic」→ 匹配失败 → 误报 unverified

## 修复要点

### check-delegation.sh 改动
1. line 322 注释修正: 原"去中文括号"与代码"去冒号前缀"不符 → 改"去冒号前缀"
2. 两处 Handoff 校验点改写:
   - type_hint 按 NUL 分隔拆 token (printf '%s\0' + tr '+' '\0' + read -d '')
   - 每个 token trim 空白 + 去括号 + 去空白 → 逐个 grep Handoff 表
   - 全部找到 → 计 1 个 delegated; 任一缺失 → unverified_delegation
   - reason 改为 "Executor 含未登记子代理类型:<missing_tokens>"
3. 两处都加注释标记: [2026-09-07 task-v055-fix] 复合Executor按+拆分逐个校验

### 实施过程中发现的 NUL vs 换行 bug
- 原计划用 `tr '+' '\n'` + `read -r`,但 tr 末尾不补换行时,
  bash read 把整段（含内嵌 \n）当一行读 → 单 token 处理 → bug
- 改用 NUL 分隔 + `read -d ''` 正确拆分每个 token
- 顺手在注释里记录该陷阱,避免重犯

### selftest-delegation.sh 改动
- T15 + T15b: 复合 Executor「architect + critic」全登记 → 不误报 + 仍计 delegated
- T16 + T16b: 复合 Executor「architect + nonexistent」部分缺失 → unverified + reason 含 nonexistent
- 注释行同步: T15/T16 描述行
- 共 4 行新增 PASS (T15, T15b, T16, T16b)

## 自测结果
```
========================================
selftest-delegation results
========================================
PASS  T01 无计划放行  (exit=0)
PASS  T02 子代理 sid 放行  (exit=0)
PASS  T03 plans 白名单放行  (exit=0)
PASS  T04 SKILL_ROOT 放行  (exit=0)
PASS  T05 trivial 3 行放行  (exit=0)
PASS  T06 4 行拦截  (exit=2)
PASS  T07 enforce exit2  (exit=2)
PASS  T08 warn 不阻断  (exit=0)
PASS  T08 warn 注入  (grep hit)
PASS  T09 .allow-direct 放行  (exit=0)
PASS  T09b ledger 写入 bypass
PASS  T10 过期 allow-direct 拦截  (exit=2)
PASS  T11a 首次 on 成功  (exit=0)
PASS  T11b 二次 on 拒绝  (exit=3)
PASS  T12 stats 占位/理由检测  (grep hit)
PASS  T12 stats 退出码非 0(violation)  (exit=1)
PASS  T13 Handoff 交叉校验  (grep hit)
PASS  T14 jq 失败 fail-open  (exit=0)
PASS  T15 复合Executor全在Handoff不误报
PASS  T15b 复合Executor仍计delegated
PASS  T16 复合Executor部分缺失触发unverified
PASS  T16b reason字段含缺失token
----------------------------------------
Total: 22    PASS=22  FAIL=0
========================================
```

## Commit
- hash: 956c2697896bd9dfbd1c37cd25f06b7f3dee314b
- message: fix(task-planner): task-v055 — stats复合Executor按+拆分校验(修unverified误报)+自测+2断言
- diff stat: 2 files changed, 146 insertions(+), 8 deletions(-)
  - skills/task-planner/scripts/check-delegation.sh: 72 +++++++++++++++---
  - skills/task-planner/scripts/selftest-delegation.sh: 82 ++++++++++++++++++++++

## 完成动作
- [x] git add 仅 2 文件,commit 已建 (956c269)
- [x] 自测输出已追加 plans/task-v055-scheduler-enforce/tmp/enforce-demo.txt (标注 fix-composite 段)
- [x] checkpoint 落盘: plans/task-v055-scheduler-enforce/subagent-state/08-executor-fix.md (本文件)

## 备注
- 主仓未做合并 (按 worktree 隔离 SOP,合并由调度方决定)
- 没动主仓 plans/task-v055-scheduler-enforce/tmp/ 和 subagent-state/ 之外的任何文件
- 没动 ~/.zcode/** 或 ~/.claude/**