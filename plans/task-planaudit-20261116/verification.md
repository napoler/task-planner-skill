# Verification Contract & Phase Gates

## Goal (1 sentence)

在 task-planner 技能中落地“L1+ 计划产出后、D1 前独立子代理审计迭代通过”门控，并以增量文本条款将“未经审计产出禁交用户”原则（已识别覆盖面非穷尽，未列面默认简版复核）映射贯彻到计划、执行产物、终验、报告/裁决等全流程审核面。

---

## Verification Contract (≥5 items, objective standards)

> All must pass for goal to be COMPLETE. 每条 VC 的 **Verify command** 为可执行纯命令（退出码判据，禁占位/禁真空/须引用本 VC 产出物）。VC-1/2/3 采用判别性专有 token + 基线负断言记录（基线=改动前 grep 0，见 findings.md “VC 判别性基线”）。

- [ ] VC-1: 计划审计门落地（判别性）——SKILL.md 在智能子动作完成后、D1 展示前插入 `计划独立审计门`（L1+ 强制，mini/L0/trivial 轻量复核或登记豁免，L0-E 豁免），独立子代理审计 APPROVED 后方可进入 D1；含再展示简版审计、44.3 不适用、审计体降级链
  Evidence: `skills/task-planner/SKILL.md` 审计门步骤段落与 D1 前置条件；`plans/task-planaudit-20261116/findings.md` 基线负断言
  **Verify command**: `grep -n "计划独立审计门" /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md`
- [ ] VC-2: 审计迭代闭环与留痕落地——达标=0 CRITICAL 且 0 IMPORTANT 且连续一轮零新发现（新发现=新增 CRITICAL/IMPORTANT；WARNING/QUESTION/NIT 留档不阻断）⇒APPROVED，否则 REJECTED（审计体出具，主进程只登记）；固定留痕 `progress.md [plan-audit-R<N>]`（轮次/审计体/结论/问题清单/修复对照）；升级出口与 R1 首例在位
  Evidence: `skills/task-planner/SKILL.md` 迭代与留痕文本；`plans/task-planaudit-20261116/progress.md` `[plan-audit-R1]`
  **Verify command**: `grep -n "\[plan-audit-R1\]" /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/progress.md && grep -n "REJECTED" /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/progress.md && grep -n "plan-audit-R" /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md`
- [ ] VC-3: 全流程“未经审计产出禁交用户”原则落地——`audit-before-delivery` 总则映射已识别覆盖面（非穷尽：计划/执行产物 Rule 103/终验 Rule 84+108/报告总结/上抛裁决 Rule 69），未列面默认简版独立复核+判定规则，103 边界不叠加
  Evidence: `skills/task-planner/references/critical-rules.md` Rule 109 条款 + `skills/task-planner/SKILL.md` 映射表述；findings 基线
  **Verify command**: `grep -n "audit-before-delivery" /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md`
- [ ] VC-4: 增量合规与归属/编号/索引一致性——Rule 74 增量，Rule 109 归属定稿（核心计划制作域+全流程总则，跨域引用不改写），`^### 109` 定义唯一且索引同步
  Evidence: 变更标注表勾核 + grep 计数/索引命中
  **Verify command**: `test "$(grep -rn '^### 109 ' /mnt/data/dev/task-planner-skill/skills/task-planner/references 2>/dev/null | wc -l)" -eq 1 && grep -n "Rule 109" /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md`
- [ ] VC-5: 计划与知识底座可审计——task_plan.md 必填字段与 R→VC 完整，knowledge-brief.md §1-§6 实条目且 §2/§3 有可追溯锚点
  Evidence: `plans/task-planaudit-20261116/task_plan.md`、`knowledge-brief.md`
  **Verify command**: `test -f /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/task_plan.md && test -f /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/knowledge-brief.md && grep -n "^## §2" /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/knowledge-brief.md && grep -n "^## §3" /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/knowledge-brief.md && grep -n "R1" /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/task_plan.md`
