# Task Plan: [角色设计与一致性锁定任务]
<!-- template_type: character-design -->
<!-- 角色资产工序专用：设定卡→根图→QC→G1 定稿→multiview→MCD+四登记→一致性锁传播。边界：新角色/角色包；既有根锚派生补制入 multiview-ref-type；场景/道具件入 image-type。触发词：新角色/定妆/角色卡/母图/一致性锁定 -->
<!-- 五要素：①编号原子步骤+显式状态定义（角色卡全字段+状态卡）+合规检（中式审美基线/双硬错误/安全）+静默迭代（修词重抽环）+验收判据（VC 表） -->
<!-- 交互：默认 interaction_mode: silent——生成/QC/重抽环静默；唯一合法人工停点=G1 定妆终审（现役锚定门）与预算冻结 STOP（≤20 抽/件）、Rule 28 D6 -->

<!-- plan_tier: standard -->
## Goal
[一句话：N 个角色资产包（定妆根图+multiview 合版+角色卡含音色）定稿入库，达成标准（G1 放行+双硬 QC 全过+四登记齐）]

## 任务分型（三选一）
| 型 | 场景 | 差异 |
|----|------|------|
| A 常驻新角色 | 有台词/特写的正式角色 | 全六相+五件包全量 |
| B 一次性角色 | 单集功能性出场 | 简化包产线（自动工单）；有台词/特写默认升级 multiview |
| C 存量升级 | 旧三视角件升 multiview | P1 直入根锚确认，P4 重补制 |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 原子闭环：六相顺序过门；根图未定稿禁派生（根图先行），禁跳根直出派生件 | Phase Status 链+根锚登记行 | task_plan |
| VC-2 | 显式状态定义：角色卡全字段（含音色/声线/服装变体登记表/变更记录）；定妆态声明入卡；一次性/常驻标注 | 角色卡字段 grep | assets/<series>/cards/characters/ |
| VC-3 | 合规检硬门：中式/东亚审美基线（禁西化五官+点缀特征 1-2 项具体位置）+逐图双硬错误 QC（事实逻辑+解剖）+安全基线 | QC 逐图行（图×结论×日期） | progress.md+tmp/qc |
| VC-4 | 静默迭代：缺陷唯一路径=修词重抽（正向显式子句+负向基线），账本 ≤20 抽/件，禁 PIL 修补/同词重发；落选件当日归档 | 账本对账行 | tmp/_gen-budget/ledger.json |
| VC-5 | 验收判据：multiview 合版=唯一现役件（三视角≠多视角判例）+主进程 Read 亲检记录+G1 放行登记行 | 亲检记录+放行登记 | progress.md |
| VC-6 | 登记收口：四登记齐（bible 绑定表/登记册/upload-map/产出台账）+MCD 逐字定稿+废弃件归档登记 | 四登记 grep | docs+assets 台账 |

## 📐 评级契约（Rule 50）

计划期把复合内容需求拆为**原子验收条目**表（机读四列 + 判定刻度）：

| 条目 | 类型 | 层级 | 权重 | 判定刻度 |
|------|------|------|------|---------|
| <需求原子化条目，逐条列出> | P（存在性）/ E（程度） | H（硬约束）/ S（评分项） | H=必过 / S=1-5×权重 | PASS/PARTIAL/FAIL 刻度 |

- 程度约束词（不注意看不到/不明显/轻微/小/淡/低调/含蓄）必须显式落为 E 类条目，禁止并入存在性条目；未标层级默认 H。
- **逐条评级**（PASS/PARTIAL/FAIL）：每条按判定刻度评级；**程度条目双向判**——过显眼（超上限）→ FAIL，过小到不可见（低于下限）→ 亦 FAIL（同时违反存在性条目），落在目标区间 → PASS。
- 加权判定：全 H 过 + S 加权总分 ≥ 阈值 = 整体 PASS；H 类任一 FAIL = 整体 FAIL，不受 S 加权补偿。

## Phases（六原子步骤）

### Phase 1: ① 设定卡（文字层定稿）
- [ ] 人设字段全定义（中式审美+点缀特征具体位置+音色/声线初值+用途定位+分型标注）；产出=设定卡（状态：待生成）
- **V-N:** VC-2, VC-3
- **Status:** pending
- **Executor:** 主进程（设定层判断需 bible 上下文）

### Phase 2: ② 根图生成（t2i 多抽择优）
- [ ] 风格 token 块+负向基线+全身构图词；批量多抽 N 候选；机器 QC（双硬错误）后主进程 Read 亲检择优；账本闸门全程生效
- [ ] 产出=根图候选（状态：待 G1）
- **V-N:** VC-3, VC-4
- **Status:** pending
- **Executor:** 子代理 A（生成+机检）→主进程亲检

