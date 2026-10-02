# Task Plan: [图像生成任务]
<!-- template_type: image -->
<!-- 图像生成工作流（Agnes 图像链路：母图/资产件/关键帧·线稿格/批量出图/修词重抽）。目标=出图稳定性与一致性：九原子步骤管线+合规/一致性/质量三检硬门+全自动静默。触发词：图像生成/批量出图/母图/关键帧批/线稿批/修词重抽/多抽卡/资产图/缺陷重出 -->
<!-- 九原子步骤对照：①剧本规划=P1 ②合规与物理事实核验=P2 ③多状态定义=P3 ④提示词结构化=P4 ⑤图像生成=P5 ⑥质量审查+⑦缺陷检测+⑧静默重生成=P6（检测→归因→静默重抽闭环，回 P4/P5） ⑨终验=P7 -->
<!-- 交互模式：本模板计划默认 interaction_mode: silent（2026-10-01 用户定令"fully automated, silent mode with minimal interruptions"）——批次执行 0 用户打断，唯一合法打断=预算冻结 STOP（约束 19②）与 Rule 28 D6 硬停点；人工裁决收敛到 Phase 7 批次末单份收尾报告（静默决策清单随附） -->
<!-- 门语义（与 video 模板的关键差异，同上用户定令）：约束 16 试水门在本工作流内机器化——试水件=批次第 1 件，须过 Phase 6 完整三检才扩批（FAIL=修词重抽直至 PASS，禁扩批）；验收件日后进视频链路仍受 AGENTS.md 约束 14 草稿人工门（视频侧门不豁免） -->
<!-- plan_tier: standard -->
## Goal
[一句话：本图像任务产出什么（N 件×用途×分型），达成标准（逐件三检 PASS 证据齐+预算账本对账+台账/归档收口+静默自动完成）]

