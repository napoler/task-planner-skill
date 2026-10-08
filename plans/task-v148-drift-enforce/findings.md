# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1 [目标] 防偏移体系加强——把「防偏移容易失效」扭转为「必被检测、必被纠正、必留证据」
- R2 [目标] 根因面：现有触发依赖模型自觉（调研实证 0% 执行率）——须机械化触发与消费闭环
- R3 [目标] 「时刻记得纠正」——高频/常驻提醒（节奏化）+ Phase 级硬门控兜底
- R4 [手段] 载体复用 Rule 61 drift-checker 子代理（不另造执行体），纯增量接线

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### 2026-10-08 防偏移机制面盘点与失效取证（01-explore，主进程代落盘——子代理返回消息全文已蒸馏，检查点 subagent-state/01-explore.md 同步）

**A 面：机制面 18 项盘点——机械强制仅 2 项，其余 16 项全软性**（全表见检查点）
- 机械力仅：`check-drift.sh`（exit 1 但仅作 61.5 降级佐证、正常流程不跑）+ `selftest-drift-check-subagent.sh`（DCS-01~20 守护**措辞**不守护**执行行为**）
- 软性全清单：Rule 11（L37-46）/Rule 15（L57-74 含 15.1 触发表）/Rule 61（L716-725）/SKILL.md Phase 循环第 6 步/C4/Chain 交接第 4 步/B-C 类必派/[plan-note][plan-data] 注入（additionalContext 无拦截力）/Drift Log 纯模板/反模式行/task-drift-guard skill/ledger 无 drift 事件/config 无 drift 键/check-3file-gate 与 check-complete 不校验 drift 执行/pre-posttooluse hook grep drift=0

**B 面：失效取证（用户观察的数据实证）**
- **执行率 0%**：task-v141~v145 共 25 Phase / 85 todo，drift-checker 检查点 0 个、progress.md [DRIFT CHECK] 记录 0 处（证据：各 plans/task-v14*/subagent-state/ 目录枚举）；全 plans/ 93 任务仅 task-v085 一处手工 [DRIFT CHECK] 记录（plans/task-v085-task-type-mechanism-profile/progress.md:39）
- 历史偏移实例 ≥4：task-v075:215（三文件分流偏差）/task-v096:107（执行器违禁 git+虚构授权）/task-v095:130（子代理违禁 git）/task-v079:142（派发契约漂移连拦 3 次）——真实偏移靠运气与 [plan-compass] 兜住，非 drift-check 检出

**根因三连（设计输入）**
1. 触发全链无机械计数器/hook——Phase complete 后是否派发纯靠模型自觉，0% 实证不可靠
2. 判定结果无机器消费通道——ledger-append.sh:28 VALID_EVENTS 无 drift 枚举、check-3file-gate/check-complete 不查、Drift Log 纯模板无门控
3. selftest 守护错位——DCS 20 断言守护载体锚措辞，执行率无任何静态/行为断言

**接线锚点（64.x 条款挂载位，探明在位）**：H1 zcode-posttooluse.sh（计数器注入，v068 delegation-observe 注入+会话节流先例）/ H2 check-3file-gate.sh（Phase 门控追加条件）/ H3 ledger-append.sh:28 VALID_EVENTS / H4 config 无需新键（env 降档口）/ H5 check-complete.sh（终验统计可选）/ H6 userpromptsubmit [plan-note] 已有软提醒 / H7 selftest-drift-check-subagent.sh 扩展位

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->

### S1 执行回执（03-code-assistant）

- 变更：critical-rules.md 尾部追加 18 行（Rule 64 注释行+块头+引言段+64.1~64.6）；CHANGELOG.md `### 新增` 区顶部插入 2 行（task-v148 Rule 64 条目）；合计 20 行新增 / 0 行删除（纯增量）
- 锚点命中：`grep -c '^64\.[1-6] \*\*'`=6 / `grep -c '^### 64 '`=1 / CHANGELOG `grep -c 'Rule 64'`=1 / 全仓 diff 删除行=0
- 自验命令输出摘要：`git -C <worktree> diff --numstat` → `2 0 CHANGELOG.md` + `18 0 skills/task-planner/references/critical-rules.md`；逐字对照 rule64-draft.md §1/§7，What+Why 注释零删减
- 检查点：subagent-state/03-code-assistant.md（两里程碑全落盘）

