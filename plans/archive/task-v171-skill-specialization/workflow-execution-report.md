# task-v171 技能专业化拆分 — 工作流执行报告（Phase 5-8）

> **报告人**：报告撰写员（dynamic workflow 运行 dwfrun-d3699adc 的 actor#14）
> **日期**：2026-10-12
> **worktree**：`/mnt/data/dev/task-planner-skill-worktrees/task-v171-skill-specialization`（分支 `wt/task-v171-skill-specialization`，基点 e82dd42 = 当时 master tip）
> **来源数据**：`plans/task-v171-skill-specialization/task_plan.md`、`plans/task-v171-skill-specialization/design-architecture.md`、`plans/task-v171-skill-specialization/{progress,findings}.md`（P4.5 前主进程落盘）、worktree `git status`/`git diff --stat` 实测、workflow 运行脚本 `.zcode/workflow-runs/dwfrun-d3699adc-e2a3-49d2-8bad-d1d028e5b1d7.mjs`、actor 执行日志 `/home/terry/.zcode/cli/exec/sess_dwf-dwfrun-*`、本报告撰写时亲跑的复验命令（附录 A）
> **诚实声明**：本子代理会话无 workflow 运行记录读取能力（工具返回 `workflow_introspection_unavailable`），VC 复核员与 CR 评审员的**结论文本**存于运行记录中、本会话不可达；凡本报告未能亲跑复验的项目均逐处显式标注「未复验/未运行」。

---

## 1. 总览

### 1.1 执行载体与拓扑

P5-P8 由 dynamic workflow 执行（用户 `/workflow` 显式指令启动；运行脚本演进：初版 dwfrun-0f6be881 → 修订 dwfrun-eeaa3e10 → 本次运行 dwfrun-d3699adc，前两轮完成态被缓存复用——progress.md:103、findings.md:71）。拓扑共 8 阶段、14 个 actor（workflow 脚本头注释与 `createActor` 清单实测）：

```
回归修复 → 纪律技能建设（上/下/搬迁 3 路）→ 8 卫星并行收编 → 核心瘦身
→ 锚修复 3 批并行 + 契约收尾 → 全量回归终验（门控循环）→ VC 复验与 CR 质量门 → 执行报告
```

### 1.2 完成面

| Phase | 内容 | 状态 |
|-------|------|------|
| Phase 5 | task-discipline 新技能建设（36 规则 + 4 组搬迁） | worktree 侧完成（§2.1 实测） |
| Phase 6 | media-planner 新建 + 7 既有卫星收编（19 规则） | worktree 侧完成（§2.2 实测） |
| Phase 7 | 核心瘦身 + selftest 锚修复 3 批 + 契约收尾 | worktree 侧完成（§2.3/§2.4 实测） |
| Phase 8 | 终验回归 + VC 复验 + CR 质量门 | 门控部分完成；merge-back/部署对账/呈报=主进程待办（§5） |

### 1.3 最终门状态

| 门 | 结果 | 证据 |
|----|------|------|
| 全量回归（核心 77 selftest） | **FAIL=0**（`Total: 77 PASS=77 FAIL=0 (run=77 reused=0)`） | 双证一致：① workflow 运行时——质量门评审员 actor#13 于 21:40 经 world.run 亲跑的日志（`/home/terry/.zcode/cli/exec/sess_dwf-dwfrun-d3699adc-…-actor_13_1/call_8c1e36a530914b9eb7e7bf69-stdout.log`）；② 本报告撰写时复跑 `bash skills/task-planner/scripts/run-selftests.sh --fresh`（附录 A-8） |
| task-dispatch 2 随迁 selftest | 全绿：selftest-fallback 31/31、selftest-rescue-chain 11/11 | 本报告复跑（附录 A-7） |
| VC-1..VC-5、VC-7 | 本报告逐条复验通过（原始行见附录 A） | 附录 A-1~A-9 |
| VC-6（check-complete 全门 + attest 试锁） | **本报告未复跑**（会改写 attest 态，未执行） | 标注为未复验；attest 四锚在 P2 已实测锁过（progress.md:44-45） |
| VC-8（删除基线+merge-back+部署对账） | **未通过=计划内待办**：删除基线 grep 零残留已由全集唯一性机检覆盖（附录 A-3）；merge-back 与部署对账属主进程动作（task_plan.md:346-348），尚未执行 | §5 |
| CR 质量门 | 通过（工作流推进至报告阶段=门控循环退出）；第 1 轮拦截发现 master 并行 Rule 81 需并集解，修正登记后放行（task_plan.md:405）；**评审意见原文不可达**（见附录 B 说明） | task_plan.md:405 + workflow 阶段推进事实 |

