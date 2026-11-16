# Verification Contract & Phase Gates

## Goal (1 sentence)

在 task-planner 技能中落地“L1+ 计划产出后、D1 前独立子代理审计迭代通过”门控，并以增量文本条款将“未经审计产出禁交用户”原则（已识别覆盖面非穷尽，未列面默认简版复核）映射贯彻到计划、执行产物、终验、报告/裁决等全流程审核面。

---

## Verification Contract (≥5 items, objective standards)

> All must pass for goal to be COMPLETE. 每条 VC 的 **Verify command** 为可执行纯命令（退出码判据，禁占位/禁真空/须引用本 VC 产出物）。VC-1/2/3 采用判别性专有 token + 基线负断言记录（基线=改动前 grep 0，见 findings.md “VC 判别性基线”）。

- [x] VC-1: 计划审计门落地（判别性）——SKILL.md 在智能子动作完成后、D1 展示前插入 `计划独立审计门`（L1+ 强制，mini/L0/trivial 轻量复核或登记豁免，L0-E 豁免），独立子代理审计 APPROVED 后方可进入 D1；含再展示简版审计、44.3 不适用、审计体降级链
  Evidence: `skills/task-planner/SKILL.md:68-77`；基线 0→落地 3（:68/:81/:185）；P5-S1 采证 PASS；合并回后主仓实测 3 命中
  **Verify command**: grep -n "计划独立审计门" /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md
- [x] VC-2: 审计迭代闭环与留痕落地——达标=0 CRITICAL 且 0 IMPORTANT 且连续一轮零新发现（新发现=新增 CRITICAL/IMPORTANT；WARNING/QUESTION/NIT 留档不阻断）⇒APPROVED，否则 REJECTED（审计体出具，主进程只登记）；固定留痕 `progress.md [plan-audit-R<N>]`（轮次/审计体/结论/问题清单/修复对照）；升级出口与 R1 首例在位
  Evidence: SKILL.md:75 迭代闭环行+progress `[plan-audit-R1/R2/R3]` 三段全录；合并回后主仓实测三段全命中
  **Verify command**: grep -n "\[plan-audit-R1\]" /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/progress.md && grep -n "REJECTED" /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/progress.md && grep -n "plan-audit-R" /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md
- [x] VC-3: 全流程“未经审计产出禁交用户”原则落地——`audit-before-delivery` 总则映射已识别覆盖面（非穷尽：计划/执行产物 Rule 103/终验 Rule 84+108/报告总结/上抛裁决 Rule 69），未列面默认简版独立复核+判定规则，103 边界不叠加
  Evidence: `references/critical-rules.md:194-212` Rule 109（109.1 总则/109.4 五面映射/109.5 未列面规则）+ SKILL.md:68/:75；实测 SKILL 2 处+critical-rules 4 处
  **Verify command**: grep -n "audit-before-delivery" /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md
- [x] VC-4: 增量合规与归属/编号/索引一致性——Rule 74 增量，Rule 109 归属定稿（核心计划制作域+全流程总则，跨域引用不改写），`^### 109` 定义唯一且索引同步
  Evidence: 变更标注表 CA-1~CA-4 落地+CA-5 预裁+CA-6 未授权未实施；计数 1-109/15 条/90 条四处一致，旧计数 0；合并回后主仓实测 ^### 109=1
  **Verify command**: test "$(grep -rn '^### 109 ' /mnt/data/dev/task-planner-skill/skills/task-planner/references 2>/dev/null | wc -l)" -eq 1 && grep -n "Rule 109" /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md
- [x] VC-5: 计划与知识底座可审计——task_plan.md 必填字段与 R→VC 完整，knowledge-brief.md §1-§6 实条目且 §2/§3 有可追溯锚点
  Evidence: P5-S2 核对 11 必填区块×1 全在位+kb §1-§7 在位+R1/R2/R3→VC 无 uncovered
  **Verify command**: test -f /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/task_plan.md && test -f /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/knowledge-brief.md && grep -n "^## §2" /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/knowledge-brief.md && grep -n "^## §3" /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/knowledge-brief.md && grep -n "R1" /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/task_plan.md
