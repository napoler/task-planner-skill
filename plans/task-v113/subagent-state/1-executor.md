# Checkpoint: 1-executor — Phase 1 消解链影响面普查（task-v113）
status: done

## 里程碑
- [2026-10-02 T1] 已读 task_plan/findings/progress/knowledge-brief + 宪法 §七
- [2026-10-02 T2] 第一部分（现行链拆解）完成——证据 critical-rules.md:158/159/160/167-168/24 + reference.md:226-233
- [2026-10-02 T3] 第二部分（引用面 grep）完成——13 文件含 22.3/41.1/五档；selftest 断言锚定位
- [2026-10-02 T4] 第三部分（宪法落差）完成——AGENTS.md:127 vs 22.3 无资料档
- [2026-10-02 T5] 第四部分（修订方案）写入——最终结论段

## 第一部分 现行链拆解（全部引用 critical-rules.md 除非注明）

22.3 五档（critical-rules.md:158）逐档语义与触发：
- ① 改派：失败=subagent 类型不匹配 → 换更合适 subagent_type；SKILL.md:389 表行 1
- ② 拆细：子任务触及 21.1b 步级上限（>2 文件/>100 行/预估 >15min）或超时 → 回计划层拆更小 S-unit 重派，不改模型档位；每子任务限 1 次；SKILL.md:390 表行 2
- ③ 降档：类型对且已拆细仍失败（能力不足）→ 升一档 model（haiku→sonnet→opus）；SKILL.md:391 表行 3。术语注意：条款内「降档」实指模型升档（档位上移），SKILL.md 表述为「降档=升一档 model」
- ④ 主进程接管：单文件 ≤300 行、目标明确、可独立验收；须按 25.3 登记白名单⑤；SKILL.md:392 表行 4
- ⑤ AskUserQuestion：前四档全失败或需用户决策；SKILL.md:393 表行 5
- 附加约束：达 config.json#subagent.retry_limit（默认 2）→ 必须 AskUser，禁同法重试（:158 行内）；理念=「任务太大/上下文太长」优先假设

22.3.1（:159 行首）provider 失败主动 Scaling：provider/网络类失败（ECONNREFUSED/other side closed/400 rejected/Headers Timeout，日志 model.network.failed）→ 先 ①-fb：subagent-fallback.sh probe 预检 → next 取健康 fallback → bind 生成 <type>-fb 变体 agent，零消耗改派不计 retry_limit；边界=变体 agent 会话启动固化、当前会话不可见；无健康通道 → 22.3 ④/⑤；连续 2 通道全灭 → 22.7 STOP。
22.3.2（:159 行内后半，与 22.3.1 同物理行——编号在行中）provider 全灭挽救档：任务超 ④ 上限（单文件 ≤300 行）→ 先回计划层拆细到每片 ≤300 行单文件再逐片 ④ 接管；仍无法接管部分登记未完成清单降级交付，禁裸 BLOCKED。
22.3.3（:160）协同技能接管评估：位于 ④ 与 ⑤ 之间；④ 不可行（超 300 行且 22.3.2 拆细后仍无法接管）或 ④ 仍失败 → 先评估专业技能族接管（comet / openspec-propose / superpowers 系），CLI 探针前置（command -v）；接管失败才允许 ⑤ AskUser。
子条边界：22.3.1/22.3.2 管 provider 面；22.3.3 管技能族接管面；三者都不含「查官方文档/查网络现成方案」动作——与资料档无编号冲突但 22.3.0 新号与 22.3.1 序号相邻需注意 selftest T4 行号序断言。

Rule 41.1 消解优先链（:415）逐项：① 重读计划三文件对齐目标 ② 22.3 ①-④ 兜底链全试 ③ 最小探针复测（35.6）④ 问题拆细（大失败拆可独立消解小失败逐个击破）⑤ 替代路径检索（35.2 三关=通读完整接口面/CRUD 一致性推断/替代路径）。升级=最后手段非默认出口；「停点成本低于消解成本」列为反模式。
41.4 升级前置消解清单（:418）：任何 AskUserQuestion/STOP 前必须过清单①-⑤（同 41.1 五步），升级消息必附「已尝试清单」（逐条已试动作+结果），缺失=violation；D6 硬停点语义保留不弱化（触发前先执行清单可自动部分）。

