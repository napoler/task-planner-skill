# Task Plan: [分镜规划与镜头拆解任务]
<!-- template_type: storyboard -->
<!-- 剧本→分镜工序专用：走位清单→地理底图→线稿逐格→QC+准入→页定稿。边界：剧本文字层入 script-dev-type；关键帧后的视频生成入 video-type；单角色资产入 character-design-type。触发词：分镜/线稿/走位/镜头拆解/关键帧页 -->
<!-- 五要素：①编号原子步骤+显式状态定义（走位清单/格位映射/页状态）+合规检（走位铁律/去标注/负向基线）+静默迭代（修词重抽环）+验收判据（VC 表） -->
<!-- 交互：默认 interaction_mode: silent——线稿/关键帧修词重抽环静默；唯一合法人工停点=页级草稿人工门（约束 14）与预算冻结 STOP、Rule 28 D6 -->

<!-- plan_tier: standard -->
## Goal
[一句话：哪一集拆解为 N 页分镜（线稿定稿页+关键帧九宫格），达成标准（逐格双硬 QC 过+四步准入过+页级放行登记）]

## 任务分型（三选一）
| 型 | 场景 | 差异 |
|----|------|------|
| A 线稿页 | 走位示意定稿页 | 走位级极简上限+彩色 wash 合法 |
| B 关键帧九宫格 | 节拍钉住参考 | 第一格=首帧锚+四步准入门 |
| C 修正补页 | 既有页局部重制 | P1 并入缺陷归因；同 piece_id 计账 |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 原子闭环：五相顺序；批次第 1 件=地图俯视底图（geo lock），无现役底图=STOP；页内全格禁鸟瞰/俯视/地图 | 底图登记行+格位映射 | progress.md |
| VC-2 | 显式状态定义：逐页 walk_lock 走位清单先建后派（缺清单=STOP）；「格位 panel N×剧本镜号」映射行逐页登记；页状态（候选/QC 过/放行/废弃） | 清单行+映射行 grep | progress.md |
| VC-3 | 合规检：单格单实体/服装本镜事实/误导走位排除/间距硬子句四铁律；线稿源放样词带去标注剥离子句；行驶镜强化负向 | 逐格判定层快审（review-lineart/refgroup） | 快审记录 |
| VC-4 | 静默迭代：缺陷唯一路径=修词重抽（≤20 抽/件账本）；关键帧格入九宫格前过四步准入（机判 K 组→亲检→择优登记→送审对照）；落选件当日归档 | 准入记录+账本 | progress.md+ledger |
| VC-5 | 验收判据：页级放行=用户人工门（草稿按展示规则呈示+审查地址+逐格指认登记）；`[gate-skip]` 仅限用户原话逐字双登记 | 放行/gate-skip 登记行 | progress.md+Decisions |
| VC-6 | 登记收口：定稿页登记入册；废弃页当日归档；下游（视频任务）引用指针更新 | 登记行 | assets 台账 |

## Phases（五原子步骤）

### Phase 1: ① 剧本拆解与走位清单
- [ ] 剧本三表逐行取现役锚点；逐页 walk_lock 走位清单（主体×起点×终点×交互）；镜号-格位映射表；产出=拆解清单（状态：待底图）
- **V-N:** VC-2, VC-1
- **Status:** pending
- **Executor:** 主进程（需剧本+锚点上下文）

### Phase 2: ② 地理底图（geo lock）
- [ ] 现役集级地图俯视底图核对；缺=STOP 开底图补制；底图登记（本批全部页共用）；产出=底图登记行
- **V-N:** VC-1, VC-2
- **Status:** pending
- **Executor:** 主进程/executor

### Phase 3: ③ 线稿/关键帧逐格生成
- [ ] i2i 逐格生成（锚点铆钉件入 refs+风格防渗+走位级极简+零五官硬子句按线稿域 SOP）；批次试水件=第 1 格，过 P4 完整门才扩批；产出=候选格（状态：待 QC）
- **V-N:** VC-3, VC-4
- **Status:** pending
- **Executor:** 子代理 A（生成执行体）

### Phase 4: ④ 质量审查与准入
- [ ] 机检+主进程 Read 亲检；走位/标注泄漏/解剖逐格判；关键帧格过四步准入门；FAIL 回 P3 修词重抽环（静默）；产出=合格格池（状态：待放行）
- **V-N:** VC-3, VC-4
- **Status:** pending
- **Executor:** QC 执行体+主进程亲检

### Phase 5: ⑤ 页定稿与登记（人工门）
- [ ] 整页按展示规则呈示（格位映射行+审查地址清单+逐格指认）；放行=定稿页登记；否决格回 P3；定稿页指针更新下游
- **V-N:** VC-5, VC-6
- **Status:** pending
- **Executor:** 用户裁决（主进程 STOP 呈示）

## 🔗 隔离与静默纪律
- 生成（P3）/QC（P4）/呈审（P5）分属不同执行体；主进程亲检=呈审前置；子代理无权代页级放行
- 静默环：修词重抽不呈送中间态；用户可见=页级送审包、批次收尾报告
- 冻结 STOP（≤20 抽/格耗尽）=合法打断；冻结期禁续抽

## 📚 必要知识储备（均仓相对路径或技能名）
| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|----------|------|---------|--------|
| 线稿域 | lineart-gen 技能（walk_lock/geo/3C 满配/retry10）+线稿对齐协议 | 仓库技能层 .zcode/skills/videop1-lineart-gen/；docs/series/<id>/lineart-alignment-protocol.md | 必读 | ☐ |
| 定档 | 关键帧定档 §v6+参考槽位规范+草稿防漂移卡 | plans/task-videop1-lineart-storyboard-001/p5-reflock.md；prompts/reference-slots-v2.md；docs/series/<id>/ep1-generation-spec-card.md | 必读 | ☐ |
| 剧本 | epNN-script 三表+镜号表 | docs/series/<id>/ | 必读 | ☐ |
| 风格 | style.md §2/§4+去标注子句 | docs/style.md；prompts/common-sense-clauses.md | 必读 | ☐ |
| 工具 | gen.py 账本/qc.py 机检 | tools/README.md | 必读 | ☐ |

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

