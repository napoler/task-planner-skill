# Knowledge Brief — task-v125（任务知识简略要点）

> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由主进程产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：把「总是用通用 Agent」的三类缺口收口为机制——覆盖矩阵落仓 + Rule 49 专用体优先 + 三登记面修复 + selftest-agent-coverage 守护；执行顺序= v124 之后。
- 背景/动机：用户系统层反馈（「确保后期拆分子代理时用更对应的专业代理」）；审计实证=资产不缺（87 agent/14 族），缺「找得到+选得中」的机制。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 三登记面 | SKILL.md 路由表 / skill-agent-router SKILL.md / template-mapping §九§十（执行体登记的三处） |
| A/B/C 缺口 | A=类型无具名映射；B=登记名指向不存在/名不符实体；C=实体未登记（有体不用，41 个） |
| 覆盖矩阵 | 新落仓 references/agent-coverage.md = 执行体选型单一事实源（Rule 49） |
| 族级登记 | C 类 41 实体按 6 族行入路由表（防膨胀），矩阵逐行保可追溯 |
| AC-* | 新守护断言编号（selftest-agent-coverage.sh） |

## §2 已验证关键事实

| 事实 | 证据 file:line | 影响 |
|------|---------------|------|
| A 类：媒体 11 类+video/video-fix 无具名映射 | 2-coverage.md §二 A1/A2（mapping:277-288/:273-274） | v124 补两执行体；其余工序=兜底登记（49.2） |
| B 类 5 条实证 | script-writer/script-auditor（mapping:278）；research-assistant（SKILL:348，是 skill）；article-batch-publish（mapping:266 名漂移）；ComplexProblemSolver（SKILL:340/:350 大小写） | S3/S4 行内修正；AC-03/04 防复发 |
| C 类 41 实体名单（6 相） | 2-coverage.md §二 C（质量5/运维5/营销7/数据研究5/文档UI3+其他） | S1 矩阵逐行纳入/豁免；S3 六族行 |
| 资产 87 agent、14 族；9 大领域零专用体 | 1-inventory.md（findings 摘要） | 零领域清单=增补候选（用户裁决） |
| SKILL.md 现 447 行（skill-split 锁） | selftest-skill-split.sh:41（v122 演进值） | S3 增行后 S5 锚演进（先例） |
| 三登记面锚位 | SKILL:333-357 / router:25-101 / mapping:258-312 | S3/S4/P5 编辑定位 |
| 编号现状：48=v123/49=v126/50=v127/51=v129 全 landed；52=v125（rule-reserve 已预留） | master（多轮合流）；plans/.rule-reservations.jsonl | 本任务取 **Rule 52**（三次改号终版）；执行期先 grep 全量索引锚（v127 已扩 1-5[0-9]；v128 T-主 级联） |
| 复盘 F1 同判「v125/v126 同瞄 49」 | plans/round-retrospective-2026-10-04.md:64 | 编号预留登记制=独立小任务承接；本任务人工裁决过渡=50 |
| registry T02 硬门 | selftest-registry.sh T02 | S6 双文件（脚本+tsv） |
| rule-skill 引用实例：research-assistant 是 skill | SKILL:348 + skills/ 列表 | B3 修正为双列（Skill 调用+web-search-agent） |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要 |
|------|------|-----------|
| skills/task-planner/SKILL.md | :333-357 | 路由表（S3 六族行插表尾 :357 后；3 行内修正 :340/:348/:350） |
| skills/task-planner/SKILL.md | :282-308 | 摘要区+references 表（S3 bullet 与行尾追加） |
| skills/task-planner/references/critical-rules.md | :476-494 | Rule 46/47 尾部范式（S2 Rule 49 追加点=文末） |
| skills/plan-template-kit/references/template-mapping.md | :266, :268, :278 | 三处 B 修正（S4） |
| skills/task-planner/scripts/selftest-media-dispatch.sh | 全文 | 新守护范式（S6 照抄结构） |
| skills/task-planner/scripts/selftest-registry.tsv | 末行 | 登记行追加（S6） |
| plans/task-v125/subagent-state/2-coverage.md | 全文 | 矩阵/缺口底稿（S1 转写来源） |
| ~/.zcode/skills/skill-agent-router/SKILL.md | :25-101 | 路由表（P5 族行插入点；先 find 全部署位） |

## §4 易错点与禁止假设清单
1. 禁动：v124 媒体两行（S3 编辑范围外）、v123 终验段、既有 Rules 1-47、config.json、其他 selftest。
2. 行内替换前 grep 核原文（v123/v124 已合并可能移行）；锚不匹配=BLOCKED 上报。
3. SKILL 增行后必跑 S5 锚演进（447→实测值），否则 skill-split FAIL（v122 同型级联）。
4. B 类反证必须双侧：修正后旧字面零残留 + 新字面在位（AC-03）。
5. AC-04 实体存在性断言读 $HOME/.zcode/agents（仓外）；目录缺位 fail-open SKIPPED（禁硬 FAIL）。
6. 派发纪律：三文件绝对路径+brief §引用+8 字段+圈码 ≤4+单 ID；[readonly-parallel] 只读并行。
7. skill-agent-router 先 find 全部存在位（.zcode/.claude/…）再逐位写；写前展示 diff、写后 grep 复核。
- FMEA RPN>100 兜底指针：无（最高 36=router 位遗漏；兜底=find 全位+grep 复核）。

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1 | §1+§2（C 名单行）+§4.6 | findings.md §设计 1 + subagent-state/2-coverage.md |
| S2 | §2（编号现状行）+§3（critical 行） | findings.md §设计 3 |
| S3 | §3（SKILL 两行）+§4.1/4.2 | findings.md §设计 2 |
| S4 | §3（mapping 行）+§4.4 | findings.md §设计 2 |
| S5 | §2（447 锚行）+§4.3 | progress.md（SKILL 实测行数） |
| S6 | §2（registry 行） | findings.md §设计 4 + scripts/selftest-media-dispatch.sh |
| S7/S8 | §4.3 | progress.md 基线段 |
| S9/S10 | task_plan VC 表 | verification.md |
