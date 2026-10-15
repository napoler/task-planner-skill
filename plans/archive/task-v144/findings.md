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
#### [sub:13-code-assistant] 合并级联：workflow-orchestration（WF-10/WF-12）+ evidence-goal-gate（EG-16）锚/键数/负断言对象演进（task-v144，2026-10-08）
- WF-10 旧口径「'Rules 1-39'+'Rules 1-45' 4 索引文档命中总和 ≥6」实测 FAIL（SKILL.md 锚已演进 1-62，旧变体命中 4<6）→ 演进口径：'Critical Rules 1-62'+'1-62' 变体族命中总和 ≥3 + SKILL.md 旧 'Rules 1-39/1-45' 残留=0（负断言锚定 SKILL.md 主文件；CLAUDE.md L33/README_zh L136,229/skills-README L72 旧残留=4 处，归另行级联单元不在本锚检核面，已在脚本 docblock 注释说明）
- WF-12 config.json properties 键数 40→42（task-v142 遗留 2 个 periodic_review 孤儿键，同 IP-15/LA-14/RC-13 漂移面口径对齐）
- EG-16 负断言对象 '^59\.[0-9] '→'^63\.[0-9] '：Rule 59 已由 S1 合法落地 59.1-59.8（旧断言实测 =8 FAIL）；61 预留未落地（^61.=0）、62 已落地（^62.=6），63 为首个全未占用编号（^63.=0），=0 保持防顺手创建语义不弱化
- 验证：两脚本实跑 Total: 16 PASS=16 FAIL=0 / Total: 21 PASS=21 FAIL=0（exit 0）；每处修改断言+docblock+诊断串三同步，级联注释 `[2026-10-08 task-v144 合并级联]` 齐备
- 负结果：本 S-unit 仅触碰 2 个目标文件（WF/EG 两脚本）；git status 中其余 M 文件（SKILL.md/check-dispatch 等 7 项）为 S1-S12 既有产物零触碰；未 git add/commit

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

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

## Research Findings

#### [sub:1-explore] 拆分纪律与技能路由现状调研（2026-10-08）
- Rule 21.1b 三值上限在（≤2文件/100行/15min, critical-rules.md:144），但 check-dispatch.sh 只机械校验 prompt 长度+步骤计数+S-unit 打包计数（:316-431）；文件数/行数/时长三项超限仅打 SKIPPED 不阻断——条文自认「提示不阻断,拆分判断归模型」
- Rule 46.1 单会话单 S-unit 在（:494）；任务书豁免 fail-open（任务书文件不可解析时 SKIPPED）
- 无技能伴飞条款：Rule 22.4 九字段（:168）无技能字段；仅媒体任务 Rule 47.2（:506）要求点名技能
- 无执行前技能激活条款：Rule 22.3.3（:167）只是失败后接管评估；Rule 42.2 是质量审查检测链
- Rule 22.3 拆细先于升档=失败后兜底（:163）；43.2 计划期档位标注=经济导向（:456），均无「能力不足→预防性拆细」判据
- **Rule 21.1c / analyze-splits.sh 在 master 不存在**——v135（INDEX in_progress 2/5）产出未合并且 worktree 已消失，其「智能拆分分析」目标由本任务 S7 吸收重建

#### [sub:2-explore] 技能面与子代理工具面事实调研（2026-10-08）
- comet 族=用户显式触发设计（无 hook 自动激活；comet-any 带 disable-model-invocation: true）；using-superpowers 对话开始使用但有 SUBAGENT-STOP（子代理忽略）；brainstorming=创意工作前 HARD-GATE
- 工具面扫描（~/.zcode/agents/ frontmatter）：含 Skill 工具仅 3 个——task-orchestrator / auto-agent / article-research-heavy-agent；executor/code-assistant/simple-agent/debugger 等执行体全部无 Skill 工具；**几乎所有 agent 都有 Read**
- 结论：子代理技能强化可行路径排序=①任务书内联 SKILL.md 路径+首动作 Read（全量可行）②主进程激活后提炼要点内联（重型技能）③改 agent 定义加 Skill 工具（保护区+30 文件，不可行）④子代理内再派有 Skill 工具的 agent（间接，复杂）
- 设计裁决：59.2 伴飞走路径①+②组合；59.3 技能扫描含用户触发型标注（comet 族只提示不自动激活——尊重其 frontmatter 设计）

#### [sub:1-code-assistant] Rule 59 条文块撰写（task-v144 S1，2026-10-08）
- 产出：worktree critical-rules.md 文件尾纯增量 22 行（L692 锚注释→L713 59.8），七子条 59.1-59.7 + 59.8 关系澄清；diff --numstat = 22 insertions / 0 deletions，仅此一文件
- 锚格式对齐 Rule 57/58 惯例（`<!-- Rule 59 (task-v144 2026-10-08): ... -->` 块首锚 + `### 59 ...` 标题行 + 子条 `59.N **名（What 规则）** + Why=判例` 双层注释，Rule 45 对齐）
- 七子条落点：59.1 三值 Nf/Nl/Nmin 强制填报+超 step_max_*（config.json L430-433 现行值 2/100/15）enforce 拒锁 / 59.2 伴飞技能列+SKILL.md 绝对路径注入+子代理首动作 Read+重型技能主进程提炼 ≤20 行内联（依据=工具面仅 3 agent 有 Skill 工具） / 59.3 任务画像期技能扫描→knowledge-brief「可用强化技能」区块，comet 族用户触发型仅提示不代激活（disable-model-invocation 设计尊重） / 59.4 计划期能力预防判据（超档先拆细再派，22.3 理念前移） / 59.5 分段执行锚（多段=多 S-unit 多派发+检查点链，与 46.1 联动；任务书豁免 fail-open 收窄至「不可解析」一档） / 59.6 analyze-splits.sh+selftest 守护+registry 登记 / 59.7 零新 config 键（复用 step_max_*）
- 负结果：检查 worktree 内 check-dispatch.sh 未同步修改（属 S6 范围，本 S-unit 只动 critical-rules.md）；既有 Rule 1-58 原文零改动（diff 仅 +22 行）；无冲突

