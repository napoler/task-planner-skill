# Task Plan: [文章创作任务]
<!-- 写作型模板 — 适用于文章管线 Phase 0→6 -->

## Goal
[一句话描述文章目标，如：为 soundgearx 站点创作关于 XXX 的长尾关键词文章]

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | article.json schema 通过 | python3 scripts/article_json_editor.py validate data/{site}/{id}/article | -- |
| VC-2 | content 原创性 ≥15% | python3 scripts/verify_content_originality.py --threshold 0.85 | tmp/originality-report.json |
| VC-3 | 封面域白名单通过 | grep storage.maomihezi.com article.json | article.json |
| VC-4 | SEO 字段完整 | jq '.meta_title, .focus_keyword' article.json | article.json |
| VC-5 | 配图 ≥3 张 | jq '.images | length' article.json | article.json |
| VC-6 | 无 Amazon 链接 | grep -c "amazon.com" content | content 字段 |

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

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## Phases（对齐管线 Phase 0→6）

### Phase 1: 研究阶段 (Phase 0.5→1.5)
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
- [ ] Phase 3.2: body writing（fork article-phase-3-2-writer，deepseek-v4-pro 强制）
- [ ] Phase 3.3: assemble_article.py
- [ ] Phase 3.5: quality-reviewer 审查
- [ ] Phase 4: schema 验证
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
