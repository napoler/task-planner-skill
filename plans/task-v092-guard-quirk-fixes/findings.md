# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
-

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
-

### S1 check-conflicts 取证（2026-09-27，executor）
环境：GNU Awk 5.2.1；真实数据 /mnt/data/dev/task-planner-skill/plans/INDEX.md；夹具 /tmp/s1-fixtures/{repo-fa,repo-fb,repo-fc}；逐段证据 /tmp/s1-evidence/stage1-5.txt。

#### 1a INDEX 解析恒空 —— 根因已锁定（HIGH）
真实 INDEX.md 形态（plans/INDEX.md:8-9）：表头 9 字段 `| Task ID | Status | ... | 待办 |`；**下一行即分隔行** `|---------|--------|-----------|------|---------|------|`（首列 9 连字符，且仅 6 字段——与 9 字段表头列数不一致，sync-todos.sh 产出畸形，登记不修）。

管道五段逐段实跑（check-conflicts.sh:144，段与段以 /tmp/s1-evidence/stage1-5.txt 为证）：

| 段 | 命令 | 输出行数 | 首/尾行内容 |
|----|------|---------|------------|
| S1 | `sed -n '/^| Task ID/,/^|-------/p'` | **2** | 行1=表头；行2=分隔行（数据行 :10-:47 全未捕获） |
| S2 | `… \| tail -n +2` | **1** | 仅分隔行 |
| S3 | `… \| grep '^|'` | 1 | 同上 |
| S4 | `… \| sed 's/^|//;s/|$//'` | 1 | `---------|--------|-----------|------|---------|------` |
| S5 | `… \| awk -F'|' '{gsub…print $1"|"$2…}'` | 1 | 同 S4（task_id=`---------`，status=`--------`） |

while read 模拟（:124-126 原样五字段）：`read: task_id=[---------] status=[--------] -> BRANCH: continue (status != in_progress)`。

**1a 根因结论**：sed 区间 `/start/,/end/` 语义=「end 匹配的第一行即终止区间输出」。真实 INDEX.md 分隔行首列 9 连字符命中 end 模式 `^|-------`（≥7 连字符），且分隔行紧邻表头 → 区间只输出表头+分隔行 2 行，数据行永不进入管道；`tail -n +2` 跳表头后只剩分隔行；分隔行拆出的 status=`--------` 恒 ≠ `in_progress` → :126 continue 恒命中 → **active_plans 恒空，A/B/C 检测从不触发**。材料包候选「表头形态不匹配」「status 含格式」均被排除（表头匹配成功、status 门控逻辑本身正常），真因=区间提前终止。

#### 1b 自计划跳过恒不等 —— 根因已锁定（HIGH）
判定代码 check-conflicts.sh:170 `[[ "$other_plan" == "$current_plan_dir" ]]`。两侧来源：
- `other_plan` = :127 `plan_dir="plans/$task_id"` → **相对路径** `plans/task-fc`
- `current_plan_dir` = :149 `for candidate in "$repo/plans"/*` glob → **绝对路径** `/tmp/s1-fixtures/repo-fc/plans/task-fc`

实证证据（/tmp 夹具 repo-fc，bash -x trace 原文）：
```
+ [[ plans/task-fc == \/\/\t\m\p\/\s\1\-\f\i\x\t\u\r\e\s\/\r\e\p\o\-\f\c\/\p\l\a\n\s\/\t\a\s\k\-\f\c ]]
```
→ 恒 NOT-EQUAL（字符串比较，相对≠绝对）→ :170 continue 恒不执行 → 自计划进入 A/B/C 检测。端到端后果（repo-fc 实跑 runtime）：自计划与自己 scope 比较，`comm -12` 交集=自身全部 scope → **恒自报冲突 A 误报** `🔴 冲突 A(同文件): plan task-fc … 覆盖文件: src/shared.py, lib/util.ts`，rc=1。材料包候选「路径形态不一致」实证成立；「空白未剥」排除（awk gsub 已剥净，管道输出 task_id 无空白）。注：1b 与 1a 是叠加缺陷——1a 修复前循环体零执行，1b 不可见；1a 修复后 1b 必然显形（当前活跃计划自身必然在 INDEX in_progress 行中）。

#### 夹具对照表（同一管道、3 种 INDEX 形态）
| 夹具 | INDEX 形态 | 管道输出 | while read 门控结果 | active_plans |
|------|-----------|---------|--------------------|--------------|
| repo-fa | 真实形态：9 连字符分隔行紧邻表头 | 1 行（分隔行） | SKIP `status=[--------]` | **恒空**（复现 1a） |
| repo-fb | 表头与分隔行间夹数据行 | 2 行（数据行+分隔行） | `ACTIVE: plans/task-fb` + SKIP 分隔行 | 非空 |
| repo-fc | 标准 markdown 短分隔行 三连字符紧邻表头 | 2 行（分隔行+数据行） | SKIP `task_id=[---]` + `ACTIVE: plans/task-fc` | 非空（end 模式不匹配→区间延伸至 EOF） |

端到端对照：repo-fa（真实形态）runtime → `✓ 运行时并发冲突检测通过` rc=0（INDEX 有 in_progress 行仍零检测=1a 后果）；repo-fc runtime → 自报冲突 A rc=1（1b 证据）；主仓真实环境 runtime → 仅信号①（3 文件均本任务簿记：plans/.active_plan、plans/INDEX.md、plans/task-v092-guard-quirk-fixes/），A/B/C 零输出。

#### 范围外注记（一行，维持 deferred）
S13②「plan glob 不匹配顶层形态」（v091 progress.md:79 维持 deferred）：本 S1 实测 `"$repo/plans"/*` 顶层 glob 在夹具上可正常命中 `plans/<task>/task_plan.md` 顶层目录形态（VARREPLAY 输出 current_plan_dir=/tmp/s1-fixtures/repo-fc/plans/task-fc），其登记所指的具体不匹配机理未在本 S1 展开，维持 deferred。

#### 供 Phase 2 修复注意（证据支持的方向，非定论）
1. 1a 修法须使「表头→分隔行→数据行」整表进入清洗管道并滤除表头/分隔行；分隔行/伪行（task_id=`---`）即使到达 :128 `[ -f plans/---/task_plan.md ]` 亦会自然 continue，无副作用风险。
2. 1b 修法候选：比较键归一为 basename（task_id 唯一）或 plan_dir 产绝对路径 `"$repo/plans/$task_id"`；注意 :149 glob 绝对性依赖传入 repo 参数为绝对（repo 默认 $PWD 为绝对；传相对则双侧同相对——basename 归一两种传参均稳）。
3. 不得回退 :139/:166 plan_parse_scope 接入（计划强约束）；E2E-FC 中 scope 交集按「整格」比较输出 `src/shared.py, lib/util.ts` 一条，系 plan_parse_scope 点分整格既有语义，非缺陷。
4. CC-06 夹具同步（S7）：真实 INDEX.md 形态=9 字段表头+**6 字段**分隔行（列数不一致畸形），CC-06 改造应按此真实形态构造。

