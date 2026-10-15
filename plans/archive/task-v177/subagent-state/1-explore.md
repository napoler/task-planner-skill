# S1 落点调研（2026-10-15）

任务 task-v177：新 Rule 86「可测问题禁问 + 无推荐禁上抛」落点调研。仓库=/mnt/data/dev/task-planner-skill（主仓）。
**编号凭证**：`plans/.rule-reservations.jsonl` 末行已有 `{"rule":86,"status":"reserved","task_id":"task-v177","ts":"2026-10-15"}`——86 已为本任务预留（合并后须 `rule-reserve.sh land`，Rule 20.6）。

## Rule 44 现状摘要（≤5 行+关键 file:line）
1. Rule 44=「用户选择点默认项与自动超时裁决」（P1, task-v103），全文在 `skills/task-discipline/references/critical-rules-discipline.md:167-175`（子条 44.1 呈现契约/44.2 低区分度直裁/44.3 超时自动裁决/44.4 机制/44.5 阻塞点展示限制+task-v160 两段续行 171/175）。
2. 范围=**选择点「怎么呈现」**（必带默认选项+5 分钟自动超时+留痕），不管「哪些问题不该问」——Rule 44 是计划/执行全域的交互呈现纪律，非媒体专属，也不自带「可测性」判据。
3. 与「禁问面」的衔接点=**170-171 行**：44.2「低区分度优先直接裁决（不问）」+ v160 续行「低区分度选项按 Rule 72.1 C 级处置：直接裁决+登记,禁止 AskUserQuestion（Rule 72 琐碎上抛禁令 72.3）」。
4. 禁问面真正总纲在 Rule 72（`critical-rules-discipline.md:431-453`：72.1 A 必问/B 默认+超时/C 禁问 分级表 + 72.3 琐碎上抛禁令:443-444 + 72.4 基础质检硬门:446-447）；升级纪律在 Rule 41（41.1 消解优先:128、41.4 升级前置消解清单:132、41.5 打包呈报:133）。
5. 结论：Rule 86 应落 task-discipline 域（规则全文文件末尾，85 之后）；「可测问题禁问」=72.1 C 级扩展判据（可测试/可择优的问题=禁问，须自迭代取优）；「无推荐禁上抛」=44.1/28.3/70④ 的 P0 升级硬化。既有条款零改动（Rule 36.5 纯增量）。

## 触点清单（≥6 处，file:line+一句）
1. `skills/task-discipline/references/critical-rules-discipline.md:51`（28.3 询问规范）—「每次 AskUserQuestion 带 2-4 个选项,首选标 (Recommended) 置顶」=**已有必须带推荐约束**（P1 级）。
2. `critical-rules-discipline.md:133`（41.5 打包呈报）—「每项附主进程推荐项与默认动作」=已有推荐要求，但属升级 SOP 层非 P0 铁律。
3. `critical-rules-discipline.md:443-444`（72.3 琐碎上抛禁令）—「C 级问题必须自动修复+登记，禁止 AskUserQuestion」=**禁问面既有锚**（C 级三类判据在 438 行 72.1，均不含「可测/可择优」形态）。
4. `critical-rules-discipline.md:446-447`（72.4 基础质检硬门）—「质检不合格禁止上抛用户代审，必须回炉重生成或修复后重检」=媒体侧「禁代审」唯一规则级表述，但**未禁「把修词/重抽/多抽卡策略当选项抛用户」**。
5. `skills/task-planner/templates/variant/image-type.md:88`（Phase 7 终验门）—「动作（选定/重抽+默认项）」=带默认项的既成模板 SOP，但**仍把「选定 vs 重抽」作为选项呈用户**（用户投诉模式：换提示词/随机重抽几种方案丢给用户选）；:81「静默重生成唯一路径=修词重抽（禁 PIL 修补/同词原参重发）」「多抽卡批量出 N 候选全下载」(:73) 是「自迭代取优」SOP 的既有模板层先例。
6. `skills/task-planner/templates/variant/video-fix-type.md:45`—「同型缺陷连续 3 轮未收敛=强制停批+4 维归因+**用户三选项裁决**」=**裸上抛触点**（把三种处置丢给用户选，未先自测择优/未标推荐）。
7. `skills/task-planner/templates/variant/character-design-type.md:42`—「批量多抽 N 候选；机器 QC 后主进程 Read 亲检择优」=「测试取优不自抛」正向先例（仅模板层，无规则级条款）。
8. `skills/plan-cost-guard/references/billing.md:48-53`（17.5）—「opus ≥10 次 → 触发 AskUserQuestion「继续/拆型/降级」/「询问用户 继续/拆 phase/降档」」=裸上抛触点（无 Recommended 标注；成本门控域，Rule 86 可豁免此域或要求带推荐）。
9. `skills/task-drift-guard/SKILL.md:59/68/80`—「⚠️ DRIFT→询问用户继续/缩批/熔断」「⚠️ → 问用户：纠正/继续/STOP」=裸上抛触点（三选项无推荐项）。
10. `critical-rules-discipline.md:170-171`（44.2+v160 续行）— 禁问面与 Rule 44 的既有接缝（Rule 86 的级联落点之一）。

