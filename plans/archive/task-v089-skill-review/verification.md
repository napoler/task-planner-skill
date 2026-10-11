# Verification Contract & Phase Gates

## Goal (1 sentence)

通过动态工作流对 skills/task-planner 做只读全面审查，产出含证据与独立验证的审查报告（只列问题不实施修复）。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: 审查报告存在且非空（4 领域分节 + 发现证据 + 确定性门结果 + 未覆盖说明）
  Evidence: `plans/task-planner-skill-review/report.md`（21864 bytes，①-⑤ 五节齐全，Read 全文复核）
- [x] VC-2: 27/27 selftest 逐一运行并汇报 Total 行；FAIL>0 脚本逐一名列
  Evidence: 工作流阶段 1 实跑 ΣPASS=453 FAIL=0（27 脚本全 rc=0，无 FAIL>0 脚本）；报告 ③ 门控表
- [x] VC-3: 每个领域有独立审计结论，每条发现带 confirmed/unconfirmed 标注
  Evidence: 报告 ② 四领域 28 条（27 confirmed + 1 unconfirmed）逐条带证据列；artifact board「已出结果」4 项
- [x] VC-4: 三文件回填 + INDEX 刷新
  Evidence: findings.md「Research Findings」含工作流结论摘要与证据；progress.md Phase 1 段已回填；INDEX 由 sync-todos.sh --index 刷新（含 task-v089 行）
- [x] VC-5: 交付结论数字与 verified 值一致
  Evidence: 报告 ① 结论「28 条（27+1）、453 断言 FAIL=0」与 ③ 门控表、run return conclusion 三处互对一致；基线 commit f926af6 标注

---

## Phase Gates

### Phase 1: 工作流执行

**Goal**: 工作流跑完 4 阶段并产出已发布报告。

**Depends on**: none

**Done when**:
- [x] 工作流 run dwfrun-133695f0 completed，报告落盘 + primary artifact 发布
- [x] conclusion/findings/verified/notCovered 四字段收取（完成通知含全量）

**Verification**:
- [x] V-1.1: 报告 Read 复核（VC-1/VC-5）
- [x] V-1.2: 发现 status 标注逐条可查（VC-3）

Status: `complete` Last verified: 2026-09-25

---

### Phase 2: 簿记回填与终验交付

**Goal**: 三文件 + INDEX 闭环，交付结论给用户。

**Depends on**: Phase 1

**Done when**:
- [x] findings/progress/verification 回填完成
- [x] INDEX 刷新 + check-complete.sh exit 0

**Verification**:
- [x] V-2.1: Read 三文件（VC-4）
- [x] V-2.2: 数字一致性终验（VC-5）

Status: `complete` Last verified: 2026-09-25

---

## 委派统计复验（Rule 25.4）

**机器统计为事实源**：本计划 2 Phase 均 Executor=主进程且登记白名单理由（Phase 1=④ 用户显式 /workflow 编排 + ③ 机械验证由工作流执行；Phase 2=② 计划簿记）→ 委派率 0 属 WHITELIST-EXEMPT（全理由命中 25.3 白名单，非白名单外直做）。
```json
{
  "phases_total": 2, "phases_subagent": 0,
  "direct": [
    {"phase": 1, "reason": "④ 用户显式 /workflow 编排（Rule 39 路由）+ ③ 机械验证命令由工作流 world.run 执行"},
    {"phase": 2, "reason": "② 计划系统文件维护"}
  ],
  "rate": 0, "verdict": "WHITELIST-EXEMPT（理由全命中 25.3 ④②）"
}
```

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成:触发 0 项,豁免 0 项,未处置 0 项
- [x] Evidence 抽查 ≥3 条:VC-1 报告 Read / VC-2 Σ453 / VC-4 三文件 Read，均可复现
- [x] 豁免登记: 无

## Goal Gate (终验)

```
## Goal Verification — 只读审查 + 证据化报告交付
- [x] VC-1: 报告 21864 bytes 五节齐全 → PASS
- [x] VC-2: 27/27 selftest Σ453 FAIL=0 → PASS
- [x] VC-3: 28 条发现全带 status 标注 → PASS
- [x] VC-4: 三文件 + INDEX 回填 → PASS
- [x] VC-5: 数字三处互对一致 → PASS

 outcome: COMPLETE
```

**遗留（报告 ⑤ 未覆盖项，非本任务 scope，登记供后续任务）**：
1. 部署位 `~/.zcode/skills/task-planner` WF-10 FAIL（3<6，相对路径解析不鲁棒）——「全绿」结论限定 as-of 仓侧
2. high 级 2 条 jq 单层路径 config 覆盖失效（subagent-fallback.sh:46-52 / check-plan-dispatch.sh:115-116）
3. Rule 12 worktree 旧路径残留、Rule 16 锚 21→22、video 类型四点同步缺口、goal-gate mini 降档未同步等文档漂移
4. 「440 键」口径应为「440 行 / properties 40 键」；「13 死键」证据不足已降级
5. v090 草案（workflow auto-activation）未运行，落地后本报告部分结论将失效
