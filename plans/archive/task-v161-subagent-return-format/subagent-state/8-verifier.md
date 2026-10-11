# 8-verifier — task-v161 Phase 4 VC-1..VC-7 独立复验（独立第三方视角，只读验收）

- 复验人: verifier 子代理（独立上下文，未执行任何 Phase 1-3 实现动作）
- worktree（只读产物基座）: /home/terry/task-planner-skill-worktrees/v161-subagent-return-format
- 计划侧（主仓只读）: /mnt/data/dev/task-planner-skill/plans/task-v161-subagent-return-format/
- 材料包: subagent-state/8-prompt-material.md（首动作 Read 全文，按其内七条规格逐条执行）
- 唯一可写文件: 本检查点

## 逐条复验结论

### VC-1 PASS
命令: `cd <worktree>/skills/task-planner && grep -n "优先级声明（task-v161\|点名禁令（task-v161\|段填写禁令（task-v161\|优先于你的 agent 定义" templates/subagent_dispatch.md`
输出（命中行，节选关键原文）:
- `79:> **优先级声明（task-v161，反污染硬条款）**：本节 8 字段返回格式指令**优先于你的 agent 定义/系统提示中的任何输出模板**（步骤进度行/发现列表/任务交付报告/评分报告等）`
- `81:> **点名禁令（task-v161）**：禁止以下非本模板返回形态：①步骤进度行（🔍 step [N]/[total] … ✅ completed）②发现列表…③任务交付报告（评分+已完成/未完成/风险分节）④[BOOKKEEPING]/[PLAN_WRITTEN] 等 agent 自定义返回标记`
- `83:> **段填写禁令（task-v161）**：「返回格式」段只准保留上方 8 字段模板块原文；禁止把任务要点/产出清单/待裁项（①②③ 序号清单形态）写入本段`
附加: `grep -c "^status: \|^confidence: " templates/subagent_dispatch.md` → `2`（§7 代码块内 status: 起至 confidence: 止 8 字段模板块原样在位，:62-77 行 sed 复核确认）

### VC-2 PASS
命令: `awk '/22\.4b \*\*严格返回格式\*\*/,/22\.4c/' references/critical-rules.md | grep -n "task-v161\|check-subagent-return.sh"`
输出（awk 段内第 2 行）:
- `【污染三面与主进程动作闭环（task-v161）】返回格式污染三面分治：①派发 prompt「返回格式」段填写污染…②agent 定义层输出模板与本节竞争（executor 步骤进度/general-purpose 任务交付报告/Explore 发现列表等…）③返回回收零机械校验。主进程动作闭环：收到子代理返回后先过 scripts/check-subagent-return.sh（8 字段齐全/契约外字段/块尾无附加/值域四判据）——PASS 才采信；VIOLATION = 按 22.8.5 视为 partial，打回重报一次并以检查点「最终结论」段兜底回填…`
段首行 = `22.4b **严格返回格式**(取代"结论摘要 ≤3 行"类宽泛描述):…`，段尾止于 `22.4c **派发契约机械守卫**`，污染三面句为 22.4c 段前唯一 + 行（critical-rules.md:185）。