#### [sub:2-code-assistant] SKILL.md Rule 59 级联联动（task-v144 S2，2026-10-08）
- 三处行内改写完成：①L9 Rules 索引行「1-57」→「1-59」，枚举末追加「、58 主动解决问题泛化行为原则（task-v142 落地但本行此前漏登——顺带修正）、59 子代理拆分粒度硬门与技能伴飞纪律」（原括注编号+名称格式保持）；②L338 References 表 critical-rules.md 行「1-39」→「1-59」，枚举末追加「 / Rule 56 用户指令优先与自动执行 / Rule 57 迭代测试轮次落盘 / Rule 58 主动解决问题泛化行为原则 / Rule 59 子代理拆分粒度硬门与技能伴飞纪律」；③L259 S-unit 表机器契约消费点（22.6 声明格式段 ① 行末）旁追加注释行 `<!-- Rule 59 (task-v144): S-unit 表新增粒度三值(Nf/Nl/Nmin)与伴飞技能列,契约见 critical-rules 59.1/59.2,超限 enforce 拒锁 -->`
- SKILL.md diff = +3/-2（被替换的两行均为行内改写非净删；git diff 仅 SKILL.md 单文件属本 S-unit，worktree 内 critical-rules.md/knowledge-brief.md 的 M 状态为并行单元 S1/S4 既有产物，本单元未触碰）
- 负结果：grep 全部 S-unit 消费点后确认 L258 三层声明段（含 22.6 S-unit 表加列机制）为最近机器契约消费点；主仓 SKILL.md 未动；无净删行

#### [sub:5-code-assistant] subagent_dispatch.md §2 插入「伴飞技能」子节（task-v144 S5，2026-10-08）
- 产出：worktree templates/subagent_dispatch.md §2 末行（并行组声明行）之后、「## 📚 必要知识储备上下文包」之前纯插入「### 伴飞技能（Rule 59.2，任务书派发侧载体）」子节 +5 行（标题 + 三条 bullet），diff = +5/-0 单文件，既有行零改动
- 子节三要素：①取值规则（S-unit 表「伴飞技能」列值非「无」时本节必填，「无」写「无（纯机械单元）」）②注入格式行（SKILL.md 绝对路径占位 {escort_skill_path} + 指令「子代理首动作：Read 该路径对齐方法论后再执行本任务」）③重型技能规则（SKILL.md 全文 >300 行：主进程提炼 ≤20 行要点内联 + 全文路径供按需回读，禁通读全文——防上下文叠加 59.2/R3）
- 九字段字面锚（L2 头注释与 §1-§9 编号）零改动，新子节为 §2 附属内容不占编号
- 验证：grep -c "伴飞" = 3（≥2）；git diff --numstat = 5 0
- 负结果：worktree 内既有 M 文件（critical-rules.md/knowledge-brief.md/SKILL.md）属并行单元 S1/S2/S4 产物，本单元未触碰；未执行 git add/commit；knowledge-brief.md 未触碰（属 S4 范围）

#### [sub:3-code-assistant] task_plan.md S-unit 表派发单元改造（task-v144 S3，2026-10-08）
- 产出：worktree templates/task_plan.md S-unit 派发单元表（机器契约注释块 L225-233 + 表头/示例行 L234-239）单区段改写：①表头 7 列→9 列，「粒度(三值)」「伴飞技能」插在「预估时长」列之后（布局契约：check-plan-dispatch.sh 按 awk -F'|' 固定列位解析 $5=输入/$7=预估时长，新列追加其后零错位，状态列右移为 $10 不影响既有解析）；②示例数据行 S1/S2 同步补两列占位（`1f/30l/15min` + `无(示例)`）；③机器契约 ①② 两处 SKIPPED 提示措辞升级为「超限= enforce 档硬阻断拒锁回炉重拆（Rule 59.1，2026-10-08 由 SKIPPED 提示升级）」，③「机侧提示行」同步改为「机侧校验行」；④新增两条 bullet 契约（无数字序号）：粒度三值列 Nf/Nl/Nmin 逐行校验超限→enforce 拒锁 + 伴飞技能列非「无」→校验 SKILL.md 路径存在(Rule 59.2)
- 验证：grep -c "enforce" 模板 = 5（≥2）；grep -E "粒度\(三值\)|伴飞技能" 命中 L232/L234；git diff 该模板 +16/-13 仅本区段，非 S-unit 区段零改动
- 负结果：worktree 内既有 M 文件（SKILL.md/critical-rules.md/knowledge-brief.md/subagent_dispatch.md）属并行单元 S1/S2/S4/S5 产物未触碰；check-plan-dispatch.sh 脚本本体 SKIPPED→enforce 升级属 S6 范围本单元未改（模板注释已先行对齐 59.1 目标态）；未执行 git add/commit

#### [sub:6-code-assistant] check-dispatch.sh 粒度三值+伴飞校验落地（task-v144 S6，2026-10-08）
- 产出：worktree scripts/check-dispatch.sh fine_grain_checks 新增两项检测（纯增量 +96/-0 单文件，既有 ①-⑤ 分支与成功路径静默语义零改动）：⑥粒度三值——全文 grep -oE `[0-9]+f/[0-9]+l/[0-9]+min` 候选 + awk 行级边界双验证（前界=行首/空白/|，后界=行尾/空白/|：裸独立行与表格列内嵌 `| 1f/150l/20min |` 均合法入口，自由文本粘连剔除防误报），首个 token 三值任一超 config subagent.step_max_files/lines/minutes（jq 读既有键现行 2/100/15，59.7 零新键；缺失→回退默认+SKIPPED 一行）→ 计 hits 走档位管线（enforce=exit 2），提示串含「Rule 59.1 粒度三值硬门」；⑦伴飞路径存在性——仅「伴飞」关键行内 .md 路径 token（字符类 [A-Za-z0-9._/-]，实例化绝对路径完整命中；未实例化占位符 <path>/SKILL.md 最长匹配得 /SKILL.md → -f 必失败按违规计，单一判据零剔除特例），逐路径 -f 校验不存在→计违规（fail-closed，提示串含「Rule 59.2 伴飞路径不存在」），无伴飞声明跳过不误报；⑥⑦ 均同步覆盖 ② 任务书分支（59.5 豁免收窄同口径：引用任务书内容合并提取）
- 验证：bash -n 通过；11 样例矩阵 enforce 档实测——超限 3f/150l/20min→exit 2+59.1 命中（prompt 裸行 p1/粘连形态 p7/任务书表格内嵌 p8 三口径全命中）；伴飞路径不存在→exit 2+59.2 命中（prompt p2/任务书 p6）；干净样例 p3/p4/p9 exit 0 零输出；既有 ①长度 ②多 S-unit 打包 回归命中不回退；warn 档 p1 落盘计数行含「粒度三值超限」；off 档静默
- 回归：selftest-dispatch.sh 31 PASS / selftest-dispatch-grain.sh 10 PASS / selftest-fine-grain-steps.sh 11 PASS 全量零回退
- 负结果：worktree 内既有 M 文件（SKILL.md/critical-rules.md/knowledge-brief.md/subagent_dispatch.md/task_plan.md）属并行单元 S1-S5 产物未触碰；check-plan-dispatch.sh 表侧三值 enforce 升级属后续单元本单元未改（brief §5 口径一致）；git diff 本单元仅 check-dispatch.sh 单文件 +96/-0；未执行 git add/commit