- [ ] VC-6: 端到端实跑证据——本计划 R1(REJECTED, 18发现)→修订(F1-F18)→最终达标轮复审留痕与裁决；负向验证=R1 REJECTED 且达标前阻断进入 D1/展示；最终达标轮（首个达成 0 CRITICAL 且 0 IMPORTANT 且连续一轮零新发现的复审轮，如 R3）由审计体记录 APPROVED（新发现定义同 VC-2）后方可 D1
  Evidence: `plans/task-planaudit-20261116/progress.md` `[plan-audit-R1]`、最终达标轮 `[plan-audit-R<N>]`；Handoff 审计行
  **Verify command**: `grep -n "\[plan-audit-R1\]" /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/progress.md && grep -q "REJECTED" /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/progress.md && awk '/^## \[plan-audit-R[0-9]+\] /{buf=""} {buf=buf $0 "\n"} END{printf "%s",buf}' /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/progress.md | grep -q "结论: \*\*APPROVED\*\*"`

---

## Phase Gates

### Phase 1: 现状核实与覆盖面盘点

**Goal**: 产出插入点、已识别覆盖面（非穷尽）缺口矩阵与 Rule 109 落点/归属/边界结论，落盘 findings 与 kb。

**Depends on**: none（计划获最终达标轮审计 APPROVED 且 D1 确认后启动执行）

**Done when**:
- [ ] S1-S3 完成且 Handoff verify_done 勾选
- [ ] findings.md 含插入锚点、已识别面矩阵、未列面判定输入、编号/归属/边界结论

**Verification** (run before moving on):
- [ ] V-1.1: 证据面①②③关键取证已落盘（对应 VC-1,VC-3 前置信息）
  **Verify command**: `grep -n "Research Findings" /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/findings.md`
- [ ] V-1.2: Rule 109 落点/归属与文本优先决策登记（对应 VC-3,VC-4）
  **Verify command**: `grep -n "Rule 109" /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/findings.md /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/task_plan.md`

Status: `pending` Last verified: —

---

### Phase 2: 方案定稿与变更设计

**Goal**: 定稿审计门协议、全流程映射与 Rule 109 草案/归属，完善变更标注表与输入材料包。

**Depends on**: Phase 1

**Done when**:
- [ ] 审计分档/插入点/达标判据/裁决转换/升级出口/降级链/再展示简版审计定稿
- [ ] 修正执行体（主进程驱动 Plan Writer 重派）、再审派发方、审计输入材料包定稿
- [ ] CA-1~CA-6 可执行且满足 Rule 74 增量与归属定稿

**Verification**:
- [ ] V-2.1: 协议覆盖 R1 迭代、达标判据与留痕要求（对应 VC-1,VC-2）
  **Verify command**: `grep -n "0 CRITICAL" /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/task_plan.md`
- [ ] V-2.2: 已识别覆盖面（非穷尽）与 Rule 109 草案/归属在 Decisions/CA 中可定位（对应 VC-3,VC-4）
  **Verify command**: `grep -n "audit-before-delivery" /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/task_plan.md`

Status: `pending` Last verified: —

---

### Phase 3: 计划审计门落地（SKILL.md 流程）

**Goal**: SKILL.md 计划制作循环具备钉死位置的 D1 前 `计划独立审计门` 与一致性表述。

**Depends on**: Phase 2

**Done when**:
- [ ] S1-S2 完成，SKILL.md 审计门与 D1 前置条件一致
- [ ] 未破坏 22.4a/62.2/既有 D1 语义；103 边界不叠加

**Verification**:
- [ ] V-3.1: 审计门专有 token 与阻断语义存在（对应 VC-1）
  **Verify command**: `grep -n "计划独立审计门" /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md`
- [ ] V-3.2: 迭代/留痕/达标判据关键词在位（对应 VC-2）
  **Verify command**: `grep -n "plan-audit-R" /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md`

Status: `pending` Last verified: —

---

### Phase 4: 全流程原则条款与索引联动落地

**Goal**: Rule 109 `audit-before-delivery` 增量落地并完成索引/映射联动。

**Depends on**: Phase 3

**Done when**:
- [ ] S1-S2 完成，Rule 109 定义唯一且索引同步
- [ ] 已识别覆盖面映射与未列面简版复核规则可读可检索

