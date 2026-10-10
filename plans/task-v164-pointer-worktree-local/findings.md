# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1-R5 逐字原文以 task_plan.md「🎯 用户需求原文」区块为唯一权威（禁此处转译）；摘要=R1 状态文件存工作数内 / R2 指针并行混乱（[目标]）/ R3 指针存工作数文件 / R4 合并时忽略状态临时文件 / R5 执行会话实证（全局指针仍指已完成 v152、被移交给 v163）

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| set-active-plan.sh 全文（268 行） | skills/task-planner/scripts/set-active-plan.sh | ☑ | Research Findings A/B |
| resolve-plan-dir.sh 全文（130 行） | skills/task-planner/scripts/resolve-plan-dir.sh | ☑ | Research Findings A/C |
| 仓根 .gitignore | /mnt/data/dev/task-planner-skill/.gitignore | ☑ | Research Findings D |
| 上一轮指针修复计划 | plans/fix-pointer-race-20261007/ | ☑ | Research Findings E |
| git 历史/索引状态 | git log -- plans/.active_plan / git ls-files | ☑ | Research Findings B |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### A. 机制第一手审计：指针路径层面已随工作树本地化（纠正用户模型的前提事实）
- `set-active-plan.sh:69` ROOT 默认 `$PWD`；`:84-85` `PLAN_ROOT/ACTIVE_FILE=$ROOT/plans/.active_plan` → 指针文件路径本就 `$PWD` 相对，工作树各自一份
- `resolve-plan-dir.sh:30` `ROOT="${1:-$PWD}"`；`:58-95` side 层优先（TTL 24h + 双命名空间兼容 + sidmap 转译）→ `:97-105` 全局层 → `:107-124` mtime 最新 → `:126-129` legacy 根单文件
- 结论：用户"指针存放在工作数相应文件下"（R1/R3）的**路径诉求是既成事实**；真缺陷在 B/C 的跟踪态与叙事层，不在路径层——方案应聚焦瞬态化而非路径改造（避免不必要大改）

### B. git 跟踪态实证：churn 噪音 8 连（根因一）
- `git ls-files --error-unmatch plans/.active_plan` → 被跟踪；`git show HEAD:plans/.active_plan` = `task-v152-proactive-context`（一个已完成计划的指针值被提交入库）
- `git log --oneline -8 -- plans/.active_plan`：
  - `f6d6158` chore(task-v153): .active_plan 移交修复→task-v152（v150 已完成孤儿指针）
  - `de3c19f` v151 收尾簿记入库（含 .active_plan 指认）
  - `21f7e6b` v146/v148 收尾簿记入库
  - `ee978a1` v144 land
  - `55c24fc`/`76168cb`/`26f938c`/`26878fe` 会话指针收尾（v095-v098 同例连发，"交付后残留"字样自证）
- 结论：跟踪态把"即写即弃的运行态"变成永久提交噪音，每次移交/指认都是一次 chore——与 R4"合并时忽略该状态文件"正相反

### C. 并行实况：side 层已保护真实会话，全局层是可见漂移面（根因二）
- `.active_plan_side/` 现存 8 个会话指针（mtime 05:56→11:04）：v152×2 / v151 / v156-drift-shield / v160-decision-grading / v162-change-absorption-safety / v163×2 → 并行会话实际在跑 ≥6 个任务
- 全局指针（主树）= v152（completed）→ sid-less 消费者/cron 解析到已完成计划；v163 会话（sid cbab959f/de2c5bba）实录 R5b"先移交全局指针到 v163"= 用户观察到的漂移来源
- 2026-10-07 fix-pointer-race 已把权威解析下沉 side 层（sidmap 映射优先+新鲜窗+拒抢 WARN，见 `plans/fix-pointer-race-20261007/`）；本会话（v152 执行会话）side 指针 `1cefd1cf…` 在 TTL 内解析正确=**未被劫持**——用户所感混乱=全局 fallback 层漂移 + 历史 churn 噪音的叠加，而非 side 层失效
- 残留（瞬态化不消除、记录备查）：主树内 sid-less 消费者仍共享该树全局指针；真实会话有 side 层保护不受影响

