# 场景化模板映射指南

> 根据 skill 类型匹配对应的 task_plan 变体模板。

---

## 一、模板选择决策树

```
任务描述是什么?
├─ 关键词/SERP/数据调研 → research-type.md
├─ skill 审计/bug 排查 → diagnostic-type.md
├─ 文章/长文撰写 → writing-type.md
├─ API 发布/分发（数据推送）→ publish-type.md
├─ 代码改/写/删（明确单次编辑）→ code-edit-type.md
├─ 重构（行为不变）/ 瘦身 → refactor-type.md
├─ 修 bug（用户描述了具体症状）→ bugfix-type.md
├─ 跨语言/框架迁移 / CLI 重写 → migration-type.md
├─ 单元/集成/E2E 测试编写 / 覆盖率提升 → test-writing-type.md
├─ 部署 / CI-CD / Docker / k8s / nginx / 基础设施 → deployment-type.md
├─ 性能瓶颈定位 / 优化 / 压测 / benchmark → performance-tuning-type.md
├─ DB schema 变更 / migration / 索引 / 数据回填 → schema-migration-type.md
├─ 记忆体系盘点/整理/治理（记忆目录 MEMORY.md+topic）→ memory-hygiene-type.md
├─ 图像生成工作流（母图/资产图/关键帧·线稿批/批量出图/修词重抽，Agnes 图像链路）→ image-type.md
├─ 剧本开发与合规审查（M0 大纲→M1→M2→M3，零生成）→ script-dev-type.md
├─ 角色设计与一致性锁定（设定→根图→G1→multiview→MCD 锁）→ character-design-type.md
├─ 多视角参考图补制（既有根锚 i2i 派生合版）→ multiview-ref-type.md
├─ 分镜规划与镜头拆解（走位清单/geo lock/线稿关键帧页）→ storyboard-type.md
├─ 图像提示词结构化（四段式写词，零生成）→ prompt-struct-type.md
├─ 视频提示词转换（reference 配置+机械门，零视频调用）→ video-prompt-type.md
├─ 运动与运镜控制（运动卡/运镜词，零生成）→ motion-camera-type.md
├─ 物理事实与交通合规核验（判定工序，零生成）→ physics-compliance-type.md
├─ 质量审查与缺陷检测（机检+亲检+最小范围处置）→ qc-defect-type.md
├─ 音频配音对齐（音色/语言锁/TTS 声线，零生成）→ audio-voice-type.md
├─ 终剪组装验证（组装/seam/成片判定/NAS 备份）→ final-assembly-type.md
└─ 不匹配上述任何一类 → templates/task_plan.md（通用）
```

> **Rule 34 门控提示（task-v074）**：选定 template_type 后 attest 锁定会经 `check-template-type.sh` 机器门控（34.1：白名单=variant/ 动态派生+general，enforce 档缺失/非法拒绝锁定）；类型不在既有 variant 白名单（动态派生，v093 起 16 类，task-v109 起 17 类，task-videop1 起 image=18 类+视频工序 11 类=28 类，task-v115 videop1 回流起 29 类）且命中 34.3 沉淀触发条件时，按 34.4 评估沉淀新 variant 变体。完整条款见 `../../task-planner/references/critical-rules.md` Rule 34。

> 选定 template_type 后，立即按 §九「机制适用性矩阵」套用该类型的机制画像（Rule 37）：Code Review Gate、执行体路由等按矩阵行取捨。