**Verification**:
- [ ] V-4.1: Rule 109 条款与专有 token 存在（对应 VC-3）
  **Verify command**: `grep -n "^### 109 " /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md`
- [ ] V-4.2: 编号/索引一致性（对应 VC-4）
  **Verify command**: `grep -n "Rule 109" /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md`

Status: `pending` Last verified: —

---

### Phase 5: 校验、收尾与交付准备

**Goal**: 采集 VC 证据、完成同步核对与交付前准备。

**Depends on**: Phase 4

**Done when**:
- [ ] VC-1~VC-6 证据记录在 verification/progress
- [ ] 103.6（如触发）与变更标注表勾核完成

**Verification**:
- [ ] V-5.1: 规则/索引机械校验通过（对应 VC-4）
  **Verify command**: `grep -rn "^### 109 " /mnt/data/dev/task-planner-skill/skills/task-planner/references 2>/dev/null | wc -l`
- [ ] V-5.2: 计划与 kb 完整性可检（对应 VC-5）
  **Verify command**: `grep -n "^## §2" /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/knowledge-brief.md`

Status: `pending` Last verified: —

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| SKILL.md 计划制作循环与 D1 | VC-1/VC-2 对照实际插入位置、分档与顺序 | 待终验 |
| core critical-rules + Rule 74/82 约束 | VC-3/VC-4 对照增量条款、归属与索引 | 待终验 |
| critic 能力与只读边界 | VC-1/VC-2 审计体、修正执行体与降级链分工 | 待终验 |
| Rule 103/84/108/69 映射源 | VC-3 已识别覆盖面映射与 103 边界 | 待终验 |

## 委派统计复验（Rule 25.4）

```bash
bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116
```

JSON 输出：
```json
{待执行期粘贴 stats 命令原文输出}
```

- [ ] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3）
- [ ] 委派率与 verdict 满足终验要求（不满足则按规则回炉/降级）

## 质量门控统计（Rule 26）
- [ ] Q1-Q6 逐项核查完成:触发 __ 项,豁免 __ 项,未处置 __ 项
- [ ] Evidence 抽查 ≥3 条（或全查）：路径可 Read、结论可复现，记录 __
- [ ] 豁免登记：项号/范围/理由/日期 __（仅用户显式文字豁免；Q3 不适用）
- [ ] 存在未处置违规 → outcome 已按 Rule 26.3 降级；Q3 → BLOCKED + STOP

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 落地 L1+ 计划 D1 前独立审计与全流程未经审计产出禁交用户原则
- [ ] VC-1: {evidence} → PASS/FAIL
- [ ] VC-2: {evidence} → PASS/FAIL
- [ ] VC-3: {evidence} → PASS/FAIL
- [ ] VC-4: {evidence} → PASS/FAIL
- [ ] VC-5: {evidence} → PASS/FAIL
- [ ] VC-6: {evidence} → PASS/FAIL

 outcome: COMPLETE / PARTIAL / BLOCKED
```

> **验证独立性**：终验核查由全新独立子代理执行，主进程仅编排与簿记（Rule 33.3 延伸）。

## 交叉验证记录（Rule 108）
| 验证对象 | 机械面路径（命令+结果） | 语义面路径（复检体+结论） | 判定（一致/分歧→108.4 处置） |
|----------|------------------------|--------------------------|------------------------------|
| 计划审计门与全流程原则落地 | 待执行（VC grep/计数/留痕命令） | 待执行（critic R2 复审/CR 复检） | 未触发（R2 待执行） |

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase 1（计划 R1 REJECTED 已修订，待 R2 审计 APPROVED 后进 D1 展示） |
| 2 | Where am I going? | R2 复审→D1→Phase 1-5：核实→设计→SKILL 落地→规则/索引落地→校验交付 |
| 3 | What's the goal? | Goal statement above |
| 4 | What have I learned? | 见 findings.md 与 knowledge-brief.md（含 R1 审计教训与判别性基线） |
| 5 | What have I done? | 见 progress.md（计划产出+R1 留痕+F1-F18 修订准备） |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区（执行期按需刷新） |
