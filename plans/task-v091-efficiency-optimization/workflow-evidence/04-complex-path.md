# 04 复杂路径开销取证（多 Phase 复杂任务的仪式乘积 / 串行链 / 重复门控）

> 审计员：04-complex-path（/workflow 并行取证领域 4）。基线 commit：`87d306b`（git log 头部确认）。
> 方法：只读读码（SKILL.md 558 行 / critical-rules.md 365 行 / scripts 关键 12 脚本）+ 沙箱与真仓实测计时 + 上轮审查报告交叉引用（plans/task-planner-skill-review/report.md）。
> 计时环境：Bash `TIMEFORMAT='%R'` 多次取均值。技能本体未改动；计时均在 /tmp 沙箱副本（cp -r 只读复制）或真仓只读运行。
> 所有命令实测于本会话执行；无法执行的检查在文末「未执行项」如实声明。

## 〇、实测计时总表（本会话实跑，命令见各条锚）

| # | 被测对象 | 命令要点 | 实测均值 | 测次 |
|---|---------|---------|---------|------|
| M1 | UserPromptSubmit hook（真仓 38 plans） | `printf JSON \| bash skills/task-planner/scripts/zcode-userpromptsubmit.sh` | **752 ms/次** | 5 |
| M2 | check-conflicts.sh --runtime（真仓 38 plans） | `bash check-conflicts.sh --runtime /mnt/data/dev/task-planner-skill` | **508 ms/次** | 5 |
| M3 | PreToolUse hook Edit（真仓） | `zcode-pretooluse.sh`（tool=Edit） | **228 ms/次** | 5 |
| M4 | PreToolUse hook Agent 派发（沙箱） | 同上（tool=Agent，含 check-dispatch.sh） | 334 ms/次 | 5 |
| M5 | PostToolUse hook 普通调用（沙箱） | `zcode-posttooluse.sh` | 276 ms/次 | 5 |
| M6 | PostToolUse hook 编辑 task_plan.md（含 attest 自动重锁） | 同上（tool_input.file_path=task_plan.md） | **538 ms/次**（+262ms 为重锁） | 5 |
| M7 | check-3file-gate.sh | `bash check-3file-gate.sh <plan-dir>` | 92 ms/次 | 5 |
| M8 | check-drift.sh --json | `bash check-drift.sh plan progress findings --json` | 158 ms/次 | 5 |
| M9 | sync-todos.sh --index | `bash sync-todos.sh --index plans` | **179 ms/次**（全量重写 INDEX.md） | 5 |
| M10 | ledger-append.sh | `bash ledger-append.sh <plan-dir> note ... --phase 1` | 87 ms/次 | 5 |
| M11 | check-context-hygiene.sh | `bash check-context-hygiene.sh <plan-dir>` | 61 ms/次 | 3 |
| M12 | check-plan-dispatch.sh | `bash check-plan-dispatch.sh task_plan.md` | 199 ms/次 | 5 |
| M13 | check-complete.sh 全门链（全 complete 计划） | `bash check-complete.sh task_plan.md` | **441 ms/次** | 5 |
| M14 | attest-plan.sh 全链（dispatch+template+fmea 子门） | `bash scripts/attest-plan.sh task_plan.md` | 337 ms/次 | 5 |
| M15 | **selftest 全量 27 脚本** | `for f in scripts/selftest-*.sh; do bash $f; done` | **65.7 s/轮**（沙箱副本） | 1 轮（27 脚本） |
| M16 | plan-resume scan-plans.sh | `bash ~/.agents/skills/plan-resume/scripts/scan-plans.sh` | 22 ms/次 | 3 |
| M17 | 外部 Skill 载荷 | `wc -c` | task-drift-guard SKILL.md=3,455B（81 行）；plan-resume SKILL.md=**28,616B（433 行）** | — |

计数锚：本仓 `plans/` 下 task 目录 = **38 个**（`ls -d plans/task-* | wc -l`）。config.json 顶层 properties = **40 键**（python3 -c json 解析）。

