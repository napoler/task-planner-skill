# Verification Contract & Phase Gates

## Goal (1 sentence)
为 task-planner 技能 Rule 18 族落地批量试点先行硬门（18.9/18.10/18.11）+详解+守护并合并部署三位，回应用户 2026-09-18「无十足把握禁批量、宁慢勿错」训诫。

---

## Verification Contract（终验复验 2026-09-18）

- [x] VC-1: critical-rules.md 18.9/18.10/18.11 三条款在位且纯追加零语义删除
  Evidence: master skills/task-planner/references/critical-rules.md:84-86（18.9 试点先行硬门/18.10 投毒红线/18.11 宁慢勿错）；worktree 期 git diff numstat=3增0删、deleted-lines=0；合并后 grep `^18\.9 `=1
- [x] VC-2: batch-quality-gate.md v2.3 七处增补，零语义删除
  Evidence: master batch-quality-gate.md（:1 v2.3/:25 十一条款/:38-40 表 3 行/:111 §五 Rule 31 行/:123 §六训诫行/:130 §七联动/:143 §八详解）；worktree 期 numstat=37增3删，删除行恰为 3 处机械联动；「八条款」残留=0
- [x] VC-3: SKILL.md Rule 18 摘要行含「试点先行」，净增 0 行（wc=543）
  Evidence: master SKILL.md:287 行内含「试点先行硬门（18.9-18.11…task-v083）」；`wc -l` = 543（合并 v082 后仍 543，三处 ≤548 断言 PASS）
- [x] VC-4: selftest-batch-pilot.sh 新建全 PASS；worktree 全量与 master 全量 0 FAIL（主进程逐 Total 亲算）
  Evidence: worktree 期 23 脚本 376/0（=基线366+10）；合并 v082 后 master 23 脚本 **377 PASS/0 FAIL**（bc 机械求和，/tmp/v083-master-suite.txt）；selftest-batch-pilot BP-01..10 全 PASS
- [x] VC-5: 仓库根 CHANGELOG.md 条目在位
  Evidence: master CHANGELOG.md:12「批量试点先行硬门（task-v083）」条目全文（合并冲突已解，v083/v082 双条目并存）
- [x] VC-6: 3 实体位 diff -r IDENTICAL 主进程亲验；origin/master push；worktree/分支清理
  Evidence: diff -r 亲验三位（~/.zcode、~/.claude、~/.config/opencode）全 IDENTICAL；`git push` 输出 c10e8f2..8fed498 master->master；`git worktree list` 仅剩主仓+v082（他者）；wt/task-v083-batch-pilot-first 已删

**终验规则**: 6/6 VC 通过 → **COMPLETE**

---

## Phase Gates

### Phase 1: 调研定稿与基线
**Goal**: 冲突侦察+现状盘点+联动审计+条款定稿落 findings+账本认领+veto 登记
**Depends on**: none
**Done when**: 定稿可执行、计划 attest 锁定
**Verification**:
- [x] V-1.1: 联动审计三关键词宽口径（→VC-1/VC-2 基准）
- [x] V-1.2: attest 锁定 SHA d2315a7f（→计划有效性）
Status: `complete` Last verified: 2026-09-18

### Phase 2: worktree 创建+条款落地
**Goal**: critical-rules 18.9-18.11 追加 + batch-quality-gate 详解增补
**Depends on**: Phase 1
**Done when**: 两文件改动落地且零语义删除
**Verification**:
- [x] V-2.1: 编号连续性 18.1-18.11 各=1（→VC-1）
- [x] V-2.2: git diff 零语义删除（→VC-1/VC-2）
Status: `complete` Last verified: 2026-09-18（commit cce19d3 前序 6e987ca）

### Phase 3: SKILL 联动+selftest 守护
**Goal**: SKILL 行内联动+CHANGELOG+BP-01..10 守护
**Depends on**: Phase 2
**Done when**: 净增 0+条目在位+selftest 全 PASS
**Verification**:
- [x] V-3.1: wc -l=543（→VC-3）
- [x] V-3.2: selftest-batch-pilot 10/10（→VC-4）
Status: `complete` Last verified: 2026-09-18

