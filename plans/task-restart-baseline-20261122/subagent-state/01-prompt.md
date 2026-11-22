你是实现子代理（general-coder 角色），在隔离 worktree 内完成纯文本条款固化。**只改下列 4 个文件，不碰任何其他文件（尤其不碰主仓 plans/、不碰其他 worktree）。**

## 派发契约（Rule 22.4a/b/22.8.1）
- 计划三文件绝对路径：
  - /mnt/data/dev/task-planner-skill/plans/task-restart-baseline-20261122/task_plan.md
  - /mnt/data/dev/task-planner-skill/plans/task-restart-baseline-20261122/findings.md
  - /mnt/data/dev/task-planner-skill/plans/task-restart-baseline-20261122/progress.md
- 检查点路径：/mnt/data/dev/task-planner-skill/plans/task-restart-baseline-20261122/subagent-state/impl-checkpoint.md（写自审段）
- 8 字段返回模板（回复必须逐项含这些 key）：status: / files_changed: / summary: / acceptance: / verification: / checkpoint: / risks: / next_hint:
- 需求锚（Rule 51.1a）：R1=方向根本错误时主动放弃错误路线、从干净基线牵新版本+新计划从头做、抛弃错误历史负担；R2=从当前解决中提取有效数据；R3=延续 git-rework-guard 作为其补充出口（§4.6）。

## 工作区（所有写操作用绝对路径，CWD 不迁移）
worktree 根：`/mnt/data/dev/task-planner-skill/tmp/worktrees/task-restart-baseline-20261122`
（独立 git worktree，分支 wt/task-restart-baseline-20261122，基线 master；改这里的 skills/ 文件）

## 任务：固化「弃旧开新（restart-from-baseline）」机制——4 个文件的精确文本改动

### 文件 1（主落点）：`<worktree>/skills/task-planner/references/worktree-isolation.md`
在 §4.5「返工 Git 找回流程」节之后、`## 5. 反模式` 之前，插入新节 `## 4.6 方向性止损与弃旧开新（restart-from-baseline）`（标题行注明 `（restart-from-baseline 2026-11-22，用户诉求）`）。含六个加粗小标题子块，纯 markdown 中文，风格对齐 §4.5（加粗小标题+编号步骤+代码块+❌清单）：

1. **定位与核心原则**：本节是 §4.5 git-rework-guard 的补充出口——§4.5 解决"局部返工能用 Git 找回"，本节解决"方向根本错误、找回已无意义时如何止损重开"。核心原则=主动放弃错误路线，从干净基线牵新版本+新计划从头做，切断错误上下文与错误历史负担（用户真实诉求：继续在错误方向挣扎会把可控项目改得不可控，重开往往更有效）。引用同一 git/worktree/commit 基座（§4③、Rule 27、§4.5）。

2. **触发门（三级，逐级通过才执行，不可逆操作守宪法 §五）**：
   - ①量化阈值信号（复用既有规则，不新造）：Rule 96.7 单一会话/目标 `Agent()` 累计 >40 次或 >60 分钟；Rule 103.8b 同一 canonical 文件进入第 3 轮返工前 STOP。命中任一 = "疑似方向性错误"，进入②。
   - ②归因评估：派 drift-checker（Rule 61/64）判 🔴BLOCKED，或 decision-arbiter 归因分层，确认为"方向根本错误/整体路线错"而非局部 bug（局部 bug 回 §4.5 找回，不触发本节）。
   - ③用户确认门：主进程出评估报告（已耗预算/已证伪方向/有效数据清单/推荐 restart 范围）→ 用户显式 yes 才执行。禁未经确认就丢弃分支或改计划终态。

3. **有效数据提取白名单（salvage-manifest）**：从混乱状态提取有效数据、写入 salvage-manifest 随新计划登记（复用 findings.md/Decisions 载体，不新建文件类型）。✅可带=findings 结论/证据锚、knowledge-brief 知识锚、已 PASS 的 VC 结果、已 commit 且验证过的产物、user-session-log 中用户确认的决策；❌不带=FAIL 产出、错误路线代码/文件、未验证推测、RAW 调试日志、被 [corrected] 的旧上下文。原则：只迁经验证有效数据，禁把错误历史带进新基线。

