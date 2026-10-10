# Design Draft — task-v156 Rule 73 执行期决策对齐与不变量纪律（防漂移强化）

<!--
  WHAT: 本文件=task-v156 Phase 1 设计定稿稿，Phase 3 五个 S-unit 的全部逐字采用源。
  WHY: 用户 2026-10-10 03:3x 三连发反馈（R1-R6）的机制化设计——决策点未回读设定即下手、
       四文件无「哪些不变/可变/学得」显式声明、被否内容散落正常文档三类根因的修复方案。
  WHEN: Phase 3 S1-S5 派发时随任务书注入；裁决变更必须回改本文件并登记 Decisions Made。
-->

## §0 侦察结论（插入锚 + 冲突面，2026-10-10 09:5x 一手取证）

### 0.1 插入锚（master 现实态，HEAD=8fd9d92）

| 目标文件 | 插入锚（file:line） | 事实 |
|---------|---------------------|------|
| references/critical-rules.md | 文末 :942（Rule 71 段结束=EOF） | Rule 67-69/71 均 `### NN` 标题+`NN.x` 内联编号（Rule 70 为 `## Rule NN`+`NN.x` 二级标题的异形，后随多数范式=Rule 71 形）；规则账本 71=landed(v158)、72=reserved(v160 在途)、**73 空闲** |
| SKILL.md | :9 全集计数行 | 存量缺陷：停在「1-69+70」（v158 加 Rule 71 时漏改）——本任务 S2 一并修复 |
| SKILL.md | :295 详见行 / :355 Rule 71 摘要 bullet / :381 References 行 | 三处计数/摘要级联点 |
| SKILL.md | C 清单 :230-231（C49=v152、C50=v158） | 新合规行=C51（master 现实态 tail） |
| scripts/check-complete.sh | :1323 goal-gate 段后 | [judge-gate] 插入位（standard/full 档 warn 默认、env 升 enforce，范式同 goal-gate 档位三分支） |
| scripts/zcode-posttooluse.sh | :336-345 due=1 emit 块 | [judge] 提醒随 drift-rhythm 同发（单行 JSON 携带追加行，env `TASK_PLANNER_DECISION_JUDGE=off` 降档，范式同 :341-347 [context-pressure]） |
| templates/task_plan.md | :20 根源覆盖表后 / :30 Goal 前 | 「🔒 不变量声明区」区块插入位 |
| templates/（新）deprecated.md | — | 新建（第 5 类计划文件=废弃隔离区，Rule 73.5 载体） |
| scripts/selftest-registry.tsv | :71 末行后 | +1 行（decision-drift 域） |
| 仓根 CLAUDE.md:33 / README_zh.md:136,229 | 「Rules 1-71」标签 | v158 已改 1-71；本任务级联至 1-71+73（同族手法） |

### 0.2 冲突面与规避

1. **v160 在途占 Rule 72**：其 SKILL 接线将把 :9 计数改「1-72」——本任务写「1-71+73」保持并集可解（v152 三轮并集判例：标签并集+C 编号让位链），合并期按 master 现实态取并集，selftest 断言用宽锚（`1-7[0-9]` 族）不钉死单形态。
2. **v159/v160 worktree 并行在飞**：建仓前对账 master HEAD；合并用 smart-merge-back.sh 智能门。
3. **SKILL:9 存量漏改**：S2 顺手修复（1-69+70 → 1-71+73），selftest 加宽锚断言防再次漂移。
4. **config.json 零新键**：现 properties=42；[judge] 门与 hook 注入均用 env 降档（TASK_PLANNER_DECISION_JUDGE），终验断言 properties=42 不变。
5. **attest 机械门**（本会话实证）：派发型 Phase 必须 S-unit 表（22.6/59.1/68.1 列）——计划已锁前补齐；表格单元格禁裸 `|`（awk 列漂移实证：`\|` 转义也被拆列，验收描述改用「grep -e 分次计数」措辞）。

---

## §1 Rule 73 条款草案（S1 逐字采用——critical-rules.md 文末追加，禁改既有条款）

