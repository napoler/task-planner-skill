# Knowledge Brief — task-v075-fine-grain-methodology（任务知识简略要点）

> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer 产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：机器化强制细粒度 S-unit（A1 attest 数值门控 + A2 dispatch 三项增量）+ 兑现 fmea_enforce/methodology 消费（B1 双点 + B3 v063 遗留清理），全量 selftest 0 FAIL 后合并 master、部署 3 实体位并 push。
- 背景/动机：调研（findings.md A/B 两节）证实 21.1b 步级上限纯 prose 零机器校验、fmea_enforce 等 5 开关键零运行时消费方；用户要求往更细粒度强制方向优化 + 优化 methodology 使用。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| S-unit | 22.6 派发单元表一行 = 一次 Agent() 派发；步级上限 ≤2 文件/≤100 行/≤15min（21.1b） |
| attest 门控 | attest-plan.sh 锁定时跑的门控（现含 check-plan-dispatch + check-template-type，本轮加数值门控 + FMEA 段） |
| dispatch_contract_enforce | config.json:61 三档键（默认 warn），check-dispatch.sh PreToolUse 守卫档位 |
| fmea_enforce | config.json:81 三档键（默认 warn，"预留"），本轮首次被 attest+check-complete 消费 |
| hermetic selftest | mktemp 夹具范式（selftest-methodology.sh），对真实仓只读，末行 Total=ok 数 |
| 3 实体位 | ~/.zcode、~/.claude、~/.config/opencode 的 skills/task-planner（smart-merge-back --deploy 对账） |
| NNmin | S-unit 预估时长列格式契约：`NNmin` 且 ≤15min，不可解析行 attest 时 SKIPPED 显式化 |

## §2 已验证关键事实
| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| check-plan-dispatch.sh 现仅 3 项校验（表头存在/≥1 S 行/执行体列非空），零规模数值检查；legacy（无 `- **Executor:**` 行）整体 fail-open | scripts/check-plan-dispatch.sh:37-40,84-124 | P2 数值门控须插入 :84-124 循环段并沿用 :37-40 legacy 先例（无 Executor 行 = 放行） |
| check-dispatch.sh 只查 7 项文本存在性，无 prompt 长度/多 S-unit 打包检测；:167-179 三级解析未命中降级 warn fail-open | scripts/check-dispatch.sh:48,167-179 | P3 三项增量挂既有 dispatch_contract_enforce 分档，:167-179 语义不可动，默认 warn 零回归 |
| config 键均为既有：step_max_files/lines/minutes(默认 2/100/15) 与 prompt_max_chars(3000) 定义区+默认值区、fmea_enforce/dispatch_contract_enforce/content_quality_enforce/knowledge_brief_enforce 三档键 | config.json:339-357,394-397,61,71,81,101 | 本轮无新 config 键，仅首次被运行时脚本消费；jq 读取参照 attest :80-84 tcfg 范式 |
| attest template-gate 段含三档 resolve_template_tier + fail-open 显式化 SKIPPED 行先例 | scripts/attest-plan.sh:80-120 | P4 FMEA 门控段照抄该挂载范式（env>config>warn + 逃生 --skip 披露） |
| check-complete.sh 无 FMEA/methodology grep 命中；既有门控段范式在 :453-472（PLAN-DISPATCH/RESCUE-CHAIN/VC-GATE） | scripts/check-complete.sh:453-472（全文件 781 行零 FMEA 命中） | P4 S2 在 :453 附近按既有门控段范式插入 FMEA 终验段 |
| verify.sh §9 循环现仅 check-delegation/allow-direct/selftest-delegation 三件，未含 selftest-methodology（v063 遗留①） | lib/verify.sh:225-235 | P5 S1 在 :227 for 列表追加 1 项 |
| methodology.md 两处不可核出处 = v063 遗留②（Q4/Q5 段「待补」标注原文） | references/methodology.md:137,158 | P5 S2 改泛化表述且保留文末待补登记，禁编造原文；selftest M-03（9 方法名关键词）须仍 PASS |
| 主仓未提交变更全在 plans/ 内（.active_plan/2×.plan_required_side 删除 + task-v074 .plan-attestation 改 + task-v075 untracked），与实现 scope 零重叠 | git status --short（2026-09-16 实查） | 隔离决策=worktree（仅信号①），P10 合并三问自检可直接过第 3 问 |
| selftest-methodology.sh 现 96 行 M-01..M-07 全 PASS（hermetic mktemp 夹具，config 双键+模板 FMEA 段+指针守护） | scripts/selftest-methodology.sh:1-96 | P4 S3 新增断言续 M-08+ 编号，保持末行 Total 范式 |

