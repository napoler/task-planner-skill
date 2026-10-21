# S6 Critic — 子代理派发契约四载体措辞/字段对齐审计

> 审计对象：`skills/task-planner/references/critical-rules.md`、`skills/task-dispatch/references/critical-rules-dispatch.md`、`skills/task-discipline/references/critical-rules-discipline.md`（规则正文）｜`skills/task-planner/templates/subagent_dispatch.md`、`templates/task_plan.md`、`templates/delivery-summary.md`、`templates/session-handoff.md`（模板）｜`check-dispatch.sh`、`check-plan-dispatch.sh`、`check-delegation.sh`、`check-complete.sh`、`check-subagent-return.sh`（机器门）｜`skills/task-planner/SKILL.md`、`skills/task-dispatch/SKILL.md`（索引指针）
> 方法：全只读；grep/sed 取行号；4 个脚本以 stdin/实跑取证（未写任何文件，`.backup` 已排除）。审计基线 = 当前工作树 HEAD。
> 结论：契约正文与返回模板高度一致（8 字段逐字对齐），**漂移集中在「机器门只认模板的子集」与「模板自身示例/标签触发机器门」两侧**，共 24 条，其中 P0 4 条。

---

## ① 派发契约应然要素表（要素 + 权威出处）

| # | 要素 | 应然内容 | 权威出处 |
|---|------|---------|---------|
| E1 | 返回格式（8 固定字段） | status / acceptance / files / evidence / checkpoint / findings_written / blockers / confidence，顺序与名称不得改、无内容填 none、8 字段后不得有内容 | `skills/task-dispatch/references/critical-rules-dispatch.md:60`（22.4b）；载体 `skills/task-planner/templates/subagent_dispatch.md:72-82` |
| E2 | 派发 prompt 九字段 | 目标/输入/验收/Scope 禁改/工作路径/时长预算/返回格式/checkpoint 路径/上下文预算 | `.../critical-rules-dispatch.md:58`（22.4）；模板 §1-§9 `templates/subagent_dispatch.md:15,22,49,55,66,69,72,95,101` |
| E3 | S-unit 粒度三值上限 | ≤`step_max_files`(2) 文件 / ≤`step_max_lines`(100) 行 / ≤`step_max_minutes`(15) 分钟 | `.../critical-rules-dispatch.md:21`（21.1b）、`:152`（59.1）；`skills/task-planner/config.json:500-502`；模板 `templates/task_plan.md:328` |
| E4 | Phase/单派发规模上限 | 单 Phase ≤3 文件且 ≤300 行；单任务 >3 文件或 >300 行须拆 | `.../critical-rules-dispatch.md:20`（21.1）、`:51`（22.1） |
| E5 | 单派发生产单元数上限 | 内容/媒体类 1 单元/派发；批量小操作 ≤5；其他 ≤3 | `.../critical-rules-dispatch.md:122-130`（46.6） |
| E6 | 步骤枚举 ≤ `step_max_steps`(4) | 显式 StepN/①-⑮ 序号去重超限 = 拆分信号，enforce 硬拦 | `.../critical-rules-dispatch.md:21`（21.1b）；`templates/subagent_dispatch.md:84`；`check-dispatch.sh:505-516` |
| E7 | 执行体选型 | 专用体优先（矩阵）+ 执行一律低档 + 组内异构 + 白名单直做 | `.../critical-rules-dispatch.md:137`（52.1）、`:24`（21.3）、`:177`（68.3）、`:105`（25.3）；`skills/task-dispatch/references/agent-coverage.md:5` |
| E8 | 四文件读写契约不可收窄 | task_plan 只读 / findings 可读+仅追加 `#### [sub:…]` / progress 仅追加 `[sub:N]` / kb 只读（主进程单写） | `.../critical-rules-dispatch.md:59`（22.4a）；`critical-rules.md:115`（62.2）；`templates/subagent_dispatch.md:22-26` |
| E9 | 检查点强制与断点重试 | `<plan-dir>/subagent-state/{seq}-{agent_type}.md`，T1-T5 落盘，fail 后先 Read 再 resume | `.../critical-rules-dispatch.md:67-73`（22.8/22.8.1-22.8.6）；`templates/subagent_dispatch.md:95-99` |
| E10 | Handoff 登记 | 派发前逐行登记（含 findings 落点/checkpoint/rescue/verify_done），返回 30s 内 Read 并复核/回填 | `.../critical-rules-dispatch.md:63`（22.5）；`templates/task_plan.md:492-506`；`critical-rules.md:117`（62.3 调研双锚） |
| E11 | check-dispatch 判定条件 | 三文件绝对路径 + 3 个返回 key + `subagent-state/`；细粒度 6 项；返回段结构；契约收窄；串行槽 | `.../critical-rules-dispatch.md:62`（22.4c）；`check-dispatch.sh:126,202-217,419-631,642-679` |
| E12 | 违例/失败处置 | 三档 enforce/warn/off；兜底 ①改派→②拆细→③降档→④接管→⑤AskUser（+22.3.0 资料档、22.3.3 技能接管）；STOP 6 字段 | `.../critical-rules-dispatch.md:53,54,57,65,66,72`；`skills/task-dispatch/references/dispatch-examples.md:44-58` |
| E13 | 返回回收四判据 | 8 字段齐全 / 无契约外字段 / 块尾无附加 / 值域（status、confidence） | `.../critical-rules-dispatch.md:61`（22.4b 污染三面③）；`skills/task-dispatch/scripts/check-subagent-return.sh:2-8,24-55` |

