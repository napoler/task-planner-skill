# Knowledge Brief — task-v157-error-fix-prompt-forge（任务知识简略要点）

> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由主进程产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：在仓库新建顶层 skill `error-fix-prompt-forge`（SKILL.md+模板+selftest+registry 登记），把已完成根因定位的错误排查结果转化为可派发的专业修正提示词，冒烟实跑通过且全量回归 FAIL=0，合并回 master 并三宿主部署 IDENTICAL。
- 背景/动机：用户要求「对错误排查调研，将排查结果，并且生成提供专业的提示词，用于后期的修正」——排查结论与修正执行之间存在高质量任务书断层。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| error-fix-prompt-forge | 本任务新建的 skill 名：排查结果→fix prompt 锻造器 |
| fix prompt | 自包含修正任务书：根因+证据锚+范围+禁改区+≥1 机器可检查验收+回滚，可直接派发子代理执行 |
| QC-FP | fix prompt 自检表（QC-Fix-Prompt-1..6，Step 4 逐条 PASS 才可交付） |
| 三态结论 | READY（全 PASS）/ PARTIAL（有未验证区）/ BLOCKED（根因未定位或验收不可判定） |
| worktree | git 隔离开发区，本任务在 /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| v106 先例：新建顶层 skill = SKILL.md + scripts/selftest-*.sh + selftest-registry.tsv 追加 1 行，共 3 文件 land | git show --stat b5acff6（merge commit 文件清单）；memory: projects/task-planner-skill-fba311568bf6d7b3/memory/task-v106-iterative-optimizer.md:16 | 本任务四件（+模板）不超先例结构；registry 行必须追加 |
| iterative-optimizer SKILL.md=97-98 行，结构=frontmatter(name+description 触发词)/Goal/触发条件/输入契约/执行流程/门控铁律/输出合约/反模式 | skills/iterative-optimizer/SKILL.md:1-97 | SKILL.md ≤100 行按此结构压缩；frontmatter description 必须双语触发词密集 |
| selftest 范式：断言编号 IL-01..08、脚本可独立执行 exit 0、相对路径解析禁写死 /home/terry | skills/iterative-optimizer/scripts/selftest-iterative-optimizer.sh:1-80（v106 记忆 S75-D1 合规） | 新 selftest 用 FP-01..NN 编号；断言对象用相对路径 |
| selftest-registry.tsv 现 66 行（65 selftest + 表头），TSV 四列：脚本名/说明/守护锚/关联文件 | wc -l skills/task-planner/scripts/selftest-registry.tsv=66；末行 selftest-parallel-scheduling.sh 行 | 追加行格式对齐末行；新增后总数 66→67，回归时查计数级联 |
| 派发纪律：prompt ≤3000 字符；S-unit ≤2 文件/≤100 行/≤15min；九字段模板；8 字段严格返回 | ~/.zcode/skills/task-planner/templates/subagent_dispatch.md:86（§9 预算）；SKILL.md Rule 22.4b:62-77 | 派发 prompt 禁贴全文；子代理返回必须 8 字段 |
| 主进程 Write/Edit 白名单外被 check-delegation hook 拦截；白名单=①git 编排②计划系统文件③机械验证④用户要求⑤22.3 兜底⑥≤3 行 trivial | ~/.zcode/skills/task-planner/SKILL.md 六项白名单段；本会话已实证：哨兵期非 plans/ 写入被拦 | SKILL.md/模板/selftest 一律派子代理写；主进程只动 plans/ |
| live ~/.zcode/skills/task-planner 与仓库 skills/task-planner 的 init-session.sh 一致 | diff -q 两处 init-session.sh → IDENTICAL | 仓库为 truth source；部署后须三宿主 diff 对账 |
| master 持续前进（并发会话）：worktree 创建时 HEAD=f6d6158 | git worktree add 输出 "HEAD is now at f6d6158" | 合并回前以 merge 时点 master 为准；禁从 main（15a3ecf 落后）建 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/iterative-optimizer/SKILL.md | :1-97 | 顶层执行型 skill 完整范式（frontmatter→Goal→触发→契约→流程→门控→输出合约→反模式→尾部注释锚） |
| skills/iterative-optimizer/scripts/selftest-iterative-optimizer.sh | :1-80 | selftest 脚本范式（IL-01..08 断言+exit 0） |
| skills/task-planner/scripts/selftest-registry.tsv | :1-66 | 65 个 selftest 登记行；末行=v153 parallel-scheduling |
| plans/task-v153-parallel-scheduling/fix-prompts.md | 全文 | Phase 4 冒烟 fixture：真实排查调研结论（A/B/C fix prompts 形态） |
| ~/.zcode/skills/task-planner/templates/subagent_dispatch.md | :1-88 | 九字段派发模板（22.4a/22.4b） |
| skills/task-planner/lib/install-companion.sh | 待验 | 三宿主部署工具（--target ×3）；用法 Phase 5 前 head 验证 |