### D. 兄弟瞬态文件范式：.active_plan 是旧设计仅存的跟踪态漏网
- 仓根 `.gitignore:1-10` 已 ignore：`.active_plan_side/`、`.plan_required_side/`、`plans/**/.session-owner`、`.drift-rhythm/`、`.backup*/`、`__pycache__/`
- `.active_plan` 与上述同族（即写即弃运行态）却是唯一跟踪态 → 归一即完成治理拼图（R1/R4 直接兑现）

### E. 引用面规模（级联工作量测算）
- `grep -rn 'active_plan' skills/task-planner/` → 28 文件 166 hits；多为只读消费方（zcode-*posttooluse/userpromptsubmit/sessionstart、check-complete/check-scope/check-dispatch/allow-direct/plan-doctor/ledger-append、selftest-*）
- 措辞更新方集中：`set-active-plan.sh`/`resolve-plan-dir.sh` 头注释 + `references/critical-rules.md` 指针段 + `SKILL.md`/`README.md`/`INSTALL.md` + selftest 注释/断言 → Phase 3 逐个人工判定（禁 sed 批量）

### F. 相邻观察（登记不扩大范围，Rule 8.1 防 scope 蔓延）
- `plans/task-v161-subagent-return-format/subagent-state/.dispatch-inflight` 被 git 跟踪（status=M），而同目录 subagent-state/*.md 未跟踪也未 ignore → 22.8 检查点瞬态文件治理不完全；本任务不处理，待后续裁决
- `plans/INDEX.md:101` task-v146 行状态=pending/"⚠ 未开始"，但该任务 10-08 已 COMPLETE（merge e54973d，计划目录 task_plan.md 已归档）→ INDEX 陈旧行（本轮写 task_plan.md 时被 conflict hook 误报的来源）；本任务不处理，待后续清理

#### [sub:1-code-runner-agent] S1 基线结论
- 事实：v164 worktree（HEAD 7317455，wt/v164-pointer-worktree-local）全量 71 个 `selftest-*.sh` 逐脚本真实退出码 **全部 rc=0**（rc≠0 集合=空）；逐段关键行落 `plans/task-v164-pointer-worktree-local/baseline-selftest.log`（71 个 `=== selftest-*.sh rc=` 段，`grep -cE '^=== selftest-.*\.sh rc=0$'`=71，rc≠0 段=0）。rc 捕获法自证：/tmp 故意 exit 3 脚本经同款 `out="$(bash f)"; rc=$?` 得 rc=3；抽样独立复跑 agent-coverage/periodic-review/registry 均 rc=0 且 FAIL=0；全 log 无非零 FAIL 计数（`grep -nE 'FAIL[=: ]+[1-9]'` 空）
- 与材料预期差异（主进程注意）：材料引先例 fix-pointer-race「既有 FAIL ~15」在本基线**不复现**——15 嫌疑脚本在 log 内逐段 rc=0 且 FAIL=0（agent-coverage `Total: 9 PASS=9 FAIL=0`、workflow-orchestration `Total: 16 PASS=16 FAIL=0`、registry `Total: 5 PASS=5 FAIL=0 (registry rows=71, actual selftest=71)` 等，15 项逐一提取均 FAIL=0）。归因锚：先例清单出自 `plans/fix-pointer-race-20261007/subagent-state/4-code-assistant.md:34`（2026-10-07 时点，已过时）；14/15 脚本自 10-07 起被修复提交触及（`git log --since=2026-10-07 -- <脚本>`，如 0cea211「合并态全量 70/70 PASS」2026-10-10、f3ff1b8 2026-10-08），registry 本身 0 提交但动态断言随数据更新通过
- 边界事实：worktree HEAD 7317455 是 master 的**祖先**，master 领先 16 提交（`git rev-list --count HEAD..master`=16、`master..HEAD`=0；master tip 79cd10a=task-v161 Phase 3）→ 本基线=worktree 态基线，≠当前 master tip 态；knowledge-brief「worktree 根（=master HEAD 态）」措辞与现状不符，S8 对照口径需按此校准（是否需 rebase/重基线由主进程裁决）
- 两段特殊格式（无 Total 字样但含 PASS/FAIL 关键行原文）：selftest-final-gate-hash.sh 段 log:155-161 结行 `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====`；selftest-user-instruction-priority.sh 段 log:468-469 输出 `=== ALL PASS ===`（脚本自带格式，无 Total 行）
- 负结果报告：未发现任何 rc≠0 脚本；未发现 log 中非零 FAIL 计数；未修改 worktree 内除 baseline-selftest.log / subagent-state/1-code-runner-agent.md / 本 findings 段 / progress.md 单行外的任何文件；未执行 git 写操作（git status 复核：M progress.md、?? baseline-selftest.log、?? subagent-state/）

#### [sub:2-executor] S2 索引瞬态化
- 事实（命令→关键输出）：`git rm --cached plans/.active_plan` → `rm 'plans/.active_plan'`（exit 0；工作区文件保留，`ls -la` 仍见 28B）；`.gitignore` 末尾追加 3 行（Why 注释 2 行 + `plans/.active_plan`，仓根 .gitignore 现 15 行）
- 验收复核：`git ls-files --error-unmatch plans/.active_plan` → `error: pathspec 'plans/.active_plan' did not match any file(s) known to git`（exit 1）；`grep -n '^plans/.active_plan$' .gitignore` → `15:plans/.active_plan`；legacy `set-active-plan.sh task-v164-pointer-worktree-local` → `全局指针已设置`，`cat plans/.active_plan`=`task-v164-pointer-worktree-local`
- 瞬态性确认：`git status --short --untracked-files=all | grep -F plans/.active_plan` 仅见 `D  plans/.active_plan`（索引删除态），**无 `??` 未跟踪条目** → gitignore 生效
- 边界事实（主进程注意）：`.gitignore` 为未暂存（` M`）改动，故 `git diff --cached --stat` 当前仅见 `plans/.active_plan | 1 -`（D），`.gitignore` 行在 `git diff`（未暂存）；按 §4「禁 git add」未暂存，暂存/提交归主进程
- 负结果报告：未执行 git add/commit/checkout/reset；未删工作区文件；未动 skills/task-planner/**；`git status` 另见 ` M subagent-state/.dispatch-inflight` 为派发期既有改动（非本次产生）

#### [sub:3-executor] S3 头注释改述
- 事实（命令→关键输出）：`grep -c 'task-v164'` → set-active-plan.sh:6 / resolve-plan-dir.sh:4；`bash -n` 两脚本 rc=0；`git diff --stat` 仅两脚本（+ 既有派发期 `.dispatch-inflight` 改动）
- 改述锚：set-active-plan.sh:3-8（摘要行"全局 fallback"+side 权威层补注）:9-17（新增 `[2026-10-10 task-v164]` 三点块：①路径本地化既成事实 ②瞬态化 git rm --cached+.gitignore 同族 ③角色降级 fallback+退役"移交"叙事）:41（usage 行内补注，命令形态不变）:33-34（尾部"全局 legacy"→"全局 fallback"补注）；resolve-plan-dir.sh:7-14（同三点块）:19（解析链第 2 行"全局指针"→"全局 fallback"补注）:29-30（2026-09-10 errata 段末补注）
- 保留纪律核验：2026-09-10 active-plan-race / task-planrequired-race 既有 errata 段落逐字保留，仅追加/行内补注 `[2026-10-10 task-v164]`；usage 命令形态未改；`set -u` 之后零改动
- 验收复核：`git diff -U0 -- <两脚本> | grep -E '^[+-]' | grep -vE '^(\+\+\+|---)' | grep -vE '^[+-][[:space:]]*#' | grep -c .` → 0（代码区零改动）；"移交"7 处均为退役/历史事实陈述（"退役'移交全局指针'叙事"/"不再称'移交/指认全局指针'"/历史 chore 移交噪音），无推荐操作表述
- 负结果报告：未改函数体/变量/usage 命令形态/解析链逻辑；未执行 git add/commit/checkout/reset；未动其他文件（`.dispatch-inflight` M 为派发期既有改动，非本次产生）

#### [sub:4-executor] S4 引用面分级
- 全集：`grep -rln 'active_plan' skills/task-planner/` = **28 文件**；`grep -rn 'active_plan' skills/task-planner/` = **170 hits**（材料记 166，实测 170，差 4；以实测为准，文件数 28 与材料一致）
- 判据：hit 落在代码逻辑（路径拼装/守卫断言/resolver 调用）或注释语义中性 → 只读消费方；hit（或其所处注释块 ±5 行）为注释/文档正文且把全局指针框为旧语义（全局 legacy / 全局指针·单例 / 移交 / 跨树共享 / 入库 / git 跟踪 / legacy…指针）→ 措辞更新方；S3 已改述两文件单列
| 文件(相对 skills/task-planner/) | hits | 分类 | 依据(file:line + 一句理由) |
|--------|------|------|---------------------------|
| INSTALL.md | 1 | 措辞更新方 | :189 正文"全局 legacy `plans/.active_plan` 仅兜底"→旧语义"全局 legacy" |
| README.md | 2 | 措辞更新方 | :100,:101 文档"全局 legacy .active_plan"→旧语义 |
| scripts/selftest-check-conflicts.sh | 1 | 只读消费方 | :18 注释述测试局部变量 active_plans 恒空(中性,无指针语义) |
| scripts/selftest-rule23-conflict-scan.sh | 2 | 只读消费方 | :12,:98 注释=测试场景"无 active_plan 指针"(中性) |
| scripts/plan-hygiene.sh | 2 | 只读消费方 | :7 注释=side 指针残留(中性); :117 代码 for 循环 |
| scripts/allow-direct.sh | 3 | 只读消费方 | :73,:140,:159 代码 error 串 "no_active_plan"(守卫断言) |
| scripts/zcode-userpromptsubmit.sh | 5 | 措辞更新方 | :23 注释"并行会话不再互顶全局 legacy 指针"→旧语义 |
| scripts/plan-doctor.sh | 2 | 只读消费方 | :4 注释"无 .active_plan 指针"(中性); :48 代码路径拼装 |
| SKILL.md | 2 | 措辞更新方 | :59 "全局 legacy"(旧语义); :111 "指针移交…全局指针"(旧语义 移交) |
| scripts/ledger-append.sh | 1 | 只读消费方 | :5 注释"本仓脚本惯例,无 .active_plan"(中性) |
| scripts/selftest-delegation.sh | 11 | 只读消费方 | :93,:94,:410 等测试代码写/清 .active_plan 路径拼装 |
| scripts/zcode-posttooluse.sh | 2 | 措辞更新方 | :43-44 注释块"不再被全局 legacy 指针互顶"→旧语义 |
| scripts/check-scope.sh | 2 | 只读消费方 | :136 注释 side 指针(中性); :140 代码守卫断言 |
| scripts/zcode-sessionstart.sh | 1 | 只读消费方 | :30 注释=gc 清扫 side 指针(中性) |
| scripts/task-plan-init.cjs | 3 | 措辞更新方 | :128-131 代码,邻注释 :122-124"不读全局 legacy/全局指针恒有效"→旧语义 |
| scripts/selftest-drift-enforcement.sh | 12 | 只读消费方 | :66-158 测试代码 mkdir/printf side 指针路径拼装 |
| scripts/resolve-plan-dir.sh | 11 | 已改述（S3） | :7-14,:18,:29-30 [2026-10-10 task-v164] 三点块+"全局 fallback"补注在位 |
| scripts/init-session.sh | 12 | 措辞更新方 | :719,:720"不碰/写全局 legacy"; :727"legacy 全局指针"→旧语义 |
| scripts/zcode-pretooluse.sh | 1 | 措辞更新方 | :72-73 注释"不再被互顶的全局指针误拦"→旧语义 |
| scripts/check-conflicts.sh | 4 | 只读消费方 | :121,:137,:177 代码 active_plans 数组(局部变量) |
| scripts/check-complete.sh | 3 | 措辞更新方 | :1338 注释"全局指针…仍指向本任务"; :1346"移交提醒…请移交"→旧语义 移交 |
| scripts/set-active-plan.sh | 15 | 已改述（S3） | :3-17 [task-v164] 三点块 + :21,:33"全局 legacy"→fallback 补注在位 |
| scripts/selftest-active-plan.sh | 42 | 只读消费方 | :59-363 测试代码 side/global 指针路径拼装与断言 |
| scripts/plan-created.cjs | 17 | 措辞更新方 | :134 注释"③ legacy plans/.active_plan 指针"→旧语义 legacy…指针 |
| scripts/check-dispatch.sh | 2 | 措辞更新方 | :20 注释"全局指针 .active_plan 被并发会话/cron 频繁翻转"; :216"全局 legacy 指针"→旧语义 |
| scripts/selftest-pointer-lifecycle.sh | 7 | 只读消费方 | :59 注释测试判据(中性); :61-82 测试代码指针路径 |
| scripts/check-skill-modify.sh | 2 | 只读消费方 | :64,:65 代码守卫断言读 side 指针 |
| references/critical-rules.md | 2 | 措辞更新方 | :196 Rule22.9"全局 legacy…互顶全局指针"(旧语义); :298 side 指针(中性) |

汇总：只读 14 个 / 措辞更新 12 个 / 已改述 2 个（14+12+2=28）
- 负结果报告：本 S-unit 零文件编辑（仅 findings.md 追加段 + progress.md 单行）；未执行 git 写操作；未动 skills/task-planner/**（`git status --short` 无 skills/ 条目，见 checkpoint）

#### [sub:5-executor] S5 critical-rules+SKILL 改述
- 事实（命令→关键输出）：基线 `grep -nE '全局 legacy|指针移交'` = 4 hits（SKILL.md:59/111、critical-rules.md:196）；改述后 = 0（rc=1 空集）；`grep -c 'task-v164'` critical-rules.md=2 / SKILL.md=2（改述前各 0）
- 改述锚：critical-rules.md:196（Rule 22.9 解析链 ②「全局 legacy」→「全局 fallback」+`[2026-10-10 task-v164]` 补注；「互顶全局指针」→「覆写全局层」+退役叙事补注）；:198-201 新增「### [2026-10-10 task-v164] 瞬态状态文件合并规则」登记段（范围/合并纪律/依据+R4 锚四要素，全文照 5-prompt-material.md）；SKILL.md:59（「全局 legacy」→「全局 fallback」+补注）；:111（「指针移交」→「指针清理」、「全局指针」→「全局 fallback」、「显式移交」→「显式改写」、「移交提醒」→「提醒」+补注；task-v159 HTML 注释逐字保留）
- :298 核对为中性（仅 side 指针 .active_plan_side/，无旧语义）→ 不改（与 S4 判只读一致）
- 语义零改动核验：`git diff` 内解析链①②③④/set-active-plan 命令形态/check-complete warn 行为均未变，仅措辞+新增段（critical-rules +7/-2、SKILL +2/-2）
- ⚠️ 副作用（主进程注意，S4 未列）：`selftest-pointer-lifecycle.sh` PL-07（:43-44 `cnt '指针移交' "$SKILL" -ge 1`）因 SKILL.md 字面「指针移交」被改述 → 该脚本 rc=1（`FAIL PL-07 (SKILL.md 移交纪律行缺失)`、`Total: 10 PASS=9 FAIL=1`）。禁动 .sh（S5 边界）→ 需后续 S-unit 同步 PL-07 锚为「指针清理」（Phase 3/4 .sh 措辞更新批次）
- 负结果报告：仅改清单内两文件区段；未改 :298/其他规则/SKILL 其他节；未动任何 .sh/.cjs；未执行 git add/commit/checkout/reset；`git diff --stat` 除两目标文件外仅 `.dispatch-inflight`（派发期既有 M，非本次产生）

#### [sub:6-executor] S6 README+INSTALL 改述
- 事实（命令→关键输出）：基线 `grep -nE '全局 legacy' README.md INSTALL.md` = 3 hits（README:100/101、INSTALL:189）；改述后 = 0（rc=1 空集）；`grep -c 'task-v164'` README.md=1 / INSTALL.md=1（改述前各 0）
- 改述锚：README.md:100（`全局 legacy .active_plan`→`全局 fallback .active_plan（工作树内瞬态兜底）`）；:101（同→`全局 fallback .active_plan`）；:102 邻行新增 `│   # [2026-10-10 task-v164] 上两行原措辞以 legacy 描述该层，改述为「全局 fallback」：实为工作树内瞬态兜底（路径随 $PWD 本地化；git rm --cached+.gitignore，与 .active_plan_side/ 同族瞬态运行态）；正常路径=side 会话私有指针（权威层）；退役「legacy/移交」叙事`。INSTALL.md:189（`全局 legacy plans/.active_plan`→`全局 fallback plans/.active_plan（工作树内瞬态兜底，路径随 $PWD 本地化）`+行内 `[2026-10-10 task-v164 补注：原措辞以 legacy 描述该层…退役「legacy/移交」叙事]`）
- 防 grep 误伤核验：注记避开字面「全局 legacy」连写（仿 S5 用「原措辞以 legacy 描述该层」），故 A2 grep=0 与「保留原措辞说明」兼得
- 保留纪律核验：两文件仅动清单内行（README 净 +1 行 ≤±2、INSTALL 行数不变）；代码块箱线/安装命令块/表格零改动（`git diff` 仅 2 hunk，未触及 install.sh 命令块与 §0/§4.5 表格）
- 验收复核：`grep -c 'task-v164'`→1/1；`grep -nE '全局 legacy'`→空 rc=1；`git diff --stat`→仅 INSTALL.md(+1/-1)+README.md(+3/-2)（第三行 `.dispatch-inflight` 为派发期既有 M，非本次产生）
- 负结果报告：仅改清单内两文件区段；未动 skills/ 下其他文件与任何脚本；未改安装命令/表格；未执行 git add/commit/checkout/reset

#### [sub:7-executor] S7 两 hook 注释改述
- 事实（命令→关键输出）：基线 `grep -nE '互顶全局|全局 legacy' zcode-userpromptsubmit.sh zcode-posttooluse.sh` = 2 hits（UPS:23、PTU:44）；改述后 = 0（rc=1 空集）；`grep -c 'task-v164'` 两脚本各=1（改述前各 0）
- 改述锚：UPS:23（原「并行会话不再互顶全局 legacy 指针」→ `优先(权威层,2026-10-07 fix-pointer-race 后)` + `[2026-10-10 task-v164]` 三点块：全局 `plans/.active_plan` 实为工作树内瞬态 fallback（路径随 $PWD 本地化；git rm --cached+.gitignore，与 .active_plan_side/ 同族）；正常路径=side 会话私有指针（权威层）；退役"互顶"叙事）。PTU:43-44（原「不再被全局 legacy 指针互顶」→ 同三点块 + 注记）。注记仿 S5/S6 用「原措辞以「legacy 全局指针被互顶」描述」避开字面「全局 legacy」连写，防 grep 误伤（A4 与保留原措辞说明兼得）
- 保留纪律核验：改述处仅增 `#` 行，历史勘误注释（[2026-09-10 active-plan-race] 等）逐字保留未删；`set -u` 之后/全部代码、变量、函数、usage 零改动（`git diff -U0 | 非#行 | grep -c .` = 0）
- 验收复核：`grep -c 'task-v164'`→1/1；`grep -nE '互顶全局|全局 legacy'`→rc=1 空；`bash -n` 双脚本 rc=0；`git diff --stat`→仅 zcode-userpromptsubmit.sh(+5/-1)+zcode-posttooluse.sh(+6/-2)（`.dispatch-inflight`/`7-prompt-material.md` 为派发期既有，非本次产生）
- 负结果报告：仅改清单内两脚本注释区；未动其他 26 个引用面文件、未动任何代码行；未执行 git add/commit/checkout/reset

#### [sub:8-executor] S8 pretooluse+init.cjs 注释改述
- 事实（命令→关键输出）：基线 `grep -nE '互顶|全局 legacy' zcode-pretooluse.sh task-plan-init.cjs` = 2 hits（pretooluse.sh:73、task-plan-init.cjs:122）；改述后 = 0（rc=1 空集）；`grep -c 'task-v164'` 两文件各=1（改述前各 0）
- 改述锚：zcode-pretooluse.sh:73（原「不再被互顶的全局指针误拦」→「不再被并发覆写的全局层误拦」+ `[2026-10-10 task-v164]` 三点块：plans/.active_plan 现为工作树内瞬态 fallback（路径随 $PWD 本地化；git rm --cached+.gitignore 同族瞬态，非入库单例）；正常路径=side 会话私有指针（权威层）；退役旧"单例全局指针"框架）。task-plan-init.cjs:122-124（原「不读全局 legacy」「全局指针恒有效」「置全局指针」→ 三处改「全局 fallback」+ `[2026-10-10 task-v164]` 三点块，退役原"全局单例指针"叙事）。注记仿 S5/S6/S7 用「原措辞"并发翻转全局指针误拦"/"全局单例指针"」避开字面「互顶」「全局 legacy」连写，防 grep 误伤（保留原措辞说明与验收清零兼得）
- 保留纪律核验：.sh 仅增 `#` 行（历史勘误注释 [2026-09-10 active-plan-race] 逐字保留未删），`git diff -U0 | 非#行 | grep -c .` = 0；.cjs 9 条变更行全为 `//` 注释（`grep -vE '^[+-][[:space:]]*//' | grep -c .` = 0），JS 逻辑/字符串字面量/usage 零改动
- 验收复核：`grep -c 'task-v164'`→1/1；`grep -nE '互顶|全局 legacy'`→rc=1 空；`bash -n zcode-pretooluse.sh` rc=0；`node --check task-plan-init.cjs` rc=0；`git diff --stat`→仅 zcode-pretooluse.sh(+4/-1)+task-plan-init.cjs(+6/-3)（`.dispatch-inflight`/`8-prompt-material.md` 为派发期既有，非本次产生）
- 负结果报告：仅改清单内两文件注释区；未动其他引用面文件、未动任何代码行/字符串字面量；未执行 git add/commit/checkout/reset

