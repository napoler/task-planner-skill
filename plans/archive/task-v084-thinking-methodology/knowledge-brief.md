# Knowledge Brief — task-v084 思维方法论（任务知识简略要点）
> 定位：执行期稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由主进程产出，执行期回填。

## §1 任务速览与核心概念
- 任务一句话：methodology.md 新增 §思维方法论 T1-T5（问题先行/解构四问/金字塔/逐步推导/消费点）+ SKILL 三处联动 + plan-writer 契约行 + selftest M-12..16 + CHANGELOG，全量 0 FAIL 后合并部署 push
- 背景/动机：用户 2026-09-18 思维纪律「解决问题前先思考问题；多问为什么；问题→本质→方案→执行；5 Whys+金字塔原理；不走弯路事半功倍」

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| T2 解构四问 | 问题是什么→本质是什么（5 Whys ≥5 层）→解决方案是什么（候选+取舍）→执行方案是什么（步骤化+门控） |
| 同法不同时 | T2（问题侧，动手前）与 Rule 31.2/R4（错误侧，失败后）用同一 5 Whys 但时机不同，交叉引用不重复定义 |
| 金字塔原理 | Minto：结论先行/以上统下/归类分组（MECE）/逻辑递进 |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响 |
|------|---------------------|------|
| methodology.md=177 行，R1-R4+Q1-Q5，每条五字段（方法名/出处/触发场景/可操作动作/映射/惩罚/开关键） | references/methodology.md:1-177 | T 条款照五字段范式写 |
| R4 已含 5 Whys（失败侧根因链，≤5 层） | methodology.md:69-88；critical-rules.md:256（31.2 触发） | T2 交叉引用防双定义 |
| 定位声明"9 条可操作方法论"字样 3 处+守护/落点行 | methodology.md:3,13,170,173,174 | 机械联动改 14 条（grep "9 条" 全仓核对） |
| selftest-methodology=11 断言 hermetic（fixture 镜像+M-03 关键词 ≥9 加法兼容+M-06 SKILL ≥3） | scripts/selftest-methodology.sh:1-177 | 追加 M-12..16 不动既有；fixture 需补 cp plan-writer.md |
| SKILL 指针三处：L81 Poka-Yoke §R1/R2 / L161 内容质量 / L297 Methodology 指针行 | SKILL.md | 行内×2+新增 bullet（净增 ≤2，≤548） |
| plan-writer 产出契约表 L116 knowledge_brief 行 | companion/agents/plan-writer.md:116 | 四问契约行插其后 |
| v083 全套先例存活：接管路由/hermetic 扩展/委派门关键词口径 | plans/task-v083-batch-pilot-first/ | 照抄 SOP；P2/P3 接管理由文本须含「白名单⑤」「兜底接管」 |
| 本会话 code-assistant(haiku) 2 连败、code-runner(mini) 存活 | v083 Handoff 表 | P2/P3 直接 ④ 接管不盲试；P4 派 mini |
| config 仅 fmea/content_quality 两方法论键；零 batch 键 | config.json | 零新键（M-01/02/07 不触） |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要 |
|------|------|-----------|
| references/methodology.md | :3,5,13 | 定位声明/开关键/防护描述（9 条→14 条联动点） |
| references/methodology.md | :88-90 | §可靠性末尾（§思维方法论插入位，§内容质量之前） |
| references/methodology.md | :165-174 | 与 Rule 1-28 关系表（落点行/防护行联动） |
| skills/task-planner/SKILL.md | :81 | Poka-Yoke 行（指针扩 §思维方法论，行内） |
| skills/task-planner/SKILL.md | :83 后 | 共享内容追踪检查点之前（新增思维解构 bullet 位） |
| skills/task-planner/SKILL.md | :297 | Methodology 指针行（行内补 5 条） |
| companion/agents/plan-writer.md | :116 | knowledge_brief 契约行（四问行插其后） |
| scripts/selftest-methodology.sh | :70-100 | M-03..M-07 段（M-12..16 追加于 M-11 后） |

## §4 易错点与禁止假设清单
1. 纯增量铁律：R1-R4/Q1-Q5 既有行零改写；git diff 只许 `+` 行+机械联动行
2. "9 条"字样 4 处（L3/L13/L170/L174）必须联动"14 条"，漏一处=守护文本自相矛盾；selftest 注释 L7 同步
3. SKILL 净增 ≤2：只许 bullet 新增，行内改不增行；wc 终态 ≤548（现 543）
4. M-03 断言=关键词 ≥9 加法口径，T 关键词不触它；新断言勿用「=9」硬计数
5. T2 禁重复定义 5 Whys：写"同法不同时+见 31.2/R4"，禁另立层数口径冲突（31.2 为 ≤5 层，T2 用 ≥5 层追问？——对齐取"≥5 层或至不可再分层，对齐 31.2 上限语义"写法防冲突）
6. plan-writer 契约行插 L116 后保持表格管道转义；hermetic fixture 补 cp plan-writer.md 路径
7. 派发 prompt 8 字段标签+三文件路径；接管理由文本含「白名单⑤」「兜底接管」（check-complete 委派豁免 grep 口径，v083 教训）
8. active_plan sid 指针异常→全程显式路径传参；守卫 warn 假阳性不阻断（v080 先例）
- FMEA RPN>100 兜底指针：无（最高 60=P2 联动漏改，兜底=grep "9 条" 全仓审计；→ task_plan FMEA 表 P2 行）

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1 | §1+§2+§3+§4 | plans/task-v084-thinking-methodology/findings.md §条款定稿+§联动清单 |
| S2 | §3+§4 | findings.md §SKILL 联动 |
| S3 | §3+§4 | findings.md §契约行 |
| S4 | §2+§3+§4 | findings.md §断言清单 |
| S5 | §2 | findings.md §CHANGELOG 草稿 |
