# Verification Contract & Phase Gates

## Goal (1 sentence)
为 task-planner 技能落地思维方法论（methodology §思维方法论 T1-T5：问题先行/解构四问/金字塔原理/逐步推导剖析/消费点）+SKILL 三处联动+plan-writer 契约行+守护扩展，Code Review Gate 三轮收敛后合并部署三位。

---

## Verification Contract（终验复验 2026-09-18）

- [x] VC-1: methodology.md §思维方法论 T1-T5 五条在位（五字段齐全）纯追加；机械联动 7 处（L3/L4/L5/L13/L170/L173/L174），git diff 删除行逐一核对=联动行本身零语义删除；「9 条」清零/「14 条」×4
  Evidence: master methodology.md:90-155（§思维方法论）；worktree diff numstat +66/-7 与 +4/-2（SKILL）；grep 实测 `^### T[1-5]`=5、"9 条"=0、"14 条"=4
- [x] VC-2: SKILL.md 三处（Poka-Yoke 行内 §R1/R2/§思维方法论、计划确认后新增解构 bullet、Methodology 指针行内补 5 条），净增 2 行 wc=545≤548
  Evidence: master SKILL.md:81/83/299；`wc -l`=545；三处 ≤548 断言 PASS（全量含）
- [x] VC-3: plan-writer.md 产出契约表新增 T2 四问契约行
  Evidence: master plan-writer.md:117（knowledge_brief 行后）；M-16 断言 PASS
- [x] VC-4: selftest-methodology.sh M-12..M-16 扩展（11→16）全 PASS；Code Review Gate 三轮收敛 **APPROVED**（轮 3 含突变实测：删 T3 节→M-12 FAIL 16=15+1，基线 16/16 双向核对）；worktree 全量 382/0（主进程对检查点表 bc 亲算）且合并后 master 全量 382/0（23 脚本全 rc=0，/tmp/v084-master-suite.txt）
  Evidence: subagent-state/7{,b,c}-code-reviewer-*.md；/tmp/v084-master-suite.txt；selftest-methodology Total: 16 PASS=16 FAIL=0
- [x] VC-5: 仓库根 CHANGELOG.md 条目在位
  Evidence: master CHANGELOG.md:12「思维方法论（task-v084）」条目全文
- [x] VC-6: 3 实体位 diff -r IDENTICAL 主进程亲验；origin/master push；worktree/分支清理
  Evidence: diff -r 三位亲验 IDENTICAL（~/.zcode、~/.claude、~/.config/opencode）；push 见终验输出；`git worktree list` 仅剩主仓；分支已删

**终验规则**: 6/6 VC 通过 + Code Review APPROVED → **COMPLETE**

---

## Phase Gates

### Phase 1: 调研定稿与基线
**Goal**: 现状盘点+条款定稿+锁定
**Done when**: T1-T5 定稿落 findings+attest 锁定
- [x] V-1.1: 五字段范式对齐+联动审计 6 处清单
- [x] V-1.2: attest 锁定 SHA 7aed53c3（首跑正确拦截 P4 缺 S-unit 表→计划期补 S6/S7）
Status: `complete` Last verified: 2026-09-18

### Phase 2: worktree 创建+条款落地
**Goal**: §思维方法论+SKILL 三处落地
- [x] V-2.1: T 锚×5+零语义删除（删除行恰为 7 处联动）
- [x] V-2.2: SKILL wc=545 净增 2
Status: `complete` Last verified: 2026-09-18

### Phase 3: 契约行+守护+CHANGELOG
- [x] V-3.1: plan-writer 契约行在位（M-16）
- [x] V-3.2: selftest-methodology 16/16
Status: `complete` Last verified: 2026-09-18

### Phase 4: 全量回归+Code Review Gate
- [x] V-4.1: 全量 382/0（检查点表 bc 亲算，子代理自报弃用）
- [x] V-4.2: CR 轮 1 CR(4)→轮 2 CR(3)→轮 3 APPROVED（突变实测）
Status: `complete` Last verified: 2026-09-18

### Phase 5: 合并部署+簿记收尾
- [x] V-5.1: master 全量 382/0
- [x] V-5.2: 三位 IDENTICAL 亲验+push+清理
Status: `complete` Last verified: 2026-09-18

---

## 📚 必要知识储备符合性核验
| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| methodology.md 五字段范式 | T1-T5 逐字段对照 R/Q 条款 | 符合 |
| selftest hermetic 范式 | M-12..16 照 fixture 口径+补 plan-writer 镜像 | 符合 |
| 31.2/R4 错误侧边界 | T2 同法不同时交叉引用（M-13 钉） | 符合 |
| plan-writer 契约表 | 四问行插 knowledge_brief 后 | 符合 |

## 委派统计复验（Rule 25.4）

JSON 输出：
```json
{"phases_total":5,"phases_delegated":1,"main_direct_count":4,"delegation_rate":0.200,"violations":[],"verdict":"ok"}
```
- [x] 主进程直做白名单理由：P1=③②、P2/P3=⑤（22.3④ 兜底接管，code-assistant 本会话 2 连败实证）、P5=①②；P4 实派 code-runner-agent（mini）+Code Reviewer 三轮
- [x] 初判 violation 根因=Handoff 表未填（22.5 遗忘）+Executor 字段混入复合描述（v081 教训复现）→ 补 Handoff 两行+Executor 字段干净化后 verdict=ok
- [x] WHITELIST-EXEMPT 口径：rate 0.2<0.7 但全直做理由在白名单（verdict=ok）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 核查：触发 0 项，未处置 0 项（Batch Report 零单元逃生；本任务编辑单件串行+逐件验证=18.9 自证）
- [x] Evidence 抽查 3 条：①methodology.md §思维方法论五锚 ②/tmp/v084-master-suite.txt 23 行 Total（bc=382）③CR 轮 3 突变实测原始行（16=15+1）——可复现
- [x] 无豁免、无未处置违规

## Goal Gate (终验)

```
## Goal Verification — 思维方法论落地并合并部署
- [x] VC-1: §思维方法论 T1-T5+联动 7 处零语义删除 → PASS
- [x] VC-2: SKILL 三处净增 2（545≤548） → PASS
- [x] VC-3: plan-writer 四问契约行 → PASS
- [x] VC-4: 16/16+全量 382/0（双端亲算）+CR APPROVED → PASS
- [x] VC-5: CHANGELOG 条目 → PASS
- [x] VC-6: 三位 IDENTICAL 亲验+push+清理 → PASS

 outcome: COMPLETE
```

---

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | 终验 COMPLETE（871e71a 已合并，push 见输出） |
| 2 | Where am I going? | 无剩余执行动作，仅交付报告 |
| 3 | What's the goal? | 思维方法论 T1-T5 落地（用户 09-18 纪律） |
| 4 | What have I learned? | findings（CR 三轮 7 处/突变实测价值/Handoff 表机器口径） |
| 5 | What have I done? | progress 五 Phase 段 |
| 6 | Which tasks need processing? | 无本会话遗留 |
