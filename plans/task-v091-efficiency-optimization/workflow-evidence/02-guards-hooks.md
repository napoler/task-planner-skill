# 02-guards-hooks.md — 守卫脚本与 hook 链开销取证（领域 2）

> 审计员：取证-守卫与hook开销（只读审计，未修改技能本体与仓库任何文件；本文件为唯一写入物）
> 日期：2026-09-27。所有计时为**本机实测**（date +%s%N 墙钟 / strace -f -c），对象 = 部署位 `~/.zcode/skills/task-planner/scripts`（与本体 `skills/task-planner/scripts` 经 `diff -rq` 核对：58/59 脚本 + config.json 完全一致；仅 sync-todos.sh 部署位多 3 行热修复，见 §7.4）。
> 基准仓状态：plans/ 下 39 个目录、37 个 task_plan.md（`ls -d plans/*/ | wc -l`=39；`ls plans/*/task_plan.md | wc -l`=37）——本仓历史计划规模是所有 O(N_plans) 扫描的放大器。

---

## 0. 结论速览（每类工具调用的 hook 税实测表）

| 事件 | 触发脚本数（进程树根） | 墙钟实测 | clone/execve（strace -f -c） | 全文件扫描 |
|---|---|---|---|---|
| 每条用户消息（UserPromptSubmit） | zcode-userpromptsubmit → resolve-plan-dir + attest-plan --verify + check-conflicts --runtime | **1796 ms/次** | 214 clone / 138 execve | check-conflicts 遍历 plans/* + INDEX 全表 awk；task_plan.md 被 6 个进程各读一遍 |
| 每次 Edit/Write（PreToolUse matcher=`Write\|Edit\|Agent\|CreateWorkflow\|AmendWorkflow\|SaveWorkflow\|EvalWorkflowSnippet`） | zcode-pretooluse → check-scope + check-delegation + check-skill-modify + **内联 Rule23 循环** | **1329–1403 ms/次** | **439 clone / 338 execve** | Rule23 对 37 个 task_plan.md 逐个 awk 全量解析（每 plan 5 进程）；check-scope 哨兵期 sha256sum |
| 每次 Agent 派发（PreToolUse Agent 分支） | zcode-pretooluse → mktemp + check-dispatch pretool | 219 ms/次 | 52 clone / 39 execve | scan_missing grep + stat/realpath；fine_grain 2 次 jq |
| **每次任意工具**（PostToolUse **无 matcher=全工具**） | zcode-posttooluse → resolve-plan-dir | **143 ms/次** | 35 clone / 20 execve | grep task_plan.md + verification.md 各一次（单文件，轻） |
| 会话启动（SessionStart） | zcode-sessionstart → task-plan-init.cjs(node) + set-active-plan gc | 热 255–342 ms；首轮冷 23.7 s（离群，未复现，见 §1.6） | node 冷启动主导 | gc 扫 .active_plan_side |
| Phase complete 翻转（流程门，主进程显式调用） | sync-todos --index | **2642 ms/次** | ~300 子进程（37 plan × ~8） | find 全 plans/ ×37 plan，每 plan rollup 1 awk + meta 3 awk + 4 grep/sed |
| Phase complete 翻转（流程门） | check-3file-gate | 80 ms/次 | — | 3 文件各一遍 grep/sed |
| 终验（流程门） | check-complete（895 行，94 处 awk/grep/for） | 10 ms（未完结计划早退） | — | 完结时全量 |
| attest 校验 | attest-plan --verify | 112 ms/次（UPS 每次用户消息都跑） | — | sha256sum 全文件 |

**核心定量结论**：一个"Edit 1 次 + Bash 3 次 + 派发 1 个子代理 + 用户发 2 条消息"的最小工作循环，纯 hook 税 ≈ 1403 + 143×3 + 219 + 143 + 1796×2 ≈ **5.6 秒**，全部为脚本进程编排开销，其中约 80% 来自对 37 个历史计划的全量重复扫描（与当前任务无关）。simple 任务（总时长本就以分钟计）税率占比远高于 complex 任务——这解释了"简单与复杂任务都慢、simple 相对更慢"的体感。

---

## 1. 逐条瓶颈（标题 / 证据锚 / 任务类别 / 质量耦合 / 预估影响）

### B-1【最重】PreToolUse Rule23 并发检测对 plans/ 全目录 37 个历史计划逐个 awk 全量解析：单次 Edit 439 次 clone，循环体单独 833 ms
- **证据锚**：`skills/task-planner/scripts/zcode-pretooluse.sh:91-116`——`tool=Write|Edit` 即进入循环：`:102` 当前 plan 一次 awk 链（awk+grep+grep+awk+tr=5 进程），`:104-107` `for other_plan in $(ls -t "$CWD/plans"/*/task_plan.md)` **不加任何状态过滤**遍历全部 37 个 plan，每个 plan 重复同一条 5 进程 awk 链，`:109` 仅做 `basename` 字符串匹配。
- **实测**：`bash -x zcode-pretooluse.sh`（Edit 输入）统计外部命令：grep×110、awk×74、tr×40、dirname×38、basename/echo×36×2、循环 37 轮；strace -f -c：**439 clone / 338 execve**。循环体单独复测（等价管道）= **833 ms**；全链 5 次均值 1375 ms、两轮复测 1329/1403 ms。
- **任务类别**：both（simple 任务每次 Edit 都付，占比更高）
- **质量耦合**：**low**——`:112` 命中仅输出 `additionalContext` 提醒（非阻断），且只匹配 basename 字面；历史 complete 计划被扫进去纯属噪声。提速（限 in_progress/活跃指针计划）不削弱任何门控。
- **预估影响**：37 plan 规模下 833→<50 ms（限活跃计划集合或单 awk 合并）；单次 Edit 总耗时 -60% 左右。

### B-2 PostToolUse 无 matcher 挂全工具 + 每次跑 5 个 jq 读同一 config.json：143 ms × 所有工具调用
- **证据锚**：hook 挂载 `~/.zcode/cli/config.json` PostToolUse 块**无 matcher 字段**（对比 PreToolUse 有 `matcher: "Write|Edit|Agent|CreateWorkflow|..."`）→ 每次任意工具（Bash/Read/Grep/Glob/TaskOutput/Agent）都执行；`skills/task-planner/scripts/zcode-posttooluse.sh:109-116` 连续 5 个独立 `jq -r '.properties.X.default' "$SKILL_ROOT/config.json"`（todo_sync_interval_calls/plan_update_interval_minutes/stale_remind_cooldown_calls/findings_stale_minutes/progress_stale_minutes/compass_escalate_after），加 `:43` 每次必跑 `resolve-plan-dir.sh` 子进程（实测 24 ms）。
- **实测**：PostToolUse-Bash 输入 5 次均值 **143 ms**；strace 35 clone / 20 execve；裸 jq 读 config 5 ms/次。
- **任务类别**：both（Bash/Read 调用次数最多，累计税最大）
- **质量耦合**：low——纯阈值读取，合并为一次 jq（或 env 预注入）零语义变化。注意该处 `.properties.X.default` 单层路径读法与 review report #15/#16（high）同根因：用户 config 覆盖静默失效，合并时顺带修复可提质量。
- **预估影响**：143→~60 ms/次；按一天数百次工具调用计，是最大累计税基。

### B-3 UserPromptSubmit 每条用户消息 1796 ms：check-conflicts --runtime（1820 ms 级）+ attest --verify（112 ms）+ 同一 task_plan.md 被 6 个进程各读一遍
- **证据锚**：`skills/task-planner/scripts/zcode-userpromptsubmit.sh:136` 每次调用 `check-conflicts.sh --runtime`（实测单独 1820 ms：内部 9 处 git 调用行——`git status --porcelain` ×2、`git worktree list` ×2、`git branch` ×2 等，git status 单次实测 185 ms；再加 INDEX.md 全表行 × awk + `for candidate in plans/*`（check-conflicts.sh:97-134, 170-172）；:61 每次跑 `attest-plan.sh --verify`（112 ms，含 sha256sum 全文件）；:73-79 同一 task_plan.md 被 sed 全文剥离 + goal/next_step/current 3 个独立 awk + ip RS 扫描 awk + decisions awk+grep×3 共 6 个进程各读一遍（且 plan_clean 经 heredoc 重复传 3 次）。
- **实测**：UPS 单次 **1796 ms**；strace 214 clone / 138 execve。
- **任务类别**：both
- **质量耦合**：medium——UPS 承担防漂移注入（Rule 20.4）+ attest 防篡改（Rule 20.1）+ 委派 owner 认领（:110-123），注入内容与判定逻辑不可删；但**计算方式**可优化（单 awk 提取全部字段、check-conflicts 限活跃计划、git 调用合并），attest 校验可用 mtime+size 短路缓存（篡改必改 mtime）。
- **预估影响**：1796→~400 ms/条；每个用户回合省 1.4 s。

### B-4 sync-todos.sh --index 全量重写：37 plan × ~8 进程 = 2642 ms，每次 Phase complete 翻转都跑
- **证据锚**：`skills/task-planner/scripts/sync-todos.sh:234` `find "$plans_dir" -maxdepth 2 -name task_plan.md` 全目录枚举；`:215-233` 对每个 plan 跑 `rollup_task`（1 awk，:166-186）+ `extract_plan_meta`（3 个独立 awk + 4 个 grep/sed/head/tr，:191-199）≈ 8 子进程/plan；`:271` 每次全量重写 INDEX.md。
- **实测**：2642 ms/次（本仓 37 plan）。SKILL.md 执行循环要求每次 Phase 翻转刷新 INDEX（3-File 门控配套）。
- **任务类别**：both（complex 任务 Phase 多、调用次数多）
- **质量耦合**：medium——INDEX.md 是恢复入口（SessionStart 读待处理区，zcode-sessionstart.sh:18-28），全量重写语义应保留；优化=单 awk 聚合全部 plan（一次进程读 N 文件）或仅更新变化行，输出字节不变即可，无质量损失。
- **预估影响**：2642→~300 ms；每次 Phase 翻转省 2.3 s。

### B-5 check-scope.sh 每次写路径检查启动 python3 解释器 + 哨兵期 sha256sum：129 ms/次，且对 Agent/CreateWorkflow 等无文件工具也空跑
- **证据锚**：`skills/task-planner/scripts/check-scope.sh:51` `python3 -c "import os,sys; print(os.path.abspath(...))"` 做 abs 化（裸 python3 实测 6 ms）；`zcode-pretooluse.sh:18` 的 check-scope 调用在 `case "$tool"` **之前**无条件执行——Agent/CreateWorkflow 等 tool_input 无 file_path 时靠 `check-scope.sh:32` 空参早退，但脚本加载链已付；哨兵活跃时 `:142-144` 每次写检查都做 `.plan-attestation` sha256sum 实时哈希 + `:108` 再起一个 resolve-plan-dir.sh 子进程。
- **实测**：check-scope 正确传参 129 ms/次。
- **任务类别**：both
- **质量耦合**：**high**——哨兵/计划先行是本技能第一质量门（P0），判定逻辑不可削弱；但 python3→纯 bash `realpath -m`、sha256sum 结果按 (mtime,size) 短路缓存，均为实现替换，判定语义不变。
- **预估影响**：129→~20 ms；且消除每 Edit 一个 python3 进程。

### B-6 config.json 的 jq 单键重复读取遍布热路径：单次 Edit 事件链合计 8-9 个 jq 进程；且全部用 `.properties.X.default` 单层路径，用户覆盖不生效（review #15/#16 同根因在 3 个 hook 脚本复现）
- **证据锚**：`zcode-posttooluse.sh:109-116`（5 键 5 次 jq）；`check-dispatch.sh:268`（prompt_max_chars）与 `:130`（get_mode，1 次 jq）；`check-delegation.sh:131`（get_enforce_mode）；`zcode-userpromptsubmit.sh:99`（prompt_note_interval）；`check-plan-dispatch.sh:115-116`（review report #16 已确证 step_max_minutes/step_max_files 得 null 回退默认）。一次 Edit 事件：pretooluse 内 check-delegation(1) + check-skill-modify + posttooluse(5) ≈ 7-9 个 jq，每个 ~5 ms。
- **实测**：`grep -c config.json` 计数：posttooluse=7 处引用、check-dispatch=4、check-delegation=2、UPS=1。
- **任务类别**：both
- **质量耦合**：medium——若顺手改成双层路径（`.X // .properties.X.default`），同时修复"用户调 warn/off 不生效"的正确性缺陷（质量**增强**而非削弱）。
- **预估影响**：省 30-40 ms/事件 + 修复 config 覆盖失效类缺陷。

### B-7 并发冲突检测三套实现并存、同一文件三处复制同一 awk 管道
- **证据锚**：①`zcode-pretooluse.sh:100-116`（Rule23 目录遍历版，Edit 时跑）；②`check-conflicts.sh --runtime`（INDEX 驱动版，`check-conflicts.sh:97-113` 对 INDEX 每行 awk、`:118` 再 `for candidate in plans/*` 遍历、`:134` current_scope 解析，UPS 每次跑）；③scope 表提取管道 `awk '/^## .*执行范围限制/{f=1; next} /^## /{f=0} f' | grep '^|' | grep -v '^|---' | awk -F'|' ...` 在 `zcode-pretooluse.sh:102,107`、`check-conflicts.sh:108/134`、`sync-todos.sh:197`（extract_plan_meta）**四处逐字重复**。同一用户回合内（发消息→Edit），两套检测先后各扫一遍全 plans/。
- **任务类别**：both
- **质量耦合**：medium——合并实现时保留两处调用点（或收敛为一处共享 helper），检测语义并集不变。
- **预估影响**：去重后 B-1+B-3 的冲突检测税减半以上；消除三处管道漂移风险（review #28 类漂移同型）。

### B-8 check-dispatch pretool 每次派发 90 ms（Agent 税）：2 次 jq + scan_missing stat/realpath 链 + prompt 落盘 mktemp 往返
- **证据锚**：`zcode-pretooluse.sh:70-76` 每次派发 mktemp 写 prompt 全文到 /tmp 再由子脚本读回；`check-dispatch.sh:160` get_mode 1 jq、`:171` decl_taskdirs grep+xargs+sort、`:209` scan_missing（对 prompt 中每个三文件候选 stat -c %d:%i / realpath -m 循环，:67-114）、`fine_grain_checks` 再 2 个 jq（`:268` prompt_max_chars、step_max_steps 同范式）+ 4 组 grep 全文扫描（count_step_markers，:247-255）。
- **实测**：check-dispatch pretool 单独 90 ms；Agent 全链 pretooluse 219 ms。
- **任务类别**：both
- **质量耦合**：**high**——派发契约门默认 enforce（config.json `dispatch_contract_enforce` default=enforce），是子代理协议的质量门；只能做进程合并/短路（如 jq 一次读 3 键），**七项缺项判定与四项增量检测的判定逻辑不可减**。
- **预估影响**：90→~40 ms；单次派发省 50 ms（相对派发本身秒级成本，优先级最低）。

### B-9 派发守卫链中 resolve-plan-dir.sh 被重复调用：单次 Agent 事件 3+ 次，check-delegation resolve_plan_dir_any 最多向上 6 级 + home 兜底各跑一遍
- **证据锚**：`zcode-posttooluse.sh:43`（每次任意工具 1 次）；`zcode-posttooluse.sh:30`（Agent 时再 1 次清锁）；`check-delegation.sh:48-57`（pretool 内 1 次）+ `:60-81` resolve_plan_dir_any 的 CWD 向上 6 级循环与 `$HOME/.zcode/plans` 兜底**每次调用都是新的 bash 子进程**（实测单次 resolve-plan-dir 24 ms）。Edit 事件链合计 2-9 次 resolver 子进程。
- **任务类别**：both
- **质量耦合**：low——解析结果在同一 hook 进程内可传递/缓存，指针语义不变。
- **预估影响**：每事件省 25-100 ms。

### B-10 SessionStart 首轮冷启动 23.7 s 离群（node 冷缓存），热态 255-342 ms；task-plan-init.cjs 热态 656 ms
- **证据锚**：`zcode-sessionstart.sh:13` 每会话启动 node 跑 task-plan-init.cjs（热态实测 656 ms）；首轮三连测均值 23.7 s、复测两轮 342/255 ms——冷缓存离群未复现，如实标注为"未定位到稳定根因"。`:33` set-active-plan gc 实测 55 ms（轻）。
- **任务类别**：both（每会话一次，simple 任务一次性税占比高）
- **质量耦合**：medium——哨兵写入（§一 计划先行触发器）不可删；可评估 node→纯 bash 重写哨兵写入（哨兵格式 task-plan-init.cjs 内定义）。
- **预估影响**：会话启动税 656→~50 ms；冷启动离群需在真实冷环境另测（本环境未能复现稳定值）。

---

## 2. 可合并守卫清单（合并后质量门不降）

1. **Rule23（pretooluse 内联）+ check-conflicts --runtime** → 一个共享的"活跃计划冲突扫描器"（限 active 指针/in_progress 计划，单 awk 聚合）。两处调用点保留，检测结果复用。锚：B-1/B-7。
2. **scope 表提取管道四处复制**（B-7 锚）→ 提取为 lib/ 单函数（本仓已有 lib/ 目录），四处 source。
3. **posttooluse 5 jq + check-dispatch/check-delegation get_mode jq** → 统一 config 加载 helper：一次 jq 读全部键 + 双层路径修正。
4. **check-scope 的 sha256sum 与 attest --verify 与 posttooluse auto-relock** 三处对同一 task_plan.md 哈希（B-5/B-3 锚）→ 以 `.plan-attestation` + (mtime,size) 短路：文件未变直接复用上次判定，篡改必变 mtime，防篡改语义不弱。

## 3. 可懒执行 / 可增量化热点

1. **Rule23 循环懒执行**：仅当 `plans/.active_plan_side/` 有活跃指针或计划状态非 complete 时才做 scope 比对；37 个历史计划中 30+ 个 complete（posttooluse:100-105 已有 outcome COMPLETE 跳过先例可复用）。
2. **sync-todos --index 增量**：单 awk 进程聚合全部 plan（awk 可多文件输入），或按 task_plan.md mtime 只重写变化的行；INDEX.md 输出格式不变。
3. **check-conflicts git 调用合并**：`git status --porcelain` ×2 + `worktree list` ×2 + `branch` ×2 → 各 1 次（结果变量复用），git status 单次 185 ms 是该脚本主税。
4. **posttooluse config 懒读**：5 个阈值在一次 jq 里读出；或在 SessionStart 写入 /tmp 缓存文件供后续 hook source。
5. **UPS 字段提取**：goal/next_step/current/ip/decisions 5 个独立 awk + sed → 1 个 awk 一次遍历产出全部字段（task_plan.md 单文件 <10 KB 量级，进程开销远大于解析本身）。
6. **check-scope python3 → bash realpath -m**（零解释器）。

## 4. config.json enforce/warn 档位分布实测

`skills/task-planner/config.json` 中 `_enforce` 三档键共 **19 个**：
- **默认 enforce（2 个）**：`delegation_enforce`（:43-51）、`dispatch_contract_enforce`（:62-70）——即 hook 链中真正阻断级的门只有委派门与派发契约门两个。
- **默认 warn（17 个）**：content_quality、fmea、skill_collab、knowledge_brief、hook_self_heal、vc_gate、rescue_chain、context_hygiene、plan_hygiene、shared_tracker、error_loop、veto、reflect_verify、template_gate、mechanism_profile、skill_modify、plan_tier（各行 :71-328）——全部"观察期"设计：**hook/校验代码仍在跑（jq 读取 + 告警注入 + 计数落盘），只是不阻断**。
- 效率含义：17 个 warn 档守卫是"持续付费、暂不收获"的观察面——其中 hook 层实跑的仅 skill_modify（pretool 第 3 门，13 ms）与 vc_gate/rescue 等 check-complete 终验段；其余为流程层。优化空间在合并它们的读取成本（B-6），而非删检查。

## 5. 59 脚本归类总表（按触发方式）

| 类别 | 数量 | 脚本 | hook 高频？ |
|---|---|---|---|
| hook 适配器 | 4 | zcode-pretooluse / zcode-posttooluse / zcode-sessionstart / zcode-userpromptsubmit | ★★★ 每工具/每消息 |
| pretool 守卫 | 4 | check-scope / check-delegation / check-skill-modify / check-dispatch | ★★★ 每写/每派发 |
| 流程门（主进程显式调用） | 9 | check-3file-gate / check-complete / check-plan-dispatch / check-rescue-chain / check-scope(工具) / check-template-type / check-drift / check-doc-sync / check-context-hygiene + plan-hygiene | ★★ 每 Phase/终验 |
| 状态/解析支撑 | 7 | resolve-plan-dir / set-active-plan / resolve-interaction-mode / sync-todos / ledger-append / plan-doctor / check-conflicts | ★★ resolver 每 hook 必跑；check-conflicts 被 UPS 挂载 |
| attestation/委派豁免 | 3 | attest-plan / allow-direct / subagent-fallback | ★ attest 被 UPS 每消息调用 |
| 合并/初始化 | 7 | smart-merge-back / init-session / task-plan-init.cjs / plan-created.cjs / sync-companion / sync-ide-folders.ts / session-catchup.ts | ★ 会话/交付一次性 |
| selftest 守护套件 | 27 | selftest-*.sh（review report 领域 4：实跑 453 断言 0 FAIL；任务书称 457——本次未重跑全量 selftest，以 report 453 实测记载为准，差异如实标注） | 0（仅开发期） |
| 其他 | 3 | check-complete.ps1 / init-session.ps1 / register-hooks-cj.ts | 0 |

hook 挂载点（`~/.zcode/cli/config.json` `.hooks.events`）：SessionStart/PreToolUse/PostToolUse/UserPromptSubmit 各 1 命令，全部指向部署位 `~/.zcode/skills/task-planner/scripts/zcode-*.sh`，timeout 均 5-10 s。**PostToolUse 无 matcher = 全工具触发**；PreToolUse matcher 覆盖 Write|Edit|Agent|CreateWorkflow|AmendWorkflow|SaveWorkflow|EvalWorkflowSnippet（Bash/Read 不进 PreToolUse）。

## 6. 交叉参考上一轮 review report（plans/task-planner-skill-review/report.md）

- **#15/#16（high，confirmed）**：jq 单层路径 config 覆盖失效（subagent-fallback.sh:46-52、check-plan-dispatch.sh:115-116、check-dispatch.sh:268）——本域 B-6 实测确认同一模式遍布 4 个 hook 热路径脚本，属于"效率+正确性"双修复点。
- **#27（medium）**：check-conflicts / check-drift / check-doc-sync / plan-doctor / ledger-append 零 selftest 引用——其中 check-conflicts 恰是本域最重性能点之一（B-3），重构时先补行为级 selftest 再动。
- **#21（low）**：cost-control.md:143-152 声明的 3 个 hook 注入点与脚本标记脱同步——hook 面文档漂移先例，本次优化改 hook 行为时须同步 cost-control.md 与 SKILL.md 计数口径。
- selftest 断言基线：report 记 453/453（领域 4 实测 3 轮），任务书基线写 457——本次审计未重跑 selftest 全量，无法裁决 453 vs 457，如实存疑。

## 7. 审计边界与未竟事项（如实声明）

1. 计时环境 = 本机（linux 6.8，容器/开发机），绝对值随机器浮动；但**同机对比**（Rule23 循环 833 ms vs 全链 1400 ms、posttooluse 143 ms vs 单 jq 5 ms）的相对结论稳。
2. SessionStart 首轮 23.7 s 冷启动离群在 2 轮复测中未复现（热态 255-342 ms），根因未定位，不作为独立发现。
3. selftest 27 个共 453 断言（report 记载）本次未重跑；任务书称 457，差异未裁决。
4. 部署位 sync-todos.sh 比本体多 3 行热修复（2026-09-25 task-videop1-partial-regen-001，goal 竖线清洗，diff 实证）——本体落后于部署位，属反向漂移记录，建议并入主任务回填。
5. check-complete.sh 全量路径（计划完结后的 94 处 awk/grep 段）仅测了未完结早退分支（10 ms）；完结分支耗时未测，不影响本次结论（终验为低频事件）。
6. 本审计未运行任何 selftest、未修改任何技能文件（只读 + 本文件写入）。
