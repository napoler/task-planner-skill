# Task Plan: [多视角参考图生成任务]
<!-- template_type: multiview-ref -->
<!-- 既有定稿根锚的派生补制工序：视角清单→i2i 派生→QC→合版定稿→归档替换。边界：新角色全包入 character-design-type；镜头图入 storyboard-type；视频修正入 video-fix-type。触发词：multiview/多视角/三视角/sheet/装备变体/补制 -->
<!-- 五要素：①编号原子步骤+显式状态定义（视角清单逐行+合版构成）+合规检（双硬错误+根锚溯源）+静默迭代（修词重抽环）+验收判据（VC 表） -->
<!-- 交互：默认 interaction_mode: silent——全程 0 用户打断（本工序无约束级人工门）；唯一合法打断=预算冻结 STOP（≤20 抽/件）与 Rule 28 D6；批次末单份收尾报告（逐件+审查地址清单） -->

<!-- plan_tier: standard -->
## Goal
[一句话：为哪些既有锚件补制 multiview/sheet/装备变体合版，达成标准（合版定稿入役+旧件归档替换+收尾报告）]

## 任务分型（三选一）
| 型 | 场景 | 差异 |
|----|------|------|
| A 角色多视角 | 缺 multiview 的已定稿角色 | i2i 锚定定妆根图 |
| B 道具/载具 sheet | 道具多视角或装备变体 | 锚定道具定稿根图；变体走装备登记表 |
| C 场景包派生 | 场景根锚派生多视角件 | 锚定根锚按派生链 |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 原子闭环：五相顺序；根锚先行——一切派生 i2i 锚定已定稿根图，禁跳根直出 | 根锚登记行+Phase 链 | task_plan |
| VC-2 | 显式状态定义：视角清单逐行（视角×格位×内容）；合版构成登记（行列/格数）；每件状态（候选/合版/现役/归档） | 视角清单+状态字段 | progress.md |
| VC-3 | 合规检：逐图双硬错误 QC（事实逻辑+解剖）+一致性（派生件与根锚逐字溯源，无法溯源=编造=FAIL）+白名单偏离登记（换装/加装） | 逐图 QC 行+溯源对照 | progress.md+tmp/qc |
| VC-4 | 静默迭代：缺陷唯一路径=修词重抽（正向子句+负向基线），账本 ≤20 抽/件；落选件当日归档 | 账本对账 | tmp/_gen-budget/ledger.json |
| VC-5 | 验收判据：multiview 合版=唯一入生产参考组件（单视角/三视角定稿件归档禁入参考组）；主进程 Read 亲检记录；收尾报告附审查地址清单（tmp 绝对路径×公网 URL） | 亲检记录+报告 | progress.md+收尾报告 |
| VC-6 | 登记收口：登记册/upload-map/产出台账更新；被替换件 -superseded 当日归档+归档登记簿一行+引用同步 grep 0 残留 | 登记行+grep | assets 台账+归档登记 |

## Phases（五原子步骤）

### Phase 1: ① 根锚确认
- [ ] 目标件现役根锚核验（定稿态/登记态）；缺根锚=STOP 转 character-design-type 补制（本模板不产根图）；产出=根锚清单（件×根锚×状态）
- **V-N:** VC-1, VC-2
- **Status:** pending
- **Executor:** 主进程（登记层判断）

### Phase 2: ② i2i 派生生成
- [ ] 视角清单逐格派生（锚定根图+视角子句+负向基线）；装备变体同步登记；账本闸门生效；产出=候选格（状态：待 QC）
- **V-N:** VC-2, VC-4
- **Status:** pending
- **Executor:** 子代理 A（生成执行体）

### Phase 3: ③ 质量审查与归因
- [ ] 机检（≤4 图/批）+主进程 Read 亲检；缺陷四维归因（提示词/随机/参考带入/规格）；FAIL 回 P2 修词重抽环（静默）
- **V-N:** VC-3, VC-4
- **Status:** pending
- **Executor:** QC 执行体+主进程亲检

### Phase 4: ④ 合版定稿
- [ ] 合图（columns 护栏，件数>3 必带；宽高比 ≤2.5）+命名归属标注（label 逐件）；合版亲检（格位×视角对照）；状态=待登记
- **V-N:** VC-5, VC-2
- **Status:** pending
- **Executor:** 子代理 B（合图）+主进程亲检

### Phase 5: ⑤ 登记替换与收尾
- [ ] 现役替换登记；被替换件当日归档+引用同步（grep 旧路径 0 残留）；单份收尾报告（逐件验收行+归档清单+账本对账+审查地址清单）
- **V-N:** VC-6, VC-5
- **Status:** pending
- **Executor:** 主进程（验收+登记）

## 🔗 隔离与静默纪律
- 生成（P2）/QC（P3）/合图（P4）分属不同执行体；主进程 Read 亲检=验收前置，机判=参考项
- 静默环：重抽不呈送中间态；用户可见=批次末单份收尾报告
- 根锚换代=派生件连锁重派生（登记链）；冻结 STOP 期间禁对冻结件任何续抽

## 📚 必要知识储备（均仓相对路径或技能名）
| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|----------|------|---------|--------|
| 派生链 | 根锚派生规则/场景包派生 | docs/CHARACTER.md §4/§8 | 必读 | ☐ |
| 产线 | master-asset 技能（multiview SOP/预算纪律/择优放行） | 仓库技能层 .zcode/skills/videop1-master-asset/ | 必读 | ☐ |
| 参考组 | 参考槽位规范（multiview 唯一件硬锁） | prompts/reference-slots-v2.md | 必读 | ☐ |
| 工具 | compose.py 合版（columns/label）/gen.py 账本 | tools/README.md | 必读 | ☐ |
| 风格 | style.md §2 token+§4 负向基线 | docs/style.md | 必读 | ☐ |

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

