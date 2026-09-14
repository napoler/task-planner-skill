# skill-collaboration — 专业技能协同路由（comet/OpenSpec/superpowers）

> **定位**：task-planner 的「专业技能协同路由」层——把复杂任务按信号移交/嵌入到 comet、OpenSpec、superpowers 三族专业技能协同解决，task-planner 专注统筹编排。
> **权威源声明**：本文件 = 协同路由唯一权威源。SKILL.md 只保留触发条件与指针行，规则细节以本文件为准。
> **开关键**：`config.json#skill_collab_enforce`，enum `enforce|warn|off`，默认 `warn`：
> - `off` = 跳过移交评估与 22.3.3（旧行为）
> - `warn` = 提醒性评估（命中矩阵提示移交、22.3.3 评估记录不强制）
> - `enforce` = 计划期命中矩阵必须登记不移交理由方可继续；22.3.3 未评估禁止 ⑤AskUser/STOP
> - 三档均流程层执行，无 hook 校验；`enforce` 档语义预留（description 注明）

## §一 三族能力画像表

（源：subagent-state/01-explore-skill-families.md「一、三族画像表」，压缩为表；证据 = 各成员 SKILL.md，见末列）

### A. comet 族（13 成员，`~/.zcode/skills/comet*`）

- **定位**：跨会话项目级变更工作流托管引擎（`.comet.yaml` 状态机 + Comet CLI），Classic（OpenSpec+superpowers 双星）/ Native 两套独立工作流
- **工作流**：open → design → build → verify → archive；短路径预设 hotfix（bug 单 change）/ tweak（轻中量改）
- **输入**：用户原始请求 + `.comet.yaml` 状态 + `comet workflow resolve . --activate --json` + 仓库 dirty 状态
- **输出物**：proposal.md / design.md / tasks.md / delta spec / 验证报告 / 归档提交 + 状态推进；跨会话断点恢复（resume-probe）
- **成本量级**：重（跨会话托管 + CLI + 状态机 + 10 个用户决策点）
- **CLI 依赖**：`comet` CLI + `.comet.yaml` 激活
- **成员分工**（证据）：comet(入口 haiku) / comet-classic(主流程 opus, SKILL.md:111-116,202-211) / comet-native / comet-open(sonnet) / comet-design / comet-build / comet-verify(haiku) / comet-archive(haiku) / comet-hotfix(sonnet, SKILL.md:13-18,180-192) / comet-tweak(haiku) / comet-any(元技能) / comet-review / comet-memory

### B. OpenSpec 族（11 成员，`~/.zcode/skills/openspec-*`）

- **定位**：spec 驱动的「提案→实现→归档」change 生命周期；核心 openspec-propose（一次生成全部 artifacts）+ openspec-onboard（教学）
- **工作流**：explore → new/propose → specs → design → tasks → apply → verify → archive
- **输入**：change 描述 + openspec CLI + 已有 `openspec/` 根目录
- **输出物**：change 目录（proposal/design/specs/tasks）+ 实现代码 + 归档 `changesDir/archive/YYYY-MM-DD-<name>/`
- **成本量级**：中（单会话多步 CLI 往返，无跨会话托管）
- **CLI 依赖**：`openspec` CLI + `openspec/` 目录
- **成员分工**（证据）：propose(SKILL.md:27-98) / new-change / ff-change / continue-change / explore / apply-change / verify-change / archive-change / bulk-archive / sync-specs / onboard(SKILL.md:40-50)

### C. superpowers 族（10 成员，`~/.agents/skills/`）

- **定位**：单会话「过程纪律 + 执行手法」技能集——先查技能再动手 / 根因优先 / 先测后码 / 审查纪律
- **工作流**：无跨会话固定阶段；brainstorming → writing-plans → executing-plans / subagent-driven-development → test-driven-development → requesting/receiving-code-review → finishing-a-development-branch 灵活组合
- **输入**：任务描述 + spec/需求 + 代码库；using-superpowers（SKILL.md:10-16）为前置铁律
- **输出物**：无跨会话文件；设计共识 / 实施计划 / 通过的测试 / 审查反馈 / 合并收尾
- **成本量级**：轻（单 Skill 调用，无托管无状态机）
- **CLI 依赖**：无（纯 .md 技能）
- **成员分工**（证据）：using-superpowers / brainstorming / writing-plans / executing-plans / subagent-driven-development / systematic-debugging(根因 4 阶段, SKILL.md:19-22,195-197) / test-driven-development / requesting-code-review / receiving-code-review / finishing-a-development-branch

