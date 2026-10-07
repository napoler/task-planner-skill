# Delivery Summary — task-v143 Rule 58 调研分析证据纪律与核心目标达成门控

> 日期：2026-10-07 ｜ outcome: **COMPLETE** ｜ merge: 96c474c ｜ worktree: wt/task-v143（已清理）｜ 部署位：7 文件 IDENTICAL

## 一、说明（做了什么、为什么）

针对用户 2026-10-07 反馈的调研/分析类任务两大缺陷——①**无据结论**（"为什么没流量"的归因连竞品分析都没做就下结论）；②**不解决问题即停**（分析报告写完就宣布完成，核心问题实际没解决）——新增 **Rule 58「调研分析证据纪律与核心目标达成门控」** 七子条，并以计划模板双区块+init 注入兜底做成"每次任务强制携带"的载体：

| 子条 | 管什么 |
|------|--------|
| 58.1 证据面清单 | 调研/分析/评估/归因类任务计划期必列三基线证据面：自身样本/对标样本/外部约束，缺面=计划无效回炉 |
| 58.2 对标取证强制 | 归因结论前必须对 ≥1 个可指名对标对象完成第一手取证；**无对标取证的归因结论=无据结论**；豁免须登记理由禁裸豁免 |
| 58.3 结论-证据锚定 | 每结论必引证据锚；≥2 面交叉方可定论；无据判断标「推测（未验证）」；定稿前反证检查 |
| 58.4 手段/目标二分 | 需求 R 行逐条标 [手段]/[目标]；[目标] 行必须映射「问题解决判据」VC；漏标=计划无效回炉 |
| 58.5 完成裁决门 | 终验必出三态裁决 solved/partial/not-solved；**交付物完成禁冒充问题解决**；not-solved/partial 禁 COMPLETE |
| 58.6 因果链 | 每个实质活动必须可回答"服务于核心目标哪一块"，绕弯活动禁执行（对应"别绕弯消耗资源"） |
| 58.7 机制 | 零新 config 键；selftest-evidence-goal-gate.sh 静态守护（EG-01..21） |

## 二、产出（可定位）

| 产出 | 路径 | 看点 |
|------|------|------|
| Rule 58 条款 | `skills/task-planner/references/critical-rules.md:656-676`（仓版） | 七子条+判例引用用户原话 |
| 模板双区块 | `skills/task-planner/templates/task_plan.md`（🔍 证据面清单 / 🎯 核心目标达成裁决） | init 全任务注入+variant 兜底 |
| variant 兜底注入 | `skills/task-planner/scripts/init-session.sh` `inject_evidence_goal_block()` | research-type 等路由产物缺锚时补注入（CR F-1 修复） |
| 守护脚本 | `skills/task-planner/scripts/selftest-evidence-goal-gate.sh` | EG-01..21，21/21 PASS（仓/部署位双验证） |
| SKILL 联动 | `SKILL.md` 摘要行+C41 合规项+frontmatter 全集 1-58 | 执行期可发现 |
| 级联演进 | `scripts/selftest-iteration-persistence.sh` IP-14 负断言 58.x→59.x | task-v127 RC-15 同范式，口径扩展非回退 |

## 三、审查详情

- **Code Review（REQUIRED）**：general-purpose 独立审查 → **APPROVED-WITH-NOTES**（1 MAJOR+2 MINOR+4 NOTE），**F-1~F-7 全部修复闭环**：F-1(MAJOR) variant 路由零覆盖→init-session.sh 新增兜底注入+EG-21 断言+research-type 冒烟 PASS；F-2 EG-13 口径注释；F-3 frontmatter 全集 1-58；F-4 三态词改 58 块内语境锚定；F-5 零新键断言扩 evidence 前缀族；F-6 58.4 补漏标回炉句；F-7 chmod +x。
- **回归**：全量 57 selftest 双基线对照（master vs worktree→合并后三时点），**零新增回归**；既有 FAIL 面与基线完全一致（IP-15/T02/PR-* 等归属 v142 合并事故与他账 deferred）。检查点：`plans/task-v143/subagent-state/04-regression.md`。
- **init 冒烟**：general 路由与 research-type（variant）路由双冒烟，双区块注入均 PASS。

## 四、风险与已知事项（必须列举）

1. **v142 编号强占事故（二犯）**：task-v142 未走 rule-reserve 预留制，在我已合法预留 58 的情况下把「主动解决问题」条款落为 Rule 58（a7c01a8；其 Rule 57 撞 task-v141 为同模式首犯）。**已仲裁**：58 归 task-v143，v142 条款重编号 60（内容零改动+仲裁注记），60 号避开了 task-v144 已预留的 59。行动项：建议用户对 v142 会话的编号纪律作裁决（Rule 20.6 预留制的执行缺口在人会话侧，机制本身已二次证明有效——账本+仲裁避免了双 58 条款并存）。
2. **既有漂移面（他账）**：config.json 42 键（v142 遗留孤儿键，IP-15 FAIL）、selftest-periodic-review.sh 未登记 TSV（T02 FAIL）、PR-03..10 五断言 FAIL（v142 的 57 条款已在后续合并中丢失但其脚本/键残留）——归属 v142 会话账，未越权修复。
3. **SKILL.md References 表止于 Rule 55、:271「Rule 40-55」**：v140/v141 起的既有漂移，本任务未触碰（宽容锚容忍，改它会级联多脚本锚）。
4. **行为面验证待实战**：Rule 58 是 LLM 行为面条款，机器面只锁文本锚；条款实效需后续真实调研/分析任务检验（如下次"内容为什么没流量"任务是否强制竞品取证）。
5. **并行会话活跃**：v144（已预留 59）/v145 worktree 在途，本任务合并期间 master 两度前进（ba12733→a7c01a8），后续会话合并前须重扫基点。

## 五、下一步建议

1. 对 v142 会话的编号强占行为作用户裁决（是否要求其会话回改/致歉登记，或修订 rule-reserve 机制的 enforce 档）。
2. 清账 v142 遗留：config 孤儿键 2 个（periodic_review_*）与其 57 条款文本的归属二选一（补条款或删键删脚本），可消掉 IP-15/T02/PR-* 共 8 处既有 FAIL。
3. Rule 58 行为面实战检验：下一次调研/分析类任务观察证据面清单与三态裁决是否被强制执行，实战判例回填 58.x。
4. SKILL.md References 表/40-55 全集声明的存量漂移可随下一个 Rule 任务顺带清账。
