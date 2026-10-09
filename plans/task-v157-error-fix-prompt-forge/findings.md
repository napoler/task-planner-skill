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

#### [sub:01-explore] 存量能力侦察结论（Phase 1 S1）

**能力清单（与错误排查/提示词生成相关）：**

| 名称 | 位置 | 职责 |
|------|------|------|
| systematic-debugging | ~/.agents/skills/systematic-debugging/SKILL.md | 系统化调试方法论：根因定位优先于修复（Iron Law: NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST） |
| debugger | ~/.zcode/agents/debugger.md | Agent 定义：根因分析→修复建议→回归隔离，先定位再动手 |
| prompt-corrector / prompt-master | ~/.zcode/skills/prompt-corrector/、~/.zcode/skills/prompt-master/ | 提示词修正 / 提示词工程 |
| skill-fix / skill-evolve | ~/.zcode/skills/ | Skill 修复 / 演进 |
| code-quality-review / general-review / security-review / test-quality-review | ~/.zcode/skills/ | 通用/安全/测试质量审查族 |
| verification-before-completion | ~/.zcode/skills/ | 完成前验证 |
| iterative-optimizer | /mnt/data/dev/task-planner-skill/skills/iterative-optimizer/ | 仓库内迭代优化 skill（顶层 skill 结构范式） |

**边界清单（新 skill error-fix-prompt-forge 不得做什么，各指名对应既有能力）：**
1. 不得做根因定位/调试——systematic-debugging（~/.agents/skills/systematic-debugging/）+ debugger agent（~/.zcode/agents/debugger.md）
2. 不得做代码修改/修复实施——debugger agent 工作流第 4 步「修复」
3. 不得做通用提示词工程——prompt-master / prompt-corrector（~/.zcode/skills/）
4. 不得做代码质量/安全/测试审查——code-quality-review / security-review / test-quality-review
5. 不得做完成前验证——verification-before-completion
6. 不得做 skill 维护/修复——skill-fix / skill-evolve

**fix-prompts.md 形态摘要（≤10 行）：**
- 三条提示词 A/B/C：A=事后审计（溯源审计逐句三态判定）；B=事前自检（写入前 5 问）；C=传播面契约行（防幻觉契约）
- 形态=自包含修正任务书：目标/背景/口径/输出契约/铁律，可直接复制使用；Agent 派发时补 8 字段返回模板+checkpoint 路径
- 来源：plans/task-v153-parallel-scheduling/fix-prompts.md:1-56

**对本设计的含义**：仓内确无「排查结果→修正任务书」转换类能力（debugger 止于修复建议，fix-prompts.md 是 v153 一次性产物非 skill）→ 新建 skill 差异化成立；新 skill 职责收窄为：消费已定位结论+锻造可派发任务书，不重排查、不实施修复。

#### [sub:02-code-assistant] SKILL.md 编写记录

- 落盘: skills/error-fix-prompt-forge/SKILL.md（worktree 内，84 行 ≤100）；结构 11 项按 knowledge-brief.md §5 设计定稿详述逐项实现，文风对齐 iterative-optimizer/SKILL.md（97 行范式）
- 验收自跑: wc -l=84；六区块锚（触发条件/执行前输入契约/执行流程/QC-FP/门控铁律/反模式）grep 各 1 处；frontmatter name=目录名（:2）；尾部锚 task-v157-error-fix-prompt-forge（:84）；Step 0-4/QC-FP-1..6/三态 READY·PARTIAL·BLOCKED 齐现
- 边界继承: 「不触发」4 条取自 [sub:01-explore] 边界清单 6 条中的相关项（未定位根因→排查族/一次性小修直接做/润色→prompt-master/审查→review 族）
- 交叉依赖（供 S2/S3 消费）: Step 3 引用模板路径 skills/error-fix-prompt-forge/templates/fix-prompt-template.md（S2 产物）；selftest FP-05/06 槽位锚须与本文件 Step 1 槽位表（问题陈述/根因+证据/影响面/复现/禁改区/验证判据/回滚/参考材料）对齐

#### [sub:03-code-assistant] 模板编写记录

- 落盘: skills/error-fix-prompt-forge/templates/fix-prompt-template.md（worktree 内，49 行 ≤60）；九槽位顺序按 knowledge-brief §5 设计定稿详述：① 任务与范围(问题陈述) ② 背景与根因(根因+证据) ③ 复现 ④ 约束与禁改区 ⑤ 执行步骤(枚举≤4) ⑥ 验收判据(≥1 机器可检查) ⑦ 验证命令 ⑧ 回滚 ⑨ 未验证假设区(可空) + 参考材料 + DoD 行
- 验收自跑: wc -l=49；九槽位锚 grep 各 ≥1（任务与范围/根因+证据/影响面/复现/禁改区/执行步骤/验收判据/验证命令/回滚/未验证假设区 均命中）；「定义完成(DoD)」行存在（末行）；每槽位 1 行 What+Why 填写注释（Rule 45）
- 槽位互现: Step 1 槽位表 8 词（问题陈述/根因+证据/影响面/复现/禁改区/验证判据/回滚/参考材料）模板中全部出现（8/8 ≥5，selftest FP-06 可过）

