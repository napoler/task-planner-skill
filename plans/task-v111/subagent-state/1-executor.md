# Checkpoint 1-executor — Phase 1 注释规范普查
status: in_progress
<!-- 22.8.3 纯 markdown 分段, append-only 里程碑 -->

## 已完成里程碑

- [16:0x] M1 Init: 读 task_plan/progress/findings 三文件 + 普查对象结构。75 脚本=72 selftest 外实际 scripts/*.sh 计数 72(ls 实数), 含 check-*/selftest-*/工具类。置信 HIGH
- [16:1x] M2 Part 1 条款现状完成。证据:
  - 技能侧 grep「注释|docstring|comment」命中: critical-rules.md:293(31.6 模板消费侧契约**注释**)、:370(38.4 口径注释, 纯增注释零语义变更)、:416(41.2 注释细节归自动消解)、:417(41.3 注释同步归 trivial)——全部为流程语义附带词, **无任何注释产出规范条款**
  - SKILL.md 全文 0 命中「注释/docstring/comment」
  - 仓根 CLAUDE.md/CONTRIBUTING.md/CONTRIBUTING_zh.md 0 命中(grep 注释|docstring|comment 无输出)
  - 宪法 §九 = /home/terry/.zcode/AGENTS.md:158-159: 修改现有函数须注明修改原因/时间/原行为; 新增函数有 docstring; 修 bug 注明现象+根因+修法; 禁止 TODO 替代修改说明; :159 结论写入注释
  - 缺口判定: 宪法有 4 项最小注释条款(修注/docstring/bug 三要素/禁 TODO), skill 侧 critical-rules Rules 1-44 **零映射**——尤其 ①无 What+Why 双层(设计思路入注释)要求 ②无头注释四要素 ③无「禁止为美观删减注释」反向条款(平台默认倾向克制注释, 与用户裁决相逆需显式声明) ④无机器承载。判定: HIGH 置信, skill 侧缺口成立
- [16:2x] M3 Part 2 级联面完成。Rules 1-44→1-45 口径级联全集(现状=「1-39」+括注含至 44 的混合口径):
  - critical-rules.md 尾部: 新增「### 45」段(44.4 后顺延, 现文件末行 451/452)
  - SKILL.md:9 frontmatter「Critical Rules 全集 1-39」→ 扩写锚(含 Rule 40-44 枚举)→ 加 /45
  - SKILL.md:246 「(Rules 1-39(含 Rule 40/41/42/43/44))」→ 加 45
  - SKILL.md:304 References 索引行「Critical Rules 1-39(含 ... Rule 44 ...)」→ 加「/ Rule 45 注释完整性规范」
  - SKILL.md Rule 摘要区(:278-280 Rule 43/44 行后)→ 加「- **Rule 45(注释完整性规范 — task-v111)**: ...」摘要行
  - SKILL.md 合规清单 C 表(C33 :198 后)→ 加 C34 行(消费面, 按 RT 范式)
  - CLAUDE.md:32「critical-rules.md ← Rules 1-39 核心执行约束」
  - README_zh.md:136 同句式 + :229「Rules 1-39 —— 自定义前必读」
  - selftest 宽容锚(需随 45 同批改, 否则负断言 FAIL):
    - scripts/selftest-reliability-institution.sh:76-77 R-09: `grep -c '含 Rule 40/41/42/43'` ≥1 ∧ `grep -c '1-40'`=0 —— 硬负断言, SKILL 出现「1-40」字面即 FAIL(括注若写成「含 Rule 40/41/42/43/44/45」含「1-40」? 不含——括注无「1-」前缀; 但索引行若升级「1-45」仍安全; R-09 括注需扩为含 44/45)
    - scripts/selftest-self-resolution.sh:64-67 SR-07: 「Rules 1-39」=2 且「1-40」=0 —— 字面锚, SKILL 升级 1-40+ 后「1-39」计数变 0 → SR-07 必改(宽容化 1-3[9]|1-4[0-9] 或字面改 1-44/1-45)
    - scripts/selftest-tool-selection.sh:53-56 TS-05: 同 SR-07 范式(=2/0) → 同批改
    - scripts/selftest-plan-tier.sh:75 PT-08: 「Critical Rules 全集 1-39」frontmatter 字面 → 同步
    - scripts/selftest-workflow-orchestration.sh:52-63 WF-10/WF-11: 4 索引文档(SKILL/CLAUDE/README_zh/skills/task-planner/README.md)「Rules 1-39」总和≥6 且「Rules 1-38」=0 → 升级 1-44/1-45 后 WF-10 改目标串
    - 宽容锚类(grep 1-3[5-9] 型): selftest-conclusion-discipline.sh:62-67(CD-11 `1-3[5-7]` 系, 实际 :79/:81 已用 `1-3[5-8]`/`Rules 1-3[5-9]`; :66 CD-12 「1-34」=0 反回退可保留)、selftest-reflect-verify.sh:60 RV-10 `Rules 1-3[5-9]`、selftest-veto.sh VT-10 `Rules 1-3[1-7]`、selftest-error-loop.sh EL-11 `Rules 1-3[1-6]`、selftest-batch-pilot.sh:57 BP-09「隶属 Rules 1-36」(CD-19 子串保护钉, 文档内历史锚, 不动)——REGEX 类锚兼容未来值(1-44 命中 [5-9]), **无需改**; 硬字面类(SR-07/TS-05/PT-08/WF-10/11/R-09)需改
  - templates/: 若 Rule 16 计数锚「grep -rl "## 📚 必要知识储备" templates/ | wc -l」=21 与 C16 断言存在, 不涉及; 本任务不加模板, 计数不变
  - selftest-registry.tsv: 新增 selftest 守护行(Rule 45 域) 建议 1 行(与 R/RT/SR 范式同)
  - 结论: 必改 8 处(正文 4: critical-rules/SKILL×2/C 表; 索引 2: CLAUDE.md/README_zh.md; selftest 硬字面 6 断言: R-09/SR-07/TS-05/PT-08/WF-10/WF-11) + 新增 2(selftest 守护+registry 行)。REGEX 宽容锚 5 处天然兼容零改。HIGH 置信
