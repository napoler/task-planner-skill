# 04-critic-audit.md — 独立计划审计（Rule 109 audit-before-delivery）R1

- 审计体: critic（独立第三方，只读）
- 轮次: R1
- 时间: 2026-11-24
- verdict: **REJECTED**（C=1 / I=7 / W=5 / Q=1；共 14）
- 审计对象: plans/task-two-stage-fix-20261124/{plan-state.json,task_plan.md,findings.md,verification.md,knowledge-brief.md} + subagent-state/{01,02,03}
- 锚面: user-session-log.md #1 逐字原文（逐条比对 R1-R8）

## 问题清单（key | severity | file:line | 描述 → 修复建议）

- C1 | CRITICAL | task_plan.md:80 + check-evidence-anchor.sh:509-515 | VC-5 声称 POS/NEG 实跑，命令只有 POS；且新 source 若仅被 arg-case 接受、无 mode 分支时脚本 FAILS=0 直接 exit 0 —— 实测把脚本复制到 /tmp 仅加 `--source=rootcause-followup` 到 :115 case（无任何 mode），POS fixture rc=0、NEG fixture（无标记）rc=0，VC-5 全链 PASS ⇒ 整条驱动点③可零逻辑交付仍通过验收。 → VC-5 必须补 NEG fixture（无标记 findings 期望 rc=1），并断言 POS=0/NEG=1 双向。
- I1 | IMPORTANT | task_plan.md:133（S8）/166（CHG-8）+ check-complete.sh:761,769,792,1064,1841 | 「在 :735-780 区内（:769 扩展点之后）加 run_evidence_anchor rootcause-followup 调用」的 :769/:780 位于 `run_evidence_anchor()` 函数体（761 `{` … 792 `}`）内部；照字面加调用=函数自递归。真实调用点只有 :1064（coverage，guard :1063 VC_GATE_TIER+非 mini）与 :1841（goal，guard :1839 plan_tier standard|full）。 → S8/CHG-8 改为「新增受控调用块（明确 guard：VC_GATE_TIER!=off / mini / L0 口径）」，并给 VC-5 加位置断言（门序/上下文），不要以 735-780 作调用点证据。
- I2 | IMPORTANT | task_plan.md:84（VC-9）+ 实测 | VC-9 对 G3 两项核心约束无判别力：部署位在仓外（~/.zcode|~/.claude…），仓内 `git status` 永不显示；命令也不校验「改动集合 ⊆ CHG-1..9」。当前未实施即 PASS rc=0 ⇒ G3「改动集合严格落在清单内」无证据。 → 增 `git diff --name-only`（或 status 路径集）对 CHG-1..9 求差集断言；部署位改为 `find ~/.zcode/skills -newer <ts>` 或显式声明该条不可机器验证。
- I3 | IMPORTANT | task_plan.md:30-31（R6/R7→VC-5,VC-9）+ :76-84 | 用户核心语义（阶段一完成后「立即合并回主分支」/「阶段二开新分支新工作树并行、不阻塞」/「拆成两个独立任务」）无任何判别性 VC；VC-3/VC-4 只 grep '两段式'/'修复类'/'P13'/'阶段一'，不含 合并/新 worktree/不阻塞/两个 task-id 关键词；R6/R7 映射到的 VC-5/VC-9 与这些语义无关。 → 增 VC（或扩 VC-3/VC-4 关键词集）覆盖「立即合并」「新 worktree/新分支」「不阻塞」「两独立 task-id」，并重映射 R6/R7。
- I4 | IMPORTANT | findings.md:46（D9）+ task_plan.md:80（VC-5 fixture）+ planctl.py:757-758 | 标记契约二义：`[rootcause-followup:PASS]+tag=` 是「findings 文本字样」还是「planctl tag-add 写入的倒排登记」未定义；VC-5 fixture 在 `$T`（计划目录）写 `.tags-index.json={}`，而真实索引在 `<plan-dir>/../`（planctl.py:757-758）——位置错且空索引，实质只允许「写字样即过」的弱实现，「后续任务已登记」不可验证（正是 plan-writer 未决#1）。 → 契约定为 tag-add → plans/.tags-index.json 真登记 + mode 读索引校验；fixture 用 planctl tag-add 生成；若坚持文本契约须写明降级理由。
- I5 | IMPORTANT | task_plan.md:220（模板 feature「消费侧门控与 selftest 守护」）+ :147（S11 仅全量跑）+ CHG-1..9 无 selftest | rule-enhancement 模板明列 selftest 守护；本计划无任何新增/扩展 selftest，B12 与新 source 无常驻回归断言（selftest-evidence-anchor.sh 存在但未扩），「以后每次执行」缺守护。 → 增 S-unit + CHG：selftest-evidence-anchor.sh 加 rootcause POS/NEG 用例（+B12 断言）。
- I6 | IMPORTANT | SKILL.md:98,105 + check-complete.sh:362,1063-1064 | 轻量档逃逸：两段式判定入口落在「初始化首动作委派（L1+）」块且 :105 明示 L0/mini/trivial/L0-E 豁免；L0 跳过 3-File Gate（:362 `three_file_gate_active and not LANE_L0`）可无 findings.md；coverage source 对 mini 豁免（:1063），若新调用同 guard 则 mini 修复类亦跳过 ⇒ 用户原话的典型场景（「只改一个数据」的小修）可绕过两段式。 → 判定入口上移到 lane 无关段（或规定 L0/trivial 修复类必须升 L1 复核）；B12 在 todo-sync 契约明文 mini/L0 口径。
- I7 | IMPORTANT | task_plan.md:210,214 + user-session-log.md:48 | 「机制类步骤按 2026-11-24 用户裁决需驱动点」被用作免去「文本 or 机器门」请示的依据，但 user-session-log #1 无该表述（无逐字锚）。 → 补录用户原话条目（append #2）或改登记为「主进程设计选择（非用户裁决）」，二者择一并同步 D8/理解镜像。
- W1 | WARNING | critical-rules-discipline.md:749-751 + CHG-1/CHG-2 | Rule 106.5 仍枚举「通用基线组…B1-B8」且自称语义锚；CHG 清单未含该文件 ⇒ 契约面（todo-sync.md）与规则语义面漂移；他会话 task-session-regression 已按「脚本+契约+106.5」三处同步先例（其 worktree :753）。 → 增 CHG-10（或明示 106.5 为摘要面不改并写理由）。
- W2 | WARNING | task_plan.md:68-71 + plan-state.json root_causes=null | 根源覆盖表（Rule 53.1）留占位指令文本，既未登记也未写「不适用（非结果级）」+理由。 → 补一行定性。
- W3 | WARNING | task_plan.md:76（VC-1） | VC-1 只断言 B1-B8+B12；与他会话合并并线后不校验 B9-B11 存活，人工并线可能静默吞掉对方基线项。 → 终态复跑时断言 B1-B12 全集。
- W4 | NIT | task_plan.md:83（VC-8） | 正向分支 `Total.*0` 近似恒真（任何以 0 结尾的 Total 命中），真正判别靠负向分支；当前输出格式 `Total: N PASS=x FAIL=y`（run-selftests.sh:166）使结论仍成立。 → 改 `FAIL=0` 精确匹配。
- W5 | WARNING | task_plan.md:211（D5）+ CHG-3/CHG-5 | 阶段二启动协议只有 SKILL.md 一句 + P13 步骤，无「合并后由谁、用什么命令（--base master / wt/<id>-rc）触发派发」的章节化步骤，执行方可能只写线索包而不真正派生阶段二。 → 在 S4 或 P13 写明触发点/命令/失败留 pending 的呈现面（plan-resume）。
- Q1 | QUESTION | task_plan.md:207（D1） | 用户原话「我希望就是解决以后解决问题都是这样子」「贯穿到整个任务执行过程中」（#1:43）比「仅修复类」宽；D1 收窄未获用户显式批准。 → 用户确认触发面，或写明收窄依据并留待批准。