---

## ② 四载体逐要素比对矩阵

图例：✅ 一致　⚠️ 缺失（仅部分载体有）　❌ 冲突（两侧表述互斥）

| 要素 | ①规则正文 | ②模板 | ③机器门 | ④索引指针 | 判定 |
|------|-----------|-------|---------|-----------|------|
| E1 8 字段 | 22.4b 全列 8 项（`dispatch:60`） | §7 逐字 8 行（`subagent_dispatch.md:74-82`） | 返回侧 8/8（`check-subagent-return.sh:24`）；prompt 侧仅 3/8（`check-dispatch.sh:126`） | `task-dispatch/SKILL.md:49`「8 字段契约校验」 | ❌ prompt 侧窄化（C-01）；⚠️「≤20 字原因」仅规则有（C-20） |
| E2 九字段 | 22.4 枚举 9 项（`dispatch:58`） | 实有 §1-§9 + §4b + §10 + 伴飞（`subagent_dispatch.md:58,104`） | 仅校验 3 key + 检查点 + 长度（§9 预算） | `SKILL.md:80`「按九字段模板」 | ❌ 模板强制段多于规则枚举（C-21） |
| E3 2/100/15 | 21.1b 与 59.1 同值（`dispatch:21,152`） | 列头 + 示例 `1f/30l/15min`（`task_plan.md:328,330`） | plan 侧 col8 enforce（`check-plan-dispatch.sh:287-297`）；dispatch 侧 token enforce（`check-dispatch.sh:557-564`） | 无 | ✅ 值一致 |
| E4 3/300 | 21.1/22.1 独立存在（`dispatch:20,51`） | 未体现 | 无任何门校验 3/300 | 无 | ❌ 与 E3 双轨且无门（C-08） |
| E5 46.6 单元上限 | 全表在位（`dispatch:122-130`） | 无对应字段 | 无脚本 | 无 | ⚠️ 三载体全缺（C-09） |
| E6 ≤4 步 | 21.1b | `subagent_dispatch.md:84` | `check-dispatch` ④ enforce；`check-plan-dispatch` 仅 advisory（`:307-309`） | `SKILL.md:240` 未提 | ✅ 口径已声明（差异属设计） |
| E7 选型 | 52.1/21.3/68.3 | 执行体列仅「继承/type(model)」（`task_plan.md:328`） | `check-plan-dispatch` 仅查非空（`:248-250`），不查矩阵 | `SKILL.md:240` →「路由表」指向卫星 | ❌ 规则三处指向不存在章节（C-10） |
| E8 四文件契约 | 22.4a + 62.2 禁收窄 | §2 四行契约（`subagent_dispatch.md:22-26`） | 三文件身份判定 + 收窄 lint（`check-dispatch.sh:120-195`） | `SKILL.md:215` 摘要 | ⚠️ 只读型子代理无 findings 豁免，契约与工具事实冲突（C-11） |
| E9 检查点 | 22.8.1 命名、22.8.6 代建 | §8 + §7 `checkpoint:` | 仅要求字面 `subagent-state/`（`check-dispatch.sh:126,167`） | `delivery-summary.md:60`、`session-handoff.md:22` | ⚠️ 22.8.6 前提失真、模板无代建形态（C-19）；命名 seq 口径漂移（C-22） |
| E10 Handoff | 22.5 列 12 项（`dispatch:63`）；22.4b 说「结论摘要」列（`:61`） | 10 列，第 6 列「结论摘要」、第 10 列「备注(rescue/retry/verify_done)」（`task_plan.md:502`） | `check-delegation.sh:445` 裸类型整格匹配；`check-complete.sh:1741,1747` | 无 | ❌ type 列缺失、结论/结论摘要两称（C-16）；verify_done 门死代码（C-17） |
| E11 check-dispatch | 22.4c 3 key（`dispatch:62`） | §7 有 8 key | 段门要求第 4 key `confidence:` 且以标题形态为前提（`check-dispatch.sh:202-208`） | 无 | ❌ 同一脚本两套 key 集 + 标题形态开关（C-02） |
| E12 违例处置 | 三档 + 六档兜底 + STOP 6 字段 | `dispatch-examples.md:44-58` 6 字段 | `check-dispatch.sh:630-631` exit 2 | `SKILL.md:240`「五档兜底」漏 22.3.0/22.3.3 | ⚠️ 索引收窄（C-12） |
| E13 四判据 | 22.4b 污染三面 | §7「8 字段之后不得有任何内容」 | 逐条实现（`check-subagent-return.sh:31-55`） | `task-dispatch/SKILL.md:49` 仅列脚本 | ✅ 规则↔脚本一致；⚠️ 未接任何 hook/终验（C-15） |