---

## 2. 各阶段产出（全部为 worktree 实测或盘面文件实测）

### 2.1 Phase 5 — task-discipline 纪律卫星（36 规则 + 4 组搬迁）

- **36 规则落位**：`skills/task-discipline/references/critical-rules-discipline.md` 实测 `grep -cE '^### [0-9]+ '` = **36**（本报告复验，附录 A-4）。
- **4 组搬迁**（git staged renames 实测，`git -C <worktree> status`）：
  1. `references/batch-quality-gate.md` → `task-discipline/references/`
  2. `references/capability-registry.md` → `task-discipline/references/`
  3. `scripts/capabilities/agnes-quota.sh` → `task-discipline/scripts/capabilities/`（源路径勘误后按 `skills/task-planner/scripts/capabilities/` 实搬，findings.md:54）
  4. `scripts/plan-hygiene.sh` → `task-discipline/scripts/`（实测 `-rwxrwxr-x` 可执行位保留）
- **SKILL.md**：frontmatter `name: task-discipline` + 描述触发词合规（附录 A-5 实测）。
- 执行体：纪律规则撰写员·上/下 + 纪律文件搬迁员 3 路（脚本 actor#2/#3/#4）。

### 2.2 Phase 6 — 8 卫星收编（media-planner 新建 + 7 既有卫星 16 规则）

逐卫星 grep 实测（附录 A-6），全部与 design-architecture §3 清单一致：

| 卫星 | 收编规则 | 实测 |
|------|---------|------|
| media-planner（新建） | 47,49,50 | 3 条 ✓（`references/critical-rules-media.md`） |
| plan-research-router | 58,63,75 | 3 条 ✓ |
| plan-template-kit | 16,34,37,38 | 4 条 ✓ |
| plan-collab-router | 39,40 | 2 条 ✓ |
| plan-cost-guard | 17 | 1 条 ✓ |
| plan-resume | 24 | 1 条 ✓ |
| progress-tracker | 30 | 1 条 ✓ |
| task-drift-guard | 11,15,61,64 | 4 条 ✓ |

7 个既有卫星 SKILL.md 索引更新：worktree `git status` 显示 7 个卫星 SKILL.md 全部 modified；media-planner 为 untracked 新目录。合计收编 **19 条**（media 3 + 卫星 16）。

### 2.3 Phase 7 — 核心瘦身

- **SKILL.md 瘦身**：556 行 → **218 行**（实测 `wc -l`，≤250 达标；BP-08 钉演进注释记录瘦身时点实值 214 行，`selftest-batch-pilot.sh:11`）；「卫星路由表」在位（`SKILL.md:145`）；权威口径行自述「核心在位 13 条（1,2,3,5,19,20,26,51,62,66,80,81,82）」（`SKILL.md:162`）。
- **核心 critical-rules.md 重构**：实测 13 个规则头（行 9/12/15/18/21/33/54/84/99/115/129/147/161），全集唯一性机检 **79 个编号零重复**、覆盖 1-76+80+81+82（77/78/79 为预留未落地号，`critical-rules.md:130` 注释口径；附录 A-3）。
  - **计数勘误**：本次任务指令写「核心瘦身（12 规则）」，盘面权威行（SKILL.md:162 与 critical-rules.md 实测）为 **13 条**——Rule 82 边界自述列举 12 条（1,2,3,5,19,20,26,51,62,66,80,82，`critical-rules.md:165`）未计入由并集解决策并入核心的 Rule 81（task_plan.md:406「Rule 81 归核心…插 80.6 与 Rule 82 之间」）。两处文本的枚举不一致如实登记于 §5 遗留项。
  - 同理，task_plan.md:69 的 VC-2 修订口径「全集 78 条」与盘面实测 79（76+80+81+82，Rule 80 正文已由 task-v169 实落）存在 1 条计数差，如实登记于 §5。
