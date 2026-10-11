# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 优化 task-planner:复杂/开发类问题能协同调用更专业技能(comet 族 / OpenSpec 族 / superpowers 族)一起解决
- 遇到解决不了的问题时,能自动寻找更适配的技能接手(卡壳升级阶梯新增 22.3.3「协同技能接管评估」)
- task-planner 专注统筹编排,不是所有工作都自己做

## 基线勘察(计划期, 2026-09-13, 证据 file:line)
- SKILL.md 共 508 行(500 边界遗留), L46-52「🚀 复杂功能开发 → 移交 /comet 工作流」段(任意 3 项命中→移交) `skills/task-planner/SKILL.md:46-52`
- critical-rules.md 224 行: Rule 22.3 L124 五档兜底全序(①改派②拆细③降档④主进程接管⑤AskUserQuestion/STOP), 22.7 L132(≥2 次失败禁直接 STOP,须换档重试), 28.4.1 L223(D6 silent 降级交付,禁静默空等)
- config.json L81-89 fmea_enforce 范式(enum enforce/warn/off, 默认 warn)——本任务 skill_collab_enforce 对齐此范式
- selftest 体系: scripts/selftest-*.sh(10 个) + tests/smoke.sh; 基线 159 用例(task-v065 后)
- 部署位 9 处, 合并后 smart-merge-back.sh <worktree> --deploy 部署对账 + diff -r 复验; sync-companion 有反向拉回陷阱, 部署一律定向 cp -rL

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **Phase 1 三族画像（seq 01 explore，全文见 subagent-state/01-explore-skill-families.md）**：
  - comet 族（13 成员）= **重**：跨会话变更托管引擎（.comet.yaml 状态机+CLI），open→design→build→verify→archive，可断点恢复；信号=新 capability/API/schema/跨模块/需归档/跨会话续做（证据 comet/SKILL.md:16-25, comet-classic:111-116）
  - OpenSpec 族（11 成员）= **中**：spec 驱动 change 生命周期（propose 一次生成 proposal/design/specs/tasks→apply→verify→archive）；信号=有明确 change 容器且需 spec 产物（证据 openspec-propose/SKILL.md:27-98）
  - superpowers 族（10 成员）= **轻**：单会话过程纪律技能集（systematic-debugging 根因 4 阶段/writing-plans/executing-plans/TDD/code-review）；信号=单会话 bug 调试/多步实现/合并前审查（证据 systematic-debugging/SKILL.md:19-22）
  - 路由裁定输入：三族**叠加非互斥**，顺序敏感先命中先用 comet>OpenSpec>superpowers（重→轻）
- **现有协同条款盘点**：唯一移交条款=SKILL.md:46-52（仅覆盖 comet）；22.3.1 provider 改派与技能族接管语义不重叠；Rule 17 opus 节流须把接管调用计入；Rule 13/14 对接管后执行体仍生效
- **selftest 冲突面（Key Q3 答案）**：唯一硬断言=scripts/selftest-fallback.sh:125（精确五档全序字符串）+ :126 tier_order length==5；subagent-fallback.sh:286 hint 文本+数组联动；check-rescue-chain.sh:5/selftest-rescue-chain.sh:57,72 仅注释/fixture 非冲突；templates/subagent_dispatch.md:109 档位清单文档性同步项
- **设计裁定输入（Phase 2 用）**：① 22.3.3 插 ③降档 与 ④主进程接管 之间（④之前，专业接管优先于主进程硬扛——对齐用户「统筹者不硬扛」诉求+调研路由建议#5）；② tier_order 建议扩 6 项（fallback 时刻 hint 是行为驱动源，不纳入则 22.3.3 只活在 reference）；③ **CLI 可用性探针前置**（comet/openspec 强依赖 CLI+项目激活，接管评估先探测，未装则该族不可接管降级）

