# Knowledge Brief — task-v098-auto-resolution（任务知识简略要点）

> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer/主进程产出，执行期持续回填。

## §1 任务速览与核心概念

- 任务一句话：纯增量落地 Rule 41「问题自主消解与升级纪律」（critical-rules.md 六子条 + selftest 守护 + SKILL.md 四锚联动 + 行数级联），并把仓根 .gitignore 增补 `.backup-*/` 一行作为 41.3 首个消费示范，全量 selftest 0 FAIL 后合并 master、部署 3 位、清理 worktree。
- 背景/动机：用户反馈原话点名「遇到问题不是想方设法解决而是推给用户，需要自动处理问题的能力」——升级点遍地（STOP/AskUser/留用户裁决）却从未定义「什么才配升级」的门槛。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 消解优先（41.1） | 遇问题第一反应=自动消解链（重读计划三文件→22.3 ①-④→35.6 最小探针→拆细→35.2 替代路径三关），升级=最后手段 |
| 升级四门槛（41.2） | 仅 G1 破坏性不可逆 / G2 范围越界 / G3 对外不可撤回发布 / G4 语义级目标分叉 四类可升级用户，其余自动消解+登记 |
| trivial 自主裁定（41.3） | 命名/格式/注释/一致性顺带修/明显正确小修（含 .gitignore 增补类）=直接做+登记，禁「留用户裁决」措辞 |
| 升级前置消解清单（41.4） | AskUser/STOP 前必过消解清单+附「已尝试清单」；D6 硬停点语义保留不弱化 |
| 打包呈报（41.5） | 多待决项一次性打包+每项附推荐与默认动作，禁逐个骚扰 |
| 行数级联 | selftest-skill-split.sh:41 T-主 断言值随 SKILL.md 行数实测值更新，label 注明 task 代号（先例 task-v097: ≤430→433） |
| 三位部署 | smart-merge-back.sh:377 默认槽=~/.zcode、~/.claude、~/.config/opencode 的 skills/task-planner |
| 对策 b 字面锚 | 「Rules 1-39」字面在 SKILL.md 恒 =2（:241/:295）且「1-40」子串恒 =0，由 TS-05/WF-10 断言锁死 |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| master HEAD=76168cb，SKILL.md=433 行，critical-rules.md=402 行 | `git rev-parse HEAD` + `wc -l` 实测（2026-09-30 本会话） | P1 worktree 基线与 P2 级联计算起点；级联目标值=改后 wc 实测，禁手估 |
| config.json properties 键数=40 | `jq '.properties \| length' config.json` 实测 | Rule 41 零新键 → properties 维持 40，TS-12/WF-12 断言零改动 |
| C28 在 SKILL.md:193；Rule 40 摘要行在 :271；「Rules 1-39」字面 2 处在 :241/:295 | SKILL.md 实测 grep | 四锚编辑点定位；C29 接 :193 后，Rule 41 摘要行接 :271 后 |
| selftest-skill-split.sh:41 = T-主 行数断言 `≤433（task-v097 Rule 40 联动 430→433）且 ≤558` | scripts/selftest-skill-split.sh:41 Read | 级联改此行断言值+label；≤558 上限不动 |
| TS-05 断言：SKILL.md 「Rules 1-39」=2 且「1-40」=0；WF-10：4 索引文档命中总和 ≥6 | scripts/selftest-tool-selection.sh:53-57 / selftest-workflow-orchestration.sh:52-57 | 新增文本禁含「1-40」；禁动两处字面（v097 对策 b 实证边界） |
| 全量 selftest 基线 37 脚本 604/0（v097 终验） | 调用方提供基线；P1 复测定数 | P3-S6 全量求和 ≥604+SR 增量；总数=主进程逐脚本 Total 求和禁采信子代理自报 |
| 升级点盘点：SKILL.md STOP×14/AskUser×6/等决策×2；critical-rules.md STOP×23/AskUser×17/等决策×4/留用户×0（合计 66 处） | 本会话 `grep -o \| wc -l` 实测（已同步 findings.md） | 归因「规则缺位」量化证据：66 处升级出口措辞、0 处升级门槛定义 |
| critical-rules.md 关键联动锚：22.3 五档=L151、22.7/22.7.1=L160-161、28.2 D1-D6=L249、28.4/28.4.1=L252-253、33.4=L305、35.6=L328 | critical-rules.md 实测 grep -n | VC-6 逐字节零改动核对清单；41.x 条款引用行号来源 |
| 三位部署槽=smart-merge-back.sh:377；.zcode/.claude 两部署位当前与主仓 IDENTICAL | smart-merge-back.sh:377 + diff 实测 | P4-S9 部署对账预期 IDENTICAL；opencode 位随 --deploy 一并 |
| 仓根 .gitignore 现 6 行，缺口实证：`git check-ignore .backup-20260930-test` → NOT ignored（`.backup/` 仅匹配该名字目录） | .gitignore + check-ignore 实测 | 追加 1 行 `.backup-*/` 即闭环；此为 v097 CR P2-b 遗留与 41.3 消费示范 |
| .gitignore 为仓根文件，不在三部署槽内 | smart-merge-back.sh:377 槽清单 | 该改动随 merge 进 master 即生效，不参与 deploy 对账（如实披露） |
| 冲突扫描信号①=plans/.active_plan(M)+plans/task-v098-auto-resolution/(??)，②③④⑤无信号 | check-conflicts.sh 实跑（2026-09-30） | conflict_scan=safe；两信号均计划系统文件与 scope 零重叠 |
| Rule 41 已定方案（D2 已裁勿推翻）：41.1 消解优先链/41.2 四门槛 G1-G4/41.3 trivial 直接做+登记/41.4 前置清单+已尝试清单+D6 保留/41.5 打包呈报/41.6 零新键+SR selftest+C29 消费侧 | 调用方方案骨架（本计划 Phase 2 S-unit 材料包） | 条款撰写唯一蓝本；执行期不得改语义只可细化措辞 |
| SR 断言清单（新建 selftest-self-resolution.sh，SR-01..SR-12）：^41\.=6 / 41.2 含 G1-G4 / 41.4 含「已尝试清单」+「D6 硬停点语义保留不弱化」 / 41.3 含「直接做」+「留用户裁决」禁令措辞 / 41.6 零新键+properties=40 / SKILL 三锚（C29/Rule 41 摘要/括注 Rule 40/41）/ Rules 1-39=2 且 1-40=0 / skill-split label task-v098 / registry 行存在 | 计划期设计（对齐 selftest-tool-selection.sh TS-01..12 范式） | S4 撰写蓝本；TS 范式=变量头/ok()/bad()/编号断言/exit 0-or-1/只读零写入 |
| 机制画像：rule-enhancement ∈ 代码组 → Code Review Gate+修改后验证流程适用，执行体路由 code-assistant/executor | ../plan-template-kit/references/template-mapping.md:220, :240 | code_review: required 合法；executor(sonnet-1) 路由依据；主进程 git 编排=白名单①（:240 印证） |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md | :369-402 | Rule 39（:369 节头+39.1-39.7）与 Rule 40（:393 节头+40.1-40.6）完整条款块——Rule 41 追加格式范式（节头含 P0—task-id 目标句；子条行首 NN.M；末子条机制收尾声明零新键+selftest） |
| /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md | :151-161 | 22.3 五档兜底链原文（①改派②拆细③降档④接管⑤AskUser）+22.7/22.7.1 连续失败 STOP 与上报最小集——41.1 消解链引用对象，零改动 |
| /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md | :249-253 | 28.2 ask 询问点 D1-D6 + 28.4/28.4.1 silent 语义与 D6 例外——41.2 四门槛的语义邻接区，D6 硬停点零弱化 |
| /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md | :305, :328 | 33.4 迭代边界≤3 轮（超限走 22.3/28）；35.6 最小探针原则——41.1 消解链第 3 环引用 |
| /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md | :193 | C28 合规清单行（Rule 40.2/40.3/40.4 检查项句式+机器面=selftest-tool-selection 静态断言）——C29 接续其后，句式对齐 |
| /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md | :241 | 「详见 references/critical-rules.md（Rules 1-39（含 Rule 40））」节头——括注改「含 Rule 40/41」，字面 Rules 1-39 不动 |
| /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md | :271 | Rule 40 摘要行（六子条一句话分解句式）——Rule 41 摘要行接续其后，净增 ≤6 行 |
| /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md | :295 | References 表 critical-rules.md 行（末尾含「Rule 40 harness 工具面主动选择」）——行末追加「/ Rule 41 问题自主消解与升级纪律」 |
| /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-skill-split.sh | :41 | T-主 行数断言：`≤433（task-v097 Rule 40 联动 430→433）且 ≤558`——级联点：值改 P2 后 wc 实测，label 注 task-v098 |
| /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-tool-selection.sh | :1-60 | TS 范式全貌：头注断言清单/变量定义（CRIT/SKILLMD/CONFIG/TPL…）/ok()/bad()/TS-01 六子条锚 `grep -c '^40\.'`=6——SR 脚本直接对标 |
| /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-registry.tsv | :1-38 | 四列 TSV（script/domain/trigger_scenarios/dep_anchors），37 脚本行+S5 追加第 39 行（selftest-registry.sh 守护双向一致） |
| /mnt/data/dev/task-planner-skill/.gitignore | :1-6 | 现行：`.backup/`、`__pycache__/`、plans 指针目录、session-owner——追加 1 行 `.backup-*/` 至 `.backup/` 行后 |
| /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/smart-merge-back.sh | :377 | SLOTS 默认=3 真实部署位（zcode/claude/opencode 的 skills/task-planner）——P4-S9 对账对象 |