- [x] VC-6: 端到端实跑证据——本计划 R1(REJECTED, 18发现)→修订(F1-F18)→最终达标轮复审留痕与裁决；负向验证=R1 REJECTED 且达标前阻断进入 D1/展示；最终达标轮（首个达成 0 CRITICAL 且 0 IMPORTANT 且连续一轮零新发现的复审轮，如 R3）由审计体记录 APPROVED（新发现定义同 VC-2）后方可 D1
  Evidence: progress.md `[plan-audit-R1]`（REJECTED 18 发现）→`[plan-audit-R2]`（REJECTED 12）→`[plan-audit-R3]`（**APPROVED** 0C/0I）；负向验证=R1/R2 REJECTED 期间计划未进 D1 展示（D1 于 R3 APPROVED 后才执行，44.3 登记在 Decisions）；awk 断言两轮独立实测 VC6=0
  **Verify command**: grep -n "\[plan-audit-R1\]" /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/progress.md && grep -q "REJECTED" /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/progress.md && awk '/^## \[plan-audit-R[0-9]+\] /{buf=""} {buf=buf $0 "\n"} END{printf "%s",buf}' /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/progress.md | grep -q "结论: \*\*APPROVED\*\*"

---

## Phase Gates

### Phase 1: 现状核实与覆盖面盘点

**Goal**: 产出插入点、已识别覆盖面（非穷尽）缺口矩阵与 Rule 109 落点/归属/边界结论，落盘 findings 与 kb。

**Depends on**: none（计划获最终达标轮审计 APPROVED 且 D1 确认后启动执行）

**Done when**:
- [x] S1-S3 完成且 Handoff verify_done 勾选（Handoff #1-#3 done ☑）
- [x] findings.md 含插入锚点、已识别面矩阵、未列面判定输入、编号/归属/边界结论（findings P1 段）

**Verification** (run before moving on):
- [x] V-1.1: 证据面①②③关键取证已落盘（对应 VC-1,VC-3 前置信息）——findings P1 段+基线表
  **Verify command**: `grep -n "Research Findings" .../findings.md` → PASS
- [x] V-1.2: Rule 109 落点/归属与文本优先决策登记（对应 VC-3,VC-4）——findings P1-S3+Technical Decisions
  **Verify command**: `grep -n "Rule 109" findings/task_plan` → PASS

Status: `complete` Last verified: 2026-11-16

---

### Phase 2: 方案定稿与变更设计

**Goal**: 定稿审计门协议、全流程映射与 Rule 109 草案/归属，完善变更标注表与输入材料包。

**Depends on**: Phase 1

**Done when**:
- [x] 审计分档/插入点/达标判据/裁决转换/升级出口/降级链/再展示简版审计定稿（design-p3-p4.md §A）
- [x] 修正执行体（主进程驱动 Plan Writer 重派）、再审派发方、审计输入材料包定稿（design §A+task_plan:225）
- [x] CA-1~CA-6 可执行且满足 Rule 74 增量与归属定稿（CA-1~4 落地/CA-5 预裁不落地/CA-6 未授权未实施）

**Verification**:
- [x] V-2.1: 协议覆盖 R1 迭代、达标判据与留痕要求（对应 VC-1,VC-2）——task_plan 达标判据多处+design §A
  **Verify command**: `grep -n "0 CRITICAL" .../task_plan.md` → PASS
- [x] V-2.2: 已识别覆盖面（非穷尽）与 Rule 109 草案/归属在 Decisions/CA 中可定位（对应 VC-3,VC-4）——design §C+CA-3
  **Verify command**: `grep -n "audit-before-delivery" .../task_plan.md` → PASS

Status: `complete` Last verified: 2026-11-16

---

### Phase 3: 计划审计门落地（SKILL.md 流程）

**Goal**: SKILL.md 计划制作循环具备钉死位置的 D1 前 `计划独立审计门` 与一致性表述。

**Depends on**: Phase 2

**Done when**:
- [x] S1-S2 完成，SKILL.md 审计门与 D1 前置条件一致（worktree commit 5b728a7；G1:185+D1:81 对齐）
- [x] 未破坏 22.4a/62.2/既有 D1 语义；103 边界不叠加（P3 独立复检 RECHECK: PASS 四维全过）

**Verification**:
- [x] V-3.1: 审计门专有 token 与阻断语义存在（对应 VC-1）——:68-77 区块+阻断语义行
  **Verify command**: `grep -n "计划独立审计门" SKILL.md` → PASS（3 命中）
