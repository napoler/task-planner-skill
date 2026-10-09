# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1 审批请求必须列出待审批内容清单+简介（用户 2026-10-10 原话见 task_plan.md 需求区）
- R2 其余类似缺陷场景一并修正（全触点）
- R3 汇报阶段须完整给出：做了什么/风险/产出清单/待审项+地址（路径/网址）
- R4 全部补全，杜绝"让用户审查一个莫名其妙的东西"

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| delivery-summary 模板（Rule 48 金标准） | /mnt/data/dev/task-planner-skill/skills/task-planner/templates/delivery-summary.md | ✅ | Research Findings §金标准 |
| critical-rules.md Rule 48 / config.json#interaction_mode | /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md | ✅ | Research Findings §现状 |
| Explore 全触点审计报告 | 子代理返回（2026-10-10，agent_d01cc03e） | ✅ | Research Findings §触点审计 |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### 触点审计（Explore 子代理 2026-10-10，very thorough）
**技能实际根目录 = `/mnt/data/dev/task-planner-skill/skills/task-planner/`（仓内嵌套子目录）。**

**核心结论**：全工作流约 30 个"向用户请求审批/审查/确认/呈报"触点中，仅"终验交付总结"一处满足完整呈报契约；其余触点普遍缺 ①待审项清单+逐项简介 ②可定位地址（绝对路径/URL）③看点 ④动作+默认项 四要素中的至少一项；**机器面零守护**（check-complete.sh 仅 rcov-gate 校验需求覆盖表 L784-931 fail-open；selftest 全部是模板/条款文本静态锚，对实际呈报完整性零校验）。

**主要缺口触点清单**（完整表见子代理返回，此处存级联修复所需的锚点）：
| 文件 | 行号锚 | 场景 | 缺口 |
|---|---|---|---|
| skills/task-planner/SKILL.md | :23（P0 diff 展示）/:34（bypass 终验展示）/:72-74（D1 计划确认）/:105（drift BLOCKED）/:139-150（CR Gate）/:232-233（B/C 变更确认） | 各类呈报 | 缺①②③④ 或部分 |
| references/critical-rules.md | 28.3（D2-D6 选项）/:287（28.4.1 D6 降级交付）/:359-362（35.4 否定结论）/:447（41.5 打包呈报）/:459-462（42.6 审查结果）/:482（44.5 阻塞点）/:835（65.4 矛盾报告） | 呈报规格弱 | 缺②③④/① |
| references/worktree-isolation.md | :11/:25/:78/:83 | 冲突/合并 STOP 报告 | 全缺 |
| templates/task_plan.md | :100（not-solved 下一步）/:135（范围自检）/:337（FMEA AskUser） | 呈报字段 | 缺②③④ |
| templates/batch_report.md | 全文 | 面向用户呈报规格缺失 | 全缺 |
| templates/variant/image-type.md | :87 | 媒体送审清单 | 有②缺①③④ |
| templates/variant/multiview-ref-type.md | :25 | 收尾送审 | 有②缺①③④ |
| references/batch-quality-gate.md | :29/:31/:99（18.1/18.3 熔断呈报） | 批量熔断报告 | 全缺 |
| reference.md | :232 | 3 次失败升级 | 缺②，③④弱 |
| review-library/{general-review,alignment-review,code-quality-review}/SKILL.md | 各 :44-48/:66-71/:44-48 | 审查报告输出合约 | 缺①（审查对象总清单） |
| companion/agents/{article-batch-publisher.md:77,90, article-field-fixer.md:47, plan-writer.md:106} | 熔断/跳过率呈报 | 全缺 |
| scripts/check-complete.sh | L784-931 rcov-gate 之外 | 交付总结完整性 | 零校验（五要素/可定位性 grep 零命中） |

### 金标准现状（同仓既有成功先例 = 对标样本）
- `templates/delivery-summary.md`：五要素+定位栏+可定位性硬规则（Rule 48.2 五条）+反模式→修法对照+行动项定位三要素（对象/看点/动作）。头部注释记录 2026-10-03 task-v123 用户同义投诉原话——**本缺陷类是第二次反馈，v123 只修了交付总结单点**。
- critical-rules.md Rule 48 条文（:530-534 区段）48.1-48.5 仅约束交付总结。

### Rule 31 四维归因（用户指出错误 → 先归因后修）
- **现象**：用户被要求审批/审查，但呈报中无待审项清单、无简介、无文件地址。
- **直接原因**：除 Rule 48 外，各触点条款只写「展示/确认/报告用户/STOP」等动作动词，无呈报最小信息集规格。
- **根因（5 Whys）**：①无从审批 ← 呈报缺内容清单与地址 ← ②无契约 ← 除 Rule 48 外无条款定义呈报最小信息集 ← ③未泛化 ← Rule 48 是 task-v123 单点补丁，未横向推广到全部触点 ← ④无横向审计机制 ← 规则按单点投诉逐个补丁演进 ← ⑤零机器守护 ← selftest 只锚模板结构不守护呈报完整性，缺陷无信号。
- **类别**：规则覆盖缺口（系统性设计缺陷）——非单点 bug，修法必须=全触点泛化+机器守护双层（53.2 根治判据）。

#### [sub:1-executor] Rule 70 条文追加（S1 机械单元）
- **动作**：将 task_plan.md「📜 Rule 70 条文草案（S1 材料包）」代码块全文（源行 375-399，共 25 行）逐字追加到 worktree 内 `skills/task-planner/references/critical-rules.md` 文件末尾（Rule 66 段之后）。
- **证据**：`diff <(sed -n '375,399p' task_plan.md) <(tail -25 critical-rules.md)` 无差异（VERBATIM-MATCH）；`git diff --numstat` = `26 0`（26 新增行=1 空行分隔+25 条文行，0 删除行）。
- **验收**：A1 `grep -c '^## Rule 70（'`=1；A2 `70.[1-6]` 命中=7（≥6）；A3 `待审项清单`=1、`可定位地址`=1；A4 diff 仅该文件且全为新增。
- **边界**：未触碰任何其他文件（含 SKILL.md/config.json/registry/templates）；未执行 git add/commit。