### S2 执行回执（04-executor）

- 变更：ledger-append.sh +3/-1 行（:24 docblock drift_check 注释行 + :27 第 8 项注释行 + :28 VALID_EVENTS 值尾追加 ` drift_check`，1 行删除=VALID_EVENTS 原行被值尾追加替换，任务明确要求）；check-3file-gate.sh +83 行（docblock 第 6 条描述行 + drift_check_activity/drift_checkpoint_activity/drift_exempt_check 三函数 + 条件 6 段）；合计 86 行新增 / 1 行删除（既有条件 1-5 语义零改动）
- 锚点命中：`grep -c 'drift_check' ledger-append.sh`=3（VALID_EVENTS+两注释行）/ `grep -c 'Rule 64.2' check-3file-gate.sh`=8（docblock+条件段+三函数注释+env 降档注释）/ `grep -c 'drift_exempt_check' check-3file-gate.sh`=2（定义+调用）
- 自验命令输出摘要：ledger-append drift_check 写入成功且 grep 命中；gate 两态实测——无痕迹 exit 1 + stderr Rule 64.2 提示 / warn exit 0 / drift_exempt exit 0 / off exit 0 / ledger 痕迹 exit 0 / subagent-state mtime 兜底 exit 0；既有行为回归（不存在路径 + 空目录）与基线逐字一致
- 检查点：subagent-state/04-executor.md（最终结论已落盘）

### S3 执行回执（05-executor）

- 变更：zcode-posttooluse.sh +41 行 / -0 行（纯增量，`git diff --numstat` 删除列=0）——新增 `drift_rhythm_check()` 独立函数（emit() 之后）+ 主流程末段一处调用点（:241 写回 state 后、exit 0 前）；既有函数/主流程语义零改动
- 状态文件：`<plan-dir>/.drift-rhythm/<sidkey>.state`，两键 `count`/`last_inject`（纯文本两行，容错解析，缺文件/坏行按 0）；N=10 默认，env `TASK_PLANNER_DRIFT_RHYTHM_N` 覆盖；fail-open（解析失败/目录不可写/无 jq → 全段静默跳过，零 stdout）
- 注入文案（逐字）：`[drift-rhythm] 距上次偏移检查已 ≥N 次工具调用：活跃执行期按 Rule 15 派发 drift-checker（Rule 61 载体）并按 Rule 64.1 留痕三件套`；代码注释含 `Rule 64.3` 字面锚（供 selftest grep），注释按 Rule 45 What+Why 双层
- 自验命令输出摘要：AC1 静默态 stdout=[] exit=0；AC2 注入态 stdout JSON `jq -r .additionalContext` 含 `drift-rhythm` exit=0（state 更新 count 11 last_inject 11）；AC3 阈值覆盖 `TASK_PLANNER_DRIFT_RHYTHM_N=2` count=1→2 触发含 `≥2`；AC4 `git diff --numstat` 41 新增/0 删除；`bash -n` 语法通过；临时物已清理
- 检查点：subagent-state/05-executor.md（最终结论已落盘）

### S3b 执行回执（06-executor，22.3④ 主进程接管收尾）
- 修正：zcode-posttooluse.sh:177 sdir 定位迁至 plans 根（`$(dirname "$plan_dir")/.drift-rhythm`）+函数头注释同步；对齐条款 64.3 `<plans>/.drift-rhythm/` 会话级语义；plan 任务目录不再被运行态状态污染
- 验证（主进程 12:46）：注入链 plans 根触发 ✓ / 写回 count 11·last_inject 11 ✓ / plan 目录零残留 ✓ / 静默链 0 字节 ✓ / bash -n OK ✓
- 过程：executor 派发后 19min 零检查点滞留 → TaskStop → 22.3④ 接管（核实代码已完成，补验证+簿记）

