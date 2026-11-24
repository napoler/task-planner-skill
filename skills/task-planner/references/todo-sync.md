# 原生 Todo 同步契约（Native Todo Sync Contract）

> **事实源声明**：`task_plan.md` 是唯一事实源（single source of truth）；原生 Todo（ZCode/Claude 内置 TodoWrite 或 Task 系统）只是**执行视图**。二者不一致时，以 task_plan.md 为准重建 Todo，禁止反向覆盖计划文档。

## 1. 工具选择

| 场景 | 用什么 | 说明 |
|------|--------|------|
| 默认（单会话、Claude/ZCode 通用） | `TodoWrite` | 内置 todo 清单，实时可视，最通用 |
| 跨会话恢复 / 多任务编排 / 子代理可见 | `TaskCreate` + `TaskUpdate` + `TaskList` | 持久化任务系统，`sync-todos.sh --index` 的 INDEX.md 可直接转译为 Task |

**规则**：二选一即可，禁止同一 Phase 双写两套 todo（会漂移）。会话内默认 TodoWrite；需要断点续做或多任务并行时用 Task 系统并保持唯一。

## 2. 映射规则

| task_plan.md | 原生 Todo | 说明 |
|--------------|-----------|------|
| 每个 `### Phase N: <title>` | 一条 todo | subject 格式：`{task-id}/Phase N: title`（与 `sync-todos.sh` 输出一致） |
| `**Status:** pending` | `pending` | 未开始的 Phase 不强制预建，按需 |
| `**Status:** in_progress` | `in_progress` | 同时只允许一条 in_progress |
| `**Status:** complete` | `completed` | 必须带证据（文件/命令输出），见 completion-gate；注：脚本 JSON 输出（`sync-todos.sh --json` / `check-complete.sh`）归一为 `complete`，`completed` 为原生 Todo 状态词汇 |
| Goal / VC 表 | 不建 todo | VC 复验走终验流程，不是待办项 |

## 3. 强制同步时机（S1–S5，全部强制）

| # | 时机 | 动作 |
|---|------|------|
| S1 | 计划创建后（init-session.sh 完成、哨兵清除前） | 运行 `sync-todos.sh --json` → 按映射规则建立全部 Phase 的 todo（一条 in_progress + 其余 pending） |
| S2 | Phase 状态每次变更后（in_progress / complete） | `planctl phase-start/phase-done --id P<n>` + `render`（状态行经派生视图刷新）+ 同步该条 todo 状态，**必须紧邻执行，禁止只做其一** |
| S3 | 每 `todo_sync_interval_calls`（默认 10）次工具调用 | 收到 `[plan-sync]` hook 提醒 → 执行第 4 节响应协议 |
| S4 | 会话结束前（交付 COMPLETE/PARTIAL/BLOCKED 之前） | 终态同步：全部 todo 终结 + `sync-todos.sh --index` 刷新 INDEX.md + 计划文档终态一致（**前置=Rule 84.14 收尾回读梳理迭代已完成+B17/B18 收尾对齐与清理已完成**——收敛出口（连续一轮零新发现）通过后才可终结 Todo 进入终态同步） |
| S5 | 用户新指令影响计划后（扩展 B / 矛盾 C） | 先 `planctl update/set`（Phase/VC/执行范围，注明来源指令与时间）+ `render`→ 紧邻完成 Todo 重映射（增/改/删对应条目）→ 复述变更后再执行；**禁止口头接受新指令而不落盘**（判定规则见 SKILL.md § 用户新指令处理） |