## media SOP 缺位（确切插入位置 file:line）
- **规则级缺位**：`skills/media-planner/references/critical-rules-media.md`（47/49/50 全文 1-56 行）中**无**「生成不满意→迭代重试/取优」条款、**无**「禁止把迭代策略当选项抛用户」表述。最近邻=47.3 批量试点先行（:15，只管「首单元失败禁止批量」，不管失败后如何迭代取优）；72.4（discipline :447）只管「质检不合格回炉」，不管「策略选择权归属」。
- **「测试择优」SOP 现状只在项目 variant 模板层**：image-type.md:73/81/87、storyboard-type.md:24/49/62、multiview-ref-type.md:24/45/64、character-design-type.md:42/47（静默修词重抽环+亲检择优+不呈送中间态）——规则层未收录，通用任务（非该 variant）无此纪律。
- **最适插入位置（推荐）**：`critical-rules-media.md` **47.3（:15）之后新增 47.5 子条**（生成不满意处置：QC/评级 FAIL→自迭代取优【修词重抽/多抽择优，静默，预算账本限额】；迭代策略（换提示词/重抽/换参）属 C 级禁问面，禁止作为选项上抛；仅 A 级风格/交付物形态变更才可问）；:17 现有 47.4 机制行需顺延为 47.6 并改「四子条→五子条」（selftest-media-dispatch.sh 锚级联）。
- **备选位置**：Rule 86 本体 86.x 子条（discipline 文件）内放「86.5 媒体域消费面」一句锚（47/50 评级 FAIL 时按 86.x 处置），media 文件只在 50.6 后（:56 文件尾）加一行消费锚——改动面更小，但「生成不满意 SOP」在 media 域的可发现性弱于 47.5。
- 级联面：media-planner/SKILL.md:32-34 规则索引表（47 行）、:46 参考文档行「3 条规则全文（Rule 47,49,50）」措辞；task-planner/SKILL.md:17/:163 与 core critical-rules.md:183 的 media-planner 行（Rule 47,49,50 号列）如 47.5 不改编号则号列不变，仅标题级锚动。

## 索引线级联点（4 处，每处「Rule 44 行句式+86 插入格式」）
1. **`skills/task-planner/references/critical-rules.md:182`**（核心卫星路由索引 task-discipline 行）— 现行句式=「- **task-discipline**（域=执行纪律与工作产物维护）：规则全文见 …（Rule 4,6,7,8,9,10,18,27,28,29,31,32,33,35,36,41,42,43,44,45,48,53,54,55,56,57,60,65,67,69,70,71,72,73,74,76,85）」（44 在枚举中段，85 为末位）→ 86 插入格式=行末 `,85` 后追加 `,86`。旁证：:165 边界段「核心 14 条」不受影响（86 归卫星非核心）。
2. **`skills/task-planner/SKILL.md:17`**（frontmatter 卫星技能行）—「…（`../task-discipline/`，Rule 4,6,7,8,9,10,18,27-36,41-45,48,53-57,60,65,67,69-76,85）」（区间缩写式，85 末位）→ 追加 `,86`。同文件 **:162**（文末卫星路由表 task-discipline 行，逐列式「…44,45,48,53-57,60,65,67,69-76,85」）→ 追加 `,86`。**另**：:9/:175/:217 三处「Rules 1-84 全集索引」已陈旧（85 落地未级联），加 86 时一并刷「1-86」。
3. **`skills/task-discipline/SKILL.md:24`**（卫星路由段枚举）—「规则全文见 `references/critical-rules-discipline.md`（Rule 4,6,…,76）」**——85 也缺=v175 级联欠账** → 86 落地时补 `,85,86`。同文件 **:30-67 规则索引表**现行 Rule 44 相邻行=**:50 `| 44 | 用户选择点默认项与自动超时裁决 | 同上 |`**（夹在 :49 Rule 43 与 :51 Rule 45 之间）；表末 **:67 `| 76 | 总结阶段格式可读性与审查清单实体化纪律 | 同上 |`** → 插入格式=表末续行 `| 85 | 用户输入一致性纪律 | 同上 |` + `| 86 | 可测问题禁问与无推荐禁上抛（测试择优纪律） | 同上 |`。**同文件 :15 域边界段「共 36 条」与 :69 落盘状态行计数（19+17=36）需级联 36→38；:80 参考文档行「36 条规则全文」同刷。**
4. **`skills/media-planner/SKILL.md:30-34`**（规则索引表）— 现行三行：:32 `| 47 | 媒体制作任务派发纪律（P0） | references/critical-rules-media.md |`、:33 `| 49 | … | 同上 |`、:34 `| 50 | … | 同上 |`（表中无 44——Rule 44 不属 media 域，此处「相邻」指表格式照抄）→ 若 47.5 方案落地，:32 标题可括注「含 47.5 生成不满意自迭代取优」；:36-42 联动规则表追加一行 `| Rule 86 | task-discipline | 可测问题禁问/迭代策略禁上抛（47.5 消费） |`；:46 参考文档行「3 条规则全文」措辞不变（47.5 仍属 47）。

