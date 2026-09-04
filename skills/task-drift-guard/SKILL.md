---
name: task-drift-guard
description: 定期检测任务执行是否偏离原始计划/用户指令，生成漂移报告并要求停止确认。当用户说"检查漂移"、"漂移检测"、"对齐检查"、"task drift guard"、"检查任务偏移"、"这个任务和计划一致吗"、任务执行了 5+ 步工具调用后需要回读计划时触发。也适用于：用户感觉任务跑偏了、任务卡住反复修同一问题、完成一个 Todo 条目后需要定期对齐、切换模块或文件前需确认未越界。
model: haiku
---

# Task Drift Guard

只读漂移检测。不修改任何文件，发现偏差后 STOP 并报告，等用户决策。

## 触发条件（命中任一即调用）

1. 连续 ≥3 次工具调用后未回读计划
2. 完成 Todo 条目后 / 切换模块/文件前
3. 用户反馈同一问题 ≥2 次
4. 执行超过 10 分钟无阶段性产出
5. 用户明确说"检查漂移"等关键词

## 执行步骤

### Step 1: 找计划源

| 线索 | 计划源 |
|------|--------|
| `plans/<当前目录>/task_plan.md` 存在 | 读它 |
| 文章管线（有 `data/{site}/{id}/`）| 读 `.execution-plan.json` |
| 批量处理（`plans/batch-xxx/plan.json`）| 读它 |
| comet change 活跃 | 读 `.comet.yaml` 的 phase/tasks 字段 |
| 无以上线索但有明确用户指令 | 以用户原话为锚点 |

**无计划源 → 输出 WARNING 后 STOP。**

### Step 2: 读取计划，提取信息

只读。提取：目标（Goal）、VC 条目、执行范围限制、当前 Phase。

**批量任务附加提取（Rule 18.3/18.6）**：计划含「📦 Batch Report」区块或 `chain_mode: fan-out` 时，额外提取八字段（total/success/failed/failure_rate/sampled_pass/sampled_fail/pre_check/rollback_point）。`failure_rate` 缺失或未填 → 视为批量质量不可见，报告提示补填。

### Step 3: 获取当前状态证据

```bash
git status --short && git diff --stat
TaskList  # 如有
```

结合会话上下文回顾已做操作。

### Step 4: 比对，判态

| 状态 | 含义 | 动作 |
|------|------|------|
| ✅ ALIGNED | 与计划一致 | 继续 |
| ⚠️ DRIFT | 偏离但未阻塞 | 询问用户 |
| 🔴 BLOCKED | 严重偏离，关键路径被跳过 | STOP 等决策 |

漂移判定三原则（任一命中）：改计划外文件 / 做的事与 VC 不符 / 跳过关键路径做低优先级。

**批量漂移判定（Rule 18.3,批量任务附加）**：

| Batch Report 指标 | 判定 |
|-------------------|------|
| `failure_rate` >5% | ⚠️ DRIFT（批量质量漂移）— 报告失败明细,询问用户继续/缩批/熔断 |
| `failure_rate` >20% | 🔴 BLOCKED — 立即 STOP,要求熔断回滚 |
| `sampled_fail` >0 | 🔴 BLOCKED — ground truth 失败 = 整批未验证(Rule 18.2) |
| 八字段缺项 | ⚠️ DRIFT — 批量不可见,要求补填 Batch Report |

### Step 5: 输出报告（不写文件）

模板见 EXAMPLES.md。用 markdown 直接输出，不做任何写入。批量任务附报：Batch Report 八字段快照 + failure_rate 走向（与上次检测对比升/降）。

### Step 6: 按结果行动

- ✅ → 继续
- ⚠️ → 问用户：纠正/继续/STOP
- 🔴 → STOP 所有写入，等用户决策

## 铁律

- 只读。不改任何文件，不写日志，不 commit
- 证据优先：结论必须来自 `git diff`/Read/TaskList 输出，不用推测
- 范围最小化：只检查当前任务的 VC 条目，不扫描全项目