- **Rule 82 写入**：`critical-rules.md:161` 起全文在位（建制/边界/回归防线），其正文同时记录了执行期的两个拦截事实：66 条迁移中 4 条溯源注释漂移被配对前核验拦截并补挂；Rule 80 曾按空壳登记删除、S31 实测正文已实落而保留核心（`critical-rules.md:167`）。
- **锚修复 3 批并行**：批1 纪律关联 46 个 / 批2 媒体协同模板 5 个 / 批3 派发 13 个（design-architecture.md §7 清单）；worktree `git status` 显示约 60 个 `selftest-*.sh` modified，与三批清单规模一致。**每批的逐断言运行结果未在本报告逐个复跑**（以全量回归 FAIL=0 终态覆盖，见 §3）。
- **执行体**：核心瘦身员（actor#6）+ 锚修复员·纪律批/媒体批/派发批（actor#7/#8/#9）。

### 2.4 Phase 7 契约收尾

- **install-stub.sh 注册 3 新卫星**：`lib/install-stub.sh:41` 实测 `SATELLITE_SKILLS=(plan-research-router plan-template-kit plan-cost-guard plan-collab-router task-dispatch task-discipline media-planner)`（原 4 + 新 3，附录 A-9）。
- **BP-08 行数钉演进**：`selftest-batch-pilot.sh:11,63,65` 实测 558→**275**（≤250+25 边距先例，注释含 S38 演进记录）。
- **README/ARCHITECTURE 重写**：`git status` 显示 `skills/task-planner/README.md`、`skills/task-planner/docs/ARCHITECTURE.md` modified（内容按分层架构重写的逐行核验未在本报告进行——标注未复验）。
- **执行体**：契约收尾员（actor#10）。
- 并集解系列（质量门第 1 轮拦截后追加，task_plan.md:405-408 登记）：Rule 81 逐字并入核心、SKILL.md G9/G10 行承载 C56/C57 语义、17 脚本纪元锚 `'1-80'→'1-8[01]'` 宽容化（plan 已登记，逐脚本 grep 未在本报告复验）。

---

## 3. 回归修复过程

1. **首轮失败**：P4 完成态全量回归 **14 个 selftest 脚本 FAIL**（32 条断言级失败），清单实测记录于 findings.md:48：agent-coverage(3)/context-hygiene(3)/decision-arbiter(1)/dispatch(3)/drift-check-subagent(1)/parallel-scheduling(1)/registry(1, rows=78≠76)/self-resolution(1)/skill-collab(2, T6a/T6b)/split-pattern-library(7)/subagent-granularity-skill-escort(1)/subagent-return(5)/summary-readability(2)/fallback(task-dispatch, T08)。
2. **根因定位（主进程 P4.5 探针，findings.md:47-50）**：detached@master 临时 worktree 全量回归零 FAIL → 14 项全部由搬迁引入、非存量问题。根因同构=**搬迁路径层级 bug 家族**：caller/selftest 的 `$SCRIPT_DIR/../` 只上一级到 `skills/task-planner`，再拼卫星名解析到不存在的 `task-planner/<卫星>/`。4 处确诊：`selftest-skill-collab.sh:14`（FALLBACK）、`selftest-context-hygiene.sh:27`（HYG）、`selftest-subagent-return.sh:9`（RS）、`selftest-subagent-granularity-skill-escort.sh:55`（ASPL）；正确语义为 `$ROOT/../`、`$REAL_ROOT/../`、`$SCRIPT_DIR/../../`、`$SKILL_ROOT/../`（对照：check-complete.sh/install.sh/verify.sh 的层级本就正确）。另有 registry 计数锚（78≠76）类断言需随全集演进。
3. **修复**：workflow 阶段 1「修复拆分引入的自检回归」由回归修复员（actor#1）执行，修 4 处路径层级 + 锚/计数断言；终验阶段门控循环中的终验修复员（actor#11）兜底复核（脚本 `createActor` 清单）。
4. **终态**：全量回归 **FAIL=0**（双证：actor#13 运行时日志 + 本报告复跑，§1.3）；本报告另抽查 task-dispatch 2 个随迁 selftest 独立全绿（附录 A-7）。

