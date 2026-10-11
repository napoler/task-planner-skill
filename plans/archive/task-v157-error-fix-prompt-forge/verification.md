# Verification Contract & Phase Gates — task-v157-error-fix-prompt-forge

## Goal (1 sentence)
在仓库新建顶层执行型 skill `error-fix-prompt-forge`：把已完成根因定位的错误排查调研结果，经输入校验→结构化抽取→缺口分析→模板渲染→自包含自检五步闭环，转化为可直接派发子代理执行修正的专业任务书（fix prompt），含 selftest 守护与三宿主部署，全量回归零 FAIL。

---

## Verification Contract 终验复验（逐条）

- [x] VC-1: `skills/error-fix-prompt-forge/SKILL.md` 存在且含触发条件/输入契约/五步流程/门控铁律/输出合约/反模式六区块
  Evidence: 文件 84 行；`grep -c` 六区块锚命中 7 ≥6（selftest FP-02）；三态 READY/PARTIAL/BLOCKED 与 QC-FP-1..6 在位（FP-03/04）；主进程 Read 全文复核（Phase 3 S1 验收 7/7）
- [x] VC-2: `skills/error-fix-prompt-forge/templates/fix-prompt-template.md` 存在且九槽位+DoD 覆盖根因证据锚/复现/范围/禁改区/机器可检查验收/回滚/未验证假设区
  Evidence: 文件 49 行；槽位 grep 各 ≥1（selftest FP-05 逐词 8/8 命中）；主进程 Read 全文复核（Phase 3 S2 验收 6/6）
- [x] VC-3: `skills/task-planner/scripts/selftest-error-fix-prompt-forge.sh` 存在、可执行、8 断言全 PASS；registry 末行登记
  Evidence: `bash selftest-error-fix-prompt-forge.sh` → `Total: 8 PASS=8 FAIL=0` exit 0（主进程复跑 ×3 一致，含 CR 加固版与宿主部署位副本）；registry.tsv 67→69 行（v155 行并集在前，本任务行在后），`selftest-registry.sh` `Total: 5 PASS=5 FAIL=0 (registry rows=68, actual selftest=68)`
- [x] VC-4: 行为冒烟产物通过 QC-FP 自检表，三态结论显式
  Evidence: `subagent-state/04-executor/fix-prompt-sample.md`（39 行，九槽位/绝对路径 8 行/单 S-unit/grep 机器验收）+ `qc-fp-selfcheck.md`（QC-FP-1..6 全 PASS，结论 READY）；主进程 Read 双产物复核；Rule 43.5 提示词类实际生成测试满足
- [x] VC-5: 全量 selftest 回归 FAIL=0（含新增脚本与级联计数）
  Evidence: Round 3（修复后 worktree）66 脚本 FAIL=0；Round 6（合并 master 后）68 脚本 836 断言 FAIL=0；MASTER-FINAL（合并回后主仓复跑）68 脚本 836 断言 FAIL=0；宿主位（~/.zcode）跑 selftest-error-fix-prompt-forge.sh exit 0
- [x] VC-6: worktree 合并回 master；部署位 diff IDENTICAL；簿记完整
  Evidence: merge commit `6d46d3ec`（smart-merge-back --no-ff，V1-V6 全过）；`diff -r skills/error-fix-prompt-forge` vs ~/.zcode、~/.claude、~/.cursor 三宿主位 → IDENTICAL×3；task-planner 本体三位（zcode/claude/opencode）smart-merge-back --deploy → 全部 IDENTICAL；INDEX/ledger/Drift Log/attest 簿记在位

**终验规则执行**：全部 VC 通过 → outcome: **COMPLETE**

## Phase Gates

### Phase 1: 存量能力侦察 — complete（04:30，explore）
V-1.1/V-1.2 → VC-1/VC-4 判据来源落地（findings [sub:01-explore] 边界 6 条+fixture 形态）

### Phase 2: 设计定稿 — complete（05:00，主进程白名单②）
V-2.1/V-2.2 → 设计规格落 knowledge-brief §5（Phase 3 编写唯一依据）+ Technical Decisions 3 条

### Phase 3: 编写三件 — complete（06:00，code-assistant ×3 + 级联修复）
V-3.1/V-3.2/V-3.3 → VC-1/2/3；alignment-review APPROVED（P0/P1=0）；Round 1 级联→Round 3 归零

### Phase 4: 冒烟+回归 — complete（06:40，executor 冒烟 + 主进程白名单③回归）
V-4.1/V-4.2/V-4.3 → VC-3/4/5；冒烟 READY；Round 4-6 回归 FAIL=0