| 族 | 定位 | 成本量级 | CLI 依赖 | 最强信号 |
|----|------|---------|---------|---------|
| comet | 跨会话变更托管 | 重 | comet CLI + .comet.yaml | Phase≥5/跨模块/需架构/需归档/跨会话续做 任意 3 项 |
| OpenSpec | spec 驱动 change 生命周期 | 中 | openspec CLI + openspec/ 目录 | 需求需 spec 化 / 变更触及已有 spec |
| superpowers | 单会话过程纪律 | 轻 | 无 | bug→systematic-debugging；TDD→test-driven-development；合并前→requesting-code-review |

## §二 协同路由触发矩阵（D1）

**计划期**（T0 计划确认前评估）。判定顺序敏感、先命中先用（重→轻）：**comet → OpenSpec → superpowers**；多族命中 = 叠加协同（comet classic 本身即 OpenSpec+superpowers 双星）。

| 族 | 触发信号（命中任意） | 成本 | CLI 探针前置 |
|----|---------------------|------|-------------|
| comet | 现有任意 3 项（Phase≥5 / 跨模块 / 需架构选型 / 新功能 feature / 需 proposal-design-tasks 三件套归档 / 期望跨会话断点续做） | 重（跨会话托管） | `command -v comet` + `.comet.yaml` 激活状态 |
| OpenSpec | 需求模糊需 spec 化（proposal/design/specs/tasks 产物有留存价值）/ 项目已有 `openspec/` 目录且变更触及 spec / 用户要求提案评审流 | 中（单会话多步 CLI） | `command -v openspec` + `openspec/` 目录 |
| superpowers（嵌入为主） | bug 排查→systematic-debugging；实现前需 TDD→test-driven-development；需求不清→brainstorming；按既有书面计划执行→executing-plans / subagent-driven-development；合并前→requesting-code-review + finishing-a-development-branch | 轻（单 Skill 调用） | 无（纯 .md 技能） |
| progress-tracker（嵌入，Rule 30 专属触发，task-v071） | 共享内容认领追踪命中 30.1 识别条件（可枚举共享资源且只认领一部分 / 同类任务 ≥3 次）→ 设计期 D1 前调用创建/复用项目级账本（.zcode/ledger/ 或 .claude/ledger/ 多平台跟随）+ 认领登记 30.3 + 防冲突 30.4 | 轻（Skill 调用 + JSONL 追加） | 无（纯 .md 技能；探针=`~/.zcode/skills/progress-tracker/SKILL.md` 存在，缺失 → 提醒用户先建该技能，本项降级 warn 不阻塞） |

- **移交（handoff）**：主进程让出统筹权，按「移交评估流程」（总结已有 plan 内容 → 提示用户 → 用户确认 → 引导启动目标技能 → 主进程簿记 handoff）；silent 模式按 Rule 28 推荐项自主处置并登记 `silent:` 决策行（推荐项 = 命中 comet 3 项即移交，否则留在 task-planner）
- **嵌入（embed）**：主进程保持统筹，Phase 内调用成员技能作为执行 SOP（计子代理路由表的 Skill() 列），无需用户确认
- **CLI 缺失降级**：探针失败 → 该族标记「不可接管」，继续评估下一族或留在 task-planner，禁止假设已装
- **两层正交**：子代理选型走 SKILL.md §子代理路由表（skill-agent-router），技能族选型走本矩阵；两层互不替代
- **成本护栏**：移交/接管调用计入 Rule 17 opus 节流

## §三 卡壳升级阶梯 22.3.3（D2 全文）