### S2 check-drift 取证（2026-09-27，executor）
环境：GNU Awk 5.2.1 + mawk 交叉验证；bash 5.2.21；对象 skills/task-planner/scripts/check-drift.sh（master 0b2208b）；夹具 /tmp/s2-fixtures/fixture-{a,b,c,d,e}/plans/task-x/；逐段证据 /tmp/s2-evidence/{3a-runs.txt,3b-stages.txt,3c-probes.txt,3c-precedents.txt}。

#### 3a check_phase_order 初值误报 —— 根因已锁定（HIGH）
机理：check-drift.sh:122 `local prev_status="pending"` 初值凭空虚构「虚拟 Phase 0=pending」；:138 判定 `status=="complete" && prev_status=="pending"` → 扫描区间（:146 sed 区间 `/^## Phases/,/^## Key Questions/p`，首尾模式不同，不踩 3c 缺陷）内**首个状态行为 complete 即违约**。全脚本四夹具实跑对照（/tmp/s2-evidence/3a-runs.txt）：

| 夹具 | Status 序列 | check_phase_order 输出 | rc |
|------|------------|----------------------|----|
| fixture-a | complete,complete,complete（ALIGNED 全完成）| **CRITICAL PHASE-SKIP 误报** | 1 |
| fixture-c | complete,in_progress,pending（正常推进中）| **CRITICAL PHASE-SKIP 误报**（文案与真越级完全相同）| 1 |
| fixture-b | pending,complete,pending（真越级）| CRITICAL PHASE-SKIP **正常报警** | 1 |
| fixture-d | pending,in_progress,complete（渐进完成）| INFO PHASE-ORDER「Phase 顺序正常」| 0 |

误报原文（fixture-a/c 同文案）：`[DRIFT-CRIT] PHASE-SKIP: 发现 phase 越级：在 pending phase 之后直接完成 phase`，末行 `检测到漂移，drift_score=3` rc=1。

**3a 根因结论**：prev_status 初值应为中性（空/"none"），现值 "pending" 使缺陷面比登记更宽——不止「全 Phase complete 恒误报」，任何**首状态行=complete** 的计划（含「P1 完成、P2 进行中」的日常合法推进形态 fixture-c）恒误报 CRITICAL。正常报警路径存在（fixture-b）；首状态行为 pending 时无误报（fixture-d）。修复最小面=:122 一行初值（或首状态行特判），Check 1/3/4/5 不受影响。

#### 3b check_scope_breach 尾列提取失效 —— 根因已锁定（HIGH，双层叠加）
管道五段逐段实跑（:205-211 原样管道；夹具A 三列表 / 夹具E 两列表 / 真实 v092 计划三套结果**完全一致**；/tmp/s2-evidence/3b-stages.txt）：

```
S1  awk '/^## ⚠️ 执行范围限制/,/^## /'   → 恒 1 行：仅标题行「## ⚠️ 执行范围限制」自身（表体 0 行）
S2  … | grep '|'                         → 0 行（标题行无竖线）
S3  … | grep -vE '(类别|允许|禁止|---)'  → 0 行
S4  … | sed 's/.*|//;s/|.*//'            → 0 行
S5  … | tr ',' '\n' | trim | grep -v '^$' → 空 → allowed_files=""
```

端到端：fixture-a 全脚本实跑输出 `[DRIFT-INFO] SCOPE-NONE: task_plan.md 无范围限制表，跳过 scope 检查`——夹具明明有完整三列范围表。

**第一性根因裁决：双层叠加。当前生效的第一因=3c 区间 awk（表体根本进不了管道）；sed 取列是独立成立的第二因，区间修复后立即显形**。P8 行形探针（/tmp/s2-evidence/3c-probes.txt）隔离证明 sed 层：

| 输入行形 | sed 输出 | 判定 |
|---------|---------|------|
| `\| 源码 \| src/main.py, src/util.py \|`（竖线收尾，两列）| **空** | `s/.*\|//` 贪婪吞至行尾竖线 → 恒空；S32 登记「两列取不到允许列」真实机理=取空，非取错列 |
| `\| 源码 \| src/main.py, src/util.py`（无尾竖线，两列）| ` src/main.py, src/util.py` | 正确取「允许的文件」列（唯一可工作形态，证明该 sed 按无尾竖线表形设计）|
| `\| 源码 \| a.py \| 其他 \|`（竖线收尾，三列）| 空 | 同恒空 |
| `\| 源码 \| a.py \| 其他`（无尾竖线，三列）| ` 其他` | **错列**：取到「禁止」列（仅修区间不修 sed 且表无尾竖线 → 禁止项被当允许项，反向风险）|

真实计划表形（类别\|允许的文件\|禁止，竖线收尾）两层全中：区间恒剩标题行 + sed 恒空 → SCOPE-NONE 恒跳过实锤。

#### 3c :205 区间式 awk 同型 bug —— 根因已锁定（HIGH，实测精确化登记）
边界探针组（/tmp/s2-evidence/3c-probes.txt）：

| 探针 | 形态 | 输出 | 结论 |
|------|------|------|------|
| P1 | `/^## ⚠️ 执行范围限制/,/^## /`，标题+表体+下节 | **仅标题 1 行** | 起始行同配终止模式 → gawk 在起始行上即测 end 并闭合区间 |
| P2 | 同型 `/^## /,/^## /` | `## A`/`## B` 各自成单行区间 | 同型模式=每命中行自成单行区间 |
| P3 | `/## A/,/^## /` 同线双配 | 仅 `## A` 1 行 | 同线双配即闭 |
| P6 | scope 区置于文件末尾 | 仍仅标题 1 行 | **无任何文件形态可取到表体，恒坏** |
| P7 | mawk 同输入 | 同 P1 | 非 gawk 特有，跨实现一致（修复勿赌实现差异）|
| P4 对照 | 终止改非重叠 `/^## Next/` | 标题+表体+终止行全出 | 区间机制正常，纯因模式重叠 |
| P5 对照 | 状态机 `{f=1;next} /^## /{f=0} f` | 仅表体行 | 仓内规范修形 |

**3c 结论**：登记「起始行同配终止恒空」实证成立并精确化——输出非字面空，恒为**起始行标题 1 行**（经 `grep '\|'` 后恒 0 行，管道效果等同恒空）。仓内先例对照：该提取已多处状态机化且陷阱有文字登记——状态机形 `awk '/^## .*执行范围限制/{f=1;next} /^## /{f=0} f'` 见 check-skill-modify.sh:69、check-plan-dispatch.sh:94、check-complete.sh:31/:954、selftest-plan-tier.sh:162；文字登记见 check-rescue-chain.sh:33（纯 bash while-read 状态机规避 gawk 区间 bug）、check-plan-dispatch.sh:21（「禁用 awk 区间模式——gawk 区间 bug 已知」）、check-complete.sh:755（「gawk 5.2 下起始行同配终止模式恒为空的已知陷阱」）。check-drift.sh:205 确为登记在案的第 5 处漏网，实锤。

