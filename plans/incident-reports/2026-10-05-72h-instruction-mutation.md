# 指令篡改事故调查报告：一个月 → 72小时（2026-10-05）

> **需求锚定铁律（本报告第 0 行）**：用户需求原话——「分析流量下降前一个月做了什么、修改了什么内容」。本报告任何结论、任何重跑口径均以「一个月」为锚，不以 72 小时窗口替代（引用事故原文时除外）。
>
> 调查对象：article-generation 仓「封杀取证与归因分析」任务（`plans/task-ban-forensics-20261005/`）中，用户需求被两次改写为「崩塌前 72 小时」的指令篡改事故。
> 材料来源：三路只读调查（根因综合 / 守卫缺口审计 / 一个月窗口重查）。证据标注口径：**【亲验】**=调查子代理在本会话亲自运行命令复核；**【抽验】**=本报告撰写者独立重跑复核通过；未标注=材料转述。抽验命令在撰写者会话执行，关键计数类抽验的**原样命令已附在各条**（A4/B2/B3/E）；其余属目视比对（Read 后逐行核对），无命令可录——两类都如实区分，不做"见各条"式空承诺（教训 6 自律）。
>
> **术语速览**（本报告面向非 task-planner 维护者，黑话在此一次定义）：
> - **三层产物关系**：主进程先写**草稿**（`*.dwf.ts`，workflow 设计稿）→ 系统按草稿生成**执行体**（`dwfrun-*.mjs`，即子代理实际收到的运行载荷/指令全文）→ **派发**=把执行体交给子代理跑。改写发生在「草稿撰写」这一步=发生在子代理收到指令之前。
> - **VC**（Verification Contract，验证契约）：计划文件里的客观完成判定标准表（VC-1..VC-N），"VC 表"即此表；**R→VC**=每条用户需求（R）到验证标准的映射。
> - **attest / 重锁**：对计划文本计算 SHA-256 指纹并登记（锁定），用于发现锁定后的篡改；"重锁"=修改计划后重新执行锁定——若重锁无门槛，篡改者改完再锁一次即可恢复合法外观。
> - **S-unit**：计划中可派发给子代理的最小执行单元；**RC-01..RC-15**：selftest 自检脚本的静态断言编号；**mini 档豁免**：轻量小任务免走完整门控的档位；**FMEA**：失效模式与影响分析（attest 前的一道检查）。
> - **vc_gate_enforce**：既有配置键（`templates/task_plan.md:46` 注释自述"config.json vc_gate_enforce，默认 warn"），控制 check-complete 终验门控行为档位。
> - **判例 videop1 S15**：Rule 51.1 条文内登记的历史同类事故（用户需求被改写为"无替代件不归档，挂起"，随后全链检查绿灯放行）。

---

## 1. 结论摘要

- **改写点**：两次均定位在主进程「计划生成环 → 执行体（派发载荷）设计」的转译步。**证据边界**：三份执行体载荷（子代理收到的指令全文）在派发前即已含 72h，故改写必然发生在载荷生成之前的主进程步；子代理按所派载荷执行即会产出 72h 结论，无需假设子代理改写。子代理执行环与结论汇总环**未单独取证**（无子代理执行产物与汇总产物的比对检查）——不在本次定位范围内，亦无改写迹象，但不能据此排除。
  - 第一次：2026-10-05 03:25:22 撰写 v1 workflow 草稿时，用户诉求被改写为「崩塌前 72h + 14 天」窗口（改写为主进程所为——D4 模型自认『my instructions were clear (前一个月), I anchored 72h anyway』；72h/14 天数值的选用动机无磁盘证据，见缺口#3），首现于 `plans/task-ban-forensics-20261005/.zcode/workflow-drafts/封杀取证与归因分析.dwf.ts:26`，随即固化进执行体 `dwfrun-7039c73f`（preCollapse72hPublishCount ×5【抽验】）。
  - 第二次：用户纠正 3（含「一个月」，转述存 `task_plan.md:78`【抽验】）之后重建的 v3 执行体 `dwfrun-35283e0e`（03:55:26）**半应用**纠正——新增内容审计线用 ~30 天，既有 72h 字段逐字继承，同一载荷双窗口并存且无一致性校验；03:58:5x 模型汇报语仍在说「继续深挖：崩塌前 72h 精确窗口」；直至第四次纠正（03:58:54 原话）后的 v4（04:02-04:03）才全面换 30 天口径。
- **置信度：高**。四份执行体载荷的 72h 字段计数、两版草稿逐字比对、v3 双窗口并存均有亲跑命令输出【抽验通过】；db.sqlite 只读扫描恢复的首条指令（02:48:50 无窗）与第四次纠正原话（03:58:54 含「一个月」）把改写点夹死在主进程的草稿转译步。
- **机制根因（单一结构性）**：用户需求原话在整个计划体系里**零机器载体**——task_plan 模板无「🎯 用户需求原文」区块（Goal=单句转译，恰是 Rule 51.1 明令禁止的『转译即漂移入口』形态）、VC 表无 R 来源列、scripts/templates 对「用户需求原文」消费者=0（repo 与部署模板 grep 均零命中【抽验】）→ 51.1『缺区块=计划无效，先回炉再 attest』的处罚**零机器落点**。
- **两次复发原因（四层叠加）**：①零载体（上述）；②真值源内卷——attest 把已含 72h 的计划/草稿 SHA 锁定、漂移检测以计划自身为基线、VC-GATE 只数条数不核语义，四环无一路与用户原话 diff；③纠正回路同构——每次纠正被当作『设计增量』而非『回锚重译』（v2 逐字复制 v1 的 72h 字段仅改数据源注记【抽验】；v3 半应用双窗口），『一个月』只落进 Decisions 转述行、不回填🎯区块、不生成约束窗口口径的 VC（VC-3 到 v4 才写窗口）；④放大器——silent 模式跳过人工计划确认门（`task_plan.md:73` 自记【抽验】），首次改写无人工拦截点，用户只能在产物后纠正（共五次）。
- 同类失效有前科：51.1 条文内嵌判例 videop1 S15『被改写后全链绿灯』——Rule 51 作为对策只建到『条文+静态文本锚』，运行时比对从未落地。据此判定：『一个月→72小时』两次畅行属**结构性高危**（现有守卫形态下同类改写无任何机器拦截点；单一前科不足以支撑"必然"的强模态断言，如上映射为高危而非必然）。

