# task-planner 迁移指南

> 从旧的"per-tool 独立副本"模式迁移到"canonical + per-tool stub"架构。

---

## 0. 旧模式 vs 新模式

| 维度 | 旧模式 | 新模式 |
|------|------|------|
| 源 | `~/.claude/skills/task-planner/` + `~/.zcode/skills/task-planner/` 双份独立 | `~/dev/task-planner/` 单一 canonical + 各 stub 薄壳 |
| 内容 | 每工具全量副本（40+ 文件 / 工具） | stub 仅 41 文件（含 rsync 的 content） |
| 同步 | 手动 `cp -r` / `rsync` | `git pull` in canonical |
| 路径 | 硬编码 `~/.claude` / `~/.zcode` | env-var `${TASK_PLANNER_ROOT:-...}` |
| 新工具接入 | 全量复制 40+ 文件 | 复制 stub 模板 + 改 1 个 frontmatter |

---

## 1. 自动迁移

### 1.1 一键迁移

```bash
# 1. 备份现有 install
cp -r ~/.claude/skills/task-planner ~/.claude/skills/task-planner.bak.$(date +%s)
cp -r ~/.zcode/skills/task-planner ~/.zcode/skills/task-planner.bak.$(date +%s)

# 2. 跑 install.sh
bash install.sh
```

`install.sh` 内部自动：
1. 创建 canonical `~/dev/task-planner/`（从现有 `~/.zcode/skills/task-planner/` rsync 内容）
2. 备份现有 stub 到 `~/dev/task-planner/.backup/<ts>/`
3. 重写 stub 路径
4. 安装薄壳 stub
5. 迁移 external references

### 1.2 验证迁移

```bash
bash tests/smoke.sh
```

应输出：`[smoke] summary: 16 pass / 0 fail`

---

## 2. 手动迁移（逐步）

### 2.1 准备 canonical 仓

```bash
mkdir -p ~/dev/task-planner
cd ~/dev/task-planner
git init

# 从 zcode 端拉取最新内容（因为 zcode 端通常比 Claude 端更新）
rsync -av --exclude='.git' ~/.zcode/skills/task-planner/ ./

# 提交
git add -A
git commit -m "feat: initial canonical source from zcode"
```

### 2.2 剥除 SKILL.md hooks

```bash
# 编辑 canonical SKILL.md，删除 hooks: 字段
# （钩子属于平台特定层，不应在 canonical 仓内）
vi ~/dev/task-planner/SKILL.md
```

### 2.3 写 Claude stub

```bash
# 备份旧 Claude stub
cp -r ~/.claude/skills/task-planner ~/.claude/skills/task-planner.bak

# 清理
rm -rf ~/.claude/skills/task-planner/*
mkdir -p ~/.claude/skills/task-planner/scripts

# rsync 内容
rsync -av --exclude='SKILL.md' --exclude='.git' ~/dev/task-planner/ ~/.claude/skills/task-planner/

# 改写路径
sed -i \
  -e 's|"${OPENCODE_SKILL_ROOT:-$HOME/\.zcode/skills/task-planner}"|"${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}"|g' \
  ~/.claude/skills/task-planner/scripts/zcode-posttooluse.sh \
  ~/.claude/skills/task-planner/scripts/zcode-userpromptsubmit.sh

sed -i \
  -e 's|bash "/home/terry/\.zcode/skills/task-planner/scripts/|bash "${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/|g' \
  ~/.claude/skills/task-planner/scripts/zcode-pretooluse.sh

# 写薄壳 SKILL.md（见 INSTALL.md §3 模板）

# 注册 hooks
bun run ~/.claude/skills/task-planner/scripts/register-hooks-cj.ts
```

### 2.4 更新 external references

```bash
# CLAUDE.md
sed -i 's|bash ~/.claude/skills/task-planner/|bash ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/|g' \
  ~/.claude/CLAUDE.md

# commands/*.md
for f in ~/.claude/commands/*.md; do
  sed -i 's|bash ~/.claude/skills/task-planner/|bash ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/|g' \
    "$f"
done
```

### 2.5 验证

```bash
# 0 硬编码残留
grep -rln '\$HOME/\.claude/skills/task-planner\|\$HOME/\.zcode/skills/task-planner' \
  ~/.claude/skills/task-planner/scripts/ 2>/dev/null && echo "FAIL" || echo "CLEAN"

# hooks 触发
# 启动新 Claude Code 会话，观察 SessionStart 输出 [task-plan] 提示
```

---

## 3. 故障回滚

如果新模式出问题，一键回到旧模式：

```bash
# 删除 stub
rm -rf ~/.claude/skills/task-planner
rm -rf ~/.zcode/skills/task-planner

# 恢复旧 stub
mv ~/.claude/skills/task-planner.bak ~/.claude/skills/task-planner
mv ~/.zcode/skills/task-planner.bak ~/.zcode/skills/task-planner

# 还原 external references
# (若有 git tracked 备份：git checkout)
```

canonical 仓可保留作为下一步升级的 source of truth。

---

## 4. 共存期策略

迁移期可让新旧模式共存：
- 旧 stub 在 `~/.claude/skills/task-planner.bak.12345`
- 新 stub 在 `~/.claude/skills/task-planner/`
- 旧 hook command 仍可被旧 stub 调用（若 hook 路径未变）

观察 1-2 周无问题后，删除旧 stub。

---

## 5. 验证清单

迁移完成后逐项检查：

- [ ] `~/dev/task-planner/` 是 git 仓库（`git log` 有 commits）
- [ ] `~/.claude/skills/task-planner/SKILL.md` 是薄壳（< 15KB）
- [ ] `~/.claude/skills/task-planner/scripts/` 0 硬编码路径
- [ ] `~/.claude/settings.local.json` 包含 5 个 hook 注册
- [ ] 启动新 Claude Code 会话，SessionStart 输出 `[task-plan]` 提示
- [ ] `/goal` 命令可正常创建 plans/{id}/task_plan.md
- [ ] `bash ~/dev/task-planner/tests/smoke.sh` 16/16 通过
- [ ] `bash ~/dev/task-planner/lib/verify.sh` ≥ 7 pass / 0 fail

---

## 6. 常见迁移问题

### 6.1 `init-session.sh` 找不到项目级模板

症状：plan 创建时模板未从 `~/.claude/plan-templates/` 复制。
原因：旧 stub 可能硬编码 `~/.claude/plan-templates`。
解决：检查 `init-session.sh` 的 `find_project_templates` 函数路径是否为 `${TASK_PLANNER_ROOT}/...`。

### 6.2 `check-doc-sync.sh` 配置读取失败

症状：post-write hook 报 `STALE: 0min` 或 `FRESH: 0min` 误判。
原因：fallback 链未包含 canonical。
解决：检查 `check-doc-sync.sh` line 30-40 的 `for _c in ...` 循环是否含 `${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/config.json`。

### 6.3 旧 stub 与新 stub 冲突

症状：Claude 加载多个 task-planner skill。
原因：`user-invocable: true` 导致双注册。
解决：删除旧 stub 后重启 Claude Code。