#### plan_parse_scope 语义摘录（S3 备料；lib/plan-parse.sh:18-46）
- 区间：状态机 `/^## .*执行范围限制/{inscope=1;next}` + `/^## /{inscope=0}`——宽松表头匹配（含/不含 ⚠️ 均命中，修复过 v090 无 emoji 表头恒空盲区）
- 行：仅 `/^\|/` 表格行，排除 `|---` 分隔行
- 条目：`-F'|'` 第 3+ 字段中含点分路径 `/\.[a-zA-Z]/` 的单元格，trim 后**整格**输出、**不拆逗号**（{a.sh,b.sh} 括号清单与带注 prose 均为一条，对齐 pretooluse 子串匹配语义）；无点分内容自然滤除
- fail-open：文件缺失/无区块 → 空输出 rc=0；单 awk 实现，37 计划 byte-identical 对拍（lib 头注 :27-29）
- S3 对拍种子（本 S2 顺带观察，未展开）：① lib 整格不拆逗号 vs check-drift :209 `tr ',' '\n'` 拆逗号（后者按单文件 grep -qF 比较）——接库需裁决拆分归属；② 三列形态（类别\|允许\|禁止）下 awk 字段 4=「禁止」列，lib「第 3+ 字段全扫」会把禁止列含点分单元格也取为允许项（潜在反向风险），check-drift 语义只取允许列；③ 两列/三列形态下视觉列 2（允许的文件）=awk 字段 3（前导竖线偏移），lib 的 i=3 起始可覆盖该列——取列语义存在接轨基础；④ lib 宽松表头（无 ⚠️ 也命中）vs check-drift :205 严格含 emoji 匹配，接库顺带消除该脆弱性

### S3 接库裁决（2026-09-27，executor）
环境：GNU Awk 5.2.1 + mawk 1.3.4 交叉验证；bash 5.2.21；对象 lib/plan-parse.sh（46 行，master 0b2208b）+ check-drift.sh:196-253。夹具 /tmp/s3-fixtures/t{1..5}-*/plans/task-x/；证据 /tmp/s3-evidence/matrix.txt（25 格判定矩阵）；harness /tmp/s3-harness.sh（消费侧**逐字复刻** check-drift.sh:213-245，仅提取侧参数化）。

#### 消费语义取证（check_scope_breach 拿 allowed_files 做什么）
- :205-211 提取管道产出**换行分隔逐条清单**（:209 `tr ',' '\n'` 在提取侧拆逗号）；空则 :213-216 SCOPE-NONE fail-open
- :234-240 消费 = **逐条** while read + **双向 grep -qF 子串**比对：`file 含 allowed`（方向1，全路径包含）**或** `allowed 含 basename(file)`（方向2，basename 子串）。非全等、非单方向
- 3 调用方消费形态：check-conflicts.sh:139/:166 整格 comm -12 交集；sync-todos.sh:244 内联副本+头10条逗号 join（INDEX 待办列）；zcode-pretooluse.sh:115 内联 awk 不 source 库（basename 子串匹配，与库互为语义锚）

#### 对拍矩阵（5 夹具 × 5 提取变体；判定=复刻消费侧 end-to-end）
变体：V0=原管道逐字；V1=lib plan_parse_scope 原样（整格）；V1tr=lib+消费侧拆逗号；V2=lib 列限变体（仅字段3，模拟"接库+参数扩展"）；V2tr=V2+拆逗号。

| 夹具（范围表形态） | V0 原管道 | V1 lib整格 | V1tr lib+拆 | V2 列限i3 | V2tr 列限+拆 | 期望判定 |
|---|---|---|---|---|---|---|
| t1 两列·竖线收尾（`src/main.py, src/util.py` + `docs/guide.md`；progress 含越权 `hack/evil.py`） | **SCOPE-NONE 恒跳过**（复证 3c 第一因端到端生效） | BREACH=evil.py ✅ | BREACH=evil.py ✅ | BREACH=evil.py ✅ | BREACH=evil.py ✅ | 报 evil.py |
| t2 三列·竖线收尾·禁止列含点分（`forbidden/secret.py, hack/*.py`；progress 越权写 forbidden/secret.py + hack/extra.py） | SCOPE-NONE | **BREACH=仅 hack/extra.py**（forbidden/secret.py 被禁止列整格误收为允许→**漏报**） | **BREACH=仅 hack/extra.py**（同漏报） | BREACH=forbidden/secret.py, hack/extra.py ✅ | 同左 ✅ | 双报 |
| t3 逗号清单+方向1边界（`src/a.py, src/b.py`+`{c.sh,d.sh}`；progress 含 `x/src/a.py/extra/readme.md`） | SCOPE-NONE | BREACH=evil.py **+ readme.md**（整格丢方向1） | BREACH=仅 evil.py（拆分后方向1 `src/a.py`⊂readme 路径命中→in-scope） | 同 V1 | 同 V1tr | 两可（见下） |
| t4 无范围表 | SCOPE-NONE | SCOPE-NONE | SCOPE-NONE | SCOPE-NONE | SCOPE-NONE | fail-open 一致 ✅ |
| t5 三列·无尾竖线·禁止列（S2 P8 唯一 sed 可工作形态） | **SCOPE-NONE**（区间 bug 在 sed 之前恒死，**端到端证明第二因被第一因完全掩盖**，P8 系隔离探针结论） | **SCOPE-OK 零检出**（progress 明写越权 forbidden/secret.py 仍判全绿=反向风险最重实证） | 同左零检出 | BREACH=forbidden/secret.py ✅ | 同左 ✅ | 报 forbidden |

- **禁止列反向风险实证结论（种子②，有实证）**：lib「字段3+全扫」确会把禁止列点分单元格收为允许项——夹具层 T2 漏报 1/2 越权文件、T5 整案零检出；**仓内量化：38 计划中 17 个字段4+ 含点分内容**（多为真实禁止 prose：`config.json`、`SKILL.md`、`其他 scripts/*.sh`、v092 自身禁止列 3 格全中），经消费方向2 basename 子串会直接豁免对应越权写入。非理论风险。
- **拆逗号归属实证（种子①，open_questions ① 裁决）**：整格 vs 拆逗号在 t1/t2/t4/t5 判定完全一致（方向2 basename 兜底吸收差异），**唯 t3 方向1包含场景分歧**（`x/src/a.py/extra/readme.md`：整格=BREACH 更严，拆分=in-scope 更宽）。原管道意图=拆分（:209 tr 本就存在）→ **拆分留在消费侧**，lib 保持整格权威语义不变。
- mawk 交叉验证 t2：V1/V2 输出与 gawk 逐字节一致（跨实现稳，延续 S2 P7 教训）。
- 真实数据 v092 本计划：V0 空（恒 SCOPE-NONE）；V1 7 格（混入 3 格禁止列 prose）；V2 恰 4 格=计划允许列本意。

