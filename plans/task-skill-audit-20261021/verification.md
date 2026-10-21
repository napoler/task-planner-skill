# Verification Contract & Phase Gates

## Goal (1 sentence)
完成 task-planner-skill 仓六维系统性审计，经独立复核分级，产出「审计报告 + 逐条可执行修改方案」两份文档，使「所有执行产出的稳定性」具备可复现的证据基础。

---

## Verification Contract（6 项，客观判定）

- [x] VC-1: 审计报告在位且覆盖六维（事实编造/规则三面一致性/脚本与回归/部署与簿记/派发契约/结构面），每维含结论+发现编号+证据锚
  - 验证命令：`grep -c '^## §' /mnt/data/dev/task-planner-skill/plans/task-skill-audit-20261021/audit-report.md`（≥5）+ `grep -n '^## §' ...`
  - Evidence: 实测 9（§0 结论摘要 + §0.1 VC 映射 + §1~§6 六维 + §7 复核裁决 + §8 总体裁决）；文件 `plans/task-skill-audit-20261021/audit-report.md`
- [x] VC-2: 修改方案在位，每条=对象（文件+锚点）+变更类型（增量/替代/删除）+优先级+执行动作+依据四要素齐备
  - 验证命令：`grep -c '^| RP-' .../revision-proposals.md` 与 `grep -c '^| RP-.*|.*|.*|.*|.*|$' .../revision-proposals.md`（两数相等=四要素齐备）
  - Evidence: 实测均为 31；替代类 RP-05/07/12 均标 Rule 74 四条件核对状态；删除类 RP-18/25 均标「需用户逐项授权」
- [x] VC-3: 全量 selftest 回归执行记录在案（命令 + PASS/FAIL 数字），审计动作本身零新增 FAIL
  - 验证命令：活树回归口径 `find skills/task-planner -path '*/.backup' -prune -o -name 'selftest-*.sh' -print`（92 个）；逐个 `timeout 60 bash <script>`
  - Evidence: `subagent-state/S4-runner.md`——92/92 exit 0、1315 PASS / 0 FAIL / 0 超时、bash -n 0 语法错、registry 92=92；在途变更未致任何 FAIL（HEAD 镜像 23 PASS/0 FAIL vs 工作树 27 PASS/0 FAIL）
- [x] VC-4: 全部 P0/P1 发现有证据锚；无锚结论=0；独立复核判定闭合
  - 验证命令：`grep -n 'Evidence\|file:line' .../subagent-state/S7-verifier.md` + 复核表逐条判定
  - Evidence: `subagent-state/S7-verifier.md`——22 条判定 = verified 17 / partial 3 / fp 2 / unverified 0；跳过 5 项已列理由；撤回 1 条（FP-1「FACT LOCK 无产出」）；2 处措辞修正已同步到报告与 findings
- [x] VC-5: 无回归破坏——本任务零改动仓内既有文件，写面仅 plans/task-skill-audit-20261021/
  - 验证命令：`git -C /mnt/data/dev/task-planner-skill status --short -- plans/task-skill-audit-20261021` 与全量 `git status --short` 对照
  - Evidence: 本目录为唯一新增（`?? plans/task-skill-audit-20261021/`）；仓内既有 4 个 M（`plans/.rule-reservations.jsonl`、`skills/task-planner/SKILL.md`、`references/critical-rules.md`、`scripts/selftest-requirement-coverage.sh`）为**在途他人变更**，本任务未触碰（mtime 保持 10-21 11:30）
- [x] VC-6: R3 取证链闭合——①声称原文锚 ②真实额度锚 ③编造+固化发生点 ④守护条款方案
  - 验证命令：sqlite3 只读 `select id,time_created from part where data like '%物理约束%'`
  - Evidence: ①`part_mvia2iou_0657e219-14ba-4a80-9ac2-ec8b081fa769` / `msg_mvi9riyb_…`（2026-10-21 23:30:54 +08）②账本 `videop1/tmp/_gen-budget/video-seconds-20261021.json`={"used":198}（mtime 23:03:58）+ `agent_ce1928bc…/output.txt:46`「剩余 302s」（23:25:12 已回灌主会话）③固化落点 5 类（`videop1/AGENTS.md:84` 判例行等，见报告 §1.3）④守护条款方案=revision-proposals.md RP-01~RP-04（生效通道）+ RP-30/RP-31（跨项目措辞纠正）

