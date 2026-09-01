<!-- cost_log.md — Opus 调用成本日志模板(v2.1 Rule 17.8 配套) -->

# Opus 调用成本日志

> 每次 opus 档 Skill 调用 / 主进程 opus 计算 / 嵌套 opus 都记一行。
> 主进程在 PostToolUse hook 检测到 opus 类调用时自动追加;用户也可手工补充。
> 详见 `references/cost-control.md` §四 + critical-rules.md Rule 17.5。

---

## 调用记录

| # | 时间 | 类型 | 触发点 | 累计 opus 调用 | 备注 |
|---|------|------|--------|--------------|------|
| 1 | 09:00 | 主会话 | task-planner 启动 | 1 | 主进程烧 1 次（必烧） |
| 2 | 09:15 | Skill("code-review") | Phase 3 complete | 2 | 嵌套 opus（Rule 17.1 第 1 次） |
| 3 | 09:20 | Agent(code-assistant) | 修改 src/foo.ts | 2 | haiku-1，不计入 opus 累计 |
| 4 | 09:25 | Skill("task-drift-guard") | 每 2-3 todo | 2 | haiku，不计入 |
| 5 | 09:30 | Skill("code-review") | Phase 4 complete | 3 | 嵌套 opus（Rule 17.1 第 2 次，⚠️ 节流警告） |
| ... | ... | ... | ... | ... | ... |

**opus 类型枚举**:
- 主会话：`main_session`（每次会话 +1）
- 嵌套 Skill：列出 Skill 名（如 `code-review` / `systematic-debugging` / `brainstorming` / `writing-plans` / `comet-*`）
- subagent 升级：`complex-problem-solver upgrade`（3-strike 触发）
- 嵌套 opus Skill 触发时同时记录同 phase 累计次数（Rule 17.1）

---

## 累计统计

- 本会话 opus 调用总数：**N 次**
- 是否触发门控（≥10）：**yes / no**
- 嵌套 opus Skill 占比：**M / N × 100%**
- 主要 opus 来源：主会话 / 嵌套 skill / subagent 升级

---

## 节流建议（Rule 17 自检）

- [ ] 嵌套 skill 累计 >5 次 → **拆 phase**（每 phase 内嵌套 opus ≤1 次）
- [ ] 单 phase opus 累计 >3 次 → **派 subagent 替代**（沿用 §子代理路由与模型分级）
- [ ] 单会话累计 ≥10 次 → **询问用户**「继续 / 拆型 / 降级」(Rule 17.5)
- [ ] 重复 plan-writer 调用 → **复用 Decisions Made**（Rule 17.3）

---

## 历史会话对比（可选）

| 会话日期 | opus 总数 | 主要来源 | 节流效果 |
|---------|---------|---------|---------|
| 2026-09-01 | 12 | 嵌套 skill 7 次 | 未触发 Rule 17.5,但单 phase >3 |
| 2026-09-02 | 6 | 嵌套 skill 2 次 | 良好,节省约 50% |
| ... | ... | ... | ... |

---

## 关联文档

| 文档 | 用途 |
|------|------|
| `references/cost-control.md` | 完整成本控制策略 + 模型档位映射 |
| `references/critical-rules.md` | Rule 17 八条款（核心载体） |
| `references/billing.md` | 子代理成本估算表 |
| `agents/plan-writer.md` | `cost_estimate` 字段定义 |

