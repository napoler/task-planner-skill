# S7 独立复核 — P0/P1 发现逐条复现（只读）

- 复核者：S7-verifier（独立于 S3/S4/S5/S6/S8/S9）
- 仓：/mnt/data/dev/task-planner-skill（HEAD 2448e01，工作树 4 个在途 M 文件，未触碰）
- 复核时点：2026-10-22 约 01:50~02:05 +08
- 纪律：只读；唯一写入=本文件；grep/find 排除 `.backup`；sqlite `mode=ro` + `.timeout 20000`；/mnt/data/dev/videop1 只读；无 git 写操作
- 判定四态：verified / fp（假阳性，附反证）/ partial（部分不成立）/ unverified

---

## ① 复核表

编号对应任务书 P0 清单 1–22。所有命令 cwd=/mnt/data/dev/task-planner-skill（除注明）。

### [1] 宽锚计数守卫失效 — **verified**
- 复现：`grep -rlc --exclude-dir=.backup "1-\[89\]\[0-9\]" skills/task-planner/scripts/*.sh | wc -l`；`printf 'Rules 1-80 全集索引' | grep -cE '1-[89][0-9]'`
- 实测：脚本数=**20**；`1-80` 命中=**1**（`1-93` 亦=1）；`selftest-absorption-discipline.sh:85-89` 确有 5 处 `_pin_lit … "grep -cE '1-[89][0-9]'"`，`:96` 判定文案「live 锚字面（精确 5…）或宽容正则族（6）」。
- 判定：verified（宽锚接受任意 8x/9x 上界；反向钉死成立）。

### [2] 三面计数互斥（真值 90） — **verified**
- 复现：`grep -hoE '^#{2,4}[[:space:]]*(Rule[[:space:]]+)?[0-9]+' <12 个 critical-rules*.md> | sed -E 's/^#+[[:space:]]*(Rule[[:space:]]+)?//' | sort -nu | wc -l`；`sed -n '9p;208p' skills/task-planner/SKILL.md`；`sed -n '193,203p' skills/task-planner/references/critical-rules.md`
- 实测：distinct=**90**，缺号仅 77/78/79（abandoned）；核心文件标题 14 条（含 `## Rule 80`）。`plans/.rule-reservations.jsonl:55-57` note 写「全集实测 86=14 核心+72 卫星」；`SKILL.md:9` 与 `:208` 均写「其余 **74** 条」（=88）；`critical-rules.md:198` plan-collab 行只列 `Rule 39,40`（漏 91）→ 逐行和 14+75=89。
- 判定：verified（90 = 14+76；86/88/89 三错值并存）。

### [3] Rule 75 双行认领 — **verified**
- 复现：`sed -n '195p;197p' skills/task-planner/SKILL.md`；`grep -cE '^### 75 ' skills/task-discipline/references/critical-rules-discipline.md`；`sed -n '42p' skills/plan-research-router/references/critical-rules-research.md`
- 实测：`:195` task-discipline 行含 `…69-76…`；`:197` plan-research-router 行含 `Rule 58,63,75`；discipline 内 `^### 75` = **0**；真身 `critical-rules-research.md:42`「### 75 网络调研主动激活…」在位。
- 判定：verified。

### [4] 配对守卫基线自含失配 — **verified**
- 复现：`sed -n '36,45p' skills/task-planner/scripts/selftest-rule-reserve-pairing.sh`；`bash skills/task-planner/scripts/selftest-rule-reserve-pairing.sh`；`grep -nE '^#{2,4} *(Rule )?(57|60|80|82)([[:space:]]|（)' <discipline/core>`
- 实测：`:41 EXEMPT_DANGLING=(57 60 80 82)`；实跑输出 `PR-02 PASS … 57 60 80 82 全在豁免表`、`Total: 3 PASS=3 FAIL=0`、rc=0；而 57→discipline:278、60→discipline:295、80→core:139、82→core:173 **全部正文在位**。
- 判定：verified（注释「非在途」与事实相反；门对「已落地漏登记」不可区分）。

### [5] Rule 56/83 账本零登记 — **verified**
- 复现：`grep -cE '"rule"[[:space:]]*:[[:space:]]*(56|83)[,}]' plans/.rule-reservations.jsonl`；`grep -nE '^### (56|83) ' <discipline/core>`
- 实测：账本计数=**0**；正文在位 discipline:260（### 56）、core:181（### 83）。
- 判定：verified。