#### 裁决：接库 + 参数扩展（可选列限参数，默认=现行为）+ 消费侧保留 tr 拆逗号
1. **消费侧需要「逐条清单」**（:234-240 逐行迭代），但条目粒度（整格/拆逗号）对判定不敏感（t1/t2/t4/t5 全一致）→ lib 整格输出**可直接满足**，拆逗号由 check-drift 消费侧保留 `tr ',' '\n'|sed trim|grep -v '^$'` 完成，不进 lib。
2. **lib 唯一必须补的语义=列限**：需「仅允许列」（=awk 字段3，种子③ 视觉列2=字段3 偏移成立）。实现为**可选第 2 参数**（如 `plan_parse_scope <file> [maxcol]`，`${2:-}` 默认空=现行为 `i=3..n`），lib 改动面 ~4 行（签名+默认值+循环上界+头注注记）。
3. **3 调用方零波及论证**：① check-conflicts.sh:139/:166 单参调用→默认行为 byte-identical（comm 交集语义不变）；② sync-todos.sh source 库但 scope 走 :244 内联语义副本（head -10/逗号 join 在调用侧），库加默认无害参数不触及其副本；③ zcode-pretooluse.sh:115 不 source 库（热路径内联 awk），仅「语义变更须同步」耦合——默认行为未变=无语义变更=无需改其代码，仅 lib 头注注记补一句。三处均无 `plan_parse_scope file N` 形态调用，签名向后兼容。
4. **替代案（状态机化+取对列，check-skill-modify.sh:69 先例形）可行但不采**：改动面与接库案相当（状态机 awk ~8 行 vs 接库 ~7 行），却保留第 5 处复制、违背 v091 建库既定方向（lib 头注 :5-6「后续调用方一律接入而非再复制」；lib:14 已预留「check-drift.sh:205 待后续组统一」）。两案不并列：接库案在波及面（零）与消复制收益上严格占优。接库顺带收益：宽松表头消除 :205 严格 emoji 匹配脆弱性（种子④）；fail-open 语义与 :213-216 现状一致（t4 五变体全一致，无回归）。
5. **check-drift 侧改动面（供 S9 估参考）**：补 SCRIPT_DIR 2 行（现无，参照 check-conflicts.sh:19 形）+ source 1 行 + :205-211 替换为 `plan_parse_scope "$PLAN_FILE" 3 | tr ',' '\n' | sed 's/…//;s/…//' | grep -v '^$' || true`（tr/trim/grep -v '^$' 留消费侧），净 ~7-9 行。

#### 供 Phase 3 S9 注意
1. 列限语义定「仅字段3」，勿做「3..N-1」（禁止列可在任意后位字段）；两列表无禁止列时字段3天然=允许列
2. 禁止顺手删 :209-211 的 tr/trim/`grep -v '^$'`（`|| true` 兜底是 :213 fail-open 路径依赖）
3. selftest 行为级用例必须含：三列竖线收尾禁止列反向样本（断言 forbidden 项被报 BREACH，t2/t5 夹具可直接搬）+ 无表计划 SCOPE-NONE（防 fail-open 回归）
4. v092 自身允许列整格含 prose 注记（"；…（仅当…）"），V2 输出 4 条长格属既有整格语义（S1 已裁决非缺陷），勿顺手修
5. lib 头注「调用方清单」须同步补 check-drift 接入记录并移除 :14「未纳入」标注

### S4 template-guide 计数与锚归因（2026-09-27，executor）
环境：master 工作区只读实测（零仓内修改，本 findings/progress/checkpoint 为唯一写入）；对象 skills/task-planner/references/template-guide.md + templates/；历史核对 `git show b21eaff / 10ba3d1 / db7e724` + `git log -S` pickaxe。

#### 1. 实测三数（2026-09-27）
| 项 | 实测 | 清单要点 |
|---|---|---|
| `ls templates/*.md \| wc -l`（根目录） | **10** | 5 核心（task_plan/findings/progress/verification/notepad-learnings）+ 3 辅助（cost_log/batch_report/subagent_dispatch）+ knowledge-brief.md（b21eaff v067 第 6 计划文件）+ shared-tracker.md（760c2a3 v071 Rule 30 区块模板，**guide/mapping 全表未登记**） |
| `ls templates/variant/*.md \| wc -l` | **15** | 文档登记 13 + mini-lite-type（d6a0f76 v086，49 行 mini 档）+ video-type（51ca883 重建；首建于 v085 期曾丢失，提交信息自证「v085 对齐声称 15 但磁盘 14」） |
| `grep -rl "## 📚 必要知识储备" templates/ \| wc -l` | **22** | = 5 核心 + 3 辅助 + 14 variant（15−mini-lite）；**无锚 3 文件** = knowledge-brief（设计使然，§2.5 此点声明正确）/ shared-tracker（v071 起从未含锚）/ variant/mini-lite-type（Rule 38.3 仪式区块白名单豁免） |

templates/ 下 .md 总数 = **25**。

#### 2. 声明清单表（行号/原文/实测/差值/归因）
| 行号 | 原文（关键） | 实测 | 差值 | 归因 |
|---|---|---|---|---|
| :32（§2.2 标题） | 「Variant 模板（13 个…）」，表列 13 行 | 15 | −2 行 | video 首建（约 2026-09-20 v085 期，丢失无独立提交，51ca883 提交信息可证）；可归因提交 d6a0f76（09-21 mini-lite）+51ca883（09-22 video 重建）；guide 最后一次被改 = db7e724（09-20 v085/P2），此后两批新增均未回写 |
| :60（§2.3） | 「5 核心 + 3 辅助 + 13 variant = **21 个模板**（2026-09-16 task-v074 P8 核对 ls 实测）」 | 同口径 5+3+15=**23**；目录实数 25 | 21→23（口径内）/25（目录） | 同上（d6a0f76+51ca883 后未回写）；另该口径从未计入 shared-tracker（760c2a3，09-14 早于 P8 核对日已存在）与 knowledge-brief |
| :62（§2.4 标题） | 「全部 21 个模板统一含」 | grep=22/25 文件 | 21→22 | **51ca883**（video 带锚重建 +1）；mini-lite/shared-tracker 无锚未增数 |
| :66（§2.4） | 「验收（应为 21）」 | 22 | +1 | 同 :62，首次过时 = 51ca883 |
| :67（§2.4） | 「task_plan 系（主模板 + 13 variant）」 | 15（含锚 14） | 13→15 | d6a0f76+51ca883 |
| :74（§2.5） | 「故 ：65 的 grep 锚计数 … **维持 20 不变**」 | grep=**22**；:65 现为空行 | 20→22；":65" 锚漂移 | **双重过时**：① 计数自 92f933c（v074/P6 rule-enhancement 带锚，09-15）即应 21；同日 **10ba3d1（P8）把 :66 改成「应为 21」却漏改本行「维持 20」**（同提交内自相矛盾，pickaxe -S 实证「维持 20 不变」仅 b21eaff 一次引入、从未再改）；② 51ca883 后应 22；③ 「:65」行号锚因 10ba3d1 在 §2.2 加 rule-enhancement 表行整体 +1 漂移——b21eaff 写入时 :65 恰为「统一标题…应为 20」验收行（引用当时正确），现验收行在 :66 |

