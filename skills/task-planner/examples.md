# Examples: Planning with Files in Action

## Example 1: Research Task

**User Request:** "Research the benefits of morning exercise and write a summary"

### Loop 1: Create Plan
```bash
Write task_plan.md
```

```markdown
# Task Plan: Morning Exercise Benefits Research

## Goal
Create a research summary on the benefits of morning exercise.

## Phases
- [ ] Phase 1: Create this plan ✓
- [ ] Phase 2: Search and gather sources
- [ ] Phase 3: Synthesize findings
- [ ] Phase 4: Deliver summary

## Key Questions
1. What are the physical health benefits?
2. What are the mental health benefits?
3. What scientific studies support this?

## Status
**Currently in Phase 1** - Creating plan
```

### Loop 2: Research
```bash
Read task_plan.md           # Refresh goals
Skill("research-assistant", "morning exercise benefits")
Write findings.md              # Store findings
python3 scripts/planctl.py phase-done --id P2 && python3 scripts/planctl.py render   # Mark Phase 2 complete（派生视图）
```

### Loop 3: Synthesize
```bash
Read task_plan.md           # Refresh goals
Read findings.md               # Get findings
Write morning_exercise_summary.md
python3 scripts/planctl.py phase-done --id P3 && python3 scripts/planctl.py render   # Mark Phase 3 complete（派生视图）
```

### Loop 4: Deliver
```bash
Read task_plan.md           # Verify complete
Deliver morning_exercise_summary.md
```

---

## Example 2: Bug Fix Task

**User Request:** "Fix the login bug in the authentication module"

### task_plan.md
```markdown
# Task Plan: Fix Login Bug

## Goal
Identify and fix the bug preventing successful login.

## Phases
- [x] Phase 1: Understand the bug report ✓
- [x] Phase 2: Locate relevant code ✓
- [ ] Phase 3: Identify root cause (CURRENT)
- [ ] Phase 4: Implement fix
- [ ] Phase 5: Test and verify

## Key Questions
1. What error message appears?
2. Which file handles authentication?
3. What changed recently?

## Decisions Made
- Auth handler is in src/auth/login.ts
- Error occurs in validateToken() function

## Errors Encountered
- [Initial] TypeError: Cannot read property 'token' of undefined
  → Root cause: user object not awaited properly

## Status
**Currently in Phase 3** - Found root cause, preparing fix
```

---

## Example 3: Chain Task — Research → Write → Publish

**User Request:** "为 soundgearx 站点创作并发布一篇关于 XXX 的文章"
这是一个典型的三阶段链式任务，对应 Block 1(调研) → Block 2(创作) → Block 3(发布)。

### task_plan.md（链式结构）

```markdown
# Task Plan: soundgearx 文章创作并发布

## Goal
完成从调研到发布的完整文章管线。

## 🔗 Chain 区块交接配置

### Chain 模式: linked（串行接力）

### Block 1: 调研阶段
| 字段 | 值 |
|------|-----|
| **goal** | 完成 keyword research |
| **passes_to** | Block 2: `data/soundgearx/{id}/research/research_data.json` |
| **status** | in_progress |

### Block 2: 创作阶段
| 字段 | 值 |
|------|-----|
| **goal** | 完成 article.json |
| **depends_on** | Block 1 → `data/soundgearx/{id}/research/research_data.json` |
| **passes_to** | Block 3: `data/soundgearx/{id}/article/article.json` |
| **status** | pending |

### Block 3: 发布阶段
| 字段 | 值 |
|------|-----|
| **goal** | API 发布文章 |
| **depends_on** | Block 2 → `data/soundgearx/{id}/article/article.json` |
| **status** | pending |

### 🔗 Handoff 追踪表
| Block | 状态 | 交接产物 | 验证命令 | 完成时间 |
|-------|------|---------|---------|---------|
| Block 1 | in_progress | research_data.json | `jq '.data|length' research_data.json` | - |
| Block 2 | pending | article.json | `python3 article_json_editor.py validate` | - |
| Block 3 | pending | API post_id | `api_client posts list --site soundgearx` | - |

---
## Goal
[Block 2 独立目标 — 从 research_data.json 创作 article.json]
## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | article.json schema 通过 | python3 scripts/article_json_editor.py validate | -- |
...
## Phases
### Phase 1: 从 research_data.json 生成 writing_context.md
...
---
## Goal
[Block 3 独立目标 — 发布文章]
## ✅ Verification Contract
...
```

