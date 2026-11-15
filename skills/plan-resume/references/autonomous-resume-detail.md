# plan-resume 自主推进详细参考（§7 展开）

> 从 `SKILL.md` §7 拆分的详细内容，供需要完整契约/配置/框架时查阅。权威行为契约以本文件与 `SKILL.md` §7 摘要一致为准；`config.json` 为阈值真源。

## 7.2 配置（config.json，与 SKILL.md 同目录）

```json
{
  "autonomous_resume": true,
  "max_auto_plans_per_trigger": 1,
  "cross_project_auto_resume": false,
  "skip_states": ["blocked", "hold", "user-vetoed"],
  "fresh_threshold_days": 7,
  "max_failure_count": 3
}
```

| 键 | 默认 | 说明 |
|----|------|------|
| `autonomous_resume` | `true` | 自主推进总开关（false=退回全 dry-run） |
| `max_auto_plans_per_trigger` | `1` | 单次触发自主续推上限，禁止调大 |
| `cross_project_auto_resume` | `false` | **禁止改 true**——跨仓候选永远只报告（宪法 §五 P0） |
| `skip_states` | blocked/hold/user-vetoed | 硬排除，不参与打分；`[awaiting-user]` **不在内**（v0.6 按 §7.10 自主裁决） |
| `fresh_threshold_days` | `7` | age 上限 |
| `max_failure_count` | `3` | Error Log 失败数上限，≥N 过滤 |

脚本读取：`select-and-resume.sh` 解析同目录 `config.json`（缺文件/缺键用默认值，不报错）。

## 7.3 智能打分公式（v0.5 沿用）

```
importance_score(plan) =
    0.5 × normalize(out_degree(plan), 0..max)
  + 0.3 × normalize(git_keyword_hits(plan), 0..max)
  + 0.2 × normalize(max(0, 5 - failure_count) / 5)
```

- **out_degree(50%)**：`block_id`/task_id 被其他 plan `depends_on` 引用次数。
- **git_keyword_hits(30%)**：Goal 前 5 关键词在最近 7d `git log --oneline -i` 命中数。
- **failure 反比(20%)**：`failure_count` 来自 progress.md Error Log；≥3 次直接过滤。

## 7.4 候选过滤（必须全部满足）

| 条件 | 来源 | 不通过动作 |
|------|------|-----------|
| age ≤ `fresh_threshold_days` | `git log -1 --format=%ct`，untracked 用 mtime | 跳过 |
| `all_complete = 0` | 含 pending/in_progress | 跳过 |
| 无 `skip_states` 标记 | Status/标签 blocked/hold/user-vetoed | **硬排除**（`[awaiting-user]` 不排除，§7.10） |
| 非脚手架垃圾 | Goal 段含 `[一句话`/`$SITE`/`$ID`/`$RUNTS` 字面 | **硬排除** `skip: scaffold-garbage` |
| `failure_count < max_failure_count` | Error Log | 跳过 |
| 位于 `--repo-root` 仓内 | 扫描源仓内 | 硬排除（跨项目只报告） |
| 无 `[auto-pushed-by-cron]` | 防重入 | 跳过 |
| 无 `[circuit-break-by-cron]` | 防熔断 | 跳过 |
| `## Goal` 存在 | Read 头 30 行 | CIRCUIT-BREAK |

## 7.5 推进纪律（circuit-break 一律熔断）

- 单次触发最多 `max_auto_plans_per_trigger`(=1) 个 plan。
- 推进前 Read 头 30 行确认 Goal 不变。
- 推进 = plan 头部写 `<!-- [auto-pushed-by-cron: <ts> mode=auto-resume score=<N>] -->`。
- 选中后调用方立即续推：Read 三文件 → 下一 pending Phase → 按 task-planner 协议执行；不得改 Goal/VC/范围。
- 途中决策点一律自主裁决（§7.10），禁止停车等用户。
- **circuit-break 触发**（任一）：Phase 推进连续失败 ≥2 次；子代理 30min 无产物；P0 投毒哨兵触发；推进时检测 Goal 被人工改向 → 停止并写 `[circuit-break-by-cron: <reason>]`。
- **不做**：不替用户 archive/drop；不读改 `/tmp`、`config/`、`.env*` 等非 plans/ 文件；不中途开新计划。

## 7.6 报告输出