---

## 一、结构性冗余清单：同一检查 × 出现的门数（本次审计主交付）

以下每行均经读码核对锚点；「门数」= 同一检查在独立流程位置被要求执行的次数（一次任务内最少发生次数）。

| 检查名 | 出现的门（锚点） | 门数 | 重复性质 |
|--------|----------------|------|---------|
| **S-unit 表/执行体校验（check-plan-dispatch.sh）** | ① attest 锁定时：attest-plan.sh:67-77（`bash "$cpl" "$plan_file"` 缺失拒绝锁定）② 终验：check-complete.sh:457-459（`bash "$cpl" "$PLAN_FILE"` 再次全量跑）③ 每 Phase 委派检查点（SKILL.md:91）④ 合规清单 C14（SKILL.md:191） | **4** | ①②为同脚本逐字节重复执行（计划文本 attest 后未变时终验必同结果）；③④为 LLM 重复人工复核 |
| **FMEA 门控（同口径双实现）** | ① attest：attest-plan.sh:130-149 `check-fmea-gate()`（awk 第7列 RPN 判定）② 终验：check-complete.sh:466-511 内联重写（注释自证：「与 attest-plan.sh check-fmea-gate 同口径；独立实现避免 source 依赖」check-complete.sh:476） | **2** | 同一检查两份实现 + 两次执行；双实现还是漂移隐患（上轮审查报告 ②-17 同类：阈值脱钩先例） |
| **Rule 27 scope 未提交检查（git status --porcelain）** | ① 每 Phase 步骤 4.5 提交后人工校验（SKILL.md:100「提交后 git status --porcelain -- <scope> 必须为空」）② 终验 check_scope_porcelain（check-complete.sh:18-97）③ 终验联动再查（SKILL.md:167「确认任务 scope 文件无未提交变更」）④ 清单 C17（SKILL.md:194）⑤ worktree 合并前 V2 干净预检（smart-merge-back.sh:35「git status --porcelain 为空 → 否则 exit 3」） | **5** | 逐 Phase 提交模型下（27.1），①通过则②③对同 scope 必为空——检查对象是同一组刚提交过的文件 |
| **3-File 回填校验** | ① 每 Phase：check-3file-gate.sh（SKILL.md:99，M7 实测 92ms）② 终验：check-complete.sh:299-329（Rule 19.5 stub 判定，python 内联）③ 清单 C16（SKILL.md:193） | **3** | ①②设计上分别管 Phase 粒度/终验粒度，但 ② 检查的「非 stub」是 ① 的严格弱化条件（每 Phase 都回填过的计划终验必然非 stub） |
| **委派判定（Rule 25）** | ① 每 Phase 委派检查点（SKILL.md:91）② 每 Write/Edit PreToolUse hook 调 check-delegation.sh pretool（zcode-pretooluse.sh:40；该脚本 571 行、7 次 jq）③ 终验 stats（check-complete.sh:381-455）④ verification.md「委派统计」段（Rule 25.4，critical-rules.md:177） | **4** | ②是机器门（必要）；①③④三层对同一事实重复统计与登记 |
| **漂移检测** | ① 每 Phase complete 调 Skill("task-drift-guard")（SKILL.md:102）② check-drift.sh --json（清单 C4a，SKILL.md:181）③ Rule 15 每 2-3 个 todo 再调（critical-rules.md:58）④ 连续 ≥3 次工具调用后（SKILL.md:106）⑤ 切换模块前（SKILL.md:522） | **5**（Rule 17.4 上限 ≤3 次/Phase 的 Skill 调用 + 每次 Phase 的脚本跑） | 同一时点两套实现（Skill 全文加载 + 本地脚本）叠加；高频触发点 4 处 |
| **VC/V-N 完整性** | ① 终验 VC-GATE（check-complete.sh:527-691，165 行 awk/grep）② 清单 C15（SKILL.md:193）③ Rule 26 Q1 每 Phase 判定（critical-rules.md:187）④ goal-gate.md 文档层 | **4** | 同一数据（VC 表+V-N 行）四处判读，两处人工 |
| **计划防篡改（SHA-256 attestation）** | ① 批准后 attest 锁定（SKILL.md:79）② **每轮用户 prompt** 重校验：zcode-userpromptsubmit.sh:58-68 `bash attest-plan.sh --verify`（sha256sum 子进程）③ **每次编辑 task_plan.md** 自动重锁：zcode-posttooluse.sh:54-89（实测 M5→M6 单次 +262ms） | **3** | 高频路径上的加密校验；②无 mtime 短路，每 prompt 付一次 bash+sha256 |
| **INDEX.md 刷新（sync-todos --index）** | ① 每 Phase complete（SKILL.md:101）② Rule 23.7 每 10 次工具调用心跳（critical-rules.md:157）③ 归档后重跑（critical-rules.md:240 29.4）④ S4 终态同步（SKILL.md:208） | **4** | M9 实测 179ms/次且**全量重写** INDEX.md（write_index 对全部 38 个历史 plan 逐个 rollup_task） |
| **并发/冲突检测** | ① 初始化 check-conflicts.sh（SKILL.md:71）② 每 prompt --runtime（zcode-userpromptsubmit.sh:136，实测 M2=508ms）③ 每 Write/Edit 遍历全部其他 plans 的 scope（zcode-pretooluse.sh:104-115） | **3** | ②③均为 O(N_plans) 全量扫描，随 plans 积累线性变慢（本仓 38 个） |
| **模板类型校验（check-template-type.sh）** | ① attest 内（attest-plan.sh:93-114）② 清单 C22（SKILL.md:199） | **2** | 轻度（脚本+清单各一） |

