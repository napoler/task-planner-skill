# Task Plan: Rule 48 交付总结可定位性与实用性（delivery-summary 实用化）
<!-- template_type: rule-enhancement -->
<!-- 沉淀出处: task-v123（2026-10-03 用户指令原话：「当前的完成任务后的展示总结存在严重的缺陷 比如 让人审查接下来做什么时候 竟然不包含 审查内容路径或者网址 让人完全不知道到哪里审查 类似 的缺陷不一一列举 我希望的是完成总结可以更加实用」） -->

<!-- plan_tier: standard -->
<!-- execution_lane: L1（新 Rule 条款，38.7 明示「首个新 Rule 条款不适用 L0」） -->
<!-- 编号协调（D5）: Rule 47 已被并行会话 task-v122（媒体制作任务派发纪律，2026-10-03 在途）占用 → 本任务取 Rule 48；1-4[5-9] 预扩窗口（v121）内两编号均零守卫级联；合并乱序安全（critical-rules.md 块级追加 + SKILL 同区行按 46/47/48 序合并） -->
<!-- [2026-10-03 ENOSPC 事故重建] 本文件于 14:40 因磁盘满被非原子写截断为 0 字节，14:45 由主进程按会话记录完整重建（原文逐段回放：初始 Write + 全部已应用编辑）；重建后重跑 attest；事故归因见 progress.md Error Log -->

## Goal
落地 Rule 48「交付总结可定位性与实用性」：交付总结模板升级（定位栏 + 可定位性硬规则/反模式对照 + §3 快速复核入口 + §5 行动项定位三要素）+ SKILL 终验段联动（4 处行内替换，净增 0 行）+ selftest TL-22/23/24 静态守护 + 全新独立子代理样例实证，零新 config 键，全量 selftest 0 FAIL 后合并回 master 并部署 3 实体位。