---

## ③ 机器门字面 vs 模板字段对照表

| 门 | 实际字面（含行号） | 模板实际字段/文本 | 一致性 | 后果 |
|----|------------------|------------------|--------|------|
| 三文件路径 | `cands="$(grep -oE '[^[:space:][:cntrl:]]*/(task_plan\|findings\|progress)\.md'"`（`check-dispatch.sh:125`）+ inode/realpath 身份比对（`:138-156`） | `{plan_dir}/task_plan.md` 等（`subagent_dispatch.md:23-25`） | ✅ | 占位符未实例化即缺项 |
| 返回 key（prompt） | `for item in … "status:" "acceptance:" "checkpoint:" "subagent-state/"`（`:126`，命中判定 `:167` `grep -qF`） | 8 字段 block（`:74-82`） | ❌ 3/8 | 只声明 3 key 的 prompt 放行（T1） |
| 返回格式段标题 | `^## ([0-9][.] )?返回格式`（`:202-203`） | `## 7. 返回格式(严格 — Rule 22.4b…)`（`:72`） | ⚠️ 形态敏感 | `###`/`## 7、返回格式` → 整门 fail-open（T2） |
| 段内 key | `for k in status: acceptance: checkpoint: confidence:`（`:208`） | 8 字段 | ❌ 4/8 且必含 confidence | 同内容有标题则拦、无标题则放（T3） |
| 检查点路径 | 字面 `subagent-state/`（`:126`） | §8「约定 `<plan-dir>/subagent-state/{seq}-{agent_type}.md`」（`:96`） | ⚠️ 模板文字即可满足 | 空占位模板也过门 |
| 打包检测 | `grep -oE 'S[0-9]+' … sort -u … ≥2`（`:462,472-473`） | S-unit ID `S1`（`task_plan.md:328`） | ✅ | 检查点文件名 `S6-critic.md` 计入，可能噪声 |
| 步骤枚举 | `step ?[0-9]{1,3}` / `步骤 ?[0-9]{1,3}` / `第[0-9]{1,3}步` / ①-⑮（`:385-394`） | §7 注「≤ step_max_steps（默认 4）」（`:84`） | ✅ | — |
| 粒度三值 | `[0-9]+f/[0-9]+l/[0-9]+min` + 行界双验证（`:540-543`） | `1f/30l/15min`（`task_plan.md:330`） | ✅ | — |
| 伴飞路径 | `grep '伴飞' … \| grep -oE '[A-Za-z0-9._/-]+\.md'` 后 `-f` 校验（`:580-592`） | 「注入格式: 伴飞技能 SKILL.md 绝对路径:{escort_skill_path}」（`subagent_dispatch.md:38`） | ❌ 标签被当路径 | enforce 档误拦合规派发（T4） |
| 契约收窄 | `#### [sub:` / `可写=仅追加` / `只写检查点` / `主进程回填.*(你只\|不用写\|…)`（`:183-190`） | §2 同时含前两锚（`:24`） | ✅（22.4a 写 `可写 = 仅追加` 带空格 → 仅靠 `#### [sub:` 兜住） | 空格漂移时漏判（C-23） |
| 串行槽 | `.dispatch-inflight` age<120s（`:646-655`） | 21.4「后台派发视为持续占用」（`dispatch:29`） | ✅ | 边界已如实披露 |
| 返回 8 字段 | `^[[:space:]]*${c}:` 逐字段（`check-subagent-return.sh:24,32`） | 8 字段（`:74-82`） | ✅ | — |
| 契约外字段 | `^[[:space:]]*[a-z_]+:` 反白名单（`:35-36`） | 8 字段 | ✅（严格） | 小写辅助行（`tests: 12 passed`）被误判（实测 rc=1） |
| 块尾 | 最后一个 `confidence:` 后仅空白/```（`:38-44`） | 「8 字段之后不得有任何内容」 | ✅ | 同时隐式强制 confidence 末位，但字段内部顺序不校验（T: 实测 PASS） |
| 值域 | status 4 值 / confidence 3 值（`:46-55`） | §7 同（`:74,82`）；Handoff 状态枚举 8 值（`task_plan.md:496`） | ❌ 跨载体 | `status: blocked` 被判不合格（T5） |
| Handoff 已填 | 第 5 列（任务目标）非空（`check-complete.sh:1741`） | 第 5 列 = 任务目标（`task_plan.md:502`） | ✅ | — |
| verify_done 列 | 单元格全等 `"verify_done"`（`check-complete.sh:1747`） | 单元格 `备注(rescue/retry/verify_done)`（`:502`） | ❌ 恒不匹配 | 恒 fail-open（T12） |
| Executor↔Handoff | `\|[[:space:]]*<tok>[[:space:]]*\|` 整格匹配（`check-delegation.sh:445`） | subagent_type 无格式约定；22.6 执行体为 `type(model)`（`dispatch:64`） | ❌ | 带 `(model)` 或聚合式 Executor 判 unverified（T8/T9） |

---

## ④ 误判触发条件清单

| # | 触发条件 | 门的行为 | 应然 | 实测/静态 |
|---|---------|---------|------|-----------|
| T1 | prompt 只写 `status:` `acceptance:` `checkpoint:` 三 key | enforce 放行 | 22.4b 要求 8 字段 | 静态（`check-dispatch.sh:126`）；3 字段返回实测 `VIOLATION 判据一: 缺字段 files:` rc=1 |
| T2 | 返回格式段标题写成 `### 7. 返回格式` 或 `## 7、返回格式`，段内塞 ①②③ 任务清单 | 不识别标题 → 整门 skip（fail-open） | 应拦污染段 | 静态（`:202-204` + `[ -n "$ln" ] \|\| return 0`） |
| T3 | 有 `## 返回格式` 段但只列 3-4 key（缺 `confidence:`） | enforce exit 2 | 与 T2 同内容应同判 | 静态（`:208-217`） |
| T4 | 照模板 §2 保留「伴飞技能 SKILL.md 绝对路径:<真实绝对路径>」整行 | 提取 token `SKILL.md`（本仓根无该文件）→ `-f` 失败 → exit 2 误拦 | 应只校验真实路径 | 静态（`subagent_dispatch.md:38` + `check-dispatch.sh:580-598`） |
| T5 | 子代理返 `status: blocked`、`blockers:` 写原因 | VIOLATION 判据四（值域外） | Handoff 枚举含 blocked（`task_plan.md:496`） | 实测 rc=1 |
| T6 | 子代理返 `status: failed` + `blockers: none` | PASS | 模板：「failed 时 `blockers:` 写原因」（`:87`） | 实测 rc=0 |
| T7 | 子代理返 `acceptance: 全部通过`（n/total 缺失） | PASS | 22.4b 要求 `n/total pass` + 逐项 | 实测 rc=0 |
| T8 | Phase Executor 写「按 S-unit 表（A/B/C）」 | type_hint=`按S-unit表` → 恒不命中 → `unverified_delegation`，delegated-1 | 应支持聚合声明 | 实测：`check-delegation.sh stats plans/task-skill-audit-20261021` → `delegation_rate:0.000`、violation 含「Executor 含未登记子代理类型:按S-unit表」 |
| T9 | Handoff `subagent_type` 格写 `executor(sonnet-1)`（与 22.6 执行体列同形） | `\| executor \|` 不命中 → unverified | 格式应在 22.5/模板成文 | 静态（`check-delegation.sh:436-445`） |
| T10 | S-unit 行「输入」列 ≥3 个 .md/.sh 路径 | 仅 `SKIPPED … 建议拆分(提示不阻断)` | 模板声称「超限= enforce 档硬阻断拒锁」（`task_plan.md:321`） | 实测：`[plan-dispatch] SKIPPED Phase 2 S3 输入 3 个文件路径 > step_max_files(2)` |
| T11 | 计划「预估时长」列按模板示例写 `≤15min` | `^([0-9]+)min$` 不匹配 → `SKIPPED 时长不可解析` | 模板注释要求「一律写 NNmin 格式」（`:320`） | 静态（`check-plan-dispatch.sh:261-268` + `task_plan.md:330`） |
| T12 | Handoff 行 `verify_done` 留 ☐ | 门静默跳过（列名折叠不符） | 22.5 硬条件 | 静态（`check-complete.sh:1747` + `task_plan.md:502`） |

