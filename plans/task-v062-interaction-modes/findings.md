# Findings & Decisions — task-v062-interaction-modes
<!-- Rule 19.1: 子代理/调研返回后紧邻回填;Rule 3: 每 2 次 view/search 后更新 -->

## Requirements
- 用户指令（2026-09-12）：给 task-planner 添加两种交互模式——①**静默模式**（不询问，自主执行）；②**询问用户模式**（关键决策点将选项供用户选择）。核心目标：**提高整体执行可靠性，减少重复返工的概率**。
- 设计原则：方向性错误在分叉点被拦截（ask）或被显式登记供事后复核（silent），两端都压缩"执行到底才发现错"的返工面；安全底线（破坏性操作确认、连续失败 STOP、漂移 BLOCKED）两模式一致不可豁免。
- **中断恢复重建结论（18:1x-18:2x，恢复窗口回填）**：Phase 5 派发中断后另一恢复窗口独立完成 Phase 5-8（合并 b0da240 + 重部署 + Gate CHANGES_REQUESTED→16f051b 修复→APPROVED 复验）；本窗口按「先复验后采信」全量第一手复测（6 套件 106 用例 fail=0 / 3 位 diff IDENTICAL / agent 2 位符合 / 部署位探针全命中）；补登 Handoff #2-#7 后委派率修正 0.44/exempt → **0.778/ok**（差异根因=Handoff 登记滞后，见 verification.md 修正记录）；双窗口竞态与恢复协议已固化 memory `interruption-recovery-first-verify`。

## 📚 必要知识储备对齐记录
| 知识源 | 定位 | 已消费 | 结论落点 |
|--------|------|--------|---------|
| memory: change-linkage-audit | memory 目录 | ☑ | 联动面清单（下表）+ Phase 6/8 联动范围 |
| memory: task-planner-repo-deploy-flow | memory 目录 | ☑ | companion 改动 → agent 2 位对齐（v057 陷阱） |
| memory: serial-dispatch-iron-rule | memory 目录 | ☑ | 全程串行派发执行 |
| config.json 现行结构 | `skills/task-planner/config.json`（JSON schema，additionalProperties:false） | ☑ | Phase 4 设计 |
| 既有询问点盘点 | SKILL.md:77-79/148/291/382 + critical-rules:30/44/64/68/76/124 | ☑ | Rule 28 D1-D6 设计 |
| 联动面盘点 | 见下表 | ☑ | scope_files + Phase 分配 |

## Research Findings

### 联动面盘点（2026-09-12 主进程取证）
| # | 位置 | 现状 | 联动动作 |
|---|------|------|---------|
| 1 | `config.json` | JSON schema，18 键，`additionalProperties:false` | 新增 `interaction_mode` property（ask\|silent，默认 ask） |
| 2 | `SKILL.md:77-79` | 计划确认门"等待用户显式 yes" | 接 Rule 28：ask 保持；silent 自动通过（attest 后直执行） |
| 3 | `SKILL.md:148` / `:382` / `:291` | 既有 AskUserQuestion 点（fix-phase 3 败/22.3⑤/escalation） | 注记 Rule 28 交互语义 |
| 4 | `SKILL.md:274` 摘要区 | Rule 27 行止 | 追加 Rule 28 摘要行 |
| 5 | `critical-rules.md` | 规则 1-27；既有询问点 :30/:44/:64/:68/:76/:124 | 新增 Rule 28（D1-D6+询问规范+silent 语义+resolve 脚本） |
| 6 | `templates/task_plan.md:24-26` | 配置表 code_review/session_id/worktree_path | 加 `interaction_mode` 行（可选字段） |
| 7 | `templates/variant/*.md`（12 个，≥6 个含配置表） | 无 interaction_mode | **不改**（字段可选,缺省回落 config;取舍记录于 Decisions,防误判遗漏） |
| 8 | `companion/agents/plan-writer.md:129` 区 | 配置表含 code_review 行 | 加 interaction_mode 行（plan-writer 须知此字段） |
| 9 | `README.md`（skills/task-planner/ 内）:119 | "config.json 键说明（18 键）" | 18→19 + 新键说明行 |
| 10 | `CLAUDE.md`（仓根） | 树仅列 plans/references，无 config/scripts 行 | 不改（无失效引用） |
| 11 | 部署位 | 3 位 skill + plan-writer agent 2 位 | companion 改动 → agent 2 位必须对齐（memory v057 陷阱） |
| 12 | examples.md / reference.md | 无确认/模式相关联动 | 不改 |

