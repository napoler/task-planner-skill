# Reference: Manus Context Engineering Principles

> **⚠ 外部事实声明（未验证）**：Manus 被 Meta 收购的声明来源 https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus，收购金额/日期未独立核实。
>
> 本 skill 基于上述 Manus context engineering 原则实践，用于文件驱动规划。

This skill is based on context engineering principles from Manus (https://manus.im).

## The 6 Manus Principles

### Principle 1: Design Around KV-Cache

> "KV-cache hit rate is THE single most important metric for production AI agents."

**Statistics:**
- ~100:1 input-to-output token ratio
- Cached tokens: $0.30/MTok vs Uncached: $3/MTok
- 10x cost difference!

**Implementation:**
- Keep prompt prefixes STABLE (single-token change invalidates cache)
- NO timestamps in system prompts
- Make context APPEND-ONLY with deterministic serialization

### Principle 2: Mask, Don't Remove

Don't dynamically remove tools (breaks KV-cache). Use logit masking instead.

**Best Practice:** Use consistent action prefixes (e.g., `browser_`, `shell_`, `file_`) for easier masking.

### Principle 3: Filesystem as External Memory

> "Markdown is my 'working memory' on disk."

**The Formula:**
```
Context Window = RAM (volatile, limited)
Filesystem = Disk (persistent, unlimited)
```

**Compression Must Be Restorable:**
- Keep URLs even if web content is dropped
- Keep file paths when dropping document contents
- Never lose the pointer to full data

### Principle 4: Manipulate Attention Through Recitation

> "Creates and updates todo.md throughout tasks to push global plan into model's recent attention span."

**Problem:** After ~50 tool calls, models forget original goals ("lost in the middle" effect).

**Solution:** Re-read `task_plan.md` before each decision. Goals appear in the attention window.

```
Start of context: [Original goal - far away, forgotten]
...many tool calls...
End of context: [Recently read task_plan.md - gets ATTENTION!]
```

### Principle 5: Keep the Wrong Stuff In

> "Leave the wrong turns in the context."

**Why:**
- Failed actions with stack traces let model implicitly update beliefs
- Reduces mistake repetition
- Error recovery is "one of the clearest signals of TRUE agentic behavior"

### Principle 6: Don't Get Few-Shotted

> "Uniformity breeds fragility."

**Problem:** Repetitive action-observation pairs cause drift and hallucination.

**Solution:** Introduce controlled variation:
- Vary phrasings slightly
- Don't copy-paste patterns blindly
- Recalibrate on repetitive tasks

---

## The 3 Context Engineering Strategies

Based on Lance Martin's analysis of Manus architecture.

### Strategy 1: Context Reduction

**Compaction:**
```
Tool calls have TWO representations:
├── FULL: Raw tool content (stored in filesystem)
└── COMPACT: Reference/file path only

RULES:
- Apply compaction to STALE (older) tool results
- Keep RECENT results FULL (to guide next decision)
```

**Summarization:**
- Applied when compaction reaches diminishing returns
- Generated using full tool results
- Creates standardized summary objects

### Strategy 2: Context Isolation (Multi-Agent)

**Architecture:**
```
┌─────────────────────────────────┐
│         PLANNER AGENT           │
│  └─ Assigns tasks to sub-agents │
├─────────────────────────────────┤
│       KNOWLEDGE MANAGER         │
│  └─ Reviews conversations       │
│  └─ Determines filesystem store │
├─────────────────────────────────┤
│      EXECUTOR SUB-AGENTS        │
│  └─ Perform assigned tasks      │
│  └─ Have own context windows    │
└─────────────────────────────────┘
```

**Key Insight:** Manus originally used `todo.md` for task planning but found ~33% of actions were spent updating it. Shifted to dedicated planner agent calling executor sub-agents.

### Strategy 3: Context Offloading

**Tool Design:**
- Use <20 atomic functions total
- Store full results in filesystem, not context
- Use `glob` and `grep` for searching
- Progressive disclosure: load information only as needed

---

## The Agent Loop

Manus operates in a continuous 7-step loop:

```
┌─────────────────────────────────────────┐
│  1. ANALYZE CONTEXT                      │
│     - Understand user intent             │
│     - Assess current state               │
│     - Review recent observations         │
├─────────────────────────────────────────┤
│  2. THINK                                │
│     - Should I update the plan?          │
│     - What's the next logical action?    │
│     - Are there blockers?                │
├─────────────────────────────────────────┤
│  3. SELECT TOOL                          │
│     - Choose ONE tool                    │
│     - Ensure parameters available        │
├─────────────────────────────────────────┤
│  4. EXECUTE ACTION                       │
│     - Tool runs in sandbox               │
├─────────────────────────────────────────┤
│  5. RECEIVE OBSERVATION                  │
│     - Result appended to context         │
├─────────────────────────────────────────┤
│  6. ITERATE                              │
│     - Return to step 1                   │
│     - Continue until complete            │
├─────────────────────────────────────────┤
│  7. DELIVER OUTCOME                      │
│     - Send results to user               │
│     - Attach all relevant files          │
└─────────────────────────────────────────┘
```

---

## File Types Manus Creates

| File | Purpose | When Created | When Updated |
|------|---------|--------------|--------------|
| `task_plan.md` | Phase tracking, progress | Task start | After completing phases |
| `findings.md` | Discoveries, decisions | After ANY discovery | After viewing images/PDFs |
| `progress.md` | Session log, what's done | At breakpoints | Throughout session |
| Code files | Implementation | Before execution | After errors |

---

## Critical Constraints

- **Single-Action Execution:** ONE tool call per turn. No parallel execution.
- **Plan is Required:** Agent must ALWAYS know: goal, current phase, remaining phases
- **Files are Memory:** Context = volatile. Filesystem = persistent.
- **Never Repeat Failures:** If action failed, next action MUST be different
- **Communication is a Tool:** Message types: `info` (progress), `ask` (blocking), `result` (terminal)

---

## Manus Statistics

| Metric | Value |
|--------|-------|
| Average tool calls per task | ~50 |
| Input-to-output token ratio | 100:1 |
| Acquisition price | $2 billion |
| Time to $100M revenue | 8 months |
| Framework refactors since launch | 5 times |

---

## Key Quotes

> "Context window = RAM (volatile, limited). Filesystem = Disk (persistent, unlimited). Anything important gets written to disk."

> "if action_failed: next_action != same_action. Track what you tried. Mutate the approach."

> "Error recovery is one of the clearest signals of TRUE agentic behavior."

> "KV-cache hit rate is the single most important metric for a production-stage AI agent."

> "Leave the wrong turns in the context."

---

## Source

Based on Manus's official context engineering documentation:
https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus

---

## § 三击错误协议

```
第1次: 诊断 + 修复 → 读错误 → 根因 → 定点修复
第2次: 换方法   → 不同工具？不同库？绝不重复完全相同的失败操作
第3次: 全局重想 → 质疑假设 → 搜索方案 → 考虑更新计划
3次后: 升级用户  → 解释尝试 → 分享具体错误 → 请求指导
```

## § 五问重启测试

能回答以下 5 问 = 上下文可靠，可安全重启：

| # | 问题 | 答案来源 |
|---|------|----------|
| 1 | 我在哪？ | task_plan.md 当前 phase |
| 2 | 我要去哪？ | 剩余 phases |
| 3 | 目标是什么？ | plan 中的 Goal |
| 4 | 我学到了什么？ | findings.md |
| 5 | 我做了什么？ | progress.md |
| **6** | **哪些任务待处理？** | **plans/INDEX.md 待处理区** |

## § 适用场景

**用本 skill：** 多步骤任务（3+ 步）/ 调研 / 建项目 / 跨多次工具调用 / 需组织管理
**跳过：** 简单提问 / 单文件编辑 / 快速查找

---

## Chain Handoff Contract(链式交接合约,Rule 22 配套)

**核心原则**:Block 间交接通过 plan_dir/.handoff 目录 + `passes_to` / `depends_on` 字段;每个 Block 完成后,主进程必须 Read 实际产出 + 写交接 handoff,下游 Block 才能开始。

**交接合约(每次交接前必须满足)**:

```
1. 当前 block 所有 Phase = complete
2. 交接产物文件存在且 size > 0
3. 交接产物通过 verification_cmd 验证(exit 0)
4. Handoff 追踪表已更新(状态 + 完成时间)
5. 下游 block 的 status 已设为 in_progress
6. Subagent Handoff 登记表已填(若该 Block 派发了子代理)
```

**字段定义**:

| 字段 | 必填 | 说明 |
|------|------|------|
| `passes_to` | ✅ | 下一个 block 依赖的文件路径 |
| `depends_on` | ✅ | 上一个 block 的产物路径 |
| `handoff_status` | ✅ | `pending` / `in_progress` / `complete` / `blocked` |
| `verification_cmd` | ✅ | 验证交接产物合法性的命令 |

**重规划触发条件**(任一):
- 上游 block verification_cmd 失败
- 下游 block depends_on 路径不存在
- 链式交接产物 schema 不匹配
- Subagent Handoff 登记表出现连续失败(≥2 次)

**修正时间**:2026-09 修复悬空引用(SKILL.md:328 原指向 `reference.md § Handoff` 但该节不存在,本节补全)。

## Chain 模式详解（chain_mode 值语义与执行规则）

> [task-v095 P6] 自主 SKILL.md「Chain 模式详解」内敛（2026-09-29），与 Chain Handoff Contract 合约同址维护。本段定义 `chain_mode` 取值语义（single/linked/fan-out）与执行规则；交接的字段表/6 条件/重规划触发以上方「Chain Handoff Contract」节为唯一权威源，两节互补不重叠。

### linked（串行接力）

适用场景：同一任务被拆解为多 skill 接力，如 `调研 → 创作 → 发布`。

```
Block 1 (调研) complete
  → handoff: data/{site}/{id}/research/research_data.json
  → Block 2 (创作) depends_on → in_progress
  → Block 2 Phases 执行 → complete
  → handoff: data/{site}/{id}/article/article.json
  → Block 3 (发布) depends_on → in_progress
  → ...
```

**chain_mode: linked 时必须**：
- 每个 block 是独立的 Goal + Phases + VC
- `passes_to` 字段指向下一个 block 的输入文件
- 交接产物必须存在且非空，才能标记下游 block 为 in_progress

### fan-out（一对多派发）

适用场景：同一个上游产物，多个下游 skill 依次消费（派发仍串行 — Rule 21.4）。

```
Block 1 (选题) complete
  → 串行逐个派发 Block 2A → 2B → 2C（Rule 21.4 铁律）
  → 全部 complete → Block 3 (汇总)
```

**chain_mode: fan-out 时**：
- 上游 Block 完成后，所有下游 Block 状态变为 `pending`
- 每个 Block 独立执行，派发仍按 Rule 21.4 串行（互不依赖不构成并行理由）
- 汇合点需等所有下游 Block complete 后才继续

### 执行规则

1. **chain_mode 默认 `single`**：只有一个 block，不需要 chain 区块
2. **初始化时填写 chain 区块**：任务开始前根据复杂度选择模式
3. **block 之间用 `---` 分隔**：`task_plan.md` 可按 `---` 分割为多个独立 plan
4. **下游 block 的 Phase 编号可以复用**（各 block 独立计数）
