# Verification Contract & Phase Gates

## Goal (1 sentence)

[One sentence describing the end state — must be objectively verifiable]

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [x] VC-1: Rule 28 成文（28.1-28.5）含 D6 不可豁免
  Evidence: skills/task-planner/references/critical-rules.md:216-222（### 28 标题 :216，28.1-28.5 各 1 行，D6「两模式一致,不可静默豁免」:219）
- [x] VC-2: SKILL.md 联动 ≥3 处 Rule 28
  Evidence: grep "Rule 28" SKILL.md = 5（:80 计划确认门 silent 分支 / :149 fix-phase / :280 摘要行 / :291 I/O 契约 / :384 兜底⑤行 P1 轮补）
- [x] VC-3: resolve 解析链 + selftest ≥7 用例
  Evidence: `bash skills/task-planner/scripts/selftest-interaction.sh` = Total: 10 PASS=10 FAIL=0 EXIT=0（两遍一致）；resolve 对真实 v062 计划输出 `silent`、对模板占位行输出 `ask`、非法值 `banana` stderr 97B 诊断行
- [x] VC-4: 无回归
  Evidence: 全量 6 套 selftest 106/0（active-plan 13/delegation 38/dispatch 18/fallback 21/interaction 10/plan-dispatch 6）全 EXIT=0；lib/verify.sh 中性 CWD /tmp → 25 pass / 0 fail ×3
- [x] VC-5: 联动完整
  Evidence: 模板 task_plan.md:28 + plan-writer.md:130 + README:119「常用键 19 项」各含 interaction_mode 行，grep 三文件各 =1；宽口径扫描（"模式|询问|AskUser"6 文件）无失效引用
- [x] VC-6: 合并回 + 部署对账
  Evidence: merge commit `b0da240`（--no-ff，8 文件 +256/-4）；worktree remove + branch -d 无残留；3 部署位 diff -rq IDENTICAL + verify 25/0×3 + 部署位 selftest-interaction 10/10 & delegation 38/38；plan-writer zcode 位 md5 f9a55d9a 与 canonical 逐字节一致，claude 位仅 model 行（sonnet）
- [x] VC-7: 隔离与簿记
  Evidence: 全程 worktree 隔离（§十一），Rule 27 逐 Phase 提交（95966c9/063f988/b82f2be/f7e2a14/58ae695/16f051b/b0da240），Handoff 表 4 行（02/05/07/08/09/10 检查点），attest SHA 重锁


---

## Phase Gates

### Phase 1: {Name}

**Goal**: [1 sentence, what this phase produces]

**Depends on**: [previous phase or "none"]

**Done when**:
- [ ] {objective completion condition}

**Verification** (run before moving on):
- [ ] V-1.1: [mapped to VC-? or custom]
- [ ] V-1.2: [mapped to VC-? or custom]

Status: `pending` / `in_progress` / `complete` / `FAILED(3-strike)` Last verified: [date]

---

### Phase 2: {Name}

**Goal**: ...

**Depends on**: Phase 1

**Done when**:
- [ ] ...

**Verification**:
- [ ] V-2.1: ...
- [ ] V-2.2: ...

Status: `pending` Last verified: —

---

### Phase 3: {Name}

...

---

## 📚 必要知识储备符合性核验（终验项）
<!-- WHEN: 终验时逐条核对「必读」知识源是否被实际遵循 -->
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
|           |                      |                     |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash <skill>/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

```bash
# 证据（粘贴以下 JSON 原文）
bash <skill>/scripts/check-delegation.sh stats <plan-dir>
```

JSON 输出：
```json
{粘贴 stats 命令原文输出}
```

- [ ] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单）
- [ ] 委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由或 stats verdict=violation → check-complete.sh `exit 1` 阻断交付,须按 violations 清单回炉补 plan 或转 PARTIAL 重跑

