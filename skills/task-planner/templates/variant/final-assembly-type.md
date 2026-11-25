# Task Plan: [终剪组装验证任务]
<!-- template-lineage: level=derived parent=../task_plan.md base=../task_plan.md spec_version=1 pruned="用户需求原文,根源覆盖表,不变量声明区,规范基线,进度产出基线,CodeReview配置,双轮质检与同步完整性声明,核心目标达成裁决,执行范围限制,变更标注表,核心问题定义,调研需求与检索计划,证据面清单,CurrentPhase,NextStep,工具选择与编排,防倒退终检,收尾回读梳理记录,收尾对齐与清理,隔离决策,FMEA预演,原生Todo同步,KeyQuestions,DecisionsMade,ErrorsEncountered,Notes,Chain区块交接配置" pruned_reason="variant=领域裁剪全文，裁剪面以本清单显式登记（Rule 34.5 派生登记）" -->
<!-- JSON 模板源(task-json-template-20261125)：skills/task-planner/templates/json/final-assembly.template.json — 本 MD 为教学/临时视图；权威源=plan-state.json 的 template_doc/template_checks；勾选请用 planctl set --section template_checks ... -->
<!-- planctl 派生口径(task-planctl-exec-surface-20261122)：本骨架数据经 planctl add/set 写入 plan-state.json 后 render 派生 task_plan.md 视图；直接填写会在首次 render 被覆盖 -->
<!-- template_type: final-assembly -->
<!-- template_meta: {"type": "final-assembly", "name": "终剪组装验证", "summary": "成片工序：段片清点→剪辑组装→seam QC→成片判定→NAS 备份→终审登记。", "scenarios": ["粗剪", "段片组装", "成片制作", "终剪", "seam 边界检查与备份"], "features": ["段片清点与剪辑组装", "seam QC 边界检查", "成片判定", "NAS 备份与终审登记", "六原子步骤 Phases"]} -->
<!-- 成片工序：段片清点→剪辑组装→seam QC→成片判定→NAS 备份→终审登记。边界：段片生成与段级修正入 video-type/video-fix-type；配音对齐入 audio-voice-type。触发词：粗剪/组装/成片/终剪/seam/备份 -->
<!-- 五要素：①编号原子步骤+显式状态定义（段片台账×拼接清单）+合规检（seam 边界+成片判定层）+静默迭代（seam FAIL 回剪环）+验收判据（VC 表） -->
<!-- 交互：默认 interaction_mode: silent——剪辑与 seam 修正环静默；唯一合法人工停点=成片用户终审与 Rule 28 D6 -->

<!-- plan_tier: standard -->
<!-- execution_lane: L1（Rule 38.7 — 缺省 L1；L0 微变更通道禁滥用） -->
## Goal
[一句话：把哪些段片组装为完整片，达成标准（seam 全过+成片判定达级+NAS 备份+终审登记）]

<!-- 任务分型（按型裁剪 Phase 骨架）：A 全片组装=整集段片成片，全六相；B 修正回拼=替换段回拼，P1 并入替换对照+seam 复验；C 版本精修=时序/节奏重剪，P1 并入节奏参数核对 -->

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 原子闭环：六相顺序；段片清点与终稿台账逐笔对账（缺段/多段=STOP 回生产域） | 对账行+Phase 链 | progress.md+output 台账 |
| VC-2 | 显式状态定义：拼接清单逐接缝（前段×后段×接缝类型×时码）；段片状态（现役/废弃/带缺陷放行 ★✗⚠ 标记） | 拼接清单 grep | progress.md |
| VC-3 | 合规检：seam 合法性 5 边界逐缝核对+成片判定层（video-qc 四趟协议）达级；FAIL 缝回剪环（静默） | seam 核对行+判定 verdict | 判定报告 |
| VC-4 | 静默迭代：seam FAIL 回剪（tools/edit 截取/回拼/xfade）环静默 0 生成；结构性缺陷转段级处置路由（video-fix 域，不本域硬剪） | 回剪环计数+路由行 | progress.md |
| VC-5 | 验收判据：粗剪成品时码表+判定达级结论+成片 tmp/ 下载 Read 呈示+审查地址清单；终审=用户人工门（放行/否决登记） | 呈示记录+终审登记 | progress.md+Decisions |
| VC-6 | 登记收口：NAS 三目录备份（逐镜终态/成片/源版本）+VERSIONS.md 逐镜对照（★✗⚠ 全标记）；output 台账终稿行；废弃件归档 | NAS 对账+台账行 | NAS+output 台账 |

## Phases（六原子步骤）

### Phase 1: ① 段片清点对账
- [ ] 终稿台账逐笔对账（镜号×段片件×版本×状态）；缺段=STOP 回生产域；产出=段片清单（状态：待组装）
- **V-N:** VC-2, VC-1
- **Status:** pending
- **Executor:** 主进程（台账对账）

### Phase 2: ② 剪辑组装
- [ ] tools/edit 组装（cut/concat/xfade 按处置决策表；拼接清单先行）；产出=粗剪候选（状态：待 seam QC）
- **V-N:** VC-2, VC-4
- **Status:** pending
- **Executor:** 剪辑执行体（子代理）

### Phase 3: ③ seam QC
- [ ] 逐缝核对（5 边界+否定式措辞口径）；FAIL 缝回剪环（静默）；结构性缺陷转段级路由；产出=seam 核对行（状态：待成片判定）
- **V-N:** VC-3, VC-4
- **Status:** pending
- **Executor:** QC 执行体+主进程亲检