## 任务分型（三选一，只调 Phase 1-3 深度；Phase 4-7 管线恒定）
| 型 | 场景 | 分型差异 |
|----|------|---------|
| A 资产件 | 母图/定妆/装备变体/场景包/道具 sheet | P1 先查 masters-registry 与根图派生链（根图先行）；P3 含 multiview/threeview/sheet 规格；P7 接 registry/upload-map 登记 |
| B 镜头图 | 关键帧/线稿格/合图素材（服务视频生产） | P1 锚点取剧本三表逐行；P3 必含走位清单（walk_lock）+geo lock；产出=草稿层，进视频前仍走 video 模板人工门 |
| C 修正重抽 | 缺陷件修词重出/择优替换 | P1 即做 4 维归因（P6 前置）；沿用原件预检记录；重抽与原件同 piece_id 计账 |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | **三检闭环（核心铁律）**：每张验收图三检证据齐——①合规检（安全装备/危险动作/平台合规）②一致性检（对锚件与剧本逐字溯源，无法溯源=编造=FAIL）③质量检（事实性/逻辑性+解剖双硬错误+水印乱码+风格漂移）；任一缺检/未过=不得验收、不得入台账、不得进下游 | 逐件三检行（件名×检种×结论×日期）grep 可查 | progress.md 三检登记+tmp/qc-*.json |
| VC-2 | 锚点先行：生成前锚点清单齐（角色 MCD/multiview、场景卡、道具卡逐字取用），缺锚=STOP 转资产补制，禁盲生成；提示词实体串=MCD 逐字，禁自创锚件不存在属性（第零条） | 锚点清单行+提示词 vs MCD 对照 | 提示词存档+对照行 |
| VC-3 | 提示词结构化：四段式+style.md §2 token 块+§4 负向基线+常识子句族+去标注剥离（线稿源）+行驶强化负向；五问自检过 | grep 提示词档案四段与 token 块 | prompts/ 提示词档案 |
| VC-4 | 预算账本：批量走 tools/gen.py spec `budget{piece_id,limit}` 闸门（≤20 抽/件跨版本累计）；超限 exit 3 冻结——冻结件禁任何续抽（含换单），STOP 呈用户=合法打断 | tmp/_gen-budget/ledger.json 对账行 | 账本+spec |
| VC-5 | 静默纪律：批次执行 0 用户打断（VC-4 冻结与 D6 除外）；子代理进度只落检查点文件不回传过程叙事；批次末单份收尾报告（逐件展示+审查地址清单 tmp/×URL+静默决策清单） | progress.md 打断计数（除登记项=0） | 收尾报告+progress.md |
| VC-6 | 台账与归档收口：验收件 URL/seed/参数入 output/ 台账；落选/失败件当日归档（-failed/-superseded+归档登记簿一行）；A 型件同步 registry/upload-map | 台账行 grep URL+归档登记 | output/*.md+docs/archive/README.md |
| VC-7 | 多态与状态登记：换装/加装偏离走白名单登记（角色卡服装变体表/道具卡装备变体表+i2i 锚定根图）；状态链字段逐件登记（时段/天气/载具态/穿戴态） | grep 变体登记行+状态链表 | 角色/道具卡+progress.md |

## Phases（九原子步骤管线）

### Phase 1: ① 剧本规划（件清单与锚点）
- [ ] 件清单逐行（piece_id×用途×规格×候选数 N——重要件多抽卡，约束 19①）；分型路由确认（C 型先做 4 维归因）
- [ ] 锚点清单：每件出场实体→现役锚件逐字取用；缺锚=STOP 登记缺口转资产补制，禁盲生成
- **V-N:** VC-2, VC-7
- **Status:** pending
- **Executor:** 主进程/executor（规划层需 bible/MCD 上下文）

### Phase 2: ② 合规与物理事实核验（预检——FAIL=改规划不生成）
- [ ] 安全合规逐件自检（骑行头盔/水域救生/危险动作；骑行镜提示词必带头盔子句）
- [ ] 物理事实预检：多态状态声明（行驶禁开门/升顶落下锁定/水域着装）逐件核对
- **V-N:** VC-1, VC-7
- **Status:** pending
- **Executor:** 子代理（审查执行体；判定层=videop1-review-safety+review-physics 快审）

### Phase 3: ③ 多状态定义（状态卡逐件）
- [ ] 逐件状态卡：服装变体（角色卡登记表取场景适配）/道具状态/载具态（升顶落下锁定）/时段天气；偏离走白名单登记（换装/加装+i2i 锚定根图）
- [ ] 状态词固化进提示词固定句式（P4 输入）
- **V-N:** VC-7, VC-2
- **Status:** pending
- **Executor:** 主进程（设定层判断需角色卡上下文）

### Phase 4: ④ 提示词结构化（逐件提示词卡）
- [ ] 四段式：主体（MCD 逐字）+动作/状态+场景/光线+风格 token 块与负向基线+常识子句族+语言/去标注子句；五问自检过
- [ ] 判定层快审（videop1-review-prompt：D10 逐字一致/元素可见性二选一）
- **V-N:** VC-3, VC-2
- **Status:** pending
- **Executor:** 子代理（写词执行体）→主进程抽查

### Phase 5: ⑤ 图像生成（试水件=机器门）
- [ ] tools/gen.py spec 逐件 jobs（budget{piece_id,limit} 账本闸门）；试水件=批次第 1 件
- [ ] 试水件过 P6 完整三检 PASS 才扩批；FAIL=修词重抽直至 PASS（禁扩批）；多抽卡批量出 N 候选全下载 tmp/
- **V-N:** VC-4, VC-1
- **Status:** pending
- **Executor:** 子代理 A（生成执行体；禁在本 Phase 内自行扩批）

### Phase 6: ⑥ 质量审查+⑦ 缺陷检测+⑧ 静默重生成（闭环，回 P4/P5）
- [ ] 机检 tools/qc.py 逐件（≤4 图/批）+主进程 Read 亲检（机判=参考项，亲检=验收前置——visual-audit-discipline 判例）
- [ ] 三检登记逐件三行（合规/一致性/质量×结论×日期）；缺陷 4 维归因（提示词缺陷/模型随机/参考带入/规格缺陷）
- [ ] 静默重生成唯一路径=修词重抽（正向显式子句+§4 负向；禁 PIL 修补/同词原参重发）；同型缺陷 ≥2=模板级固化子句进 prompts/+判例入 docs/experience/；落选件当日归档
- **V-N:** VC-1, VC-4, VC-7
- **Status:** pending
- **Executor:** 子代理 B（重抽执行体，与子代理 A 分派）+主进程亲检

### Phase 7: ⑨ 终验与静默交付
- [ ] 终验门：逐件三检证据齐+预算账本对账+择优件 tmp/ Read 展示+审查地址清单（tmp 绝对路径×公网 URL，缺地址=未送审）
- [ ] 台账/归档/登记收口（VC-6）；单份收尾报告呈用户（逐件验收行+归档清单+账本对账+静默决策清单）
- **V-N:** VC-5, VC-6
- **Status:** pending
- **Executor:** 主进程（亲检终判+报告）

## 🔗 子代理隔离与静默纪律
- 生成（P5/重抽）与机检 QC 分属不同执行体；主进程 Read 亲检=验收前置；人工裁决只在 P7 收尾报告与两类合法打断点
- 子代理 prompt 必含：piece_id×账本 limit×锚点材料包路径×三检判据指针×「止于本相，禁跨相衔接」；子代理无权代替三检判定或放行
- 静默：失败/重试只落 progress.md+检查点文件（subagent-state/），不向用户推送中间过程；生成物展示规则全程适用（tmp/ 下载+Read 呈示+审查地址清单）
- 预算冻结（≤20 抽/件耗尽）=STOP 呈用户（合法打断）；冻结期间禁对该件任何续抽（含换单/换版本号）

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）
| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|----------|------|---------|--------|
| 风格规范 | style.md §2 token 块+§4 负向基线 | docs/style.md | 必读 | ☐ |
| 锚件事实源 | MCD/multiview/masters-registry | docs/CHARACTER.md §4.8+assets/<series>/masters-registry.md | 必读 | ☐ |
| 项目指令 | AGENTS.md 约束 8/9/13/16/19+第零条裁决顺位 | AGENTS.md | 必读 | ☐ |
| 提示词件 | structured-shot-template/common-sense-clauses/model-limit-avoidance | prompts/ | 必读 | ☐ |
| 工具面 | gen.py 预算账本/qc.py 机检（≤4 图/批） | tools/README.md+videop1-tools skill | 必读 | ☐ |
| 判定层 | review-image/review-physics/review-safety/review-prompt/review-image-script/review-asset-anchor | videop1-review-index 路由 | 必读 | ☐ |

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