**文件路径**（相对 `${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/`）：
- `templates/task_plan.md`(默认通用)
- `templates/variant/research-type.md`
- `templates/variant/diagnostic-type.md`
- `templates/variant/writing-type.md`
- `templates/variant/publish-type.md`
- `templates/variant/code-edit-type.md`
- `templates/variant/refactor-type.md`
- `templates/variant/bugfix-type.md`
- `templates/variant/migration-type.md`(v2)
- `templates/variant/test-writing-type.md`(v2)
- `templates/variant/deployment-type.md`(v2)
- `templates/variant/performance-tuning-type.md`(v2)
- `templates/variant/schema-migration-type.md`(v2)
- `templates/variant/rule-enhancement-type.md`(v2,沉淀；技能规则增强/新增 Rule/门控/selftest 守护模板，§六 速查表既有落点回填)
- `templates/variant/mini-lite-type.md`(v2，task-v086 新增；轻量档 mini 计划模板，Rule 38.3 区块白名单承载)
- `templates/variant/video-type.md`(v3，task-v093 收录；视频生产任务模板，video 家族主分支)
- `templates/variant/video-fix-type.md`(v3，task-v093 收录；视频修正/局部重生成/QC FAIL 处置，video 家族 C 修正分支展开)
- `templates/variant/memory-hygiene-type.md`(v4，task-v109 收录；记忆体系盘点/整理/治理模板，M1-M5 记忆整理协议承载)
- `templates/variant/image-type.md`(v1，task-videop1-planimage-001 收录；图像生成九原子步骤管线——三检闭环+静默自动，video 家族姊妹模板)
- `templates/variant/script-dev-type.md`(剧本工序 M0-M3+合规审查，零生成；task-videop1-videotpl-001 收录)
- `templates/variant/character-design-type.md`(角色设定→根图→G1→multiview→MCD 一致性锁)
- `templates/variant/multiview-ref-type.md`(既有根锚派生 multiview/sheet/装备变体补制)
- `templates/variant/storyboard-type.md`(分镜拆解：走位清单/geo lock/线稿关键帧页)
- `templates/variant/prompt-struct-type.md`(图像提示词四段式结构化，零生成)
- `templates/variant/video-prompt-type.md`(视频提示词转换+reference 配置+机械门，零视频调用)
- `templates/variant/motion-camera-type.md`(运动与运镜控制写词，零生成)
- `templates/variant/physics-compliance-type.md`(物理事实与交通合规判定，零生成)
- `templates/variant/qc-defect-type.md`(质量审查与缺陷检测+最小范围处置)
- `templates/variant/audio-voice-type.md`(音色/语言锁/TTS 声线对齐，零生成)
- `templates/variant/final-assembly-type.md`(终剪组装/seam QC/成片判定/NAS 备份)

**选择策略**:按场景词命中优先(见决策树),复杂度评分仅作辅助;若 plan 涉及多类场景(罕见),可同时引用多个模板的 VC 字段。

---

## 二、调研型模板（Research Type）

**适用场景**：关键词调研、SERP 分析、竞品研究、数据抓取

**关键差异**：
- Phase 1 强制"调研策略 ≥3 种"检查
- VC 绑定 `_channel_attempts[]` 字段
- 增加"证据来源"列

**模板路径**：`${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/templates/variant/research-type.md`

**使用方式**：
```bash
# 项目级覆盖
cp ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/templates/variant/research-type.md \
   .claude/plan-templates/task_plan.md
```

---

## 三、写作型模板（Writing Type）

**适用场景**：文章创作、内容生成、文案撰写

**关键差异**：
- Phase 对齐管线 Phase 0→6
- 范围限制表列 `data/{site}/{id}/`
- 增加"封面保护"验证点
- 强制 SEO 字段检查

**模板路径**：`${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/templates/variant/writing-type.md`

**使用方式**：
```bash
# 文章管线项目级覆盖
mkdir -p /mnt/data/dev/article-generation/.claude/plan-templates/
cp ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/templates/variant/writing-type.md \
   /mnt/data/dev/article-generation/.claude/plan-templates/task_plan.md  # （示例路径，仅作格式示意）
```

---

## 四、诊断型模板（Diagnostic Type）

**适用场景**：skill 审计、bug 排查、代码审查、质量评估

**关键差异**：
- Phase 1 强制"前置 Read 门（S59）"
- Phase 1.5 强制"路径存在性验证（S64）"
- 增加"evidence 完整性"检查点
- 禁止凭印象诊断

**模板路径**：`${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/templates/variant/diagnostic-type.md`

**使用方式**：
```bash
# skill-fix 项目级覆盖
mkdir -p ~/.zcode/skills/skill-fix/.zcode/plan-templates/
cp ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/templates/variant/diagnostic-type.md \
   ~/.zcode/skills/skill-fix/.zcode/plan-templates/task_plan.md  # （示例路径，仅作格式示意；Claude Code 侧对应 `.claude/plan-templates/`）
```

---

## 五、发布型模板（Publish Type）

**适用场景**：API 发布、批量部署、数据同步

**关键差异**：
- 增加"发布前二次验证"阶段
- VC 绑定 API 响应码
- 强制幂等性检查
- 失败回滚策略

**模板路径**：`${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/templates/variant/publish-type.md`

---

## 六、模板路径速查表