---

## Phase Gates

### Phase 1: 侦察盘点（G1a 并行组）
**Goal**: 产出技能全树/部署位/会话取证三份基线
**Depends on**: none
**Done when**: S1/S2/S8 三份检查点落盘且 findings 对应三节有回填
**Verification**:
- [x] V-1.1 → VC-1/VC-5：盘点清单与漂移清单非空；git status 未出现非本计划目录改动（`subagent-state/S1-explore.md`、`S2-explore.md`）
- [x] V-1.2 → VC-6：涉事会话声称原文与真实额度锚可复现（`subagent-state/S8-runner.md` + sqlite 只读复查）
Status: `complete` Last verified: 2026-10-22

### Phase 2: 系统性审计（G2a 并行组）
**Goal**: 五维审计面全部产出带锚发现
**Depends on**: Phase 1
**Done when**: S3/S4/S5/S6/S9 检查点落盘 + findings 七节回填
**Verification**:
- [x] V-2.1 → VC-1：六维审计面在报告 §1~§6 均有对应章节
- [x] V-2.2 → VC-3：全量回归基线数字落 progress.md Test Results（S4-runner.md）
- [x] V-2.3 → VC-4：全部 P0/P1 条目带 file:line 或命令锚
Status: `complete` Last verified: 2026-10-22

### Phase 3: 独立复核与分级
**Goal**: 22 条 P0/P1 经独立复现判定，撤回误报
**Depends on**: Phase 2
**Done when**: S7-verifier.md 判定表完成，误报已在报告与 findings 中撤回
**Verification**:
- [x] V-3.1 → VC-4：verified 17 + partial 3 + fp 2 = 22，unverified 0
- [x] V-3.2 → VC-1：撤回项（FP-1 FACT LOCK 产出）在报告 §1.2 与 §7 均已改写，findings D-F4 标 [fp-已撤回]
Status: `complete` Last verified: 2026-10-22