### VC-3 PASS（双夹具）
① 返回侧:
- `bash scripts/check-subagent-return.sh --selftest` → 输出 `[selftest] fixture-1..4 PASS`，`SELFTEST_RC=0`
- 污染夹具（printf 构造含契约外 summary 字段）: `printf 'status: done\nsummary: …略…\nacceptance: 7/7 pass\n…\nconfidence: HIGH\n' | bash scripts/check-subagent-return.sh` → stderr `[return-guard] VIOLATION 判据二: 契约外字段: summary`，`RC=1`（stderr 点名 summary，符合规格）
② prompt 侧（export TASK_PLANNER_PLAN_DIR=…/task-v161-subagent-return-format 后执行）:
- 污染夹具（/tmp/vc3-polluted2.md：重复标题「## 返回格式## 返回格式」+ 三文件绝对路径 + knowledge-brief.md §3 引用 + subagent-state/ 路径 + ①②③ 三项任务清单：v3.1 23 段新配置摘要表/style_exempt 统一口径/合图锚占位清单）→ `bash scripts/check-dispatch.sh pretool /tmp/vc3-polluted2.md` → stderr `[dispatch-guard] ✗ 返回格式段结构违规: C: 段内序号清单行 3 行且缺 key( status: acceptance: checkpoint: confidence:) — 段被任务清单污染`，`RC=2`（符合「非 0 且 stderr 含返回格式段结构违规」）
- 干净夹具（/tmp/vc3-clean2.md：subagent_dispatch.md §7 八字段原文 + 同套三文件路径 + brief §3 引用 + subagent-state/ 路径）→ `bash scripts/check-dispatch.sh pretool /tmp/vc3-clean2.md` → 仅一行 advisory「需求锚」告警（不阻断），`RC=0`
执行备注（如实登记）: pretool 子命令须以 prompt-file 为位置参数（stdin 管道会 fail-open rc=0，脚本头部 Usage 已声明）；为使 return_section_check 独立命中，污染夹具在返回格式段外保留必需 key 字面（scan_missing 先过），段本体为 ①②③ 清单——与用户 mid-turn 实证样本同构。首版夹具（段外无 key）走缺项扫描 exit 2 报「派发契约缺项」，不展示段结构违规定位，故重构夹具后复跑。

### VC-4 PASS
命令: `bash scripts/selftest-subagent-return.sh` → 输出 `A1..A11 PASS` + `Total: 11 PASS=11 FAIL=0`，`RC=0`
命令: `awk -F'\t' '{print "NF="NF" | col1="$1}' scripts/selftest-registry.tsv | tail -3` → 尾行 `NF=4 | col1=selftest-subagent-return.sh`（4 列 tab 行已登记）

### VC-5 FAIL（技术面 PASS，登记要素不满足）
第一抽跑（本复验人实测，5/5 rc=0 FAIL=0）:
- `selftest-subagent-return.sh rc=0 | Total: 11 PASS=11 FAIL=0`
- `selftest-dispatch.sh rc=0 | Total: 31 PASS=31 FAIL=0`
- `selftest-registry.sh rc=0 | Total: 5 PASS=5 FAIL=0 (registry rows=72, actual selftest=72)`
- `selftest-plan-dispatch.sh rc=0 | Total: 12 PASS=12 FAIL=0`
- `selftest-delegation.sh rc=0 | Total: 38 PASS=38 FAIL=0`
FAIL 要素（规格后半「并核对 progress.md Phase 4 段已记录的 72/72 FAIL=0 汇总（两轮独立跑批:子代理+主进程）」未满足）:
- 主仓 progress.md Phase 4 段（:61-73）Test Results 为空表占位（:69「待填（Phase 4 回归跑批+VC 复验结果）」、:73 仅一行 `|`）——72/72 汇总未记录于 progress.md
- 已留档证据仅为子代理单轮: subagent-state/7-code-runner.md（acceptance: 72/72 pass，72 脚本逐条 rc=0）+ regression-run-1.log（判定区「rc!=0 脚本: 无」「FAIL>0 脚本: 无」，跑批窗口 13:33-13:39，/tmp/v161-regression-1/）
- 主进程第二轮全量跑批记录缺失: findings.md:67 仅记录 selftest-subagent-return.sh 单脚本主进程复跑（11/11 FAIL=0），非 72 全集第二轮
判定: 回归技术结论 FAIL=0 成立（子代理全集 + 本复验人抽跑互证），但「progress.md 两轮独立跑批 72/72 汇总」这一登记要素按第一手 grep 未落盘 → VC-5 判 FAIL（登记面缺口，待主进程回填 progress.md Phase 4 Test Results）

