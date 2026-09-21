# Task Plan: [视频创作任务]
<!-- template_type: video -->
<!-- 视频创作任务（Agnes API 链路：母图/资产生成、分镜提示词、镜头/整集视频生产、修正重生成、成片质检、台账登记） -->
<!-- 触发词：视频生成/母图/定妆/场景母图/分镜/提示词/重生成/成片质检/视频资产/整集生产 -->
<!-- 人工门：草稿（关键帧/参考稿）未过 AGENTS.md 关键约束 14 用户定稿，任何 video 调用 STOP（判例 videop1 lineart-storyboard 段一 7 段作废；Rule 32.2 禁令：无第一人工确认就发起 video） -->

<!-- plan_tier: standard -->
## Goal
[一句话：本视频任务产出什么（N 段视频/一批资产/修正重出），达成标准（QC 全 PASS + 台账登记 + 草稿经人工门放行）]

## 任务分型（三选一，决定 Phase 序列）
| 型 | 场景 | Phase 骨架 |
|----|------|-----------|
| A 整集 | epNN 全片镜头生产（剧本→草稿→视频→成片 QC） | P1 基线核验 → P2 草稿产出（**子代理 A**）→ **P3 G1 人工门（STOP 等用户）** → P4 视频生成（**子代理 B**）→ P5 成片 QC+台账 |
| B 资产 | 母图/场景/道具/UI 生成与登记 | P1 需求+风格/角色卡核验 → P2 生成+机器 QC → **P3 G1 人工门（定妆终审签核）** → P4 台账/角色卡登记 |
| C 修正 | 既有镜头/资产修正重生成 | P1 归因（提示词缺陷/模型随机/参考带入）→ P2 改词重出草稿 → **P3 G1 人工门（重出件不豁免，r2 亦须过）** → P4 重发视频 → P5 成片 QC |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 成图 QC 闭环：所有图片产物（母图/关键帧/成片帧）先 analyze 机器质检过，未 QC 不得 complete、不得入台账 | analyze_image/analyze_video 报告 + progress 记录 | tmp/qc-*.json |
| VC-2 | 风格一致：提示词携带 style.md §2 token 块 + §4 负向基线（行驶镜强化负向） | grep 提示词档案 token 块 | epNN-prompts.md / 提示词存档 |
| VC-3 | 角色一致：出场角色提示词逐字抄角色卡；登记角色禁纯文生视频（须带母图走 reference/keyframe） | grep 角色串=角色卡原文 | 角色卡对照 |
| VC-4 | 安全合规：骑行全员头盔（含后座）/水域救生装备/无危险驾驶动作——发起 video 前逐镜头自检过 | 自检清单（镜位×装备×结论） | progress.md 自检行 |
| VC-5 | 台账登记：生成物 URL/seed/参数落 output/ 台账；可复现任务 seed 记录 | 台账行 grep URL | output/*.md |
| VC-6 | 成本警示：video 调用前已向用户提示配额/计费；逐 case 测试走 smoke-test 不裸调 video | progress.md 警示行 | progress.md |
| VC-7 | **草稿人工审查门（AGENTS.md 关键约束 14）**：任一 video 调用前，草稿图已 tmp/ 呈示+用户定稿放行；放行/跳过/否决三登记齐全（镜位×草稿版本×判定×日期）；跳过仅当用户显式指令且 `[gate-skip]` 逐字登记 progress.md+Decisions；无登记=违规，产出按"未经门"作废重走门 | grep progress.md 放行/gate-skip 行 | progress.md + task_plan Decisions |

## Phases（A 型示例；B/C 型按上表骨架裁剪）

### Phase 1: 基线核验（铆钉前置门）
- [ ] 剧本三表（出场角色/骑行装备/道具状态）逐行取现役锚点，缺锚点=STOP 先走 B 型补资产
- [ ] 风格/角色卡/场景卡/绑定表/continuity 核验（N1-N7 铆钉）
- **Status:** pending
- **Executor:** 主进程/executor

### Phase 2: 草稿产出 + 机器 QC（子代理 A 任务——完成态=STOP，不衔接视频）
- [ ] 元素清单+合图（PIL 等比禁裁剪，人物格大道具格小；合图仅辅助参考，分离图仍单独进 reference）
- [ ] 关键帧 i2i（多图官方模板逐张点名）/线稿定稿页
- [ ] analyze_image 逐图机器 QC（事实性/解剖双硬错误；不过=回改重出，不过的草稿不送审）
- [ ] 草稿全部下载到 tmp/ 供呈示
- **Status:** pending
- **Executor:** 子代理 A（executor 或对应生成 agent；**草稿任务内禁止任何 video 调用**）

### Phase 3: G1 人工审查门（STOP 等用户裁决）
- [ ] 草稿逐张 Read 呈示 + 对照行（镜位×出场角色×头盔×座驾×道具状态×时段）
- [ ] 用户逐张/逐段定稿放行（或否决/或显式指令跳过）
- [ ] 三登记：放行/跳过/否决各一行（镜位×草稿版本×判定×日期）入 progress.md；跳过须 `[gate-skip]` 逐字录用户原话 + task_plan Decisions；否决镜草稿当日归档（-failed/-superseded）
- **门控语义**：本 Phase complete 条件=放行登记行存在（progress.md 可 grep）；未获放行=本 Phase 停留 in_progress 呈用户，**禁止进入 Phase 4**
- **Status:** pending
- **Executor:** 用户裁决（主进程 STOP 呈示，子代理无权代放行）

### Phase 4: 视频生成（子代理 B 任务——与 Phase 2 分派不同子代理）
- [ ] 启动前置检查：Phase 3 放行登记行 grep 可查（缺=STOP 回 G1）
- [ ] reference 模式混交 4-5 张（关键帧+角色母图+道具+场景）发起 video；批次级成本警示（VC-6）已在前置完成
- [ ] 轮询完成、逐段 analyze_video 机器质检
- **Status:** pending
- **Executor:** 子代理 B（与子代理 A 独立任务；派发 prompt 含 Rule 32.2 禁令行）

### Phase 5: 成片 QC + 台账 + 归档
- [ ] FAIL 段：回 Phase 2 重出草稿重走 ③④（修正型 C 的 r2 不豁免人工门）
- [ ] 全 PASS：URL/seed/参数入 output/ 台账；否决/废弃件按归档规程当日归档
- [ ] 展示规则：成片 tmp/ 下载后 Read 呈示（批量逐条）
- **Status:** pending
- **Executor:** 子代理 B → 主进程验收

## 🔗 子代理隔离铁律（AGENTS.md 约束 15 执行序）
- ③ 草稿产出+④ 机器 QC = **子代理 A**；⑥ 视频生成 = **子代理 B**；同任务/同 Phase 自动衔接=违规
- 派发 B 的 prompt 必含：「前置=草稿放行登记存在（progress.md grep 可查，缺=STOP 不得发起 video）」+ Rule 32.2 禁令原文
- A 的任务 prompt 必含：「本任务止于草稿+机器 QC+呈示，完成态=STOP 呈用户；禁止调用 AGNES_API video 子命令」
- 子代理只能产出草稿与机器 QC 结论；**人工放行判定只有用户能做**

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）
| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|----------|------|---------|--------|
| 风格规范 | style.md token 块+负向基线 | docs/style.md §2/§4 | 必读 | ☐ |
| 角色卡 | 出场角色全字段（含音色/声线） | assets/<series>/cards/characters/ | 必读 | ☐ |
| 项目指令 | AGENTS.md 关键约束 4/8/9/13/14/15 + SOP 七阶段 | AGENTS.md | 必读 | ☐ |
| 台账约定 | output/ 台账格式+tmp/ 命名 | AGENTS.md 文件命名规则 | 必读 | ☐ |

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |          |        |      |
