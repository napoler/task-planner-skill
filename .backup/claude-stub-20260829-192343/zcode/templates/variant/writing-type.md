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

## Phases（对齐管线 Phase 0→6）

### Phase 1: 研究阶段 (Phase 0.5→1.5)
- [ ] Phase 0.5: research_data.json validator size-fail exit 7
- [ ] Phase 1-KW-Intel: keyword intel gather
- [ ] Phase 1-Topic: topic validation
- [ ] Phase 1-SEO: SEO tag generation
- [ ] Phase 1.5: synthesis prep
- **Status:** pending

### Phase 2: 合成阶段 (Phase 2→2.7)
- [ ] Phase 2: raw research → structured
- [ ] Phase 2.5: compression
- [ ] Phase 2.7: writing_context.md 生成
- **Status:** pending

### Phase 3: 写作阶段 (Phase 3.1→4)
- [ ] Phase 3.1: title draft
- [ ] Phase 3.2: body writing（fork article-phase-3-2-writer，deepseek-v4-pro 强制）
- [ ] Phase 3.3: assemble_article.py
- [ ] Phase 3.5: quality-reviewer 审查
- [ ] Phase 4: schema 验证
- **Status:** pending

### Phase 4: 发布阶段 (Phase 5→6)
- [ ] Phase 5: Django API publish
- [ ] Phase 6: post-publish verify
- **Status:** pending

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |          |        |      |
