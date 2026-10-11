<!-- template_type: rule-enhancement -->
<!-- 适用场景: task-planner 技能规则/条款增强——新增 Rule NN、config 三档键、消费侧门控脚本、selftest 守护、SKILL 联动 -->
<!-- 触发关键词: 加规则/新增 Rule/条款/门控/合规清单/守护/技能增强/机制化 -->
<!-- 推荐 subagent: executor(sonnet-1) 写条款与脚本; code-runner-agent 跑 selftest; 合并部署主进程 -->
<!-- 沉淀出处: task-v074（Rule 34.3① 同类任务第 3 次触发；v071-v073 同套路轮次佐证） -->
<!-- frontmatter（本任务定值）: template_type=rule-enhancement / new_rule=55 / interaction_mode=silent / isolation=worktree / code_review=required / parallel_groups=[] -->

# Task Plan: Rule 55 可复用能力落盘纪律（能力脚本目录+注册表+Agnes 额度脚本+执行体接线+selftest 守护）

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：Rule 51.1 计划侧载体。R 行=用户原话逐条编号抄录；映射=每条核心需求 ≥1 VC。来源=plans/task-v138/design-brief.md §2（唯一需求权威源，逐字抄录） -->

- **R1**: 「我希望可以在我的该技能中，确保就是常用的功能、可复用的功能及时落盘到一个固定的脚本或者固定文档中」
- **R2**: 「确保后期不会重新再执行一遍弱智的功（能）」
- **R3**: 「像获取视频额度、视频剩余视频生成剩余额度，这种非常常用的功能……正常应该是直接通过API继续获取……他做的时候是每次将莫名其妙，第一次消耗了几秒，第二次消耗了几秒，然后统计出来，最终产出的结果就是一个莫名其妙的完全不对的结果」
- **R4**: 「（复述确认范围）机制落在 task-planner 技能体系=通用执行纪律（覆盖一切任务链），视频额度查询为其首个落盘实例；非仅视频个案补丁」

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2, VC-3 | Rule 55.3/55.4 条款在位（grep `^55\.[34]`）且固定落点实体存在：`scripts/capabilities/agnes-quota.sh` 与 `references/capability-registry.md` 绝对路径 `test -f` =1 |
| R2 | VC-1, VC-4 | 复用前置检查条款 `^55.1` 在位；两个 executor 文件含复用指向行（grep 计数 ≥1/文件），且与注册表首条行号交叉可指 |
| R3 | VC-1, VC-2 | `^55.2` 权威来源优先禁令在位；`bash -n scripts/capabilities/agnes-quota.sh` exit 0 且实跑输出结构化额度（端点确认时）/ 或显式 PARTIAL 登记（不可得时） |
| R4 | VC-1, VC-3, VC-6 | 条款落在 `references/critical-rules.md`（通用执行纪律载体，非视频项目文件）；注册表首条 8 列完整；合并回 master 后三宿主部署 diff=0 |

<!-- plan_tier: standard -->
## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- R1/R3 含结果性词「确保/完全不对的结果」→ 结果级需求，走 53.1 全链工序审计（非裸豁免）。审计对象=「一次高频可复用操作的执行全链」 -->
| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| ① 需求识别（判定本次操作是否「可复用」） | 无判别标准，执行体不认为「查额度」属可复用操作 → 从不查注册表 | Rule 55.1 三条可复用判别特征（查询类外部事实/重复≥2 次固定多步/存在权威源） | VC-1 |
| ② 执行前复用检查 | 无「先查注册表/脚本目录」的强制动作位，即使已有脚本也重写一遍 | Rule 55.1 复用前置检查（必查 `capability-registry.md` + `scripts/capabilities/`）+ 55.4 固定位置 | VC-1, VC-3 |
| ③ 执行方法选取（数据来源） | 权威 API 不直查，改用耗时累计推算 → 结果完全错误（用户实证） | Rule 55.2 权威来源优先禁令（代理推算一律禁止；不可得才允许且标「推算值+方法+未验证」） | VC-1, VC-2 |
| ④ 首次成功后的落盘 | 成功执行后无落盘义务，方法随会话蒸发 → 下次重新发明（用户 R2「重新再执行一遍弱智的功」） | Rule 55.3 首次成功即落盘（可脚本化→scripts/capabilities/；纯知识→references/），落盘计入任务 DoD | VC-1, VC-2 |
| ⑤ 落盘产物的索引与可发现 | 脚本无唯一索引则下一个执行体找不到它，落盘等于半落盘 | Rule 55.4 注册表 `references/capability-registry.md` 8 列唯一索引 + 三宿主同步 | VC-3 |
| ⑥ 下一次任务的实际复用 | 条款写完但执行体 SOP 无挂点 = 条款死文（53.2 反例：task-v131 清账判例） | Rule 55.5 执行体接线（image/video-generation-executor SOP 指向行）+ 55.6 selftest 静态守护 | VC-4, VC-5 |
| ⑦ 机制防复发 | 只写条款无机器守卫 → 回归期可被静默删改 | `scripts/selftest-capability-persistence.sh` + `selftest-registry.tsv` 登记（零新 config 键） | VC-5 |
| ⑧ 部署与合并 | 源仓落地但三宿主未同步 = 执行体从部署位读到旧规则 | Phase 5 smart-merge-back --deploy + 逐位 IDENTICAL 对账 | VC-6 |

