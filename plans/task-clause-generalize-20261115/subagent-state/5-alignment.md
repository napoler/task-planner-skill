# 5-alignment 检查点（alignment-review：新条款 vs 上位规范体系）

- 任务：task-clause-generalize-20261115（源仓 e4235af / 2afedb2；5 文件）
- 审查对象：94.7 v2（discipline:618）+94.5 衔接（:616）、51.14 v2（planner critical-rules:107）、64.7 v2（drift:68）+64.4 四锚（:63）、SKILL bullet（:229）、recall card A/B/E（:7/:14/:41）
- 对照基准：用户宪法 AGENTS.md §一/§二/§四/§五/§十三；Rule 95/74/8.1.1/64.2.1/51.3/51.8/53.3/41.2/88
- 方式：只读 + Grep 复现，未改任何文件

## verdict: DRIFT（0 CRITICAL / 5 IMPORTANT / 4 WARNING / 3 NIT / 1 QUESTION）

## 维度一 P0 层级一致性 — 部分通过

- 通过：94.7 停等映射 G2「范围越界」/28.2 D4 真门，95.5 明文允许真门停等；豁免线 G-1 正确指向 95.4④（专档原话裁决），可消解「有原话覆盖仍被门拦」的一侧互搏；未新增脚本/配置键（对齐宪法 §二 文本优先）。
- F1 [IMPORTANT] `skills/task-planner/companion/agents/drift-checker.md:36` — 唯一派发消费点仍是「判定输入三锚」，且构成与 64.4 不同（①=用户原话双源，缺 Goal 原文锚；原话被并入三锚而非第四锚）
  - 原文：「判定输入三锚（Rule 64.4，[task-v172 CA-7] 复合审查强化）：任务书必须内嵌 ① 用户原话锚=user-session-log.md 全部原话条目+task_plan.md R 条目双源」
  - 推理：64.4 要求「四锚…缺任一即不完整」且自述「配套：drift-checker agent 定义增补判定输入要求段（部署位随 Phase 5 同步）」，但本计划无 Phase 5（task_plan:439 仅为 Todo 表占位行），部署位承诺无落点 → 检查体按三锚自证合规，64.7 的 ④ 在原位失效
  - 置信度：HIGH
- F2 [IMPORTANT] `skills/task-discipline/references/critical-rules-discipline.md:618` — 94.7 停等门无 silent 档降级，与 28.4（除 D6 外按推荐项自主决策）及 28.2 D4 冲突；同 Rule 94 的 94.3 显式处理（:614「Rule 28 silent 档下本门不停摆」），94.7 缺同位句
  - 原文：「该扩批动作=B 类扩范围（Rule 74），必须停下复述…并等用户显式确认后才可继续」
  - 推理：silent/mini-silent 场景下 94.7 被字面读成无条件硬停，与 28.4 冲突，且与姊妹条 94.3 的处置不对称（同门不同档）
  - 置信度：HIGH
- F3 [IMPORTANT] `critical-rules-discipline.md:618` — 「范围上限不可判定时仍须停下复述范围描述」只引 95.4④，未引 95.1 执行即探测/95.0「有直推路径禁停」；判据②的基线（可推定范围）未要求先探测
  - 原文：「范围上限不可判定时仍须停下复述范围描述，禁自行推定 N」
  - 推理：对象数可经 Read/清单/计数直接取到时，停等属 95.0 定义的「非必要暂停」；本条把「不确定」整段转为门，正是 95.5 禁的形态（G-1 只解了「有原话覆盖」半边）
  - 置信度：HIGH
- F4 [IMPORTANT] `skills/task-planner/references/critical-rules.md:107` — 51.14 内部自相矛盾：「三要素齐备，缺一禁用」与「trivial 自述…免耗时项」互斥
  - 原文：「完成/交付类声称必须三要素齐备，缺一禁用「完成」措辞」/ 同行「单文件 ≤3 行 trivial 修改的自述可一行式（操作类型+覆盖 1/1），免耗时项」
  - 推理：同一 P0 行既禁缺③（实测耗时）又豁免③，执行体可两端取材；trivial 档缺③仍可称「完成」=对主句的例外未在前置句显式化
  - 置信度：HIGH
- F5 [IMPORTANT] `skills/task-drift-guard/references/critical-rules-drift.md:68` — 非 trivial 专档缺失无条件 BLOCKED，与 80.6 机器面双源定级不一致，且未先走 80.1 建档路径
  - 原文：「非 trivial 档专档缺失（文件不存在）与空/零条目同款按 64.1 留痕+🔴BLOCKED 升级处置」
  - 推理：80.6（critical-rules:155）对同一事实的机器面是「FAIL / env 降级 warn=告警不阻断（默认）」；80.1 明示 init 幂等建档 → 存在 95.1 直推路径（主进程按需建档回填当轮原话）却直接 BLOCKED，与 95.0/95.1 冲突，且未写两源优先级
  - 置信度：HIGH

