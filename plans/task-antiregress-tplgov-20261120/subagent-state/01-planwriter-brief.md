# 计划撰写任务书（S-01 planwriter，2026-11-20）

你是本任务的计划撰写执行体（等效 plan-writer 角色）。只写 task_plan.md + knowledge-brief.md 两个文件，不执行任何 Phase、不调子代理、不改其他任何仓库文件。全程中文。

## 0. 绝对路径
- 仓库：/mnt/data/dev/task-planner-skill（master，HEAD=76a6466）
- 计划目录：/mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/
- 必读调研：…/plans/task-antiregress-tplgov-20261120/research/template-inventory.md（304 行：未提交改动归属/防倒退既有设计/模板结构/加载链/守卫面/规则编号现状）
- 计划格式参考：先 Read /mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md（601 行主模板，按其区块结构组织计划），并与骨架文件现状对照；条款格式遵循 skills/task-planner/references/critical-rules.md 的 Rule 16/34 相关要求（与骨架实际区块冲突时以骨架为准）
- 未来 worktree（计划中所有实施路径写这里）：/mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120（分支 wt/task-antiregress-tplgov-20261120，从 HEAD 建，尚未创建）

## 1. 🎯 用户需求原文（逐字复制进 task_plan.md 对应区块，含原有笔误，禁转写）

"为该项目skill加入放倒退机制  也就是  在合适的地方加入防倒退相关操作 比如在计划完成或者初期  就评估是否会将项目进度产出倒退影响,不能做拆东墙补西墙,为了可以践行任务执行防倒退原则可以在多个地方进行限制已经增加步骤   比如 模板等   另外我希望可以升级模板skill 将类似防倒退机制等推广到所有的模板文件 就是 在模板中要求对各种原则性的问题注入到模板 确保原则的可靠性. 另外确保所有任务都主动加载适配的模板文件 确保执行任务使用针对性优化方案, 增加覆盖场景模板  另外还有就是提高对已有模板升级能力  以后升级模板skill规范后可主动改造已有过时的模板来提高模板可靠性 还有就是 模板的派生机制   我希望可以对模板进行分级  对于基础模板提供更高的可靠性  不能说以后几个模板派生后偏移原本模板的核心原则  比如  基础模板要求的某些 因素对于 派生a 不必要删除了  如果使用a派生a1 可能导致 传导错误  也许a1中需要符合基础模板所以对齐到基础模板派生 才是核心  比如派生a1需要同时参考基础和a来派生a1  来提高可靠性不会丢失核心"

## 2. 任务定义（五子项目 R1–R5，经调研核实后的方向）

- **R1 防倒退机制（P1，最高优先）**：新 Rule「进度产出基线防倒退」：①计划初期 task_plan.md 登记「📦 进度产出基线」（动工前项目关键产出/进度快照+禁倒退清单）②交付/合并前「🛡 防倒退终检」逐项对照判定 ③拆东墙补西墙机器化判定：diff 中既有产出的删除/降级/替换须登记消费方影响评估且净效果≥0 否则 BLOCK。
  设计指令：与既有 Rule 51.15（Spec-Baseline 规范阈值冻结）/74.7（修改合规门）**分工互锁不重复**——74.7 管修改依据、51.15 管规范阈值面、新 Rule 管进度产出面；复用 51.15 的「登记→attest 锁→四环回归」范式（22.4e 携带/103.3b 复检/106.7 返工回归/84.15 verification）。
  落点：core critical-rules.md 新条款 + discipline/dispatch 级联锚 + 主模板 task_plan.md 两区块（📦 基线登记 + 🛡 终检）+ variant 同族 + selftest 断言 + SKILL.md 接线（初期登记触发点+交付终检触发点）。
- **R5 模板分级派生（P2）**：base（templates/task_plan.md 主模板，最高可靠性，改动最严流程）/derived（variant/*-type.md 31 个）两级；variant 增 lineage 头（parent/base 锚/裁剪清单：裁了 base 哪些区块+为何合法）；派生铁律=裁剪逐级对齐 base 重新评估，二级派生必须 base+parent 双参照，裁剪清单=父级∪新增，核心区块不可沿派生链静默丢失。
- **R2 原则注入注册表（P2）**：plan-template-kit 建「原则→模板区块」注册表（防倒退→基线/终检区块、验证→VC 区块、证据→证据锚区块、理解迭代→28.2.2 区块等，从主模板现有区块归纳）；守卫校验每模板原则覆盖面，缺必选区块=FAIL，豁免须登记。
- **R4 spec_version+存量改造（P3）**：模板与 kit 声明 spec_version；规范升级→扫描 spec_version<N 存量清单→逐模板改造→守卫复验→登记；把 task-variant-upgrade-20261113 的 28 文件手工升级经验机制化成 kit 的 retrofit SOP。
- **R3 主动加载+场景覆盖（P3）**：general 兜底从静默默认改为须登记理由（init-session/check-complete/advisor 链）；场景缺口盘点须数据驱动——统计 plans/ 历史任务类型分布对照 31 variant 覆盖面，按频率提出补缺候选清单（补哪些模板作为计划内决策点登记，不拍脑袋）。

## 3. 分期

P1=R1 → P2=R5+R2 → P3=R4+R3 → P4=部署同步（既有部署位 diff=0 复验）+收尾簿记。每 Phase 拆 S-unit（每单元≤100 行变更、独立可验收）。

## 4. 硬约束（违反=计划废）

1. 实施全在上述 worktree；主仓 18 个未提交文件属三簇在途任务（调研报告§1），**本任务禁触碰**；templates/task_plan.md 合并期预期冲突，写入风险区。
2. 新 Rule 编号分配前 grep 三份规则文件全集确认空号（现状 core max 109/dispatch 110/discipline 106；Rule 110 已被任务分级占用，候选 111 起须实测）。
3. selftest 回归纪律写入计划：动工前跑全量取基线（预存 FAIL 清单落盘），收尾对照**同集零增量**。
4. 31 个 variant 的 lineage/spec_version 注入是批量面：计划按「脚本生成+抽检复验」组织（一个生成 S-unit+一个抽检 S-unit），禁 31 次逐个手工 Edit。
5. variant 文件头注入不得破坏 check-template-type.sh 的类型白名单三形态提取（兼容性验证列入 VC）。
6. dogfood 设计：本计划文件自身作为 P1 防倒退区块的首个实弹载体——实施动工时在计划内回填自身基线（44 模板/规则编号/selftest 基线等）。
7. Decisions Made 区登记：D1=在途改动不碰/worktree 从 HEAD/合并期冲突延后（依据 task-worktree-no-ask-fix SOP）；D2=P1→P3 分期推进。
8. 模板选择按 advisor 逻辑从 variant 白名单选最适配 template_type（技能治理类；无更适配者用 general），把选择理由写进计划。
9. VC 判据全部机器可执行（grep/脚本+PASS 口径，行首 **Verify command**: 格式）；[goal:Gn] 行齐备。
10. 文本优先：本任务交付物=规则条款/模板文本/注册表/守卫与 selftest 脚本（本仓规则落地的既有机器面惯例），不新增 hook/registry 之外的基础设施。

## 5. 验收（完成后的自查标准，写入 checkpoint 自审段）

task_plan.md 结构完整可 attest：①用户原话逐字在位 ②根源覆盖表 R1–R5 全覆盖 ③每 Phase 有 S-unit 表（执行体/输入/产出/VC/时长）④VC 全部机器判据 ⑤风险区含合并冲突+白名单兼容+部署漂移+场景选取数据依据 ⑥Decisions 区含 D1/D2。写入后自查一遍结构再回报。