## selftest 范式摘要（断言风格+registry 列结构）
- **脚本范式**（`skills/task-planner/scripts/selftest-four-file-dataflow.sh` :55-110）：bash；头注释 What（断言枚举 FF-01..FF-18 逐条说明+运行方式）/Why（规则锚+用户诉求）四要素（Rule 45）；助手函数 `ok/bad`（PASS/FAIL 计数）+`eq/ge/zero/pair`（判定助手，pair=双锚各≥1 防「半裁」漏检）+`cnt`（`grep -c -e` 文本锚计数，缺文件回显 0）；被检路径全部相对 `SCRIPT_DIR` 解析；**grep 文本锚+计数器**风格=每断言 `eq "FF-NN <文件> <语义描述>" "$(cnt '<锚正则>' "$FILE")" N`；负断言=下一规则号 `^NN\.` 计数=0（FF-16 前向防线，v127/RR-09 范式）；config 零新键=jq `.properties|length` 时点基线（现=46）；末行 `Total: N PASS=x FAIL=y`，全 PASS exit 0。Rule 86 新脚本（如 `selftest-testable-no-ask.sh`，TA-01..TA-NN 断言 ID）照抄此结构：锚=discipline 文件 86.x 子条文本+44.2/72.3/72.4 衔接句+4 索引线级联行（各 SKILL/critical-rules 枚举中的 `86`）+media 47.5 锚（若落）+零新键。
- **registry 范式**（`skills/task-planner/scripts/selftest-registry.tsv`，82 行，4 列 tab 分隔）：表头=`script` \t `domain` \t `trigger_scenarios` \t `dep_anchors`。新行格式照 :81（selftest-input-consistency.sh, Rule 85 判例）：`selftest-<name>.sh` \t `Rule 86 可测问题禁问与无推荐禁上抛静态守护 TA-01..NN（task-v177）` \t `<触发场景：86.x 条款锚/级联行/零新 config 键改动>` \t `skills/task-discipline/references/critical-rules-discipline.md;skills/task-discipline/SKILL.md;skills/task-planner/SKILL.md;skills/task-planner/references/critical-rules.md;[skills/media-planner/references/critical-rules-media.md;]config.json;scripts/selftest-registry.tsv`。

## 负结果记录（未找到的东西）
- 全仓 grep「可测/能测试/测试选/择优」于规则文件（discipline/media）：**无规则级「可测问题禁问/测试取优」条款**（仅 L0 微变更 :192「三条件机器可测」与 73.6 :469「验收标准禁不可测表述」沾边，均非本议）；「择优」仅出现在 variant 模板层（image/character-design/storyboard/multiview-ref 各文件，见触点 5/7）。
- `C33` 合规清单行仅在 44.4 机制行（:173）被引用，各 SKILL.md 中无实体 C33 行（C 行体系已于 task-v171 瘦身退役为 G 表，见 four-file-dataflow FF-11 注释）——Rule 86 机制行勿再引「合规清单 CNN」。
- `plans/task-v177/` 下原本无 `subagent-state/` 目录，本次已建（本检查点为其中首个文件）。
