# Task Plan: [剧本开发与合规审查任务]
<!-- template_type: script-dev -->
<!-- 剧本工序专用（M0 大纲→M1 展开→M2 审查→M3 静默修正；判定层=script-craft 全集）。边界：本模板止于定稿剧本与登记，零生成调用；全流程视频生产入 video-type。触发词：写剧本/大纲/台词修正/剧本审查/合规审查 -->
<!-- 五要素：①编号原子步骤+显式状态定义（每 Phase 产出物形态+剧本头部五声明块）+合规检（V16 八红线/V8 语言锁/V34 大纲一致）+静默迭代（M3 修正环 0 打断）+验收判据（VC 表） -->
<!-- 交互：默认 interaction_mode: silent——M1→M2→M3 修订环静默跑；唯一合法人工停点=M0 大纲放行门（大纲先行门，约束级）与 Rule 28 D6；放行/否决登记双落 progress+Decisions -->

<!-- plan_tier: standard -->
## Goal
[一句话：产出哪一集/哪个剧本件（M0 大纲或 M1 定稿本），达成标准（M2 判定层 PASS 或 PASS_WITH_NOTES+八红线自检齐+登记收口）]

## 任务分型（三选一）
| 型 | 场景 | Phase 骨架 |
|----|------|-----------|
| A 新集 | 新一集从零创作 | 全六相（M0 放行门在 P2） |
| B 存量重写 | 既有集推倒重写 | P1 并入旧件归因复盘；旧件当日归档 |
| C 局部修正 | 台词/结构修正 | P1 核验→P4 快审→P5 M3 闭环→P6 |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 原子闭环：六相逐相过门，未过相禁进下一相；M0 未放行=禁 M1（大纲先行门），静默变更=blocker | Phase Status 链+放行登记行 grep | task_plan+progress.md |
| VC-2 | 显式状态定义：每 Phase 产出物形态明确（大纲件/剧本件/审查报告/修正日志）；剧本头部五声明块齐（戏剧结构登记/出场角色表/语言声明/音色声明/腔调口癖） | 剧本头部五块 grep | 剧本件 |
| VC-3 | 合规检硬门：V16 平台合规八红线逐条自检（缺条=总评无效）+V8 语言锁三层优先级+V34 大纲一致性核对 | M2 报告 verdict+自检行 | 审查报告 |
| VC-4 | 静默迭代：M3 修正环（findings 逐条修→复检）0 用户打断；修正确认只落修正日志；新 blocker=STOP 合法停点 | 修正日志环计数 | 修正日志 |
| VC-5 | 验收判据：判定层全集（P1-P10/V1-V38/E0-E7）逐维结论，blocker 未处置=不得定稿；终态=PASS 或 PASS_WITH_NOTES | M2 报告 verdict 行 | 审查报告 |
| VC-6 | 登记收口：定稿件落 docs/series/<id>/；outline/continuity 联动更新；废弃版本当日归档；资产缺口扫描结果移交资产任务 | 登记行+归档登记 | series docs |

## Phases（六原子步骤）

### Phase 1: ① 锚点核验（铆钉前置门）
- [ ] style token/角色卡+母图锚点/场景卡/道具卡/bible 绑定表/continuity/outline 七类逐项核验；产出=核验清单（✅/缺口登记行）；M0 门口径=N2-N4 缺件降为资产缺口登记不 STOP，其余缺=blocked
- **V-N:** VC-2, VC-6
- **Status:** pending
- **Executor:** 主进程/executor（需 bible/continuity 上下文）

### Phase 2: ② M0 集级大纲（唯一人工停点）
- [ ] 十节大纲（冲突/段子清单/反转/情绪弧线/传播位）+反平淡自检 10 问；完成态=STOP 呈用户放行；放行/否决逐字登记（progress+Decisions 双落）
- **V-N:** VC-1, VC-3
- **Status:** pending
- **Executor:** script-writer（M0 模式）→用户放行

### Phase 3: ③ M1 剧本展开
- [ ] 铆定放行大纲展开（禁临场发明段子/冲突）；头部五声明块齐；台词密度/段子密度/情绪弧线按 outline 节奏参数；产出=epNN-script 件（五块+三表+时间轴）
- **V-N:** VC-2, VC-3
- **Status:** pending
- **Executor:** script-writer（M1 模式）

### Phase 4: ④ M2 全量审查（判定层全集，只读）
- [ ] 判定维全集逐维结论；出场角色表双向对账/八红线自检/大纲核对/E 维完整性——缺任一=总评强制 FAIL；产出=审查报告（verdict+逐条 findings）
- **V-N:** VC-3, VC-5
- **Status:** pending
- **Executor:** script-auditor（M2 只读，与 P3/P5 不同执行体）

### Phase 5: ⑤ M3 静默修正闭环
- [ ] findings 逐条修（blocker/major→全清）→复检环；0 用户打断；≤3 轮收敛，超轮升级呈报（附已尝试清单）；修正日志逐条留痕
- **V-N:** VC-4, VC-5
- **Status:** pending
- **Executor:** script-writer（M3 模式）

### Phase 6: ⑥ 定稿与登记收口
- [ ] verdict 达标才定稿；prompts 联动缺口登记；废弃版本当日归档（-superseded+登记簿一行）；资产缺口扫描移交
- **V-N:** VC-5, VC-6
- **Status:** pending
- **Executor:** 主进程（验收+登记）

## 🔗 隔离与静默纪律
- M2 审查（script-auditor，只读）与 M1/M3 落刀（script-writer）分属不同执行体，防自我背书
- 静默环：M3 不呈送中间态；用户可见态仅两个=M0 大纲、定稿本
- `[gate-skip]` 仅限用户显式原话逐字登记且双落 progress+Decisions；范围外批次另行授权

## 📚 必要知识储备（开工前必填，均仓相对路径或技能名）
| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|----------|------|---------|--------|
| 工作流 | script-craft 技能（M0-M3 模板/判定清单/verdict 模板） | 仓库技能层 .zcode/skills/script-craft/ | 必读 | ☐ |
| 系列设定 | bible 绑定表/outline 节奏参数/continuity | docs/series/<id>/ | 必读 | ☐ |
| 角色 | 角色卡（含音色/声线）+MCD | assets/<series>/cards/characters/；docs/CHARACTER.md §4.8 | 必读 | ☐ |
| 风格 | style.md token 块+语言锁基线 | docs/style.md | 必读 | ☐ |
| 对话基线 | 对话守则+分剧语料路由 | 系列内 dialogue-rules 件；docs/corpus-styles/index.md | 参考 | ☐ |

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |          |        |      |