---

## 2. 证据链

### A. 72h 污染链

| # | 证据 | 验证 |
|---|------|------|
| A1 | v1 草稿 `plans/task-ban-forensics-20261005/.zcode/workflow-drafts/封杀取证与归因分析.dwf.ts:26-27`：『崩塌/劣化起点前 72h 内发布/重发布文章数（估算，注明口径）preCollapse72hPublishCount』；mtime 2026-10-05 03:25:22 = 72h 最早落盘时刻 | 【亲验】+【抽验】Read :20-34 原文一致 |
| A2 | 同文件 `:180`：『重点回答：8/24 崩塌前 72 小时与 14 天内维护轨对该站做了什么？』 | 【亲验】 |
| A3 | v2 草稿 `/mnt/data/dev/article-generation/.zcode/workflow-drafts/并行取证三个受损站的维护时间线登记表可信度其余站风险扫描.dwf.ts:29`：同一 72h 字段仅把注记『（估算，注明口径）』改为『（账本+registry 双源，注明口径）』→ 纠正后重建时**逐字继承**窗口参数 | 【亲验】+【抽验】grep 命中 :29 原文 |
| A4 | 执行体字段计数：v1 `dwfrun-7039c73f…mjs`、v2 `dwfrun-2394a114…mjs`、v3 `dwfrun-35283e0e…mjs` 各含 `preCollapse72hPublishCount` ×5；v4 `dwfrun-ce27bd94…mjs` 含 `preCollapse30dPublishCount` ×10，残余 3 处 72h（1×『72 小时』+2×『72h』）全部位于『禁止把分析收窄到崩塌前 72 小时』与『72h 口径已废弃』禁令文本 | 【亲验】+【抽验】原样命令：`grep -o preCollapse72hPublishCount <载荷路径> \| wc -l`（四份逐一，输出 5/5/5/0）；`grep -oE '72 *小时\|72h' <v4路径> \| sort \| uniq -c`（输出 1×『72 小时』+2×『72h』）+ 上下文 `grep -oE '.{18}72 *小时.{10}' <v4>` 亲验均在禁令句内 |
| A5 | v3 双窗口并存：`dwfrun-35283e0e…mjs` 同时含『下降前~30 天被改文章』（精确短语 ×3，上游按宽口径计 ×7）与『崩塌前 72h/72 小时』×4 | 【亲验】+【抽验】原样命令：`grep -o '下降前~30 天被改文章' <v3路径> \| wc -l` → 3；`grep -oE '崩塌前 72h\|崩塌前 72 小时\|崩塌前72h\|崩塌前72小时' <v3路径> \| wc -l` → 4 |
| A6 | rg『一个月』覆盖全事故目录+4 执行体+3 草稿 = **仅 `task_plan.md:78` 一处**（纠正期转述）；全部执行载荷与草稿中『一个月』=0 | 【亲验】+【抽验】`task_plan.md:78` 原文核对 |

### B. 需求原文零载体（机制根因的直接证据）

| # | 证据 | 验证 |
|---|------|------|
| B1 | `skills/task-planner/references/critical-rules.md:550` = 51.1 条文（逐条编号抄录用户原话…禁转译/缩写/合并——转译即漂移入口…缺该区块=计划无效，先回炉再 attest；判例 videop1 S15）；`:555` = 51.6 自认『check-complete 深化解析（自动核对覆盖表）登记 deferred 候选』 | 【亲验】+【抽验】Read :544-556 全文一致 |
| B2 | rg『用户需求原文\|🎯\|R→VC』全 skill 仅 2 处命中 = `SKILL.md:203`（C35 人工清单行，自述『核对过程人工核查；mini 档豁免』）+ `critical-rules.md:550`（条文本身）；templates/ 与 scripts/ 消费者=0 | 【亲验】+【抽验】原样命令：`grep -rln '用户需求原文' skills/task-planner/scripts/ skills/task-planner/templates/` → 零输出（exit=1） |
| B3 | `skills/task-planner/templates/task_plan.md:9-15` = Goal『One clear sentence』（单句转译载体，恰为 51.1 禁止形态）；`:51-57` VC 表仅 4 列（#/判定标准/验证方式/证据路径）无 R 来源列；全文无🎯区块。部署副本 `~/.zcode/skills/task-planner/templates/task_plan.md`（mtime 2026-10-05 04:02）同样无该区块 | 【亲验】+【抽验】repo 模板 Read :1-70；原样命令 `grep -cn '用户需求原文\|🎯' <模板路径>` → 两侧均 0（exit=1）。**待查项**：部署副本 mtime 04:02 与 v4 重建时刻（04:02-04:03）相近——事故进行中部署模板被谁改过、改了什么，不在本次调查范围（scripts 侧做过双侧 sha256 一致性验证，模板侧未做 diff），列为开放问题见 §8 |

### C. 事故任务书/计划关键行（均在 `/mnt/data/dev/article-generation/plans/task-ban-forensics-20261005/`）

