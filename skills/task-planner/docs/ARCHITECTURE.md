# task-planner 多工具架构设计

> **目标**：一份 canonical source，多工具 stub 适配，零内容重复，env-var 解析路径。

---

## 1. 设计原则

### 1.1 单一事实源（Single Source of Truth）

canonical 仓 `${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/` 是 task-planner 全部内容实现的唯一来源：
- `SKILL.md`（剥除 hooks）
- `references/`（8 篇规则文档）
- `templates/`（5 个核心模板 + 3 个辅助模板 + 12 个变体，统一含「📚 必要知识储备」章节）
- `scripts/`（16 个工具脚本）
- `config.json`（阈值配置）

### 1.2 工具无关性

canonical 仓的**内容不绑定**任何特定 agent 工具：
- 无 `~/.claude` / `~/.zcode` 硬编码
- hook 命令通过 `${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}` 解析
- 配置文件 / 模板 / references 文本均不假设运行环境

### 1.3 工具特定层

每个 agent 工具的 stub 负责两件事：
1. **路径解析**：将工具的 hooks / commands / scripts 入口指向 canonical
2. **平台适配**：把 canonical 路径转换为该工具识别的 hook 格式

---

## 2. 目录结构

```
${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/                          ← canonical source (git 仓库)
├── SKILL.md                                 ← 工具无关主文档（hooks 字段为空）
├── config.json
├── README.md
├── WORKFLOW.md
├── examples.md
├── reference.md
├── references/                              ← 规则文档
│   ├── critical-rules.md
│   ├── todo-sync.md
│   ├── worktree-isolation.md
│   ├── template-mapping.md
│   ├── template-guide.md
│   ├── goal-gate.md
│   ├── completion-gate.md
│   └── billing.md
├── templates/                               ← 计划文件模板
│   ├── task_plan.md
│   ├── progress.md
│   ├── findings.md
│   ├── verification.md
│   ├── notepad-learnings.md
│   └── variant/                             ← 场景化变体
│       ├── research-type.md
│       ├── writing-type.md
│       ├── diagnostic-type.md
│       └── publish-type.md
├── scripts/                                 ← 工具无关脚本
│   ├── check-complete.sh / .ps1
│   ├── check-conflicts.sh
│   ├── check-doc-sync.sh
│   ├── check-drift.sh
│   ├── check-scope.sh
│   ├── init-session.sh / .ps1
│   ├── plan-created.cjs
│   ├── session-catchup.ts
│   ├── sync-ide-folders.ts
│   ├── sync-todos.sh
│   ├── task-plan-init.cjs
│   ├── zcode-posttooluse.sh
│   ├── zcode-pretooluse.sh
│   ├── zcode-sessionstart.sh
│   └── zcode-userpromptsubmit.sh
├── lib/                                     ← installer 库
│   ├── detect-tools.sh
│   ├── backup.sh
│   ├── install-stub.sh
│   ├── migrate-refs.sh
│   └── verify.sh
├── tests/
│   └── smoke.sh
├── docs/
│   └── ARCHITECTURE.md
├── install.sh                               ← 主入口
├── uninstall.sh
├── MIGRATION.md
├── INSTALL.md
└── .gitignore

~/.claude/skills/task-planner/               ← Claude Code stub
├── SKILL.md                                 ← 薄壳：声明 hooks + 路径契约
├── scripts/                                 ← rsync from canonical + sed-rewritten
├── references/, templates/, config.json     ← 直接 rsync from canonical
└── (无独立 lib/、tests/、docs/、install.sh)

~/.zcode/skills/task-planner/                ← ZCode stub
├── SKILL.md                                 ← 薄壳：zcode 风格 hooks
└── (其他结构同 Claude stub)
```

### 2.5 外围 Skills 清单(2026-09-04 起源 = 仓库顶层 skills/)

外围 skill = task-planner 运行时依赖、但安装在 `<tool-root>/skills/<name>/`(而非 `<tool-root>/skills/task-planner/` 内)的同伴 skill。**2026-09-04 布局统一**:原先嵌在 `companion/skills/` 的目录已全部迁移到仓库顶层 `skills/`(与 task-planner 同级),companion/ 仅保留 agents/;`install.sh` Phase 5.6 + `lib/install-companion.sh` 自动发现顶层 skills/(排除 task-planner 本体,仅分发含 SKILL.md 的目录),`scripts/sync-companion.sh` 按同一布局回同步。

