# Task Plan: task-v085 任务类型机制画像 — task-planner 按 template_type 裁剪机制适用性

## Goal
为 task-planner 建立「机制画像（mechanism profile）」映射层：按 template_type 判定 Code Review Gate / code-assistant 路由 / 修改后验证等代码组机制的适用性，使非代码任务（writing/research/publish）不再被通用流程引向代码审查机制，而通用守卫全类型不变。

## 核心问题定义
- **问题**：task-planner 机制对全任务类型无差别套用——文章撰写任务也被引向 Code Review Gate 与 code-assistant/code-reviewer 路由（误路由 + 审查浪费）。
- **本质**：机制适用性与任务类型之间缺少映射层——机制没有「按类型分档」的权威判定源。
- **方案**：机制画像映射（**映射而非删除机制**）：critical-rules.md Rule 37 定判定规则与指针，template-mapping.md §九 放 14 行画像矩阵权威源，config 新键 `mechanism_profile_enforce` 控档，check-complete.sh 画像抽查 + 新 selftest 守护。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `template_type` | `rule-enhancement` |
| `code_review` | `required` |
| `session_id` | task-v085-task-type-mechanism-profile（注册表追踪） |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v085-task-type-mechanism-profile` |
| `scope_files` | 见「执行范围限制」表，11 个明确路径 |
| `interaction_mode` | `ask` |
| `reflect_verify` | `required` |
| `git_commit` | 逐 Phase 提交（每 Phase complete 即 commit） |
| `isolation` | `worktree`（§十一 P0：本任务改技能运行时文件，命中 11.1-1/3/4） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）
| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | critical-rules.md 末尾存在 Rule 37（任务类型机制画像，≤70 行纯追加，含 37.1-37.5），且 template-mapping.md 存在 §九 机制适用性矩阵（14 行，13 variant+general） | `grep -n "### 37 " .../critical-rules.md` 与 `grep -n "^## 九、" .../template-mapping.md` | skills/task-planner/references/critical-rules.md; skills/task-planner/references/template-mapping.md |
| VC-2 | template-mapping.md §九 矩阵中 writing/research/publish 行明确「不适用：Code Review Gate、code-assistant/debugger/code-reviewer 路由」，且 §一决策树尾部有指向 §九/Rule 37 的注记行 | Read §九 表逐行核对 + `grep -n "Rule 37" template-mapping.md` | skills/task-planner/references/template-mapping.md |
| VC-3 | SKILL.md 三处纯增量在位：路由表头部类型适配注记（L354 附近）、合规检查清单 C25 行、Critical Rules 列表 Rule 37 行；通用 templates/task_plan.md Code Review 节与 Executor 示例两处微调在位（共 ≤18 行增量） | `grep -n "C25" SKILL.md` + `grep -n "Rule 37" SKILL.md` + `grep -n "机制画像" templates/task_plan.md` | skills/task-planner/SKILL.md; skills/task-planner/templates/task_plan.md |
| VC-4 | 边界条件：新 selftest 行为级断言通过——fake plan（template_type=writing + code_review: required）在 warn 档 check-complete.sh 相关段不改变 exit（恒 exit 0），enforce 档 exit 1；同时 check-template-type.sh 动态白名单不被新增章节破坏（rule-enhancement 通过 gate） | 运行 `bash skills/task-planner/scripts/selftest-mechanism-profile.sh`，全断言 0 FAIL | plans/task-v085-task-type-mechanism-profile/verification.md（V 记录）+ 脚本输出 |
| VC-5 | 无回归：selftest-template-lifecycle.sh 全量 0 FAIL（TL-01..TL-17 存量断言 + 新增 TL-18 矩阵节断言）；config.json `mechanism_profile_enforce` 新键 json 合法（python json.load 通过）；全量 selftest 与改动前基线一致 | `bash skills/task-planner/scripts/selftest-template-lifecycle.sh` + `python3 -m json.tool skills/task-planner/config.json` | plans/task-v085-task-type-mechanism-profile/verification.md |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> `code_review: required`：终验前必须先通过 Code Review Gate；本计划即机制画像首个消费案例——rule-enhancement 属代码组，Code Review Gate 适用（Rule 37 判定示例）。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则 | skills/task-planner/references/critical-rules.md（仅末尾纯追加 Rule 37，≤70 行） | 其余 references/ 文件；既有条款任何改写 |
| 主文件 | skills/task-planner/SKILL.md（仅三处纯增量 ≤10 行） | SKILL.md 既有段落/锚点改写（TL-14/15 grep 锚须保留） |
| 映射/模板 | skills/task-planner/references/template-mapping.md（仅 §九 新增 ≤60 行 + §一尾注记 1 行）；skills/task-planner/templates/task_plan.md（仅两处微调 ≤8 行）；skills/task-planner/references/template-guide.md（仅计数/矩阵联动核对行） | 其余 templates/ 与 references/ 文件 |
| 脚本 | skills/task-planner/scripts/check-complete.sh（仅末段画像抽查 ≤15 行）；skills/task-planner/scripts/selftest-mechanism-profile.sh（新建）；skills/task-planner/scripts/selftest-template-lifecycle.sh（仅追加 TL-18） | 其他 .sh 文件 |
| 配置 | skills/task-planner/config.json（仅新增 `mechanism_profile_enforce` 键，位置邻近 template_gate_enforce） | config.json 其余 37 键任何改动 |
| 文档 | 本计划目录四文件：task_plan.md / findings.md / progress.md / knowledge-brief.md | verification.md / notepad-learnings.md / 其他 plans/ 目录 |

**执行前自我检查：** 只操作上表 11 个路径；未列路径一律不碰；扩展范围须用户授权。

## 📚 必要知识储备（任务知识库对齐 — 已验证本地可获取）
| 知识源 | 定位 | 用途 |
|--------|------|------|
| critical-rules.md Rule 25-26（派发契约/子代理产出核查）、Rule 34（template gate） | skills/task-planner/references/critical-rules.md | Rule 37 措辞与锚点格式对齐 |
| template-mapping.md 全文（198 行 8 章节，§六互斥表 L145-154，§七定制红线） | skills/task-planner/references/template-mapping.md | §九 矩阵格式仿既有章节 |
| config.json `content_quality_enforce`（L71-80，writing/research/publish 分档先例） | skills/task-planner/config.json | 新键 enum/default/description 仿写 |
| template-guide.md 计数锚（L32「13 个」、L60 总数） | skills/task-planner/references/template-guide.md | Phase 2 S5 计数联动核对 |
| selftest-template-lifecycle.sh（17 断言 TL-01..17，TL-17 断言在 L80-82） | skills/task-planner/scripts/selftest-template-lifecycle.sh | TL-18 追加格式仿写 |

## Phases

### Phase 1: 规则与主文件层（Rule 37 + SKILL.md 纯增量）
- **目标**：建立机制画像的规则权威（Rule 37）与主文件三个指针（路由表注记 / C25 / Critical Rules 列表行）。
- [x] S1 critical-rules.md 末尾纯追加 Rule 37（37.1 画像表权威源=template-mapping.md §九；37.2 判定时点=计划创建期选定 template_type 后立即套用；37.3 三类机制组；37.4 消费侧；37.5 机制键）
- [x] S2 SKILL.md 三处纯增量（①路由表头部类型适配注记行指向 Rule 37+§九 ②合规检查清单加 C25 ③Critical Rules 列表加 Rule 37 一行）
- [x] 逐 Phase git commit
- **Status:** complete
- **Executor:** code-assistant
- **V-1:** VC-1, VC-3

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | critical-rules.md 末尾纯追加 Rule 37 任务类型机制画像（≤70 行，37.1-37.5 五子条） | code-assistant, haiku-1 | plans/task-v085-task-type-mechanism-profile/knowledge-brief.md §1/§2 + references/critical-rules.md（315 行，末条 Rule 36.7 L315）+ 材料包「方案设计 A」段：Rule 37 只放判定规则+指针，画像表权威源在 §九，明示「仅裁剪类型组机制，3-File/委派率/漂移检测等通用守卫全类型不变」 | `grep -n "### 37"` 命中且文件行数 ≤385（原 315+70）；既有 L1-315 与 `git diff` 对照零改动 | ≤15min | pending |
| S2 | SKILL.md 三处纯增量：路由表头部注记 / 合规清单 C25 / Critical Rules 列表 Rule 37 行（共 ≤10 行） | code-assistant, haiku-1 | plans/task-v085-task-type-mechanism-profile/knowledge-brief.md §3 锚点表（SKILL.md 545 行；路由表 L354 起、L355 强制约束行、L357 表头）+ 材料包「方案设计 C」段三处定位与措辞；注记须明示「仅裁剪代码组机制，通用守卫不变」（FMEA R1 兜底措辞） | `grep -c` 三处锚各 ≥1 命中；`git diff --stat` 显示 SKILL.md 净增 ≤10 行；TL-14/15 grep 锚保留（selftest-template-lifecycle 相关断言不破） | ≤15min | pending |

### Phase 2: 模板与映射层（§九 矩阵 + 通用模板微调 + 计数联动）
- **目标**：落地图画像矩阵权威源（§九）并让通用模板与 guide 计数与新结构一致。
- [x] S3 template-mapping.md 新增 §九 机制适用性矩阵（14 行 × 4 列）+ §一决策树尾注记
- [x] S4 通用 templates/task_plan.md 两处微调（Code Review 节自动判定句 + Executor 示例注记）
- [x] S5 template-guide.md 计数联动核对（章节计数/「13 个」锚不被破坏，必要时补一行矩阵指针）
- [x] 逐 Phase git commit
- **Status:** complete
- **Executor:** code-assistant（三个 S-unit 均为文档/模板小步编辑）
- **V-2:** VC-1, VC-2, VC-3

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S3 | template-mapping.md 新增 §九 机制适用性矩阵（14 行：13 variant+general × 列=类型/默认适用机制/不适用机制/执行体路由组，≤60 行）+ §一决策树尾部加 1 行指针注记 | code-assistant | knowledge-brief.md §2 事实 2/4 + references/template-mapping.md（198 行 8 章节；§六互斥表 L145-154 表格样式、§七定制红线 L158 起禁改区、§八验证命令 L178 起——§九 追加于 §八 之后，编号顺延）+ 材料包「方案设计 B」段列定义与三内容类行措辞 | `grep -n "^## 九、"` 命中；表体 14 数据行（`grep -c '^|'` 差值核对）；writing/research/publish 三行含「不适用：Code Review Gate」字样 | ≤15min | pending |
| S4 | 通用 templates/task_plan.md 两处微调（≤8 行）：Code Review 配置节加自动判定句；Executor 示例加机制画像注记 | code-assistant | knowledge-brief.md §3（templates/task_plan.md 416 行；Code Review 节 L16-24 二态注释、L24 值行）+ 材料包「方案设计 D」段两句措辞：判定句=「默认按 template_type 机制画像判定，代码组外默认 n/a」 | `grep -n "机制画像" skills/task-planner/templates/task_plan.md` ≥2 命中；`git diff --stat` 净增 ≤8 行 | ≤15min | pending |
| S5 | template-guide.md 计数联动核对：确认「13 个」variant 计数与模板总数锚不受影响，追加 §九 矩阵指针 1 行 | code-assistant | knowledge-brief.md §3（template-guide.md L32「13 个」、L60 总数锚）+ selftest-template-lifecycle.sh L80-82 TL-17 断言原文（grep '13 个' 必须继续命中）+ 材料包 FMEA R2 兜底（只同步计数不改结构） | `bash skills/task-planner/scripts/selftest-template-lifecycle.sh` TL-17 仍 PASS；guide 新增行 ≤1 | ≤15min | pending |

### Phase 3: 脚本与守卫层（config 键 + 画像抽查 + selftest）
- **目标**：机制画像获得机器执行与守护——config 档位键、check-complete 抽查段、新 selftest + TL-18。
- [x] S6 config.json 新增 `mechanism_profile_enforce` 键（enum warn/enforce/off 默认 warn）
- [x] S7 check-complete.sh 末段新增画像抽查段（≤15 行，warn 不改 exit / enforce exit 1）
- [x] S8 新建 selftest-mechanism-profile.sh（12-15 断言含行为级）+ selftest-template-lifecycle.sh 追加 TL-18
- [x] 逐 Phase git commit
- **Status:** complete
- **Executor:** code-assistant（S7/S8 为脚本小步编辑；S6 走 json-edit-agent 保 JSON 合法性）
- **V-3:** VC-3, VC-4, VC-5

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S6 | config.json 新增 mechanism_profile_enforce 键（enum [enforce,warn,off] 默认 warn，位置邻近 template_gate_enforce L305） | json-edit-agent | knowledge-brief.md §3（config.json L71-80 content_quality_enforce 先例：enum 三档+default warn+description 注明 Rule 编号；L305 template_gate_enforce 块样式）+ 材料包「方案设计 G」段 | `python3 -m json.tool` 通过；新键 grep 命中且 default=warn；其余 38 键零改动（diff 行数=键块行数） | ≤15min | pending |
| S7 | check-complete.sh 末段新增画像抽查段（≤15 行）：读计划 template_type，∈writing/research/publish 且 code_review: required → warn 提示不改 exit，enforce 档 exit 1 | code-assistant | knowledge-brief.md §3（check-complete.sh 868 行；L11 exit 0 出口、L509 enforce/warn 档语义注释）+ selftest-smart-merge.sh 范式 + 材料包「方案设计 E」段 | 手工构造 fake plan 双档实测：warn 档脚本整体 exit 0 不变、enforce 档该段命中 exit 1；既有断言全量不破 | ≤15min | pending |
| S8 | 新建 selftest-mechanism-profile.sh（12-15 断言，含行为级 fake plan 双档断言）+ selftest-template-lifecycle.sh 追加 TL-18（template-mapping.md 含 §九 矩阵节） | code-assistant | knowledge-brief.md §3（selftest-template-lifecycle.sh 85 行，L80-82 TL-17 ok/bad 范式；selftest-veto.sh 静态守护范式）+ 材料包「方案设计 F」段断言清单 | 新 selftest 运行 0 FAIL（含 warn 档 exit 0 + enforce 档 exit 1 行为断言）；lifecycle 脚本含 TL-18 且全量 PASS | ≤15min | pending |

### Phase 4: 验证与交付层（复验 + Code Review Gate + 合并回）
- **目标**：全量复验、Code Review Gate、worktree 合并回主仓与簿记收尾。
- [x] S9 关键文件 Read 复验 + 可靠性自查（对照 VC-1/2/3 逐条）
- [x] S10 全量 selftest + 逐 Total 行求和核对（0 FAIL 基线）
- [x] S11 Code Review Gate + 终验 + smart-merge-back --deploy + 簿记
- [x] 全部 VC 复验通过后 outcome 判定
- **Status:** complete
- **Executor:** 主进程（例外理由：S11 合并回/簿记/AskUser 属主进程编排职责与白名单①③⑥动作，不可下放；S9/S10 为验证类派发）
- **V-4:** VC-4, VC-5

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S9 | 关键文件 Read 复验 + 可靠性自查（VC-1/2/3 逐条对照） | verifier | knowledge-brief.md §2/§3 + task_plan.md VC 表 + 材料包「已验证事实」段（7 条一手调研事实） | 逐 VC 复验记录写入 verification.md（V-N.N 项）；无「未验证」结论残留 | ≤15min | pending |
| S10 | 全量 selftest 运行 + 主进程逐 Total 行求和核对（0 FAIL） | code-runner-agent | knowledge-brief.md §3 selftest 目录锚 + Phase 3 产出脚本路径 + 材料包 VC-4/VC-5 判定标准 | 全量 selftest 汇总 0 FAIL；Total 行求和与逐项一致（求和记录落 verification.md） | ≤15min | pending |
| S11 | Code Review Gate → 终验 → smart-merge-back --deploy → 簿记（progress/ledger/notepad 收尾） | 主进程（白名单①③⑥：合并回主仓、用户确认点、终验簿记为主进程编排职责） | task_plan.md 终验规则 + references/worktree-isolation.md §3 SOP + §11.3 合并回五条件 | Code Review 通过记录；`git log` 含 wt 分支 --no-ff 合并提交；worktree remove + branch -d 完成；merge_back=merged(&lt;commit&gt;) | ≤15min | pending |

## 🔀 隔离决策
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（本仓即 task-planner 技能仓本体，多任务并行可能，改 SKILL.md/脚本区） |
| `isolation` | `worktree` |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v085-task-type-mechanism-profile`（集中目录，§11.2 规范） |
| `branch` | `wt/task-v085-task-type-mechanism-profile` |
| `merge_back` | `pending`（完成后 merged(&lt;commit&gt;)） |
| `备注` | 计划文档（plans/task-v085-*）保留主仓 plans/ 目录，不进 worktree；执行期子代理 prompt 一律带 worktree 绝对路径并强约束「禁止触碰其他 worktree」（§11.4） |