#### [sub:9-executor] S9 init-session+plan-created 注释改述
- 事实（命令→关键输出）：基线 `grep -nE '全局 legacy|legacy 全局指针' init-session.sh plan-created.cjs` = 3 hits（init-session.sh:719/720/727）；改述后 = 0（rc=1 空集）；`grep -c 'task-v164'` init-session.sh=2 / plan-created.cjs=1（改述前各 0）
- 改述锚：init-session.sh:719（原「不碰全局 legacy」→「不碰全局 fallback 指针」）；:720（原「写全局 legacy」→「写全局 fallback 指针」）；:721-723 新增 `[2026-10-10 task-v164]` 三点块（原措辞以「legacy」描述全局层；实为工作树内瞬态兜底：路径随 $PWD 本地化 + git rm --cached+.gitignore 与 .active_plan_side/ 同族瞬态；正常路径=side 会话私有指针权威层；退役「legacy/移交」旧叙事）；:727（原「legacy 全局指针」→「全局 fallback 指针」）；:729 新增 `[2026-10-10 task-v164]` 补注行。plan-created.cjs:134（原「③ legacy plans/.active_plan 指针」→「③ 全局 fallback plans/.active_plan 指针」）；:135-136 新增 `[2026-10-10 task-v164]` 三点块
- 保留纪律核验：2026-09-10 active-plan-race / 2026-09-16 task-v074 P10 历史勘误段逐字保留未删，仅改述旧语义词+追加 `[task-v164]` 注记；注记仿 S5/S6 用「原措辞以「legacy」描述/框定该层」避开字面「全局 legacy」/「legacy 全局指针」连写（防 grep 误伤，A3=0 与保留原措辞说明兼得）；usage/解析链/`set -u` 之后代码零改动
- 验收复核：`grep -c 'task-v164'`→2/1；`grep -nE '全局 legacy|legacy 全局指针'`→rc=1 空；`bash -n init-session.sh` rc=0；`node --check plan-created.cjs` rc=0；`.sh git diff -U0 | 非#行 | grep -c .` = 0；`.cjs git diff | 非//行 | grep -c .` = 0；`git diff --stat`→仅 init-session.sh(+7/-3)+plan-created.cjs(+3/-1)（`.dispatch-inflight` 为派发期既有 M，非本次产生）
- 边界事实（登记不改，S4 清单仅列 :134）：plan-created.cjs:151 注释「②③ 会话指针 → legacy 指针」亦含「legacy」修饰全局层语义，但不在 S4 清单（:134）内且不命中验收 grep 模式 → 本 S-unit 未改（禁扩范围）
- 负结果报告：仅改清单内两文件注释区（.sh 4 处、.cjs 1 处目标 + 各新增注记行）；未动其他 26 个引用面文件、未动任何代码行/字符串字面量/usage；未执行 git add/commit/checkout/reset