#### [sub:7-code-assistant] S7 analyze-splits.sh 新建（Rule 59.6 机器面 / 吸收 v135 丢失目标）
- 产出：worktree `skills/task-planner/scripts/analyze-splits.sh`（190 行，单文件 +190/-0，git status 未新增其他文件）
- 行为口径：读 S-unit 表「粒度(三值)」列（表头含「粒度」→ $8，否则旧 7 列 SKIPPED 放行，与 check-plan-dispatch.sh fail-open 口径一致）；阈值 jq 读 config.json subagent.step_max_files/lines/minutes（双层路径 `.subagent.X // .properties.subagent.properties.X.default`，现行默认 2/100/15），jq 缺失/键缺回退默认并打一行提示（禁静默）；粒度值 `Nf/Nl/Nmin` 三段切分，缺段按 0，畸形→SKIPPED 不计违规
- 超限判定：任一维超上限→逐行输出「Phase N S<n> 粒度 Xf/Yl/Zmin 超限(files≤2/lines≤100/min≤15) — 建议: 拆成 K 个子单元」，K=各超限维度 ceil(值/上限) 取最大（保底 2），exit 1；全合规 exit 0；无参 usage exit 2
- 双 fixture 实测：超限行 3f/150l/20min→「拆成 2 个子单元」rc=1（files ceil(3/2)=2 / lines ceil(150/100)=2 / min ceil(20/15)=2 取最大=2，同值收敛）；旧 7 列表 fixture→SKIPPED rc=0；本任务 plans/task-v144/task_plan.md 实测 11 行粒度全合规 rc=0；缺文件 fail-open rc=0
- 负结果：未修改 worktree 既有任何 M 文件（S1-S6 产物零触碰）；未执行 git add/commit；阈值未走 env 覆盖（59.7 零新 config 键纪律延伸，单一事实源=config.json）；已知边界——S 行出现在 `## ` 二级标题前未结算（与 check-plan-dispatch Phase 状态机同源，不影响 S-unit 表均在 Phase 段内的 canonical 格式）

#### [sub:8-code-assistant] S8 selftest-subagent-granularity-skill-escort.sh 新建（Rule 59.6 静态守护机器面）
- 产出：worktree `skills/task-planner/scripts/selftest-subagent-granularity-skill-escort.sh`（246 行，23 断言 SG-01..SG-23，实测 Total: 23 PASS=23 FAIL=0 exit 0）+ `scripts/selftest-registry.tsv` 仅追加 1 行（4 列对齐既有行，既有行零改动，diff +1/-0）
- 断言面（六文件锚全覆盖）：critical-rules.md `^### 59 `=1 / `^59\.[1-7] `=7 / 七子条字面锚各=1（59.1 行含 enforce、59.2 行含「首动作 Read」、59.3 行含「可用强化技能」∧「仅提示用户可手动激活」、59.4 行含「先拆细再派」、59.5 行含「分段」）；templates/task_plan.md 表头行锚定 `| ID ...粒度(三值)|伴飞技能|`=1（行首锚定防契约注释行同字面误计数——全文裸计数伴飞技能=2 属预期，首版 SG-13 按全文=1 误报 FAIL 后改行锚定修复）；templates/knowledge-brief.md「§6 可用强化技能清单」=1；templates/subagent_dispatch.md「### 伴飞技能」=1+「九字段」≥1（既有 22.4 面防破坏）；scripts/check-dispatch.sh「Rule 59.1 粒度三值硬门」≥1+「Rule 59.2 伴飞路径不存在」≥1；scripts/analyze-splits.sh -x 可执行；config.json 零新键负断言（granularity/skill_escort/escort_skill 字面=0）
- 负断言自测：SKILL_ROOT 支持 env 覆盖（`SG_SKILL_ROOT`，默认=脚本上级目录，本体零触碰）；mktemp 临时副本删 task_plan.md 表头「伴飞技能」列→SG-13 FAIL exit 1，证明断言非恒真；恢复（副本即弃）后 23/23 PASS
- 负结果：selftest-registry.sh T02 报「未登记: selftest-periodic-review.sh」为**存量问题**（该脚本在本仓 master 已存在而 registry 无行，与本单元无关，本单元新增行已登记且 T03/T04/T05 PASS）；未 git add/commit；worktree 其他 M 文件（S1-S7 产物）零触碰

#### [sub:9-code-runner] S9 全量 selftest 回归跑批 + master 对照归属（task-v144，2026-10-08）
- 口径：worktree 57 脚本全量批跑（cwd 剥离 /tmp，TMPDIR 隔离，每脚本 `timeout -k 5 120`；批产物 /tmp/tp144/wt-out/{summary.tsv,logs/}；最长 selftest-final-gate-hash 17.0s，零超时）+ master da1f308 同口径 57 脚本对照批跑（/tmp/tp144/master-out/）+ 新守护单跑复验；详表 subagent-state/9-code-runner.md
- 结果（验收①逐脚本原文行 57 条如下，主进程机械求和；`~` 为同脚本多 FAIL 行分隔符）：

