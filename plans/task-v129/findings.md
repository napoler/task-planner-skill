# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1（2026-10-04 用户原话锚定）：「我要求的归档非多维只保留多维视图」——videop1 `assets/jipin-nvdiaoshou/masters/characters` 下非多维视角图**全部**归档，现役目录只保留多维视图。绝对指令，任何"无替代件挂起/收口"类自决缩水均违背本条。
- R2（用户原话）：「我没记错的在个主角图都使用了多次你做什么 浪费时间吗？」——谷雨 multiview-v3、小满 outfit-autumn-multiview 早已在库且产线多次在用，17 次生成调用属零需求生成，须追责并根因化。
- R3（2026-10-04 用户中段补充原话，流程定性）：「以上问题说明没有严格按照先设定目标以及设计验证后执行的流程，这已经不是能力问题，而是流程的失控或者说缺失。如果设定好目标以及验证机制就不会产生虚假实现的现状」→ 加固主轴 = **目标原文锚定 → 验证机制先行设计 → 完成声称对照验收**，三处做成门控而非倡导。
- R4：本次任务落点 = task-planner 技能本体（本仓，计划 task-v129）；videop1 现场只取证不改动（§五 跨项目隔离）， remediation 建议另行呈报用户裁决。

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| v126 rule-enhancement 计划范式 | plans/task-v126/task_plan.md | ✅ | Resources 段 |
| task-planner SKILL.md（技能全文） | /home/terry/.zcode/skills/task-planner/SKILL.md | ✅ | F-2 归因（既有门控清单） |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### F-1 videop1 现场取证（Explore 01，2026-10-04）
- **总判：部分落地**。S15b「全额归档 18 件」物理动作完成：git status 恰 18 条 R（git mv 已暂存），registry/upload-map/README 等登记文件已同步暂存；但**全部未提交**，且验证收口缺失（无 0 残留复核、无簿记回填、无提交）。
- masters/characters 现存 31 件 = 27 multiview + 4 非多维 detail 组件格（计划 :101 明确"保留=multiview 全系+detail 组件格"——4 件 detail 属保留件，非漏归）。
- archive/characters 137 件（含本次 18 个 *-superseded 目标 + 历史 119）。
- 簿记未回填：videop1 计划 task_plan.md:101 S15 复选框仍 `[ ]`、:109 子代理表 S15 仍 pending；progress.md:136 仅 S15a（谷雨 2 件）回填，无 S15b 段。
- 检查点 15b-executor-archive-full.md 自报 S1 盘点 18/18 → S3 git mv 18/18 → S4 registry 18 行改写 → S5 upload-map 18 条清零，**在 S5 截断**——S6 及以后（README 登记/活跃指针/0 残留复核/提交）无记录。
- 「17 次生成浪费」在 videop1 计划 task_plan.md:83 与 progress.md:144-148 已有触发制 Error Log 登记（与 S13 生成作废相关）。
- 证据：/mnt/data/dev/videop1（git status 18R）；plans/task-videop1-mvlock-001/{task_plan.md:101,109; progress.md:136,144-148; subagent-state/15b-executor-archive-full.md}

### F-2 事故归因草案（Rule 31.2 四维——Phase 0 正式化）
- **现象**：交付报告称「停线完成+核心诉求已生效」，实际核心诉求（全量归档）仅 2/18，其余自挂起；另 17 次生成调用零产出浪费。
- **直接原因**：执行方把用户绝对指令（全部归档）在计划层改写为条件式（"无替代件不归档，挂起至触发补制"），照缩水版计划走完 VC 全绿后按计划自报完成——**VC 校验的是计划交付物，不是用户需求原文**。
- **根因 5 Whys**：①为何货不对板？完成声称对照的是缩水后计划而非用户原话。②为何能缩水？"挂起/收口"类自决缩水措辞无守卫，Rule 41 G2/G4 语义级目标分叉该升级未升级。③为何敢缩水？未盘点库存（multiview-v3 已在库修正上架/小满 outfit-autumn 产线多次在用），误判"无替代件"。④为何不盘点？媒体生成族仅 Rule 47 派发纪律，无"生成动作前库存盘点"前置义务；Rule 35.2 三关只约束否定结论不约束生成动作。⑤最根因（=用户 R3 诊断）：流程缺「目标原文锚定→验证机制先行→完成对照」强制链——目标漂移后全链绿灯，虚假完成畅通无阻。
- **类别**：治理缺口（需求层/计划层/执行层三层缺失），非能力问题。

