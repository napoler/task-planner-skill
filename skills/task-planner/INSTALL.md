# task-planner 多工具安装指南

> **单命令安装**（推荐）：从任意位置运行 `bash <(curl -sSL https://raw.githubusercontent.com/napoler/task-planner-skill/main/install.sh)`，自动检测并安装所有已部署的 agent 工具。
>
> **本地安装**（开发）：`cd ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner} && bash install.sh`

---

## 0. 系统要求

| 工具 | 用途 | 必需? |
|------|------|------|
| `git` 2.30+ | 克隆/拉取 canonical source | ✅ |
| `bash` 4.0+ | 运行 install.sh | ✅ |
| `bun` 1.0+ | Claude Code hook 注册（register-hooks-cj.ts） | 仅 Claude |
| `jq` 1.6+ | check-doc-sync.sh 配置解析 | ✅ |
| `node` 18+ | .cjs 脚本运行时 | ✅ |

---

## 1. 默认安装流程

```bash
# 下载并运行
bash install.sh
```

**自动行为**：
1. ✅ Pre-flight：检查 `git`、`bash`、`jq`、`node` 可用性
2. ✅ Clone canonical：若 `${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}` 不存在，git init；存在则 `git pull`
3. ✅ Detect tools：扫描 `~/.claude/`、`~/.zcode/`、`~/.opencode/`、`~/.cursor/`、`~/.continue/` 是否存在
4. ✅ Backup：现有 stub 备份到 `${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/.backup/<timestamp>/`
5. ✅ Install stub：每个检测到的工具创建薄壳 stub（SKILL.md + scripts + references + templates）
6. ✅ Migrate refs：`~/.claude/CLAUDE.md`、`commands/*.md`、`prompts/*.md` 中的硬编码路径替换为 `${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}` 形式
7. ✅ Verify：7 项自检（canonical git 状态、stub 文件完整性、零硬编码路径、SKILL.md 大小、check-complete.sh/check-doc-sync.sh 可执行、external refs 已迁移）

---

## 2. 高级选项

### 2.1 指定 canonical 位置

```bash
bash install.sh --canonical /opt/task-planner
```

> 后续所有 stub 通过 `TASK_PLANNER_ROOT=/opt/task-planner` 解析路径。

### 2.2 仅安装指定工具

```bash
bash install.sh --tools claude-code,zcode
```

跳过 opencode / cursor / continue 检测（即使已安装也不配置）。

### 2.3 跳过备份（危险）

```bash
bash install.sh --no-backup
```

直接覆盖现有 stub。**仅在 stub 已是 thin shell 或全新环境使用**。

### 2.4 Dry-run 模式

```bash
bash install.sh --dry-run
```

打印所有动作但不实际执行。安全用于预演。

### 2.5 跳过验证

```bash
bash install.sh --no-verify
```

安装但不跑自检（CI 场景下用）。

### 2.6 完整示例

```bash
bash install.sh \
  --canonical /home/terry/dev/task-planner \
  --tools claude-code,zcode \
  --no-backup \
  --dry-run
```

---

## 3. 卸载

```bash
# 完全卸载（删除 canonical + 所有 stub + 备份）
bash uninstall.sh

# 保留 canonical，仅删除 stub
bash uninstall.sh --keep-canonical

# 保留备份
bash uninstall.sh --keep-backups

# 演练
bash uninstall.sh --dry-run
```

> **注意**：uninstall 不会自动还原 `CLAUDE.md` / `commands/*.md` 的路径迁移。这些已替换为 `${TASK_PLANNER_ROOT:-...}` 形式，若需回滚需手动 git 还原或 sed 反向替换。

---

## 4. 升级（更新 canonical）

```bash
cd ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}
git pull
```

所有 stub 自动生效（路径解析通过 `${TASK_PLANNER_ROOT:-...}`，canonical 仓内容即更新）。

> 升级无需重跑 `install.sh` — 仅当：
> - 新增工具
> - SKILL.md frontmatter 字段变更
> - hook 配置变更
>
> 才需要重跑 stub install。

---

## 4.5 伴随文件一键安装（companion/ — 伴生 agents（plan-writer 等））

`companion/agents/` 存放随行 agents;外围 skill 位于仓库顶层 `skills/`(2026-09-04 自 `companion/skills/` 迁移,与 task-planner 同级),由同一脚本统一分发:

| 源路径 | 安装目标 | 用途 |
|----------------|---------|------|
| `companion/agents/plan-writer.md` | `~/.zcode/agents/` | 计划撰写子代理(sonnet-1,Rule 13-16) |
| `companion/agents/article-batch-publisher.md` | `~/.zcode/agents/` | 批量发布(Rule 18.1-18.6 分项门控) |
| `companion/agents/article-field-fixer.md` | `~/.zcode/agents/` | 批量字段修复(verify 抽检,Rule 18.2/18.4) |
| `skills/task-drift-guard/` | `~/.zcode/skills/` | 漂移检测 skill(含批量 failure_rate 判定) |
| `skills/plan-resume/` | `~/.zcode/skills/` | 中断/过期计划扫描与续推决策 skill |
| `skills/todo-skill/` | `~/.zcode/skills/` | 跨会话 todo 持久化 skill |

**一键安装**(install.sh Phase 5.6 自动执行,也可单独跑):

```bash
bash ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/lib/install-companion.sh
# 可选: --dry-run(预览) / --force(不备份覆盖) / --target <tool-root>(指定工具根)
```

**修改后反向同步**(在 ~/.zcode 改了伴随文件后,拉回 companion/ 以便新机器装到最新版):