#### [sub:2-executor] SKILL.md 四处接线（S2 机械单元）
- **动作**：在 worktree 内 `skills/task-planner/SKILL.md` 落位 Rule 70 四处接线（材料=task_plan.md「🧩 接线材料包」逐字）：① :9 顶部 references 索引行「全集 1-66」→「全集 1-66+70（67-69 并行任务预留）」+ 该行规则枚举末追加「、70 用户呈报可审批性纪律」；② :365 `## References` 表 critical-rules 行「Critical Rules 1-66（含…」→「1-66+70（含…」+ 行尾追加「+Rule 70 用户呈报可审批性纪律（task-v155）」；③ 终验交付段交付总结 bullet 后补「会话内一切其他呈报（审批/审查/确认/升级/熔断报告）按 Rule 70 四要素输出」；④ `## Critical Rules` 段 Rule 66 行后新增 Rule 70 摘要行 + 合规清单 C45 行后新增 C46 行。
- **证据**：`git diff --numstat -- skills/task-planner/SKILL.md` = `5 2`（5 新增+2 删除=两处索引行口径替换，零其他删除）；`grep -c 'Rule 70'`=4（:165/:220/:341/:365）、`grep -c '1-66+70'`=2（:9/:365）、`grep -c 'C46'`=1（:220，含「待审项清单」「可定位地址」）。
- **验收**：A1 Rule 70≥4 ✓；A2 C46≥1 且含待审项清单/可定位地址 ✓；A3 1-66+70≥2 ✓；A4 diff 仅 SKILL.md（critical-rules.md 变更属 S1 并行单元，非本单元）✓。
- **边界**：未触碰 SKILL.md 外任何文件；未执行 git add/commit/checkout/reset/push；未碰 v152/153/154 worktree。

#### [sub:3-code-assistant] SKILL.md 四触点呈报规格指针（S3 机械单元）
- **动作**：在 worktree 内 `skills/task-planner/SKILL.md` 四触点目标行后各新增一行「呈报规格（Rule 70）」指针（材料=task_plan.md「🧩 触点指针材料包」T1-T4 逐字，四要素词与 Rule 70 字样全部保留，零连接词微调）：T1 :72「展示 task_plan.md（含 Phase 列表 + Verification Contract 表）给用户」行后（计划确认段）；T2 :105「drift-checker 为只读检测执行体，发现 BLOCKED 时必须等用户明确决策后再继续」行后；T3 :150「失败处理：fix-phase 失败 3 次 → AskUserQuestion 决策…」行后（Code Review Gate）；T4 :247「每次 B/C 类变更 → Decisions Made 表记一行（指令→变更）+ progress.md 记录」行后（B/C 变更确认，宿主语境即向用户复述计划变更处）。
- **证据**：插入前基线 `grep -o 'Rule 70' | wc -l`=5（:165/:220/:341/:365 四处行 + 行 9 索引行口径）；插入后=9；`grep -c '呈报规格（Rule 70）'`=4；`git diff --numstat -- skills/task-planner/SKILL.md`（本单元内）= `4 0`（4 增 0 删）；`git diff | grep -c '^-[^-]'`=0（既有行零删除）；新增行逐一 grep 与材料包 T1-T4 对拍一致。
- **验收**：A1 `grep -c 'Rule 70'` 9≥9 ✓；A2 `grep -c '呈报规格（Rule 70）'`=4 ✓；A3 diff 仅新增行（删除行计数=0）✓。
- **边界**：未触碰 SKILL.md 外任何文件（findings/progress 按 Rule 22.4a 契约回填除外）；未执行 git add/commit/checkout/reset/push；未碰 v152/153/154 worktree。

#### [sub:5-code-assistant] task_plan.md 三处呈报字段补 Rule 70 四要素指针（S5 机械单元）
- **动作**：在 worktree 内 `skills/task-planner/templates/task_plan.md` 三处呈报字段行末各追加一句 Rule 70 指针（材料=task_plan.md「🧩 触点指针材料包」T7 逐字，既有行语义零改动，仅值列/行末追加）：①「🎯 核心目标达成裁决」表「下一步建议」行值列末补「（按 Rule 70：对象路径+看点+动作）」；②「执行前自我检查」区块末行「- 全部 Yes → 可以执行 | 任一 No → 先问用户」行末补「（问询按 Rule 70 四要素）」；③ FMEA 表下「**填写规则**」段（含「走 22.3 哪一档：…AskUserQuestion」字样处）段末补「（AskUser/呈报按 Rule 70 四要素）」。
- **证据**：`grep -c "Rule 70"` 插入后=3；三处短语 grep 各=1；`git diff --numstat`=3 3（3 增 3 删，系同 3 行行末追加所致）；`git diff --word-diff=porcelain` 纯新增词片段=3 段（均为 Rule 70 指针语，其余词零改动，既有行语义零删除）。
- **验收**：A1 `grep -c "Rule 70"`=3（≥3）✓；A2 diff 零删除行（word-diff 纯增）✓；A3 三短语各=1 ✓。
- **边界**：未触碰 templates/task_plan.md 外任何文件（findings/progress 契约回填除外）；未执行 git add/commit/checkout/reset/push；未碰其他 worktree。

#### [sub:6-code-assistant] batch_report.md 头部注释补 T8 Rule 70 呈报规格（S6 机械单元）
- **动作**：在 worktree 内 `skills/task-planner/templates/batch_report.md` 头部 HTML 注释区 :5「详见:references/batch-quality-gate.md §三/§四」行后插入 T8 逐字行：`<!-- 面向用户呈报时按 Rule 70 四要素：失败/跳过单元逐项清单（编号+简介）+产物绝对路径+看点（失败原因列）+动作（重试/放弃+默认项）。 -->`（新增行 = :6，参照 delivery-summary.md 头部注释惯例；四要素词与 Rule 70 字样完整保留）。
- **证据**：`grep -c "Rule 70"`=1；`grep -n "失败/跳过单元逐项清单"`→:6；`git diff --numstat -- skills/task-planner/templates/batch_report.md`= `1 0`（1 增 0 删，纯新增）；`git diff | grep -c '^-[^-]'`=0。
- **验收**：A1 `grep -c "Rule 70"`≥1 ✓；A2 新增行含「失败/跳过单元逐项清单」与「动作」字样 ✓；A3 diff 0 删除行 ✓。
- **边界**：未触碰 batch_report.md 外任何文件（findings/progress 契约回填除外）；未执行 git add/commit/checkout/reset/push；未碰其他 worktree。