## §3 关键文件锚点表
| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/scripts/check-plan-dispatch.sh | :84-124 | Phase 扫描循环（Phase 头/## 标题/Executor 行/S-unit 表头与行判定）+ settle_phase 结算违规——P2 数值校验插入点 |
| skills/task-planner/scripts/check-dispatch.sh | :48-120 | scan_missing（7 项缺项扫描）+ 档位分处置——P3 三项增量（长度/打包/brief 引用）插入点 |
| skills/task-planner/scripts/attest-plan.sh | :80-120 | template-gate 三档解析 + fail-open 显式化 + LOCK 写 attestation——P4 FMEA 门控挂载范式 |
| skills/task-planner/scripts/check-complete.sh | :453-472 | 既有 PLAN-DISPATCH/RESCUE-CHAIN/VC-GATE 门控段——P4 S2 FMEA 终验段插入点 |
| skills/task-planner/lib/verify.sh | :225-235 | §9 三脚本存在性循环——P5 S1 追加 selftest-methodology 项 |
| skills/task-planner/references/methodology.md | :134-163 | Q4 五维评分（:137 DeepMind 待补）+ Q5 契约复用（:158 Anthropic 待补）——P5 S2 修正点 |
| skills/task-planner/templates/task_plan.md | :180-184,229 | S-unit 表 HTML 注释（:182）+ FMEA 段标题（:229）——P6 S1 契约注释补 NNmin |
| skills/task-planner/config.json | :339-357,394-397 | step_max_* 与 prompt_max_chars 键定义区+默认值区——P2/P3 数值来源（jq 只读） |
| skills/task-planner/references/critical-rules.md | :114,127,132,169 | 21.1b 步级上限/22.4 prompt 预算/22.6 S-unit 表/25.1 机械校验——P7 S1 标注点 |
| skills/task-planner/SKILL.md | :78,287,291,533 | attest 门控说明/Rule 21/25 摘要行/派发说明——P7 S2 标注点（净增 ≤10 行） |

## §4 易错点与禁止假设清单
1. 禁止改既有门控语义：check-dispatch :167-179 三级解析 fail-open、check-plan-dispatch :37-40 legacy 放行——只增不改，A2 默认 warn 行为必须与基线 diff 一致（V2 验收条件）。
2. 禁止采信子代理自报 selftest 总数：P9 定数只认主进程逐脚本 Total 行求和（v074 Error Log#2 先例）；委派统计/验收以 progress.md Selftest Log 为准。
3. 禁止在 methodology.md 补造「待补」出处原文——只改泛化表述+保留登记（Rule 3 反造谣；P5 S2 验收含 M-03 仍 PASS）。
4. 禁止 `git add -A`：逐 Phase 提交 scope 限定本 Phase 产物（Rule 27）；P10 收尾提交限 plans/+INDEX/ledger。
5. 禁止触碰主仓 plans/ 簿记与既有 worktree/分支（宪法 §11.4；仅 P10 主进程做 INDEX/ledger）。
6. SKILL.md 改动前先 `grep -rn "Rules 1-" skills/task-planner/scripts/` 扫锚断言一次修齐（v074 锚定级联先例）；净增 ≤10 行，超预算改行位替换。
7. FMEA 兜底指针：本计划 FMEA 表 RPN>100 两行（P2 误伤存量 RPN140 / P9 计数口径错见 RPN60+P3 打包误伤 RPN48 观察项）兜底动作已登记——P4 落地门控后本计划 attest 自检即为首个 dogfood 实例。
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「P2 attest 数值门控误伤存量计划（RPN140）」行（拆细 S1 解析为独立函数 + selftest 反例夹具；误伤存量以 selftest 夹具为准回炉，不改档位默认）。

## §5 S-unit 材料包索引
| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| P2-S1 | §2 + §3（check-plan-dispatch:84-124/config:339-397） | skills/task-planner/scripts/check-plan-dispatch.sh |
| P2-S2 | §4 + §3（selftest 范式） | skills/task-planner/scripts/selftest-plan-dispatch.sh |
| P3-S1 | §2 + §3（check-dispatch:48-120/:167-179） | skills/task-planner/scripts/check-dispatch.sh |
| P3-S2 | §4 + §3 | skills/task-planner/scripts/selftest-dispatch.sh |
| P4-S1 | §2 + §3（attest:80-120 范式/config:81） | skills/task-planner/scripts/attest-plan.sh |
| P4-S2 | §4 + §3（check-complete:453-472） | skills/task-planner/scripts/check-complete.sh |
| P4-S3 | §4 + §2（M-01..M-07 范式） | skills/task-planner/scripts/selftest-methodology.sh |
| P5-S1 | §3（lib/verify.sh:225-235） | skills/task-planner/lib/verify.sh |
| P5-S2 | §4 + §3（methodology.md:134-163） | skills/task-planner/references/methodology.md |
| P6-S1 | §1 + §4（模板同步） | skills/task-planner/templates/task_plan.md + templates/variant/rule-enhancement-type.md |
| P7-S1 | §3（critical-rules.md 锚点 5 行） | skills/task-planner/references/critical-rules.md |
| P7-S2 | §4（SKILL 行数纪律+锚定级联） | skills/task-planner/SKILL.md |
| P8-S1 | §1（交付条目风格） | /mnt/data/dev/task-planner-skill/CHANGELOG.md + README_zh.md |
