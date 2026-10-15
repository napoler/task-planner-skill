# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
- R1 优化 task-planner 防偏移策略：偏移检查从主上下文 skill 调用改为子代理隔离执行
- R2 动机=保持主上下文干净 + 规避上下文爆炸（检查时读计划全文+git 输出涌入主上下文是现状痛点）
- 约束：触发时机/三态/处置链语义不变（R 只要求换执行位置）；Rule 36.4 载体语义改写授权=用户本条指令

## §1 现状链路（2026-10-08 Explore 侦察，主进程复核锚点）
- 触发 6 处：SKILL.md:98（执行循环步骤6，自称"唯一检测载体"）/127（Chain 交接步骤4）/173（合规清单 C4）/236（用户新指令 B/C 后）/274（Rule 15 摘要）/383（路由表「漂移检测」行）；critical-rules.md:57-72（Rule 15 全文，15.1 触发时机表 :60）
- 检查载体=`Skill("task-drift-guard")`——**主上下文内执行的 skill**（卫星 skills/task-drift-guard/SKILL.md 82 行，frontmatter model: haiku，纯 LLM 无脚本）；检查时主进程读 task_plan.md+git status/diff+会话上下文 → 三态判定 → 处置（ALIGNED 继续/DRIFT 追加 [drift-fix] todo/BLOCKED STOP）
- check-drift.sh 在位=可选机器佐证（读三文件校验，SKILL:98 明示不双跑）
- 关键约束：**子代理无 Skill() 工具**（schema-migration-type.md:110 明示）→ 子代理化必须把 SOP 嵌入 agent 定义或派发 prompt，不能让子代理调 skill

## §2 改造设计要点（全文草案见 knowledge-brief §5）
- 新增 Rule 61（61.1 载体强制/61.2 派发契约/61.3 产出契约/61.4 防自触发/61.5 失败兜底/61.6 机制）+ Rule 15 追加 15.4 载体条款
- 新建 companion/agents/drift-checker.md（haiku-1 档；只读仓库+唯一写检查点；SOP 嵌入式）——伴随 agent 走 install-companion.sh:154-156 通配部署，**零脚本接线改动**（claude 位 model 行自适应 :101）
- 派发走 Rule 22.4 九字段模板+drift 专用四字段 → 天然过 check-dispatch.sh 守卫，零守卫改动
- task-drift-guard 卫星保留（交互/独立场景），增补「子代理消费模式」说明节（纯增量 ≤10 行）