#### [sub:7-code-assistant] 送审模板「审查地址清单」补 T9 逐件规格（S7 机械单元）
- **动作**：worktree 内两文件各纯新增 1 行 T9 逐字行（含「Rule 70」字样与 ①③④ 形态）：`image-type.md` :87 终验门行后插入（新行 :88）；`multiview-ref-type.md` VC 表 :26 行后插入（新行 :27，表内无独立规格区，按「段末/规格行后」条款落 VC 表末行后）。
- **证据**：`grep -c "Rule 70"` 两文件各=1；`git diff --numstat` 两文件均 `1 0`（1 增 0 删，纯新增）；既有行语义零改动。
- **验收**：A1 两文件 grep "Rule 70" ≥1 ✓；A2 两文件 diff 0 删除 ✓。
- **边界**：未触碰两文件外任何文件（findings/progress 契约回填除外）；未执行 git add/commit/checkout/reset/push；未碰其他 worktree。

#### [sub:8-code-assistant] batch-quality-gate.md 3 处 + plan-writer.md 1 处补 T10/T11 Rule 70 呈报指针（S8 机械单元）
- **动作**：worktree 内 4 处纯新增（既有行语义零改动）：`references/batch-quality-gate.md` ①18.1 表行后（新行 :30）②18.3 表行后（新行 :34）各插入 T10 逐字块「报告按 Rule 70 四要素——受影响单元清单+产物路径+看点（failure 明细行）+动作（重审/回滚+默认项）」；③§四 抽检失败处理段末（:102 行后新行）复同一措辞（共 ≥2 处命中 T10 语义）；`companion/agents/plan-writer.md` :106 批量场景红线段末行后插入 T11 逐字行「（呈报按 Rule 70:风险项清单+计划文件路径+看点+动作）」。
- **证据**：`grep -c "Rule 70" batch-quality-gate.md`=3；`grep -c "Rule 70" plan-writer.md`=1；`git diff --numstat`=batch-quality-gate `3 0`、plan-writer `1 0`（均 0 删除，纯新增）。
- **验收**：A1 batch-quality-gate ≥2 ✓（=3）；A2 plan-writer ≥1 ✓（=1）；A3 两文件 diff 0 删除 ✓。
- **边界**：未触碰两文件外任何文件（findings/progress 契约回填除外）；未执行 git add/commit/checkout/reset/push；未碰其他 worktree。


#### [sub:9-code-assistant] article-batch-publisher.md 2 处 + article-field-fixer.md 1 处补 T12 Rule 70 呈报指针（S9 机械单元）
- **动作**：worktree 内 3 处纯新增（既有行语义零改动）：`companion/agents/article-batch-publisher.md` ①:77「跳过单元 ≥10% AskUserQuestion 重审」行后（新行 :78）②:90「失败率 STOP/熔断回滚 (Rule 18.3)」行后（新行 :91，缩进 3 空格随列表项）各插入 T12 逐字块「（呈报按 Rule 70 四要素：单元清单+路径+看点+动作）」；`companion/agents/article-field-fixer.md` :47「failed >0 → 整批熔断报告用户」行后（新行 :48）复同一措辞。
- **证据**：`grep -c "Rule 70" article-batch-publisher.md`=2；`grep -c "Rule 70" article-field-fixer.md`=1；`git diff --numstat` 两文件分别 `2 0` / `1 0`（均 0 删除，纯新增）。
- **验收**：A1 batch-publisher ≥2 ✓（=2）；A2 field-fixer ≥1 ✓（=1）；A3 两文件 diff 0 删除 ✓。
- **边界**：未触碰两文件外任何文件（findings/progress 契约回填除外）；未执行 git add/commit/checkout/reset/push；未碰其他 worktree。

#### [sub:10-code-assistant] review-library general-review 与 alignment-review 输出合约补 T13 审查对象总清单行（S10 机械单元）
- **动作**：worktree 内 2 文件各 1 处纯新增（既有行语义零改动）：`skills/task-planner/review-library/general-review/SKILL.md` 与 `alignment-review/SKILL.md` 的「## 输出合约」段 verdict 首行规则（`- 结论二值: APPROVED…`）之后各插入 T13 逐字行「- **审查对象总清单（Rule 70①）**：报告须附本次审查对象文件清单（绝对路径+逐项一句话），使收报告者无需追问即知审了什么。」
- **证据**：`grep -c "审查对象总清单（Rule 70" general-review/SKILL.md`=1；`grep -c "审查对象总清单（Rule 70" alignment-review/SKILL.md`=1；`git diff --numstat` 两文件均 `1 0`（0 删除，纯新增）。
- **验收**：A1 general-review grep=1 ✓；A2 alignment-review grep=1 ✓；A3 两文件 diff 0 删除 ✓。
- **边界**：未触碰两文件外任何文件（findings/progress 契约回填除外）；未执行 git add/commit/checkout/reset/push；未碰其他 worktree。

#### [sub:11-code-assistant] review-library code-quality-review 输出合约补 T13 审查对象总清单行（S11 机械单元）
- **动作**：worktree 内 1 文件 1 处纯新增（既有行语义零改动）：`skills/task-planner/review-library/code-quality-review/SKILL.md` 的「## 输出合约」段 verdict 首行规则（`- 结论二值: APPROVED…`）之后插入 T13 逐字行「- **审查对象总清单（Rule 70①）**：报告须附本次审查对象文件清单（绝对路径+逐项一句话），使收报告者无需追问即知审了什么。」
- **证据**：`grep -c "审查对象总清单（Rule 70" code-quality-review/SKILL.md`=1；`git diff --numstat` = `1 0`（0 删除，纯新增）。
- **验收**：A1 grep=1 ✓；A2 diff 0 删除 ✓。
- **边界**：未触碰该文件外任何文件（findings/progress 契约回填除外）；未执行 git add/commit/checkout/reset/push；未碰其他 worktree。

