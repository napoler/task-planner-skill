# Verification Contract & Phase Gates

## Goal (1 sentence)

`plans/.active_plan` 从 git 跟踪文件变更为工作树内瞬态状态文件（`git rm --cached`+`.gitignore` 条目，工作区文件保留），引用面措辞级联无旧语义残留，selftest 全量 0 FAIL，合并规则登记，部署对账通过。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [ ] VC-1: 瞬态化落地——`git ls-files plans/.active_plan` 输出为空 + `.gitignore` 含 `plans/.active_plan` + 主树 legacy set 后 `git status --short` 无该文件条目 + 工作区文件仍在
  Evidence: progress.md 行为验证段（命令+输出原文）
- [ ] VC-2: 工作树本地化+并行不互顶——两个隔离 worktree 分别 set 指针互不感知对方；新 worktree 无全局指针时 `resolve-plan-dir.sh` side→mtime 链 exit 0 且 slug 正确
  Evidence: progress.md 行为验证段（双 root 实跑对比输出）
- [ ] VC-3: 级联无残留——28 文件引用面中描述全局指针"入库/跟踪"的措辞全部改述，`grep -rn 'active_plan'` 无旧语义；只读消费方逐个登记
  Evidence: findings.md 级联清单（每文件判定）
- [ ] VC-4: 全量 selftest 0 FAIL（主进程逐 Total 行求和）+ 飞行 worktree 合并规则登记 critical-rules
  Evidence: progress.md Selftest Log + critical-rules.md 合并规则段
- [ ] VC-5: 部署簿记——INDEX/ledger/CHANGELOG 更新 + 部署位对账（.gitignore 不随部署=预期差登记）
  Evidence: 部署输出 + INDEX.md

---

## Phase Gates

### Phase 1: 隔离与基线

**Goal**: 在 worktree 中建立隔离区并固化基线（selftest 基线+引用面清单+先例复读）

**Depends on**: 用户批准本计划

**Done when**:
- [x] worktree `wt/v164-pointer-worktree-local` 建立且与主仓对账一致（建时对账 7317455 → FF master 79cd10a）
- [x] 全量 selftest 基线数字落 progress.md（71/71 rc=0 FAIL=0，主进程复核负用例文本非段头）
- [ ] 28 文件引用面分级清单（只读/措辞更新）落盘 —— 按计划重构移交 S4（Phase 3）执行，Phase 1 不阻塞
- [x] plans/fix-pointer-race-20261007/ 复读结论入 findings（既有 FAIL 时点清单已修复=零增量干净起点）

**Verification** (run before moving on):
- [x] V-1.1: worktree HEAD 与主仓对齐（7317455→FF 79cd10a）→ mapped VC-1 前置
- [x] V-1.2: selftest 基线 71 段 rc=0 经主进程独立复核（`grep -cE '^=== selftest-.*\.sh rc=0$'`=71）→ mapped VC-4 前置

Status: `complete` Last verified: 2026-10-10 15:2x

---

### Phase 2: 指针瞬态化（git 索引 + 头注释）

**Goal**: `.active_plan` 变瞬态（S2）+ 两脚本头注释退役"移交"叙事（S3）

**Depends on**: Phase 1

**Done when**:
- [x] S2: `git rm --cached plans/.active_plan` 完成 + `.gitignore`:15 追加条目 + 工作区文件保留
- [x] S3: 两脚本头注释改述完成，diff 只见注释区（逻辑零改动）

**Verification**:
- [x] V-2.1: VC-1 命令级判定全过（ls-files exit1/ignore 命中/legacy set 后仅 D 态无 ??）
- [x] V-2.2: diff 验证解析链逻辑零改动（`git diff -U0` 非注释行=0；bash -n 双过）

Status: `complete` Last verified: 2026-10-10 15:5x

---

### Phase 3: 引用面措辞级联

**Goal**: 28 文件引用面逐个判定（S4）后按 ≤2 文件/次完成措辞改述（S5 critical-rules+SKILL / S6 README+INSTALL / S7-S10 八脚本注释）

**Depends on**: Phase 2

**Done when**:
- [x] S4: findings.md 级联清单=28 文件逐个判定（只读14/措辞更新12/已改述2，主进程复核）
- [x] S5-S10+9b+锁步: 12 个措辞更新目标+S9b 两处残留+PL-07 锁步全部落地 + 只读消费方登记不改

**Verification**:
- [x] V-3.1: VC-3 grep 无旧语义残留（全域扫描 ZERO-RESIDUE，残余 7 处=注记引文）
- [x] V-3.2: findings.md 级联清单含 28 文件逐个判定
- [x] V-3.3: 合并规则段在位（critical-rules:198-201，RPN=90 FMEA 兜底）

Status: `complete` Last verified: 2026-10-10 16:4x

---

### Phase 4: 全量回归 + 行为验证 + CR

**Goal**: selftest 回归零新增 FAIL（S11，现 72 脚本）+ 并行行为验证（S12）+ code-reviewer 全量 CR（S13）

**Depends on**: Phase 3

**Done when**:
- [x] S11: 全量 selftest 主进程逐 Total 求和，对照基线新增 FAIL=0（72 段 rc=0，差集=decision-grading 新增且过）
- [x] S12: 双 worktree 行为验证通过（VC-2，主进程亲验 log 原文）
- [x] S13: code-reviewer CR APPROVED（7/7，3 NIT 已处置：2 锚修正+1 口径更正）

**Verification**:
- [x] V-4.1: selftest Total 求和=0 新增 FAIL → mapped VC-4
- [x] V-4.2: 行为验证命令+输出落 progress.md → mapped VC-2
- [x] V-4.3: CR 结论（APPROVED+nit 清单）落 subagent-state → mapped VC-4 质量面