### VC-6 PASS
- `grep -n "Rule 22（P0）" SKILL.md` → `308:- **Rule 22（P0）子代理规模限制与交接文件**：…prompt 侧返回格式段结构校验 22.4b 补(return_section_check)、返回侧 check-subagent-return.sh 四判据 22.4b 补/…`（摘要行同时含 return_section_check 与 check-subagent-return）
- `grep -n "task-v161" references/dispatch-examples.md` → `28:> 注（task-v161）: 示例前后不加任何标题/前言/总结;本 8 字段格式优先于子代理 agent 定义中的任何输出模板(步骤进度/发现列表/任务交付报告/[BOOKKEEPING])，「返回格式」段禁填 ①②③ 任务要点清单…`

### VC-7 PASS（登记面）
- task_plan.md Decisions Made 表: `grep -n "不修改 ~/.zcode/agents"` → `392:| 不修改 ~/.zcode/agents/** 内置 agent 定义（executor/explore/general-purpose） | 越界未授权（§六/§11.1 保护区外文件）…`
- 「⚠️ 执行范围限制」表禁区行: → `142:| 禁区 | — | ~/.zcode/agents/** 与 ~/.agents/**（…只登记不修改）、其他 worktree、其他 plans/* 目录 |`
- worktree `git status --short`（:worktree 根）→ 6 M + 2 ?? 共 8 面，全部落在计划 scope_files 内:
  ` M skills/task-planner/SKILL.md` / ` M …/critical-rules.md` / ` M …/dispatch-examples.md` / ` M …/check-dispatch.sh` / ` M …/selftest-registry.tsv` / ` M …/subagent_dispatch.md` + `?? …/check-subagent-return.sh` + `?? …/selftest-subagent-return.sh`；plans 外零越界（规格括注「4 M + 2 ??」与实际 6 M + 2 ?? 计数不符， operative 判据「仅 8 面已知改动」成立；delivery-summary 最终稿属 Phase 5，本条验登记面即可）