```
### 73 执行期决策对齐与不变量纪律（防漂移强化 — task-v156，目标：把用户 2026-10-10 三连发反馈（长会话执行严重漂移实证=调研 6 分钟假完成/视频剪纸风格被改 3D 风/参考母图逻辑违背；四文件无「哪些不变/哪些可变/哪些学得」显式声明；被否/推翻/旧版内容散落正常文档）制度化为「决策点分类→对齐三问→三态标注→强制评判→废弃隔离→消歧义」六位一体闭环，根除「决策点未回读设定即下手」类漂移；判定面=LLM 行为留痕（[align]/[judge] 行）+check-complete [judge-gate]+posttooluse 节奏注入+selftest-decision-drift.sh 静态守护、零新 config 键；衔接 Rule 29/30/31/32/51/58/65/67/68/69/70 与在途 Rule 72（task-v160），既有条款原文零改动）

73.1 **变更型决策点定义（decision-point taxonomy）**：执行期遇以下任一动作即=变更型决策点，动手前必须过 73.2 对齐三问——① 改变已确认交付物的风格/形态/结构/参数（判例：用户要求剪纸风格视频，执行体擅自改 3D 风=直接触碰风格不变量）；② 变更任务范围（砍需求/加需求/改验收标准）；③ 接受用户新需求并入当前任务（先按 Rule 8.1 完成 D/A/B/C 类影响判定再对齐）；④ 推翻/否决/采信可疑结论（含采信子代理自报 done 前的复核结论、把未验证推测当事实）；⑤ 宣称「调研/分析/检查已完成」并准备收口（Rule 51.8 未测试就声称完成禁令的对齐侧前置）。判定存疑（某动作是否算变更型）→ 按 Rule 69.1 T1 委派 decision-arbiter 定级，禁自行降格为「普通执行步骤」跳过对齐（降格=漂移主通道，用户 R4 实证）。

73.2 **对齐三问与 [align] 留痕（alignment three questions）**：变更型决策点按下述三问逐项作答，并立即落盘 progress.md `[align]` 行（三问答案+依据锚点，缺一问=对齐未完成，禁止进入实施）——① **读什么**：回读 task_plan.md「🔒 不变量声明区」（73.3）+对应用户需求原文（Rule 51.1 R 条目）+相关 findings.md 结论+notepad「🚫 被否决方案」段（Rule 32.2），列出本决策可能触碰的不变量清单；② **判什么**：逐条判定=不变量内执行（可变量调整=直接做+登记）还是触碰不变量（STOP：按 Rule 28 选项化呈报用户，或按 Rule 72 分级判断归属——Rule 72 由 task-v160 在途落地，未落地前一律按 Rule 28 呈报，禁静默修改）；③ **验什么**：实施后对照不变量声明复验（grep/Read/diff 至少一种），确认未违反并在同一 [align] 行附证据锚（54.0 有依据原则）。用户显式指令（宪法 P0-1）要求变更时=走「不变量更新流程」（更新声明区+登记指令来源与时间），不是跳过三问的理由；指令与禁令冲突→Rule 32.4 处置或 Rule 28 D6 硬停。

73.3 **三态标注与🔒不变量声明区（tri-state annotation）**：每份 task_plan.md 必须含「🔒 不变量声明区」区块，把任务要素显式分为三态——🔒 **不变量**（Goal/VC 表/用户需求原文 R 条目/风格与质量约束/已确认的技术选型；声明后任何改动必须走 73.2 全流程）；🔀 **可变量**（执行细节/工序排期/工具选型/S-unit 拆分；主进程可自主调整+progress.md 登记）；📈 **学得量**（执行期新发现的事实/教训/锚点；只入 findings.md 与 notepad-learnings.md，禁止反向改写不变量——改写=73.2 触发）。区块在 templates/task_plan.md 预置（新建计划 init 时带入），存量计划在下次重规划/编辑时补建（warn 档适配，防 legacy 误伤）。三态词条口径=消歧义示范（73.6）。

73.4 **强制评判点与 [judge] 留痕（mandatory judge points）**：Rule 65 周期回顾管「节奏面」（每 N 次调用），本条补「事件面」强制评判——① 每个变更型决策点实施完成后立即一次 [judge] 评判（三问是否执行+不变量是否守住+[align] 行是否齐备）；② 每个 Phase 标记 complete 前一次（与 64.2 门同层）；③ worktree 合并回前一次（防漂移产物合进主干）。评判结论（守住/违反+违反项+处置）落 progress.md `[judge]` 行；发现违反→STOP 按 65.4 自动纠正+报告用户，禁带病推进。机器承载=scripts/check-complete.sh [judge-gate]（standard/full 档，warn 默认，env `TASK_PLANNER_DECISION_JUDGE=enforce` 升级为 exit 1 阻断、`=off` 跳过）+scripts/zcode-posttooluse.sh 单行节奏注入（随 drift-rhythm due 同发，单行 JSON 双段约束同 Rule 67.5）。

73.5 **废弃内容只入不出（deprecated quarantine）**：被否决/被推翻/旧版内容（过期锚点、失效结论、旧版方案文本、废弃产物指针）唯一存放点=计划目录 `deprecated.md`（模板=templates/deprecated.md 五段结构）。登记条目五要素=原内容指针（file:line/URL）+废弃类型（否决/推翻/旧版）+废弃原因+日期+替代锚（新结论或新路径，无则显式写「无」）；只入不出=禁止删除/改写既有废弃条目（留痕可追溯，29.2a superseded 语义延伸到产物面）；正常四文件罗盘（task_plan/findings/progress/notepad）正文禁止混放废弃内容——发现残留=迁移入 deprecated.md 并在原位置留指针。分账口径：notepad「🚫 被否决方案」段（Rule 32）=veto 决策登记处（方案+否决原文+适用范围）；deprecated.md=被推翻的产物/旧版结论/过期锚的隔离区；两者互补不重叠。消费侧=提方案/写条款/改文件前必查 deprecated.md+notepad 双源（同 Rule 32.2 禁令源扫描面）。

73.6 **消歧义表述纪律（disambiguation）**：产生歧义的表述=禁止裸奔——歧义词后必须带解释层（同义词/判据/反例三者至少其一，示例：「不变量（invariant，指 Goal/VC/用户原话类声明后改动须走 73.2 的条目；反例=可变量）」）；新建条款/模板/派发任务书中的术语默认首现带解释；验收标准禁「确保质量/基本可用」类不可测表述（可观察判据口径同 Rule 66.1 验证方式列）；对齐与废弃两模板词条均按本条示范带解释（防下游理解分叉=用户 R5「为犯错堵住漏洞」）。

73.7 **机制（mechanism）**：零新 config 键（沿用 64.5/67.5 env 降档范式，env=`TASK_PLANNER_DECISION_JUDGE`，off/enforce 两档降升）；机器面=scripts/selftest-decision-drift.sh 静态守护（73.1-73.7 子条锚/🔒 三态区块锚/deprecated.md 五段锚/[align] 与 [judge] 留痕格式锚/check-complete [judge-gate] 锚/posttooluse 注入锚/SKILL 接线与计数 1-73/C51 合规行/registry 登记行/零新键负断言）+selftest-registry.tsv 登记；合规清单 C51（SKILL.md 消费侧，C50 由 task-v158 占用本任务顺延）；**机器边界如实披露**：73.1 决策点分类与 73.2 三问执行的语义面不可静态机检——selftest 只锚定规则条/模板区块/留痕格式/门控接线存在性，运行时对齐与评判由 LLM 行为留痕（[align]/[judge] 行）+check-complete 事后对照承载，本机制不声称自动判对齐。
```