### [6] 恒真断言 — **verified**
- 复现：`sed -n '73p' skills/task-planner/scripts/selftest-verification-gate.sh`；`grep -cF 'Rule 80,88,84' skills/task-planner/SKILL.md`
- 实测：`:73` 含 `[ "$(grep -cF 'Rule 80,88,84' "$TP_SKILL" || true)" -ge 0 ]`；该字面命中数=**0**，`[ 0 -ge 0 ]` 仍 TRUE。
- 判定：verified（纸面守卫）。

### [7] Rule 82 vs 38.7 逐字双载 — **verified**
- 复现：`awk 'NR==45' critical-rules-template.md > /tmp/a387.txt; awk 'NR==195' critical-rules-discipline.md > /tmp/b387.txt; diff /tmp/a387.txt /tmp/b387.txt`
- 实测：diff 无输出（**IDENTICAL**，各 305 B）。core:173 为 Rule 82「技能专业化分层纪律…防回潮」。
- 判定：verified（双载与 Rule 82 禁镜像并存；SKILL.md:187 自述「逐字双载…由 SKILL 授予豁免」）。

### [8] 规则定位走错分支 — **verified（含 1 处 partial）**
- 8a Rule 91：`sed -n '199p' SKILL.md` = `（Rule 39,40,91）` vs `critical-rules.md:198` = `（Rule 39,40）`；真身 collab:38 在位 → verified。
- 8b Rule 30/34：README/ARCH 行未定位（见「跳过」），但 discipline 内 `^### (30|34)` = **0**，真身 progress:8（### 30）、template:11（### 34）在位 → 机制 verified。
- 8c Rule 80：`grep -cE '^### 80 ' core` = **0**，真身 `core:139 '## Rule 80（…'` → verified。
- 8d Rule 38.7「0 命中」：`grep -c '38\.7' core` = **1**（`core:181` 为 Rule 83 内的交叉引用，非正文）→ **partial**：声明「0 命中」字面不成立，但「核心文件非权威锚」的结论成立。

### [9] 回归全绿悖论 — **partial（抽样）**
- 复现：抽样 5 个（4 个实跑 + plan-tier 未跑）：`bash scripts/{selftest-absorption-discipline,selftest-context-pressure,selftest-verification-gate,selftest-user-instruction-priority}.sh`
- 实测：rc 全=0（`Total: 16 pass,0 fail,1 skip` / `9 PASS=9 FAIL=0` / `PASS=13 FAIL=0` / `=== ALL PASS ===`）。
- 判定：partial —— 方向一致，未全量复跑 92/1315（见跳过）。

### [10] check-complete / check-3file-gate — **verified**
- 复现：`bash skills/task-planner/scripts/check-complete.sh plans/task-skill-audit-20261021/task_plan.md`；`bash skills/task-planner/scripts/check-3file-gate.sh plans/task-skill-audit-20261021/`
- 实测：前者输出 `[plan] Rule 27.3 violation: scope 内存在未提交变更` + `?? plans/task-skill-audit-20261021/`，rc=**1**；后者无输出 rc=**0**。
- 判定：verified。

### [11] plans/ 形态 — **verified**
- 复现：`ls -1d plans/*/ | grep -v '^archive/' | wc -l`；逐目录 `[ -f $d/task_plan.md ]`；`grep -cE '^- \*\*Status:\*\*'`；`grep -cE '^- \*\*Status:\*\* pending' plans/archive/task-v069-context-hygiene/task_plan.md`
- 实测：根在途目录=**23**；无 task_plan.md=**7**（含 `plans/task-v183/`，`ls -A` = 0 项）；零 Status 行=**3**（task-defect-rrv13-dg12-false-pass / task-v192-deploy-zcode / task-v193-skill-goal-drift-fix）；Status 全 complete 留根=**8**（4/4,4/4,5/5,1/1,1/1,5/5,5/5,4/4）；archive task-v069 pending=**3**（:218、:238 等）。
- 判定：verified（数量与清单逐项吻合）。

