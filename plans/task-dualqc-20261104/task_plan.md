# Task Plan: 双轮质检机制：执行子代理自审+新子代理升格模型二次复检（提示词简洁直接）
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} token 由 init-session.sh render_template() 脚本渲染（task-id/任务名/日期/路径）；尖括号中文占位=模型填写面，脚本禁碰 -->
<!-- ===== frontmatter 头（Rule 16 选模板 + Rule 34.1 门控 + Rule 38.7 执行通道分级）=====
  选定 variant 后 template_type 填所选类型名（白名单=/home/terry/.zcode/skills/task-planner/templates/variant/*-type.md 动态派生，见 check-template-type.sh）；general=通用回退（恒合法，Rule 34.1）
  plan_tier ∈ {standard, mini}（Rule 38.1，mini 四条件机器判定）；execution_lane ∈ {L0, L1, L2}（Rule 38.7，缺省 L1；L0 禁滥用见 38.7 末段）
  check-template-type.sh 三形态之一：行首 `^template_type:`（本块）/ 表格行 / HTML 注释；本块用行首形态 -->
template_type: general
plan_tier: standard
execution_lane: L1
parallel_groups: pg-tpl, pg-review

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：Rule 51.1 计划侧载体（审计 H-3 清账）。R 行=用户原话逐条编号抄录；映射=每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉（51.1/51.2） -->
<!-- 2026-10-07 task-v143：Rule 58.4 手段/目标二分——每条 R 行末尾标注 [手段] 或 [目标]；[目标] 行必须映射 ≥1 条「问题解决判据」VC（核心问题的可观察解决证据，非手段产物完成）；目标型任务终验必填「🎯 核心目标达成裁决」区块（58.5） -->

- **R1**: 「执行完成之后……可以设置两道检核，审核机制，就是子代理自身对执行任务的执行度，然后进行审核」<sub>（[目标]：第一轮=执行体自审）</sub>
- **R2**: 「审核完成之后，交给主代理，然后……成果，然后再次派新的子代理……去处理，再次检测一次」<sub>（[目标]：第二轮=主代理派全新子代理独立复检）</sub>
- R3: 「所有的质量检测不应该全部由……子代理自身去执行，因为子代理可能会因为上下文污染之类的导致检测结果出现偏移。但是我希望是可以通过新的子代理再次检测一次」<sub>（[目标]：复检体必须独立上下文）</sub>
- **R4**: 「在第二轮的质量检测的时候，采取更加更高的模型档位来处理任务」「升格模型，但是不做复杂的……在二次检测中使用的提示词，包含……更直接的内容……减少走弯路的可能性」「更简洁。更直接」<sub>（[目标]：复检体升格档位+提示词简洁直接+低资源高效）</sub>
- **R5**: 「我希望可以同步修改，因为这个涉及同步修改相关的技能以及技能模板」「从当前技能的底层，比如说规范流程以及相关的模板的全部更新，同步到这个这种模式」<sub>（[手段]：技能规范+模板全量同步承载该机制）</sub>
- **R6**: 「修改涉及多个文件修改，但是遗漏了其中一两个，那么后期这就是一个严重的事故」「每次执行完成都需要做一次相关文档的同步……同步修改了，以及这些东西的审查，这才是……核心的问题」「我希望达到的就是每次修改完之后都可以审查，审查是否进行同步修改、同步纠正，确保没有说遗漏的地方」「最核心的就是每一轮修改之后都做同步审查，而不是说……其中一部分修改完了，另一部分没有修改」<sub>（[目标]：每轮修改后的同步完整性审查——多文件变更零遗漏）</sub>
- **R7**: 「这个任务可能说……并不是一个非常复杂的任务，我希望只需要……派委派一个一般的……agent他去解决就可以，不需要去消耗高档模型」<sub>（[手段约束]：本任务执行通道用一般档 agent，禁高档模型消耗）</sub>
- **R8**: 「与这个文件的写入应该是在前后脚的问题。那么是否可以将这两个……功能合并，也就是说先写入这个文件，然后再执行计划任务的同步」「帮我分析一下是否有冗余……这两个任务明显的就可以通过前后脚的步骤执行，应该是可以通过合并，然后得到一个更加简洁的直接执行方案」「我需要的是……方案的简化，而不是说方案功能的缺失」「合并在一个体系内……执行」<sub>（[目标]：新指令收口统一序列——逐字落盘与计划同步合并为单入口定序流程，简化零缺失）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-3 | 规则条款含自审子条（grep 命中）+ 派发模板含自审段（grep 命中+路径） |
| R2 | VC-1, VC-2, VC-3 | 规则条款含独立复检子条 + 84.7 指针 + 派发模板复检段（grep 命中） |
| R3 | VC-1, VC-2 | 复检体=全新子代理/独立上下文措辞在规则与 84.7 衔接中（grep 命中） |
| R4 | VC-1, VC-3 | 升档映射表（haiku→sonnet/sonnet→重档/重档封顶）+ 复检任务书简洁直接四要素禁令（grep 命中） |
| R5 | VC-2, VC-3, VC-4, VC-5, VC-6, VC-7 | 规则/接线/模板/守护/回归/部署全链证据 |
| R6 | VC-9, VC-10 | 同步完整性审查条款在位（103.6 关联面推导+核对清单+每轮门控 grep 命中）+ 模板承载（复检输入含核对清单/模板声明区块 grep 命中） |
| R7 | VC-6 | 流程约束判据（R7）：终验时与 VC-6 复验同程核对「📊 委派统计表+Handoff 登记表档位列」——全任务执行档 ≤中档 sonnet-1/haiku-1、零重档消耗登记在案 |
| R8 | VC-11 | SKILL.md「用户新指令处理」段含新指令统一收口序列行（①逐字落盘→②判定→③计划同步→④Todo S5→⑤103.6 衔接，grep 命中+顺序字面在位）；冗余分析结论落 findings |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
- **专档路径**：`plans/task-dualqc-20261104/user-session-log.md`（模板 = /home/terry/.zcode/skills/task-planner/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 派发（任务书制作） | 任务书无自审要求，执行体不申报执行度即返回 | 派发模板自审段（S5） | VC-3 |
| 返回（主代理验收） | 仅有 V-N 机器门+主进程 Read 抽查，无与执行上下文隔离的语义复检轮 | Rule 103 第二轮（S1） | VC-1 |
| 模型档位 | 复检无升档口径，复检质量上限受执行体档位钳制 | 96.2 衔接+升档映射（S1/S2） | VC-1, VC-2 |
| 复检成本 | 复检任务书无简洁直接约束，升格模型+长提示词放大 token 消耗 | 复检任务书四要素+禁令（S1/S5） | VC-1, VC-3 |
| 计划期 | 计划不声明质检模式，双轮机制无法在计划阶段被设计进任务书 | task_plan 模板声明行（S6） | VC-3 |
| 守护 | 新条款无机器面回归，措辞可被后续任务无声漂移 | selftest-dual-qc.sh（S7/S8） | VC-5, VC-6 |
| 部署 | 三部署位不同步则新会话不生效（机制停留在源仓） | 部署门 diff=0（S12/S13） | VC-7 |
| 同步（多文件变更收口） | 多文件修改遗漏一两处=后期严重事故（用户点名痛点，R6） | Rule 103.6 同步完整性审查（关联面推导+核对清单+每轮修改后门控） | VC-9, VC-10 |
| 守护（同步面） | 同步审查机制自身无机器面回归，措辞可被漂移 | selftest-dual-qc 断言扩展含 103.6 | VC-9, VC-5 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | ① Goal 与 R1-R5 原文；② VC 表 8 条；③ 派发模板 §7 八字段返回契约不增删（task-v161 契约，调研锚 templates/subagent_dispatch.md L72）；④ 纪元顶锚 11x 窗不回退（R8-b 008e680 预放宽）；⑤ 卫星分层纪律：新规则落 task-dispatch 卫星、禁镜像副本进核心（Rule 82） | 本文件对应区块 |
| 🔀 可变量 | S-unit 拆分粒度/工序排期/审查子代理选型/纪元注释链随动的具体文件清单（grep 驱动） | - |
| 📈 学得量 | 执行期发现的锚级联新形态/attest 校验形态→findings.md；禁反向改写不变量 | findings.md |

## Goal
在 task-planner 技能层固化双轮质检与同步完整性机制（Rule 103：① 派发型 S-unit 执行体完成即自审执行度；② 主代理派全新子代理以升格一档的模型、简洁直接的复检任务书做独立复检；③ 每轮多文件修改后强制同步完整性审查——关联面推导+核对清单，确保零遗漏），并同步落地规则条款、卫星接线、派发/计划模板、机器守护与三部署位，使机制自新会话起默认生效。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（含 1 个新 .sh 守护脚本+多文件规则文本，按仓库惯例过 CR）；**CR 门承载登记（Rule 42.2 替代形态）**：S9 general-reviewer 对齐审查 APPROVED + S10 critic 挑刺 7 项 MAJOR 全闭环（13/14 检查点报告）+ S11 复验回归 95/95 零 FAIL——双独立视角审查+闭环复验即 CR 门实证，不再另跑 code-review skill（文档+守护脚本型 diff，机器面 DQ 14 断言在位） |
| `session_id` | `a840963a-0d72-44d8-a685-96f67a78763d` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-dualqc-20261104` |
| `scope_files` | 见「⚠️ 执行范围限制」 |
| `interaction_mode` | `ask`（缺省回落 config.json） |
| `对齐审查` | `[登记]`：终验前跑 alignment-review 对齐审查（Phase 5 S9 承载）；文档更新前版本一致性校验 |
| `自动超时默认项` | `[询问点: D1 计划确认=默认按已展示计划执行/5min]`；执行期 2+ 选项询问点一律按 44.2 低区分度裁决+登记，仅 G1-G4 门与破坏性动作等用户 |
| `new_rule` | `103` |
| `质量审查工具` | `[登记]`：规则文本审查=既有 agent `general-reviewer`（sonnet-1）+ `critic`（挑刺视角）；对齐审查=既有 skill `alignment-review`；无需补建（42.2 检测结论：池内工具覆盖） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）
> **验证独立性**：本计划验证动作默认由独立子代理执行（Executor 字段可填 V-类执行体），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 103 条款在 task-dispatch 卫星全文在位：含六子条（自审契约/独立复检契约/升档映射/复检任务书简洁直接四要素/豁免面/FAIL 闭环） | grep 断言 | `grep -n "103\." /mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md` 命中 ≥6 子条锚；升档映射含 haiku→sonnet、sonnet→重档、重档封顶三形态字面 |
| VC-2 | 双向接线在位：task-dispatch 96 区含复检升档衔接；verification-gate Rule 84.7 块含 Rule 103 指针行 | grep 断言 | `grep -n "Rule 103" <verification-gate>/references/critical-rules-verification.md` 与 `grep -n "103" <task-dispatch>/references/critical-rules-dispatch.md`（96 区）均命中 |
| VC-3 | 模板承载在位：templates/subagent_dispatch.md 含「第一轮自审」与「第二轮独立复检」段（含升档映射与简洁直接禁令）；templates/task_plan.md 含双轮质检声明行 | grep 断言 | 两模板各自 grep 命中新段锚；§7 八字段契约字面零改动（`git diff` 不触 §7 行） |
| VC-4 | SKILL.md 接线与计数随动：`1-102→1-103`、`其余 85 条→其余 86 条`、纪律/派发域枚举含 103、Phase 执行循环含 103 指针行 | grep 断言 | `grep -n "1-103\|86 条" <root>/skills/task-planner/SKILL.md` 命中；Phase 循环区 grep "Rule 103" 命中 |
| VC-5 | 新守护在位且自证：scripts/selftest-dual-qc.sh 全部断言 PASS + selftest-registry.tsv 含其登记行 | 运行命令 | `bash scripts/selftest-dual-qc.sh` exit 0；`grep -c "selftest-dual-qc" scripts/selftest-registry.tsv` = 1 |
| VC-6 | 全量回归零 FAIL：fresh 环境跑 run-selftests.sh，ΣFAIL=0（脚本数 94→95） | 运行命令 | worktree 内 `bash scripts/run-selftests.sh` 输出 ΣFAIL=0（合并回后主仓复跑一次同口径） |
| VC-7 | 三部署位同步：zcode/claude（git 位）与 cursor（落盘位）关键文件与源仓 diff=0；zcode/claude 两仓提交后 ahead=0 | diff+git 断言 | 对每变更文件 `diff <部署位>/<同路径> <源仓>/<同路径>` 全空；`git -C ~/.zcode status --short -- <相应 pathspec>` 干净且 push 后 ahead=0；claude 位同口径 |
| VC-8 | master 合并在位且隔离区清理：master 含本任务 merge commit；worktree 与 wt/* 分支已删除；rule-reserve 账本 103=landed | git 断言 | `git -C /mnt/data/dev/task-planner-skill log --oneline -3` 含 merge；`git worktree list` 无本任务残留；`tail plans/.rule-reservations.jsonl` 含 `{"rule":103,...,"status":"landed"}` |
| VC-9 | 同步完整性审查条款在位：Rule 103 含同步审查子条（每轮修改后触发+关联面推导四族=同族字面/引用面/部署镜像位/纪元级联+核对清单门+多文件变更集强制） | grep 断言 | `grep -n "同步完整性\|核对清单" <task-dispatch>/references/critical-rules-dispatch.md` 命中 103.x 子条锚 |
| VC-10 | 同步审查模板承载：复检任务书形态含「同步核对清单」输入项（多文件 S-unit 时）；task_plan 模板声明区块含同步完整性审查声明与关联面推导提示 | grep 断言 | 两模板各自 grep 命中「同步核对清单/同步完整性」锚 |
| VC-11 | 新指令统一收口序列在位：SKILL.md「🆕 用户新指令处理」段含统一收口序列（① 逐字落盘 user-session-log（80.1/80.7）→ ② D/A/B/C/E 判定 → ③ B/C/D/E 计划文档同步 → ④ Todo S5 → ⑤ 修改轮衔接 Rule 103.6），两义务单入口定序、零删除既有义务 | grep 断言 | `grep -n "统一收口序列" <root>/skills/task-planner/SKILL.md` 命中且同段含 user-session-log 与 103.6 引用；既有 D/A/B/C/E 表行 diff 零删改 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：`code_review: required`，终验前必须先通过 Code Review Gate（详见 SKILL.md），否则不得标记 COMPLETE。

## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1、R2、R3、R4 |
| **裁决** | `solved` |
| **解决证据锚** | ①双轮质检机制在位=skills/task-dispatch/references/critical-rules-dispatch.md:215 起 `### 103`（103.2 自审/103.3 独立复检/103.4 升档封顶/103.5 四要素）→R1/R2/R4；②独立上下文复检=103.3「全新子代理……零共享上下文」+复检实战（S9/S10 双审查=APPROVED+7 意见闭环）→R3；③同步完整性=103.6 每轮修改后关联面推导+核对清单门+VC-9/VC-10 模板承载→R6；④机器面=selftest-dual-qc DQ 14/14+全量回归 95/95 两腿（VC-5/6）+部署三位置 diff=0（VC-7） |
| **未解决面+原因** | 无（S10 critic 7 项意见已全部闭环：行为条款增量修复，运行时机器门按比例原则以「主进程翻转门自核+selftest 文本守护」承载并登记） |
| **已排除路径** | 不适用（solved） |
| **下一步建议** | 行为面冒烟：新会话实测 103 双轮质检与统一收口序列的实际触发（agent 定义未改，机制经任务书注入生效，建议下个真实任务观察一轮） |

> 纯手段型任务可填 `n/a（纯手段型任务）`——本任务含目标型需求（R1-R4），不适用裸豁免。

## 🎯 Goal 单元表（Rule 66.1 — 规划获批后任务单元固化；standard 必填）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 规则落地 | Rule 103 八子条落 task-dispatch 卫星尾部（双轮质检+同步完整性审查） | `grep -n "103\." skills/task-dispatch/references/critical-rules-dispatch.md` ≥8 命中 | S1/Phase 2 | complete |
| G2 | 双向接线 | 96.2 升档衔接+84.7 指针+SKILL.md 计数/枚举/循环指针+新指令统一收口序列 | 两卫星与 SKILL.md grep 命中（VC-2/VC-4/VC-11 命令） | S2/S3/Phase 2 | complete |
| G3 | 派发模板 | 派发模板含自审+复检+同步核对清单段且八字段契约零动 | `grep -n "自审\|独立复检\|同步核对" templates/subagent_dispatch.md` 命中；§7 diff 空 | S5/Phase 3 | complete |
| G4 | 计划模板 | task_plan 模板含双轮质检与同步完整性声明区块 | `grep -n "双轮质检\|同步完整性" templates/task_plan.md` 命中 | S6/Phase 3 | complete |
| G5 | 机器守护 | selftest-dual-qc.sh 全 PASS+registry 登记（断言含同步完整性条款） | `bash scripts/selftest-dual-qc.sh` exit 0；TSV 行=1 | S7/Phase 4 | complete |
| G6 | 全量回归 | fresh run-selftests ΣFAIL=0（95 脚本） | worktree+主仓两次 `bash scripts/run-selftests.sh` 输出 ΣFAIL=0 | S8/Phase 4 | complete |
| G7 | 双审查 | 对齐审查+critic 审查通过且意见闭环 | 两审查报告路径+意见处置清单（progress.md） | S9/S10/Phase 5 | complete |
| G8 | 合并部署 | master merge+三部署位 diff=0+账本 land+归档 | VC-7/VC-8 命令输出 | S11-S15/Phase 6 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则文本 | `skills/task-dispatch/references/critical-rules-dispatch.md`、`skills/verification-gate/references/critical-rules-verification.md`（worktree 内副本） | 其他卫星规则文件、核心 critical-rules.md |
| 技能主线 | `skills/task-planner/SKILL.md`（worktree 内副本） | 其他技能 SKILL.md |
| 模板 | `skills/task-planner/templates/subagent_dispatch.md`、`skills/task-planner/templates/task_plan.md`（worktree 内副本） | 其他模板文件 |
| 脚本 | `skills/task-planner/scripts/selftest-dual-qc.sh`（新增）、`skills/task-planner/scripts/selftest-registry.tsv`（+1 行）、纪元注释链随动清单（`skills/task-planner/scripts/*.sh` 内 grep 驱动的纯注释行，S4 产清单登记 progress 后才可动） | 任何断言逻辑改动、任何 scripts/ 新增脚本 |
| 部署位 | `~/.zcode/skills/`、`~/.claude/skills/`、`~/.cursor/skills/` 中与本任务 scope 同路径文件（仅同步） | 部署位其他文件、memories/、agents/ |
| 计划目录 | `plans/task-dualqc-20261104/**` | 其他计划目录（含 task-crossprojauth-20261104 残留——旧任务遗留，不动） |

**执行前自我检查:**
- [ ] 这个文件在上面的列表中吗？
- [ ] 这个修改对完成任务有必要吗？
- [ ] 用户明确要求我做这个修改吗？
- 全部 Yes → 可以执行 | 任一 No → 先问用户（问询按 Rule 70 四要素）

## 📋 变更标注表（Rule 74.3 — 修订方案必填，无表=无效方案）
任何对既有文件/条目的变更，制定方案时在此逐条登记；本表兼任验收清单（执行后逐行勾核，新增而产物缺失/增量而旧内容被改=FAIL）。用户新指令到达时先转标注行再动任何文件——先标注后执行。

| 编号 | 对象（文件+锚点） | 类型 | 吸收判定 | 用户原话（逐字摘录） | 依据（证据） | 执行动作 |
|------|------------------|------|-----------|----------------|---------|---------|
| CA-1 | skills/task-dispatch/references/critical-rules-dispatch.md 尾部（Rule 96 块后） | 新增 | 增量（既有条目零改动） | 「增加一轮质量检测」「升格做，升格模型」「每一轮修改之后都做同步审查」 | 调研锚 §3（96 尾 L214） | 追加 Rule 103 标题（双轮质检与同步完整性审查）+103.1-103.8 八子条（含 103.6 同步完整性审查） |
| CA-2 | 同文件 96.2（L206 档位梯子） | 修改 | 增量（96.2 原文零改动，其后追加衔接行） | 「采取更加更高的模型档位」 | 调研锚 §3 | 追加一行复检档位映射指针（引 Rule 103） |
| CA-3 | skills/verification-gate/references/critical-rules-verification.md 84.7 块（L46-52） | 修改 | 增量（84.7 原文零改动，块内追加指针行） | 「再次派新的子代理……再次检测一次」 | 84.7.2 L48 全新上下文先例 | 追加 Rule 103 指针行（含同步完整性审查面） |
| CA-4 | skills/task-planner/SKILL.md L9/L210/L253 计数与枚举 | 修改 | 增量（计数窗演进 1-102→1-103、85→86 条、枚举追加 103；仓库级联 SOP 既定动作，非内容替代） | 「同步修改相关的技能」 | 级联 SOP 先例 008e680 | 字面随动（CA-5 同批） |
| CA-5 | skills/task-planner/SKILL.md Phase 执行循环（L78-104 区）+终验段（L107-118 区）+「🆕 用户新指令处理」段（L164 区） | 修改 | 增量（步骤后追加指针行；新指令段追加统一收口序列行，既有 D/A/B/C/E 表行零删改） | 「审核完成之后，交给主代理……再次检测」「每次执行完成都需要做一次相关文档的同步」「先写入这个文件，然后再执行计划任务的同步……合并在一个体系内执行」 | 调研锚 §6+L164 现状 grep（两机制分散无定序实证） | 步骤 3 区追加 Rule 103 双轮质检指针行；步骤 4（Phase 翻转前）追加多文件变更同步核对指针行；新指令段追加「统一收口序列」行（CA-11 详） |
| CA-6 | skills/task-planner/templates/subagent_dispatch.md（§3 验收 L49 后） | 新增 | 增量（§1-§10 既有段零改动，§7 八字段契约字面零动） | 「子代理自身对执行任务的执行度进行审核」「第二轮……提示词……更简洁。更直接」「确保没有说遗漏的地方」 | 调研锚 §2 | 插入「🛡 双轮质检与同步完整性（Rule 103）」段：自审指令块+复检任务书形态（四要素+禁令+升档映射）+多文件变更同步核对清单输入项 |
| CA-7 | skills/task-planner/templates/task_plan.md | 新增 | 增量（既有表格 schema 零改动） | 「在计划阶段就设计两轮的检测机制」「每一轮修改之后都做同步审查」 | R5/R6 | 追加「🛡 双轮质检与同步完整性」声明区块（适用面+关联面推导提示+豁免登记位） |
| CA-8 | skills/task-planner/scripts/selftest-dual-qc.sh | 新增（新文件） | 增量 | 「通过更多的检测以及认证来确保产出质量稳定性」 | 仓库守护 SOP（registry T02/T03 双向守护） | 新建守护脚本（断言 CA-1~CA-7 产物在位，含 103.6 同步条款断言） |
| CA-9 | skills/task-planner/scripts/selftest-registry.tsv | 修改 | 增量（追加 1 行） | 同上 | registry 契约 | 登记 selftest-dual-qc.sh 行 |
| CA-10 | skills/task-planner/scripts/*.sh 纪元注释链（grep 驱动清单） | 修改 | 增量（纯注释字面随动 1-102→1-103 形态族；断言零改动；清单登记 progress 后才可动） | 「同步修改」（级联 SOP） | 级联 SOP 先例 008e680「十位窗字面族全仓随动」 | executor 子代理机械批量+抽样复核 |
| CA-11 | skills/task-planner/SKILL.md「🆕 用户新指令处理」段（L164 表格前） | 新增 | 增量（既有 D/A/B/C/E 表与 E 类判定零删改；仅追加统一收口序列行） | 「先写入这个文件，然后再执行计划任务的同步」「方案的简化，而不是说方案功能的缺失」 | 冗余分析（findings Technical Decisions 2026-11-04 第三行）：两义务分散承载（G9/Rule 80 vs L164 段+hook plan-note），无定序锚=漏写 session-log 或漏同步计划的整合缺口 | 追加「新指令统一收口序列」一行：① 逐字落盘（80.1/80.7）→② 判定 →③ 计划同步 →④ S5 →⑤ 103.6 衔接 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）
| 类别 | 名称/主题 | 定位（路径/版本） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规则文本 | Rule 103 落点锚：task-dispatch 尾部插入位已核（96 块后）；84.5 L42/84.7.2 L48 先例已核 | /mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md | 必读 | ☑ |
| 项目内部 | verification-gate 规则全文（84.5 L42 独立子代理先例；84.7.2 L48 内容审查门先例） | /mnt/data/dev/task-planner-skill/skills/verification-gate/references/critical-rules-verification.md | 必读 | ☑ |
| 项目内部 | 派发模板全文（§3 L49/§7 L72 八字段/§8 L95 checkpoint） | /mnt/data/dev/task-planner-skill/skills/task-planner/templates/subagent_dispatch.md | 必读 | ☑ |
| 项目内部 | SKILL.md 接线点（L9/L78/L97/L164/L206/L210/L253） | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md | 必读 | ☑ |
| 项目内部 | selftest 体系（registry.tsv 列契约+run-selftests.sh 入口；基线 94/94 已跑通） | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-registry.tsv | 必读 | ☑ |
| 项目内部 | worktree 隔离合约 | /home/terry/.zcode/skills/task-planner/references/worktree-isolation.md | 参考 | ☐ |
| 项目内部 | 调研检查点（子代理产出全景） | plans/task-dualqc-20261104/subagent-state/01-explore-qc-landscape.md | 必读 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）
**核心问题**: 子代理执行产出的质检当前仅有机器 V-N 门+主进程 Read 抽查+终验内容审查，缺一道与执行上下文隔离的独立语义复检轮，且复检无模型升格与提示词简洁化口径；同时多文件修改存在「部分修改部分遗漏」的同步完整性盲区（用户点名痛点：遗漏即后期严重事故）——需要把「自审+独立复检升格+简洁直接+每轮修改后同步完整性审查」固化为技能层计划期即设计的标准机制。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（机制经规则+接线+模板+守护+部署落地即交付）
- [x] 核心问题不解决，其他工作都白费吗？（用户点名痛点=质检全压在执行体自身上下文，产出质量稳定性无独立保障）
- [x] 核心问题的解决方法是清晰的、可执行的？（调研已完成：载体/锚点/零级联结论全部在位）

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）
| S-unit/子目标 | 三态 | 检索关键词 | 检索渠道 | 预期产出形态 | 网络解难评估 |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| S1-S10 全部 | LOCAL-ONLY | 本仓规则文本/模板/自检脚本 | 本仓文件+已落盘调研检查点 | 规则与模板文本 | 不适用（制度文本工程，无外部事实依赖） |

> 豁免声明：本任务为纯本地制度文本工程，无 NET-* 条目；计划期调研已由 01-explore 子代理完成并落盘检查点（LOCAL-ONLY 判据=全部素材在仓内）。

## 🔍 证据面清单（Rule 58.1）
`n/a（纯执行类：制度文本落地任务，无归因结论产出；机制有效性由 VC-5/VC-6 回归证据承载）`

## Current Phase
Phase 6

## Next Step
S12 主仓 merge --no-ff + 主仓回归复验 → S13 三部署位同步 diff=0 → S14 land 103+簿记 → S15 归档 → S16 交付总结

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | 机械守卫脚本（rule-reserve/run-selftests）+ git | 白名单①② 编排 |
| Phase 2 | 主进程（S1-S3）+ Agent executor(haiku-1)（S4） | 规则文本锚级联精度要求主进程；S4 为机械批量适用 executor |
| Phase 3 | Agent general-coder(sonnet-1) ×2 | 模板段编辑，brief 内联精确插入锚与文本 |
| Phase 4 | Agent general-coder(sonnet-1)（S7）+ 主进程跑回归（S8） | 脚本编写派发；机械跑脚本主进程 |
| Phase 5 | Agent general-reviewer(sonnet-1) + critic 并行 | 独立视角双审查 |
| Phase 6 | 主进程 git/部署编排 | 白名单①② git 编排+簿记 |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8 激活条件（无 ≥3 独立 S-unit fan-out 需求、非长链编排、用户未点名 /workflow）→ Rule 21.4 独立性守门调度（并行默认+声明制，parallel_groups=pg-tpl/pg-review 已声明）
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 证据源；用户未用 /goal 锚定

## Phases

### Phase 1: 预留与隔离基线
- [x] `bash scripts/rule-reserve.sh check 103` 确认编号空闲（attest 时自动 reserve，land 在 Phase 6）
- [x] 创建 worktree：`git worktree add /mnt/data/dev/task-planner-skill-worktrees/task-dualqc-20261104 -b wt/task-dualqc-20261104 master`；创建后对账关键文件与主仓一致（worktree-branch-desync 教训）
- [x] worktree 内跑基线回归 `bash scripts/run-selftests.sh` 输出 ΣFAIL=0（预改基线）
- [x] 技术方案细节（Rule 103 八子条逐条文本设计要点）落 findings.md
- [x] 知识储备必读项确认可获取（勾「必要知识储备」表）
- **V-N:** VC-6（基线 ΣFAIL=0）, VC-8（worktree 建成前置态登记）
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+编号账本机械操作——Rule 25.3 白名单）

### Phase 2: 规则条款与双向接线
<!-- S1-S3 派发 general-coder（主进程直写 skills 被 delegation 守卫拦截——2026-11-04 实测，白名单仅 plans/ 路径；改派亦符合 R7 一般档要求）；S4 注释链批量=主进程白名单①机械 Bash 批量（grep 清单驱动+逐文件 diff 复核+Batch Report 门控） -->
- [ ] S1（general-coder 派发）：Rule 103 八子条落 task-dispatch 卫星尾部（103.1 定义与适用面/103.2 第一轮自审契约/103.3 第二轮独立复检契约/103.4 升档映射与封顶/103.5 复检任务书简洁直接四要素/103.6 同步完整性审查/103.7 豁免面与成本约束/103.8 FAIL 闭环与冲突仲裁）
- [ ] S2（general-coder 派发）：96.2 后追加复检升档衔接行；verification-gate 84.7 块内追加 Rule 103 指针行
- [ ] S3（general-coder 派发）：SKILL.md 计数随动（1-103/86 条/枚举+103）+ Phase 执行循环与终验段加 103 指针行 + 「🆕 用户新指令处理」段追加统一收口序列行
- [ ] S4（主进程，白名单①机械 Bash 批量）：纪元注释链随动（grep 驱动清单→逐文件目标替换+diff 复核，Batch Report 门控，清单登记 progress 后才可动）
- **V-N:** VC-1, VC-2, VC-4, VC-9
- **Status:** complete
- **Executor:** general-coder（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | Rule 103 八子条落卫星尾部 | general-coder | findings.md「Rule 103 设计稿」段（逐字转录蓝本）+worktree dispatch 文件尾部锚 | `grep -c '^103\.[1-8]'`=8+既有行零改动 | 15min | 1f/20l/15min | 无 | - | pending |
| S2 | 96.2 衔接行+84.7 指针行 | general-coder | findings.md「接线文本蓝本」前两条+两文件锚 | 两卫星 grep 命中 | 10min | 2f/4l/10min | 无 | S1 | pending |
| S3 | SKILL.md 计数/枚举/循环+终验指针+统一收口序列随动 | general-coder | findings.md「接线文本蓝本」后三条+SKILL.md L9/L210/L253/L78/L107/L164 锚 | VC-4/VC-11 grep 命中 | 10min | 1f/10l/10min | 无 | S1 | pending |
| S4 | 纪元注释链随动批量 | 主进程（白名单①机械 Bash 批量，非 Agent 派发） | grep 驱动清单（progress 登记） | 清单文件逐行 diff=预期字面+抽样 ≥3 复核 | 15min | 0f/0l/15min | 无 | S3 | pending |

<!-- S-unit 派发单元表(Rule 22.6) 机器契约：ID 纯数字/时长裸 NNmin/粒度三值 ≤2f/≤100l/≤15min -->

### Phase 3: 模板双轮质检段落地
- [x] S5：subagent_dispatch.md 插入「🛡 双轮质检与同步完整性（Rule 103）」段（自审指令块+复检任务书形态+多文件变更同步核对清单输入项）
- [x] S6：task_plan.md 模板追加「🛡 双轮质检与同步完整性」声明区块（适用面+关联面推导提示+豁免登记位）
- [x] S5/S6 产出主进程逐行 Read 复核+§7 八字段契约零动核验+既有表格 schema 零动核验
- **V-N:** VC-3, VC-10
- **Status:** complete
- **Executor:** general-coder（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S5 | 派发模板插双轮质检+同步核对段 | general-coder | templates/subagent_dispatch.md（§3 L49 插入锚+CA-6 全文文本随 brief 内联） | 新段 grep 命中+§1-§10 既有行 diff 空+§7 零动 | 15min | 1f/50l/15min | 无 | S1 | pending [parallel-group:pg-tpl] |
| S6 | 计划模板加声明区块 | general-coder | templates/task_plan.md（插入锚随 brief 内联+CA-7 文本） | grep -e 双轮质检 -e 同步完整性 命中+模板既有区块与表格 schema diff 空 | 10min | 1f/12l/10min | 无 | S1 | pending [parallel-group:pg-tpl] |

### Phase 4: 守护脚本与全量回归
- [x] S7：编写 scripts/selftest-dual-qc.sh（断言 CA-1~CA-7 产物在位：规则八子条/双向接线/模板段/计数/升档映射/四要素禁令/103.6 同步完整性条款）+ selftest-registry.tsv 登记
- [x] S8：fresh 全量回归 `bash scripts/run-selftests.sh`（worktree 内）ΣFAIL=0
- **V-N:** VC-5, VC-6, VC-9
- **Status:** complete
- **Executor:** general-coder（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S7 | 守护脚本+registry 登记 | general-coder | 同仓最近 selftest 范例（selftest-anti-deferral.sh）+registry.tsv 列契约 | 脚本 exit 0+TSV 行=1 | 15min | 2f/90l/15min | 无 | S3, S5, S6 | pending |
| S8 | fresh 全量回归 | 主进程（机械执行脚本——白名单①机械操作） | run-selftests.sh 入口 | 输出 ΣFAIL=0 | 10min | 0f/0l/10min | 无 | S7 | pending |

### Phase 5: 双审查与意见闭环
- [x] S9：对齐审查（alignment-review 视角子代理）——规则/模板措辞与既有条款一致性
- [x] S10：critic 挑刺审查——机制漏洞（升档死角/豁免滥用/与 84.7 内容审查门重复面）
- [x] S11：意见闭环：MAJOR 以上逐条修复+复验；审查报告落 plan-dir
- **V-N:** VC-6, VC-1（审查确认条款完整后回归仍绿）
- **Status:** complete
- **Executor:** general-reviewer（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S9 | 对齐审查 | general-reviewer | 变更 diff+alignment-review 关注清单（brief 内联） | 审查报告落盘+意见清单 | 15min | 0f/0l/15min | alignment-review | S8 | pending [parallel-group:pg-review] |
| S10 | critic 挑刺 | critic(sonnet-1) | 变更 diff+Rule 103 全文（brief 内联） | 挑刺报告落盘+分级意见 | 15min | 0f/0l/15min | 无 | S8 | pending [parallel-group:pg-review] |
| S11 | 意见闭环修复 | 主进程（白名单②锚精度修复） | 两审查意见清单 | MAJOR 清零+复跑 selftest ΣFAIL=0 | 15min | 2f/40l/15min | 无 | S9, S10 | pending |

### Phase 6: 合并部署簿记归档
- [x] S12：worktree 全 VC 复验+git status 干净→主仓 `git merge --no-ff wt/task-dualqc-20261104`→Read 复验→清理 worktree+分支
- [x] S13：部署三位置：zcode/claude 位文件级 cp（禁整仓 add，pathspec 锁定）+cursor 位落盘；逐文件 diff=0 门；两位 git commit+push ahead=0
- [x] S14：主仓簿记 commit+`rule-reserve.sh land 103 task-dualqc-20261104`+memory 记忆更新
- [x] S15：`set-active-plan.sh --clear`→`archive-plan.sh task-dualqc-20261104`→`sync-todos.sh --index`
- [x] S16：交付总结（delivery-summary 五要素）
- **V-N:** VC-7, VC-8
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+部署编排+簿记——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号① 未提交 3 文件=旧任务 crossprojauth 残留 attestation+会话草稿+本计划目录，与本任务 scope 零重叠，不处置；信号③ 遗留分支 wt/task-v168-machine-parked=他人任务遗留，不清理不动） |
| `isolation` | `worktree`（保护区 skills/** 命中 §11.1 第 1 条，强制隔离） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-dualqc-20261104`（§11.2 集中目录规范） |
| `branch` | `wt/task-dualqc-20261104`（自 master 创建） |
| `merge_back` | `merged(1e705db)`（worktree 已 remove、wt/task-dualqc-20261104 已删；源仓已 push 7d48161..1e705db） |

> 契约详见 `/home/terry/.zcode/skills/task-planner/references/worktree-isolation.md`。

## 📊 FMEA 预演（规划期）
| Phase | 失败模式 | S | O | D | RPN | 预设兜底动作（RPN>100 必填） |
|-------|---------|---|---|---|-----|------------------------------|
| Phase 2 | 计数/枚举字面随动漏网触发守卫 FAIL（锚级联） | 6 | 5 | 4 | 120 | 22.3② 改前 grep 全仓旧字面清单驱动逐文件修；同法 ≥2 败→主进程接管（22.3④） |
| Phase 2 | attest 校验拒锁（S-unit 表契约形态不符） | 5 | 4 | 2 | 40 | 按 attest 报错逐条修表形态后重锁 |
| Phase 3 | 模板插入位置锚漂移（模板行号与调研快照不一致） | 5 | 4 | 3 | 60 | 子代理 brief 内联插入锚文本+主进程逐行 Read 复核；漂移即停回报 |
| Phase 4 | selftest 断言与纪元窗形态不匹配误报 | 5 | 3 | 3 | 45 | 对照 11x 窗形态族（008e680）写断言；FAIL 逐条归因 |
| Phase 6 | 部署位漂移方向误判（多位部署逐对 diff 判向教训复发） | 7 | 4 | 4 | 112 | 22.3② 逐对 diff 判向（crossprojauth R8 判例）；claude 位 pathspec 锁定禁整仓 add；diff≠0 即停定位不覆盖 |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填；RPN≤100 可留空。执行期实际失败仍走 Rule 22.3 完整兜底链。（AskUser/呈报按 Rule 70 四要素）

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-11-04 | sync-todos S1 已跑 |
| Phase 2 | ☐ |  |  |
| Phase 3 | ☐ |  |  |
| Phase 4 | ☐ |  |  |
| Phase 5 | ☐ |  |  |
| Phase 6 | ☐ |  |  |

> 契约详见 `/home/terry/.zcode/skills/task-planner/references/todo-sync.md`。

## Key Questions
1. 双轮质检的适用面与豁免面如何划定，才不违反「流程开销与变更体量成比例」（宪法 §四.6/Rule 38.7）？→ 103.1/103.6：默认适用=派发型实质产出 S-unit；豁免=L0-E 纯执行档/纯查询零产出类/mini 计划档/计划期显式登记豁免
2. 重档执行的复检如何升格？→ 103.4：升格封顶=重档；重档执行取同档独立上下文（独立性已消除污染增量），质量争议升级 decision-arbiter（GLM-5.3 强档裁决）
3. 自审结论承载面？→ 派发模板 §8 checkpoint 增自审段（§7 八字段契约零动，task-v161 契约保全）
4. 同步完整性审查与既有 Rule 74.3 变更标注表/越界自检的关系？→ 74.3 管「计划内」枚举面，越界自检查「不该改的改了」；103.6 管「计划外关联面漏改」（卫星镜像/部署位/引用面/纪元级联四族推导），三者互补零重复
5. 每轮修改后的同步审查由谁执行？→ 多文件变更集时随第二轮复检一并核验核对清单（同一复检体，不新增派发成本）；单文件小改由主进程翻转门自核（103.6 分级门控，控成本）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| Rule 103 载体=task-dispatch 卫星（非 verification-gate/非核心） | 模型档位权威梯子 96.2 在 task-dispatch（L206），机制触发点在派发流程；Rule 96 先例同域；核心域禁非核心规则回潮（Rule 82） |
| 自审指令经派发任务书注入，不改 agents/ 定义 | 用户授权范围=「技能以及技能模板」；agents/ 属 §六 保护区需另行授权；任务书注入即可达执行体行为面 |
| §7 八字段返回契约零改动，自审结论走 §8 checkpoint | task-v161 八字段契约「不得增删」是既有不变量；自审段为 checkpoint 必填节，不破契约 |
| 升档映射：轻档(haiku-1)→中档(sonnet-1)；中档→重档(GLM5.3/Opus 级)；重档封顶同档独立上下文 | 96.2 三档表既有词汇；22.3③「升一档，如 haiku→sonnet」先例措辞；重档无更高可升，独立性已贡献质量增量，争议走 decision-arbiter（既有裁决链） |
| 复检体选型走 Rule 52 specialist-first（代码→general-reviewer/Code Reviewer 系；全类型→general-reviewer；对抗挑刺→critic），model 显式升档指定 | Rule 52 执行体专业化优先既有纪律；避免新造 agent（§四.6 范围最小化） |
| 新增 1 个 selftest 守护脚本（非纯文本零守护落地） | 仓库既定 SOP：规则落地必带守护+registry 登记（94 脚本体系）；用户要求「更多检测以及认证确保产出质量稳定性」；守护断言只锚新产物在位，零新机器门收窄既有行为 |
| 双轮质检默认适用=派发型实质产出 S-unit，豁免面显式登记 | 用户要求机制默认生效（「同步到这种模式」）；同时以豁免面守住低资源原则（机械/查询类不过检，升格成本只花在实质产出上） |
| 部署三位置纳入本任务范围 | 用户原话「全部更新，同步到这种模式」=机制须对新会话生效；三部署位为该技能的运行载体（调研 §7） |
| 同步完整性审查并入 Rule 103（103.6），不另立 Rule 104 | 与双轮质检同属「修改轮次收口质检」语义域：103.6 复用第二轮复检体核验核对清单，避免两条规则两套触发点；Rule 20.6 编号账本单一占用 |
| 同步完整性审查定位=漏改检测（补 Rule 74.3 变更标注表的盲区） | 74.3 枚举的是「计划内」变更面；103.6 补「关联推导面」——计划外但同族联动的文件（卫星镜像位/部署位/引用面/纪元级联面），推导四族+核对清单+每轮修改后门控，两者互补不重复 |
| 本任务执行通道零高档消耗（R7） | 全部执行档 ≤中档：主进程编排+general-coder/general-reviewer/critic（sonnet-1）+executor（haiku-1）；升档映射只存在于交付的机制文本中，不用于本任务自身执行通道 |
| **[冗余分析结论 2026-11-04，R8]** 「新指令→同步更新计划」与「user-session-log 逐字写入」**功能不重复但承载分散**：前者改计划文档（执行视图），后者记原话（需求事实源），消费者不同不可互相替代（合并=功能缺失）；真缺口=两义务分散在 G9/Rule 80 与 SKILL.md L164 段+hook plan-note 三处、无定序锚，agent 须各自记得两件事→漏一即事故。方案=「新指令统一收口序列」单入口定序（①落盘→②判定→③计划同步→④S5→⑤103.6 衔接），CA-11 落 SKILL.md L164 段，零删除既有义务 | 用户 #3「先写入这个文件，然后再执行计划任务的同步」「合并在一个体系内执行」「要简化不要功能缺失」；本次会话 #1/#2/#3 实操即按此顺序执行（无重复劳动实证） |
| 旧任务 crossprojauth 残留（未归档+attestation 未提交改动）不纳入本任务 | Rule 8.1 不相干内容禁止混入；Rule 102.0 D 类处置=旧任务已 COMPLETE 无在途单元，残留另行处理 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
|       | 1       |            | → progress.md Error Log   |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-11-04 23:05 | ALIGNED（Phase1-3 合窗；drift-checker provider 拒→general-purpose 改派 22.3①） | VC-1~4/9/10/11 | 7 文件全在 scope 内零越界；progress/commit/grep 证据一致；Goal 对齐无夹带（检查点 08） |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6）
<!-- 适用=S4 纪元注释链批量（清单 ≥5 文件即命中批门）；其余 S-unit 非批量 -->
| 字段 | 值 |
|------|-----|
| `total` | 3 行/2 文件（S4 注释链批量，2026-11-04 22:47 执行） |
| `success` | 3 |
| `failed` | 0 |
| `failure_rate` | 0% |
| `sampled_pass` | 3（小批全抽） |
| `sampled_fail` | 0 |
| `pre_check` | Q1:否/Q2:有（git worktree 隔离）/Q3:能（git restore/revert） |
| `rollback_point` | commit 4371ac0 前=git restore；后=revert 单提交 |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 4 / 6（Phase 2/3/4/5 主体子代理派发；机器口径 delegated=4 main_direct=2 verdict=ok violations=0） |
| 主进程直做 Phase 清单 | Phase 1（① git 编排+编号账本机械）、Phase 6（① git/部署编排+簿记）——均 Rule 25.3 白名单；Phase 2 的 S4 与 Phase 4 的 S8 为主进程白名单①机械单元（Handoff 已登记） |
| 委派率 | 0.667（check-delegation.sh stats verdict=ok：两直做 Phase 均白名单内，violations=0；S-unit 面实际派发 10 体=01-explore/S1/S2/S3/S5/S6/S7/S9/S10/S11a，S11b 虚报由主进程兜底） |
| 激活子代理数（Rule 96.5） | 11（调研 1+执行 9+drift 改派 1；drift-checker 原通道 provider 拒未计入成功） |
| 最大并行宽度（Rule 96.5） | 2 组（pg-tpl / pg-review，最宽 2） |
| 串行化例外理由（Rule 96.4） | pg-tpl/pg-review 各自同消息并发；S1→S2/S3 同文件族串行；S2 与 S3 并发后登记教训=同 worktree 并发验收命令须 path 限定（findings Issues） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-11-04 | Explore | 质检机制全景+级联面调研 | done | 纪元锚零级联（11x 窗）；载体=task-dispatch；部署位 3 处 diff=0 | 见检查点 84 行 | findings.md §Research | subagent-state/01-explore-qc-landscape.md | - / 0 / ☑ |
| 2 | 22:30 | general-coder | S1 Rule 103 八子条落卫星尾部 | done | +23/-0 grep 全过；建制段按 96 房规补写（偏差登记采信） | dispatch:215-237 | findings §Rule103 设计稿 | subagent-state/03-general-coder-s1.md | - / 0 / ☑ |
| 3 | 22:38 | general-coder | S2 双向衔接行 | done | +31/-3 段内两文件纯插入；原文零改动盘上核清 | dispatch 96.2 后/vg 84.7 | findings §接线蓝本 | subagent-state/04-general-coder-s2.md | - / 0 / ☑ |
| 4 | 22:38 | general-coder | S3 SKILL.md 接线+统一收口序列 | done | +9/-3 计数/3h/翻转门/收口序列/终验衔接 | SKILL.md L9/L210/L253/L99/L164 | 同上 | subagent-state/05-general-coder-s3.md | 与 S2 同消息并发（同文件族 race 迹象已盘上核清，教训入 findings）/ 0 / ☑ |
| 5 | 22:52 | general-coder | S5 派发模板 3b 段 | done | +7/-0 逐字转录；§7 零动 | subagent_dispatch.md §3b | findings §模板设计 | subagent-state/06-general-coder-s5.md | pg-tpl 并发 / 0 / ☑ |
| 6 | 22:55 | general-coder | S6 计划模板声明区块 | done | +9/-0（自报 14 误报）；三派（契约缺项→KQ3→过） | task_plan.md:110-121 | 同上 | subagent-state/07-general-coder-s6.md | pg-tpl 并发 / 0 / ☑ |
| 7 | 23:16 | general-reviewer | S9 对齐审查 | done | APPROVED（①-⑥ 全过零 MAJOR） | 检查点 11 | progress P5 | subagent-state/11-alignment-review-s9.md | pg-review 并发 / 0 / ☑ |
| 8 | 23:16 | critic(sonnet-1) | S10 挑刺审查 | done | 7 项（6 MAJOR+1 minor） | 检查点 12 | progress P5 | subagent-state/12-critic-s10.md | pg-review 并发 / 0 / ☑ |
| 9 | 23:22 | general-coder | S11a Rule103 五处修复+模板澄清 | done | 6 处 grep=1+DQ 14/14 | 检查点 13 | findings Issues | subagent-state/13-general-coder-s11a.md | - / 0 / ☑ |
| 10 | 23:22 | general-coder | S11b 收口序列分支澄清 | done | **首报虚报（盘上 grep=0）→主进程补刀落盘** | SKILL.md:168 | findings Issues（虚报判例） | subagent-state/14-general-coder-s11b.md | 虚报拦截-修复闭环 / 0 / ☑ |

## 🔁 模板感知
<!-- template_type: general -->
<!-- task-v096 P2-S1: 运行时追加区块（非模板本体）; general=类型空缺兜底, 已知 16 类类型不产生本区块;
     上方注释行为 check-template-type 第三形态机读标记（general 恒合法, gate exit 0）, 同时完成 Rule 34.3② 预登记 -->
- 触发信号: 任务类型空缺 → 落 general 兜底（非 16 类已知类型之一）
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant；本次机制为规则+模板工程，若 34.3 三条件命中可评估沉淀「制度文本落地」variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 沉淀理由 / 不沉淀理由（二选一必填）→ 指向 plan-template-kit 卫星 SOP