### Rule 28 设计（材料包源 — Phase 2 照此执行）

**`### 28 交互模式与询问门控(P0 — task-v062,目标:减少返工)`**

28.1 **模式定义与解析优先级**:两种模式——`ask`（默认:关键决策点给选项供用户选）与 `silent`（静默:不询问、自主决策、登记清单）。解析优先级:env `TASK_PLANNER_INTERACTION_MODE` > 当前计划配置表 `interaction_mode` 行 > `config.json#interaction_mode` > 默认 `ask`;非法值视同缺失,降级到下一级;用户会话中口头切换("接下来静默执行"/"问我")优先于一切既设值,切换后须 S5 回写计划配置表。
28.2 **ask 模式询问点(D1-D6)**:D1 计划批准——展示计划后等待显式 yes(既有门控,保持);D2 方案分叉——实现存在 ≥2 条合理路径且影响交付物形态/范围/兼容性 → AskUserQuestion;D3 兜底前移——22.3 链走到 ③ 降档前(② 拆细已失败)即询问"继续拆细/换方向/降档";D4 范围外需求——执行中发现需触碰 scope 外文件/引入新依赖/改 schema → 询问;D5 歧义指令——用户指令存在 ≥2 种合理解读且影响交付 → 询问;D6 既有硬停点——22.7 连续失败 STOP/Rule 11 drift BLOCKED/Rule 26 Q3/§五 破坏性操作确认,**两模式一致,不可静默豁免**。
28.3 **询问规范**:每次 AskUserQuestion 带 2-4 个选项,首选标 (Recommended) 置顶并写明理由与权衡(对齐用户宪法 §四 选项呈现规范);能选项化必须选项化,禁止开放提问代替选择题;用户答案回填 Decisions Made 表(问题+选择+时间),防止口头决策不留痕。
28.4 **silent 模式语义**:除 D6 外不调用 AskUserQuestion;每个被跳过的询问点按"推荐项"自主决策,并登记「静默决策清单」——Decisions Made 表加 `silent:` 前缀行(决策+假设+复核入口);交付报告必须附清单供用户复核;用户保留随时打断与切换权。Why:方向性错误在分叉点被拦截(ask)或被显式登记供复核(silent),两端都压缩"执行到底才发现错"的返工面。
28.5 **机制**:scripts/resolve-interaction-mode.sh 统一解析口径(env > plan 配置表 > config > 默认 ask),供主进程/自测/hook 后续扩展使用;scripts/selftest-interaction.sh 守护解析优先级与 fail-safe(缺 config/非法值 → ask)。

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 默认模式 = ask | 用户核心目标是减少返工;ask 在分叉点拦截方向错误;silent 是用户显式让渡决策权时的加速态 |
| D6 硬停点两模式一致 | 安全底线(破坏性操作/连续失败/漂移 BLOCKED)属宪法 §五 层,不因静默而豁免 |
| variant 模板不加 interaction_mode 行 | 字段为可选(缺省回落 config.json),主模板已文档化;12 个 variant 重复加行是冗余而非联动(取舍登记,防误判遗漏) |
| resolve 独立脚本而非并入既有脚本 | 单一职责 + 可被 selftest/hermetic 守护;后续 hook 扩展可复用 |
| interaction_mode 放计划配置表而非 frontmatter | 与 code_review/session_id/worktree_path 同表同范式,plan-writer 填表口径一致 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| （暂无） | |

## Resources
- 同构先例：plans/task-v061-serial-dispatch/（文本+机制+selftest+Code Review+重部署全流程）
- README 键说明段：skills/task-planner/README.md:119（"config.json 键说明（18 键）"）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7) -->