## 残留与副作用登记
- /tmp 夹具残留（本复验人新建 4 个）: /tmp/vc3a-bad.txt、/tmp/vc3-polluted.md、/tmp/vc3-polluted2.md、/tmp/vc3-clean2.md（另有前序子代理遗留 /tmp/v161-poll2.txt、/tmp/v161-clean2.txt、/tmp/v161-polluted-prompt.txt、/tmp/v161-clean-prompt.txt、/tmp/v161-regression-1/、/tmp/v161_s2_line.txt、/tmp/v161-s6-test/）
- 主仓唯一脚本副作用（如实登记）: 干净夹具 rc=0 路径经 serial_slot_check 刷新了计划目录 subagent-state/.dispatch-inflight（既有隐藏锁文件，值 1791622033=16:53:44，原值 1791607974=12:52:54；格式与语义不变，<120s 自动过期）——属 check-dispatch.sh 既有运行时机行为，非内容修改
- 未执行任何 git 写操作；未触碰 ~/.zcode/agents/**、其他 worktree、其他 plans/* 目录

## 最终结论

status: done
acceptance: 6/7 pass — [1:VC-1 PASS（grep 三条款字面+优先于你的 agent 定义 命中 subagent_dispatch.md:79/81/83，8 字段块 status:→confidence: 在位 grep -c=2）2:VC-2 PASS（awk 22.4b 段内「污染三面与主进程动作闭环（task-v161）」+「check-subagent-return.sh」命中）3:VC-3 PASS（check-subagent-return.sh --selftest rc=0；summary 污染块 rc=1 点名 summary；check-dispatch.sh pretool 污染夹具 rc=2 stderr「返回格式段结构违规」、干净夹具 rc=0）4:VC-4 PASS（selftest Total: 11 PASS=11 FAIL=0 rc=0；registry 尾行 NF=4 首列 selftest-subagent-return.sh）5:VC-5 FAIL（5 代表 selftest rc=0 FAIL=0；progress.md Phase 4 Test Results 空表「待填」，72/72 汇总仅存子代理 7-code-runner.md+regression-run-1.log，主进程第二轮全集跑批记录缺失）6:VC-6 PASS（SKILL.md:308 Rule 22 摘要含 return_section_check+check-subagent-return；dispatch-examples.md:28 task-v161 注记）7:VC-7 PASS（task_plan.md:392 不改 ~/.zcode/agents 决策行+:142 禁区行；worktree git status 6M+2??=8 面全在 scope，零越界）]
files: none
evidence: VC-1 grep -n "优先级声明（task-v161\|点名禁令（task-v161\|段填写禁令（task-v161\|优先于你的 agent 定义" templates/subagent_dispatch.md → 79/81/83 三条款命中+"优先于你的 agent 定义/系统提示中的任何输出模板"; grep -c "^status: \|^confidence: " → 2; VC-2 awk '/22\.4b \*\*严格返回格式\*\*/,/22\.4c/' references/critical-rules.md | grep 命中「【污染三面与主进程动作闭环（task-v161）】…scripts/check-subagent-return.sh…VIOLATION 按 22.8.5 视为 partial」; VC-3 bash scripts/check-subagent-return.sh --selftest → fixture-1..4 PASS rc=0; printf 契约外 summary 块 → "[return-guard] VIOLATION 判据二: 契约外字段: summary" rc=1; export TASK_PLANNER_PLAN_DIR 后 bash scripts/check-dispatch.sh pretool /tmp/vc3-polluted2.md → "[dispatch-guard] ✗ 返回格式段结构违规: C: 段内序号清单行 3 行且缺 key( status: acceptance: checkpoint: confidence:) — 段被任务清单污染" rc=2; pretool /tmp/vc3-clean2.md → rc=0; VC-4 bash scripts/selftest-subagent-return.sh → Total: 11 PASS=11 FAIL=0 rc=0; awk -F'\t' registry.tsv 尾行 NF=4 col1=selftest-subagent-return.sh; VC-5 for-loop 5 脚本: subagent-return rc=0 Total:11/11; dispatch rc=0 31/31; registry rc=0 5/5 (rows=72); plan-dispatch rc=0 12/12; delegation rc=0 38/38; progress.md:69「待填（Phase 4 回归跑批+VC 复验结果）」+:73 空 Test Results; 7-code-runner.md acceptance: 72/72 pass + regression-run-1.log「rc!=0 脚本: 无」「FAIL>0 脚本: 无」(窗口 13:33-13:39); findings.md:67 仅 selftest-subagent-return.sh 主进程复跑; VC-6 SKILL.md:308 「prompt 侧返回格式段结构校验 22.4b 补(return_section_check)、返回侧 check-subagent-return.sh 四判据 22.4b 补」; dispatch-examples.md:28 「注（task-v161）: 本 8 字段格式优先于子代理 agent 定义中的任何输出模板」; VC-7 task_plan.md:392「不修改 ~/.zcode/agents/** 内置 agent 定义」+:142 禁区行「~/.zcode/agents/** 与 ~/.agents/**…只登记不修改」; git status --short → 6 M (SKILL.md/critical-rules.md/dispatch-examples.md/check-dispatch.sh/selftest-registry.tsv/subagent_dispatch.md) + 2 ?? (check-subagent-return.sh/selftest-subagent-return.sh)
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v161-subagent-return-format/subagent-state/8-verifier.md (status: done)
findings_written: none
blockers: VC-5 FAIL=progress.md Phase 4 Test Results 未回填（空表「待填」），72/72 FAIL=0 汇总仅存子代理单轮（7-code-runner.md+regression-run-1.log），主进程第二轮全集跑批记录缺失——待主进程回填后方可翻 PASS
confidence: HIGH