**S1 两组结构（任务组+基线组，Rule 106.5——task-docmod-recheck-20261112 落地）**
1. S1 建立两组原生 todo：**任务组**（Phase 映射，既有规则）+**基线组**（固定十八项 B1-B18（B1-B5 逐字保留 + B6 引擎检测/B7 对齐/B8 worktree 核验 + B9 基线快照/B10 检查点/B11 差异处置 + B12 SP/OS 技能到达与产物承接收据检查/B13 Spec 路由命中核查（需求特征终判） + B14 根因/风险线索包已落盘 + 后续任务已登记 + B15 周期性偏移回顾 + B16 合并回主分支+合并后回归核验 + B17 口径对齐 + B18 垃圾清理），B6-B8 不动，措辞以 Rule 106.5 为准）；两组必须同为原生条目（TodoWrite/Task 系统条目，禁止只存计划文档）。B17/B18 为收尾最后两步：执行时机在 outcome 判定前、B16 合并回之前（清理改动须先落盘提交才能合并）。**B17 口径对齐**：交付前拉平本任务触及的过期计数与冲突条款；判据=冲突锚 grep 无本任务新增命中；证据落 progress `[align-final]` 行。**B18 垃圾清理**：**范围仅限会被 Agent 读取进上下文的 Skill 说明文件（SKILL.md/references/templates 等 Markdown）**——删除本任务新增的无价值历史旁注，保留描述字段语义/消费方/脚本锚点的高价值契约注；含守卫盲区事实的判例注归档 forensics 不直删；**代码文件（.py/.sh/.ts 等）里的注释属保护对象、禁止清理**（不进 Agent 上下文、便于后期理解）；证据落 progress `[cleanup-final]` 行。
2. 基线组生命周期：B1 持续项（开启即 in_progress，终验翻 complete，判据=progress 全部 [recheck] 行）；B2 每 Phase 翻转前勾检；B3/B4 终验期；B5 收尾；B9 任务开始前备份（Git 基线快照）——首次写入受管文件前一次，由清哨兵前校验强制；B10 修改后备份（检查点）——每个 S-unit/Phase 翻转前；B11 Git 差异分析与处置——Phase 翻转前增量、终验前全量，由 check-3file-gate 第 8 条件与 check-complete 的 GIT-BASELINE GATE 两处门自动执行（2026-11-24 task-session-regression-20261124）；基线组独立计数：B1 持续 in_progress 不受「同时只允许一条 in_progress」约束（该唯一性约束限任务组/Phase 映射条目）；B6 建 todo 时检测引擎适配性（OpenSpec 规格化/Superpowers 方法论），结论落盘 Decisions；B7 对齐核查（吸收旧 task-align 默认项语义）；B8 实现类任务 worktree 隔离核验；B12 SP/OS 技能到达与承接收据检查（需求产出后由 `check-spec-route.sh --probe` 驱动，收据须同时登记技能名与该步骤产出物路径）；B13 Spec 路由命中终判（需求产出后由 `check-spec-route.sh --feature` 驱动并写 `<plan-dir>/route-receipts.jsonl`）（2026-11-24 方案A/H3）；B14 根因/风险线索包登记驱动点——修复类请求在根因/风险线索包落盘并登记后续任务后勾检；非修复类标 N/A 但必须有证据（写 findings 一行）；B15 周期性偏移回顾——每 N 次工具调用（S3 周期）读 user-session-log.md 全原话对照当前执行，跑 `periodic-review.sh <plan-dir>` 得无矛盾后在 findings/progress 落 `[periodic-review:PASS]`（有偏移落 `[periodic-review:DRIFT:<n>]` 并先处置）；证据由 sync-todos.sh baseline_b15_receipt 读取，缺标记=未回顾（2026-11-25 压缩后核心任务丢失根治）；B16 合并回合（`git merge --no-ff` 回 master + `git worktree remove <path>` + `git branch -d wt/<task-id>` 清理）+ 合并后回归（`run-selftests.sh --fresh` 不增 FAIL + `verify.sh` 0 fail）；完成判据=plan-state.json `.isolation.merge_back` 含 `merged(`，缺=未完成（2026-11-24 task-session-regression-20261124 续）；B17/B18 收尾期勾选（outcome 判定前、B16 合并回之前）
3. 门禁挂钩（对齐 Rule 106.5）：B1 未完成留痕=该修改步禁声称完成；B2 未勾=Phase 禁 complete；B3/B4 未勾=禁出 outcome。B6 未留痕=不得声称按专业引擎推进；B7 未勾=对齐核查未完成；B8 未勾=实现类不得直接改主树；B9 无基线证据=受管写入未完成；B10 无检查点=Phase 禁 complete；B11 unresolved>0=Phase 禁 complete 且禁出 outcome（2026-11-24 task-session-regression-20261124）；**B12 未留「技能步骤产物承接收据」=禁声称完成**（只查 SKILL.md 存在不算：必须同时有技能名 + 该步骤产出物在 findings.md/actions.md/task_plan.md/progress.md 的登记；R4「被调用并用于推进」验收）；**B13 命中路由未勾/无终判收据=Phase 禁 complete**（命中 `spec-mode.md` §1 路由表却无 `route-receipts.jsonl` 终判留痕即拦截）（2026-11-24 方案A/H3）；**B14 未留痕（线索包未落盘或后续任务未登记，且非 N/A+证据）=修复类请求禁进入根治后续阶段/禁声称两段式闭环**；**B15 无 periodic-review 收据=该周期偏移回顾未完成，禁声称已按 Rule 65/80.4/61 对照原话、禁出 outcome（压缩后核心任务丢失根治）**；**B16 无 merge_back 合并证据（isolation.merge_back 缺 merged(...)）=禁声称已合并回主分支/禁出 outcome（2026-11-24 task-session-regression-20261124 续）**；**B17 无 `[align-final]` 证据 / B18 无 `[cleanup-final]` 证据=收尾对齐与清理未完成，禁出 outcome**
4. S3 `[plan-sync]` 回写协议：两组均回写；发现基线组条目丢失（含 B6/B7/B8/B9/B10/B11/B12/B13/B14/B15/B16/B17/B18，hook 重映射/会话恢复后）=当次重建，禁止静默缺组运行（2026-11-24 task-session-regression-20261124 覆盖至 B11；2026-11-24 方案A/H3 覆盖至 B13；2026-11-24 task-two-stage-fix-20261124 覆盖至 B14；2026-11-25 压缩后核心任务丢失根治覆盖至 B15；2026-11-24 task-session-regression-20261124 覆盖至 B16；B17/B18 同属必重建项）。
5. mini 档豁免口径：B1 不豁免（修改后验证无小任务例外）；B2-B8、B14、B15、B16、B17、B18 随 mini 档既有豁免面（B1 仍不豁免；B16 合并回合属收尾环节，mini 可豁免但须在 progress 留痕说明豁免理由；B17/B18 与模板板块同步豁免）；**B14 在 mini/L0 口径下 = N/A，但必须有证据（写 findings 一行）**。**修复类请求命中 L0/mini/trivial/L0-E 一律先升 L1 standard 复核，再走两段式。**
6. 基线组固定清单唯一事实源=本文件；Rule 106.5（task-discipline）为规则锚，两处措辞漂移以本文件为契约面、规则文为语义面。B6/B7/B8 同步见 Rule 106.5（task-discipline）语义锚；B14 = 根因/风险线索包 + 后续任务已登记；B15 = 周期性偏移回顾（每 N 次工具调用读 user-session-log 原话 + periodic-review 对照，落 PASS/DRIFT 标记）；B16 = 合并回主分支+合并后回归核验（merge --no-ff/worktree 清理/verify 0 fail/selftest 不增 FAIL），证据读 plan-state.json isolation.merge_back。
7. B9-B11 同属基线组固定清单，唯一事实源=本文件、语义锚=Rule 106.5（task-discipline）；措辞漂移同样以本文件为契约面、规则文为语义面（2026-11-24 task-session-regression-20261124）。B14 同属基线组固定清单，唯一事实源=本文件、语义锚=Rule 106.5（task-discipline）。B16 同属基线组固定清单，唯一事实源=本文件、语义锚=Rule 106.5（task-discipline）。
8. B9-B11 完成判据=`git-baseline.sh` 写入的 sidecar 证据 `<plan-dir>/.git-baseline.json`，非 todo 勾选；勾选仅作执行视图留痕，sidecar 缺项=该基线项未完成（2026-11-24 task-session-regression-20261124）：
   - B9 任务开始前备份：`bash <skill>/scripts/git-baseline.sh snapshot <plan-dir>`
   - B10 修改后备份：`bash <skill>/scripts/git-baseline.sh checkpoint <plan-dir> --label <S-unit 或 Phase id>`
   - B11 Git 差异分析与处置：`bash <skill>/scripts/git-baseline.sh diff <plan-dir>`
