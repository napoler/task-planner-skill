# Task Plan: Rule 46 子代理单任务专注度（单会话单 S-unit + 守卫豁免收窄）
<!-- template_type: rule-enhancement -->
<!-- 沉淀出处: task-v118（2026-10-03 用户指令：单个子代理任务过于复杂致效率低下，要求单代理任务简单高效/禁一次性过多任务/保持专注） -->

<!-- plan_tier: standard -->
## Goal
落地 Rule 46「子代理单任务专注度」：单次子代理会话只领 1 个 S-unit（禁批次连做）+ check-dispatch 双豁免收窄（任务书场景 S-unit/步骤计数不失效）+ 拆分单一性引导 + 派发模板显式条款，零新 config 键，全量 selftest 0 FAIL 后合并回 master 并部署。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含 .sh 脚本 check-dispatch.sh） |
| `session_id` | `13ddd75014f14a92b7d4143f8cef3532` |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v118` |
| `scope_files` | `references/critical-rules.md, SKILL.md, templates/subagent_dispatch.md, scripts/check-dispatch.sh, scripts/selftest-dispatch-grain.sh(新建/既有锚扩展面)` |
| `interaction_mode` | `ask` |
| `对齐审查` | `[登记]` 终验前跑 alignment-review（42.6.2 标准收尾）；条款/守卫/模板三面同步核对（42.6.1） |
| `自动超时默认项` | 本计划询问点=计划批准（默认批准=继续，超时 5min 按推荐自动执行并登记）；其余无 2+ 选项询问点 |
| `质量审查工具` | 内置 code-review skill（42.2 四级检测：项目级无 → 用户级 code-review skill 命中，Code Review Gate 承载） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 46 条款完整落地（46.1-46.5 子条，范式对齐既有规则：子条=NN.M 动词短语，末条机制声明零新键+selftest 守护） | `grep -c '46\.[1-5]' references/critical-rules.md` ≥5 锚 | `references/critical-rules.md` |
| VC-2 | 守卫豁免收窄行为实测：① 任务书场景（prompt 含「任务书」+「subagent-state/」）任务书内容含 ≥2 个 S-unit ID → enforce 档拦截；② 任务书含 >step_max_steps 个行首 markdown 编号动作 → 拦截；③ 正常单 S-unit 派发（含任务书引用、单 S-unit、≤4 步）→ 放行不误伤 | 构造 3 个 fixture prompt 实跑 check-dispatch.sh 三档 | progress.md Test Results |
| VC-3 | 全量 selftest 回归 0 FAIL（**总数=主进程逐脚本 Total 行求和，禁采信子代理自报**） | `for f in scripts/selftest-*.sh; do bash $f; done` 逐个求和 | progress.md Selftest Log |
| VC-4 | SKILL.md 联动（Critical Rules 摘要行 + 委派检查点 2.5「单会话单 S-unit」措辞）+ 净增 ≤10 行 + 行数上限断言级联上调（label 注明 task-v118） | `wc -l SKILL.md` + grep 联动锚 + 行数断言复核 | SKILL.md / selftest 输出 |
| VC-5 | 合并回 master（--no-ff）+ 部署 3 实体位 diff=0 + worktree/分支清理 + memory 簿记 | `smart-merge-back.sh <wt> --deploy` 输出 + `git worktree list` 空 | progress.md 合并段 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则条款 | `references/critical-rules.md`（追加 Rule 46 块） | 改既有规则语义（锚定行号引用除外） |
| 守卫脚本 | `scripts/check-dispatch.sh`（豁免收窄 + 计数口径扩展） | 其他脚本 |
| selftest | `scripts/selftest-dispatch-grain.sh`（新建）+ 既有锚口径扩展（CD-12 等，按 grep 实测面） | 无关 selftest |
| 模板 | `templates/subagent_dispatch.md`（§1/§9 引导语） | 其他模板 |
| SKILL | `SKILL.md`（净增 ≤10 行：摘要行 + 2.5 措辞 + 索引行，行位替换优先） | 大段新增 |
| 配置 | `config.json` 零改动（零新键——Rule 46 挂既有 dispatch_contract_enforce 档位） | 动既有键 |

**执行前自我检查**:
- [ ] 这个文件在上面的列表中吗？
- [ ] 这个修改对完成任务有必要吗？
- [ ] 用户明确要求我做这个修改吗？
- 全部 Yes → 可以执行 | 任一 No → 先问用户

**锚定级联预警（v117 教训）**：改 check-dispatch.sh 与 critical-rules.md 行数/SKILL.md 行数必撞 CD-12（3=3 零余量）、RT-08/PT-08 等旧守卫——统一走「口径扩展非回退」范式（守卫登记同步扩容），两阶段间禁留回归 FAIL 窗口。

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部 | 最近规则块范式（Rule 44/45 写法） | references/critical-rules.md 末尾 | 必读 | ☑ |
| 项目内部 | 守卫现状三道门 + 双豁免 | scripts/check-dispatch.sh L255-355 | 必读 | ☑（调研已读） |
| 项目内部 | selftest 写法范式 | scripts/selftest-veto.sh | 必读 | ☑ |
| 项目内部 | 根因实证（v117 批次/v116 任务书） | plans/task-v118/findings.md Research Findings | 必读 | ☑ |
| 项目内部 | 守卫口径扩展范式 | task-v117（RT-08/CD-12/PT-08 三守卫 1-45 面扩展） | 参考 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 单个子代理任务过载（批次连做 9 S-unit + 任务书塞 6 类 23 处编辑）使守卫与拆分规则双双失效，子代理专注度与效率双降。

**核心问题判断**:
- [x] 核心问题解决后（单会话单 S-unit 条款 + 守卫豁免收窄 + 拆分单一性引导），子代理任务复杂度被三面钳制，结果能交付
- [x] 核心问题不解决，拆分规则形同虚设（v117 实证批次形态全绕过），其他优化白费
- [x] 解决方法清晰：条款（46.1-46.5）+ 机器（check-dispatch 收窄）+ 模板（引导语）三层落地

## Current Phase
**COMPLETE（2026-10-03 终验通过：check-complete exit 0，VC-1..5 全过，outcome=COMPLETE）**

## Next Step
无——任务已交付（机器档案=本目录四文件+subagent-state/，用户面总结=delivery-summary.md）

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 code-runner-agent(mini) + 机械守卫脚本 | selftest 基线是机械批量执行，mini 档足够；worktree git 编排主进程白名单① |
| Phase 2 | Agent 子代理 executor(sonnet-1)×2 + code-assistant(haiku-1) | 条款/SKILL 联动是判断型写作；模板引导语是机械小改 |
| Phase 3 | Agent 子代理 executor(sonnet-1)×2 串行 | bash 守卫逻辑改动判断型；同文件串行（21.4 文件集四问） |
| Phase 4 | Agent 子代理 executor(sonnet-1) + code-runner-agent(mini) | selftest 锚扩展判断型；全量回归机械执行 |
| Phase 5 | 主进程（白名单①②）+ smart-merge-back.sh | git 编排+部署对账+簿记 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件（用户未点名 /workflow；S-unit 链短且含同文件串行依赖，fan-out 收益低）→ 按 Rule 21.4 独立性守门调度（S2/S3 声明并行组，其余串行）
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即任务目标证据源；用户未用 /goal 锚定，无需映射

## Phases

### Phase 1: 隔离与基线
- [ ] worktree 建立（/home/terry/task-planner-skill-worktrees/task-v118, 分支 wt/task-v118）
- [ ] code-runner-agent 跑全量 selftest 基线（逐脚本 Total 求和记录）
- [ ] grep 确认锚定级联面（`grep -rn 'check-dispatch\|CD-12\|46' scripts/selftest-*.sh` 列受影响断言清单）
- [ ] findings.md 回填基线数字
- **V-N:** VC-3, VC-5
- **Status:** complete
- **Executor:** 主进程（例外理由: ① git/worktree 编排——Rule 25.3 白名单）+ executor 改派（code-runner-agent custom 端点 provider 拒绝 ×2，Rule 22.3① 改派）
- **证据**: subagent-state/1-code-runner.md（42/42 rc=0，ΣPASS=666 ΣFAIL=0）；findings.md 锚级联八锚清单

### Phase 2: Rule 46 条款 + SKILL 联动 + 模板引导
- [ ] S1 条款全文（46.1-46.5）追加至 critical-rules.md 末尾
- [ ] S2 SKILL.md 联动（Critical Rules 摘要行 + 委派检查点 2.5「单会话单 S-unit」+ 索引行，净增 ≤10 行）
- [ ] S3 派发模板 §1/§9 单 S-unit 引导语 + checkpoint 批次追加禁令
- **V-N:** VC-1, VC-4
- **Status:** complete
- **Executor:** executor（S1/S2）+ code-assistant（S3）并行组 [S2,S3]
- **证据**: commit e145555（3 files +16-4）；critical-rules.md L474-483；SKILL.md L9/L85/L247/L305；subagent_dispatch.md L17/L67；检查点 2/3/4-executor|code-assistant.md
- **parallel_groups**: [[S2, S3]]（S1 完成后放行；S2=SKILL.md, S3=subagent_dispatch.md 文件集互斥，输入各自独立）
<!-- 派发型 Phase S-unit 7 列表（22.6）；本任务自身消费新规则：每行=一次独立 Agent() 派发，禁合并 -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------------|-----------------------------|---------|------|------|
| S1 | 写 Rule 46 条款全文（46.1 单会话单 S-unit/46.2 守卫豁免收窄/46.3 拆分单一性/46.4 模板引导/46.5 机制零新键）至 critical-rules.md 末尾 | executor(sonnet-1) | wt:references/critical-rules.md（末尾 Rule 44/45 范式）+ plans/task-v118/findings.md（根因与条款草案段） | grep '46\.[1-5]' ≥5 锚且范式对齐（子条动词短语+末条机制） | 15min | complete |
| S2 | SKILL.md 三处联动：Critical Rules 摘要行加 Rule 46、委派检查点 2.5 补「单会话单 S-unit（Rule 46.1）」、References 索引行更新；净增 ≤10 行 | executor(sonnet-1) | wt:SKILL.md（Rule 22/25 摘要行 + 2.5 段）+ findings.md §条款锚（S1 定稿锚名） | grep 3 联动锚命中 + wc -l 净增 ≤10 | 12min | complete |
| S3 | 派发模板 subagent_dispatch.md §1 加「本会话只领本 S-unit，完成后交回主进程重派」+ §9 加 checkpoint 禁批次追加 | code-assistant(haiku-1) | wt:templates/subagent_dispatch.md（§1 L7-10 / §9 L58-71） | grep 两条引导语命中 | 8min | complete |

### Phase 3: check-dispatch.sh 守卫豁免收窄
- [ ] S4 守卫②收窄：任务书豁免场景不再整体 SKIPPED，改为解析 prompt 引用的任务书文件内容做 distinct S-unit ID 计数（≥2 命中）
- [ ] S5 守卫④口径扩展：任务书模式下行首 markdown 编号列表并入步骤计数（仅任务书文件内容；自由 prompt 保持原口径防误伤）+ 头注释同步
- [ ] 三档行为实测（VC-2 三 fixture）
- **V-N:** VC-2, VC-3
- **Status:** complete
- **Executor:** executor（S4→S5 串行，同文件）
- **证据**: commit（check-dispatch.sh +47/-9）；fixture 三态×2 全过；selftest-dispatch 31/0 + fine-grain-steps 11/0（主进程直跑复验）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------------|-----------------------------|---------|------|------|
| S4 | 守卫②豁免收窄：L297-301 任务书豁免改为对任务书内容 S-unit ID 计数（解析 prompt 中 subagent-state/ 路径 + 「任务书」关键字定位文件） | executor(sonnet-1) | wt:scripts/check-dispatch.sh（fine_grain_checks L275-355 + 头注释 L43-47） | fixture: 任务书含 S1+S2 → enforce exit 2；任务书文件缺失回退 SKIPPED 注释 | 15min | complete |
| S5 | 守卫④任务书模式纳入行首 markdown 编号口径（count_step_markers 加任务书模式参数；自由 prompt 不变）+ 头注释/档位说明同步 | executor(sonnet-1) | wt:scripts/check-dispatch.sh（count_step_markers L259-267 + 守卫④ L319-343） | fixture: 任务书 6 个 markdown 编号动作 → 命中；自由 prompt markdown 编号仍不入口径 | 15min | complete |

### Phase 4: selftest 守护 + 全量回归
- [ ] S6 新建 selftest-dispatch-grain.sh（三断言：条款锚 grep / 守卫②任务书计数 / 守卫④ markdown 口径）+ 既有受影响锚口径扩展（CD-12 等，按 Phase 1 实测清单）
- [ ] S7 全量 selftest 回归（code-runner 跑，主进程逐 Total 求和）
- **V-N:** VC-3, VC-1
- **Status:** complete
- **Executor:** executor（S6a∥S6b 并行组 → S7 → S6c 修复串行）
- **parallel_groups**: [[S6a, S6b]]（已执行，文件集互斥）
- **证据**: commit（5 文件）；S6a 9/9+registry 43 行；S6b 9/9+32/32 负向自检过；S7 全量 43 脚本 ΣPASS=674 ΣFAIL=1→S6c 修 CD-12 后 24/24 复验，折算全量 675/0
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------------|-----------------------------|---------|------|------|
| S6a | 新建 selftest-dispatch-grain.sh（断言：Rule 46 条款锚/守卫收窄标记/行为 fixture 三态）+ registry.tsv 登记 | executor(sonnet-1) | wt:scripts/selftest-veto.sh（范式）+ selftest-registry.tsv（行格式） | 新 selftest 单跑全 PASS + registry T02/T03 一致 | 15min | complete |
| S6b | 既有锚口径扩展：RT-08 白名单 1-45→1-4[56]、PT-08 字面锚宽容化 1-4[56]（v117 范式） | executor(sonnet-1) | wt:scripts/selftest-ask-default-timeout.sh:59-62 + selftest-plan-tier.sh:74-76 + findings.md 锚表 | 两 selftest 单跑 PASS（SKILL.md 已是 1-46 现实下） | 8min | complete |
| S7 | 全量 selftest 回归执行并输出逐脚本 Total | code-runner-agent(mini) | wt:scripts/selftest-*.sh | 全部 exit 0，总数主进程求和登记 progress.md | 10min | complete |
| S6c | CD-12 双锚 n45 1-45→1-4[56] 宽容化（S7 暴露的 v117 扩展断言失配） | executor(sonnet-1) | wt:selftest-conclusion-discipline.sh:67-72 | 24/24 PASS+负向自检有牙齿 | 8min | complete |

### Phase 5: 合并回 + 部署 + 簿记
- [ ] smart-merge-back.sh --deploy（合并 + 3 实体位部署对账）
- [ ] worktree/分支清理 + 主仓 Read 复验
- [ ] memory 簿记 + INDEX/ledger + 交付总结（五要素）
- **V-N:** VC-5, VC-4
- **Status:** complete
- **Executor:** 主进程（例外理由: ① git 编排 + ② 计划系统文件/簿记——Rule 25.3 白名单）+ Code Reviewer（CR Gate×2）+ executor（终验回归）
- **证据**: master df7e427；三部署位 0 差异；worktree/分支清零；alignment-review APPROVED；43/43 selftest 676/0

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号①：2 个未提交变更 = v116 遗留 `plans/task-v116/subagent-state/.dispatch-inflight` + 本计划目录 `plans/task-v118/`；均不在本任务 scope，无重叠不阻塞） |
| `isolation` | `worktree`（§十一 11.1 条款 1 命中：修改 ~/.zcode/skills/** 对应源仓技能文件） |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v118` |
| `branch` | `wt/task-v118` |
| `merge_back` | `merged(df7e427)` |