### S4 执行回执（07-code-assistant）

- 变更：SKILL.md +2/-1 行（① Phase 循环第 6 步 [DRIFT CHECK] 块内、`**DRIFT CHECK 触发时机（强制）**` 行之前插入 64.1 留痕三件套行 1 行；② 合规清单 C4 行末追加「；留痕三件套已落实（Rule 64.1，缺一=未执行）」——C4 行在 ` | ☐ |` 表格分隔前原位改写，既有措辞逐字保留，纯行末增量语义）；companion/agents/drift-checker.md +1/-0 行（判定纪律段后追加「判定输入三锚（Rule 64.4）」1 行）
- DCS 前后基线：写前 `selftest-drift-check-subagent.sh` 20/20 PASS（FAIL=0）→ 写后复跑仍 20/20 PASS（FAIL=0），DCS-01~20 字面锚零破坏实证
- 锚点命中：`grep -c '64.1 留痕三件套' SKILL.md`=1 / `grep -c '留痕三件套已落实' SKILL.md`=1 / `grep -c '判定输入三锚' drift-checker.md`=1
- 自验命令输出摘要：`git diff --numstat` → SKILL.md `2 1`（1 行删除=C4 行原位改写，删除行与保留行逐字一致仅行末追加；第 6 步为纯插入）/ drift-checker.md `1 0`；既有 label（`drift-checker 子代理偏移检查`、`Rule 61 载体` 等）零触碰
- 过程备注：C4 行首次编辑一度错配多出一个全角右括号（双 `）`），当次自检 diff 发现并回正，终态逐字对照 rule64-draft.md §4.1 验收
- 检查点：subagent-state/07-code-assistant.md（DCS 基线+最终结论两落盘）

### S5 执行回执（08-executor）

- 变更：新建 `scripts/selftest-drift-enforcement.sh`（61 行，DCE-01~16 全 16 条断言：静态 grep DCE-01~10 + 行为 fixture DCE-11~16）；`scripts/selftest-registry.tsv` 追加 1 行登记（Rule 64.5 机制守护面）
- 验收证据：`bash -n` 语法通过；全量运行 `Total: 16 PASS=16 FAIL=0` exit 0；`wc -l` = 61 行（目标 <=110）
- 负例自查：DCE-04 grep 目标临时改为 `Rule 99.9` → `FAIL DCE-04 (条件段缺失)` + `Total: 16 PASS=15 FAIL=1`；改回 `Rule 64.2` 后复跑全 PASS
- 修复记录：CHANGELOG.md 路径 `../` → `../../../`（仓根）；DCE-16 fixture 补全 plan 三件套（task_plan.md/findings.md/progress.md）
- 检查点：subagent-state/08-executor.md（最终结论已落盘）

### S7-fix 执行回执（12-executor）

- 变更：F1-F7 全部修复，F8 规格固有不动
  - F1(MAJOR): check-3file-gate.sh 条件 6 补 `plan_tier: mini` 豁免出口（drift_exempt 后、env 降档前）
  - F2(MINOR): selftest-drift-enforcement.sh 补 DCE-17（off 档）+ DCE-18（mini 豁免），Total 16→18
  - F3(MINOR): selftest-drift-enforcement.sh fixture Started 改运行时 date 生成（`date -d '-1 hour'`）
  - F4(MINOR): selftest-drift-enforcement.sh DCE-16 SID 改随机（`dce16$$`）
  - F5(MINOR): zcode-posttooluse.sh emit+drift_rhythm_check 函数定义整体前移至 plan 解析成功后，删原函数定义和末尾调用（函数体零改动）
  - F6(MINOR): ledger-append.sh docblock 枚举补 `| drift_check`
  - F7(MINOR): drift-checker.md 追加行改列表项（空行+`- ` 前缀）