`.zcode/plans/plan-resume-report-<YYYYMMDD-HHMM>.md` 包含：扫描/候选/Top 1 score、候选 Top 列表（完整 score 细节）、推进模式、推进结果（标记/跳过/circuit-break）、自主裁决清单（§7.10：裁决内容/依据/回滚路径）。

## 7.7 与旧契约的兼容性

| 调用方 | 默认行为 | v0.5 影响 |
|--------|----------|------|
| task-planner Rule 24 执行中被动扫描 | dry-run | 不变 |
| 会话启动/恢复指令/交付终态后 | 自主续推 Top 1（config 开） | 变更：旧版 dry-run 等点名 |
| 用户调 Skill 且指明“只扫不动” | dry-run | 不变 |
| cron `automation-ae80e75d` / `--auto-push` | auto-push | 沿用 |
| `--dry-run` / `autonomous_resume: false` / “不要自动续推” | 只报告 | 可整体退回 v0.4 |

## 7.8 已知风险与缓解

| 风险 | 缓解 |
|------|------|
| 误推 stale plan | 用 `git log` 真实时间；untracked 用 mtime 但记录 |
| 与 article-update cron 抢 plan | Read 头 30 行 + `[auto-pushed-by-cron]` 防重入 |
| 接管用户故意搁置计划 | `skip_states` 排除 blocked/hold/user-vetoed；口头逃生 |
| 自主裁决误判 | §7.10 四项测试（T1 一票否决）；记录依据+回滚；否决→`[user-vetoed]`+还原；连续误判≥2→circuit-break |
| 撤回 auto-push 授权 | 删 `[auto-pushed-by-cron]` 或 config 关总开关 |
| score 选错 plan | 单次 1 个，失败 circuit-break，下次重评估 |
| Goal 需重定义 | §7.10 合法停点：STOP + `[awaiting-user]`（或精确授权包） |
| `[auto-pushed]` 标记长期残留 | Phase complete 时由调用方清理 |

## 7.9 用户决策记录（摘要）

改 skill 文件；重要度优先综合加权；单次≤1；circuit-break 熔断；打分 out_degree50%+git_hits30%+失败反比20%。v0.5（2026-09-05）恢复触发点默认自主；v0.6（2026-09-06）途中决策点 §7.10 自主裁决、`[awaiting-user]` 移出 skip_states、归档限已交付/垃圾脚手架逐条关账（用户原话见 SKILL.md §7.9/v0.6 决策表）。

## 7.10 自主决策框架（v0.6，四项测试 + 裁决/记录/停点）

自主续推遇 HANDOFF「待你决策」/「待你授权」/二选一/`[awaiting-user]`：**不停车、不问用户**，四项测试全 PASS → 裁决、执行、记录，继续至交付。

### 四项测试（任一 FAIL → 合法停点）

| # | 测试 | PASS | FAIL 示例 |
|---|------|------|-----------|
| T1 | 可逆性 | 有文档化回滚路径（备份/软状态/draft|archive/git revert/可移回） | 物理删除、trash 清空、凭据轮换、硬删、不可逆 schema |
| T2 | 范围 | 落在计划执行范围限制内且服务 Goal | 超 scope/跨站点/改正文越权 |
| T3 | 宪法 P0 | 不写保护区、不涉凭据、不跨项目 | 保护区一行 diff 仍停；技能无法自我授权 |
| T4 | 先例一致性 | 与用户既有裁决/显式反馈不冲突 | 否决过批量却选批量 |

### 裁决优先级

1. 用户先例（memory/Decisions Made）；2. 数据判据；3. 保守可逆（软下架>删除、draft>publish、备份后改>直接改、少动>多动）。

### 记录义务（缺一=违规）

三处落盘：① 计划 `Decisions Made`（裁决+理由+回滚路径）② progress.md 动作留痕 ③ 报告 §7.6「自主裁决清单」。用户否决 → `[user-vetoed]` + 按回滚还原。

### 唯一合法停点

1. 宪法 P0（T3 FAIL）— 停并交付「精确授权请求包」（待改文件+一行 diff+理由）。
2. Goal/VC 需重定义。
3. circuit-break（§7.5）。
4. 用户本轮喊停。

> 停止≠空手停：交付已完成裁决清单，停点项打包最小决策请求。禁止把 T1/T2/T4 可判定决策包装成“待用户确认”。
