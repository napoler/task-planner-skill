# S3 簿记失真对照（2026-10-15）

> 子代理 S3（重派）｜只读调查｜唯一写入=本检查点文件
> 仓库 /mnt/data/dev/task-planner-skill，分支 master，HEAD=4287b7a

## 对照表（INDEX vs git 真实状态）

前提澄清：派发 prompt 称「INDEX.md 待处理区列了 8 个未完成任务」。该前提在 commit 8999c82（2026-10-14 12:00）时点成立——当时 INDEX 确实以 in_progress=7/pending=1 列出这 8 项。但 commit 4287b7a（2026-10-15 09:50:55）已将这 8 项全部 git mv 入 plans/archive/ 并刷新 INDEX。当前 INDEX（Last refreshed: 2026-10-15_09:43）只列 task-v176。故「INDEX 状态」列标注两个时点。

| 任务 | INDEX 状态 | task_plan 声明 | git 证据（commit hash+日期） | 真实状态 | 失真类型 |
|------|-----------|---------------|------------------------------|---------|---------|
| task-v133 | in_progress(8999c82) → 现不在 INDEX | complete（archive/task-v133/task_plan.md:116/129/141/153） | 4e734b2 2026-10-05 Merge branch 'wt/task-v133' | 已完成+已归档 | INDEX 快照过期 10 天 |
| task-v135 | in_progress(8999c82) → 现不在 INDEX | complete（archive/task-v135/task_plan.md:114/122/132/139/147） | b03fd36 2026-10-05 Merge branch 'wt/task-v135b' | 已完成+已归档 | INDEX 快照过期 10 天 |
| task-v142 | in_progress(8999c82) → 现不在 INDEX | complete（archive/task-v142/task_plan.md:103/110/117/124/132） | a7c01a8 2026-10-08 feat(task-v142): Rule 58 主动解决问题泛化行为原则 | 已完成+已归档 | INDEX 快照过期 7 天 |
| task-v143 | in_progress(8999c82) → 现不在 INDEX | complete（archive/task-v143/task_plan.md:128/137/144/154/165） | 96c474c 2026-10-08 merge: task-v143 Rule 58 合入 master | 已完成+已归档 | INDEX 快照过期 7 天 |
| task-v144 | in_progress(8999c82) → 现不在 INDEX | complete（archive/task-v144/task_plan.md:204/228/240） | c997fa7 2026-10-08 merge: task-v144 Rule 59 合入 master | 已完成+已归档 | INDEX 快照过期 7 天 |
| task-v146-drift-check-subagent | pending(8999c82) → 现不在 INDEX | complete（archive/task-v146-drift-check-subagent/task_plan.md:103/109/118/128/139） | e54973d 2026-10-08 Merge branch 'wt/task-v146' | 已完成+已归档 | INDEX 快照过期 7 天 |
| task-v165-agent-template-deploy | in_progress(8999c82) → 现不在 INDEX | complete（archive/task-v165-agent-template-deploy/task_plan.md:262/280/292） | af321a3 2026-10-11 docs(plans): task-v165 INDEX 登记 complete 3/3 | 已完成+已归档 | INDEX 快照过期 4 天 |
| task-v172-skill-efficiency-opt | in_progress(8999c82) → 现不在 INDEX | complete（archive/task-v172-skill-efficiency-opt/task_plan.md:294/308/323） | 0817eef 2026-10-14 merge: task-v172 CA-5/CA-6 入 master | 已完成+已归档 | INDEX 快照过期 1 天 |

补充：8 项均由 commit 4287b7a（2026-10-15 09:50:55）「归档 9 个已完成计划」一次性 git mv 入 archive/（第 9 个=task-v174）。归档前 INDEX 由 sync-todos.sh --index 于 09:43 刷新，8 行 in_progress/pending 同时消失（见 `git show 4287b7a -- plans/INDEX.md` diff）。

## 形态量化

- 未提交变更：**1**（`?? plans/task-v176/subagent-state/`，即本 S3 检查点目录自身；plans/ archive 移动 R 状态 = **0**，归档已在 4287b7a 干净提交）
- 遗留 wt/ 分支：**wt/task-v168-machine-parked**（`git branch | grep wt/` 唯一命中；`git branch --merged master | grep wt/` = 空，未合并；commit cdf437e 明确「机器面封存 wt/task-v168-machine-parked 不合入」，3a68579「未合并主仓、未部署」——有意封存非泄漏，但无到期/清扫机制）
- 根目录任务目录：**1**（task-v176）vs archive/：**141**
- 编号账本（plans/.rule-reservations.jsonl）：`grep -c '"landed"'` = **34**，`grep -c '"reserved"'` = **32**
  - 不对称分析（python 集合比对）：landed 无 reserved = {46,47,48,49,50,75}（6 条旁路；其中 rule 75 由 task-v163 于 2026-10-10 landed 但无 reserved 行，为真旁路；46-50 系账本建立时点前 back-fill）
  - reserved 无 landed = {57,60,80,82}（4 条悬空预留；如 rule 57 reserved by task-v142 2026-10-07，但 v142 实际 landed 的是 rule 58，预留从未关闭）