## §3 载体切换锚清单（Phase 3 逐处消费）
> **[2026-10-08 v143 合入后勘误]** master 前进至 da1f308（编号仲裁：58=v143 落地、v142 规则改号 60、59 待 v144）；行号已按 worktree 重测。**本表坐标以 knowledge-brief §5.4 十二行措辞表为权威**（新增 :103 检测层行与 :481 摘要行两处遗漏点；v143 未扩索引括注仍写 40-55，本次顺带修复至 40-61）。Rule 15 块内另有 4 处旧载体词（导语/15.1/15.2/15.3，零脚本锚已验证）——见 KB §5.2。
| # | 文件:位置 | 现串特征 | 动作 |
|---|-----------|---------|------|
| 1 | SKILL.md 执行循环步骤6 | `[DRIFT CHECK]** 调用 \`Skill("task-drift-guard")\`` | 改派发 drift-checker（Rule 61 载体） |
| 2 | SKILL.md Chain 交接步骤4 | `4. 调用 \`Skill("task-drift-guard")\`` | 同上 |
| 3 | SKILL.md C4 合规清单 | C4 行含 `Skill("task-drift-guard")` | 措辞切派发+Rule 61 |
| 4 | SKILL.md 用户新指令段 | `B/C 类处理完必须再跑 \`Skill(...)\`` | 改派发 |
| 5 | SKILL.md Rule 15 摘要段 | `任一触发条件命中立即调 \`Skill(...)\`` | 改派发+Rule 61 指针 |
| 6 | SKILL.md 路由表漂移检测行 | `\`Skill("task-drift-guard")\` \| haiku（内置）` | 改 `drift-checker` \| haiku-1 |
| 7 | SKILL.md References 表 | 外部 skill 行含 `Skill("task-drift-guard")` | 执行载体 drift-checker+交互载体说明 |
| 8 | SKILL.md 反模式段 | （无偏移行） | 追加禁止主进程偏移比对行 |
| 9 | SKILL.md Critical Rules 索引 | `Rules 1-39（含 Rule 40-55 全集...）` | **只扩括注至 40-61，头部 1-39 禁动**（级联）+追加 Rule 61 摘要 bullet |
| 10 | scripts/zcode-userpromptsubmit.sh:220 | `偏离即跑 Skill(\"task-drift-guard\")。`（bash 双引号内转义引号） | 改 `偏离即派发 drift-checker 子代理偏移检查(Rule 61 载体)。` |
- 负断言目标：改后 SKILL.md 全文 `Skill("task-drift-guard")` 精确串 0 命中
- 锚级联判例（禁触发）：selftest-error-loop.sh:59 `Rules 1-3[1-9]` / selftest-conclusion-discipline.sh:86 `Rules 1-3[5-9]` / selftest-reflect-verify.sh:60 `Rules 1-3[5-9]`——均匹配头部 `Rules 1-39` 前缀，头部不动即零级联
- 行数断言：selftest-knowledge-brief.sh:38 SKILL.md ≤558（实测当前 484，净增预算 ≤20 行 → 不触上限）

## §4 基线与回归（Phase 1/4 回填）
**Phase 1 基线（2026-10-08，worktree=da1f308 零修改态，检查点=subagent-state/1-code-runner-agent.md）**
- 命令：`for f in selftest-*.sh; do timeout 90 bash "$f"; done`（4 批，worktree scripts/）
- 结果：57 脚本 / ΣPASS=863 / ΣFAIL=21 / FAIL≠0 脚本 15 个
- **FAIL 分类（全部预存，非本任务引入）**：
  - 13×「config.json properties 键数=42 应 40」：AC-07/RT-09/CP-16/IP-15/LA-14/MA-10/MD-08/R-12/RC-13/RG-07/SR-09/TS-12/WF-12——根因=并行任务在 master 加 2 个 config 键未同步零新键断言（债，非本任务修复面；本任务零新键不碰）
  - 4×periodic-review 缺陷（PR-03/04/05/10）+ registry 未登记（PR-09/T02/SR-12 关联）——预存债
  - 1×RC-15「'56.' 子条应=0」——Rule 56（v140）落地破坏编号假设；本任务加 61.x 不含 '56.' 串，预期不受影响
- **Phase 4 门口径（据实修订）**：FAIL 集合 ⊆ 本基线集合（零新增）+ 新 selftest 全 PASS；预期数字漂移仅 SR-12/T02 行内计数（我加 registry 行后 rows=scripts-1 恒等式保持，缺口仍=1 系 periodic-review 预存）
- （待 Phase 4 回填：改后全量回归求和+差值）

## Resources
- 部署位：~/.zcode/skills/task-planner（主）/ ~/.claude/skills/task-planner / ~/.config/opencode/skills/task-planner / cursor 位 planning-with-files；伴随 agent → ~/.zcode/agents/ + ~/.claude/agents/
- 先例：v142/v144 `interaction_mode: silent`；task-v124 伴随 agent 双位部署+model adapt；task-v129 4 文件冲突并存解法（50/51 并存）
- agent-coverage.md 在位（Rule 52.3 矩阵同步义务；AC-04 登记名实体存在性零容忍）

## Technical Decisions
（8 条见 task_plan.md Decisions Made 表——双写指针，此处不重复）
- 核心一句：载体切换≠语义变更；触发频率、三态、处置链全保留；一致性由新 selftest 静态断言

## Issues Encountered
- （暂无）