### [12] 部署位落后 + ~/.zcode 缺 Rule 93 — **partial**
- 复现：`wc -l < <各部署位>/skills/task-planner/SKILL.md`；`git rev-list --count 0c9a408..HEAD`；`grep -rl 'Rule 93' /home/terry/.zcode/skills/task-planner | wc -l`；`grep -c '### 93\|Rule 93' /home/terry/.zcode/skills/task-discipline/references/critical-rules-discipline.md`；`ls <deploy>/execution-recall-card.md`
- 实测：4 位均存在且内容不同（SKILL.md 行数 265/237/237/237 vs 仓 266；critical-rules.md 193/193/191/193）；`.zcode` 的 SKILL.md 匹配提交 `0c9a408`（2026-10-21 10:04），`rev-list --count` = **19**；`.zcode` 内 Rule 93 命中=**0**，discipline=**0**，`execution-recall-card.md` **不存在**；仓内 SKILL.md:95（3g 规范召回）、discipline:590（### 93）、召回卡 4458 B 均在位。
- 判定：partial —— `.zcode` 落后 19 提交 + Rule 93 全套缺失 **verified**；其余 3 位 47/47/56/74 的**具体数字未重新推导**（仅证实内容不同）。

### [13] selftest-doc-script-paths.sh --deploy report-only — **verified**
- 复现：`bash skills/task-planner/scripts/selftest-doc-script-paths.sh --deploy`
- 实测：`[deploy-path] ✗ 悬空引用 2 处…execution-recall-card.md`、`注：report-only 不计入 FAIL`、`Total: 3 PASS=3 FAIL=0`、rc=**0**。
- 判定：verified。

### [14] check-dispatch.sh:126 只校验 3/8 字段 — **verified**
- 复现：`sed -n '120,132p' skills/task-planner/scripts/check-dispatch.sh`
- 实测：`:126` `for item in "$pd/task_plan.md" "$pd/findings.md" "$pd/progress.md" "status:" "acceptance:" "checkpoint:" "subagent-state/"; do`（返回 key 仅 3 个），vs dispatch:60 的 8 字段。
- 判定：verified。

### [15] 返回格式段门随标题形态判定 — **verified（行为实测）**
- 复现：/tmp 造 prompt（三文件绝对路径 + 三 key + `subagent-state/`），变体 A=`### 7. 返回格式`、B=`## 7. 返回格式` 且缺 confidence；`TASK_PLANNER_DISPATCH_ENFORCE=enforce TASK_PLANNER_PLAN_DIR=/tmp/vplan bash scripts/check-dispatch.sh pretool /tmp/pX.md`
- 实测：A rc=**0**（静默，仅 advisory 需求锚告警）；B rc=**2**（`✗ 返回格式段结构违规: C: 段内序号清单行 3 行且缺 key( confidence:)`）。
- 判定：verified（同内容因标题形态一放一拦）。

### [16] 伴飞门把模板标签当路径 — **verified（行为实测）**
- 复现：`grep '伴飞' skills/task-planner/templates/subagent_dispatch.md | grep -oE '[A-Za-z0-9._/-]+\.md' | sort -u`；再以变体 D（`伴飞技能 SKILL.md 绝对路径:/tmp/vreal/SKILL.md`，真实文件存在）跑 pretool
- 实测：token 抽取=**SKILL.md**（仅此一个）；变体 D rc=**2**，stderr `⚠ Rule 59.2 伴飞路径不存在: SKILL.md` + `[dispatch-block] …伴飞路径不存在(SKILL.md)`。
- 判定：verified（合规路径同在行内仍被标签词拖垮，enforce 档误拦）。

### [17] status 值域跨载体不一致 — **verified（行为实测）**
- 复现：`bash skills/task-dispatch/scripts/check-subagent-return.sh /tmp/r_blocked.txt`（8 字段 + `status: blocked`）；同 `/tmp/r_failed.txt`（`status: failed` + `blockers: none`）；`/tmp/r_accept.txt`（`acceptance: 全部通过`）
- 实测：blocked → `VIOLATION 判据四: status 值 blocked 超出值域` rc=**1**；failed+none → `PASS` rc=**0**；`acceptance: 全部通过` → `PASS` rc=**0**；仅 3 key → `VIOLATION 判据一: 缺字段 files:` rc=1。
- 判定：verified（且 :51 值域 = done|partial|failed|timeout，未含 Handoff 枚举的 blocked）。

