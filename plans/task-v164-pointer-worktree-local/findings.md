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