## 🔁 原生 Todo 同步
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ | | 开工时建 4 条（每 Phase 1 条） |
| Phase 2 | ☐ | | |
| Phase 3 | ☐ | | |
| Phase 4 | ☐ | | |

## 🤝 Subagent Handoff 登记表（Rule 22.5 — 逐 S-unit 派发，禁打包）
| seq | agent_type(model) | 目标 | 状态 | checkpoint |
|-----|-------------------|------|------|------------|
| 2 | code-assistant(haiku-1) | S1 Rule 37 纯追加 | pending | plans/task-v085-task-type-mechanism-profile/subagent-state/2-code-assistant.md |
| 3 | code-assistant(haiku-1) | S2 SKILL.md 三处增量 | pending | plans/task-v085-task-type-mechanism-profile/subagent-state/3-code-assistant.md |
| 4 | code-assistant | S3 template-mapping §九 | pending | plans/task-v085-task-type-mechanism-profile/subagent-state/4-code-assistant.md |
| 5 | code-assistant | S4 通用 task_plan 微调 | pending | plans/task-v085-task-type-mechanism-profile/subagent-state/5-code-assistant.md |
| 6 | code-assistant | S5 guide 计数联动 | pending | plans/task-v085-task-type-mechanism-profile/subagent-state/6-code-assistant.md |
| 7 | json-edit-agent | S6 config 新键 | pending | plans/task-v085-task-type-mechanism-profile/subagent-state/7-json-edit-agent.md |
| 8 | code-assistant | S7 check-complete 抽查段 | pending | plans/task-v085-task-type-mechanism-profile/subagent-state/8-code-assistant.md |
| 9 | code-assistant | S8 新 selftest+TL-18 | pending | plans/task-v085-task-type-mechanism-profile/subagent-state/9-code-assistant.md |
| 10 | verifier | S9 复验+可靠性自查 | pending | plans/task-v085-task-type-mechanism-profile/subagent-state/10-verifier.md |
| 11 | code-runner-agent | S10 全量 selftest 求和 | pending | plans/task-v085-task-type-mechanism-profile/subagent-state/11-code-runner-agent.md |
| 12 | 主进程 | S11 Gate+终验+合并回+簿记 | pending | plans/task-v085-task-type-mechanism-profile/subagent-state/12-main.md |

