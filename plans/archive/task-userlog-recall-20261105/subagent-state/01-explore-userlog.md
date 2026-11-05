# 01-explore: user-session-log.md 写入面/读取面盘点（2026-11-05 subagent explore）

## ① Rule 80 子条清单（skills/task-planner/references/critical-rules.md，行号实测）
| 子条 | 行号 | 一句话 | 读/写 |
|---|---|---|---|
| 80.1 | L144 | 建档与记录范围：init 独立建档，用户全部需求/对话逐字落档，条目格式以模板为口径源 | 写 |
| 80.2 | L146 | 只写不改（append-only）：唯一合法写=文件尾追加，错=追加更正条目 | 写 |
| 80.3 | L148 | 写入时机与写入者：发言到达即落盘禁攒批；主进程单写，子代理只读不改 | 写 |
| 80.4 | L150 | 恢复协议：**会话中断/压缩/重启恢复时本文件=用户意图权威源，先读本文件再读 task_plan.md**，冲突以本文件为事实源 | **读（唯一读取触发，且仅限恢复场景）** |
| 80.5 | L152 | 与 attest 哈希锁边界：会话记录外置专档，task_plan 指针区块纯静态 | 机制 |
| 80.6 | L154 | 守护机制：init 复核 + check-complete SESSION-LOG GATE + selftest-session-log.sh，零新 config 键 | 写面守护 |
| 80.7 | L156 | 理解镜像：逐字条目同号配对镜像块（非权威对照面，回溯时对照定位理解偏差） | 写（"回溯对照"仅为 80.7 定位语，非强制读取动作） |

结论：**Rule 80 全体系无一条要求"在决策/对照时读取该文件"**——80.4 仅覆盖"会话恢复"场景；80.7 的"回溯对照"是镜像设计目的描述，无强制触发点。

## ② 写入触发点表
| 触发点 | 位置 | 时机 |
|---|---|---|
| init 建档 | skills/task-planner/scripts/init-session.sh L826-846,849-867 | 计划目录初始化（trivial 档按需） |
| 新指令统一收口序列① | skills/task-planner/SKILL.md L175 | 每次用户新指令到达，先逐字落盘（含 80.7 镜像） |
| 更正追加通道 | skills/context-corrector/SKILL.md L44（Rule 98.4） | 结论整理时 append-only 追加"更正 #N" |
| SESSION-LOG GATE 校验 | scripts/check-complete.sh L1349-1418 | 终验时查文件存在/非空/条目/baseline 漂移（读校验非消费） |
| 静态守护 | scripts/selftest-session-log.sh, selftest-dual-qc.sh DQ-10 | 守护面 |

## ③ 读取/消费触发点表（全仓 grep 判定）
| 读取触发点 | 位置 | 性质 |
|---|---|---|
| 80.4 会话恢复读序 | critical-rules.md L150；templates/user-session-log.md L25-27（恢复协议节）；execution-recall-card.md L43（恢复读序首项） | **强读，但仅限"中断/压缩/重启恢复"场景** |
| drift-checker SOP step 1"必读全部原话条目"（task-v172 CA-7） | skills/task-planner/companion/agents/drift-checker.md L22,L36 | **强读（子代理面）**；Rule 64.4 三锚①=用户原话锚双源 |
| 64.2.1 目标漂移定义 | critical-rules-drift.md L59 | 读（判定口径：Goal 与最近用户原话零交集=目标漂移，不可豁免） |
| 64.3 rhythm nudge 文案"复合审查=读全原话对照" | zcode-posttooluse.sh L378 | **弱读**——软提醒文案，读取动作落在 drift-checker 派发面 |
| D1 目标绑定确认"复述服务用户指令=最近一条原话" | SKILL.md L58 | **强读（计划批准期）** |
| G1b 目标绑定核查（Goal 与原话有交集） | SKILL.md L157；goal-gate 域 | 读（门禁勾选面） |
| 51.11 留口/挂起需同号逐字让步锚 | critical-rules.md L102 | **读（交付前门控）**：缩水处置须 user-session-log.md 有同号逐字条目 |
| Rule 87/88/89/92/94/95 判例锚引用 | critical-rules-discipline.md L530,546,554,566,570,582,591,609,617,621 | 写面引用（建制锚），非读取触发 |