9. B12/B13 同属基线组固定清单，唯一事实源=本文件、语义锚=Rule 106.5（task-discipline）；路由判定的文本事实源=`spec-mode.md` §1 路由表（运行时脚本 `check-spec-route.sh` 只读该表、不在运行时另立规则）。B12/B13 与 B9-B11 的 Git 基线语义不重叠，禁止以基线快照/备份/差异证据顶替技能到达或路由命中证据（2026-11-24 方案A/H3）。
10. B12/B13 完成判据与可复制命令（2026-11-24 方案A/H3；证据由 `sync-todos.sh --json` 的 `evidence`/`command` 字段带出，非 todo 勾选）：
    - B12 技能到达与承接收据：`bash <skill>/scripts/check-spec-route.sh --probe --dry-run`
      - 承接收据格式：`[sp-os-receipt] <skill> -> <artifact-path>`，写入 `findings.md` / `actions.md` / `task_plan.md` / `progress.md` 任一；例：`[sp-os-receipt] brainstorming -> docs/superpowers/specs/2026-11-24-x-design.md`。
      - 判据：仅有 `SKILL.md` 存在或 Read 记录 **不算完成**，必须同时登记技能名与该技能步骤产出物（brainstorming 选项/设计文档、systematic-debugging 根因报告、OpenSpec proposal/tasks 等）；缺收据 → evidence 空串 → 门不通过。
    - B13 Spec 路由命中终判：`bash <skill>/scripts/check-spec-route.sh --feature <需求特征> --no-dry-run --receipt-file <plan-dir>/route-receipts.jsonl`
      - 判据：`<plan-dir>/route-receipts.jsonl` 末行含 `route` 字段即终判留痕；命中路由却无该留痕 → Phase 禁 complete。init 期的 tier 粗筛收据由 `check-spec-route.sh --tier <tier>` 产出，与 B13 终判分级互补、不互相顶替。