> 契约详见 `~/.zcode/skills/task-planner/references/worktree-isolation.md`。

## 📊 FMEA 预演（规划期 — references/methodology.md §R2）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 2 | SKILL.md 行数撞行数上限断言（skill-split:50 类） | 7 | 6 | 4 | 168 | ②拆细：净增行数压到行位替换；断言口径扩展（v117 范式，label task-v118） |
| Phase 3 | 守卫改动破坏既有正常派发（误伤） | 8 | 5 | 4 | 160 | ②拆细回退单豁免收窄 + fixture 回归三档实测；仍败 ③ 原逻辑降档保留新逻辑 warn 观察 |
| Phase 4 | CD-12 零余量守卫 3=3 撞新计数面漏改 | 7 | 7 | 3 | 147 | ②拆细：按 Phase 1 grep 清单逐锚扩口径非回退；仍败 ⑤ 带清单呈报 |

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  |  |
| Phase 2 | ☐ |  |  |
| Phase 3 | ☐ |  |  |
| Phase 4 | ☐ |  |  |
| Phase 5 | ☐ |  |  |

> 契约详见 `~/.zcode/skills/task-planner/references/todo-sync.md`。

## Key Questions
1. 守卫②任务书收窄后，任务书文件解析失败（路径在 prompt 中不可读）时如何处置？→ 回退 SKIPPED + 注释（fail-open 对齐既有 L281-284 范式），不新增硬失败面
2. 「单会话单 S-unit」与 21.4 并行组是否冲突？→ 不冲突：并行组 = 多个独立 Agent() 各领 1 S-unit；禁的是同一会话连领多个
3. 调研型复合 S-unit（v113/v115 形态）如何钳制？→ 46.3 拆分单一性（调研与产出分离，复合目标=拆两 S-unit），计划期 check-plan-dispatch 预估时长 SKIPPED 提示已有，加定性条款引导

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 新增 Rule 46 而非扩展 25.2 | 三根因横跨 Rule 21/22/25，独立规则主题统一（专注度）且索引清晰；对齐 v098-v104 演进惯例 |
| 零新 config 键 | 守卫行为挂既有 dispatch_contract_enforce 档位；对齐 Rule 39-44 零新键趋势 |
| 守卫②收窄保留 fail-open（任务书不可读→SKIPPED 注释） | 对齐既有 jq 缺失回退范式（L281-284），不新增硬失败面；豁免收窄仅覆盖可解析场景 |
| 本任务执行自身消费新规则（每 Agent() 单 S-unit） | 自示范（dogfood）：计划 S-unit 表每行=一次独立派发，Phase 2 的 S2/S3 声明并行组示范 21.4 |
| 思路复述已呈示,2026-10-03 | Rule 28.2.1 ask 模式计划批准前口头复述大体执行思路 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
|       | 1       |            | → progress.md Error Log   |

