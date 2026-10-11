# Checkpoint 005 drift-check-p3（general-purpose 改派，只读偏移检查）

status: done

## 判定对象与依据

- 对象：task-v170 Phase 3 完成态；Goal=「补齐计划完成后归档机制+存量全归档」；需求锚 R1（task_plan.md:8）。
- 输入（只读）：task_plan.md、progress.md、findings.md、worktree archive-plan.sh、worktree git log/status。
- 本检查体独立复核命令：`bash -n` + `wc -l` 脚本；`git show --stat 05ccb12`；主仓 `ls -d plans/task-v060*` / `ls -d plans/archive/task-v060*` / `git status --porcelain -- "plans/task-v060*"`。
- 约束遵守：未修改任何被审文件；唯一写入=本检查点；git 仅只读查询。

---

## 五项判定（逐项证据）

### (a) Phase 3 动作（S2 派发/脚本编写/独立核验/事故闭环）全部服务 Goal — PASS

- Phase 3 三项 [x] + Status complete：task_plan.md:198-203（S2 编写 / S-unit 自测 / 事故闭环）。
- 执行留痕：progress.md:56-69（S2 派发 code-assistant、commit 05ccb12、主进程独立核验、事故闭环、预防沉淀）。
- 提交范围核验：`git show --stat 05ccb12` → 单文件 `skills/task-planner/scripts/archive-plan.sh +213`，无越界文件——Phase 3 产出恰为 Goal 的机制核心件（archive-plan.sh，对应 CA-1/VC-1/VC-2）。
- 独立核验与事故闭环均服务于「成品可信 + 数据面安全」，与 Goal 同向；未发现服务于 Goal 之外的动作（Why：Phase 3 无 SKILL.md/Rule 81 等后续 Phase 对象提前落子）。
- 锚：task_plan.md:198-209；progress.md:52-69；git show 05ccb12；004-code-assistant-s2.md:4-10。

### (b) 误归档事故 Rule 31 四步入 Error Log 且恢复经独立核验 — PASS

- Error Log 行（progress.md:91）四字段均非占位：
  - ① 错误原文：「S2 探针未加 --dry-run 对主仓 plans/ 实跑 task-v060 归档（误操作）」；
  - ② Root Cause 四问：「现象=主仓数据被移动；直接原因=破坏性探针未用临时根隔离；根因=探针设计无强制 dry-run 前置步（Scope 禁改条款存在但探针越界未被机器拦）；类别=执行偏差+契约缺口」；
  - ③ Resolution：「当次 git restore --worktree + 删 archive 副本；主进程独立核验干净」；
  - ④ Prevention：「S15 批量任务书硬性先 dry-run 双采样+实做显式 --root；notepad 沉淀通用规则；Phase 6 CR 复核守卫面」。
- 复验结果独立记录：progress.md:69 Test Results「事故恢复核验 | 主仓 git status/ls | task-v060 零残留 | PASS」。
- 本检查体三方一致复核（只读命令，2026-10-12）：
  - `ls -d /mnt/data/dev/task-planner-skill/plans/task-v060*` → `plans/task-v060-drift-collect`（在根，恢复在位）；
  - `ls -d plans/archive/task-v060*` → No such file（archive 无副本）；
  - `git -C /mnt/data/dev/task-planner-skill status --porcelain -- "plans/task-v060*"` → 空（git 零变更）。
- 结论：恢复声明经主进程记录 + 本检查体命令复核双重确认。

### (c) 脚本守卫与契约一致（fail-closed 三拦+幂等放行+全 Status 计数判据），无放松守卫迹象 — PASS

- 契约（progress.md:38-42 Phase 2 定稿 5 条）逐条对脚本（worktree archive-plan.sh）：
  - 幂等先行：L141-144（archive/<id> 已存在 → ALREADY_ARCHIVED exit 0，唯一放行特例）；
  - fail-closed 三拦：active 指针全局+side L92-100（无例外）；live-owner 仅 mtime<1440min 才拦 L102-108（TTL 口径与契约一致）；Status 全计数判据 L111-121（total>0 且 total==ok，禁 grep -m1，0 行=status-none）——对应 task_plan.md:342 Decisions Made 判据逐字一致；
  - 附加守卫：missing-src L90、no-task-plan L112（fail-closed 注释 L86-87「拿不准一律给 skip 码」）；
  - 执行：git ls-files 判定 → git mv / mv 兜底 L126-135（与契约第 3 条一致）；
  - 批量：find -maxdepth 1 枚举直接子目录 + not-a-plan-dir 归类（hidden/archive-target/非 task- 前缀/无 task_plan.md）L164-207；BATCH total/ok/skip/fail 汇总 L209；任一 FAIL → exit 1 L210-212；
  - 退出码：0=成功/幂等/--help/批量 dry-run；1=拒绝/失败/参数错（usage L34-37 与实现一致）。
