# S2 脚本验证基线与簿记脚本审计（2026-10-15）

> 子代理：code-runner-agent（S2）；任务 task-v176；主仓 /mnt/data/dev/task-planner-skill；HEAD=4287b7a
> 标尺：回归（selftest）是否真实可信、簿记脚本是否如实反映状态。所有数字/结论以实测命令输出为准。

## selftest 基线

- 入口：`bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/run-selftests.sh --fresh`
  （官方统一入口；--fresh 忽略指纹缓存全量重跑；cwd=plans/task-v176；日志 /tmp/task-v176-selftest-baseline.log）
- 脚本总数/PASS/FAIL：**80 / 77 / 3**（尾行 `Total: 80 PASS=77 FAIL=3 (run=80 reused=0)`；入口 exit=1）
- FAIL 明细（3 个，独立复测真实 rc=1×3）：
  1. `selftest-registry` — `T02 FAIL 未登记: selftest-input-consistency.sh`（registry rows=79, actual selftest=80）
  2. `selftest-self-resolution` — `SR-12 FAIL registry 漂移（selftest-self-resolution 命中 2 应 ≥1 / 总行数 80 应 81=脚本数+表头）`
  3. `selftest-summary-readability` — `SRV-11 FAIL: registry 登记(got 1 expect>=1)` + `SRV-12 FAIL: 9 级联脚本(pass=8 fail=1)`
- 共同根因（单点故障→3 连红）：`selftest-input-consistency.sh`（commit ddf6ede `feat(task-v175): Rule 85 用户输入一致性纪律 — 反投毒`，文件时间戳 10-15 01:07）**未登记进 selftest-registry.tsv**（grep NOT FOUND；数据行 79 vs 实际脚本 80）。registry 守护（selftest-registry.sh T02）报警正确；该 occurrences 说明 task-v175 提交时全量回归要么未跑、要么带红入库。
- 跳过/超时：**无**。80/80 全部执行完成，无单脚本 >120s（入口全量完成远小于预算），日志无 [TRUNCATED]。
- 可信度附注：首轮复跑 FAIL 脚本时 `RC=0` 系管道 `| tail` 退出码误读；改用独立重定向复测确认真实 rc=1×3。跑完基线后 `git status` 仅剩本检查点目录未跟踪 → selftest 未污染工作树，基线可复现。
- 复现命令：`bash skills/task-planner/scripts/run-selftests.sh --fresh`；单脚本：`bash skills/task-planner/scripts/selftest-<name>.sh`。

## 脚本缺陷清单（10 条，前 6 条为高置信实证）

- **缺陷1（高）**：sync-todos write_index 状态计数用 contains 匹配（无词界/无行首锚），括号注记含 "complete" 一词即把 in_progress 计为 complete
  - 证据：`skills/task-planner/scripts/sync-todos.sh:238`（`if (line ~ /[Ss]tatus:\*\*/)` 任意位置子串）；`:243-245`（`if (s ~ /complete/) comp++ else if (s ~ /in_progress/)...`，先 gsub 去 `**` 与空白后 contains 判定）
  - 实证：fixture task-A 的 Phase2 为 `- **Status:** in_progress（前一轮 complete 判定已撤回）` → INDEX.md 输出 `| task-A | complete | 2/2 | ... | ✓ |`、`- task-A ✓ (2/2)`、汇总 `complete: 1`
  - 失真场景：状态行带历史注记（"complete 判定撤回/曾标 complete"等）时，INDEX 把**进行中任务记录为已完成**并入"已完成"区；恢复流程据此跳过该任务。回归盲区：selftest-sync-index.sh T07 只测「注记不含状态词」（夹具 `in_progress（2026-09-27, note）`），此形态无断言。

- **缺陷2（高）**：sync-todos 两个入口（forward_sync / write_index）状态判定口径不一致 + Status 行无 Phase 归属
  - 证据：`sync-todos.sh:93-99`（forward_sync：先 `sub(/[（(].*$/, "", status)` 剥括号再前缀匹配 `status ~ /^in_progress/`）vs `:238-246`（write_index：保留注记、contains 匹配）；`:237-246` 计数与 `### Phase` 标题无绑定状态机——文件中任意含 `…status:**` 的行（Sub-status、表格单元格、正文引用）均参与 comp/inp/pend 计数
  - 失真场景：同一 task_plan.md 在 `sync-todos.sh`（报告）与 `sync-todos.sh --index`（INDEX）两个入口产出不同状态判定；游离 Status 行（如"整体状态"行）污染逐 Phase 计数，进而翻转 complete/in_progress 结论。