---

## §2 templates/deprecated.md 五段草案（S3 逐字采用，新建文件）

```
# Deprecated — 废弃内容隔离区（Rule 73.5 只入不出）
<!--
  WHAT: 本文件=被否决/被推翻/旧版内容的唯一存放点（计划级第 5 文件，与四文件罗盘互补）。
  WHY: 用户 2026-10-10 R6 实证——被否内容散落 findings/progress/notepad 正文，正确错误混放致理解混乱；
       Rule 73.5 规定废弃内容只入不出+正常四文件禁混放，本模板=该规则落点载体。
  WHEN: 任何内容被判「否决/推翻/旧版」时，按 §1 登记表五要素迁入本文件，原位置留指针；只入不出。
  与 notepad 分账：notepad「🚫 被否决方案」段（Rule 32）=veto 决策登记处；本文件=产物/结论/旧版锚隔离区。
-->

## 1. 废弃条目登记表
<!-- 五要素=原内容指针(file:line/URL)+废弃类型(否决/推翻/旧版)+废弃原因+日期+替代锚；只入不出=禁删除/改写既有条目 -->
| 条目ID | 原内容指针 | 废弃类型 | 废弃原因 | 日期 | 替代锚 |
|--------|-----------|---------|---------|------|--------|
| DEP-001 | <原内容所在文件+行号或 URL> | <否决/推翻/旧版> | <一句话原因+依据锚> | <YYYY-MM-DD> | <新结论/新路径，无则写「无」> |

## 2. 分账说明（与 notepad/四文件罗盘的边界）
- notepad「🚫 被否决方案」段（Rule 32）=用户否决的方案决策登记处（方案描述+否决原文+日期+适用范围）。
- 本文件=被推翻的产物/旧版结论/过期锚点/废弃产物指针的隔离区（Rule 73.5）。
- task_plan/findings/progress 正文禁止混放废弃内容；发现残留=迁移入本表+原位置留指针（如「已废弃，见 deprecated.md DEP-00N」）。

## 3. 只入不出规则
1. 只追加登记，禁删除/禁改写既有废弃条目（留痕可追溯，对齐 Rule 29.2a superseded 语义延伸到产物面）。
2. 新废弃内容=新增行（条目ID 递增 DEP-NNN），禁覆盖/合并旧行。
3. 原位置保留指针一行，确保从正确内容可追溯到废弃记录（双向可追溯）。

## 4. 消费侧契约（改动前必查双源）
提方案/写条款/改文件/验收结论前，按 Rule 32.2 禁令源扫描面同款，必查：① 本文件全表；② notepad「🚫 被否决方案」段。命中=禁止把废弃内容当可行方案重新引入（Rule 32.4 解禁条件同款：用户显式撤销或可引用新证据+标注否决出处）。

## 5. 消歧义词条（Rule 73.6 示范）
- **废弃类型「否决」**：用户显式不允许/禁止的方案（登记同步 notepad，双源都在）。
- **废弃类型「推翻」**：执行中被新证据/新结论取代的旧结论或旧产物（无用户否决动作）。
- **废弃类型「旧版」**：任务演进后被替换的旧版文本/锚点/参数（如旧版模板段落、过期计数标签）。
```

