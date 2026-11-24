# Knowledge Brief — task-two-stage-fix-20261124（任务知识简略要点）
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；项目级双轨与内建 templates/knowledge-brief.md 同契约 -->
<!--
  定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；
  计划期由 plan-writer 产出（内容来自实际 Read 过的源码/检查点，禁凭记忆编造），执行期持续回填 §2/§3。
  与三文件罗盘关系：本文件=知识维；findings=决策维 / progress=进度维 / task_plan=目标维。
  本任务事实源：user-session-log.md #1 + subagent-state/01-general-analyst.md + 02-general-analyst.md + plan-writer 本次 Read 源码实证。
-->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer 产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：把「修复类请求两段式（阶段一快修表层+根因线索包+立即合并→阶段二新 worktree 独立根治、不阻塞主线）」固化为 task-planner 调度默认形态，经三驱动点 + 双计划 tag 登记落地，全量 selftest 0 FAIL，不部署。
- 背景/动机：用户原话 #1 指出「只改个例表层不查根因→处理问题所调用技能本身的缺陷未修→下次再犯」，并要求从调度阶段起贯穿「先快修早合并、再底层排雷且并行不阻塞」的思路。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 两段式修复 | 一个修复类请求拆成两个独立 task-id 计划：阶段一=快修表层+根因线索包+立即合并回 master；阶段二=`<A-id>-rc` 新 worktree 独立根治，失败不回滚阶段一。 |
| 根因线索包 | 阶段一必产登记物（≤15 行，不改源文件）：现象/直接原因/根因假设/出错来源(技能·规则·脚本·agent·门)/本该拦住而未拦/同族波及面/规模预估/证据锚。 |
| B12 | 原生 Todo 基线组新增必选项「修复类：根因线索包+后续任务已登记（非修复类标 N/A）」；B9-B11 属他会话占用，禁撞号。 |
| tags + .tags-index.json | 零 schema 新字段的跨计划双向登记：阶段一打 `rootcause-followup:<B-id>`、阶段二打 `followup-of:<A-id>`；倒排索引位于 `<plan-dir>/../.tags-index.json`。 |
| 消费门 --source=rootcause-followup | EVIDENCE-ANCHOR GATE 第三 source，校验线索包+tag 登记（或 N/A+证据）存在；须双文件改，禁新增独立门/改门序。 |
| 制度层 vs 实例层 | 本任务是制度层机制固化（Rule 31.8 走原路径，单计划 L2）；两段式触发仅限修复类实例请求（D1）。 |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| Rule 31.1-31.8 / 33 / 36.2 / 102.0 根因闭环条款已完备；触发面 SKILL.md:182/284；缺口在「修复类任务没把归因登记为必选动作+早合并拆分」，非无规则。 | subagent-state/01-general-analyst.md:8-21（Q1，含 critical-rules-discipline.md:79-91 原文锚） | 不必新增归因 Rule；只在载体面加登记/拆分驱动点，避免重复造轮子。 |
| "把错值改回"属实例层小改；本仓 skills/ 为保护区使 trivial 失效、回落 L1；本计划头显式 L2/standard 优先。 | subagent-state/01-general-analyst.md:23-33（Q2，lane-detect.sh:7-9/78-85、init-session.sh:610-638） | 本任务按 L2/standard 走（FMEA/知识表/委派统计/S-unit 表必填），禁降 mini。 |
| 每次必发生驱动点唯一落点=sync-todos.sh:200-214 基线组 B1-B8 + todo-sync.md:34-40 契约；B9-B11 被他会话占用。 | subagent-state/01-general-analyst.md:35-40（Q3）；本次 Read sync-todos.sh:207-214 / todo-sync.md:34-40 实证 | 新项 B12 追加在 B8 行后；禁占 B9-B11；脚本与契约必须同步改。 |
| 阶段二塞进阶段一命中 Rule 88.2③（发现的问题改登记+报告）、74.2/74.3（须标注表且默认增量）、87.4①（只改必须改处）。 | subagent-state/01-general-analyst.md:42-49（Q4，critical-rules-discipline.md:558-562/491-497/546） | 线索包定位为「登记产物不改源文件」；逐文件改动走变更标注表(CHG-1..9)。 |
| 拆分模式库 P1-P12 无二阶段模式（P12 仅静态域并行）；根因 Phase 仅 bugfix-type.md:85 有、rule-enhancement 无；「合并后再开第二 worktree 根治」NONE FOUND。 | subagent-state/02-general-analyst.md:10-27/61-63/39-53（Q1/Q4/Q3） | P13 新增位置=split-pattern-library.md:118 后/:120 前；bugfix-type.md Phase 2 补交付物；阶段二启动协议需文本新增。 |
| 零新 schema 字段最小手段=tags + plans/.tags-index.json 倒排（planctl.py:1055 tag-add / :757 tag_index_path=<plan-dir>/../）；消费门最合适落点=EVIDENCE-ANCHOR GATE(:735/:769，已按 --source 扩展)，新建专用门需改门序+哈希锚成本高。 | subagent-state/02-general-analyst.md:27-37/65-96（Q2/Q5） | 用 tag-add 双向登记；门扩 --source 而非新门；不改门序/哈希锚。 |
| plan-writer 实证：check-evidence-anchor.sh:115 仅接受 coverage\|goal\|all，:121 未知参数 exit 2，:509-514 dispatch 只两支；check-complete.sh:769 传 --source=$src、:771 rc=2 fail-open；调用点 :1064(coverage)/:1841(goal)。 | plan-writer 本次 Read（check-evidence-anchor.sh:112-125/509-531、check-complete.sh:735-780/1064/1841） | D9：第三 source 必须双文件改（解析+mode 与调用点），只改调用点会因 rc=2 fail-open 成空门。 |
| 根因 Phase 锚=bugfix-type.md:85「### Phase 2: 根因定位」，现有 4 条 checkbox（:86-89）+ Status/Executor（:90-91）。 | 本次 Read bugfix-type.md:78-95 | 交付物追加在既有四条之后，既有文字逐字保留（Rule 74.2a）。 |
| 合并基线=master HEAD d9f68655；main 与 master 无共同祖先，worktree 基线用 master。 | AGENTS.md §6；git rev-parse HEAD 实测 d9f68655；02-analyst.md:99-100 | 合并预案(KQ-2)按 D7；禁把 main 合进 master。 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/scripts/sync-todos.sh | :200-220 | JSON 输出分支构造 B1-B8 基线组（:207-214 逐条 subject），:215-219 逗号衔接；B12 加在 :214 B8 后。 |
| skills/task-planner/references/todo-sync.md | :34-40 | S1 两组结构 6 项：固定八项 B1-B8、生命周期、门禁挂钩、S3 丢失重建、mini 口径、唯一事实源；B12 同步这 6 项。 |
| skills/task-planner/SKILL.md | :98-107 | 初始化首动作委派（L1+）：触发/动作/计划期例外/主代理收窄/收据契约/边界/豁免/动机/可选前置；两段式判定入口加在本块。 |
| skills/task-planner/companion/agents/plan-writer.md | :37-47 | 「掌握的技能」清单（模板选择/任务分解/VC/Scope/隔离/knowledge-brief/工具编排/质量审查）；两段式判定加为一条。 |
| skills/task-dispatch/references/split-pattern-library.md | :110-120 | P12 依赖分批并行判据/步骤/反例/消费时机/来源/关联；:120 起伴飞映射表；P13 插在两者之间。 |
| skills/task-planner/templates/variant/bugfix-type.md | :85-91 | Phase 2 根因定位 4 条 checkbox（systematic-debugging 5 步/debugger 协助/证据链/findings 根因节）+ Status/Executor；追加线索包/登记 2 条。 |
| skills/task-planner/scripts/check-evidence-anchor.sh | :112-125 / :499-514 | source 解析(:115 case/:117 help/:121 未知参数 exit2)；run_source 主判定(:509-514 两支 dispatch/:524-530 FAIL 汇总)；加第三 mode 与分支。 |
| skills/task-planner/scripts/check-complete.sh | :735-780 / :1064 / :1841 | EVIDENCE-ANCHOR GATE 档位解析+run_evidence_anchor 封装(:769 传 --source=$src/:771 rc=2 fail-open)；调用点 coverage(:1064)/goal(:1841)；第三调用点加在本区内。 |
| skills/task-discipline/references/critical-rules-discipline.md | :91 | Rule 31.8 制度层/实例层边界；实例层「禁止擅自升级为改规则/技能本体」；交叉引用消歧一句加在此。 |
| plans/.tags-index.json | <plan-dir>/../（planctl.py:757-759） | 跨计划共享 tag 倒排索引；tag-add(:1055)写入，tag-search O(1) 反查；双向登记载体。 |