Rule 7 三击（critical-rules.md:23-24）：action_failed: next_action != same_action，指针 → reference.md §三击协议（reference.md:226-233）：第 1 次诊断+修复；第 2 次换方法（不同工具/库，绝不重复完全相同失败操作）；第 3 次全局重想（质疑假设/搜索方案/考虑更新计划）；3 次后升级用户。既有换道语义边界：Rule 7 管「同法不重复」通用纪律（所有失败动作）；21.4 失败兜底链（critical-rules.md:149）管「同一子任务失败 ≥2 次 → 禁止同法重试（联动 Rule 7），回计划阶段重拆或升级 Complex Problem Solver」；22.7（:167）管「连续失败 ≥2 次必须换档重试（跳过已失败档位），穷尽 ①-④+22.3.3 才 STOP」；22.7.1（:168）STOP 上报 6 字段含已尝试档位清单。重叠区=「失败 ≥2 次触发换道」在三处都有：Rule 7（行为面）、21.4（派发面 ≥2 次禁同法）、22.7（子代理面 ≥2 次换档）——新换道义务应以引用化（21.4 行 + 22.7 行加指针）不重复定义。

## 第二部分 引用面（skills/task-planner 内，plans/ 除外，grep 实测 2026-10-02）

含「22.3/41.1/五档」文件全集（13）：README.md / SKILL.md / scripts/{selftest-skill-collab,selftest-reflect-verify,selftest-methodology,check-rescue-chain,selftest-fallback,subagent-fallback,selftest-conclusion-discipline}.sh / lib/verify.sh / references/{completion-gate,dispatch-examples,critical-rules}.md / templates/task_plan.md。「41.1」字面仅在 critical-rules.md:415（条款本体）与 SKILL.md:278（摘要行「41.1」）。