### Phase 5: 合并+部署+CR+终验 — complete（07:40，主进程白名单①+②）
V-5.1/V-5.2 → VC-5/6；CR Gate APPROVED+P1/P2 修复轮；合并回 6d46d3e；三宿主 IDENTICAL

## 📚 必要知识储备符合性核验（终验项）

| 必读知识源 | 核验方式(交付物对照点) | 结论 |
|-----------|----------------------|------|
| task-planner 派发纪律（22.4/59/46/22.4c） | 全部 8 次派发过 check-dispatch 契约门（1 次超长按 35.3 落盘任务书后通过）；S-unit 粒度三值/前置依赖列齐 | 符合 |
| iterative-optimizer SKILL.md 范式 | 新 SKILL.md 六区块结构同构；selftest SCRIPT_DIR/ok()/bad()/Total/exit 同构 | 符合 |
| v106 交付先例 | selftest 落位 task-planner/scripts（T03 实证后平移）；install-companion 部署；registry 追加 | 符合（selftest 位置按 registry 实际计数口径修正并登记 Decisions） |
| fix-prompts.md fixture | 冒烟实际消费（Step 0-4 全跑） | 符合 |

## 委派统计复验（Rule 25.4）

机器统计（check-delegation.sh stats，facts source）：

```json
{"phases_total":5,"phases_delegated":2,"main_direct_count":3,"delegation_rate":0.400,"verdict":"ok"}
```

- 主进程直做 Phase：2（②规划/簿记）、4（S2 回归=③机械验证命令，S1 冒烟为 executor 派发）、5（①git/worktree 编排+②簿记）——全部白名单内
- verdict=ok；delegation_rate 0.4 < floor 0.7 但直做理由全部命中 Rule 25.3 白名单 → WHITELIST-EXEMPT（check-complete 不阻断）
- 治理登记：本轮 Executor 字段曾带档位后缀致 stats violation（explore(mini) 等），已按 Rule 51.7 登记 Decisions 后规范化裸名并重签 attest（SHA e6cae0e0）→ 复跑 verdict=ok。v150「Handoff 裸名」教训本轮复发一次，已修

## 质量门控统计（Rule 26）

- Q1（范围外文件修改）:未触发——scope 外零写入（8 文件全在计划 scope+授权级联修复范围）
- Q2（造谣/无据结论）:未触发——全部结论附 file:line/命令输出
- Q3（伪造证据）:未触发——全部数据主进程复跑/复算（冒烟绝对路径行数自报 7 vs 复算 8 已如实登记偏差，不伪造）
- Q4（静默降级）:未触发——两处降级（drift-checker provider 拒→61.5 佐证；subagent 只读→主进程代写）均显式登记
- Q5（未测先完成）:未触发——VC 逐条复验后才翻 complete
- Q6（漂移）:4 次 drift 检查全 ALIGNED（降级路径已常态化登记）
- Evidence 抽查 3 条：VC-3 命令输出（复跑一致）/VC-4 产物 Read/VC-6 diff IDENTICAL 输出 —— 均可复现

## Goal Gate（终验）

```
 outcome: COMPLETE
```

## 需求覆盖核对表（Rule 51.3 — 交付终态）

| R | 需求原文 | 覆盖 VC | 覆盖证据 | 状态 |
|---|---------|---------|---------|------|
| R1 | 「创建一个skill」 | VC-1/2/3/5/6 | 三件文件在位含锚+selftest 8/8+部署 IDENTICAL+合并 6d46d3e | covered |
| R2 | 「对错误排查调研 将排查结果 并且生成提供专业的提示词 用于后期的修正」 | VC-4（问题解决判据）+VC-1..3 | 冒烟实际生成 fix prompt 样例 READY（QC-FP 6/6）；「核心目标达成裁决」=solved | covered |

## 遗留登记（不阻断 COMPLETE）

1. skill 行为面收敛质量依赖排查结果包质量（首实战后回灌，迭代优化路径=iterative-optimizer）
2. 宿主位 frontmatter 为快照语义，新 skill 生效需新会话（install-companion NOTE 已明示）
3. v150 「Handoff 裸名」教训本轮复发一次（ Executor 档位后缀致 stats violation），已修+复跑 verdict=ok；建议后续任务写计划时 Executor 字段直接裸名（本条已入 final report 建议）

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | Phase 5 complete，终验通过，outcome=COMPLETE |
| 2 | Where am I going? | 交付收尾：delivery-summary+check-complete+报告 |
| 3 | What's the goal? | 新建 error-fix-prompt-forge skill 并交付 |
| 4 | What have I learned? | findings.md（8 个小节）+knowledge-brief §5 |
| 5 | What have I done? | progress.md（Phase 1-5+Round 1-6） |
| 6 | Which tasks need processing? | plans/INDEX.md（v152/v154/v155/v156 等在册任务非本任务范围） |