## §4 易错点与禁止假设清单
1. 禁止占 B9-B11 号段（属他会话 task-session-regression），新基线项只能用 B12；VC-1 断 B1-B8+B12 全在。
2. 禁止把「根因线索包」当成修复动作直接改源文件（Rule 88.2③：发现的问题改为登记+报告）；线索包=登记产物≤15 行。
3. 禁止只改 check-complete.sh 就以为消费门生效——check-evidence-anchor.sh:121 对未知 source exit 2、:771 rc=2 fail-open，会成空门（D9）；必须双文件改 + VC-5 POS/NEG 实跑。
4. 禁止改门序或哈希锚、禁新增独立门（新建门需改门序+selftest 哈希锚成本高）；只在 EVIDENCE-ANCHOR GATE 区内加一次 run_evidence_anchor 调用。
5. 禁止新增 schema 字段；用现成 tags + .tags-index.json 双向登记（D2）。
6. 禁止在本计划套用两段式：本任务是制度层机制固化（Rule 31.8 原路径，单计划 L2）；D1 触发仅报错/改错/bug/回归类修复请求。
7. 禁止触碰他 worktree 改动面与主仓未提交文件（SKILL.md/todo-sync.md/sync-todos.sh/task_plan.md 他会话在改；init-session.sh/planctl.py/attest-plan.sh 主仓未提交改）；冲突按 D7/KQ-2 延后 smart-merge-back 逐条并线。
8. 禁止部署/碰部署位（~/.zcode|~/.claude|~/.agents|~/.config/opencode skills 副本）、禁跑会话绑定脚本（init-session.sh/attest-plan.sh/set-active-plan.sh/plan-created.cjs）、禁建 worktree（本任务只产计划）。
9. 禁止手工 Edit 4 个派生 MD（task_plan/findings/progress/verification）；只经 planctl add/set+render 改权威源。
10. 增量档（Rule 74.2a）：既有文字逐字保留，禁以「整合/去重/格式化」名义回写；无需变更标注已落 CHG-1..9。
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表 FM1(336)/FM2(180)/FM3(252)/FM4(360)/FM5(256) 行；对应兜底动作见各 S-unit 验收 + VC-1/2/5/8 实跑。

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1 | §1 + §2 + §3 + §4(7) | /mnt/data/dev/task-planner-skill/plans/task-two-stage-fix-20261124/subagent-state/01-general-analyst.md + 02-general-analyst.md |
| S2 | §2(驱动点/撞号) + §3(sync-todos/todo-sync) + §4(1) | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/sync-todos.sh + references/todo-sync.md |
| S3 | §3(sync-todos) + §4(1) | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/sync-todos.sh |
| S4 | §3(SKILL/plan-writer) + §4(6) | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md + companion/agents/plan-writer.md |
| S5 | §2(模式库 NONE FOUND) + §3(split/bugfix) + §4(10) | /mnt/data/dev/task-planner-skill/skills/task-dispatch/references/split-pattern-library.md + skills/task-planner/templates/variant/bugfix-type.md |
| S6 | §3(split/bugfix) | task_plan.md VC-3/VC-4 + /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-template-lifecycle.sh |
| S7 | §2(D9 实证) + §3(check-evidence-anchor) + §4(3/4) | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-evidence-anchor.sh |
| S8 | §2(D9) + §3(check-complete) + §4(4) | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-complete.sh |
| S9 | §2(D9) + §4(3/4) | task_plan.md VC-5（POS/NEG fixture 命令）+ /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-evidence-anchor.sh |
| S10 | §3(critical-rules-discipline) + §4(6) | /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md |
| S11 | §4(7/8/9) | task_plan.md VC-7/VC-8/VC-9 + /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/run-selftests.sh |

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）
| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| task-dispatch | /mnt/data/dev/task-planner-skill/skills/task-dispatch/SKILL.md | 本任务派发 11 个 S-unit、拆分模式库 P13 落点 | 子代理 prompt 挂载（卫星路由，非用户触发型） |
| n/a | — | 本任务为仓内机制固化，未检索到需额外激活的用户触发型(comet 族)强化技能 | 不代激活 |

## §7 项目知识库回链（终验后入库触发）
- **触发点**：任务终验交付完成后（check-complete exit 0 后、归档前后皆可）
- **入库命令**：`bash scripts/kb-sync-from-plan.sh plans/task-two-stage-fix-20261124`
- **精炼**：draft 需人工/模型合并去重→主题化→补证据锚行号→去除 `_draft-` 前缀改名
- **索引**：改名后 `bash scripts/kb-rebuild-index.sh` 重建 INDEX.md（勿手改）
- **条目规范**：见 knowledge/README.md 与 knowledge/entry-template.md