```
selftest-active-plan.sh rc=0 :: Total: 29 PASS=29 FAIL=0
selftest-agent-coverage.sh rc=1 :: Total: 9 PASS=8 FAIL=1 SKIPPED=0 :: FAIL: AC-07 FAIL config.json properties 键数=42（应 40，零新键承诺被破坏）
selftest-ask-default-timeout.sh rc=1 :: Total: 11 PASS=10 FAIL=1 :: FAIL: RT-09 FAIL config.json properties 键数=42（应 40）
selftest-batch-pilot.sh rc=0 :: Total: 10 PASS=10 FAIL=0
selftest-capability-persistence.sh rc=1 :: Total: 20 PASS=19 FAIL=1 :: FAIL: CP-16 FAIL config.json properties 键数=42（应 40，零新键被破坏）
selftest-check-conflicts.sh rc=0 :: Total: 7 PASS=7 FAIL=0
selftest-check-drift.sh rc=0 :: Total: 6 PASS=6 FAIL=0
selftest-conclusion-discipline.sh rc=0 :: Total: 24 PASS=24 FAIL=0
selftest-context-hygiene.sh rc=0 :: Total: 12 PASS=12 FAIL=0
selftest-delegation.sh rc=0 :: Total: 38    PASS=38  FAIL=0
selftest-dispatch-grain.sh rc=0 :: Total: 10 PASS=10 FAIL=0
selftest-dispatch.sh rc=0 :: Total: 31 PASS=31 FAIL=0
selftest-error-loop.sh rc=0 :: Total: 16 PASS=16 FAIL=0
selftest-execution-honesty.sh rc=0 :: Total: 14 PASS=14 FAIL=0
selftest-execution-stability.sh rc=1 :: Total: 19  PASS=18  FAIL=1 :: FAIL: [FAIL] T10a knowledge-brief.md 五段 grep -c '^## §' = 5
selftest-fallback.sh rc=0 :: Total: 31  PASS=31  FAIL=0
selftest-final-gate-hash.sh rc=0 :: ==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====
selftest-fine-grain-steps.sh rc=0 :: Total: 11 PASS=11 FAIL=0
selftest-interaction.sh rc=0 :: Total: 11 PASS=11 FAIL=0
selftest-iteration-persistence.sh rc=1 :: Total: 18 PASS=16 FAIL=2 :: FAIL: IP-14 FAIL critical-rules.md 57 块尾「58.x」=8（应 =0，58 号被顺手创建）~IP-15 FAIL config.json properties 键数=42（应 40，零新键被破坏）
selftest-iterative-optimizer.sh rc=0 :: Total: 8 PASS=8 FAIL=0
selftest-knowledge-brief.sh rc=1 :: Total: 16  PASS=15  FAIL=1 :: FAIL: [FAIL] T1b 五段标题 grep -c '^## §' = 5
selftest-lane-advancement.sh rc=1 :: Total: 14 PASS=12 FAIL=2 :: FAIL: LA-12 FAIL SKILL.md 主锚 'Rules 1-39' 命中=1（应 =2，SR-07 主锚被改动）~LA-14 FAIL config.json properties 键数=42（应 40，Rule 49 零新键被破坏）
selftest-mechanism-profile.sh rc=0 :: Total: 19 PASS=19 FAIL=0
selftest-media-agents.sh rc=1 :: Total: 10 PASS=9 FAIL=1 :: FAIL: MA-10 FAIL config.json properties 键数=42（应 40，零新键承诺被破坏）
selftest-media-dispatch.sh rc=1 :: Total: 9 PASS=8 FAIL=1 :: FAIL: MD-08 FAIL config.json properties 键数=42（应 40，Rule 47 零新键被破坏）
selftest-methodology.sh rc=0 :: Total: 16 PASS=16 FAIL=0
selftest-periodic-review.sh rc=1 :: Total: 10 PASS=5 FAIL=5 :: FAIL: PR-03 FAIL Rule 57 前后对照检查维度缺失~PR-04 FAIL Rule 57 自动纠正机制缺失~PR-05 FAIL Rule 57 开关键缺失~PR-09 FAIL selftest-registry.tsv 注册缺失~PR-10 FAIL SKILL.md C39 引用缺失
selftest-plan-dispatch.sh rc=0 :: Total: 12 PASS=12 FAIL=0
selftest-plan-tier.sh rc=0 :: Total: 32 PASS=32 FAIL=0
selftest-reflect-verify.sh rc=0 :: Total: 12 PASS=12 FAIL=0
selftest-registry.sh rc=1 :: Total: 5 PASS=4 FAIL=1 (registry rows=56, actual selftest=57) :: FAIL: T02 FAIL 未登记: selftest-periodic-review.sh 
selftest-reliability-institution.sh rc=1 :: Total: 16 PASS=15 FAIL=1 :: FAIL: R-12 FAIL config.json properties 键数=42（应 40）
selftest-requirement-coverage.sh rc=1 :: Total: 23 PASS=20 FAIL=3 :: FAIL: RC-11 FAIL SKILL.md 主锚 'Rules 1-39' 命中=1（应 =2）或 '1-40' 变体非 0（SR-07 主锚被改动）~RC-13 FAIL config.json properties 键数=42（应 40，Rule 51 零新键被破坏）~RC-15 FAIL critical-rules.md '56.' 子条命中=5（应 =0，编号假设被破坏）
selftest-requirement-grading.sh rc=1 :: Total: 7 PASS=6 FAIL=1 :: FAIL: RG-07 FAIL config.json properties 键数=42（应 40，Rule 50 零新键被破坏）
selftest-rescue-chain.sh rc=0 :: Total: 11 PASS=11 FAIL=0
selftest-review-library.sh rc=0 :: Total: 15 PASS=15 FAIL=0
selftest-root-resolution.sh rc=0 :: Total: 17 PASS=17 FAIL=0
selftest-rule23-conflict-scan.sh rc=0 :: Total: 3 PASS=3 FAIL=0
selftest-rule-reserve.sh rc=0 :: Total: 10 PASS=10 FAIL=0
selftest-self-resolution.sh rc=1 :: Total: 13 PASS=10 FAIL=3 :: FAIL: SR-07 FAIL SKILL.md 字面锚漂移（Rules 1-39=1 应 2 / 1-40=0 应 0）~SR-09 FAIL config.json properties 键数=42（应 40）~SR-12 FAIL registry 漂移（selftest-self-resolution 命中 1 应 ≥1 / 总行数 57 应 58=脚本数+表头）
selftest-shared-tracker.sh rc=0 :: Total: 11 PASS=11 FAIL=0
selftest-skill-collab.sh rc=0 :: Total: 25  PASS=25  FAIL=0
selftest-skill-modify.sh rc=0 :: Total: 9 PASS=9 FAIL=0 (SKIP=0)
selftest-skill-split.sh rc=0 :: Total: 41  PASS=41  FAIL=0
selftest-smart-merge.sh rc=0 :: Total: 17 PASS=17 FAIL=0
selftest-subagent-granularity-skill-escort.sh rc=0 :: Total: 23 PASS=23 FAIL=0
selftest-sync-index.sh rc=0 :: Total: 13 PASS=13 FAIL=0
selftest-task-boundary.sh rc=0 :: Total: 11 PASS=11 FAIL=0
selftest-template-lifecycle.sh rc=0 :: Total: 24 PASS=24 FAIL=0
selftest-template-sense.sh rc=0 :: Total: 8 PASS=8 FAIL=0
selftest-tier-b.sh rc=0 :: Total: 18 PASS=18 FAIL=0
selftest-tool-selection.sh rc=1 :: Total: 12 PASS=10 FAIL=2 :: FAIL: TS-05 FAIL SKILL.md 字面锚漂移（Rules 1-39=1 应 2 / 1-40=0 应 0）~TS-12 FAIL config.json properties 键数=42（应 40）
selftest-user-instruction-priority.sh rc=0 :: === ALL PASS ===
selftest-vc-gate.sh rc=0 :: Total: 11 PASS=11 FAIL=0
selftest-veto.sh rc=0 :: Total: 13 PASS=13 FAIL=0
selftest-workflow-orchestration.sh rc=1 :: Total: 16 PASS=14 FAIL=2 :: FAIL: WF-10 FAIL Rules 1-39+1-45 命中总和 5 <6~WF-12 FAIL config.json properties 键数=42（应 40）
```