**矩阵结论**：11 项检查合计约 38 个门位；其中 attest↔check-complete 两门逐字节重复的 2 项（S-unit 校验、FMEA）与 5 门位的 porcelain/漂移检测是纯结构性冗余的最大头。

---

## 二、逐条瓶颈

### 瓶颈 1：每 Phase 固定仪式 ≥16 个主上下文动作 × Phase 数的乘积效应
- **证据锚**：SKILL.md:88-107（Phase 执行循环「6 步」逐条展开）——① Edit task_plan.md 翻 in_progress + Current Phase 同步（L89，2 处编辑）② TodoWrite S2（L90）③ 委派检查点（L91）④ 每 2 Phase check-context-hygiene.sh（L92，实测 61ms）⑤ 每 S-unit：Handoff 登记行 Edit + Agent() + Read 产出 + findings 回填 Edit + verify_done 勾选 Edit（L94+critical-rules.md:136 22.5）⑥ 每关键动作 ledger-append（L96，实测 87ms）⑦ hook 提醒响应回写（L97）⑧ Edit task_plan.md 翻 complete + checkbox + 证据（L98）⑨ check-3file-gate.sh（L99，92ms）⑩ git commit + porcelain 校验（L100，2 条命令）⑪ TodoWrite completed + sync-todos --index（L101，179ms）⑫ Skill("task-drift-guard")（L102，3.5KB 全文载入）⑬ Skill("plan-resume")（L107，**28.6KB 全文载入**）⑭ check-drift.sh --json（C4a，SKILL.md:181，158ms）。合计 **≥16 次主进程串行工具轮/Phase**，另加 C1-C27 清单（见瓶颈 12）。6-Phase 任务 = ~100 次纯仪式轮，还未计实际工作。
- **任务类别**：complex
- **质量耦合**：medium——其中 3-File gate/commit/委派检查承担门控职能（high 部分须保留）；Skill(plan-resume)、INDEX 刷新、双 TodoWrite 无质量职能（low 部分可降频/合并）
- **预估影响**：仪式轮占复杂任务主上下文轮次的 50% 以上（16 仪式 vs 实际工作轮）；把 plan-resume/INDEX/双写合并降频可砍掉每 Phase 4-6 轮

