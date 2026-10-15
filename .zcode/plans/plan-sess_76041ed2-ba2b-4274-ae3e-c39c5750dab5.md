## 计划：清理 4 个陈旧计划 + 冲突告警 + 部署位验证

### 背景
4 个未完成任务的产出都已在 master 合并，但计划文件未归档（Rule 81 未执行），导致 INDEX.md 仍标记 in_progress，触发无意义的"冲突告警"和"任务恢复"提醒。

### 验证结果
| 任务 | 产出 | 验证 |
|------|------|------|
| task-v133 | Rule 54 执行诚实性 | ✅ 13 处在 critical-rules-discipline.md |
| task-v135 | Rule 21.1c 智能拆分 | ✅ 被 task-v144 整合为 Rule 59.6，analyze-splits.sh 存在 |
| task-v142 | Rule 57 周期性回顾 | ✅ periodic-review.sh 存在 |
| task-v165 | agent 模板 8 字段范式 | ✅ 5 个 agent 定义含 8 字段范式 |

### 方案
**Phase 1: 更新计划状态**（4 个任务 × 2 文件 = 8 文件）
- 将 task-v133/v135/v142/v165 的 task_plan.md 中所有 `**Status:**` 更新为 `complete`
- 更新对应 progress.md 标记 Phase complete

**Phase 2: 归档计划**（Rule 81）
- 运行 `archive-plan.sh` 归档 4 个任务到 `plans/archive/`
- 更新 INDEX.md 移除"待处理"标记

**Phase 3: 冲突告警清理**
- 处理 task-v165 的冲突告警（plan task-v165-agent-template-deploy session= 覆盖文件）
- 确认告警来源并清理

**Phase 4: 部署位验证**
- 验证两个部署位的 selftest-input-consistency.sh 通过
- 确认 Rule 85 生效

### 验收标准
- 4 个任务归档到 plans/archive/
- INDEX.md 无"待处理"标记
- 冲突告警清除
- 两个部署位 selftest 5/5 PASS

### 工作区
- 纯文档操作（plans/ 目录），§十一 11.5 例外②，无需 worktree