- 验收证据：
  - `bash skills/task-planner/scripts/selftest-drift-enforcement.sh` → `Total: 18 PASS=18 FAIL=0`
  - `bash skills/task-planner/scripts/selftest-drift-check-subagent.sh` → `Total: 20 PASS=20 FAIL=0`
  - `bash skills/task-planner/scripts/selftest-four-file-dataflow.sh` → `Total: 18 PASS=18 FAIL=0`
  - hook 两态：注入触发（stdout 含 drift-rhythm）+ 静默 0 字节
  - 分支命中场景：优先级 4 命中时 drift 计数仍自增（count 10→11）
  - `bash -n` x3 全通过
  - `git diff master --numstat` 无新增删除行（删除行来自 S1-S6 既有改动和 F5 函数定义移动）
- 硬约束：F1 新增判断不动既有函数体 PASS；F5 仅移动+删一行 PASS；critical-rules.md 零改动 PASS；主仓只读 PASS；禁 git 写 PASS
- 检查点：subagent-state/12-executor.md（最终结论已落盘）

### S7-fix2 执行回执（15-general）

- 入场事实更正：前次派发**非零落地**——worktree 内 zcode-posttooluse.sh 已含 F9/F10 修复草案（due 第三键 + 末尾延迟 emit），
  selftest 已扩至 21 断言（DCE-19/20/21）；但复跑暴露 2 处真实 FAIL，草案未闭环，本轮补齐。