---

## ⑤ 发现清单（C-01 起，按等级）

### P0 — 会导致执行产出不稳定

**C-01（P0｜误放行→返工）prompt 侧只校验 8 字段中的 3 个，返回侧却要求 8 个**
- 原文 A：`` `for item in "$pd/task_plan.md" … "status:" "acceptance:" "checkpoint:" "subagent-state/"; do` ``（`check-dispatch.sh:126`）
- 原文 B：`` 子代理必须按 … §7 的 **8 个固定字段**逐字段返回 ``（`critical-rules-dispatch.md:60`）
- 原文 C：`FIELDS="status acceptance files evidence checkpoint findings_written blockers confidence"`（`check-subagent-return.sh:24`）
- 原因：派发端只保证 3 key 即可过门，子代理按 3 key 返回必被返回端判 VIOLATION（已实测），或主进程被迫打回重报/以检查点兜底。
- 置信度：HIGH（静态 + 行为实测）

**C-02（P0｜误拦+漏拦双面）返回格式段门以「标题形态」为开关，且要求第 4 个 key**
- 原文 A：`n="$(grep -cE '^## ([0-9][.] )?返回格式'"` / `[ -n "$ln" ] || return 0`（`check-dispatch.sh:202-204`）
- 原文 B：`for k in status: acceptance: checkpoint: confidence:; do`（`:208`）
- 原因：改成 `###`/中文顿号即整门静默放行（污染 prompt 漏拦）；保留标题但缺 confidence 则 exit 2（合规倾向 prompt 误拦）——同一契约两种判定。
- 置信度：HIGH（静态）

