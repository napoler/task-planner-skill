<!-- template_type: memory-hygiene -->
<!-- 适用场景: 记忆体系盘点/整理/治理（MEMORY.md 索引 + topic .md 目录，如 ~/.zcode/cli/memories/projects/<project>/memory/） -->
<!-- 触发关键词: 记忆整理/记忆卫生/记忆过时/记忆偏见/强时效断言漂移/基线数字被替代 -->
<!-- 推荐 subagent: executor(fresh) 全量盘点 + verifier 抽验;主进程仅簿记(验证独立性铁律) -->
<!-- execution_lane: L1 -->

# Task Plan: [记忆整理任务名称]

<!-- plan_tier: standard -->
## Goal
[一句话:整理哪个项目记忆目录(路径),达成什么终态(每条 topic 有 4 维校验+处置结论,修正版先落计划目录抽验后才应用)]

<!-- 机制画像(Rule 37.3 通用组):记忆目录非 git 仓=仓内文件面(worktree)+记忆目录 dogfood 面,无代码功能变更;本类型走 content_quality 门控,不硬套 Code Review Gate;mini 档豁免 -->

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 索引层全量盘点 | MEMORY.md 逐行 Read(57 条口径按实测);每条 name/末次日期/声明状态提取 | `findings.md` 盘点表 |
| VC-2 | A 类(强时效断言)全读 4 维校验 | 逐条 grep/ls/git log 锚验证,证据 ≥10 字符 | `findings.md` A 类表 |
| VC-3 | 修正版产出契约 | 先写 `MEMORY.md.proposed`+整理报告(含原文留存节);主进程抽验 ≥5 条重跑命令复现通过后才应用 | `plans/<task>/` 抽验记录 |
| VC-4 | 删除零自动执行 | 全库 grep 处置表:删除类仅出现在「删除建议」节=仅建议,无已执行删除记录 | 整理报告 Read |
| VC-5 | 计数/锚级联自洽(涉及模板/文档面时) | 全库 grep 旧计数串零残留/新计数命中(按当次任务口径);gate 脚本 exit 0 | checkpoint+findings |

> **验证独立性铁律（延续 v108 用户 P0）**：全部验证由全新独立子代理执行；主进程仅编排/簿记/Read 结论。

- **终验规则**:全部 VC 通过 → COMPLETE;VC-3 失败=修正版未抽验→禁止应用修正版,回 Phase 3;VC-4 失败=发生自动删除→P0 回滚+报告用户

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 记忆目录(只读盘点面) | `~/.zcode/cli/memories/projects/<project>/memory/**`(Read/grep/ls 盘点) | 盘点阶段直接改写 topic/MEMORY.md |
| 修正版产出面 | `plans/<task>/MEMORY.md.proposed` + `plans/<task>/memory-hygiene-report.md` | 未抽验前覆盖原 MEMORY.md/topic |
| 仓内模板/级联面 | worktree 内列明的模板/计数文件(按任务 Scope) | 级联面外任何改动 |

- **强制约束**:①记忆目录盘点只读,修正版一律先落计划目录(MEMORY.md.proposed+报告),主进程抽验 ≥5 条证据(重跑命令复现)通过后由主进程应用②删除类处置**永不自动执行**(不可逆,交用户裁决),报告仅列「删除建议」节③每条处置必附验证锚(file:line 或命令→关键输出 ≥10 字符),缺一不成立

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

> 目的：对齐任务知识库。列出本任务依赖的记忆目录/规则条款/历史任务产物等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 记忆目录 | MEMORY.md + topic .md 全量 | `~/.zcode/cli/memories/projects/<project>/memory/` | 必读 | ☐ |
| 项目内部文档 | task-planner critical-rules 相关条款 | `${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/references/critical-rules.md` | 参考 | ☐ |
| 历史任务产物 | 被引用锚点的 plans/verification 文件 | `plans/<task-id>/*.md` | 参考 | ☐ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

- **调研需求三态（Rule 75.1/75.6）**：本模板任务默认 NO-RESEARCH（不需要调研）——记忆体系盘点全部证据锚来自本地文件系统与 git 历史,无网络信息来源需求;仅当条目锚点为外部 URL 时才升级 OPTIONAL-RESEARCH,并登记到计划「🔍 调研需求与检索计划」区块

- **核心问题定义(methodology.md T2)**: [强时效断言数 N=哪些条目会被新会话盲信]→[5 Whys 漂移根因:基线无失效条件→被替代后静默漂移→索引行与 topic 双源不同步]→[解法:四态处置+修正版抽验契约+M5 三要素]→[执行:Phase1 盘点→Phase4 独立验证,门控=VC-3 抽验]
## Current Phase
Phase 1

- **工具选择与编排(Rule 40)**:Phase 1 全量盘点派 executor(fresh)(大体量原料隔离 context);Phase 4 独立 verifier 重跑锚+机械 gate 脚本;Executor 字段仍是委派门控机器事实源

## Phases

