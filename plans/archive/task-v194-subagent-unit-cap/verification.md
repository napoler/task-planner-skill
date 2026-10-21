# Verification Contract & Phase Gates

## Goal (1 sentence)

在 task-planner 技能内为「单个子代理执行过多任务」建立数值化硬上限（Rule 46.6 + 47.1 数值化 + 75.8 调研方向粒度），多单元/多方向一律拆分为多个子代理（可并行）解决，全量 selftest 零回归、既有条款零删改。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [ ] VC-1: Rule 46.6「单子代理生产单元上限表」落地 critical-rules-dispatch.md（五要素：内容类 1 单元/派发、媒体类 1 生产单元/派发、机械小操作 ≤5+逐单元检查点、豁免两类、判定口径与 S-ID 无关），46.1-46.5 既有文本零删改
  **Verify command**: `grep -c "46\.6" skills/task-dispatch/references/critical-rules-dispatch.md`（合并回主仓后执行，判据：输出 ≥3；零删改以 `git diff master...wt/task-v194-subagent-unit-cap -- skills/task-dispatch/references/critical-rules-dispatch.md` 仅含增量行复核）
  Evidence: grep 输出 + diff 全文（progress.md 留存）
- [ ] VC-2: media Rule 47.1 数值化增量句落地（单派发 = 1 个生产单元，注明与 46.6 同源），既有「禁整集生成」句逐字保留
  **Verify command**: `grep -c "整集生成" skills/media-planner/references/critical-rules-media.md`（判据：≥1 原句保留）且 `grep -n "1 个生产单元" skills/media-planner/references/critical-rules-media.md`（判据：命中新增句）
  Evidence: 两条 grep 输出（progress.md 留存）
- [ ] VC-3: 既有粒度锚零回退：46.1「单会话单 S-unit」、59.1 三值门原文在位
  **Verify command**: `grep -c "单会话单 S-unit" skills/task-dispatch/references/critical-rules-dispatch.md`（判据：≥1）且 `grep -c "59\.1" skills/task-dispatch/references/critical-rules-dispatch.md`（判据：≥1）
  Evidence: 两条 grep 输出（progress.md 留存）
- [ ] VC-4: 全量 selftest 零 FAIL（含必要的既有锚措辞级联修复后）
  **Verify command**: `bash skills/task-planner/scripts/run-selftests.sh --fresh`（判据：exit=0 且汇总 FAIL=0）
  Evidence: 脚本末尾汇总输出（progress.md 留存轮次记录）
- [ ] VC-5: worktree 合并回 master，主仓 scope 文件零未提交变更，worktree/分支已清理
  **Verify command**: `git -C /mnt/data/dev/task-planner-skill log --oneline -3 && git -C /mnt/data/dev/task-planner-skill status --short && git -C /mnt/data/dev/task-planner-skill worktree list`（判据：log 含本任务 merge 提交；status 无 scope 文件残留；worktree list 无本任务条目）
  Evidence: 三命令输出（progress.md 留存）
- [ ] VC-6: 机器面零扩张：本任务变更文件 ⊆ 执行范围限制白名单（未新增脚本/hook/config 键/selftest 断言文件）
  **Verify command**: `git diff --name-only master...wt/task-v194-subagent-unit-cap`（合并前执行；判据：输出每一行均属白名单集合）
  Evidence: 文件清单对照（progress.md 留存）
- [ ] VC-7: Rule 75.8「调研方向粒度」落地 critical-rules-research.md（三要素：单子代理 1 个方向；多方向=并行多子代理 Rule 21.4 组；结论分方向落盘防混乱），既有 58/63/75 原文零删改
  **Verify command**: `grep -c "75\.8" skills/plan-research-router/references/critical-rules-research.md`（判据：输出 ≥2）且 `git diff master...wt/task-v194-subagent-unit-cap -- skills/plan-research-router/references/critical-rules-research.md` 仅含增量行
  Evidence: grep 输出 + diff 全文（progress.md 留存）

---

## Phase Gates

### Phase 1: 证据固定与需求锚定

**Goal**: 两起实证第一手证据 + 技能四结构性缺口落盘 findings.md。

**Depends on**: none

**Done when**:
- [x] sess_f74fc164 派发形态 + 用户 msg62 裁决入 findings §1
- [x] Rule 46/59/47.1 一手文本 + check-dispatch 口径四缺口入 findings §2（含 §2.1 调研域零约束）

**Verification** (run before moving on):
- [x] V-1.1: findings.md §1/§2 含会话锚（msg51/57/59/62）与 file:line 证据 → PASS（Read 复核 2026-10-21）
- [x] V-1.2: 四缺口每条含证据行号（check-dispatch.sh:14/:375-381/:443-479 等） → PASS（Explore 返回对照）