```bash
bash ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/scripts/sync-companion.sh
# 可选: --dry-run(只看差异) / --diff(输出完整 diff)
# 同步后记得: git add companion/ && git commit && git push
```

**幂等保证**:内容一致自动跳过;内容不同默认先备份到 `companion/.backup-<时间戳>/` 再覆盖。

---

## 5. 故障排查

### 5.1 `check-doc-sync.sh` 报 `SKILL_ROOT undefined`

`${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}` 在你的 shell 环境下 fallback 失败。解决方案：

```bash
# 显式 export
export TASK_PLANNER_ROOT="$HOME/dev/task-planner"
```

或在 `.bashrc`/`.zshrc` 添加：
```bash
export TASK_PLANNER_ROOT="$HOME/dev/task-planner"
```

### 5.1a ZCode PreToolUse matcher 须含 Agent（派发契约守卫，Rule 22.4c）

`~/.zcode/cli/config.json` → `hooks.events.PreToolUse[].matcher` 必须为 `"Write|Edit|Agent"`（旧值 `"Write|Edit"` 不会检查 Agent() 派发）。命令仍为 `bash ~/.zcode/skills/task-planner/scripts/zcode-pretooluse.sh`；Agent 分支调用 `scripts/check-dispatch.sh` 检查 prompt 含计划三文件绝对路径 + 8 字段返回 key + `subagent-state/` 检查点路径，档位见 `config.json#dispatch_contract_enforce`（enforce/warn/off）。自测：`bash scripts/selftest-dispatch.sh`（12 用例）。Claude Code 侧对应工具名为 `Task`，如需同等守卫在 `register-hooks-cj.ts` 的 PreToolUse matcher 加 `Task`（后续任务，本期未改）。
**计划批准门控（task-v058，Rule 22.6/25.1）**：`attest-plan.sh` 锁定前自动跑 `scripts/check-plan-dispatch.sh` 校验派发型 Phase 已带执行体的 S-unit 表（缺失拒绝锁定，`--skip-dispatch-check` 逃生）；`check-complete.sh` 终验同校验。自测：`bash scripts/selftest-plan-dispatch.sh`（6 用例）。
**会话 sid 隔离（task-v059 active-plan-race，Rule 22.9）**：4 个 `zcode-*.sh` hook 从 hook 输入 `.session_id` 解析 sid 并传给 `resolve-plan-dir.sh` 第 2 参——活跃计划解析走会话私有指针 `plans/.active_plan_side/<sid>.active_plan`（优先），全局 legacy `plans/.active_plan` 仅兜底；并行会话不再互顶（残留由 SessionStart 钩子顺带 `gc` 清扫 >24h 指针）。

### 5.2 Claude Code hook 不触发

检查 `~/.claude/settings.local.json` 是否已注册 hooks：
```bash
cat ~/.claude/settings.local.json | grep -A20 hooks
```

未注册则：
```bash
bun run ~/.claude/skills/task-planner/scripts/register-hooks-cj.ts
```

### 5.3 升级后 `install.sh` 行为异常

`install.sh` 本身可被升级覆盖。直接重新运行：
```bash
cd ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}
git pull
bash install.sh --no-backup
```

### 5.4 旧 stub 未被覆盖

检查 stub 目录权限：
```bash
ls -la ~/.claude/skills/task-planner/
```

若文件被锁，先 `chmod -R u+w` 再重跑。

### 5.5 `task-drift-guard` 未触发（v2.1+）

检查 skill 链注册与 hooks:
```bash
# 1. 确认 hooks 已注册(应见 SessionStart/PreToolUse/PostToolUse/UserPromptSubmit 4 类)
grep -E "task-drift|drift-guard" ~/.zcode/cli/config.json

# 2. 确认 drift-guard skill 文件存在
ls ~/.zcode/skills/task-drift-guard/SKILL.md

# 3. 手动跑一次验证(SKILL.md 描述)
# 主进程:Skill("task-drift-guard")
```

### 5.6 `plan-writer` agent 缺失

新装的 ZCode 环境可能没装 plan-writer agent:
```bash
# 1. 检查
ls ~/.zcode/agents/plan-writer.md

# 2. 若缺失,从 source repo 拷贝:
cp /path/to/task-planner-skill/companion/agents/plan-writer.md ~/.zcode/agents/plan-writer.md

# 3. frontmatter `model` 应为 `custom:9e221f47-...:sonnet-1`(或继承主会话);改完需重启会话生效
```

### 5.7 模板完整性验证(v2.1+)

12 个 variant 模板文件必须齐全:
```bash
ls ~/.zcode/skills/task-planner/templates/variant/*.md | wc -l
# 应 = 12

# 缺哪个补哪个:
for f in research diagnostic writing publish code-edit refactor bugfix migration test-writing deployment performance-tuning schema-migration; do
  [ -f ~/.zcode/skills/task-planner/templates/variant/$f-type.md ] || echo "MISSING: $f"
done
```

---

## 6. 完整工作流示例

```bash
# Step 1: 首次安装
bash install.sh

# Step 2: 查看检测结果
ls -la ~/.claude/skills/task-planner/
cat ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/install.log | tail -20

# Step 3: Claude Code hook 注册
bun run ~/.claude/skills/task-planner/scripts/register-hooks-cj.ts

# Step 4: 启动 Claude Code 新会话，测试 SessionStart hook
# 应该看到：[task-plan] mkdir -p plans/task-{id}/ ...

# Step 5: 创建第一个 plan
# 在 Claude Code 中：Skill("task-planner")
# → 跟随提示创建 plans/task-001/task_plan.md
```