### 执行流程

```
[Block 1] Phase 0.5→1.5 调研 → complete
  handoff: Read data/soundgearx/{id}/research/research_data.json 确认非空
  → 更新 Handoff 追踪表 Block 1 = complete
  → Block 2 status = in_progress

[Block 2] Phase 2→4 创作 → complete
  handoff: Read article.json 确认 schema 通过
  → 更新 Handoff 追踪表 Block 2 = complete
  → Block 3 status = in_progress

[Block 3] Phase 5→6 发布 → complete
  handoff: api_client posts create 返回 post_id
  → 更新 Handoff 追踪表 Block 3 = complete
  → chain 结束
```

---

## Example 3: Feature Development

**User Request:** "Add a dark mode toggle to the settings page"

### The 3-File Pattern in Action

**task_plan.md:**
```markdown
# Task Plan: Dark Mode Toggle

## Goal
Add functional dark mode toggle to settings.

## Phases
- [x] Phase 1: Research existing theme system ✓
- [x] Phase 2: Design implementation approach ✓
- [ ] Phase 3: Implement toggle component (CURRENT)
- [ ] Phase 4: Add theme switching logic
- [ ] Phase 5: Test and polish

## Decisions Made
- Using CSS custom properties for theme
- Storing preference in localStorage
- Toggle component in SettingsPage.tsx

## Status
**Currently in Phase 3** - Building toggle component
```

**findings.md:**
```markdown
# Findings: Dark Mode Implementation

## Existing Theme System
- Located in: src/styles/theme.ts
- Uses: CSS custom properties
- Current themes: light only

## Files to Modify
1. src/styles/theme.ts - Add dark theme colors
2. src/components/SettingsPage.tsx - Add toggle
3. src/hooks/useTheme.ts - Create new hook
4. src/App.tsx - Wrap with ThemeProvider

## Color Decisions
- Dark background: #1a1a2e
- Dark surface: #16213e
- Dark text: #eaeaea
```

**dark_mode_implementation.md:** (deliverable)
```markdown
# Dark Mode Implementation

## Changes Made

### 1. Added dark theme colors
File: src/styles/theme.ts
...

### 2. Created useTheme hook
File: src/hooks/useTheme.ts
...
```

---

## Example 4: Error Recovery Pattern

When something fails, DON'T hide it:

### Before (Wrong)
```
Action: Read config.json
Error: File not found
Action: Read config.json  # Silent retry
Action: Read config.json  # Another retry
```

### After (Correct)
```
Action: Read config.json
Error: File not found

# Update task_plan.md:
## Errors Encountered
- config.json not found → Will create default config

Action: Write config.json (default config)
Action: Read config.json
Success!
```

---

## The Read-Before-Decide Pattern

**Always read your plan before major decisions:**

```
[Many tool calls have happened...]
[Context is getting long...]
[Original goal might be forgotten...]

→ Read task_plan.md          # This brings goals back into attention!
→ Now make the decision       # Goals are fresh in context
```

This is why Manus can handle ~50 tool calls without losing track. The plan file acts as a "goal refresh" mechanism.

---

## Example 5: Multi-task Parallel Pattern

When a project has multiple independent sub-features, spawn parallel agents — each manages its own plan subdirectory.

**User Request:** "Build a REST API with auth, CRUD endpoints, and tests"

```
├── plans/task-001-auth/     (subagent: auth agent)
│   ├── task_plan.md
│   ├── verification.md
│   └── findings.md
├── plans/task-002-crud/     (subagent: CRUD agent)
│   ├── task_plan.md
│   ├── verification.md
│   └── findings.md
└── plans/INDEX.md           (main coordinator tracks both)
```