## Goal
[一句话: 落地 Rule 55「可复用能力落盘纪律」五子条+机制（55.1 复用前置检查 / 55.2 权威来源优先禁令 / 55.3 首次成功即落盘 / 55.4 固定位置与注册表 / 55.5 执行体接线 / 55.6 机制），并交付首个落盘实例 `scripts/capabilities/agnes-quota.sh` + `references/capability-registry.md` 首条 + 两个生成执行体 SOP 指向行 + selftest 守护，全量 selftest 0 FAIL 后合并回 master 并部署 3 宿主实体位]

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（新增 `.sh` 脚本 agnes-quota.sh + selftest-capability-persistence.sh，含密钥读取与网络调用路径） |
| `session_id` | 启动时由 init-session 生成，登记表追踪 |
| `worktree_path` | /home/terry/task-planner-skill-worktrees/task-v138（§十一 隔离决策） |
| `scope_files` | `[skills/task-planner/references/critical-rules.md, skills/task-planner/SKILL.md, skills/task-planner/references/capability-registry.md, skills/task-planner/scripts/capabilities/agnes-quota.sh, skills/task-planner/scripts/selftest-capability-persistence.sh, skills/task-planner/scripts/selftest-registry.tsv, skills/task-planner/companion/agents/video-generation-executor.md, skills/task-planner/companion/agents/image-generation-executor.md]` |
| `interaction_mode` | `silent`（Rule 28：无人值守会话 + 用户指令明确；D6 硬停点语义不变，照旧等待确认） |
| `new_rule` | 55 |
| `对齐审查` | `required` — Phase 4 S3 alignment-review（Rule 42.6 标准收尾）；变更记录随交付物落盘；mini 档豁免不适用（plan_tier: standard） |
| `自动超时默认项` | 询问点无（端点探测结果决定后续分支属事实判定非选项分叉；Rule 44.2 低区分度直接裁决并登记 Decisions Made）；兜底超时 5 分钟 |
| `质量审查工具` | 42.2 四级检测结论：项目级/用户级未建专用审查体；命中环境既有 review-library 池 → `code-quality-review`（脚本/代码面）+ `alignment-review`（文档/条款面），两者执行期必须实跑，登记于 Phase 4 S2/S3 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）
> **验证独立性**：本计划验证动作由独立子代理执行（Phase 4 Executor = code-runner-agent / code-quality-review / alignment-review），主进程自测不作有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式（可复验命令） | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 55 六子条（55.1-55.6）以「`### 55 <标题>` + `55.N **动词短语**：正文`」范式在 `references/critical-rules.md` 文件尾（53.5 之后）纯增量落地；R1-R4 四条需求在条款内有对应条款位（55.1↔R1/R2、55.2↔R3、55.3/55.4↔R1、55.5↔R2/R4）；SKILL.md 索引行含 Rule 55 | `grep -nE '^55\.[1-6] ' skills/task-planner/references/critical-rules.md`（期望 6 行）+ `grep -c '^### 55 ' `（=1）+ `grep -n 'Rule 55' skills/task-planner/SKILL.md`（≥2 处：Critical Rules 全集行 + Rules 索引 bullet） | worktree 内 `references/critical-rules.md` 尾段 + `SKILL.md` 索引段 |
| VC-2 | `scripts/capabilities/agnes-quota.sh` 存在、`bash -n` 语法通过、What+Why 双层注释齐全（Rule 45）、脚本内无硬编码密钥（复用 `agnes_api.py` 的 `get_api_key()` 同源）、**端点确认时**实跑返回结构化额度且非推算值；**端点不可得时**落盘为「错误处理已验证+端点待确认」形态并在 findings 显式登记（V2 判 PARTIAL，禁伪造直查成功） | `test -f` + `bash -n scripts/capabilities/agnes-quota.sh; echo $?`（=0）+ `grep -nE 'agnes_api|get_api_key' `（密钥同源证据）+ `grep -icE 'sk-|api[_-]?key *= *["'\'']' `（=0，禁硬编码）+ `bash scripts/capabilities/agnes-quota.sh` 实跑输出 | `skills/task-planner/scripts/capabilities/agnes-quota.sh` + findings.md Phase 1 探针原始响应 |
| VC-3 | `references/capability-registry.md` 存在且首条（agnes-quota）8 列字段完整：名称\|脚本路径\|用途\|调用方式\|数据来源端点\|输出形态\|verified 日期\|任务来源；表头与首条列数一致 | `test -f` + `head -3` 目视 + `awk -F'|' '/agnes-quota/{print NF}'`（列数 = 表头列数）+ `wc -l`（≥3：标题+表头+首条） | `skills/task-planner/references/capability-registry.md:1-5` |
| VC-4 | `companion/agents/video-generation-executor.md` 前置检查段含额度查询复用指向行（指向 capability-registry.md 首条 + 调用方式），指向行内出现「禁止自行估算/以脚本直查值为唯一来源」语义；`image-generation-executor.md` 对称接线（若 Phase 1 判定额度为账户级）或仅 video 接线并在 findings 登记理由 | `grep -n 'capability-registry\|agnes-quota' companion/agents/video-generation-executor.md`（≥1）+ 同命令跑 image（对称则 ≥1；非对称则 =0 且 findings 有理由行） | `companion/agents/video-generation-executor.md` 前置检查段 + findings.md Phase 1 结论 |
| VC-5 | 全量 selftest **FAIL=0，总数 51+1=52**（总数=主进程逐脚本 Total 行求和，禁采信子代理自报总数）；新增 selftest 只断言 Rule 55 新增锚，零触碰既有脚本既有断言行 | `ls skills/task-planner/scripts/selftest-*.sh \| wc -l`（=52）+ `for f in scripts/selftest-*.sh; do bash "$f" 2>&1 \| grep -i '^Total'; done` 逐行求和（FAIL 计数=0）；`git diff --stat` 确认既有 selftest 脚本零改动 | progress.md Selftest Log + `scripts/selftest-registry.tsv` 末行（新增登记） |
| VC-6 | 合并回 master 后：`git status` 干净、worktree 已 remove、`wt/task-v138` 分支已删；三宿主部署位（`~/.zcode/skills/task-planner`、`~/.claude/skills/task-planner`、`~/.config/opencode/skills/task-planner`）逐位 IDENTICAL diff=0；编号账本 55 = landed；合并后 Read 复验 critical-rules.md 尾段 + capability-registry.md | `smart-merge-back.sh --deploy` 输出 `[DEPLOY] IDENTICAL` ×3；`git log --oneline -1`；`git worktree list \| grep task-v138`（=0 行）；Read 关键文件复核 | 部署输出 + `plans/.rule-reservations.jsonl` 末行 + `plans/INDEX.md` |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但端点不可得（R3 分支）→ outcome: **PARTIAL**（列出「端点待确认」+ 建议后续调研，禁伪造直查成功）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）
- `code_review: required` → 终验前必须先过 Code Review Gate（Phase 4 S2），否则不得标 COMPLETE