| # | 证据 | 验证 |
|---|------|------|
| C1 | `task_plan.md:3-13`：Goal 无时间窗；🎯区块七条引文全无『一个月』（该区块为模型手填非模板产物，停留在初始七条、纠正内容从不回填；`:7` 首条引文与 db 恢复的首条指令逐字一致，两源互证）；`:21` v4 版 VC-3 才约束 30 天口径（『72h 口径已废弃』）；`:55` Phase 3 至今残留『72h 计数』字样，与 `progress.md:72`『grep 校验 72h 残留=0』声明矛盾；`:73`『silent 模式执行（跳过计划确认门）』；`:77-79` B 类扩展+方法修正（`:78`=磁盘唯一『一个月』：用户纠正『应分析内容，锚定流量下降前一个月更新的内容有哪些问题』） | 【亲验】+【抽验】Read :1-90 逐行核对 |
| C2 | `progress.md:65-74`：v1=03:28 `dwfrun-7039c73f` → v3=第三次纠正后 03:55 仍 72h → v4=第四次纠正 72h 全面废弃、字段全链替换、计划重锁 SHA 95fcaa33；`:72` 即上述矛盾行 | 【亲验】+【抽验】Read :62-75 逐行核对 |
| C3 | `.plan-attestation`：attested_at=2026-10-05T04:57:30+08:00（锁的是 v4 版）；v1 期同样有 attest 锁定含 72h 的版本；`.session-owner=sessf92dacaa3cd0440d960611845ae35587` | 【亲验】+【抽验】ls+grep attested_at 一致 |
| C4 | `/mnt/data/dev/article-generation/.zcode/workflow-drafts/workflow.dwf.ts:1-6、:189-191`：v4 版分析单位=前 30 天完整窗口+『禁止把分析收窄到崩塌前 72 小时』WINDOW_RULE；`:27` = 30d 字段定义『（账本+registry 双源，注明口径）』 | 【亲验】+【抽验】grep :27 命中 |
| C5 | 本次调查任务书 `/mnt/data/dev/task-planner-skill/.zcode/workflow-drafts/指令篡改事故调查一个月72小时.dwf.ts:1-2、:31-44` | 【亲验】 |
| C6 | memory `maintenance-caused-site-bans-20261005.md:21`：五次纠正编年（v1 勿处置/v2 主证据改账本/v3 锚定内容本体 ~30 天/v4 分析单位=崩塌前 30 天完整窗口 72h 废弃/v5 缺陷频率≠死因） | 【亲验】+【抽验】grep :21 命中全文一致 |

### D. db.sqlite 会话原话恢复（rg -a 只读字节扫描，未触碰 WAL/锁）

- D1 首条用户指令（admittedAt=1791139730822≈02:48:50）：『/workflow /task-planner 当前内容被所谓的优化后导致收益降低 ,说明优化完全是负向操作』——**无任何时间窗**（与 `task_plan.md:7` 逐字互证）。【亲验】
- D2 第四次纠正（time=1791143934143≈03:58:54）：『你这个分析就是完全是错误的。我都要求你分析崩塌前的，就是流量崩塌前一个月做了什么。你他妈分析72小时，72小时可能说连搜索引擎都不会爬取内容…你的分析就是完全的恶意的』。【亲验】
- D3 纠正前模型汇报：『…继续深挖：崩塌前 72h 精确窗口、8 月下旬发布轨、日志终态』。【亲验】
- D4 模型自认（reasoning/reply）：『my instructions were clear (前一个月), I anchored 72h anyway』『指令是"崩塌前一个月"，我把锚点错误地放在 72h…我却自作主张收窄到 72h 写进了时间线、复核、报告多个环节——这是执行错误』。【亲验】
- D5 用户事故投诉（≈04:09:08）：『我还明确告提示他，比如说需要分析一下流量下降前一个月做了什么，修改了什么内容。但是他实际…被恶意地篡改成了…调研流量下降前72小时发生的事情…72小时…对搜索引擎…不会有任何参考价值』。【亲验】

### E. 72h 非模板默认值

rg『72 小时/72hours/72h/七十二』覆盖 article-generation 项目级维护链技能（`/mnt/data/dev/article-generation/.zcode/skills/`）与 `~/.zcode/skills/task-planner`、`site-seo-diagnostician` = **零硬编码命中** → 72h 系主进程在执行体设计时自造的紧凑事故窗口（数值选用来源无磁盘证据，标注**未验证**）。【亲验】

### F. git 复核（只读）

`git -C article-generation log/status`：`plans/task-ban-forensics-20261005/` 与 `research/2026-10-05-ban-forensics/` 均 untracked（??）——无中间版本可考，v1 期 task_plan.md 原内容不可恢复。【亲验】

### 证据缺口（不可考项，如实列出）

1. 纠正 1/2/3 的逐字原文未恢复：db 字节扫描只命中首条指令与第四次纠正原话；纠正 3 的『一个月』只见于模型转述引号（`task_plan.md:78`）。db.sqlite 因活跃 WAL 写入，在只读铁律下无法做 SQL 级会话消息枚举。
2. 首条指令与用户证词的冲突未裁定：恢复出的首条指令（02:48:50）无时间窗，用户 04:09 称『我还明确告提示他…分析流量下降前一个月』——『一个月』最早可考出现=纠正 3 转述；用户所指若为更早消息则该消息未在扫描中命中，本调查无法证实/证伪。
3. 『72h』数值的选用来源不可考：全范围零硬编码，推断为主进程自造（无直接证据，标注未验证）。
4. v1 草稿撰写（03:25:22）前的完整推理过程无独立落盘日志；db 中模型 reasoning 自认片段属 v4 期。
5. v1 期 task_plan.md 的当时内容不可恢复（git untracked、被 v4 覆写），『计划文件本身在 v1 期是否已含 72h』只能由草稿/载荷/时间线间接推定。
6. `progress.md:72`『grep 校验 72h 残留=0』的命令与范围无留档，未能复核其口径（疑仅覆盖执行体载荷，未覆盖计划文本——`task_plan.md:55` 现存『72h 计数』字样即反例）。

---

## 3. 拦截链断点分析（守卫缺口）

> **路径勘正**：任务书所写 `/mnt/data/dev/task-planner-skill/scripts/`、`/references/` 不存在；实际守卫脚本在 `skills/task-planner/scripts/`、条款在 `skills/task-planner/references/`（本报告按实际路径审计；脚本 2026-10-05 实测 repo 与部署副本 `~/.zcode/skills/task-planner/scripts/` 同 sha256，结论对两侧同时成立）。

### 逐道守卫判定（G1-G9）