逐处 file:line + 语义 + 硬锚/文档分类：
- references/critical-rules.md:149（21.4 失败兜底链：首次失败评估 ②/③，≥2 次禁同法联动 Rule 7）— 文档，改法=加换道评估顺序指针
- :158（22.3 条款本体五档）— 硬锚（多处 grep 断言定位 `^22\.3 `），五档→六档演进标注
- :159（22.3.1+22.3.2 同物理行）— 硬锚（selftest-skill-collab.sh:44 `^22\.3\.1` grep）
- :160（22.3.3）— 硬锚（selftest-skill-collab.sh T4/T5）
- :167-168（22.7/22.7.1 穷尽集合 ①-④+22.3.3）— 硬锚（selftest-skill-collab.sh:48 `^22\.7 ` 行 grep）；改法=穷尽集合文案加资料档
- :206（25.6 失败联动「按 Rule 22.3 兜底顺序」）— 文档指针
- :256（28.2 D3「22.3 链走到 ③ 降档前」）— 文档，若编号不变则零改动
- :312（33.4 超限按 22.3 升档/拆细）— 硬锚（selftest-reflect-verify.sh:40 grep `^33\.4 ` 含 'Rule 22.3'）
- :386（Rule 39 dynamic-workflows 表行「失败换档/修复续做（Rule 22.3 ①-⑤ / 22.7）」）— 文档
- :411/:413/:415/:418/:420（Rule 41 本体）— 硬锚（selftest-self-resolution.sh SR 系列）；41.1/41.4 扩档点
- :422/:424/:430/:435/:437（Rule 42/43 段「既有 22.3…原文零改动」声明）— 若改 22.3 本体，这些「零改动」声明需评估是否同步（它们指 Rule 42/43 自身不改动 22.3，历史性表述，建议保留原文加演进标注而非改写）
- SKILL.md:36（白名单⑤「Rule 22.3 兜底接管」）— 文档
- SKILL.md:46（22.3.3 卡壳接管指针）— 文档
- SKILL.md:197（C31 行「失败先 22.3 升档」）— 文档
- SKILL.md:221（Rule 33 段「超限按 Rule 22.3 升级」）— 文档
- SKILL.md:278（Rule 41 摘要行，含 41.1 消解链=重读计划→22.3 ①-④ 兜底→最小探针→拆细→替代路径）— 硬锚（selftest-self-resolution SR-06/SR-10 关联）；改法=摘要行同步扩档
- SKILL.md:280（Rule 43 摘要「失败先 22.3 升档」）— 文档
- SKILL.md:312（权威源表 22.3.3 卡壳接管行）— 文档
- SKILL.md:385（「**五档兜底(优先级顺序,Rule 22.3…)**」+ 387-393 表）— 改法=「五档」→ 演进标注（六档含资料档 or 维持字面加演进注）；最小改法=标题行加「（含 22.3.0 资料档演进）」注，表体不动
- SKILL.md:406（反模式行「违反 Rule 7 三击协议 + Rule 22.3」）— 文档
- SKILL.md:411（Provider Scaling 段，引用 22.3.1/22.3.2）— 文档
- README.md:143（config 表 subagent 行「Rule 22.3」）— 文档
- templates/task_plan.md:261（「对齐 Rule 22.3 五档兜底链」WHY 注）/ :266（「对齐 22.3 ①-⑤」列头）/ :270（「走 22.3 哪一档」填写规则）/ :379-380（Handoff 表注 22.3.1/22.3 retry_limit）— 文档；:261 字面「五档」需演进标注
- references/completion-gate.md:30（「按 Rule 22.3 兜底（拆细先于升档）」）— 文档指针
- references/dispatch-examples.md:33（「已尝试档位清单(22.3 ①-④ 与 22.3.3 逐档)」）— 文档；若资料档入穷尽集合则 22.7.1 ②字段与该行需同步
- scripts/subagent-fallback.sh:24/29/266/273/288/300（hint 串：全序「①改派→②拆细→③降档→④主进程接管→22.3.3 技能族接管评估→⑤AskUser」、tier_order 6 项）— 硬锚（selftest-skill-collab.sh T6/T10 精确串断言）；改法=若资料档入 hint 全序须同步 T10a 精确串断言（selftest-fallback.sh:125）
- scripts/lib/verify.sh:248（「config.json missing .properties.provider_fallback (Rule 22.3.1)」文案）— 硬锚（verify 断言文案）
- selftest-rescue-chain.sh：hermetic 夹具自测 check-rescue-chain.sh，无 22.3 字面断言（grep 22\.3 零命中）；check-rescue-chain.sh:5 注释「五机械档+22.3.3 评估档」=文档注释，改法=注释加演进注或不动（历史注释）
- selftest-fallback.sh:74/77/125/137（T02c/T10a/T11c 精确串）— 硬锚
- selftest-conclusion-discipline.sh:11/68-69（CD-13 注释「五档兜底引用注」，断言本体 grep 'Rule 35.3 大输入落盘引用' 不含「五档」字面）— 注释级，改法=注释同步可选
- selftest-skill-collab.sh:44-48（T4 行号序 22.3.1<22.3.3<22.4 + T5 22.7 行文案）— 硬锚；插入 22.3.0 在 22.3 行（:158）之前/之内不影响 T4（T4 只比 22.3.1/22.3.3/22.4 相对序，22.3.0 无断言引用）——若新号 22.3.0 落在 22.3 行与 22.3.1 行之间，`^22\.3\.0` 不违反 T4
- selftest-methodology.sh:160（sed 注入夹具「按 22.3② 拆细重派」）— 硬锚（夹具文案，不动 ② 语义则零改动）

## 第三部分 宪法落差确认

宪法 /home/terry/.zcode/AGENTS.md:127 原文：「**核心原则**：遇到问题第一动作是上网查资料，不是本地瞎猜反复试错。执行前至少 1 次调研；工具失败 ≠ 任务失败，穷尽 ≥3 种策略。」§七 路由表（:129-141）另定「工具失败/查报错 → 搜报错文本 / 本地历史」「编程库文档 → Doc Search Agent」「GitHub/PyPI/npm → 官方 CLI+镜像」。
落差陈述：宪法把「上网查资料」立为遇到问题第一动作（先于本地试错），并要求穷尽 ≥3 种策略；skill 执行层 22.3 五档（改派/拆细/降档/接管/AskUser）+ 41.1 消解链五步（重读/兜底/探针/拆细/替代路径检索）中，「替代路径检索」仅引用 35.2 三关（通读本地接口面/CRUD 推断/本地变通方案），无任何「查 help/man/官方文档/网络现成方案（research-assistant/Doc Search Agent/web-search）」动作——35.2 的「通读 --help 全文」是查文档面但限定在本地接口面通读，未覆盖官方文档/网络方案借鉴。结果=机制缺位导致「网络查资料兴趣低」（用户 2026-10-02 实证），且与宪法「第一动作」优先级冲突：宪法要求查资料先行，skill 链将其完全缺省。

## 第四部分 修订方案

### 4.1 资料档条款草案（建议名「资料先行档」，编号 22.3.0）