## ⚠️ 执行范围限制（强制 — 只操作列表内的文件）
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则条款 | `references/critical-rules.md`（**文件尾纯增量追加** Rule 55 块） | 改 1-53 既有条款语义；在中间插入 |
| SKILL 索引 | `SKILL.md`（Critical Rules 全集行 + Rules 索引 bullet + References 表 critical-rules 行内改写「含 Rule 53」→「含 Rule 55」，**行内改写禁净删**） | 大段新增；动其他章节 |
| 新建能力资产 | `references/capability-registry.md`、`scripts/capabilities/agnes-quota.sh`、`scripts/selftest-capability-persistence.sh` | 建 `scripts/capabilities/` 之外的目录 |
| 执行体 SOP | `companion/agents/video-generation-executor.md`、`companion/agents/image-generation-executor.md`（各仅前置检查段追加指向行） | 改两执行体 Workflow 步骤语义 |
| 登记表 | `scripts/selftest-registry.tsv`（**仅追加 1 行**） | 改既有行；重排 |
| 配置 | **零改动** | `config.json` 任何键（55.6 零新 config 键承诺） |
| 计划系统 | `plans/task-v138/**`、`plans/.rule-reservations.jsonl`（land 一行）、`plans/INDEX.md` | 其他 plans/ 目录 |

**强制约束**：
- **纯增量纪律（Rule 36.5）**：无删除、无既有行语义改写（SKILL References 表行内改写为唯一例外，已在范围表登记）；36.3 删除基线 = 空清单
- **锚级联防御**：新 selftest 只断言 Rule 55 新增锚（`^55\.`、`capability-registry`、`agnes-quota`、`scripts/capabilities/`），**禁触碰任何既有脚本既有断言行**；若既有脚本已对 SKILL.md 行数/`Rules 1-N` 字样设钉，实施前先 `grep -rn 'Rules 1-' scripts/` 与 `grep -rn 'SKILL.md' scripts/selftest-knowledge-brief.sh` 扫一次锚清单
- **密钥安全**：`agnes-quota.sh` 禁硬编码 key，必须复用 `~/.zcode/skills/agnes-ai-generation-skill/scripts/agnes_api.py` 的 `get_api_key()` 同源来源
- **最小探针（Rule 35.6）**：Phase 1 端点探测 GET ≤3 个，原始响应全量落 findings.md
- **派发契约（Rule 22.4）**：每个 S-unit 派发 prompt 必含计划三文件绝对路径 + 九字段上下文 + 8 字段返回标签 + checkpoint 路径；`check-dispatch.sh` 逐字校验
- **v136 在途并存**：`wt/task-v136`（@4bca3dd，Rule 54 reserved 未实施）→ 本任务改动全为文件尾追加，Phase 5 合并前复查 master 是否已被 v136 推进，冲突预期=同区域追加，hunk 级手工合流

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | 卫星技能 web-search-agent(mini) ×1 + Agent 子代理 executor(sonnet-1) ×1 + 机械守卫脚本（bash -n / curl 探针） | 官方文档调研属搜索面，路由表「网络调研」行；端点探测是只读机械命令但需密钥上下文，executor 承接避免主进程密钥外泄；两条串行（探针依赖调研候选清单） |
| Phase 2 | Agent 子代理 executor(sonnet-1) ×2 串行 | 保护区 `.md` 编辑，路由表「业务文档/技能文件」行；Rule 46.1 单会话单 S-unit，critical-rules 与 SKILL.md 分派 |
| Phase 3 | Agent 子代理 executor(sonnet-1) ×3 串行 | bash 脚本 + 注册表 + SOP 行 + selftest 均为保护区写入，需 What+Why 注释规范（Rule 45）由有经验执行体承担；声明组为空 → 串行 |
| Phase 4 | Agent 子代理 code-runner-agent + code-quality-review + alignment-review | 机械验证命令（路由表「跑测试/构建」行）+ 两把质量审查体（42.2 检测登记值） |
| Phase 5 | 机械 git/部署编排（主进程白名单①②） | smart-merge-back / worktree 清理 / rule-reserve land / ledger 簿记属 git 与计划系统运维 |
| **workflow 编排判定（40.4）** | **不命中** | 无 fan-out 型独立并行子任务（S-unit 间文件集与输入均串行依赖），无长链多 skill 接力复用，用户未点名 `/workflow` → Rule 39.1 不路由 |
| **/goal 对齐（40.3）** | 映射指引 | 本计划 Goal + VC 即 session goal 证据源；`/goal` 为用户侧 harness 命令，技能层不可代调（40.3 如实披露） |
| **`parallel_groups`（Rule 21.4）** | `[]`（空） | **未声明并行组 = 全部 S-unit 串行**（2026-10-02 演进默认）；Phase 1-4 每组一次只派一行，验收后再派下一行 |

## Phases