### Phase 4: worktree 全量回归
**Goal**: worktree 内 23 脚本全量 0 FAIL
**Depends on**: Phase 3
**Done when**: 主进程亲算求和 0 FAIL
**Verification**:
- [x] V-4.1: 376 PASS/0 FAIL（→VC-4 worktree 侧）
Status: `complete` Last verified: 2026-09-18

### Phase 5: 合并部署+簿记收尾
**Goal**: 合并 master+部署三位+push+清理+簿记
**Depends on**: Phase 4
**Done when**: 三位 IDENTICAL+master 全量 0 FAIL+push+清理
**Verification**:
- [x] V-5.1: master 全量 377/0（→VC-4 master 侧）
- [x] V-5.2: 三位 diff -r IDENTICAL 亲验+push 8fed498（→VC-6）
Status: `complete` Last verified: 2026-09-18

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| critical-rules.md:76-83 现状 | 条款定稿与插入位照 brief §3 执行 | 符合（18.9-18.11 紧随 18.8） |
| batch-quality-gate.md v2.2 全文 | 七处增补清单逐项对照 | 符合（详见 VC-2 Evidence） |
| SKILL.md Rule 18 行+行数断言三处 | 行内改+wc=543+三断言 PASS | 符合 |
| v082 并行范围（禁碰） | worktree list 全程仅本任务 worktree 新增；其 worktree/分支未动 | 符合（其已合并 e120331，位留其属主） |
| CHANGELOG 格式先例 | v081/v080 bullet 同构 | 符合 |

## 委派统计复验（Rule 25.4）

JSON 输出：
```json
{"phases_total":5,"phases_delegated":1,"main_direct_count":4,"delegation_rate":0.200,"violations":[],"verdict":"ok"}
```
- [x] 主进程直做 Phase 均登记白名单内例外理由：P1=③②、P2/P3=⑤（22.3④ 接管，code-assistant 2 连败实证）、P5=①②
- [x] 委派率 0.200 < 0.7 但全部直做理由命中 Rule 25.3 白名单（机器 verdict=ok，violations 空）→ **WHITELIST-EXEMPT 放行**；P4 实际委派成功（code-runner-agent mini 档）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查：触发 0 项，豁免 0 项，未处置 0 项（无降质行为；Batch Report 走零单元逃生且本任务编辑全程单件串行+逐件验证=18.9 自证）
- [x] Evidence 抽查 3 条：①critical-rules.md:84-86 三条款 Read 在位 ②master 全量 suite Total 行 23 条原文（/tmp/v083-master-suite.txt，bc 求和 377）③CHANGELOG.md:12 条目 Read 在位——均可复现
- [x] 豁免登记：无
- [x] 无未处置违规

## Goal Gate (终验)

```
## Goal Verification — Rule 18 族落地批量试点先行硬门并合并部署
- [x] VC-1: 三条款在位+零语义删除（git diff numstat 实测） → PASS
- [x] VC-2: v2.3 七处增补+八条款清零（grep 实测） → PASS
- [x] VC-3: SKILL 行内联动 wc=543（实测） → PASS
- [x] VC-4: selftest-batch-pilot 10/10 + master 全量 377/0（亲算） → PASS
- [x] VC-5: CHANGELOG 条目在位（Read 实测） → PASS
- [x] VC-6: 三位 IDENTICAL 亲验+push 8fed498+清理完成（实测） → PASS

 outcome: COMPLETE
```

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | 终验 COMPLETE（8fed498 已 push） |
| 2 | Where am I going? | 无剩余 Phase；仅剩交付报告 |
| 3 | What's the goal? | 批量试点先行硬门落地（用户 09-18 训诫） |
| 4 | What have I learned? | findings.md（BP-10 路径教训/接管路由） |
| 5 | What have I done? | progress.md 五 Phase 段 |
| 6 | Which tasks need processing? | v082 属其属主会话收尾（禁碰）；无本会话遗留 |