- 新守护验收③：selftest-subagent-granularity-skill-escort.sh 在列且 rc=0 `Total: 23 PASS=23 FAIL=0`（单跑复核同）
- 归属（验收②，双跑定位）：worktree rc=1 ×17；其中 9 脚本与 master 败绩逐行相同=存量（agent-coverage/ask-default-timeout/capability-persistence/media-agents/media-dispatch/periodic-review/registry/reliability-institution/requirement-grading；根因簇=config.properties 实键 42 vs 断言应 40 + periodic-review 未登记 registry，两仓 config.json diff IDENTICAL）；另 8 脚本含 worktree-only 失败（master 同断言 PASS）：
  - ① knowledge-brief 六段化未级联（v144 S4 加 §6 直接后果）：selftest-knowledge-brief.sh T1b、selftest-execution-stability.sh T10a（断言 `-eq 5`，实 6；取证 `grep -c '^## §'`：base a7c01a8=5 / master=5 / worktree=6）
  - ② SKILL.md 'Rules 1-39' 锚漂移（v144 S2 把 References 行 `Critical Rules 1-39`→`1-59`）：TS-05 / SR-07 / LA-12 / RC-11 / WF-10（取证 `grep -c 'Rules 1-39'`：base=2 / master=2 / worktree=1）
  - ③ selftest-iteration-persistence.sh IP-14（57 块尾「58.x」=8 应 0）：worktree 脚本=base 版断言（58.x=0）而 base 树已含 v142 Rule 58 块 → 基线自带缺口（base 即败）；master 已由 v143 级联（59.x=0）通过 → 非 v144 引入；前向风险：worktree 57 块后 `^59\.[0-9] `=8（v144 Rule 59 块），master 版断言（59.x=0）若原样用于合并后树将必 FAIL，需按 v143 同范式再级联
- 反向核查：无 worktree PASS / master FAIL 的脚本；master 独有 selftest-evidence-goal-gate.sh（task-v143 产物，21/21 PASS）不在本分支，合并时 registry 行需并存
- 写面：两仓跑批零写入（worktree git status 与批前一致；脚本 fixture 全 mktemp/$TMPDIR，grep 验证无仓库相对路径写入）；未修复任何 FAIL、未 git add/commit（Scope 禁改）

#### [sub:10-code-assistant] 合并级联：两个 selftest 五段定数断言 5→6 同步（task-v144 S10，2026-10-08）
- 背景：S4 为 templates/knowledge-brief.md 纯增量追加「## §6 可用强化技能清单（Rule 59.3）」区块（预期演进非破坏），S9 跑批定位 worktree-only FAIL=9-code-runner 归属①（knowledge-brief 六段化未级联，断言 `-eq 5` 实 6）
- 产出：worktree 两脚本共 5 处同步（断言+docblock+诊断串三同步，级联锚注释统一为 `[2026-10-08 task-v144 合并级联] 五段→六段（§6 技能扫描区块，Rule 59.3）`）：
  - selftest-knowledge-brief.sh：头注释 L3「五段骨架」→「六段骨架」+级联锚行；T1 段注释「五段标题」→「六段标题」；T1b 断言名 `grep -c '^## §' = 5` → `= 6（级联锚）` 且条件 `-eq 5` → `-eq 6`
  - selftest-execution-stability.sh：T10 段注释「五段 = 5」→「六段 = 6」+级联锚行；T10a 断言名 `= 5` → `= 6（级联锚）` 且条件 `-eq 5` → `-eq 6`