#### 3. :69 文档锚归因（v091 progress.md:85 deferred 项定案）
- :69 = §2.4「契约安全」行，原文引用「该区块被 check-conflicts.sh / check-drift.sh 以状态机方式提取（`/^## ⚠️ 执行范围限制/{f=1;next} /^## /{f=0}`）」。
- 实测失配：check-conflicts.sh 已**无** f=1/f=0——73730f7（v091/S16，2026-09-27）scope 提取接 lib/plan-parse.sh `plan_parse_scope`（lib:34 用 inscope 变量 + 宽松表头 `/^## .*执行范围限制/`，check-conflicts:134 仅存注释）；check-drift.sh:205 现为**区间式** `/^## ⚠️ 执行范围限制/,/^## /`（非状态机，S2 已实证第 5 处漏网，待 S9 接库）。→ :69 引用的正则与两脚本现状**均不符**，「文档锚过时」成立；使 check-conflicts 侧失配的提交 = **73730f7**。
- 附注：materials/defect-evidence.md 缺陷 4 自身锚「:69（§2.5 knowledge-brief 段）」亦不精确——:69 属 §2.4，被引文本「故 :65 的 grep 锚计数…维持 20 不变」实际在 **:74**（§2.5 差异行）。Phase 4 修正面应覆盖 :69 与 :74 两行。
- 修正措辞：「:65 的 grep 锚计数」→「**§2.4「统一标题」条的 grep 锚计数**」（章节锚形态，抗插行漂移）。

#### 4. template-mapping.md 同型漂移（只登记——scope 禁改该文件）
| 行号 | 原文 | 实测 | 判定 |
|---|---|---|---|
| :26 | 「类型不在既有 13 类」 | variant 实为 15 | **同型漂移**：少记 mini-lite/video；check-template-type.sh 白名单动态派生不受影响，纯文档漂移 |
| :132-144（§六 速查表） | 表列 13 个 variant 路径 | 磁盘 15 | **同型漂移**：缺 mini-lite-type/video-type 两行，与 guide :32 同源（v086/v085 两批未回写） |
| :168（§七） | 「6 个文件名白名单（…knowledge-brief）」 | 与 init 白名单一致 | 无漂移 |
| :191（§八注释） | 「应包含: findings.md…verification.md」5 文件 | 白名单实为 6（+knowledge-brief） | 轻微：措辞为「应包含」非穷举，可顺手补（可选） |

无「21/20 个模板」总数声明，总数漂移仅存于 template-guide.md。

#### 5. Phase 4 修正指令（建议字面值，Phase 4 裁量为准）
1. **:32** →「Variant 模板（15 个…）」；§2.2 表补两行：`variant/mini-lite-type.md` (v2,mini 档)｜轻量任务 ≤2 文件 ∧ ≤15min ∧ 单模块（Rule 38，38.3 白名单豁免无 📚 章节）｜Goal/VC/范围表/2 Phase/Handoff；`variant/video-type.md` (v2)｜视频内容生产｜G1 人工草稿审查门（STOP 等用户）/VC-7 草稿门
2. **:60** → 「**总文件数**:5 核心 + 3 辅助 + 15 variant = 23 个模板；另有 knowledge-brief.md（第 6 计划文件）/shared-tracker.md（Rule 30 区块模板）不入此口径，templates/ 实际 25 个 .md（2026-09-27 task-v092 S4 `ls` 实测;旧文 13 variant/21 总数漂移自 v086/v085 两批新增未回写）」
3. **:62** → 「（22/25 个模板文件统一含 — mini-lite/knowledge-brief/shared-tracker 三者例外）」；**:66** → 「验收（应为 22；例外：knowledge-brief、shared-tracker、variant/mini-lite-type）」；**:67** → 「主模板 + 15 variant（含锚 14，mini-lite 除外）」
4. **:74** → 「故 §2.4「统一标题」条的 grep 锚计数 `grep -rl "## 📚 必要知识储备" templates/ | wc -l` 现为 22（=25 − 3 无锚例外）；由 init-session.sh 建档并计入白名单（模板白名单 5→6，见 template-mapping.md §七）」
5. **:69** → 脚本引用改如实描述：「该区块被 check-conflicts.sh 经 lib/plan-parse.sh plan_parse_scope（宽松表头状态机）与 check-drift.sh:205（区间式，已知 gawk 区间陷阱，接库后按 lib 形态）提取」——若 S9 已接库则以接库后形态为准
6. **template-mapping.md** :26 与 §六 表两处同型漂移登记留后续任务（本 scope 禁改）；修正完成后复跑三件套 `ls *.md|wc -l` ×2 + grep 锚对账（若 Phase 2/3 不新增模板，22/23/25 即终值）

### S5 修复记录（2026-09-27，executor）
对象：worktree 内 `skills/task-planner/scripts/check-conflicts.sh`（分支 wt/task-v092-guard-quirk-fixes，commit **59b1471**，+5/-1 单文件，worktree 提交后干净）。修法一句话：sed 区间 end 模式 `^|-------` 改 `^[^|]`（首个非表行止，表头→分隔行→数据行整表入管道），管道中段新增 `grep -vE '^[[:space:]:|-]+$'` 滤分隔行（纯 |/-/:/空格 构成行），表头由既有 `tail -n +2` 滤除。改动面=原 :144 管道行（修后 :148）+:123 前 4 行注记；plan_parse_scope 接入（:134-139）与 :166 调用、:147-157 current_plan_dir、:170 自计划跳过零触碰。

#### 验证证据（全实跑，夹具 /tmp/s5-fixtures/repo-s5=真实形态 INDEX：9 字段表头+紧邻 6 字段分隔行首列 9 连字符+数据行）
- 管道首段：pre-fix 旧模式 2 行（表头+分隔行，4 数据行全丢）；post-fix 新模式 6 行（整表）；全管道 post-fix 输出 4 数据行（task-alpha/task-beta=in_progress、task-gamma=pending、task-delta=complete）
- 端到端 runtime：pre-fix `✓ 运行时并发冲突检测通过` rc=0（2 条 in_progress 零检测=1a 复现）；post-fix `🔴 冲突 A(同文件): plan task-beta session=sess-beta 覆盖文件: src/shared.py`（跨计划真冲突）+ 1b 自报 task-alpha 冲突 A/B（S6 已知）rc=1；task-beta 改 pending 后 beta 冲突行消失（:126 pending 门控正常，pending 不进 active_plans）
- 主仓真实 INDEX.md（21:42 刷新版）post-fix 全管道：38 数据行 = `grep -c '^| task-'` 直数 38，`grep -vE` 仅滤真分隔行 1 条（cat -A 证实）；区间捕获 42 = 表头1+分隔行1+数据38+空行1+终止行 `## 完成计划（归档）`1，空行/终止行由既有 `grep '^|'` 滤除——零数据行误滤
- selftest 双基线：pre-fix（/tmp/cc-baseline 副本 + HEAD 版脚本）**6/6 PASS**；post-fix worktree 实跑 **6/6 PASS**，零回归无红项（任务预警的 CC-06 红未发生：分隔行置尾夹具在新管道下仍解析）