---

## §3 templates/task_plan.md「🔒 不变量声明区」草案（S2 逐字采用，插 :20 根源覆盖表后）

```
## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
<!-- WHAT: 任务要素显式分三态——不变量(锁)/可变量(自主调+登记)/学得量(只入 findings、禁反写不变量)。
     WHY: 用户 R2「强化四文件，确保哪些不变/哪些可变/哪些学得」；无声明=执行期风格/范围漂移无对照物（R1 实证）。 -->
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | <Goal/VC 表/用户需求原文 R 条目/风格与质量约束，逐条列> | <task_plan.md 对应章节锚> |
| 🔀 可变量 | <执行细节/工序排期/工具选型/S-unit 拆分> | - |
| 📈 学得量 | <执行期新事实/教训/锚点→findings.md/notepad-learnings.md；禁反向改写不变量> | findings.md |
```

> v156 本计划同款区块随 Phase 6 前补建入 plans/task-v156-drift-shield/task_plan.md（dogfood，51.7 登记+重锁）。

---

## §4 D4 双承载施工图（S4 逐字采用）

### 4.1 check-complete.sh [judge-gate]（插 :1323 goal-gate 段后）

```bash
    # [2026-10-10 task-v156] Rule 73.4 [judge-gate] 强制评判点终验对照段
    # WHAT: standard/full 档计划对照 progress.md [judge]/[align] 留痕行数—— Phase complete 前
    #       强制评判（73.4②）未留痕=评判未执行；warn 默认提示，env TASK_PLANNER_DECISION_JUDGE=enforce 升 exit 1。
    # WHY: 用户 R3「周期性评判数据、及时发现错误」+R4「每次做出决定/更改前对齐设定」的机器承载面。
    # 档位: 仅 plan_tier: standard|full 进入（mini 档豁免，同 goal-gate 门控范式）;env TASK_PLANNER_DECISION_JUDGE = off(跳过)/enforce(缺失 exit 1)/默认 warn(提示不阻断)
    # [2026-10-10 06b 修正] 计数行鲁棒化：grep -c 零匹配已打印 0 且 exit 1 → `|| echo 0` 会捕获
    #       "0\n0" 致 [ -eq ] 报错、闸门对失败面静默失效；改 `|| true`+case 兜底（覆盖文件缺失/空值）
    # [2026-10-10 CR S8 修正] 档位门控补全（MAJOR）：按 goal-gate 同款 grep plan_tier 前置门,
    #       mini/legacy 计划走 SKIPPED 分支——否则 warn 对 mini 误报、enforce 对 mini exit 1 违背 C51「mini 档豁免」契约
    if grep -qm1 -E 'plan_tier:[[:space:]]*(standard|full)' "$PLAN_FILE" 2>/dev/null; then
      case "${TASK_PLANNER_DECISION_JUDGE:-warn}" in
        off) printf '[judge-gate] SKIPPED (env TASK_PLANNER_DECISION_JUDGE=off)\n' >&2 ;;
        enforce|warn)
          _jl="$(grep -c '\[judge\]\|\[align\]' "$PLAN_DIR_GUESS/progress.md" 2>/dev/null || true)"
          case "$_jl" in ''|*[!0-9]*) _jl=0 ;; esac
          if [ "$_jl" -eq 0 ]; then
            printf '[judge-gate] ✗ progress.md 无 [judge]/[align] 留痕行 (Rule 73.4: 变更决策后/Phase complete 前/合并回前各一次评判)\n' >&2
            [ "${TASK_PLANNER_DECISION_JUDGE:-warn}" = enforce ] && exit 1
          else
            printf '[judge-gate] OK ([judge]/[align] 留痕 %s 行, Rule 73.4)\n' "$_jl" >&2
          fi
          ;;
      esac
    else
      printf '[judge-gate] SKIPPED (mini 档豁免或计划无 plan_tier: standard|full 标记, Rule 73.4/C51)\n' >&2
    fi
```