#### [sub:03b-code-assistant] selftest+registry 落盘记录

- 落盘: skills/task-planner/scripts/selftest-error-fix-prompt-forge.sh（82 行 ≤90，+x，最终落位见 [sub:06] 平移记录）；断言 FP-01..08 按 knowledge-brief §5 selftest 段定义逐项实现，风格对齐范例 selftest-iterative-optimizer.sh（SCRIPT_DIR 相对解析、ok()/bad()、Total 行、exit 语义同构，无写死 /home/terry）
- 验收自跑: bash 脚本 → FP-01..08 全 PASS（8/8），Total: 8 PASS=8 FAIL=0，EXIT=0；FP-02 六区块命中 7、FP-03 BLOCKED=6/根因未定位=6、FP-04 QC-FP 行 8≥6 且机器可检查 4≥1、FP-05 槽位命中 18≥8、FP-06 互现 6≥5、FP-07 registry 末行命中、FP-08 config.json grep=0
- registry: selftest-registry.tsv 仅末行追加 1 行（66→67 行），diff 校验 head -66 与追加前快照零差异（REG_HEAD66_UNCHANGED），既有 66 行零改动

#### [sub:06-code-assistant] 级联修复:selftest 位置平移

- 平移: skills/error-fix-prompt-forge/scripts/selftest-error-fix-prompt-forge.sh → skills/task-planner/scripts/selftest-error-fix-prompt-forge.sh（mv 保留 +x；空目录已 rmdir）。仓库惯例=全部 selftest 集中于 task-planner/scripts（iterative-optimizer 先例；selftest-registry.sh 的 actual 计数集只扫该目录，顶层 skill 自带 scripts/ 位置会被 T03 判孤儿）
- 路径解析修正（iterative-optimizer 范式，SCRIPT_DIR=task-planner/scripts → SKILL_ROOT=skills/task-planner）: SKILL/TPL=$SKILL_ROOT/../error-fix-prompt-forge/...，REG=$SCRIPT_DIR/selftest-registry.tsv，CFG=$SKILL_ROOT/config.json；无写死绝对路径；FP-01..08 断言逻辑零改动
- 三脚本回归（worktree 内 bash 自跑，主进程独立复跑一致）: fp 8/8 exit 0 + registry T01-T05 `Total: 5 PASS=5 FAIL=0 (registry rows=66, actual selftest=66)` + self-resolution SR-01..13 全 PASS（SR-12 动态口径 lines=67=脚本数 66+1）
- 全量回归: Round 3 find 去重 66 脚本 TOTAL=66 PASS=66 FAIL=0

#### [sub:04-executor] 行为冒烟记录（Phase 4 S1）

- 产物: subagent-state/04-executor/fix-prompt-sample.md（按模板九槽位渲染，修正目标=对 findings.md 跑提示词 A 溯源审计）+ subagent-state/04-executor/qc-fp-selfcheck.md（QC-FP-1..6 全 PASS）
- 三态结论: READY（无未验证假设区内容）
- 验收: QC-FP 机检 6/6 PASS（绝对路径 grep 7 行/证据锚 fix-prompts.md:3-5 Read 复核/grep -c 验收命令有效/单 S-unit 对照/无花括号占位符/未验证假设区存在且空）
- 修正目标选择理由: fixture 三条提示词中选提示词 A（溯源审计），因可执行+有机器可检查验收+单 S-unit 范围清晰

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| Phase 2 设计定稿：五步闭环=Step0 输入校验→Step1 结构化抽取→Step2 缺口分析→Step3 模板渲染→Step4 自检交付；QC-FP 6 条自检；三态结论 READY/PARTIAL/BLOCKED | 与 iterative-optimizer 五步闭环+状态文件范式同构降低学习成本；fail-closed 三处（输入/缺口/验收）对应根源覆盖表四缺陷面；边界 6 条（sub:01 侦察结论）写入「不触发」 |
| 模板独立成文件 templates/fix-prompt-template.md 而非内联 SKILL.md | 输出物是提示词本身，槽位模板是其 schema；selftest FP-05/06 可对模板做机械断言（v106 未用模板是因其输出为迭代摘要表；本 skill 输出为结构化任务书，模板即交付 schema） |
| selftest 断言 FP-01..08 全静态守护 | 静态断言=零依赖可重复；行为面由 Phase 4 冒烟承担（Rule 43.5 提示词类必须实际生成测试），两者互补不重复 |

#### [sub:aln-01] alignment-review 对齐审查结论（Phase 3，Rule 42.6）

**结论: APPROVED**（P0/P1=0；1 项 P2 建议不阻断）

