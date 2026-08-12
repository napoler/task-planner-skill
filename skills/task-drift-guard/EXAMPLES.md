# Task Drift Guard — 使用示例

## 示例 1：任务中途检查（task_plan.md 存在）

**场景**：用户让 agent 修复某个 bug，已做了 8 步工具调用，用户说"检查漂移"。

```
# 执行结果
计划源: plans/fix-auth-bug/task_plan.md
当前阶段: Phase 2 (修改 token 验证逻辑)

检测结果:
| VC 条目 | 状态 | 说明 |
|---------|------|------|
| VC-1: token 验证函数返回 401 | ✅ | 已修改 src/auth.py:47 |
| VC-2: 不改变路由定义 | ✅ | git diff 无路由变更 |
| VC-3: 添加单元测试 | ⚠️ | 未开始，但 Phase 2 不要求写测试 |

结论: ⚠️ 轻微漂移 — VC-3 暂未覆盖，但不阻塞 Phase 2
建议: 继续当前 Phase，Phase 3 补充测试
```

---

## 示例 2：文章管线 Orchestrator 模式

**场景**：正在跑 `article-orchestrator` CREATE 模式，完成 Phase 2 后检查。

```
计划源: data/soundgearx/79/article/.execution-plan.json
当前阶段: Phase 2.7 完成，准备进入 Phase 3

检测结果:
| VC 条目 | 状态 | 说明 |
|---------|------|------|
| writing_context.md 存在且 ≥1KB | ✅ | 12.3KB |
| .phase2.7-completed marker 存在 | ✅ | |
| 已修改 article-orchestrator/references/dispatch-rules.md | 🔴 | 不在允许范围内 |

结论: 🔴 BLOCKED — 修改了禁止文件
建议: 立即 STOP，用户决策是否回滚
```

---

## 示例 3：用户感觉跑偏了

**场景**：用户说"我感觉我们做偏了，检查一下"，无显式计划文件。

```
计划源: 用户原话（无 plan 文件）
用户原话: "帮我把登录页面的颜色改成蓝色，不要太蓝"

当前状态:
- 已修改 7 个文件（css、html、js、config）
- 颜色已改为深蓝色 (#003366)
- 但同时也修改了路由配置和 API 端点

结论: ⚠️ DRIFT — 范围扩展到路由和 API，超出"颜色"变更
建议: 确认是否保留路由/API 修改，还是回滚
```

---

## 示例 4：无计划源

**场景**：新会话，用户直接让修改代码，没有 task_plan.md。

```
WARNING: 无计划源可对比，无法做漂移检测。请先创建 task_plan.md 或声明目标。
STOP。
```

---

## 示例 5：批量任务中途检查

**场景**：`batch-optimizer-soundgearx` 批量优化，第 30/129 篇完成，执行了 45 分钟无产出更新。

```
计划源: plans/batch-optimizer-soundgearx-20260717/plan.json
当前阶段: 已完成 30/129 篇，状态 pending → in_progress 循环

检测结果:
| VC 条目 | 状态 | 说明 |
|---------|------|------|
| batch-state.json completed 计数 | ⚠️ | 30 篇 completed，但有 3 篇 status=completed 但 completion_type=skipped_no_value |
| 每篇有 .optimizer-baseline.json | ✅ | 30 篇都有基线记录 |
| verify_optimizer_effectiveness exit 0 | 🔴 | 3 篇 skipped 未运行验证 |

结论: ⚠️ DRIFT — 3 篇被标记 completed 但实际未通过验证
建议: 对 3 篇 skipped 重新走 optimize 流程，或标记为 needs_rerun
```

---

## 示例 6：范围偏移（改错文件）

**场景**：修复 Phase 3.2 上下文污染，但改了 article-orchestrator 的模板。

```
计划源: plans/phase32-fix/task_plan.md
允许修改: .claude/skills/article-content-writer/tools/generate_prompts.py
           .claude/skills/article-content-writer/templates/writing-prompt-template.md

实际修改:
- ✅ generate_prompts.py — 修改（在允许范围）
- ✅ writing-prompt-template.md — 修改（在允许范围）
- 🔴 article-orchestrator/templates/steps/update/step-2-execute.md — 修改（超出范围）
- 🔴 config/django-api-client.json — 修改（超出范围）

结论: 🔴 BLOCKED — 修改了计划外的 orchestrator 模板和配置文件
建议: 回滚 step-2-execute.md 和 django-api-client.json，等待用户确认
```