- 验证（实跑原文行）：`bash selftest-knowledge-brief.sh` → `Total: 16  PASS=16  FAIL=0` exit 0（T1b PASS）；`bash selftest-execution-stability.sh` → `Total: 19  PASS=19  FAIL=0` exit 0（T10a PASS）；S9 两 FAIL 项（归属①两条）消除
- 取证：模板 `grep -n '^## §'` 现 6 个区块（L71 §6「可用强化技能清单（Rule 59.3 — 执行前技能扫描）」）
- 负结果：git status/diff 仅两目标文件（selftest-knowledge-brief.sh +7/-5 口径内、selftest-execution-stability.sh +5/-2 口径内）；未 git add/commit；worktree 其余 M 文件（S1-S9 产物）零触碰

#### [sub:12-code-assistant] 合并级联：lane-advancement + requirement-coverage 锚/键数/负断言对象演进（task-v144，2026-10-08）
- 背景：S9 跑批定位 worktree-only FAIL 归属②（SKILL.md 'Rules 1-39' 锚漂移，LA-12/RC-11）+ 键数 40→42（LA-14/RC-13）+ RC-15 负断言对象 '^56.'=5 过时（Rule 56 由 task-v140 合法落地 56.1-56.5）
- 产出：worktree 两脚本共 8 处同步（断言+docblock+诊断串三同步，级联锚注释统一为 `[2026-10-08 task-v144 合并级联] ...原因...`）：
  - selftest-lane-advancement.sh：LA-12 `'Rules 1-39'=2` → `'Critical Rules 1-62'≥1 且 '1-39'=0`（参照 selftest-tool-selection.sh TS-05 / selftest-self-resolution.sh SR-07 刚完成范式）；LA-14 键数 40→42；头注释 L5 键数 40→42
  - selftest-requirement-coverage.sh：RC-11 同 LA-12 范式演进（'1-40'=0 变体随主锚漂移失去意义，并入 '1-39'=0 负断言）；RC-13 键数 40→42；RC-15 负断言对象 '^56.'→'^63.'（56/57/58/59/60/62 号均已落地、61 预留未落地（SKILL.md L9 括注明示「61 预留未落地」），下一未用编号=63，=0 保持负断言语义：防顺手创建未登记新号）；RC-23 注释内 RC-15 引用同步；头注释 L5 键数 40→42
- 验证（实跑原文行）：`bash selftest-lane-advancement.sh` → `Total: 14 PASS=14 FAIL=0` exit 0（LA-12/LA-14 PASS）；`bash selftest-requirement-coverage.sh` → `Total: 23 PASS=23 FAIL=0` exit 0（RC-11/RC-13/RC-15 PASS）
- 取证：SKILL.md L273 `grep -c 'Critical Rules 1-62'`=3 / `'Rules 1-39'`=0 / `'1-39'`=0；config.json `jq '.properties | length'`=42；critical-rules.md `^56.`=5、`^63.`=0、`^62.`=6、`^61.`=0
- 负结果：git diff 仅两目标文件；未 git add/commit；worktree 其余 M 文件（S1-S11 产物）零触碰；WF-10（'Rules 1-39'+1-45 总和断言）与 execution-stability IP-14（58.x 负断言）不在本 S-unit 范围

## Technical Decisions
- 伴飞机制选 Read 路径而非改 agent 定义（证据：工具面扫描）；comet 不自动激活（证据：frontmatter 设计）；Rule 58 已被 v142 落地、v143 预留冲突由其自行改号，本任务 Rule 59

#### [sub:14-code-assistant] IP-14/IP-15 级联修复 + registry.tsv 补登（iteration-persistence FAIL 清零）
- IP-14：负断言对象 `^59\.[0-9]`→`^63\.[0-9]`（63=首个全未占用号：59=v144 已落 59.1-59.8、60=v142、62=v145 已落地、61 预留未落地；取证 `grep -cE '^59\.[0-9] '`=8、`'^6[0-9]\.[0-9] '`=14、`'^63\.[0-9] '`=0）；三同步=断言+docblock（L21 负断言条目+L40 Why 段）+诊断串
- IP-15：config properties 键数 40→42（`jq '.properties|keys|length'`=42，v145 合法加 2 键、FF 守护 42 为准）；Rule 57 自身仍零新键（IP-16 未动）；三同步=断言+docblock（L23 条目+L176 Why 加级联注释）+诊断串（jq/python3 双分支）
- 附带级联（本脚本范围内）：IP-12 宽容正则 `Rule 40-5[5-9]`→`Rule 40-[56][0-9]`——SKILL.md 全集声明已演进为「Rule 40-62」（L273），旧正则失配 =0，属同 S-unit 目标 A 内合法级联
- registry.tsv 补登 selftest-periodic-review.sh 1 行（master 存量脚本从未登记=T02/SR-12 根因）：守护对象=Rule 57 周期性回顾与前后对照 PR-01..10（五维度锚/periodic-review.sh 可执行/config 双键/registry 自登记/SKILL C39），触发条件对齐 brief 口径，dep_anchors 取自脚本实际引用文件
- 验证（实跑原文行）：`bash selftest-iteration-persistence.sh` → `Total: 18 PASS=18 FAIL=0`；`bash selftest-registry.sh` → `Total: 5 PASS=5 FAIL=0 (registry rows=59, actual selftest=59)`；`bash selftest-self-resolution.sh` → `Total: 13 PASS=13 FAIL=0`
- 负结果：本 S-unit 仅改 2 文件（selftest-iteration-persistence.sh + selftest-registry.tsv）；未 git add/commit；worktree 内其余 9 个 M 文件为前序 S1-S11 单元既有产物，零触碰

#### [sub:15-code-assistant] 存量清账：7 脚本 config properties 键数 40→42（task-v144 S15，2026-10-08）
- 背景：v145 合法新增 2 键（config=42，FF 守护 42 为准），7 个 master 存量 selftest 的键数断言 40 未级联（S9 跑批 CP-16/R-12 FAIL 定位；RT-09/AC-07/MA-10/MD-08/RG-07 同定数属同型遗留，S9 时脚本未整体 FAIL 系断言尚未咬合或他项先 FAIL）
- 产出（worktree 7 脚本，三同步=断言+docblock+诊断串，级联锚统一 `[2026-10-08 task-v144 合并级联: v145 新增 2 键(config=42),FF 守护 42 为准,旧定数 40→42]`）：
  - selftest-agent-coverage.sh AC-07（头注释 L6 + 段注释 + ok/bad 串）
  - selftest-ask-default-timeout.sh RT-09（头注释 L13 + 段注释 + ok/bad 串）
  - selftest-capability-persistence.sh CP-16（头注释 L11 + 段注释 + jq/python3 双分支 ok/bad 串 + Why 内 tsv 口径注）
  - selftest-media-agents.sh MA-10（头注释 L6 + 段注释 + ok/bad 串）
  - selftest-media-dispatch.sh MD-08（头注释 L5 + 段注释 + ok/bad 串）
  - selftest-requirement-grading.sh RG-07（头注释 L5 + 段注释 + ok/bad 串）
  - selftest-reliability-institution.sh R-12（头注释 L17 + 段注释 + ok/bad 串）