**解决的用户诉求（原话）**：「当前的完成任务后的展示总结存在严重的缺陷 比如 让人审查接下来做什么时候 竟然不包含 审查内容路径或者网址 让人完全不知道到哪里审查 类似 的缺陷不一一列举 我希望的是完成总结可以更加实用」

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含 .sh selftest 扩展面；代码文件仅 1 个且 <50 行 → 轻 diff 单轮轻量审查） |
| `session_id` | `fe0e5590357e4f39ad6f2dcb4909c7ae` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v123` |
| `scope_files` | `templates/delivery-summary.md, SKILL.md, references/critical-rules.md, scripts/selftest-template-lifecycle.sh` |
| `interaction_mode` | `ask` |
| `对齐审查` | `[登记]` 终验前跑 alignment-review（42.6.2 标准收尾）；模板/条款/SKILL/守卫四面同步核对（42.6.1） |
| `自动超时默认项` | 本计划唯一 2+ 选项询问点=计划批准（默认=批准，超时 5 分钟按推荐自动执行并登记自动裁决五要素，44.3）；D2/D3/D4【Rule 36.4 逐项确认项】随批准逐项生效 |
| `质量审查工具` | review-library 池成员 `code-quality-review`（42.2 四级检测：项目级无 → 用户级/review-library 命中，Code Review Gate 承载，轻 diff 单轮） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 模板升级落地：delivery-summary.md 含 ①定位栏 ②可定位性硬规则（Rule 48）+反模式对照表 ③§3 快速复核入口 ④§5 行动项定位三要素 ⑤§1 行为面变化/§4 待裁决对象定位 锚；五区块计数保持 =5（TL-19 复跑 PASS） | grep 逐锚 + `grep -cE '^## [1-5]\.'` =5 + TL-19 复跑 | `templates/delivery-summary.md` / progress.md |
| VC-2 | SKILL.md 联动 4 处行内替换（:9 frontmatter 索引 1-46→1-48 / :158 终验段可定位性括注 / :247 规则枚举 / :305 References 行）且 `wc -l` 保持 444（T-主 断言 rc=0） | grep 4 锚 + `wc -l` + `bash scripts/selftest-skill-split.sh` rc=0 | SKILL.md / selftest 输出 |
| VC-3 | Rule 48 条款完整（`grep -cE '^48\.[1-5]'` ≥5；48.5 含零新键声明）+ 旧锚守卫不破（RT-08/PT-08/CD-12 三 selftest 单跑 PASS） | grep 锚 + 三守卫单跑 | `references/critical-rules.md` / selftest 输出 |
| VC-4 | 全量 selftest 回归 0 FAIL（**总数=主进程逐脚本 Total 行求和，禁采信子代理自报**；基线 43 脚本 676/0）+ TL-22/23/24 新断言含负向自检（缺锚 fixture 必 FAIL） | `for f in scripts/selftest-*.sh; do bash $f; done` 逐个求和 | progress.md Selftest Log |
| VC-5 | 独立验证：① 全新子代理按新模板以本任务真实内容撰写样例 `plans/task-v123/delivery-summary-sample.md`（审查类条目 100% 含对象定位）② 第二个全新子代理独立审计样例+四锚复验 PASS ③ alignment-review verdict=APPROVED | sample 逐条核对 + 审计报告 + alignment 输出 | `plans/task-v123/delivery-summary-sample.md` / subagent-state/ |
| VC-6 | 合并回 master（`--no-ff`，smart-merge-back 智能门）+ 部署 3 实体位 diff=0 + worktree/分支清理 + memory 簿记 | `smart-merge-back.sh <wt> --deploy` 输出 + `git worktree list` 空 | progress.md 合并段 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 模板 | `templates/delivery-summary.md`（升级：头部硬规则+定位栏+五区块定位要求；五区块数量不变） | 改五区块数量（TL-19 锚=5 保持）；删既有指引（纯增量） |
| 规则条款 | `references/critical-rules.md`（末尾追加 Rule 48 块） | 改既有规则语义（1-46 原文零改动） |
| SKILL | `SKILL.md`（4 处行内替换，**净增 0 行**，行位替换优先） | 大段新增；触碰行数定数 |
| selftest | `scripts/selftest-template-lifecycle.sh`（TL-22/23/24 追加 + 头注释同步） | 其他 selftest；新建脚本（registry 43 行零动） |
| 配置 | `config.json` 零改动（零新键——Rule 48 定性规则面，机器面挂既有静态守卫） | 动既有键 |
| 计划系统 | `plans/task-v123/**`（簿记/sample） | 其他 plans 目录（v122 并行会话产物禁触） |

**执行前自我检查**:
- [ ] 这个文件在上面的列表中吗？
- [ ] 这个修改对完成任务有必要吗？
- [ ] 用户明确要求我做这个修改吗？
- 全部 Yes → 可以执行 | 任一 No → 先问用户

**锚定级联预警（v117/v118 教训——改前先扫锚）**：
- SKILL.md 行数定数：`selftest-skill-split.sh:41` T-主 `≤444` —— 4 处编辑一律行内替换保零净增；P2/P3 完成即 `wc -l` 复核（P2 已完成 ✓ 444）
- Rule 编号：48 ∈ 1-4[5-9] 预扩窗口（v121）；禁止写「1-4x」字面（RT-08 零越界断言）；frontmatter「1-46→1-48」仍匹配 PT-08 宽容锚 `1-4[5-9]`
- 五区块计数：TL-19 `^## [1-5]\.` =5 —— 定位栏用 blockquote 不占 `## N.` 序号
- 并行会话 v122 同文件区：SKILL.md :9/:247/:305 与 critical-rules.md 尾区为双方共同编辑面 → 块级/行尾追加最小化冲突；合并遇到冲突按「46/47/48 序并存」解决（登记 FMEA）

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部 | 现行交付总结模板（46 行，五要素） | `templates/delivery-summary.md` | 必读 | ☑（规划期已读） |
| 项目内部 | 实际总结实例（缺陷证据） | `plans/task-v120/delivery-summary.md`（§5 无对象定位）、`plans/task-v112/delivery-summary-sample.md`（§4 待裁决无路径） | 必读 | ☑（规划期已读） |
| 项目内部 | 终验交付段+规则索引+References 锚 | `SKILL.md:9/:158/:247/:305` | 必读 | ☑（行号实测 2026-10-03 08:53） |
| 项目内部 | 守卫范式 TL-19/20/21 | `scripts/selftest-template-lifecycle.sh:20-24,90-96` | 必读 | ☑（规划期已读） |
| 项目内部 | 最近 Rule 块范式（45/46 写法） | `references/critical-rules.md` 末尾（L438-483） | 必读 | ☑（规划期已读） |
| 项目内部 | 部署/合并智能门（--deploy 对账语义） | `scripts/smart-merge-back.sh:348-470` | 必读 | ☑（规划期已读） |
| 项目内部 | 并行会话冲突面（Rule 47 在途） | `plans/task-v122/task_plan.md` Goal（Rule 47 媒体派发） | 必读 | ☑（规划期已读） |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 交付总结的「指向性信息」不可定位——指针用裸文件名（「见 verification.md」）、行动项无审查对象路径/URL（「实战观察 1-2 周」）、回滚/失效条件带未解析占位符；用户读完总结不知道去哪看、去哪审、怎么执行。

**核心问题判断**:
- [x] 核心问题解决后（模板硬规则 + SKILL 联动 + 静态守卫 + 样例实证），每条指针/建议可被用户直接打开或执行，总结从「叙事实」变为「可行动」
- [x] 核心问题不解决，形态缺陷将被复制到之后每一个任务的交付总结（模板是所有任务的消费源）
- [x] 解决方法清晰：可定位性硬规则（48.2）+ 行动项定位三要素（48.3）+ 模板/SKILL 落地 + TL-22/23/24 守护

**T1/T2 方法论答案**（Rule 45 衔接，落 findings.md）: 现象=总结不可定位；本质=模板只约定「写什么区块」未约定「指针长什么样」，且无守卫校验定位形态；方案=硬规则入模板+SKILL+守卫三层。

## Current Phase
**COMPLETE（2026-10-03 16:0x 终验通过：check-complete exit 0，VC-1..6 全过，outcome=COMPLETE）**

## Next Step
无——任务已交付。用户面总结=`plans/task-v123/delivery-summary.md`（chat 同出，新模板首用自示范）；遗留待裁决：ENOSPC 写前快照/原子写机制是否立项（登记于交付总结 §4）

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 Explore(mini) + code-runner-agent(mini) + 主进程 worktree 编排 | 普查=跨文件只读提炼；基线=机械批量执行；worktree git=白名单① |
| Phase 2 | Agent 子代理 executor(sonnet-1)×2 + code-assistant(haiku-1) | 模板/条款=判断型写作；SKILL 行内替换=机械小改（文件集互斥，声明并行组） |
| Phase 3 | Agent 子代理 code-assistant(haiku-1) + code-runner-agent(mini) | 守卫断言追加=机械范式复制；全量回归=机械执行（串行：S7 依赖 S6） |
| Phase 4 | Agent 子代理 4 路全新独立视角（CR/样例/审计/对齐） | 验证独立性（43.1/2026-09-26 裁决）；全判断型 |
| Phase 5 | 主进程（白名单①②③）+ smart-merge-back.sh | git 编排+部署对账+簿记（机械 diff 只读验证） |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件（用户未点名 /workflow；S-unit 链短且含同文件依赖，fan-out 收益低）→ 按 Rule 21.4 独立性守门调度
**/goal 对齐（Rule 40.3）**: 用户未使用 /goal 锚定；本计划 Goal+VC 即目标证据源，无需映射

