# Knowledge Brief — task-v145-four-file-dataflow（任务知识简略要点）
<!-- 模板说明见 templates/knowledge-brief.md；本文件=本任务知识底座，执行期 §2/§3 持续回填 -->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识。

## §1 任务速览与核心概念
- 任务一句话：新增 Rule 60 把四文件体系（task_plan/findings/progress/knowledge-brief）制度化为主子代理数据流转协议——调研双落盘（findings 自写+主进程蒸馏 kb）、派发契约不可收窄 lint、kb 增量门控，selftest 守护+全量回归+部署同步。
- 背景/动机：videop1 实证调研子代理被「只写检查点」收窄契约后知识只停检查点（findings 43 行 0 小节 vs 检查点 30KB），守卫对契约措辞盲区。
- 核心概念：四文件罗盘=目标维(task_plan)/决策维(findings)/进度维(progress)/知识维(kb)；22.4a B-2=子代理必做自写 findings 小节+主进程兜底回填；单写者纪律=同锚点唯一写者。

## §2 已验证关键事实
<!-- 只放已验证事实（带证据锚点），未验证推测禁入 -->
- 22.4a（deployed critical-rules.md:169）：findings 对子代理可写=仅追加 `#### [sub:{seq}-{type}]` 小节，追加是子代理必做，主进程仅兜底 [2026-10-08 Phase 0]
- check-dispatch.sh 校验面=三文件路径+8 字段标记+checkpoint 路径+KQ3 三项（:2-37），无契约措辞检测 [2026-10-08 Phase 0]
- check-3file-gate.sh 主信号=ledger 锚点后行（:89-98）、mtime 兜底（:108+） [2026-10-08 Phase 0]
- 派发模板 §2 无 knowledge-brief 行（subagent_dispatch.md:21-24） [2026-10-08 Phase 0]
- 规编号终态（两轮仲裁后）：58=v143 调研证据纪律（landed 96c474c）；v142 主动解决问题被仲裁改号至 60（内容零改动）；59=v144 在飞；61=v146 预留；**62=本任务四文件罗盘纪律** [2026-10-08 Phase 5]
- 部署位漂移：v142 原 Rule 58（a7c01a8:653-690）deployed 缺；v143 新 58+模板双区块+init-session 注入均未同步部署位——本任务 Phase 5 一并补齐 [2026-10-08 Phase 0]
- v143/v144 双 worktree 在飞（worktrees/task-v143@ba12733、task-v144@a7c01a8） [2026-10-08 Phase 0]
- Rule 62.2 lint 双条件判定落地（worktree check-dispatch.sh:152-175）：A 收窄词（「只写检查点」∨ 同行「主进程回填」+否定续文）∧ B 缺 append 锚点（`#### [sub:`∨`可写=仅追加`）短路放行；接入 cmd_check(:309-317)+fine_grain ⑥(:471-482) 挂 dispatch_contract_enforce 档位；负样例拦/正样例放/回归一致/误报 edge×3 全过 [2026-10-08 Phase 2 S1]
- Rule 62.5 gate 第 5 条件落地（worktree check-3file-gate.sh:126-139,173-197）：--require-kb 置位加查 kb 存在∧（ledger 锚点后 kb_distill ∨ kb mtime 晚于锚点；无锚点退化 findings_stale_minutes 阈值——复用既有键零新键）；ledger-append VALID_EVENTS 第 7 项 kb_distill（:28）；锚点前 kb_distill 不放行（T9） [2026-10-08 Phase 2 S2]

## §3 关键文件锚点表
| 文件 | 绝对路径（仓内） | 说明 |
|------|-----------------|------|
| 条款正文 | /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md | Rule 60 追加到文末（58 之后） |
| 主技能 | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md | 映射表+摘要行+C41 三触点 |
| 派发模板 | /mnt/data/dev/task-planner-skill/skills/task-planner/templates/subagent_dispatch.md | §2 增 kb 行 |
| 派发守卫 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-dispatch.sh | S-1 契约措辞 lint |
| 回填门控 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-3file-gate.sh | S-2 --require-kb |
| 工作账本 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/ledger-append.sh | S-2 事件枚举+kb_distill |
| 新守护 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-four-file-dataflow.sh | Phase 4 新建 |
| 守护登记 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-registry.tsv | Phase 4 登记 |
| 配置档位 | /home/terry/.zcode/skills/task-planner/config.json#dispatch_contract_enforce | lint 挂既有档位（零新键） |
| 部署位 | /home/terry/.zcode/skills/task-planner/ | Phase 5 rsync+diff IDENTICAL |

## §4 易错点与禁止假设清单
- 行号级联：critical-rules/SKILL 增行会破坏既有 selftest 行号窗口断言（历史 5 次）——先记 master 基线再改，FAIL 按口径扩展范式同步
- plans/ 不入库（git untracked 是常态，非事故）；计划文档留主仓不进 worktree
- 契约 lint 误报面：黑名单词须 ∧ 缺 append 锚点才判（「主进程回填」在兜底说明语境合法）
- 全角括号/含 tab 行手打必错（v118/v131 教训）——fixture 与断言从既有文件复制原行
- 编号竞态：v143 落地必改号，land 60 时若账本 WARN 被占 → 本任务改 61（land 前重跑 check）
- 部署位同步前全量 diff 盘点（v142 Rule 58 漂移已知，可能不止一处）
- 60.3 蒸馏=提炼可复用知识（≠复制 findings 原文）；禁改 kb 既有内容（append/更新对应节，单写者=主进程）

## §5 S-unit 材料包索引
| S-unit | 该读哪节 | 补充材料 |
|--------|---------|---------|
| Phase 1（条款） | §2 全部+§4 级联行 | findings.md 设计决策段 |
| S-1（lint） | §2 行 2/行 6+§4 误报面行 | 计划 Phase 2 S-1 规格+check-dispatch.sh :1-37 |
| S-2（gate/ledger） | §2 行 3+§3 两脚本行 | 计划 Phase 2 S-2 规格+两脚本 |
| S-3（回归） | §4 级联行+§3 全表 | scripts/selftest-*.sh 清单 |