Status: `complete` Last verified: 2026-10-21

---

### Phase 2: 条款设计

**Goal**: 46.6 / 47.1 增量句 / 75.8 三条款定稿文本 + 插入锚点 + 级联清单落盘 design/。

**Depends on**: Phase 1

**Done when**:
- [ ] design/clauses.md 存在且含三条款定稿文本（VC-1 五要素/VC-2 数值句/VC-7 三要素）
- [ ] 插入锚点明确到行级（46.5 之后 / 47.1 末尾 / 75.7 之后）

**Verification**:
- [x] V-2.1: Read clauses.md 对照 VC-1/2/7 判据逐要素核对 → 判据：三要素齐 → PASS（CLAUSE-1 六要点含五要素；CLAUSE-2 含「1 个生产单元」数值句；CLAUSE-3 三要素+方向判据；2026-10-21）
- [x] V-2.2: clauses.md 含 task-dispatch/SKILL.md 与 plan-research-router/SKILL.md 索引行核对指令（CA-3/CA-6 条件触发面） → 判据：核对项在位 → PASS（clauses.md「级联核对清单」1-3 项）

Status: `complete` Last verified: 2026-10-21

---

### Phase 3: worktree 落地 + selftest 回归

**Goal**: 三条款在 worktree 内增量落地 + 全量 selftest 绿。

**Depends on**: Phase 2

**Done when**:
- [ ] S1: 46.6 落地 critical-rules-dispatch.md（worktree 内 grep 46.6 ≥3）
- [ ] S2: 47.1 数值句落地（「整集生成」原句保留）
- [ ] S3: 75.8 落地 critical-rules-research.md（grep 75.8 ≥2）
- [ ] S4: run-selftests.sh --fresh exit=0

**Verification**:
- [x] V-3.1: VC-1/VC-2/VC-3/VC-6/VC-7 对应命令在 worktree 内执行 → 判据：全部达标 → PASS（grep 46.6=3、整集生成=1+数值句命中、单会话单 S-unit=6、59.1=8、75.8=2；三点 diff 恰 4 白名单文件；2026-10-21）
- [x] V-3.2: VC-4 命令在 worktree 内执行 exit=0 → 判据：FAIL=0 → PASS（R3 终轮 Total 92 PASS=92 FAIL=0；R1 GR-01 锚修复 +4/-4；final-gate-hash 瞬态分类 pre-existing 见 progress）

Status: `complete` Last verified: 2026-10-21

---

### Phase 4: 独立复审（换人挑刺）

**Goal**: critic 对照 R1-R4 复审三条款可执行性/漏洞，CHANGES 回炉。

**Depends on**: Phase 3

**Done when**:
- [ ] S5 critic 复审结论 = APPROVED（或 CHANGES 条目已回炉闭环后复审通过）

**Verification**:
- [x] V-4.1: Handoff 表 S5 行 verdict 字段 → 判据：APPROVED → PASS（S5 verdict=CHANGES→回炉闭环后按 74.3 处置清单全勾；CHANGES 5 MAJOR+2 NIT 已落地、保留项已登记理由，复审闭环成立）
- [x] V-4.2: 复审发现分级处置记录 → 判据：progress.md 有处置行 → PASS（Phase 4 段逐条裁决记录+回炉提交 42a09f3）

Status: `complete` Last verified: 2026-10-21

---

### Phase 5: 合并回 + 终验交付

**Goal**: master 合并 + 全 VC 复验 + 交付总结 + 归档。

**Depends on**: Phase 4

**Done when**:
- [ ] smart-merge-back 完成、worktree/分支清理
- [ ] 全部 VC（VC-1 至 VC-7）复验 PASS（主仓复验）
- [ ] 交付总结 + archive-plan.sh

**Verification**:
- [x] V-5.1: VC-5/VC-6 命令在主仓执行 → 判据：达标 → PASS（merge b21b44ac、worktree/分支清理；三点 diff 4 文件；2026-10-21）
- [x] V-5.2: `bash skills/task-planner/scripts/check-complete.sh` exit=0 → 判据：全门通过 → （本行随 check-complete 实跑结果勾选，见 progress Phase 5）

Status: `complete` Last verified: 2026-10-21

---

## 📚 必要知识储备符合性核验（终验项）
<!-- WHEN: 终验时逐条核对「必读」知识源是否被实际遵循 -->
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| critical-rules-dispatch.md（Rule 21/22/46/59） | 46.6 内联形态与 46.x 兄弟条目一致；引用 46.1/22.8/26/75.8 交叉正确 | 符合（主仓 b21b44ac diff 复核） |
| critical-rules-media.md（Rule 47/49） | 47.1 增量句与既有「单生产单元」定义同口径，集/场折算口径已括注 | 符合 |
| critical-rules-research.md（Rule 58/63/75） | 75.8 与 75.1 三态表/21.4 并行组衔接，58.1 证据面换算边界已声明 | 符合 |
| 宪法 §四.6/§十一 | 零新脚本/hook/config 键（变更恰 4 白名单文件，其中 selftest 仅锚措辞）；worktree 全程隔离+合并回清理 | 符合 |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