### Coordinator flow:
```
1. Read plans/INDEX.md → confirm both plans created
2. Agent(subagent_type="code-assistant", prompt="Run plans/task-001-auth/init-session.sh")
3. Agent(subagent_type="code-assistant", prompt="Run plans/task-002-crud/init-session.sh")
4. Wait for both → Read INDEX.md → sync
5. Execute Phase 1 of task-001-auth
6. Execute Phase 1 of task-002-crud (concurrent)
7. Run sync-todos.sh --index after each completed phase
8. Completion Gate: Read each plan's verification.md, verify all [x]
```

### Index entry format:
```markdown
## Active Tasks
| ID | Plan Path | Phase | Status | Last Update |
|----|-----------|-------|--------|-------------|
| task-001 | plans/task-001-auth/task_plan.md | 2 | in_progress | 2026-08-01 |
| task-002 | plans/task-002-crud/task_plan.md | 1 | in_progress | 2026-08-01 |
```

Parallel tasks share the same INDEX.md — the coordinator runs `sync-todos.sh --index` after every phase completion to keep track.

---

## Example 6: Migration Task（v2 variant — `migration-type`）

**User Request**: "把 content-extractor 从 Python 迁移到 Bun + TS"

### template_type 选择
- 关键词命中「迁移 / Python / TS」 → `migration-type.md`
- plan-writer 自动用 migration 模板填充

### 关键 Phase
```markdown
### Phase 1: 旧实现基线锁定
- [ ] git tag migration-baseline-<commit>
- [ ] 旧代码归档到 archive/legacy-<date>/
### Phase 2: 新实现开发(Bun + TS)
- [ ] 派 executor 跨文件协调
### Phase 3: 双跑回归对照
- [ ] 跑 tmp/dual-run.sh,输出 tmp/dual-run-diff.txt
### Phase 4: 切流/路由切换
- [ ] 旧入口加 deprecation warning
### Phase 5: 文档更新 + 旧入口归档
```

完整模板：`templates/variant/migration-type.md`。

---

## Example 7: Test Writing Task（v2 variant — `test-writing-type`）

**User Request**: "为 src/auth/*.ts 写单元测试,覆盖率达到 80%"

### 关键 Phase
- Phase 1: 测试目标分析（识别核心函数/分支）
- Phase 2: 用例设计（等价类 + 边界值）
- Phase 3: 用例实现（派 code-assistant）
- Phase 4: 覆盖率验证（`bun test --coverage`）
- Phase 5: CI 集成

**VC 重点**：VC-2 覆盖率 ≥80% 强制门控。

---

## Example 8: Deployment Task（v2 variant — `deployment-type`）

**User Request**: "把 staging 部署到生产,蓝绿发布"

### 关键 Phase
- Phase 1: 环境清单 + staging 准备
- Phase 2: 配置变更（infra as code）
- Phase 3: staging 验证（**VC-1 门控**）
- Phase 4: 生产部署（蓝绿/灰度，**VC-3 回滚预案必填**）
- Phase 5: 部署后监控

---

## Example 9: Performance Tuning Task（v2 variant — `performance-tuning-type`）

**User Request**: "优化 API /search 的 P95 延迟"

### 关键 Phase
- Phase 1: 瓶颈定位（profile + 数据库慢查询分析）
- Phase 2: 基线 benchmark（`tmp/perf-before.json`）
- Phase 3: 优化实施（索引/缓存/算法/并发）
- Phase 4: 验证 benchmark + 测试
- Phase 5: 复现性归档

**VC 重点**：VC-2 P95 降幅 ≥30%。

---

## Example 10: Schema Migration Task（v2 variant — `schema-migration-type`）

**User Request**: "为 users 表加 last_login_at 字段,支持回滚"

### 关键 Phase
- Phase 1: schema 变更设计（可逆 up/down）
- Phase 2: 编写 up/down 脚本
- Phase 3: staging 演练（**VC-1/VC-2 门控**）
- Phase 4: 生产执行（pt-online-schema-change）
- Phase 5: 回滚预案确认

**VC 重点**：VC-1 migration 可逆（up + down 双向脚本）。

---

## Example 11: template-catalog CLI — 检索选型到 init-session.sh 闭环