机器可复现证据：
1. 登记联动: registry 67 行(66 数据+表头) ↔ `ls task-planner/scripts/selftest-*.sh | wc -l`=66，一一对应；selftest-registry.sh `Total: 5 PASS=5 FAIL=0 (registry rows=66, actual selftest=66)`
2. 计数级联: Round 1 回归暴露 2 处（T03 孤儿行/SR-12 计数）→ 平移修复后 Round 3 `TOTAL=66 PASS=66 FAIL=0`；修复仅路径块+头注释，FP-01..08 断言逻辑零改动
3. 引用完整性: SKILL.md 内全部跨实体指向（templates/fix-prompt-template.md、debugger、systematic-debugging、prompt-master/prompt-corrector、review 族、verification-before-completion）grep/ls 验存在（Phase 1 侦察证据+本 Phase 复跑）
4. 术语一致性: 「fix prompt/修正任务书/修正提示词」为 description 同义词簇（有意为之），正文统一用 fix-prompt，无新旧混用
5. 多副本同步: 当前仅 worktree 单副本；三宿主 diff 对账为 Phase 5 VC-6 门控，登记 pending 不视为缺陷
6. 变更日志: CHANGELOG.md 先例不含 skill 新建条目（v106 三文件先例 grep 实证）→ 不补登；INDEX.md 由 sync-todos.sh --index 在 Phase 5 终验前更新
7. 越界自检: 触及文件=SKILL.md/模板/selftest(平移后)/registry(+1 行)，与 scope_files 一致（位置修正已登记 Decisions Made）

变更记录（三要素）: ① 变更范围=worktree 4 文件（2 新建+1 平移新建+registry 末行+1）② 冲突处理=Round 1 两处计数级联已更新（裁决依据=registry actual 集口径+iterative-optimizer 先例），残留=0，P2=selftest 头注释可再补强（不阻断）③ 文档当前状态=4 文件一致、双向登记平衡、全量 ΣFAIL=0

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

#### [sub:08-code-assistant] CR 修复:断言加固
- P1-1 (FP-06): 槽位词 6 词宽 BRE 循环 → 候选 7 词（问题陈述/根因+证据/复现/禁改区/验证判据/回滚/参考材料）逐词 grep -qF 互现计数, 阈值 ≥5 不变; 实测 7/7
- P1-2 (FP-05): 宽 OR 累计（8 模式 grep -c 阈值 8, 近似恒真）→ 8 关键词（根因/复现/禁改区/验收/回滚/未验证假设区/DoD/验证命令）逐词独立 grep -qF 判定, 要求 8/8; n=0 兜底保证模板缺失时诊断值可靠; 注释口径「九槽位」→「八槽位锚, 逐词各 ≥1」（L14/59 头注+代码注释 3 处）
- P1-3 (FP-04): 全文 grep -c 'QC-FP-'（实测 8=表行 6+正文引用 2）→ 锚定表行 grep -c '^| QC-FP-'（实测=6）, 阈值 ≥6 不变
- P2-1: FP-05 FAIL 分支 n 有 0 兜底; FP-07 FAIL 分支附 registry 末行快照（tail -1 | cut -c1-60）
- Nit-1 (FP-01): name=目录名做实——head -5 内 grep -m1 '^name:' 取值 sed 归一, 与 SKILL.md 所在目录 basename 字符串相等比对, FAIL 分支附 name/dir 双值诊断
- 回归: bash -n OK; 85 行 ≤90; selftest-error-fix-prompt-forge 8/8 exit 0; selftest-registry 5/5 exit 0; selftest-self-resolution 13/13 exit 0

#### [sub:09-code-assistant] 合并级联修复:FP-07 含口径化
- 现象: 合并 master(v155 selftest-report-reviewability.sh 登记行与本脚本登记行解并集)后 registry 末两行为 report-reviewability + error-fix-prompt-forge, 原 FP-07「末行口径」断言(仅锁末行=本脚本)被跨任务追加登记行打破风险落地
- 根因: 末行钉口径与 registry 纯增量追加约定冲突(G-07 同源范式判例: v153 追加行曾打破 goal-unit G-07 末行口径)
- 修法: FP-07 改含口径——`n="$(grep -c 'error-fix-prompt-forge' "$REG" 2>/dev/null || true)"` + `[ "$n" -ge 1 ]` 判定(数据行出现 ≥1 即 PASS); PASS/FAIL 消息带 $n 诊断; 头注释 FP-07 行同步改「含口径登记」并注记本次合并级联原因(对齐 G-07 :106-108 写法)。FP-01..06/08 零改动
- 回归: bash -n OK; 89 行 ≤90; selftest-error-fix-prompt-forge 8/8 exit 0; selftest-registry T01-05 5/5 exit 0; selftest-self-resolution SR-12 动态口径 13/13 exit 0(registry 69 行=脚本 68+表头); selftest-report-reviewability RRV-01..13 13/13 exit 0(不受本改动影响, 复跑确认)