## Notes
- 本任务执行自身即为新规则的第一个消费者：所有 Agent() 派发一律单 S-unit 单目标，Handoff 每次派发独立登记
- 主进程写计划文件 = 白名单②；调研结论已回填 findings.md（2026-10-03 Explore 五面调研）

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-03 P1 后 | ALIGNED | VC-3,VC-5 | Phase 1 全动作在计划内（worktree+基线+锚清单），无范围外写入 |
| 2026-10-03 P5 后（终检） | ALIGNED | 全部 | CR fix-phase 属计划 Code Review Gate 内置回路；S6 拆 S6a/b 已落计划；交付范围=scope_files 全集，无越界 |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 5（Phase 2/3/4 全子代理执行 + fix-phase F1/F2 + CR×2 + 终验回归） |
| 主进程直做 Phase 清单 | Phase 1（① git/worktree 编排+改派后基线由 executor 承担）、Phase 5（① git 编排 ② 计划系统文件/簿记） |
| 委派率 | 0.6 <0.7 → WHITELIST-EXEMPT（直做理由均命中 Rule 25.3 白名单①②）；S-unit 级委派率 100%：16 次派发全部单 S-unit 单目标（Rule 46 自示范） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|---------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-10-03 | Explore | 五面现状调研（条款/守卫/模板/实证/variant） | done | 根因三层：批次连做主因+双豁免放大器+拆分粗次因 | findings.md Research Findings | Research Findings | n/a（一次性调研） | - / 0 / ☑ |
| 2 | 2026-10-03 | executor（改派，code-runner custom 端点拒） | Phase 1 selftest 基线 42 脚本 | done | 42/42 rc=0，ΣPASS=666 ΣFAIL=0 | subagent-state/1-code-runner.md:64 | Phase 1 基线段 | subagent-state/1-code-runner.md | - / 0 / ☑ |
| 3 | 2026-10-03 | executor | S1 Rule 46 条款写入 critical-rules.md | done | 10 行纯增量，46.1-46.5 全锚，禁字面归零 | wt:critical-rules.md:474-483 | Research Findings | subagent-state/2-executor.md | - / 0 / ☑ |
| 4 | 2026-10-03 | executor | S2 SKILL.md 四处联动 | done | 四处编辑在位，净增 0，SR-07 保持 | wt:SKILL.md:9,85,247,305 | Phase 2 段 | subagent-state/3-executor.md | - / 0 / ☑ |
| 5 | 2026-10-03 | code-assistant | S3 派发模板双引导行 | done | §1 L17+§8 L67 引导在位，净增 2 | wt:subagent_dispatch.md:17,67 | Phase 2 段 | subagent-state/4-code-assistant.md | - / 0 / ☑ |
| 6 | 2026-10-03 | executor | S4 守卫②任务书豁免收窄 | done | 三态 fixture 过+FG-05 保持，+27/-3 | wt:check-dispatch.sh:48-53,304-327 | Phase 3 段 | subagent-state/5-executor.md | - / 0 / ☑ |
| 7 | 2026-10-03 | executor | S5 守卫④任务书 markdown 口径 | done | 6>4 拦截实测+自由 prompt 不变，+20/-6 | wt:check-dispatch.sh:264-277,365-372 | Phase 3 段 | subagent-state/6-executor.md | - / 0 / ☑ |
| 8 | 2026-10-03 | executor | S6a 新建 dispatch-grain selftest+registry | done | 9/9 PASS，registry 43 行一致 | wt:selftest-dispatch-grain.sh | Phase 4 段 | subagent-state/7-executor.md | - / 0 / ☑ |
| 9 | 2026-10-03 | executor | S6b RT-08/PT-08 锚宽容化 | done | 9/9+32/32，负向自检有牙齿 | wt:selftest-ask-default-timeout.sh:63-65 | Phase 4 段 | subagent-state/8-executor.md | - / 0 / ☑ |
| 10 | 2026-10-03 | executor | S7 全量回归 43 脚本 | done | ΣPASS=674 ΣFAIL=1（CD-12 失配暴露） | subagent-state/9-executor.md:64 | Phase 4 段+Error Log | subagent-state/9-executor.md | - / 0 / ☑ |
| 11 | 2026-10-03 | executor | S6c CD-12 双锚宽容化修复 | done | 24/24 PASS+负向自检有牙齿 | wt:selftest-conclusion-discipline.sh:67-72 | Error Log | subagent-state/10-executor.md | - / 0 / ☑ |
| 12 | 2026-10-03 | Code Reviewer | 全量 CR wt/task-v118 diff | CHANGES_REQUESTED | BLOCKER=守卫②④提取器全角标点盲区（fail-open 绕过）+2 SUGGESTION+2 NIT | CR 报告（会话） | fix-phase 登记 | n/a | - / 0 / ☑ |
| 13 | 2026-10-03 | executor | F1 守卫修复（CR finding 1+2） | done | 全角形态 8 种提取全过+位限防幽灵计数，回归绿 | wt:check-dispatch.sh:285,298-302 | Phase 5 段 | subagent-state/11-executor.md | - / 0 / ☑ |
| 14 | 2026-10-03 | executor | F2 selftest 修复（CR finding 3/4/5） | done | GR-10 全角 fixture 过+RT-08 逐匹配粒度负向自检过 | wt:selftest-dispatch-grain.sh:131-140 | Phase 5 段 | subagent-state/12-executor.md | - / 0 / ☑ |
| 15 | 2026-10-03 | Code Reviewer | fix-phase 复审 | done(APPROVED) | 5 项销项+无回归+21 复跑全绿 | CR 复审报告 | Phase 5 段 | n/a（会话内报告） | - / 0 / ☑ |
| 16 | 2026-10-03 | executor | 终验全量回归 43 脚本 | done | ΣPASS=676 ΣFAIL=0 全绿 | subagent-state/13-executor.md | Phase 5 段 | subagent-state/13-executor.md | - / 0 / ☑ |
| 2 | | | | queued | | | | | - / 0 / ☐ |
| 3 | | | | | | | | | - / 0 / ☐ |
| 4 | | | | | | | | | - / 0 / ☐ |
| 5 | | | | | | | | | - / 0 / ☐ |
| 6 | | | | | | | | | - / 0 / ☐ |
| 7 | | | | | | | | | - / 0 / ☐ |