#### [sub:04-executor] S3 产出
- S3 三处文本改动全部完成(6/6 验收 PASS)：① critical-rules.md L126 插入 22.3.3 条款(位于 22.3.2 段 L125 与 22.4 L127 之间,独立行,含技能族 ①comet/②openspec-propose/③superpowers + CLI 探针前置 + 接管语义 + Rule 17/13/14 约束 + 权威源指针) ② 22.7 行(L133)双替换「档位与 22.3.3 协同接管评估」「⑤ STOP」 ③ 22.7.1 行(L134)「①-④ 与 22.3.3 逐档」 ④ templates/subagent_dispatch.md L109 档位清单同步 ⑤ references/skill-collaboration.md L74 全序图 ① 行修正为「换更合适的 subagent 类型；provider 类失败走 22.3.1 ①-fb 零消耗改派」
- 验收证据：grep -n "22.3.3" critical-rules.md 命中 L126/L133/L134；22.3 五档行(L124) git diff 零改动；git diff --numstat = critical-rules.md +3/-2 + subagent_dispatch.md +1/-1（skill-collaboration.md 为 S1 新建 untracked 文件，本步仅改 1 行）
- 负结果报告：未改 SKILL.md/config.json/tests/；SKILL.md 工作树 M 状态为 S2 既有改动(+8/-6)非本步；selftest-fallback.sh:125 硬断言(tier_order)影响面未在本步范围内，留 S4/主进程处置

#### [sub:05-executor] S4 产出
- 改动 4 处全部完成（5/5 验收 PASS）：① subagent-fallback.sh:286 `*` 分支 hint 于 ④主进程接管 与 ⑤AskUser 之间插入「22.3.3 技能族接管评估(见 references/skill-collaboration.md)」，tier_order 扩为 6 项 `[dispatch_swap,split,model_downgrade,main_takeover,skill_takeover,ask_user]` ② subagent-fallback.sh:282 `timeout` 分支仅 tier_order 数组同步扩 6 项（hint 拆细指引文本未动）③ selftest-fallback.sh:123-128 T10 区：注释更新、T10a 精确字符串更新为含 22.3.3 的全序、T10b length 5→6、T10c 保持、新增 T10d tier_order 含 skill_takeover 断言（断言只增不减）④ check-rescue-chain.sh:5 注释「五档兜底串行穷尽」→「五机械档+22.3.3 评估档兜底串行穷尽」（仅注释）
- 验收证据：`bash scripts/selftest-fallback.sh` → Total: 31 PASS=31 FAIL=0 EXIT=0；bash -n 三脚本语法过；grep -c skill_takeover = subagent-fallback.sh:2（:282/:286）+ selftest-fallback.sh:1（T10d）；git diff --numstat（scripts/ 范围）= subagent-fallback.sh +2/-2、selftest-fallback.sh +4/-3、check-rescue-chain.sh +1/-1，恰好 3 文件；hint「④主进程接管」「⑤AskUser」文本在 :286 仍存在（档位语义未删）
- 负结果报告：仅改 scope 内 3 文件；未改 critical-rules.md/SKILL.md/config.json/tests/；未 git commit；工作树既有 M/?? 状态（SKILL.md、critical-rules.md、subagent_dispatch.md M，skill-collaboration.md ??）为 S2/S3 既有产出非本步；selftest-rescue-chain.sh 注释性五档提及（:57,:72）不在 scope 且其断言不依赖 tier_order length，无交叉破坏
- checkpoint：`/mnt/data/dev/task-planner-skill/plans/task-v066-skill-collab-routing/subagent-state/05-executor-s4.md`（done）

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 22.3.3 定位 ④主进程接管 与 ⑤AskUser 之间（维持已 attest 的 VC-3） | 微恢复便宜先行（①②③④ 都是轻动作），工作流接管昂贵殿后——专业接管作为 AskUser 前最后一次自主挽救；主动协同职责交给计划期路由矩阵，避免卡壳路径被 comet 重流程绑架；Key Question 2 的「④之前」草稿措辞作废 |
| tier_order 机械层扩 6 项（纳入 skill_takeover） | fallback 时刻的 hint 是行为驱动源，不纳入则 22.3.3 只活在 reference 文本、卡壳时永不浮现；改动面 = subagent-fallback.sh `*` 与 `timeout` 两分支 + selftest-fallback.sh:123-127 断言同步 |
| skill_collab_enforce 三档语义本轮纯流程层执行（无 hook 机械校验） | 对齐 v063 fmea_enforce「先登记后校验」范式；enforce 档语义预留后续轮接 hook；YAGNI |
| 移交 vs 嵌入 双模式 | 移交=统筹权让渡（comet/openspec 整工作流）；嵌入=Phase 内调用单成员技能作方法论 SOP（superpowers 为主，主进程保持统筹）——嵌入是本任务「协同解决问题」的主形态，移交是重形态 |

