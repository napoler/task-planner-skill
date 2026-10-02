# Task Plan: [物理事实与交通合规核验任务]
<!-- template_type: physics-compliance -->
<!-- 判定审查工序：风险清单→逐镜合规核对→多态状态声明→修正路由→判定报告。边界：纯审查零生成调用；缺陷重生成处置入 qc-defect/video-fix-type；完整词工序入 prompt-struct-type。触发词：物理核验/合规检查/交通合规/装备核对/物理审查 -->
<!-- 五要素：①编号原子步骤+显式状态定义（逐镜风险状态卡）+合规检（本模板即判定工序）+静默迭代（核对 FAIL 回改环）+验收判据（VC 表） -->
<!-- 交互：默认 interaction_mode: silent——核对与回改环静默；唯一合法打断=发现系统性风险面（建议全批冻结）时 STOP 与 Rule 28 D6 -->

<!-- plan_tier: standard -->
## Goal
[一句话：对哪批镜头行/提示词做物理事实与交通合规判定，达成标准（逐镜判定报告+修正路由清单+零未处置 FAIL）]

## 任务分型（三选一）
| 型 | 场景 | 差异 |
|----|------|------|
| A 发批前预检 | 生成前镜头行/词判定 | 全镜序核对 |
| B 成图/成片后核验 | 对产出物判定 | 附加画面层证据（抽帧） |
| C 规则修订触发 | 同型 FAIL 复盘 | P1 并入判例归因 |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 原子闭环：五相顺序；未出判定报告禁进生成/投产（预检前置） | Phase 链+报告文件 | task_plan |
| VC-2 | 显式状态定义：逐镜风险状态卡（镜号×风险类[骑行/水域/夜驾/载具态/开门/装备]×判定×证据），判定枚举 PASS/FAIL/WAIVED（waived 须条款依据） | 状态卡 grep 逐镜 | progress.md/报告 |
| VC-3 | 合规检（判定清单）：骑行全员头盔含后座/水域按场景补救生装备/行驶中禁开门与升顶落下锁定/危险驾驶动作零容忍/交通法规基线——逐镜逐条过 | 判定层（review-physics/safety）清单逐条 | 判定报告 |
| VC-4 | 静默迭代：FAIL 项路由修正（改剧本/改词/改状态声明）后复检环静默；复检仍 FAIL=升级 STOP（合法打断，附已尝试清单） | 修正路由行+复检环计数 | 判定报告 |
| VC-5 | 验收判据：多态状态声明块齐（V38 口径：每镜载具态/装备态/环境态显式）+判定报告 verdict=全 PASS 或 FAIL 项全部路由处置 | verdict 行+声明块 grep | 判定报告 |
| VC-6 | 登记收口：判定报告归档（批次×日期×verdict）；同型 FAIL ≥2 固化子句/条款；判例入 docs/experience/ | 归档行+固化记录 | docs/experience/ |

## Phases（五原子步骤）

### Phase 1: ① 风险清单提取
- [ ] 对象件（镜头行/提示词/画面）逐镜扫风险类（骑行/水域/夜驾/载具/装备/人群）；产出=风险清单（镜×风险类，状态：待核对）
- **V-N:** VC-2, VC-3
- **Status:** pending
- **Executor:** 判定执行体（子代理，清单提取）

### Phase 2: ② 逐镜合规核对
- [ ] 判定清单逐镜逐条核对（头盔含后座/救生装备/禁开门/升顶锁定/危险动作/交通法规）；画面核验场景附抽帧证据；产出=逐镜状态卡
- **V-N:** VC-3, VC-2
- **Status:** pending
- **Executor:** 判定执行体（review-physics/safety 判定层口径）

### Phase 3: ③ 多态状态声明核对
- [ ] 每镜载具态/装备态/环境态显式声明核对（缺声明=FAIL——状态先验污染防线）；产出=声明块核对行
- **V-N:** VC-5, VC-2
- **Status:** pending
- **Executor:** 判定执行体

### Phase 4: ④ 修正路由（FAIL 处置）
- [ ] FAIL 逐项路由：改剧本（script-dev 域）/改词（prompt-struct 域）/改状态声明（上游补块）；路由后复检环静默；系统性风险面=STOP 建议（合法打断）
- **V-N:** VC-4, VC-3
- **Status:** pending
- **Executor:** 判定执行体出路由+主进程复核

### Phase 5: ⑤ 判定报告与固化
- [ ] verdict 汇总（全 PASS/FAIL 全路由）；报告归档登记；同型 FAIL ≥2 固化子句与判例；单份收尾报告
- **V-N:** VC-6, VC-5
- **Status:** pending
- **Executor:** 主进程

## 🔗 隔离与静默纪律
- 判定执行体独立于被审对象的生产执行体（审查不同执行体，防自我背书）
- 静默环：复检环不呈送中间态；用户可见=系统性风险 STOP、批次末收尾报告
- waived 判定必须附条款依据行，禁无依据豁免

## 📚 必要知识储备（均仓相对路径或技能名）
| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|----------|------|---------|--------|
| 判定层 | physics 判定技能（成图/成片 QC 默认门+行驶禁开门锚例） | 仓库技能层 .zcode/skills/videop1-review-physics/ | 必读 | ☐ |
| 安全判定 | safety 判定技能 | 仓库技能层 .zcode/skills/videop1-review-safety/ | 必读 | ☐ |
| 基线 | 安全合规基线（头盔含后座/救生/危险动作）+状态链 | AGENTS.md 约束 7/9；docs/experience/ 判例 | 必读 | ☐ |
| 多态声明 | V38 多态状态声明块口径 | script-craft 判定清单 | 必读 | ☐ |
| 装备 | 装备三元组/道具状态锁 | script-craft V12/V13 | 参考 | ☐ |

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