## Phases

### Phase 1: 隔离与基线
- [x] worktree 建立（`/mnt/data/dev/task-planner-skill-worktrees/task-v123`, 分支 `wt/task-v123`，接 master b07c0cb；2026-10-03 09:41 建立）
- [x] S1 交付面缺陷普查（模板+3 实例+守卫锚+并行冲突面）——20/20 PASS，D1-D9 全确认
- [x] S2 全量 selftest 基线（43 脚本，改前）——43/43 rc=0，ΣPASS=676 FAIL=0
- [x] findings.md 回填普查结论与级联锚清单（B1-B4 + C 段）
- **V-N:** VC-4（基线面 ✓ 676/0@b07c0cb）
- **Status:** complete（2026-10-03 12:50；3-File gate exit 0；本 Phase 无 worktree 产物 → Rule 27 skip 理由=零仓内变更，porcelain 空）
- **Executor:** Explore（S1）+ executor（S2 **改派**——code-runner-agent mini provider 拒绝 ×1、fallback 无通道，Rule 22.3①）；worktree 建立=主进程（Rule 25.3 白名单①，git 编排）
- **parallel_groups**: [[S1, S2]]（声明可并行；**实执=串行**——串行槽锁机制拦截同批派发，锁 age<120s，登记 progress.md）
- **证据**: subagent-state/1-explore.md（20/20）+ subagent-state/2-executor.md（43/43，ΣPASS=676）+ findings B/C 段
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------------|-----------------------------|---------|------|------|
| S1 | 交付面缺陷普查：审计模板+3 真实总结实例+守卫锚，输出缺陷清单(path 级证据)与级联锚清单 | Explore(mini) | `plans/task-v123/findings.md`（普查要点v0）+ wt 技能树 4 目标文件 | 缺陷清单 ≥5 条带 file:line 证据 + 级联锚清单（行数定数/1-4x/五区块/TL/口径句） | 15min | complete |
| S2 | 全量 selftest 基线（43 脚本逐 Total 记录） | code-runner-agent(mini)→**改派 executor(sonnet-1)**（provider 拒绝） | wt:`scripts/selftest-*.sh` | 全部 rc 记录 + ΣPASS/ΣFAIL 原文 | 10min | complete |

