# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概览

这是一个 **Claude Code Skill 仓库**，核心是 `task-planner` skill——一套基于文件系统驱动的 AI 代理任务规划与执行框架。灵感来自 Manus 的 Context Engineering 原则，用 Markdown 文件替代 volatile context window 作为持久化工作记忆。

仓库不运行可执行程序，不提供 API——它是一个 skill 包，被 Claude Code / OpenCode 加载后作为子流程工具使用。

## 目录结构

```
skills/task-planner/
├── SKILL.md              ← skill 入口：frontmatter + workflow 定义
├── config.json           ← 所有可调阈值（max_vc, retry_count, escalation_threshold 等）
├── reference.md          ← Manus 6 原则 + 3 策略 + 决策矩阵 + 三击协议
├── examples.md           ← 实际使用示例（调研/bugfix/功能开发）
├── scripts/
│   ├── init-session.sh   ← 初始化 task_plan.md + findings.md + progress.md 等
│   ├── check-scope.sh    ← PreToolUse hook：Write/Edit 前验证文件是否在 scope 内
│   ├── sync-todos.sh     ← Phase 状态 → Todo 同步 + plans/INDEX.md 生成（--index 模式）
│   ├── check-complete.sh ← Stop hook：汇总 phase 完成情况
│   └── session-catchup.py ← 跨会话恢复：扫描历史 session，检测未同步规划更新
├── templates/
│   ├── task_plan.md      ← 主计划模板（含 VC 表、scope 表、phase 追踪）
│   ├── verification.md   ← 验证契约模板（phase gate + 5 问重启检查）
│   ├── findings.md       ← 调研发现记录
│   ├── progress.md       ← 会话进度日志
│   └── notepad-learnings.md
└── references/
    ├── critical-rules.md ← Rules 1-10 核心执行约束
    ├── completion-gate.md← 子代理验证 + 并行同步协议
    ├── goal-gate.md      ← VC 规则 + COMPLETE/PARTIAL/BLOCKED 退出标准
    └── billing.md        ← 计费模式说明
```

## 核心架构

**规划循环（每轮任务执行）：**

```
用户请求 → session-catchup.py(中断恢复?) → init-session.sh(新建)
→ 填写 task_plan.md(含 VC 表 + Scope 表) → 展示计划等待 "yes"
→ 逐 Phase 执行（每 phase 完 Edit task_plan.md + sync-todos.sh --index）
→ 全部 phase complete → 逐条复验 VC → 输出 COMPLETE/PARTIAL/BLOCKED
```

**关键设计决策：**

- `check-scope.sh` 通过 PreToolUse hook 拦截，防止计划外文件写入（exit 1 = blocked, exit 2 = 需初始化 plan）
- `config.json` 是运行时唯一配置入口，所有阈值中心化管理（`max_vc`, `retry_count`, `escalation_threshold` 等）
- 子代理完成"done"后必须 Read 实际文件验证，禁止信任子代理自述——见 `completion-gate.md`
- `session-catchup.py` 在 workflow 第一步运行，检测上一轮中断点，避免重复劳动

**模板优先级：** `init-session.sh` 先搜 `{project}/.claude/plan-templates/`（项目级），未找到则 fallback 到内置模板。项目可通过此机制覆盖默认行为。

## 开发规范

### 修改 skill 逻辑

所有可执行逻辑（≥10 行或含循环/条件/IO）必须外置到 `scripts/`，SKILL.md 内仅保留单行调用指令。

- 修改 shell 脚本 → 先用 `bash -n` 检查语法，再跑最小可运行测试
- 修改 Python 脚本 → 用 `python3 -c "import ast; ast.parse(open('...').read())"` 检查语法
- `config.json` 修改后需保持 JSON Schema 兼容（`additionalProperties: false`）

### 添加新模板

在 `templates/` 下新建 `.md` 文件，同时在 `init-session.sh` 的循环里加入新文件名（第 62 行 `for file in ...`）。

### 新增脚本参数

所有脚本的 CLI 接口必须向后兼容，新参数加默认值，不改现有行为。

## 常用命令

```bash
# 语法检查所有脚本（含新增 check-drift.sh）
bash -n skills/task-planner/scripts/*.sh && bash -n skills/task-planner/scripts/check-drift.sh
python3 -m py_compile skills/task-planner/scripts/session-catchup.py

# 验证 config.json schema
python3 -c "import jsonschema, json; jsonschema.validate({}, json.load(open('skills/task-planner/config.json')))"

# 测试 init-session（dry-run，不修改实际文件）
cd /tmp && mkdir -p test-plan && cd $_ && bash <repo>/skills/task-planner/scripts/init-session.sh test-project && cat task_plan.md | head -30 && cd -

# 测试 check-scope
cd /tmp/test-plan && bash <repo>/skills/task-planner/scripts/check-scope.sh Write "task_plan.md" "task_plan.md"; echo "exit: $?"
```

## 版本与许可

- 许可：MIT（见 `LICENSE`）
- 初始提交：2026-08-08
- 当前分支：`main`，无其他分支