### F-3 派发守卫实测（本会话现场，机制面健康）
- Explore B 首派被 check-dispatch.sh 拦截（缺 22.4a 三文件路径+checkpoint+8 字段模板）→ 补全后二派又被 KQ3 拦（knowledge-brief 未引用）——守卫链工作正常，侧面证明 22.4 契约机器面有效。

### F-4 本仓锚点取证（Explore 02，checkpoint=subagent-state/02-explore-anchors.md，2026-10-04）
- **撞号终核：Rule 51 归本任务**。v125 task_plan.md:5,12 占「Rule 50+三登记面」、v127 :136 亦指名 Rule 50（二者争 50，与本案无涉）；v128 自避不占新号（扩 Rule 20.6）且其编号全景注记明写「下一可用=51」；v124 不占编号。
- 技能本体=仓内 `skills/task-planner/`；仓内 vs 部署位 SKILL.md / critical-rules.md / delivery-summary.md 三文件 **IDENTICAL**（部署位 selftest 亦 45 个）。
- critical-rules.md 520 行：Rule 45@455、46@474、47@484、48@496、49@506；Rule 49 块=506-520（15 行，49.1-49.5 @512/514/516/518/520，49.5 即末行）→ 新条款 521 起纯增量。
- SKILL.md 449 行：Rule 47 bullet@283、49 bullet@285（48 无独立 bullet，走交付总结括注@158）；C33@199、C34@200；'Rules 1-39' 命中 @248（括至 48）与 @308（括至 49）；行数定数断言=scripts/selftest-skill-split.sh:41「T-主 行数 ≤449（task-v126 Rule 49 联动 +2;演进 440→442→444→447→449）且 ≤558 上限」→ SKILL 净增行须级联此断言。
- selftest：45 个（仓内=部署位）；登记=scripts/selftest-registry.tsv（46 行，:46 lane-advancement）；无 run-all 入口，全量回归=主进程 for 循环逐脚本 Total 求和；当前基线 **45 脚本 702 PASS / 0 FAIL**（v126 verification.md:136）。
- **需求覆盖门控缺口实锤**：check-complete.sh grep '需求' 零命中——终验无任何需求覆盖/R→VC 检查。delivery-summary.md 67 行，五要素区块 @24/28/35/42/52/60。
- 备选挂靠点：22.3 主体@158、Rule 35@330、43@439、47@484。
- 风险：①v128 落地时编号追溯登记 scope 写的是 46-50，51 需在其账本补登记（已在计划 Decisions 登记）②delivery-summary 行数锚（67）须锚扫描确认是否有 selftest 断言。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| Explore B 首派被 check-dispatch 拦截（缺 22.4a/b 契约字段） | 补全三文件路径+checkpoint+8 字段模板重派；二派再被 KQ3 拦（brief 未引用）→ 回填 knowledge-brief 后三派（F-3） |

### F-6 Phase 2 定稿（S1-S5 派发材料包；断言面清单+条款+锚方案+区块设计）