### 瓶颈 2：Rule 21.4 串行铁律下 S-unit 链式等待的墙钟代价（固定启动开销 × 数量）
- **证据锚**：critical-rules.md:122（21.4：同一时刻至多 1 个活跃子代理，「互不依赖」不构成并行理由；后台派发也占槽）。每个 S-unit 固定开销：主进程 Handoff 行 Edit（22.5）+ 九字段 prompt（critical-rules.md:132，≤prompt_max_chars=3000 字符，config.json#subagent.prompt_max_chars 实测读出）+ 子代理冷启动 + **22.4a 强制首块传计划三文件绝对路径且子代理按需 Read**（critical-rules.md:133）+ 检查点 T1-T5 写盘（critical-rules.md:142）+ 8 字段严格返回（critical-rules.md:134）+ 主进程 30s 内 Read 产出 + findings 回填/复核 + verify_done 勾选。粒度上限：max_per_phase=5、单步 ≤2 文件/≤100 行/≤15min/≤4 步枚举（config.json#subagent 实测读出；check-dispatch.sh:242-325 步骤枚举计数）。6-Phase × 3 S-unit = 18 次完整「冷启动→执行→三证据验收」串行循环，任一环等待全链等待。
- **任务类别**：complex
- **质量耦合**：**high**——21.4 是用户实证事故（2026-09-12 sess_1316c7f8：16 编辑批并行→千级残迹）换来的防投毒门控；提速只能走 Rule 39.4 式「显式豁免登记」或按 S-unit 只读/只写隔离分级放行，不可放松验收
- **预估影响**：串行链墙钟 ≈ Σ(启动+执行+验收)；只读型 S-unit（explore/research）互不写共享状态，若允许小并发（如 2）可省 30-50% 链式等待，但必须登记豁免而非改铁律

### 瓶颈 3：27 个 selftest 全量重复重跑（每轮实测 65.7 秒，每任务 ≥2-3 轮）
- **证据锚**：本会话实测 `for f in /tmp/tp-bench/skill/scripts/selftest-*.sh; do bash "$f"; done` = **65.674s**（27 脚本）。重复执行证据：① Rule 36.6（critical-rules.md:316）「修改后回归验证：selftest 全量 0 FAIL」——每次技能修改强制一轮；② task-v090 verification.md:21-22 实录「主仓 master 全量求和 PASS=457 FAIL=0（27 脚本）；**worktree 内执行时同口径 457/0**」= 同一任务两轮全量；③ task-v089 report.md:58「实跑 3 轮全部通过」；④ 本次 task-v091 计划 Goal 又含「全量 selftest 0 FAIL」= 第 3 轮。每轮产出 453-457 行 PASS 断言需主进程求和复核。
- **任务类别**：both（简单任务改 1 行也触发全量）
- **质量耦合**：high（这是技能修改的回归总门）——优化方向是「改动面相关 selftest 增量跑 + 终验一次全量」，而非删断言
- **预估影响**：每技能修改任务节省 1-2 轮 × 65.7s ≈ 1-2 分钟纯墙钟 + 数千行输出复核；配合 457 断言分域索引可再减复核量

### 瓶颈 4：check-complete 终验 11 道门串联，其中 2 道与 attest 逐字节重复
- **证据锚**：check-complete.sh（895 行）全链实测 441ms/次（M13）：porcelain 预检（L18-97）→ python 门（Phase 计数/Batch/Aggregator/3-File stub，L122-376）→ 委派 stats（L381-455）→ **check-plan-dispatch.sh 重跑（L457-459；attest-plan.sh:67-77 已跑同一脚本）** → **FMEA 门控内联重实现重跑（L466-511；attest-plan.sh:130-149 同口径双实现，L476 注释自证）** → rescue-chain（L517-525）→ VC-GATE 165 行（L527-691）→ Learning Gate（L694-795）→ Reflect Gate（L797-835）→ SKILL-MODIFY Gate（L837-870）→ mechanism-profile（L872-880）→ warn 计数（L882-892）。计划文本在 attest 后若未被 B/C 类重规划触碰，后两道重复门结果必然与锁定时相同。
- **任务类别**：complex
- **质量耦合**：high（终验是交付总闸）——去重方式应为「attest 后哈希未变 → 跳过与 attest 重复的两道」而非删门
- **预估影响**：终验门耗时减半（441→~250ms 量级）+ 维护面减一份双实现（FMEA 双实现是上轮审查已出现的阈值脱钩同类隐患，report.md ②-17）