- 无「为过测试放松守卫」迹象：dry-run 分支（L196-199）位于 guard_reason（L190）之后——dry-run 零移动但守卫判据不减，candidate/skip 分类全量输出；findings.md:98 登记的两处与契约偏差（缺省 root 改为上溯找 .git 限 4 级、dry-run candidate 措辞）均为非守卫面且显式留痕交 CR。
- 独立验证：`bash -n` → SYNTAX_OK；`wc -l` = 213（与 progress.md:56、findings.md:96、004 检查点:5 声明一致）。
- 锚：archive-plan.sh:86-213；progress.md:38-42；task_plan.md:342；findings.md:97-98。

### (d) 事故暴露的探针风险已吸收为后续任务书约束（S15 dry-run 先行）而非仅会话记忆 — PASS

- 持久层落点（均非会话记忆）：
  - progress.md:59「预防沉淀：S15 批量任务书将硬性要求先 --dry-run 双采样、实做必须显式 --root、输出双采样对账」；
  - progress.md:91 Prevention 列（同上内容入 Error Log）；
  - findings.md:99-100「教训=S15 任务书须硬性 dry-run 先行」；
  - task_plan.md:289 S15 验收列含「归档数=dry-run 候选数」（dry-run 先行结构化为验收判据）；task_plan.md:276 Phase 8 段「试点已先行」；task_plan.md:357 Notes「批量操作按 Rule 18：dry-run→试点→双采样→熔断」；
  - task_plan.md:250 Phase 5 S13「批量 dry-run：候选清单 vs 三类跳过的双向对账 + 双采样抽检」——S13→S12→S15 链路使 dry-run 先行成为前置依赖，不是纯口号；
  - notepad-learnings.md:29「dry-run 先行」+ :36 通用规则「在途保护先于批量……dry-run 锁定候选集」（Rule 31.7 通用规则表在册）。
- 观察（非判否项）：progress.md:59 承诺的逐字「实做必须显式 --root」未原样写入 task_plan.md S15 行验收列（该列现为「归档数=dry-run 候选数；INDEX 重生；git status 仅 archive/ 与 INDEX」）。建议主进程派 S15 时按 progress.md:59 原文写入 executor prompt 并把该约束回填 S15 验收列——属加固建议，不影响吸收成立判定（dry-run 先行已在任务书结构与持久层成立）。

### (e) task_plan.md Phase 3=complete、并行组声明合法、Next Step 与 Phase 4 一致 — FAIL

- 子项 1「Phase 3=complete」✓：task_plan.md:203 `Status: complete`，:199-201 三项动作全 [x]。
- 子项 2「并行组声明合法」✓：task_plan.md:3-4 `parallel_groups/lanes=[g-wire]`；:224 组声明注释 `[parallel-group:g-wire] = S3,S4,S5,S6`；四成员文件集两两不相交（S3→SKILL.md；S4→critical-rules.md+reference.md；S5→sync-todos.sh+resolve-plan-dir.sh；S6→set-active-plan.sh+plan-created.cjs，:228-231）；Phase 3 无组成员，不越组。
- 子项 3「Next Step 与 Phase 4 一致」✗：
  - task_plan.md:152 `Current Phase` 仍为「Phase 2」——滞后两相（Phase 2 已于 :195 complete、Phase 3 已于 :203 complete、Phase 4 :221 pending，当前应为 Phase 4）；
  - task_plan.md:154-156 `Next Step` 仍为「Phase 2 主进程定稿 archive-plan.sh 契约为 S-unit 表『输入』列回填……随即派 S2 编码」——描述的是已完成动作，未指向 Phase 4（S3-S6 g-wire 并行组派发）；
  - task_plan.md:209 Phase 3 S-unit 表 S2 行状态仍 `pending`，与同文件 :199-201 [x]/:203 complete 自相矛盾（簿记内不同源）。
- 类别判定：机械簿记滞后（三处联动未同源翻转），与 003-drift-check-p1 同源（task_plan.md:364 Drift Log 已登记该教训「进度簿记必须三文件同源翻转」）；非 Goal 级偏离——Phase 3 实质产出（脚本/核验/事故闭环）与服务 Goal 的 (a)(b)(c)(d) 均无问题。

---

## 最终结论

status: done
acceptance: 4/5 pass
files: /mnt/data/dev/task-planner-skill/plans/task-v170-archive-completed-plans/subagent-state/005-drift-check-p3.md
evidence: task_plan.md:152/154-156/209（Current Phase=Phase 2、Next Step 停于 Phase 2/S2 派发、S2 行 pending——与 :199-203 Phase 3 complete 三处不同源）;progress.md:91（Rule 31 四字段非占位）+:57,69（恢复独立核验）+主仓命令复核（v060-drift-collect 在根/archive 无副本/git status 空）;archive-plan.sh:141-144/92-100/102-108/111-121（幂等先行+fail-closed 三拦+全 Status 计数，dry-run 守卫不减:190-199）;git show --stat 05ccb12→单文件+213;findings.md:99-100+task_plan.md:276,289,357+notepad-learnings.md:29,36（S15 dry-run 先行已入持久层与任务书结构）
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v170-archive-completed-plans/subagent-state/005-drift-check-p3.md (status: done)
findings_written: none
blockers: none
confidence: HIGH

VERDICT: DRIFT