11. B14 完成判据与可复制命令（2026-11-24 task-two-stage-fix-20261124；证据由 `sync-todos.sh --json` 的 `evidence`/`command` 字段带出，非 todo 勾选）：
    - B14 两段式根因/风险线索包登记：`bash <skill>/scripts/check-evidence-anchor.sh <plan-dir> --source=rootcause-followup`
      - 机器标记：修复类请求须用 `planctl add --section findings` 写 `[rootcause-followup:PASS] 线索包已落盘` 字面标记（非修复类无风险用 `[rootcause-followup:N/A]` + 理由），render 后自动进 findings.md 供消费门校验；禁只登记 tag 不写标记。
      - 判据：需线索包落盘（含根因/风险/证据路径）且后续任务已登记（计划/INDEX/todo 有可追踪项）；非修复类=N/A，必须在 findings 写一行证据说明为何 N/A。B14 与 B12/B13 语义零重叠，禁止以技能到达/路由收据顶替线索包证据。
12. B16 完成判据与可复制命令（2026-11-24 task-session-regression-20261124 续；证据由 `sync-todos.sh --json` 的 `evidence`/`command` 字段带出，非 todo 勾选）：合并回 master 用 `git merge --no-ff` + `git worktree remove <path>` + `git branch -d wt/<task-id>`（见 `worktree-isolation.md`）；合并后回归跑 `bash <skill>/scripts/run-selftests.sh --fresh` 不增 FAIL + `bash <skill>/lib/verify.sh` 0 fail；完成判据=plan-state.json `.isolation.merge_back` 含 `merged(`。

## 4. Hook 提醒响应协议

PostToolUse hook（`zcode-posttooluse.sh`）在检测到**计划文档超龄**（> `plan_update_interval_minutes`，默认 15 分钟）或**工具调用达到阈值**（`todo_sync_interval_calls`，默认 10）时，注入 `[plan-sync]` 提醒。**陈旧提醒触发后进入冷却**（`stale_remind_cooldown_calls`，默认 10 次调用内不再重复催）；已完结计划（outcome 为 COMPLETE/BLOCKED）不再提醒。收到提醒后必须立即执行三步：

```
1. planctl phase-done + add --section errors + render → 回写进度（Phase 状态 / Errors 经派生视图刷新）
2. TodoWrite / TaskUpdate   → 同步原生 Todo 状态
3. bash scripts/sync-todos.sh --index   → 刷新 INDEX.md（校验解析一致）
```

hook 提醒是**阻断性提示**：不响应则同一提醒会在后续调用中反复出现，且违反 Critical Rules（计划腐化 = 目标丢失）。

另有 UserPromptSubmit hook 在用户每条指令到达时注入 `[plan-note]` 提示（有活跃计划时）：提示先做 D/A/B/C 影响判定（D=新任务边界，Rule 8.1）——命中 D 类（与当前计划 Goal/范围/交付物均无关联）→ 为该新指令开新计划目录 `plans/{new-task-id}/`（init-session 全流程 + 新计划自己的 S1 映射），**旧计划的 Todo 映射原样保留**（旧计划 Phase/VC 继续推进，不删不改）；命中 B/C 按 S5 处理——计划变更三步同上（回写计划 → Todo 重映射 → INDEX 刷新）。

## 5. 命令速查

```bash
# Phase→Todo 同步报告（JSON，机器可读；agent 据此调 TodoWrite/TaskUpdate）
bash <skill>/scripts/sync-todos.sh --json

# 刷新 plans/INDEX.md（跨任务注册表；S4 / 恢复会话时必跑）
bash <skill>/scripts/sync-todos.sh --index

# 手动检测计划文档陈旧度（0=新鲜 1=STALE 需回写 2=无计划）
bash <skill>/scripts/check-doc-sync.sh [task_plan.md 路径] [最大陈旧分钟数]
```

阈值配置：`config.json#todo_sync_interval_calls` / `config.json#plan_update_interval_minutes`。

## 6. 反模式（禁止）

- ❌ 只建不同步：S1 建了 todo，之后 Phase 完成从不更新
- ❌ 单边操作：只改 task_plan.md 不动 todo，或只动 todo 不回写文档
- ❌ 用 todo 替代计划文档：todo 里写细节、plan 文档停在初始状态
- ❌ 双写漂移：同一进度同时维护 TodoWrite 和 Task 两套
- ❌ 忽略 `[plan-sync]` 提醒继续埋头干活
- ❌ 口头接受新指令：只应承、计划与 Todo 均不更新（违反 S5，后期执行漂移之源）