**场景**：用户要求"为登录模块做一次代码审查与重构"。不再凭记忆猜模板名，改用 `template-catalog` 的检索/推荐结果反推 `template_type`，再初始化并校验 7 文件。

> **占位符声明（执行前必须替换）**：下文 `<SKILL_DIR>` 换成 task-planner 技能真实根目录（含 `scripts/` 与 `templates/`）；`<计划目录>` / `plans/task-011/` 换成真实计划目录。下列选型结果是本机实测示例，实际以你自己 `list` 的输出为准。

### 正例：可照抄工作流

```bash
# ① 路径占位符替换（SKILL_DIR=技能根目录；PLAN_DIR=计划目录）
SKILL_DIR="<SKILL_DIR>"
PLAN_DIR="<计划目录>"

# ② 列清单（只读）：先看有哪些模板、默认模板是谁
bash "$SKILL_DIR/scripts/template-catalog.sh" list
bash "$SKILL_DIR/scripts/template-catalog.sh" list --scope builtin

# ③ 关键词筛选 + 推荐排序（只读）：--json 便于脚本解析
bash "$SKILL_DIR/scripts/template-catalog.sh" list --query "代码审查" --json \
  | jq -r '.templates[].type'          # 本机实测命中 diagnostic
bash "$SKILL_DIR/scripts/template-catalog.sh" list --query "重构" --json \
  | jq -r '.templates[].type'          # 本机实测命中 refactor
bash "$SKILL_DIR/scripts/template-catalog.sh" list --recommend "代码审查" --json
# 若环境无 jq，直接看第 ② 步的人读表，效果等价

# ④ 定 template_type：取上面命中/推荐首位的 type（本例 diagnostic，或按需 refactor）
#    若要定制：先 --dry-run 预览（不落盘），看到 CATALOG DERIVE DRY <path> 再决定是否写入
bash "$SKILL_DIR/scripts/template-catalog.sh" derive --from code-edit --to my-review --prune "发布,回滚" --scope project --dry-run
# 写入示例（去掉 --dry-run 才真正落盘，按需取消注释）：
# bash "$SKILL_DIR/scripts/template-catalog.sh" derive --from code-edit --to my-review --prune "发布,回滚" --scope project

# ⑤ init-session.sh 初始化（写操作：在计划目录内创建 7 个规划文件）
mkdir -p "$PLAN_DIR" && cd "$PLAN_DIR"
bash "$SKILL_DIR/scripts/init-session.sh" "登录模块代码审查与重构"

# ⑥ 校验 7 文件在位：task_plan / findings / progress / notepad-learnings /
#    verification / knowledge-brief / user-session-log
bash "$SKILL_DIR/scripts/verify_io.sh" "$PLAN_DIR"
```

关键判据：`template-catalog.sh` 的写操作（`add` / `clone` / `derive`）先加 `--dry-run`，stdout 出现 `CATALOG <ACTION> DRY <path>` 才算预览成功；退出码 `0`=成功、`1`=业务失败（源不存在/同名冲突等）、`2`=用法错误。`verify_io.sh` 全绿才说明 7 文件到位。

### 反例 / 错误示范

```bash
# 反例 1：跳过检索，凭印象直接 derive → 模板不对，后续领域附录与任务错位
bash "$SKILL_DIR/scripts/template-catalog.sh" derive --from code-edit --to my-review   # 未 --dry-run 直接写入

# 反例 2：在仓库根目录跑 init-session.sh → "[init] ERROR: 必须在 plans/<task-id>/ 目录下运行"
bash "$SKILL_DIR/scripts/init-session.sh" "登录模块代码审查与重构"   # 错误：没有先 cd "$PLAN_DIR"

# 反例 3：verify_io.sh 传技能根目录 → 7 文件全部 missing、rc 1
bash "$SKILL_DIR/scripts/verify_io.sh" "$SKILL_DIR"
```

反例根因：① 选型未用机器检索结果；② `init-session.sh` 强依赖"当前目录=计划目录"；③ 校验参数必须是计划目录而非技能目录。

---

## Example 12: planctl JSON Authority Loop — init → add → set → check → render → audit-add → render