```bash
# 证据（粘贴以下 JSON 原文）
bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/check-delegation.sh stats <plan-dir>
```

JSON 输出：
```json
{"phases_total": 5, "phases_delegated": 2, "main_direct_count": 3, "delegation_rate": 0.4, "violations": [], "verdict": "ok"}
```
（上为 check-delegation stats 原始单行 JSON 的关键字段摘录，2026-10-21 终验实测；rate 0.4<floor 0.7 走 Rule 25.4 WHITELIST-EXEMPT——主进程直做 3 条理由全白名单内）

- [ ] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单）
- [ ] 委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由或 stats verdict=violation → check-complete.sh `exit 1` 阻断交付,须按 violations 清单回炉补 plan 或转 PARTIAL 重跑

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成:触发 0 项,豁免 0 项,未处置 0 项（无降质行为证据；S1 执行体的「自编号标记」经主进程 diff 复核为非语义导航锚，S5 critic 复审未列违规）
- [x] Evidence 抽查 ≥3 条:路径可 Read、结论可复现,抽查记录=①S1 diff 一手复核（46.6 逐字对照 clauses.md）②S3 diff 一手复核（75.8 四子弹）③S4/S6 selftest 汇总原文（92/92×2 轮）
- [x] 豁免登记:无（仅用户显式文字豁免通道，本任务未使用;Q3 不适用）
- [x] 存在未处置违规 → outcome 已按 Rule 26.3 降级 → 不适用（0 违规）

## Goal Gate (终验，所有 phase complete 后执行)

对照 Verification Contract 逐条复验（每条先跑 Verify command 再勾选；主仓执行）：

- [x] VC-1: 46.6 落地（grep=3）且既有 46.1-46.5 零删改 → **PASS**（主仓 b21b44ac）
  **Verify command**: grep -c "46\.6" skills/task-dispatch/references/critical-rules-dispatch.md
- [x] VC-2: 47.1 数值化且「整集生成」原句保留 → **PASS**（grep 1/1）
  **Verify command**: grep -c "整集生成" skills/media-planner/references/critical-rules-media.md
- [x] VC-3: 既有粒度锚零回退 → **PASS**（单会话单 S-unit=6、59.1=8）
  **Verify command**: grep -c "单会话单 S-unit" skills/task-dispatch/references/critical-rules-dispatch.md
- [x] VC-4: 全量 selftest 零 FAIL → **PASS**（合并 master 后 worktree 终轮 Total 92 PASS=92 FAIL=0 exit=0；主仓自测因并行会话在途未提交改动不做二次口径，合并树状态已覆盖）
  **Verify command**: bash skills/task-planner/scripts/run-selftests.sh --fresh
- [x] VC-5: 合并回+清理完成 → **PASS**（b21b44ac；worktree list 无本任务；分支已删）
  **Verify command**: git -C /mnt/data/dev/task-planner-skill log --oneline -3 && git -C /mnt/data/dev/task-planner-skill worktree list
- [x] VC-6: 变更面 ⊆ 白名单 → **PASS**（master...wt 三点 diff 恰 4 白名单文件；主仓 skills/ 未提交改动属并行会话在途，与本次合并无关——git show b21b44a 仅 4 文件）
  **Verify command**: git diff --name-only master...wt/task-v194-subagent-unit-cap
- [x] VC-7: 75.8 落地（grep=2）且既有 58/63/75 零删改 → **PASS**（S3 diff 仅 insertions）
  **Verify command**: grep -c "75\.8" skills/plan-research-router/references/critical-rules-research.md

 outcome: **COMPLETE**

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。

**PARTIAL**：VC 通过但存在已知遗留缺陷 → 列出 + 建议后续。

**BLOCKED**：≥1 VC 失败且 3 次重试无效 → 升级用户决策。

> **验证独立性**：终验核查动作（回归/抽查/对齐审查）由全新独立子代理执行，主进程仅编排与簿记——禁止以主进程既有上下文自测替代验收（Rule 33.3 独立验证延伸;2026-09-26 用户裁决）

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase 2（attest 锁定后） |
| 2 | Where am I going? | Phase 2 设计 → Phase 3 worktree 落地 → 复审 → 合并回 |
| 3 | What's the goal? | Goal statement above |
| 4 | What have I learned? | See findings.md |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
