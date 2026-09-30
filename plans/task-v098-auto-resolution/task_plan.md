---
template_type: rule-enhancement
plan_tier: standard
cost_estimate:
  main_process_opus: 1
  subagent_calls:
    executor: 3
    code-runner-agent: 2
  estimated_opus_equivalent: 1.2
  estimated_savings_vs_naive: 0.6
---

# Task Plan: task-v098-auto-resolution — Rule 41 问题自主消解与升级纪律（规则增强）

<!--
  WHAT: 本计划落地纯增量 Rule 41（六子条）+ selftest 守护 + SKILL 四锚联动 + 仓根 .gitignore 增补（41.3 首个消费示范）。
  WHY: 用户反馈原话（Rule 31.1 触发①）:「我发现当前遇到问题不是想方设法的解决问题 而是更加倾向于将问题推给用户 我希望可以解决 我需的是自动处理问题的能力 而不是将无关紧要内容推给用户」。
  归因（主进程已完成 31.2 四维，直接采用）:
    现象 = 遇问题倾向 STOP/询问/「留用户裁决」而非穷尽自动手段
    直接原因 = 升级点很多（22.3 档5/28 D1-D6/drift BLOCKED→STOP/escalation_threshold）但从未定义「什么才配升级用户」的门槛，升级被当默认出口
    根因（5 Whys 终点）= 缺「问题自主消解」纪律层 → 各机制各自设停点 → 停点成本低于消解成本
    类别 = 规则缺位（→ Rule 36.2 归因指向本体，修改提案合法）
  活例 = task-v097 CR P2-b（.gitignore 增补一行）被以「基建配置留裁决」推给用户，实为可自动完成的安全小修。
  交互模式: /goal 自主会话延续，interaction_mode: silent（D6 硬停点两模式一致不可豁免，Rule 41 不弱化 D6）。
-->

