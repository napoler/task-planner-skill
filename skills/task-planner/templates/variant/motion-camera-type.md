# Task Plan: [运动与运镜控制任务]
<!-- template_type: motion-camera -->
<!-- 镜头运动层写词工序：镜次目的→运镜选词→运动状态定义→物理可行性→落词登记。边界：纯文本层零生成调用；完整镜头词入 prompt-struct/video-prompt-type；物理合规判定入 physics-compliance-type。触发词：运镜/镜头运动/跟拍/甩镜/运动控制 -->
<!-- 五要素：①编号原子步骤+显式状态定义（逐镜运动卡：镜次目的×运动主体×运动态×运镜词）+合规检（POV 纪律+物理可行性）+静默迭代（可行性 FAIL 回改环）+验收判据（VC 表） -->
<!-- 交互：默认 interaction_mode: silent——零生成零额度；唯一合法打断=Rule 28 D6；批次末单份收尾报告 -->
<!-- 调研需求三态（Rule 75.1/§2.6）：可选——默认按存量词库/状态链执行；仅当引入新运镜词/新载具态需外部参照时触发 NET-RESEARCH（检索关键词+渠道+预期产出登记到计划调研区块）；无新参照需求=不需要 -->
<!-- plan_tier: standard -->
<!-- execution_lane: L1 -->
## Goal
[一句话：为哪些镜头定义运动与运镜方案并落词，达成标准（运动卡齐+可行性核对过+落词登记）]