#### [sub:12-executor] selftest-report-reviewability.sh 创建（S12 机械单元）
- **动作**：在 worktree 内新建 `skills/task-planner/scripts/selftest-report-reviewability.sh`（RRV-01..07 断言 + RRV-08..13 预留骨架），逐条实现材料文件规格：RRV-01 条款锚（标题=1 六子条≥6）；RRV-02 四要素词齐备；RRV-03 行号锚禁令（Rule 70 段内 `:\s?[0-9]+`=0，v148 判例）；RRV-04 SKILL 接线锚（Rule 70≥4 C46≥1 含四要素）；RRV-05 13 触点文件 Rule 70 锚齐备；RRV-06 registry 登记+config 零新键（WARN 档默认，env RRVV_REGISTRY_STRICT=1 升 FAIL）；RRV-07 check-complete report-lint 段（WARN 档默认，同 env 升级）。RRV-08..13 预留 TODO 注释骨架。脚本头注释四要素齐全（用途/消费方/断言面/依据），What+Why 双层注释（Rule 45），禁硬编码行号，禁 `:数字` 引用形态（RRV-03 自合规）。
- **证据**：`bash -n` 通过；`chmod +x` 通过；运行输出 `Total: PASS=5 FAIL=0 WARN=2` EXIT=0（RRV-01..05 PASS，RRV-06/07 WARN 中间态宽限）；`grep -nE ':\s?[0-9]+'` 脚本自身 NO_MATCH（自合规）。
- **验收**：A1 bash -n 通过 ✓；A2 运行 exit 0 且输出含 RRV-01..07 各编号行与 Total 行 ✓；A3 chmod +x ✓；A4 脚本自身无 `:数字` 引用形态 ✓。
- **边界**：未触碰新建脚本外任何文件（findings/progress/checkpoint 契约回填除外）；未执行 git add/commit/checkout/reset/push；未碰其他 worktree。

#### [sub:13-executor] selftest-report-reviewability.sh 追加 RRV-08..13 触点分组锚断言（S13 机械单元）
- **动作**：在 worktree 内 `skills/task-planner/scripts/selftest-report-reviewability.sh` 第 159-165 行预留骨架处替换为 RRV-08..13 六条实际断言：RRV-08 模板面组（task_plan>=3/batch_report>=1/image-type>=1/multiview>=1 各 grep "Rule 70"）；RRV-09 管线面组（article-batch-publisher>=2/field-fixer>=1/plan-writer>=1）；RRV-10 审查工具面组（review-library 三 SKILL.md 各 grep -c "审查对象总清单（Rule 70" =1）；RRV-11 主链面组（reference>=1/worktree-isolation>=4）；RRV-12 SKILL 触点组（"呈报规格（Rule 70）"=4 且「会话内一切其他呈报」=1）；RRV-13 预留骨架（TODO(RRVV-14) 占位注释存在即 PASS）。全部 FAIL 档（RRV-13 除外），使用既有 helper 函数，无行号硬编码。
- **证据**：`bash skills/task-planner/scripts/selftest-report-reviewability.sh` EXIT=0，输出含 RRV-01..13 全编号，Total: PASS=11 FAIL=0 WARN=2（RRV-06/07 仍中间态 WARN）；`git diff | grep -c '^-[^-]'`=0（零删除行）；既有 RRV-01..07 关键行（:74/:148/:68）零改动；`grep -nE ':\s?[0-9]+'` NO_MATCH。
- **验收**：A1 exit 0 且 RRV-01..13 全编号 PASS=11 FAIL=0 ✓；A2 仅该脚本变更且全部新增行（删除行=0）✓；A3 脚本无 `:数字` 引用形态 ✓。
- **边界**：未触碰该脚本外任何文件（findings/progress/checkpoint 契约回填除外）；未执行 git add/commit/checkout/reset/push；未碰其他 worktree。

#### [sub:14-executor] check-complete.sh rcov-gate 段后追加 report-lint 守护段（S14 机械单元）
- **动作**：在 worktree 内 `skills/task-planner/scripts/check-complete.sh` 的 rcov-gate 段结束处（rcov-gate 外层 `fi` 之后、Learning Gate 之前，4 空格同层级）插入独立函数 `run_report_lint()` 并追加一处调用。三项 fail-open warn 检查：①「## 2. 产出清单」区表格数据行（排除区块首个表格行=表头与 `| --- |` 分隔行）中不含 `/` 的行数 ≥2 → warn（Rule 48.2/70②）；②「## 5. 下一步建议」区缺「看点」或「动作」→ warn（Rule 48.4/70④）；③「待裁决」行同行无 `/` 或 `http` → warn（Rule 70②）。区块锚容忍模板阿拉伯数字式（`## 2.`/`## 5.`，金标准 templates/delivery-summary.md）与历史中文数字式（`## 二、`/`## 五、`）；delivery-summary.md 不存在 → SKIPPED 后 `return 0`。全部输出仅 `printf '[report-lint] ⚠ ...' >&2`，不改 exit code / 不写 FAIL 计数 / return 恒 0。
- **证据**：`bash -n check-complete.sh` rc=0；`grep -c "report-lint"`=6（≥4）；`git diff --numstat`=53/0（零删除）；`git diff -U0 | grep '^+' | grep -c 'exit 1'`=0；冒烟（/tmp 最小样例）worktree 输出 3 行 `[report-lint] ⚠` 且 `WT_EXIT=0` == `MASTER_EXIT=0`；缺 delivery-summary → `[report-lint] SKIPPED` 且 exit 0；干净样例与真实 v149 summary（中文数字式）零 warn（无假阳性）；`selftest-report-reviewability.sh` RRV-07 由 WARN 翻 PASS（Total PASS=12 FAIL=0 WARN=1）。
- **验收**：A1 bash -n 通过 ✓；A2 grep -c report-lint=6≥4 ✓；A3 新增行 `exit 1`=0 且既有行零删除（+53/-0）✓；A4 冒烟触发 [report-lint] 且主仓/worktree exit code 一致（0==0）✓。
- **边界**：仅改 check-complete.sh（git status 仅该文件 M）；未执行 git add/commit/checkout/reset/push；未碰其他 worktree；未改任何既有 exit 语义。注：`selftest-goal-unit-goal-mode.sh` G-09 FAIL（SKILL.md=518>515）系 S2/S3 早前单元所致（master=511），不在 S14 scope，留 Phase 7 级联处置。

