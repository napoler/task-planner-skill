# S1 派发指令：init-session.sh claimant 守卫修复（G1 直写+fallback 门控+G3 锚定）

## 执行区（只改 worktree 内文件）
- 文件：/mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120/skills/task-planner/scripts/init-session.sh
- 禁碰 worktree 外任何文件；禁碰同目录其他脚本

## 背景与根因（自包含）
用户投诉：每次新任务 init 或 D 类意图切换报「指针仍被旧计划声明，需 --force」，2-3 次交互才切换成功。根因=init-session.sh 同 sid 在途 claimant（旧计划 .session-owner 匹配且其 task_plan.md 含 in_progress）时置 SKIP_SIDE_WRITE=1 静默失切；且 in_progress 判定用 `grep -qi 'Status.*in_progress'` 扫全文（:1236 附近），注释/散文/模板示例字样误命中扩大拦截面。

## 修改要求（先 Read init-session.sh:1140-1260 再动手）
1. **fallback 门控标记**：在 :1205-1207 freshness fallback 抢用他会话哨兵 sid 的分支置变量 `_sid_fallback=1`（该路径=他会话身份，历史上发生过 init 误写他会话指针空间的 D3 事故，必须保留拦截）。
2. **claimant 守卫重构**（:1229-1256 段）：
   - `_sid_fallback=1` 时：保留原 skip+WARN 行为，文案改为提示「会话 id 未确定（freshness fallback），skip 写入防覆盖他会话 side 键」
   - 身份确定（非 fallback，即 SIDKEY 来自 CLAUDE_CODE_SESSION_ID env 或 .sidmap）时：不再置 SKIP_SIDE_WRITE=1，改为输出通告行后**直接继续写 side 指针**。通告文案模板（三行内）：
     `[init] NOTICE: 检测到同会话在途计划 <claimant>——init 于新计划目录执行=明确切换意图，side 指针切换写入。`
     `[init] 旧计划请按意图切换清单挂起登记并释放 .session-owner 占用；plan-resume 可恢复。`
   - 通告输出需含 claimant 名与「挂起」「恢复」或「session-owner」字样（VC-1 断言依赖）
   - claimant 不存在/已 complete 的 fail-open 分支保持不变
3. **in_progress 判定锚定**（:1236 附近裸 grep 处）：改为
   `grep -Eq '^[[:space:]]*[-*][[:space:]]*(\*\*)?Status:(\*\*)?[[:space:]]*in_progress' "$PLAN_ROOT/$_claimant/task_plan.md"`
   （兼容 `- **Status:** in_progress` 加粗与 `- Status: in_progress` 非加粗两种真实形态；不匹配散文/注释行）
4. **注释规范**（Rule 45 What+Why 双层）：修改处注明 2026-11-20 task-pointer-switch-defect-20261120、现象（用户投诉反复 --force）、根因、修法；**禁止在代码行尾注释中复述旧 grep 调用字面**（会触发 VC-3 静态反向断言假红）；旧实现的说明放整行注释（行首 #）。
5. 修改最小化：只动上述三处逻辑相关行，其余逻辑（sidmap/sidkey 计算、哨兵、7 文件创建、全局指针分支）不动。

## 自验（完成后在 /tmp 夹具跑）
- 伪造 plans/old-claimant（task_plan 含 `- **Status:** in_progress` + .session-owner=sess<sid>）+ plans/new-task，export CLAUDE_CODE_SESSION_ID=<sid>，cd new-task 跑本脚本 → side 键= new-task 且 stdout/stderr 含通告行与 old-claimant 字样、无「skip 写入」
- 非加粗 `- Status: in_progress` 的 claimant 同样命中通告（不漏判）
- claimant task_plan 仅含注释 `<!-- Status: in_progress -->` 与散文行 `- Update phase status as you progress: pending → in_progress → complete` + 状态行 complete → 不拦（fail-open 写入）

## acceptance
- 上述三夹具行为全部符合；git -C worktree diff 仅本文件；bash -n 语法过
