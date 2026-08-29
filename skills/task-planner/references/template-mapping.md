# 场景化模板映射指南

> 根据 skill 类型匹配对应的 task_plan 变体模板。

---

## 一、模板选择决策树

```
skill 复杂度评分 ≥9 分（复杂级）
├─ 调研/搜索类 → research-type.md
├─ 写作/内容类 → writing-type.md
├─ 诊断/修复类 → diagnostic-type.md
└─ 发布/集成类 → publish-type.md
```

**文件路径**（相对 `${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/`）：
- `templates/variant/research-type.md`
- `templates/variant/writing-type.md`
- `templates/variant/diagnostic-type.md`
- `templates/variant/publish-type.md`

---

## 二、调研型模板（Research Type）

**适用场景**：关键词调研、SERP 分析、竞品研究、数据抓取

**关键差异**：
- Phase 1 强制"调研策略 ≥3 种"检查
- VC 绑定 `_channel_attempts[]` 字段
- 增加"证据来源"列

**模板路径**：`${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/templates/variant/research-type.md`

**使用方式**：
```bash
# 项目级覆盖
cp ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/templates/variant/research-type.md \
   .claude/plan-templates/task_plan.md
```

---

## 三、写作型模板（Writing Type）

**适用场景**：文章创作、内容生成、文案撰写

**关键差异**：
- Phase 对齐管线 Phase 0→6
- 范围限制表列 `data/{site}/{id}/`
- 增加"封面保护"验证点
- 强制 SEO 字段检查

**模板路径**：`${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/templates/variant/writing-type.md`

**使用方式**：
```bash
# 文章管线项目级覆盖
mkdir -p /mnt/data/dev/article-generation/.claude/plan-templates/
cp ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/templates/variant/writing-type.md \
   /mnt/data/dev/article-generation/.claude/plan-templates/task_plan.md
```

---

## 四、诊断型模板（Diagnostic Type）

**适用场景**：skill 审计、bug 排查、代码审查、质量评估

**关键差异**：
- Phase 1 强制"前置 Read 门（S59）"
- Phase 1.5 强制"路径存在性验证（S64）"
- 增加"evidence 完整性"检查点
- 禁止凭印象诊断

**模板路径**：`${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/templates/variant/diagnostic-type.md`

**使用方式**：
```bash
# skill-fix 项目级覆盖
mkdir -p ~/.claude/skills/skill-fix/.claude/plan-templates/
cp ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/templates/variant/diagnostic-type.md \
   ~/.claude/skills/skill-fix/.claude/plan-templates/task_plan.md
```

---

## 五、发布型模板（Publish Type）

**适用场景**：API 发布、批量部署、数据同步

**关键差异**：
- 增加"发布前二次验证"阶段
- VC 绑定 API 响应码
- 强制幂等性检查
- 失败回滚策略

**模板路径**：`${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/templates/variant/publish-type.md`

---

## 六、模板路径速查表

| 场景 | 模板路径 | 复杂度阈值 |
|------|---------|-----------|
| 通用标准 | `templates/task_plan.md` | 5-8 分 |
| 调研类 | `templates/variant/research-type.md` | ≥9 分 |
| 写作类 | `templates/variant/writing-type.md` | ≥9 分 |
| 诊断类 | `templates/variant/diagnostic-type.md` | ≥9 分 |
| 发布类 | `templates/variant/publish-type.md` | ≥9 分 |
| 已有 .execution-plan.json | 允许替代 | — |

---

## 七、定制红线（禁止改动）

以下标记被脚本硬解析，**定制时禁止改动格式**：

| 固定标记 | 被谁解析 |
|---------|---------|
| `### Phase N: {标题}` | check-complete.sh:14 / sync-todos.sh:54-56 |
| `- **Status:** complete\|in_progress\|pending` | check-complete.sh:17-19 / sync-todos.sh:63-66 |
| 5 个文件名白名单 | init-session.sh:62 / check-scope.sh:59 |
| fallback `[complete]` inline | check-complete.sh:23-25 |

**可自由定制区域**：
- Phase 数量（3-7 个）
- VC 条目内容与验证方式
- 范围限制表内容
- Key Questions / Decisions / Notes 等结构区

---

## 八、验证命令

```bash
# 检查 Phase 解析数
grep -c "### Phase" task_plan.md  # 应 ≥ 3

# 检查 Status 标记
grep -c "\*\*Status:\*\*" task_plan.md  # 应 = Phase 数

# 检查文件名白名单
ls *.md | sort
# 应包含: findings.md, notepad-learnings.md, progress.md, task_plan.md, verification.md

# 运行完成检测
bash ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/check-complete.sh
# 应返回 exit 0
```