### Phase 3: ③ G1 定妆终审（唯一人工停点）
- [ ] 择优件 tmp/ 下载 Read 呈示+审查地址清单+对照行（角色×特征×服装×状态）；放行=根锚确立（登记行）；否决=归档回 P2 改词
- **V-N:** VC-5, VC-1
- **Status:** pending
- **Executor:** 用户裁决（主进程 STOP 呈示）

### Phase 4: ④ multiview 补制
- [ ] i2i 锚定根图派生多视角（正/侧/背+细节格，视角清单逐行）；禁跳根；逐格双硬 QC；缺陷回修词重抽环
- [ ] 产出=multiview 合版候选（状态：待合版）
- **V-N:** VC-1, VC-3
- **Status:** pending
- **Executor:** 子代理 B（与子代理 A 分派）

### Phase 5: ⑤ MCD 定稿+四登记
- [ ] MCD 精准描述逐字段定稿；角色卡全字段回填；登记册/upload-map/产出台账四登记；状态=现役
- **V-N:** VC-2, VC-6
- **Status:** pending
- **Executor:** 主进程

### Phase 6: ⑥ 一致性锁传播
- [ ] 下游引用纪律登记（提示词逐字抄 MCD/换装走变体登记表/改声=换声通知在途任务）；基线更新（绑定表/大纲常驻名单）
- **V-N:** VC-6, VC-2
- **Status:** pending
- **Executor:** 主进程

## 🔗 隔离与静默纪律
- 生成（P2/P4）与 QC 分属不同执行体；主进程 Read 亲检=择优呈审前置；子代理无权代 G1
- 静默环：P2/P4 重抽不呈送中间态；用户可见态=G1 呈审包、入库收尾报告（逐件+审查地址清单）
- 预算冻结（≤20 抽/件耗尽）=STOP 呈用户，冻结期禁对该件任何续抽

## 📚 必要知识储备（均仓相对路径或技能名）
| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|----------|------|---------|--------|
| 角色规范 | 字段表/MCD 机制/审美基线/条款集 | docs/CHARACTER.md | 必读 | ☐ |
| 风格 | style.md §2 token+§4 负向基线 | docs/style.md | 必读 | ☐ |
| 产线 | master-asset 技能（五件包 SOP/简化包产线/预算纪律） | 仓库技能层 .zcode/skills/videop1-master-asset/ | 必读 | ☐ |
| 项目指令 | AGENTS.md 约束 7/8/9/19 | AGENTS.md | 必读 | ☐ |
| 工具 | gen.py 预算账本/compose.py 合版 | tools/README.md | 必读 | ☐ |

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |          |        |      |

## 📊 委派统计（Rule 25.4 — 终验前必填）
<!-- 
  WHAT: 本计划子代理 vs 主进程的执行分布统计。
  WHY: 子代理占比需要可见反馈闭环;委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由 → outcome 最高 PARTIAL(白名单见 critical-rules.md Rule 25.3)。
  WHEN: 每个 Phase complete 后更新;终验交付前必须完整。
-->
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  /  |
| 主进程直做 Phase 清单 | （含例外理由） |
| 委派率 | （< delegation_rate_floor 默认 0.7,或含白名单外理由 → 最高 PARTIAL） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
<!--
  WHEN: 每次 Agent() 派发前填一行;子代理返回 30s 内主进程必须 Read 实际产出 + 紧邻 Edit findings.md 回填结论(「findings 落点」列记段落锚点),两动作完成才在「备注」列勾 verify_done;failed/timeout 行必须回填 checkpoint 路径列(Rule 22.8.4)
  WHY: 子代理规模限制 + 交接文件保障(Rule 22);findings 回填绑定(Rule 19.1/22.5)防止结论只留会话记忆
  状态枚举: queued/pending/running/done/partial/timeout/failed/blocked/scaling-redispatch(22.3.1 provider 失败改派)
  列说明: 备注列 = 低频列折叠单列(rescue 换档挽救记录 档位/结果/时间,failed|timeout 行必填,Rule 22.7;retry_count = 22.3 retry_limit 计数,初值 0,每次重试 +1;verify_done☐ = Read 产出 + findings 复核/回填双条件,Rule 22.5)——字段内容不删,仅列位折叠;verify_done 无机器消费(grep 实证 scripts/*.sh 除 selftest 零命中),为人工义务,不声称机器门
  派发 prompt 八字段模板: templates/subagent_dispatch.md
  # [2026-09-27 task-v091 B-2] 单写者澄清+Handoff 低频列折叠（verify_done 无机器消费如实披露）
-->

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | | | | queued | | | | | - / 0 / ☐ |
| 2 | | | | | | | | | - / 0 / ☐ |
| 3 | | | | | | | | | - / 0 / ☐ |