### Phase 2: 规则落地（模板 + SKILL + Rule 48）
- [x] S3 模板升级（按 D2 定稿）——逐字节 VERBATIM_OK，六锚全命中，46→67 行
- [x] S4 SKILL.md 4 处行内替换（按 D4 定稿）——四锚命中，444 行保持
- [x] S5 critical-rules.md 追加 Rule 48（按 D3 定稿）——+10/-0 纯插入，48.1-48.5=5
- **V-N:** VC-1 ✓（S3 六锚+TL 21/21）、VC-2 ✓（S4 四锚+444+41/41）、VC-3 ✓（S5 子条 5+零键锚+RT/PT/CD 三守卫 9/32/24 全 PASS）
- **Status:** complete（2026-10-03 13:03；产物 commit **bd79190**（3 文件 +46/-15）；3-File gate exit 0）
- **Executor:** executor(sonnet-1)（S3/S5）+ code-assistant(haiku-1)（S4）
- **parallel_groups**: [[S3, S4, S5]]（声明可并行；实执=串行——串行槽锁机制，逐 S-unit 独立派发）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------------|-----------------------------|---------|------|------|
| S3 | 按 D2 定稿升级 delivery-summary.md（定位栏+硬规则/反模式+§1/§3/§4/§5 增强，纯增量） | executor(sonnet-1) | wt:`templates/delivery-summary.md` + `plans/task-v123/findings.md`（D2 定稿段） | 新锚 grep 全命中 + `^## [1-5]\.` 仍=5 + TL-19 单跑 PASS | 15min | complete |
| S4 | SKILL.md 4 处行内替换（:9/:158/:247/:305），净增 0 行 | code-assistant(haiku-1) | wt:`SKILL.md` + `plans/task-v123/findings.md`（D4 定稿段） | grep 4 锚命中 + `wc -l`=444 + T-主/SR 断言复核 | 8min | complete |
| S5 | critical-rules.md 末尾追加 Rule 48 块（48.1-48.5，含零新键声明） | executor(sonnet-1) | wt:`references/critical-rules.md`（Rule 46 范式）+ `plans/task-v123/findings.md`（D3 定稿段） | `grep -cE '^48\.[1-5]'` ≥5 + 48.5 零新键声明锚 + 既有 1-46 原文零改动 | 12min | complete |

### Phase 3: 守卫与回归
- [x] S6 selftest-template-lifecycle.sh 追加 TL-22/23/24 + 头注释同步（含负向自检）——21→24 全 PASS，三锚负向各有牙齿
- [x] S7 全量回归（43 脚本，主进程逐 Total 求和）——43/43 rc=0，ΣPASS=679 FAIL=0
- **V-N:** VC-4 ✓（679/0，主进程 bc 独立求和）+ VC-1 ✓（TL-22 三锚守卫在位）
- **Status:** complete（2026-10-03 15:06；产物 commit **ca7c741**（+10/-1）；3-File gate exit 0；ENOSPC 事故已恢复并登记）
- **Executor:** code-assistant(haiku-1)（S6）→ code-runner-agent(mini)（S7）（串行：S7 依赖 S6 产物；provider 拒绝则按 22.3① 改派 executor）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------------|-----------------------------|---------|------|------|
| S6 | 追加 TL-22（模板三锚）/TL-23（SKILL 括注锚）/TL-24（Rule 48 子条+零键锚）三断言 + 头注释 | code-assistant(haiku-1) | wt:`scripts/selftest-template-lifecycle.sh` + `plans/task-v123/findings.md`（TL 定义段） | 单跑 Total 全 PASS + 负向自检有牙齿（缺锚 fixture 必 bad） | 12min | complete |
| S7 | 全量 selftest 回归执行并输出逐脚本 Total | code-runner-agent(mini)→改派预案 executor | wt:`scripts/selftest-*.sh` | 全部 exit 0，总数主进程求和登记 progress.md | 10min | complete |

### Phase 4: 独立验证（CR + 样例 + 审计 + 对齐）
- [x] S8 Code Review Gate：wt diff 代码面（.sh）单轮轻量审查 → **APPROVED**（P0=0，负向可达性 4/4 独立复证）
- [x] S9 样例撰写（全新子代理，按新模板 + 本任务真实内容）——47 行，三要素 5/5，审查类含路径 2/2，零违规
- [x] S10 独立审计（第二全新子代理：样例逐条定位符核对 + VC-1/2/3 锚复验）——全 PASS + 反例三检查全 FAIL（区分度实证）
- [x] S11 alignment-review 对齐审查（四要素）→ **APPROVED**（P0=0）
- **V-N:** VC-5 ✓（样例 S9 + 审计 S10 + 对齐 S11 三件齐；CR S8 另证）
- **Status:** complete（2026-10-03 15:26；本 Phase 零 worktree 产物 → Rule 27 skip 理由=产物均在主仓 plans/ 与检查点，porcelain 空）
- **Executor:** executor(sonnet-1)（S8/S9/S11）+ executor（S10 改派：Verifier 档 provider 认证失败，Rule 22.3①）——4 路独立视角，执行期不参与前序 Phase 的撰写/编辑
- **parallel_groups**: [[S8, S9, S11]] 先行 → S10（依赖 S9 样例产物）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------------|-----------------------------|---------|------|------|
| S8 | CR Gate 轻 diff 单轮：审查 selftest-template-lifecycle.sh 变更面 | executor(sonnet-1) + Skill(code-quality-review) | wt:`scripts/selftest-template-lifecycle.sh` diff（`git diff master`） | verdict=APPROVED 或 CHANGES_REQUESTED 清单（后者走 fix 回路） | 12min | complete |
| S9 | 按新模板撰写样例 delivery-summary-sample.md（本任务真实内容；审查类条目必含对象定位） | executor(sonnet-1) | `plans/task-v123/findings.md` + wt 4 文件 diff | 五区块齐 + 每条建议含对象/看点/动作 + 零裸文件名 | 15min | complete |
| S10 | 独立审计：样例逐条定位符核对（审查类 100% 路径/URL）+ VC-1/2/3 锚独立复验 | **executor（改派：Verifier 档 provider 认证失败）** | `plans/task-v123/delivery-summary-sample.md` + wt 4 文件 | 审计报告 PASS/FAIL 逐项 + 反例构造（缺定位条目应被判定不合规） | 12min | complete |
| S11 | alignment-review 对齐审查：模板/条款/SKILL/守卫四面 diff↔意图 | executor(sonnet-1) + Skill(alignment-review) | wt 4 文件 diff + `plans/task-v123/task_plan.md` | verdict=APPROVED（P0=0）或处置清单 | 12min | complete |