#### 供 S6/S7 注意
1. 1b 已如 S1 预判显形：夹具端到端出现 task-alpha 自报冲突 A（scope 全量自交 `lib/util.ts`/`src/alpha.py`/`src/shared.py`）+ 冲突 B 自报（worktree_path 与自身相等）——S6 修 :170 路径归一后两行应消失，仅剩 task-beta 真冲突行
2. scope 交集为整格精确匹配：两计划共享文件但整格写法不同（`src/shared.py, src/alpha.py` vs `src/shared.py`）时交集为空（S1 注记③ 既有语义非缺陷）——S6/S7 验证夹具须用相同整格才能演示真冲突 A（本 S5 夹具首版即踩此坑后修正）
3. CC-06 语义已过时（改造仍属 S7）：CC-06 夹具「分隔行置尾」锁定的是旧行为路径，selftest 头注 :14-18「已知既有限制」描述的 sed 区间缺陷已被本 S5 修复——S7 应按真实形态（9 字段表头+紧邻 6 字段分隔行）改造 CC-06 夹具并刷新头注，锁定新行为

### S6 修复记录（2026-09-27，executor）
对象：worktree 内 `skills/task-planner/scripts/check-conflicts.sh`（分支 wt/task-v092-guard-quirk-fixes，commit **cba40ec**，+5/-1 单文件，提交后 worktree 干净）。修法一句话：:131 `plan_dir="plans/$task_id"`（相对）改 `plan_dir="$repo/plans/$task_id"`（与 :153 current_plan_dir 的 glob `"$repo/plans"/*` **同源构造**）+4 行注记；S5 管道行/plan_parse_scope 接入/:147-157 mtime 判定/空值分支零触碰。

#### 选型：候选 a（构造点归一），候选 b（basename 双侧）不采的理由
1. 同源构造后两侧共享**逐字** `$repo/plans/` 前缀——repo 传参任意形态（绝对/`.`/尾斜杠/含 `..`）字符串恒等，比较语义保持「同一目录」精确判定，不引入 basename 派生
2. 单点单行改动；assoc 数组键（plan_sessions/plan_worktrees/plan_scopes）与 active_plans 同步归一，下游零波及（冲突输出本就走 `basename $other_plan`，输出不变）
3. 候选 b 覆盖面与 a **完全相同**：深相对 repo（如 `s5-fixtures/repo-s5`）下 glob 侧 cd 后匹配不到 → current_plan_dir 空 → :162 提前 exit，:174 比较根本不执行——basename 归一无处生效，故无额外收益
4. 深相对 repo 提前退出为**既有行为**（修前 HEAD 版本对拍逐字节一致，V3c），属 v091 progress 登记的 deferred 项，不在本 S6 范围

#### 验证证据（全实跑，S5 夹具 /tmp/s5-fixtures/repo-s5；证据 /tmp/s6-evidence/）
夹具复用前 drift 修正：task-beta 被 S5 验证改为 pending + 2 个未提交修改 → 恢复 beta=in_progress 并提交夹具树（信号基线归零），scope 整格共享 `src/shared.py` 确认在。

| repo 形态 | pre-fix（HEAD 59b1471 对拍） | post-fix（cba40ec） | 判定 |
|---|---|---|---|
| 绝对 `/tmp/s5-fixtures/repo-s5` | 自报 A(task-alpha, 3 文件全量自交)+自报 B(/tmp/s5-wt-alpha)+真冲突 A(task-beta, src/shared.py) rc=1 | **仅真冲突 A(task-beta)** rc=1 | 1b 消除 ✅ |
| `.`（repo 内相对） | 同上三段 rc=1 | **仅真冲突 A(task-beta)** rc=1 | 相对形态自跳过成立 ✅ |
| 深相对 `s5-fixtures/repo-s5`（/tmp 下） | `无活跃 plan,跳过运行时检测` rc=0 | 同左（逐字节一致） | 非回归 ✅ |
| 自计划唯一（/tmp/s6-fixtures/repo-s6-selfonly，仅 task-alpha 行+目录） | —（未测，无对照意义） | `✓ 运行时并发冲突检测通过` **rc=0** | 零冲突 ✅ |
| selftest（worktree 实跑） | — | **6/6 PASS** rc=0 | 零回归 ✅ |

#### 消费点核对结论（硬约束④）
`current_plan_dir` 全部消费点：:162 空值分支、:167/:168/:170 属性读取（非比较）、**:174 唯一字符串比较点**（已由构造点归一覆盖）；冲突 B 比较的是 worktree_path **值**（同计划自等是 1b 跳过失效的下游症状，非独立路径缺陷）；冲突 C 的自报被 :198 `current_session != other_session` 天然抑制（同一 plan session 必等）——均无需额外归一，diff 保持最小。

#### 供 S7 注意
1. CC-06 改造（真实形态 9 字段表头+紧邻 6 字段分隔行）可增加「自计划跳过」断言：S6 夹具 /tmp/s5-fixtures/repo-s5（alpha 自+beta 他共享整格 `src/shared.py`）期望输出恰 1 条冲突 A 且 plan=非当前 plan；/tmp/s6-fixtures/repo-s6-selfonly 期望 rc=0
2. 深相对 repo 提前退出是既有 deferred 行为（v091 progress:79），CC-06 若要覆盖「repo 传参形态」维度需另行立项，勿顺手扩
3. 本 S6 夹具 INDEX/session/worktree 字段构造可直接复用；注意夹具是 git 仓，改完须 commit 保持信号①不干扰断言

### S7 修复记录（2026-09-27，executor）
对象：worktree 内 `skills/task-planner/scripts/selftest-check-conflicts.sh`（分支 wt/task-v092-guard-quirk-fixes，commit **7bdd6ff**，+50/-14 单文件，提交后 worktree 干净；被测 check-conflicts.sh 本体零触碰——sha256 对 HEAD 逐位一致 f015837e…）。改造一句话：CC-06 夹具 INDEX 由「分隔行置尾」畸形（6 字段表头+数据行+尾置分隔行）改真实形态（9 字段表头+紧邻 6 字段分隔行+9 列数据行，表头/分隔行两行与主仓 plans/INDEX.md:8-9 **逐字节一致**），头注「已知既有限制」块改「历史限制注记」（声明 S5 已修失效+保留变更脉络），新增 CC-07 自计划跳过用例；CC-01..05 五夹具零改动（diff 区块逐一核验）。

#### 断言清单（改造后 7 用例，7/7 PASS）
| 用例 | 断言 | 语义 |
|---|---|---|
| CC-06（改造） | rc=1 + `mode=runtime` + **冲突 A 行数==1**（grep -c 计数断言）+ 行内容逐字锁 `🔴 冲突 A(同文件): plan t-other session=sess-other` + 交集文件 `src/shared.py` | 原底线（冲突 A 报警+交集文件+rc=1）全保留；「恰 1 条且报他计划」即增补项 3a（自计划 task-cur 被正确跳过，S6 修复后语义） |
| CC-07（新增） | rc=0 + `✓ 运行时并发冲突检测通过` + **冲突 A 行数==0** | 增补项 3b：仅自计划（INDEX 在册唯一 in_progress=当前计划自身）零冲突；跳过失效时将自报 `plan self-plan … src/solo.py` 且 rc=1 即红，非恒真 |