## §4 易错点与禁止假设清单

1. 禁止改 22.3/28.2（D1-D6）/28.4/33.4/35.6/Rule 39 全部 39.x/Rule 40 全部 40.x 任何原文——41 为后置纪律层，语义经 41.4「D6 硬停点语义保留不弱化」明文保留；VC-6 逐字节 diff 核对（§3 锚点行号清单为核对范围）。
2. 禁止在 SKILL.md 新增文本中产生「1-40」子串（TS-05 负断言 FAIL=回归事故）；禁止触碰「Rules 1-39」字面 2 处（:241/:295）——括注只能改「含 Rule 40」→「含 Rule 40/41」。
3. 行数级联值必须以 S2 完成后 worktree 内 `wc -l` 实测为准，禁止手估；忘改 selftest-skill-split.sh:41 = 全量回归 FAIL（v097 同位事故先例）。
4. 条款措辞禁用弱化词：41.x 不得出现「尽量消解」「可考虑不升级」类软措辞——消解是默认动作、升级是四门槛例外，方向不可倒置。
5. registry 与 selftest 脚本必须同 PR 同步（selftest-registry.sh 双向一致守护）——新脚本落盘而 tsv 未 +1 行（或反向）= 回归 FAIL。
6. .gitignore 增补后验证用 `git check-ignore <探针名>` 而非肉眼；验证探针（.backup-<ts>-demo 目录）验后必删，禁残留。
7. .gitignore 是仓根文件、不在三部署槽——禁止假设 smart-merge-back --deploy 会同步它；其生效路径=git merge 进 master。
8. 全量 selftest 总数判定=主进程逐脚本 Total 行求和，禁止采信子代理自报总数（模板 VC-4 红线原文）。
9. P4 主仓 merge 前必须确认 worktree `git status` 干净且主仓无 scope 重叠未提交变更（worktree-isolation.md 合约条件③），否则 STOP 报告而非硬合。
10. 禁止假设 interaction_mode 可走 ask——/goal 自主会话已裁 silent；唯一例外=D6 硬停点（两模式一致），且触发前仍须先过 41.4 可自动部分。
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「Phase 3 新 selftest 断言与既有断言口径冲突」行（兜底=①改派→②拆细→③④接管链，级联值以 wc 实测为准）。

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1（P2 条款） | §1 概念表 + §2 已定方案行 + §3（critical-rules.md :369-402 范式 / :151-161, :249-253, :305, :328 联动锚）+ §4 第 1/4 条 | /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md |
| S2（P2 四锚） | §2 四锚行 + §3（SKILL.md :193/:241/:271/:295）+ §4 第 2 条 | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md |
| S3（P2 级联） | §3（selftest-skill-split.sh:41）+ §4 第 3 条 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-skill-split.sh |
| S4（P3 selftest） | §2 SR 断言清单行 + §3（selftest-tool-selection.sh:1-60 范式）+ §4 第 5 条 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-tool-selection.sh |
| S5（P3 registry） | §3（selftest-registry.tsv:1-38）+ §4 第 5 条 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-registry.tsv |
| S6（P3 回归） | §2 基线行（37 脚本 604/0）+ §4 第 8 条 | （worktree 内 scripts/selftest-*.sh 全集） |
| S7-S10（P4 部署链） | §2 部署槽行 + .gitignore 行 + 冲突扫描行 + §3（smart-merge-back.sh:377）+ §4 第 6/7/9 条 | /mnt/data/dev/task-planner-skill/.gitignore |