### Phase 5: 合并回 + 部署 + 簿记
- [x] S12 冲突解决（B 类修订追加：`git merge master`，SKILL.md + critical-rules.md 冲突按「46/47/48 序并存」解决）——executor；主进程收口 merge 提交 b356bd5
- [x] 合并后全量回归（44 脚本）——44/44 rc=0，ΣPASS=688 FAIL=0（=679+MD9；主进程 bc 复核）
- [x] 部署前方向审计（3 位 ≡ master 基线 a183a99，diff 0 差异）×3 位
- [x] `smart-merge-back.sh <wt> --deploy`——master **5f250f8**（--no-ff）；3 实体位 ALL IDENTICAL（rc=0）
- [x] worktree/分支清理 + 主仓 Read 复验——`git worktree list` 仅主仓；wt/task-v123 已删（was b356bd5）
- [x] verification.md 回填 + `check-complete.sh` exit 0 + 交付总结（新模板首次自示范，chat 直出 + 落盘 `plans/task-v123/delivery-summary.md`）
- [x] memory 簿记 + INDEX/ledger + 计划档案入库
- **V-N:** VC-6 ✓, VC-5 ✓
- **Status:** complete（2026-10-03 16:0x；含 v122 合流 S12/S13）
- **Executor:** 主进程（例外理由: ① git/worktree 编排 ② 计划系统文件/簿记 ③ 机械 diff 验证——Rule 25.3 白名单）+ executor（S12 冲突解决 / S13 合流后回归）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号①：plans/ 未提交 6 项均不在本任务 scope；信号②③：并行会话 task-v122 活跃 worktree `wt/task-v122`（Rule 47 在途）与 SKILL.md/critical-rules.md 同文件区——块级追加+行尾追加最小化冲突，编号避让 48 解决） |
| `isolation` | `worktree`（§十一 11.1 条款 1 命中：修改 skill 源文件） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v123` |
| `branch` | `wt/task-v123` |
| `merge_back` | `pending` |

> 契约详见 `~/.zcode/skills/task-planner/references/worktree-isolation.md`。

## 📊 FMEA 预演（规划期 — references/methodology.md §R2）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 2 | SKILL.md 行内替换失误致 +1 行，撞 T-主 ≤444 定数 | 7 | 4 | 3 | 84 | 替换后立即 `wc -l` 复核（=444）；若不可避则按 v103/v112 级联先例同步上调定数并注明 task-v123 |
| Phase 2 | 模板升级破坏 TL-19 五区块=5（误加 `## 6.` 区块） | 6 | 4 | 3 | 72 | 定位栏用 blockquote；S3 完成前 `grep -cE '^## [1-5]\.'`=5 + TL-19 单跑 |
| Phase 3 | TL-22/23/24 负向无牙齿（恒 PASS 假绿） | 5 | 5 | 4 | 100 | fixture 缺锚必 FAIL 自检（v118 教训）；实现后现场构造缺锚输入实测 |
| Phase 4 | 审计发现模板规则歧义/样例不合规 | 4 | 6 | 3 | 72 | 回炉 S3 修订（计划内 fix 回路，重跑 S6/S7 相关子集） |
| Phase 5 | 部署位存在未收编前向更新被 --deploy 覆盖 | 8 | 2 | 3 | 48 | 部署前方向审计硬门（VC-6 前置）：diff ≢ 基线即 STOP 收编 |
| Phase 5 | v122 先合并致 SKILL.md 同区行/CR 尾区冲突 | 5 | 6 | 2 | 60 | 合并冲突按「46/47/48 序并存」解决；解决后 `wc -l`/grep 全线复验；冲突面登记 delivery-summary |
| 全任务 | 磁盘 ENOSPC 非原子写截断计划文件（2026-10-03 14:40 已发生一次） | 9 | 3 | 2 | 54 | 写前 `df` 余量检查（<50MB 预警）；重建事实源=会话记录；已按 R31 归因登记 |

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-03 12:50 | S2 同步（completed） |
| Phase 2 | ☑ | 2026-10-03 13:03 | S2 同步（completed） |
| Phase 3 | ☑ | 2026-10-03 13:04 | S2 同步（in_progress） |
| Phase 4 | ☑ | 2026-10-03 15:26 | S2 同步（completed） |
| Phase 5 | ☑ | 2026-10-03 16:0x | S2/S4 同步（completed；sync-todos --index 刷新 INDEX） |

> 契约详见 `~/.zcode/skills/task-planner/references/todo-sync.md`。

