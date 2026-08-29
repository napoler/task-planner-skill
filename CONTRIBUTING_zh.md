# 贡献指南

感谢你对 task-planner 的关注。本文档说明如何在不破坏 Skill 运行契约的前提下参与开发。

---

## 仓库结构

```
task-planner-skill/
├── CLAUDE.md                  # 仓库级指南（必读）
├── scripts/                   # 安装/验证工具（你的入口）
│   ├── install.sh
│   ├── uninstall.sh
│   └── validate.sh
├── examples/
│   └── full-workflow.md       # 端到端演示
├── skills/task-planner/       # Skill 本体 —— 打磨时只读参考
│   ├── SKILL.md
│   ├── config.json
│   ├── scripts/               # 现有脚本（新增脚本前请先评审）
│   ├── templates/
│   └── references/
└── plans/                     # 规划工作区（已 gitignore）
```

**规则：** Skill 逻辑改动在 `skills/task-planner/` 中；打包/安装/验证改动在仓库根目录的 `scripts/` 和 Markdown 文件中。

---

## 开发流程

```bash
# 1. 初始化
git clone <repo>
cd task-planner-skill

# 2. 快速检查所有脚本
bash -n scripts/*.sh
python3 -m py_compile skills/task-planner/scripts/session-catchup.py
node -e "require('typescript')" 2>/dev/null && npx tsc --noEmit scripts/sync-ide-folders.ts

# 3. 安装 Skill 到本地环境进行真实测试
bash scripts/install.sh

# 4. 验证
bash scripts/validate.sh
# 预期输出：VALIDATION PASSED

# 5. 修改 → 重新安装 → 重新验证
bash scripts/install.sh --force
bash scripts/validate.sh

# 6. 提交（遵循 Conventional Commits）
git add -p
git commit -m "feat(install): install.sh 新增 --source 参数"
```

---

## 脚本规范

### `scripts/*.sh`

- Bash 编写，顶部必须包含 `set -euo pipefail`
- `--dry-run` 是安全默认值；`--force` 覆盖确认提示
- 退出码：0 成功，1 用户错误，2 环境错误，3 验证失败
- 禁止依赖 Python 或 Node —— Shell 脚本必须在裸 bash 环境中可运行
- 每次修改后：`bash -n path/to/script.sh` 必须通过才能提交
- 每次修改后：用 `--dry-run` 和 `--force` 测试后再提交

### `scripts/*.py`

- 仅支持 Python 3.8+，不允许第三方依赖 —— Skill 必须无需 `pip install` 即可安装
- 如需 `jsonschema`，检测并警告即可，禁止在 ImportError 时失败
- 每次修改后：`python3 -m py_compile path/to/script.py` 必须通过才能提交

### `scripts/*.ts`

- 尽力而为，非强制。Skill 可脱离 TypeScript 运行；`sync-ide-folders.ts` 是可选增强
- `@types/node` 不能是硬依赖
- 如 CI 有 `tsc` 则验证；否则静默跳过

### `templates/*.md`

- 这些模板由 `init-session.sh` 渲染到用户工作区
- 保留占位符（`[task-id]`、`[目标]` 等），但让它们自解释
- 本项目的目标受众支持双语标题（中文 + 英文）
- 每次修改后：运行 `bash scripts/install.sh` 并抽查生成的文件

### `references/*.md`

- 仅供 Skill 代理在运行时读取的参考文档
- 修改这些文件可能破坏已有计划 —— 需配合版本号升级

---

## 提交规范

遵循 Conventional Commits 格式：

```
feat(install): install.sh 新增 --dry-run 参数
fix(validate): TypeScript 类型错误降级为警告
docs: 为 v2.0.0 添加 CHANGELOG 条目
chore: 更新 README 快速上手代码块
```

作用域可选值：`install`、`validate`、`uninstall`、`skill`、`templates`、`docs`。

---

## PR 检查清单

提交 PR 前请确认：

- [ ] 所有新 Shell 脚本通过 `bash -n` 语法检查
- [ ] 所有新 Python 脚本通过 `python3 -m py_compile`
- [ ] `scripts/validate.sh` 对已安装 Skill 验证通过（退出码 0）
- [ ] `scripts/install.sh --dry-run` 和 `--force` 均可正常执行
- [ ] `README.md` 和 `README_zh.md` 链接了所有新增文档
- [ ] `CHANGELOG.md` 有 `[Unreleased]` 条目描述变更
- [ ] `CLAUDE.md`（如有仓库结构变更）保持一致
- [ ] 未经明确授权不修改 `skills/task-planner/` 中的 Skill 逻辑
- [ ] 提交信息遵循 Conventional Commits 规范

---

## 端到端测试

标准测试流程：

```bash
# 干净环境
rm -rf /tmp/test-skill-install
bash scripts/install.sh --target /tmp/test-skill-install
bash scripts/validate.sh /tmp/test-skill-install

# 启动一个真实任务计划
mkdir -p /tmp/test-plan && cd /tmp/test-plan
bash /tmp/test-skill-install/scripts/init-session.sh test-task
cat task_plan.md | head -30
# 应包含：目标、VC 表、阶段、范围
```

通过此测试即意味着 PR 可安装。

---

## 向后兼容性

Skill 的外部接口是**目录结构和 frontmatter**。请勿变更：

- `SKILL.md`、`config.json`、`templates/`、`scripts/`、`references/` 的存在性
- frontmatter 字段：`name`、`model`、`description`、`allowed-tools`、`hooks`
- `config.json` Schema（`additionalProperties: false`）
- 现有脚本的 CLI 参数（新增参数时提供默认值，不删除旧参数）

破坏性变更应放在大版本升级中，并在 `CHANGELOG.md` 的 `### Breaking` 下记录。

---

## 问题与帮助

- 在 GitHub 提交 Issue，标签使用 `bug`、`feature` 或 `docs`
- 如遇验证失败，请粘贴完整的 `validate.sh` 输出 —— 它会列出每一项检查结果
- 如脚本在不同操作系统上行为异常，请在 Issue 中注明操作系统 + bash 版本

---

## English Version

[English Contributing Guide](CONTRIBUTING.md)

---

## 许可

参与贡献即表示你同意将你的贡献以项目 MIT 许可证授权。
