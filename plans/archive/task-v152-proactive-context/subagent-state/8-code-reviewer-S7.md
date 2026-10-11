# S7 Code Review — task-v152 worktree 全量 diff（2026-10-09）

**结论：CHANGES_REQUESTED**（BLOCKER=0 / MAJOR=3 / MINOR=3）

**审查对象**：worktree `/mnt/data/dev/task-planner-skill-worktrees/v152-proactive-context` 相对其基线（HEAD=dbc635a=merge-base，master 独有 9 commit 为 v151 收尾簿记，非本任务改动）的全部变更：15 文件 `git diff HEAD` +2 未跟踪新文件（session-handoff.md / selftest-context-pressure.sh）。注：`git diff master` 混入 master 前进的 v151 文件（plans/task-v151-*/check-complete.sh 等），已剔除。

## 需求锚 R 裁决
- R1（主动压缩/整理）：落实 ✓ — 67.3 + 判定 PRESSURE + hook 节奏提醒（实测注入文本含「PRESSURE 即压缩(67.3)」）。
- R2（交接文档转新会话）：落实 ✓ — 67.4 + templates/session-handoff.md 五段完整 + 恢复链（session-catchup→四文件读序→plan-resume）。
- R3（主动评估/主动优化）：落实 ✓ — 67.1 三档触发 + 67.2 三态裁决 + 「主动评估」「主动优化」关键词入条款。

## 逐维度结论
- 条款语义正确性：PASS（67 六子条与草案逐字一致；交叉引用 19.3/22.3/22.7/24.5/29.1-29.5/62.1/62.3/64.1/64.3/64.4/64.6/65.5 均实存；HEALTHY/PRESSURE/CONFUSED 术语在条款(5)/hook(4)/selftest(8)/模板(CONFUSED,1)无同义改写）
- hook 零副作用：PASS-除 MAJOR-1（_cp 块确在 else 分支；F9 单 emit 未破——实测单行 JSON 携带双行文本；count/last_inject/due 与 F10 两守卫逐字零改动；rhythm_n 除零防护有效；env off 降档有效；_cpn≥2 降频语义正确）
- selftest 断言有效性：PASS-除 MAJOR-2（CP-01..09 实跑 9/9 全绿且非放水；8 个锚演进脚本 990 PASS/0 FAIL；RC-15 `^66\.`=0 防线零触碰，diff 确认仅 RC-11 行演进）
- SKILL 级联：PASS（三处 1-67 计数实证；Rule 67 bullet；C45 行；行数 511 符合钉 ≤518）
- 模板五段/恢复链：PASS（§1-§5 标题 + session-catchup + plan-resume + 62.1 齐备）
- 索引文档标签：PASS（CLAUDE.md/README_zh.md×2/skills README.md 均 1-65→1-67；无残留错误标签）

## MAJOR
1. **MAJOR-1 [正确性/除零防护不完整]** `skills/task-planner/scripts/zcode-posttooluse.sh:348-350`
   - 原文：`_cpn="${TASK_PLANNER_CONTEXT_PRESSURE_N:-1}"; case "$_cpn" in ''|*[!0-9]*) _cpn=1 ;; esac` + `if [ "$_cpn" -eq 1 ] || [ $(( rhythm_count / rhythm_n % _cpn )) -eq 0 ]; then`
   - 原因：除零防护仅覆盖 `rhythm_n`（:349），`_cpn=0|00` 是纯数字通过 case 校验却为 0；`-eq 1` 为 false 时执行 `% _cpn` → division by 0。
   - 复现（worktree fixture，due=1,count=20,n=10）：`TASK_PLANNER_CONTEXT_PRESSURE_N=0 bash zcode-posttooluse.sh` → stderr `line 350: ... % _cpn : division by 0` 且该轮 drift-rhythm emit 丢失（无 JSON 输出）；`_cpn=00` 同。默认 `_cpn=1` 短路不受影响。
   - 修复：`_cpn` 校验后补 `[ "$_cpn" -ge 1 ] 2>/dev/null || _cpn=1`（与 :349 同款）。
   - 置信度：HIGH（已实测复现）
2. **MAJOR-2 [环境耦合/守护在部署位失效]** `skills/task-planner/scripts/selftest-context-pressure.sh:89`
   - 原文：`emit_master=$(git show master:skills/task-planner/scripts/zcode-posttooluse.sh 2>/dev/null | grep -c 'emit ')`
   - 原因：该行是全仓 selftest 中**唯一** git 依赖（`grep -l git show selftest-*.sh` 仅本脚本）。部署位 `~/.zcode` git repo 分支为 `main`（无 master），`git show master:` 恒失败→`emit_master=0`→CP-06 的 `[ 12 -eq 0 ]` 恒 FAIL；错误被 `2>/dev/null` 静默吞掉（违反 §九 禁静默失败）。
   - 复现：`cd /home/terry/.zcode && git show master:skills/task-planner/scripts/zcode-posttooluse.sh` → `fatal: invalid object name 'master'`。
   - 修复：把期望 emit 数固化为脚本内常量（现为 12）做 `-eq 12` 负锚，或加 fallback：`[ -z "$emit_master" ] && emit_master=12`；避免 git 依赖。
   - 置信度：MEDIUM（事实=部署位无 master 已证；是否在部署位实际跑该脚本依赖用户/CI 惯例）