## 结构性缺陷（5 条，每条带证据+失真机制）

### 缺陷 1：INDEX 状态翻转无强制钩子，完成→归档→INDEX 刷新全链靠代理纪律
- 证据 A：8 个任务从 merge 到 master（最早 2026-10-05）到被归档（2026-10-15 09:50, 4287b7a）滞后 **1–10 天**；期间 INDEX 一直标 in_progress，恢复入口指向已完成的任务。
- 证据 B：`skills/task-planner/config.json` 的 `hooks` 字段为空 `{}`（python 解析输出 `hooks keys: []`），无任何 hook 在 merge/完成时触发 sync-todos.sh --index 或 archive-plan.sh。
- 证据 C：`auto-finalize.sh` 存在且会调 `sync-todos.sh --index`（auto-finalize.sh:29-34），但 `grep -rn "auto-finalize" skills/task-planner/ --include=*.sh --include=*.json --include=*.cjs --include=*.ts | grep -v selftest` 返回空——收尾引擎是手动脚本，无自动触发。
- 失真机制：完成事件（git merge）与簿记事件（INDEX 刷新+归档）之间无机器耦合，窗口期 INDEX 必然失真；窗口长度取决于代理何时「记得」跑收尾。

### 缺陷 2：归档无自动触发，Rule 81「完成即归档」靠手动 git mv 批量执行
- 证据 A：8999c82（2026-10-14 12:00）手动「归档 8 个已完成/废弃计划」，4287b7a（2026-10-15 09:50）手动「归档 9 个已完成计划」——两次都是 agent 手动跑 archive-plan.sh + git mv + commit，非完成事件的直接后果。
- 证据 B：`selftest-archive-plan.sh` 测试的是 archive-plan.sh 的判定逻辑（何时该归档），但没有任何机制在任务 complete 时自动调用它；判定与触发分离。
- 失真机制：归档是「记得才做」的批处理，根目录在途数与 archive 数的平衡完全依赖代理自觉；Rule 81 的「完成即归档」实际是「完成+代理记得才归档」。

### 缺陷 3：编号账本无 reserve→land 配对机器门，双向失真
- 证据 A：`grep -c '"landed"'` = 34，`grep -c '"reserved"'` = 32；python 集合分析：landed 无 reserved = {46,47,48,49,50,75}（6 条旁路，rule 75 为真旁路），reserved 无 landed = {57,60,80,82}（4 条悬空预留）。
- 证据 B：selftest 脚本清单（`ls skills/task-planner/scripts/selftest-*.sh`）中无任何 reservation 配对校验脚本；账本不变量（reserve→land 或 reserve→release 必须闭合）无机器门。
- 失真机制：预留生命周期无强制闭合——任务改号/放弃时预留永久悬空（57/60/80/82），landed 可绕过 reserved 直接登记（75）；账本双向失真且随时间累积。

### 缺陷 4：wt/ 隔离分支无到期清扫机制，封存分支永久遗留
- 证据 A：`git branch | grep wt/` = `wt/task-v168-machine-parked`；`git branch --merged master | grep wt/` = 空（未合并）。
- 证据 B：commit cdf437e 明确「机器面封存 wt/task-v168-machine-parked 不合入」，3a68579「未合并主仓、未部署」——有意封存，但无到期/复核/删除机制。
- 失真机制：§十一 worktree 隔离要求合并后清理分支，但「有意封存」分支无到期清扫，`git branch` 长期携带 wt/ 遗留，与自身规则「遗留 wt/* 分支=下次冲突信号」矛盾；封存决策无复核入口。

### 缺陷 5：selftest-sync-index 只测生成器行为，不测真实仓 INDEX 与 git 一致性
- 证据 A：`selftest-sync-index.sh` 头部注释明确「hermetic: 夹具全在 mktemp -d, 跑完 trap rm -rf; 不触真实 plans/」——T01-T13 全在夹具上验证 sync-todos.sh 的输出格式，从不读取真实 plans/INDEX.md 与 git log 做交叉比对。
- 证据 B：即使真实 INDEX 已失真（8 个 in_progress 任务实际已 merge 但未归档），selftest-sync-index 仍全 PASS——机器门测的是「生成器没坏」，不是「账本没失真」。
- 失真机制：簿记体系的自测覆盖「格式正确性」而非「事实一致性」，失真（INDEX 状态 vs git 真实状态）无任何机器检测面。

## 自验
- `wc -l` = 61 行（非空，2026-10-15 S3 自验）
