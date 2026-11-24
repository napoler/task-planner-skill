# todo-frontmatter-fix 检查点报告

- 任务：`task-fix-all-20261123` Phase 4+5
- Worktree：`/mnt/data/dev/task-planner-skill/tmp/worktrees/task-fix-all-20261123`
- 分支/提交：`wt/task-fix-all-20261123 @ 70c108abc1a7a9a998f11d7e9262f61feb7b2b93`
- Commit message：`fix(todo-skill): 失败态改blocked+留痕，补每步完成判据（task-fix-all-20261123）`
- 提交范围（git diff --name-only HEAD~1..HEAD）：仅 3 文件
  - `docs/frontmatter-linter-skill-tier-proposal.md`（新增提案）
  - `skills/todo-skill/SKILL.md`
  - `skills/todo-skill/tools/cli_todo-manager.ts`

## 任务A — todo-skill 失败态假完成修复（已落地）

### 改动

1. `skills/todo-skill/SKILL.md` Step 5a（原 105-109 行附近）：
   - 失败处理由“重试仍失败则跳过并标记 completed”改为“重试仍失败时标记 `blocked` 并留痕（session-kv 保留失败原因/步骤/时间，Todo 描述或备注注明阻塞点），不得标记 `completed`”。
   - 错误留痕格式改为结构化 JSON：`'{"step":N,"reason":"<失败原因>","action":"<失败动作/命令>","time":"<ISO8601>"}'`。
   - 明确 `completed` 必须有完成证据；无证据不得声称完成/不得标记 completed。
   - 正常流程补充“执行步骤并收集完成证据（产物路径/命令输出/验证结果，至少一项可复核）”，仅证据齐备才 completed。

2. `skills/todo-skill/SKILL.md` Step 5b：
   - 补“每步最小完成判据（缺一不可）”：执行证据、产物证据、验证证据。
   - 任一缺失保持 `in_progress` 或标记 `blocked`，不得假完成。

3. `skills/todo-skill/tools/cli_todo-manager.ts`：
   - `STATUSES` 增加 `blocked`：`["pending","in_progress","completed","blocked"]`。
   - `list` 帮助文本同步为 `[--status pending|in_progress|completed|blocked]`。

### 验证

- 代码检查：`git diff` 仅包含上述 3 文件对应改动；Step 5a 不再出现“跳过并标记 completed”。
- Smoke test（隔离临时 store，`TODO_STORE_FILE=$(mktemp -d)/store.json`）：
  - `node skills/todo-skill/tools/cli_todo-manager.ts create --title "t1" --desc "d1"` → `status=pending`，exit 0
  - `update --index 1 --status blocked` → `status=blocked`，exit 0
  - `list --status blocked` → 返回 1 条 blocked 任务
  - `status` → `by_status.blocked=1`
  - 临时目录已清理。
- todo-skill 自身 selftest：`find skills/todo-skill -maxdepth 4 -type f` 未发现 test/selftest 脚本；仓库范围 `find` 也未发现 `*todo*test*` / `*todo-manager*selftest*`。因此无可单跑 todo-skill selftest，本次以 smoke test + diff 复核作为验证证据。

## 任务B — frontmatter-linter skill 档适配（提案，未改保护区）

### 约束遵守

- `/home/terry/.zcode/agents/frontmatter-linter.md` 属 §六 全局保护区，本次用户未明确授权修改 agent 定义，**未触碰**。
- `git diff --name-only HEAD~1..HEAD` 不含 `.zcode/agents` / `~/.zcode` 路径。

### 提案产物

- 路径：`docs/frontmatter-linter-skill-tier-proposal.md`（worktree 内）
- 内容：根因（agent R1 契约误扫 skill）、档位判定（agent/skill/unknown）、R1 拆分为 R1-agent/R1-skill、R2-R5 档位适配、`allowed-tools` 视为 skill 档合法可选字段、输出模板加档位标记、落地后验证建议、风险边界。

### 副本核实

- worktree 与主仓 `find -name '*frontmatter*linter*' -not -path '*/.git/*'`：除全局 agent 定义外，未发现 `skills/*/companion/agents/` 或仓库内 frontmatter-linter 副本。提案中已记录“若未来出现非保护区副本可同步，但需用户确认范围”。

## 保护区检查

- 未修改 `/home/terry/.zcode/agents/frontmatter-linter.md`
- 未修改 `~/.zcode/skills/**`、`~/.zcode/commands/**`、`~/.zcode/AGENTS.md`
- 未触碰主仓 `skills/`（所有改动在 worktree）

## 风险/后续

- `cli_todo-manager.ts` 增加 `blocked` 状态后，现有依赖“仅三态”的外部消费者可能需要同步识别；本次未发现仓内 todo-skill selftest 覆盖该枚举。
- frontmatter-linter 真正修复需用户显式授权后按提案落地到保护区 agent 定义。