- **缺陷3（高）**：archive-plan Status 门 total/ok 计数口径不对称（列表锚 vs 全文子串），双向失真（假 PASS + 假 FAIL），实证
  - 证据：`skills/task-planner/scripts/archive-plan.sh:113-114`：`total=grep -cE '^[[:space:]]*[-*][[:space:]]+\*\*Status:\*\*'`（行首列表符锚定）vs `ok=grep -c 'Status:\*\* complete'`（无锚、全文字串行计数）；判据 `:119 [ "$total" != "$ok" ] → status-incomplete`
  - 实证（假 PASS）：fixture task-F = `- **Status:** in_progress`（唯一列表行）+ 一行无列表符 `**Status:** complete（样例行）` → total=1, ok=1 → 输出 `SKIP task-F (candidate/none)`（将归档一个 in_progress 任务）
  - 实证（假 FAIL）：fixture task-G = 2 个列表行全 complete + 正文引用行「完成态格式为 **Status:** complete」→ total=2, ok=3 → `status-incomplete`（**拒绝归档真正完成的任务**；且 check-complete 对同一文件判 `2/2 phases (complete)`——两工具相反结论）
  - 失真场景：判据实际语义= "子串出现行数恰等于列表行数"，而非"全部 Status 行均 complete"。任何正文引用/样例文字使计数漂移：补数可假放行（低计非 complete 行），多计可假拒绝（真完成被拒且原因显示为 status-incomplete）。

- **缺陷4（高）**：archive-plan 不校验 Phase 覆盖——无 Status 行的 Phase 被整体忽略，实证
  - 证据：`archive-plan.sh:109-121` 仅对"存在的 Status 行"做全 complete 判定（`total<1` 才 fail-closed 拒绝），没有任何"Phase 标题数 vs Status 行数"对照（对比 check-complete.sh:181/207-213 按 `### Phase` 提取条目）
  - 实证：fixture task-C（Phase2 无 Status 行）→ total=1=ok → `SKIP task-C (candidate/none)`（将归档"含未登记 Phase"的任务）
  - 失真场景：计划中途追加 Phase 忘写 Status 行 → 归档器无感放行；同文件 check-complete 判 in_progress（拦）→ 归档器与终验门判定分裂。

- **缺陷5（高）**：check-complete「No phases found」→ exit 0，全部门链静默跳过，实证
  - 证据：`skills/task-planner/scripts/check-complete.sh:181`（Phase 标题正则 `^###\s+Phase\s`——二级标题 `## Phase N:`、`### Phase1:` 等格式不匹配）+ `:310-312`（`if total == 0 and not block_statuses: print "No phases found"; sys.exit(0)`）；`:329` 3-File Gate 的 active 判据同为 total>0
  - 实证：fixture task-E（`## Phase 1:` 二级标题）→ 输出 `[plan] No phases found in task_plan.md.` + 一系列 SKIPPED/WARNING + **exit 0**（CC_RC=0）
  - 失真场景：Phase 标题格式轻微漂移 → 完成性判定全部失效（3-File/Batch/complete 判定全跳），exit 0 被 Stop hook/簿记抄作"终验通过"；唯一线索是 stdout 一行 "No phases found"。

