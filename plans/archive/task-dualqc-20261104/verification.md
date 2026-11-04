# Verification Contract & Phase Gates
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；{语义占位}/<plan-dir>=模型/调用方填写面 -->

## Goal (1 sentence)

在 task-planner 技能层固化双轮质检与同步完整性机制（Rule 103 八子条）并同步落地规则条款、卫星接线、模板、机器守护与三部署位，全部 VC 通过即完成。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [ ] VC-1: Rule 103 八子条在 task-dispatch 卫星全文在位（含 103.6 同步完整性审查+103.4 升档映射+103.5 四要素）
  **Verify command**: test "$(grep -c '^103\.[1-8]' /mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md)" -ge 8 && grep -q '同步完整性' /mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md && grep -q '核对清单' /mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md
  Evidence: grep 输出+条款文本（findings/progress 引用行号）
- [ ] VC-2: 双向接线在位（verification-gate 84.7 含 Rule 103 指针；task-dispatch 96 区含复检升档衔接）
  **Verify command**: grep -q 'Rule 103' /mnt/data/dev/task-planner-skill/skills/verification-gate/references/critical-rules-verification.md && grep -q 'Rule 103' /mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md
  Evidence: grep 命中行
- [ ] VC-3: 模板承载在位（subagent_dispatch.md 含自审+复检段；§7 八字段契约字面零改动）
  **Verify command**: grep -q '双轮质检' /mnt/data/dev/task-planner-skill/skills/task-planner/templates/subagent_dispatch.md && grep -q '第一轮' /mnt/data/dev/task-planner-skill/skills/task-planner/templates/subagent_dispatch.md && grep -q '第二轮' /mnt/data/dev/task-planner-skill/skills/task-planner/templates/subagent_dispatch.md
  Evidence: grep 命中行+git diff 显示 §7 区零改动
- [ ] VC-4: SKILL.md 接线与计数随动（1-103/86 条/枚举含 103/循环与终验指针）
  **Verify command**: grep -q '1-103' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && grep -q '其余 86 条' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md
  Evidence: grep 命中行
- [ ] VC-5: 守护脚本在位且自证（selftest-dual-qc.sh exit 0+registry 登记行=1）
  **Verify command**: bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-dual-qc.sh && test "$(grep -c 'selftest-dual-qc' /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-registry.tsv)" -eq 1
  Evidence: 脚本输出 exit 0+grep 计数
- [ ] VC-6: 全量回归零 FAIL（fresh run-selftests ΣFAIL=0；worktree 与合并后主仓各跑一次）
  **Verify command**: cd /mnt/data/dev/task-planner-skill/skills/task-planner/scripts && bash run-selftests.sh 2>&1 | tail -5
  Evidence: 两次运行输出（progress.md 粘贴，ΣFAIL=0 判据）
- [ ] VC-7: 三部署位同步（zcode/claude/cursor 与源仓变更文件 diff 全空；zcode/claude push 后 ahead=0）
  **Verify command**: git -C /mnt/data/dev/task-planner-skill diff --name-only 7d48161..HEAD -- skills/ | while read f; do for d in ~/.zcode ~/.claude ~/.cursor; do diff -q "$d/skills/${f#skills/}" "/mnt/data/dev/task-planner-skill/$f" || exit 1; done; done && echo DEPLOY-DIFF-ZERO
  Evidence: DEPLOY-DIFF-ZERO 输出+两 git 位 push 回执
- [ ] VC-8: master 合并在位且隔离区清理（merge commit+worktree 清理+103=landed）
  **Verify command**: git -C /mnt/data/dev/task-planner-skill log --oneline -5 | grep -qi 'task-dualqc' && test -z "$(git -C /mnt/data/dev/task-planner-skill worktree list | grep task-dualqc)" && grep -q '"rule":103.*"landed"' /mnt/data/dev/task-planner-skill/plans/.rule-reservations.jsonl
  Evidence: git log+worktree list+账本行
- [ ] VC-9: 同步完整性审查条款在位（103.6 含每轮触发+关联面推导+核对清单+多文件强制）
  **Verify command**: grep -q '103.6' /mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md && grep -q '关联面' /mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md
  Evidence: 103.6 子条文本
- [ ] VC-10: 同步审查模板承载（复检任务书含同步核对清单输入项；task_plan 模板含同步完整性声明）
  **Verify command**: grep -q '同步核对清单' /mnt/data/dev/task-planner-skill/skills/task-planner/templates/subagent_dispatch.md && grep -q '同步完整性' /mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md
  Evidence: grep 命中行
- [ ] VC-11: 新指令统一收口序列在位（SKILL.md 用户新指令处理段：落盘→判定→计划同步→S5→103.6 衔接定序；既有表行零删改）
  **Verify command**: grep -q '统一收口序列' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && grep -A6 '统一收口序列' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md | grep -q 'user-session-log' && grep -A6 '统一收口序列' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md | grep -q '103'
  Evidence: SKILL.md 该段文本

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

终验时对照上方 Verification Contract（VC-1..VC-11，Verify command 已内联）逐条复验，证据与结论登记于下表：

| VC | 证据（路径/命令输出锚） | PASS/FAIL |
|----|------------------------|-----------|
| VC-1 | master grep `^103\.[1-8]`=8；同步完整性/核对清单命中 | PASS |
| VC-2 | vg 'Rule 103'=1；dispatch 96 区衔接=1+103 块内=2 | PASS |
| VC-3 | 派发模板 '### 3b. 双轮质检与同步完整性'=1；§7 八字段区 git diff 零改动 | PASS |
| VC-4 | SKILL.md '1-103'=3、'其余 86 条'=2、'3h 双轮质检（Rule 103）'=1 | PASS |
| VC-5 | selftest-dual-qc.sh rc=0 PASS=14 FAIL=0；registry 行=1 | PASS |
| VC-6 | worktree 95/95 + master 95/95（Total: 95 PASS=95 FAIL=0 两次） | PASS |
| VC-7 | 三部署位 9 文件 diff 全空（DEPLOY-GATE-DONE）；zcode push 011435f；claude push 003b5c8；两仓 skills/ status=0 | PASS |
| VC-8 | master merge 1e705db；worktree removed+分支 deleted；账本 `{"rule":103,"status":"landed"}` | PASS |
| VC-9 | dispatch 103.6 子条+关联面推导四族+核对清单门 | PASS |
| VC-10 | 派发模板 '同步核对清单（103.6）'=1；计划模板 '同步完整性声明'=1 | PASS |
| VC-11 | SKILL.md '统一收口序列'=1，其后含 user-session-log 与 103.6 衔接；A/E 类分支澄清在位 | PASS |

 outcome: COMPLETE

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