3. **MAJOR-3 [合并口径遗漏]** `skills/task-planner/SKILL.md:218`（worktree）vs master:218
   - 原文（worktree）：`| C45 | 上下文压力主动评估自查（Rule 67）：...`；master 同名：`| C45 | goal 单元自查（Rule 66）：...`
   - 原因：worktree 基线下 C44 后下一号是 C45，master 的 v151 已占用 C45 给 Rule 66。Phase 6 merge wt→master 时两处 C45 同行插入点必冲突/重复编号（task_plan 风险表仅登记「SKILL 计数行并集解」，**未**点名 C45 行号冲突）。
   - 修复：Phase 6 合并时把 v152 的 C45 重编号为 **C46**，并同步 `selftest-context-pressure.sh` CP-07 的 `C45` 断言与 Rule 67.6 措辞「合规清单新增 C45」→C46。
   - 置信度：HIGH（两侧 C45 行内容已对照）

## MINOR
1. **MINOR-1 [文档计数漂移]** `skills/task-planner/README.md:35,79`
   - 原文：`templates/   (10 核心 + 29 variant)` / `← 10 核心 + 29 个 variant <!-- 2026-10-08 task-v149 对齐实态 -->`
   - 原因：本任务新增 `templates/session-handoff.md`（master 10 个 .md → worktree 11 个），README 模板计数未随动（若 session-handoff 计入核心模板则应=11）。
   - 修复：更新为「11 核心」并刷新注释日期。
   - 置信度：MEDIUM（「核心」口径由作者定义）
2. **MINOR-2 [断言覆盖面]** `skills/task-planner/scripts/selftest-context-pressure.sh:51-59`（CP-03）
   - 原文：`c1=$(grep -c 'HEALTHY' "$CRIT")`
   - 原因：设计 §1 声称三态词在「条款、模板、selftest、hook 注入文案逐字回写」，CP-03 仅在 critical-rules 断言三态词，未交叉断言 hook 注入文案/hook 代码的三态词（hook 代码实测含 4 处，可加断言防未来改写）。
   - 修复：CP-03 增补对 `$POSTTOOLUSE` 的 HEALTHY|PRESSURE|CONFUSED ≥1 断言。
   - 置信度：MEDIUM
3. **MINOR-3 [行为耦合]** `skills/task-planner/scripts/zcode-posttooluse.sh:349`
   - 原文：`[ "$rhythm_n" -ge 1 ] 2>/dev/null || rhythm_n=10   # 除零防护（env 可注入 0）`
   - 原因：该行位于 `if [ "${TASK_PLANNER_CONTEXT_PRESSURE:-on}" != "off" ]` 块内，使既有 drift-rhythm 文案在 `DRIFT_RHYTHM_N=0` 时随**新** env 开关变化（off→「≥0」/on→「≥10」），非纯「零改动」（仅病态 env 可见）。
   - 修复：将 `rhythm_n` 钳位提到 `_cp` 块外（drift 分支内统一钳位），与 CONTEXT_PRESSURE 开关解耦。
   - 置信度：HIGH（控制流已核对）

## 负结果（已排查未发现）
- 无安全漏洞：本次为技能文档/脚本规则增强，diff 无外部输入解析、无 SQL/命令注入面；hook 对所有外部值沿用既有 `case`/整数校验，无新增 eval/未引号展开。
- critical-rules.md 纯追加（`git diff | grep -c '^-[^-]'`=0，Rule 1-65 正文零改动）；SKILL.md 删除行仅 2 处旧计数标签（机械同步非语义删除），符合 §36.3 纯增量声明。
- 除零/空值：`rhythm_n`/`rhythm_count`/`rhythm_last`/`due` 均有 `case` 容错；`_cpn` 见 MAJOR-1。
- F9 单 emit 约束未破（实测单行 JSON）；F10（COMPLETE/age>86400）两守卫零改动。
- 990 PASS/0 FAIL（58 selftest）+ registry 5 PASS，与基线口径一致（未逐字节比对 baseline-selftest.log）。
- RC-15 `^66\.` 防线、FF-16/EG-16/IP-14 同族防线均零触碰。

## 未覆盖/限制
- 未在部署位实际执行 selftest-context-pressure.sh（部署位尚无该文件，仅以 git 行为模拟 MAJOR-2）。
- 未做 merge 演练（MAJOR-3 为静态对照推断）。