<!-- plan_tier: standard -->
## Goal
在 task-planner 技能内落地纯增量 Rule 41「问题自主消解与升级纪律」（41.1-41.6 六子条：消解优先原则/升级四门槛/trivial 自主裁定/升级前置消解清单/打包呈报/零新键机制），配套新建 selftest-self-resolution.sh 守护、SKILL.md 四锚联动（C29/摘要行/括注/行数级联）、全量 selftest 0 FAIL 后合并回 master、部署 3 实体位 IDENTICAL、worktree 清理，并把仓根 .gitignore 增补 `.backup-*/` 一行作为 41.3 首个消费示范直接自动修。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含 .sh 脚本 selftest-self-resolution.sh，模板画像代码组触发） |
| `session_id` | task-v098-auto-resolution（plan 目录即会话锚，注册表=plans/INDEX.md） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v098-auto-resolution` |
| `scope_files` | `skills/task-planner/references/critical-rules.md`; `skills/task-planner/SKILL.md`; `skills/task-planner/scripts/selftest-self-resolution.sh`(新); `skills/task-planner/scripts/selftest-registry.tsv`; `skills/task-planner/scripts/selftest-skill-split.sh`; `.gitignore` |
| `interaction_mode` | `silent`（/goal 自主会话延续；env TASK_PLANNER_INTERACTION_MODE 同值优先级最高；silent 语义=D6 外不 AskUserQuestion+静默决策清单登记，Rule 41.2 语义兼容） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 41 条款完整：critical-rules.md EOF 追加节头 + 六子条，`grep -c '^41\.'` = 6；41.2 含四门槛措辞 G1-G4（破坏性不可逆/范围越界/对外不可撤回发布/语义级目标分叉）；41.4 含「已尝试清单」与「D6 硬停点语义保留不弱化」措辞；41.3 含「直接做+登记」与「禁用『留用户裁决』措辞推诿」；41.6 含「零新 config 键」 | `grep -c '^41\.'` + `grep -c 'G1'/'G4'` + 逐措辞 grep | worktree 内 `references/critical-rules.md` 末段 |
| VC-2 | SKILL.md 四锚落地：C28 后新增 C29 行；Rule 40 摘要行后新增 Rule 41 摘要行；L241「含 Rule 40」→「含 Rule 40/41」；L295 References 行追加 Rule 41 括注；字面子串 `grep -c 'Rules 1-39'` = 2 且 `grep -c '1-40'` = 0（TS-05/WF-10 对策 b 锁保持）；行数级联 selftest-skill-split.sh T-主 上限 433→P2 实测值（label 注明 task-v098） | `grep -c` 逐锚 + `wc -l` 对照级联值 + `bash scripts/selftest-skill-split.sh` PASS | worktree 内 `SKILL.md` / `scripts/selftest-skill-split.sh` |
| VC-3 | 新 selftest 过 + 全量回归 0 FAIL：`bash scripts/selftest-self-resolution.sh` 全 PASS exit 0（对齐 selftest-tool-selection.sh TS 静态断言范式，含 ^41\.=6、四门槛、零新键 properties=40、Rules 1-39=2 负断言）；全量 `for f in scripts/selftest-*.sh` 逐脚本 Total 行求和 = 0 FAIL 且总数 ≥604 基线+SR 断言增量（总数=主进程逐脚本求和，禁采信子代理自报）；selftest-registry.tsv +1 行且 `bash scripts/selftest-registry.sh` PASS（双向一致） | worktree 内逐脚本实跑 | progress.md Selftest Log / selftest-self-resolution.sh 输出 |
| VC-4 | .gitignore 增补落地（41.3 首个消费示范）：仓根 .gitignore 增 1 行 `.backup-*/`，`git check-ignore .backup-20260930-test` exit 0；`git status --porcelain` 不再出现 companion/.backup-*/ 类未跟踪备份目录；该改动不进三部署位（smart-merge-back 部署槽不含仓根文件，实测 confine）；demo 残留物执行后即删 | `git check-ignore` + `git status` + Read .gitignore | worktree 内 `.gitignore` / progress.md P4 段 |
| VC-5 | 合并部署清理闭环：`git merge --no-ff wt/task-v098-auto-resolution` 成功；`bash scripts/smart-merge-back.sh <worktree> --deploy` 三位输出 IDENTICAL（~/.zcode、~/.claude、~/.config/opencode 的 skills/task-planner）；`git worktree remove` + `git branch -d wt/task-v098-auto-resolution` 完成，`git worktree list` 无残留；主仓 Read 关键文件复验（^41\.=6 在部署位命中） | smart-merge-back [DEPLOY] 行 + `git worktree list` + 部署位 grep | 主仓 git log / 合并输出 / 部署位文件 |
| VC-6 | 边界与零回归：`git diff master^..master` 对照——Rule 22.3（L151 附近）、22.7、28.2（D1-D6）、28.4/28.4.1、33.4、35.6、Rule 39 全部 39.x 行、Rule 40 全部 40.x 行原文逐字节零改动（diff 面仅限 scope_files）；Rule 41 不弱化 D6（41.4 明文「D6 硬停点语义保留不弱化」）；config.json 零改动（properties=40 维持）；Code Review Gate 输出 APPROVED | `git diff` 定向核对 + `grep '^40\.' -A0` 字节比对 + CR 输出 | progress.md / git diff 输出 / CR 报告 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策——本任务自身即 Rule 41 首个适用对象，升级前必须先过 41.4 消解清单并在上报附「已尝试清单」）

> **注意**：`code_review: required` → 终验前必须先过 Code Review Gate（改动含 .sh，属重 diff 界定以实际 diff 量为准；selftest 脚本单文件新增为主，预计轻 diff 走单轮轻量审查亦可，按 task-v094 T-B6 分级），APPROVED 才可交付。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则条款 | `skills/task-planner/references/critical-rules.md`（EOF 纯追加 Rule 41 节，格式同构 Rule 39/40） | 改既有任何 Rule 原文/语义（22.3/28/D6/33.4/35.6/39/40 全部逐字节零改动）；机械锚点级联（行号引用随追加漂移）除外且登记 |
| 技能正文 | `skills/task-planner/SKILL.md`（四处联动：C29 行新增/Rule 41 摘要行新增/L241 括注/L295 括注） | 动「Rules 1-39」字面 2 处；新增段落禁产生 `1-40` 子串；超四锚外的大段新增 |
| 测试 | `skills/task-planner/scripts/selftest-self-resolution.sh`（新建）；`skills/task-planner/scripts/selftest-registry.tsv`（+1 行）；`skills/task-planner/scripts/selftest-skill-split.sh`（仅 T-主 行数断言值级联，label 注明 task-v098） | 其他 selftest/check 脚本；断言逻辑语义改写 |
| 配置 | `.gitignore`（仓根，仅追加 1 行 `.backup-*/`） | `config.json`（零新键，properties=40 维持）；其他任何配置 |
| 计划文件 | `plans/task-v098-auto-resolution/**`（三件套与 knowledge-brief 与 subagent-state；如实披露：27.3 预检会把 `**` 剥成裸目录 token，本计划目录在簿记提交前恒为 untracked → 执行中跑 check-complete 会撞 27.3；对齐 v097 先例（checkpoint 01 :32 披露 + 终验前 1382218 簿记提交），check-complete 定位于 P5 簿记提交之后终验复跑） | 其他 plans/ 目录 |

**执行前自我检查:**
- [x] 这个文件在上面的列表中吗？
- [x] 这个修改对完成任务有必要吗？
- [x] 用户明确要求我做这个修改吗？（用户反馈原话点名「需要自动处理问题的能力」= Rule 41 提案授权；Rule 36.2 归因类别=规则缺位指向本体）
- 全部 Yes → 可以执行 | 任一 No → 先问用户

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | Rule 39/40 既有条款范式（节头+子条+机制收尾） | `/mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md` :369-402 | 必读 | ☑（plan-writer 已 Read） |
| 项目内部文档/知识库 | SKILL.md 四锚现状（C28/摘要行/Rules 1-39 字面/References） | `/mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md` :193, :241, :271, :295 | 必读 | ☑ |
| 项目内部文档/知识库 | selftest TS 静态断言范式 | `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-tool-selection.sh` :1-60 | 必读 | ☑ |
| 项目内部文档/知识库 | 行数级联断言点 | `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-skill-split.sh` :41 | 必读 | ☑ |
| 项目内部文档/知识库 | registry 双向一致契约 | `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-registry.tsv` :1-38 | 参考 | ☑ |
| 项目内部文档/知识库 | rule-enhancement 模板与机制画像 | `templates/variant/rule-enhancement-type.md` + `../plan-template-kit/references/template-mapping.md` :220, :240 | 参考 | ☑ |
| 项目内部文档/知识库 | 升级点现状（STOP/AskUser 等措辞盘点） | 本会话 grep 实测，落 findings.md「升级点盘点」 | 必读 | ☑ |
| 用户级宪法 | §十一 worktree 隔离 / §六 保护区 | `/home/terry/.zcode/AGENTS.md` | 参考 | ☑ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 技能各机制各自设停点（STOP/AskUser/留用户裁决），从未定义「什么才配升级用户」的门槛，导致遇问题把可自动消解的事项（如 .gitignore 增补一行）推给用户——补上「问题自主消解」纪律层（Rule 41），升级从默认出口变为四门槛 gated 的最后手段。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（Rule 41 六子条 + 守护 + 示范修复落地 = 交付）
- [x] 核心问题不解决，其他工作都白费吗？（不解决则用户点名的行为模式不改变，一切门控照旧推诿）
- [x] 核心问题的解决方法是清晰的、可执行的？（D2 已裁：纯增量六子条 + 零新键 + selftest 守护 + C29 消费侧；方案骨架用户已定，本计划细化不推翻）

**如果无法回答核心问题，禁止开始任务！**（已回答，归因见文件头注）

## Current Phase
Phase 4

## Next Step
主进程执行 P4:worktree 内 .gitignore +1 行（41.3 消费示范）→ commit → smart-merge-back --deploy → companion 位核对 → worktree 清理 → **git push origin master（用户授权）**。

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | ⑥ 机械守卫脚本（check-conflicts.sh/selftest 全量求和）+ ② 计划系统文件维护（归因落盘）+ ① git 编排（worktree 建立） | 基线测绘与 worktree 编排为白名单③①②直做面，无执行型工作 |
| Phase 2 | ③ Agent 子代理 executor(sonnet-1) | 条款撰写与 SKILL 联动为判断型编辑工作，主进程禁亲为（Rule 14） |
| Phase 3 | ③ Agent 子代理 executor(sonnet-1) 写脚本 + ⑥ 机械守卫（全量回归由 code-runner-agent(mini) 跑） | selftest 撰写=代码组判断型；回归实跑=机械 IO 面 mini 档 |
| Phase 4 | ① git 编排（merge/deploy/cleanup 主进程白名单①）+ ⑥ 机械验证（check-ignore/git status ③） | 部署编排是 git 生命周期操作；.gitignore 1 行为⑥⑥白名单 trivial 直做 |
| Phase 5 | ③ Agent 子代理 code-reviewer/critic(sonnet-1)（Code Review Gate 经 Skill("code-review")）+ ② 簿记 + ⑥ 终验 check-complete.sh | CR 上下文隔离审查；簿记=白名单②；终验=白名单③机械验证 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件 → 维持 Rule 21.4 串行（Phase 间强依赖：P2 条款→P3 守护→P4 合并部署，无可并行独立子任务，无长链复用，用户未点名 /workflow）。
**/goal 对齐（Rule 40.3）**: 用户已用 /goal 锚定自主会话延续（interaction_mode: silent 即其映射）；本计划 Goal+VC 表即该会话目标完成审计的证据源；如实披露：/goal 为用户侧 harness 命令，技能层不可代调、不可读取其运行态，对齐证据 = VC 证据链本身。