## ❓ Key Questions
1. Rule 37 是否需要覆盖「计划显式 code_review: required 覆盖画像判定」的优先级语义？（建议：显式声明优先于画像默认，37.4 写明）
2. §九 矩阵 13 variant 行中 bugfix/refactor 等代码组与内容组的边界行措辞如何定？（建议：按「主产出物=代码 vs 内容」划分，逐行写明）
3. check-complete.sh 画像抽查段读取活跃计划的路径解析是否复用 resolve-plan-dir.sh？（建议：复用，避免第二套路径逻辑）

## 📋 Decisions Made
| Decision | Rationale |
|----------|-----------|
| 采用「机制画像映射层」方案（A-G 七件套）而非「每机制加 per-type 开关键×N」 | 调研来源：Explore 子代理一手调研（2026-09-20，事实 1-7）。否决理由：per-type 键方案 config 键爆炸（N 机制×M 类型）、新机制必改 config；映射层一次收口，先例=config.json content_quality_enforce 已按 writing/research/publish 分档（L71-80） |
| 画像表权威源放 template-mapping.md §九，Rule 37 只放判定规则+指针 | 模板知识单一事实源原则；template-mapping.md 已是 13 类模板导航权威（198 行 8 章节），避免 critical-rules.md 与 mapping 双源漂移 |
| Rule 37 编号取 37（现末位 Rule 36.7 在 critical-rules.md L315） | 已实测 grep 确认 36 为最高编号；37 纯追加无级联改号 |
| config 键名 `mechanism_profile_enforce` 默认 warn | 仿 template_gate_enforce/content_quality_enforce 三档范式（L305/L71），观察期默认 warn 降低误伤 |
| check-complete 抽查 warn 档不改 exit（恒 exit 0） | 与 L509 既有档位语义一致；防止新段破坏既有 868 行脚本的 exit 0 出口语义（FMEA R3） |
| 本计划自身 code_review: required | 本任务改 .sh 与技能运行时文件（材料包事实 7），rule-enhancement 属代码组，Code Review Gate 自律适用——同时成为 Rule 37 判定的首个消费示例 |
| D1 计划批准 | 2026-09-20 AskUserQuestion 呈示计划后用户未即时应答（自主会话）；任务源自用户显式优化指令且方案纯增量可逆（worktree 隔离+warn 档非破坏）→ 按最佳判断继续执行，交付报告供用户事后复核 | silent: D1 自主继续（无应答≠否决） |