#### [sub:9b-executor] plan-created 残留清零
- 事实（命令→关键输出）：改前 `grep -n 'legacy 指针' plan-created.cjs` 命中 2 行（:153 注释「②③ 会话指针 → legacy 指针」、:174 label `'legacy 指针 .active_plan'`）；改后 `grep -n 'legacy 指针'` = rc=1 空集；`grep -n 'legacy'` 剩余仅 :11/:16（哨兵迁移史）+ :135-136（S4 [task-v164] 注记引文）+ :222-223/:238/:240/:302（legacy 哨兵）——指针层语义=0
- 改述锚：plan-created.cjs:153（原「②③ 会话指针 → legacy 指针」→「②③ 会话指针 → 全局 fallback 指针」）；:154 新增 `[2026-10-10 task-v164]` 注记行（原措辞说明：本层旧称已改述为「全局 fallback 指针」，同上方 ③ 层口径）；:175（原 label `'legacy 指针 .active_plan'` → `'全局 fallback 指针 .active_plan'`；display label 仅此一处字符串，无 selftest/脚本耦合该字面）
- 验收复核：`node --check plan-created.cjs` rc=0；`grep -c 'task-v164'` = 2（:135 + :154）；本 S9b 增量 `git diff` = 1 注释行(:153) + 1 字符串行(:175) + 1 注记行(:154)（同文件另含 S4 既有未提交改动 :134/:135-136，非本 S-unit 产生）
- 注记行刻意不写裸字「legacy」（用「本层旧称」指代），使 `grep -n 'legacy'` 与 material 验收清单逐行一致；禁改范围外 0 行、未动其他文件、未执行 git 写操作
- 负结果报告：仅改 plan-created.cjs 上述 3 行；未动该文件任何代码/其他字符串；未触碰其他引用面文件

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| D1（采纳）：`plans/.active_plan` untracked+gitignore，头注释语义改述为"工作树内瞬态 fallback"，退役"移交"叙事 | 直接兑现 R1/R3/R4；与 .gitignore:1-10 兄弟范式一致；合并零冲突；git churn 止于本提交；改动面最小（索引态+1 行 ignore+注释+措辞） |
| D2（不取）：保留跟踪+约定"合并时忽略" | 仍产生 status dirty 与 chore 提交机会；违反"运行态文件不入库"一贯范式；R4 用户明示忽略该文件——约定式忽略=每次靠人记，机械化失效 |
| D3（否决）：删除全局指针文件只留 side+mtime | 破坏 cron/sid-less legacy 消费者（set-active-plan.sh:3 注释明示兼容旧调用方）；side TTL 24h 过期后无全局锚点；解析链语义冻结条款下改动面大于收益 |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| 写 task_plan.md 触发 conflict hook 报与 task-v146 疑似冲突 | 查证=INDEX:101 v146 陈旧行（pending vs 实际 COMPLETE）致误报；本任务文件在全新自有目录无真实冲突；登记 F 节待后续清理，不阻塞 |
| v163 计划 task_plan.md 仍是 init 模板未填写（该会话被本反馈打断于撰写中） | v164 不接管 v163 内容（Rule 8.1 D 类分立）；v163 续写由其后端会话完成；INDEX 条目遵循 v163 先例=执行期再登记 |

## Resources
<!-- 有用的 URL/文件/路径,发现即记 -->
- 机制脚本：`skills/task-planner/scripts/set-active-plan.sh`、`skills/task-planner/scripts/resolve-plan-dir.sh`
- 先例计划：`plans/fix-pointer-race-20261007/`
- ignore 范式：仓根 `.gitignore:1-10`
- selftest 守护：`skills/task-planner/scripts/selftest-active-plan.sh`、`selftest-pointer-lifecycle.sh`
- worktree SOP：`skills/task-planner/references/worktree-isolation.md`

## Visual/Browser Findings
（本任务暂无多模态发现——未产生截图/PDF/网页证据）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