## Phase 2 设计定稿（S1-S5 材料包源，2026-09-13 主进程裁定）

### D1. 协同路由触发矩阵（计划期，T0 计划确认前评估）
判定顺序敏感先命中先用（重→轻）：**comet → OpenSpec → superpowers**；多族命中=叠加协同（comet classic 本身即 OpenSpec+superpowers 双星）。

| 族 | 触发信号（命中任意） | 成本 | CLI 探针前置 |
|----|---------------------|------|-------------|
| comet | 现有任意 3 项（Phase≥5/跨模块/需架构选型/新功能 feature/需 proposal-design-tasks 三件套归档/期望跨会话断点续做） | 重（跨会话托管） | `command -v comet` + `.comet.yaml` 激活状态 |
| OpenSpec | 需求模糊需 spec 化（proposal/design/specs/tasks 产物有留存价值）/ 项目已有 `openspec/` 目录且变更触及 spec / 用户要求提案评审流 | 中（单会话多步 CLI） | `command -v openspec` + `openspec/` 目录 |
| superpowers（嵌入为主） | bug 排查→systematic-debugging；实现前需 TDD→test-driven-development；需求不清→brainstorming；按既有书面计划执行→executing-plans / subagent-driven-development；合并前→requesting-code-review + finishing-a-development-branch | 轻（单 Skill 调用） | 无（纯 .md 技能） |

- **移交（handoff）**：主进程让出统筹权，按「移交评估流程」（总结已有 plan 内容→提示用户→用户确认→引导启动目标技能→主进程簿记 handoff）；silent 模式按 Rule 28 推荐项自主处置并登记 `silent:` 决策行（推荐项=命中 comet 3 项即移交，否则留在 task-planner）
- **嵌入（embed）**：主进程保持统筹，Phase 内调用成员技能作为执行 SOP（计子代理路由表的 Skill() 列），无需用户确认
- **CLI 缺失降级**：探针失败 → 该族标记「不可接管」，继续评估下一族或留在 task-planner，禁止假设已装
- 两层正交：子代理选型走 SKILL.md §子代理路由表（skill-agent-router），技能族选型走本矩阵
- 成本护栏：移交/接管调用计入 Rule 17 opus 节流

### D2. Rule 22.3.3 条款全文（S3 落地原文）

> 22.3.3 **协同技能接管评估(task-v066)**：位于 ④主进程接管 与 ⑤AskUserQuestion 之间的兜底档——④ 接管不可行（任务超单文件 ≤300 行上限且 22.3.2 拆细后仍无法接管）或 ④ 接管后仍失败时，⑤ AskUser/STOP 之前，主进程必须先评估「是否存在更适配的专业技能族可接管」：① 任务整体超载/需跨会话托管 → `Skill("comet")`（先跑 CLI 探针，见 references/skill-collaboration.md D1）② 需求/规格层反复返工 → `Skill("openspec-propose")` 规格化 ③ 单点能力缺口（调试/TDD/审查）→ superpowers 对应成员技能。探针前置：`command -v comet` / `command -v openspec`，CLI 缺失或项目未激活 → 该族标记不可接管并评估下一族，禁止假设已装。接管语义：把剩余工作连同 task_plan 快照（Goal+VC+已完成 Phase 摘要，格式见 skill-collaboration.md §移交/回填合约）交目标技能，task_plan.md Handoff 表登记 `skill:<name>` 行；接管成功 → 剩余 Phase 由目标工作流推进；接管失败 → 才允许 ⑤ AskUser（silent 模式按 28.4.1 降级交付，禁空等）。约束：接管调用计入 Rule 17 opus 节流；接管后执行体仍受 Rule 13/14 约束；本评估为 22.7 穷尽集合的组成部分（①②③④+22.3.3）。