## Key Questions
1. 编号避让：为什么 48 不是 47？→ 47 被并行会话 task-v122 在途占用（2026-10-03 08:33 起，活跃中）；1-4[5-9] 预扩窗口内两者均零守卫级联；合并乱序安全（块级追加）；若 v122 终止 → 47 缺口登记由后续任务回填或重排
2. L0 精简模式是否豁免定位规则？→ 不豁免（48.1 明示：精简只降详略）；L0 本身不适用于本任务（38.7 新 Rule 条款排除）
3. chat 直出 vs 存证文件两形态？→ 同一模板规则；定位栏给出机器档案绝对路径，存证时该路径即指向落盘件
4. 与 Rule 43.1（证据先行）关系？→ 互补：43.1 管「声称有可复现证据」，48 管「指针可被用户直接打开/执行」；共享机器面=静态锚+独立复验
5. 为什么零新 config 键？→ 定性写作规则面，机器面=静态守卫（TL-22/23/24）+独立审计；对齐 39-46 零新键趋势

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| D1 新增 Rule 48 而非扩展 38.7 | 交付面是可独立成条的主题（45/46 范式）；38.7 是通道比例原则，挂载会造成类别错位 |
| D2【Rule 36.4 逐项确认项 1/3】`templates/delivery-summary.md` 升级：新增「定位栏」（blockquote，含机器档案/仓库/交付基线/部署位绝对路径）+ 头部「可定位性硬规则（Rule 48）」+ 反模式对照表 + §1「行为面变化」行 + §2 路径形态要求 + §3「快速复核入口」+ §4 待裁决对象定位/可执行回滚 + §5 定位三要素；五区块数量不变；全文见 `plans/task-v123/findings.md` D2 区（已实施 S3，commit bd79190） | 纯增量（既有指引零删除；区块要求换写为增强）；**计划批准即确认本项** |
| D3【Rule 36.4 逐项确认项 2/3】`references/critical-rules.md` 末尾追加 Rule 48 块（48.1 适用范围/48.2 指针形态硬规则/48.3 行动项定位三要素/48.4 复核回滚失效可执行/48.5 机制零新键+TL-22/23/24 守护声明）；全文见 findings.md D3 区（已实施 S5） | 纯增量追加，既有 1-46 原文零改动；**计划批准即确认本项** |
| D4【Rule 36.4 逐项确认项 3/3】`SKILL.md` 4 处行内替换：:9 frontmatter 索引「1-46→1-48」+ 规则名追加；:158 终验段尾追加「可定位性（Rule 48）」括注；:247 规则枚举「46→46/47/48」；:305 References 行尾追加 Rule 47/48 条目（已实施 S4） | 行内替换保零净增（不撞 T-主 444）；47 一并列入因 v122 在途（合并后连续）；**计划批准即确认本项** |
| D5 编号避让：47→48 | 并行会话 task-v122 已规划 Rule 47（媒体派发纪律）；编号先占先得，避让成本最低；乱序合并安全 |
| D6 执行通道 L1（非 L0） | 38.7 明示「首个新 Rule 条款不适用 L0」 |
| D7 零新 config 键 | 定性规则面；机器面=TL-22/23/24 静态守卫 + P4 独立审计；对齐 39-46 零新键趋势 |
| D8 样例+独立审计纳入 VC-5 | 用户诉求是「实用」——端到端样例是唯一能证明「审查类条目可定位」的证据（43.1 证据先行）；v112 样例先例 |
| 思路复述已呈示,2026-10-03 | Rule 28.2.1 ask 模式计划批准前口头复述大体执行思路（见会话） |
| **D1 自动裁决【Rule 44.3】**: 计划批准询问未获答复 → 按推荐默认项「批准，按计划执行」自动放行 | 五要素——超时值: 约定 5 分钟（询问发出后未答复即适用）；推荐项: D1 批准；触发时间: 2026-10-03 09:40；裁决理由: 用户指令明确（原始诉求直指本缺陷）+ worktree 隔离 + 独立验证兜底（D8）+ 全程可撤回（合并前零主仓写入）；被覆盖选项: 「不加新 Rule 编号」「暂停审计划」 |
| **ENOSPC 事故恢复决策**（2026-10-03 14:45） | task_plan/progress 被截断归零 → 按会话记录完整重建（唯一无损事实源）；重建后重跑 attest；不改变任务范围/VC；事故本身按 Rule 31 归因（progress Error Log）、失效面登记 FMEA |
| **B 类修订（2026-10-03 15:26）**: master 已前进（v122 a183a99 并入：Rule 47 + 44 脚本 + SKILL 447/T-主≤447）→ Phase 5 增补「先 merge master 解决同区冲突（按 46/47/48 序并存）+ 合并后全量回归（44 脚本，预期 ΣPASS=679+MD9=688）」 | 并行会话先落地（P2 观察项已预登记）；不改本任务 VC 口径，仅基线随合并上移；冲突解决规则=预登记 FMEA 行 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| ENOSPC 截断 task_plan.md/progress.md | 1 | 会话记录完整重建 + 重 attest（详见 progress.md Error Log） | → progress.md Error Log（Root Cause/Prevention 已填） |