- [x] V-3.2: 迭代/留痕/达标判据关键词在位（对应 VC-2）——:75 迭代闭环行
  **Verify command**: `grep -n "plan-audit-R" SKILL.md` → PASS

Status: `complete` Last verified: 2026-11-16

---

### Phase 4: 全流程原则条款与索引联动落地

**Goal**: Rule 109 `audit-before-delivery` 增量落地并完成索引/映射联动。

**Depends on**: Phase 3

**Done when**:
- [x] S1-S2 完成，Rule 109 定义唯一且索引同步（worktree commits 70e29b1/1f568f7/1c49637；P4 独立复检 RECHECK: PASS）
- [x] 已识别覆盖面映射与未列面简版复核规则可读可检索（109.4/109.5）

**Verification**:
- [x] V-4.1: Rule 109 条款与专有 token 存在（对应 VC-3）——:194-212（109.1-109.7+Why）
  **Verify command**: `grep -n "^### 109 " critical-rules.md` → PASS（:194 唯一）
- [x] V-4.2: 编号/索引一致性（对应 VC-4）——计数 1-109/15 条/90 条四处一致
  **Verify command**: `grep -n "Rule 109" SKILL.md critical-rules.md` → PASS

Status: `complete` Last verified: 2026-11-16

---

### Phase 5: 校验、收尾与交付准备

**Goal**: 采集 VC 证据、完成同步核对与交付前准备。

**Depends on**: Phase 4

**Done when**:
- [x] VC-1~VC-6 证据记录在 verification/progress（P5-S1 采证 16/16 PASS+P5-S2 核对 PASS+本文件 VC 行回填）
- [x] 103.6（如触发）与变更标注表勾核完成（P3/P4 双独立复检 RECHECK: PASS；CA-1~CA-6 勾核见 task_plan Phase 5）

**Verification**:
- [x] V-5.1: 规则/索引机械校验通过（对应 VC-4）——`^### 109 ` 计数=1
  **Verify command**: grep -rn "^### 109 " /mnt/data/dev/task-planner-skill/skills/task-planner/references 2>/dev/null | wc -l
- [x] V-5.2: 计划与 kb 完整性可检（对应 VC-5）——kb §1-§7 在位
  **Verify command**: `grep -n "^## §2" .../knowledge-brief.md` → PASS

Status: `complete` Last verified: 2026-11-16

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| SKILL.md 计划制作循环与 D1 | VC-1/VC-2 对照实际插入位置、分档与顺序 | 符合（:68-77 插入+G1:185+D1:81；顺序=智能子动作后、D1 展示前，与计划钉死一致） |
| core critical-rules + Rule 74/82 约束 | VC-3/VC-4 对照增量条款、归属与索引 | 符合（:194-212 纯追加，80-83 零改动；归属=核心计划制作域+总则，跨域仅引用） |
| critic 能力与只读边界 | VC-1/VC-2 审计体、修正执行体与降级链分工 | 符合（critic R1/R2/R3 三轮只读审计；修正=Plan Writer；降级链条款在位未触发） |
| Rule 103/84/108/69 映射源 | VC-3 已识别覆盖面映射与 103 边界 | 符合（109.4 引用映射；SKILL:75 103 边界不叠加声明；P3/P4 复检即 103.3 实跑） |

## 委派统计复验（Rule 25.4）

```bash
bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116
```