---

## 4. 偏离登记（对 plan 原定的偏离，均有依据）

| # | 偏离 | plan 原定 | 实际执行 | 依据/理由 |
|---|------|----------|---------|----------|
| 1 | **锚修复 3 批并行**（plan 原定串行） | S35→S36→S37 串行（task_plan.md:321-323 前置依赖链） | 同相并行创建锚修复员·纪律批/媒体批/派发批 3 个 actor（脚本 actor#7/#8/#9） | Rule 21.4 独立性四问：批间文件集不相交（python 交叉清单实测）+无共享资源；已登记 findings.md:72 与 task_plan.md:312 状态注 |
| 2 | **world.run 门替代 code-runner 跑批** | S41 回归执行体=code-runner-agent(mini)（task_plan.md:194 工具编排表、:461 委派表） | workflow 以 world.run 直接跑 `run-selftests.sh --fresh`（脚本 `world-read#1`，timeoutMs=600000），门控循环判定 `FAIL=(\d+)` | task_plan.md:336 Phase 8 状态注已登记「S41 回归=world.run 门」；运行脚本为实证 |
| 3 | **P5-P8 执行载体整体改为 dynamic workflow**（plan 原定 executor/code-assistant 子代理） | Phase 5-7 Executor=executor/code-assistant（sonnet-1） | 用户 `/workflow` 显式指令 → Skill(dynamic-workflows) → CreateWorkflow/AmendWorkflow | findings.md:71「用户 /workflow 显式指令=强制 workflow」；task_plan.md Phase 5/6/7/8 Executor 字段已同步改注 |

---

## 5. 遗留与下一步

| # | 事项 | 责任方 | 说明 |
|---|------|--------|------|
| 1 | **merge-back 待执行** | 主进程 | `git merge --no-ff wt/task-v171-skill-specialization`（task_plan.md:346）。前置合约（§十一.3）：worktree 内 VC 全绿（已达成，§1.3）+ **worktree git status 需先提交干净**（当前实测：staged 13 renames+7 脚本文件、unstaged 79 文件 2036+/2477-、untracked 新卫星与 references 文件——`git -C <worktree> status`/`git diff --stat` 实测）+ 主仓无重叠未提交变更 |
| 2 | **部署位对账与写入** | 主进程对账、写入待用户授权 | ~/.zcode、~/.claude、~/.config/opencode、~/.cursor 四位只读对账（task_plan.md:347）；§六 保护区写入须用户显式授权 |
| 3 | **行为面冒烟待新会话** | 用户新开会话 | 技能定义改动（3 新卫星+核心瘦身）的生效验证不能以临时计划任务代验（宪法 §十二已知限制） |
| 4 | **plans/ 罗盘回填** | 主进程 | progress.md 停在 P4.5（5-Question 表自述「等 workflow 通知」），P5-P8 段未回填；Subagent Handoff 表（task_plan.md:451-461）多为 queued 态 |
| 5 | **计数口径文本对齐**（小项） | 后续任务/主进程 | ① task_plan.md:69 VC-2 口径「78 条」vs 盘面实测 79（1-76+80+81+82，Rule 80 已实落）；② critical-rules.md:165 Rule 82 边界自述 12 条清单 vs 盘面 13 条（漏 81）。两处均为已落盘文本的事实差，本报告不裁决，登记待对齐 |
| 6 | **VC-6 / 逐批锚修复断言级复跑** | 主进程或终验方 | check-complete 全门试跑与 attest 试锁、三批锚修复的逐 selftest 断言运行结果，本报告未复跑（以全量 FAIL=0 覆盖回归面） |

