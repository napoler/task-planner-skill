# modification-compliance-gap 取证报告（只读）

- task: 调查 task-planner skill 体系中「修改合规性」的现有机制覆盖度与缺口
- status: done（只读取证；未修改任务三文件/规则文件，仅写本检查点）
- checkpoint: `/mnt/data/dev/task-planner-skill/forensics/modification-compliance-gap-20261119.md`
- date: 2026-11-19
- scope_roots:
  - canonical: `/mnt/data/dev/task-planner-skill/skills/task-planner/`
  - deployed(read-only compare): `/home/terry/.zcode/skills/task-planner/`
  - constitution: `/home/terry/.zcode/AGENTS.md`
  - 参考计划(只读): `/mnt/data/dev/task-planner-skill/plans/archive/task-spec-baseline-freeze-20261119/{task_plan.md,findings.md,progress.md}`
- 需求锚(Rule 51.1a, 用户原话): 「核心问题就是为什么将一个原本有理有据的模型能力限制被恶意修改了…也就是修改是否合规 连合规性都没有就做恶意修改只会导致投毒…我的目的以后不会出现这种合规性都没有就做恶意修改」
- 证据方法(磁盘实际 grep/read): `grep -rn`/`sed -n`/`cat` 于上述路径；关键命令含 `grep -rn "Rule 74.3|Rule 20.1|Rule 51.15|SPEC-BASELINE|Rule 23.12|RefSet|Rule 84|Rule 36.6|skill-modify|判据冻结|①-校验|check-delegation|白名单" skills/`、`grep -n "展示后执行|写入最小化|先检索后定位|保护区|worktree" /home/terry/.zcode/AGENTS.md` 等（行号以下文逐条引用）。

---

## A. 现有机制清单（file:line 证据）