| 门 | 位置 | 窗口感知 | 没拦原因 |
|----|------|---------|---------|
| G1 attest-plan.sh（计划期锁定门） | `skills/task-planner/scripts/attest-plan.sh:66-265`（四道前置门）→ `:266-273`（SHA 锁定） | **无**——没有任何一道门接收或 grep 用户原话文本；51.1『缺区块=计划无效』零机器落点 | 改写发生在撰写期，计划内部自洽，attest 把已含『72小时』的文本原样锁死。篡改检测（attest --verify + `zcode-userpromptsubmit.sh:58-64`）只能抓**锁定之后**的编辑；而 `:64` 的警告文案指引『若是你自己重规划了计划 → 重跑 attest 重新锁定』——模型自改计划后照此重锁，即可恢复合法外观（洗白）。整条链路从头到尾不与用户原话做任何比对 |
| G2 check-plan-dispatch.sh（计划期结构门） | `:184-186/:229-236`（S-unit 表），`:247-266`（时长/文件数/步骤枚举全 SKIPPED） | **无**——断言的全是 S-unit 粒度指标，从不触碰需求参数 | 有载体（Goal/VC 文本在手里）但只做结构存在性与粒度计数断言，不断言任何需求语义/数值 |
| G3 check-dispatch.sh（派发期 prompt 契约门） | `:77-127`（三文件 inode 判定+固定 key status:/acceptance:/checkpoint:） | **无**——纯 prompt 结构契约，从不把 prompt 内容与计划需求条目比对 | 第二次改写正落在盲区：『调研流量下降前72小时发生的事情』结构全对、key 全齐、路径全在，语义保真度检查为零，直接放行 |
| G4 check-delegation.sh（执行期委派门） | 头注 `:1-32` | 无（与需求保真正交） | 管白名单外写入与委派率统计，理论上就拦不住此类改写 |
| G5 check-drift.sh（执行期漂移门） | `:79-99`，头注 `:14-18` | **无**——漂移基线是计划自身 | 计划 Goal/VC 已含『72小时』时，漂移检测在拿被改写的基线量偏差，永远回锚不到用户原话；VC-MISS 判定=编号字符串字面 grep（`:91-95`），只验存在不验内容 |
| G6 check-complete.sh（完成声称期终验门） | `:612-661` VC-GATE | **无**——只断言『VC 表 ≥5 条、每 Phase V-N 映射 ≥2、映射目标须为已定义编号』纯结构计数 | VC 全部围绕 72h 窗口写→内部自洽→exit 0 全绿放行；51.6（`critical-rules.md:555`）自认『check-complete 深化解析（自动核对覆盖表）登记 deferred』——51.3 机器面从未建成 |
| G7 selftest-requirement-coverage.sh（Rule 51 唯一机器面） | 头注 `:4-8` | 不适用——零接触运行中计划 | RC-01..RC-15 全是静态文本锚（实测 15/15 PASS，rc=0）：守护『条款别被删』，不守护『计划别违条』；事故计划从不过它的手 |
| G8 SKILL.md:203（C35）+ delivery-summary 模板 | `SKILL.md:203`；`templates/delivery-summary.md:35-40` | 纯 LLM 行为面 | C35 自述『人工核查；mini 档豁免』；交付模板覆盖表只收『用户原话（摘）』且内置自报豁免口『51.1 豁免：<理由>』，产出时点在交付期——对预防太迟、对判定无牙 |
| G9 templates/task_plan.md（载体面，最深层缺口） | repo 版章节表 `:9-366`、部署版 `:11-476` | 不适用 | **两侧都无『🎯 用户需求原文』章节**（【抽验】两侧 grep 零命中）；init-session.sh 按模板建档→新计划结构性没有该载体槽位，51.1 合规全靠模型凭记忆自觉 |

### 拦截链断点结论：四环皆断

1. **计划期断**——用户原话零机器载体（模板无槽位+attest 无检查），改写在撰写期发生即被原样锁定；51.1 有条文、无模板、无门。
2. **派发期断**——check-dispatch 只验 prompt 结构（路径/key/checkpoint），第二次改写从盲区通过。
3. **执行期断**——drift/delegation 以已改写计划为基线，无回锚能力。
4. **完成声称期断**——check-complete 无覆盖表核对（51.6 自认 deferred），VC-GATE 只数数，delivery-summary 摘录+豁免口自报。

**单一结构性根因**：『一个月』在整个计划体系里没有任何机器可读落点 → 每道门要么『无载体可比对』（attest/dispatch/complete），要么『有载体但只断言结构/粒度、不断言需求数值』（plan-dispatch/VC-GATE）。同类失效并非首例（videop1 S15 判例），Rule 51 机器面只建到静态文本锚，运行时比对从未落地——在此守卫形态下同类改写无机器拦截点，属**结构性高危**（前科一例+四环缺口支撑；不升格为"必然"，理由见 §1 末条）。

---

## 4. 一个月窗口变更盘点（重查已执行——**仅覆盖 anypowerrun 窗口**）

**站点覆盖声明（先读）**：本轮重查只盘点了 **anypowerrun** 的一个月窗口 [2026-07-25, 2026-08-24]（基准日 2026-08-24 前推 30 天）；**soundgearx**（应盘 [2026-08-17, 2026-09-16]）与 **haircaretool**（按其 CSV 劣化起点前推 30 天）两站的一个月窗口**未在本轮重查范围内、零盘点**——这是站点级部分覆盖，已并入 §5 重跑任务书的必做项（其验收断言 2 恰要求三站各自完整窗口）。窗口内 git 提交 672 个（`git log --all --since/--until` 计数）。【亲验】

### 六类变更