## Phases

### Phase 1: 基线测绘 + Rule 31 归因落盘 + worktree 隔离
- [x] check-conflicts 已跑（信号①=plans 指针+本计划目录,零重叠;隔离决策表已填 safe/worktree）
- [x] worktree 建立（@76168cb,porcelain=0）;worktree 内基线复测=37 脚本 **604/0**;wc 复核 SKILL=433/CRIT=402
- [x] Rule 31 归因落盘（progress Error Log+findings 盘点 66 处 0 门槛+Issues 活例 v097 CR P2-b）
- [x] Rule 36.3 删除基线=空清单声明落 findings
- **V-N:** VC-1, VC-2, VC-6——基线锚全部确认 ✅（progress.md Phase 1 Test Results）
- **Status:** complete
- **Executor:** 主进程（例外理由:① git/worktree 编排 + ② 计划系统文件维护（归因落盘 findings/progress）+ ③ 机械验证命令（check-conflicts/selftest 求和/wc -l 只读输出可控）——Rule 25.3 白名单①②③）

### Phase 2: 条款层 Rule 41（critical-rules.md EOF 追加）+ SKILL.md 四锚联动 + 行数级联
- [x] S1: critical-rules.md EOF（L402 后）纯追加 `### 41 问题自主消解与升级纪律（P0 — task-v098，目标：…）` 节头段 + 41.1-41.6 六子条（内容骨架见 knowledge-brief §2「已定方案」表；格式同构 Rule 39/40：节头+行首 41.N+末子条机制收尾）
- [x] S2: SKILL.md 四处联动——①C28（:193）后加 C29 行（措辞对齐 C28 句式：Rule 41.2/41.3/41.4 检查项+机器面=selftest-self-resolution 静态断言）；②Rule 40 摘要行（:271）后加 Rule 41 摘要行（六子条一句话分解，净增 ≤6 行）；③:241「（含 Rule 40）」→「（含 Rule 40/41）」；④:295 References 行末追加「/ Rule 41 问题自主消解与升级纪律」
- [x] S3: 行数级联——worktree 内 `wc -l SKILL.md` 得实测值 N，改 selftest-skill-split.sh:41 `≤433` → `≤N`，label 改注 task-v098（对齐先例「≤430→433 task-v097 Rule 40 联动」）
- [x] 字面锚自检：`grep -c 'Rules 1-39' SKILL.md` = 2 且 `grep -c '1-40' SKILL.md` = 0（新增文本禁含该子串）
- **V-N:** VC-1, VC-2, VC-6（条款六子条 grep=6；四锚在位；22.3/28/39/40 原文 diff 面外零改动）
- **Status:** complete
- **Executor:** executor（sonnet-1）
<!-- S-unit 派发单元表(Rule 22.6 — 单步 ≤2 文件/≤100 行/≤15min;ID 纯数字;时长 NNmin;输入列=路径+≤10 行摘要) -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | critical-rules.md EOF 追加 Rule 41 节头+六子条全文 | executor(sonnet-1) | `skills/task-planner/references/critical-rules.md`:369-402（Rule 39/40 节头+子条+机制收尾格式范式）；`plans/task-v098-auto-resolution/knowledge-brief.md` §2 已定方案表（六子条逐条骨架与措辞锚） | `grep -c '^41\.'`=6；节头含（P0 — task-v098）；41.2 含 G1-G4 四门槛；41.4 含「已尝试清单」「D6 硬停点语义保留不弱化」；41.6 含「零新 config 键」；既有行 diff 零改动 | 15min | pending |
| S2 | SKILL.md 四锚联动（C29/摘要行/两处括注） | executor(sonnet-1) | `skills/task-planner/SKILL.md`:193（C28 行句式）、:271（Rule 40 摘要行句式）、:241 与 :295（括注位）；`plans/task-v098-auto-resolution/knowledge-brief.md` §2 C29 措辞骨架 | C29 行与 Rule 41 摘要行在位；括注更新；`grep -c 'Rules 1-39'`=2 且 `grep -c '1-40'`=0；净增 ≤8 行 | 10min | pending |
| S3 | 行数级联 selftest-skill-split.sh 上限更新 | executor(sonnet-1) | `skills/task-planner/scripts/selftest-skill-split.sh`:41（T-主 断言行现状）；S2 完成后 `wc -l SKILL.md` 实测值 | 断言值=实测 N 且 label 含 task-v098；`bash scripts/selftest-skill-split.sh` 全 PASS | 5min | pending |