- [16:3x] M4 Part 3 密度基线完成(12 脚本: 守卫 4 + selftest 4 + 工具 4; 统计命令与输出见 evidence 段)
  - 头注释在位率 12/12(全部含 hdr15 ≥2 行头注释; 最弱 check-complete.sh hdr15=7 行, 无「— 脚本名+Rule 锚」第一行模式)
  - 函数级注释率(函数定义行前 1 行内 `#` 注释, awk 统计): check-dispatch 9/9, check-delegation 12/12, ledger-append 4/4, selftest-veto 2/2, selftest-plan-tier 2/2, selftest-registry 2/2, init-session 3/3, smart-merge-back 1/1 —— 12 脚本函数合计 37, 带前置注释 37 = 100%(shell 惯例头注释块紧跟函数行); 特例 check-complete.sh 1 函数(内部 python heredoc 为主)
  - 逻辑段内联注释密度(^# 行占比): check-complete 4%/attest-plan 8%/check-delegation 12%/check-dispatch 22%/ledger-append 18%/init-session 22%/smart-merge-back 22%/selftest-veto 44%/selftest-plan-tier 25%/selftest-registry 25%/selftest-reliability-institution 31%/selftest-ask-default-timeout 32% —— 全仓脚本注释行占比区间 4-44%, 中位 ~22%
  - Why 类注释存在性(设计/取舍/避免/防/原因 关键词): check-complete 12(check-complete.sh:524 「独立实现避免 source 依赖」、:587 「避免门控自身配置问题锁死终验」、:979 「脚本内表或 registry 取舍」、:981 「防 A-1 提高 mini 命中率后新断言误报」)/check-delegation 15(:19 「设计原则(P0 / 用户指令锁定)」)/ledger-append 头注释 4-6 行均为 Why(上游移植裁剪理由 :3-6)/check-dispatch 5 —— Why 注释**存在但不系统**: 集中在守卫脚本头部与关键分支, 函数体逐段 Why 覆盖不保证(如 selftest 类仅 0-4 处)
  - md 抽 3 个: templates/subagent_dispatch.md 62 行 3 处 html comment(5%)/templates/knowledge-brief.md 52 行 6 处(12%)/references/dispatch-examples.md 41 行 2 处(5%) —— md 注释密度低, 以段标题承载解释为主
  - 基线结论: 头注释 100% 在位 / 函数前置注释 100% / 逻辑段 Why 注释点状存在(密度 4-44%, 无统一要求)——Rule 45 落地主要补「函数内逻辑段 Why 系统覆盖」+「头注释四要素形式化」, 存量补强量=中(见清单)
- [16:4x] M5 Part 4 Rule 45 草案 + 存量补强清单完成(全文见下「最终结论」段前草案区)

## Rule 45 草案(全文, 交 Phase 2 落 critical-rules.md)

### 45 注释完整性规范（P0 — task-v111，目标：所有产出含完整 What+Why 双层注释，设计思路入注释，禁止为美观删减；判定面=产出自查、机器面=selftest 静态锚；衔接宪法 §九，用户裁决优先于平台默认克制倾向）

45.1 **适用范围**: 本任务全部产出——代码/脚本(含本仓 scripts/*.sh 与子代理产出)/文档(.md 含计划三文件)/模板/配置(json 注释性字段)/subagent prompt 材料——凡写入仓库或交付文件的注释层均适用；纯一次性会话内临时命令(不落盘)豁免。
45.2 **双层注释要求（What+Why）**: 每个函数(壳函数/子函数/heredoc 内函数)与每个 ≥5 行逻辑段须含 ① What=做什么(一句话行为描述)② Why=设计思路/取舍理由/坑点/防什么(至少其一)；Why 可引用户裁决/task-id/上游先例作锚(范式: check-delegation.sh:19 「设计原则(P0 / 用户指令锁定)」、check-complete.sh:587)。**有效注释边界**: 注释必须携带信息增量——逐字复述下一行代码的注释(如 `# 循环数组` 之于 for 循环)= 灌水, 不算完整; 无意义注释缺失 ≠ 完整, 宁无灌水。
45.3 **头注释四要素**: 每个脚本/模块文件头含 ① 用途(一行: 脚本名—功能, 锚 Rule/任务)② 输入(位置参/env/读取文件)③ 输出(exit 码语义/stdout 格式/写入文件)④ 依赖(调用脚本/config 键/外部命令)。范式=check-dispatch.sh 头注释(校验面/档位/依据三段)。
45.4 **修改注明三要素（衔接宪法 §九:158）**: 修改现有函数/条款/脚本 → 注释注明 修改原因 + 时间 + 原行为(范式: 本仓 `[2026-09-27 task-v091]` 标注惯例); 新增函数 → docstring/前置注释块; 修 bug → 现象+根因+修法; 禁止只写 `TODO` 替代修改说明。
45.5 **禁止为美观/简洁删减注释**: 重构/简化/格式化/清理类动作不得删除既有 Why 注释与修改留痕注释；删注释 = 删除性行为, 按 Rule 36.3/36.4 列清单确认；「代码短一点」不构成删注释理由(与 Rule 18 质量门控同构)。
45.6 **平台冲突显式声明（用户裁决优先）**: 平台默认注释倾向=克制(「注释只写代码无法自明的约束」)；用户 2026-10-02 裁决=「所有产出必须包含完整注释，便于理解与维护，不要为了美观减少注释，思路上面的最好也写到注释」——**本 Rule 45 与用户裁决一致并优先于平台默认克制倾向**；执行层遇「注释是否冗余」判断时按 45.2 双层标准判定, 不以「代码可读就少写」为由跳过 Why。
45.7 **机器承载（selftest 静态锚）**: 新建 `scripts/selftest-comment-completeness.sh`(CC 组)断言: ① critical-rules.md `grep -c '^45\.'` = 5(45.1-45.5, 45.6 并入 45.5 或独立计——Phase 2 定)② SKILL.md 索引/摘要/C34 行含「Rule 45」「注释完整性」③ 本任务 scope 脚本头注释四要素 grep(用途行/输入行/输出行/依赖行) ④ 零新 config 键(与 40/41/42/43/44 同范式); registry.tsv 加 1 行; C34 消费行(SKILL 合规清单, 机器面=CC 静态断言+人工自查)。

## 存量补强清单(交用户裁决, 不自动实施; 工作量分级)

脚本类:
| 对象 | 缺口 | 建议 | 级 |
|---|---|---|---|
| check-complete.sh(1053行) | 头注释无「— 脚本名+Rule 锚」第一行范式(hdr15=7 行弱于其余); 4% 注释占比全仓最低; 逻辑段 Why 点状(12 处) | 头注释补四要素; 关键 gate 段补 Why(VC-GATE/3-File Gate/委派统计段) | M |
| attest-plan.sh(225行) | why_style=1; 无函数(单流程脚本) | 主流程分步注释块(为何先哈希后写/为何 --clear 幂等) | S |
| check-dispatch.sh / check-delegation.sh | 头注释与 Why 良好基线; 个别分支缺取舍说明 | 抽 3-5 个核心判定分支补取舍一行 | S |
| selftest-* 42 个 | 头部断言表完备(范式好); 函数内逻辑段 Why 少(why_style 0-2) | 仅对本任务触改的 selftest(硬字面 6 断言脚本)顺手补, 全 42 个补强=大批量走 Rule 18 门控 | S(触改面) / L(全量) |
| ledger-append.sh | 头注释 Why 完备(上游移植裁剪理由); 函数级 100% | 无缺口(基线范例) | - |

文档类:
| 对象 | 缺口 | 建议 | 级 |
|---|---|---|---|
| critical-rules.md 尾部 | Rule 45 段缺失(本任务主产物) | Phase 2 新增 | M(任务内) |
| SKILL.md 索引面 4 处 + 摘要行 + C 表 | 口径停留 1-39/含至 44 | Phase 2 级联 | M(任务内) |
| templates/subagent_dispatch.md(62行 3 注释)/knowledge-brief.md(52行 6 注释)/dispatch-examples.md(41行 2 注释) | html comment 密度 5-12%; 模板字段「为什么这样填」说明缺 | 每模板头部补 1 段填写指引 Why(何时用/为何九字段) | S |
| CLAUDE.md:32 / README_zh.md:136,229 | 索引口径 1-39 | Phase 2 级联 | S(任务内) |

## 最终结论(8 字段, Phase 2 实施时以主进程复验为准)

status: done
acceptance: 3/3 pass — ① 四部分逐项有结论(条款现状/级联面/密度基线/Rule 45 草案+清单, 见上各 M 段) ② Rule 45 草案完整(45.1-45.7 七子条, 含编号/名称/适用范围/双层/头四要素/衔接宪法/禁删减/平台冲突声明/有效边界/机器承载)+存量补强清单(脚本 5 行+文档 4 行, S/M/L 分级) ③ 检查点已落盘含最终结论 8 字段块(本文件)
files: /mnt/data/dev/task-planner-skill/plans/task-v111/subagent-state/1-executor.md(+1/0); /mnt/data/dev/task-planner-skill/plans/task-v111/findings.md(+1段/0); /mnt/data/dev/task-planner-skill/plans/task-v111/progress.md(+1行/0)
evidence: critical-rules.md:451(末行, Rule 44.4 后即 45 落点) / SKILL.md:9,246,304,198,280 / CLAUDE.md:32 / README_zh.md:136,229 / selftest-reliability-institution.sh:76-77(SR-07 负断言 1-40=0) / selftest-self-resolution.sh:64-67 / selftest-tool-selection.sh:53-56 / selftest-plan-tier.sh:75 / selftest-workflow-orchestration.sh:52-63 / 宪法 AGENTS.md:158-159 / 密度统计 12 脚本命令输出(见 M4)
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v111/subagent-state/1-executor.md (status: done)
findings_written: #### [sub:1-executor] 注释规范普查
blockers: none
confidence: HIGH
