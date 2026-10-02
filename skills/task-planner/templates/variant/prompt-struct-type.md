# Task Plan: [图像生成提示词结构化任务]
<!-- template_type: prompt-struct -->
<!-- 写词层工序专用：铆钉取材→四段式组装→子句族选配→自检+判定层→存档登记。边界：纯文本层零生成调用；视频提示词转换入 video-prompt-type；成图后 QC 入 qc-defect-type。触发词：写提示词/提示词结构化/组装镜头词/写词 -->
<!-- 五要素：①编号原子步骤+显式状态定义（逐件提示词卡四段齐）+合规检（判定层 D10 逐字一致/可见性二选一）+静默迭代（判定层 FAIL 回改环）+验收判据（VC 表） -->
<!-- 交互：默认 interaction_mode: silent——全程零生成零额度，判定层 FAIL 自行回改；唯一合法打断=Rule 28 D6；批次末单份收尾报告 -->

<!-- plan_tier: standard -->
## Goal
[一句话：为哪些镜头/主体产出结构化提示词卡，达成标准（四段齐+判定层快审过+存档登记）]

## 任务分型（三选一）
| 型 | 场景 | 差异 |
|----|------|------|
| A 镜头词 | epNN 逐镜生成用词 | 挂接参考组槽位与状态链 |
| B 资产词 | 母图/合版生成用词 | 挂接根图派生链与视角清单 |
| C 修词 | 缺陷纠正子句注入 | P1 并入缺陷归因；正向显式约束优先 |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 原子闭环：五相顺序；提示词卡先过判定层再入生成任务（未过卡禁投生成） | Phase 链+快审记录 | task_plan |
| VC-2 | 显式状态定义：逐件提示词卡四段齐（主体锚定段/动作状态段/场景光线段/风格约束段）+七要素（主体/动作/场景/运镜/光线/风格/约束）完整 | 四段 grep 逐卡 | prompts/ 提示词档案 |
| VC-3 | 合规检：实体描述=锚件 MCD/卡文本逐字（自创属性=FAIL）；风格 token 块+负向基线必带；子句族按域选配（常识/去标注/语言/行驶强化负向/装备状态）；安全基线（头盔/救生衣）前置 | 判定层（review-prompt）快审 verdict | 快审记录 |
| VC-4 | 静默迭代：判定层 FAIL→回 P2/P3 修正环（静默，0 打断）；同型 FAIL ≥2=子句级缺陷固化进模板件 | 回改环计数 | progress.md |
| VC-5 | 验收判据：逐卡五问自检记录+快审 PASS 行+元素可见性二选一判定（给足锚入画或零提及+负向清场） | 自检行+PASS 行 | progress.md |
| VC-6 | 登记收口：提示词卡入 epNN-prompts/提示词档案（件名×版本×状态）；废弃版当日归档 | 档案登记行 | prompts/ 档案 |

## Phases（五原子步骤）

### Phase 1: ① 铆钉取材
- [ ] 逐件锚点材料包（MCD 逐字/道具卡/场景卡/状态链字段/服装变体）；缺锚=STOP 登记缺口转资产任务；产出=材料包索引（状态：待组词）
- **V-N:** VC-2, VC-3
- **Status:** pending
- **Executor:** 主进程（登记层）

### Phase 2: ② 四段式组装
- [ ] 逐卡四段组装（主体锚定段逐字抄 MCD；动作/状态段挂状态链字段；场景光线段；风格约束段=token 块+负向基线）；产出=提示词卡草案（状态：待检）
- **V-N:** VC-2, VC-3
- **Status:** pending
- **Executor:** 写词执行体（子代理）

### Phase 3: ③ 子句族选配
- [ ] 按域选配常识子句/去标注剥离/语言约束/行驶强化负向/装备状态子句；安全子句前置；产出=完整卡（状态：待自检）
- **V-N:** VC-3, VC-2
- **Status:** pending
- **Executor:** 写词执行体

### Phase 4: ④ 五问自检+判定层快审
- [ ] 逐卡五问自检；判定层（review-prompt）快审：D10 逐字一致/可见性二选一/禁标注泄漏/语言子句在位；FAIL 回 P2 环（静默）；产出=PASS 卡池
- **V-N:** VC-5, VC-4
- **Status:** pending
- **Executor:** 判定层审查执行体（与 P2 不同执行体）

### Phase 5: ⑤ 存档登记
- [ ] PASS 卡入提示词档案（件名×版本×状态×关联镜头/主体）；版本废弃归档；单份收尾报告（逐卡清单+快审结论）
- **V-N:** VC-6, VC-5
- **Status:** pending
- **Executor:** 主进程

## 🔗 隔离与静默纪律
- 组词（P2/P3）与判定层快审（P4）不同执行体，防自我背书
- 静默环：全程零生成调用零额度消耗；用户可见=批次末收尾报告
- 子句固化：同型 FAIL ≥2 → 修模板件/子句库（当日），禁口头补丁

## 📚 必要知识储备（均仓相对路径或技能名）
| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|----------|------|---------|--------|
| 组词法 | 结构化镜头模板+四段式+五问自检 | prompts/structured-shot-template.md | 必读 | ☐ |
| 子句库 | 常识子句族/模型盲区规避 | prompts/common-sense-clauses.md；prompts/model-limit-avoidance.md | 必读 | ☐ |
| 槽位 | 参考组槽位规范 | prompts/reference-slots-v2.md | 必读 | ☐ |
| 锚件 | MCD/角色卡/道具卡/场景卡 | docs/CHARACTER.md §4.8；assets/<series>/cards/ | 必读 | ☐ |
| 风格 | style.md §2 token+§4 负向基线 | docs/style.md | 必读 | ☐ |
| 判定层 | review-prompt 技能 | 仓库技能层 .zcode/skills/videop1-review-prompt/ | 必读 | ☐ |

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

