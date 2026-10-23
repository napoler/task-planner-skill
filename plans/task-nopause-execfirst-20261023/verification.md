# Verification Contract & Phase Gates

## Goal (1 sentence)

在 task-planner 技能族制度化泛化"执行优先/非必要暂停禁令"纪律（新增 Rule 95），修正视频与图片生成执行体的额度预询问与决策推诿条款，纪元级联回归绿并同步部署位。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [ ] VC-1: Rule 95 七子条全文落位 skills/task-discipline/references/critical-rules-discipline.md（95.0-95.6，锚 token：Rule 95/执行即探测/时间衰减/暂停前三问）
  Evidence: 两 grep 计数输出均 ≥1（合并 master 后于主仓执行，输出原文落 progress.md）
  **Verify command**: grep -c "Rule 95" skills/task-discipline/references/critical-rules-discipline.md && grep -c "95\.4" skills/task-discipline/references/critical-rules-discipline.md && grep -c "暂停前三问" skills/task-discipline/references/critical-rules-discipline.md
- [ ] VC-2: video-generation-executor.md 无额度预询问/停等措辞，含执行即探测语义
  Evidence: 旧措辞 grep=0 且新锚 grep≥1（输出原文落 progress.md）
  **Verify command**: ! grep -qE "是否有额度|询问.{0,12}额度|额度.{0,12}询问" skills/task-planner/companion/agents/video-generation-executor.md && grep -q "执行即探测" skills/task-planner/companion/agents/video-generation-executor.md
- [ ] VC-3: image-generation-executor.md 含质检处置自主化条款（处置自主/禁推给用户锚）
  Evidence: 两锚 grep 均命中（输出原文落 progress.md）
  **Verify command**: grep -q "处置自主" skills/task-planner/companion/agents/image-generation-executor.md && grep -q "推给用户" skills/task-planner/companion/agents/image-generation-executor.md
- [ ] VC-4: 纪元级联完成且全量 selftest 套件 ΣFAIL=0
  Evidence: 套件运行输出原文落 progress.md（Rule 57 轮次记录）
  **Verify command**: fail=0; for f in skills/*/scripts/selftest-*.sh scripts/selftest-*.sh; do [ -f "$f" ] || continue; bash "$f" >/dev/null 2>&1 || { fail=$((fail+1)); echo "FAIL $f"; }; done; [ "$fail" -eq 0 ]
- [ ] VC-5: 部署位（smart-merge-back --deploy 登记位）与源仓 diff=0
  Evidence: diff 复核输出为空，落 progress.md（zcode 位主命令；cursor 等位按 Phase 1 映射冻结于 V-5.2）
  **Verify command**: diff -rq /mnt/data/dev/task-planner-skill/skills/task-planner /home/terry/.zcode/skills/task-planner -x .backup -x __pycache__ | wc -l | grep -q "^0$"
- [ ] VC-6: rule-reserve 编号账本 land 95
  Evidence: jsonl 含 landed 行（grep 输出原文落 progress.md）
  **Verify command**: grep '"rule":95.*"status":"landed"' plans/.rule-reservations.jsonl

---

## Phase Gates

### Phase 1: 发现与映射

**Goal**: 承载体/纪元锚/部署位全部映射成冻结清单，供 Phase 2/3 消费。

**Depends on**: none

**Done when**:
- [ ] 检查点四节齐（执行体措辞面/规则锚面/纪元锚行清单/部署位映射），每节含路径+行号
- [ ] findings.md 载体表回填

**Verification** (run before moving on):
- [ ] V-1.1: 检查点文件存在且四节非空（→ VC-4 输入完备）
- [ ] V-1.2: `grep '"rule":9[45]' plans/.rule-reservations.jsonl` 确认 95 空闲（→ VC-6 前置）

Status: `complete` Last verified: 2026-10-23（V-1.1 检查点四节 PASS；V-1.2 账本 95 reserved PASS）

---

### Phase 2: Rule 95 文本定稿+变更标注

**Goal**: Rule 95 七子条写入 worktree discipline 文件；两执行体改写精确 diff 冻结进变更标注表。

**Depends on**: Phase 1

**Done when**:
- [ ] worktree 内 discipline 文件含 Rule 95 全文
- [ ] CA-1..CA-n 变更标注表填毕（含执行体精确前后文）

**Verification**:
- [ ] V-2.1: `grep -c "Rule 95" <worktree>/skills/task-discipline/references/critical-rules-discipline.md` ≥1（→ VC-1）
- [ ] V-2.2: 变更标注表每行有精确替换文本（→ VC-2/VC-3 方案冻结）

Status: `pending` Last verified: —

---

### Phase 3: 执行体修正+纪元级联

**Goal**: 两执行体按冻结 diff 改写；纪元锚清单行 1-94→1-95。

**Depends on**: Phase 2

**Done when**:
- [ ] S1/S2/S3 子代理产出 Read 复核通过
- [ ] 旧锚残留=0（冻结清单范围）

**Verification**:
- [ ] V-3.1: VC-2/VC-3 grep 命令在 worktree 内执行通过（命令于 Phase 2 定稿后冻结在此行）
- [ ] V-3.2: `grep -rn "1-94" <worktree>/scripts/*.sh | grep -v "历史\|1-940\|1-94[0-9]"` 仅余登记豁免行（→ VC-4 输入）

Status: `pending` Last verified: —

---

### Phase 4: 回归+CR

**Goal**: 全量 selftest ΣFAIL=0；CR APPROVED。

**Depends on**: Phase 3

**Done when**:
- [ ] 套件输出 ΣFAIL=0 落 progress
- [ ] CR APPROVED 留痕

**Verification**:
- [ ] V-4.1: selftest 套件入口命令 exit 0（→ VC-4）
- [ ] V-4.2: `grep '"rule":95' plans/.rule-reservations.jsonl`（→ VC-6）

Status: `pending` Last verified: —

---

### Phase 5: 合并部署与簿记

**Goal**: master 合并+部署位同步 diff=0+账本 land+归档。

**Depends on**: Phase 4

**Done when**:
- [ ] merge commit 入 master；worktree/分支清理
- [ ] 部署位 diff=0 复核留痕

**Verification**:
- [ ] V-5.1: VC-1/VC-2/VC-3 grep 命令在主仓重跑通过（→ 终验）
- [ ] V-5.2: VC-5 diff 复核为空（→ 终验）

Status: `pending` Last verified: —

---

## 📚 必要知识储备符合性核验（终验项）
<!-- WHEN: 终验时逐条核对「必读」知识源是否被实际遵循 -->
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
|           |                      |                     |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

```bash
# 证据（粘贴以下 JSON 原文）
bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/check-delegation.sh stats <plan-dir>
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

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — {Goal 语句}
对照 Verification Contract 逐条复验：
- VC-1: {evidence} → PASS/FAIL
- VC-2: {evidence} → PASS/FAIL
...

 outcome: COMPLETE / PARTIAL / BLOCKED
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。

**PARTIAL**：VC 通过但存在已知遗留缺陷 → 列出 + 建议后续。

**BLOCKED**：≥1 VC 失败且 3 次重试无效 → 升级用户决策。

> **验证独立性**：终验核查动作（回归/抽查/对齐审查）由全新独立子代理执行，主进程仅编排与簿记——禁止以主进程既有上下文自测替代验收（Rule 33.3 独立验证延伸;2026-09-26 用户裁决）

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase N |
| 2 | Where am I going? | Remaining phases |
| 3 | What's the goal? | Goal statement above |
| 4 | What have I learned? | See findings.md |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