## ⚠️ FMEA（≥3 项）
| # | 失败模式 | 影响 | 严重度 | 兜底动作 | RPN |
|---|---------|------|--------|---------|-----|
| R1 | 路由表注记被误读为「非代码豁免全部守卫」→ 通用守卫被跳过（3-File/委派率/漂移检测失守） | 高 | 8 | 注记措辞明示「仅裁剪代码组机制，通用守卫全类型不变」；S2 验收含措辞核对；TL-18 断言注记锚 | 160 |
| R2 | TL-17「13 个」计数断言 FAIL（guide 被 §九 联动改坏计数锚） | 中 | 6 | 兜底=只同步计数不改结构；S5 验收=执行 selftest-template-lifecycle.sh TL-17 仍 PASS | 90 |
| R3 | check-complete.sh 新增段破坏 exit 语义 → 全量任务终验误拦/误放 | 高 | 8 | warn 档不改 exit（恒 exit 0）+ enforce 档行为断言（fake plan 双档实测，S7/S8 验收）；新 selftest 行为级守护 | 144 |
| R4 | 通用 templates/task_plan.md 微调破坏 check-complete.sh 既有 grep 锚（模板是脚本的校验对象） | 中 | 7 | S4 限两处 ≤8 行；S10 全量 selftest 求和复验；锚区（L16-24/L180）diff 逐行核对 | 105 |

## 🔬 假设登记（未验证 — 执行期转证据或废除）
1. 假设 §八验证命令（template-mapping.md L178 起）之后追加 §九 不会破坏 §八 内的验证命令语义 —— 执行期 S3 派发前 Read §八 全文确认。
2. 假设 SKILL.md「合规检查清单」存在编号至 C24 的行（C25 顺延）—— 执行期 S2 派发前 grep 核实最大 C 编号。

## 📝 Notes
- 用户原话：「优化我的该技能（task-planner） 我希望可以区分任务 不是所有的任务都需要使用 比如 @Code Reviewer 在文章撰写任务完全不需要 这种skill的使用」
- 材料包：plans/task-v085-task-type-mechanism-profile/subagent-state/1-plan-writer-brief.md（S1 派发源）
- 执行期逐 S-unit 派发（禁打包，Rule 21.1b）；S-unit ID 纯数字（attest 拒锁字母后缀命名）
- S1 材料包引用 knowledge-brief.md §1/§2/§3 锚点，执行体可只读 brief 完成编辑
