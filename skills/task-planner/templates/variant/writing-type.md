# Task Plan: [文章创作任务]
<!-- template-lineage: level=derived parent=../task_plan.md base=../task_plan.md spec_version=1 pruned="用户需求原文,根源覆盖表,不变量声明区,规范基线,进度产出基线,双轮质检与同步完整性声明,核心目标达成裁决,变更标注表,核心问题定义,调研需求与检索计划,证据面清单,CurrentPhase,NextStep,防倒退终检,收尾回读梳理记录,收尾对齐与清理,隔离决策,FMEA预演,原生Todo同步,KeyQuestions,DecisionsMade,ErrorsEncountered,Notes,Chain区块交接配置" pruned_reason="variant=领域裁剪全文，裁剪面以本清单显式登记（Rule 34.5 派生登记）" -->
<!-- JSON 模板源(task-json-template-20261125)：skills/task-planner/templates/json/writing.template.json — 本 MD 为教学/临时视图；权威源=plan-state.json 的 template_doc/template_checks；勾选请用 planctl set --section template_checks ... -->
<!-- planctl 派生口径(task-planctl-exec-surface-20261122)：本骨架数据经 planctl add/set 写入 plan-state.json 后 render 派生 task_plan.md 视图；直接填写会在首次 render 被覆盖 -->
<!-- template_type: writing -->
<!-- template_meta: {"type": "writing", "name": "文章创作", "summary": "写作型模板，适用于单篇/SEO 文章管线 Phase 0→6；长篇连载改用 longform-continuity。", "scenarios": ["单篇文章创作", "SEO 文章管线", "长尾关键词文章", "文章创作"], "features": ["Code Review 配置", "Verification Contract", "工具选择与编排", "文章管线 Phase 0→6", "执行范围限制"]} -->
<!-- 写作型模板 — 适用于单篇/SEO 文章管线 Phase 0→6；若为长篇/连载/长论文长报告/跨章节一致性长文（含续写改写），优先改用 longform-continuity-type.md，并须加载 skills/longform-continuity/SKILL.md（Rule 107/长文连续性治理） -->