### 方法论调研（用户 09-12 指令：引入方法论提升执行质量与可靠性）
[2026-09-12 主进程,派 2 个 web-search-opencode 子代理并行调研,只读不写]
- 可靠性/执行侧可引入条目（带出处）：Poka-Yoke 防错(前置条件函数阻断)、Quality Gate 门控表、FMEA 预演(RPN 评分)、5 Whys 根因链、鱼骨图分类、验证驱动完成(证据随 Phase 提交)、幂等+检查点(checkpoint.jsonl 断点续)、降级阶梯(三层,每层留痕)、小批量(chunk≤3 独立验收)。与既有 Rule 22.3 五档兜底、Rule 19 三文件门控、Rule 26 降质惩罚大量同构,增量点=Poka-Yoke 前置条件+FMEA 规划期预演+checkpoint.jsonl 显式化。
- 内容质量侧可引入条目：证据化写作(三级引用/矛盾检测)、事实核查流水线(URL+时间戳+独立源交叉)、去 AI 化 10 条清单(删过渡短语/数字替代模糊词/长短句交替/承认不确定性)、8 字段输出契约(与 22.4b 同构)、五维评分卡(准确性 25/相关 20/可读 20/原创 20/SEO 15,≥4.0 发布)。
- 定位判断:方法论落点 = task-planner 技能的"执行可靠性"侧 + 文章流水线侧的"内容质量"侧;需与既有 Rule 25 降级范式范式对齐,不重复造轮子。
- 证据:2 子代理返回全文已回收(会话内),关键条目已摘要;出处=Shingo(1989)/SAE J1739/Lamport(1978)/Anthropic Claude Code 2024/GPTZero/Poynter 等。

## Code Review Gate（2026-09-12，agent=Code Reviewer sonnet-1，只读，检查点 subagent-state/07-code-reviewer.md）
- 判定: CHANGES_REQUESTED（P0=0 / P1=2 / P2=3 / P3=4），6 套 selftest 104/0、8 文件 diff 全核对、jq 缺失 fail-safe 实测排除 P0
- P1-1: resolve-interaction-mode.sh:63-64 值列带注解（`\`silent\`（用户…）`）时静默降级到 config 层——实测真实 v062 计划声明 silent 却解析出 ask，口径漂移+无痕降级；修复=第 63 行 grep 改 `[[:space:]]` 锚定键、第 64 行取首 token（sed 提取），/tmp 副本预验证 4 场景全对+8/8 不变
- P1-2: SKILL.md:384（22.3 兜底链第⑤档 AskUserQuestion 行）缺 Rule 28 注记（findings 联动表 #3 要求 :148/:382/:291 三处，:382 实证缺口）；修复=行尾单行追加
- P2（同轮合并）: ①resolve:68 非法值降级分支加 stderr 诊断行 ②selftest 补 TI-09（注解值）/TI-10（顶层 .interaction_mode） ③README:119 标题改「常用键（19 项）」消除与 schema 22 键的歧义
- P3（登记不强制）: trap 扩 INT/TERM；:11 fail-open 措辞改 fail-safe；local num 未用
- 冲突检查: D6 vs Rule 11/22.7/26 语义一致无矛盾；Rule 7 三击未被 D6 列举=LOW 可选收口，不阻塞

## Code Review 复验（2026-09-12，agent=Code Reviewer sonnet，检查点 09-code-reviewer-recheck.md）
- 终判: APPROVED（P1 2/2 CLOSED + P2 3/3 CLOSED，P0=0；6 套件 106/0 EXIT=0；worktree clean HEAD=16f051b）
- P1-1 CLOSED: resolve:64-66 [[:space:]] + awk 取列 + sed 首 token + :69-70 stderr 诊断；真实计划实测 silent（修复前 ask）、模板占位 ask
- P1-2 CLOSED: SKILL.md:384 第⑤行 Rule 28 注记在位，表 5 行完整
- 残留登记（LOW，不阻断，用户决策是否排后续轮）: env 层（①）非法值仍静默降级无诊断（与②层不对称）；P3 2 条未改（run_case 冗余 local num / assert 重复编号）
