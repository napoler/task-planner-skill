# task-planner 多工具安装指南

> **单命令安装**（推荐）：从任意位置运行 `bash <(curl -sSL https://raw.githubusercontent.com/your-org/task-planner/main/install.sh)`，自动检测并安装所有已部署的 agent 工具。
>
> **本地安装**（开发）：`cd ~/dev/task-planner && bash install.sh`

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
2. ✅ Clone canonical：若 `~/dev/task-planner` 不存在，git init；存在则 `git pull`
3. ✅ Detect tools：扫描 `~/.claude/`、`~/.zcode/`、`~/.opencode/`、`~/.cursor/`、`~/.continue/` 是否存在
4. ✅ Backup：现有 stub 备份到 `~/dev/task-planner/.backup/<timestamp>/`
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
cd ~/dev/task-planner
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
cd ~/dev/task-planner
git pull
bash install.sh --no-backup
```

### 5.4 旧 stub 未被覆盖

检查 stub 目录权限：
```bash
ls -la ~/.claude/skills/task-planner/
```

若文件被锁，先 `chmod -R u+w` 再重跑。

---

## 6. 完整工作流示例

```bash
# Step 1: 首次安装
bash install.sh

# Step 2: 查看检测结果
ls -la ~/.claude/skills/task-planner/
cat ~/dev/task-planner/install.log | tail -20

# Step 3: Claude Code hook 注册
bun run ~/.claude/skills/task-planner/scripts/register-hooks-cj.ts

# Step 4: 启动 Claude Code 新会话，测试 SessionStart hook
# 应该看到：[task-plan] mkdir -p plans/task-{id}/ ...

# Step 5: 创建第一个 plan
# 在 Claude Code 中：Skill("task-planner")
# → 跟随提示创建 plans/task-001/task_plan.md
```
