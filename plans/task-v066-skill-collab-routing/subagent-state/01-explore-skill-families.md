# Checkpoint: 01-explore-skill-families (task-v066-skill-collab-routing)

- **time**: 2026-09-13
- **agent**: Explore（mini）, seq 01, Phase 1 S1
- **status**: done（子代理无 Write 工具，本文件由主进程按返回全文落盘，Rule 22.8）
- **消耗**: subagent_tokens≈4140k, tool_uses=57, 764s

## 一、三族画像表

### A. comet 族（13 成员，/home/terry/.zcode/skills/comet*）
- **定位**: 跨会话项目级变更工作流托管引擎，`.comet.yaml` 状态机 + Comet CLI，把「变更」当一等公民托管到归档；Classic（OpenSpec+Superpowers 双星）/ Native 两套独立工作流
- **工作流阶段**: open → design → build → verify → archive；预设短路径 hotfix（bug 单 change）/ tweak（轻中量改）
- **输入**: 用户原始请求 + `.comet.yaml` 状态 + `comet workflow resolve . --activate --json` 路由 + 仓库 dirty 状态
- **输出物**: proposal.md / design.md / tasks.md / delta spec / 验证报告 / 归档提交 + 状态推进；跨会话可断点恢复（resume-probe）
- **适用信号**: 用户显式 /comet*；新 capability/public API/schema 变更/跨模块协调→full；已有行为 bug→hotfix；轻中量改→tweak；项目已激活时改动类任务前先 resume-probe
- **成本量级**: **重**（跨会话托管 + CLI + 状态机 + 10 个用户决策点）
- **成员分工**: comet(入口 haiku, resolve 二选一) / comet-classic(主流程 opus) / comet-native(opus) / comet-open(sonnet) / comet-design(opus) / comet-build(sonnet) / comet-verify(haiku) / comet-archive(haiku) / comet-hotfix(sonnet) / comet-tweak(haiku) / comet-any(元技能) / comet-review(手动审查) / comet-memory(记忆判断)

### B. OpenSpec 族（11 成员，/home/terry/.zcode/skills/openspec-*）
- **定位**: spec 驱动的「提案→实现→归档」change 生命周期管理；核心 openspec-propose（一次生成全部 artifacts）+ openspec-onboard（教学演练）
- **工作流阶段**: explore → new/propose → specs → design → tasks → apply → verify → archive
- **输入**: change 描述 + openspec CLI + 已有 openspec/ 根
- **输出物**: change 目录（proposal/design/specs/tasks）+ 实现代码 + 归档 changesDir/archive/YYYY-MM-DD-<name>/
- **适用信号**: 有明确「change 容器」的 spec 驱动任务；快速提案→propose；渐进→new-change；快进→ff-change；继续→continue；验证→verify；归档→archive（批量 bulk）；探索→explore
- **成本量级**: **中**（单会话多步 CLI 往返，无跨会话托管）
- **成员分工**: propose(全量生成) / new-change(单步) / ff-change(快进) / continue-change(续建) / explore(思考伙伴) / apply-change(实现) / verify-change(一致性验证) / archive-change(归档) / bulk-archive(批量) / sync-specs(delta→main 同步) / onboard(教学)

### C. superpowers 族（10 成员，/home/terry/.agents/skills/）
- **定位**: 单会话内「过程纪律 + 执行手法」技能集——先查技能再动手 / 根因优先 / 先测后码 / 审查纪律
- **工作流阶段**: 无跨会话固定阶段；brainstorming→writing-plans→executing-plans/subagent-driven-development→test-driven-development→requesting/receiving-code-review→finishing-a-development-branch 灵活组合
- **输入**: 任务描述 + spec/需求 + 代码库；using-superpowers 为前置铁律
- **输出物**: 无跨会话文件；设计共识 / 实施计划 / 通过的测试 / 审查反馈 / 合并收尾
- **适用信号**: 单会话强过程纪律：bug/调试→systematic-debugging；多步实现→writing-plans+executing-plans；实现前→TDD；合并前→requesting-code-review；收尾→finishing-a-development-branch
- **成本量级**: **轻**（单 Skill 调用，无托管无状态机）
- **成员分工**: using-superpowers(前置铁律) / brainstorming(创意前置) / writing-plans(计划) / executing-plans(按计划执行) / subagent-driven-development(子代理驱动) / systematic-debugging(根因 4 阶段,3 次失败质疑架构) / test-driven-development(先测后码) / requesting-code-review / receiving-code-review / finishing-a-development-branch

## 二、task-planner 现有协同条款清单