**权威源声明**：`<计划目录>/plan-state.json` 是任务状态**唯一权威源**。`planctl.py render` 产出的 4 个 MD（`task_plan.md` / `progress.md` / `verification.md` / `findings.md`）是**只读派生视图，禁止用 Write/Edit 手工修改**——任何改动都必须先写回 JSON，再 render 重新派生；否则下次 render 会覆盖手改，造成 JSON/MD 不一致。

> **占位符声明（执行前必须替换）**：`<计划目录>` 换成含 `plan-state.json` 的真实目录；`--json` 里的 `id` / `text` / `criterion` / `command` 按任务实情填写。

### 正例：可照抄闭环

```bash
PLAN_DIR="<计划目录>"

# ① init：从模板生成 plan-state.json（原子写；已存在需 --force，谨慎）
python3 planctl.py init --plan-dir "$PLAN_DIR" --task-id TASK-001 --tier standard --lane L0

# ② add requirements / vcs（--json 为完整条目结构，字段按段而定）
python3 planctl.py add --plan-dir "$PLAN_DIR" --section requirements --json '{"id":"R1","text":"按模板完成代码审查","type":"手段"}'
python3 planctl.py add --plan-dir "$PLAN_DIR" --section vcs --json '{"id":"VC1","criterion":"7 文件在位且 schema 通过","command":"test -f plan-state.json"}'

# ③ set：条目字段 + 顶层字段（template_type 用 Example 11 的选型结果）
python3 planctl.py set --plan-dir "$PLAN_DIR" --section requirements --id R1 --field text --value '按模板完成代码审查（已确认）'
python3 planctl.py set --plan-dir "$PLAN_DIR" --field template_type --value 'diagnostic'
python3 planctl.py set --plan-dir "$PLAN_DIR" --field next_step --value '执行 Phase 1'

# ④ check：机器门判定，stdout 单行 PLANCTL CHECK <name>: PASS|FAIL
python3 planctl.py check --plan-dir "$PLAN_DIR" vc-nonvacuous
echo "check rc=$?"   # 退出码 rc 0 = PASS；rc 1 = FAIL；rc 2 = 输入异常

# ⑤ render：生成 4 个 MD 派生视图（只读产物，禁止手工 Edit）
python3 planctl.py render --plan-dir "$PLAN_DIR"

# ⑥ audit-add：追加审计轮次（写入权威源 JSON）
python3 planctl.py audit-add --plan-dir "$PLAN_DIR" --round 1 --verdict APPROVED --by reviewer --c 3 --i 0 --w 0

# ⑦ 再 render：让 4 个 MD 与新审计轮次保持一致
python3 planctl.py render --plan-dir "$PLAN_DIR"

# 只读核对：validate（退出码 0=通过 / 1=失败）、status、get
python3 planctl.py validate --plan-dir "$PLAN_DIR"
python3 planctl.py status --plan-dir "$PLAN_DIR"
python3 planctl.py get --plan-dir "$PLAN_DIR" --section vcs --id VC1
```

写入安全：每条管理命令先校验新文档 → 旧版备份到 `<计划目录>/.history/`（保留最近 20 版）→ 临时文件 + fsync + `os.replace` 原子替换 → 回读校验，失败回滚。错误走 stderr，业务/IO/JSON 错误退出码 `1`。

### 反例 / 错误示范

```bash
# 反例 1：直接 Edit task_plan.md 改 Phase 状态 → 下次 render 被 JSON 覆盖，改动丢失
# Edit task_plan.md    # 错误：4 个 MD 是派生视图，禁手工 Edit

# 反例 2：未 init 就 add → rc 1（plan-state.json 不存在），错误走 stderr
python3 planctl.py add --plan-dir "$PLAN_DIR" --section requirements --json '{"id":"R9","text":"无权威源"}'

# 反例 3：check 返回 rc 1 仍继续 render/audit-add → 把未过门状态固化进 MD
python3 planctl.py check --plan-dir "$PLAN_DIR" vc-nonvacuous || echo "rc=1 FAIL，先回 JSON 修，禁止继续 render"
```

反例根因：①② 混淆"权威源 vs 派生视图"与写前依赖；③ 忽略机器门退出码，把 FAIL 当 PASS 往下走。