## §4 易错点与禁止假设清单
1. 禁止从 main 建 worktree（main=15a3ecf 落后 master=78b9659→f6d6158，文件不同步——worktree-branch-desync 教训）
2. 禁止触碰其他 worktree（v152/v154/v155）与其他 plans/ 任务目录；只读查询也限于 git worktree list/log
3. registry 追加行禁改动既有行；新增 selftest 后回归必须查「脚本总数/断言总数」级联断言（计数漂移=回归 FAIL 首因）
4. dispatch prompt 禁占位符（{placeholder} 形态）与「参考相关文件」模糊指代（No-Placeholder 契约 Rule 21.6.4）
5. SKILL.md frontmatter name 必须=目录名 error-fix-prompt-forge；description 触发词中英双语
6. 零新 config 键、零新 Rule 编号（v106 先例）；本任务不动 config.json
7. 主进程不得亲自 Write SKILL.md/模板/selftest（白名单外）；只派子代理+Read 验收
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「Phase 3 子代理一次成型不符仓库风格」行（S1 拆两轮/22.3① 改派 executor）

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| Phase 1 S1（explore 侦察） | §1 + §2 + §3 | /mnt/data/dev/task-planner-skill/skills/（目录树）、~/.zcode/skills/（能力清单）、plans/task-v153-parallel-scheduling/fix-prompts.md（fixture 形态）、~/.agents/skills/systematic-debugging/（既有排查 skill） |
| Phase 3 S1（SKILL.md） | §2 + §3 + §5 设计定稿详述 | skills/iterative-optimizer/SKILL.md（范式）、skill-creator 插件 SKILL.md（作者范式参考） |
| Phase 3 S2（模板） | §5 设计定稿详述 | 无（槽位以详述为准） |
| Phase 3 S3（selftest+registry） | §5 设计定稿详述 | skills/task-planner/scripts/selftest-registry.tsv（格式）、selftest-iterative-optimizer.sh（范例） |
| Phase 4 S1（冒烟） | §2 + §3 | Phase 3 产物三件 + fixture plans/task-v153-parallel-scheduling/fix-prompts.md |
| Phase 4 S2（回归） | §2 | skills/ 全部 selftest-*.sh（跑全量） |

### 设计定稿详述（Phase 2 主进程产出，Phase 3 编写唯一依据）

**SKILL.md 结构（目标 ≤100 行，行号顺序即章节顺序）**：
1. frontmatter：`name: error-fix-prompt-forge`（=目录名）；`description` 中英双语触发词密集（错误排查/troubleshooting/排查结果/修正提示词/fix prompt/修正任务书/根因/root cause），含「不触发」指向（未定位根因先 debugger/systematic-debugging）
2. `# error-fix-prompt-forge · 排查结果→修正提示词锻造` + 一句话闭环说明
3. `**Goal**`：输入=已定位根因的排查结果包；输出三项=fix-prompt.md / QC-FP 自检表 / 三态结论
4. `## 触发条件`：触发 3 条 + 不触发 4 条（未定位根因→先排查；无需派发的一次性小修→直接做；通用提示词润色→prompt-master；质量审查→review 族）
5. `## 执行前输入契约`（表）：症状+影响面(必填)/复现路径(必填或登记为何不可复现)/根因结论(必填)/证据锚 ≥1 条(file:line 或命令输出)/已尝试方案(必填防重复)/约束禁改区(可选)；契约规则=fail-closed：缺必填→STOP 与用户协商，协商不成不启动；根因未定位=BLOCKED 退回排查
6. `## 执行流程(五步)`：
   - Step 0 输入校验：逐项核契约；根因结论无证据锚→只可进「未验证假设区」并显式标注；根因未定位→BLOCKED 不出稿
   - Step 1 结构化抽取：排查结果→槽位表（问题陈述/根因+证据/影响面/复现/禁改区/验证判据/回滚/参考材料）
   - Step 2 缺口分析：逐槽位问「执行体拿到这个能干活吗」；阻断级缺口（缺机器可检查验收/缺复现路径/缺范围定义）→禁出稿+列清单交用户补；非阻断→「未验证假设区」登记
   - Step 3 渲染：按 templates/fix-prompt-template.md 产出 fix-prompt.md；遵守派发纪律（绝对路径/单 S-unit/≤3000 字符/禁花括号缩写/步骤枚举 ≤4）
   - Step 4 自检交付：QC-FP-1..6 逐条核验，机检项跑命令附输出