### D3. 机械层改动（S4 原文）
- subagent-fallback.sh `*` 分支(:286) hint：`①改派(换类型) → ②拆细 → ③降档 → ④主进程接管 → 22.3.3 技能族接管评估(见 references/skill-collaboration.md) → ⑤AskUser（消耗 retry_limit）`；tier_order → `["dispatch_swap","split","model_downgrade","main_takeover","skill_takeover","ask_user"]`
- subagent-fallback.sh `timeout` 分支(:282) tier_order 同步扩 6 项（hint 文本不动）
- selftest-fallback.sh:123-127 断言同步（T10a 全序字符串含 22.3.3 / T10b length 5→6 / T10c 不变）；执行前 Read :110-135 确认 T10 目标分支，两分支断言若分别存在则逐一同步
- check-rescue-chain.sh:5 注释「五档」→「六档（五机械档+22.3.3 评估档）」（可选，非断言）

### D4. 移交/回填合约（S1 落地原文，进 skill-collaboration.md）

**移交快照**（写入 `<plan-dir>/handoff-snapshot.md`，prompt 附路径）：
```
task_id / Goal 原文 / VC 表全文 / 已完成 Phase+证据路径 / 未完成 Phase 清单 /
Decisions Made 关键行 / 工作分支与 worktree 路径 / CLI 探针结果
```
**主进程簿记**：Handoff 登记表加一行（subagent_type=`skill:<name>`，状态=handoff/rolled_back）；隔离决策表注记接管方。
**回填**：目标技能完成 → 产物路径回填 findings.md `## Resources`，交付报告注明「由 <skill> 接管完成」。
**回退**：移交后发现不适配 → 用户否决权恒有效；task_plan.md 标 `handoff_rolled_back`，主进程恢复统筹。

### D5. config 键（S5）
`skill_collab_enforce`：enum `enforce|warn|off`，default `warn`。off=跳过移交评估与 22.3.3（旧行为）；warn=提醒性评估（命中矩阵提示移交、22.3.3 评估记录不强制）；enforce=计划期命中矩阵必须登记不移交理由方可继续、22.3.3 未评估禁止 ⑤ AskUser/STOP。本轮三档均流程层执行，无 hook 校验（description 注明 enforce 档语义预留）。

#### [sub:02-executor] S1 产出
- 文件：`/home/terry/task-planner-skill-worktrees/task-v066-skill-collab-routing/skills/task-planner/references/skill-collaboration.md`（新建，110 行 ≤300）
- 结构五节：§一 三族能力画像表（源自 01-explore 画像表，表格化+file:line 证据保留）/ §二 协同路由触发矩阵（D1 全文：触发表+判定顺序+移交 vs 嵌入双模式+CLI 探针前置+Rule 17 成本护栏+两层正交说明）/ §三 卡壳升级阶梯 22.3.3（D2 条款全文逐字收录，diff 验证 VERBATIM MATCH；补 22.3 兜底全序图+与 22.3.1/22.7/28.4.1 关系说明）/ §四 移交/回填合约（D4 全文）/ §五 反模式清单（6 条 ≥5）
- 头部：定位一句话 + 权威源声明 + skill_collab_enforce 三档语义（enforce/warn/off 默认 warn，三档流程层执行无 hook 校验，enforce 语义预留）
- 验收自检：① 文件存在 110 行 PASS ② grep 三族=3/触发矩阵=1/22.3.3=11/移交合约(移交/回填合约)=2/skill_collab_enforce=1/command -v comet=3 各≥1 PASS ③ D2 逐字 diff PASS ④ markdown 表格语法 PASS
- checkpoint：`/mnt/data/dev/task-planner-skill/plans/task-v066-skill-collab-routing/subagent-state/02-executor-s1.md`