**C-03（P0｜错误拦截）伴飞检查把模板标签「SKILL.md」当成路径**
- 原文 A：`注入格式: 伴飞技能 SKILL.md 绝对路径:{escort_skill_path}；`（`subagent_dispatch.md:38`）
- 原文 B：`esrcs+=("$er"); done < <(grep '伴飞' "$pf" … | grep -oE '[A-Za-z0-9._/-]+\.md'` + `if [ ! -f "$p" ]`（`check-dispatch.sh:580,592`）
- 原因：即使 `{escort_skill_path}` 已填真实绝对路径，同行的标签词 `SKILL.md` 仍被抽为候选，CWD 下不存在 → enforce 档 exit 2，合规派发被拦。
- 置信度：HIGH（静态；脚本注释 `:574-578` 还把「未实例化占位符=违规面」合法化，未覆盖标签词）

**C-04（P0｜返回被判不合格）`status` 值域 4 值 vs Handoff 状态枚举 8 值**
- 原文 A：`status ∈ done|partial|failed|timeout`（`check-subagent-return.sh:51`）
- 原文 B：`状态枚举: queued/pending/running/done/partial/timeout/failed/blocked/scaling-redispatch`（`task_plan.md:496`）
- 原因：子代理按 Handoff 口径返 `status: blocked`（22.7/28.4.1 语境合法）→ 判据四 VIOLATION（实测 rc=1），合法信号被判不合格。
- 置信度：HIGH（行为实测）

### P1 — 会导致返工或追溯困难

**C-05（P1｜误判）Handoff `subagent_type` 必须写裸类型，该约束无任何成文**
- 原文 A：`if grep -qE "\|[[:space:]]*${_tok_norm}[[:space:]]*\|" "$plan_file"`（`check-delegation.sh:445`）
- 原文 B：`| # | 时间 | subagent_type | 任务目标(≤1 句) | …`（`task_plan.md:502`，无格式约定）；22.6 执行体为 `subagent_type(model)`（`dispatch:64`）
- 原因：按 22.6 同形写 `executor(sonnet-1)` → 整格不匹配 → `unverified_delegation` + delegated-1 → 委派率被压低。
- 置信度：HIGH（静态）

**C-06（P1｜实测）聚合式 Executor 恒判未登记**
- 原文 A：`- **Executor:** 按 S-unit 表（agent-quality-auditor/critic/code-runner-agent/Explore）`（`plans/task-skill-audit-20261021/task_plan.md:183`）
- 原文 B：`type_hint="${type_hint#*:}" … "${type_hint%%（*}"`（`check-delegation.sh:421-424`）
- 原因：剥括号后得 `按S-unit表`，永不匹配 Handoff 列 → 该 Phase 不计委派。实测本计划 `phases_delegated:0 / delegation_rate:0.000`（5 Phase 全派发），终验 `delegation_rate_floor` 0.7 将直接判不合格。
- 置信度：HIGH（行为实测）

**C-07（P1｜判定口径不一）「三证据」= 2 动作还是 3 证据**
- 原文 A：`子代理返回 30s 内主进程必须 Read 实际产出 **并复核/回填 findings** … 两动作完成才可勾 verify_done`（`dispatch:63`，22.5 只定义 2 动作）
- 原文 B：`三证据验收(执行记录/产出 Read 复核/验证证据)`（`dispatch:26,29,95,160,179`；`critical-rules.md:133`；`critical-rules-discipline.md:385`；`templates/session-handoff.md:17` 写 `<三证据>`）
- 原因：引用者把「22.5 口径」当 3 项，22.5 本体是 2 项；验收时按哪套判定无权威答案 → 合格/不合格可争议。
- 置信度：HIGH（两侧原文对照）