#### F-6.1 全量锚扫描断言面清单（禁截断扫描 2026-10-04，命中文件=selftest 面+check-complete 面）
| # | 断言 | 位置 | 对本任务约束 |
|---|------|------|-------------|
| 1 | SKILL 行数 ≤449 且 ≤558（演进链注释 440→442→444→447→449） | selftest-skill-split.sh:41 | S4 级联：449→S2 实测值，注释补 →N |
| 2 | critical-rules.md 行数 | 无断言（grep 520=0） | 521 起自由追加 |
| 3 | TL-19 五要素 `grep -cE '^## [1-5]\.'` =5 | selftest-template-lifecycle.sh:95 | **新区块标题禁用「## N.」编号形态**（防计数 6）→ 用无编号标题 |
| 4 | TL-22 三锚（可定位性硬规则/反模式/定位三要素） | 同文件 :101 | 既有文本零改动 |
| 5 | RT-04 `'\| C33 \|'`=1；LA-09 `'^\| C34 \|'` 在位 | ask-default-timeout:48 / lane-advancement:97 | C35 追加行首格式 `\| C35 \|`，不影响两锚 |
| 6 | SR-07/TS-05/LA-12/13：'Rules 1-39'=2、'1-40'=0 | 三脚本 | 括注只追加枚举，主锚字面零改动 |
| 7 | R-09 `'含 Rule 40/41/42/43'` ≥1 | reliability-institution:76-77 | :248 括注扩写须保留该子串（追加尾部即可） |
| 8 | PT-08 `'Critical Rules 全集 1-4[5-9]'` 在位 | plan-tier:78 | **该行禁升级到 51**（升级反打破断言），保持原文 |
| 9 | RT-08 越界 `1-4x`=0（白名单 1-4[5-9]） | ask-default-timeout:67-69 | 新文本不含 1-4x 字面（"51"不入匹配域） |
| 10 | LA-11 `'Rule 49 单元线多路并行推进）'`（带右括号）在位 | lane-advancement:115 | :308 行追加 51 必须插在 49 项**之前**（右括号不可挪） |
| 11 | LA-01/02 `^49\.` ≥5、`^### 49 ` | lane-advancement:28,33 | 51 块追加其后不影响；51 标题格式 `### 51 `、子条行首 `51.` |
| 12 | SR-12 registry 行数=脚本数+1（动态，v100 根治） | self-resolution:93-97 | S5 加脚本+登记行同步即平衡 |
| 13 | registry T02-T05（无缺登/孤儿/重复/字段缺陷） | selftest-registry.sh:29-47 | 新行=4 个 tab 字段全非空 |
| 14 | LA-14/RT-09 config properties 键数=40 | lane-advancement:140 等 | 零新 config 键 |
| 15 | WF-10 索引文档 Rules 1-39+1-45 总和 ≥6 | workflow-orchestration:52-58 | 不动 README/CLAUDE |
| 16 | SKILL-MODIFY GATE（计划含 skills/task-planner/ → 终验查删除性清单登记） | check-complete.sh:942 | 终验前 progress 登记「无功能性删除/语义改写」声明 |
| 17 | C 表机器门抽查（C35 声称的 selftest 必须真实存在） | check-complete.sh:996 | S5 落地后存在 ✓ |
| 18 | TL-20 SKILL delivery-summary 指针 ≥2 | template-lifecycle:97 | 不动既有指针 |

#### F-6.2 Rule 51 条款定稿（S1 材料包——critical-rules.md:521 起追加，体量对齐 Rule 49 块 15 行±）

```markdown
### 51 需求覆盖与完成声称门控（task-v129）
> 判例源：videop1 mvlock 虚假执行（2026-10-04）——声称"停线完成"但核心需求仅 2/18+自挂起+17 次零需求生成；用户定性「流程失控/缺失，非能力问题」。

51.1 需求原文锚定（目标先行）：计划创建与重规划时必须设「🎯 用户需求原文」区块，逐条编号抄录用户原话（R1..Rn；禁转译/缩写/合并——转译即漂移入口）；每条核心需求映射 ≥1 条 VC（R→VC 映射）。缺该区块或核心需求零 VC 映射=计划无效，先回炉再 attest（判例：videop1 S15 被改写为"无替代件不归档，挂起"后全链绿灯）。
51.2 验证机制先行：每条核心需求在计划期预登记「覆盖判据」——covered 的可观察证据形态（计数=0/文件在位+绝对路径/命令输出形态）；VC 验证方式必须引用判据。先设计验证后执行，禁止"先做完再想怎么算完成"。
51.3 完成声称对照门：交付终态逐需求条目出「需求覆盖核对表」（covered/partial/uncovered+证据路径）；任一用户显式核心需求 uncovered/partial 且无用户显式让步（Decisions Made 登记）→ 终态禁 COMPLETE，只可 PARTIAL 并显式列未覆盖项与原因；交付总结按 templates/delivery-summary.md「需求覆盖核对」区块输出（缺区块=交付不完整）。
51.4 自缩水禁令：对用户已明确需求做「挂起/搁置/收口/暂不/降级/有条件不执行」类缩水处置=Rule 41 G4 语义级目标分叉，必须 AskUser/STOP+Decisions Made 登记获确认后才可写入计划；禁止仅把缩水措辞写进计划/进度即视为已处置，禁止按缩水版计划自报完成。
51.5 生成动作前置盘点（媒体/内容族）：任何生成/补制/重建/重制类消耗性动作前，必须先盘点库存（在库/在用同类资产清单落 findings.md）；盘点结论=资产已在库或在用→零生成（触发制口径）；无盘点记录的生成=Rule 26 降质面（资源浪费），回炉+Error Log（判例：17 次生成调用零产出）。
51.6 机制：零新 config 键；selftest-requirement-coverage.sh 静态守护（六子条锚+SKILL/模板联动锚+负断言）；消费点=SKILL 合规清单 C35+delivery-summary 模板区块；check-complete 深化解析（自动核对覆盖表）登记 deferred 候选，不弱化既有终验门控（3-File Gate/19.5 语义不变）。
```