## ④ 决策点核查表（读/不读/弱读）
| 决策点 | 是否要求读 user-session-log | 判定 |
|---|---|---|
| Rule 102.0 反思门（新指令到达先反思四问→分类→同步） | 无。102.0-102.5 全文（discipline L693-704）+ UPS hook [plan-note]（zcode-userpromptsubmit.sh L283-287）均未提该文件 | **不读** |
| 新指令统一收口序列（SKILL.md L175） | 序列只有"写入"（①逐字落盘→②判定→③同步），无"读取既有条目做对照"步 | **不读** |
| Rule 61/64 偏移检查 | drift-checker 必读（L22/L36）；64.2.1 目标漂移需读 | **读（仅子代理面）** |
| Rule 51.x 完成声称门控 | 51.11 有读（让步锚）；51.3 需求覆盖核对=按 task_plan R 条目，非专档 | **读（仅 51.11 面）** |
| 交付总结 delivery-summary.md 模板 | 模板全文无 user-session-log 字段，"需求覆盖核对"数据源=task_plan R 条目（R 是转译面，专档才是原话权威面 80.4） | **不读（缺口）** |
| AskUserQuestion/用户裁决上抛前检查（Rule 44 默认项与自动超时裁决、86 可测问题禁问、72 分级、70 呈报） | 44.1-44.5/86.1-86.5/72 全文无一处提及该文件；上抛前不核查"该问题用户是否已在专档中给过指令" | **不读（核心缺口，即用户抱怨场景）** |
| Rule 95 非必要暂停禁令 | 95.0-95.6 无提及；"能自答不提问"的"自答"未定义含"读专档找既有指令" | **不读** |
| 子代理派发需求锚 templates/subagent_dispatch.md | 需求锚字段（L19-20）=task_plan R 条目逐字引用（转译面），无"专档原话条目"锚字段；子代理只感知转译版，与 80.4"转译与原话冲突以原话为准"权威序断链 | **不读（缺口）** |
| templates/user-session-log.md 自身 | 只定义"恢复协议"读取（L25-27），无任何常规决策触发点 | **不定义读取触发** |

## ⑤ 实盘核查
- 全仓 user-session-log.md 实盘 20+ 份。读取实迹仅 2 类：a) drift-checker 检查点确证读过（plans/archive/task-v179/subagent-state/4-drift-checker.md L12"对照 user-session-log.md #1"、task-focus-plan-split.../02-drift-check-p1.md L5、task-kb-persist.../drift-check-2.md L14、task-v186.../subagent-state/2-s1-executor.md）；b) task-v184/task-v187 等专档本体只含写入条目。
- **无任何实盘记录表明：主进程在"用户补充要求后做决策/上抛前/交付前"读取过该专档做对照**——印证"只写不读"。task-v186 专档 #1 诉求（"后期出问题方便回溯是不是理解偏差"）的读取承诺=80.7 设计目的，但无机制承载读取动作。

## ⑥ 缺口清单（按严重度排序）
1. **[P0] AskUserQuestion/裁决上抛前检查（Rule 44/86/95 面）**：上抛前无"先读 user-session-log.md 核查该决策是否已有用户原话指令"条款——即用户抱怨的直接成因。修复点：Rule 95.4 暂停前三问增加一问（④该问题在 user-session-log.md 是否已有用户原话指令？有=直接按原话执行禁上抛），或在 Rule 86.1 分类闸前加前置读档门（新增子条 86.0/95.7 或 80.8）。
2. **[P0] Rule 102.0 反思门**：反思四问基于"当前活跃计划 Goal"，未要求读专档既有原话做对照（B/C 类判定、"口头接受不落盘"均只针对本次指令）。修复点：102.0 总纲四问扩展第⑤问"与 user-session-log.md 既有原话条目是否冲突/已被裁决"，并写入 UPS hook [plan-note] 文案（zcode-userpromptsubmit.sh L283-287 三处 note 同步追加一句）。
3. **[P1] 交付总结 delivery-summary.md**：无"用户原话回溯核对"区块。修复点：模板"需求覆盖核对"表增列"专档条目#（user-session-log.md）"，51.3 口径由 R 条目扩为 R 条目+专档同号条目双锚（防转译面冒充原话面，80.4 权威序延伸）。
4. **[P1] 子代理派发需求锚（subagent_dispatch.md 需求锚字段，51.1a 派发侧锚）**：只锚 task_plan R 条目（转译面）。修复点：字段增加"专档条目号（user-session-log.md #N）"双锚，对齐 drift-checker CA-7 双源口径。
5. **[P2] 新增子条 80.8（读取纪律/消费面）**：现 Rule 80 只有 80.4 恢复场景一个读触发。修复点：critical-rules.md Rule 80 追加 80.8"决策前读取（对照面）"——上抛/交付/目标判定/反思门前读取最近 N 条原话，selftest-session-log.sh 加 SL 断言守护，selftest-dual-qc 加锚。
