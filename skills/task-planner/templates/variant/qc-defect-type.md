# Task Plan: [质量审查与缺陷检测任务]
<!-- template_type: qc-defect -->
<!-- 质检工序：抽样拆批→机检→亲检→四维归因→最小范围处置→判例固化。边界：判定与处置路由（重生成执行入 image-type/video-fix-type 生产域）；单一资产补制入 multiview-ref-type。触发词：质检/QC/缺陷检测/成片审查/择优 -->
<!-- 五要素：①编号原子步骤+显式状态定义（逐件质检卡+处置枚举）+合规检（双硬错误+风格+一致性）+静默迭代（QC-重抽环 0 打断）+验收判据（VC 表） -->
<!-- 交互：默认 interaction_mode: silent——QC 与重抽修正环静默；唯一合法打断=全量级缺陷（须用户显式批准 full-regen）与预算冻结 STOP、Rule 28 D6 -->

<!-- plan_tier: standard -->
## Goal
[一句话：对哪批产出件（图/片）质检并出处置清单，达成标准（逐件质检卡齐+FAIL 全路由+判例固化）]

## 任务分型（三选一）
| 型 | 场景 | 差异 |
|----|------|------|
| A 成图质检 | 图片批交付前 | 机检 ≤4 图/批+亲检择优 |
| B 成片质检 | 视频段/成片判定 | 四趟协议×五层判据（video-qc 口径） |
| C 缺陷专案 | 用户指认/复现缺陷 | P1 并入归因；最小范围处置 |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 原子闭环：六相顺序；未过质检件禁交付/入台账/进下游（先 QC 后展示） | Phase 链+质检卡 | task_plan |
| VC-2 | 显式状态定义：逐件质检卡（件名×检种×结论枚举 PASS/FAIL/WAIVED×缺陷分类×处置枚举[剪辑补救/段级重生成/整件重生成/全量例外]） | 质检卡 grep | progress.md |
| VC-3 | 合规检：双硬错误（事实逻辑+解剖）逐件必检；水印乱码/风格漂移/元素缺失/一致性偏离分类判；机检 ≤4 图/批拆批纪律 | 机检输出+亲检记录 | tmp/qc+progress.md |
| VC-4 | 静默迭代：FAIL 处置回生产域修正环（静默）；复检闭环至 PASS；同型缺陷 ≥2=模板级（先固化子句再分流） | 复检环计数+固化记录 | progress.md |
| VC-5 | 验收判据：主进程 Read 亲检=机判之上的前置仲裁（机判=参考项，判例 visual-audit-discipline）；择优件=亲检记录在案；处置=最小范围四级阶梯（能小不大，全量=用户显式批准登记） | 亲检行+处置登记 | progress.md+Decisions |
| VC-6 | 登记收口：质检报告归档（批×verdict）；PASS 件入台账；FAIL 件按处置路由移交；判例入 docs/experience/ | 报告+台账行 | 报告+output 台账 |

## Phases（六原子步骤）

### Phase 1: ① 抽样与拆批
- [ ] 全件清点入检（件名×源任务×版本）；机检拆批（≤4 图/批，sheet 锚不离批）；产出=入检清单（状态：待机检）
- **V-N:** VC-2, VC-3
- **Status:** pending
- **Executor:** QC 执行体（子代理）

### Phase 2: ② 机检
- [ ] tools/qc.py 逐批机检（八类判据）；产出=机检原始结论（状态：待亲检）
- **V-N:** VC-3, VC-2
- **Status:** pending
- **Executor:** QC 执行体

### Phase 3: ③ 主进程亲检
- [ ] 逐件 Read 亲检（机判之上前置仲裁）；机检满分仍错=以亲检为准（判例）；产出=质检卡（状态：待归因）
- **V-N:** VC-5, VC-3
- **Status:** pending
- **Executor:** 主进程亲检

### Phase 4: ④ 缺陷归因
- [ ] FAIL 件四维归因（提示词缺陷/模型随机/参考带入/规格缺陷）；同型 ≥2 判模板级；产出=归因表
- **V-N:** VC-4, VC-2
- **Status:** pending
- **Executor:** QC 执行体出表+主进程复核

### Phase 5: ⑤ 最小范围处置路由
- [ ] 四级阶梯分流（剪辑补救 0 生成/片内段级重生成/整件重生成/全量例外=用户显式批准登记）；路由单发对应生产域；产出=处置清单
- **V-N:** VC-5, VC-4
- **Status:** pending
- **Executor:** 主进程（路由裁决）

### Phase 6: ⑥ 复检闭环与判例固化
- [ ] 修正件回 P1 复检环（静默）至 PASS；同型缺陷固化子句/模板件；判例入 docs/experience/；质检报告归档+台账收口
- **V-N:** VC-4, VC-6
- **Status:** pending
- **Executor:** QC 执行体+主进程

## 🔗 隔离与静默纪律
- QC 执行体独立于生产执行体；亲检=主进程；处置路由=主进程（子代理无权裁决处置级）
- 静默环：复检环不呈送中间态；用户可见=全量例外请求、预算冻结 STOP、批次末质检报告
- 先 QC 后展示；机检满分不豁免亲检

## 📚 必要知识储备（均仓相对路径或技能名）
| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|----------|------|---------|--------|
| 成片判定 | video-qc 技能（四趟协议×五层判据×可用性分级） | 仓库技能层 .zcode/skills/videop1-video-qc/ | 必读 | ☐ |
| 图检 | review-image 判定+机检拆批 ≤4 配方 | 仓库技能层 .zcode/skills/videop1-review-image/；tools/README.md | 必读 | ☐ |
| 处置 | 最小范围四级阶梯/seam 边界 | videop1-video-fix 技能；AGENTS.md 约束 17 | 必读 | ☐ |
| 判例 | 双硬错误/择优/亲检前置判例链 | docs/experience/ | 参考 | ☐ |
| 工具 | qc.py/img_compare/edit.py | tools/README.md | 必读 | ☐ |

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