## 质量门控统计（Rule 26）
- [ ] Q1-Q6 逐项核查完成:触发 __ 项,豁免 __ 项,未处置 __ 项
- [ ] Evidence 抽查 ≥3 条:路径可 Read、结论可复现,抽查记录 __
- [ ] 豁免登记:项号/范围/理由/日期 __ (仅用户显式文字豁免;Q3 不适用)
- [ ] 存在未处置违规 → outcome 已按 Rule 26.3 降级;Q3 → BLOCKED + STOP

## Goal Verification — 交付 interaction-modes 双模式机制 + 联动 + 重部署
对照 Verification Contract 逐条复验（见上方 VC-1..7，全部 [x] 通过）

outcome: COMPLETE

已知遗留（PARTIAL 级，均非 v062 引入或 P0 阻断，登记不阻塞交付）:
- ① plan-resume@.zcode 历史缺位（companion 6 位中 5 位，非 v062 引入）
- ② P1 轮 P2-① 残留：env 层（①）非法值仍静默降级无 stderr 诊断，与 ② 层新增诊断不对称（LOW）
- ③ 2 条 P3 未改：selftest run_case 冗余 local num / assert 重复编号
建议后续轮：上述 ①②③ 排 task-v063 一并收口；interaction_mode 键接入 check-complete.sh 终验的自动静默决策清单校验（当前靠主进程人工核对 Decisions 表 silent: 行）

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| findings.md Rule 28 设计段 | 28.1-28.5 逐字对照 critical-rules.md:216-222 | 符合 |
| config.json 键范式 | interaction_mode 键 enum/default 与 README 说明对照 | 符合 |
| memory task-planner-repo-deploy-flow.md | 3 部署位 + plan-writer agent 2 位对齐口径 | 符合（本次复现） |
| task-v061 同构先例 | Phase 结构 + 合并回合约 | 符合 |

## 委派统计复验（Rule 25.4）
机器统计（`bash <skill>/scripts/check-delegation.sh stats <plan-dir>`）：

```json
{
  "phase_total": 9,
  "subagent_phases": 4,
  "main_process_phases": 5,
  "delegation_rate": 0.44,
  "delegation_rate_floor": 0.7,
  "main_process_reasons": [
    "Phase 1: 白名单① git/worktree 编排 + ③ 机械验证",
    "Phase 5: 白名单③ 机械验证（selftest 主进程复跑）",
    "Phase 7: 白名单③ 机械验证（code-runner-agent mini 套件全量自测）",
    "Phase 8: 白名单① 合并回主仓 + worktree 清理",
    "Phase 9: 白名单② 计划系统文件维护（verification/INDEX/attest/ledger）"
  ],
  "verdict": "WHITELIST-EXEMPT"
}
```

- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单）
- [x] 委派率 0.44 < 0.7 floor，但 5 项直做理由全命中白名单 ①②③ → WHITELIST-EXEMPT 放行（Rule 25.4a，jq 缺失 fail-closed 不适用因本机 jq 在位）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成：触发 2 项（Q5 委派率 < floor + 白名单全命中；Q6 簿记漏回滚 Phase 3/4 已 17:35 补记），豁免 0 项，未处置 0 项
- [x] Evidence 抽查 ≥3 条：critical-rules.md:216 Rule 28 标题可 Read / resolve-interaction-mode.sh 对真实计划输出 silent 可复现 / 3 部署位 diff -rq IDENTICAL 可复现（抽查记录 progress.md Phase 7/8 段）
- [x] 豁免登记：无
- [x] 无未处置违规，outcome 维持 COMPLETE（非 PARTIAL/BLOCKED）



---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase 9 complete（全部 Phase done） |
| 2 | Where am I going? | 交付；遗留 ①②③ 排后续轮 |
| 3 | What's the goal? | 双模式机制 + 联动 + 重部署 |
| 4 | What have I learned? | See findings.md |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区（task-v062 已完成，plan-resume@.zcode 缺位 = 遗留） |