### 瓶颈 5：hook 每 prompt / 每工具调用的固定进程开销（真仓实测）
- **证据锚**：M1=UserPromptSubmit **752ms/次**（真仓 38 plans；内含 5 次 jq + resolve-plan-dir.sh 子 shell + attest-plan --verify sha256 子 shell + check-conflicts --runtime 508ms 子 shell，zcode-userpromptsubmit.sh:39/61/136）；M3=PreToolUse Edit **228ms/次**（check-scope.sh 180 行 + check-delegation.sh pretool 571 行/7 jq + check-skill-modify.sh + Rule 23 全 plans 遍历，zcode-pretooluse.sh:18/40/57/104-115）；M5/M6=PostToolUse 276ms（普通）/538ms（编辑 task_plan.md 时 attest 重锁）。一次 Edit 工具调用 = Pre 228ms + Post 276-538ms ≈ **0.5-0.8s 纯 hook 墙钟**；一次复杂任务数百次工具调用 → 数分钟纯 hook 开销，且每条 hook 提醒（[plan-sync]/[plan-compass]/[plan-note]）触发后还要再花主进程轮次响应（SKILL.md:97）。
- **任务类别**：both
- **质量耦合**：medium（delegation/scope/attest 校验承担门控职能，须保留本体；可做 mtime/哈希短路缓存，不做语义放松）
- **预估影响**：mtime 短路（计划与 config 未变时跳过重活）+ conflicts 扫描降频（如每 N prompt 一次）可削 hook 墙钟 50-70%，零语义损失

### 瓶颈 6：冲突扫描 O(N_plans) 随 plans 积累线性放大（本仓 38 个 task 目录）
- **证据锚**：zcode-pretooluse.sh:104-115——每次 Write/Edit `for other_plan in $(ls -t "$CWD/plans"/*/task_plan.md)` 循环，每个他计划做 awk×2+grep 提取 scope 再字符串匹配；zcode-userpromptsubmit.sh:136 每 prompt 跑 check-conflicts.sh --runtime（M2 实测 508ms，含对全部 plans 的解析）。plans/task-* 目录数=38（本会话 `ls -d plans/task-* | wc -l` 实测），且按 task-v069 29.4 归档策略仍在增长。
- **任务类别**：both
- **质量耦合**：low（纯只读检测，无门控语义损失风险）
- **预估影响**：加 active-plan 过滤或 mtime 缓存后，随 plans 增长从线性恶化回归常数；当前即省 ~0.5s/prompt

### 瓶颈 7：plan-resume 每 Phase 全文加载 28.6KB（执行中「仅报告」模式纯仪式）
- **证据锚**：SKILL.md:107（每 Phase complete、DRIFT CHECK 之前被动调 Skill("plan-resume")）+ Rule 24.1（critical-rules.md:163）。plan-resume SKILL.md=433 行/28,616 字节（本会话 wc 实测）≈ 9K tokens 注入/Phase；其脚本 scan-plans.sh 仅 22ms（M16）——成本在 Skill 全文加载与解读轮，不在扫描本身。执行中模式恒为「只报告不续推」（critical-rules.md:161），对当前计划执行零增益；Rule 24.7 仅有「≤3 Phase 跳过」例外（critical-rules.md:169）。
- **任务类别**：complex
- **质量耦合**：low（报告型功能，与质量门控无关；恢复触发点保留即可）
- **预估影响**：6-Phase 任务省 ~54K token 注入 + 6 个解读轮；改为「终态/会话恢复时一次」即消除全部执行中开销