**C-08（P1｜门与文档不符）S-unit 上限双轨（2/100/15 vs 3/300），且模板声称 enforce 实为 advisory**
- 原文 A：`≤step_max_files 文件 / ≤step_max_lines 行 / ≤step_max_minutes 分钟`（`dispatch:64`，22.6/21.1b）
- 原文 B：`单任务触及文件 >max_files_per_dispatch(默认 3)或行数 >max_lines_per_dispatch(默认 300)→ 拆子任务`（`dispatch:51`）
- 原文 C：`② 输入列文件路径 token 计数 ≤2,超限= enforce 档硬阻断拒锁`（`task_plan.md:321`）vs 脚本 `echo "[plan-dispatch] SKIPPED … 建议拆分(提示不阻断,复杂度由模型判断)"`（`check-plan-dispatch.sh:270-273`）
- 原因：三值并存，机器只对「粒度三值列」(col8) enforce，对「输入列/预估时长列」仅提示 → 超限 S-unit 合法流入派发；模板承诺的拒锁不存在（已实测 SKIPPED）。
- 置信度：HIGH（行为实测）

**C-09（P1｜三载体全缺）46.6「单派发 1 个生产单元」无模板字段、无机器面、无索引**
- 原文 A：`内容生产/修正类…**1 个生产单元/派发**…2 篇及以上一律拆分`（`dispatch:124`）
- 原文 B：`本会话只执行本 S-unit：完成后交回主进程验收`（`subagent_dispatch.md:17`，只约束 S-unit 数，不约束单元数）
- 原因：4 篇并入一个 S-unit 仍满足模板与全部门 → 46.6 无载体可执行（该条自述 LLM 行为面，但模板亦无提示）。
- 置信度：HIGH（静态；`grep 46.6` 仅命中规则正文 + selftest 计数）

**C-10（P1｜指针悬空）执行体选型的权威章节不存在**
- 原文 A：`完整路由表见 SKILL.md §「子代理路由与模型分级」`（`critical-rules-dispatch.md:11`）；`详见 SKILL.md §「编辑强制隔离」`（`:14`）；`:49` 同引两节
- 原文 B：`选型按 SKILL.md §子代理路由与模型分级路由表`（`templates/task_plan.md:270`）；同类悬空 `plan-research-router/references/research-routing.md:42`、`plan-cost-guard/references/cost_log.md:42`
- 原因：`skills/task-planner/SKILL.md` v171 瘦身后已无该章节（全文 17 个 `## ` 标题无此节）→ 选型指向死链，读者只能落到 `agent-coverage.md`（非规则所列）。
- 置信度：HIGH（章节枚举 + grep）

**C-11（P1｜契约与工具事实冲突）只读/聚合型子代理的 findings 自写无豁免**
- 原文 A：`禁止出现「只写检查点」「主进程回填（你不用写）」类**收窄措辞**`（`critical-rules.md:115`，62.2）
- 原文 B：22.8.6 只豁免 checkpoint：`22.8.1 的检查点文件允许**由主进程当场代建**`（`dispatch:73`）
- 原文 C：`tools: Read, Write, Grep, Glob, Bash, TodoWrite`（`/home/terry/.zcode/agents/explore.md:5`）
- 原因：22.8.6 以「tools 不含 Write（如 Explore）」为前提，但 Explore 实有 Write → 豁免条件失真；同时 findings 侧无对应豁免，遇到真正无写能力的执行体只能收窄（违 62.2）或静默兜底。
- 置信度：HIGH（三处原文）

**C-12（P1｜处置链被收窄）索引把六档兜底压成五档**
- 原文 A：`五档兜底=改派→拆细→降档→接管→AskUser`（`skills/task-planner/SKILL.md:240`）
- 原文 B：`22.3.3 协同技能接管评估 … ⑤ AskUser/STOP 之前,主进程必须先评估`（`dispatch:57`）；`22.7 … 未走完 22.3 ①-④（含 22.3.0 评估）档位与 22.3.3 … 禁止直接 STOP`（`dispatch:65`）
- 原因：只读索引的读者会在 ④→⑤ 直接 STOP，跳过 22.3.0 资料档与 22.3.3 技能接管两道强制评估。
- 置信度：HIGH（静态）