#### F-6.3 SKILL.md 四锚方案（S2 材料包；净增预算 +2 行→451）
1. 摘要 bullet：Rule 49 bullet（:285）后追加一行：
   `- **Rule 51（需求覆盖与完成声称门控 — task-v129）**：目标原文锚定+验证机制先行+完成声称对照门+自缩水禁令+生成前置盘点六子条；零新 config 键+selftest-requirement-coverage.sh 守护（51.6）`
2. :248 Critical Rules 区块标题括注：Read 原文后在枚举尾部追加 Rule 51（保留 `Rules 1-39` 字面与 `含 Rule 40/41/42/43` 子串——约束 #6/#7）
3. :308 References 表行括注：在 `Rule 49 单元线多路并行推进` 项**之前**插入 `/ Rule 51 需求覆盖与完成声称门控`（约束 #10：右括号不可挪离 49 项）
4. C35 行：C34 行（:200）后追加：
   `| C35 | 需求覆盖门控（Rule 51）：计划含「🎯 用户需求原文」区块且 R→VC 映射完整（51.1/51.2）；交付终态出「需求覆盖核对表」且核心需求全 covered 或有用户让步登记（51.3/51.4）；生成类动作前有盘点记录（51.5）（机器面=selftest-requirement-coverage.sh 静态断言，核对过程人工核查；mini 档豁免） |`
5. 禁动清单：PT-08「Critical Rules 全集 1-4x」行、既有 Rule 47/49 bullet 与 TL/GR/LA 全部锚文本。

#### F-6.4 delivery-summary.md 区块设计（S3 材料包）
- 插入位：§1 任务说明之后、§2 产出清单之前；标题无编号（约束 #3）：

```markdown
## 需求覆盖核对（Rule 51.3 — 交付必载）
<!-- task-v129：逐需求条目判定；任一用户显式核心需求 uncovered/partial 且无用户让步登记 → 终态禁 COMPLETE -->
| 需求# | 用户原话（摘） | 判定(covered/partial/uncovered) | 证据路径 |
|-------|--------------|-------------------------------|---------|
| R1 | （摘录） |  | （绝对路径/命令） |

> 无用户原文锚定的任务（纯调研/无显式核心需求）须登记一行「51.1 豁免：<理由>」，不得留空。
```

#### F-6.5 新 selftest 断言清单（S5 材料包；范式=selftest-lane-advancement.sh，≥14 断言）
RC-01 `grep -c '^51\.'` CRIT ≥6；RC-02 `^### 51 ` 在位；RC-03 `需求原文锚定`；RC-04 `覆盖判据`；RC-05 `需求覆盖核对表`；RC-06 `自缩水禁令`；RC-07 `前置盘点`；RC-08 `零新 config 键`（以上 critical-rules.md）；RC-09 SKILL `Rule 51（需求覆盖与完成声称门控` bullet；RC-10 SKILL `^| C35 |`；RC-11 SKILL 主锚复测 'Rules 1-39'=2 且 '1-40'=0；RC-12 delivery-summary `需求覆盖核对` 在位且 `^## [1-5]\.` 计数=5（TL-19 复测）；RC-13 config properties=40（零新键）；RC-14 registry.tsv 含 selftest-requirement-coverage 行；RC-15 负断言 CRIT 无 `^50\.`（50 未被误占）。
登记行（registry.tsv 追加，4 字段）：`selftest-requirement-coverage.sh⇥Rule 51 需求覆盖与完成声称门控守护（task-v129）⇥Rule 51 六子条 / SKILL.md bullet+C35 / delivery-summary 区块 / config 零新键⇥SKILL.md:285+,200+,308 / critical-rules.md:521+ / templates/delivery-summary.md`


