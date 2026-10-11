# Knowledge Brief — task-v083 批量试点先行硬门（任务知识简略要点）
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由主进程产出（plan-writer 不可用环境），执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：为 Rule 18（批量处理质量门控）末尾纯追加 18.9 试点先行硬门/18.10 投毒红线/18.11 宁慢勿错 + batch-quality-gate.md 详解 + SKILL.md 行内联动（净增 0）+ 新建 selftest-batch-pilot.sh + CHANGELOG，全量 selftest 0 FAIL 后合并部署 push
- 背景/动机：用户 2026-09-18 训诫「单个处理都做不好还恶意批量处理=投毒；无十足把握禁批量；宁慢勿错」——18.1-18.8 只管批中/批后，缺启动前置门

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 试点先行（Pilot-First） | 批量启动前必须先对 1 个代表性样本完成单件「处理→端到端验证」且通过，证据落 progress.md |
| 投毒红线 | 单件失败且根因未定位/未修复复验时启动或继续批量 = P0 级违规（明知不可靠仍扩大爆炸半径） |
| 十足把握四构成 | ①单件试点通过 ②首批小步（≤5 单元）③批间抽检（18.2）④可回滚/可枚举已写对象 |
| 纯追加（Rule 36.5） | 只加不改不删；git diff 对照分支点必须只有 `+` 行 |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| Rule 18 现状=八条款 18.1-18.8，无启动前置试点门 | references/critical-rules.md:76-83 | 18.9-18.11 插入位=L83 后，纯追加 |
| Q3「3-5 单元试点」仅是不可回滚补救动作 | references/batch-quality-gate.md:17 | 18.9 是普适前置门，详解段须写明分层防误读 |
| batch-quality-gate.md=134 行 v2.2；"八条款"两处 L25/L130；§二表 L27-37；L35 零单元逃生注记在表外 | references/batch-quality-gate.md:1,25,35,130 | 联动改两处字样+表尾 L37 后加 3 行；追加行避让 L35 注记 |
| SKILL.md=543 行；Rule 18 摘要行含「前置 3 问评估 + 双采样抽检 + 失败率熔断 + Batch Report 八字段」 | skills/task-planner/SKILL.md（Critical Rules 列表） | 行内改净增 0，wc -l 须仍=543 |
| 行数断言三处值 ≤548 | selftest-knowledge-brief.sh:38 / selftest-skill-collab.sh:81 / selftest-execution-stability.sh:72 | 净增 0 则三断言自然绿 |
| config.json 零 batch 相关键 | grep batch config.json（空结果） | 零新 config 键口径 |
| 并行 v082 活跃：worktree b9ba09a+INDEX 在册+TAMPERED；范围=Rule 35 族 35.6 插入式+SKILL C23/Rule 35 行+CHANGELOG | plans/task-v082-minimal-probe/task_plan.md（只读）；git worktree list | 同文件异条款区合并顺序敏感；v082 全程禁碰 |
| CHANGELOG 格式=v081/v080 bullet 在 ## [Unreleased] ### 新增 下 | 仓库根 CHANGELOG.md:11-13 | S4 照格式追加 |
| 本仓 selftest=22 脚本；总数口径=主进程逐 Total 行求和 | ls scripts/selftest-*.sh | 禁采信子代理自报总数 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/references/critical-rules.md | :76-83 | Rule 18 八条款 18.1-18.8（18.9-18.11 追加于 :83 后） |
| skills/task-planner/references/critical-rules.md | :179,187,199 | Rule 26 Q6 引用 18.3/18.6（本任务不改动，确认无波及） |
| skills/task-planner/references/batch-quality-gate.md | :25-37 | §二八条款表（v2.2；本任务加 3 行+标题字样联动） |
| skills/task-planner/references/batch-quality-gate.md | :100-111 | §五 关系表（加 Rule 31 关系行）；:114-122 §六 教训表（加用户训诫行） |
| skills/task-planner/references/batch-quality-gate.md | :126-134 | §七 关联文档（「八条款」字样联动）；文末加 §八详解段 |
| skills/task-planner/SKILL.md | Critical Rules 列表 Rule 18 行 | 摘要行行内追加试点先行引用（净增 0） |
| 仓库根 CHANGELOG.md | :11 起 | ### 新增 下追加 v083 bullet |

## §4 易错点与禁止假设清单
1. 纯追加铁律：禁动 18.1-18.8 任何一行；git diff 对照分支点（c10e8f2）只许 `+` 行（VC-1/VC-2 硬条件）
2. "八条款"字样两处（L25/L130）必须联动"十一条款"，漏一处=回归 FAIL
3. SKILL.md 净增 0：只许行内改；改动后确认该行既有锚子串（如「Batch Report 八字段」）仍在，防他 selftest 锚定断裂；兼容 v082 VC-2 的 wc=543 预期
4. v082 worktree/plans 目录全程禁碰（含不代为重锁其 TAMPERED attestation）
5. S-unit ID 纯数字；派发 prompt 8 字段标签逐字校验（check-dispatch enforce 档）
6. selftest 总数禁采信子代理自报，主进程逐 Total 行求和；合并后 master 必须重跑（不采信 worktree 期结果）
7. 部署源=主仓副本 skills/task-planner（DEPLOY_SRC=$MAIN_REPO/...），部署后 diff -r 三位主进程亲验（v077 根因已修仍保留亲验）
8. Bash/sed 改计划文件=TAMPERED（只许 Edit 工具改 plans/）；本任务文件编辑自身按 18.9 示范单件串行逐件验证
- FMEA RPN>100 兜底指针：无 RPN>100 项（最高 P5 合并竞态 RPN=72，兜底=rebase 重跑 P4 再合并；→ task_plan.md FMEA 表 P5 行）

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1 | §1 + §2 + §3 | plans/task-v083-batch-pilot-first/findings.md §条款定稿 |
| S2 | §2 + §3 + §4 | plans/task-v083-batch-pilot-first/findings.md §详解段大纲 |
| S3 | §3 + §4 | plans/task-v083-batch-pilot-first/findings.md §SKILL 联动 |
| S4 | §2 + §3 | plans/task-v083-batch-pilot-first/findings.md §CHANGELOG 草稿 |
| S5 | §3 + §4 | plans/task-v083-batch-pilot-first/findings.md §断言清单 |