## 维度结论
- ① 需求覆盖: R1-R8 逐字与 #1 一致（无改写/编造）；但 R6/R7 核心语义无判别性验收（I3），触发面收窄待确认（Q1）。
- ② 机制设计: 三驱动点方向成立（B12 自动带出 + 消费门 + 入口/模式库/模板）；缺 selftest 守护（I5）、轻量档漏人（I6）、阶段二启动无协议面（W5）、标记契约二义（I4）。
- ③ 冲突面: B9-B11 占用属实（他会话 worktree sync-todos.sh:322-324）；SKIP-BY-HASH 段 :552-575 在插入点之前，门序风险可控；但 106.5 漂移（W1）、并线后基线项存活无断言（W3）。
- ④ 比例: 9 文件对用户诉求规模合理，不过度；但少 2 类必要改动（selftest、106.5），属不足。
- ⑤ 可执行性: VC-1 有效（实测 MISSING-B12）；VC-2/3/4/6 单关键词可过、位置不可判（WARNING 级）；VC-5 no-op 可过（C1）；VC-7 实测 VALIDATE PASS rc=0（合法）；VC-8 结论成立（W4）；VC-9 无判别力（I2）。
- ⑥ 篡改面: 未发现编造用户承诺；唯一归因缺口=「驱动点裁决」无逐字锚（I7）。

## 负结果（检查了但未发现问题）
- 逐条比对 R1-R8 与 user-session-log #1:43 —— 逐字一致（含"工作书"原错别字保留，无美化改写）。
- 零 schema 新字段主张成立（git 侧未触 plan-state.schema.json；D2 用 tags 合法，planctl.py:1055/757 实测存在）。
- FMEA 哈希锚（check-complete.sh:552-575 四元键）覆盖区段为 FMEA 段（:622 前），本计划插入点（> :735）不扰动键③。
- 未发现在既有 B1-B8 行上做语义替换的计划指令（CHG-1 明确逐字保留 + 仅补逗号追加）。
- KQ-3「本任务不套两段式」自洽（制度层机制固化，D1 仅修复类触发）。

## 验证摘要
- 总发现 14 / 已验证 14 / 通过率 100%（每条均以 Read/sed/grep/实跑复核；C1 与 I2 附实跑证据）。

## 裁决
REJECTED（须修 C1 + I1..I7；W/Q 留档不阻断）

## 审计留痕素材（供主进程 planctl audit-add）
[plan-audit-R1] round=R1 auditor=critic verdict=REJECTED C=1 I=7 W=5 Q=1 keys=C1,I1,I2,I3,I4,I5,I6,I7,W1,W2,W3,W4,W5,Q1 target=task-two-stage-fix-20261124