### Phase 4: ④ 成片判定
- [ ] video-qc 四趟协议判定（含语言音色观感联动 audio-voice 域核查结论引用）；FAIL 路由（回剪/段级）；产出=判定报告（状态：待终审）
- **V-N:** VC-3, VC-5
- **Status:** pending
- **Executor:** 判定执行体+主进程亲检

### Phase 5: ⑤ NAS 备份与 VERSIONS
- [ ] 三目录备份（逐镜终态件/成片/源版本存档）+VERSIONS.md 逐镜对照（★推荐/✗废弃/⚠带缺陷放行全标记，缺标记=备份不完整）；替换件同步覆盖
- **V-N:** VC-6, VC-2
- **Status:** pending
- **Executor:** 备份执行体（子代理）+主进程核对

### Phase 6: ⑥ 终审与登记（人工门）
- [ ] 成片 tmp/ 呈示+审查地址清单+时码表；用户终审（放行/否决登记）；output 台账终稿行+废弃件归档
- **V-N:** VC-5, VC-6
- **Status:** pending
- **Executor:** 用户裁决（主进程 STOP 呈示）

## 🔗 隔离与静默纪律
- 剪辑（P2）/QC（P3/P4）/备份（P5）分属不同执行体；主进程亲检=判定仲裁；终审=用户
- 静默环：回剪环不呈送中间态，用户可见=成片终审呈示包；剪辑补救优先原则——能剪不重生成（0 生成调用路径优先），结构性缺陷才路由段级重生成

## 📚 必要知识储备（均仓相对路径或技能名）
| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|----------|------|---------|--------|
| 剪辑食谱 | video-edit 技能（抽帧×3/截取/concat/xfade 命令逐字锁参） | 仓库技能层 .zcode/skills/videop1-video-edit/ | 必读 | ☐ |
| seam 判据 | 拼接合法性 5 边界+否定式措辞 | tools/README.md；videop1-video-fix 技能 | 必读 | ☐ |
| 成片判定 | video-qc 技能四趟协议 | 仓库技能层 .zcode/skills/videop1-video-qc/ | 必读 | ☐ |
| 备份规程 | NAS 三目录/VERSIONS 标记/替换同步 | docs/experience/nas-backup.md | 必读 | ☐ |
| 台账 | output 台账格式+命名规则 | AGENTS.md 命名规则；docs/naming-rules.md | 必读 | ☐ |

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


## 🎯 Goal 单元表（Rule 66.1 — attest 获批后填写）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 |  |  |  |  | pending |

## Phases 派发表骨架（S-unit 10 列固定列序——check-plan-dispatch.sh $4/$5/$7/$8 定位，禁增列/禁单元格管道转义；类别=目标列内（An）前缀）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | （A6） | 继承 |  |  | 10min | 1f/10l/10min | 无 | - | pending |

## 📦 Batch Report（Rule 18.6 — 留空会被 check-complete 拦）
| 字段 | 值 |
|------|-----|
| `total` | n/a（<一句理由>） |
| `success` | n/a |
| `failed` | n/a |
| `failure_rate` | n/a |
| `sampled_pass` | n/a |
| `sampled_fail` | 任务 <5 单元不触发抽样 |
| `pre_check` | Q1:否 / Q2:无共享写 / Q3:能 |
| `rollback_point` | <worktree 分支，合并前可弃> |

## 🧩 输出示例与格式契约（Rule 113）
> **展示义务（Rule 113.10 · 项目级强制）**：先向用户展示至少一个完整产出示例实物（真实路径/可读代码块 + 同结构占位模板 + 审查命令与预期输出），再写条款；权威形态=`examples/json-template-upgrade/review.md`；禁仅标题 token。
> 必填：本类型计划中凡声明输出格式/结构的交付物，均须在 `plan-state.json.output_examples` 登记至少 1 条完整示例 + 1 个同结构可复用模板（经 `planctl add --section output_examples` 写入），由 `planctl render` 派生到 task_plan.md 同名区块。禁止只写「输出为 JSON」等无样例声明；禁「略/同上/TBD」。

| 交付物 | 格式 | 完整示例（fenced，见下方） | 可复用模板（占位符版，见下方） | 对应 VC |
|---|---|---|---|---|
| assembly-manifest.md | Markdown 表格 | 见下方示例代码块 | 见下方模板代码块 | VC-2 |

**完整示例（可直接查看、可比对）**：

```markdown
| 镜号 | 前段 | 后段 | 接缝类型 | 时码 | seam QC |
|---|---|---|---|---|---|
| S01 | cut-01.mp4 | cut-02.mp4 | cut | 00:00:06.000 | PASS |
| S02 | cut-02.mp4 | cut-03.mp4 | xfade | 00:00:12.000 | PASS |
```

**可复用模板（占位符版，供执行期复制）**：

```markdown
| 镜号 | 前段 | 后段 | 接缝类型 | 时码 | seam QC |
|---|---|---|---|---|---|
| <PLACEHOLDER> | <PLACEHOLDER> | <PLACEHOLDER> | <PLACEHOLDER> | <PLACEHOLDER> | <PLACEHOLDER> |
```

填写纪律：① 示例与模板的字段集/层级必须一致；② 示例必须自包含可查看（JSON 须合法可解析、表格须有表头+≥1 行数据）；③ 无格式交付物时显式写 `none-justified（理由）`，禁留空；④ 示例的 `vc_refs` 至少映射 1 个已存在 VC（Rule 113.4）。