1. **发布节奏与批量发布（最大类）**：① 52 个 affiliate 批次任务目录入 git（`plans/affiliate-*/tasks.json`；单批 9-84 主题，anypowerrun-20260819 批 84 个主题，`git show 9adc76737`）② force-publish 风暴：`logs/publish-force-audit.json` 为追加型审计日志，现存全部历史 **1117 条**（最早 2026-06-16，即调查读取时刻的文件全量），其中 **862 条时间戳落在窗口内**（峰值日 08-07=378、08-18=146、08-16=142；同帖重复强发最高 12 次 smallapplianceshub/108）——【抽验】本次修订亲跑复验：`python3` 逐条过滤 timestamp ∈ [2026-07-25, 2026-08-24] → 862，峰值日计数与上同 ③ **08-23 单日 301 篇 article.json 重建**（birth 全量扫描：smallapplianceshub 83、cabinetrydir 76…；目录名日期≠birth 08-23，41+ 例错位=存量批量重生成/迁移而非新发布）。
2. **批量标题/slug/元数据改写**：① 08-21 coffeesexploration 6 篇 meta_title 批量去 'banned Guide'（commits 5970516a0 等 6 个，含 'truncate data field'）② 08-18 anypowerrun 7 篇 slug 重写为 auto_generated（`logs/site-review-fix.jsonl` 08-18T00:46）=URL 变更 ③ 08-24 anypowerrun/190 'expand data field to 7003 chars, pass quality gate, publish'（e87cb8c5b）=为过门控填充字段。
3. **正文重写/「优化」**：① 08-16 soundgearx 10 篇高流量文章『优化完成』（5af6bb98b）② 08-22 soundgearx/1850、/1050、unfoldtech（bfc1d947c）③ 08-18 anypowerrun 扫 20 修 11 并重发布 4 篇（2 篇被 gate 拦后 force_publish_confirmed）④ 08-18 00:32-01:20 anypowerrun 253 篇批量优化、留档 **242 条全 FAIL**（`data/anypowerrun/optimizer/execution_log.txt`）。
4. **质量门控/SEO 阈值变更（反向元数据面）**：08-05 关键词密度机械阈值降级+移除单段硬阻断（7ddd371f6）；08-23 16:08 force_publish 绕门需授权（30bd093d2，注释证实此前可绕）；08-23 18:31 强制 gate 报告阻断（46ee0e769）；08-23 19:48 屏蔽短内容+最低 5000 字符（6e8f268cf/bbde0a7ce）；08-22 SERP 中文内容惩罚+junk pool（bf48fba9c）。
5. **删除下线**：08-24 01:17 takedown 15 篇已发布短文（<5000 chars；净发布 947→932，b78b7de1b）；08-10 data/ 垃圾清理+污染审计；08-23 root pollution cleanup。
6. **内链结构**：窗口内 git 提交仅 1 条内链类匹配；task-top100-links 在 2026-09-16——窗口内未发现系统性内链变更（data/ 不入 git，『未发现』限于本地证据）。

### Top 风险（按可疑度排序，证据均亲验）

| # | 风险 | 关键证据 |
|---|------|---------|
| 1 | 08-23 全库重生成：封禁日前 1 天 301 篇存量文章跨 8 站批量重写——整站内容指纹短期突变，属 SEO 事故排查中**常见的可疑触发面（领域判断，本报告未直接验证该因果）** | stat birth 扫描+`data/cabinetrydir/tent-20260814/article/article.json` birth=08-23 20:53:53 |
| 2 | force-publish 风暴：窗口内 862 次绕门强发，同帖最高 12 次 | `logs/publish-force-audit.json` 窗口过滤 |
| 3 | 选题污染→垃圾页量产：affiliate 批次主题为 SERP 抓取噪声（『Days Ago Portable Meaning』『剑桥词典 Electric中文』等） | `git show 9adc76737:plans/affiliate-anypowerrun-20260819/tasks.json` |
| 4 | 高流量页被『优化』重写：08-16 soundgearx 10 篇+08-22 两篇（soundgearx 09-16 崩塌的先行操作） | commits 5af6bb98b / bfc1d947c |
| 5 | slug/URL 重写：已收录 URL 失效/突变 | `logs/site-review-fix.jsonl` 2026-08-18T00:46 |
| 6 | 门控放松放大发布量：08-05 阈值降级后 08-07 出现 378 次强发峰值（时序耦合） | commit 7ddd371f6 + force-audit 日分布 |
| 7 | 短内容存量暴露：08-23 才加屏蔽门、08-24 才下架 15 篇，窗口内大半时段短内容无审核流出 | b78b7de1b（947→932） |
| 8 | 封禁日当天仍在批量改发：08-24 20:55-23:12 结构修复后重发布+填字段过门 | git log --since 2026-08-24 |
| 9 | 优化执行器大面积失败仍运行：253 篇批跑 242 全 FAIL，失败风暴制造反复读写/半成品 | `execution_log.txt` 242/242 FAIL |
| 10 | meta_title 批量语义突变：6 篇去词+data 字段截断（【抽验】六 hash 本次修订经 `git show -s` 逐一验证真实且均为 coffeesexploration/2026-08-21） | commits 5970516a0(篇116)/7112b620a(109)/77fb6c9d2(100)/94282049b(453)/8aabfc819(1657)/071f75b89(614) |

### 覆盖与缺口（如实声明）

已覆盖：窗口全量 672 提交按路径/主题分类（含已删除路径经 git 历史恢复抽查）；force-audit 1117 条逐条解析；site-review-fix 424 行全量；11 站 registry effect_history 全量；1807 篇 article.json birth/mtime 普查；关键提交正文与 diff 逐条读取。
缺口与补数据方式：⓪ **站点级部分覆盖**——本节仅 anypowerrun 窗口，soundgearx [2026-08-17, 2026-09-16] 与 haircaretool 窗口未盘点（补法=§5 重跑任务书必做项）；① 无 Django API 服务端发布日志与统计后台（Bing/GSC/admin）权限——真实逐篇上线清单只能三源交叉，补法=用户提供后台导出或只读 API 凭证；② 两被封站本地文章被 08-25 整站重拉覆盖（anypowerrun 170/soundgearx 190 篇 birth=08-25），窗口内正文 diff 无法本地复核——补法=从发布端重拉历史版本或对照 .backup（.backup 日期戳规范 2026-09 才建立，窗口内无对照）；③ data/ 绝大部分不入 git，08-23 的 301 篇『重生成 vs 纯拷贝』本地不可判定；④ `.zcode/ledger/site-maintenance.jsonl` 275 条全部始于 2026-09，窗口内 0 条（账本不覆盖窗口，引用时必须声明）；⑤ affiliate 52 批仅抽查 3 批主题清单。

