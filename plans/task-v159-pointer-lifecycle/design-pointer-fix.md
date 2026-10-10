# Design — task-v159 指针与部署生命周期五修复（F1-F5）

> 基线=部署位 ~/.zcode/skills/task-planner（与仓内 master 一致，v153 恢复日 04:5x diff 0 实测）。行号为基线参考，施工日以 worktree 实测为准。所有改点为纯增量或语义修正，禁删既有行为（旧路径保留 fallback）。

## F1 — gc 全局指针生命周期 + check-complete 移交提醒（D1）

**set-active-plan.sh gc 分支（基线 ~125-152）**新增：
```
GLOBAL_PID="$(tr -d ' \r\n\t' < "$ACTIVE_FILE" 2>/dev/null || true)"
if [ -n "$GLOBAL_PID" ]; then
  if [ ! -d "$PLAN_ROOT/$GLOBAL_PID" ]; then action=clear(reason=dead-ref)
  elif 计划 task_plan.md 【锚定真实状态行】判定整体完成==是 && mtime>24h; then action=clear(reason=completed-ttl)
# 整体完成定义（CR2 B1/M1 修正，2026-10-10）：存在锚定 complete 行 `^\s*[-*]\s*\*\*Status:\*\*\s*complete`
# 且无任何锚定活跃行 `^\s*[-*]\s*\*\*Status:\*\*\s*(in_progress|pending)`
# ——禁裸 grep 'Status.*in_progress'：模板固定行「pending → in_progress → complete」会误命中全部模板派生计划（34 个完成态被误判在途）
  fi
  # 清除用原子语义：置空文件（内容空串→slug_is_valid fail→resolve 回退 mtime），不删文件本身（兼容旧调用方 -f 检查）
  # 输出：[active-plan] gc 全局指针 stale(原因)=<pid> → 已置空回退 mtime
fi
```
**check-complete.sh 尾部（最终输出段前）**新增 warn：`cat plans/.active_plan==本任务 id` → `[plan] 移交提醒(Rule 25 完成项): 全局指针仍指向本任务，按 pointer-lifecycle B 提示词移交（置空或指向在途任务）`（warn 恒 exit 0，不阻断）。

## F2 — 哨兵-side 缺口巡检（D2）

**gc 分支**新增（advisory）：遍历 `.plan_required_side/*.plan_required`（mtime<24h=活跃），对每个 sidkey 检查 `.active_plan_side/<sidkey>.active_plan` 缺失→输出 `[active-plan] gc 巡检: 哨兵 <sid> 无 side 指针（该会话解析将回退全局/mtime，建议其跑 set-active-plan set --sid）`。**只报告不代写**（§十一 并行踩踏禁令；代写=侵犯他会话指针空间）。

## F3 — side 写入所有权守卫（D3）

**set-active-plan.sh set 分支（153-161）+ init-session.sh side 写段（~796-802）**同语义新增：
```
# 写 <SID>.active_plan 前：扫 plans/*/.session-owner，找 sess<SID-core> 声明
claimant="$(grep -l "^sess${SID}" plans/*/.session-owner 2>/dev/null | head -1 | xargs -r dirname | xargs -r basename)"
# claimant 存在且 != 本计划（basename PWD）且 claimant 计划 Status=in_progress：
#   → 拒绝 trample：不写该键，WARN「side 键 sid=<SID> 已被在途计划 <claimant> 声明，skip 写入防沿袭互踩；--force 可覆盖」
# claimant complete/不存在：正常写（fail-open 只 WARN 不拦，防误伤）
# init 同语义；init 当前 sidmap 映射逻辑保留（映射值仍可能撞车→由守卫兜底）
```
--force 参数：set 模式新增可选第三位置参数或 `--force` flag（SIDARG 同款提取），显式覆盖。

## F4 — set ROOT fallback 修正（D5）

**line 58/60**：set 模式 `ROOT="${positional[1]:-$PWD}"`（当前 `positional[0]` fallback 在计划目录内运行时把 task-id 当 root）。改后 `set <id>` 在任意 cwd 行为一致。回归：在 plans/task-x/ 内运行 set exit 0。

## F5 — deploy staging 原子化（D4）

**smart-merge-back.sh deploy 段（基线 ~590-640）**重构为三段：
1. **staging**：对 SLOTS 全部先 `cp -rL "$DEPLOY_SRC" <slot>/.stage.$$`（同父目录 staging，跨 slot 无依赖）；
2. **swap**：逐 slot `rm -rf <slot>` → `mv .stage.$$ <slot>`（逐个间隔最小化；或 rename-swap 优先）；
3. **post-verify**：每 slot 存在性 + `diff -r <slot> "$DEPLOY_SRC"` 零差异 → 任一失败 exit 1 且输出缺失/diff 详情，**禁止部分成功当成功**。
EXIT trap 保留；旧直写路径删除前的并行守护：v152/v154/v155 在途共用 deploy——纯换实现不动接口。

## SKILL.md 落点（S3）

计划撰写流程段（Phase 完成/初始化附近）加一行：`计划完成或移交时检查全局指针 plans/.active_plan 归属：不再指向本任务（Rule 25 完成项；gc 会清理 stale，显式移交优先）`；计数级联按合并时 master 实际递推（当前 v152 land 后或为 1-67；SKILL 脚本数钉值+1=66）。

## 新 selftest 断言清单（S5，selftest-pointer-lifecycle.sh）

| # | 断言 | 判据 |
|---|------|------|
| PL-01 | gc 源码含全局生命周期分支（死引用+completed TTL） | grep 'stale\|dead-ref\|completed-ttl' ≥1 |
| PL-02 | gc 源码含哨兵-side 缺口巡检 | grep '巡检'+'.plan_required_side' 各≥1 |
| PL-03 | set 源码含所有权守卫（.session-owner 扫描） | grep 'session-owner' ≥1 |
| PL-04 | set 分支 ROOT 默认 $PWD | grep 'positional\[1\]:-\$PWD' ≥1 |
| PL-05 | deploy 段含 staging 与 post-verify | grep 'stage' + 'diff -r' 各≥1 |
| PL-06 | check-complete 含移交提醒 | grep '移交提醒' ≥1 |
| PL-07 | SKILL.md 含移交纪律行 | grep ≥1 |
| PL-08 | 行为级：隔离 tmp 仓跑 set ROOT 回归（计划目录内 set exit 0） | rc=0 |
| PL-09 | 行为级：stale 夹具跑 gc（临时 PLAN_ROOT）输出清除行 | 输出含 stale |
| PL-10 | 行为级：所有权守卫夹具（假 claimant owner=in_progress）→ skip+WARN | 输出含 claimant 键名 |

## 合并注意

- 若 v152 已 land Rule 67：SKILL 计数 1-67/钉 518 面并集；我的移交纪律行与 C47 相邻不冲突。
- worktree 创建后用 `git log --oneline -3 master` 复核；如与我 base 不一致>3 提交，先 rebase 再施工。
