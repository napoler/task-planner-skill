# Knowledge Brief — task-docmod-recheck-20261112（任务知识简略要点）
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；项目级双轨与内建 templates/knowledge-brief.md 同契约 -->
<!--
  模板说明（复制后随正文保留至文件头部注释区，执行期可删除）:
  - 本模板由 scripts/init-session.sh 复制到 plans/task-docmod-recheck-20261112/knowledge-brief.md（第 6 计划文件）
  - 填写主体：计划期 plan-writer/主进程；执行期各 S-unit 完成后持续回填 §2/§3
  - 定位一句话：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；
    计划期产出，执行期回填
  - 与三文件罗盘关系：本文件=知识维（knowledge），不替代 findings（决策维）/ progress（进度维）/ task_plan（目标维）
  - 注意：本模板不含任务计划主模板的知识章节标题，templates/ 全库该标题 grep 锚计数维持 35（task-v115 videop1 回流 12 类后实测，template-guide.md 计数口径，验收以 guide §2.4 统一 grep 锚为准，不引行号）
-->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer/主进程产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：把 sess_1378b365「文档改后不复检即放行」缺陷固化为 Rule 106（五子条）+todo 两组契约并级联部署，判例=G22-05a 三方时间口径不一致。
- 背景/动机：用户实锤验证机制失效（改核心文件不复检就放行）+ B 扩展「todo 驱动防流程丢弃」。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| Rule 106 | 文档修改复检与 todo 驱动对齐纪律（106.1 写后回读门/106.2 派生值先定基准/106.3 同文件二次修改全量回归/106.4 验证对象=交付物本体/106.5 两组 todo） |
| 两组 todo | 通用基线组 B1-B5（验证类恒存在项，门禁挂钩）+任务步骤组（Phase/S-unit 映射），必须同步到原生 TodoWrite |
| 过程期 vs 终验期 | 106=改后即刻（过程期）；84.x=交付前（终验期）——禁互吞（verification-gate:56 互指） |
| epoch 锚 | 规则编号上界字面（Rules 1-10N），新 Rule land 后全仓级联+selftest 断言同步翻转 |
| 判例 sess_1378b365 | 修复器 v4-v6 局部修补→三方时间口径漂移→对整合版终验 PASS 但用户所见仍带缺陷（副本/本体脱钩两态） |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| Rule 106 五子条已落 discipline 规则文件 | skills/task-discipline/references/critical-rules-discipline.md:721-734（merge 02d90e2） | 新会话生效；后续规则任务最大编号=106 |
| 106 编号已 land（reserved→landed） | plans/.rule-reservations.jsonl（2026-11-13 land 行） | 下一个新 Rule=107，须先 rule-reserve |
| master selftest 基线非全绿（2 预存 FAIL） | findings §5+S5 检查点 06（active-plan T11/execution-stability T11b，双仓对照形态一致） | 后续任务基线对照勿把这 2 项归因自身；建议另立任务修 |
| EN-06 断言=纪元语义（随编号走） | selftest-enumerate-first.sh:92-99（翻转后 1-106/,106） | 下次 land 107 需再翻转该断言族 |
| S-unit 表机器列序=10 列（awk $4执行体/$5输入/$7时长/$8粒度） | check-plan-dispatch.sh:246-278 | 写计划时禁加列/禁单元格管道转义（v150+本任务双判例） |
| attest vc-gate 判据=verification.md 行首 **Verify command**: 纯命令 | attest-plan.sh:244-285 | VC 命令禁占位/禁真空（test+命令引用产出物） |
| 部署三仓收口 | 源 9126c3c..bdbcfc2 / zcode c8b874d(main) / claude cf28dd5(master) 已 push；cursor 非 git 仓落盘 | 配置仓仍有其他会话在途未提交变更（非本任务 scope，未动） |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-discipline/references/critical-rules-discipline.md | :721-734 | Rule 106 段（五子条+判例+Why；下一 Rule 107 插入点=本段后） |
| skills/task-planner/SKILL.md | :105 | 3i 修改后复检步（Phase 执行循环内过程期门指针） |
| skills/task-planner/SKILL.md | :152 | Rule 20.5 行尾豁免口径（写入确认型重读≠跨字段复检） |
| skills/task-planner/SKILL.md | :173 | 原生 Todo 同步段尾两组结构指针 |
| skills/task-planner/references/todo-sync.md | :29-46 | S1 两组结构契约块（B1-B5+生命周期+门禁挂钩+丢失重建+mini 豁免） |
| skills/verification-gate/references/critical-rules-verification.md | :56 | 84↔106 过程期/终验期互指行 |
| skills/task-planner/scripts/selftest-enumerate-first.sh | :92-99 | EN-06 纪元断言（1-106/,106） |

## §4 易错点与禁止假设清单
1. **Edit 锚点纪律（本任务双犯，已根治性记录）**：用既有整块做插入锚时 new_string 必须回填锚块原文——本会话两次吞块（user-session-log「消费点」标题、findings 106.4 整段），均靠子代理自审/自检当场捕获。禁止「锚点行只当定位不回填」。
2. S-unit 表禁加「96 类别」独立列（列序漂移=整表错位）；类别标注用目标列内（An）前缀承载。
3. selftest 剩余 2 FAIL=master 既有，禁止在本任务射程内顺手修（Rule 87/§13.3：报告+另立任务）。
4. G22-05a 文档本体两轮检索未命中（videop1 七目录+三邻接仓）——**未验证**，禁把「副本漂移 vs 虚报」写成已定事实。
5. merge 遇他任务暂存变更阻断：走 stash push→merge→stash apply --index 原样恢复（含暂存态），禁 commit 他任务文件。
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「Phase 3 epoch 锚漏改/错改」行（S5 基线对照法已消费）。

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1-S7（均已完） | §2 + §3 | findings.md §Rule106 草案/§todo 契约草案/§级联锚位清单 |
| 后续会话恢复 | §1 + §4 | progress.md + verification.md |

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| verification-gate（卫星） | skills/verification-gate/SKILL.md | 终验 VC 复验 SOP | 本仓卫星随 task-planner 生效 |
| task-dispatch（卫星） | skills/task-dispatch/SKILL.md | 派发契约/列序 | 本仓卫星随 task-planner 生效 |

## §7 项目知识库回链（终验后入库触发 — task-kb-persist-20261022 增补）
<!-- 项目级覆盖段：仅本仓（.zcode/plan-templates/ 覆盖生效）；源模板无此段 -->
- **触发点**：任务终验交付完成后（check-complete exit 0 后、归档前后皆可）
- **入库命令**：`bash scripts/kb-sync-from-plan.sh <本计划目录相对路径，如 plans/archive/task-docmod-recheck-20261112>` → 生成 knowledge/entries/_draft-task-docmod-recheck-20261112.md
- **精炼**：draft 为机械提取原文，需人工/模型合并去重→主题化→补证据锚行号→去除 `_draft-` 前缀改名
- **索引**：改名后 `bash scripts/kb-rebuild-index.sh` 重建 INDEX.md（勿手改）
- **条目规范**：见 knowledge/README.md 与 knowledge/entry-template.md（主题级合成、Rule 71 无源不写、sources 仓相对路径）
