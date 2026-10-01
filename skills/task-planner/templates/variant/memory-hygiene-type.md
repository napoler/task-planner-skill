<!-- template_type: memory-hygiene -->
<!-- 适用场景: 记忆体系盘点/整理/治理（MEMORY.md 索引 + topic .md 目录，如 ~/.zcode/cli/memories/projects/<project>/memory/） -->
<!-- 触发关键词: 记忆整理/记忆卫生/记忆过时/记忆偏见/强时效断言漂移/基线数字被替代 -->
<!-- 推荐 subagent: executor(fresh) 全量盘点 + verifier 抽验;主进程仅簿记(验证独立性铁律) -->

# Task Plan: [记忆整理任务名称]

<!-- plan_tier: standard -->
## Goal
[一句话:整理哪个项目记忆目录(路径),达成什么终态(每条 topic 有 4 维校验+处置结论,修正版先落计划目录抽验后才应用)]

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `对齐审查` | `[登记]` | Rule 42.6 消费：完成前跑 alignment-review;变更记录随交付落盘;mini 豁免 |
| `自动超时默认项` | `[询问点: 默认选项/超时值]` | Rule 44 消费：默认项+超时 5 分钟;低区分度 44.2 直接裁决;mini 豁免 |
| `质量审查工具` | `[检测结论]` | Rule 42 消费：42.2 四级检测登记;本类型默认 alignment-review;mini 豁免 |

**修改面声明**:记忆目录非 git 仓,本任务「修改面=模板/仓内文件(worktree)+记忆目录 topic 文件(dogfood 直改,修正版抽验兜底),无代码功能变更」。

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 索引层全量盘点 | MEMORY.md 逐行 Read(57 条口径按实测);每条 name/末次日期/声明状态提取 | `findings.md` 盘点表 |
| VC-2 | A 类(强时效断言)全读 4 维校验 | 逐条 grep/ls/git log 锚验证,证据 ≥10 字符 | `findings.md` A 类表 |
| VC-3 | 修正版产出契约 | 先写 `MEMORY.md.proposed`+整理报告(含原文留存节);主进程抽验 ≥5 条重跑命令复现通过后才应用 | `plans/<task>/` 抽验记录 |
| VC-4 | 删除零自动执行 | 全库 grep 处置表:删除类仅出现在「删除建议」节=仅建议,无已执行删除记录 | 整理报告 Read |
| VC-5 | 计数/锚级联自洽(涉及模板/文档面时) | 全库 grep 旧计数串零残留/新计数命中(按当次任务口径);gate 脚本 exit 0 | checkpoint+findings |
| VC-6 | 写入规范三要素(M5) | 新增/更新条目含绝对日期+可复现命令锚+失效条件,缺一=处置不成立 | topic 文件 Read 抽查 |

> **验证独立性铁律（延续 v108 用户 P0）**：全部验证由全新独立子代理执行；主进程仅编排/簿记/Read 结论。

**终验规则**:
- 全部 VC 通过 → COMPLETE
- VC-3 失败 = 修正版未抽验 → 禁止应用修正版,回 Phase 3
- VC-4 失败 = 发生自动删除 → P0 回滚+报告用户

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 记忆目录(只读盘点面) | `~/.zcode/cli/memories/projects/<project>/memory/**`(Read/grep/ls 盘点) | 盘点阶段直接改写 topic/MEMORY.md |
| 修正版产出面 | `plans/<task>/MEMORY.md.proposed` + `plans/<task>/memory-hygiene-report.md` | 未抽验前覆盖原 MEMORY.md/topic |
| 仓内模板/级联面 | worktree 内列明的模板/计数文件(按任务 Scope) | 级联面外任何改动 |

**强制约束**:
- 记忆目录盘点只读;修正版一律先落计划目录(MEMORY.md.proposed+报告),主进程抽验 ≥5 条证据(重跑命令复现)通过后由主进程应用
- 删除类处置**永不自动执行**(不可逆,交用户裁决);报告仅列「删除建议」节
- 每条处置必附验证锚(file:line 或命令→关键输出 ≥10 字符),缺一不成立

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

> 目的：对齐任务知识库。列出本任务依赖的记忆目录/规则条款/历史任务产物等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 记忆目录 | MEMORY.md + topic .md 全量 | `~/.zcode/cli/memories/projects/<project>/memory/` | 必读 | ☐ |
| 项目内部文档 | task-planner critical-rules 相关条款 | `skills/task-planner/references/critical-rules.md` | 参考 | ☐ |
| 历史任务产物 | 被引用锚点的 plans/verification 文件 | `plans/<task-id>/*.md` | 参考 | ☐ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（问题解构四问 — methodology.md T2）
1. **问题是什么**: [记忆目录哪些条目会被新会话盲信消费?量化=强时效断言条目数 N]
2. **本质是什么（5 Whys ≥5 层）**: [如:基线数字无失效条件→被后续任务替代后静默漂移→索引行与 topic 双源不同步→…]
3. **解决方案是什么**: [四态处置(verified/updated/stale-marked/删除建议)+修正版抽验契约+M5 三要素防再犯]
4. **执行方案是什么**: [Phase 1 盘点→Phase 2 处置→Phase 3 修正版产出→Phase 4 独立验证,门控点=VC-3 抽验]