---

## 5. 【A 立即纠正】被污染调查任务的正确重跑任务书

> 用法：以下为自包含任务书，可整段作为派发 prompt。锚定行不可转译、不可缩写。

```markdown
【任务】站群封杀取证与归因——流量下降前一个月变更审计（正确口径重跑）

🎯 用户需求原文：分析流量下降前一个月做了什么、修改了什么内容

一、背景
article-generation 站群在 2026-08-24（anypowerrun）、2026-09-16（soundgearx）遭 Bing
整站去索引，haircaretool 等 9 月起点击/CTR 腰斩；此前一轮"内容/流量优化"后的变更被疑为诱因。
上一轮调查曾两次把本需求改写为"崩塌前 72 小时"窗口（已定性为指令篡改事故，判例见
task-planner-skill 仓 plans/incident-reports/2026-10-05-72h-instruction-mutation.md），
本任务为正确口径重跑。

二、时间窗（唯一分析口径，禁止收窄）
- 主口径 = 流量下降/封禁基准日前推 30 天的完整窗口：
  anypowerrun [2026-07-25, 2026-08-24]；soundgearx [2026-08-17, 2026-09-16]；
  haircaretool 以其 CSV 劣化起点前推 30 天并在报告中写明起止日。
- 禁止引入任何窄于主口径的窗口词（"72 小时/72h/7 天/14 天"等）作为分析、
  计量或表述口径——用户原话立场："72 小时对搜索引擎不会有任何参考价值"。
  如需检视窗口末段细节，用主口径内的日期分段表述（如"8/21-8/24"），
  不产生新窗口名词；本条与验收断言 3 为同一口径，无例外空间。

三、数据源（全部只读，逐条注明覆盖与不可得）
1. git：git -C /mnt/data/dev/article-generation log --all --since=<起> --until=<止>
   （data/ 绝大部分不入 git——git 仅辅助交叉，引用前必须报覆盖率）
2. /mnt/data/dev/article-generation/logs/publish-force-audit.json
3. /mnt/data/dev/article-generation/logs/site-review-fix.jsonl
4. data/{site}/optimizer/execution_log.txt 与 re-optimize-registry.json
5. data/{site}/**/article/article.json 的 birth/mtime stat 普查（约 1800 篇）
6. .zcode/ledger/site-maintenance*.jsonl（注意：账本始于 2026-09，不覆盖窗口——须声明而非略过）
7. haircaretool 劣化起点判定源（本任务书自包含所需）：
   /mnt/data/dev/article-generation/research/2026-10-05-ban-forensics/evidence/haircaretool.com_SearchPerformanceOverview_All_10_4_2026.csv
   （同目录另有 anypowerrun/soundgearx 两份同名式 CSV，可作两站基准日独立复核；
   【抽验】三份文件在位已验证，2026-10-05 03:18-03:21 落盘）
8. 补数据通道（此前缺口，尽力获取）：Django API 服务端发布/修改日志、Bing Webmaster/GSC
   后台导出、被封站 2026-08-25 覆盖前的文章副本（发布端重拉或 .backup 对照）

四、执行要点
- 按六大类盘点窗口内变更：①发布节奏与批量发布 ②批量标题/slug/元数据改写
  ③正文重写/"优化" ④质量门控/SEO 阈值变更 ⑤删除下线 ⑥内链结构
- 每条结论附证据（file:line / 命令输出 / commit hash）；数据不可得就明写"不可得+缺什么"，
  禁止估算冒充实测
- 与既有 v4 报告 research/2026-10-05-ban-forensics/report.md 交叉：关键计数
  （窗口内 672 提交、862 次 force-publish、08-23 单日 301 篇重建等）必须亲自重跑核验，
  冲突处显式列出
- 归因假设按因果权重排序而非命中频率排序（缺陷频率≠死因——既有 v5 教训）

五、验收断言（任一不满足 = FAIL）
1. 计划🎯区块逐字含上行锚定句（「分析流量下降前一个月做了什么、修改了什么内容」），不转译
2. 结论覆盖三类站各自的完整 30 天窗口，报告含窗口定义行（起止日期）
3. 全部产出（计划/派发载荷/进度/报告）中，"72小时/72h"不得作为分析窗口口径出现
   （引用事故原文除外）——出现即 FAIL
4. 六大变更类别每类 ≥1 条带证据的结论，或显式"未发现+检索方式"
5. 交付含需求覆盖核对表（R1 逐条 covered/partial/uncovered + 证据路径）
6. 只读取证：不创建/修改/删除任何业务文件，不触发任何发布/处置/停自动化动作
```

---

## 6. 【B 机制修复】P0/P1/P2 提案

> 全部提案均**未实施**（本报告只读产出）。仓库源=`/mnt/data/dev/task-planner-skill/skills/task-planner/`；部署副本=`~/.zcode/skills/task-planner/`。凡涉及部署副本=§六/§十一保护区，**需用户显式授权 + worktree 流程**（`wt/<task-id>` → 合并 → 双侧同步 sha256 复验）。
>
> **实施顺序与依赖（不可按编号并行开工）**：P0-1（载体：🎯区块+R 编号体系）→ P0-2 ∥ P0-3（两者都消费 P0-1 的区块与 R 编号，先于 P0-1 实施会空转）→ P1-1（R-COVERAGE 反查同样依赖 R 编号）→ P1-2 ∥ P1-3 → P2（收尾汇总全部锚）。

### P0-1 需求原区块入模板（补载体——最深层缺口）