### Phase 1: 记忆目录盘点（只读）
- [ ] 全量 Read MEMORY.md,提取每条 name/末次日期/声明状态/遗留断言
- [ ] A 类(强时效断言)全读+4 维锚验证;B 类抽查 ≥8 条;C 类(历史教训)免检登记
- [ ] 盘点表(M1 列定义)落 findings.md
- [ ] 知识储备必读项已确认可获取(勾选「已确认」列)
- **Status:** pending
- **Executor:** executor（fresh）
### Phase 2: 处置执行（四态+守门）
- [ ] 按 M3 处置枚举逐条定态:verified/updated/stale-marked/删除建议(仅建议)
- [ ] updated 条目:原文留存整理报告+更新点列表化;MEMORY.md 索引行同批刷新
- [ ] stale-marked 条目:加「[STALE <YYYY-MM-DD>: <失效条件>]」固定格式标注,不删原文
- [ ] 每条处置附验证锚(①file:line 或 ②命令→关键输出 ≥10 字符)
- **Status:** pending
- **Executor:** executor（fresh）
### Phase 3: 修正版产出（抽验契约）
- [ ] 写 `plans/<task>/MEMORY.md.proposed`(索引行 ≤200 字符:任务名/末次日期/一句话状态/遗留 N 断言(有则)/验证戳 `[<task> <日期> 盘点 verified]`)
- [ ] 写 `plans/<task>/memory-hygiene-report.md`(含原文留存节+删除建议节)
- [ ] 主进程抽验 ≥5 条:重跑 M2 命令复现证据;topic 文件更新同契约(报告留存旧文)
- [ ] 抽验通过 → 主进程应用修正版;失败 → 回 Phase 2 重做该条
- **Status:** pending
- **Executor:** 主进程（例外理由:抽验/应用属主进程簿记面;重写条目仍派 executor）
### Phase 4: 独立验证 + 级联自检
- [ ] 独立 verifier 子代理重跑 M2 抽样锚(≥3 条),复现输出入 checkpoint
- [ ] grep 全库计数级联自洽(任务涉及时,如 variant 17 口径)
- [ ] 删除建议节 Read 复核=零自动执行(VC-4)
- [ ] 派发 `drift-checker` 子代理偏移检查（Rule 61 载体）终验
- **Status:** pending
- **Executor:** verifier（fresh）+ 主进程（例外理由:簿记与终验）

## 📋 记忆整理协议（本模板核心合约 — M1-M5）

- **M1 盘点表（逐条必填,落 `findings.md`）**:name/类(A 强时效断言全读·B 行为偏好抽查·C 历史教训免检登记)/①定位(引用锚 grep/ls 实测命中或未命中)/②时效(末次任务日期 vs 现状,基线被替代?遗留被清账?)/③冲突(与他条目或仓现状矛盾,无=「-」)/④风险(高/中/低,会被直接执行的断言=高)/处置(枚举 verified/updated/stale-marked/删除建议)/证据(file:line 或命令+关键输出 ≥10 字符,强制)
- **M2 四维校验（机械命令范式）**:①定位实存 `grep -n "<锚>" <目标>` 或 `ls <路径>`(命中行原文或未命中报错;规则号 `grep -c "21.4" $CR`/文件锚 `ls $R/plans/archive/...`/commit 锚 `git log --oneline | grep <sha前缀>`)②时效 `grep -n "末次任务" 条目` 对照 `git log --since="<末次日期>"` 后续是否替代+基线类重跑原命令 diff③冲突 `grep -n "<断言关键词>" <MEMORY.md+topic>` 多条目取最新+仓现状 diff④消费风险 可被直接执行=高,纯教训=低;时点断言用 `git status -sb`/`git rev-list --count origin/master..HEAD` 原样输出,禁转述;每维=可复现命令+关键行,禁「应该/大概」
- **M3 四态处置+守门**:verified(断言与现状一致保留,附①②证据免改)/updated(原文留存整理报告+更新点列表化+MEMORY.md 索引行同批刷新)/stale-marked(加「[STALE <日期>: <失效条件>]」固定格式标注不删原文;边界=仅数字/状态漂移且更新代价小→updated,主体叙事正确仅个别断言失效或需保留旧值对照→stale-marked)/删除建议(锚全灭/被新条目完全替代/纯时点快照=整体失效,**仅建议永不自动执行**,写入「删除建议」节交用户裁决)
- **M4 验证锚规范+修正版产出契约**:每条处置必附 ①file:line 或 ②命令→关键输出(≥10 字符),缺一=处置不成立;修正版先写 `plans/<task>/MEMORY.md.proposed`+`memory-hygiene-report.md`(含原文留存节),主进程抽验 ≥5 条重跑命令复现证据通过后才应用,topic 文件更新同契约(报告留存旧文);索引行 ≤200 字符含任务名/末次日期/一句话状态/遗留 N 断言(有则)/验证戳 `[<task> <日期> 盘点 verified]`

- **M5 写入规范三要素（防再犯）**:①绝对日期(正文基线/事实断言带 YYYY-MM-DD 前缀,禁「当前/最新/已」等相对词)②验证锚(每个数字/状态断言附可复现命令,消费方=新会话可机械复核)③失效条件(显式写「何时本条过时」,如「基线 42 脚本 660/0 — 失效条件:新增/删除 selftest 脚本或计数漂移」/「遗留 N 项 — 清账后删除」,消费方见触发即重验不盲信)
## Notes
- **铁律**:验证锚缺一=处置不成立(M4);删除永不自动执行(M3);新增/更新条目必满足 M5 三要素(绝对日期+验证锚+失效条件);每 2 个 Phase 完成 → 派发 `drift-checker` 子代理偏移检查（Rule 61 载体）