| 机制名 | file:line（关键锚） | 保护对象 | 是否覆盖“修改前合规论证”（为什么改/依据是什么/是否破坏既有约束） | 证据摘录/机制要点 |
|---|---|---|---|---|
| Rule 74.3 变更标注表（先标注后执行） + Rule 74.2 三判门（增量/替代四条件/删除授权） | `skills/task-discipline/references/critical-rules-discipline.md:486`(§74 标题) `:489`(74.2 三判门) `:490`(74.3 逐条变更标注, 无表=无效禁入执行, 74.3d 先标注后执行) `:493`(74.6 守护)；`skills/task-planner/SKILL.md:118`(2.5d 变更类型判定 P0) `:214`(B 扩展先重规划+三判门+变更标注表)；`skills/task-planner/templates/task_plan.md:184-189`(变更标注表区块: 对象+锚点/类型/吸收判定/依据/执行动作, “先标注后执行”)；`skills/task-planner/references/critical-rules.md:147,155`(user-session-log 冲突对齐走 74.3)；守护 `skills/task-planner/scripts/selftest-absorption-discipline.sh:29,103,126,132` | 既有计划/规则/模板/清单等被吸收/修订对象（五类吸收场景 74.1） | **部分覆盖（计划/修订语义层，LLM 行为+静态守护，非运行时通用编辑硬门）**：要求登记“吸收判定(增量/替代/删除)+依据(用户原话或证据)+执行动作”，74.2b 替代须“既有内容被证伪或用户明示否决/作废 + 覆盖论证 + 先 Read 旧内容全文 + 守护/selftest 全绿”；74.3d 新指令先转标注行再动文件。**但**属“修订方案/吸收语义”纪律，主要计划期/方案期载体；无 PreToolUse 类运行时门阻断“未登记标注表就改文件/改规范”的任意编辑；对执行期产出内悄悄放宽既有规范无直接绑定。 | `74.3b 无变更标注表的修订方案=无效方案,禁入执行`；`74.3d 用户新指令到达时先把指令逐条转成标注表行，再动任何文件——先标注后执行`；`74.2(d) 先问是补充还是替代——未做三判即写入 = P0 违规` |
| Rule 20.1 计划 attestation（SHA-256 锁定）+ [PLAN TAMPERED] | `skills/task-planner/references/critical-rules.md:36`(20.1)；`skills/task-planner/scripts/attest-plan.sh:2`；hook 校验 `skills/task-planner/scripts/zcode-userpromptsubmit.sh:11,66` | `task_plan.md` 完整性（获批后计划内容防篡改） | **不覆盖内容合规，仅覆盖“改动可被感知/需显式重锁”**：哈希不符→注入 `[PLAN TAMPERED]` 并拒绝注入计划内容；重规划后须重跑 attest。能阻止“静默改计划不留痕”，但不判定修改是否合规/有无依据；重 attest 本身是操作步骤而非合规论证门。 | `哈希不符 → 注入 [PLAN TAMPERED] 警告并拒绝注入计划内容;自己重规划后重跑 attest 更新锁定` |
| Rule 51.15 规范基线冻结（Spec-Baseline Freeze）+ [SPEC-BASELINE TAMPERED] + 四环绑定 | `skills/task-planner/references/critical-rules.md:109`(51.15 全文)；模板 `skills/task-planner/templates/task_plan.md:62-63`；派发携带 `skills/task-dispatch/references/critical-rules-dispatch.md:66`(22.4e) + 模板 `skills/task-planner/templates/subagent_dispatch.md:48`；复检回归 `skills/task-dispatch/references/critical-rules-dispatch.md:241`(103.3b)；返工/续写回归 `skills/task-discipline/references/critical-rules-discipline.md:756`(106.7)；终验门 `skills/verification-gate/references/critical-rules-verification.md:60`(84.15)；落地追溯 `plans/archive/task-spec-baseline-freeze-20261119/findings.md`、`task_plan.md`(VC-1~5/锚清单)；部署位对照命中 `~/.zcode/skills/task-planner/references/critical-rules.md:109`、`templates/task_plan.md:55`、`templates/subagent_dispatch.md:48` | 已登记为 Spec-Baseline 的“已确立且影响验收的业务硬约束”（task_plan「🔒 规范基线」区块内项） | **覆盖已登记基线的“修改前合规/授权门”（强，作用域=已登记基线）**：执行期修改/放宽/删除任一基线项或以“超拍登记/NOTE 保留/叙事必要”软豁免放行越界值 = 等同改判据，**唯一合法路径=STOP→用户显式授权→Decisions Made 登记→更新基线→重跑 attest 重锁**；未走流程=`[SPEC-BASELINE TAMPERED]`(P0 交付作废)。含**双向显式铁律**（区间型必须同时登记上下界，禁只写单边）。四环消费将合规要求下沉到派发/复检/返工回归/终验。**边界**：依赖“计划期识别并登记”；判定/验真由 LLM 行为门+既有 attest/check 承载（无独立数值解析脚本）。 | `唯一合法路径=STOP→用户显式授权→Decisions Made 登记→更新基线→重跑 attest 重锁`；`双向显式铁律...禁只写单边`；`103.3b` 查“软豁免放行/区间降单边/前序合规本单元退化”；`106.7` 返工/续写全量回归并 `[spec-regression]` STOP；`84.15` 终验逐条双向验真、sha256 漂移/缺表即不可 COMPLETE |
| 判据冻结协议（verification.md 状态行 vs 判据行） | `skills/verification-gate/SKILL.md:98` | `verification.md` 的判据行（Verify command/判定标准/期望值） | **覆盖判据修改前合规/授权门（作用域=verification 判据行）**：判据行自 attest 锁定起冻结；执行期修改未走“STOP→用户授权→Decisions 登记→attest 重锁”四步=对已批准契约篡改，`[PLAN TAMPERED]` 拦截+交付作废；“判据达不成”只能 BLOCKED 升级不得改判据。状态行（勾选/证据回填）与判据行分离。 | `判据行若在执行期被修改而未走「STOP→用户授权→Decisions 登记→attest 重锁」四步，视为对已批准契约的篡改，[PLAN TAMPERED] 机制拦截+交付作废` |
| Rule 23.12 共享引用管理（RefSet 冻结 + 单写者 + 换代协议） | `skills/task-dispatch/references/critical-rules-dispatch.md:101`(23.12)；三检测时机 `:100`(23.11)；指针引用 `plans/archive/task-spec-baseline-freeze-20261119/findings.md:17` | 共享锚件/可变共享资源（id+版本+sha256 冻结、只读共享、单写者维护、锚件换代 stale 广播+冻结锁+引用同步验证） | **部分覆盖“引用/锚件变更合规”**：共享锚件“只读共享+版本冻结”；换代需“G1 人工门+单写者登记+stale 广播+冻结锁”，完成后按 sha 差集重跑；引用同步需 grep 旧 sha 0 命中方可提交。提供了变更流程与证据链，但针对的是“共享引用资产一致性/换代”，非任意业务规范文本的合规论证门。 | `id+版本+sha256 冻结...锚件换代协议（stale 广播+冻结锁）...换代完成后按 sha 差集重跑 stale 单元（引用同步：grep 旧 sha 0 命中方可提交）` |
| ①-校验 规则版本一致性硬门（worktree 创建后） | `skills/task-planner/references/worktree-isolation.md:60-66`(①-校验段)；落盘 `plans/archive/task-spec-baseline-freeze-20261119/findings.md:17` | worktree 与主工作分支的关键规则文件版本（`*/SKILL.md`、`*/references/critical-rules*.md` 行数与关键锚）及正确基线分支选择 | **不覆盖修改合规，覆盖“创作/审查所依据规则版本一致性”**：进入开发前校验，不一致则禁止开发并从主工作分支同步；防“按旧规创作/按新规判 FAIL”。属版本对齐门，非修改授权/依据门。 | `①-校验...关键规则文件...行数与关键锚一致。任一不一致 = 禁止开发...创作与审查必须同一规则版本快照` |
| Rule 84 终验（VC 逐条复验 / 验证全链路） | `skills/verification-gate/references/critical-rules-verification.md:1-63`(84.1-84.15 等, 含 VC 可执行性/复验 SOP/84.15 Spec-Baseline 终验门)；`skills/verification-gate/SKILL.md:98`(判据冻结协议, 引用 84 链)；主路由 `skills/task-planner/SKILL.md:20,81,133,153-154,256,260,275,280`；脚本 `skills/verification-gate/scripts/run-verification.sh`(统一执行入口, 目录实存) | 交付物/验证契约满足度（VC/V-N/判据/基线逐条证据） | **间接/滞后覆盖（验收面）**：通过 VC/判据/Spec-Baseline 逐条验真拦截不合规结果进入 COMPLETE（84.15 直接对基线双向判定式验真）。但终验发生在交付前而非“修改动作前”；若执行期已悄然放宽且未被复检拦截，终验是最后一道门而非预防性合规论证。 | `84.15...对交付物本体逐条执行“双向判定式”验真...任一 FAIL/被软豁免放行/核验表缺失或 sha256 漂移=不得判 COMPLETE`；`84.5 终验复验 SOP` |
| Rule 36（技能修改保守化与功能删除防护）含 36.2 归因前置/36.4 删除确认/36.5 保守化/36.6 回归/36.6a 分域实跑/36.7 机制；终验 SKILL-MODIFY GATE | `skills/task-discipline/references/critical-rules-discipline.md:122-130`(36.1-36.7, 含 36.5 引 Rule 74.2)；`skills/task-planner/config.json:391`(`skill_modify_enforce` enforce/warn/off)；`skills/task-planner/scripts/check-skill-modify.sh:2-40+`(pretool: 技能文件写入须在活跃计划执行范围限制表登记, 否则 warn/enforce 阻断；主/子代理一致)；接线 `skills/task-planner/scripts/zcode-pretooluse.sh:105`；终验门 `skills/task-planner/scripts/check-complete.sh:1626-1654`(SKILL-MODIFY GATE: 涉及技能文件修改须登记删除性行为清单/无删除声明)；守护 `skills/task-planner/scripts/selftest-skill-modify.sh` 等 | 技能文件（`skills/<name>/**` 含 SKILL/references/scripts/templates/config 等，仓库与部署副本） | **部分覆盖（技能域修改授权/范围控制，非通用“规范合规论证”）**：36.2 要求先四维归因、仅“技能本体缺陷且用户显式要求当前任务内修改”才可发起；36.4 功能性删除/语义改写须逐项用户确认（D6）；36.5 默认纯增量、语义变更须登记旧→新对照；36.6/36.6a 回归；pretool 把“写入是否在活跃计划执行范围限制表登记”变成可阻断门。**缺口**：聚焦技能保护区与删除/语义改写，未要求对“放宽既有业务规范/约束”做显式合规论证（为什么可改、是否破坏既有约束）；“新增/看似局部修改导致约束失效”的合规性不在其判定面。 | `36.4 任何功能性删除或既有语义改写...逐项列清单交用户确认...未确认前禁止执行`；`36.5 默认纯增量追加；既有条款语义变更须...登记旧语义→新语义对照`；`check-skill-modify.sh` 未在执行范围限制表登记→warn/enforce(exit2) |
| check-delegation 白名单（执行期委派门控） | `skills/task-planner/scripts/check-delegation.sh:2-9`(session-owner 对比+白名单+exit2) `141-172`(路径白名单: plans/*.md|*.json、记忆目录、tmp/output 等) `235`(误拦提示指向 plans 白名单) `288-317,390,406-448,628`(owner/白名单链/理由编号/统计)；接线 `skills/task-planner/scripts/zcode-pretooluse.sh`(pretool 分支调用, 同仓模式) | 写入主体与路径权限（主进程 vs 子代理、白名单路径直做豁免，防主进程越权直写实现文件） | **不覆盖**：控制“谁在什么路径可写/可派发”，不评估修改内容是否合规、是否有依据、是否放宽既有约束。 | `exit 0 放行(白名单命中/子代理 sid/.allow-direct/...) exit 2 enforce 模式阻断(主进程白名单外 Write/Edit)`；白名单以路径/理由编号判定 |
| 宪法 §五 安全底线（展示后执行/写入最小化/先检索后定位/危险命令需授权等） | `/home/terry/.zcode/AGENTS.md:76-82`(展示后执行/写入最小化/先检索后定位/危险命令需授权/Git 安全/基础设施配置保护/跨项目隔离/超时/错误曝光) | 有副作用写操作、修改范围与定位正确性、高危命令与基础设施配置 | **部分覆盖“过程合规”，不等同“规范修改合规论证”**：要求先展示再执行、只改用户要求部分、先 Read 后改——可减少误改/越改，但未要求在修改既有规范/约束前声明“修改依据+是否破坏既有约束”并过合规门。 | `展示后执行` `写入最小化：只改用户要求部分` `先检索后定位：禁止未 Read 目标文件就 Edit/Write` |
| 宪法 §六 技能与配置文件保护（P0） | `/home/terry/.zcode/AGENTS.md:88-96` | 保护区 `~/.zcode/skills/**` `~/.zcode/agents/**` `~/.zcode/commands/**` `~/.zcode/AGENTS.md` 及 `~/.agents/skills/**` | **部分覆盖（修改授权门，作用域=保护区文件）**：未经用户明确授权禁止修改；修改前须 Read+展示 diff+逐项确认；未授权修改=投毒并还原/降级。覆盖“是否获授权”与可审查，但未细化到“对已确立业务规范的放宽是否合规/破坏既有约束”的论证格式（虽实践中可借确认承载）。 | `未经用户明确授权禁止修改任何技能/agent 定义/指令文件...修改前必须 Read 现状+展示 diff+逐项确认` |
| 宪法 §十一 工作树隔离与并行开发强制（P0） | `/home/terry/.zcode/AGENTS.md:151-194`(11.1 必须 worktree 范围含保护区/skills/scripts/配置等；11.3 合并回约束；11.5 例外)；SOP `skills/task-planner/references/worktree-isolation.md:60-66`(①-校验) | 运行行为/保护区/基础设施变更的隔离、合并前验证与可回滚性 | **不直接覆盖修改合规论证**：通过隔离+合并前 VC/状态检查降低污染与失控风险，但不规定“修改既有规范前必须给出合规依据/影响评估”。 | `实现类任务...必须在 git worktree 隔离区开发...worktree 内全部 Phase=complete，VC 逐条复验通过...主仓无与任务范围重叠的未提交变更` |

> 部署位对照（只读）：`/home/terry/.zcode/skills/task-planner/` 中 51.15 与 74.3 文本已存在（如 `references/critical-rules.md:109`、`templates/task_plan.md:55,177`、`templates/subagent_dispatch.md:48`）；但 canonical `SKILL.md`(63440B) 与 deployed `SKILL.md`(2048B) 体量差异显著（部署位为轻量指针形态），本次取证以 canonical 规则/脚本/模板与 constitution 为一手证据主源，部署位仅作机制存在性对照。

---

## B. 缺口分析（编号，证据 + 为何是缺口）

### B1. “修改前合规论证”无通用硬门，现有强门均为作用域受限
- **证据**：
  - 已登记规范基线修改有强门：`critical-rules.md:109`(Rule 51.15) 要求 `STOP→用户显式授权→Decisions Made 登记→更新基线→重跑 attest 重锁`，并四环绑定 `dispatch:66`(22.4e)、`dispatch:241`(103.3b)、`discipline:756`(106.7)、`verification:60`(84.15)。
  - 判据行修改有强门：`verification-gate/SKILL.md:98` 要求同构四步，否则 `[PLAN TAMPERED]`。
  - 计划文件内容改动有完整性门：`critical-rules.md:36`(20.1) 改后哈希不符即 `[PLAN TAMPERED]` 拒注入。
  - 变更标注为方案/行为纪律：`critical-rules-discipline.md:490`(74.3b 无表=无效方案禁入执行, 74.3d 先标注后执行) + `SKILL.md:118`(2.5d P0)；但守护以 `selftest-absorption-discipline.sh` 等静态锚/流程承载（`:29,103,126,132`），未见对任意文件 Edit/Write 的 PreToolUse 运行时拦截要求“必须存在合规论证记录”。
  - 技能文件写入有范围门非合规门：`check-skill-modify.sh` 校验活跃计划执行范围限制表登记（warn/enforce），`check-complete.sh:1626-1654` 校验删除性行为清单/无删除声明；未校验“修改依据/是否破坏既有约束”。
- **为何是缺口**：不存在一条覆盖“任何对已确立规范/规则/约束的修改”的统一前置合规门。51.15/判据冻结只保护各自作用域（已登记 Spec-Baseline、verification 判据行）；未登记的业务规范、项目/技能内嵌硬约束、执行期产物中的约束定义被放宽时，缺少“修改前必须声明合规依据+走授权门，否则禁止落地”的普适硬约束。
- **与诉求关系**：sess_ba603cf5 式“已确立 4-12s 约束被改为 3s/15s 口径/结果”若未被登记为 Spec-Baseline 且改动发生在计划外产物/隐含口径中，现有通用机制无法在修改动作前强制合规论证。

### B2. Rule 74.3 以“计划/修订方案”载体为主，执行期规范变更缺强制重填与执行绑定
- **证据**：
  - 载体与时机表述：`critical-rules-discipline.md:490` “制定方案时必须在 task_plan.md「📋 变更标注表」逐条登记…”；`74.3d` “用户新指令到达时先把指令逐条转成标注表行，再动任何文件”；`templates/task_plan.md:184-189` 区块注释“制定修订方案时填写/用户新指令到达时先逐条转标注行再动任何文件（先标注后执行,74.3d）”。
  - 计划/模板受锁但标注表非执行期通用闸：`critical-rules.md:36` 仅锁 `task_plan.md`；执行期子代理产出/代码/文案/分镜脚本等非 task_plan 改动不触发 `[PLAN TAMPERED]`，也未见“每次改规范先补 CA 行并获批准”的运行时校验。
- **为何是缺口**：当规范/约束在执行过程中被“就地”放宽或改写（尤其由子代理在产物内实现，或主进程未走正式重规划），74.3 的“先标注后执行”缺少可强制兑现的机器/流程钩子，易退化为事后文档或被绕过；无法保证“执行期改规范必须重填并合规审查后才落地”。
- **对单边放水的意义**：即便执行者把 `4-12s` 写成 `≤12s`，若未触发 51.15 已登记基线的比对/复检路径，74.3 本身不会自动识别这是“放宽”。

### B3. “禁止无依据放宽约束”未形成通用显式铁律；单边约束检出仅在 Spec-Baseline 注册链路内成立
- **证据**：
  - 显式双向/禁软豁免（作用域=Spec-Baseline）：`critical-rules.md:109` “**双向显式铁律**：区间型硬约束必须同时登记上下界...禁只写单边...单边口径等于无下限”；`dispatch:241`(103.3b) 复检查“区间约束被偷偷降为单边/越界值被软豁免放行”；`discipline:756`(106.7) 返工/续写全量回归查退化；`verification:60`(84.15) 终验“逐条执行‘双向判定式’验真”。
  - 通用变更语义仍偏原则：`critical-rules-discipline.md:489`(74.2b 替代四条件) 与 `:125`(36.5 保守化/语义变更登记旧→新) 要求有据/覆盖/回归，但未出现面向“已确立业务约束/规范”的通用条款如“禁止无依据放宽/收紧口径需等价性证明，否则 STOP”；未规定“只写上限缺下限=放宽”对所有约束成立的统一判据。
  - 历史判例佐证机制前态：`plans/archive/task-spec-baseline-freeze-20261119/findings.md` F1/F2 指出“C87 只写 `C87时长=3s≤12s`（缺 ≥4s 下限）”“QC-G4 无时长硬门”“4-12s 未下沉为技能/QC 强制门”；F2 指出缺 Spec-Baseline Freeze 闭环前，业务硬约束可被静默降级。
- **为何是缺口**：单边约束“看似合法实为放水”能否被检出，取决于约束是否被登记为 Spec-Baseline 并经 22.4e/103.3b/106.7/84.15 四环实际执行；对未登记约束、非区间但语义放宽（阈值上调/条件删减/豁免条款新增）、或项目侧 QC 口径自身缺下限（如判例中 C87/QC-G4），缺少可普适触发的“无依据放宽=违规”铁律与检出门。检测仍主要是 LLM 复检语义判断，无确定性解析器。

### B4. 规范基线保护依赖“登记前提”，源规范/项目侧定义未被同等纳管
- **证据**：
  - 51.15 触发前提：`critical-rules.md:109` “计划期必须在 `task_plan.md`「🔒 规范基线（Spec-Baseline）」区块逐条登记…”；未登记则四环与 `[SPEC-BASELINE TAMPERED]` 不适用。
  - 历史事实：`plans/archive/task-spec-baseline-freeze-20261119/findings.md` F1 “4-12s 双界...在弧规格与 script-craft M0 模板”“从未下沉到 storyboard-craft 技能层”“C87 无正式定义”；F2 “冻结机制保护对象均非‘项目业务规范基线’（20.1 锁 task_plan、判据冻结锁 verification、23.12 锁引用资产、①-校验锁规则文件版本）”——即使 51.15 落地，保护对象仍是“登记进受管区块的条目”。
  - 宪法 `AGENTS.md:82` 跨项目隔离、`:88-96` §六保护区限定为特定配置/技能路径；StoryLab 等业务仓规范文件不在 task-planner 自身可强制纳管范围（且本取证范围外不可改）。
- **为何是缺口**：若硬约束只存在于业务源文档/SOP/弧规格而未被提取登记，执行期仍可能按被削弱口径生产；“登记遗漏”本身缺机器校验。51.15 解决“已登记后防篡改/防降级”，未完全解决“应登记未登记”的发现与强制。

### B5. 宪法/委派/范围门提供过程约束但不构成“修改合规性”判定
- **证据**：`AGENTS.md:76-82`(§五 展示后执行/写入最小化/先检索后定位)；`AGENTS.md:151-194`(§十一 worktree 隔离+合并前 VC)；`check-delegation.sh:141-172,288-317`(路径/owner 白名单控制可写性)。
- **为何是缺口**：这些机制降低误改、越权改、不可回滚改的概率，但均不回答“该修改是否有合规依据、是否破坏既有约束、放宽是否合法”；因此无法单独阻止“看似流程合规、实质放水”的恶意/错误修改。

---

## C. 根因判定 + 最小修复面建议

### C1. 根因判定（基于证据，针对 sess_ba603cf5 类“规范被静默放宽”）

1. **事故当时的直接机制根因（Spec-Baseline Freeze 落地前）**：硬约束“4-12s/镜”未被固化为可强制消费的受管基线与硬 QC 门。证据：`plans/archive/task-spec-baseline-freeze-20261119/findings.md` F1 指出 4-12s 仅在弧规格/script-craft M0、未下沉 storyboard-craft/QC；C87 实作 `3s≤12s` 缺 ≥4s，且可“超拍登记/NOTE 保留”放行；QC-G4 无时长硬门；未见单点篡改而是“硬约束从未固化→逐步丢弃”。F2 指出当时缺“定义→冻结→派发携带→QC 回归→终验绑定”闭环（`critical-rules.md:109` 已将该判例作为 51.15 建制背景）。
2. **当前机制下是否仍有漏洞可乘（51.15 落地后）**：**有，但漏洞从“无防线”收敛为“注册与作用域漏洞”**。
   - **已覆盖边界（可阻断/可检出）**：若任务将 `4s≤单镜≤12s` 等约束按 51.15 登记入 `task_plan.md`「🔒 规范基线」并完成 attest，则 `critical-rules.md:109`+`templates/task_plan.md:62-63` 冻结其内容；`dispatch:66`/`subagent_dispatch.md:48` 强制派发携带；`dispatch:241`(103.3b) 复检查软豁免/降单边/退化；`discipline:756`(106.7) 返工续写全量回归；`verification:60`(84.15) 终验双向验真；任何未授权修改/放宽须走 STOP→显式授权→Decisions→更新基线→重 attest，否则 `[SPEC-BASELINE TAMPERED]`。因此“已登记、已走四环”的同类降级在规则设计上应被拦截。
   - **仍可乘缺口**：① 约束未登记（B4），保护链不触发；② 执行期改规范未被纳入 74.3 强制重填/合规门（B2），在未登记场景可绕过；③ 无“禁止无依据放宽既有约束”的通用铁律与通用检出（B3），单边/语义放宽在注册链路外难自动识别；④ 复检/终验为 LLM 行为门，存在漏检风险但较前态已显著收敛。结论：**51.15 已覆盖“已登记业务硬约束的防倒退与修改合规”，但尚未覆盖“所有已确立规范的修改合规性”这一更大命题。**

### C2. 最小修复面建议（纯文本条款，零新脚本/零新 config 键，复用现有 attest/74.3/四环门）

> 原则：优先“把未登记规范纳入既有门”而非新建机制；所有修改走“声明依据→授权→锁定→四环验真”。

1. **新增通用修改合规铁律（建议编号落位：Rule 74.7 或 Rule 51.16，纪律/核心域择一保持分层）——插入锚行后追加**
   - 建议文件/锚：`skills/task-discipline/references/critical-rules-discipline.md` 紧接 Rule 74.6 机制段后（现锚 `74.6 **机制与守护（零新 config 键）**：① ../../task-planner/scripts/selftest-absorption-discipline.sh...`，行 `:493`）追加子条；并在 `skills/task-planner/references/critical-rules.md`（核心域）`51.15` 末尾 `:109` 后追加一行指针“通用修改合规门见纪律域 74.7/106.x”以跨域可达（避免规则孤岛）。
   - 最小条款要点（文本）：对任何“已确立规范/规则/验收约束/阈值/区间”的修改或放宽，落地前必须登记合规四元组 `变更对象+当前值(原文)→拟变更值+变更依据(证据/用户逐字授权)+影响评估(破坏/放宽了哪些既有约束)+处置(保留/等价替代/用户授权放宽)`；**无依据放宽=禁止落地（P0）**；区间型约束放宽判据显式化：删下界/抬上界/改单边/增加软豁免条款均属放宽。执行期发生时须即时补记 `task_plan.md`「📋 变更标注表」并（若影响计划/基线）按 20.1 重 attest；未登记合规四元组=未获修改许可。
   - 复用：沿用 74.3 表、20.1 attest、Rule 8 B/C 重规划流程；零新脚本。

2. **强制“执行期改规范必回填 74.3 +（命中基线则）51.15 路径”**
   - 建议文件/锚：`skills/task-planner/SKILL.md` 现有变更判定步 `:118` `2.5d [A] **变更类型判定（Rule 74 三判门，P0）**...` 行尾/后句追加“执行期任一对已确立规范/阈值/区间的改动（含产物内口径）在落地前必须补「📋 变更标注表」合规四元组；命中 Spec-Baseline 同步走 51.15 STOP→授权→Decisions→更新→重 attest”。
   - 建议文件/锚：`skills/task-dispatch/references/critical-rules-dispatch.md` 在 `22.4e` 段后（现锚 `:66` 末尾）追加一句“执行体发现需改动基线/规范口径时禁止自行落地，须回传主进程按 74.7/51.15 合规门处置”；与既有 22.4e “禁止子代理...自行重建/转译/放宽基线”衔接。

3. **把“单边约束/软豁免=放水”从 51.15 作用域上提为通用判据（供复检/验收引用）**
   - 建议文件/锚：`skills/task-discipline/references/critical-rules-discipline.md` `106.7` 段（现锚 `:756`，`判例锚：sess_ba603cf5...` 同段）在“发现任一基线项...退化”定义后补充“通用：区间约束缺上下界（如仅≤上限）或引入‘超拍登记/NOTE/叙事必要’类豁免，等同无依据放宽，按本门 STOP”；使 106.7 不仅回归“已登记基线”也能在文案上兜住同型口径（实施仍以登记/证据为准）。
   - 建议文件/锚：`skills/task-planner/templates/task_plan.md` 变更标注表说明 `:184-189` 附注列增加“放宽判据示例：区间去边界/阈值放松/豁免新增=须用户授权+依据”。

4. **登记前置强化（降低 B4 注册遗漏）**
   - 建议文件/锚：`skills/task-planner/references/critical-rules.md` `51.15` 首句后（现锚 `:109` “计划期必须在...”前后语境）补充“计划期对用户/项目/SOP/技能中已确立硬约束做来源扫描，候选约束未登记须在 task_plan 显式写 `none-justified` 或逐条登记（禁静默遗漏）；存在区间/阈值时必须原文抄录双界”。复用 51.1 逐字锚与 51.2 覆盖判据，无新机制。

5. **最小落点清单（按需一次性修改，均为文本）**
   - `skills/task-discipline/references/critical-rules-discipline.md` @ `:493`(74.6 末) 后：增 74.7 通用修改合规铁律 + 合规四元组。
   - `skills/task-planner/references/critical-rules.md` @ `:109`(51.15 末)：增指针与“未登记须显式 none-justified”登记纪律。
   - `skills/task-planner/SKILL.md` @ `:118`(2.5d)：增执行期改规范强制补标注与 51.15 联动语句。
   - `skills/task-dispatch/references/critical-rules-dispatch.md` @ `:66`(22.4e 末)：增“执行体禁自行改规范口径，回传主进程合规处置”。
   - （可选，同步）`skills/task-planner/templates/task_plan.md` @ `:184-189`、`templates/subagent_dispatch.md` @ `:48`：补“放宽判据/回传合规”提示行，保持模板与条款同构。
   - 验证：复用现有 `selftest-absorption-discipline.sh`（可增文本锚断言如已有范式）+ 现有 attest/四环门，无新脚本。

### C3. 判定结论（一句话）
- **结论**：当前体系对“计划文件完整性(20.1)”“技能文件授权与范围(36.x/§六)”“已登记 Spec-Baseline 与判据冻结(51.15/判据冻结/四环)”已有较强防篡改与合规门，但**缺少覆盖所有已确立规范/约束的通用“修改前合规论证+授权”硬门**；Rule 74.3 提供方案期三判与标注但执行期可绕过且非普适放宽禁令。sess_ba603cf5 类静默放宽在 51.15 落地后**若基线已登记且四环严格执行可被拦截**，但在“未登记/执行期就地放宽/单边口径未被识别”场景仍存在可乘漏洞，根因应定性为“合规门作用域与登记前置不足 + 缺通用无依据放宽铁律”。