### 瓶颈 8： attest SHA-256 高频路径重校验/重锁（每 prompt 与每次计划编辑）
- **证据锚**：zcode-userpromptsubmit.sh:58-68——有 .plan-attestation 时每轮 prompt `bash attest-plan.sh --verify`（bash+sha256sum 子 shell，无 mtime 短路）；zcode-posttooluse.sh:54-89——每次 Write/Edit 命中 task_plan.md 即同步重跑 attest（M5→M6 实测 +262ms/次）。复杂任务中 task_plan.md 是最高频编辑对象之一（状态翻转/Handoff/checkbox 全在它上面），「编辑→重锁→下轮 prompt 再校验」构成每次编辑 2 次哈希全链。
- **任务类别**：both
- **质量耦合**：medium（防篡改是 Rule 20 质量职能）——保留校验语义，加「文件 mtime+size 未变则跳过重锁/校验」的廉价短路即可，非放松
- **预估影响**：每次计划编辑省 ~0.3s + 每 prompt 省一次 sha256 子进程；复杂任务全程省数十次进程生成

### 瓶颈 9：委派判定 4 门重复（每 Phase 检查点 + 每 Write/Edit hook + 终验 stats + verification 登记）
- **证据锚**：SKILL.md:91（每 Phase 委派检查点）+ zcode-pretooluse.sh:40（每 Write/Edit 调 check-delegation.sh，571 行/7 jq，M3 的主要组成）+ check-complete.sh:381-455（终验 stats 全套解析）+ critical-rules.md:177（25.4 verification.md 统计段）。同一事实（Executor 字段 + Handoff 表）在 4 个位置判定/登记；终验 stats 还会因 Handoff 表格式细节产生 violation 误报（本会话沙箱实测：合法计划因「Executor 含未登记子代理类型:executor」判 verdict=violation → DELEGATION GATE FAILED，见 /tmp/cc-out.txt 记录——该误报本身说明门控对格式敏感、返工概率高）。
- **任务类别**：both
- **质量耦合**：**high**（委派率是本技能第一设计目标的核心门控，SKILL.md:31）
- **预估影响**：不可拆门；可做的是把 ①④ 的 LLM 层复核收敛为引用机器层结果（省每 Phase 一次确认 + 终验重复统计），并修误报源降低返工

### 瓶颈 10：部署三实体位 + diff -rq 三遍 + 部署位 selftest 重跑（交付尾部固定大头）
- **证据锚**：smart-merge-back.sh:375 默认三 slot `$HOME/.zcode/skills/task-planner:$HOME/.claude/skills/task-planner:$HOME/.config/opencode/skills/task-planner`；每 slot 原子替换（cp -rL → mv 改名换位）+ `diff -rq "$DEPLOY_SRC" "$slotdir"` 对账（L555）。实证负担：task-v090 verification.md:23-24「4 文件 ×3 位定向 cp 后逐文件 diff -q 全空；部署位 wf selftest 15/16」——部署位还要再跑一轮 selftest（第 3+ 轮，叠加瓶颈 3）。合并回合约本身还有 V1-V4 预检（smart-merge-back.sh:35-89：worktree 干净 porcelain/已合并检测/--no-ff）。
- **任务类别**：complex
- **质量耦合**：medium（对账是防部署漂移门控，task-v077 修过假 IDENTICAL——diff 必须保留；三遍全量 diff 可改为按变更文件清单定向 diff）
- **预估影响**：技能修改任务交付尾段省 2 次全量 diff -rq（对 558+365+59 脚本的全树比较）+ 部署位 selftest 可降为相关脚本

