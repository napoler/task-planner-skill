# Verification Contract & Phase Gates
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；{语义占位}/<plan-dir>=模型/调用方填写面 -->

## Goal (1 sentence)

在五类决策面（上抛裁决前/反思门/完成声称与交付/子代理派发/周期对照）落强制读取 user-session-log.md 专档对照条款（统一锚=Rule 80.8），杜绝「用户已要求过、agent 反过来问」。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [ ] VC-1: 五决策点读取条款在位——80.8 统一锚+五决策点子锚（上抛/反思门/交付/派发/周期）grep 命中
  Evidence: `grep -c "80.8" skills/task-planner/references/critical-rules.md` ≥ 2；五决策点锚 grep 各 ≥1
  **Verify command**: WT=/mnt/data/dev/task-planner-skill-worktrees/task-userlog-recall-20261105; grep -q "80.8 \*\*决策前读取纪律" $WT/skills/task-planner/references/critical-rules.md && grep -q "暂停前四问" $WT/skills/task-discipline/references/critical-rules-discipline.md && grep -q "反思门\*\*五问" $WT/skills/task-discipline/references/critical-rules-discipline.md && grep -q "前置读档门" $WT/skills/task-discipline/references/critical-rules-discipline.md && grep -q "## 消费点" $WT/skills/task-planner/templates/user-session-log.md && grep -q "专档条目#" $WT/skills/task-planner/templates/delivery-summary.md && grep -q "双锚升级（Rule 80.8④）" $WT/skills/task-planner/templates/subagent_dispatch.md && echo VC1-PASS
- [ ] VC-2: selftest-session-log.sh 扩展 SL 断言后全绿
  Evidence: selftest 输出 0 FAIL
  **Verify command**: cd /mnt/data/dev/task-planner-skill-worktrees/task-userlog-recall-20261105 && bash skills/task-planner/scripts/selftest-session-log.sh 2>&1 | tail -5
- [ ] VC-3: 全量 selftest 与 master 基线一致（零新增 FAIL，预存环境态失败按基线对照豁免并逐条登记）
  Evidence: 全量输出与 master 基线对照表落 progress.md
  **Verify command**: cd /mnt/data/dev/task-planner-skill-worktrees/task-userlog-recall-20261105 && for f in skills/task-planner/scripts/selftest-*.sh; do bash "$f" >/dev/null 2>&1 || echo "FAIL: $f"; done; echo DONE
- [ ] VC-4: 部署 3 位（zcode/claude/cursor）改动文件 diff=0
  Evidence: 部署 diff 输出为空/IDENTICAL
  **Verify command**: for f in skills/task-planner/references/critical-rules.md skills/task-planner/SKILL.md skills/task-planner/templates/user-session-log.md skills/task-planner/templates/delivery-summary.md skills/task-planner/templates/subagent_dispatch.md skills/task-planner/scripts/selftest-session-log.sh skills/task-discipline/references/critical-rules-discipline.md; do diff -q "/mnt/data/dev/task-planner-skill-worktrees/task-userlog-recall-20261105/$f" "/home/terry/.zcode/$f" || echo "DIFF: $f"; done; echo VC4-DONE
- [ ] VC-5: worktree 合并回 master + worktree/分支已清理
  Evidence: git log 含 merge commit；git worktree list 无该路径；git branch 无 wt/task-userlog-recall-20261105
  **Verify command**: cd /mnt/data/dev/task-planner-skill && git log --oneline -3 && git worktree list | grep -c task-userlog-recall || echo CLEAN
- [ ] VC-6: delivery-summary/subagent_dispatch 模板专档双锚字段在位
  Evidence: 两模板 grep 命中双锚字段
  **Verify command**: cd /mnt/data/dev/task-planner-skill-worktrees/task-userlog-recall-20261105 && grep -q "专档" skills/task-planner/templates/delivery-summary.md && grep -q "专档" skills/task-planner/templates/subagent_dispatch.md && echo VC6-PASS

---

## Phase Gates

### Phase 1: 调研缺口定位

**Goal**: user-session-log 读写面盘点+五决策点缺口清单

**Depends on**: [previous phase or "none"]

**Done when**:
- [x] 缺口清单落盘 findings+检查点复核

**Verification** (run before moving on):
- [x] V-1.1: VC-1（缺口清单即五决策点设计依据）
- [x] V-1.2: VC-4（部署对齐设计依据）

Status: `complete` Last verified: 2026-11-05（原枚举说明行，Phase 3 终态）

---

### Phase 2: 设计定稿与计划审批

**Goal**: 80.8 条款+三处扩展+变更标注表+attest 锁定

**Depends on**: Phase 1

**Done when**:
- [ ] ...

**Verification**:
- [x] V-2.1: VC-1（attest 四锚+vc-gate 6/6）
- [x] V-2.2: 变更标注表 CA-1..CA-7 登记

Status: `complete` Last verified: 2026-11-05

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

**机器统计为事实源，人工仅复核**：运行 `bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

```bash
# 证据（粘贴以下 JSON 原文）
bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats <plan-dir>
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
对照 Verification Contract 逐条复验（VCx = VC-1..VC-6 逐条替换）：
- [ ] VCx: {evidence} → PASS/FAIL
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