### Phase 3: 新 selftest 守护 + registry 登记 + 全量回归
- [x] S4: 新建 scripts/selftest-self-resolution.sh（对齐 selftest-tool-selection.sh TS 范式：SR-01..SR-12 静态断言，断言清单见 knowledge-brief §2 守护设计行）
- [x] S5: selftest-registry.tsv 追加 1 行（script=selftest-self-resolution.sh / domain=Rule 41 问题自主消解与升级纪律 / trigger_scenarios=Rule 41 条款/SKILL C29/skill-split 行数级联改动 / dep_anchors=critical-rules.md ^41;SKILL.md C29+Rule 41;selftest-skill-split.sh）+ 跑 `bash scripts/selftest-registry.sh` 验双向一致
- [x] S6: 全量回归——code-runner-agent 在 worktree 内 `for f in scripts/selftest-*.sh; do bash $f; done` 逐脚本 Total 求和（主进程复核定数，禁采信子代理自报总数），预期 0 FAIL 且总数 ≥604+SR 增量
- **V-N:** VC-3, VC-6（守护落地+全量 0 FAIL；properties=40 零新键断言含于 SR-10）
- **Status:** complete
- **Executor:** executor（sonnet-1）（S4/S5）；全量回归实跑=workflow 内 world.run 确定性门（silent 决策登记）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S4 | 新建 selftest-self-resolution.sh 静态守护 | executor(sonnet-1) | `skills/task-planner/scripts/selftest-tool-selection.sh`:1-60（TS 范式：变量头/ok()/bad()/编号断言/exit 语义）；`plans/task-v098-auto-resolution/knowledge-brief.md` §2 SR 断言清单 | `bash scripts/selftest-self-resolution.sh` 全 PASS exit 0；只读零仓库写入；断言含 ^41\.=6/G1-G4/D6 保留/零新键/Rules 1-39=2/C29/properties=40/registry 行/skill-split label | 15min | pending |
| S5 | registry.tsv +1 行并过一致性守护 | executor(sonnet-1) | `skills/task-planner/scripts/selftest-registry.tsv`:1-38（四列表头与既有行格式）；selftest-registry.sh 消费逻辑 | tsv=39 行且新行四列齐；`bash scripts/selftest-registry.sh` PASS | 5min | pending |
| S6 | 全量 selftest 回归求和 | code-runner-agent(mini) | worktree 内 `scripts/selftest-*.sh` 37+1 脚本清单；progress.md Selftest Log 表格式 | 逐脚本 Total 求和输出；0 FAIL；总数 ≥604 基线+SR 增量（定数由主进程复核） | 10min | pending |

