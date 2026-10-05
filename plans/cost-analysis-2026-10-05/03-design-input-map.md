# 03-design-input-map — 设计代理输入链路测绘底稿（2026-10-05）

> 任务：测绘「设计代理」（把审计发现转成修复/守卫设计的代理）的派发位置与输入构成，为输入收窄方案提供事实底座。
> 范围：源 `/mnt/data/dev/task-planner-skill/skills/task-planner`（下称【源】）与部署位 `/home/terry/.zcode/skills/task-planner`（下称【部署】，只读对照）。
> 只读研究；本文件为唯一写入物。证据一律 path:line；区分「档案实证」与「推断」。

## 0. 进度（全部完成）

- [x] 里程碑 1：规范层——派发点定位（SKILL.md / critical-rules / dispatch-examples / templates / scripts）
- [x] 里程碑 2：机器门控——check-dispatch.sh / check-plan-dispatch.sh 硬性输入要求
- [x] 里程碑 3：档案层——v116/v117/v125/v127 实际派发记录与重读行为
- [x] 里程碑 4：源↔部署 diff + 体量测算
- [x] 最终结论

## 1. 术语映射（推断，依据档案）

「设计代理」字面词两棵树 grep 0 命中。按定义映射：审计发现产生方 = alignment-review 技能（【源】review-library/alignment-review/SKILL.md:67-68，CHANGES_REQUESTED + `[P0|P1|P2] file:line — 问题 — 建议修法` 逐条清单）；设计代理 = rule-enhancement 型计划中承接发现清单、产出条款/守卫设计的 executor 子代理（【源】templates/variant/rule-enhancement-type.md:4「推荐 subagent: executor(sonnet-1) 写条款与脚本」）。派发统一走 Rule 22.4 九字段模板。

## 2. dispatchSites — 派发点与输入构成（档案实证，除注明外源=部署）

规范层（skill 文件内的派发规定与门控）：

| # | 派发点 | 输入构成 |
|---|--------|---------|
| D1 | 【源】templates/subagent_dispatch.md:13-72（九字段模板本体；Rule 22.4） | §2:19-22 计划三文件必传（task_plan 只读/findings/progress 追加契约，22.4a）；:23 材料包路径取自 S-unit 表「输入」列（计划期预写）；:24 findings 摘要 ≤10 行；:29-33 knowledge-brief 上下文包（brief 存在时必读 §5 索引节）；:70-72 §9 预算 ≤3000 字符、禁贴三文件全文与大段源码、子代理只 Read §2 列出路径 |
| D2 | 【源】references/critical-rules.md:165-168（Rule 22.4/22.4a/22.4b/22.4c 权威条款） | 九字段=目标/输入/验收/Scope/路径/时长/返回 8 字段/checkpoint/上下文预算；:165 输入首块=三文件绝对路径+材料包路径+findings 摘要；:167 派发 prompt 必须附 templates/subagent_dispatch.md **路径引用**（非贴原文）；:168 机器守卫挂 PreToolUse hook |
| D3 | 【源】references/critical-rules.md:143-144,170（Rule 21.1b/21.2/22.6） | S-unit 表 7 列（:170），「输入」列=路径+≤10 行摘要计划期预写；单步 ≤2 文件/≤100 行/≤15min（:143）；知识要点沉到 knowledge-brief 五段、prompt 材料包引用 brief 节锚点 §1-§5（:144） |
| D4 | 【源】templates/variant/rule-enhancement-type.md:47,65-68,82-88,107-110（设计类任务的计划载体） | :47 派发契约——executor prompt 必含计划三文件路径+acceptance:/checkpoint: 等 8 字段标签（check-dispatch.sh 逐字校验）；:65-68 S-unit 表实例列法；:82-88 必读知识储备表=critical-rules.md 末尾范式（☑）/selftest-veto.sh（☑）/config.json 三档键（☑）；:107-110 Handoff 登记表 |
| D5 | 【源】scripts/check-dispatch.sh:39-76,84-91（派发时机器门控，pretool hook 入口 :8） | 缺项扫描七项=三文件绝对路径+`status:`+`acceptance:`+`checkpoint:`+`subagent-state/`；①prompt ≤prompt_max_chars（默认 3000，wc -m 口径 :39-42）②单 prompt 单 S-unit（:43-44）③有 checkpoint 引用但无 brief/§ 锚→告警（:50-55）④步骤枚举 >step_max_steps(4) enforce 硬拦（:57-65） |
| D6 | 【源】scripts/check-plan-dispatch.sh:26-31,255-258（attest/终验时 S-unit 表门控） | 列序 $5=输入列；输入列路径 token >step_max_files(2) → SKIPPED 提示拆分（提示不阻断） |