### Phase 4: 报告·方案·终验交付
**Goal**: 两份交付文档落盘 + 六 VC 复验通过 + 归档 + 交付总结
**Depends on**: Phase 3
**Done when**: 报告/方案齐备、对齐审查修正完成、check-complete exit 0、archive-plan 走通
**Verification**:
- [x] V-4.1 → VC-1/VC-2：两份文档在位且四要素齐备（`grep -c` 实测 9 / 31 / 31）
- [x] V-4.2 → VC-6：取证链四要素在报告 §1 + 方案 RP-01~RP-04 / RP-30 / RP-31 齐备
- [x] V-4.3 → VC-3/VC-5：回归基线与 git 写面范围已复验（progress.md Test Results）
Status: `in_progress`（报告/方案/复验/裁决/提交已毕；待 check-complete exit 0 + archive-plan 走通后置 complete） Last verified: 2026-10-22

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| 宪法 §六（保护区）/§十一（worktree） | 交付物是否含任何「已修改 skills/**」表述；方案是否全部落在 plans/ 且标「需授权/需 worktree」 | 符合——报告零越界改动声明；方案 §七明确 worktree 与逐项授权前置 |
| 记忆库 MEMORY.md 判例 | 报告是否交叉验证既往缺陷复发面 | 符合——报告 §6/§历史线索 引 3 条既往判例互证（锚点失效/部署债/计数级联） |
| 技能规则全集（核心+11 卫星） | 审计面是否覆盖规则载体与索引层 | 符合——S3 建立 90 条规则事实表并给出计数互斥与走错分支清单 |

## 委派统计复验（Rule 25.4）

**机器统计为事实源**：`bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/check-delegation.sh stats <plan-dir>`

JSON 输出：
```json
{"phases_total":4,"phases_delegated":3,"main_direct_count":1,"delegation_rate":0.750,"main_direct":[{"phase":"4 报告·方案·终验交付","executor":"主进程（白名单② 计划系统文件维护——报告/方案为 plans/ 内文档写作，综合面须持有 S1-S9 全结论上下文；白名单① git 编排与终验门执行）","reason":"白名单② 计划系统文件维护——报告/方案为 plans/ 内文档写作，综合面须持有 S1-S9 全结论上下文；白名单① git 编排与终验门执行","needs_git_evidence":0,"self_declared":0}],"violations":[],"verdict":"ok"}
```

- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（白名单② 计划系统文件维护 / 白名单① git 编排与终验门执行）
- [x] 委派率 0.750 ≥ floor 0.7，violations=[]，verdict=ok

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成：触发 1 项（Q3 语义级产出零机器检查——本任务产出为审计报告/方案两份文档，其「内容是否真实」由独立复核 S7 + 对齐审查 ALIGN 承担，非纯机器可判，已按 R-COVERAGE 精神补人审），豁免 5 项，未处置 0 项
- [x] Evidence 抽查 ≥3 条：①`templates/task_plan.md:502` 列折叠（grep 实测）②`check-dispatch.sh:126` 3/8 字段（行为实测 rc 判定）③`~/.zcode/skills/task-planner/SKILL.md` 「规范召回」0 命中（grep 实测）——抽查记录见 subagent-state/S7-verifier.md
- [x] 豁免登记：archive-plan dry-run 豁免（会产生写操作，由主进程在终验阶段实跑并登记）；videop1 业务事实（用户当夜是否真实发起生成）未验证项 1 条已在报告 §1.1 标注
- [x] 存在未处置违规 → 无；outcome 按 §8 裁决为 **PARTIAL**（审计与方案已交付，修复未执行——属任务边界而非缺陷）

## Goal Gate（终验）

```
## Goal Verification — 六维审计 + 独立复核分级 + 报告与逐条修改方案
对照 Verification Contract 逐条复验：
- VC-1 报告在位且六维覆盖（grep '^## §' = 9）→ PASS
- VC-2 方案 31 条且四要素齐备（RP 行数 31 = 五要素行数 31）→ PASS
- VC-3 全量回归基线在案（92/92、1315 PASS/0 FAIL、0 语法错；审计零新增 FAIL）→ PASS
- VC-4 复核闭合（verified 17/partial 3/fp 2/unverified 0=22；误报已撤回）→ PASS
- VC-5 写面零越界（唯一新增=本计划目录；仓内 4 个 M 为在途他人变更，未触碰）→ PASS
- VC-6 取证链四要素闭合（原文锚+真实额度锚+固化发生点+守护条款方案）→ PASS

 outcome: PARTIAL
```

**PARTIAL 理由**：六条 VC 全部通过 → 审计与方案交付完成；但**修改未执行**（本任务边界=只读审计+出方案；技能文件属 §六 保护区且须走 §十一 worktree + 用户逐项授权），故「所有执行产出的稳定性」**尚未达成**，只达成「可被证据验证的缺陷定位与可执行方案」。遗留：RP-01~RP-31 待落地（其中 RP-12/RP-13 部署同步与 RP-14 在途固化须先行，否则其余修复不生效在真实会话）。

---

## 5-Question Reboot Check
| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase 4（交付阶段，Phase 1-3 已 complete） |
| 2 | Where am I going? | 归档 + 交付总结；修改落地为独立后续任务 |
| 3 | What's the goal? | 见 Goal 一句话 |
| 4 | What have I learned? | 见 findings.md 七节 + 报告 §1~§8 |
| 5 | What have I done? | 见上方 Phase 段与 progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区（本任务归档后刷新） |