- **缺陷6（高）**：check-complete CR-GATE 的 diff 范围限于 plan 目录，仓内代码变更不可见；且 SKIPPED 与 PASS 并存输出
  - 证据：`check-complete.sh:1199-1206`（`git -C "$PLAN_DIR_GUESS" diff "$CR_BASE_REF" --name-only -- .`——`-C` 把工作目录切到 `plans/<task-id>/`，pathspec `.` 仅覆盖计划目录子树；`cr_nfiles` 数代码扩展名、`cr_tlines` 数全部行数）；`:1215`（PASS 行无条件 printf）
  - 实证（diff 范围）：/tmp git 仓内 `git -C plans/task-X diff HEAD --name-only -- .` 只输出 `plans/task-X/task_plan.md`；对照全仓 diff 含 `src/code.py`。真实 plan 目录仅 md 文件 → `cr_nfiles`（代码文件>3 信号）恒 0 不可达；`cr_tlines` 实际统计 plan 目录 md 行数却出现在"代码文件=%s, diff 合计=%s 行"文案中
  - 实证（输出面）：fixture task-E 同屏输出 `[CR-GATE] SKIPPED（非 git 目录无 diff 面…）` 与 `[CR-GATE] PASS（无风险信号命中/已豁免…）`——"跳过"与"通过"混杂，审计不可区分
  - 失真场景：任务改动大量代码文件而 plan 目录 diff 小 → CR-GATE PASS（真实变更未被检查）；大计划 md 行数 >50 → 假"风险信号"要求 CR APPROVED 否则 exit 1。

- **缺陷7（中）**：check-complete DELEGATION GATE 文案与真实判定不符（豁免放行仍打印 "rate >= floor"）
  - 证据：`check-complete.sh:464-474`（whitelist 豁免置 rate_ok=1 后打 WHITELIST-EXEMPT 行）与 `:492`（无条件模板句 `PASSED (rate=%s >= floor=%s, ...)`）
  - 实证：fixture task-E 输出 `[plan] DELEGATION GATE PASSED (rate=0.000 >= floor=0.7, violations=0)`（"0.000 >= 0.7"为假命题；上一行 WHITELIST-EXEMPT 描述正确）
  - 失真场景：簿记只抄 PASSED 行 → 记录为"委派率达标"而实际是白名单豁免放行（rate 远低于 floor）。

- **缺陷8（中）**：check-complete L0 GATE ③ 单 commit 校验口径与注释不符 + 任意位置字样豁免
  - 证据：`check-complete.sh:1613`（`git -C "$repo_root" log --oneline --grep='feat\|fix' --since='30 days ago'`——无 pathspec=全仓 30 天计数；`--grep` 子串命中 "feature/prefix/hotfix" 等）；`:1614-1618`（计数≠1 时全文 `grep -qE '单[[:space:]]*commit|单commit' "$PLAN_FILE"` 命中即豁免）
  - 失真场景：注释声称"对计划 scope 数 feat|fix 提交"（:1607-1609），实现是全仓窗口计数——活跃仓库恒 ≠1 → 门③实质退化为"文档任意位置搜到'单 commit'字样即过"，commit 惯性验证≈0；且计划正文引用"单 commit"条款字样也可解锁。

- **缺陷9（中）**：Status 行格式跨脚本口径分裂（三工具三结论），实证
  - 证据：三处解析器：`sync-todos.sh:238`（`[Ss]tatus:\*\*` 任意位置）／`archive-plan.sh:113`（`^[[:space:]]*[-*][[:space:]]+\*\*Status:\*\*`，接受 `-` 与 `*`）／`check-complete.sh:189`（strip 后 `startswith("- **Status:**")`，仅 `- ` 前缀）
  - 实证：fixture task-H（`* **Status:** complete`）→ sync-todos=`complete 1/1 ✓`；archive-plan=`candidate/none`（满足归档）；check-complete=`Segment 0: 0/1 phases (pending)`。同一文件：一个说已完成、一个说可归档、一个说未完成
  - 失真场景：状态行轻微变体（星号列表符/缩进差异）→ INDEX / 归档器 / 终验门互相矛盾，下游流程取哪个工具就得哪个"事实"。

- **缺陷10（中，系统性）**：假 PASS/fail-open 面缺乏可观测性（多处静默跳过 + 默认 warn 面）
  - 证据：`check-complete.sh:574`（`elif [ -f "$cpl" ]; then ...; fi` 无 else——check-plan-dispatch.sh 缺失时零输出静默跳过）；`:662-663`（RESCUE-CHAIN `if [ -f "$crc" ]` 无 else）；`:1269-1270`（LEARNING-GATE 无 Error Log 表头列时零输出，与"PASS 静默"不可区分）；DRIFT-GATE(:515-525)/COMPLIANCE(:1515-1516)/report-lint(:1152)/judge-gate(:1643-1648)/AUTO-TIER(:1450-1454) 默认档永不改 exit 码
  - 失真场景：check-complete exit 0 被簿记抄作"全部门通过"，实际含 N 个静默未运行门 + warn 未达标门；审计无法从输出区分"验证通过"与"验证未运行"。