| 场景 | 模板路径 | 关键差异 |
|------|---------|----------|
| 通用标准 | `templates/task_plan.md` | 5 条通用 VC |
| 调研类 | `templates/variant/research-type.md` | _channel_attempts[] / 数据源 ≥2 |
| 诊断类 | `templates/variant/diagnostic-type.md` | S59 Read 门 / S64 路径验证 |
| 写作类 | `templates/variant/writing-type.md` | SEO 字段 / 配图 ≥3 / 无 Amazon |
| 发布类 | `templates/variant/publish-type.md` | API 200 / 幂等性 / 回滚策略 |
| 代码编辑 | `templates/variant/code-edit-type.md` | diff / lint / 测试 / 风格 |
| 重构 | `templates/variant/refactor-type.md` | 行为不变 / 复杂度下降 |
| bug 修复 | `templates/variant/bugfix-type.md` | 复现 / 根因证据 / 回归测试 |
| 迁移(v2) | `templates/variant/migration-type.md` | 基线归档 / 双跑对照 / 旧入口下线 |
| 测试编写(v2) | `templates/variant/test-writing-type.md` | 用例数 / 覆盖率 / 独立性 / 边界 |
| 部署(v2) | `templates/variant/deployment-type.md` | staging 验证 / 健康检查 / 回滚预案 |
| 性能调优(v2) | `templates/variant/performance-tuning-type.md` | 基线 benchmark / P95 降幅 / 资源 |
| schema 迁移(v2) | `templates/variant/schema-migration-type.md` | 可逆 up/down / 数据零丢失 / 在线切换 |
| 规则增强(v2,沉淀) | `templates/variant/rule-enhancement-type.md` | 新增 Rule 条款 / config 三档键 / selftest 守护 / SKILL 联动 / 锚定级联防呆 |
| 轻量档(v2) | `templates/variant/mini-lite-type.md` | 轻量档豁免（Rule 38.3 区块白名单：≤2 文件 ∧ ≤15min ∧ 单模块） |
| 视频生产(v3) | `templates/variant/video-type.md` | 内容组-视频：人工门 32.2 / QC 8 类 / video 家族主分支 |
| 视频修正(v3) | `templates/variant/video-fix-type.md` | 内容组-视频：disposition_ref 必填 / full-regen 仅 d 级显式批准 |
| 记忆卫生(v4) | `templates/variant/memory-hygiene-type.md` | 通用组-记忆卫生：M1 盘点表 / M2 四维校验 / M3 四态处置(删除仅建议) / M4 修正版抽验契约 / M5 写入三要素 |
| 图像生成 | `templates/variant/image-type.md` | 九原子步骤管线 / 三检闭环 / 静默自动 / 预算账本 |
| 剧本工序 | `templates/variant/script-dev-type.md` | M0-M3 六相 / 八红线 / M0 放行门 |
| 角色设计 | `templates/variant/character-design-type.md` | 根图先行 / G1 终审 / MCD 一致性锁 |
| 多视角补制 | `templates/variant/multiview-ref-type.md` | i2i 派生 / 合版护栏 / 全静默 |
| 分镜拆解 | `templates/variant/storyboard-type.md` | walk_lock / geo lock / 四步准入 |
| 图像写词 | `templates/variant/prompt-struct-type.md` | 四段式 / 判定层 / 零生成 |
| 视频写词 | `templates/variant/video-prompt-type.md` | 槽位配置 / 机械门 / 零视频调用 |
| 运镜控制 | `templates/variant/motion-camera-type.md` | 运动卡 / POV 纪律 / 零生成 |
| 物理合规 | `templates/variant/physics-compliance-type.md` | 风险状态卡 / 判定清单 / 多态声明 |
| 质检 | `templates/variant/qc-defect-type.md` | 机检+亲检 / 四级处置 / 判例固化 |
| 配音对齐 | `templates/variant/audio-voice-type.md` | 声线表 / 语言锁 / 零生成 |
| 终剪组装 | `templates/variant/final-assembly-type.md` | seam 5 边界 / 成片判定 / NAS |
| 已有 .execution-plan.json | 允许替代 | — |

### 模板互斥关系(避免误选)