#### [sub:15-executor] registry 登记 + RRV-06/07 翻硬档 + 全仓计数钉核查（S15 机械单元）
- **动作**：① worktree 内 `skills/task-planner/scripts/selftest-registry.tsv` 末行追加 `selftest-report-reviewability.sh` 登记行（tab 4 列，域=Rule 70 用户呈报可审批性纪律守护 RRV-01..13（task-v155））；② `selftest-report-reviewability.sh` 中 RRV-06/07 由 WARN 宽限档改为常驻 FAIL 档（移除 `RRVV_REGISTRY_STRICT` env 分支与 `STRICT` 变量，registry 登记行缺失 / report-lint 段缺失即 `bad` FAIL；注释更新为「登记行与 lint 段已落位（S14/S15），2026-10-10 翻硬档」）；③ 全仓 selftest 计数钉核查。
- **证据**：registry `awk -F'\t' '$1=="selftest-report-reviewability.sh"{print NF}'`=4；`wc -l`=66（表头+65 脚本），数据行 65=`ls selftest-*.sh | wc -l`=65；`bash selftest-report-reviewability.sh` exit 0、`Total: PASS=13 FAIL=0 WARN=0`；`RRVV_REGISTRY_STRICT=1 bash 同脚本` exit 0 且 `diff` 与普通跑 IDENTICAL；脚本 `bash -n` rc=0；`selftest-registry.sh` T01-T05 全 PASS（registry rows=65=actual 65）。
- **③ 计数钉核查结论（无静态脚本总数钉，动态口径）**：全仓 grep `64` 相关 selftest/count/total 命中项经逐条排查均为误报（`\{64\}` 十六进制形态 / Rule 64 条款锚 / 「1-64→1-65」历史演进注释），**未发现把 selftest 脚本总数钉死为 64（或任何定数）的静态断言**；唯二做脚本数比对的守卫均为动态口径——`selftest-registry.sh` T02/T03（`ls selftest-*.sh` + `comm` 双向核对）、`selftest-self-resolution.sh` SR-12（`expected=$(ls selftest-*.sh | wc -l) + 1` 表头），新增脚本自动纳入无需改数；故本单元**未修改任何既有脚本**（scope 第三面零改动）。
- **附带发现（非本单元引入，留 S16/S17 清账）**：`selftest-self-resolution.sh` SR-01 FAIL（`grep -c '^41\.' critical-rules.md`=7 应 6）——根因=Rule 70.5 首行「41.5 打包呈报补四要素…」（critical-rules.md:883）以 `41.` 开头被 SR-01 正则误计；该行为 S1（Rule 70 条文）引入，与本单元（未触碰 critical-rules.md）无关，属 Phase 7 级联修复面。
- **边界**：仅改 registry.tsv（纯追加 1 行）与 selftest-report-reviewability.sh（WARN 逻辑改造，净 -9 行，删除行仅限 STRICT/WARN 分支及其注释）；未执行 git add/commit/checkout/reset/push；未碰其他 worktree；未改任何既有脚本。

#### [sub:16-code-runner] 全量 selftest 回归（S16 机械单元）
- **动作**：worktree 内 65 个 `selftest-*.sh` 全量跑批（逐脚本独立 `timeout 120` + 独立日志 `/tmp/rrv-<脚本名>.log`），逐脚本记录 rc 与 Total 行，FAIL 脚本提取断言行原文。
- **结果**：`total=65 rc0=62 rc1=3 assertFAIL_sum=4`；rc=1 者=goal-unit-goal-mode（G-07+G-09）/ self-resolution（SR-01）/ skill-split（T-主）。
- **FAIL 明细**：① G-07：`selftest-registry.tsv` 末行现为 v155 新增 `selftest-report-reviewability.sh`（S15 追加）顶掉「末行=goal-unit」断言（goal-unit 登记行仍在第 65 数据行）；② G-09 与 T-主 同根因：`wc -l SKILL.md`=518 >515（v155 Rule 70 摘要+C46 接线净增后被两脚本 515 钉拦截）；③ SR-01 预知 FAIL（Rule 70.5 首行「41.5…」被 `^41\.` 误计 7>6）。明细与逐脚本 rc/Total 全量落 `subagent-state/16-code-runner.md`。
- **验收**：逐脚本 rc 清单 + ΣFAIL 落检查点 ✓；跑批只读，worktree `git status --short` 空（零改动）✓。

#### [sub:17a-executor] 锚级联修复（SR-01 精确锚 + G-07 存在性断言）
- **动作**：修 worktree 内两个 selftest 脚本的锚级联 FAIL（合计 3 处）。
  - SR-01（selftest-self-resolution.sh）：计数锚从 `^41\.` 精确化为 `^41\.[0-9]+ \*\*`（匹配子条标题加粗格式），排除 Rule 70.5 行内「41.5 打包呈报补四要素」误计。
  - G-07（selftest-goal-unit-goal-mode.sh）：从「末行是」改为「表内含」grep 存在性断言，不钉绝对位置。
- **结果**：selftest-self-resolution.sh exit=0 Total 13/13 PASS；selftest-goal-unit-goal-mode.sh G-07 PASS，剩余仅 G-09 FAIL（SKILL.md 行数 518>515，另一单元修）。
- **验收**：两脚本 diff 删除行仅限被改锚对应行；改锚均附根因注释（2026-10-10 task-v155）。

#### [sub:17b-executor] SKILL.md 行数钉上调 515→540（worktree 两 selftest 守卫）
- **动作**：修 worktree 内两个 selftest 脚本的 SKILL.md 行数上界钉（v155 Rule 70 接线净 +7 → SKILL.md 实际 518 行触旧 515 钉）。
  - selftest-skill-split.sh：新增 v155 合并级联注释行（`Rule 70 接线净 +7（511→518），钉随演进上调 515→540（留 22 行余量给后续并行任务 v152-154/v156；≤558 总上限不动）`）；断言行 `≤515`→`≤540` 且 `-le 515`→`-le 540`，保留既有演进史文字。
  - selftest-goal-unit-goal-mode.sh：G-09 段头部注释 + 段内 What/Why + `if [ "$n" -le 515 ]` + ok/bad 文案同步改 540（ok 文案 =「≤540（task-v155 上调后上限，Rule 70 接线 +7 触顶，留余量）」）。
