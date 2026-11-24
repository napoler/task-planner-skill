# 立项：task-planner「弃旧开新」（restart-from-baseline）机制固化

## Context（为什么做）

用户延续 git-rework-guard 思路提出：长链任务改到一定时限、确认方向根本错误后，与其在错误上下文里挣扎，不如**主动放弃错误路线**——从当前混乱状态提取有效数据、用 Git 从干净基线牵出新版本、创建新计划从头做，抛弃错误历史负担。事实证明重开往往比继续挣扎更有效。

勘察结论：现有 `worktree-isolation.md §4.5` 已有"方向彻底错→丢弃分支从头来"**半条出口**，但缺完整机制（触发阈值/有效数据提取/旧计划终态/新分支新计划命名/从基线牵新版本命令序列）。这是制度层诉求（Rule 31.8），交付物=规则文本+模板锚，非脚本/hook。定位为 **git-rework-guard 的补充出口**（§4.6），不是独立新机制——二者共用同一 git/worktree/commit 基座，是同一决策链的"能找回→找回已无意义时止损重开"升级分支。

**未答澄清项按推荐自决**（批准时可否决）：①触发=量化阈值命中→出评估报告→用户显式 yes 才执行（不可逆方向变更守 §五安全底线）；②旧计划 `outcome: RESTARTED`（新状态词，区别 CANCELLED=用户授权不做 vs SUPERSEDED=被外部新目标取代）+链接新计划，错误 wt 分支留档不物理删除，"抛弃负担"体现在新计划从干净基线起不带错误产物。

## 实施约束（P0）

- **worktree 隔离**：改保护区技能，在 `<repo>/tmp/worktrees/task-restart-baseline-20261122`（分支 `wt/task-restart-baseline-20261122`）实施，验证后合并回 master 并清理。基线用 master（§4①-校验：本仓 main 为陈旧无关历史）。
- **纯文本**：零新增脚本/hook/daemon（用户"不要搞复杂"+Rule 31.8/文本优先铁律）。
- **复用骨架**：Rule 96.7（>40 派发/>60min）、Rule 103.8b（同文件第 3 轮返工 STOP）、Rule 102.1e（取消登记不删条目）、Rule 61 drift-checker、decision-arbiter 归因、D 类意图切换登记载体、Rule 100 worktree 路径。
- mini/L0 档豁免。

## 方案（单 Phase，4 落点 + 派发契约计划）

### 1. `references/worktree-isolation.md` 新增 §4.6「方向性止损与弃旧开新（restart-from-baseline）」— 主落点
- **核心原则**：区分 §4.5「局部返工=Git 找回文件/回退 commit」与 §4.6「方向根本错误=从干净基线牵新分支+新计划从头做」；后者收益=切断错误上下文与错误历史负担（用户核心诉求）。
- **触发门（三级）**：①量化阈值（复用不新造）Rule 96.7 >40 派发或 >60min / Rule 103.8b 同文件第 3 轮返工前 STOP → "疑似方向性错误"；②归因评估 drift-checker 判 🔴BLOCKED 或 decision-arbiter 归因确认为"方向根本错误/整体路线错"（非局部 bug）；③用户确认门——评估报告（已耗预算/已证伪方向/有效数据清单/推荐 restart 范围）经用户显式 yes 才执行。
- **有效数据提取白名单**（用户"提取有效数据"诉求，形成 salvage-manifest 随新计划登记，复用 findings/Decisions 载体不新建文件）：✅可带=findings 结论/证据锚、knowledge-brief 知识锚、已 PASS 的 VC 结果、已 commit 且验证过的产物、user-session-log 中用户确认的决策；❌不带=FAIL 产出、错误路线代码/文件、未验证推测、RAW 调试日志、被 [corrected] 的旧上下文。
- **从基线牵新版本标准序列**：基线优先 master 当前 HEAD 上该任务开始前干净 commit（或 wt 分支早期已验证 good commit）；`git worktree add <project>/tmp/worktrees/<task-id>-rN -b wt/<task-id>-rN <baseline-commit>`（新 worktree 不带错误分支后续提交）；新计划 `plans/<task-id>-rN/` init 全流程，头部登记 `restarted_from=<old-task-id>`+salvage-manifest 指针。
- **旧线冻结登记**：旧计划 `outcome: RESTARTED`+Decisions 登记（触发证据+新计划 ID+salvage-manifest+ISO8601 时间）+progress 追加 `[restart]` 行；旧 wt 分支留档不删、仅从活跃指针移除，后续按正常收口或用户明示清理。
- **反模式**：❌未归因就弃旧（把局部 bug 当方向错）❌无用户确认就丢弃分支+改终态 ❌把 FAIL 产出/错误代码带进新计划（污染新基线）❌物理删除旧证据（失去复盘）❌restart 循环无上限（restart ≥2 次仍方向错→必须升级用户裁决，不开 -r3）。

