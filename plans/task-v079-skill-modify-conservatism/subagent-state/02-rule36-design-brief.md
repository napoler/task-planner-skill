# 设计简报 02 — Rule 36 技能修改保守化与功能删除防护（主进程裁定，plan-writer 直接采用）
> 裁定人：主进程（task-v079 计划期）；依据：用户 2026-09-17 原始诉求 + 01-explore-conventions.md 结构侦察。

## 用户原始诉求（复述）
1. 执行任务中技能出错时，agent 常把「修改技能内容」当第一补救动作，而根因未必在技能本身 → 技能被"偷渡"修改。要求预防。
2. 真实事故：用户的文章优化技能中「流量分级优化」功能（流量多→仅微调，流量少→深度优化）在未知时点被静默移除，导致高流量旧文被彻底重构、既有流量尽失，后期持续产出低质量内容。要求防止已有功能被静默移除。
3. 技能修改默认更保守；确需修改时必须请求用户提示/确认。

## Rule 36 条款设计（写入 references/critical-rules.md，追加 `### 36 技能修改保守化与功能删除防护（P0 — task-v079，目标：技能文件修改先归因再动刀、删除已有功能=高危须用户逐项确认、默认纯增量，杜绝偷渡式修改与功能静默丢失）`）

- **36.1 适用范围与触发**：任何技能文件写操作（SKILL.md / references/ / scripts/ / templates/ / config.json / companion agents 及一切 `skills/<name>/` 目录下文件，含仓库副本与已部署副本），无论主进程还是子代理、无论计划内还是执行期临时起意。命中即进入本 Rule 流程。机械联动（锚点级联如 Rules 1-35→1-36、INDEX 行数、引用同步）不算功能删除，登记即可。
- **36.2 归因前置门（防盲目修改）**：执行期任务失败/技能表现异常时，「修改技能」禁止作为第一补救动作；必须先按 31.2 完成 4 维归因。仅当归因结论指向**技能本体缺陷**（规则缺位/条款错误/脚本 bug）才可发起修改提案；其余类别按 31.3 路由（信息缺失→补调研、假设未验→修计划、执行偏差→修正执行、数据源过时→修数据源），**禁止以改技能替代**。与 31.3 衔接：31.3 已规定执行期内本体修改走后续任务；36.2 细化唯一例外 = 归因指向本体 且 用户显式要求当前任务内修改。
- **36.3 修改前基线（防静默移除）**：动手修改目标技能文件前必须建立删除基线：目标在 git 仓内 → 用 `git diff` / `git log --follow` 提取既有功能面（条款/子条/脚本断言/config 键/模板段/消费侧门控）；目标不在 git 仓（如未纳管技能）→ 先 `cp` 基线副本到 `<plan-dir>/skill-baseline/`。产出**「删除性行为清单」**（将删除/改写的功能项逐条列出，落 findings.md + progress.md）。
- **36.4 删除=高危确认门**：任何功能性删除或既有语义改写（非纯新增）→ 逐项列清单交用户确认（ask 模式 AskUserQuestion 列删除项+理由；属 Rule 28 D6 级硬停点语义——**引用 D6 不扩列，不改 Rule 28 既有语义**）；silent 模式同样不得跳过（D6 两模式一致）。未确认前禁止执行该删除。
- **36.5 保守化修改纪律**：默认纯增量追加；既有条款语义变更须同时 ① 计划「执行范围限制」表逐行登记 ② progress.md 记录旧语义→新语义对照；禁止以「重构/顺手整理/清理」名义触碰未授权区域。
- **36.6 修改后回归验证**：对照 36.3 基线——删除清单每项要么已获用户确认、要么实际零删除；selftest 全量 0 FAIL；SKILL/锚点 grep 复核。
- **36.7 机制**：config 键 `skill_modify_enforce`（enum [enforce,warn,off]，**默认 warn**，description 注明 Rule 36）。消费侧三件：① 新建 `scripts/check-skill-modify.sh` 挂入 zcode-pretooluse.sh 的 Write/Edit 分支——目标路径（realpath 归一化，兼容 worktree 与部署位）命中技能文件模式 且 当前活跃计划「执行范围限制」表未列该文件 → warn 注入提醒（enforce 档 exit 2 阻断）；**对主进程与子代理一致生效**（补 check-delegation 子代理 exit 0 的空档）；② check-complete.sh 追加 SKILL-MODIFY GATE（终验校验删除性行为清单已登记且逐项有确认记录，resolve tier 范式）；③ 新建 `scripts/selftest-skill-modify.sh` 静态守护（selftest-veto.sh 范式：36.x 条款锚 + config 键 json 校验 + SKILL 联动 + C24 + pretooluse 接线锚 + GATE 锚）。