| 易混对 | 边界 |
|--------|------|
| publish vs deployment | publish=**数据**推送到 API;deployment=**代码/服务/基础设施**部署 |
| migration vs code-edit | migration=**多步骤**流程(基线锁定→双跑→切流);code-edit=**单次编辑** |
| refactor vs performance-tuning | refactor=**行为不变**前提;performance-tuning=允许**功能+性能**共同变化 |
| test-writing vs code-edit | test-writing 缺**覆盖率门槛/独立性/边界 case**;code-edit 通用编辑 |
| schema-migration vs bugfix | schema-migration=**可逆 up/down** + **在线切换**;bugfix 假设修复即正确 |
| bugfix vs diagnostic | bugfix=**根因已知**进入修复;diagnostic=**根因排查**阶段 |
| video vs image | video=**视频生产链**（草稿→video 调用→成片 QC）;image=纯图像层（成图三检即验收；产出进视频仍走 video 门） |
| video/image vs 工序 11 类 | video=全流程整集;image=通用图像批;工序 11 类=**单专业任务**（各模板头注边界声明，误选回互斥表对账） |
| script-dev vs video | script-dev=剧本文字层止于定稿（零生成）;video=生成生产链 |
| qc-defect vs video-fix | qc-defect=判定与处置路由;video-fix=重生成执行域 |

---

## 七、定制红线（禁止改动）

以下标记被脚本硬解析，**定制时禁止改动格式**：

| 固定标记 | 被谁解析 |
|---------|---------|
| `### Phase N: {标题}` | check-complete.sh:14 / sync-todos.sh:54-56 |
| `- **Status:** complete\|in_progress\|pending` | check-complete.sh:17-19 / sync-todos.sh:63-66 |
| 6 个文件名白名单（task_plan/findings/progress/notepad-learnings/verification/knowledge-brief） | init-session.sh:122 / check-scope.sh:66（knowledge-brief 为 task-v067 第 6 文件，init-session.sh 建档） |
| fallback `[complete]` inline | check-complete.sh:23-25 |

**可自由定制区域**：
- Phase 数量（3-7 个）
- VC 条目内容与验证方式
- 范围限制表内容
- Key Questions / Decisions / Notes 等结构区
- 「📚 必要知识储备」章节内容（全部模板标配,任务知识库对齐;按任务填充知识源,结构可按需增删行）

---

## 八、验证命令

```bash
# 检查 Phase 解析数
grep -c "### Phase" task_plan.md  # 应 ≥ 3

# 检查 Status 标记
grep -c "\*\*Status:\*\*" task_plan.md  # 应 = Phase 数

# 检查文件名白名单
ls *.md | sort
# 应包含: findings.md, notepad-learnings.md, progress.md, task_plan.md, verification.md

# 运行完成检测
bash ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/check-complete.sh
# 应返回 exit 0

# 检查「执行范围限制」区块可被脚本提取(scope 护栏;check-conflicts.sh / check-drift.sh 依赖)
awk '/^## ⚠️ 执行范围限制/{f=1; next} /^## /{f=0} f && /\|.*\|.*\|/ && NF>2' task_plan.md | grep -c '^|'
# 应 ≥ 范围表数据行数;若为 0 说明区块结构被破坏(如标题插入区块中间)
```

---

## 九、机制适用性矩阵（Rule 37 权威源 — 按 template_type 裁剪机制）

本矩阵是 `critical-rules.md` Rule 37 引用的机制画像表单一权威源。表中「不适用」仅指该类型组的机制不触发；3-File 限制、委派率、漂移检测等通用守卫对所有类型不变。内容组「不适用」项集中出现于 writing / research / publish 三行（Code Review Gate 与代码类执行体路由不触发）。