### 2. `SKILL.md` 步骤 4.5 交叉锚（L145）
现有"方向彻底错→丢弃 wt/<task-id> 分支"后追加一句：方向根本错误且阈值命中→走 §4.6 弃旧开新（评估→确认→提取有效数据→从基线牵新 `wt/<task-id>-rN`→新计划 outcome 登记 RESTARTED 非 CANCELLED）。

### 3. `templates/task_plan.md` Git checkpoint 条目（L347）
末尾追加弃旧开新锚（触发→评估→确认→有效数据→新分支/新计划登记），与 3f'/3f 同拍的周期性回顾配合。

### 4. `templates/progress.md` Git checkpoint 行（L26）
追加 `[restart]` 留痕位（旧任务 ID/新任务 ID/有效数据清单/触发证据/确认原话），复用既有留痕载体形态。

### 5. 派发契约轻量 mini 计划（主仓 plans/）
建 `plans/task-restart-baseline-20261122/`（plan_tier:mini，≤12 行 stub）满足 [dispatch-block] 三文件+8 字段+checkpoint 契约；单独精确 pathspec 提交（不捎带 hook 改写的 task-cli-help-examples）。

## 关键文件
- 主落点：`skills/task-planner/references/worktree-isolation.md`（§4.6 新增于 §4.5 之后、§5 反模式之前）
- 交叉锚：`skills/task-planner/SKILL.md:145`、`templates/task_plan.md:347`、`templates/progress.md:26`
- 复用参照：`task-dispatch/references/critical-rules-dispatch.md:225`(96.7)/`:255`(103.8b)、`task-discipline/references/critical-rules-discipline.md:712`(102.1e)/`:89`(31.8)、`SKILL.md:216-236`(新指令处理/D 类)
- 部署位：`~/.zcode ~/.agents ~/.claude ~/.cursor` 的 skills/task-planner（勘察确认 16/16 identical，实施后文件级 cp 同步）

## 验证（Exit 门，逐条实弹）
1. 全量 selftest fresh：`bash scripts/run-selftests.sh --fresh`，PASS/FAIL 集与基线（当前 master 96 PASS/8 FAIL）逐字一致、零新增 FAIL。
2. init 渲染冒烟：从正确嵌套目录跑 `init-session.sh`，确认 §4.6 锚点/模板新条目进派生 `task_plan.md`+`progress.md`。
3. 四部署位逐位 `diff -q`，全部 identical。
4. VC 逐条实弹（命令+PASS+绝对路径）；worktree `git status` 干净后 `smart-merge-back.sh` 合并回 master、Read 关键文件+`git log` 复验；清理 worktree/分支。
5. 记忆落盘：一事一文件 + MEMORY.md 索引行；Todo 刷新全 completed。

## 范围外（明确不做）
不改 AGENTS.md/宪法本体、不改 dispatch/discipline 卫星仓的 96.7/103.8b 原文（只引用）、不新建脚本/hook/状态机机器门、不物理删除任何旧计划或分支、不执行旧计划。