| Skill | 描述 | 文件 |
|-------|------|------|
| `task-drift-guard` | 执行中漂移检测(每 phase 完成后调) | 顶层 3 文件:SKILL.md / EXAMPLES.md / README.md |
| `plan-resume` | 中断/过期计划扫描与续推决策(支持 task-planner / openspec / spec-kit 三格式) | SKILL.md / README.md + `scripts/`(4 脚本)+ `tests/`(1 smoke) |
| `todo-skill` | 跨会话 todo/计划状态持久化 | SKILL.md + `scripts/` |

### 2.6 Companion 同步器设计决策

**问题**：早期 `lib/install-companion.sh` 与 `scripts/sync-companion.sh` 用 bash glob `for f in "$skill_dir"*` 扫外围 skill 目录，**只匹配顶层文件**(匹配到 `scripts/` 目录但不会递归)，导致带子目录(`scripts/*.sh`)的外围 skill 在分发时被静默丢弃。

**决策**(2026-09-04)：改用 `find -maxdepth 2 -type f -print0` 配合 `-d ''` while read：

- `-maxdepth 2` 覆盖"扁平 3 文件"(depth=1)与"含 1 层子目录"(depth=2)
- `-type f` 排除目录、socket、pipe
- `-not -path '*/tests/*'` 显式排除 tests/ 子目录(避免 smoke.sh 被分发到客户端)
- `-not -path '*/.git/*'` 排除 git 元数据
- `-print0` + `IFS= read -r -d ''` 处理文件名含空格/特殊字符
- `${f#$skill_dir}` 取相对路径保留子目录结构(如 `scripts/scan-plans.sh`)

**向后兼容**：`task-drift-guard` 只有顶层3 文件，新 find 输出仍是 3 行，分发行为不变。

**已知限制**：
- 不递归到 depth=3 及以上。若未来外围 skill 需要更深嵌套,需调整 maxdepth
- `tests/` 排除意味着 smoke.sh 不分发。客户端测试通过 CI 在 canonical 仓跑
- `skills/plan-resume/` 支持 3 种格式(task-planner / openspec / spec-kit)扫描,但 spec-kit 本机未见过真样例(基于官方模板约定),文档标记为[实验性]

### 2.7 plan-resume 与 task-planner 集成契约

`plan-resume` 不是 task-planner 的子集,而是**外围监控 skill**,通过被动扫描让 task-planner 会话知晓工作区其他中断任务。

**集成节点**:
1. `references/critical-rules.md` Rule 24 — Phase complete 后被动调 `Skill("plan-resume")`
2. `SKILL.md` frontmatter `references` 表 + §Execution 流程图 DRIFT CHECK 节点 + Chain handoff step 5 + 合规清单 C13
3. `templates/progress.md` 加「plan-resume 报告检查点」表

**边界**:(详见 `skills/plan-resume/SKILL.md` §6 与其他 skill 的关系)
- task-planner **只读**其他 plan 的 `task_plan.md`,不修改它
- plan-resume **不替用户续推**,只产报告
- 用户须明确说"续推 task-X"才会调 task-planner 创建新 plan
- 失败时 plan-resume 报错不阻塞当前 Phase 推进(软约束 P1)

**向后兼容**:Rule 24 是新增,P1 级。task-planner v2.3 已有任务不受影响;plan-resume 未安装时 Rule 24 跳过(见 `SKILL.md` §6 失败兜底)。


---

## 3. 路径解析契约

### 3.1 单一表达式

所有 hooks / scripts / 文档使用同一表达式：
```bash
${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}
```

### 3.2 三级 fallback

```
一级：环境变量 TASK_PLANNER_ROOT
二级：fallback 至 canonical 仓默认位置
三级：（无）若一二都未设，命令失败 — 提示用户
```

### 3.3 路径解析脚本

canonical 提供 `lib/detect-tools.sh` 用于检测和 `lib/install-stub.sh` 内的 sed 规则。所有 stub scripts 在 install 时被改写，确保与 canonical 解析一致。

---

## 4. Per-Tool Stub 适配

### 4.1 通用结构

每个 stub 持有：
- **SKILL.md**（薄壳）
  - `description` / `model` / `allowed-tools` 与 canonical 一致
  - hook 字段：仅声明该工具识别的 hook 格式
  - 内容主体：内容引用表（指向 `${TASK_PLANNER_ROOT}/...`）
