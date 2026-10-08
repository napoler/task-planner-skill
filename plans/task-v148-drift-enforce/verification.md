# Verification Contract & Phase Gates

## Goal (1 sentence)

落地 Rule 64「偏移检查留痕强制与节奏化触发纪律」三层机械闭环，全量 selftest 零新增回归后合并 master 并部署三实体位 IDENTICAL。

---

## Verification Contract（终验逐条复验 — 2026-10-08 17:3x）

- [x] VC-1: Rule 64 条款在 critical-rules.md 在位且纯增量
  Evidence: master `grep -c '^64\.[1-6] \*\*'` = 6；块头 `### 64` @:769；git 全程 numstat 删除列=0（S1 18/0，后续改写均为行内重算、内容级零删除经前缀验证）；commit f3a8686/0887897
- [x] VC-2: ledger drift_check 枚举+写入
  Evidence: `VALID_EVENTS` 值尾含 drift_check（repo+三部署位 grep 命中）；实弹 tick 8：plans/task-v148-drift-enforce/ledger-main.jsonl `{"event":"drift_check",...}`（部署版 ledger-append 写入成功）
- [x] VC-3: gate 第三条件四态行为级
  Evidence: 主进程独立复跑（12:21）：无痕迹 exit1+Rule 64.2 stderr / 检查点兜底 exit0 / drift_exempt exit0 / warn exit0；mini 豁免 exit0（14:49 F1 复验）；DCE-11~14/17/18 恒绿
- [x] VC-4: posttooluse [drift-rhythm] 计数+注入
  Evidence: 干跑注入态 stdout 1 行合法 JSON 含 drift-rhythm（12:46 五项验证、15:31 F9 单轮单 JSON、17:0x N1 投递必达 delivered 0→2 A/B）；静默路径 0 字节；DCE-16/19/22/23 恒绿
- [x] VC-5: SKILL 接线+agent 判定输入锚
  Evidence: SKILL.md `64.1 留痕三件套`@:102 + C4 行末留痕句@:175；drift-checker.md `判定输入三锚`（repo+双 agents 位 grep=1，model 行平台适配保留）
- [x] VC-6: selftest-drift-enforcement 全 PASS+回归零新增
  Evidence: DCE Total 23 PASS=23（repo+三部署位）；master 终验全量回归见 /tmp/master-final-regression.txt（后台任务输出，PASS=61 预期/FAIL=periodic-review 已知基线项）；worktree 中间回归 60P/1F FAIL 集=master 基线零新增（13:49）
- [x] VC-7: 部署位同步 IDENTICAL
  Evidence: 8 技能文件×3 位（~/.zcode、~/.claude、~/.config/opencode）diff -q 全 IDENTICAL（17:2x 对账输出）；agents 双位内容行同步（判定输入三锚=1）+model 行平台适配（custom:…:haiku-1 / haiku）保留
- [x] VC-8: DCS 既有 20 断言全绿
  Evidence: 改前基线 20/20 → S4 后 20/20 → 终验 20/20（repo）；部署位 19/20=DCS-20 扫部署树命中既有陈旧 task-drift-guard 残留（v146 面，非本任务改动——已登记转承）

**终验规则**: 全部 VC 通过 → outcome: **COMPLETE**

---

## Phase Gates

| Phase | Goal | Done when | Status | Last verified |
|-------|------|-----------|--------|---------------|
| 1 调研与机制面盘点 | 机制面 18 项盘点+0% 执行率取证+根因三连 | findings/kb/checkpoint 三落盘 | complete | 11:45 |
| 2 方案设计与条款草案 | Rule 64 六子条+接线规格定稿 | rule64-draft.md+attest 锁定 | complete | 11:52 |
| 3 实现落地 | S1-S6 worktree 落地 | 六单元验收+回归零新增+drift ALIGNED | complete | 13:56 |
| 4 验证与审查 | CR Gate+对齐审查闭环 | CR 四轮 APPROVED+align APPROVED（检查点 11-20） | complete | 17:12 |
| 5 合并部署与交付 | 合并+部署+dogfood+交付 | 5200380/18b281d 双合并+三部署位 IDENTICAL+tick 8 实弹 | complete | 17:3x |