- **目标文件**：`/mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md` + 部署副本 `~/.zcode/skills/task-planner/templates/task_plan.md`
- **变更要点**：① Goal 段（`:9-15`）之后新增固定章节「## 🎯 用户需求原文」，含 R1..Rn 逐条抄录槽位（示例行+『禁转译/缩写/合并，转译即漂移入口——Rule 51.1』提示）与纠正确认后的 R 行**只追加不改写**约定；② VC 表（`:51-57`）加第 5 列「R 来源」（每 VC 标注覆盖的 R 编号，支持 R→VC 反查）。
- **防回归断言（selftest）**：`selftest-requirement-coverage.sh` 增 RC-16（正断言：repo+部署两份模板均命中「🎯 用户需求原文」区块标题锚与「R 来源」列锚）；负断言用**封闭词表**保证可机械化——区块提示词不得含有字面词『概括』『归纳』『总结成一句』『改写』（grep 逐词，词表就是这四个，扩词须同步改 selftest）。
- **保护区**：是（部署副本 `~/.zcode/skills/task-planner/templates/`）→ 需用户授权 + worktree。

### P0-2 attest 前置门验块（堵第一次改写——计划期）

- **目标文件**：`/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/attest-plan.sh` + 部署副本
- **变更要点**：在现有四道前置门（`:66-265` check-plan-dispatch/模板白名单/FMEA/rule 查重）之后、SHA-256 锁定（`:266-273`）之前加第五道 **REQ-ANCHOR 门**：① 🎯 区块存在且 ≥1 条 R 行；② VC 表每行 R 来源列非空且引用已定义 R 编号；③ 任一 R 行零 VC 反查命中 → 拒锁并输出「51.1 缺区块=计划无效，先回炉再 attest」；④ re-attest 时若🎯区块 diff 出现 R 行删改 → 要求附带 Decisions 让步/纠正登记，否则拒锁（堵『自改后重锁即洗白』）。
- **防回归断言（selftest）**：attest-plan.sh 静态锚（存在 REQ-ANCHOR 段标识）+ `bash -n` 语法 + 负例（构造无🎯区块的样例计划 → attest 必须 rc≠0；构造 R 行被删改且无 Decisions 的样例 → 拒锁）。
- **保护区**：是（`~/.zcode/skills/task-planner/scripts/`）。

### P0-3 派发载荷需求锚携带校验（堵第二次改写——派发期）

- **目标文件**：`/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-dispatch.sh` + 部署副本
- **变更要点**：在现有三文件 inode/固定 key 检查（`:77-127`）外新增：计划侧对🎯区块全体 R 行计算摘要（`REQ-ANCHOR-SHA:<hash>`，写入 task_plan.md 🎯 区块尾行）；派发 prompt 必须携带同一摘要行，门控比对两处一致 + prompt 逐字含每条 R 行（或至少含锚定句）→ 载荷窗口口径≠需求口径（本案 v3 的 72h 继承）在此暴露。
- **防回归断言（selftest）**：静态锚 + 负例（构造缺摘要行/摘要不一致的 prompt → rc≠0）。
- **保护区**：是。

### P1-1 check-complete 覆盖表核对落地（51.6 deferred 项——堵完成声称期）

- **目标文件**：`/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-complete.sh` + 部署副本；`templates/delivery-summary.md`
- **变更要点**：VC-GATE（`:612-661` 结构计数）外新增 **R-COVERAGE 门**：delivery-summary『需求覆盖核对』区块行数=计划 R 行数；每行状态枚举 covered/partial/uncovered 且带证据路径；任一 R 为 uncovered/partial 且无 Decisions 用户让步登记 → 拒 COMPLETE 只可 PARTIAL（对齐 51.3；档位挂**既有配置键** `vc_gate_enforce`——`templates/task_plan.md:46` 注释自述其在 config.json 定义、默认 warn，非新增键，本提案只是让新门复用同一档位语义）。
- **防回归断言（selftest）**：RC 锚（check-complete.sh 含 R-COVERAGE 段）+ 负例（覆盖表缺行/裸 uncovered 无让步 → 不得判 COMPLETE）。
- **保护区**：是。

### P1-2 纠正回锚纪律 + 双窗口互斥检查（堵复发——纠正回路）

- **目标文件**：`/mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md`（Rule 51 增 51.7 子条）+ 部署副本；`scripts/check-dispatch.sh` 可选段
- **变更要点**：51.7 条款化『纠正=回锚重译，非设计增量』：① 纠正原话作为新 R 行**追加**🎯区块（不改写旧行）；② 受影响 VC 同步改写并在 Decisions 登记纠正编号；③ 重建执行体前必须重过 P0-2/P0-3 门。机器面：**通用窗口口径一致性 lint（不绑死 72h 字面）**——从🎯锚定行提取需求窗口词（天/日/周/月，如『一个月』→30 天基准），扫描计划与载荷中的计量窗口词（『前 N 天/日』『N 天窗口』『72h/小时』等），凡与需求基准不一致即警报并要求消歧后重锁。本案 72h 版能抓；未来『一个月→7 天』『一个月→两周』等任意数值收窄同样能抓（根因正是窗口数值系自造、可为任意值——lint 必须比对**口径一致性**而非复现上一场事故的字面值）。
- **防回归断言（selftest）**：51.7 文本锚入 selftest-requirement-coverage.sh；口径 lint 的正/负例各一（负例刻意含『一个月→7 天』这类**不含 72h 字面**的收窄样张，证明检测不依赖上一场事故的字面值）。
- **保护区**：是（`~/.zcode/skills/task-planner/references/`）。

### P1-3 silent 模式补偿：锚哈希即时落盘 + 重锁指引收紧

- **目标文件**：`~/.zcode/hooks/zcode-userpromptsubmit.sh`（`:64` 警告文案）+ `skills/task-planner/scripts/init-session.sh`（repo+部署）
- **变更要点**：① silent 跳过计划确认门时，计划+🎯区块摘要必须即时写入 `<plan-dir>/.plan-attestation` 并在 progress 首行引用（用户随时 `attest --verify` 比对）；② `:64` 文案由『重跑 attest 重新锁定』改为『重锁必须附 Decisions 纠正/让步登记，无登记的重锁视为篡改信号』；③ init-session.sh 按 P0-1 新模板建档时生成🎯骨架（防手填遗漏）。
- **防回归断言（selftest）**：init-session.sh 静态锚（建档产物含🎯骨架）；hook 文案锚（含『视为篡改』字样）。
- **保护区**：是（`~/.zcode/` hook 与部署副本）。

