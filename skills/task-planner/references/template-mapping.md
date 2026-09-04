# 场景化模板映射指南

> 根据 skill 类型匹配对应的 task_plan 变体模板。

---

## 一、模板选择决策树

```
任务描述是什么?
├─ 关键词/SERP/数据调研 → research-type.md
├─ skill 审计/bug 排查 → diagnostic-type.md
├─ 文章/长文撰写 → writing-type.md
├─ API 发布/分发（数据推送）→ publish-type.md
├─ 代码改/写/删（明确单次编辑）→ code-edit-type.md
├─ 重构（行为不变）/ 瘦身 → refactor-type.md
├─ 修 bug（用户描述了具体症状）→ bugfix-type.md
├─ 跨语言/框架迁移 / CLI 重写 → migration-type.md
├─ 单元/集成/E2E 测试编写 / 覆盖率提升 → test-writing-type.md
├─ 部署 / CI-CD / Docker / k8s / nginx / 基础设施 → deployment-type.md
├─ 性能瓶颈定位 / 优化 / 压测 / benchmark → performance-tuning-type.md
├─ DB schema 变更 / migration / 索引 / 数据回填 → schema-migration-type.md
└─ 不匹配上述任何一类 → templates/task_plan.md（通用）
```

**文件路径**（相对 `${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/`）：
- `templates/task_plan.md`(默认通用)
- `templates/variant/research-type.md`
- `templates/variant/diagnostic-type.md`
- `templates/variant/writing-type.md`
- `templates/variant/publish-type.md`
- `templates/variant/code-edit-type.md`
- `templates/variant/refactor-type.md`
- `templates/variant/bugfix-type.md`
- `templates/variant/migration-type.md`(v2)
- `templates/variant/test-writing-type.md`(v2)
- `templates/variant/deployment-type.md`(v2)
- `templates/variant/performance-tuning-type.md`(v2)
- `templates/variant/schema-migration-type.md`(v2)

**选择策略**:按场景词命中优先(见决策树),复杂度评分仅作辅助;若 plan 涉及多类场景(罕见),可同时引用多个模板的 VC 字段。

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

| 场景 | 模板路径 | 关键差异 |
|------|---------|----------|
| 通用标准 | `templates/task_plan.md` | 5 条通用 VC |
| 调研类 | `templates/variant/research-type.md` | _channel_attempts[] / 数据源 ≥2 |
| 诊断类 | `templates/variant/diagnostic-type.md` | S59 Read 门 / S64 路径验证 |
| 写作类 | `templates/variant/writing-type.md` | SEO 字段 / 配图 ≥3 / 无 Amazon |
| 发布类 | `templates/variant/publish-type.md` | API 200 / 幂等性 / 回滚策略 |
| 代码编辑 | `templates/variant/code-edit-type.md` | diff / lint / 测试 / 风格 |
| 重构 | `templates/variant/refactor-type.md` | 行为不变 / 复杂度下降 |
| bug 修复 | `templates/variant/bugfix-type.md` | 复现 / 根因证据 / 回归测试 |
| 迁移(v2) | `templates/variant/migration-type.md` | 基线归档 / 双跑对照 / 旧入口下线 |
| 测试编写(v2) | `templates/variant/test-writing-type.md` | 用例数 / 覆盖率 / 独立性 / 边界 |
| 部署(v2) | `templates/variant/deployment-type.md` | staging 验证 / 健康检查 / 回滚预案 |
| 性能调优(v2) | `templates/variant/performance-tuning-type.md` | 基线 benchmark / P95 降幅 / 资源 |
| schema 迁移(v2) | `templates/variant/schema-migration-type.md` | 可逆 up/down / 数据零丢失 / 在线切换 |
| 已有 .execution-plan.json | 允许替代 | — |

### 模板互斥关系(避免误选)

| 易混对 | 边界 |
|--------|------|
| publish vs deployment | publish=**数据**推送到 API;deployment=**代码/服务/基础设施**部署 |
| migration vs code-edit | migration=**多步骤**流程(基线锁定→双跑→切流);code-edit=**单次编辑** |
| refactor vs performance-tuning | refactor=**行为不变**前提;performance-tuning=允许**功能+性能**共同变化 |
| test-writing vs code-edit | test-writing 缺**覆盖率门槛/独立性/边界 case**;code-edit 通用编辑 |
| schema-migration vs bugfix | schema-migration=**可逆 up/down** + **在线切换**;bugfix 假设修复即正确 |
| bugfix vs diagnostic | bugfix=**根因已知**进入修复;diagnostic=**根因排查**阶段 |

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
- 「📚 必要知识储备」章节内容（全部模板标配,任务知识库对齐;按任务填充知识源,结构可按需增删行）

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

# 检查「执行范围限制」区块可被脚本提取(scope 护栏;check-conflicts.sh / check-drift.sh 依赖)
awk '/^## ⚠️ 执行范围限制/{f=1; next} /^## /{f=0} f && /\|.*\|.*\|/ && NF>2' task_plan.md | grep -c '^|'
# 应 ≥ 范围表数据行数;若为 0 说明区块结构被破坏(如标题插入区块中间)
```