### 任务书三专问的直答

1. **sync-todos（状态从哪来/会不会把已完成写成 in_progress）**：状态=从 task_plan.md 的 `- **Status:**` 行内联 awk 解析（write_index，全量重算），不读 progress/session-log。"完成→in_progress"通道存在：complete 优先判定需 `total>0 && comp==total`（:276），任一 Phase 状态词未被识别（如值写 "done"/中文，或 `Status:` 丢失 `**`）→ comp 缺计 → `comp>0` 掉入 in_progress 分支（:279-281，标"中断恢复首选"）；total 高估（标题重复）同样促发。反向（进行中→complete）通道已实证（缺陷1）。
2. **archive-plan 三拒绝 checker**：active 指针（:92-100）与 .session-owner TTL（:102-108）检查本体未见缺陷（写入方 set-active-plan.sh:120 受控无空白污染）；**Status 全 complete 检查不健全**——口径不对称（缺陷3，假 PASS+假 FAIL 均实证）且不校验 Phase 覆盖（缺陷4，实证）。
3. **check-complete 覆盖与假 PASS 通道**：SESSION-LOG GATE（:1154-1189，env-only，默认 warn，存量计划无指针区块即 SKIP 放行）、ARCHIVE-GATE（:1685-1747，warn-only 提醒、仅 plans 根可解析时运行；附注 `[ARCHIVE-GATE]` 行输出到 **stdout**（:1742/:1744 无 `>&2`）与其余门 stderr 惯例不一致）、VC-GATE（:672-848，默认 warn、可 enforce；mini 降档；L0 薄化）——**三门均已覆盖**。"报告 PASS 但未真正执行验证"的通道：① No phases found→exit 0（缺陷5 实证）；② CR-GATE 跳过/PASS 并存 + 字串豁免（缺陷6/直引 :1198 `grep -qE 'CR APPROVED|审查 APPROVED'` 命中即跳过风险分析）；③ DELEGATION 豁免文案（缺陷7）；④ L0 ③ 字样豁免（缺陷8）；⑤ 多处静默 fail-open（缺陷10）；⑥ 默认全 warn 面（exit 0 ≠ 这些面验证通过）。

## 负结果报告（检查了但未发现问题/排除项）

- 已查未见缺陷：run-selftests.sh 入口自身（缓存指纹 `reused=0` 全量重跑、[FAIL] 忠实转记 rc、无递归——自身排除逻辑 :116 有效）。
- 已排除：selftest 全集运行对工作树零污染（跑后 `git status --short` 仅剩本检查点目录；HEAD 未变 4287b7a）。
- 已排除（低风险观察项，不列为缺陷）：pointer-lifecycle 提醒段（:1679 用 `tr -d ' \r\n\t'` strip）与 ARCHIVE-GATE 读取指针（:1723 不 strip）读取口径不同——因写入方受控当前无分歧，仅在未来写入方变更时才有风险。
- 未穷尽（时间盒）：check-complete 未逐门运行时打桩验证（如 R-COVERAGE L0 抽查段、CR-GATE enforce 全链）；VC-GATE 的 `vcgate_count_substantive` 单点防线弱于注释（:745 `grep -qxF -f` 为"存在任一命中即计 1"而注释称"全部 token 须已定义"）已被下游 target_bad 检查（:800-810）兜底，净效果未见假 PASS，作代码质量注记不列入前 10。

## 复现清单（全部命令可重跑）

- 基线：`bash skills/task-planner/scripts/run-selftests.sh --fresh`（80/77/3）
- fixture 目录（/tmp 下，已存在，可直接重跑）：`/tmp/s2-idx`（缺陷1）、`/tmp/s2-arc`（缺陷3/4/9）、`/tmp/s2-idx2`（缺陷9）、`/tmp/s2-cc`（缺陷5）、`/tmp/s2-git`（缺陷6）
- 典型命令：`bash skills/task-planner/scripts/archive-plan.sh --batch --dry-run --root /tmp/s2-arc/plans`；`bash skills/task-planner/scripts/check-complete.sh /tmp/s2-cc/plans/task-E/task_plan.md`（exit 0）