### Phase 4: .gitignore 修（41.3 消费示范）+ 合并回 master + 三位部署 + worktree 清理
- [x] S7: 41.3 首个消费示范——worktree 内 .gitignore +1 行 `.backup-*/`（check-ignore PASS;commit 4bd9cc0）
- [x] S8: 合并回——smart-merge-back V1-V6 全 OK → merge **88eca16**（主仓 ^41\.=6 亲验）
- [x] S9: 三位部署——--deploy 三部署位 IDENTICAL;companion 幂等;B 类用户指令追加 `git push origin master` 成功（26f938c..88eca16）
- [x] S10: 清理——worktree remove+branch -d,残留 0/0
- **V-N:** VC-4, VC-5——全部 ✅（progress.md Phase 4 Test Results）
- **Status:** complete
- **Executor:** 主进程（例外理由:① 纯 git/worktree 编排（merge/deploy/cleanup 全链）+ ⑥ 单文件 ≤3 行 trivial 修改（.gitignore 1 行追加，非保护区）+ ③ 机械验证（check-ignore/status/worktree list 只读）——Rule 25.3 白名单①⑥③）

### Phase 5: CR Gate + 终验簿记
- [x] Code Review Gate：`Skill("code-review")` 上下文隔离审查本任务改动代码文件（selftest-self-resolution.sh / selftest-skill-split.sh 级联行；critical-rules.md/SKILL.md/.tsv 为 .md/.tsv 不入 CR 面）；APPROVED 才进终验；CHANGES_REQUESTED → fix-phase（≤3 轮，33.4）
- [x] 终验：Read verification.md 逐条复验 VC-1..VC-6（每条带证据路径）；`bash scripts/check-complete.sh` exit 0（执行顺序：先完成上一条簿记提交使 plans 目录入 tracked，27.3 预检转 clean 后再跑）；委派率统计（预期 2/5 Phase 派发=0.4<0.7，但主进程直做清单全命中白名单①②③⑥ → WHITELIST-EXEMPT 放行，按 25.4a 口径登记）；质量门控 Q1-Q6 核查
- [x] 簿记收尾：findings.md 回填全部 Handoff 行 verify_done；progress.md Error Log Prevention 列回填（Rule 31.4 沉淀 notepad「What Worked/What Didn't Work」两段=Rule 41 条款要点）；Decisions Made 登记 silent: 决策清单；task_plan.md 各 Phase 翻 complete + 隔离决策 merge_back=merged(<commit>)；**计划八件套随簿记提交入库**（对齐 v097 先例 1382218——plans/task-v098 目录入 tracked 后 27.3 预检方转 clean，check-complete 在该提交之后复跑）
- [x] 学习闭环终验：check-complete Learning Gate（Error Log Root Cause 非空）；REFLECT-GATE（progress.md 落 `- [reflect] 反思:`/`- [reflect] 验证:` 两行）
- **V-N:** VC-5, VC-6（CR APPROVED+终验全 VC 复验+零回归）
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件簿记（三件套/verification/Decisions 登记）+ ③ 机械验证命令（check-complete.sh 只读终验）——Rule 25.3 白名单②③；CR Gate 本体经 Skill("code-review") 隔离执行，非主进程亲审）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（信号①=plans/.active_plan(M)+plans/task-v098-auto-resolution/(??)——均为计划系统文件/本计划目录，与 scope 六文件零重叠；②无额外 worktree；③无遗留 wt/* 分支；④无待处理任务在册；⑤本任务 scope 即运行中基础设施→按隔离处理而非冲突） |
| `isolation` | `worktree`（修改 skills/ 保护区+运行中基础设施，宪法 §十一 11.1-1/5 强制命中） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v098-auto-resolution`（§11.2 新约定集中目录，仓外绝对路径） |
| `branch` | `wt/task-v098-auto-resolution`（基线 master@76168cb） |
| `merge_back` | `merged(88eca16)`（V1-V6 全 OK+三位 IDENTICAL+清理 0/0+push 88eca16） |

> 契约详见 `~/.zcode/skills/task-planner/references/worktree-isolation.md`。并行开发约束：CWD 不迁移，worktree 内禁碰其他 worktree，禁 checkout/reset --hard/clean -fd。

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 references/methodology.md §R2）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 2 | SKILL.md 新增文本意外产生「1-40」子串或改动「Rules 1-39」字面 → TS-05/WF-10 断言 FAIL（锚定级联事故，v097 实证风险最高行） | 8 | 5 | 2 | 80 | S2 prompt 预写禁令+验收 grep 双断言（探测已前置）；FAIL 时回 S-unit 拆细修正措辞（22.3 ②），禁改 selftest 断言迁就 |
| Phase 2 | 条款六子条措辞与既有 22.3/28/D6 语义冲突（弱化 D6 或改写既有档位语义） | 9 | 3 | 3 | 81 | 41.4 明文「D6 硬停点语义保留不弱化」+VC-6 逐字节 diff 核对；冲突时回 knowledge-brief §4 禁止假设清单修正条款文本（22.3 ②） |
| Phase 3 | 新 selftest 断言与既有断言口径冲突（如 properties=40 漂移、行数级联值与 wc 实测不一致）→ 全量回归 FAIL | 7 | 5 | 3 | 105 | 兜底=①改派 debug 定位失败断言行→②拆细为单断言修复 S-unit 重派→③升档 executor→sonnet 已在位再升主进程接管④（单文件 ≤300 行）；级联值一律以 wc 实测为准禁手估 |
| Phase 4 | 部署位 DRIFT（部署位与主仓历史 diff 或 cp 失败）→ exit 6 fail-closed | 6 | 3 | 2 | 36 | smart-merge-back 自带 fail-closed；DRIFT 时读 [DEPLOY] 逐位判定行定位，手动 diff 对账后重跑 --deploy（22.3 ③机械面） |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填。本表为规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链（本任务自身消解时先过 41.4 清单，升级上报附「已尝试清单」）。

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | S1 映射在计划批准后立即建立 |
| Phase 2 | ☐ |  | 含 S1-S3 三个 S-unit |
| Phase 3 | ☐ |  | 含 S4-S6 三个 S-unit |
| Phase 4 | ☐ |  | 含 S7-S10；主进程直做 |
| Phase 5 | ☐ |  | CR Gate+终验；主进程直做+Skill(code-review) |

> 契约详见 `~/.zcode/skills/task-planner/references/todo-sync.md`。

## Key Questions

1. Rule 41 条款文本如何措辞才能 gate 升级而不弱化 D6 硬停点？（答：41.4 明文「D6 硬停点语义保留不弱化，但触发前先过本清单的可自动部分」——后置纪律层不改既有触发条件原文）
2. selftest-self-resolution.sh 的 SR 断言集怎样覆盖六子条且与既有 37 脚本零口径冲突？（答：对齐 TS 范式纯静态 grep/wc/jq；properties=40 与 WF-12/TS-12 同口径；行数级联值以 wc 实测为准）
3. 「Rules 1-39」字面锚与「含 Rule 40/41」括注如何共存？（答：TS-05 只锁「Rules 1-39」=2 与「1-40」=0，括注更新不触碰该字面；v097 对策 b 已实证此边界）
4. .gitignore 1 行为何可 41.3 自动修而非 D4 范围询问？（答：仓根 .gitignore 已列入计划 scope_files=计划内授权；1 行 trivial 非破坏性非不可逆；v097 案例正败于此——41.3 首个消费示范即纠正此行为模式）
5. 委派率 0.4<0.7 会被 check-complete 阻断吗？（答：不会——主进程直做 Phase 清单全部命中 25.3 白名单①②③⑥，25.4a WHITELIST-EXEMPT 放行；P5 统计段如实登记）

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| D2（已裁，沿用）: 纯增量新增 Rule 41 六子条，不改 22.3/28/D6/Rule 39-40 任何原文 | 41 为后置纪律层经 checklist 生效；Rule 36.5 纯增量纪律；避免触碰 D6 硬停点语义（高危确认门） |
| 零新 config 键（41.6） | 与 task-v087/v088/v097 同范式；判定面=LLM 行为无需开关键；properties=40 维持使 TS-12/WF-12 断言零改动 |
| 消费侧=C29（合规清单行）而非新 hook/check 脚本 | 轻量消费；机器面由 selftest-self-resolution.sh 静态断言承载；避免新增运行时门控复杂度 |
| .gitignore 增补入本任务 scope 并作为 41.3 首个消费示范 | 用户归因活例即此（v097 CR P2-b 推给用户）；1 行 trivial 安全小修=41.3 直接做+登记的教科书案例；仓根文件不进三部署位（smart-merge-back 槽位实测） |
| 行数级联 label 注明 task-v098 | 先例：≤430→433（task-v097）；selftest-skill-split.sh:41 断言值随实测 wc 更新，禁手估 |
| interaction_mode: silent + code_review: required | /goal 自主会话延续；改动含 .sh 触发代码组画像 CR Gate（template-mapping.md:220） |
| 主进程直做 P1/P4/P5，理由命中白名单①②③⑥ | git 编排/簿记/机械验证/trivial 1 行均为白名单面；P2/P3 判断型工作派 executor(sonnet-1)+code-runner-agent(mini)（模型分级：判断型 sonnet、机械 IO mini，禁降 haiku——条款措辞质量直接影响 D6 边界语义，haiku 档不足以承载四门槛语义精度） |
| silent: 本计划按 /goal 自主会话直接 attest 锁定后执行（Rule 28 silent 语义，D1 门控自动通过） | 计划全文落盘可查；交付报告附静默决策清单（本表 silent: 行）供复核 |
| silent: P2/P3 执行面改经 CreateWorkflow 编排（用户 2026-09-30 显式点名 /workflow「继续使用工作流来解决这个问题」，Rule 39.1 触发） | Wave1=P2-S1 ∥ P2-S2+S3（并行,不同文件）；Wave2=P3-S4+S5；Wave3=P3-S6 回归；Wave4=CR 审查（.sh diff）——**Rule 39.4 并行豁免登记**:workflow run 内部 21.4 串行铁律豁免（仅 Wave1 两路,不同文件零写冲突）,登记于本行+progress |
| silent: CR 前置至合并前（workflow Wave4 审 worktree 内未提交 diff,过滤 .sh） | fail-fast:CHANGES_REQUESTED 时修复发生在合并部署之前,避免 v097 式合并后修复+重部署;CR 门语义不变（APPROVED 才可交付,P5 终验仍复验） |
| silent: P3-S6 全量回归由 workflow 内 world.run 确定性门执行（bash 逐脚本+主进程解析 Total 求和）,取消 code-runner-agent 派发 | dynamic-workflows §5/§12: 确定性检查用 world.run 作为代码执行,禁「派子代理跑测试再信其自报」;Handoff 行 4 相应关闭（主进程终验仍复跑复核,双保险不变） |
| B 类新指令（用户 2026-09-30「完成修改之后记得部署到各个平台，然后提交到GitHub进行备份」）: P4 部署后追加 `git push origin master` | 部署本就在计划内（P4 三位 IDENTICAL）；push=用户显式授权（v086 P4 先例,外部不可撤回面 G3 已过——本轮授权成立）；远端备份防本机丢失 |

## Errors Encountered

| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| （执行前占位——首个必记行）用户点名行为偏差：遇问题倾向推给用户而非自动消解（task-v097 CR P2-b .gitignore 一行被「留用户裁决」） | 1 | P1 落 progress.md Error Log（Root Cause=缺「问题自主消解」纪律层→各机制各自设停点→停点成本低于消解成本；类别=规则缺位）+ 修正=新增 Rule 41 六子条 | → progress.md Error Log / 沉淀 notepad（P5 回填 Prevention） |

## Notes

- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition
- 本任务自身即 Rule 41 首个适用对象：执行中任何 STOP/升级冲动先过 41.4 消解清单，上报必附「已尝试清单」——dogfooding 是本任务 VC 之外的隐性验收
- 禁止在 SKILL.md 新增文本中出现「1-40」子串（TS-05 负断言）；禁止触碰「Rules 1-39」字面 2 处

## 🚨 Drift Log（漂移检测记录）

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |             |        |      |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6）

> 本任务非批量（chain_mode: single，无 ≥5 单元批量操作），本区块按模板注记不适用；S-unit 串行派发遵循 Rule 21.4。

| 字段 | 值 |
|------|-----|
| `total` | 0（零单元声明——本任务非批量,无 ≥5 同构单元批量操作） |
| `success` | 0 |
| `failed` | 0 |
| `failure_rate` | 0%（0/0,无批量面;>5% → STOP 条款不适用） |
| `sampled_pass` | 0（零单元,抽检不适用） |
| `sampled_fail` | 0（零单元,熔断条款不适用） |
| `pre_check` | Q1:否（每 Phase 独立判断，非同质单元）/Q2:有（VC 表客观验收）/Q3:能（worktree+git 可回滚） |
| `rollback_point` | master@76168cb（worktree 隔离天然回滚点） |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 2 / 5（P2、P3——经 workflow dwfrun-9a720fe2 编排执行,Rule 39.4 并行豁免已登记） |
| 主进程直做 Phase 清单 | P1（①git 编排+②计划系统文件+③机械验证）/ P4（①git 编排+⑥trivial 1 行+③机械验证）/ P5（②簿记+③机械验证；CR 经 Skill 隔离）——全部命中 25.3 白名单 |
| 委派率 | 0.4（<floor 0.7 → 走 25.4a WHITELIST-EXEMPT 判定：直做理由全白名单 → 放行不降级） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-09-30 | executor | P2-S1 条款层 Rule 41 六子条追加 | running | | | | plans/task-v098-auto-resolution/subagent-state/02-executor-p2s1.md | workflow dwfrun-9a720fe2 Wave1 / 0 / ☐ |
| 2 | 2026-09-30 | executor | P2-S2/S3 SKILL 四锚联动+行数级联 | running | | | | plans/task-v098-auto-resolution/subagent-state/03-executor-p2s2s3.md | workflow dwfrun-9a720fe2 Wave1 / 0 / ☐ |
| 3 | 2026-09-30 | executor | P3-S4/S5 新 selftest+registry 行 | running | | | | plans/task-v098-auto-resolution/subagent-state/04-executor-p3s4s5.md | workflow dwfrun-9a720fe2 Wave2 / 0 / ☐ |
| 4 | | code-runner-agent | P3-S6 全量 selftest 回归求和 | queued | | | | plans/task-v098-auto-resolution/subagent-state/05-runner-p3s6.md | - / 0 / ☐ |
| 5 | | code-reviewer | P5 CR Gate 隔离审查 | queued | | | | plans/task-v098-auto-resolution/subagent-state/06-cr-p5.md | - / 0 / ☐ |

## 🔗 Chain 区块交接配置（可选）

| 字段 | 值 |
|------|-----|
| **chain_mode** | `single`（单 block，无 chain 区块） |
| **current_block** | Block 1 |
| **handoff_on_complete** | ✅ 是（/goal 会话目标审计） |

### 🔗 Handoff 追踪表

| Block | 状态 | 交接产物路径 | 验证命令 | 实际完成时间 |
|-------|------|------------|---------|-------------|
| Block 1 | in_progress | plans/task-v098-auto-resolution/ 三件套+knowledge-brief | `bash scripts/check-complete.sh` | - |

## 🔁 模板感知
<!-- template_type: rule-enhancement -->
- 已知 16 类类型之一（rule-enhancement），非 general 兜底；无 [template-sense] 激活需求
- Rule 34.3① 同类第 N 次命中（v071/v074/v076/v079/... 规则增强序列）——variant 已存在（rule-enhancement-type.md），无重复沉淀（34.5 先查重已过）