> 22.3.3 **协同技能接管评估(task-v066)**：位于 ④主进程接管 与 ⑤AskUserQuestion 之间的兜底档——④ 接管不可行（任务超单文件 ≤300 行上限且 22.3.2 拆细后仍无法接管）或 ④ 接管后仍失败时，⑤ AskUser/STOP 之前，主进程必须先评估「是否存在更适配的专业技能族可接管」：① 任务整体超载/需跨会话托管 → `Skill("comet")`（先跑 CLI 探针，见 references/skill-collaboration.md D1）② 需求/规格层反复返工 → `Skill("openspec-propose")` 规格化 ③ 单点能力缺口（调试/TDD/审查）→ superpowers 对应成员技能。探针前置：`command -v comet` / `command -v openspec`，CLI 缺失或项目未激活 → 该族标记不可接管并评估下一族，禁止假设已装。接管语义：把剩余工作连同 task_plan 快照（Goal+VC+已完成 Phase 摘要，格式见 skill-collaboration.md §移交/回填合约）交目标技能，task_plan.md Handoff 表登记 `skill:<name>` 行；接管成功 → 剩余 Phase 由目标工作流推进；接管失败 → 才允许 ⑤ AskUser（silent 模式按 28.4.1 降级交付，禁空等）。约束：接管调用计入 Rule 17 opus 节流；接管后执行体仍受 Rule 13/14 约束；本评估为 22.7 穷尽集合的组成部分（①②③④+22.3.3）。

### 22.3 兜底全序图

```
① 改派（换更合适的 subagent 类型；provider 类失败走 22.3.1 ①-fb 零消耗改派）
→ ② 拆细（22.3.2）
→ ③ 降档（model_downgrade）
→ ④ 主进程接管（≤300 行）
→ 22.3.3 技能族接管评估（comet / openspec-propose / superpowers，探针前置）
→ ⑤ AskUser / STOP（silent 按 28.4.1 降级交付）
```

**与既有条款关系**：
- 22.3.1 provider 改派 = 通道改派（同技能族换 provider），22.3.3 = 换技能族接管，两者不重叠
- 22.7 穷尽集合 = ①②③④+22.3.3；「≥2 次失败禁直接 STOP」语义不变，22.3.3 补入穷尽集合一档
- 28.4.1：silent 模式 22.3.3 评估登记静默决策行；接管失败走 ⑤ 时按 28.4.1 降级交付，禁空等
- 22.3.3 位于 ④ 与 ⑤ 之间：专业接管优先于主进程硬扛失败后直接问用户

## §四 移交/回填合约（D4 全文）

**移交快照**（写入 `<plan-dir>/handoff-snapshot.md`，prompt 附路径）：

```
task_id / Goal 原文 / VC 表全文 / 已完成 Phase+证据路径 / 未完成 Phase 清单 /
Decisions Made 关键行 / 工作分支与 worktree 路径 / CLI 探针结果
```

**主进程簿记**：Handoff 登记表加一行（subagent_type=`skill:<name>`，状态=handoff/rolled_back）；隔离决策表注记接管方。

**回填**：目标技能完成 → 产物路径回填 findings.md `## Resources`，交付报告注明「由 <skill> 接管完成」。

**回退**：移交后发现不适配 → 用户否决权恒有效；task_plan.md 标 `handoff_rolled_back`，主进程恢复统筹。

## §五 反模式清单

1. **禁假设 CLI 已装**——`command -v comet` / `command -v openspec` 探针未跑即决定移交/接管 = 违规；CLI 缺失该族只能标「不可接管」
2. **禁跳过探针直接移交**——移交/接管前必须完成 CLI 探针前置（§二 判定矩阵「CLI 探针前置」列）
3. **禁把嵌入当移交**——嵌入（embed）模式下主进程保持统筹，禁止把「Phase 内调用成员技能」升级成让出统筹权；移交必须走「移交评估流程」+ Handoff 登记
4. **禁接管失败直接 BLOCKED 不走 ⑤**——22.3.3 接管失败后必须落到 ⑤ AskUser/STOP（silent 模式按 28.4.1 降级交付），禁止以「接管失败」为由空等或直接 BLOCKED
5. **禁接管调用不计 Rule 17 节流**——接管/移交调用计入 Rule 17 opus 节流（同 phase ≤1 次），绕过节流 = 成本违规
6. **禁 silent 模式静默移交不登记**——silent 下推荐项处置必须登记 `silent:` 决策行（comet 命中 3 项 → 移交；否则留 task-planner）