## Current Phase
Phase 1

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
逐 Phase 登记工具面与理由;Executor 字段仍是委派门控机器事实源;mini 豁免
| Phase | 命中工具面 | 选择理由 |
|-------|----------|---------|
| Phase 1 | Agent 子代理 executor(fresh) | 57 条全量读取=大体量原料,隔离 context(§一) |
| Phase 4 | 独立 verifier + 机械 gate 脚本 | 验证独立性铁律;主进程仅簿记 |

## Phases

### Phase 1: 记忆目录盘点（只读）
- [ ] 全量 Read MEMORY.md,提取每条 name/末次日期/声明状态/遗留断言
- [ ] A 类(强时效断言)全读+4 维锚验证;B 类抽查 ≥8 条;C 类(历史教训)免检登记
- [ ] 盘点表(M1 列定义)落 findings.md
- [ ] 知识储备必读项已确认可获取(勾选「已确认」列)
- **Status:** pending
- **Executor:** executor（fresh）
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|

### Phase 2: 处置执行（四态+守门）
- [ ] 按 M3 处置枚举逐条定态:verified/updated/stale-marked/删除建议(仅建议)
- [ ] updated 条目:原文留存整理报告+更新点列表化;MEMORY.md 索引行同批刷新
- [ ] stale-marked 条目:加「[STALE <YYYY-MM-DD>: <失效条件>]」固定格式标注,不删原文
- [ ] 每条处置附验证锚(①file:line 或 ②命令→关键输出 ≥10 字符)
- **Status:** pending
- **Executor:** executor（fresh）
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|

### Phase 3: 修正版产出（抽验契约）
- [ ] 写 `plans/<task>/MEMORY.md.proposed`(索引行 ≤200 字符:任务名/末次日期/一句话状态/遗留 N 断言(有则)/验证戳 `[<task> <日期> 盘点 verified]`)
- [ ] 写 `plans/<task>/memory-hygiene-report.md`(含原文留存节+删除建议节)
- [ ] 主进程抽验 ≥5 条:重跑 M2 命令复现证据;topic 文件更新同契约(报告留存旧文)
- [ ] 抽验通过 → 主进程应用修正版;失败 → 回 Phase 2 重做该条
- **Status:** pending
- **Executor:** 主进程（例外理由:抽验/应用属主进程簿记面;重写条目仍派 executor）
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|

### Phase 4: 独立验证 + 级联自检
- [ ] 独立 verifier 子代理重跑 M2 抽样锚(≥3 条),复现输出入 checkpoint
- [ ] grep 全库计数级联自洽(任务涉及时,如 variant 17 口径)
- [ ] 删除建议节 Read 复核=零自动执行(VC-4)
- [ ] `Skill("task-drift-guard")` 终验
- **Status:** pending
- **Executor:** verifier（fresh）+ 主进程（例外理由:簿记与终验）

## 📋 记忆整理协议（本模板核心合约 — M1-M5）

### M1 记忆盘点表（逐条必填,列定义）
| 列 | 定义 | 示例 |
|---|---|---|
| name | topic 文件名(不含 .md) | task-v056-fine-grained-dispatch-plan |
| 类 | A(强时效断言,全读)/B(行为偏好,抽查)/C(历史教训,免检登记) | A |
| ①定位 | 引用锚实测结果(grep/ls→命中或未命中) | grep 21.4=7 命中 |
| ②时效 | 末次任务日期 vs 现状(基线被后续任务替代?遗留被清账?) | 09-09 快照,已被 v057 清账 |
| ③冲突 | 与他条目或仓现状矛盾点(无=「-」) | 与 v109 计数锚 17 冲突 |
| ④风险 | 高/中/低(会被直接执行的断言=高) | 中 |
| 处置 | 枚举:verified/updated/stale-marked/删除建议(仅建议) | stale-marked |
| 证据 | file:line 或命令+关键输出(≥10 字符,强制) | ls session-catchup.py→No such file |

### M2 四维校验动作定义（机械验证命令范式）
- **①定位实存**:对每条记忆内引用的文件/规则号/commit,执行 `grep -n "<锚>" <目标文件>` 或 `ls <路径>`;输出=命中行原文或未命中报错。命令范式:
  - 规则号:`grep -c "21.4" $CR`
  - 文件锚:`ls $R/plans/archive/task-v053-*/deferred-issues.log`
  - commit 锚:`git log --oneline | grep <sha前缀>`
- **②时效性**:`grep -n "末次任务" 条目`→对照 `git log --since="<末次日期>"` 后续是否有替代任务;基线类断言必须重跑原命令(如 selftest 全量→新值 vs 记忆值 diff)
- **③冲突**:`grep -n "<断言关键词>" <MEMORY.md+相关 topic>`→多条目同主题取最新;与仓现状 diff(如计数锚 grep 全库实测)
- **④消费风险**:断言可被直接执行/数字可被引用=高;纯教训/历史叙述=低
- 时点断言范式:git 状态/领先落后类断言用 `git status -sb` / `git rev-list --count origin/master..HEAD` 原样输出+运行时点,禁止转述
- 每维输出必须是可复现命令+关键行,禁止「应该/大概」