```
22.3.0 **资料先行档（research-first rescue，task-v113，用户裁决 2026-10-02；宪法 §七「调研驱动」执行层落点）**：
工具持续报错或同一方法/档位连续失败（≥2 次，联动 Rule 7 三击第 2 击「换方法」与 21.4/22.7 失败计数）时，进入下一 22.3 档位或 22.3.3 技能族接管前，先走资料档两步——
第一步 本地帮助面：查工具 help（--help/-h 全文，非试错式单 flag 探测）/man 页/项目官方文档与 README（工具/库/框架报错文本逐条查，禁止凭训练记忆或单次失败下断言——35.2 三关①适用）；
第二步 网络现成方案：research-assistant（多源）/ Doc Search Agent（官方文档）/ web-search（报错文本检索，GitHub issue/PR 优先）检索同类失败既有解法，评估借鉴后回入既有档位执行（借鉴结果按 19.1 落 findings）。
衔接声明：本档=宪法 §七「遇到问题第一动作是上网查资料…穷尽 ≥3 种策略」的执行层机制化落点；与 35.2/35.6 分工——35.2 管「能力否定」查证面、35.6 管探针最小化，22.3.0 管「失败换道」的资料检索动作序；22.3.1/22.3.2/22.3.3 各档在触发前提「已评估本地帮助面与网络现成方案」时引用本档而非重述动作（引用化，零重复定义）。
```

### 4.2 换道义务草案

```
22.3.0b（或并入 22.3 行尾 + 21.4 行尾指针）换道义务（anti-stall，task-v113）：同一方法/档位失败 ≥2 次 = Rule 7 三击第 2 击强制换道——禁止第 3 次同法；换道评估顺序（按序先命中先用）：① 资料先行档现成方案（22.3.0）② 子代理隔离（换 subagent_type 即 ① 改派语义内「换更合适类型」优先读法，或派 Debugger/Explore 隔离上下文体）③ 拆解逐个击破（22.3 ② 拆细/21.1 拆 S-unit）。连续 3 次失败 = 禁止第 4 次同法 + 强制登记换道理由（Handoff 表 rescue 列 + progress.md Error Log 一行 [switch-path] 已试 N 次/换道理由/新路径）。
```
边界：Rule 7 保留为「不重复同法」通用纪律条款不动；21.4（:149）行尾加指针「换道评估顺序见 22.3.0b」；22.7（:167）穷尽集合文案「①-④ 与 22.3.3」扩为「①-④（含 22.3.0 资料档评估）与 22.3.3」；41.1 ⑤「替代路径检索」行扩为「⑤ 替代路径检索（22.3.0 资料先行档：官方文档/网络现成方案 + 35.2 三关）」；41.4 清单②③④⑤同步指针。全部为引用/扩句，无重复定义。

### 4.3 插入位置评估与推荐