## 维度二 管辖二分 — 基本成立，残余三处

- 通过：51.14 自带「与 51.3/51.8 分工」句，职责切面正确（覆盖对照/未测试/措辞档位）；64.7 有「与 64.2.1 分工…惩罚不双计」，且 64.2.1 零交集不可豁免与 64.7 的 BLOCKED 同向；94.7 对 94.1 用显式收窄句「94.1 同域口径不适用本门」属授权内收窄，非双源漂移；94.5 已写明 94.7 与 94.1-94.4「串联不重叠」。
- F6 [WARNING] `critical-rules.md:107` — K 缺省值与「须写明依据」自相矛盾且缺省偏宽松
  - 原文：「K=并发执行体数，缺省 3，须在声称中写明 K 的依据」
  - 推理：缺省 3 在「依据未写」时给出 3 倍宽限，恰好覆盖判例场景（单执行体 224 篇）；默认可被当作免证并发度，削弱本条唯一硬阈值
  - 置信度：HIGH
- F13 [QUESTION] `critical-rules-discipline.md:618` — 「上报包装禁令」与 88.3 呈报域收敛（:551）、54.3 仪式性进展禁令（:242）三源部分重叠，无分工句
  - 原文：「未经确认的扩展成果禁以任何阶段性或成果性命名（战役/阶段/批次/Wave/Batch 等）包装为用户目标进度上报」
  - 推理：三处都能判「扩批成果当里程碑呈报」，长期演进易双源漂移；94.7 新增的「显式标注未确认+单列」义务是独有增量，但未点明与 88.3/54.3 的分层
  - 置信度：MEDIUM
- 残余：64.4④「专档未建档(tier) 时显式记」（drift:63）未带 tier 限制，靠「留痕处置见 64.7」间接收口（见 F7）。

## 维度三 跨域判据可判定性 — 内容/媒体/文件可判，代码域词表与混合操作两处引入模糊

- 通过：94.7 ①状态分区词表含内容/代码/文件/媒体四域，判据句「状态分区不同且用户指令未指明该分区」可操作；②≥10× + G-6 单位判据（指令单位优先、未给则复述固定、禁跨单位折算）闭合了「放大百倍再折算」的规避路径；③动词集（审计/扫描/取证/重构/重制/重跑/批量替换）具体可判；51.14 L1<L2<L3<L4 有内容/代码/媒体三域映射，「禁止上位词包装低档工作」可判。
- F8 [WARNING] `critical-rules.md:107` — 51.14 域映射缺文件域（94.7 已含文件域），且 L2/L3 边界对混合操作无主档规则
  - 原文：「内容 L1 正则/机械扫描/L2 抽样审读/L3 逐篇语义审读/L4 文字改写/优化；代码 L1 lint·grep/L2 抽样 review/L3 逐行审读/L4 重构修复；媒体 L1 参数校验/L2 抽帧目检/L3 逐帧审看/L4 剪辑重制」
  - 推理：文件域批量动作（重命名/校验/逐文件审读）无映射示例，执行体需自行造档；抽样+逐件复检的混合形态无「按覆盖主体取档」规则，档位可争议
  - 置信度：MEDIUM
- F9 [WARNING] `critical-rules-discipline.md:618` — 代码域状态词不是对象生命周期状态，且无只读豁免
  - 原文：「代码域 merged/tag/branch/stash」
  - 推理：branch=版本位置、stash=暂存区，与 published/draft/trash 不同类；按字面读，查看其他分支/tag 或 stash 列表这类只读查询可被判「跨分区」→ 过触发 BLOCKED，与 95 执行优先冲突
  - 置信度：MEDIUM
- F12 [NIT] `critical-rules.md:107` — ③耗时证据强度弱
  - 原文：「实测耗时：产物时间戳或执行记录锚」
  - 推理：产物 mtime 可批量 touch，单靠时间戳不证明操作类型与真实耗时；建议「执行记录锚优先，时间戳仅佐证」
  - 置信度：MEDIUM

## 维度四 级联完整性 — 五处落位在位，三处未同步

- 通过：SKILL bullet（:229）含 51.14 三要素+K 依据；recall A（:7）/B（:14）/E（:41）均已补锚且新文本包含旧子串；64.4 已加 ④ 与「四锚合计…缺任一即不完整」；94.5 行尾衔接句到位且未改 94.6 行；回归 4-regression.md：comm -13 空（新增 FAIL=0）。
- F1（见维度一）= 级联最重缺口：agent def 三锚构成错位。
- F7 [WARNING] `skills/task-discipline/references/execution-recall-card.md:41` — R-1 增量只落 64.7，压缩消费面漏判「非 trivial 档专档缺失=BLOCKED」
  - 原文：「专档缺失且 trivial 档记 `专档=未建档(tier)` 不判 BLOCKED，专档在位但空/零条目或 Goal∩原话零交集按 64.1+BLOCKED 处置」
  - 推理：卡片枚举了「缺失+trivial=不 BLOCKED」与「在位但空=BLOCKED」，唯独缺「缺失+非 trivial=BLOCKED」→ 读者按对称性易推成「缺失一律不 BLOCKED」，与 64.7（:68）新句相反
  - 置信度：HIGH