---

## 附录 A：VC 复验原始行（本报告撰写时于 worktree 亲跑）

**A-1 VC-1（SKILL.md ≤250 行）**
```
$ wc -l skills/task-planner/SKILL.md
218 skills/task-planner/SKILL.md
```

**A-2 核心 critical-rules.md 规则头（VC-2 核心侧）**
```
$ grep -nE '^### [0-9]+ |^## Rule [0-9]+（' skills/task-planner/references/critical-rules.md
9:### 1 先规划，再执行          12:### 2 PreToolUse 强制阻断   15:### 3 双操作后立即保存
18:### 5 Phase 完成后更新       21:### 19 3-File 落盘强制…     33:### 20 计划注入与防篡改…
54:### 26 质量优先于速度门控…   84:### 51 需求覆盖与完成声称…  99:### 62 四文件罗盘数据流转…
115:### 66 goal 单元固化…       129:## Rule 80（用户会话逐字记录与只写不改纪律 — task-v169）
147:### 81 计划完成后归档纪律…  161:### 82 技能专业化分层纪律…
（实测 13 个规则头；各条目全文见 worktree 该文件对应行）
```

**A-3 VC-2 全集唯一性（11 归属面联合机检）**
```
$ grep -hoE '^### [0-9]+ |^## Rule [0-9]+（' <11 个归属文件> | grep -oE '[0-9]+' | sort -n | uniq -c | awk '$1>1{print "DUP:",$2} END{print "唯一编号总数:",NR}'
唯一编号总数: 79            # 无 DUP 行输出=零重复
$ … | sort -n | tr '\n' ' '
1 2 3 … 76 80 81 82        # 77/78/79 为预留未落地号（critical-rules.md:130 口径）
```

**A-4 VC-2/VC-4 归属面计数**
```
task-discipline/references/critical-rules-discipline.md  → grep -cE '^### [0-9]+ ' = 36
task-dispatch/references/critical-rules-dispatch.md      → = 11
media-planner/references/critical-rules-media.md         → = 3
```

**A-5 VC-3 新卫星 frontmatter（head -5 实测摘录）**
```
skills/task-dispatch/SKILL.md:     name: task-dispatch   description: 子代理派发与拆分调度（…）
skills/task-discipline/SKILL.md:   name: task-discipline description: 执行纪律与工作产物维护（…）
skills/media-planner/SKILL.md:     name: media-planner   description: 媒体制作任务派发（…）
```

**A-6 VC-4 七卫星收编 grep（期望=实测）**
```
plan-research-router/…research.md   期望3条 实测3条     plan-template-kit/…template.md  期望4条 实测4条
plan-collab-router/…collab.md       期望2条 实测2条     plan-cost-guard/…cost.md        期望1条 实测1条
plan-resume/…resume.md              期望1条 实测1条     progress-tracker/…progress.md   期望1条 实测1条
task-drift-guard/…drift.md          期望4条 实测4条
```

**A-7 VC-5 附加面：task-dispatch 2 随迁 selftest 独立跑**
```
$ bash skills/task-dispatch/scripts/selftest-fallback.sh      | tail -2
[PASS] T11c hint 含 22.3.2 拆细再接管
Total: 31  PASS=31  FAIL=0
$ bash skills/task-dispatch/scripts/selftest-rescue-chain.sh  | tail -2
T10 PASS
Total: 11 PASS=11 FAIL=0
```

**A-8 VC-5 主面：全量回归（官方入口，--fresh）**
```
$ bash skills/task-planner/scripts/run-selftests.sh --fresh | tail -1
Total: 77 PASS=77 FAIL=0 (run=77 reused=0)
（与 workflow 运行时 actor#13 于 21:40 的 world.run 日志尾部一致：
  Total: 77 PASS=77 FAIL=0 (run=77 reused=0)）
```