<!-- plan_tier: standard -->
## Goal
[一句话描述文章目标，如：为 soundgearx 站点创作关于 XXX 的长尾关键词文章]

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a` / `required` |
| `对齐审查` | `[登记]` | Rule 42.6 消费：完成前跑 alignment-review;变更记录随交付落盘;mini 豁免 |
| `自动超时默认项` | `[询问点: 默认选项/超时值]` | Rule 44 消费：默认项+超时 5 分钟;低区分度 44.2 直接裁决;mini 豁免 |
| `质量审查工具` | `[检测结论]` | Rule 42 消费：42.2 四级检测登记;执行期用登记工具;mini 豁免 |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | article.json schema 通过 | python3 scripts/article_json_editor.py validate data/{site}/{id}/article | -- |
| VC-2 | content 原创性 ≥15% | python3 scripts/verify_content_originality.py --threshold 0.85 | tmp/originality-report.json |
| VC-3 | 封面域白名单通过 | grep storage.maomihezi.com article.json | article.json |
| VC-4 | SEO 字段完整 | jq '.meta_title, .focus_keyword' article.json | article.json |
| VC-5 | 配图 ≥3 张 | jq '.images | length' article.json | article.json |
| VC-6 | 无 Amazon 链接 | grep -c "amazon.com" content | content 字段 |
| VC-7 | （长文/连续性场景适用）项目级大纲/设定库/知识库/脑图与 continuity 资产已登记并在动笔前全局检索；前后设定/论点一致、无静默覆盖（Rule 107） | 资产路径+检索/核对记录在位；冲突裁决已回写 | docs/<项目>/*, ledger |

> 注：VC 表中脚本路径为示例值（目标项目相对路径），非本技能仓文件

## ⚠️ 执行范围限制
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 文章数据 | data/{site}/{id}/article/* | data/ 其他站点 |
| 研究数据 | data/{site}/{id}/research/* | 其他路径 |
| 计划文件 | plans/task-{id}/* | 其他 plan 目录 |
| Skill 文件 | 仅本 skill 内部 | 其他 skill/agent 文件 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 |  |  | 必读/参考 | ☐ |
| 官方文档 |  |  | 必读/参考 | ☐ |
| 项目内部文档/知识库 |  |  | 参考 | ☐ |
| 文献/论文 |  |  | 参考 | ☐ |
| 图书/教程 |  |  | 参考 | ☐ |
| 风格/SEO 规范 | 写作风格指南与 SEO 基线 + 主题权威文献 | 路径/URL | 必读 | ☐ |
| 长文连续性资产（续写/系列/长论文长报告时必读） | 项目级 outline/setting-bible/knowledge-base/structure-map + continuity 台账（Rule 107） | 路径 | 必读（命中连续性场景）/否则 n/a | ☐ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
逐 Phase 登记工具面与理由;Executor 字段仍是委派门控机器事实源;mini 豁免
| Phase | 命中工具面 | 选择理由 |
|-------|----------|---------|
| Phase 1 | [如: Agent 子代理 executor(sonnet-1)] | [一句话理由] |

## Phases（对齐管线 Phase 0→6）

### Phase 1: 研究阶段 (Phase 0.5→1.5)
- [ ] **连续性前置（命中长篇/连载/长论文长报告/续写改写时必做）**：加载 `skills/longform-continuity/SKILL.md`；确认项目级 `outline/setting-bible/knowledge-base/structure-map` 与 continuity 台账路径；完成总纲对应段与相关设定/知识的全局检索与一致性检查（非仅紧邻），检索未完成禁动笔；纯单篇无连续性可登记 n/a
- [ ] Phase 0.5: research_data.json validator size-fail exit 7
- [ ] Phase 1-KW-Intel: keyword intel gather
- [ ] Phase 1-Topic: topic validation
- [ ] Phase 1-SEO: SEO tag generation
- [ ] Phase 1.5: synthesis prep
- [ ] 知识储备必读项已确认可获取(勾选「必要知识储备」表"已确认"列)
- **Status:** pending
- **Executor:** article-writer

### Phase 2: 合成阶段 (Phase 2→2.7)
- [ ] Phase 2: raw research → structured
- [ ] Phase 2.5: compression
- [ ] Phase 2.7: writing_context.md 生成
- **Status:** pending
- **Executor:** article-writer

### Phase 3: 写作阶段 (Phase 3.1→4)
- [ ] Phase 3.1: title draft
- [ ] Phase 3.2: body writing（fork article-phase-3-2-writer，deepseek-v4-pro 强制；连续性场景须按已检索设定/大纲写作，禁止凭记忆或静默改写既有设定/论点）
- [ ] Phase 3.3: assemble_article.py
- [ ] Phase 3.5: quality-reviewer 审查（含去 AI 化 10 条清单 + 五维评分卡 ≥4.0 门控，指针 references/methodology.md §内容质量 Q3/Q4；开关键 content_quality_enforce）
- [ ] Phase 4: schema 验证
- [ ] （连续性场景）单元完成沉淀回写：更新 continuity 台账并回写受影响的项目级 outline/setting-bible/knowledge-base/structure-map；冲突显式裁决无静默覆盖
- **Status:** pending
- **Executor:** article-writer

### Phase 4: 发布阶段 (Phase 5→6)
- [ ] Phase 5: Django API publish
- [ ] Phase 6: post-publish verify
- **Status:** pending
- **Executor:** article-writer

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
每次 Agent() 派发前填一行;子代理返回后 Read 产出+findings 回填双条件才勾 verify_done(Rule 22.5)
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 |
|---|------|--------------|----------------|------|---------------|---------------|--------------|----------------|
| 1 |  |  |  | queued |  |  |  |  |

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
> 必填：本类型计划中凡声明输出格式/结构的交付物，均须在 `plan-state.json.output_examples` 登记至少 1 条完整示例 + 1 个同结构可复用模板（经 `planctl add --section output_examples` 写入），由 `planctl render` 派生到 task_plan.md 同名区块。禁止只写「输出为 JSON」等无样例声明；禁「略/同上/TBD」。

| 交付物 | 格式 | 完整示例（fenced，见下方） | 可复用模板（占位符版，见下方） | 对应 VC |
|---|---|---|---|---|
| article.json | JSON | 见下方示例代码块 | 见下方模板代码块 | VC-1, VC-4, VC-5 |

**完整示例（可直接查看、可比对）**：

```json
{
  "title": "示例标题：轻量入门指南",
  "meta_title": "示例标题 | 示例站点",
  "focus_keyword": "示例关键词",
  "content": "<h2>示例小节</h2><p>示例正文段落。</p>",
  "images": ["https://storage.maomihezi.com/img/example-1.png", "https://storage.maomihezi.com/img/example-2.png", "https://storage.maomihezi.com/img/example-3.png"]
}
```

**可复用模板（占位符版，供执行期复制）**：

```json
{
  "title": "<TITLE>",
  "meta_title": "<META_TITLE>",
  "focus_keyword": "<FOCUS_KEYWORD>",
  "content": "<HTML_CONTENT>",
  "images": ["<IMAGE_URL_1>", "<IMAGE_URL_2>", "<IMAGE_URL_3>"]
}
```

填写纪律：① 示例与模板的字段集/层级必须一致；② 示例必须自包含可查看（JSON 须合法可解析、表格须有表头+≥1 行数据）；③ 无格式交付物时显式写 `none-justified（理由）`，禁留空；④ 示例的 `vc_refs` 至少映射 1 个已存在 VC（Rule 113.4）。