## Notes
- 主进程写计划文件 = 白名单②（v118 先例）；规划期侦察已回填 findings.md（2026-10-03）
- dogfood：本任务的终验交付总结**自身**必须示范 Rule 48 全部要求（首个样板；落盘存证）
- 并行会话风险登记见「🔀 隔离决策」+ FMEA 尾两行；v122 产物（`plans/task-v122/**`、`wt/task-v122` worktree）禁触（§11.4）
- Rule 36 全链：36.2 归因✓（用户指令直指技能本体）/36.3 基线✓（P1 删除清单）/36.4 逐项✓（D2/D3/D4）/36.5 纯增量✓/36.6 回归✓（P3）
- **ENOSPC 事故（14:40）**：/mnt/data 瞬时 100%，非原子写截断两计划文件；findings/checkpoints/ledger/worktree（bd79190）无损；重建后继续（详见 progress）

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-03 P1 后 | ALIGNED | VC-4（基线面） | Phase 1 动作全在计划内（worktree/普查/基线/簿记）；wt porcelain 空、无计划外文件；偏差（改派/串行）已登记 |
| 2026-10-03 P2 后 | ALIGNED | VC-1/2/3 | 三文件落地与 D 定稿逐字一致（S3 cmp / S4 diff 复核 / S5 Read 复核）；无计划外文件；commit bd79190 仅 3 scope 文件；五守卫 127 断言全绿 |
| 2026-10-03 P3 后 | ALIGNED | VC-4 | S6/S7 全在计划内（21→24 断言、679/0）；commit ca7c741 仅 1 scope 文件；ENOSPC 事故与恢复已按 Rule 31 登记；无计划外文件 |
| 2026-10-03 P4 后 | ALIGNED | VC-5 | 四路独立验证全过（CR APPROVED/样例/审计/对齐 APPROVED）；偏移（S10 改派 executor、v122 已并入 master）均已登记；零 worktree 产物（porcelain 空） |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | **3 / 5**（P2/P3/P4 全子代理；P1/P5 主进程白名单直做）——check-delegation.sh stats JSON：phases_total=5, delegated=3, rate=0.600, violations=[], verdict=ok |
| 主进程直做 Phase 清单 | Phase 1（worktree 建立——白名单① git 编排；S1/S2 实为子代理）、Phase 5（① git/worktree 编排 ② 计划系统文件/簿记 ③ 机械 diff 验证——Rule 25.3 白名单） |
| 委派率 | 0.600 < 0.7 → **WHITELIST-EXEMPT 放行**（直做理由全命中白名单 ①②③，self_declared=0，violations 空）；S-unit 级 13 次派发（S1-S13，含 S2/S10 两改派）全部单一 S-unit 单目标 |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|---------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-10-03 09:43 | Explore | S1 交付面缺陷普查（模板+3 实例+守卫锚） | done | 20/20 PASS；D1-D9 全确认带 file:line；级联锚逐项判定（基线四锚成立/改动须保持）；联动面 examples/docs/companion 零命中 | findings.md B1-B3 段 | findings.md B 段 | plans/task-v123/subagent-state/1-explore.md | - / 0 / ☑（主进程抽查 :28/:39/:40/:43+v120:3 复核一致） |
| 2 | 2026-10-03 12:40 | executor（改派：code-runner-agent mini provider 拒绝 ×1，fallback 无通道，Rule 22.3①） | S2 全量 selftest 基线（43 脚本） | done | 43/43 rc=0；ΣPASS=676 ΣFAIL=0；抽查 template-lifecycle 21/21 一致；porcelain 空 | 检查点 2-executor.md 最终结论段 | Phase 1 基线段（findings C） | plans/task-v123/subagent-state/2-executor.md | - / 0 / ☑（主进程逐行求和+单脚本抽查+Read 检查点） |
| 3 | 2026-10-03 12:52 | executor | S3 模板升级（按 D2 定稿，纯增量） | done | 逐字节覆盖（sed 提取+cmp VERBATIM_OK）；六锚全命中；五区块=5；TL-19/20/21 单跑 21/21；仅 1 文件 M（+32/-11）→ 67 行 | wt:templates/delivery-summary.md:8-26,32,45-46,61-62 | findings D 段 | plans/task-v123/subagent-state/3-executor.md | - / 0 / ☑（主进程 Read 成品逐行复核） |
| 4 | 2026-10-03 12:57 | code-assistant | S4 SKILL.md 4 处行内替换（净增 0 行） | done | 四锚全命中；wc -l=444 保持；skill-split 41/41 rc=0；diff +4/-4 与 D4 逐字一致 | wt:SKILL.md:9,158,247,305 | findings D 段 | plans/task-v123/subagent-state/4-code-assistant.md | - / 0 / ☑（主进程 git diff 复核） |
| 5 | 2026-10-03 12:58 | executor | S5 critical-rules.md 追加 Rule 48 块（48.1-48.5） | done | +10/-0 纯插入（483→493）；48.1-48.5=5；48.5 零新键锚 L492；### 4x 计数 44/45/46/48 各 1 | wt:references/critical-rules.md:484-493 | findings D 段 | plans/task-v123/subagent-state/5-executor.md | - / 0 / ☑（主进程 Read 尾部复核） |
| 6 | 2026-10-03 14:55 | code-assistant | S6 TL-22/23/24 追加（含负向自检） | done | +10/-1；Total 21→24 全 PASS；三锚负向自检各有牙齿（fixture 缺「定位三要素」→TL-22 FAIL）；头注释三行同步 | wt:selftest-template-lifecycle.sh:25-27,100-105 | findings D 段 | plans/task-v123/subagent-state/6-code-assistant.md | - / 0 / ☑（主进程 git diff+重跑 24/24 复核） |
| 7 | 2026-10-03 15:00 | executor（改派：mini provider 拒绝先例——本会话早前轮次实证，Rule 22.3①） | S7 全量回归 43 脚本（预期 ΣPASS=679） | done | 43/43 rc=0；ΣPASS=679 ΣFAIL=0（=676+3 符合预期）；异常 1 例=final-gate-hash Total 行格式异类（非 FAIL，重试复现 rc=0）；porcelain 仅 S6 产物 | 检查点 7-executor.md 最终结论段 | findings D 段 | plans/task-v123/subagent-state/7-executor.md | - / 0 / ☑（主进程 bc 独立求和 679+Read 检查点） |
| 8 | 2026-10-03 15:08 | executor + Skill(code-quality-review) | S8 CR Gate 轻 diff 单轮（.sh 变更面） | done | **APPROVED**（P0=0/P1=0；P2×1 风格延续不阻断）；14 维度逐项过；负向可达性 4/4 独立复证；既有 21 断言零破坏；Total 24/24 | wt:selftest-template-lifecycle.sh diff（2 hunks +10/-1） | findings D 段 | plans/task-v123/subagent-state/8-executor.md | - / 0 / ☑（主进程核对 verdict+关键输出） |
| 9 | 2026-10-03 15:12 | executor（全新独立视角） | S9 样例撰写（按新模板+本任务真实内容） | done | 样例 47 行（5 区块+定位栏）；三要素 5/5；审查类含路径 2/2；零裸文件名/零占位符（自检修正 2 处）；如实标注进行中状态不虚构 merge hash | delivery-summary-sample.md | findings E 段 | plans/task-v123/subagent-state/9-executor.md | - / 0 / ☑（主进程 Read 逐行复核） |
| 10 | 2026-10-03 15:20 | executor（改派：Verifier 档 provider 认证失败，Rule 22.3①；保持独立审计视角） | S10 独立审计（样例逐条+锚复验+反例区分度） | done | 样例逐条核对全 PASS（5 条三要素/审查类 2/2/零违规）；VC-1/2/3 锚独立复验全 PASS（TL 24、T-主 41、RT 9、PT 32、CD 24）；反例三检查全 FAIL（有区分度实证） | 检查点 10-executor.md 里程碑段 | findings E 段 | plans/task-v123/subagent-state/10-executor.md | - / 0 / ☑（主进程核对结论） |
| 11 | 2026-10-03 15:16 | executor + Skill(alignment-review)（全新独立视角） | S11 alignment-review 四要素对齐审查 | done | **APPROVED**（P0=0/P1=0；P2×2 观察不阻断）；四要素全 PASS（diff↔D 定稿逐段一致/口径 444+5+2+35 不破/引用四锚实存/五守卫复证）；侦测到 master 已含 v122（Rule 47 块 L484 四子条） | 检查点 11-executor.md 里程碑段 | findings E 段 | plans/task-v123/subagent-state/11-executor.md | - / 0 / ☑（主进程核对 verdict） |
| 12 | 2026-10-03 15:30 | executor（B 类修订追加：master 合流冲突解决） | S12 解决 SKILL.md + critical-rules.md 冲突（46/47/48 序并存） | done | 5/5：0 冲突标记；SKILL=447；47 块与 master 逐字一致；CR 序 46→47(L484)→48(L496)；四守卫快检全绿（含 media-dispatch 9/9） | wt:SKILL.md +7/-4；wt:critical-rules.md +21/-0 | findings E 段 | plans/task-v123/subagent-state/12-executor.md | - / 0 / ☑（主进程复核+merge 提交 b356bd5） |
| 13 | 2026-10-03 15:42 | executor | S13 合并后全量回归（44 脚本） | done | 44/44 rc=0，ΣPASS=688 ΣFAIL=0（=679+MD9；主进程 bc 复核一致）；porcelain 空；HEAD=b356bd5 | 检查点 13-executor.md 最终结论段 | findings E 段 | plans/task-v123/subagent-state/13-executor.md | - / 0 / ☑（主进程 bc 求和+Read 检查点） |