7. `## QC-FP 自检表`（6 条）：FP-1 自包含（无代词悬指/裸文件名，全部绝对路径）；FP-2 根因证据锚在位可复现；FP-3 ≥1 机器可检查验收判据；FP-4 单 S-unit 范围单一；FP-5 无占位符与「应该没问题」类措辞；FP-6 未验证内容已隔离且显式标注
8. `## 门控铁律`：[P0] 无证据锚根因禁入提示词主体；[P0] 阻断级缺口禁出稿；[P0] 自检禁主观自报机检项必跑命令；[P1] 同法重复失败→换策略
9. `## 输出合约`：fix-prompt.md 路径 + QC-FP 表（逐条 PASS/FAIL+证据）+ 三态结论 READY/PARTIAL/BLOCKED 定义
10. `## 反模式`：把未定位材料当排查结果/无验收标准任务书/一次塞多个修复/拿本 skill 替代排查/「应该没问题」自报
11. 尾部注释锚：`<!-- task-v157-error-fix-prompt-forge;顶层执行型 skill;与 debugger/systematic-debugging 边界=消费排查结论;install-companion 顶层分发 -->`

**fix-prompt-template.md 结构（目标 ≤60 行，含填写说明注释）**：
槽位顺序=① 任务一句话+范围(files) ② 背景与根因(证据锚 file:line) ③ 复现(命令/步骤) ④ 约束与禁改区 ⑤ 执行步骤(枚举≤4) ⑥ 验收判据(≥1 机器可检查) ⑦ 验证命令 ⑧ 回滚 ⑨ 未验证假设区(可空) + 定义完成(DoD) 一行。每槽位配 1 行 What+Why 填写注释（Rule 45）。

**selftest-error-fix-prompt-forge.sh（目标 ≤90 行，断言 FP-01..08）**：
FP-01 SKILL.md 存在+frontmatter name=目录名+description 非空；FP-02 六区块锚齐全（触发条件/输入契约/执行流程(五步)/门控铁律/输出合约/反模式）；FP-03 fail-closed 条款：BLOCKED 与「根因未定位」共现；FP-04 QC-FP ≥6 条且含机器可检查条款；FP-05 模板存在+九槽位锚（根因证据锚/复现/范围/禁改区/验收/回滚/未验证假设区/DoD）；FP-06 模板槽位与 SKILL Step 1 槽位表对齐（≥5 个槽位词互现）；FP-07 registry 末行登记 error-fix-prompt-forge；FP-08 config.json 零新键（grep error-fix-prompt-forge config.json =0）。相对路径解析（禁写死 /home/terry）；exit 0=PASS。

**registry 追加行格式**（TSV 4 列对齐末行）：`selftest-error-fix-prompt-forge.sh` TAB `Rule 21.6 兄弟位:error-fix-prompt-forge 五步闭环守护（FP-01..08）` TAB `输入契约 fail-closed/五步流程/QC-FP 6 条/模板九槽位对齐/三态结论/SKILL 六区块/零新键` TAB `skills/error-fix-prompt-forge/SKILL.md;skills/error-fix-prompt-forge/templates/fix-prompt-template.md;skills/task-planner/scripts/selftest-registry.tsv;skills/task-planner/config.json`

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| skill-creator（插件） | /home/terry/.zcode/cli/plugins/cache/zcode-plugins-official/skill-creator/0.1.0/skills/skill-creator/SKILL.md | SKILL.md 从零起草与 description 触发词精修 | 子代理可按需 Read 参考（frontmatter 未声明 disable-model-invocation；未实测调用，仅作范式参考，仓库既有 iterative-optimizer 范式优先） |
| systematic-debugging | ~/.agents/skills/systematic-debugging/SKILL.md | 与目标 skill 的边界对象（排查侧能力） | 侦察对象（Phase 1 S1 只读比对） |
