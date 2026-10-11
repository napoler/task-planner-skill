# Task Plan: task-v066 — task-planner 专业技能协同路由增强（comet/OpenSpec/superpowers 三族）
<!--
  WHAT: This is your roadmap for the entire task. Think of it as your "working memory on disk."
  WHY: After 50+ tool calls, your original goals can get forgotten. This file keeps them fresh.
  WHEN: Created by plan-writer (seq 00), 2026-09-13; owner 主进程. Update after each phase completes.
-->
<!-- template_type: skill-fix -->
<!--
  计划依据（背景事实，勿凭记忆改写）:
  - 技能源码仓(canonical): /mnt/data/dev/task-planner-skill/skills/task-planner/** (实现目标)
  - 部署位 9 处 (zcode×3/claude×4/agents×1/opencode×1, 含 ~/.zcode/skills/task-planner 等), 合并后
    用 scripts/smart-merge-back.sh <worktree> --deploy 部署对账 + diff -r 复验
  - 基线(task-v065 后): selftest 共 159 用例 (skills/task-planner/tests/smoke.sh + scripts/selftest-*.sh 体系);
    config.json 26 键; SKILL.md 508 行(500 行边界遗留, 本次净增须控, 细节进 reference, SKILL.md 只留触发条件+指针)
  - SKILL.md L46-52 现有「🚀 复杂功能开发 → 移交 /comet 工作流」段(任意 3 项命中→移交 comet)
  - critical-rules.md: Rule 22.3 五档兜底全序(①改派②拆细③降档④主进程接管⑤AskUserQuestion/STOP),
    22.7 连续失败换档语义(≥2 次失败禁直接 STOP), 28.4.1 D6 silent 降级交付
  - 本任务 session sid = 133bb46c648345a49d99665093e36080
-->

## Goal
让 task-planner 具备"专业技能协同路由"能力：复杂任务能按信号移交 comet/OpenSpec/superpowers 技能族协同解决，卡壳时按 22.3.3 协同技能接管评估自动寻找更适配技能接手，task-planner 专注统筹编排。

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | `133bb46c648345a49d99665093e36080` |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v066-skill-collab-routing`（§十一 隔离决策已有字段；基于 master 创建，执行 Phase 1 前确认 worktree 已建） |
| `scope_files` | `[skills/task-planner/SKILL.md, skills/task-planner/references/skill-collaboration.md(新增), skills/task-planner/references/critical-rules.md, skills/task-planner/config.json, skills/task-planner/tests/*(新增协同用例)]` |
| `interaction_mode` | `silent`（缺省回落 config.json#interaction_mode；silent 模式静默决策入下方「静默决策清单」） |

**静默决策清单**（silent 模式登记，交付报告置顶）:

| 时间 | 决策 | 依据 | 影响 |
|------|------|------|------|
| 2026-09-13 | interaction_mode=silent | v065 先例 + 自主会话无实时用户 | 全程静默决策,本清单供复核 |
| 2026-09-13 | 22.3.3 定位 ④与⑤之间（KQ2 草稿「④之前」作废） | 微恢复便宜先行/重流程殿后; 维持已 attest VC-3 | critical-rules L126 |
| 2026-09-13 | tier_order 机械层扩 6 项纳入 skill_takeover | fallback hint 是行为驱动源 | subagent-fallback.sh+selftest 同步 |
| 2026-09-13 | S-unit 表 S1-S4→S1-S5 重构 + scope 表修订机械层文件 | Phase 2 设计定稿 D3 | 计划重 attest acf50acd |
| 2026-09-13 | selftest 落位 scripts/ 而非计划原文 tests/ | 仓内 selftest-*.sh 惯例目录 | selftest-skill-collab.sh 路径 |
| 2026-09-13 | Code Review P2/P3 微修收口为 Handoff 07（f0fcdc8）; P3 既有噪音登记遗留 D-3 | 质量优先 + 范围纪律 | selftest-skill-collab.sh T7 双路径 |
| 2026-09-13 | verify.sh 不存在 → smoke#verify_installation 替代 | 仓内实际脚本勘验 | VC-4/Phase 4 证据口径（D-4） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

<!--
  WHAT: 任务执行完毕 ≠ 目标完成。此表确保每一步有可验证证据。
  RULE: 每个 phase 完成后对照 VC 编号复验；phase 全部 complete ≠ 通过终验。
  V-N: goal-gate 规定「每 phase ≥2 条 V-N（映射到 VC 编号）」；逐条验收记录在 verification.md 的 V-N.N 项。
-->

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | references/skill-collaboration.md 存在且覆盖四要素：三族能力画像（comet 族/OpenSpec 族/superpowers 族）+ 触发矩阵（任务信号→移交目标族）+ 卡壳升级阶梯（22.3.3 条款全文）+ 移交/回填合约 | `ls <worktree>/skills/task-planner/references/skill-collaboration.md` + `grep -c "画像\|触发矩阵\|22.3.3\|移交合约" <file>` ≥4 | worktree 内该文件 |
| VC-2 | SKILL.md 协同路由段落地：现有「🚀 移交 /comet」段（L46-52）被泛化为「🤝 专业技能协同路由」段（保留 comet 命中 3 项规则 + 新增 OpenSpec/superpowers 触发条件 + 指针行指向 references/skill-collaboration.md） | `grep -n "专业技能协同路由\|skill-collaboration.md" <worktree>/skills/task-planner/SKILL.md` 非空 且 旧段「复杂功能开发 → 移交」被替换；`wc -l` SKILL.md 较基线 508 行净增 ≤10 行 | worktree 内 SKILL.md |
| VC-3 | critical-rules.md 新增 Rule 22.3.3「协同技能接管评估」插入 22.3 ④主进程接管与 ⑤AskUserQuestion 之间，且与 22.7（≥2 次失败禁直接 STOP）/28.4.1（D6 silent 降级）/五档全序无语义冲突（不改动 ①②③④⑤ 既有档位语义） | `grep -n "22.3.3" <worktree>/skills/task-planner/references/critical-rules.md` 存在 且 `grep -n "22.3\|22.7\|28.4.1"` 相邻行档位顺序仍为 ①改派→②拆细→③降档→22.3.3→④接管→⑤Ask | worktree 内 critical-rules.md |
| VC-4 | config.json 新增键 `skill_collab_enforce`（默认 warn，对齐 v063 fmea_enforce 范式：enum enforce/warn/off）+ tests/ 新增 selftest 协同用例全绿 + 全量 selftest 0 fail（基线 159 用例不回归） | `python3 -c "import json;json.load(open('<worktree>/skills/task-planner/config.json'))['skill_collab_enforce']"` 输出 warn；`bash <worktree>/skills/task-planner/tests/smoke.sh` 与 `bash <worktree>/skills/task-planner/scripts/selftest-*.sh` 全 0 fail | worktree 内 config.json + 测试输出 |
| VC-5 | 跨文件一致性：skill-collaboration.md ↔ SKILL.md ↔ critical-rules.md ↔ config.json 四处键名/条款编号/指针路径 grep 一致（skill_collab_enforce 在 config+reference 同拼写；22.3.3 在 SKILL 指针+reference 同编号；路径引用真实存在） | `grep -rn "skill_collab_enforce" <worktree>/skills/task-planner/` 与 `grep -rn "22.3.3" <worktree>/skills/task-planner/` 各处拼写一致；`grep -n "skill-collaboration.md" SKILL.md critical-rules.md` 指向的 reference 文件存在 | worktree 内 grep 输出 |
| VC-6 | 合并回主仓（merge_back=merged(<commit>)）+ 9 位部署 diff -r = 0 对账通过（smart-merge-back.sh --deploy） | `git -C /mnt/data/dev/task-planner-skill log --oneline -1` 见 merge commit；`diff -r <canonical> <deploy-site>` 各部署位无差异；worktree 已清理（`git worktree list` 无本任务条目） | 主仓 git log + diff -r 输出 |
| VC-7 | Code Review Gate = APPROVED（code_review: required，scope_files 全量审） | Code Reviewer 子代理产出审查结论落 verification.md 并回填 VC-7 证据 | verification.md |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：`code_review: required`，终验前必须先通过 Code Review Gate，否则不得标记 COMPLETE。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!--
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码 | skills/task-planner/SKILL.md（仅协同路由段替换 + References 指针行）; scripts/subagent-fallback.sh（仅 hint/tier_order, Phase 2 修订 S4）; scripts/check-rescue-chain.sh（仅注释, Phase 2 修订 S4）; templates/subagent_dispatch.md（仅档位清单行, Phase 2 修订 S3） | 其他 .sh 业务逻辑 |
| 测试 | scripts/selftest-fallback.sh（断言同步, Phase 2 修订 S4）, scripts/selftest-skill-collab.sh（新建, 实际落位 scripts/ 为仓内 selftest 惯例目录） | 其他测试文件 |
| 配置 | skills/task-planner/config.json（仅新增 skill_collab_enforce 键） | 其他配置键改动 |
| 文档 | skills/task-planner/references/skill-collaboration.md（新增）, skills/task-planner/references/critical-rules.md（仅 22.3.3 插入 + 22.7/22.7.1 对齐） | 其他 references |

> 注：后三行修订于 Phase 2 设计定稿（D3 机械层改动面，S-unit 表同步重 attest，SHA acf50acd）；原 stub 行仅列 SKILL.md/tests/config，S3/S4 的机械层文件以本表为准。

**执行前自我检查:**
- [ ] 这个文件在上面的列表中吗？
- [ ] 这个修改对完成任务有必要吗？
- [ ] 用户明确要求我做这个修改吗？
- 全部 Yes → 可以执行 | 任一 No → 先问用户（silent 模式登记静默决策清单）

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | 本仓 SKILL.md（comet 移交段 L46-52 + References 段结构） | `/mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md` | 必读 | ☑ |
| 项目内部文档/知识库 | 本仓 critical-rules.md（22.3/22.7/28.4.1 现有语义） | `/mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md` | 必读 | ☑ |
| 项目内部文档/知识库 | 本仓 config.json（fmea_enforce 范式 L81-89） | `/mnt/data/dev/task-planner-skill/skills/task-planner/config.json` | 必读 | ☑ |
| 项目内部文档/知识库 | comet 族 SKILL.md（comet/comet-classic/comet-native/comet-open/comet-build/comet-verify/comet-hotfix 等） | `/home/terry/.zcode/skills/comet*/SKILL.md`（路径模式，Phase 1 确认可获取） | 必读 | ☑ |
| 项目内部文档/知识库 | OpenSpec 族 SKILL.md | `/home/terry/.zcode/skills/openspec-*/SKILL.md`（路径模式） | 必读 | ☑ |
| 项目内部文档/知识库 | superpowers 族 SKILL.md（using-superpowers/brainstorming/writing-plans/executing-plans/systematic-debugging 等） | `/home/terry/.agents/skills/*/SKILL.md`（路径模式） | 必读 | ☑ |
| 项目内部文档/知识库 | memory 部署流程要点：9 位部署不自动生效，须显式 smart-merge-back.sh --deploy 部署对账 | `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/smart-merge-back.sh`（参考） | 参考 | ☐ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 复杂/卡壳任务中 task-planner 无法把执行权路由给更专业的技能族（comet/OpenSpec/superpowers），导致编排者亲自硬扛 → 解决后 skill-collaboration 路由机制交付，结果可交付。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？
- [x] 核心问题不解决，其他工作都白费吗？
- [x] 核心问题的解决方法是清晰的、可执行的？

## Current Phase
已交付（COMPLETE, merge 9b3619d, 2026-09-13）

## Next Step
主仓执行 smart-merge-back.sh /home/terry/task-planner-skill-worktrees/task-v066-skill-collab-routing --deploy → worktree 清理 → 主仓 Read 复验 + 9 位 diff=0 对账 → 簿记（隔离决策 merge_back/委派统计/静默决策清单）→ 交付报告

## Phases
<!--
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6)。
-->

### Phase 1: 调研 — 三族技能能力画像 + 现有协同条款盘点
- [x] 盘点 comet 族 / OpenSpec 族 / superpowers 族 SKILL.md 能力画像（输入清单/输出契约/适用信号）
- [x] 盘点 task-planner 现有协同条款（SKILL.md L46-52 /comet 移交段、critical-rules Rule 22.3 五档、skill-agent-router）
- [x] 结论落盘 checkpoint：`plans/task-v066-skill-collab-routing/subagent-state/01-explore-skill-families.md`（主进程返回后 30s 内 Read + 回填 findings.md）
- [x] 知识储备必读项（三族 SKILL.md 路径模式）已确认可获取
- **V-N:** VC-1, VC-5
- **Status:** complete（证据: subagent-state/01-explore-skill-families.md + findings.md Research Findings 段; check-3file-gate PASS）
- **Executor:** explore（mini）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | 产出三族技能画像表 + 现有协同条款盘点 | 继承 | `/home/terry/.zcode/skills/comet*/SKILL.md` + `/home/terry/.zcode/skills/openspec-*/SKILL.md` + `/home/terry/.agents/skills/*/SKILL.md`（comet 族: 跨会话 5 阶段托管 proposal→design→build→verify→archive; OpenSpec 族: spec 驱动 change 提案/归档; superpowers 族: 头脑风暴/写计划/执行计划/系统化调试 SOP; 对照阅读 `/mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md` L46-52 与 `references/critical-rules.md` L117-133 现有协同条款） | checkpoint 文件含三族画像表（族/输入信号/输出物/典型任务）+ 现有条款清单（条款号/位置/语义），Read 可复核 | ≤15min | pending |

### Phase 2: 机制设计 — 协同路由矩阵 + 22.3.3 升级阶梯接入点 + 移交/回填合约
- [x] 产出协同路由矩阵（任务信号 → 移交哪个技能族；判定顺序敏感，先命中先用）
- [x] 设计 22.3.3「协同技能接管评估」接入点：插入 22.3 ④主进程接管与 ⑤AskUserQuestion 之间（①改派②拆细③降档失败后、主进程接管前评估是否有更适配技能族接管），与 22.7/28.4.1 语义对齐（不破坏「≥2 次失败禁直接 STOP」「silent 降级交付」）
- [x] 定义移交/回填合约：task_plan 快照（Goal + VC + Phase 摘要）传目标技能 + 结果回填 findings；结论写 `plans/task-v066-skill-collab-routing/findings.md`
- [x] 控行预算确认：SKILL.md 只留触发条件 + 指针行，细节全部进 references/skill-collaboration.md（净增 ≤10 行预算）
- **V-N:** VC-1, VC-3
- **Status:** complete（证据: findings.md「Phase 2 设计定稿 D1-D5」+ Decisions Made 4 行; KQ1-4 全部裁定; 计划修订 S1-S5 并重锁定 SHA acf50acd）
- **Executor:** 主进程（例外理由：② 计划系统文件维护 + 调度管理器规划设计本职——Rule 25.3 白名单；设计方案只写 findings.md 计划系统文件，不写业务代码）

### Phase 3: 实现 — worktree 内串行派发 S1-S5（Rule 21.4，完成一个验收一个）
- [x] S1 新增 references/skill-collaboration.md（权威源）
- [x] S2 SKILL.md 接入（L46-52 段泛化 + References 指针行）
- [x] S3 critical-rules.md 接入（22.3.3 条款 + 22.7/22.7.1 对齐 + 模板档位清单同步）
- [x] S4 subagent-fallback.sh hint/tier_order 扩 6 项 + selftest-fallback.sh 断言同步
- [x] S5 config.json 新键 + tests/ 新增 selftest-skill-collab.sh 用例
- **V-N:** VC-1, VC-2, VC-3, VC-4
- **Status:** complete（证据: 5 个 S-unit 全 done 且各自主进程 Read/复跑验收 PASS; Handoff 02-06 全 ☑; 涉及 7 改 2 新 9 文件, 见 progress.md Phase 3 Files 清单; Rule 27 提交见 git log wt 分支）
- **Executor:** executor（sonnet-1，worktree 内，串行派发 Rule 21.4；上一 S-unit 三证据验收前禁派下一个）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | 新增 references/skill-collaboration.md 权威源 | 继承 | worktree `/home/terry/task-planner-skill-worktrees/task-v066-skill-collab-routing/skills/task-planner/references/`（材料包: findings.md「Phase 2 设计定稿」D1/D2/D4 全文 + checkpoint 01 三族画像表全文；写四要素: 三族画像表/触发矩阵/22.3.3 条款全文/移交合约快照格式） | 文件存在 且 grep 四要素关键字 ≥4 命中; 行数 ≤ 300（超限再拆） | ≤15min | done |
| S2 | SKILL.md L46-52「🚀 移交 /comet」段泛化为「🤝 专业技能协同路由」段 + References 指针行 | 继承 | worktree `skills/task-planner/SKILL.md`（材料包: findings D1 矩阵触发条件摘要 ≤10 行；约束: 保留 comet 命中 3 项规则原文语义, 新增 OpenSpec/superpowers 触发条件各 1 行 + 移交/嵌入区分 1 行, 末尾加指针行指向 references/skill-collaboration.md, 全仓净增 ≤10 行） | `wc -l` ≤ 基线+10; grep "专业技能协同路由" 与 "skill-collaboration.md" 均命中; 旧段标题被替换 | ≤15min | done |
| S3 | critical-rules.md 插入 22.3.3 条款（④与⑤之间,即 22.3.2 之后 22.4 之前）+ 22.7/22.7.1 穷尽集合措辞对齐 | 继承 | worktree `skills/task-planner/references/critical-rules.md` L124-133（材料包: findings D2 条款全文 + D3 对齐说明；约束: 禁改 ①②③④⑤ 既有档位语义原文, 22.7 的「①-④」扩为「①-④ 与 22.3.3 评估」, 22.7.1 ② 字段同步, 仅插入+交叉引用）; `templates/subagent_dispatch.md:109`「已尝试档位清单(22.3 ①-④ 逐档)」→「(22.3 ①-④ 与 22.3.3 逐档)」 | grep "22.3.3" 命中且位于 22.3 与 22.7 文本域; ①-⑤ 档位语义文本未变（diff 复核）; 模板档位清单已同步 | ≤15min | done |
| S4 | subagent-fallback.sh hint/tier_order 扩 6 项（`*` 与 `timeout` 两分支）+ selftest-fallback.sh:123-127 断言同步 | 继承 | worktree `scripts/subagent-fallback.sh` L270-290 + `scripts/selftest-fallback.sh` L110-135（材料包: findings D3 改动原文；先 Read selftest :110-135 确认 T10 目标分支, 两分支断言逐一同步） | `bash scripts/selftest-fallback.sh` 全绿; hint 含 "22.3.3 技能族接管评估" + tier_order 6 项含 skill_takeover | ≤15min | done |
| S5 | config.json 新增 skill_collab_enforce（默认 warn, fmea_enforce 范式）+ tests/ 新增 selftest-skill-collab 用例 | 继承 | worktree `skills/task-planner/config.json` L81-89 fmea_enforce 块（材料包: findings D5 键语义 enum enforce/warn/off + default warn + description 写明本轮流程层执行/enforce 预留）; `tests/` 新建 selftest-skill-collab.sh（用例清单见 checkpoint 01 §三 + VC-5 一致性 grep 三命令；风格对齐既有 selftest-*.sh） | `python3 -c json.load` 读到 skill_collab_enforce=warn; 新用例 + 全量 selftest 0 fail | ≤15min | done（实际落位 scripts/selftest-skill-collab.sh=仓内 selftest 惯例目录） |

### Phase 4: 验证 — 全量 selftest + verify + 跨文件一致性
- [x] worktree 内 selftest 全量 0 fail（基线 159 用例 + 新增用例）
- [x] `bash <worktree>/skills/task-planner/tests/smoke.sh` + verify.sh 报 canonical health 通过
- [x] 跨文件一致性 grep：skill_collab_enforce 键名 / 22.3.3 条款编号 / skill-collaboration.md 指针路径三处一致
- [x] Code Review Gate 派发 Code Reviewer（scope_files 全量）→ 结论回填 verification.md（VC-7）
- [x] 结果记录 progress.md
- **V-N:** VC-4, VC-5, VC-7
- **Status:** complete（证据: 全量 11 套件 180 例 0 fail + smoke 17/0; VC-5 grep 三处一致; Code Review APPROVED + 微修 f0fcdc8 收口; 偏差注记: verify.sh 仓内不存在,由 smoke#verify_installation 覆盖=D-4）
- **Executor:** code-runner-agent（mini + 主进程机械验证白名单③：只读 grep/diff/selftest 执行，输出可控）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | 全量 selftest + smoke + verify 0 fail | 继承 | worktree `skills/task-planner/tests/smoke.sh` + `skills/task-planner/scripts/selftest-*.sh`（材料包: 基线 159 用例, 关注既有断言是否覆盖五档全序/STOP 语义且与新 22.3.3 冲突） | 全部输出 0 fail, 退出码 0 | ≤15min | pending |
| S2 | 跨文件一致性 grep + Code Review Gate | 继承 | worktree `skills/task-planner/` 全 scope_files（材料包: VC-5 grep 三命令清单） | grep 三处拼写一致; Code Reviewer 产出 APPROVED 落 verification.md | ≤15min | pending |

### Phase 5: 合并部署交付 — smart-merge-back --deploy + 清理 + 交付报告
- [x] `bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/smart-merge-back.sh /home/terry/task-planner-skill-worktrees/task-v066-skill-collab-routing --deploy`（V1-V6 预检全 OK → merge 9b3619d → 部署位对账 IDENTICAL; 未跑 sync-companion）
- [x] worktree 清理：`git worktree remove` + `git branch -d` 完成（worktree list 无本任务条目）
- [x] 主仓 Read 复验：SKILL.md 510 行/协同段 3 处命中、critical-rules 22.3.3=3、config default=warn（properties 路径）、skill-collaboration.md 110 行、selftest-skill-collab 主仓复跑 19/19; `git status -- skills/` = 0
- [x] 部署位 diff=0 对账记录：smart-merge-back 报 3 位 IDENTICAL + 主进程独立 diff -rq 复验 3 实体位全 0 + 软链位扫描 0（历史「9 位」中部分已收编/不存在,现存实体位 3 处全覆盖,verification.md D 注记）
- [x] 交付报告（含静默决策清单 + VC 逐条复验 + FMEA 兑现检查）
- **V-N:** VC-6, VC-4
- **Status:** complete（证据: merge 9b3619d + worktree list 干净 + 主仓复验全 PASS; verification.md Goal Gate outcome=COMPLETE）
- **Executor:** 主进程（例外理由：① git/worktree 编排 + ② 计划系统簿记——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（仅会话私有状态文件：plans/task-v066-skill-collab-routing/*；canonical 源无其他会话未提交变更） |
| `isolation` | `worktree` |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v066-skill-collab-routing` |
| `branch` | `wt/task-v066-skill-collab-routing`（基于 master，HEAD 6201065） |
| `merge_back` | `merged(9b3619d)`（smart-merge-back V1-V6 全 OK + --deploy 对账 IDENTICAL + worktree/分支已清理） |

> 契约详见 `~/.zcode/skills/task-planner/references/worktree-isolation.md`（决策矩阵/生命周期/合并回合约/反模式）。

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 references/methodology.md §R2）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 3 | SKILL.md 508 行已超 500 边界, S2 改动再推高行数失控 | 6 | 5 | 5 | 150 | 拆细：S2 独立 S-unit, 净增 >10 行 → 触发 22.3 ② 回计划层把细节全部下移 skill-collaboration.md 指针制（不塞 SKILL.md）; 仍超 → ③ 降档 executor 模型重做该 S-unit |
| Phase 3 | S4 新增 selftest 与既有断言冲突（既有用例断言五档全序/STOP 前穷尽, 插入 22.3.3 后语义漂移） | 6 | 4 | 6 | 144 | 先 grep 全序断言（`grep -rn "①改派\|五档\|STOP" skills/task-planner/tests/ scripts/selftest-*.sh`）再改; 冲突用例同步更新 + 记 findings; 冲突面 >3 用例 → 22.3 ② 拆细为独立 S5 |
| Phase 5 | smart-merge-back --deploy 后部署位 diff -r ≠ 0 | 7 | 3 | 5 | 105 | 重跑 cp -rL 定向部署（逐位 diff 定位首个非零位, 只重拷该位）; 警惕 sync-companion 反向陷阱——部署一律定向 cp, 禁跑 sync-companion 把旧位内容拉回; 两次仍 ≠0 → 22.3 ④ 主进程接管逐位修 |
| Phase 1 | 三族 SKILL.md 路径模式在某部署位缺失（如 openspec 未装到 ~/.zcode/skills） | 4 | 3 | 3 | 36 | （RPN≤100 可留空; 实际缺失该族 → findings 登记 n/a + 画像降级为「未知, 触发矩阵仅收其余两族」, 不阻塞 Phase 2） |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链，两者不互相替代。

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-09-13 | S1 建映射 + S2/S4 全程同步 |
| Phase 2 | ☑ | 2026-09-13 | |
| Phase 3 | ☑ | 2026-09-13 | S-unit 串行, 每完成一个 S 同步一次 |
| Phase 4 | ☑ | 2026-09-13 | |
| Phase 5 | ☑ | 2026-09-13 | 终态同步 complete |

> 契约详见 `~/.zcode/skills/task-planner/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions（Phase 2 已全部裁定）
1. 三族触发信号互斥还是叠加？→ **叠加非互斥，顺序敏感先命中先用（comet 重→OpenSpec 中→superpowers 轻）**；子代理路由表与技能族矩阵两层正交
2. 22.3.3 插入点？→ **④主进程接管 与 ⑤AskUserQuestion 之间**（微恢复便宜先行、工作流接管殿后=AskUser 前最后一次自主挽救；与 22.7 穷尽语义兼容；KQ 原草稿「④之前」作废，维持已 attest 的 VC-3）
3. 既有 selftest 是否断言五档全序？→ **是，唯一硬断言 selftest-fallback.sh:125**（精确字符串）+ :126 tier_order length==5；S4 同步处理（D3）
4. skill_collab_enforce 告警注入点？→ **本轮纯流程层执行无 hook 校验**（对齐 v063 fmea_enforce 先登记后校验范式；enforce 档语义预留）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 22.3.3 插在 ④主进程接管与 ⑤AskUserQuestion 之间 | 用户诉求「解决不了时自动寻找更适配技能接手」= 在硬扛（④）与甩锅（⑤）之间加一档专业接手；微恢复便宜先行，重流程殿后 |
| tier_order 机械层扩 6 项纳入 skill_takeover | fallback 时刻 hint 是行为驱动源，不纳入则 22.3.3 卡壳时永不浮现；改动面=两分支+3 断言行 |
| skill_collab_enforce 三档本轮纯流程层（无 hook） | 对齐 v063 fmea_enforce「先登记后校验」范式；enforce 语义预留后续轮接 hook；YAGNI |
| 移交 vs 嵌入 双模式 | 移交=统筹权让渡（comet/openspec 整工作流）；嵌入=Phase 内调用成员技能作 SOP（superpowers 为主）——「协同解决问题」主形态是嵌入 |
| SKILL.md 只留触发条件+指针行, 细节进 skill-collaboration.md | SKILL.md 508 行已有 500 边界遗留, 净增 ≤10 行硬约束（FMEA #1 兜底同源） |
| 新键名 skill_collab_enforce 默认 warn | 对齐 v063 fmea_enforce 范式（config.json L81-89）, 观察期默认 warn 不阻断 |
| 部署一律定向 cp -rL + diff -r 对账, 禁 sync-companion 拉回 | sync-companion 反向陷阱：可能把旧位内容同步回 canonical（FMEA #3 兜底同源） |

## Errors Encountered
| Error | Attempt | Resolution |
|-------|---------|------------|
|       | 1       |            |

## Notes
<!-- 
  REMINDERS:
  - Update phase status as you progress: pending → in_progress → complete
  - Re-read this plan before major decisions (attention manipulation)
  - Log ALL errors - they help avoid repetition
-->
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition
- 本任务非批量 / 单 skill 链（chain_mode: single，两区块已删）

## 🚨 Drift Log（漂移检测记录）
<!-- 
  WHEN: 每次调用 Skill("task-drift-guard") 后追加一行记录
  FORMAT: | timestamp | 结果 | VC条目 | 结论 |
-->
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-09-13 | ✅ ALIGNED | VC-1..7 | Phase 1 全程在 scope 内（仅 plans/ 簿记+只读调研），进入 Phase 2 |

## 📊 委派统计（Rule 25.4 — 终验前必填）
<!-- 
  WHAT: 本计划子代理 vs 主进程的执行分布统计。
  WHY: 委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由 → outcome 最高 PARTIAL(白名单见 critical-rules.md Rule 25.3)。
-->
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 5（Phase 1 explore; Phase 3 executor; Phase 4 code-runner-agent） |
| 主进程直做 Phase 清单 | Phase 2（② 计划系统文件维护 + 调度规划设计本职）; Phase 5（① git 编排 + ② 簿记） |
| 委派率 | 0.6 → 注：委派率口径为 Phase 数比 3/5=0.6 < floor 0.7, 但白名单内理由（①②）合法; 终验时按 25.4 如实登记, 如判 PARTIAL 则记 Decisions（用户裁决可豁免） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | rescue(档位/结果/时间) | retry_count | verify_done |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|-------------|-------------|
| 00 | 2026-09-13 | plan-writer | 撰写 task-v066 协同路由增强计划文档（覆盖本 stub） | done | 5 Phase/7 VC/FMEA 3 行 RPN>100 有兜底; findings+progress 已回填; 主进程 Read 复核通过 | plans/task-v066-skill-collab-routing/task_plan.md:1-280 | 基线勘察段 | plans/task-v066-skill-collab-routing/subagent-state/00-plan-writer.md | | 0 | ☑ |
| 01 | 2026-09-13 | explore | Phase 1 调研：三族技能画像 + 现有协同条款盘点 | done | 三族画像（comet 重/OpenSpec 中/superpowers 轻）+ 条款盘点 + 冲突面 1 硬断言（selftest-fallback.sh:125）；主进程 Read 复核+落盘 checkpoint+findings 回填 | subagent-state/01-explore-skill-families.md 证据索引节 | Research Findings 段 | plans/task-v066-skill-collab-routing/subagent-state/01-explore-skill-families.md | | 0 | ☑ |
| 02 | 2026-09-13 | executor | S1 新增 references/skill-collaboration.md 权威源 | done | 110 行五节齐(画像/矩阵/22.3.3 逐字/合约/反模式 6 条); 主进程 Read 复核 PASS; 遗留微瑕 §三全序图①标注并入 S3 修 | worktree skill-collaboration.md:1-110 | [sub:02-executor] S1 产出 | plans/task-v066-skill-collab-routing/subagent-state/02-executor-s1.md | | 0 | ☑ |
| 03 | 2026-09-13 | executor | S2 SKILL.md 移交段泛化 + References 指针行 | done | 508→510 行净+2; comet 3 项规则+移交流程逐字保留; References :314 指针行; 主进程 sed/grep 复核 PASS | SKILL.md:46-53,314 | [sub:03-executor] S2 产出 | plans/task-v066-skill-collab-routing/subagent-state/03-executor-s2.md | | 0 | ☑ |
| 04 | 2026-09-13 | executor | S3 critical-rules.md 22.3.3+22.7 对齐+模板行+S1 微瑕 | done | 22.3.3 落位 L126(22.3.2 后 22.4 前); 五档原文零改动; 22.7/22.7.1/模板 :109/全序图 :74 四处同步; 主进程 sed/grep 复核 PASS | critical-rules.md:126,133,134 | [sub:04-executor] S3 产出 | plans/task-v066-skill-collab-routing/subagent-state/04-executor-s3.md | | 0 | ☑ |
| 05 | 2026-09-13 | executor | S4 subagent-fallback.sh hint/tier_order 扩 6 项+selftest 断言同步 | done | selftest-fallback 31/31 exit0(新增 T10d skill_takeover 断言); timeout/* 两分支 tier_order 均扩 6; 主进程复跑+grep PASS | subagent-fallback.sh:282,286 | [sub:05-executor] S4 产出 | plans/task-v066-skill-collab-routing/subagent-state/05-executor-s4.md | | 0 | ☑ |
| 06 | 2026-09-13 | executor | S5 config.json 新键+selftest-skill-collab.sh 新建 | done | config :91-99 键块同构 default=warn; 新 selftest 19/19 exit0; fallback 31/31 无回归; 会话恢复后主进程一手复验 PASS | config.json:91-99 | [sub:06-executor] S5 产出 | plans/task-v066-skill-collab-routing/subagent-state/06-executor-s5.md | | 0 | ☑ |
| 07 | 2026-09-13 | executor | Code Review 微修：T7 python3 兜底降级 + 头部注释口径修正（Gate APPROVED 的 P2/P3 收口） | done | T7 双路径(python3/grep-fallback)模拟均 19/19; 注释「10 组用例/19 断言」; 主进程复验 python3 路径 PASS; commit f0fcdc8 | selftest-skill-collab.sh:5,53-70 | [sub:07-executor] 微修产出 | plans/task-v066-skill-collab-routing/subagent-state/07-executor-fix.md | | 0 | ☑ |
| 2 | | | | | | | | | | 0 | ☐ |