**C-13（P1｜定位面污染）Rule 75/91 的归属错误进入派发依赖面**
- 原文 A：`按 75.8 方向粒度处理`（`dispatch:128`，46.6 豁免①依赖 Rule 75.8）
- 原文 B：`69-76`（`skills/task-planner/SKILL.md:17,195` 把 Rule 75 划给 task-discipline）vs 真身 `skills/plan-research-router/references/critical-rules-research.md:42`（Rule 75）与 `:62`（75.8）
- 原文 C：`- **plan-collab-router**（…）（Rule 39,40）`（`critical-rules.md:198`，漏 Rule 91；真身 `critical-rules-collab.md:38`）
- 原因：按索引读 discipline 得 0 命中 → 调研粒度/模型分档两条派发约束「读了但不存在」。
- 置信度：HIGH（S3 已证 + 本次复核）

**C-14（P1｜该拦没拦）`acceptance` 值域完全不校验**
- 原文 A：`acceptance: <n>/<total> pass — [1:PASS 2:PASS ...]`（`subagent_dispatch.md:75`）
- 原文 B：判定仅「各 ≥1 行命中」（`check-subagent-return.sh:31-34`）
- 原因：`acceptance: 全部通过` 实测 PASS（rc=0），不可核验的验收自报可被采信，直接违背 22.4b 去口供化目的。
- 置信度：HIGH（行为实测）

**C-15（P1｜闭环未机器化）返回侧四判据无任何调用点**
- 原文 A：`收到子代理返回后先过 scripts/check-subagent-return.sh`（`dispatch:61`）
- 原文 B：仓库内唯一引用为文档行 `| scripts/check-subagent-return.sh | 子代理返回 8 字段契约校验 |`（`skills/task-dispatch/SKILL.md:49`）；`zcode-*.sh` / `check-complete.sh` 零命中
- 原因：不跑也没有任何信号（PostToolUse 只清串行锁，`zcode-posttooluse.sh:25-29`）→ 违规返回静默采信。
- 置信度：HIGH（grep 全仓）

### P2 — 措辞/追溯瑕疵

**C-16（P2）Handoff 列契约三方漂移**
- 原文 A：`时间/subagent_type/type/目标/状态…/结论/证据/findings 落点/checkpoint 路径/rescue…/retry_count/verify_done☐`（`dispatch:63`，12 项，含独立 `type` 列与「结论」）
- 原文 B：`| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | … | （备注(rescue/retry/verify_done)）`（`task_plan.md:502`，10 列，无 type 列、「结论摘要」）；22.4b 又称「结论摘要」列（`dispatch:61`）
- 附：62.3 要求调研类记双锚 `findings锚|kb:§N`（`critical-rules.md:117`），模板注释只写「记段落锚点」（`task_plan.md:494`）
- 原因：按 22.5 建表会多出 type 列/改列名，机器与人工各读一套；调研双锚无模板位。

**C-17（P2）verify_done 机器判定为死代码**
- 原文 A：`if(v=="verify_done"){print i;exit}`（`check-complete.sh:1747`）
- 原文 B：`备注(rescue/retry/verify_done)`（`task_plan.md:502`）；模板已披露 `verify_done 无机器消费`（`:497`）
- 原因：恒不匹配 → 恒 fail-open；模板披露与脚本注释「表头无该列 → fail-open」互相印证为「永远无该列」，22.5 硬条件实际无门。

**C-18（P2）返回侧无跨字段一致性校验**
- `status: failed` + `blockers: none` 实测 PASS，而模板要求 `failed 时 blockers: 写原因`（`subagent_dispatch.md:87`）；字段内部顺序（如 files 先于 status）实测 PASS，而 §7 写「字段名与顺序不得改」（`:72`）。

**C-19（P2）22.8.6 前提失真 + 模板无代建形态**
- `tools 不含 Write（如 Explore 等只读型）`（`dispatch:73`）与 `explore.md:5` 的 tools 列表冲突；模板 §7/§8 未给 `（待主进程代建）` 值形态（仅 `check-subagent-return.sh:71-74` fixture 5 认可）。

**C-20（P2）22.4b 细则未进模板**
- `逐项 PASS/FAIL 及 ≤20 字原因`、`派发 prompt 必须附模板路径引用`（`dispatch:60`）在 §7 block 中无对应要求（`subagent_dispatch.md:74-82`）。

**C-21（P2）模板强制段多于规则九字段**
- 22.4 只列 9 项（`dispatch:58`），模板另有 `### 4b 变更类型约束`（`:58`）与 `## 10 防幻觉契约（禁删）`（`:104`）——「九字段」口径读不出这两项强制。

**C-22（P2）检查点命名的 seq 口径漂移**
- 22.8.1：`seq 为 Handoff 表行号`（`dispatch:68`）；模板同（`subagent_dispatch.md:96`）；实际本计划目录为 `S1-explore.md / S3-auditor.md / S8-runner.md`（`plans/task-skill-audit-20261021/subagent-state/`）。追溯时「seq=行号」假设不成立。