#### [sub:03-executor] S2 产出
- 文件：`/home/terry/task-planner-skill-worktrees/task-v066-skill-collab-routing/skills/task-planner/SKILL.md`（+8/-6，净增 +2；508→510 行 ≤518 验收线）
- 改动1：L46-52「🚀 复杂功能开发 → 移交 /comet 工作流」段替换为「🤝 专业技能协同路由（comet/OpenSpec/superpowers — 权威源 references/skill-collaboration.md）」段：触发矩阵（comet→OpenSpec→superpowers 顺序敏感先命中先用，多族命中=叠加协同）+ CLI 探针前置 + skill_collab_enforce 开关键 + 段尾指针
- 语义保留：comet 行「任意 3 项」6 条件项（Phase≥5/跨模块/架构选型/新功能/三件套归档/跨会话续做）与移交流程链逐字未丢；「与 task-planner 区别」压缩为行尾一句
- 改动2：References 表 `references/todo-sync.md` 行前插入 `| references/skill-collaboration.md | 专业技能协同路由权威源（三族画像/触发矩阵/22.3.3 卡壳接管/移交合约） |`
- 验收 6/6 PASS：①510 行 ②:46/:314 协同路由命中 ③skill-collaboration.md 共 3 处(:46/:53/:314) ④:49 任意 3 项 6 条件齐全 ⑤旧标题 grep exit=1 无命中 ⑥:314 References 新行存在
- Scope：仅 SKILL.md 1 文件（git diff --stat 确认），未 commit，未触碰 critical-rules.md/config.json/templates/tests
- checkpoint：`/mnt/data/dev/task-planner-skill/plans/task-v066-skill-collab-routing/subagent-state/03-executor-s2.md`（done）

#### [sub:06-executor] S5 产出
- 文件：① `config.json`（fmea_enforce 块后插入 `skill_collab_enforce` 键，schema 完全镜像：type=string / enum=[enforce,warn,off] / default=warn，description 载三档语义+「三档均流程层执行无 hook 校验，enforce 档语义预留」+权威源指针 references/skill-collaboration.md）② `scripts/selftest-skill-collab.sh`（新建，99 行，10 用例 19 断言：T1 协作文件存在≤300 行+四关键词 / T2 SKILL 指针+引用≥2 / T3 任意 3 项保留 / T4 22.3.1<22.3.3<22.4 行号序 / T5 22.7 穷尽集合含 22.3.3 / T6 tier_order 全串 2 处+skill_takeover / T7 config 键 python3 校验 / T8 command -v comet 双文件 / T9 键名跨文件一致无连字符变体 / T10 SKILL≤518 行；路径全走 SCRIPT_DIR 相对推导无硬编码绝对路径，风格镜像 selftest-fallback.sh 的 [PASS]/[FAIL]+Total 行+FAIL>0 exit 1）
- 验收 5/5 PASS：① python3 json.load 无异常且 default=warn+enum 三值 ② `bash scripts/selftest-skill-collab.sh` → Total: 19 PASS=19 FAIL=0 exit 0（10 用例全 PASS）③ `bash scripts/selftest-fallback.sh` → Total: 31 PASS=31 FAIL=0 exit 0 无回归 ④ git status：本步新增恰 2 文件（config.json M + ?? scripts/selftest-skill-collab.sh），其余 M/?? 为 S1-S4 既有产出 ⑤ 聚合 runner 勘验：无 run-selftests/selftest-all 聚合器（scripts/ 37 脚本逐一核实，selftest-* 均为独立 bash 直跑），无需登记
- Scope：仅 config.json + 新 selftest 1 文件；未 commit；bash -n 语法过
- checkpoint：`/mnt/data/dev/task-planner-skill/plans/task-v066-skill-collab-routing/subagent-state/06-executor-s5.md`（done）

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->

#### [sub:07-executor] 微修产出
- 微修 1 (P3): selftest-skill-collab.sh:5 头部注释 "10 用例(T1-T10)" → "10 组用例 T1-T10，共 19 断言"（口径对齐实际 19 个 t() 断言）
- 微修 2 (P2): selftest-skill-collab.sh:53-70 T7 config.json 断言增加 `command -v python3` 探测双路径——有 python3 走原 JSON 断言，无 python3 降级 grep 断言（sed 键块提取 + test 式 `[ $(grep -c ...) -ge 1 ]` 三值各 ≥1 命中），T7 输出行注明所用路径 `(python3)` / `(grep-fallback)`，t() 计数器与 PASS/FAIL 风格不变
- 验收 ① 本机 19/19 PASS exit 0；② `bash -n` SYNTAX-OK；③ no-python3 模拟 (PATH=/tmp/nopy3bin2) 19/19 PASS exit 0，T7 走 grep-fallback；④ `git diff --numstat` = 14/2 仅 1 文件
- 踩坑: 键块文本跨 shell 边界 + 嵌套 bash -c 双引号导致 grep pattern 引号剥离 → 改为 $CONFIG 脚本层展开 + 内层单引号 + test 式断言（详见 checkpoint 07-executor-fix.md "踩坑记录" 节）
