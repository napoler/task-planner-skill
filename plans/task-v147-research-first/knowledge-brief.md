# Knowledge Brief — task-v147-research-first（任务知识简略要点）

## §1 任务速览与核心概念
- 任务一句话：在 task-planner 技能落地 Rule 63「检索优先与反推诿纪律」（条款文本+SKILL/派发模板传播+selftest 守护+FF-16 宽容化），全量 selftest 无回归增量后合并部署三位 IDENTICAL。
- 背景/动机：用户 2026-10-08 裁决——agent 遇知识缺口以「不知道」作答不检索是严重缺陷；网络权限下信息面基本无限制（唯一边界=用户私人数据），不知道先查、一切有理有据禁编造。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| worktree | git 隔离开发区，实现类任务必须在其中开发（§十一） |
| S-unit | Phase 内一次 Agent() 派发对应的最小执行单元（22.6 表一行） |
| 锚宽容化 | 守卫脚本的计数/负断言窗口随新规则号平移（v121/v146 先例），防新规则误触发旧守卫 |
| FF-16 | selftest-four-file-dataflow.sh 的「62 块尾 63.x 负断言」前向防线（:27 注释/:108 断言） |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| Rule 63 编号空闲 | `bash scripts/rule-reserve.sh check 63` → `free`（2026-10-08 实测）；台账 plans/.rule-reservations.jsonl 尾行=61 landed | attest 声明 new_rule:63 自动预留，合并后 land |
| critical-rules.md 共 766 行，文件尾=Rule 59 段（:747-766） | Read 实测（master e54973d） | S1 插入点=文件尾追加，既有行零改动 |
| SKILL.md 三处 `1-62` 计数锚 :9/:275/:346；合规清单尾=C43 | grep 实测 | S2 逐锚联动；:9 行含 stale 括注「（61 预留未落地）」本次不动（findings Issues 已登记） |
| FF-16 负断言：:27 注释 + :108 `TAIL61=...awk '/^60\.6 /{f=1} f' | grep -c -e '^63\.[0-9] '` | grep 实测 | S4 宽容化 `^63\.`→`^64\.`（两处同步：注释+断言） |
| selftest 基线 ΣPASS=934 / ΣFAIL=4（FAIL=periodic PR-03/04/05/10 基线预存） | plans/task-v146-drift-check-subagent/progress.md 尾段（台账锚） | Phase 4 回归对照基准：ΣFAIL ≤4 且 FAIL 构成不变；新增 selftest 只增 PASS |
| selftest 脚本 60 个；registry 三列 TSV（文件名\t描述\t锚点面） | ls + tail 实测 | 新增后 61 个；S5 尾追一行 |
| dispatch 模板 §2 结构：:26 knowledge-brief 契约行、:33 伴飞技能节 | grep 实测 | S3 插入点=:26 行后 |
| CHANGELOG 在仓根（非 skills/ 下），Keep-a-Changelog，[Unreleased]/新增 prepend | head 实测 + git show 02747b6 | S2 条目插「### 新增」列表头部 |
| Rule 60 定位 :680-714；22.3.0 定位 :166 | Read 实测 | 63.5 衔接条引用行号免查 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| references/critical-rules.md | :747-766（供料 2026-10-08，源=master e54973d；行号以实施日重验为准） | 文件尾 Rule 59 段（合并序尾），S1 追加插入点=:766 之后 |
| references/critical-rules.md | :680 / :166 | Rule 60 头 / 22.3.0 资料先行档（63.5 引用锚） |
| SKILL.md | :9 / :275 / :346 | 三处 Critical Rules 计数与列表（1-62→1-63） |
| SKILL.md | Critical Rules bullet 列表尾（Rule 62 bullet 后）/ 合规清单 C43 行后 | S2 追加 bullet 与 C44 的插入点 |
| templates/subagent_dispatch.md | :26 后 | §2 knowledge-brief 契约行，S3 检索契约行插入点 |
| scripts/selftest-four-file-dataflow.sh | :27 / :108 | FF-16 注释 / TAIL61 负断言（S4 宽容化点） |
| scripts/selftest-registry.tsv | 文件尾 | S5 追加登记行（三列 TSV） |
| CHANGELOG.md（仓根） | [Unreleased]→### 新增 列表头 | S2 条目插入点 |
| plans/task-v147-research-first/findings.md | §Research Findings | Rule 63 条款草案全文+S2/S3 逐字文案+RF 断言清单（各 S-unit 材料包主料） |

## §4 易错点与禁止假设清单
1. 禁改 22.4a/62.2 派发契约既有原文（KQ 判例：收窄即违规）——S3 只允许在 :26 后追加新行。
2. FF-16 类负断言=前向防线：新增规则必须同步宽容化（63.x→64.x，注释+断言两处同步），否则 Phase 4 全量回归 FF 脚本 FAIL（锚级联第 N 次实证）。
3. 并行组 S-unit 只写文件不 commit——同 worktree 并发 git 提交=index.lock 资源相争（21.4 四问②）；commit 收敛主进程 Phase 收口按 scope 清单统一提交。
4. S-unit 表 ID 列纯数字（禁 S2a 式）；执行体列格式 `executor(sonnet-1)`；粒度三值 `Nf/Nl/Nmin` 任一超 2f/100l/15min=attest 拒锁。
5. SKILL.md :9 行「（61 预留未落地）」为存量 stale 文案——本次不动（scope 纪律），已登记 findings Issues 交对齐审查。
6. selftest 新增脚本禁触碰既有脚本断言（55.6 防锚级联范式：只断言新增锚）。
- FMEA RPN>100 兜底指针：无（最高 RPN=84，Phase 2 S1 语义重叠——兜底=对齐审查 Phase 4 S7）

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1 | §2(插入点)+§3(尾部锚) | plans/task-v147-research-first/findings.md §「Rule 63 条款草案」 |
| S2 | §2(SKILL 锚)+§3 | plans/task-v147-research-first/findings.md §「SKILL 联动文案锚」 |
| S3 | §3(:26) | plans/task-v147-research-first/findings.md §「subagent_dispatch.md §2 检索契约行」 |
| S4 | §2(FF-16 锚)+§4(易错点 2) | 扫描命令：`grep -rn '1-62\|40-62\|\^63\\\.' scripts/selftest-*.sh`（worktree 内执行） |
| S5 | §2(基线)+§3(registry)+§4(易错点 6) | plans/task-v147-research-first/findings.md §「RF 断言清单」+ 范式参照 scripts/selftest-four-file-dataflow.sh |
| S6 | §3 + task_plan scope | git diff 基点=wt 分支点 e54973d |
| S7 | §3 + task_plan scope | 伴飞：~/.zcode/skills/alignment-review/SKILL.md（首动作 Read） |

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| alignment-review | ~/.zcode/skills/alignment-review/SKILL.md | S7 对齐审查（42.6.2 标准收尾） | 子代理 prompt 挂载（伴飞 Read，59.2 范式） |
| verification-before-completion | ~/.zcode/skills/verification-before-completion/SKILL.md | Phase 5 终验前完成度自查 | 主进程消费（宪法 §三 要求） |
| skill-fix / skill-evolve | ~/.zcode/skills/skill-fix/SKILL.md 等 | 本任务为计划内规则增强，非缺陷修复——不激活（登记防闲置质疑） | 不适用 |