- **结果**：selftest-skill-split.sh `Total: 41 PASS=41 FAIL=0` exit=0；selftest-goal-unit-goal-mode.sh `Total: 9 PASS=9 FAIL=0` exit=0；`grep -c 540` split=3 / goal=5（各 ≥2）。
- **验收**：改后自跑全 PASS；`wc -l SKILL.md`=518 ≤540 逻辑成立；未触碰 G-07（17a 已修）及其余断言行。

#### [sub:16b-code-runner] Round 2 全量 selftest 复跑（65/65 PASS 验证 Round 1 修复）
- **动作**：worktree 内 65 个 `selftest-*.sh` 全量复跑（逐脚本独立 `timeout 120` + 独立日志 `/tmp/rr2-<脚本名>.log`；总耗时 ≈202s，03:58:58→04:02:20）。
- **结果**：`total=65 rc0=65 rc1=0 assertFAIL_sum=0`（Round 1 基线 rc0=62/rc1=3/assertFAIL_sum=4）；前轮 3 个 FAIL 脚本全绿：goal-unit-goal-mode rc=0 Total 9 PASS=9 FAIL=0（G-09 文案=「SKILL.md 行数=518 ≤540」）、self-resolution rc=0 Total 13 PASS=13 FAIL=0、skill-split rc=0 Total 41 PASS=41 FAIL=0。
- **零改动**：65 脚本 md5 pre/post 逐字节一致；`git status --porcelain` pre=post=3 行（均为 Round 1 修复的预期未提交修改，跑批未新增任何改动）。
- **验收**：逐脚本 rc/Total 全量 65 行落 `subagent-state/16b-code-runner.md`；无 FAIL 行；无超时（0 个触发 timeout 120）；无 TRUNCATED。

#### [sub:18-code-reviewer] task-v155 .sh 代码改动只读审查 → CHANGES_REQUESTED（2×P1）
- **范围**：分支真实 .sh 改动 5 文件（`git diff 5afba9c..HEAD -- '*.sh'`）：selftest-report-reviewability.sh(新) / check-complete.sh(+report-lint 段) / selftest-self-resolution.sh(SR-01 精确锚) / selftest-goal-unit-goal-mode.sh(G-07+G-09) / selftest-skill-split.sh(T-主 钉 540)。注：master..HEAD 会显示 v153 工作的「假删除/假回退」（master 已前进），非本分支改动。
- **P1-1** scripts/check-complete.sh:983 — 待裁决 lint `grep -vqE` 空输入语义依赖 grep 实现：GNU=1（不 warn）vs ugrep=0（warn）。无「待裁决」行的交付总结（金标准模板即无）在 ugrep 宿主上误报。实测 `printf '' | grep -vqE x` ugrep→0。修法：`... | grep -vE '/|http' | grep -q .`（同 :741 惯用）。
- **P1-2** selftest-goal-unit-goal-mode.sh:129 + selftest-skill-split.sh:48 — 行数钉 540 与 master 的 ≤526 同点冲突（`git merge-tree` CONFLICT）；合并后 SKILL≈530 行，若解冲突取 master 526 则 G-09/T-主 合并后 FAIL。修法：merge-back 保留 540。
- **P2**：RRV-07(:143 锚可被注释满足) / RRV-13(:207 自指恒真) / RRV-06(:132 空值整型错误) / 检查①表头启发式(:966) / 检查③标题行误报(:983) / 「13 触点」口径不一致(nit) / G-07 与 master 重复(nit)。
- **负结果**：bash -n 5 文件全 OK；三脚本实跑 13/9/13 全 PASS；SR-01 修复实测 7→6 正确；fail-open 承诺核验通过（无 set -e、return 0、不改 exit）。
- 明细：subagent-state/18-code-reviewer.md

#### [sub:19-align-reviewer] 对齐审查（CHANGES_REQUESTED，1×P1）
- **范围**：分支真实 .md 改动 15 文件（`git diff 5afba9c..HEAD -- '*.md'`；master..HEAD 含 v152-154 假删除，基线取 merge-base=5afba9c）。伴飞 rubic=review-library/alignment-review/SKILL.md。
- **P1** SKILL.md:287 — 「Critical Rules 1-66」未同步为「1-66+70」（:9/:369 已改、:345 已增 Rule 70 行），同概念三处声明不一致/旧措辞残留。
- **P2** worktree-isolation.md:12/:27 — T6 指针行插入表格行间无 `|` 前缀，中断 §1 信号表与 §2 决策矩阵结构。
- **P2** T5/T6/T7 指针仅②③④缺①「待审项清单」关键词（70.4 允许简化，不阻断）。
- **P2** critical-rules.md 70.1「媒体送审清单」未交叉引用 Rule 47/50。
- **负结果**：70.5/70.1 引用子条 41.5/44.1/48.2/36.4/28.3/35.4/44.5/65.4 全部存在且语义相符；.md diff 5 处删除均为就地扩展（零语义篡改）；delivery-summary.md 未动；C45/C46 形态一致；技能 .md 零 v156/Rule 71 混入。
- 明细：subagent-state/19-align-reviewer.md

#### [sub:20b-executor] 对齐修复（S19 P1+P2）
- **修复 1（P1）**：SKILL.md:287「Critical Rules 1-66」→「1-66+70（67-69 并行任务预留）」，与 :9/:369 口径对齐。
- **修复 2（P2）**：worktree-isolation.md:12/:27 两处裸文本「呈报按 Rule 70：…」改为表格行形态（补 `|` 管道，3 列匹配），消除表格结构断裂。
- **验证**：`grep -c "1-66+70" SKILL.md` = 3（>=3 PASS）；`grep -c "Rule 70" worktree-isolation.md` = 4（>=4 PASS）；表格行 | 数一致（每行 4 个 `|`）；diff 删除行仅限被修行（3 行）。
- 明细：subagent-state/20b-executor.md