## SKILL.md 联动（净增 ≤10 行纪律）
1. Critical Rules 列表加 Rule 36 行（格式对齐 Rule 31/32 行）
2. 合规清单加 **C24**（格式对齐 C20/C23：涉及技能文件修改时已按 36.2 归因+36.3 基线+36.4 确认；纯新增/机械联动 → PASS 记一行）
3. §用户新指令处理 段加「**技能文件修改保守化（Rule 36 — task-v079）**：…」指针段（对齐 31/32/33/34 段落格式）
4. 锚级联：「Rules 1-35」→「1-36」——SKILL frontmatter references 行、L278 行头、References 表、README.md:67、batch-quality-gate.md；动手前 `grep -rn "Rules 1-" scripts/` 全修齐；selftest-conclusion-discipline CD-11/CD-12 断言同步（1-35→1-36）

## 不改动清单（保守化自身示范）
- Rule 28/31/32/35 既有语义（仅引用衔接，禁止改写其条款文字）
- templates/variant/rule-enhancement-type.md（工作区已有 v077 遗留未提交 diff——保持不动，计划登记说明）

## Phases（沿用 rule-enhancement variant P1-P5 骨架与 Executor 约定）
- P1 隔离与基线：worktree `wt/task-v079-skill-modify-conservatism`（宪法 §十一，集中目录 /mnt/data/dev/task-planner-skill-worktrees/task-v079-skill-modify-conservatism）+ 全量 selftest 基线（主进程逐脚本 Total 求和）+ 插入点锚确认。Executor: 主进程（白名单①）+ code-runner-agent
- P2 条款+config 键+消费侧门控：S1 Rule 36 条款（critical-rules.md 追加 ~25 行）/ S2 config.json 键 / S3 check-skill-modify.sh 新建+zcode-pretooluse.sh 接线 / S4 check-complete.sh SKILL-MODIFY GATE。Executor: executor（sonnet-1）严格串行，S-unit 7 列表（ID 纯数字，步级 ≤2 文件/≤100 行/≤15min）
- P3 selftest 守护+锚点修复：新建 selftest-skill-modify.sh + 既有锚宽容化/级联（CD-11/CD-12、1-35→1-36）。Executor: executor（sonnet-1）
- P4 SKILL 联动+文档同步+全量回归：SKILL.md 三处联动+级联+净增纪律复核+主进程复跑全量 selftest 定数。Executor: executor（sonnet-1）
- P5 合并回+部署+簿记：smart-merge-back --deploy 3 实体位 + 主进程 diff -r 亲验 + INDEX/ledger + worktree 清理。Executor: 主进程（白名单①②）

## VC-1..5（照 variant 模板具体化）
- VC-1 条款完整：critical-rules.md 含 36.1-36.7 且引用 31.3 衔接与 D6 语义（grep 验证）
- VC-2 config 键：skill_modify_enforce 三档+默认 warn（python3 json 校验）
- VC-3 消费侧实测：check-skill-modify.sh 三档行为各一实测证据 + pretooluse 接线 grep + SKILL-MODIFY GATE 存在
- VC-4 全量 selftest 0 FAIL（总数=主进程逐脚本 Total 求和，禁采信子代理自报；新 selftest-skill-modify 全 PASS）
- VC-5 SKILL 联动+锚级联（grep -rn "Rules 1-" 零残留 1-35 旧锚）+ 3 实体位部署 diff=0

## 计划 frontmatter/其他
- template_type: rule-enhancement（已过 init 路由）；code_review: required（改动含 .sh）；interaction_mode: ask；reflect_verify: required
- Decisions Made 预登记：① Rule 36 设计裁定=用户 2026-09-17 诉求+文章优化技能流量分级功能静默移除事故 ② 保守化示范=引用 D6/31.3 不改既有条款语义+不动 v077 遗留 diff ③ skill_modify_enforce 默认 warn（观察期先例）
- 知识储备表：01-explore-conventions.md ☑ / 02-rule36-design-brief.md ☑
- 隔离决策：worktree（仓库=运行中基础设施，信号⑤已命中）