#### 夹具 INDEX 与真实 INDEX.md 形态一致性对照（VC-3）
- 表头：`| Task ID | Status | Phase 进度 | Goal | session_id | worktree | scope_files | 最后更新 | 待办 |` = **9 字段**，与主仓 plans/INDEX.md:8 逐字节一致（sed 剥壳 diff 实证「逐字节一致」）
- 分隔行：`|---------|--------|-----------|------|---------|------|` = **6 字段、首列 9 连字符（≥7）**，紧邻表头，与主仓 :9 逐字节一致；S5 新管道 `grep -vE '^[[:space:]:|-]+$'` 正确滤除
- 数据行：9 列同构（task_id|status|phase|goal|session_id|worktree 空|反引号 scope_files|日期|待办）；解析管道仅取前 6 列，session_id/worktree 仍从 task_plan.md awk 读取——与真实形态解析路径完全一致
- 陷阱遵守（S6 checkpoint 移交）：夹具 git 仓构造后 commit（信号①归零，rc 断言不被污染）；本脚本无 sid 依赖（mktemp 目录天然唯一，v078 教训不适用）

#### 负向验证（防恒真；/tmp/s7-neg 副本实施，本体零触碰，验证后副本已弃）
| 破坏点 | 手法 | selftest 结果（/tmp 副本实跑） |
|---|---|---|
| check-conflicts.sh:130 pending 门控 | `!=` 反转 `==` | **CC-06 FAIL**（零冲突 A、`✓ 运行时并发冲突检测通过`、rc=0）、其余 6 例 PASS，Total 6 PASS=1 FAIL rc=1 |
| check-conflicts.sh:178 自计划跳过 | `==` 反转 `!=` | **CC-06 FAIL**（t-other 被误跳过、rc=0）+ **CC-07 FAIL**（自报 `🔴 冲突 A(同文件): plan self-plan session=sess-self 覆盖文件: src/solo.py`、rc=1），Total 5 PASS=2 FAIL rc=1 |

#### 实跑结果
- 改造前基线 6/6 PASS rc=0 → 改造后 7/7 PASS rc=0（提交前 + 提交后 7bdd6ff 复跑各一次）
- `git diff HEAD~1 --stat` 仅 selftest-check-conflicts.sh（+50/-14）；worktree 提交后 `git status` 干净
- 深相对 repo 提前退出（v091 deferred）未顺手扩覆盖（S6 移交约束②遵守）；对账注记：selftest 总用例 6→7，VC-2 全量求和基线对账时 +1 PASS

### S8 修复记录（2026-09-27，executor）
对象：worktree 内 `skills/task-planner/scripts/check-drift.sh` check_phase_order 函数（分支 wt/task-v092-guard-quirk-fixes，commit **f3966eb**，+5/-1 单文件，提交后 worktree 干净）。修法一句话：:122 `local prev_status="pending"` → `"none"`（中性初值，+4 行修复注记注明原因/时间/原行为/出处 findings S2 3a），:138 越级判定 `status=="complete" && prev_status=="pending"` 对中性初值天然不命中 → 「虚拟 Phase 0=pending」前驱消失，首状态行=complete 不再违约；Check 1-3/5 与 check_scope_breach 零触碰（diff 审查确认仅该函数一处 hunk）。

#### 修复前/后四夹具对照（/tmp/s8-fixtures/fixture-{a,b,c,d}/plans/task-x/，复刻 S2 构造；全脚本实跑）
| 夹具 | Status 序列 | 修复前 | 修复后 | 验收 |
|------|------------|--------|--------|------|
| fixture-a | complete,complete,complete | **CRITICAL PHASE-SKIP 误报** rc=1 | INFO PHASE-ORDER「Phase 顺序正常」rc=0 | ✅ 不再误报 |
| fixture-b | pending,complete,pending（真越级）| CRITICAL PHASE-SKIP rc=1 | CRITICAL PHASE-SKIP rc=1（文案不变）| ✅ 报警能力保持 |
| fixture-c | complete,in_progress,pending | **CRITICAL PHASE-SKIP 误报** rc=1 | INFO PHASE-ORDER rc=0 | ✅ 不再误报 |
| fixture-d | pending,in_progress,complete | INFO PHASE-ORDER rc=0 | INFO PHASE-ORDER rc=0 | ✅ 既有行为不变 |

补充探针 probe-e（pending,pending,complete）：仍报 CRITICAL PHASE-SKIP rc=1——真实前驱 pending→complete 的越级判定在任意位置均保持。误报文案与真越级文案未区分（按 S8 约束不作要求：初值修复后误报场景本身已消失，仅真越级会进入该文案路径）。

#### 实跑结果
- `bash -n` 语法通过；`git diff HEAD~1 --stat` 仅 check-drift.sh（+5/-1）；证据 /tmp/s8-evidence/{baseline-runs,postfix-runs,probe-e}.txt
- 修复未削弱任何检测维度：四夹具+探针中 Check 1（VC）/Check 3（GOAL）/Check 5（SCOPE）/循环错误检测输出与修复前逐行一致


<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

### S9 修复记录（2026-09-27，executor）
对象：worktree 内 `skills/task-planner/scripts/lib/plan-parse.sh` + `check-drift.sh`（分支 wt/task-v092-guard-quirk-fixes，commit **11c294c**，+20/-8 两文件，提交后 worktree 干净）。修法一句话（按 S3 裁决落地）：① lib `plan_parse_scope` 增可选第 2 参 `[maxcol]`——`local maxcol="${2:-}"` + `awk -v maxcol=` + 循环上界 `hi = (maxcol == "" ? n : maxcol + 0)`（缺省空=现行为 3..n 整行不变；`+0` 强制数值比较防 strnum 歧义）+ 签名/语义注释与头注注记；② check-drift `check_scope_breach` 补 SCRIPT_DIR+source 设施（参照 check-conflicts.sh:19-21 形态，插在 :23 NOTE 块后）并将原 :209-215 区间式提取管道（`awk '/^## ⚠️ 执行范围限制/,/^## /'|grep|grep -vE|sed 取末列`）替换为 `plan_parse_scope "$PLAN_FILE" 3`——`tr ',' '\n'|sed trim|grep -v '^$'||true` 留消费侧（:213 fail-open 依赖，勿并入库）；③ lib 头注调用方清单 `未纳入: check-drift.sh:205` 标注改判为 `4. check-drift.sh check_scope_breach（列限调用形态，S9 接入）`。Check 1-3/5、check_phase_order（S8 已修）零触碰（diff 仅 2 hunks 实证）。

#### 验证证据（全实跑，夹具复用 /tmp/s3-fixtures/ 四形态；证据 /tmp/s9-evidence/）
| 夹具 | pre-fix（HEAD f3966eb 版） | post-fix（11c294c 实跑） | 判定 |
|---|---|---|---|
| t1 两列·竖线收尾（progress 越权 hack/evil.py） | SCOPE-NONE rc=0（3c 恒跳过复现） | **WARNING SCOPE-BREACH: hack/evil.py rc=1** | ✅ |
| t2 三列·竖线收尾·禁止列点分（越权 forbidden/secret.py + hack/extra.py） | SCOPE-NONE rc=0 | **BREACH: forbidden/secret.py, hack/extra.py rc=1**（禁止列文件被报，反向风险已修） | ✅ |
| t5 三列·无尾竖线·禁止列（progress 明写越权 forbidden/secret.py） | SCOPE-NONE rc=0（整案零检出复现） | **BREACH: forbidden/secret.py rc=1** | ✅ |
| t4 无范围表 | SCOPE-NONE rc=0 | SCOPE-NONE rc=0（fail-open 保持，rc 不因此变 1） | ✅ |