#### [sub:20c-executor] RF-07 守卫钉值级联（S20b 头注改写两侧同步恢复）
- **背景**：S20b 把 SKILL.md:287 头注改为「1-66+70（67-69 并行任务预留）（含 Rule 40-65 全集…」，打翻 RF-07 断言的 `Critical Rules 1-66（含 Rule 40-65 全集` 子串（v151 级联判例）。
- **修复 1**：SKILL.md:287 头注改回形态「Critical Rules 1-66+70（含 Rule 40-65 全集 + Rule 70 用户呈报可审批性纪律，67-69 并行任务预留）（含 Rule 40-65 全集，…）」——保留 1-66+70 同步成果 + 下文规则名列表原文。
- **修复 2**：selftest-research-first.sh:73 RF-07 断言字面 `Critical Rules 1-66（含 Rule 40-65 全集` → `Critical Rules 1-66+70（含 Rule 40-65 全集`，注释追加「2026-10-10 task-v155 S20b 头注改写级联」。
- **验证**：`bash scripts/selftest-research-first.sh` exit 0 Total PASS=12 FAIL=0；`grep -c "Critical Rules 1-66+70（含 Rule 40-65 全集" SKILL.md`=1；`grep -c "1-66+70" SKILL.md`=3（不降）；diff 2 文件各 +1/-1，删除行仅限被修行。
- 明细：subagent-state/20c-executor.md

#### [sub:20d-executor] SKILL.md:287 冗余双括号清理（RP 级联修复残留）
- **背景**：S20b/S20c 级联修复后 SKILL.md:287 头注残留冗余双括号——`…67-69 并行任务预留）（含 Rule 40-65 全集，Rule 55…`，即外层括号内出现两个并列子括号且 `含 Rule 40-65 全集` 前缀重复。
- **修法**：合并两个括号、去重复前缀：`…67-69 并行任务预留）（含 Rule 40-65 全集，Rule 55` → `…67-69 并行任务预留；含 Rule 55`，其余语义（Rule 55/61/63/64/65 名称列表 + Rule 70 + 67-69 预留）全保留。
- **硬约束保持**：RF-07 断言锚子串 `Critical Rules 1-66+70（含 Rule 40-65 全集` 未破；本行「1-66+70」出现数不减少（仍为 1）。
- **验证**：`bash scripts/selftest-research-first.sh` exit 0 Total PASS=12 FAIL=0；`grep -c "Critical Rules 1-66+70（含 Rule 40-65 全集" SKILL.md`=1；`grep -c "含 Rule 40-65 全集" SKILL.md`=1（本行出现数 2→1）；`1-66+70` 全仓计数=3 不降。
- 明细：subagent-state/20d-executor.md

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 新增 Rule 70「用户呈报可审批性纪律」而非扩写 Rule 48 | Rule 48 权威源绑定交付总结单点（模板/selftest/用户裁决锚均在）；呈报契约是全工作流纪律，独立编号便于触点统一引用；67-69 已被并行任务预留，70 为下一可用号（账本核实） |
| 触点修补 = 指针行（按 Rule 70 四要素呈报）而非各处复制全文 | 单一权威源（70.4），防口径漂移（v117 教训：frontmatter 改口径即撞三旧守卫） |
| 机器守护 = 新 selftest 静态锚 + check-complete.sh 交付总结轻量 lint（fail-open warn） | check-complete exit 语义是交付门控承重墙，只增 warn 不改 exit；对齐 rcov-gate fail-open 先例 |
| 范围含 review-library×3 与 companion×3 | 用户明示"其他类似情况必须修正+全部补全"；均为同缺陷类呈报触点，补丁各 ≤3 行 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| 首次直读路径错（templates/ 顶层不存在） | 技能根在 skills/task-planner/ 子目录，Explore 返回已纠正 |
| 全局活跃指针指向已 COMPLETE 的 task-v150 且哈希不符（hook PLAN TAMPERED 两次） | 判定=陈旧指针（v150 已于 10-09 合并归档，非本会话篡改）；init-session 已把 side 指针切到本任务；全局指针待 v156 init 或维护窗口清理；交付报告向用户披露 |

## 新投诉归因（2026-10-10 用户第二条反馈 — Rule 31 四维，v156 立项依据）
- **现象**：① 重大决策（更换风格、更换视频生成方式——推翻用户已确认的计划要素）不询问用户、不通知，擅自执行；② 琐碎事项（「这里有错误，是否需要修正」类有明确对错的局部问题）反复上抛用户抉择，打断执行流（一小时任务几分钟即被打断）；③ 基础性质检（图像物理常识错误：动物肢体数量等）执行体不审核，直接推给用户主动审查。
- **直接原因**：决策点分级判据缺失/颠倒——Rule 41（消解优先+升级四门槛）与 Rule 44（低区分度直接裁决+自动超时）只约束「何时可以不问」，缺正向「哪些必须问」的影响权重轴；媒体质检条款（Rule 47/50）停在评级打分，无「基础性质检必须机检+禁上抛代审」硬门。
- **根因（5 Whys）**：①打断与隐瞒并存 ← ②分级只按选项区分度（44.2）与升级门槛（41.2 G1-G4）运作，缺「影响权重」轴：推翻既定计划要素=必须问；有明确对错的局部修复=必须自动消解 ← ③41/44 演进聚焦「减少打扰」（38.7 比例原则判例主诉=流程开销过大），矫枉过正，「该问不问」反向失败无对称条款 ← ④缺统一「决策分级表」载体（A 必问/B 默认+超时/C 禁问）← ⑤历史投诉单点演进模式（与 v155 归因根因⑤同构：单点补丁、无横向分级审计、零守护）。
- **类别**：规则覆盖缺口（决策分级轴）+守卫缺失（质检上抛禁令）——修法=Rule 71（A 必问：推翻已确认计划要素/不可逆/对外；C 禁问：明确对错局部修复、质检结果代审；B=44 既有）+媒体变体模板/QC 链触点修补+selftest 守护，方案细节入 task-v156 计划。

## Resources
- 技能根：/mnt/data/dev/task-planner-skill/skills/task-planner/
- 规则预留账本：/mnt/data/dev/task-planner-skill/plans/.rule-reservations.jsonl（66 landed；67=v152/68=v153/69=v154 预留；**70 可用**）
- 并行在途 worktree：v152-proactive-context / v153-parallel-scheduling / v154-decision-arbiter（合并期预期 critical-rules.md 尾段冲突，按 v149 并集解判例）

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
- 无

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->

