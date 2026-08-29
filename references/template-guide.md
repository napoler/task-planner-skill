# 模板定制指南

> 指导其他 skill 如何正确使用 task-planner 的模板系统。

---

## 一、模板系统架构

task-planner 提供 **双层优先级** 的模板机制：

```
优先级 1（最高）: {project}/.claude/plan-templates/{filename}
优先级 2（兜底）: ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/templates/{filename}
```

**初始化脚本** `init-session.sh` 自动按优先级查找并复制模板到 plan 目录。

---

## 二、内置模板清单

| 文件名 | 用途 | 被解析脚本 |
|--------|------|-----------|
| `task_plan.md` | 主计划：Goal/VC/Phase/范围限制/Drift Log | check-complete.sh, sync-todos.sh, check-scope.sh |
| `findings.md` | 外部记忆：需求/调研/决策/2-Action Rule | reference.md 引用 |
| `verification.md` | VC 明细 + Phase Gates + Goal Gate + 5Q Reboot | completion-gate.md |
| `progress.md` | 会话日志：动作/测试/错误记录 | session-catchup.ts |
| `notepad-learnings.md` | 经验记录：New Requests/What Worked/Files Modified | 会话结束归档 |

---

## 三、引用方式（推荐）

### 方式 A：项目级覆盖（推荐，全项目生效）

```bash
# 创建项目级模板目录
mkdir -p /path/to/project/.claude/plan-templates/

# 复制并修改需要的模板
cp ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/templates/task_plan.md /path/to/project/.claude/plan-templates/

# 编辑内容，适配本项目的 phase 结构
vi /path/to/project/.claude/plan-templates/task_plan.md
```

**优势**：无需修改 skill 文件，所有后续任务自动使用新模板。

### 方式 B：skill 内绝对路径引用（单 skill 定制）

```markdown
<!-- 在 SKILL.md 中引用 -->
执行前读取模板：`Read ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/templates/task_plan.md`
```

**优势**：skill 自有模板定义，不依赖项目配置。

### 方式 C：场景化变体（深度定制）

```bash
# 项目级放变体文件
cp ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/templates/task_plan.md \
   .claude/plan-templates/task_plan-research.md

# skill 内 cp 后改名使用
cp ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/templates/task_plan-research.md \
   plans/{task-id}/task_plan.md
```

---

## 四、脚本契约标记（禁止改动格式）

以下标记被 3 个下游脚本硬解析，**定制时禁止改动格式**：

| 固定标记 | 被谁解析 | 位置 |
|---------|---------|------|
| `### Phase N: {标题}` | check-complete.sh:14 / sync-todos.sh:54-56 | task_plan.md |
| `- **Status:** complete\|in_progress\|pending` | check-complete.sh:17-19 / sync-todos.sh:63-66 | task_plan.md |
| 5 个文件名白名单 | init-session.sh:62 / check-scope.sh:59 | init 逻辑 |
| fallback `[complete]` inline | check-complete.sh:23-25 | 无 **Status:** 时启用 |

**可自由定制区域**：
- Phase 数量（3-7 个）
- VC 条目内容与验证方式
- Goal 措辞
- 范围限制表内容（根据 skill 实际操作文件定制）
- 注释段（`<!-- ... -->`）
- Key Questions / Decisions / Notes 等结构区

---

## 五、常见场景定制示例

### 场景 1：调研任务

基于 `task_plan.md`，Phase 1 增加调研策略 check：

```markdown
### Phase 1: Research & Discovery
- [ ] 确认 ≥3 种搜索策略（关键词/Bing/文档）
- [ ] 记录 _channel_attempts[] 字段
- [ ] 输出 findings.md
- **Status:** pending
```

### 场景 2：Bug 修复

增加根因定位 Gate：

```markdown
### Phase 1: Root Cause Analysis
- [ ] 复现步骤已记录
- [ ] 证据链完整（日志/堆栈/最小复现）
- [ ] 根因已定位（非症状修复）
- **Status:** pending

⚠️ 禁止在 Phase 1 complete 前进入修复
```

### 场景 3：链式任务（多 skill 接力）

适用：调研→创作→发布等跨 skill 任务。`task_plan.md` 允许多个 Block，用 `---` 分隔。

```markdown
## 🔗 Chain 区块交接配置

| 字段 | 值 |
|------|-----|
| **chain_mode** | linked |
| **current_block** | Block 1 |
| **handoff_on_complete** | ✅ |

### Block 1: 调研阶段
| 字段 | 值 |
|------|-----|
| **goal** | 完成 keyword research |
| **passes_to** | Block 2: `data/{site}/{id}/research/research_data.json` |
| **status** | in_progress |

### Block 2: 创作阶段
| 字段 | 值 |
|------|-----|
| **goal** | 创作 article.json |
| **depends_on** | Block 1 → `data/{site}/{id}/research/research_data.json` |
| **passes_to** | Block 3: `data/{site}/{id}/article/article.json` |
| **status** | pending |

---
## Goal
[Block 2 独立目标]
## Phases
### Phase 1: [创作相关阶段]
...
（每个 block 保持完整 task_plan 结构）
```

### 场景 4：fan-out 派发（一对多）

Phase 对齐管线 Phase 0→6，范围限制表列 `data/{site}/{id}/`：

```markdown
## ⚠️ 执行范围限制
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 文章数据 | data/{site}/{id}/article/* | data/ 其他站点 |
| 研究数据 | data/{site}/{id}/research/* | 其他路径 |
| 计划文件 | plans/task-{id}/* | 其他 plan 目录 |
```

---

## 六、定制后验证 Checklist

```bash
# 1. 格式完整性
bash ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/check-complete.sh
# 应返回 exit 0

# 2. Phase 解析数
grep -c "### Phase" task_plan.md
# 应 ≥ 3

# 3. Status 标记解析
grep -c "\*\*Status:\*\*" task_plan.md
# 应 = Phase 数

# 4. 文件名白名单
ls *.md | sort
# 应包含: findings.md, notepad-learnings.md, progress.md, task_plan.md, verification.md
```

---

## 七、路径引用规范

**禁止使用相对路径**（从不同 skill 目录执行会落空）：

```markdown
❌ 错误：Read templates/task_plan.md
❌ 错误：Read ./templates/task_plan.md
```

**必须使用绝对路径**：

```markdown
✅ 正确：Read ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/templates/task_plan.md
✅ 正确：Read "${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/templates/task_plan.md"
```

**配置层外置**（`config.json`）：

```json
{
  "template_priority": ["project-level", "built-in"]
}
```

---

## 八、参考文件

| 文件 | 路径 |
|------|------|
| 主模板 | `${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/templates/task_plan.md` |
| 初始化脚本 | `${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/init-session.sh` |
| 完成检测 | `${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/check-complete.sh` |
| 范围检查 | `${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/check-scope.sh` |
| Todo 同步 | `${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/sync-todos.sh` |
