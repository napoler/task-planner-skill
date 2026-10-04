# m11 部署单任务书（task-v125 — router 族行追加）

## 目标
向两个 skill-agent-router 部署位文件追加 6 个族级行（追加位置：各文件「### 九、内容与媒体类」表内 `video-generation-executor` 行之后）。

目标文件（结构相同）：
- /home/terry/.zcode/skills/skill-agent-router/SKILL.md
- /home/terry/.claude/skills/skill-agent-router/SKILL.md

## 追加内容（两文件相同，逐字照抄；与既有 3 列表格格式一致）

```
| **质量审查族** | 质量校验/审查/QC：`quality-auditor` / `quality-check-agent` / `quality-control-agent` / `content-origin-verify-agent` / `doc-sync-verify-agent` | 具体代码审查（走 code-reviewer / code-quality-review） |
| **Git 运维族** | Git 操作/安全审计/隔离区巡检/定时巡检/记忆维护：`git-master` / `git-security-expert` / `worktree-janitor` / `cron-patrol` / `memory-librarian` | 业务代码修改（走 code-assistant/executor） |
| **营销 SEO 族** | SEO 策略/多渠道内容/有机内容规划：`seo-specialist` / `marketing-content-creator` / `organic-content-strategist` / `marketing-seo-specialist` | 技术文档（走 technical-writer） |
| **数据研究族** | 研究执行/接口测试/销售数据整合/日志提炼/搜索词分析：`scientist` / `api-tester` / `data-consolidation-agent` / `log-distiller` / `search-query-analyst` | 通用数据分析（走 analyst/analytics-reporter） |
| **文档 UI 族** | 技术文档/界面设计/前端实现：`technical-writer` / `ui-designer` / `frontend-developer` | 后端架构（走 architect） |
| **文章管线族** | 文章编辑/审查/研究/综合/发布 12 族（article-content-editor / article-reviewer / article-research-heavy-agent / article-synthesis-phase-agent 等，全列见覆盖矩阵） | 非文章类内容（走对应内容族） |
```

## 防呆
- 两文件九节已含 media 两行（image/video-generation-executor），勿重复/勿交集
- 先 Read 定位锚行，再 Edit；改后 grep 复核

## 验收（返回 8 字段逐项贴原文）
1. 两文件 `grep -c '质量审查族\|Git 运维族\|营销 SEO 族\|数据研究族\|文档 UI 族\|文章管线族'` 各 =6
2. 两文件 media 行仍各 1 处；每文件本单新增恰 6 行
3. 记录两文件 `wc -l`

## 记录
- 检查点: /mnt/data/dev/task-planner-skill/plans/task-v125/subagent-state/m11-deploy.md（追加 编辑摘要+核对表+最终结论 8 字段块）
- findings 追加 `#### [sub:deploy2] <标题>`；progress Phase 5 段追加 `  - [sub:deploy2] <摘要>`
- 禁改其他内容；禁止 git 写操作