### M3 处置枚举与守门规则
| 处置 | 含义 | 守门 |
|---|---|---|
| verified | 断言与现状一致,保留 | 必须附 ①② 证据,免改 |
| updated | 断言过时但条目有价值,更新正文(原文留存于整理报告) | 更新点列表化;MEMORY.md 索引行同批刷新 |
| stale-marked | 条目主体有效但局部断言过时,加「[STALE <日期>: <失效条件>]」标注 | 标注文案固定格式;不删除原文。边界:仅数字/状态漂移且更新代价小→updated;主体叙事仍正确仅个别断言失效或需保留旧值做对照→stale-marked |
| 删除建议 | 条目整体失效(锚全灭/被新条目完全替代/纯时点快照) | **仅建议,不执行**;写入报告「删除建议」节,交用户裁决 |

### M4 验证锚规范 + MEMORY.md.proposed 产出契约
- 每条处置必附 ①file:line 或 ②命令→关键输出(≥10 字符),缺一=处置不成立
- MEMORY.md 修正版产出契约:先写 `plans/<task>/MEMORY.md.proposed`+`memory-hygiene-report.md`(含原文留存节);主进程抽验 ≥5 条证据(重跑命令复现)通过后才应用;topic 文件更新同契约(报告留存旧文)
- 修正版索引行 ≤200 字符,含:任务名/末次日期/一句话状态/「遗留 N」断言(有则)+验证戳 `[<task> <日期> 盘点 verified]`

### M5 写入规范三要素（防再犯）
1. **绝对日期**:正文所有基线/事实断言带 `YYYY-MM-DD` 前缀(禁「当前/最新/已」等相对词)
2. **验证锚**:每个数字/状态断言附可复现命令(grep/ls/diff/selftest),消费方=新会话可机械复核
3. **失效条件**:显式写「何时本条过时」(如「基线 42 脚本 660/0 — 失效条件:任一新增/删除 selftest 脚本或计数漂移」/「遗留 N 项 — 清账后本行删除」),消费方看到失效条件触发即重验,不盲信

### 与 v108 范式差异（本 template_type 特有）
- Code Review 配置面:记忆目录非 git 仓=「修改面=模板/仓内文件面+记忆目录 dogfood 面,无代码功能变更」;对齐审查由独立子代理按 alignment-review;质量审查工具=alignment-review
- 删除类处置永不自动执行(删除=不可逆,必须用户裁决)
- 隔离决策:worktree 仅用于仓内模板/级联文件面;记忆目录 dogfood 直改(修正版抽验兜底)

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe` / `risk` |
| `isolation` | `worktree`(仓内文件面) + dogfood(记忆目录面,修正版抽验兜底) |
| `worktree_path` | `<repo-parent>/<repo>-worktrees/<task-id>` |
| `branch` | `wt/<task-id>` |
| `merge_back` | `pending` → `merged(<commit>)` |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | 盘点 |
| Phase 2 | ☐ |  | 处置 |
| Phase 3 | ☐ |  | 修正版 |
| Phase 4 | ☐ |  | 独立验证 |

## Key Questions

1. 强时效断言条目占比多少(决定 A 类全读成本)?
2. 基线类数字(如 selftest 计数)当前值 vs 记忆值的 diff 有多大?
3. 双源冲突(索引行 vs topic 正文)集中在哪些条目?
4. 删除建议预期条数=?(预判用户裁决面)

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 修正版先落计划目录,抽验后才应用 | VC-3 契约;记忆目录无 git 兜底 |
| 删除类仅建议 | 不可逆操作必须用户裁决 |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
|       | 1       |            |

## Notes

- **铁律**:验证锚缺一=处置不成立(M4);删除永不自动执行(M3)
- 新增/更新条目必须满足 M5 三要素(绝对日期+验证锚+失效条件)
- 每 2 个 Phase 完成 → 跑 `Skill("task-drift-guard")`

## 📊 FMEA 预演

| # | 风险 | 概率 | 影响 | RPN | 兜底 |
|---|------|------|------|-----|------|
| R1 | 基线数字读旧快照,误判 verified | 中 | 高 | 中 | M2 ②强制重跑原命令 diff |
| R2 | 修正版直接覆盖 MEMORY.md(未抽验) | 低 | 高 | 中 | VC-3 契约+主进程抽验 ≥5 条 |

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |             |        |      |

## 📊 委派统计（Rule 25.4）

| Phase | 执行体 | 委派次数 | main_direct |
|-------|--------|---------|-------------|
|  |  |  |  |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
每次 Agent() 派发前填一行;子代理返回后 Read 产出+findings 回填双条件才勾 verify_done(Rule 22.5)
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 |
|---|------|--------------|----------------|------|---------------|---------------|--------------|----------------|
| 1 |  |  |  | queued |  |  |  |  |