JSON 输出（2026-11-16 实测，P5-S1 采证 #5 复跑一致）：
```json
{"phases_total":5,"phases_delegated":4,"main_direct_count":1,"delegation_rate":0.800,"main_direct":[{"phase":"2 方案定稿与变更设计","executor":"主进程（例外理由:25.3② 计划系统文件维护——仅编辑 `plans/**` 计划文档；设计决策以既有七文件载体整合，派发开销大于收益）","reason":"例外理由:25.3② ...","needs_git_evidence":0,"self_declared":0}],"violations":[],"verdict":"ok"}
```

- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3）——Phase 2=25.3② 计划系统文件维护（check-delegation 识别为合法例外，self_declared=0）
- [x] 委派率与 verdict 满足终验要求（rate=0.800 ≥ floor 0.7；verdict=ok；violations=[]）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成:触发 2 项（Q5 子代理产出无盘上实据→Plan Writer 空收据判例，即时打回重做闭环；Q6 验证伪绿风险→tac 命令判别缺陷，模拟实测后替换）,豁免 0 项,未处置 0 项
- [x] Evidence 抽查 ≥3 条：①SKILL.md:68-77 审计门区块（主进程逐字 diff+两轮独立复检全文回读）②critical-rules.md:194-212 Rule 109（Python 逐字比对 RULE109_MATCH=True）③progress.md [plan-audit-R1/R2/R3] 三段留痕（critic R3 逐项核验与原审计输出一致）④VC-6 awk 命令三态实测（真实 FAIL/模拟 PASS/相对路径 FAIL）——均可 Read 可复现
- [x] 豁免登记：无用户文字豁免事项；CA-5 不落地=design §E 有据预裁（非质量豁免）；CA-6 未授权未实施（文本优先铁律）
- [x] 存在未处置违规 → 无；outcome 不降级

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 落地 L1+ 计划 D1 前独立审计与全流程未经审计产出禁交用户原则
- [x] VC-1: SKILL.md:68-77 审计门区块+G1:185+D1:81（grep=3；基线 0→3 判别成立）→ PASS
- [x] VC-2: SKILL:75 迭代闭环+progress [plan-audit-R1/R2/R3] 三段留痕（R1 REJECTED 首例+R3 APPROVED）→ PASS
- [x] VC-3: critical-rules.md:194-212 Rule 109 五面映射+109.5 未列面规则（audit-before-delivery 双文件 6 处）→ PASS
- [x] VC-4: ^### 109 唯一=1+计数四处一致+旧计数清零+变更标注表勾核 → PASS
- [x] VC-5: task_plan 11 必填区块+kb §1-§7+R→VC 无 uncovered（P5-S2 核对）→ PASS
- [x] VC-6: 端到端实跑 R1 REJECTED→R2 REJECTED→R3 APPROVED 全留痕+负向验证（awk 末段断言 VC6=0 双轮实测）→ PASS

 outcome: COMPLETE（待合并回主仓后由独立 Verifier 终验复核背书，见交叉验证记录）
```

> **验证独立性**：终验核查由全新独立子代理执行，主进程仅编排与簿记（Rule 33.3 延伸）。CR Gate（Code Reviewer APPROVED）+P3/P4 独立复检（general-reviewer RECHECK PASS）+P5 采证（code-runner）+漂移检查（drift-checker ALIGNED）=四路独立执行体背书；合并回主仓后 run-verification 统一入口复跑为最终机械确认。

## 交叉验证记录（Rule 108）
| 验证对象 | 机械面路径（命令+结果） | 语义面路径（复检体+结论） | 判定（一致/分歧→108.4 处置） |
|----------|------------------------|--------------------------|------------------------------|
| 计划审计门与全流程原则落地 | VC-1~VC-6 grep/计数/awk 命令全 PASS（P5-S1 采证 16/16） | P3 复检 RECHECK PASS（全文回读四维）+P4 复检 RECHECK PASS（103.6 清单）+CR Gate APPROVED+drift-checker ALIGNED | 一致（机械面与语义面四路独立执行体结论互洽，无 108.4 分歧处置） |
| 审计门机制有效性（[目标]面） | VC-6 awk 末段断言 VC6=0（R3 APPROVED 在位） | critic R3 审计体出具 APPROVED（0C/0I）+负向验证 R1/R2 REJECTED 阻断实证 | 一致 |

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | 终验收口段：P1-P5 complete+CR APPROVED+DRIFT ALIGNED+verification 回填完毕；进行中=合并回主仓→run-verification→check-complete→归档部署 |
| 2 | Where am I going? | 合并回+部署核验+归档+kb 入库+交付总结（outcome=COMPLETE） |
| 3 | What's the goal? | Goal statement above |
| 4 | What have I learned? | 见 findings.md「收尾回读梳理（84.14）」段（三教训：收据盘上复核/验证命令双态实测/共享状态文件主仓权威） |
| 5 | What have I done? | 见 progress.md（审计三轮+P1-P5+Handoff #1-#17）与 task_plan Handoff 表 |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区（收尾时 sync-todos --index 刷新） |