非派发点（澄清，档案实证）：references/dispatch-examples.md:1-5 明文「派发 prompt 不附本文」——该文件只服务主进程断点续做（§2）与 STOP 上报（§3），不进设计代理输入。

scripts/ 内**未找到**程序化 prompt 构造/生成代码（grep 派发/设计/prompt 相关仅命中校验器与锁文件 .dispatch-inflight）——派发 prompt 由主进程按模板手工构造，脚本只做校验。「未找到」如实登记。

档案层（对齐审计轮实际派发实例）：

| # | 派发实例 | 输入构成实测 |
|---|---------|-------------|
| A1 | plans/task-v127/subagent-state/04-s1-prompt.md（39 行/2368 字符，Rule 50 条款转写 S1，最典型设计代理） | 任务书本体+task_plan.md（只读，指到「📐 Rule 50 设计契约」区块 task_plan.md:118-141）+findings/progress（只读）+knowledge-brief §1/§4+worktree critical-rules.md（目标文件；范式参照 ### 47(:484)/48(:496)/49(:506) 三块）；§9 明示「设计契约区段 Read offset/limit；critical-rules.md 只读文尾 40 行」 |
| A2 | plans/task-v116/subagent-state/1-executor-prompt.md（38 行/1879 字符，R 系列文档修复 S1） | 实测基线**直接内联**（variant=29/40 键/81 脚本等逐项数据，:5-9），刷新项六类逐条指令；**无三文件绝对路径**——契约偏差实例（checkpoint 1-executor.md 亦无三文件重读记录，靠内联基线免重读） |
| A3 | plans/task-v127/task_plan.md:176-181（S-unit 输入列实例） | 每行输入=1-2 个路径+区块限定词（如「§Rule 50 设计契约全文」「插入点=:520 文末」「frontmatter :9」），未贴内容 |
| A4 | plans/task-v127/knowledge-brief.md §5（S-unit 材料包索引） | 每个设计 S-unit 预写「应读 brief 哪节 + 额外材料路径」，S1-S9 逐行互链 |
| A5 | plans/task-v125/subagent-state/m3-executor.md:6,30（Rule 52 条款设计 checkpoint） | 按 brief §3 锚定位 SKILL.md 落点；实测锚漂移 +14 行→改按 §4.2 grep 定位而非行号盲信（设计代理的实际重读=grep 局部） |

## 3. rereadFiles — 设计代理重读规范文件清单（体量=wc -l 实测；【源】=【部署】除非注明）

| 文件 | 体量 | 用途与实际读法 |
|------|------|---------------|
| templates/subagent_dispatch.md | 73 行（两树 SAME） | 派发 prompt 骨架来源；进设计代理输入的只是**路径引用**（critical-rules.md:167），不整读 |
| `<plan-dir>/task_plan.md` 实例 | v116=144 / v125=234 / v127=300 行 | 只读对齐 Goal/VC/Scope；实际只读设计契约区段——v127 S1 读 :119-141（23 行，checkpoint 04-s1-executor.md:6 实证） |
| `<plan-dir>/findings.md` 实例 | 78 行（v116=v127） | 只读+追加 `#### [sub:…]`；A2 实例未要求读 |
| `<plan-dir>/progress.md` 实例 | 66-133 行 | 只读+追加 `[sub:seq]`；仅 S8 类「取基线」S-unit 读（v127 knowledge-brief §5） |
| `<plan-dir>/knowledge-brief.md` | 模板 61 行；实例 v125=66 / v127=81 行 | §1-§5 五段知识底座；brief 存在时必读 §5 索引（subagent_dispatch.md:33）；实际按索引读 §1/§4 等节（04-s1-executor.md:7 实证） |
| references/critical-rules.md | 【源】567 / 【部署】574 行 | rule-enhancement 计划必读表「最近两轮规则块范式」（rule-enhancement-type.md:86）；实际只读文尾 ~40 行 + 3 个范式块 ~30 行（04-s1-prompt.md:13,38 实证） |
| scripts/selftest-veto.sh | 68 行 | 守卫写法范式（rule-enhancement-type.md:87 必读 ☑；v127 实例按 S-unit 换 selftest-media-dispatch.sh 等对应范式，knowledge-brief §5） |
| config.json | 440 行 | 三档键范式（rule-enhancement-type.md:88 必读 ☑）；实际按需局部查键 |
| references/dispatch-examples.md | 50 行（两树 SAME） | **非设计代理输入**——主进程失败处置才读（:4） |
| SKILL.md | 【源】461 / 【部署】475 行 | 主进程技能体；**未发现任何设计代理派发要求读 SKILL.md**（v125 m3 只 grep 定位其落点后由主进程/后续 S-unit 编辑） |

