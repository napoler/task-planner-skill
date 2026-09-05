# 项目体检报告 — 今日大改后全仓一致性审计（2026-09-04）

> 任务: task-full-sync-audit · 范围: dcfa55b(plan-resume v0.4 收编) / 4728906+1957fec(顶层迁移) / 186f3a6(todo-skill TS 收编) / 全软链化之后的全仓一致性
> 方法: 行为层实跑(verify.sh/check-doc-sync/check-complete/bash -n×20/双脚本 dry-run) + 五类陈旧模式全仓 grep + 语义抽查(模板/引用/docs/README/CLAUDE.md)

## 结论
**发现 3 处未同步 + 2 处运行时卫生问题,全部已修复;文本层(文档/模板/安装脚本)经五类模式终扫无遗漏。修复提交 49b6215(merge f281ecd)。**

## 发现与处置
| # | 发现 | 定性 | 处置 | 状态 |
|---|------|------|------|------|
| F1 | `lib/verify.sh` 仍按薄壳 stub 模型校验:薄壳<15KB/硬编码路径/zcode hooks frontmatter 三类检查对软链部署产生 5 项误报 | 安装校验脚本未跟上软链模型 | 增加 `stub_is_symlink_mode` 判定:软链位改为校验"指向 canonical+经链可读";zcode hooks 改查实际机制 `~/.zcode/cli/config.json`;opencode/cursor 薄壳保持 frontmatter 检查。修后实跑 **18 pass / 0 fail**(此前 5 fail) | ✅ 49b6215 |
| F2 | 仓根 `.backup/`(2026-08-29 旧薄壳备份,含 `$HOME/dev/task-planner` 过时路径文档)被 git 追踪 | 运行时产物误入库 | git rm(内容保留于 git 历史)+ 新增 `.gitignore`(`.backup/`、`__pycache__/`);`.backup/` 仍是 backup.sh 设计备份位,仅不再追踪 | ✅ 49b6215 |
| F3 | opencode 薄壳陈旧:config.json/examples.md 落后 canonical;内嵌 `.git`(936K)+`.backup`(740K) 垃圾 | 部署位未同步 | 走**薄壳再生成**(`install_stub_for_tool`,非软链——OpenCode hooks 走 SKILL.md frontmatter,换全量链会断 hooks,canonical frontmatter 无 hooks 块);刷新后 config.json/examples.md 与 canonical 逐字节一致,5 个 hook 声明保持;垃圾移入 `~/skill-deploy-backups-20260904/opencode-stub-internal/` | ✅ 部署位操作 |
| F4 | `plans/INDEX.md` 索引陈旧(task-skills-toplevel 显示 in_progress 1/4,实际已完成) | 簿记遗漏 | 重跑 `sync-todos.sh --index` 刷新,7 complete + 1 in_progress(本审计) | ✅ |
| F5 | `~/.agents/skills/plan-resume.bak-20260904` 残留 | 已授权清理项 | 前一轮已删除(删前核实=已收编内容,零损失) | ✅ |

## 白名单（命中但判定合法,不改）
- CHANGELOG.md 历史条目中的旧路径/旧描述(历史记录不改写)
- 各文档"自 companion/skills 迁移"说明句(迁移事实陈述)
- `${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}` 等回退表达式(INSTALL.md/template-guide/template-mapping 共 5 文件)——架构 §3.1 定义的标准路径解析契约,机器无关
- `todo-skill/tools/cli_todo-manager.ts` 注释中"与 python 版 todo_manager.py 格式兼容"(迁移溯源说明)
- `zcode-posttooluse.sh:39`、`detect-tools.sh:18-19` 的部署路径默认值(env 覆盖优先,软链模型下正确)
- 模板中 `python todo.py add` 等示例行(通用示意,非 todo-skill 引用)

## 终态快照
- 仓: master = f281ecd;四技能顶层平级;companion/ 仅 agents/;工作区干净(仅 .zcode//plans/ 未跟踪)
- 部署位: zcode/claude/agents 三根全软链指向 canonical;opencode = 薄壳(设计使然,已刷新);cursor = 薄壳(健康)
- 校验: verify.sh 18/0;20 脚本 bash -n 全过;check-complete/check-doc-sync 正常;install-companion/sync-companion dry-run 正常
- 架构说明: 本仓现共存两种部署模型——**软链模型**(zcode/claude/agents,全量内容,hooks 走平台 config)与**薄壳模型**(opencode/cursor,轻量 stub,hooks 走 frontmatter),verify.sh 已同时支持两者

## 遗留（未立项,待用户决策）
1. plan-resume v0.5 内容合并(v0.3 多格式 + v0.4 smart-resume;smoke 8/22 失败为 v0.3 测试对 v0.4 脚本既有缺口)
2. opencode 是否也要迁移到软链模型(需先给 OpenCode 建 config 级 hooks 机制,非本轮范围)