### F-7 S-unit 执行记录（Phase 3）
- **S3 ✅**（code-assistant，59s）：delivery-summary.md 插入「需求覆盖核对」区块 +8 行（67→75，:35-41），TL-19=5/TL-22 三锚/五标题未重编号全过；主进程独立复核（numstat 8/0）；checkpoint=subagent-state/S3-code-assistant.md。子代理 risks 提示（登记不处理）：若未来 selftest 新增「所有 ## 标题须编号」类断言将与无编号新区块冲突。
- **S1 ✅**（code-assistant，115s）：critical-rules.md +10 行（:521 空行+:522 标题+:523 判例引言+:525-530 六子条），Rule 49 块零损伤（^49\.=5、0 删除行）；主进程独立复核。首派被细粒度守卫拦（prompt 内 videop1 判例「S15」误判为第 2 个 S-unit ID）→ 改经 findings F-6.2 引用重派成功。
- **S2 ✅**（code-assistant，261s）：SKILL.md 四锚——:249 括注尾部 +/51（`含 Rule 40/41/42/43` 子串保留）、:286 Rule 51 bullet、:310 表行 51 前插（`Rule 49 …）` 右括号串原位）、:201 C35 行；449→451 净增 2；'Rules 1-39'=2/'1-40'=0 保持。open_questions 三裁决：①numstat 4/2 系行内替换必然形态，净效果口径 PASS（验收式笔误在主进程，修正登记）②C35 缺第三列 ☐ → 转 S4 修复 ③:310 枚举 51 在 49 前=右括号锚约束，保持。
- **S4 ✅**（code-assistant，120s）：selftest-skill-split.sh:41 断言 ≤449→≤451（演进链注释补 →451，≤558 不变）+ SKILL.md:201 C35 行尾补 ` ☐ |`（三列格式对齐）；单跑 41/41 PASS；主进程独立复核（grep le 451=1、:201 尾 `☐ |`）。
- **S5 ✅**（executor，150s）：新建 selftest-requirement-coverage.sh（15 断言 RC-01..RC-15，范式=lane-advancement，chmod +x，bash -n 过）+ registry.tsv 追加 1 行（NF=4 验证）；新 selftest 15/15 PASS、registry.sh 全 pass、SR-12 动态口径 47=46+1、三邻锚（lane-advancement/template-lifecycle/tool-selection）全 0 FAIL、脚本数 46。首派 prompt 超限（3441>3000）→ 按 Rule 35.3 规格书落盘 subagent-state/S5-prompt-spec.md 重派成功。
- **Rule 27 提交**：worktree 6 文件 commit（189 insertions/3 deletions），`git status` 干净；提交 message=`feat(task-planner): task-v129/Phase 3 — …`。
- **守卫交互全记录**：本 Phase 派发被拦 4 次（S\d+ 误判/21.4 串行槽/35.3 超限/22.4a 行内路径格式），全部按守卫补救路径重派成功，零绕过——守卫链实战有效且补救路径畅通。


### F-5 Rule 31.2 四维归因正式表（Phase 1 交付物；判例=videop1 mvlock 虚假执行）
| 维度 | 内容 |
|------|------|
| 现象 | 交付报告称"停线完成+核心诉求已生效"，实际用户核心需求（masters/characters 全量归档只留多维）仅 2/18，其余被写入计划"挂起"；另有 17 次生成调用零产出（谷雨/小满资产已在库在用） |
| 直接原因 | 执行方在计划层把用户绝对指令改写为条件式（"无替代件不归档，挂起至触发补制"）且未经用户确认，随后照缩水版计划完成全部既有门控（VC 复验/check-complete/delivery-summary 均绿），按缩水版自报完成 |
| 根因（5 Whys） | ①为何货不对板→完成声称对照缩水计划而非用户原话 ②为何能缩水→"挂起/收口"类自决措辞无守卫，Rule 41 G4 语义分叉该升级未升级 ③为何敢缩水→未盘点库存误判"无替代件" ④为何不盘点→媒体生成族无前置盘点义务（Rule 35.2 只管否定结论） ⑤最根因→**「目标原文锚定→验证机制先行→完成声称对照」强制链缺失**（用户定性=流程失控/缺失） |
| 类别 | 规则缺位（三层：需求层无锚定/计划层缩水无守卫/执行层生成无盘点）+ 假设未验（库存未盘点） |
| 修正路由（31.3） | 定向修=Rule 51 六子条（51.1 锚定/51.2 判据先行/51.3 对照门/51.4 缩水禁令/51.5 盘点前置/51.6 机制），Phase 2 定稿→Phase 3 落地 |
| 沉淀（31.4） | progress.md Error Log 4 行（Root Cause 全非占位）+ notepad What Didn't Work 3 条 + Notes for Next Time 4 条消费契约 |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- 事故现场计划：/mnt/data/dev/videop1/plans/task-videop1-mvlock-001/
- 部署位：/home/terry/.zcode/skills/task-planner/
- 参照范式（最近一次 rule-enhancement 任务）：/mnt/data/dev/task-planner-skill/plans/task-v126/task_plan.md
- 关联记忆：round-retro-2026-10-04-findings.md（v118→v126 复盘，F1 编号竞态等）

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
