# B-fixes 修正检查点 — task-v191 核心技能锚点漂移与脚本文本残留

- 子代理: B-fixes（执行修正）
- 时间: 2026-10-19
- worktree: `/mnt/data/dev/task-planner-skill-worktrees/task-v191-project-audit-sync`（分支 wt/task-v191-project-audit-sync）
- 依据: `subagent-state/B-core-skill.md`（N-1…N-5 判定）

## 逐条修正记录

| ID | 文件:行 | 改前 | 改后 | 实证 |
|----|---------|------|------|------|
| N-2 | `skills/task-planner/SKILL.md:158` | `critical-rules-discipline.md:191` | `critical-rules-discipline.md:195` | 实测 Rule 38.7 在 :195（`grep -n '^38\.7'` 命中 195）；同句 `critical-rules-template.md:45` 未动 |
| N-3 | `skills/task-planner/SKILL.md:157` | `lane-detect.sh:85` | `lane-detect.sh:86` | 实测「禁滥用机器化」注释在 :86，:85 为 L2 命中行 |
| N-4 | `skills/task-planner/scripts/register-hooks-cj.ts:32` | `examples: "$ bun scripts/register_hooks_cj.ts\n…--dry-run\n…--canonical ~/dev/task-planner"` | 三行全改 `node --experimental-strip-types scripts/register_hooks_cj.ts …`（参数不变） | 与 :1 shebang / :16 docstring 对齐 |
| N-5a | `skills/task-planner/scripts/sync-ide-folders.ts:31-33` | META_DEPS 列 `Node.js >= 18` + `ts-node` 两行 | `Node.js >= 18（node --experimental-strip-types 运行）` 单行 + `无外部依赖` | ts-node 依赖行删除 |
| N-5b | `skills/task-planner/scripts/sync-ide-folders.ts:181` | `Run 'ts-node sync-ide-folders.ts' to fix.` | `Run 'node --experimental-strip-types sync-ide-folders.ts' to fix.` | — |
| N-6 | `skills/media-planner/SKILL.md:4` | `tools: [Read, Write, Edit, Bash, Grep, Glob]` | `allowed-tools: "Read, Write, Edit, Bash, Grep, Glob"` | 对照：task-planner/task-discipline/task-dispatch/verification-gate 均用 `allowed-tools: "…"` 引号字符串键 |
| N-7 | `skills/task-discipline/SKILL.md` 规则索引表（76 与 92 行之间） | 缺 Rule 85-90 六行（索引末行到 92） | 补 6 行：`85 用户输入一致性纪律` / `86 可测问题禁问与无推荐禁上抛` / `87 精准执行与极简改动纪律` / `88 任务射程契约` / `89 前后逻辑一致性与已确立事实禁反言` / `90 任务执行首尾 Git 双提交纪律`（标题从 critical-rules-discipline.md:503/515/527/541/553/565 原文取）；锚点列照既有格式 `同上`；计数行 :15/:70/:81 的 43 不动（补完后索引表 43 行，与计数一致） | — |

## 不修登记（待裁决，未动原文）

1. `skills/task-planner/templates/variant/video-fix-type.md` — :5/:80-83 硬编码 `/mnt/data/dev/videop1/` 伴飞路径：videop1 项目专属伴飞表，改占位符可能破坏该工作流。**仅**在文件头部加了一行豁免注（第 2 行）：`<!-- S75 D1 豁免：videop1 专属伴飞路径，属部署者项目实态，非可移植硬编码；如需移植请替换为 <repo-root>/.zcode/skills/videop1-video-fix/ 占位 -->`
2. `skills/verification-gate/SKILL.md:39` — `bash scripts/check-x.sh <plan>` 为示例占位脚本名（P3），仅在行尾加 `<!-- 示例占位 -->` 标注，未改脚本名。

## 自检证据

- `grep -nE 'critical-rules-discipline\.md:191|lane-detect\.sh:85' skills/task-planner/SKILL.md` → 0 命中；`:195`/`:86` 各 1 命中（:158/:157）。
- `grep -nE '\bbun\b|ts-node' skills/task-planner/scripts/register-hooks-cj.ts skills/task-planner/scripts/sync-ide-folders.ts` → 0 命中。
- `node --experimental-strip-types --check` 两脚本 → PARSE_OK。
- task-discipline 索引表 `| N |` 数据行计数 = 43（含新补 6 行），与 :15/:70/:81 计数「43 条」一致。
- media-planner frontmatter `allowed-tools` 行确认在 :4。

## 射程外观察（未改，报告）

全仓 grep 发现 INSTALL.md:15/200/274、MIGRATION.md:100、README.md:273、docs/ARCHITECTURE.md:279 仍写 `bun run ~/.claude/skills/task-planner/scripts/register-hooks-cj.ts`（与已改的 node 通道矛盾）；init-session.sh:463 注释仍引 `lane-detect.sh:85`。均不在本任务授权射程内（本任务只授权 2 个 .ts 文件无 bun/ts-node 残留），留待后续任务裁决。