| 类型 | 组别 | 默认适用机制 | 不适用机制 | 执行体路由组 |
|------|------|-------------|-----------|-------------|
| bugfix | 代码组 | Code Review Gate+修改后验证流程 | content_quality 门控 | code-assistant/debugger/code-reviewer |
| code-edit | 代码组 | Code Review Gate+修改后验证流程 | content_quality 门控 | code-assistant(haiku-1)/executor |
| deployment | 代码组 | Code Review Gate+修改后验证流程 | content_quality 门控 | executor/code-assistant |
| diagnostic | 代码组 | Code Review Gate（修复类）+修改后验证 | content_quality 门控 | code-assistant/debugger |
| migration | 代码组 | Code Review Gate+修改后验证流程 | content_quality 门控 | executor/code-assistant |
| performance-tuning | 代码组 | Code Review Gate+修改后验证流程 | content_quality 门控 | executor/code-reviewer |
| publish | 内容组 | content_quality 门控（Q3/Q4） | Code Review Gate；code-assistant/debugger/code-reviewer 路由 | code-runner-agent/article-batch-publish |
| refactor | 代码组 | Code Review Gate+修改后验证流程 | content_quality 门控 | code-simplifier/executor |
| research | 内容组 | content_quality 门控（Q3/Q4） | Code Review Gate；code-assistant/debugger/code-reviewer 路由 | research-assistant/web-search-agent |
| rule-enhancement | 代码组 | Code Review Gate+修改后验证流程 | content_quality 门控 | code-assistant/executor |
| schema-migration | 代码组 | Code Review Gate+修改后验证流程 | content_quality 门控 | code-assistant/database-optimizer |
| test-writing | 代码组 | Code Review Gate+修改后验证流程 | content_quality 门控 | code-assistant/test-engineer |
| writing | 内容组 | content_quality 门控（Q3/Q4） | Code Review Gate；code-assistant/debugger/code-reviewer 路由 | article-writer/article-writing-phase-agent |
| video | 内容组-视频 | content_quality 门控（Q3/Q4）+人工门 32.2 | Code Review Gate；code-assistant/debugger/code-reviewer 路由 | Agnes 视频链路（母图/分镜/镜头/成片 QC 8 类） |
| video-fix | 内容组-视频 | content_quality 门控（Q3/Q4）+disposition_ref 必填 | Code Review Gate；code-assistant/debugger/code-reviewer 路由 | videop1-video-fix SOP（full-regen 仅 d 级显式批准） |
| mini-lite | 轻量档豁免 | 轻量档豁免（Rule 38.3 区块白名单：跳 FMEA/知识储备表/委派统计/Batch 区块） | standard 全量仪式（VC≥5 五条） | code-assistant 或主进程白名单 |
| memory-hygiene | 通用组 | 记忆整理协议 M1-M5（M1 盘点表/M2 四维机械校验/M3 四态处置删除仅建议/M4 修正版抽验契约/M5 写入三要素） | content_quality 门控；仓内无代码功能变更 | executor(fresh) 盘点 / verifier 抽验 |
| image | 内容组 | 成图三检 QC 门控（合规/一致性/质量——本仓 videop1-review-image 族+tools/qc.py 机检+主进程亲检） | Code Review Gate；content_quality（Q3/Q4）；code-assistant/debugger/code-reviewer 路由 | 生成/写词/QC 子代理+tools/gen.py·qc.py |
| script-dev | 内容组 | 剧本判定层全集（script-craft P/V/E 维+八红线自检+M0 放行门） | Code Review Gate；content_quality；代码类路由 | script-writer/script-auditor |
| character-design | 内容组 | 成图双硬 QC+审美基线+G1 门控+MCD 锁 | Code Review Gate；content_quality；代码类路由 | 生成/QC 子代理+主进程亲检 |
| multiview-ref | 内容组 | 成图双硬 QC+根锚溯源+合版护栏（全静默） | Code Review Gate；content_quality；代码类路由 | 生成/QC/合版子代理+主进程亲检 |
| storyboard | 内容组 | 线稿/关键帧准入门+走位铁律+geo lock+草稿人工门 | Code Review Gate；content_quality；代码类路由 | 线稿生成/QC 子代理 |
| prompt-struct | 内容组 | review-prompt 判定层（零生成） | Code Review Gate；content_quality；代码类路由 | 写词/审查子代理 |
| video-prompt | 内容组 | gen.py 机械门+语言音色子句核对（零视频调用） | Code Review Gate；content_quality；代码类路由 | 写词子代理+主进程机械 |
| motion-camera | 内容组 | POV 纪律+物理可行性判定（零生成） | Code Review Gate；content_quality；代码类路由 | 写词/审查子代理 |
| physics-compliance | 内容组 | physics/safety 判定层清单（判定工序） | Code Review Gate；content_quality；代码类路由 | 判定子代理 |
| qc-defect | 内容组 | 双硬 QC+亲检仲裁+最小范围四级处置 | Code Review Gate；content_quality；代码类路由 | QC 子代理+主进程亲检 |
| audio-voice | 内容组 | 语言锁三层+音色逐字核对（零生成） | Code Review Gate；content_quality；代码类路由 | 核对子代理 |
| final-assembly | 内容组 | seam 5 边界+成片判定层+NAS 对账+用户终审 | Code Review Gate；content_quality；代码类路由 | 剪辑/QC/备份子代理 |
| general | 通用组 | 未命中类型时按通用守卫全量执行（画像不裁剪，计划可显式声明个别机制 n/a 并登记理由） | （无预置不适用项） | 按 Phase Executor 字段逐案路由 |