4. **从基线牵新版本标准命令序列**：基线优先 master 当前 HEAD 上该任务开始前的干净 commit（或 wt 分支早期已验证 good commit，用 `git log --oneline` 定位）；命令 `git worktree add <project-root>/tmp/worktrees/<task-id>-rN -b wt/<task-id>-rN <baseline-commit>`（新 worktree 不带错误分支后续提交，路径遵守 Rule 100 项目内 tmp/）；新计划 `plans/<task-id>-rN/` 走 init 全流程，头部登记 `restarted_from=<old-task-id>` + salvage-manifest 指针。

5. **旧线冻结登记**：旧计划 `outcome: RESTARTED`（新状态词，区别于 CANCELLED=用户授权不做、SUPERSEDED=被外部新目标取代，语义=同目标换路线从头做）+ Decisions 登记（触发证据/新计划 ID/salvage-manifest/ISO8601 时间）+ progress 追加 `[restart]` 行；旧 wt 分支留档不物理删除、仅从活跃指针移除，后续按正常收口或用户明示清理；不抹 git 历史（Rule 102.1e 精神）。

6. **反模式（❌清单）**：未归因就弃旧（局部 bug 当方向错）、无用户确认就丢弃分支+改终态、把 FAIL 产出/错误代码带进新计划（污染新基线）、物理删除旧证据（失去复盘）、restart 循环无上限（restart ≥2 次仍方向错 → 升级用户裁决，不开 -r3）。

### 文件 2：`<worktree>/skills/task-planner/SKILL.md`（约 L145 步骤 4.5）
在步骤 4.5 末尾"细则→`references/worktree-isolation.md` §4.5"处，追加交叉锚（保持该行单行不换行）：`**方向根本错误且阈值命中（96.7/103.8b）→走 §4.6 弃旧开新**：评估归因+用户确认→提取有效数据(salvage-manifest)→从基线牵新 wt/<task-id>-rN→新计划 restarted_from 登记，旧计划 outcome=RESTARTED(非 CANCELLED)（细则→§4.6）`。末尾细则指针改为指向 §4.5+§4.6 两节。只改这一行，不动其他步骤。

### 文件 3：`<worktree>/skills/task-planner/templates/task_plan.md`（约 L347 Git checkpoint 条目）
在该条目行末尾追加：`方向根本错误且阈值命中→弃旧开新(§4.6)：评估归因+用户确认→salvage-manifest 提取有效数据→从基线牵新 wt/<task-id>-rN→新计划 restarted_from 登记，旧计划 outcome=RESTARTED`。保持该行单行。只改这一行。

### 文件 4：`<worktree>/skills/task-planner/templates/progress.md`（约 L26 Git checkpoint 行）
在该行下方新增一行：`- [restart] 弃旧开新(§4.6): [旧task-id → 新task-id(-rN); 有效数据清单(salvage-manifest); 触发证据(96.7/103.8b+归因); 用户确认原话#N; 基线commit]`。只加这一行。

## 硬约束
- 禁止新建/修改任何 .sh/.py/hook/配置文件——纯 markdown 文本条款。
- 禁止全量替换/全局 sed——只用精确 Edit（old_string 唯一匹配）。
- 改前先 Read 目标文件确认锚点原文；改后 Read 回读校验结构（尤其 §4.6 插在 §4.5 与 §5 之间，不得吞掉 §5 标题）。
- 每个文件改动最小：§4.6 新节约 25-35 行，其余 3 文件各 1 行。
- 注释/正文说明 What（新增什么）+ Why（用户诉求/制度理由），不写裸 TODO。

## 验收
- acceptance: §4.6 六子块齐 + 三处交叉锚在位 + 零脚本 + §5 反模式标题未被吞。
- verification: 每个文件改后 Read 回读，给出关键行号与原文片段；确认 4 文件均在 worktree 路径下。
- checkpoint: 自审段写入 subagent-state/impl-checkpoint.md。
- 完成后按 8 字段模板返回。锚点找不到或对文本有疑问先报告不要猜测硬写。