### 4.2 zcode-posttooluse.sh [judge] 节奏注入（改 :336-345 due=1 emit 块，随 drift-rhythm 同发）

```bash
    _jr=""
    if [ "${TASK_PLANNER_DECISION_JUDGE:-on}" != "off" ]; then
      _jr="$(printf '\n%s' '[judge] 变更型决策点评判（Rule 73.1/73.4）：凡改风格/范围/采信可疑结论/收口声称前过对齐三问（73.2）并留 [align]/[judge] 行')"
    fi
    emit "[drift-rhythm] 距上次偏移检查已 ≥${rhythm_n} 次工具调用：活跃执行期按 Rule 15 派发 drift-checker（Rule 61 载体）并按 Rule 64.1 留痕三件套${_cp}${_jr}"
```

> 单行 JSON 双段约束同 Rule 67.5；env=off 时零追加（向后兼容旧行为）。

---

## §5 selftest-decision-drift.sh 断言清单（S5 逐字采用，DD-01~22 全 PASS）

| # | 断言 | 判据 |
|---|------|------|
| DD-01 | CR 块头 `^### 73 执行期决策对齐与不变量纪律` | grep ≥1 |
| DD-02 | 七子条 `^73\.[1-7] ` | =7 |
| DD-03 | 73.1 决策点分类锚（变更型决策点） | ≥1 |
| DD-04 | 73.2 对齐三问+[align] 留痕 | ≥3（三问+[align]） |
| DD-05 | 73.3 三态标注+🔒 区块（CR 内锚） | ≥1 |
| DD-06 | 73.4 强制评判点+[judge] | ≥1 |
| DD-07 | 73.5 废弃只入不出 | ≥1 |
| DD-08 | 73.6 消歧义 | ≥1 |
| DD-09 | 73.7 零新键 env 锚（TASK_PLANNER_DECISION_JUDGE） | ≥1 |
| DD-10 | templates/deprecated.md 存在+五段标题 | 五段 grep 各≥1 |
| DD-11 | deprecated 五要素（原内容指针/废弃类型/废弃原因/日期/替代锚） | 各≥1 |
| DD-12 | templates/task_plan.md 🔒 不变量声明区块 | ≥1 |
| DD-13 | 三关键词（不变量/可变量/学得量）在模板 | 各≥1 |
| DD-14 | check-complete.sh [judge-gate] 锚 | ≥1 |
| DD-15 | posttooluse.sh [judge] 注入+env 降档锚 | ≥1 |
| DD-16 | SKILL.md Rule 73 摘要 bullet | ≥4 命中 |
| DD-17 | SKILL.md C51 合规行 | ≥1 |
| DD-18 | selftest-registry.tsv 自登记行 | =1 |
| DD-19 | 本计划 task_plan.md 🔒 区块（dogfood，Phase 6 前补建后生效） | ≥1 |
| DD-20 | config.json properties=42 零新键 | =42 |
| DD-21 | SKILL 计数宽锚 `1-7[0-9]`（含 73 接线） | ≥1 |
| DD-22 | 运行时留痕格式（[align]/[judge] 行格式示范在 CR 或模板） | ≥1 |