- 附带级联（超出 7 定数清单、同 worktree 内合法级联，参照 sub:14 IP-12 先例——SKILL.md 全集声明 L273 已演进为「Rule 40-62」，旧固定/宽容锚失配）：
  - selftest-capability-persistence.sh CP-05 `40-55`=1 → 宽容正则 `40-[56][0-9]`=1；CP-06 负断言对象 `40-53`→`40-5[3-9]`（覆盖 40-53..40-59 全部旧纪元字面）；头注释 L7/L24 同步
  - selftest-reliability-institution.sh R-09 宽容正则 `40-5[3-9]`→`40-[56][0-9]`（语义强度不降：仍宽容锚不钉死）；头注释 L13 + ok/bad 串同步
- 验证（实跑原文行，7/7 FAIL=0）：
  - `bash selftest-agent-coverage.sh` → `Total: 9 PASS=9 FAIL=0 SKIPPED=0`
  - `bash selftest-ask-default-timeout.sh` → `Total: 11 PASS=11 FAIL=0`
  - `bash selftest-capability-persistence.sh` → `Total: 20 PASS=20 FAIL=0`
  - `bash selftest-media-agents.sh` → `Total: 10 PASS=10 FAIL=0`
  - `bash selftest-media-dispatch.sh` → `Total: 9 PASS=9 FAIL=0`
  - `bash selftest-requirement-grading.sh` → `Total: 7 PASS=7 FAIL=0`
  - `bash selftest-reliability-institution.sh` → `Total: 16 PASS=16 FAIL=0`
- 取证：config.json `jq '.properties|keys|length'`=42；改前 stash 对照实跑 CP-16/R-12 FAIL（键数=42 应 40）确认根因；SKILL.md `grep -noE '40-[0-9]+'` 仅 L273 `40-62` 1 处
- 负结果：本 S-unit 仅改 7 目标文件（git diff 核过，无范围外触碰）；未 git add/commit；7 文件超 step_max_files(2) 为计划表已登记的 L0 轻量通道例外（Rule 38.7 精神，同质单行定数批量清账）

#### [sub:16-code-assistant] 锚长尾清账：7 selftest 宽容正则扩 6x 纪元（task-v144 S16，2026-10-08）
- 7 脚本 FAIL 锚统一演进口径（v136 宽容正则优先 + SR-08 `40-(5[3-9]|6[0-9])` 范式）：
  - selftest-conclusion-discipline.sh CD-11 双锚 n45 面 `1-4[5-9]|1-5[0-9]`→`1-[4-6][0-9]`（单锚合并扩面，旧 4x/5x 保留兼容 + 6[0-2] 纳入，合计 ≥3 阈值语义零改动）
  - selftest-error-loop.sh EL-11 `Rules 1-3[1-9]`→`Rules 1-(3[1-9]|[4-6][0-9])`（现状命中 L274 Rules 1-12 / L290 Rule 1-28 两落点）
  - selftest-execution-honesty.sh EH-09 `Rule 40-5[3-9]`→`Rule 40-(5[3-9]|6[0-9])`（现状 40-62，命中=1）
  - selftest-reflect-verify.sh RV-10 `Rules 1-3[5-9]`→`Rules 1-(3[5-9]|[4-6][0-9])`
  - selftest-skill-split.sh T-锚 固定字面 `grep -c 'Rules 1-3'`→宽容 `grep -cE 'Rules 1-(3[0-9]|[4-6][0-9])'`（1-62 纪元旧字面零命中=级联漏改面，兜底面 3[0-9] 全 3x 保留）
  - selftest-veto.sh VT-10 `Rules 1-3[1-9]`→`Rules 1-(3[1-9]|[4-6][0-9])`（同 EL-11 范式）
  - selftest-root-resolution.sh RR-09 主断言 `Critical Rules 全集 1-5[3-9]`→`1-(5[3-9]|6[0-9])`（现状 1-62）+ 负断言旧纪元清单 1-(51|53)→1-(51|53|55)（强度不减弱）；RR-16 定位字面 `'（Rules 1-39'` 在 1-62 纪元 SKILL.md 零命中（括注已演进「详见 `references/critical-rules.md`（Critical Rules 1-62…」）→ 定位改 `'详见 `references/critical-rules.md`（Critical Rules'`（=1）+ 主断言 `Rule 40-5[3-9]`→`40-(5[3-9]|6[0-9])`，兜底判定（50 与 53 逐号式）保留
- 验证（实跑原文行，7/7 FAIL=0，exit 0）：
  - `bash selftest-conclusion-discipline.sh` → `Total: 24 PASS=24 FAIL=0`
  - `bash selftest-error-loop.sh` → `Total: 16 PASS=16 FAIL=0`
  - `bash selftest-execution-honesty.sh` → `Total: 14 PASS=14 FAIL=0`
  - `bash selftest-reflect-verify.sh` → `Total: 12 PASS=12 FAIL=0`
  - `bash selftest-skill-split.sh` → `Total: 41  PASS=41  FAIL=0`
  - `bash selftest-veto.sh` → `Total: 13 PASS=13 FAIL=0`
  - `bash selftest-root-resolution.sh` → `Total: 17 PASS=17 FAIL=0`