### Phase 1: 端点调研与可用性确认
- **V-N:** VC-2, VC-3
- **Status:** complete（2026-10-05；定论=官方文档无额度端点+billing 端点存在但计费层未填充，脚本走「直查+如实呈现+禁二次推算」规格，证据 findings.md [sub:02]..[sub:06]）
- **Executor:** web-search-agent（mini，≤3 query）+ executor（sonnet-1，只读探针）— 串行两单元
- 说明：先文档后探针，探针候选清单来自调研结论；结论（端点可用/不可得）直接决定 Phase 3 S1 脚本形态与 V2 判定分支
<!-- S-unit 表（Rule 22.6：每行=一次 Agent() 派发；≤2 文件/≤100 行/≤15min；46.1 单会话单单元） -->
| ID | 目标(≤1 句) | 执行体(subagent_type(建议档位)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 | 建议档位 | checkpoint |
|----|------------|------------------------|-------------|---------|------|------|---------|-----------|
| S1 | 调研 wiki.agnes-ai.cn 官方文档确认剩余额度直查端点（≤3 query，无结论即如实登记「文档未记载」） | web-search-agent | ~/.zcode/skills/agnes-ai-generation-skill/references/api.md（Base URL `https://api.agnes-ai.cn`；apihub 域恒 401 陷阱；已知 POST /v1/videos、GET /agnesapi、POST /v1/images/generations、402=额度耗尽；**未记载额度直查端点**）+ plans/task-v138/design-brief.md（§3.3 端点事实段） | findings.md「Research Findings[P1-调研]」含候选端点清单或「文档无记载」结论，每条带 URL | 10min | pending | mini | plans/task-v138/subagent-state/01-web-search-quota.md |
| S2 | 对候选端点做只读 GET 探测（≤3 个）并把原始响应落 findings，判定额度端点可用/不可得 | executor | plans/task-v138/findings.md（S1 候选清单落点）+ ~/.zcode/skills/agnes-ai-generation-skill/scripts/agnes_api.py（`get_api_key()` 密钥同源函数位置） | findings.md「Research Findings[P1-探针]」含每个探针的 HTTP 状态码 + 响应体片段 + 端点可用/不可得判定行 | 12min | pending | sonnet-1 | plans/task-v138/subagent-state/02-executor-endpoint-probe.md |

### Phase 2: Rule 55 条款与 SKILL 索引落地（隔离区内）
- **V-N:** VC-1, VC-5
- **Status:** complete（2026-10-05；commit d6cc6c8：critical-rules +13 纯增量/SKILL +4-3/纪元钉 3 脚本+行数钉 1 行同步；四脚本自测 FAIL=0；锚级联两波按 KQ3+FMEA 兜底处置）
- **Executor:** executor（sonnet-1）— 串行两单元
| ID | 目标(≤1 句) | 执行体(subagent_type(建议档位)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 | 建议档位 | checkpoint |
|----|------------|------------------------|-------------|---------|------|------|---------|-----------|
| S1 | 在 critical-rules.md 文件尾（53.5 之后）纯增量追加 `### 55 可复用能力落盘纪律` + 55.1-55.6 六子条全文 | executor | plans/task-v138/task_plan.md（根源覆盖表八工序 + Goal + 执行范围；条款骨架见 design-brief §3.1 五子条要点）+ skills/task-planner/references/critical-rules.md（593 行，末行为 53.5 机制行，插入点=文件尾） | `grep -cE '^55\.[1-6] ' `=6；`grep -c '^### 55 '`=1；`wc -l` = 593+新增行数；git diff 纯增行零删行 | 15min | pending | sonnet-1 | plans/task-v138/subagent-state/03-executor-critical-rules.md |
| S2 | SKILL.md 追加 Rule 55 索引 bullet + 全集行改写 + References 表行内改写（纯增量/行内改写禁净删） | executor | plans/task-v138/task_plan.md（VC-1 的 SKILL.md 判定锚：全集行 `1-53`、Rules 索引 bullet 尾、References 表 critical-rules 行）+ skills/task-planner/SKILL.md（478 行；Rule 索引 bullet 位于 Rule 49-53 连排段尾部） | `grep -c 'Rule 55' SKILL.md` ≥2；`wc -l` = 478+新增行数；`grep -c '1-54\|1-53'` 行内改写无净删；`bash scripts/selftest-knowledge-brief.sh` SKILL 行数钉若触发则同任务上调并注明 task-v138 | 12min | pending | sonnet-1 | plans/task-v138/subagent-state/04-executor-skill-index.md |

### Phase 3: 能力脚本、注册表、执行体接线与 selftest 守护（隔离区内）
- **V-N:** VC-2, VC-3, VC-4, VC-5
- **Status:** complete（2026-10-05；commit 62561a1：agnes-quota.sh 185 行实跑通过（key_source=bashrc、verdict 正确、退出码 2/3/4 实测）+registry 首条 8 列+两执行体对称接线+selftest 18 断言（含 /tmp 负向副本验证断言咬合力）+tsv 53 行）
- **Executor:** executor（sonnet-1）— 串行三单元（46.1）
| ID | 目标(≤1 句) | 执行体(subagent_type(建议档位)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 | 建议档位 | checkpoint |
|----|------------|------------------------|-------------|---------|------|------|---------|-----------|
| S1 | 新建 `scripts/capabilities/agnes-quota.sh`（What+Why 注释、密钥同源、禁硬编码）+ 新建 `references/capability-registry.md` 8 列首条 | executor | plans/task-v138/knowledge-brief.md（§2 端点事实 + §3 插入点锚：脚本范式=skills/task-planner/scripts/selftest-veto.sh）+ plans/task-v138/findings.md（P1-探针 端点可用性判定结论） | `bash -n agnes-quota.sh` exit 0；注册表 `awk -F'|'` 首条列数=表头列数且 8 字段非空；脚本 `grep -icE 'sk-[a-z0-9]'`=0 | 15min | pending | sonnet-1 | plans/task-v138/subagent-state/05-executor-capability-script.md |
| S2 | 两个生成执行体前置检查段追加额度查询复用指向行（image 对称性依 Phase 1 判定） | executor | plans/task-v138/knowledge-brief.md（§3 锚点表：两执行体前置检查段行号）+ plans/task-v138/findings.md（额度是否账户级判定） | video 文件 `grep -c 'capability-registry'` ≥1；image 同命令 ≥1 或 =0 且 findings 有「仅视频级」理由行；两文件 `wc -l` 仅增 | 12min | pending | sonnet-1 | plans/task-v138/subagent-state/06-executor-sop-wiring.md |
| S3 | 新建 `scripts/selftest-capability-persistence.sh`（只断言 Rule 55 新增锚）+ `selftest-registry.tsv` 追加 1 行登记 | executor | plans/task-v138/knowledge-brief.md（§2/§3：既有 selftest 范式脚本与 tsv 列格式）+ plans/task-v138/task_plan.md（VC-5 断言口径） | `bash scripts/selftest-capability-persistence.sh` exit 0；`git diff --stat` 既有 selftest 脚本零改动；tsv 行数 52→53 且列数与表头一致 | 15min | pending | sonnet-1 | plans/task-v138/subagent-state/07-executor-selftest.md |

### Phase 4: 回归与双审查（隔离区内）
- **V-N:** VC-1, VC-4, VC-5
- **Status:** complete（2026-10-06：S1 回归 52/52 FAIL=0 主进程复核；S2 审查 CHANGES_REQUESTED→F1 经 4b 闭环；S3 对齐审查 APPROVED 0 P0/P1）
- **Executor:** code-runner-agent + code-quality-review + alignment-review（三单元串行）
| ID | 目标(≤1 句) | 执行体(subagent_type(建议档位)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 | 建议档位 | checkpoint |
|----|------------|------------------------|-------------|---------|------|------|---------|-----------|
| S1 | worktree 内全量 selftest 回归（52 脚本）+ SKILL.md 行数 + critical-rules.md 行数复核，逐脚本 Total 行落 progress.md | code-runner-agent | plans/task-v138/task_plan.md（VC-5 复验命令全文）+ plans/task-v138/progress.md（基线与结果落点；基线 51 脚本 @078c683 实测） | progress.md「Selftest Log」逐脚本 Total 行齐全、FAIL 计数=0；`ls selftest-*.sh \| wc -l`=52 | 15min | pending | mini | plans/task-v138/subagent-state/08-code-runner-regression.md |
| S2 | 代码面审查（bash 脚本规范/密钥安全/注释完整性/错误处理） | code-quality-review | plans/task-v138/task_plan.md（执行范围限制 + 强制约束 6 条，含密钥安全与 Rule 45 注释项）+ plans/task-v138/subagent-state/05-executor-capability-script.md（S1 结论与 diff 摘要） | 审查报告落 progress.md Phase 4 段，结论 PASS/CHANGES_REQUESTED；CHANGES_REQUESTED 项全部闭环后才进 Phase 5 | 12min | pending | sonnet-1 | plans/task-v138/subagent-state/09-code-quality-review.md |
| S3 | 对齐审查（条款↔需求 R1-R4↔落地资产，Rule 42.6 标准收尾） | alignment-review | plans/task-v138/task_plan.md（根源覆盖表八工序 ↔ VC 映射）+ plans/task-v138/knowledge-brief.md（§1-§5 知识对齐） | 报告落 progress.md；R1-R4 全 covered 或残余项显式登记；无 P0 遗留 | 10min | pending | sonnet-1 | plans/task-v138/subagent-state/10-alignment-review.md |

### Phase 4b: F1 修复（fix-phase，Code Review Gate CHANGES_REQUESTED 触发 — B 类扩展 2026-10-05）
- **V-N:** VC-2, VC-5
- **Status:** complete（2026-10-06：commit 8b12495，200-only 判据+exit 5+mock 断言 CP-19/20；mutant 咬合验证；主进程机械回归 53/53 FAIL=0；合并 5ed69e7+三宿主 IDENTICAL）
- **Executor:** executor（sonnet-1）→ code-runner-agent 复验
- 背景：Phase 4 S2 审查判 CHANGES_REQUESTED（F1=agnes-quota.sh 非 200 路径误判「计费层已回传数值」）；期间并行会话已将 wt/task-v138 合并回 master（merge 1992566，v136+v138 并集）且 v139 已落（fed4393）→ 修复面=最新 master 新 worktree wt/task-v138b
- 修复项：① agnes-quota.sh 判定逻辑——http_code 非 200（000/4xx/5xx）的端点一律计入「不可达/失败」分支，禁落默认成功 verdict；计费端点失败时 verdict 显式失败语义+退出码非 0（区分 3/4）② selftest-capability-persistence.sh 增补 mock 负向断言（本地 mock 服务返回 404/000 场景下脚本不得输出成功 verdict）③ 判定行语义与 55.2「禁伪成功」对齐
- 验收：mock 404/000 场景 → verdict 失败 + exit≠0；mock 200 场景 → 行为不变；全量 selftest FAIL=0；审查 F1 复验关闭
<!-- S-unit 表（Rule 22.6；46.1 单会话单单元） -->
| ID | 目标(≤1 句) | 执行体(subagent_type(建议档位)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 | 建议档位 | checkpoint |
|----|------------|------------------------|-------------|---------|------|------|---------|-----------|
| S1 | 修 agnes-quota.sh 非 200 误判成功缺陷+判定行失败语义+退出码，并在 selftest 增补 mock 负向断言 | executor | worktree 内 skills/task-planner/scripts/capabilities/agnes-quota.sh（:142-160 判定段缺陷位）+ scripts/selftest-capability-persistence.sh（断言追加位）+ 审查报告 plans/task-v138/findings.md [sub:15]（F1 复现步骤与 mock 法） | mock 404/000 → verdict 失败+exit≠0；mock 200 行为不变；既有 18 断言不减弱；bash -n 过 | 15min | pending | sonnet-1 | plans/task-v138/subagent-state/16-executor-f1-fix.md |
| S2 | worktree 内全量 selftest 回归+F1 mock 负向复验 | code-runner-agent | plans/task-v138/task_plan.md（VC-5 口径；基线 53 脚本 @fed4393 实测） | 逐脚本 Total 行 FAIL=0；mock 404/000 咬合复验 | 15min | pending | mini | plans/task-v138/subagent-state/17-code-runner-f1-regression.md |

### Phase 5: 终验合并、部署与簿记（范围更新 2026-10-05：合并回已由并行会话完成于 1992566，本会话承接 fix 合并+三宿主部署+land 55）
- **V-N:** VC-5, VC-6
- **Status:** complete（2026-10-06：merge 1992566[他会话]+5ed69e7[fix]；三宿主 sha256 对账一致 9fb898f9333a；land 55 ts 2026-10-06；INDEX 刷新；worktree/分支清理完成）
- **Executor:** 主进程（白名单① 纯 git/worktree 编排 + 白名单② 计划系统文件维护/ledger 簿记）
- 步骤：worktree 内 Phase 产物逐 Phase commit（Rule 27）→ `smart-merge-back.sh --deploy` → 三宿主逐位 IDENTICAL 对账 → 编号账本 55 land 一行 + `plans/INDEX.md` 簿记 → `git worktree remove` + `git branch -d wt/task-v138`（Rule 11.3⑤）→ 合并后 Read 复验 critical-rules.md 尾段 + capability-registry.md → 终验 VC-GATE + Code Review Gate

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号②③：额外 worktree `wt/task-v136`（@4bca3dd，Rule 54 reserved 未实施）与 `wt/task-v134`/`wt/task-v135` 周期在途；信号①：主仓 plans/ 簿记类未提交变更与本任务 scope 零重叠） |
| `isolation` | `worktree`（实现类默认首选；改动含 skills/** 保护区 = 宪法 §十一 11.1 第 1 款命中） |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v138` |
| `branch` | `wt/task-v138`（基于 `master@078c683`） |
| `merge_back` | `pending` |

> 契约详见 `skills/task-planner/references/worktree-isolation.md`。冲突预期：v136/v134/v135 同期合入 critical-rules.md 时为「同区域尾部追加」，hunk 级手工合流 + 全量回归。

## 📊 FMEA 预演（规划期，RPN>100 必填兜底）
| Phase | 失败模式 | S | O | D | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---|---|---|-----------|---------------------------------------------|
| Phase 1 | Agnes 无公开额度直查端点，官方文档+OpenAI 兼容 billing 端点均不可得 → 无脚本可写 | 7 | 5 | 6 | 210 | **22.3 ② 拆细 + ④ 主进程接管裁决**：脚本落盘为「错误处理已验证 + 端点待确认」形态，V2 判 **PARTIAL** 显式登记，禁止伪造直查成功（design-brief §3.3 兜底条款） |
| Phase 1 | 探针探到可写端点但触发真实额度消耗或风控 | 8 | 3 | 5 | 120 | **22.3 ① 改派/换策略**：立即停止后续探针，只保留已落盘的响应证据；改走文档路线，README 明示「端点待确认」 |
| Phase 2 | Rule 55 追加位置错误（在 53.5 之前插入或误改既有条款语义）→ 锚级联 FAIL | 6 | 4 | 4 | 96 | （RPN≤100，留空；执行体 S1 验收命令含 `git diff` 纯增行零删行硬判） |
| Phase 2 | SKILL.md 行数钉（selftest-knowledge-brief T2b）被追加打破 → 全量回归 FAIL | 6 | 6 | 3 | 108 | **22.3 ③ 降档拆细**：S2 内先测行数钉再改；触钉则同任务上调上限并注明 task 代号（先例：≤523 task-v071 → ≤540 task-v074），禁留给 Phase 4 收尾 |
| Phase 3 | 脚本硬编码密钥 → 安全事件 | 10 | 2 | 6 | 120 | **22.3 ④ 主进程接管 + D6 硬停点**：立即 STOP 报告用户，脚本作废重写；`grep -icE 'sk-[a-z0-9]'`=0 为放行硬条件 |
| Phase 3 | 新 selftest 误触既有脚本断言行 → 既有守卫碎 | 7 | 4 | 4 | 112 | **22.3 ② 拆细**：新断言独立成脚本、`git diff --stat` 既有 selftest 零改动为验收硬条件；触线即回滚该行 |
| Phase 4 | 合并期 v136 已推进 master 造成冲突 | 6 | 4 | 5 | 120 | **22.3 ④ 主进程接管**：hunk 级手工合流（两任务均为文件尾追加）→ 冲突解后必跑全量回归（VC-5） |
| Phase 4 | 子代理自报 selftest 总数 ≠ 实测 | 5 | 7 | 4 | 140 | **22.3 ① 改派**：总数以主进程逐脚本 Total 行求和为准（VC-5 已固化该口径），子代理自报数不采信 |
| Phase 5 | 三宿主部署漂移（部署位在途被其他会话写入） | 7 | 3 | 4 | 84 | （RPN≤100，留空；--deploy fail-closed exit 6，DRIFT 即停并报告） |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）
| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 设计权威源 | task-v138 设计简报（需求 R 行 + 条款骨架 + Phase/VC 骨架 + 风险） | `/mnt/data/dev/task-planner-skill/plans/task-v138/design-brief.md`（2026-10-05） | 必读 | ☑ |
| 规范/标准 | Rule 55 落点文件的既有范式（Rule 52/53 块结构 + 53.5 尾行） | `skills/task-planner/references/critical-rules.md:574-593`（593 行 @078c683） | 必读 | ☑ |
| 官方文档 | Agnes API 文档（额度端点候选来源） | `~/.zcode/skills/agnes-ai-generation-skill/references/api.md`（2026-10-05 读）+ `https://wiki.agnes-ai.cn`（Phase 1 联网核实） | 必读 | ☑（本地已读；线上待 Phase 1 S1） |
| 项目内部文档 | selftest 脚本范式 + registry.tsv 列格式 | `skills/task-planner/scripts/selftest-veto.sh`、`scripts/selftest-registry.tsv:1-3`（52 行） | 必读 | ☑ |
| 项目内部文档 | 同款计划先例（Phase Status 行式 + S-unit 表式） | `plans/task-v137/task_plan.md`（已合并 @4bca3dd） | 参考 | ☑ |
| 项目内部文档 | 密钥来源函数（禁硬编码依据） | `~/.zcode/skills/agnes-ai-generation-skill/scripts/agnes_api.py`（`get_api_key()`） | 必读 | ☐（Phase 1 S2 前置确认行号） |
| 台账 | Rule 编号账本（46-53 landed / 54 reserved → new_rule=55） | `plans/.rule-reservations.jsonl`（13 行 @078c683） | 必读 | ☑ |

## ⚠️ 核心问题定义
**核心问题**: 「高频可复用操作每次现场发明方法、产出错误结果且方法不沉淀」——能否用一条可机器守护的执行纪律（Rule 55）+ 固定落点资产，让「第一次正确执行」成为「永久可复用」？
**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？→ 能：条款 + 注册表 + 首个脚本 + 执行体接线 + 守卫五件套齐备即交付
- [x] 核心问题不解决，其他工作都白费吗？→ 是：只补脚本不立纪律则下个会话重演（R2 实证）
- [x] 核心问题的解决方法是清晰的、可执行的？→ 是：design-brief §3.1/§3.2 已定稿骨架与落点

## Current Phase
（全部 Phase complete — 终验 COMPLETE 2026-10-06）

## Next Step
无（交付完成；delivery-summary 已出）

## Key Questions
1. Agnes 是否存在公开的剩余额度直查端点？（决定 V2 走 PASS 分支还是 PARTIAL 兜底分支）
2. 额度是否为账户级（决定 image-generation-executor 是否对称接线）？
3. `SKILL.md` 行数钉与 `Rules 1-N` 字样在既有 selftest 中的断言位置？（决定 Phase 2 S2 是否需同任务上调上限，避免锚级联）
4. v136（Rule 54）在 Phase 5 前是否已推进 master？（决定合并冲突处置方式）

## Decisions Made
| 时间 | 决策 | 依据 |
|------|------|------|
| 2026-10-05 | `new_rule: 55`（不占 54） | 编号账本 `plans/.rule-reservations.jsonl` 46-53 landed、54=task-v136 reserved 未落地（Rule 20.6 预留后取号规则） |
| 2026-10-05 | **silent**: 交互模式取 silent，不向用户询问非 D6 级选项 | Rule 28 silent 模式 + 用户指令明确；D6 硬停点（连续失败/漂移 BLOCKED/破坏性操作）语义不变 |
| 2026-10-05 | **silent**: 端点探测取「GET 只读探针 ≤3 个」为默认选项，无需用户确认 | Rule 41.2 四门槛外=代理可判（有客观判据 + 可逆 + 最小探针原则 35.6 已限定爆炸半径） |
| 2026-10-05 | **silent**: 额度不可得时不伪造直查成功，走「错误处理已验证+端点待确认」形态并判 PARTIAL | Rule 43.1 未验证登记 + design-brief §3.3 兜底条款 + Rule 51.8 未测试不声称完成 |
| 2026-10-05 | **silent**: Phase 3 三 S-unit 串行（parallel_groups=[]） | Rule 21.4 未声明并行组=串行；S2/S3 与 S1 存在文件集/验收依赖 |
| 2026-10-05 | `code_review: required` | 改动含 2 个 bash 脚本（密钥读取 + 网络调用），非纯文档任务 |
| 2026-10-05 | image 执行体对称接线条件化处理 | 额度若为账户级则两执行体对称接线；仅视频级则只改 video 并在 findings 登记理由（design-brief §3.2 第 6 项） |
| 2026-10-05 | **silent**: 探针协议三次演进（key 候选链→鉴权控制组→日期参数核验）均为错误驱动的方法修正而非范围扩展，按 Error Log 登记，不另立选项分叉 | Rule 41.2 门槛外 + 客观判据可逆（只读 GET）+ Rule 44.2 低区分度直接裁决 |
| 2026-10-05 | **silent**: Phase 1 定论=「billing 端点存在但计费层未填充」→ 脚本规格=直查+如实呈现+显式判定行+禁二次推算；终验按计划 PARTIAL 分支登记（端点待确认→计费层未填充） | Rule 43.1 未验证登记 + 51.8 未测试不声称完成 + design-brief §3.3 兜底 |
| 2026-10-05 | **silent**: 授权既有 selftest 纪元断言同步（RR-09/RR-16/R-09/SR-08 四条：`1-53`/`40-53`→`1-55`/`40-55`），执行范围表增补该 3 文件 | 计划 KQ3 预判+FMEA「锚级联」兜底行+v117「口径扩展非回退」判例；断言强度不减弱仅跟踪新纪元；SKILL 全集 1-53→1-55 的合法演进使旧断言必然 FAIL，不同步=VC-5 永不可过 |
| 2026-10-05 | **silent**: B 类扩展登记 Phase 4b（F1 fix-phase）——并行会话已合并 wt/task-v138（1992566）且 v139 已落（fed4393），修复面切最新 master 新 worktree wt/task-v138b；Phase 5 范围更新=合并回已发生，本会话承接 fix 合并+三宿主部署（他会话未做）+rule 55 land | 用户新指令处理 B 类（先重规划再执行）+Code Review Gate CHANGES_REQUESTED→fix-phase 契约 + 多会话 live race 事实（v124/v129 判例） |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| P1 探针三连缺陷：env key 失效→CDN 缓存态冒充鉴权 200→死 key 跑假设组致误判「不可得」 | 3 | 逐波修正：key 候选链→鉴权控制组（/agnesapi bogus-id）+强制绕缓存→日期参数核验；终得 HIGH 定论 | 详见 progress.md Error Log 3 行（key 解析落盘=Rule 55.3 立法对象；缓存态观测≠鉴权证据=55.2 同构判例） |

## Notes
- 全部改动为**文件尾纯增量**（Rule 36.5）；唯一例外=SKILL.md References 表 critical-rules 行内改写「含 Rule 53」→「含 Rule 55」（禁净删，已在执行范围表登记）
- 每完成一个 S-unit 立即回填 progress.md + findings.md（Rule 19.1/19.2），不等 Phase 结束
- Phase 5 合并前必查 `wt/task-v136` 是否已推进 master（冲突预期=同区域追加）
- 计划文档留在主仓 `plans/task-v138/`（CWD 不迁移），实现在 worktree 内进行

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |          |        |      |

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ | 2026-10-05 | 计划创建时同步建立 |
| Phase 2 | ☐ |  |  |
| Phase 3 | ☐ |  |  |
| Phase 4 | ☐ |  |  |
| Phase 5 | ☐ |  |  |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 4 / 5（Phase 1-4 全部子代理执行；计划撰写由主进程直做=白名单②计划系统文件维护） |
| 主进程直做 Phase 清单 | Phase 5（白名单① git 编排 + 白名单② ledger/INDEX 簿记） |
| 委派率 | 0.8（4/5 Phase ≥ delegation_rate_floor 0.7；主进程直做理由命中 Rule 25.3 白名单①②） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注 |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------|
| 1 | 2026-10-05 | plan-writer(provider 拒→general-purpose 改派 22.3①) | 撰写 task-v138 计划与知识简报 | done | task_plan 271 行+brief 109 行，8/8 PASS；台账定数已入 brief §2/§3 | task_plan.md 全文+brief §2 | —（plan 期） | subagent-state/01-plan-writer.md | 22.3① 判例 v127 |
| 2 | 2026-10-05 | web-search-agent(provider 拒→general-purpose 改派 22.3①) | P1-S1 额度端点文档调研 | done | 官方文档穷举 26 页：无额度直查端点；额度仅仪表板暴露；402/429 事后推断 | findings.md:22-49 | findings [sub:02] | subagent-state/02-web-search-quota.md | mini 档 provider 拒 |
| 3 | 2026-10-05 | executor | P1-S2 端点只读探针 | partial | 3 探针全 401；控制组失败→key/网络问题未定论；env key 与 .bashrc 现役 key 不一致 | findings.md [sub:03] | findings [sub:03] | subagent-state/03-executor-endpoint-probe.md | 重试=S2b（key 候选链） |
| 3a | 2026-10-05 | executor | P1-S2b 探针重试（key 候选链） | done（判定被复核证伪） | 自报「不可得（穷尽）」；主进程 Read 复核发现控制组 200 全为 CDN 缓存态+假设组误用死 key → 判定不可采信 | findings.md [sub:04] | findings [sub:04] | subagent-state/04-executor-endpoint-probe2.md | 判例入 Error Log #2 |
| 3b | 2026-10-05 | executor | P1-S2c 第三波（鉴权控制组+绕缓存） | done | bashrc key 校准通过（伪 key 401/真 key 404）；billing 端点族 200 存在 | findings.md [sub:05] | findings [sub:05] | subagent-state/05-executor-endpoint-probe3.md | 推翻 S2b 定论 |
| 3c | 2026-10-05 | executor | P1-S2d 收尾波（usage 日期参数） | done | 两日期窗逐字节相同 total_usage=0 + limit=1e8 占位 → 端点在、计费层未填充 | findings.md [sub:06] | findings [sub:06] | subagent-state/06-executor-endpoint-probe4.md | HIGH 置信定论 |
| 4 | 2026-10-05 | executor | P2-S1 critical-rules 追加 Rule 55 | done | +13/-0 纯增量，六子条+判例锚+交叉引用实证（54.1 预留状态标注）；主进程 Read 复核条款全文通过 | worktree critical-rules.md:594-606 | findings [sub:07] | subagent-state/07-executor-critical-rules.md |  |
| 5 | 2026-10-05 | executor | P2-S2 SKILL.md 索引三处联动 | done（带锚级联登记） | +4/-3 零净删 479 行；3 selftest 4 条纪元断言 FAIL 登记 | worktree SKILL.md:9/:267/:308/:332 | findings [sub:08] | subagent-state/08-executor-skill-index.md | 级联按 KQ3 处置 |
| 5a | 2026-10-05 | executor | P2 修复：纪元断言同步 | done | RR-09/RR-16/R-09/SR-08 同步 1-55/40-55+负断言并入 53；4 脚本自测 FAIL=0 | worktree 3 脚本 diff | findings [sub:09] | subagent-state/09-executor-epoch-sync.md | Decisions silent 授权 |
| 5b | 2026-10-05 | executor | P2 修复：SKILL 行数钉同步 | done | skill-split ≤478→≤490 带标注；41/41 FAIL=0；兄弟钉扫描无漏网 | worktree selftest-skill-split.sh:1 行 | findings [sub:10] | subagent-state/10-executor-pin-sync.md | v109 教训消费 |
| 6 | 2026-10-05 | executor | P3-S1 能力脚本 + 注册表 | done | agnes-quota.sh 185 行实跑通过+退出码实测；registry 首条 8 列；主进程 Read 复核两文件通过 | worktree scripts/capabilities/agnes-quota.sh + references/capability-registry.md | findings [sub:11] | subagent-state/11-executor-capability-script.md | 规格=11-prompt-spec.md |
| 7 | 2026-10-05 | executor | P3-S2 执行体 SOP 接线 | done | video/image 各 +1 行对称接线；首行 md5 不变；仅增不改 | worktree companion/agents/ 两文件 | findings [sub:12] | subagent-state/12-executor-sop-wiring.md |  |
| 8 | 2026-10-05 | executor | P3-S3 selftest 守护 + tsv 登记 | done | 18 断言全 PASS+/tmp 负向副本 FAIL=16 验证咬合力；tsv 53 行；veto/media-dispatch/registry 回归全绿 | worktree selftest-capability-persistence.sh + selftest-registry.tsv | findings [sub:13] | subagent-state/13-executor-selftest.md | 规格=13-prompt-spec.md |
| 9 | | code-runner-agent | P4-S1 全量回归（52 脚本） | queued | | | | | - / 0 / ☐ |
| 10 | | code-quality-review | P4-S2 代码面审查 | queued | | | | | - / 0 / ☐ |
| 11 | | alignment-review | P4-S3 对齐审查收尾 | queued | | | | | - / 0 / ☐ |

## 🔁 模板感知
<!-- template_type: rule-enhancement -->
<!-- task-v096 P2-S1: 运行时追加区块（非模板本体）; general=类型空缺兜底, 已知 16 类类型不产生本区块;
     上方注释行为 check-template-type 第三形态机读标记（general 恒合法, gate exit 0）, 同时完成 Rule 34.3② 预登记 -->
- 触发信号: 本任务命中**既有** variant（`templates/variant/rule-enhancement-type.md`，template_type: rule-enhancement），非类型空缺兜底
- Rule 34.3② 沉淀预登记 —— **无需新沉淀**：Rule 34.3 三条件（同类第 2 次触发/类型空缺可泛化/用户点名）均未命中；本任务 = 既有 variant 第 N 次复用（Rule 50 task-v127 / Rule 51 task-v129-133 / Rule 53 task-v131 均同款），按 34.3①「已有模板直接复用」处置
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: **不沉淀理由** —— 已命中既有 `rule-enhancement-type.md`，复用即可满足需求，禁冗余建新 variant