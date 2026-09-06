# executor-3a checkpoint (FINAL)

## 已完成项
- 1a SKILL.md L297: `Rules 1-26` → `Rules 1-27` ✅
- 1b SKILL.md L569: `templates/template-guide.md` → `references/template-guide.md` ✅
- 1c SKILL.md frontmatter: 新增两条 references 条目（template-guide.md / template-mapping.md）✅
- 1d SKILL.md: 在 `## 执行流程图` 前插入路径约定 blockquote ✅
- 2a README.md L67: critical-rules.md 注释 `Rules 1-12` → `Rules 1-27（1-12 核心执行约束 + 13-27 P0/P1 扩展门控）` ✅
- 2b README.md L64: `（13 键）` → `（18 键）` ✅
- 2c README.md scripts/ 树: 新增 plan-doctor.sh / resolve-plan-dir.sh / set-active-plan.sh / zcode-sessionstart.sh 四个条目（plan-writer.md 已在 companion/ 目录实际位置；check-complete.ps1 / init-session.ps1 已有合并条目，无需重复）✅
- 2d README.md: 新增 `## config.json 键说明（18 键）` 段落（含全部 18 键表 + 4 项零文档化键 + 无 version 字段注记）✅
- 2e README.md: 在文件结构树末追加 `├── companion/ — 伴生 agents（plan-writer / article-batch-publisher / article-field-fixer，跨平台部署用）` ✅
- 3a INSTALL.md L231: `scripts/plan-writer.md` → `companion/agents/plan-writer.md` ✅
- 3b INSTALL.md L238-241: variant 模板计数断言 13 → 12（正文 + 校验命令期望值均改）✅
- 3c INSTALL.md L131: `companion/ — v2.2.1` → `companion/ — 伴生 agents（plan-writer 等）` ✅
- 4a docs/ARCHITECTURE.md L126: 在 `scripts/scan-plans.sh` 后追加 `（示例，非实存脚本）` ✅
- 4b docs/ARCHITECTURE.md L150: `task-planner v2.3 已有任务不受影响` → `task-planner 现版本已有任务不受影响` ✅
- 5a MIGRATION.md: 全文件 grep `v[0-9]+\.[0-9]+` 无具体版本断言冲突，未改动 ✅

## 待做项
无。

## 验收 grep 原始输出
```
$ grep -n "Rules 1-26" skills/task-planner/SKILL.md
(no output, exit=1)
$ grep -rn "templates/template-guide" skills/task-planner/SKILL.md
(no output, exit=1)
$ grep -n "scripts/plan-writer.md" skills/task-planner/INSTALL.md
(no output, exit=1)
$ grep -n "应 = 13" skills/task-planner/INSTALL.md
(no output, exit=1)
$ grep -c "references/" skills/task-planner/SKILL.md
40
```

## git status --short 输出
```
 M skills/task-planner/INSTALL.md                     ← 本任务 3a/3b/3c
 M skills/task-planner/README.md                      ← 本任务 2a/2b/2c/2d/2e
 M skills/task-planner/SKILL.md                       ← 本任务 1a/1b/1c/1d
 M skills/task-planner/config.json                    ← 另一并行修复预存在（未触碰）
 M skills/task-planner/docs/ARCHITECTURE.md           ← 本任务 4a/4b
 M skills/task-planner/references/batch-quality-gate.md   ← 另一并行修复预存在（未触碰）
 M skills/task-planner/references/template-guide.md   ← 另一并行修复预存在（未触碰）
 M skills/task-planner/references/template-mapping.md  ← 另一并行修复预存在（未触碰）
```

注：4 个 references/config 文件在本任务启动前已存在修改（来自平行批修），本任务严格未触碰。

## 结论
任务全部完成。共修改 5 个清单文件（SKILL.md/README.md/INSTALL.md/docs/ARCHITECTURE.md/MIGRATION.md 实际无改动），未 git commit，未触碰清单外任何文件。