- **scripts/**：rsync from canonical + sed-rewritten 路径
- **references/ + templates/ + config.json**：直接 rsync from canonical

### 4.2 工具差异

| 工具 | Hook 注册位置 | Hook 配置格式 | 适配脚本 |
|------|--------------|--------------|---------|
| Claude Code | `~/.claude/settings.json` 或 `settings.local.json` | `hooks: { SessionStart: [...], PreToolUse: [...] }` | `register-hooks-cj.ts` |
| ZCode | SKILL.md frontmatter | `hooks:\n- type: command\n  name: ...` | sed 替换路径即可 |
| OpenCode | SKILL.md frontmatter | 类似 ZCode | 通用模板 |
| Cursor | SKILL.md frontmatter | 类似 ZCode | 通用模板 |
| Continue | SKILL.md frontmatter | 类似 ZCode | 通用模板 |

### 4.3 适配原则

- **路径硬编码最小化**：所有 hook command 用 `${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/...` 形式
- **平台特性保留**：每工具的 hook 命名空间（`SessionStart` / `PreToolUse` 等）和配置语法（JSON vs YAML）必须遵循该平台规范
- **脚本无修改**：stub 内的 scripts/ 是 canonical 的精确副本（仅路径重写），逻辑与 canonical 完全一致

---

## 5. 升级与同步

### 5.1 更新 canonical

```bash
cd ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}
git pull
```

所有 stub 自动生效（无需重跑 install.sh）：
- `references/`、`templates/` 通过 rsync 在 install 时已锁定指向 canonical
- `scripts/` 通过 env-var 解析，每次调用读取 canonical 实际内容

### 5.2 添加新工具

修改 `lib/install-stub.sh` 的 `TOOL_PROBES` 数组：
```bash
TOOL_PROBES=(
  "claude-code|$HOME/.claude/skills/task-planner|claude-settings|$HOME/.claude"
  "zcode|$HOME/.zcode/skills/task-planner|zcode-frontmatter|$HOME/.zcode"
  # 新增：
  "newtool|$HOME/.newtool/skills/task-planner|newtool-frontmatter|$HOME/.newtool"
)
```

并在 `generate_stub_skill_md` 添加 `newtool-frontmatter` 分支。`install.sh` 自动检测并安装新工具。

### 5.3 添加新 Hook

canonical SKILL.md 不变（仍剥除 hooks）。在 stub SKILL.md 中添加新 hook entry 即可：
```bash
# 编辑 stub
vi ~/.claude/skills/task-planner/SKILL.md
# 添加 hooks block 内的 hook
# 重启 agent tool 加载
```

---

## 6. 故障模式

### 6.1 `TASK_PLANNER_ROOT` 未设置

症状：`check-doc-sync.sh` 报 `SKILL_ROOT undefined`。
解决：export 或 fallback 链必须包含 canonical 默认路径。

### 6.2 hook 注册未生效

症状：SessionStart 时无 task-planner 提示。
解决：检查 `settings.local.json` 的 `hooks` 块；或重跑 `bun run register-hooks-cj.ts`。

### 6.3 sed 路径改写遗漏

症状：脚本中仍含 `~/.zcode/skills/task-planner`。
解决：手动 `sed -i 's|...|...|g' <script>`，并检查 `lib/install-stub.sh` 的 `rewrite_paths_in_scripts`。

### 6.4 stub 与 canonical 内容脱节

症状：用户改 canonical 后 stub 行为不变。
原因：`scripts/` 已在 install 时 rsync 到 stub（副本）。
解决：要么改 install.sh 让 scripts 通过 env-var 解析（即 stub 仅 SKILL.md），要么每次升级后 `bash install.sh --no-backup` 重新 rsync。

---

## 7. 设计权衡（Trade-offs）

| 决策 | 备选 | 选择理由 |
|------|------|---------|
| `scripts/` 在 stub 内副本 | 完全 env-var 解析 | 部分平台 hook 配置限制路径必须在 stub 内；env-var 兼容性差 |
| canonical 仓独立 git | monorepo skill 子目录 | 跨项目共享；版本独立；多人协作 |
| 5 hooks 全部启用 | 仅 SessionStart | 与 zcode 端功能对齐；提供完整漂移检测 |
| `install.sh` 用 bash | Python / TypeScript | bash 4.0+ 跨平台一致；无运行时依赖 |
| 通过 `register-hooks-cj.ts` 改 JSON | 直接编辑 settings.json | JSON 解析可靠；避免手工错误 |
| backup 保留在 `.backup/` | 删前询问 | 默认安全；用户加 `--no-backup` 才删 |
| 不做 install 锁文件 | flock | 安装本身 < 1s；并发场景罕见 |