新增任务类型时只需在本矩阵加行并在 `variant/` 落模板（Rule 34.4）；「不适用」的例外=计划显式 `code_review: required`（Rule 37.4②）。
> 内容组「不适用」项（15 行，Code Review Gate 与代码类执行体路由不触发）：
> - writing（不适用：Code Review Gate；code-assistant/debugger/code-reviewer 路由）
> - research（不适用：Code Review Gate；code-assistant/debugger/code-reviewer 路由）
> - publish（不适用：Code Review Gate；code-assistant/debugger/code-reviewer 路由）
> - image（不适用：Code Review Gate；code-assistant/debugger/code-reviewer 路由；content_quality Q3/Q4——图像域按成图三检 QC 门控）
> - videotpl 工序 11 类（script-dev/character-design/multiview-ref/storyboard/prompt-struct/video-prompt/motion-camera/physics-compliance/qc-defect/audio-voice/final-assembly——不适用同 image 行，另按各自域 QC/判定层门控）
> 媒体族专用执行体 `image-generation-executor`/`video-generation-executor` 在位时优先（task-v124）；缺位时兜底路由 = 路由组列引用的项目专属资产（tools/gen.py·qc.py / script-writer / videop1 SOP 等）在当前环境缺位时，通用兜底路由 = executor(sonnet-1) + 对应工序 variant 模板 SOP + 生成技能（如 agnes-ai-generation-skill，派发 prompt 点名）；质检工序 = QC/审查类子代理；禁止 general-purpose 无登记默认兜底。

## §十 工具选择映射（Rule 40.1/40.2 权威消费点 — task-v097）

> 消费方: plan-writer 计划撰写期（填写「🧰 工具选择与编排」区块的选型依据）。与 §九 机制画像互补——§九 裁剪"机制适用性",本节回答"用哪类工具执行"。mini 档豁免该区块（Rule 38.3）。

| 任务类型族（对齐 §九） | 默认执行体（对齐 SKILL 路由表） | 计划期工具面建议（Rule 40.1 六类） | 编排判定倾向（Rule 40.4） |
|----------------------|------------------------------|--------------------------------|------------------------|
| 代码组（code-edit/bugfix/refactor/performance/test-writing） | code-assistant / executor / build-error-resolver 子代理 | Agent 子代理为主;机械守卫脚本（selftest/编译/lint）为验证面 | 串行为主;≥3 个独立同构单元或独立模块并行可分析 → 建议 CreateWorkflow |
| 内容组（writing/research/publish/video/image+videotpl 工序 11 类） | 内容类执行体（article-writer 等）+plan-research-router 卫星 | 卫星技能+子代理;长任务建议用户 /goal 锚定会话目标（40.3 提示点） | 阶段链（研究→写作→审查）强串行;仅批量多文发布可 fan-out |
| 媒体制作族（video/video-fix/image+工序 11 类，自内容组行特化拆出 — task-v122 Rule 47.2） | 首选 image/video-generation-executor（task-v124 在位优先）；缺位回退 executor(sonnet-1) + 工序 variant 模板 SOP + 生成技能；QC=审查类子代理 | 子代理+生成技能；机械 QC/机检脚本为验证面 | 同参批量单元可声明组并行；跨工序阶段链（母图/分镜/剧本依赖）强串行 |
| 规则/模板组（rule-enhancement/schema-migration） | executor（worktree 隔离必须） | Agent 子代理+机械 selftest 面;主进程 git 编排（Rule 25.3 白名单①） | 串行;级联锚清单先行 |
| 迁移/部署组（migration/deployment） | 主进程 git 编排+executor | 机械守卫脚本+git 编排（白名单①③）;MCP 工具按需 | 串行;合并回走 smart-merge-back |
| 轻量档（mini-lite） | code-assistant 或主进程白名单 | 豁免「🧰」区块（Rule 38.3）;默认按 21.4 独立性守门（并行默认+声明组，未声明=串行，10-02） | 不判定 |
| 调研/诊断组（research/diagnostic） | Explore/web-search/debugger 子代理 | 子代理+MCP（web_reader/node_repl）+research 卫星 | 串行;多主题可拆多 explore |

**映射使用规则**: ① 本表是建议面非强制路由——Executor 字段仍是委派门控机器事实源（Rule 40.2,区块不替代）;② 编排判定倾向=命中才在「🧰」区块登记"建议 CreateWorkflow"并按 Rule 39.4 做并行豁免登记,未命中按 Rule 21.4 独立性守门调度（并行默认+声明组，未声明=串行，10-02）;③ 类型不在表中 → 按最近似族套用并在区块理由列注明。
