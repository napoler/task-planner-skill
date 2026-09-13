
## T-1 Phase 4 微改批 checkpoint（2026-09-13）

### V-1 [P0] SKILL.md:5 allowed-tools 补缺 ✅
- before: `allowed-tools: "Read, Write, Edit, Bash, Glob, Grep, Agent, Skill, TodoWrite, TaskCreate, TaskUpdate, TaskList, TaskGet"`
- after: 追加 `, AskUserQuestion, WebSearch, WebFetch`
- 证据: grep -n "AskUserQuestion" SKILL.md → 命中 :5（frontmatter）与 :149（正文失败处理）

### V-2 [P0] 7 个 variant 模板 Skill() 主进程标注 ✅
- 每处 `Skill(` 前加 `**主进程** `，行尾加 `（子代理无 Skill() 工具）`：
  - bugfix-type.md:73（Phase 2 debugger）systematic-debugging
  - code-edit-type.md:93（Phase 5 code-assistant）task-drift-guard
  - deployment-type.md:98（Phase 5 executor）task-drift-guard
  - migration-type.md:91（Phase 4 executor）cli-tool-builder
  - performance-tuning-type.md:99（performance-optimizer）task-drift-guard
  - schema-migration-type.md:100（database-optimizer）task-drift-guard
  - test-writing-type.md:96（Phase 5 test-engineer）task-drift-guard
- 另：migration-type.md:4 注释删除 ` + Skill("cli-tool-builder")` 段 → `<!-- 推荐 subagent: executor (sonnet-1,跨步骤协调) + code-assistant -->`
- 豁免未动（范围外）: bugfix-type.md:4 注释（清单未指定）+ 各模板「节奏控制/循环」行（:143-:150）+ code-review 终验行 + refactor/diagnostic 模板（清单未指定）

### V-10 [P2] references/methodology.md:4 锚点 ✅
- 先 grep 复核 SKILL.md 实际行号: :82（Poka-Yoke 前置门）/ :159（内容质量门控），与审计一致
- SKILL.md:81 → SKILL.md:82；SKILL.md:156 → SKILL.md:159

### V-15 [P2] scripts/subagent-fallback.sh:40 ✅
- before: `CFG_PROBE_TIMEOUT_MS=10000`
- after: `CFG_PROBE_TIMEOUT_MS=20000`（对齐 config.json provider_fallback.probe_timeout_ms.default）
- 验证: bash -n exit 0

### V-17 [P2] references/template-guide.md:106 ✅
- :106 cp 源 `templates/task_plan-research.md` → `templates/task_plan.md`
- :103 cp 目标 `.claude/plan-templates/task_plan-research.md` → `.claude/plan-templates/task_plan.md`（两步名字统一为实际存在的 task_plan.md，示例自洽）
- 验证: 全目录 grep "task_plan-research" 零命中；test -e templates/task_plan.md 通过

### V-18 [P2] Rule 编号与 frontmatter 索引 ✅
1. SKILL.md:9 `Critical Rules 全集 1-27` → `1-28`（同步 13-27→13-28，补 Rule 28 说明，依据 critical-rules.md:217 `### 28 交互模式与询问门控`）
2. SKILL.md:308 `Critical Rules 1-27（含 Rule 13-18/21-23/25-27）` → `1-28（含 Rule 13-18/21-23/25-28）`
3. SKILL.md:20-21 frontmatter references 中 task-drift-guard / plan-resume 两行已移除；正文 References 表末尾追加 `| 外部 skill | \`Skill("task-drift-guard")\` 漂移检测 / \`Skill("plan-resume")\` 中断扫描（Rule 15/24 调用入口） |`
4. hooks 注释 :22-23（现 :20-21）: `# See: ~/.claude/... (Claude Code) / ~/.zcode/... (ZCode)` 为显式双平台声明行 → 保留，未改（按"不确定就保留"原则）
- 附加（同 Rule 1-28 对齐，超出清单 2 行）: SKILL.md:264 `详见 references/critical-rules.md（Rules 1-27）` → `1-28`（审计清单只列 :9/:308，但 :264 是同一句式的过期编号，属 V-18 语义范围）

### 验证 5 项（全部通过）
1. grep -n "AskUserQuestion" SKILL.md | head -2 → :5 frontmatter 命中 ✅
2. grep -rn "Skill(" templates/variant/ | grep -v 主进程 → 仅剩豁免行（diagnostic-type.md:58 检查项文本 / 各模板节奏行 :137-:150 / code-review 终验行 / bugfix:4 注释）——7 个指定 checkbox 行全部带「主进程」标注 ✅
3. bash -n scripts/subagent-fallback.sh → exit 0 ✅
4. test -e templates/task_plan.md → 存在；grep task_plan-research references/template-guide.md → 零命中 ✅
5. grep -n "1-27\|1-28" SKILL.md → 仅剩 1-28（:9/:264/:281/:306） ✅

### commit
- aa19691 fix(task-planner): task-v065/T-1 — V-1 allowed-tools 补终档工具 + V-2 七模板 Skill() 主进程标注 + V-10/15/17/18 一致性微修
- 11 files changed, 17 insertions(+), 18 deletions(-)

### 遗留/风险
- 范围外未改（清单未指定，报 verifier 裁决）: ① bugfix-type.md:4 注释仍含 `+ Skill("systematic-debugging")`；② 各模板「节奏控制」行（:137-:150）`Skill("task-drift-guard")` 未加主进程标注；③ refactor-type.md:96 / bugfix-type.md:99 的 drift-guard 终验行与 code-review 终验行未标注（refactor 不在 7 模板清单内，bugfix:99 属 Phase 5 code-assistant 终验但清单只指定 :73）
- V-18-4 hooks 双平台声明行保留 .claude（声明性非指向性，按指令保留）