- 取证：SKILL.md `grep -cE 'Critical Rules 全集 1-(5[3-9]|6[0-9])'`=1 / `(全集|Rules) 1-(51|53|55)`=0；`'详见 `references/critical-rules.md`（Critical Rules'`=1；`'Rule 40-(5[3-9]|6[0-9])'`=1；级联注释 `[2026-10-08 task-v144 合并级联]` 断言+docblock+诊断串三同步
- 负结果：本 S-unit 仅改 7 目标文件（git diff 7 文件逐一核过；worktree 其余 M 文件=前序 S1-S15 既有产物零触碰）；periodic-review.sh PR-03/04/05 登记遗留未触碰（禁修面）；未 git add/commit；7 文件超 step_max_files 为计划表 L0 轻量通道例外（同 sub:15 先例）

#### [sub:17-code-assistant] CR 闭环修复 P1-2 + P2-1（task-v144 S17，2026-10-08）
- P1-2 粒度门控落地（方案 a）：check-plan-dispatch.sh 既有 S-unit 行解析区（$7 时长校验之后）新增 $8 粒度三值列校验——`awk -F'|' '{print $8}'` trim 后匹配 `^([0-9]+)f/([0-9]+)l/([0-9]+)min$`；三值逐一对 jq 读 `subagent.step_max_files/step_max_lines/step_max_minutes`（新增 STEP_MAX_LINES 解析，同双层路径范式，缺失回退 2/100/15）超限 → add_violation（enforce 拒锁，提示串含「Rule 59.1 粒度三值硬门」）；列空→SKIPPED「粒度三值未填报（Rule 59.1 强制）」fail-open（旧格式兼容）；格式漂移→SKIPPED 提示
- 计划内必要附加行为（CR 验收项 4 要求 check-plan-dispatch.sh <本任务计划> exit 0，与本计划 S15「7f/14l/10min 文件数例外登记」行冲突）：行内含「例外」标记的超限 S-unit 降为 SKIPPED 留痕不阻断（S15 存量批量工序 L0 轻量通道先例），防 59.1 硬门误杀已登记例外的存量行；critical-rules.md 59.1 措辞同步落此例外放行口径
- P2-1 消费侧三落点（SKILL.md）：C43 合规清单行（Rule 59 自查，C42 之后 L212）+ 执行循环 2.5 委派检查点段追加 Rule 59 指针（L86 行末）+ Critical Rules 摘要 bullet 补 Rule 59 一行（L320，Rule 58 与 62 bullet 之间）
- P2-4：critical-rules.md 文件尾补行尾换行（tail -c1 → 0a）
- 三 fixture 实测：超限 3f/150l/20min→exit 1 三条 violation 均含「Rule 59.1」；合规 1f/50l/10min→exit 0；无粒度列旧格式→SKIPPED+exit 0；本计划 task_plan.md→exit 0（S15 例外留痕）；v143 计划回归 exit 0
- 守护回归：selftest-subagent-granularity-skill-escort.sh 23/23 PASS；selftest-plan-dispatch/fine-grain-steps/plan-tier/conclusion-discipline FAIL=0
- 已知残余（非本 S-unit 范围）：selftest-final-gate-hash.sh 键④枚举断言漂移 1 项（check-plan-dispatch.sh 新增消费 subagent.step_max_lines 键，FG 五键枚举需同步更新=后续 S-unit 或合并级联面，master 基线 PASS=22→本改动后 FAIL=1 可归因于本键新增）
- 负结果：git diff 仅三目标文件（check-plan-dispatch.sh +47 / critical-rules.md 59.1 措辞+尾换行 / SKILL.md +4 行落点）；check-dispatch.sh 与 analyze-splits.sh 未触碰（前序 S6/S7 产物）；未 git add/commit

#### [sub:18-code-assistant] CR 闭环收尾四项：P2-2 八子条统一 / P2-3 注释修正 / P2-5 local 卫生 / FG 键级联（task-v144 S18，2026-10-08）
- P2-2 八子条统一：selftest-subagent-granularity-skill-escort.sh SG-02 断言 `^59\.[1-7] `=7 → `^59\.[1-8] `=8（59.8 关系澄清子条对齐 Rule 58.8/60.7 惯例入守护，SG-04..SG-10 保持前七条字面锚不加独立 59.8 断言，与 58.8 同范式）；selftest-registry.tsv 本任务行 trigger 列「59.1-59.7 七子条文本锚」→「59.1-59.8 八子条文本锚」（仅该行内改写）
- P2-3 注释修正：analyze-splits.sh :148 原注「缺段按 0 计——部分填报也体检已报值」与实现相反（实际缺段/畸形走 regex 不命中→SKIPPED 放行不计违规，与头注释口径一致）→ 改正并加级联注释
- P2-5 local 卫生：check-dispatch.sh fine_grain_checks 顶部 local 声明补入 ⑥⑦ 新增未声明变量 fmax/lmax/mmax/gtok/gfv/grange/gl/gm/esrcs/er/epath/p（原泄漏外层 shell 变量域；行为零变化，31+10+11 断言全过验证）
- FG 键级联（解 S17 blocker）：selftest-final-gate-hash.sh 键④枚举 五键→六键补 subagent.step_max_lines（S17 check-plan-dispatch ⑤-c 粒度三值门新消费该键致漂移），级联注释 `[2026-10-08 task-v144 合并级联: check-plan-dispatch ⑤-c 新消费键]` 齐备
- 实跑验收：SG 守护 `Total: 23 PASS=23 FAIL=0`（SG-02 过）；analyze-splits 双 fixture 判据不变（超限 3f/150l/20min→rc 1 建议拆 2 子单元 / 合规 1f/45l/10min→rc 0）；selftest-dispatch `Total: 31 PASS=31 FAIL=0`、selftest-dispatch-grain `Total: 10 PASS=10 FAIL=0`、selftest-fine-grain-steps `Total: 11 PASS=11 FAIL=0`；selftest-final-gate-hash `PASS=22 FAIL=0`（原 PASS=21 FAIL=1 → 枚举修复后 FAIL 清零）
- 负结果：git diff 本 S-unit 仅 5 目标文件（SG 守护/registry/analyze-splits/check-dispatch/final-gate-hash；worktree 其余 M 文件=前序 S17 既有产物零触碰）；periodic-review PR×4 登记遗留未触碰（禁修面）；未 git add/commit
