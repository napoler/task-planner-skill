# Knowledge Brief — task-v081（任务知识简略要点）

> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由主进程产出（plan-writer 环境不可启动，Decisions ③），执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：给 task-planner 派发链路补「步骤枚举数」门控维度（step_max_steps 默认 4），使"单子代理打包 13 步"类粗粒度派发在计划期被提示、派发期被硬拦；达成标准=task_plan.md VC-1..10 全过+全量 selftest 0 FAIL+三位部署 IDENTICAL。
- 背景/动机：用户 2026-09-17 实证单子代理 Todo 含 Step1..Step13（跨 ≥6 文件），四层既有防线（时长/文件数/prompt 字数/S-unit ID 数）全部放行，违背小步快跑原则。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 步骤枚举标记 | prompt/S-unit 行内 `StepN`/`步骤N`/`第N步`/`①-⑮`/行首 `N.` 的序号 token，distinct 序号值计数 |
| step_max_steps | 新 config 键，单次派发允许的 distinct 步骤枚举数上限（默认 4，超限=拆分信号） |
| fine_grain_checks | check-dispatch.sh 内细粒度检测函数（①长度②打包③brief 引用，本轮增④步骤枚举） |
| 任务书防绕门 | prompt 引用落盘任务书（任务书+subagent-state/ 双条件）时，对任务书文件内容同样计数，防 13 步躲进文件绕门 |
| advisory vs enforce | 计划侧第三维=SKIPPED 提示不阻断；派发侧④=挂 dispatch_contract_enforce（默认 enforce）exit 2 |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| fine_grain_checks 现行①②③+warn/enforce 分档 | skills/task-planner/scripts/check-dispatch.sh:243-292 | ④插在③之后 `[ -z "$hits" ]` 之前，复用 hits/mode 既有管线 |
| 打包检测双条件豁免（任务书+subagent-state/ 同现才豁免） | scripts/check-dispatch.sh:263-267 | ④的防绕门扫描须挂在同一豁免分支内 |
| S-unit 数值门控仅两维且 advisory（174/182"提示不阻断"） | scripts/check-plan-dispatch.sh:161-190 | 第三维照抄 SKIPPED 提示范式；awk 列位 $3=目标/$5=输入/$7=时长 |
| Rule 21.1b 仅 文件/行数/分钟 三维 | references/critical-rules.md:114 | 步骤枚举维度以句尾追加方式增量 |
| 22.4 九字段/22.6 表说明位置 | references/critical-rules.md:127 / :132 | 各加同源半句，禁止改既有语义 |
| SKILL.md 现值 541 行；行数断言两处 ≤548 | SKILL.md(wc)；scripts/selftest-skill-collab.sh:80-81、scripts/selftest-execution-stability.sh:70-72 | 净增 ≤2 行可不扩围；扩围须两处同批 |
| config 键为双层 properties | .properties.subagent.properties.step_max_minutes.default=15（jq 实查） | 新键同层；jq 单层写法会静默回退 |
| dispatch_contract_enforce 默认 enforce | config.json（jq 实查） | ④违规默认即硬阻断，无需新 enforce 键 |
| 派发 8 字段字面 token（status:/acceptance:/checkpoint: 等） | templates/subagent_dispatch.md:53-58 | 派发 prompt 必含这些字面量，否则 pretooluse 拦截 |
| sonnet-1/继承档位子代理 Cannot start(reasoning-level-missing)；mini 正常 | 本会话 2026-09-17 实证（Plan Writer×2、general-purpose×1 失败；Explore 成功） | 实现路由=code-assistant(haiku-1) 优先，失败则主进程接管（Decisions ⑤） |
| 全量 selftest 基线 349/0（v079 后） | memory task-v079 + CHANGELOG | P1 基线复跑以此对照 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/config.json | .properties.subagent.properties | step_max_* 三键+prompt_max_chars 等子代理阈值族（step_max_steps 插此） |
| skills/task-planner/scripts/check-dispatch.sh | :243-292 | fine_grain_checks 函数体（④插入点；头注释 :39-43 补口径） |
| skills/task-planner/scripts/check-plan-dispatch.sh | :161-190 | awk 数据行数值门控（第三维插入点；头注释 :24-35 补口径） |
| skills/task-planner/references/critical-rules.md | :114 / :127 / :132 | 21.1b / 22.4 / 22.6 增量锚 |
| skills/task-planner/SKILL.md | ⏱️兜底节首段+Rule 21 摘要行 | 两处并入式修改（净增 ≤2 行） |
| skills/task-planner/templates/subagent_dispatch.md | §7 附近 | 补一行步骤枚举约束 |
| scripts/selftest-fine-grain-steps.sh | 新建 | fixtures+VC-2..5 断言组（范式对齐 selftest-veto.sh） |

## §4 易错点与禁止假设清单
1. 禁止把 jq 路径写成单层 `.properties.subagent.<key>`——真实结构双层 properties，写错静默回退默认值（假 SKIPPED）
2. 主进程交互层 `grep` 是 ugrep 别名、转义有差异——验证命令用 `command grep`；脚本文件内不受影响
3. 行数断言两处（skill-collab:81 / execution-stability:72）必须同批扩围，漏一处=全量回归 FAIL
4. 派发 prompt 缺字面 token（findings.md/progress.md/status:/acceptance:/checkpoint:）会被 check-dispatch 拦截——照 templates/subagent_dispatch.md §7 写
5. 每次失败派发泄留串行槽锁（<plan-dir>/subagent-state/.dispatch-inflight，TTL 120s）——失败后必须等锁陈旧（≥120s）再派，禁手动删锁
6. ④的防绕门扫描必须挂在②的任务书豁免分支内（单条件豁免会废门，task-v078 教训）
7. 禁动 "Rules 1-N" 字样、既有键语义、既有函数签名——本任务纯增量无级联
- FMEA RPN>100 兜底指针：→ task_plan.md「📊 FMEA 预演」表 R-1/R-2 行（fixture 失配回归 FAIL→对照 349/0 基线二分定位≤3 轮；正则误伤合法 prompt→默认 4 宽上限+SKIPPED 显式化逃生）

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1 | §2 + §3 + §4① | plans/task-v081-fine-grain-step-gate/subagent-state/01-plan-writer-input.md §2 D1 |
| S2 | §1 + §2 + §3 + §4⑥ | 同上 §2 D2（④完整规格+正则口径） |
| S3 | §2 + §3 + §4① | 同上 §2 D3 |
| S4 | §2 + §4⑤ | 同上 §5 VC 草案 |
| S5 | §2 + §3 + §4⑦ | 同上 §2 D4 |
| S6 | §2 + §3 + §4③ | 同上 §2 D5/D6 |
| S7 | §2 + §3 + §4② | 同上 §2 D7 |
| S8 | §2 + §4③ | 同上 §2 D8/D9 |