**C-23（P2）收窄 lint 字面与 22.4a 措辞空格漂移**
- lint 认 `可写=仅追加`（`check-dispatch.sh:183`）与 `可写 = 仅追加`（`dispatch:59` 带空格）不同字面；仅靠 `#### [sub:` 兜底，若 prompt 用「可写 = 仅追加」且未贴锚点字面 → 条件 B 误判成立。

**C-24（P2）锚点过期/路径基准混用**
- `subagent_dispatch.md:62-77`（`check-subagent-return.sh:9`）实际 8 字段 block 在 `:74-82`、§7 起 `:72`；
- 同一规则文件内 `scripts/check-subagent-return.sh`（`dispatch:61`，基准=task-dispatch 根）与 `../../task-planner/scripts/check-dispatch.sh`（`:62`，基准=references/）两套相对基准；
- `task-dispatch/SKILL.md:44-55` 脚本表漏 `check-dispatch.sh`、`check-plan-dispatch.sh` 与 `templates/subagent_dispatch.md` 指针。

---

## 总结：Top 3 风险

1. **C-01/C-02（P0）prompt 侧门与模板/返回侧门三套契约**：3 key vs 4 key vs 8 字段，且段门以标题形态为开关 —— 「该拦没拦」与「不该拦却拦」同源，是历史上「契约收窄 lint 与模板措辞不一致」缺陷的现行形态。
2. **C-03（P0）伴飞门误拦**：模板自带标签词 `SKILL.md` 被当作待校验路径，enforce 档下按模板骨架派发即可能 exit 2 —— 合规派发被错误拦截，且报错指向「伴飞路径不存在」误导排查方向。
3. **C-04/C-05/C-06（P0/P1）状态与执行体字段的跨载体枚举不一致**：`blocked` 合法返回被判不合格；`subagent_type` 裸类型要求未成文；聚合式 Executor 实测把委派率打成 0.000 —— 直接影响终验 outcome。

**副风险**：C-09（46.6 无载体）与 C-11（只读型 findings 契约冲突）会让「单派发单生产单元」「子代理自写 findings」两条核心纪律继续靠自觉。

## 负结果报告（检查过、未发现问题）

- 已检查：`critical-rules.md`（203 行全读）、`critical-rules-dispatch.md`（185 行全读）、`critical-rules-discipline.md`（Rule 33.3/54/69.1/74.4/76 段）、`subagent_dispatch.md`（112 行全读）、`task_plan.md`（Handoff/S-unit/Goal 段）、`delivery-summary.md`（83 行全读）、`session-handoff.md`（38 行全读）、`check-dispatch.sh`（全部关键段）、`check-plan-dispatch.sh`（表头/numeric/Goal/68 段）、`check-delegation.sh`（stats/Handoff 段）、`check-complete.sh`（compliant 抽查段）、`check-subagent-return.sh`（全读）、两个 SKILL.md。
- 预期有问题但**未发现**：① 三文件路径判定的 bind-mount 双视图误判（inode 判定已覆盖）；② `check-subagent-return.sh` 内部 5 夹具自检（`--selftest` 全 PASS）；③ config 值与 21.1b/59.1 文案不一致（500-502 与规则 2/100/15 完全一致）；④ `dispatch-examples.md` §3 STOP 六字段与 22.7.1 不一致（逐字一致）；⑤ 伴飞/收窄/粒度三值在 59.1/59.2/62.2 与模板 §2/§9 的值漂移（值一致）。
- 排除：`templates/delivery-summary.md` 与 `session-handoff.md` 只承载「指针/三证据」不承载返回格式，故不构成返回契约冲突（仅 C-07 口径引用）；`.backup` 目录按要求排除；Rule 22 的 22.3.1/22.3.2 与 fallback 脚本 `tier_order` 的边界已由规则自述披露，未计入。

## 验证摘要

- 总发现：24（P0=4、P1=11、P2=9）
- 已验证：24（Grep/sed 逐条复现原文；每条含 file:line）
- 通过率：100%
- 其中行为实测 8 条：C-01（3 字段返回 rc=1）、C-04（blocked rc=1）、C-06（delegation_rate 0.000）、C-08（SKIPPED 提示）、C-14（acceptance 全部通过 rc=0）、C-18（failed+blockers none rc=0；乱序 PASS）、C-15（全仓无调用点）、fixture 自检 5/5 PASS
- 静态未实测 16 条：C-02/C-03/C-05/C-07/C-09–C-13/C-16/C-17/C-19–C-24（代码/文本直读可判，标注置信度 HIGH）