### [18] check-delegation Executor 匹配器 — **verified（机制）／需降级（分级）**
- 复现：`bash skills/task-planner/scripts/check-delegation.sh stats plans/task-skill-audit-20261021`；`sed -n '183p' plans/task-skill-audit-20261021/task_plan.md`
- 实测：`"phases_delegated":0,"delegation_rate":0.000`，violations 含 `Executor 含未登记子代理类型:按S-unit表`（及 `:Explore`）；计划 `:183` = `- **Executor:** 按 S-unit 表（agent-quality-auditor/critic/code-runner-agent/Explore）`；脚本 `:421-424` 去括号后得 `按S-unit表`，`:445` 整格 `| tok |` 匹配。
- 判定：verified（机制）；但见「需降级」——聚合式 Executor 本身不符 22.6 `type(model)` 形态，脚本行为可辩护。

### [19] verify_done 机器门静默失效 — **verified**
- 复现：`grep -n '备注(rescue/retry/verify_done)' skills/task-planner/templates/task_plan.md`；`grep -n 'verify_done 无机器消费' …/task_plan.md`；`sed -n '1730,1760p' skills/task-planner/scripts/check-complete.sh`；`grep -rln 'verify_done' skills/task-planner/scripts/*.sh`
- 实测：模板 `:502` 表头单元格 = `备注(rescue/retry/verify_done)`（无独立 verify_done 列）；`check-complete.sh:1747` 要求 `v=="verify_done"` 精确相等 → 取不到列位 → `:1747` 上方注释「表头无该列 → fail-open 跳过」；`:1755` 命中亦仅 `WARNING … warn 档不阻断`。模板 `:497` 自述「verify_done 无机器消费（grep 实证 scripts/*.sh 除 selftest 零命中）」为**假**：消费方含 `check-complete.sh`、`auto-finalize.sh`、`selftest-delegation.sh`。
- 判定：verified（机器门只在夹具的裸 `verify_done` 表头上活）。

### [20] 资源/额度断言守卫生口 — **verified（1 处行号需修正）**
- 复现：`for k in 额度 配额 资源状态 推迟 一手证据; do grep -c "$k" skills/task-planner/SKILL.md; done`；`sed -n '235p;237p;239p;241p' skills/task-discipline/references/critical-rules-discipline.md`
- 实测：SKILL.md 五个关键词命中全 = **0**；discipline `:235/:237/:239/:241` = Rule 54.1 就绪语义 / 54.2 阻塞影响矩阵 / 54.3 仪式性进展禁令 / 54.4 推迟举证四要素（措辞覆盖「配额/容量/可用性 + 第一手查询证据」「禁止整体推迟」「推迟四要素」）。task-discipline 路由行（**SKILL.md:195**，非 S9 所写 `:196`）调用条件列无资源类触发词。
- 判定：verified（条款对、常驻面零指针成立；S9 的 `:196` 引用为行号笔误，`:196` 实为 media-planner 行）。

### [21] 固化通路 9 环节 0/9 — **verified（静态）**
- 复现：`sed -n '481p;424p' skills/task-discipline/references/critical-rules-discipline.md`；`sed -n '11p' skills/plan-research-router/references/critical-rules-research.md`；`grep -rc '证据时间\|声称时间\|先于声称' skills/*/references/critical-rules*.md`
- 实测：74.2 `(a) 增量（默认且优先）`；71.2 写入面枚举 = `计划三文件/findings/knowledge-brief/delivery-summary/派发任务书/审计报告`（**不含** AGENTS.md / 规则文件 / 经验档）；research:11 为 58.3 结论-证据锚定；时序判据词全仓规则文件命中 **0**。
- 判定：verified（三项结构性断点静态成立）。

### [22] 涉事会话 4 条关键事实 — **partial（含 1 条 fp）**
- 复现（只读）：`sqlite3 "file:/home/terry/.zcode/cli/db/db.sqlite?mode=ro" ".timeout 20000" "select substr(data,1,400) from part where id='part_mvia2iou_…';"`；`select id,datetime(time_created/1000,'unixepoch','+8 hours'),json_extract(data,'$.role'),json_extract(data,'$.time.completed') from message where id='msg_mvi9riyb_…'`；`select count(*) from part where session_id='session_a40eae…' and data like '%没有额度%'`；`stat -c '%y' /mnt/data/dev/videop1/tmp/_gen-budget/video-seconds-20261021.json`；`sed -n '46p' …/agent_ce1928bc…/output.txt`；`ls -la …/agent_1537858a…/`；`sqlite3 … "select json_extract(data,'$.tool'),count(*) from part where session_id like '%1537858a%' group by 1"`；`grep -o '额度事实断言纪律[^）]*）' /mnt/data/dev/videop1/AGENTS.md`
- 实测（逐条）：
  1. 编造声称原文 **命中**：`part_mvia2iou_0657e219-…` 含「物理约束：现在 23:30，距 00:00 仅 30min，约束 4 禁今晚发起新创建 → 重抽只能明日 00:00 后」；`msg_mvi9riyb_cacf0aed-…` time_created = **2026-10-21 23:30:54**、role=assistant、`time.completed`=1792597169869（23:39:29）。字面「没有额度」在该会话 = **0 命中**（S8 的负结果复核为真）。**verified**
  2. 真实额度账本 **命中**：`{"used": 198}`，mtime **2026-10-21 23:03:58**；回执 `agent_ce1928bc…/output.txt:46`「used=198…剩余 302s 随 00:00 清零」。**verified**
  3. 幻觉固化落点 **命中**：`/mnt/data/dev/videop1/AGENTS.md:84` 含「额度事实断言纪律（2026-10-21 立 v2，task-videop1-quotafact-001，判例=EP3 23:30 实余 302s（198/500…双证）…）」；`docs/experience/quotafact-20261021.md`（4888 B，00:41）`:6/:9/:17` 逐字引述。**verified**
  4. 「FACT LOCK 子代理无 Edit/Write 且产物零落盘」 → **fp（反证）**：`agent_1537858a…/` 现有 `output.txt`(3214 B) + `task.output`（S8 时点仅 metadata.json，非终态）；child `sess_subagent_agent_1537858a-…` 工具计数 = **Edit 20 / Write 3 / Read 14 / Bash 70 / TodoWrite 4**（非「无 Edit/Write」）；运行区间 `23:39:30 → 2026-10-22 01:42:45`（442 parts，S8 记的 117 parts/止于 01:03 是截断窗口）；产物已落盘：`ep03-prompts.md` mtime **01:29:32**、`FACT LOCK` 命中 **32**；`tmp/ep03/gen/specs/ep03-video-all.json` mtime **01:30:00**、`FACT LOCK` 命中 **18**；output.txt 自述「只新增 tmp/ep03/gen/checkpoint-factlock.md（185 行）…未再改动 ep03-prompts.md」。
- 判定：**partial** —— 1/2/3 条 verified；第 4 条 **fp**（时间片截断导致的失真结论）。

---

## ② 假阳性清单（附反证）

| # | 被推翻的结论 | 反证（复现命令 + 实测） |
|---|---|---|
| FP-1 | 「FACT LOCK 子代理（agent_1537858a）无 Edit/Write 且产物零落盘」（S8 ⑤ / S9 C-07·V-06·③小结「派发无产出仍推进」的主证据） | `ls -la …/agent_1537858a…/` → `output.txt` 3214 B + `task.output` 存在；`select json_extract(data,'$.tool'),count(*) … where session_id like '%1537858a%'` → Edit 20 / Write 3；`stat ep03-prompts.md` → 2026-10-22 **01:29:32**，`grep -c 'FACT LOCK'` = **32**；spec mtime 01:30:00，命中 18；child max(time_created) = **01:42:45**（S8 的 01:03 为观察截断）。产物确实落盘，「零产物」不成立。 |
| FP-2（弱） | 「`acceptance` 值域完全不校验 ⇒ 不可核验自报被采信」（S6 C-14 的「值域」措辞） | 实测 `acceptance: 全部通过` rc=0 成立；但脚本对 `acceptance` 只查「≥1 行命中」是**如实设计**（头部注释只承诺 status/confidence 值域），非「声称有而失效」。C-14 应表述为「acceptance 无值域判据」而非「值域校验失效」。 |

> 未发现其他假阳性：清单 1–7、10–17、19–21 的原文与行为均复现通过。

---

## ③ 需降级清单

| 编号 | 现分级 | 建议 | 依据 |
|---|---|---|---|
| [18] check-delegation 聚合 Executor | P1 | **降为 INFO/NIT** | 机制 verified，但计划 `:183` 写「按 S-unit 表（…）」本身不符 22.6「执行体列 = `type(model)`」形态；`delegation_rate 0.000` 对「非契约形态声明」而言是可辩护输出，不是门缺陷。 |
| [8d] Rule 38.7「0 命中」 | P1 | **降为 NIT** | 实测 core 内 `38\.7` = 1，但唯一命中是 `core:181` Rule 83 的交叉引用，非正文；「核心非权威锚」的结论正确，仅字面「0 命中」不严谨。 |
| [12] 部署位落后 | P0（B-13） | **降为 P1** | 部署漂移真实且 `.zcode` 缺 Rule 93 全套（verified）；但属运维面、无仓内可阻断门，且 3 位具体落后数未重新推导，不宜按 P0 计。 |
| [11] plans/ 形态 | P0（B-04） | **降为 P1** | 事实全部 verified（8/7/3/3），但影响为簿记卫生与索引失真，未直接致执行分支错误；P0 定级偏高。 |
| [19]/[22-4] 表述 | — | **修正措辞** | [19] 模板 `:497`「除 selftest 零命中」应改为「check-complete.sh/auto-finalize.sh 已消费」；[22] 第 4 条整体删除或改述为「S8 观察窗口截断于 01:03，终态有产物」。 |

---

## ④ 跳过清单 + 理由

| 跳过项 | 理由 |
|---|---|
| [9] 全量 92 selftest / 1315 PASS / 0 FAIL 重跑 | 时间预算（总量 ≤15 min）不足以复跑全量（S4 记墙钟 61 s，但需逐脚本收集 Total 行并核 1315 计数）；已抽样 4 个实跑 + 方向一致，判 partial。 |
| [12] .claude/.cursor/.opencode 的精确落后提交数（47/47/56/74） | 需逐文件做 blob 哈希与 `git log` 历史比对（S5 自述方法），成本高于收益；已证实 4 位内容确有差异 + `.zcode`=19。 |
| [8b] README.md:48/:69、docs/ARCHITECTURE.md:54/:101 原文 | 仓根无 README.md / docs/ARCHITECTURE.md（`find` 仅命中 skills/*/README.md）；未定位 S3/S5 所用实际路径，故只复核了「discipline 内 30/34 = 0 命中、真身在位」的机制面。 |
| [11] archive-plan.sh dry-run「7 个当前即可归档」 | 该脚本执行 `git mv`（非只读），不得在只读复核中运行；仅复核了 8 个计划的 Status/Phase 计数相等。 |
| [22] 「用户当夜是否真实发起生成」 | S8 已标 LOW/未验证，且属 videop1 侧业务事实，非本仓审计口径。 |

---

## ⑤ 总体可信度判定

- **可直接进报告（HIGH 置信，逐条实跑/实读复现）**：清单 [1][2][3][4][5][6][7][10][11][13][14][15][16][17][19][20][21] 及 [22] 的 1/2/3 条 —— 共 **17 条 verified**（另 [8] 大部、[18] 机制、[22] 主体亦复现）。
- **须标「未验证/部分」**：[9] 全量回归计数（抽样通过，1315 总数未重算）；[12] 三个非加载位的精确落后数。
- **必须撤回或改写**：[22] 第 4 条「FACT LOCK 无产物」（FP-1）。**该条是 S9「派发无产出仍推进」与「机器门只活在夹具上」叙事的经验支点——撤回后，[19] 的机器门死代码结论仍独立成立（静态+行为已复现），但「本案确实发生了无产物推进」这一事实主张失去证据，报告不得据此断言本案发生过虚假进展。**
- **整体**：规则/守卫/契约/簿记四面的静态与行为证据复核通过率高（22 条中 17 条 fully verified，3 条 partial 均为「方向成立、精度未全复现」），**报告主体可信**；唯一实质性风险是会话取证类的**时间片快照失真**（S8 在子代理运行中取态即定论），凡涉「运行中子代理的终态」结论一律需以「复核时点重取」为准。

---

## 附：本复核执行的命令类别（可复现，只读）
`grep -rlc/-n/-cE`（12 个 critical-rules*.md、scripts/*.sh、plans/）、`sed -n`、`awk`、`wc -l`、`ls -la/-1d/-A`、`stat -c`、`diff`、`find`（排除 `.backup`）、`git rev-list/log/rev-parse`（只读）、`bash <仓内 selftest/check 脚本>`（只读 + /tmp fixture）、`sqlite3 "file:…db.sqlite?mode=ro" ".timeout 20000"`。未执行任何 git 写操作；未修改除本文件外任何文件。