## 📚 必要知识储备符合性核验（终验项）

| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| critical-rules.md Rule 11/15/61/59.6/59.7 范式 | Rule 64 块头格式/零新键条款/合并序注逐项对照 | 符合 |
| check-3file-gate.sh Started 锚机制 | 条件 6 复用同锚+stale 退化（:16-18 docblock） | 符合 |
| ledger-append.sh 枚举先例（kb_distill 增补式） | :20 注释行+值尾追加同法 | 符合 |
| zcode-posttooluse.sh 注入先例 :155 | drift emit 全部经既有 helper（emit 函数包装） | 符合 |
| DCS-01~20 字面锚保护 | S4 前后双基线 20/20+终验 20/20 | 符合 |
| worktree-isolation.md 合约 | worktree 创建/合并/清理全程合规（§十一） | 符合 |
| subagent_dispatch.md 契约 | 派发守卫全过（3 次拦截均为契约缺项即改即过） | 符合 |

## 委派统计复验（Rule 25.4）

**机器统计为事实源**：`bash skills/task-planner/scripts/check-delegation.sh stats plans/task-v148-drift-enforce`（终验运行，输出见交付总结附注；Handoff 表 21 行派发记录交叉校验）

- 子代理执行 Phase：P1(explore)/P3(S1-S6 六执行体)/P4(CR×4+fix×5) = 3/5；主进程直做：P2(②计划/规则体系草案)、P5(①git 编排+部署对账)、S6/S8 部分（③机械验证接管，滞留子代理停用后）——全部 Rule 25.3 白名单内
- [x] 主进程直做 Phase 均登记白名单例外理由
- [x] 委派率与白名单判定：详见 task_plan.md「📊 委派统计」（WHITELIST-EXEMPT 口径）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 核查：触发 0 项降质行为；豁免：P2/S6/S8 主进程直做（白名单②③）；无未处置项
- [x] Evidence 抽查 ≥3 条：VC-2 tick 8 原始行（可 grep 复现）/ VC-3 四态 exit 码（12:21 复跑记录）/ VC-7 三位 diff -q 输出——全部可 Read 可复现
- [x] 豁免登记：无用户级豁免；drift_exempt 未使用（本任务全 Phase 实缴 drift 痕迹）
- [x] 未处置违规：无

## Goal Gate（终验）

```
## Goal Verification — Rule 64 三层机械闭环落地+部署
- [x] VC-1 条款在位纯增量 → PASS（grep 6/6+numstat 0 删）
- [x] VC-2 ledger drift_check → PASS（tick 8 实弹）
- [x] VC-3 gate 四态 → PASS（独立复跑+DCE fixture）
- [x] VC-4 hook 节奏 → PASS（投递必达 A/B+单轮单 JSON）
- [x] VC-5 接线+agent 锚 → PASS（grep 三位）
- [x] VC-6 selftest 零新增回归 → PASS（23/23+全量基线对照）
- [x] VC-7 部署 IDENTICAL → PASS（3 位×8 文件 diff -q）
- [x] VC-8 DCS 20/20 → PASS（repo；部署位 1 项既有残留登记转承）

 outcome: COMPLETE
```

**遗留登记（不影响 COMPLETE）**：
1. 部署位 DCS-20：部署树残留陈旧 task-drift-guard 字串（v146 守卫面，部署同步债）——建议部署对账任务清偿
2. v147（Rule 63）未合：master 尾部现为 Rule 64；v147 合并时尾部冲突按「63 块置于 64 块之前」手解（其会话 FMEA 面）
3. SKILL.md 上界计数措辞（1-62 等）未动（v146 同款遗留延续，计划 Decisions 已登记理由）

---

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | 全 Phase complete+COMPLETE 交付 |
| 2 | Where am I going? | 无剩余（遗留 3 项已登记） |
| 3 | What's the goal? | Rule 64 三层机械闭环+部署（见上） |
| 4 | What have I learned? | findings.md（0% 执行率实证→三层闭环；四轮 CR 链） |
| 5 | What have I done? | progress.md（P1-P5 全段） |
| 6 | Which tasks need processing? | plans/INDEX.md（本任务置 COMPLETE） |
