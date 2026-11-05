# Verification Contract & Phase Gates
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；{语义占位}/<plan-dir>=模型/调用方填写面 -->

## Goal (1 sentence)

在 task-planner 技能族建立 Rule 104「子代理使用点显式标注」机制——四载体（dispatch 规则全文/SKILL 就地速查表/模板标注列/selftest 守护）落地且标注=默认建议可微调。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.
> WT = /mnt/data/dev/task-planner-skill-worktrees/task-subagent-markup-20261105（merge 前在 worktree 验证，merge 后路径换主仓根复验）

- [ ] VC-1: Rule 104 全文在位（主条=1 且 104.1-104.6 六子条锚各 ≥1）
  **Verify command**: test "$(grep -c '^### 104 子代理使用点显式标注纪律' $WT/skills/task-dispatch/references/critical-rules-dispatch.md)" = "1" && test "$(grep -c '^104\.[1-6] \**' $WT/skills/task-dispatch/references/critical-rules-dispatch.md)" -ge "6" && echo VC1-PASS
  Evidence: 命令输出 VC1-PASS
- [ ] VC-2: SKILL.md 就地「使用点标注速查表」在位
  **Verify command**: test "$(grep -c '使用点标注速查' $WT/skills/task-planner/SKILL.md)" -ge "1" && echo VC2-PASS
  Evidence: 命令输出 VC2-PASS
- [ ] VC-3: task_plan 模板 S-unit 表「96 类别」标注列在位
  **Verify command**: test "$(grep -c '96 类别' $WT/skills/task-planner/templates/task_plan.md)" -ge "1" && echo VC3-PASS
  Evidence: 命令输出 VC3-PASS
- [ ] VC-4: selftest-subagent-activation.sh 新锚（SA-16+）全绿
  **Verify command**: bash $WT/scripts/selftest-subagent-activation.sh
  Evidence: 脚本 exit 0 输出
- [ ] VC-5: 全量 selftest 零回归（对照基线，FAIL 增量=0）
  **Verify command**: bash $WT/scripts/selftest-all.sh 2>&1 | tail -3
  Evidence: FAIL 增量=0 的汇总输出
- [ ] VC-6: 现状盘点检查点在位（8 章节+G1-G12 缺口）
  **Verify command**: test -f /mnt/data/dev/task-planner-skill/plans/task-subagent-markup-20261105/subagent-state/01-inventory.md && grep -c "^## " /mnt/data/dev/task-planner-skill/plans/task-subagent-markup-20261105/subagent-state/01-inventory.md
  Evidence: 文件存在+章节数 ≥8
- [ ] VC-7: 部署位同步 diff=0（~/.zcode/skills/ 对应文件）
  **Verify command**: diff /mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md /home/terry/.zcode/skills/task-dispatch/references/critical-rules-dispatch.md && diff /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md /home/terry/.zcode/skills/task-planner/SKILL.md && echo VC7-PASS
  Evidence: diff 空+VC7-PASS
- [ ] VC-8: 判例证据检查点在位（≥5 硬扛证据点+≥2 错误积累证据）
  **Verify command**: test -f /mnt/data/dev/statprobe/checkpoint-83f64e428b.md && test "$(grep -c '^- \*\*EP-' /mnt/data/dev/statprobe/checkpoint-83f64e428b.md)" -ge "5" && test "$(grep -c '^- \*\*ERR-' /mnt/data/dev/statprobe/checkpoint-83f64e428b.md)" -ge "2" && echo VC8-PASS
  Evidence: 命令输出 VC8-PASS

---

## Phase Gates

### Phase 1: 侦察与判例分析

**Goal**: 双检查点（盘点缺口+判例硬扛证据）在位，支撑规则设计

**Depends on**: none

**Done when**:
- [x] 01-inventory.md 8 章节在位（G1-G12 缺口）
- [x] checkpoint-83f64e428b.md ≥5 证据点+≥2 错误积累证据

**Verification** (run before moving on):
- [x] V-1.1: mapped to VC-6 → PASS（2026-11-05 检查点落盘+Read 复核）
- [x] V-1.2: mapped to VC-8 → PASS（EP-1~7 + ERR-1~5 在位）

Status: `complete` Last verified: 2026-11-05

---

### Phase 2: 设计与规则起草

**Goal**: Rule 104 六子条全文草稿+三类载体 diff 方案落盘

**Depends on**: Phase 1

**Done when**:
- [ ] rule104-draft.md 六子条全文在位
- [ ] 02-design.md 三载体 diff 方案+锚点断言清单在位

**Verification**:
- [ ] V-2.1: mapped to VC-1（草稿形态：grep 草稿文件六子条锚 ≥6）
- [ ] V-2.2: mapped to VC-2/VC-3（diff 指令含速查表+标注列具体文本）

Status: `in_progress` Last verified: —

---

### Phase 3: 载体落地（worktree）

**Goal**: 四载体 grep 命中（S1-S4 派发落地）

**Depends on**: Phase 2

**Done when**:
- [ ] 载体三 grep 判据全 PASS（主 VC 表 1-3 条）
- [ ] S4 selftest 新锚 exit 0

**Verification**:
- [ ] V-3.1: mapped to VC-1, VC-2, VC-3
- [ ] V-3.2: mapped to VC-4

Status: `pending` Last verified: —

---

### Phase 4: 验证与 Code Review

**Goal**: 全量回归零破坏 + CR APPROVED

**Depends on**: Phase 3

**Done when**:
- [ ] 全量回归 FAIL 增量=0（主 VC 表第 5 条）
- [ ] Code Reviewer APPROVED

**Verification**:
- [ ] V-4.1: mapped to VC-4, VC-5
- [ ] V-4.2: CR 结论 APPROVED 落 progress

Status: `pending` Last verified: —

---

### Phase 5: 收口合并与部署同步

**Goal**: merge back + 部署 diff=0 + 归档

**Depends on**: Phase 4

**Done when**:
- [ ] smart-merge-back 完成+主仓 Read 复验
- [ ] 部署 diff=0 + 归档完成（主 VC 表第 7 条）

**Verification**:
- [ ] V-5.1: mapped to VC-5, VC-7
- [ ] V-5.2: archive-plan.sh 执行/守卫拒绝登记

Status: `pending` Last verified: —

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

## 终验记录（2026-11-05，主仓 master 3c32cae）
- [x] VC-1 PASS（grep 主条=1 子条=6）/ VC-2 PASS（速查 grep=1）/ VC-3 PASS（96 类别 grep=2）/ VC-4 PASS（selftest 20/20 exit 0）
- [x] VC-5 PASS（全量 93/95 与基线一致，FAIL 仅 2 预存=active-plan/execution-stability）
- [x] VC-6 PASS（01-inventory.md 8 章节）/ VC-8 PASS（EP×7+ERR×5）
- [x] VC-7 PASS（zcode+claude 双部署位 diff=0，dispatch 文件级 cp 补同步——--deploy 仅覆盖 task-planner 兄弟技能已知坑，教训已登记）
- outcome 判定依据：VC-1..8 全 PASS

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 在技能族建立 Rule 104 子代理使用点显式标注机制
对照上方 Verification Contract VC-1..VC-8 逐条复验（每条执行 **Verify command** 命令）：
- [ ] 上方 VC-1..VC-8 逐条命令输出 → PASS/FAIL（结果落本文件终验区+progress）

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