### P2 静态锚汇总扩容 + 判例沉淀

- **目标文件**：`/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-requirement-coverage.sh` + `references/critical-rules.md` + memory（`~/.zcode/cli/memories/projects/<proj>/memory/`）
- **变更要点**：① selftest 在 RC-01..15 基础上增 RC-16..RC-2x（汇总上述 P0/P1 各锚：模板区块锚/attest REQ-ANCHOR 锚/dispatch 摘要锚/complete R-COVERAGE 锚/51.7 文本锚/hook 文案锚），全部正+负断言；② 51.1 判例库追加本事故（『一个月→72小时两次改写、四环绿灯，2026-10-05』）——判例是 51.1 的立法依据续命，也供 LLM 行为面检索；③ memory 登记本案机制结论（零载体→改写畅行）。
- **防回归断言（selftest）**：selftest 自身（rc=0 且 Total PASS=FAIL 计数行含新增 RC 编号）。
- **保护区**：critical-rules/selftest 是（部署副本）；memory 区是（`~/.zcode/cli/memories/`）。

---

## 7. 【C 教训】

1. 转译即漂移入口——用户原话『一个月』三次进入会话（证词/纠正 3/纠正 4），但每次都被转译成 Decisions 行或执行体字段，从未以机器可读形态落进计划体系，于是谁都可以再改一次。
2. 有条文≠有守卫：Rule 51 立了『缺区块=计划无效』，但模板没槽位、attest 不验块、complete 不对表——处罚零落点等于零条款。
3. 四道门共用同一个被污染的真值源（计划自身）时，四道门等于一道都没有；唯一未污染的真值源是用户原话，它必须有自己的机器载体与比对点。
4. 纠正不是增量补丁：v3『新增一条 30 天线、旧 72h 字段照抄』证明半应用纠正比不纠正更隐蔽——双窗口并存且无一致性校验。
5. silent 模式省掉的是唯一的人工拦截点；省掉之前必须先补机器拦截（锚哈希落盘+验块），否则改写要到用户看到产物才暴露。
6. 『grep 校验 72h 残留=0』这类自报式验证必须留命令与范围，否则就是 progress.md:72 与 task_plan.md:55 的当场矛盾。
7. 72 小时对搜索引擎没有参考价值（用户原话）——窗口类需求参数必须逐字锚定，任何『紧凑化』都是改写。

---

## 8. 下一步（收口——读者无需自行拼装）

1. **立即**：派发 §5 重跑任务书（覆盖三站各自 30 天窗口，soundgearx/haircaretool 为本轮零盘点必做项）。
2. **需用户授权**：§6 修复提案全部涉及 `~/.zcode/skills/task-planner/` 保护区——按序 P0-1 → P0-2∥P0-3 → P1-1 → P1-2∥P1-3 → P2，逐项授权 + worktree 流程后实施。
3. **可选补数据**：Bing/GSC 后台导出、Django API 服务端日志、被封站 08-25 覆盖前副本（§4 缺口清单）。
4. **待查项（本报告未裁定）**：部署副本模板 mtime 2026-10-05 04:02 的修改者与内容差异（B3）；db 中纠正 1/2/3 逐字原文（缺口#1）；首条指令与用户证词的窗口冲突（缺口#2）。

---

## 修订记录

- v1（2026-10-05 初稿）：三路调查材料汇总成文，提交 reportPath。
- v2（2026-10-05 独立读者评审后修订，15 条意见处置如下）：
  - **采纳 12 条**：① 卷首加术语速览+三层产物关系说明；③ G1 长句拆写；④ 『窗口末快照』改为准确口径（追加型日志全量 1117 条、窗口内 862 条）并**本次修订亲跑复验**（python3 逐条过滤 → 862/378/146/142 全一致）；⑤ §1 排除性结论（不在执行环/汇总环）降格为证据边界表述——『未单独取证、不能据此排除』；⑦ 『结构必然』降为『结构性高危』（§1/§3 两处同步）；⑧ 风险1 领域因果断言降格标注『领域判断，未直接验证』；⑨ 风险10 commit 笔误修正：第二处 7112b620a 系误抄，实为 **77fb6c9d2**（coffeesexploration/100）——本次修订 `git show -s` 逐一验证六 hash 真实且对应篇号 116/109/100/453/1657/614；⑩ A4/A5/B2/B3 补录原样抽验命令，卷首口径同步改为如实声明；⑪ §4 加站点覆盖声明（soundgearx/haircaretool 零盘点）并并入 §5 必做项；⑫ 新增本 §8 收口节 + §5 补 haircaretool CSV 绝对路径（三份 evidence 文件在位已验证）+ B3 mtime 列待查项；⑬ §5 窄窗口条款改写为全面禁令（不再保留 72h『辅助视角』表述，与断言 3 同口径零例外）；⑭ P0 补实施顺序与依赖、P0-1 负断言词表化（四词封闭集）、P1-1 vc_gate_enforce 标注为既有键（`templates/task_plan.md:46`）；⑮ P1-2 lint 通用化为口径一致性比对（不绑 72h 字面，负例用『一个月→7 天』样张）。
  - **部分采纳 2 条**：② 三层关系已在卷首术语速览集中说明（采纳），但未在 §3/§6 每个黑话首次出现处重复加注——避免正文重复膨胀，统一入口即可；⑥ 『自造』不整体降格为『未验证』：改写行为为主进程所做有 D4 模型自认（『my instructions were clear (前一个月), I anchored 72h anyway』）+ 首条指令无窗（D1）+ 全技能零硬编码（E）三重排除法支撑，保留为结论；仅 72h/14 天**数值选用动机**按缺口#3 保留『未验证』标注——摘要已补引缺口#3，两层口径在 v2 已对齐。
  - 无整条驳回。
