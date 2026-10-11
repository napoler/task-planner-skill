# Verification Contract & Phase Gates — task-v128（规则编号预留登记制）

## Goal (1 sentence)

落地「规则编号预留登记制」（Rule 20.6 + rule-reserve.sh 六命令 + 账本 + attest 查重挂点 + selftest 守护 + 追溯登记），全量 selftest 0 FAIL 后合并回 master 并部署 3 实体位（含 v126/v127/v129 合流）。

---

## Verification Contract（终验逐条复验）

- [x] VC-1: `rule-reserve.sh` 六命令行为实测——reserve 空闲/冲突(rc3)/check 双态/next 跳过占用/list 含 contested/land/release 越权(rc4)；append-only 与 jq 降级路径
  Evidence: S2 自测 8/8 + S8 CR 复核（exit 契约 0/3/4/5 实测吻合）+ S9 独立审计 A 组全 PASS（`subagent-state/2-executor.md`、`8-executor.md`、`9-executor.md`）
- [x] VC-2: `attest-plan.sh` 挂点四态 + fail-open——F1 空闲自动登记 / F2 contested WARN+next / F3 STRICT exit 2 / F4 未声明计划新旧输出逐字节 diff 零 / 脚本缺失 SKIPPED 继续
  Evidence: S3 fixture 全过（`subagent-state/3-executor.md`）+ S9 独立复跑 B 组全 PASS；挂点 +64/-0 零改写
- [x] VC-3: 文档与数据联动——SKILL :75/:158 两锚、CR :135 20.6 子条、模板 :33 `new_rule` 行、账本追溯 6 条并完成首次真实运维（50 land v127 / 51 land v129，contested 解除，next=52）
  Evidence: `skills/task-planner/SKILL.md:75,158`；`references/critical-rules.md:135`；`templates/task_plan.md:33`；`plans/.rule-reservations.jsonl`（8 行=6 种子+2 land）
- [x] VC-4: 守卫与回归——`selftest-rule-reserve.sh` 10/10（含负向牙齿实证）+ registry 48=48 + **合流后全量 48 脚本 48/48 rc=0，ΣPASS=734 ΣFAIL=0**（主进程 bc 独立求和复核）
  Evidence: `subagent-state/5-code-assistant.md`、`7-executor.md`（合流前 46/712）、`12-executor.md`（合流后 48/734）
- [x] VC-5: 独立验证三路——CR **APPROVED**（P0/P1=0）+ 独立行为审计 4/4（六坏输入契约）+ alignment-review **APPROVED**（P0=0）
  Evidence: `subagent-state/8-executor.md`、`9-executor.md`、`10-executor.md`
- [x] VC-6: 合并 + 部署 + 清理 + 簿记——merge **67e6c3f**（--no-ff 智能门，V1-V6 全过）；3 实体位 ALL IDENTICAL；worktree/分支清理；账本运维 commit 31e4230
  Evidence: `smart-merge-back.sh --deploy` 输出（rc=0）；`git worktree list` 仅主仓+v124；`git log` 67e6c3f

---

## Phase Gates

| Phase | 名称 | Status | 证据 |
|-------|------|--------|------|
| 1 | 隔离与基线 | complete | S1 45/702（bc 复核）；worktree@48c6952 |
| 2 | 核心脚本实现 | complete | commit 46bb036（+408）；自测 8/8 |
| 3 | 挂点与文档联动 | complete | commit 1402b64（5 文件 +70/-1）；四态+五锚 |
| 4 | 守卫+回归+数据 | complete | commit b97fde4（3 文件）；46/712 |
| 5 | 独立验证 | complete | CR/审计/对齐三路全过 |
| 6 | 合并+部署+簿记 | complete | merge 67e6c3f；3 位 IDENTICAL；48/734 |

## 🔁 过程修订与偏差登记（诚实登记）
- **B 类修订 ×2**：① 基线 0f077ae→48c6952（v126 并入：45 脚本 702/0、SKILL 449）；② 续进至 38e562e（v127+v129 并入：SKILL 452、47 脚本）——合流后级联重算为 454/48/48；冲突单点（T-主 定数行）按 454 并双 label 解决
- **范围决策**：init-session 提示行豁免不实施（三触点已足，YAGNI 登记）
- **provider 备注**：Verifier/mini 档本日不可用先例 → S1/S7/S12 直接派 executor（22.3①）

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| 复盘报告 §F1 | D2-D5 设计逐条源自 F1 建议（账本/attest 查重/next 建议） | 符合 |
| attest 门控链范式 | 追加段位于既有 gate 之后、hash 写入之前；仅锁定路径 | 符合 |
| 工具脚本范式 | bash+jq+grep 降级；头注释四要素在位（脚本 :2-23） | 符合 |
| 编号全景（46-51） | 账本种子逐字落盘 + 首次真实运维（50/51 land） | 符合 |

## 委派统计复验（Rule 25.4 — 机器统计为事实源）
```json
{"phases_total":6,"phases_delegated":4,"main_direct_count":2,"delegation_rate":0.667,"violations":[],"verdict":"ok"}
```
（原文含 main_direct 两条=Phase 1〔worktree 建立·白名单①〕与 Phase 6〔白名单①②③〕；均带编号标识 self_declared=0）
- [x] 直做理由均命中白名单 → **WHITELIST-EXEMPT 放行**（rate 0.667 < 0.7）；S-unit 级 12 次派发（S1-S12）全单一目标

## 质量门控统计（Rule 26）
- [x] Q1-Q6：触发 **0** 项 / 豁免 0 / 未处置 0（CR 2 项 P2 已登记不阻断、审计确认定档合理）
- [x] Evidence 抽查 ≥3：① checkpoint 1/5/7 executor 逐行求和三连（702→712→734）② CR 报告 20 路并发 append 无撕裂 + exit 契约四点实测 ③ S9 六坏输入契约表 ④ 部署位 3×rule-reserve.sh 在位实测
- [x] 未处置违规：无 → 无需降级

## Goal Gate（终验）
```
## Goal Verification — 落地规则编号预留登记制（Rule 20.6）
对照 Verification Contract 逐条复验：
- [x] VC-1: 六命令+append-only+降级 → PASS（三路证据）
- [x] VC-2: 四态+fail-open+零改写 → PASS
- [x] VC-3: 五锚+账本 6 种子+首次运维 → PASS
- [x] VC-4: 10/10+48=48+48/48 734/0 → PASS
- [x] VC-5: CR/审计/对齐三路 → PASS
- [x] VC-6: merge 67e6c3f+3 位 IDENTICAL+清理+簿记 → PASS

 outcome: COMPLETE
```

> **验证独立性**：CR/独立审计/alignment 由 3 个全新独立会话执行；回归由独立 executor 执行、主进程独立求和复核（2026-09-26 裁决）

---

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | 交付完成（全 Phase complete；merge 67e6c3f；3 位已部署） |
| 2 | Where am I going? | 无——后续项见 delivery-summary §5（v125 改号提醒 / F2/F3/F4/F6） |
| 3 | What's the goal? | 编号竞态机制化（用户「处理」= 复盘推荐 #1） |
| 4 | What have I learned? | 见 findings.md（R1-R7 + §设计冻结） |
| 5 | What have I done? | 见 progress.md（P1-P6 全回填） |
| 6 | Which tasks need processing? | plans/INDEX.md（v124 在途；v125 待启动需改号 50→52） |