## 4. 源↔部署 diff（档案实证，diff 命令实跑）

- SAME（0 diff）：subagent_dispatch.md / dispatch-examples.md / rule-enhancement-type.md / knowledge-brief.md / check-dispatch.sh / check-plan-dispatch.sh——**派发契约链路两树完全一致**。
- DIFF（部署位较源新）：SKILL.md（461→475，+并行创作组区块 :249-262）、critical-rules.md（567→574，+Rule 21.4.1 与 23.9-23.13）、templates/task_plan.md（440→479）。增量为 Unit×Lane 并行创作组语义，不进设计代理派发输入，不影响本测绘结论；但说明部署位领先于源仓 master（源仓 skills/ 未见对应改动，属两树漂移事实，登记待收口）。

## 5. volumeEstimate — 单次输入体量与构成（推算口径注明）

口径：字符数按 `wc -m`（check-dispatch.sh:39 同口径，预算 prompt_max_chars=3000）；行数按 `wc -l`。

- **派发 prompt 本体**：实测 3 件真实任务书 1879/1792/2368 字符（v116 S1/v125 m11/v127 S1，`wc -m` 实跑），全部 ≤3000 预算，均值 ≈2013。构成（推断）：九字段骨架与返回格式模板 ≈40%，材料路径+摘要/基线数据 ≈30%，验收+禁改+checkpoint ≈30%。
- **派发后区段化重读**：以最典型的 v127 S1 为例（档案实证）= 任务书 39 行 + task_plan 设计契约区段 23 行 + brief §1/§4 ≈40 行 + 目标文件文尾 40 行 + 范式 3 块 ≈30 行 ≈ **170 行级（约 5-8KB）**；对比「若通读」critical-rules(567)+task_plan(300)+brief(81)+findings(78)+progress(133) ≈1159 行，区段化把规范重读压到约 15%（推断）。
- **占比小结**：单次设计代理输入 ≈ prompt 本体 2-2.4K 字符 + 区段重读 5-8KB；规范大文件（critical-rules/SKILL.md）从未整读进设计代理上下文——输入收窄机制（路径+区段锚+brief 索引）在档案层已实际生效，瓶颈不在规范通读而在 prompt 内联基线的膨胀（A2 实例已现内联式变体）。

## 6. 最终结论

设计代理派发是「模板构造 + 双门控」链路：主进程按 templates/subagent_dispatch.md 九字段手工构造 prompt（无脚本生成器，未找到登记），机器侧由 check-dispatch.sh（派发时，七项缺项+长度+单 S-unit）与 check-plan-dispatch.sh（attest 时，S-unit 输入列 ≤2 路径）双闸把守；输入构成 = 计划三文件绝对路径（必传首块）+ S-unit 输入列材料路径 + findings 摘要 ≤10 行 + knowledge-brief 节锚索引，预算 3000 字符硬顶。档案层（v116/v117/v125/v127）实证设计代理实际重读全部是区段化 Read（设计契约区块/文尾范式/grep 定位），规范大文件不进上下文；两处偏差事实：①A2 实例（v116 S1）未带三文件路径改内联基线（契约的旁路变体）；②部署位 SKILL.md/critical-rules.md/task_plan.md 模板领先源仓（并行创作组增量未回流源 master）。