### 瓶颈 11：CR 多轮与「修改后验证」4 步串行链
- **证据锚**：SKILL.md:145-156——Code Review Gate（全 Phase complete 后调 Skill("code-review") 全量审查；CHANGES_REQUESTED → 自动追加 fix-phase 回执行循环；失败 3 次才 AskUserQuestion）+ SKILL.md:459-463——修改后验证 4 步全串行（code-runner-agent 跑测试 → build-error-resolver 修 → Skill("code-review") → commit），每步都是子代理冷启动；Rule 33（critical-rules.md:275-284）每问题解决动作再强制 [reflect] 反思+验证两行 + ≤3 轮迭代；Rule 31 错误指出再走 4 维归因。多轮 CR × 4 步验证链 × 每 Phase 的 33 循环构成复杂任务返工期的乘法结构。
- **任务类别**：complex
- **质量耦合**：**high**（CR 与独立验证正是「绝不降低质量」诉求的核心载体）
- **预估影响**：不删轮次；可做的是按 diff 规模分级 CR 范围（≤N 行走轻量审查）+ 把 code-runner/build-error 合并为单子代理一步，省 1 次冷启动/轮

### 瓶颈 12：C1-C27 合规清单「每 Phase 开始前逐项确认」的注意力税
- **证据锚**：SKILL.md:173-204 表标题「每 Phase 开始前逐项确认」共 **27 项**；其中 C4a（check-drift --json）、C13（plan-resume）、C16（3-File）、C17（porcelain）、C15（V-N/Evidence）等 ≥10 项与脚本机器门逐条重复（对应脚本锚见表一）；每项确认还常要求「PASS/N-A 记一行」落盘。
- **任务类别**：complex
- **质量耦合**：low（清单是机器门的复述层，机器门本身保留）
- **预估影响**：清单收敛为「脚本未覆盖项」（约 10 项人工项）后，每 Phase 省 5-8 个确认/落盘动作 × N Phase

### 瓶颈 13：同一事实 2-3 处落盘的双写/三写簿记
- **证据锚**：错误双写——critical-rules.md:98（19.4：错误同条摘要进 task_plan.md Errors 表 + progress.md Error Log）；选型双写——SKILL.md:118（技术选型「+ task_plan.md Decisions Made 双写」）；动作三写——关键动作 progress.md（SKILL.md:96）+ ledger-append（同行为 ledger 信号）+ Decisions Made（涉决策时）；Hook 注入又把 task_plan.md/progress.md 尾部反复回灌主上下文（zcode-userpromptsubmit.sh:84-91 每轮 smart 注入 progress 尾 5 行 + Decisions 末 3 行 + in_progress Phase 全文）。
- **任务类别**：both
- **质量耦合**：low（ledger=机器层、md=人读层的分层设计本身合理，冗余在人工层重复抄写）
- **预估影响**：以 ledger 为单一写入点、md 段由脚本生成或终验一次性渲染，可省每 Phase 2-4 次 Edit

---

## 三、乘积模型小结（供方案层引用）

复杂任务总开销 ≈ **[每 Phase 仪式 16 轮 × N_Phase] + [S-unit 固定开销 × ΣS-unit（严格串行）] + [hook 墙钟 0.5-0.8s × 工具调用数] + [selftest 65.7s × 2-3 轮] + [终验 11 门 + 部署 3 位 diff ×3 + CR 多轮]**。
其中纯冗余（去掉零质量损失）集中在：attest↔check-complete 重复 2 门、porcelain 5 门位、plan-resume 执行中扫描、C 清单复述层、双写簿记、hook 无短路重活；带质量职能需护栏改造的集中在：21.4 串行（豁免登记制）、selftest 全量（增量+终验全量）、CR（分级范围）。

## 四、未执行项（如实声明）

1. 未实测真实 ZCode hook 管道的端到端延迟（本次为直接 bash 调用脚本计时，与宿主 hook 调度路径可能有常数级差异）。
2. 未实测 LLM 轮次墙钟（16 轮/Phase 为结构计数，非计时——子代理冷启动耗时因模型/负载而异，无本地可复现基准）。
3. Skill("task-drift-guard")/Skill("plan-resume") 的 token 成本按 SKILL.md 字节数折算（3,455B/28,616B 实测），未做真实 tokenizer 计数。
4. 上轮报告 ④-25（19 条 Rule 无专属 selftest）与本领域交叉但属覆盖面审计，未在本文件重复展开。