| 条款位置 | 语义摘要 | 接缝点 |
|---|---|---|
| SKILL.md:46-52（🚀 移交 /comet 段）| 任意 3 项命中→移交 comet；task-planner=单会话轻量，comet=跨会话 5 阶段重量 | 泛化为「🤝 专业技能协同路由」，保留 comet 规则语义 + 新增两族触发行 + 指针行 |
| SKILL.md:301-315（References 表）| 13 项参考 | 新增 skill-collaboration.md 一行 |
| critical-rules.md:124（Rule 22.3 五档）| ①改派→②拆细→③降档→④主进程接管(≤300行)→⑤AskUser | 22.3.3 插 ③ 与 ④ 之间（调研裁定 ④之前：专业接管优先于主进程硬扛） |
| critical-rules.md:132（Rule 22.7）| ≥2 次失败禁直接 STOP，须穷尽 ①-④ | 穷尽集合补 22.3.3 一档，「禁直接 STOP」语义不变 |
| critical-rules.md:223（Rule 28.4.1）| D6 silent 降级交付，禁空等 | 22.3.3 接管评估在 silent 下登记静默决策行；接管失败走⑤按 28.4.1 降级 |
| critical-rules.md:124-125（22.3.1 provider Scaling）| provider 失败→①-fb 零消耗改派 | 22.3.1=通道改派，22.3.3=换技能族接管，两者不重叠须注明 |
| critical-rules.md:49-53（Rule 13/14）| 调研必派子代理/主进程禁改业务代码 | 22.3.3 注明「移交后执行体仍受 13/14 约束」 |
| cost-control.md:14-17（Rule 17 opus 节流）| opus 档 Skill 同 phase ≤1 次 | 22.3.3 接管调用计入 Rule 17 节流 |
| task_plan.md:223-225（Key Questions）| Q1 互斥? Q2 插入点? Q3 selftest 冲突? | Q1=叠加顺序敏感 comet最重优先；Q2=④之前；Q3=见下节 |

## 三、selftest 冲突面清单（Key Question 3 答案）

| 文件:行 | 内容 | 影响裁定 |
|---|---|---|
| scripts/selftest-fallback.sh:125 | **硬断言**精确字符串 `①改派(换类型) → ②拆细 → ③降档 → ④主进程接管 → ⑤AskUser` | 若改 hint 文本则必 FAIL，须同步更新断言 |
| scripts/selftest-fallback.sh:123,126,127 | 注释「五档」+ tier_order length==5 断言 + 含 split 断言 | tier_order 若加 skill_takeover → length 改 6 |
| scripts/subagent-fallback.sh:286 | 非 provider 失败 hint 输出五档全序文本 + tier_order 5 项数组 | 22.3.3 纳入则 hint 文本+数组各加一档 |
| scripts/check-rescue-chain.sh:5 | 仅注释提及「五档」，无机械断言 | 可选同步，非硬冲突 |
| scripts/selftest-rescue-chain.sh:57,72 | fixture 字符串 `①改派:done→②拆细:done`，不校验全序 | 非冲突 |
| templates/subagent_dispatch.md:109 | 「已尝试档位清单(22.3 ①-④ 逐档)」 | 文档性同步（→①-⑤ 含 22.3.3），易遗漏 |

**负结果**：grep 全量 tests/smoke.sh + scripts/selftest-*.sh，唯一精确五档全序断言 = selftest-fallback.sh:125；smoke.sh 只查结构完整性；其余 selftest 无 22.3 档位断言。

## 四、路由建议（调研层）
1. 三族叠加非互斥，顺序敏感先命中先用：comet（重）> OpenSpec（中）> superpowers（轻）
2. comet 最强信号：SKILL.md L48 任意 3 项（Phase≥5/跨模块/需架构/新功能/需归档/跨会话续做）
3. OpenSpec 最强信号：有明确 change 容器且 spec 驱动（需 proposal/design/tasks/delta spec 产物）
4. superpowers 最强信号：单会话 bug→systematic-debugging；多步实现→writing-plans+executing-plans；合并前→requesting-code-review
5. 22.3.3 插 ④主进程接管之前（③降档失败后先评估技能族接管）；接管调用计入 Rule 17 opus 节流；移交后执行体仍受 Rule 13/14 约束；silent 模式按 28.4.1 登记

## 五、风险与待设计裁定项（交 Phase 2）
- R1: selftest-fallback.sh:125 硬断言与 hint 文本联动——若纳入 tier_order 须同步改（subagent-fallback.sh:286 + selftest-fallback.sh:125-127）
- R2: tier_order 是否扩 6 项待设计裁定（调研倾向纳入：fallback 时刻 hint 是行为驱动源，不纳入则 22.3.3 只活在 reference 文本里）
- R3: templates/subagent_dispatch.md:109 文档性同步易遗漏
- R4: **CLI 可用性探针前置**——comet/openspec 强依赖各自 CLI 与项目激活状态；接管评估须先探测（CLI 未装则该族降级不可接管，不得假设已装）

## 证据索引
- /home/terry/.zcode/skills/comet/SKILL.md:16-25 / comet-classic/SKILL.md:111-116,194,202-211 / comet-hotfix/SKILL.md:13-18,180-192
- /home/terry/.zcode/skills/openspec-propose/SKILL.md:27-98 / openspec-onboard/SKILL.md:40-50
- /home/terry/.agents/skills/using-superpowers/SKILL.md:10-16 / systematic-debugging/SKILL.md:19-22,195-197
- /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md:46-52,301-315
- /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md:49-53,124-125,132,223
- /mnt/data/dev/task-planner-skill/skills/task-planner/references/cost-control.md:14-17
- /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-fallback.sh:123-127 / subagent-fallback.sh:286 / check-rescue-chain.sh:5 / selftest-rescue-chain.sh:57,72
- /mnt/data/dev/task-planner-skill/skills/task-planner/templates/subagent_dispatch.md:109