- F10 [NIT] `critical-rules-drift.md:63` — 「必须内嵌三锚输入」「三锚使 haiku 档判定有据可依」旧口径保留（74.2 增量 old-substring 约束所致，后句「扩展为四锚后」已澄清）
  - 原文：「必须内嵌三锚输入：① Goal 原文锚…」/「三锚使 haiku 档判定有据可依」
  - 推理：与新口径并存时首句仍是规范主句，派发侧可能读停在 3；建议后续改为「四锚输入（三锚基线见下）」
  - 置信度：HIGH
- F11 [NIT] `skills/task-planner/scripts/selftest-requirement-coverage.sh:4`（及 :26-28、51.13 机制句 :106）— 「十三子条（51.1-51.13）」「51.9-51.13 子条文本锚」在 51.14 后过期
  - 原文：「静态断言 Rule 51 十三子条（51.1-51.13，critical-rules.md）」
  - 推理：RC-01 实为 `-ge 7` 不破，仅计数口径陈旧；51.13 的机器守护范围声明未说明 51.14 为 L0-T 文本锚（在断言面外）
  - 置信度：HIGH

## 验证摘要
- 总发现 13 / 已验证 13 / 通过率 100%（每条引文均 grep -F 命中对应文件，含 line 号核对）

## 负结果报告
- 检查面：skills/task-discipline/references/critical-rules-discipline.md（94.x/95.x/88.x/41.2/28.x/53.3/54.3）、skills/task-planner/references/critical-rules.md（51.3/51.6/51.8/51.10/51.13/51.14/80.1/80.6）、skills/task-drift-guard/references/critical-rules-drift.md（61.2/64.1/64.2.1/64.4/64.7）、skills/task-drift-guard/SKILL.md、skills/task-planner/SKILL.md、skills/task-planner/companion/agents/drift-checker.md、skills/task-discipline/references/execution-recall-card.md、skills/task-planner/templates/subagent_dispatch.md、selftest-requirement-coverage.sh / selftest-drift-enforcement.sh、部署位 ~/.zcode/skills 同名三文件（与源仓逐字一致）。
- 预期有问题但**未发现**：① 94.7 与 8.1.1「目标切换 yes 门」双源——8.1.1 管指令到达期目标切换，94.7 管执行期范围触发，判据（目标实体 vs 状态分区/规模）不重叠；② 94.7 与 74.2 三判门重复——74.2 管吸收动作语义，94.7 只把「扩批」定性为 B 类，串联非重复；③ 51.14 与 43.5/51.10/51.11 冲突——三者为生成实测/计数交付/留口让步，产物性质区分清晰；④ 64.7 与 64.1/64.2.1 冲突——留痕字段与门控面分工句到位、惩罚不双计；⑤ 新增子条打破 selftest——RC-01 `-ge 7` 不破，回归 comm -13 为空；⑥ 与宪法 §五/§六/§十一 P0 冲突——94.7 未新增写权限、零脚本零新键，仅行为门。
- 排除项：把 51.14「缺一禁用」与 41.3 trivial 自主裁定判为条款冲突——41.3 管决策归属，51.14 管措辞档位，非冲突；真问题是同一行内豁免与主句措辞互斥（F4，保留）。
- 未验证/无法判定：64.4「部署位随 Phase 5 同步」所指 Phase 5 是否在他任务已完成（git log -S 显示该句出自 task-v171 P5-P8，本仓当前 agent def 仍为三锚 → 视为未闭环，不判定其历史完成度）。

## 建议处置（按优先级）
1. F1：「drift-checker.md:36 三锚→四锚（含 Goal 原文锚 + 64.7 口径指针）」— 需用户授权后作增量改写（影响派发消费面，优先于收口）。
2. F4/F6：51.14 措辞收口（主句加「② 除外」；K 缺省改 1）。
3. F2/F3/F5：94.7 补 silent 档句 + 95.1 探测前置；64.7 补「80.1 建档先于 BLOCKED」+ 与 80.6 env 档关系一句。
4. F7：recall card E 与 64.4④ 各补一句 tier 限定（均 ≤1 句，纯增量）。
5. F9/F8/F12/F13/F10/F11：词表/映射/证据强度/分工句/口径陈旧，随下轮增量处理，不阻断收口。