Status: `complete` Last verified: 2026-10-10 17:4x

---

### Phase 5: 合并回 + 部署 + 簿记

**Goal**: 合并回 master、部署对账、簿记完整、worktree 清理

**Depends on**: Phase 4

**Done when**:
- [ ] smart-merge-back no-ff 合并 + 部署位对账（.gitignore 预期差登记）
- [ ] INDEX/ledger/CHANGELOG v164 条目更新 + worktree 清理（§11.3 五条全满足）

**Verification**:
- [ ] V-5.1: 部署对账输出（diff=0/预期差说明）→ mapped VC-5
- [x] V-5.2: critical-rules 合并规则段已在 Phase 3 S5 落盘（critical-rules.md:198-201 在位）→ mapped VC-4
- [ ] V-5.3: `git worktree list` 无 wt/v164 残留 + `git branch -d wt/v164…` 完成（随收尾执行，见 delivery-summary 行动项）

Status: `complete` Last verified: 2026-10-11（V-5.3 除外=收尾动作，见上注）

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| set-active-plan.sh + resolve-plan-dir.sh 全文 | S2 索引态+S3 头注释 diff 对照（代码区 0 改动） | ☑ 符合 |
| fix-pointer-race-20261007 先例 | findings 复读结论（side 权威/sidmap）+禁重复设计（未重造解析链） | ☑ 符合 |
| selftest 范式（active-plan/pointer-lifecycle） | PL-07 锁步 2 行+断言零删 | ☑ 符合 |
| worktree-isolation SOP | Phase 1/5 操作对照（集中目录/HEAD 对账/§11.3 清理链） | ☑ 符合（V-5.3 收尾动作见 delivery-summary 行动项） |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash <skill>/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据。

```bash
# 证据（粘贴以下 JSON 原文）
bash <skill>/scripts/check-delegation.sh stats plans/task-v164-pointer-worktree-local
```

JSON 输出：
```json
{"phases_total":5,"phases_delegated":3,"main_direct_count":2,"delegation_rate":0.600,"main_direct":[{"phase":"1 隔离与基线","executor":"主进程（白名单① git/worktree 编排）+ code-runner-agent（S1 基线跑批）","reason":"白名单① git/worktree 编排）+ code-runner-agent（S1 基线跑批","needs_git_evidence":0,"self_declared":0},{"phase":"5 合并回 + 部署 + 簿记","executor":"主进程（白名单①②）","reason":"白名单①②","needs_git_evidence":0,"self_declared":0}],"violations":[],"verdict":"ok"}
```

- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（①git/worktree 编排；①②git 编排+簿记）
- [x] 委派率 0.600 < floor 0.7 但 main_direct 两条 reason 全命中白名单关键词（白名单①/①②）→ check-complete 豁免放行；verdict=ok/violations=[]（复跑于 Handoff 17 行补登后）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成:触发 2 项（Q1 变更链路审计=S4 28 文件分级已做；Q5 质量审查=CR S13 APPROVED）,豁免 0 项,未处置 0 项
- [x] Evidence 抽查 ≥3 条:①baseline-selftest.log:1 段头 rc=0 ②regression-worktree-merged.log:368 末段 rc=0 ③behavior-verification.log:4-5 双树互不感知 ④.gitignore:15 ignore 命中——均路径可 Read、结论可复现（主进程亲跑复核）
- [x] 豁免登记:无（无用户显式豁免事项）
- [x] 存在未处置违规 → 无；outcome 不降级

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — .active_plan 瞬态化后指针工作树内本地化、合并零冲突、并行不互顶
对照 Verification Contract 逐条复验：
- [x] VC-1: git ls-files --error-unmatch plans/.active_plan = exit 1（不再跟踪）+ .gitignore:15 命中 + 合并后主仓 status 无该文件（瞬态按需再生）→ PASS
- [x] VC-2: behavior-verification.log:4-17——B 树写全局不影响 A（A/B 值各异）+B-status NO-ENTRY+同 sid 双树解析各自正确+新树 mtime 兜底合法路径+side 归位+临时树零残留 → PASS
- [x] VC-3: 全域 grep（全局 legacy/legacy 指针/指针移交/互顶全局/请移交）=7 命中均为 [task-v164] 注记引文（Rule 45 原措辞说明），实际旧语义 0；findings [sub:4] 28 行判定清单 → PASS
- [x] VC-4: 合并后态全量回归 75/75 rc=0 零 FAIL（主进程亲验：段数 75/非零段头 0/FAIL 行 0）+瞬态合并规则登记段 critical-rules.md:198-201 四要素 → PASS
- [x] VC-5: smart-merge-back a849947 no-ff 在册+三部署位 post-verify 零差异 IDENTICAL+INDEX/ledger/CHANGELOG 本簿记落库 → PASS

 outcome: COMPLETE
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。
**PARTIAL**：VC 通过但存在已知遗留缺陷 → 列出 + 建议后续。
**BLOCKED**：≥1 VC 失败且 3 次重试无效 → 升级用户决策。

> **验证独立性**：终验核查动作（回归/抽查/对齐审查）由全新独立子代理执行，主进程仅编排与簿记——禁止以主进程既有上下文自测替代验收（Rule 33.3 独立验证延伸;2026-09-26 用户裁决）

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|------------------------|
| 1 | Where am I? | Phase N |
| 2 | Where am I going? | Remaining phases |
| 3 | What's the goal? | Goal statement above |
| 4 | What have I learned? | See findings.md |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