- 修复（仅 2 文件，最小侵入）：
  - F9：保留「判定提前、emit 延后」结构——早调用只计数并把 `due=1` 写入 state（不 emit），末尾（所有优先级分支之后）
    统一 emit 并清 due → 单次调用 stdout ≤1 行 JSON。
  - F10 根因修复：早调用写 due=1，但既有 `:147`（mtime>24h）/`:150`（task_plan.md outcome）/`:155`（verification.md outcome）
    静默守卫直接 exit 0，永远到不了末尾 end-emit，due 残留。新增「F10 完结/超龄 → 清 due」块，置于 `age` 计算后、
    `:147` 早退前，同条件重查，只清状态零 stdout，既有分支/守卫零改动（含 Rule 64.3 + Rule 45 What/Why 注释）。
  - DCE-20 fixture 修正：`- **Outcome:** COMPLETE` → `- **outcome: COMPLETE**`。既有守卫正则
    `outcome: *(COMPLETE|BLOCKED)` 要求值紧随 `outcome:`；仓内真实约定即 `- **outcome: COMPLETE**（...）`
    （grep plans/*/task_plan.md 实证），旧 fixture 格式不匹配致守卫不触发、emit 188 字节。
- 验收证据（可复现）：
  - `bash -n zcode-posttooluse.sh` → OK
  - `selftest-drift-enforcement.sh` → `Total: 21 PASS=21 FAIL=0`
  - `selftest-drift-check-subagent.sh` → 20/20；`selftest-four-file-dataflow.sh` → 18/18；`selftest-registry.sh` → 5/5（rows=61=actual）
  - 独立复现 reviewer 12-call 路径（rhythm N=10 + todo_n=10 同频）→ `MAXLINES=1`（master 曾在 call10=2 行）
  - 独立 F10 三场景（task_plan.md outcome COMPLETE / verification.md outcome COMPLETE / mtime>24h）→ 均 `bytes=0 且 due=0`
- 硬约束：仅动 zcode-posttooluse.sh + selftest-drift-enforcement.sh；主仓只读；禁 git 写；critical-rules.md 零改动。PASS
- 检查点：subagent-state/15-executor.md（最终结论已落盘）

### S7-fix3 执行回执（17-general）

- 目标：修终审 N1[阻断]——rhythm 投递饥饿（默认 N=10 与 todo_sync=10 相位锁定时 [drift-rhythm] 永不投递）。
- 根因链（复述 16-code-reviewer）：早调用写 due=1 → 该轮优先级 1-4 命中即 exit 0，到不了末尾 end-emit →
  due 残留；下一轮早调用 count-last_inject<N 走 else，旧代码无脑写 due 0 把残留位 clobber → 提醒永久丢失。
- 修法（Option C：due 持久化，仅 1 逻辑点 + 注释）：
  - zcode-posttooluse.sh `drift_rhythm_check`（早调用）：写 state 前先读回既有 due 位（读-改-写，防 clobber）；
    阈值命中轮置 due=1，未命中轮原样保留既有 due 写回。旧两键 state（无 due 键）按 0 容错。
  - end-emit 块逻辑零改动（due=1 即投递并清零）；F10 完结/超龄清 due 块零改动。
  - 效果：分支命中轮 due 留存，下一（或下几个）无分支调用轮由 end-emit 投递——延迟数调用而非饥饿；
    分支消息零改动零吞没（due 每轮至多 1，单轮仍 ≤1 行）。
  - 注释：新增/修改逻辑均含 `Rule 64.3` + Rule 45（What+Why）；函数头「两键」更正为「三键 count/last_inject/due」。
- 验收证据（可复现）：
  - `bash -n zcode-posttooluse.sh` / `bash -n selftest-drift-enforcement.sh` → OK
  - `selftest-drift-enforcement.sh` → `Total: 23 PASS=23 FAIL=0`（新增 DCE-22 跨分支轮持久化投递、DCE-23 相位锁定 30 调用投递≥2）
  - 独立 harness（mktemp 隔离，非采信 selftest）：同 fixture 30 次连续调用 → 修复版 `delivered=2`，pre-fix 对照版
    （仅把 else 的 `due %s`→`due 0` 一行还原）`delivered=0`；两版 diff 仅此 1 行。
  - 单轮单 JSON 不回退：DCE-19（threshold-due + 优先级 4 同轮 → 1 行合法 JSON）；DCE-22 轮1 断言 lines=1 且 due 保留=1。
  - F10 不回退：DCE-20（task_plan.md outcome COMPLETE）、DCE-21（mtime>24h）→ 均 bytes=0 且 due=0。
  - 回归：`selftest-drift-check-subagent.sh` → 20/20；`selftest-four-file-dataflow.sh` → 18/18；`selftest-registry.sh` → 5/5（rows=61=actual）。
- 硬约束：仅动 zcode-posttooluse.sh + selftest-drift-enforcement.sh；主仓只读；禁 git 写；critical-rules.md 零改动。PASS
- 检查点：subagent-state/17-executor.md（最终结论已落盘）

### N2-fix 执行回执（18-general）

- 目标：CR 终审 N2（非阻断 minor）——critical-rules.md Rule 64.3 条款内状态文件描述「两键 {count,last_inject}」与实现三键（含 due）不一致，行内同步。
- 落点：worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v148-drift-enforce`，仅 `skills/task-planner/references/critical-rules.md` 第 777 行（Rule 64.3，本任务自产块）。
- 改法（行内改写，1 行重算，行数 783 不变）：
  - 状态描述：`（两键 `{count, last_inject}`，fail-open：…）` → `（三键 `{count, last_inject, due}`，due=待投递标志——分支命中轮延迟投递的持久位；fail-open：…）`
  - 同句尾「性能约束：状态文件两键读写 O(1)」→「状态文件三键读写 O(1)」。
    （注：为满足验收②「grep '两键' 0 命中」，同一行内第二处「两键」必须同步；任务正文「仅此一处措辞」与此处措辞同属 64.3 键数描述，故一并改。）
- 验收证据（可复现）：
  - ① `grep -n '三键' critical-rules.md` → 777 行命中新表述；`grep -o '三键 `{count, last_inject, due}`' | wc -l` = 1。（文件级 286 行另有既有无关「三键独立」属 Rule 29.5，绝对「命中 1」预存不可达。）
  - ② `grep -c '两键' critical-rules.md` = 0。
  - ③ `bash skills/task-planner/scripts/selftest-drift-enforcement.sh` → `Total: 23 PASS=23 FAIL=0`（DCE-02 子条锚 `^64\.[1-6] \*\*`=6 仍在）。
  - ④ `git diff --numstat` 该文件 → `18 0`（0 删除行）；`wc -l` = 783（改前改后一致，无净新增行）。
- 硬约束：仅改 64.3 行内键数措辞；禁 git 写；主仓只读；task_plan.md/progress.md 零改动。PASS
- 检查点：subagent-state/19-executor.md（最终结论已落盘）

### align-fix 执行回执（20-general）

- 目标：R1「对防偏移进行加强」——alignment-review P2 两处联动同步（本任务自产文本的陈旧锚/枚举），仅这两处。
- 落点：worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v148-drift-enforce`
  - `skills/task-planner/references/critical-rules.md` 第 781 行（Rule 64.5，同 1 行内两处）
  - `skills/task-planner/scripts/zcode-posttooluse.sh` 第 88 行（容错注释残留「两键」）
- 改法（行内改写，逐字同步）：
  1. Rule 64.5 陈旧行锚：`VALID_EVENTS 增 \`drift_check\` 枚举（:28 尾部追加，既有枚举零改动）` → `（值尾追加，锚行随实现漂移以 grep VALID_EVENTS 为准，既有枚举零改动）`
  2. Rule 64.5 陈旧枚举：`静态断言 DCE-01~10 + 行为级 fixture DCE-11~16` → `静态断言+行为级 fixture（DCE-01~23，随守护面演进）`
  3. hook 注释：`旧两键 state（无 due 键）` → `三键 state {count, last_inject, due}（due=待投递持久位；缺 due 的旧 state）`（与 N2 同款语义）
- 验收证据（可复现）：
  - ① `grep -c ':28 尾部追加' critical-rules.md` = 0；`grep -c 'DCE-01~23' critical-rules.md` = 1
  - ② `grep -c '两键' zcode-posttooluse.sh` = 0
  - ③ `selftest-drift-enforcement.sh` → `Total: 23 PASS=23 FAIL=0`；`selftest-drift-check-subagent.sh` → `Total: 20 PASS=20 FAIL=0`（均无回退）
  - ④ `bash -n zcode-posttooluse.sh` → OK
- 硬约束：仅动这两文件这两处；主仓只读；禁 git 写；task_plan.md/progress.md 零改动。PASS
- 检查点：subagent-state/20-executor.md（最终结论已落盘）

### dce10-fix 执行回执（21-general）

- 目标：R1「对防偏移进行加强」——部署位实弹验证暴露 DCE-10 布局差异 FAIL（CHANGELOG 为仓级文件，部署位无此文件），做布局自适应微修。
- 落点：worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v148-drift-enforce`
  - `skills/task-planner/scripts/selftest-drift-enforcement.sh` 第 29 行 DCE-10 断言（单处，+5 行注释 + if/else 包裹，净 +6/-1）
- 改法（逐字采用规格）：原 `[ "$(cnt 'Rule 64' "$CHANGELOG")" -ge 1 ] && ok ... || bad "DCE-10" "条目缺失"` 单行
  → `if [ -f "$CHANGELOG" ]; then <原断言>; else ok "DCE-10 ...（SKIP：部署布局无仓级 CHANGELOG）"; fi`；Total 行逻辑未动（SKIP 计 PASS，总数恒 23）。
- 验收证据（可复现）：
  - ① 仓源运行：`bash skills/task-planner/scripts/selftest-drift-enforcement.sh` → `Total: 23 PASS=23 FAIL=0`，exit=0
  - ② 部署布局模拟（临时 `mv CHANGELOG.md CHANGELOG.md.dce10tmp` 后跑，跑完 `mv` 还原）→ DCE-10 行 = `PASS DCE-10 CHANGELOG 含 Rule 64（SKIP：部署布局无仓级 CHANGELOG）`，`Total: 23 PASS=23 FAIL=0`，exit=0；CHANGELOG.md 已还原（46121 字节，git status 无改动）
  - ③ `bash -n skills/task-planner/scripts/selftest-drift-enforcement.sh` → syntax OK
  - ④ DCE-01~09/11~23 两次运行逐行输出完全一致（仅 DCE-10 在无 CHANGELOG 时呈现 SKIP 变体）
- 硬约束：仅动这一文件这一处（`git status --short` 仅 1 文件、`git diff --stat` 1 file changed 6 insertions(+)/1 deletion(-)）；禁 git 写；主仓只读；task_plan.md/progress.md 零改动。PASS
- 检查点：subagent-state/22-executor.md（最终结论已落盘）