**A-9 VC-7 契约要素**
```
$ ls skills/task-planner/scripts/zcode-*.sh | wc -l        → 4（adapter 全在位）
  其中 zcode-posttooluse.sh 调用 scripts/sync-todos.sh（未搬迁脚本；5 个搬迁脚本无一被 adapter 调用——findings.md:43 实测口径）
$ grep -n "SATELLITE_SKILLS=" skills/task-planner/lib/install-stub.sh
41:SATELLITE_SKILLS=(plan-research-router plan-template-kit plan-cost-guard plan-collab-router task-dispatch task-discipline media-planner)
$ grep -nE "275|558" skills/task-planner/scripts/selftest-batch-pilot.sh | head -4
11:#   BP-08 SKILL.md 行数 ≤275（…[2026-10-12 task-v171 S38] …上限 558→275=250+25 边距先例…）
63:# BP-08 [2026-10-12 task-v171 S38] 上限 558→275: …
65:if [ "$lines" -le 275 ]; then ok 08 …; else bad 08 …; fi
$ ls -la 三件搬迁脚本 → -rwxrwxr-x（可执行位保留）
```

**VC 判定汇总**：VC-1 ✓ / VC-2 ✓ / VC-3 ✓ / VC-4 ✓ / VC-5 ✓ / VC-7 ✓（均本报告亲跑）；VC-6 未复跑（标注）；VC-8 待主进程 merge-back 后闭环。

## 附录 B：CR 意见与运行时证据

**可达性说明（如实）**：质量门评审员（actor#13）的评审意见原文返回给 workflow 运行记录；本报告会话调用工作流运行记录工具返回 `workflow_introspection_unavailable`（能力缺口，非空项目），故**意见原文无法在本报告粘贴**。以下为可从盘面与执行日志取证 的 CR 相关事实：

1. **CR 门通过**：工作流按「VC 复验与 CR 质量门（并行+拦截循环，cap 2）→ 执行报告」推进（脚本头注释），运行已到达报告阶段（本报告即该阶段产物）= 质量门循环退出。
2. **第 1 轮拦截的有效意见（盘面登记）**：质量门第 1 轮拦截发现「worktree 基点 e82dd42 落后 master tip 23cffa5 32 提交、master 并行落地 task-v170 Rule 81 全链，按现状 merge 将静默回退并行成果」，由此产生 4 项并集解决策（Rule 81 归核心 / SKILL.md G9/G10 行承载 / 纪元锚 '1-8[01]' 宽容化 / VC-2 口径修订），登记于 task_plan.md:405-408（原文：「本次纠正由质量门第 1 轮拦截发现」）。
3. **CR 期间回归门实测（actor#13 执行日志原文，21:40）**：
   ```
   [run]    selftest-user-instruction-priority (rc=0 PASS=0 FAIL=0)
   [run]    selftest-vc-gate (rc=0 PASS=11 FAIL=0)
   [run]    selftest-veto (rc=0 PASS=13 FAIL=0)
   [run]    selftest-workflow-orchestration (rc=0 PASS=16 FAIL=0)
   Total: 77 PASS=77 FAIL=0 (run=77 reused=0)
   ```
   日志路径：`/home/terry/.zcode/cli/exec/sess_dwf-dwfrun-d3699adc-e2a3-49d2-8bad-d1d028e5b1d7-actor_13_1/call_8c1e36a530914b9eb7e7bf69-stdout.log`
4. **VC 复核员（actor#12）结论文本**：同样存于运行记录，本会话不可达——其验证面已由附录 A 的亲跑复验覆盖（VC-1..VC-5、VC-7 同口径重证）。
5. **配对前核验拦截记录（Rule 82 正文自载，critical-rules.md:167）**：「66 条迁移中 4 条溯源注释漂移即被配对前核验拦截并补挂」。

---

*报告完。数据截止 2026-10-12 22:2x（本报告复验时点）；merge-back 后的 master 状态不在本报告覆盖范围内。*