<!-- 任务分型三选一：A 逐镜方案（整集运动设计·按镜序批量）/ B 单镜精修（指定镜运动重设计·P1 并入缺陷归因）/ C 运镜词库校订（词库/子句维护·压缩为 P2+P5） -->
## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 原子闭环：五相顺序；运动卡未过可行性核对禁落词入档案 | Phase 链 | task_plan |
| VC-2 | 显式状态定义：逐镜运动卡四字段齐（镜次目的/运动主体点名/运动态[行驶/步行/手持/静止]/运镜词）+快切段禁 slow 类词标注 | 运动卡 grep 四字段 | prompts/ 档案 |
| VC-3 | 合规检：客观第三人称默认视角（自拍 POV 非常态，逐镜显式声明方可）；运动态与载具状态一致（行驶禁升顶/停车互动）；危险动作零容忍 | 逐镜合规行 | progress.md |
| VC-4 | 静默迭代：可行性核对 FAIL→回 P2/P3 修正环（静默）；同型 FAIL ≥2=词库级修订（style 运镜词库变更登记） | 回改环计数 | progress.md |
| VC-5 | 验收判据：逐镜运动卡过物理可行性核对（运动方向×载具逻辑×场景几何不自相矛盾）+快切/慢词适配核对 | 可行性核对行 | progress.md |
| VC-6 | 登记收口：运动卡并入镜头提示词档案（关联镜号×版本）；词库变更（如有）走 style 变更登记 | 档案行+变更登记 | prompts/+docs/style.md §6 |

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 镜头提示词档案 | <项目根>/prompts/ 逐镜运动卡+镜头词（关联镜号×版本） | 写入 prompts/ 之外的成片资产 |
| 运镜词库 | <项目根>/docs/style.md 运镜词库段（§2.4/§6） | 未登记的静默词库变更 |
| 计划簿记 | plans/task-{id}/* | 其他 plan 目录 |
| 生成调用 | 无（纯文本层零生成零额度） | 任何图像/视频生成调用与额度消耗 |

**强制约束**：运动卡未过 Phase 4 可行性核对禁落词入档案（VC-1）；POV 例外逐镜显式声明且登记。

## Phases（五原子步骤）

### Phase 1: ① 镜次目的定义
- [ ] 逐镜回答「这镜为什么存在」（信息点/情绪点/节拍位）；主观/客观机位判定（POV 须逐镜显式声明）；产出=镜次目的表（状态：待选词）
- **V-N:** VC-2, VC-3
- **Status:** pending
- **Executor:** 主进程（需剧本与节奏参数上下文）

### Phase 2: ② 运镜选词
- [ ] 从运镜词汇库选配（鸟瞰/航拍/甩镜/跟拍等），快切段禁 slow 类；禁词表核对；产出=运动卡草案（状态：待状态定义）
- **V-N:** VC-2, VC-5
- **Status:** pending
- **Executor:** 写词执行体

### Phase 3: ③ 运动状态定义
- [ ] 主体运动态逐镜显式（谁×怎么动×载具态×速度感）；与状态链字段对齐（行驶中禁开门/升顶落下等）；产出=完整运动卡（状态：待核对）
- **V-N:** VC-2, VC-3
- **Status:** pending
- **Executor:** 写词执行体

### Phase 4: ④ 物理可行性核对
- [ ] 逐卡核对运动方向/载具逻辑/场景几何自洽（判定层=physics 快审口径）；FAIL 回 P2/P3 环（静默）；产出=过核卡池
- **V-N:** VC-5, VC-4
- **Status:** pending
- **Executor:** 判定层审查执行体（与 P2/P3 不同执行体）

### Phase 5: ⑤ 落词登记
- [ ] 过核卡落词入镜头提示词档案（关联镜号×版本）；词库变更（如有）登记 style §6；单份收尾报告
- **V-N:** VC-6, VC-5
- **Status:** pending
- **Executor:** 主进程

## 🔗 隔离与静默纪律
- 组卡（P2/P3）与可行性判定（P4）不同执行体；静默环零生成调用，用户可见=批次末收尾报告
- POV 例外逐镜显式声明且登记（默认客观视角纪律，s 条）

## 📚 必要知识储备
> 定位路径约定：`<项目根>/` = 目标执行仓（视频生产仓）相对路径；skill 内引用一律用 ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner} 绝对路径（R-17）。
| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|----------|------|---------|--------|
| 词库 | 运镜词汇库 10 词+快切禁 slow | <项目根>/docs/style.md §2.4 | 必读 | ☐ |
| 视角纪律 | 客观视角默认/POV 显式声明/直播框后期 | <项目根>/AGENTS.md 约束 20；<项目根>/outline §3 s 条 | 必读 | ☐ |
| 状态链 | 载具/装备多态状态字段 | <项目根>/AGENTS.md 约束 9 状态链；script-craft V38 口径 | 必读 | ☐ |
| 物理判据 | physics 判定层（行驶禁开门等） | <项目根>/.zcode/skills/videop1-review-physics/（仓库技能层） | 参考 | ☐ |
| 镜头词 | 结构化镜头模板 | <项目根>/prompts/structured-shot-template.md | 参考 | ☐ |

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |          |        |      |

## 📊 委派统计（Rule 25.4 — 终验前必填）
<!-- WHAT: 子代理 vs 主进程执行分布统计。WHY: 委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由 → outcome 最高 PARTIAL(白名单见 critical-rules.md Rule 25.3)。WHEN: 每个 Phase complete 后更新;终验交付前必须完整。 -->
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  /  |
| 主进程直做 Phase 清单 | （含例外理由） |
| 委派率 | （< delegation_rate_floor 默认 0.7,或含白名单外理由 → 最高 PARTIAL） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
<!-- WHEN: 每次 Agent() 派发前填一行;子代理返回 30s 内主进程必须 Read 实际产出 + 紧邻 Edit findings.md 回填结论,两动作完成才勾 verify_done;failed/timeout 行必填 checkpoint 路径(Rule 22.8.4)。WHY: 防结论只留会话记忆(Rule 19.1/22.5)。状态枚举: queued/pending/running/done/partial/timeout/failed/blocked/scaling-redispatch;备注列=低频列折叠单列(rescue 档位/结果/时间,retry_count 初值 0 每次重试 +1,verify_done☐=Read 产出+findings 复核双条件——人工义务,无机器消费)。派发 prompt 八字段模板: ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/templates/subagent_dispatch.md -->

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | | | | queued | | | | | - / 0 / ☐ |