- 提取层实证：t2 列限（maxcol=3）输出恰 `src/main.py, src/util.py`+`docs/guide.md` 两格，禁止列 `forbidden/secret.py, hack/*.py` 不再混入——消费端双报即此因；t5 输出恰允许列两格；四夹具 POST 段全部 WARN/CRIT 仅 3 条预期 BREACH，零其他信号污染
- mawk 交叉验证（延续 S3 P7 教训）：列限 awk 程序 gawk 5.2.1 vs mawk 1.3.4 对 t1/t2/t5 输出逐字节一致（`maxcol+0` 数值化后无 strnum 歧义）
- **3 调用方零波及回归（S3 论证实证）**：① REG1 单参对拍——修改前后 lib 对主仓 `plans/*/task_plan.md` 全部 **38 计划**逐个 `plan_parse_scope <file>` 输出 **diff 为空 byte-identical**（check-conflicts.sh:139/:166 单参调用点语义不变）；② REG2 sync-todos 夹具实跑（/tmp/s9-sync-fixture，pre=HEAD 版脚本+HEAD lib vs post=worktree 版）默认报告与 `--index` 产物 INDEX.md 均 **byte-identical**，INDEX `scope_files` 列正常输出（内联副本 :241-253 未触及）；③ zcode-pretooluse.sh 不 source 库（:115 互指注释锚，默认行为未变=无语义变更，零改动，diff 不含该文件）
- check-conflicts selftest worktree 实跑 **7/7 PASS** rc=0（CC-01~CC-07，S5/S6/S7 修复无回归）
- 验收范围核验：`git diff HEAD~1 --stat` = lib/plan-parse.sh + check-drift.sh 恰两文件（+20/-8），worktree 提交后 `git status` 干净

#### 供 Phase 4 注意
1. t3（逗号清单+方向1包含边界）属两可判定案，S3 已裁决拆逗号留消费侧、lib 整格权威语义不变——本 S9 未改该行为，无需再裁
2. lib 头注调用方清单现 4 条，后续新增调用方若需列限形态一律走第 2 参，勿再复制 awk（v091 C-1c 既定方向）
3. template-guide.md:69 修正措辞中「check-drift.sh:205 区间式」的如实描述现应更新为接库后形态（S4 节修正指令 5 已预留此分支：「若 S9 已接库则以接库后形态为准」）

### S10 修复记录（2026-09-27，code-assistant）
对象：worktree 内 `skills/task-planner/references/template-guide.md`（分支 wt/task-v092-guard-quirk-fixes，commit **35cd075**，+2/-2 单文件，仅 :69/:74 两行）。改前/改后对照：① :74「故 **:65** 的 grep 锚计数」→「故 **§2.4「统一标题」条**的 grep 锚计数」（行号锚改章节锚，S4 归因的插行漂移失配消除）；② :69「以状态机方式提取（`/^## ⚠️ 执行范围限制/{f=1;next} /^## /{f=0}`）」→「经统一库 lib/plan-parse.sh 的 `plan_parse_scope` 提取（check-conflicts 默认形态、check-drift 列限形态，语义权威源见库头注）」（S9 接库后两脚本现状：check-conflicts.sh:147/:174 单参默认形态、check-drift.sh:219 列限 `plan_parse_scope "$PLAN_FILE" 3`，旧 awk 状态机正则已不存在）。验证：全文件 `grep -n ':65'` 零命中；`git diff HEAD~1 --stat` 仅 template-guide.md 一文件（+2/-2 ≤6 行硬约束内）；未做计数修正（留 S11）与无关润色。

### S11 修复记录（2026-09-27，code-assistant）
对象：worktree 内 `skills/task-planner/references/template-guide.md`（分支 wt/task-v092-guard-quirk-fixes，commit **e5a402d**，基线 35cd075，+5/-5 单文件）。按 S4「Phase 4 修正指令」执行计数三处声明修正（指令 2/3/4 合并 + 直接关联措辞）：

| 位置 | 改前 | 改后 |
|---|---|---|
| §2.3（:60） | 「5 核心 + 3 辅助 + 13 variant = **21 个模板**（2026-09-16 task-v074 P8 核对…）」 | 「5 核心 + 3 辅助 + 15 variant = **23 个模板**；另有 knowledge-brief.md（第 6 计划文件）/shared-tracker.md（Rule 30 区块模板）不入此口径，templates/ 实际 25 个 .md（…漂移自 v086/v085 两批新增未回写——mini-lite-type d6a0f76、video-type 51ca883 重建）」 |
| §2.4 标题（:62） | 「全部 21 个模板统一含」 | 「22/25 个模板文件统一含 — mini-lite/knowledge-brief/shared-tracker 三者例外」 |
| §2.4 验收（:66） | 「验收（应为 21）」 | 「验收（应为 22；例外：knowledge-brief、shared-tracker、variant/mini-lite-type）」 |
| §2.4 task_plan 系（:67） | 「主模板 + 13 variant」 | 「主模板 + 15 variant，含锚 14——mini-lite 除外」（防与 :62/:66 矛盾，直接关联措辞） |
| §2.5（:74） | 「…grep 锚计数 … 维持 20 不变」 | 「…grep 锚计数 … 现为 22（= 25 − 3 无锚例外：knowledge-brief/shared-tracker/variant/mini-lite-type）」（语义保持：knowledge-brief 不含该章节故不计入锚数，数值 20→22 与 S4 双重过时归因一致） |

三实测数（worktree 改后复跑，与文档声明一致）：`ls templates/*.md | wc -l`=**10**（5 核心+3 辅助+knowledge-brief+shared-tracker）；`ls templates/variant/*.md | wc -l`=**15**；`grep -rl "## 📚 必要知识储备" templates/ | wc -l`=**22**（=25 总 − 3 无锚）。零残留验证：`grep -n "21 个\|应为 21\|维持 20"` rc=1 零命中；`git diff HEAD~1 --stat` 仅 template-guide.md（+5/-5=10 行 diff，≤12 硬约束内）。

**template-mapping.md 同型漂移登记（只登记不修——scope 禁改，留后续任务）**：① :26「类型不在既有 13 类」→ variant 实为 15，少记 mini-lite/video；② §六 速查表（:132-144）列 13 个 variant 路径，磁盘 15，缺 `variant/mini-lite-type.md`/`variant/video-type.md` 两行（与 guide :32 §2.2 表同源，v086/v085 两批未回写）；③ :191 §八 白名单注释「应包含: findings.md…verification.md」列 5 文件 vs init 白名单实为 6（+knowledge-brief），措辞为「应包含」非穷举，可顺手补（可选）。check-template-type.sh 白名单动态派生，不受纯文档漂移影响。

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