#### [sub:u1-executor] U1 冲突并集解完成（worktree v155-report-approvability 合并 master）
- 状态：done（验收 3/4 PASS；验收4「脱离 U 状态」需 git add，与 Scope §4「禁止 git add」矛盾 → 按禁令不 add，UU 交主进程统一 staging）
- SKILL.md：3 冲突块并集解（:227 合规表 master C46/C47 在前 + HEAD 改号 C48 在后；:293 Critical Rules 段首行 1-69+70 + 67-69 已由并行任务落位；:355 Rule 68/69 bullet 在前 + Rule 70 bullet 在后）+ 两处索引口径 :9/:387「1-66+70」→「1-69+70」
- critical-rules.md：移除标记，master（### 68 68.1-68.7、### 69 69.1-69.6）在前，HEAD（## Rule 70 70.1-70.6）在后，数值升序；Rule 67 不在文件内（无冲突未动）
- 证据：grep -c '^<<<<<<<'→0/0；1-69+70→3；| C46 |/| C47 |/| C48 |→1/1/1；Rule68/69/70 摘要 bullet→1/1/1；68/69/70 子条齐
- 约束：未 git add/commit/merge/reset/checkout；其余 4 冲突文件（registry/research-first/skill-split/goal-unit-goal-mode）仍 UU 未动

#### [sub:u2-executor] 合并冲突并集解（selftest-registry.tsv + selftest-research-first.sh）
- registry.tsv（1 块）：并集，master `selftest-parallel-scheduling.sh`(Rule 68) 行在前、本任务 `selftest-report-reviewability.sh`(Rule 70) 行在后；两行各 4 tab 列不变；`^<<<<<<<`=0，两行 grep 各=1
- research-first.sh（1 块）：RF-06 取 master 宽容锚 `cnt '1-6[0-9]' ≥3`（取代 HEAD `1-66` 字面链，涵盖本任务路线演进）；RF-07 保留 HEAD 侧双锚 pair 结构，头注字面改为 `Critical Rules 1-69+70（含 Rule 40-69 全集`（grep 复核 SKILL.md:293 现场文本 count=1，标签同步 1-69+70 全集），注释追加「2026-10-10 task-v155 合并并集：67-69 落位后口径」
- 证据：两文件 `grep -c '^<<<<<<<'`→0/0；`bash scripts/selftest-research-first.sh`→exit 0 `Total: 12 PASS=12 FAIL=0`；`bash scripts/selftest-registry.sh`→exit 0 `Total: 5 PASS=5 FAIL=0 (registry rows=67, actual selftest=67)`
- 约束：未 git add/commit/merge/reset/checkout；仅动两目标文件；UU 交主进程 staging

#### [sub:u3-executor] worktree 合并冲突并集解（selftest-skill-split.sh + selftest-goal-unit-goal-mode.sh）
- selftest-skill-split.sh（1 块 T-主行数钉）：并集解——master 侧 task-v154 S5 注释条目（Rule 69 接线 515→521，钉 515→526）保留 + HEAD 侧 v155 条目改写为并集说明；断言 `≤540`→`≤555`（=合并后 SKILL.md 实际 530 +25 余量），演进链补 `→521→530`，先例补 v154/v155
- selftest-goal-unit-goal-mode.sh（3 块）：G-07 注释+断言块取 master 侧 v153 健阔化「含数据行」断言（`row="$(grep...)"; [ -n "$row" ]`）+ 追加 HEAD 侧 v155 同验注释行；G-08 无实质冲突取 master 侧（config 零新键负断言）；G-09 钉值块并集——bound `≤540`/`≤526`→`≤555`（=n+25），注释合并双方历史（master「D2 上调」+ HEAD「task-v155 Rule 70 +7 触顶」）并注明并集取值
- 证据：两文件 `grep -c '^<<<<<<<'`→0/0；`bash scripts/selftest-skill-split.sh`→exit 0 `Total: 41  PASS=41  FAIL=0`；`bash scripts/selftest-goal-unit-goal-mode.sh`→exit 0 `Total: 9 PASS=9 FAIL=0`（G-09: SKILL.md 行数=530 ≤555）；`bash scripts/selftest-research-first.sh`（交叉验证）→exit 0 `Total: 12 PASS=12 FAIL=0`
- SKILL.md 实际行数=530 ≤ 两脚本新钉同值 555；`git diff` 删除行全部落冲突块内被修行（skill-split 2、goal-unit 15），无非冲突行被删
- 约束：未 git add/commit/merge/reset/checkout；仅动两目标文件；UU 交主进程 staging；checkpoint=subagent-state/u3-executor.md

#### [sub:u4-executor] RRV-04 绝对编号锚→内容锚（合并并集 cardinality 教训）
- 目标文件 `skills/task-planner/scripts/selftest-report-reviewability.sh` RRV-04 段（:103-113）：原绝对编号锚 `grep -e '^| C46 '` 在合并并集后失效（Rule 70 合规行让位至 SKILL.md:229 的 C48 行）→ 改内容锚 `grep -e '^| C[0-9]* |' "$SKILL" | grep "用户呈报可审批性"`，再断言该行「待审项清单」「可定位地址」各 ≥1；`Rule 70 ≥4` 首锚保留
- 变量去 C46 令牌：`RRV04_C46/_C46_LIST/_C46_ADDR` → `RRV04_LINE/RRV04_LIST/RRV04_ADDR`；What 头部 + RRV-04 段注释补根因（指定措辞已落）
- 冲突处置：prompt §2 要求根因注释点名 C46/C47，验收项 1 要求 `grep -c "C46"`=0 硬门；两者字面互斥，优先满足硬门，根因以「并行任务（Rule 68/69）占用绝对编号位、合规行整体让位（现为 C48 行）」表述
- 证据：`grep -c "C46"`→0；`bash scripts/selftest-report-reviewability.sh`→exit 0 `Total: PASS=13 FAIL=0 WARN=0`（RRV-04 PASS）；内容锚唯一命中 SKILL.md:229 C48 行；负向稳健性（变异「待审项清单」→list_hits=0 会 FAIL）
- 约束：未 git add/commit/merge/reset/checkout；仅动该脚本；未碰其他 worktree；checkpoint=subagent-state/u4-executor.md