方案 A 前置 22.3.0（推荐）：新号 22.3.0 独立行插在 :158 行之后、:159（22.3.1）之前。冲击面：selftest-skill-collab T4 只断 22.3.1<22.3.3<22.4 相对序，22.3.0 无既有断言引用，零硬锚冲突；「五档」字面（SKILL.md:385、templates:261、critical-rules:413）需加演进注「（22.3.0 资料先行档为前置评估动作档，五机械档序号 ①-⑤ 不变）」——不改编号体系、不改 tier_order 数组（subagent-fallback.sh 机械面保持 6 项，资料档=LLM 行为面动作不进 tier_order，与 41.6 零新 config 键范式一致）。
方案 B 重排编号（五档→六档，资料档=新①，原①-⑤ 顺移②-⑥）：冲击面=全部 ①-⑤ 字面引用（critical-rules.md:149/158/167/168/256/312/386/415/418 约 10+ 处 + SKILL.md:278/387-393 表 + subagent-fallback.sh hint 串 3 处 + selftest T10a 精确串断言 + dispatch-examples.md:33 + templates 3 处）= 15+ 处语义重映射 + 1 处硬锚断言改写（selftest-fallback.sh:125 精确 grep 串）+ 未来跨任务历史计划（plans/*/task_plan.md 既有 rescue 留痕「①改派:done」语义漂移）——否决。
推荐：方案 A（22.3.0 前置独立行 + 五机械档序号不变 + 「五档」字面演进注）。

### 4.4 级联清单（逐处 file:line + 改法，方案 A 口径）

1. critical-rules.md:158 行尾加一句：「任一档位连续失败 ≥2 次 → 先走 22.3.0 资料先行档评估换道（task-v113）」（不改 ①-⑤ 原文）
2. critical-rules.md:158 与 :159 之间插入 22.3.0 条款全文（4.1 草案）+ 22.3.0b 换道义务（4.2 草案）
3. critical-rules.md:149（21.4）行尾加：「换道评估顺序=现成方案（22.3.0）→子代理隔离→拆解逐个击破（22.3.0b）」
4. critical-rules.md:167（22.7）「22.3 ①-④ 档位与 22.3.3」→「22.3 ①-④（含 22.3.0 评估）档位与 22.3.3」
5. critical-rules.md:415（41.1 ⑤）「替代路径检索（Rule 35.2 三关）」→「替代路径检索（Rule 22.3.0 资料先行档+Rule 35.2 三关）」
6. critical-rules.md:418（41.4 清单）②③④⑤ 同步：「② 22.3 ①-④（含 22.3.0）全试」
7. critical-rules.md:413「Rule 22.3 已定义五档兜底链」→ 加演进注「（task-v113 扩 22.3.0 资料先行档后为六档语义，五机械档 ①-⑤ 序号不变）」
8. SKILL.md:385「**五档兜底…**」→「**五档兜底（含 22.3.0 资料先行前置评估，task-v113 演进）…**」；387-393 表体不动，表上/下加一行 22.3.0 动作说明
9. SKILL.md:278 Rule 41 摘要行「消解优先链=…→拆细→替代路径」→「…→拆细→替代路径（含 22.3.0 官方文档/网络现成方案）」
10. SKILL.md:406 反模式行加：「❌ 同法失败 ≥2 次第 3 次仍同法且不登记换道理由（违反 22.3.0b 换道义务）」
11. templates/task_plan.md:261「对齐 Rule 22.3 五档兜底链」→ 加「（task-v113 后含 22.3.0 资料先行档）」注
12. references/dispatch-examples.md:33「22.3 ①-④ 与 22.3.3 逐档」→ 同步 22.7.1 ②字段（critical-rules.md:168）「已尝试档位清单（22.3 ①-④ 与 22.3.3 逐档）」加 22.3.0 评估记录行
13. 零改动确认（不动清单，防过度级联）：subagent-fallback.sh 全部 hint 串/tier_order（机械面 6 项不含 LLM 行为面档位，selftest T10a 精确串保持全绿）/ selftest-skill-collab T4-T5 / selftest-methodology.sh:160 / selftest-rescue-chain.sh / check-rescue-chain.sh / verify.sh:248 / README.md:143 / completion-gate.md:30 / SKILL.md:36/46/197/221/280/312/411 / Rule 42-43 段「零改动」历史性声明（:422/:424/:430/:435/:437）
14. 断言面新增：selftest-self-resolution.sh 或 selftest-conclusion-discipline.sh 加 2-3 条静态锚（`^22\.3\.0 ` 行存在/「资料先行」≥1/换道评估顺序串≥1/零新 config 键维持 properties=40）；selftest-skill-collab T4 行号序扩展 22.3.0 < 22.3.1（可选，防误删）

## 最终结论（8 字段）

status: done
acceptance: 3/3 pass — ①四部分逐项结论 done（现行链/引用面/落差/方案全出）②修订方案三件 done（资料档 22.3.0 草案/换道义务 22.3.0b 草案/级联清单 14 项含插入位推荐=方案 A 前置 22.3.0）③检查点落盘含最终结论 8 字段块 done（本文件）
files: /mnt/data/dev/task-planner-skill/plans/task-v113/subagent-state/1-executor.md(+1/新建); /mnt/data/dev/task-planner-skill/plans/task-v113/findings.md(+1 小节); /mnt/data/dev/task-planner-skill/plans/task-v113/progress.md(+1 行)
evidence: critical-rules.md:158→「22.3 **失败兜底**…① 改派…⑤ AskUserQuestion」; critical-rules.md:415→「41.1 消解优先原则…⑤ 替代路径检索（Rule 35.2 三关）」; selftest-skill-collab.sh:44→「L_2231=$(grep -n '^22\.3\.1'… T4 行号序」; selftest-fallback.sh:125→「T10a hint 含全序(①改派→…→⑤AskUser)」; /home/terry/.zcode/AGENTS.md:127→「遇到问题第一动作是上网查资料…穷尽 ≥3 种策略」
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v113/subagent-state/1-executor.md (status: done)
findings_written: findings.md #### [sub:1-executor] 消解链普查
blockers: none
confidence: HIGH