> 运行位=仓内 scripts/（权威）；部署位跑时仓级文件缺失按 SKIP 计 PASS（DCE-10 范式）。

## §6 SKILL 级联清单（S2+S5 执行，master 现实态）

| # | 文件:锚 | 动作 |
|---|---------|------|
| K1 | SKILL.md:9 | 「Critical Rules 全集 1-69+70」→「1-71+73」（修存量漏改+本任务级联；括注同步「67-71+73 均经并行任务合流落地」） |
| K2 | SKILL.md:295 | 「Critical Rules 1-71（含 Rule 40-71 全集…」→「1-71+73」，全集列举补 Rule 73 条目 |
| K3 | SKILL.md:355 后 | 新增 Rule 73 摘要 bullet（同 Rule 71 bullet 格式：73.1-73.7 一句摘要+零新键+selftest-decision-drift.sh+C51） |
| K4 | SKILL.md:381 | References 表 critical-rules 行「Rules 1-71」→「Rules 1-71+73」 |
| K5 | SKILL.md:231 后 | 合规清单新增 C51 行（Rule 73 自查：变更型决策点三问/[align]/[judge] 留痕/🔒 区块/废弃双源；mini 档豁免） |
| K6 | SKILL.md 决策点对齐段 | 派发检查点 2.5 段末与「🆕 用户新指令处理」段各加一行 73 引用（变更型决策点→73.1 判定→73.2 三问） |
| K7 | CLAUDE.md:33 / README_zh.md:136,229 | 「Rules 1-71」→「Rules 1-71+73」（注释追加演进记录，同 v158 手法） |
| K8 | selftest-registry.tsv:71 后 | +1 行：selftest-decision-drift.sh 域+dep_anchors |
| K9 | 5 个存量 selftest 宽容锚（S7 回归实证新增，2026-10-10 11:5x 回填） | selftest-drift-check-subagent.sh DCS-11 `Rule 40-(69|71) 全集` → `Rule 40-(69|71|73)(\+[0-9]+)? 全集`;selftest-reliability-institution.sh R-09 `含 Rule 40-[567][0-9] 全集` → `含 Rule 40-[4567][0-9](\+[0-9]+)? 全集`（RF-07 头注锚同族加 `(\+[0-9]+)?`）;selftest-root-resolution.sh RR-09 `Critical Rules 全集 1-(5[3-9]|6[0-9])` → `Critical Rules 全集 1-[0-9]+(\+[0-9]+)?`（负断言 1-51 残留=0 保留）;selftest-parallel-scheduling.sh P-05 skill_max 提取 `Critical Rules 1-[0-9]+` → `Critical Rules 1-[0-9]+(\+[0-9]+)?`（grep -oE 两段抽数取 max，覆盖 71+73=73） |

## §7 合并回预案（Phase 6 消费，v152 判例）

1. **多轮并集预期**：v160 在途（Rule 72）、v159/v160 worktree 并行——smart-merge-back.sh 智能门预检+并集解（标签并集：1-71+73 与 v160 的 1-72 合并为 1-72+73 或 master 现实态取并集；C 编号让位：若 C51 被占顺延 C52）。
2. **宽锚容错**：本任务 selftest 全部用宽锚（`1-7[0-9]` 族/子条锚），禁钉死单行单形态（v150/v158 宽容锚纪元扩展范式）。
3. **部署对账**：--deploy 后四部署位 diff=0；部署位 config.json properties 同步核对=42。
