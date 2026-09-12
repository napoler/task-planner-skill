# Verification Contract & Phase Gates

## Goal (1 sentence)

把 task-v062 调研的 9 条可操作方法论（可靠性侧 R1-R4 + 内容质量侧 Q1-Q5）以「门控点+指针+references/methodology.md+config 开关键+selftest 守护」增量引入 task-planner 技能，不改 Rule 1-28 既有语义，合并回 master 后重部署 3 位 + plan-writer 2 位对齐。

---

## Verification Contract (7 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [x] VC-1: methodology.md 成文：可靠性侧 4 条（Poka-Yoke/FMEA/checkpoint.jsonl/chunk≤3）+ 内容质量侧 5 条（三级引用/交叉验证/去 AI 化 10 条/五维评分卡/8 字段契约），每条五字段；FMEA 段含 RPN=S×O×D 表模板、Poka-Yoke 段含前置条件函数、checkpoint.jsonl 段含断点协议、去 AI 化段含 10 条清单、五维评分卡段含权重表与阈值
  Evidence: `skills/task-planner/references/methodology.md`（176 行，commit 32d0d9e）；终验抽查 `wc -l` = 176；findings.md [sub:02-plan-writer] 自查 `grep -c '出处|映射|惩罚'`=34、`^### |^## `=13、9 条五字段齐
- [x] VC-2: 模板联动：`templates/task_plan.md` 在「🔀 隔离决策」段后插「## 📊 FMEA 预演（规划期）」段（7 列 RPN 表 + RPN>100 须登记兜底说明）；`templates/variant/writing-type.md:63` Phase 3.5 行扩为 quality-reviewer 审查（含去 AI 化清单+五维评分卡门控）；grep 两处各 =1
  Evidence: 终验抽查 `grep -c "FMEA 预演" templates/task_plan.md`=1、`grep -c "五维评分卡" templates/variant/writing-type.md`=1；commit 9072009（task_plan.md +15/-0、writing-type.md +1/-1）；findings.md [sub:03-code-assistant]
- [x] VC-3: SKILL.md 联动：Poka-Yoke 前置条件指针 + 内容质量门控指针 + Critical Rules 摘要区 methodology 行；grep "methodology" SKILL.md ≥3
  Evidence: 终验抽查 `grep -c methodology SKILL.md`=3（:82 前置检查 / :156 内容质量门控 / :283 摘要行）；commit f1341c2（SKILL.md +4/-0）；主仓探针（Phase 8 S1）复现 =3
- [x] VC-4: config 开关键：`config.json` 新增 `fmea_enforce` / `content_quality_enforce`（enum enforce/warn/off，default warn），写入 properties（additionalProperties:false 生效）；selftest-methodology.sh 守护 ≥6 用例全过
  Evidence: 终验抽查 `jq '.properties|keys|length'`=24（原 22+2），`jq` 两键 default=`warn`、enum=`["enforce","warn","off"]`；`bash scripts/selftest-methodology.sh` = `Total: 7 PASS=7 FAIL=0`（M-05/M-06/M-07 见输出）；commit 01e936e（config +20/-0）+ 119dcff（selftest +96/-0）
- [x] VC-5: 无回归：6 套既有 selftest 106 用例口径 fail=0 + selftest-methodology 全过 + verify.sh 无新增 fail（中性 CWD /tmp）
  Evidence: 7 套逐套 EXIT=0 — active-plan 13/13、delegation 38/38、dispatch 18/18、fallback 21/21、interaction 10/10、plan-dispatch 6/6、methodology 7/7 = 合计 **113 用例 0 fail**；verify.sh 基线对照实测 `git archive 1df5bb4` = 25 pass/0 fail，本轮 worktree 中间态 22 pass/3 fail（3 项 deploy drift，成因=canonical 领先未重部署，Phase 8 S2 重部署后消除 → 25/0×3）；findings.md [sub:07-code-reviewer] §S1
- [x] VC-6: 合并回 + 部署对账：task-planner 3 位 diff IDENTICAL + verify 25/0×3；plan-writer agent 2 位对齐；companion 技能 6 位无新差异
  Evidence: merge commit `9f89908`（--no-ff，parents 51b3057/119dcff，7 files +315/-2）；worktree `remove` + `branch -d`（was 119dcff）0 残留；3 部署位 `diff -rq` 全 **IDENTICAL** + 中性 CWD /tmp verify 各 **25 pass/0 fail** + 部署位 selftest-methodology 各 **7 PASS=7 FAIL=0 EXIT=0**；plan-writer `/home/terry/.zcode/agents/plan-writer.md` diff 空 + md5 `f9a55d9a28b0bfb7c661f4bd3decda9e` 逐字节一致，`/home/terry/.claude/agents/plan-writer.md` 仅 `model:` 行差异（adapt_model_line 预期）；companion 6 位 `diff -rq` 全 0 行；findings.md [sub:08-executor-deploy]
- [x] VC-7: 全程隔离与簿记：全程 worktree 隔离、worktree 清理、Rule 27 逐 Phase 提交、INDEX/attest/ledger 齐备
  Evidence: worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v063-methodology-intro`（branch `wt/task-v063-methodology-intro`）；5 个 Phase 提交链 `32d0d9e`(P2) → `9072009`(P3) → `f1341c2`(P4) → `01e936e`(P5) → `119dcff`(P6) → merge `9f89908`(P8)；`git worktree list` 仅剩主仓 + 其他并行任务位（无 v063 残留）；Subagent Handoff 表 8 行补登；attest 重锁；`ledger-main.jsonl` Phase 1 记录；INDEX.md 补 v063 行

---

## Phase Gates

> 执行序不按编号（Phase 2/3/4/5/6 为并行子代理派发；Phase 7 → 8 → 9 串行）。全部 Phase 的 Status 已在 task_plan.md 置 `complete`，对应 progress.md 段与 findings.md [sub:NN] 段已回填（Rule 19.2）。

| Phase | Name | Done when | Verification | Status | Last verified |
|-------|------|-----------|--------------|--------|---------------|
| 1 | 基线复核与计划定稿 | worktree @1df5bb4；writing-type.md 基线核对；session_id 回填；attest 锁定 | attest SHA c34847f1；worktree HEAD=1df5bb4 | complete | 2026-09-12 |
| 2 | 新建 references/methodology.md | 9 条五字段全文 + Rule 关系段 | wc -l=176；五字段齐；grep 出处\|映射\|惩罚=34 | complete | 2026-09-12 |
| 3 | 模板联动 | task_plan 模板 FMEA 段 + writing-type:63 扩 | grep 各=1；diff 仅 2 处；commit 9072009 | complete | 2026-09-12 |
| 4 | SKILL.md 3 处指针 | 3 指针插入 + 摘要行 | grep methodology=3；commit f1341c2 | complete | 2026-09-12 |
| 5 | config +2 键 + README | 两键 properties + 默认 warn + README 21 项 | jq keys=24；既有 22 键零改动；commit 01e936e | complete | 2026-09-12 |
| 6 | selftest-methodology.sh | 新套件 ≥6 用例 hermetic 全过 | 7 PASS=7 FAIL=0 EXIT=0 两遍一致；commit 119dcff | complete | 2026-09-12 |
| 7 | 全量自测 + Code Review Gate | 113 用例 0 fail + CR APPROVED | 7 套 EXIT=0；CR APPROVED（P0=0/P1=0/P2=4/P3=4） | complete | 2026-09-12 |
| 8 | 合并回 + 重部署对账 | merge + 3 位重部署 + agent/companion 对账 | merge 9f89908；IDENTICAL×3 + 25/0×3 + 7/7×3 | complete | 2026-09-12 |
| 9 | 簿记收尾与交付 | VC-1..7 终验 + INDEX/attest + 簿记 commit | 本文件 + INDEX.md + attest 新 SHA | complete | 2026-09-12 |

---

## 📚 必要知识储备符合性核验（终验项）
<!-- WHEN: 终验时逐条核对「必读」知识源是否被实际遵循 -->
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| 方法论调研结论（9 条+出处）——task-v062-interaction-modes/findings.md「方法论调研」段 | methodology.md R1-R4/Q1-Q5 逐条对照（9 条）与出处字段 | 符合（9 条齐；ISO 21434 等 6 项出处链接标「待补」如实登记，未编造——CR P2④ 已记录） |
| 嵌入点调研报告（Explore） | FMEA 段插入位置（隔离决策后/原生 Todo 同步前）、SKILL.md :81/:156、config properties、selftest 布局对照实测 | 符合（3 处口径不符以实测 grep 为准，见 findings Issues 段） |
| interaction_mode 键范式（v062 交付物） | fmea_enforce/content_quality_enforce 的 enum+default+description+selftest 守护形态对照 | 符合 |
| 部署拓扑 memory task-planner-repo-deploy-flow.md | 3 部署位 + plan-writer agent 2 位对齐口径 | 符合（本次复现：IDENTICAL×3 + md5 逐字节 + 仅 model 行） |
| writing-type.md 现有 Phase 结构 | :63 Phase 3.5 行原地扩写（不新增 Phase，不重编号） | 符合 |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash <skill>/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

```bash
# 证据（粘贴以下 JSON 原文）
bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-v063-methodology-intro
```

JSON 输出：
```json
{"phases_total":9,"phases_delegated":7,"main_direct_count":2,"delegation_rate":0.778,"main_direct":[{"phase":"1 基线复核与计划定稿","executor":"主进程（例外理由:① git/worktree 编排 + ③ 机械验证命令——Rule 25.3 白名单）","reason":"例外理由:① git/worktree 编排 + ③ 机械验证命令——Rule 25.3 白名单","needs_git_evidence":0,"self_declared":0},{"phase":"9 簿记收尾与交付","executor":"主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单）","reason":"例外理由:② 计划系统文件维护——Rule 25.3 白名单","needs_git_evidence":0,"self_declared":0}],"violations":[],"verdict":"ok"}
```

- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单）：Phase 1（① git/worktree 编排 + ③ 机械验证命令）、Phase 9（② 计划系统文件维护）
- [x] 委派率 **0.778 ≥ config.json#delegation_rate_floor(0.7)**，`verdict=ok`、`violations=[]` → 不触发 check-complete.sh 阻断，**无需降级或 WHITELIST-EXEMPT 标注**

> **口径修正（2026-09-12 Phase 9）**：派发 brief 预估「子代理 6 Phase / 委派率 0.667 / 标注 Rule 25.4a WHITELIST-EXEMPT」，与实测不符——Phase 2-8 共 **7 个** Phase 均为子代理执行（brief 列举 2/3/4/5/6/7/8 即 7 项），机器口径 `0.7778≈0.778` ≥ 0.7 floor → `verdict=ok`。以机器统计为事实源，brief 预估偏差已登记 progress.md Error Log + task_plan.md 委派统计段。

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成：触发 **0 项**，豁免 **0 项**，未处置 **0 项**（本轮交付无降质触发：Code Review P0=0/P1=0；委派率 0.778 ≥ floor；无证据不实/无跳过门控）
- [x] Evidence 抽查 ≥3 条（终验 2026-09-12 主进程第一手 Repro）：① `wc -l skills/task-planner/references/methodology.md`=176 ② `grep -c methodology SKILL.md`=3 ③ `jq '.properties|keys|length' config.json`=24 + 两键 default=warn/enum 三态 ④ `grep -c "FMEA 预演" templates/task_plan.md`=1、`grep -c "五维评分卡" templates/variant/writing-type.md`=1 ⑤ `bash scripts/selftest-methodology.sh` = `Total: 7 PASS=7 FAIL=0`（M-05/M-06/M-07 PASS 实测）——路径均可 Read、结论可复现，抽查记录见 progress.md Phase 9 段
- [x] 豁免登记：无（无用户显式文字豁免；Q3 不适用）
- [x] 无未处置违规 → outcome 维持 COMPLETE（未降级 PARTIAL/BLOCKED）

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 9 条方法论以门控+指针增量引入 task-planner（不改 Rule 1-28 语义）+ 合并回 + 重部署
对照 Verification Contract 逐条复验：
- [x] VC-1: references/methodology.md 176 行 9 条五字段（commit 32d0d9e）→ PASS
- [x] VC-2: 模板 FMEA 段 + writing-type:63 扩，grep 各=1（commit 9072009）→ PASS
- [x] VC-3: SKILL.md 3 指针，grep methodology=3（commit f1341c2）→ PASS
- [x] VC-4: config keys=24 + 两键 default warn + selftest 7/7（commit 01e936e/119dcff）→ PASS
- [x] VC-5: 113 用例 0 fail（既有 106 + 新增 7）+ verify 基线 25/0→重部署后 25/0×3 → PASS
- [x] VC-6: merge 9f89908（7 files +315/-2）+ 3 位 IDENTICAL + verify 25/0×3 + agent 2 位/companion 6 位对账 → PASS
- [x] VC-7: worktree 隔离 + 5 提交链 + Handoff 8 行 + INDEX/attest/ledger → PASS

 outcome: COMPLETE
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。

已知遗留（均非本轮引入的 P0 阻断，登记后续轮；对应 Route: 后续轮）:
- ① `lib/verify.sh:227` §9 循环未含 `selftest-methodology.sh`（CR P2③；新套件未纳入 deploy 一致性校验循环）
- ② `references/methodology.md:137`（Google DeepMind 2023）/`:158`（Anthropic Claude Code 2024 内部规范）2 处出处不可核，建议泛化表述 + 保留待补登记（CR P2④）
- ③ `references/methodology.md:4/:173` 锚点 `SKILL.md:81` 实为 `:82`（P2①，一行差，免行号漂移可改标题锚点）
- ④ `/home/terry/.zcode/skills/plan-resume` ABSENT（plan-resume@.zcode 历史缺位；companion 6 位中 5 位，v062 遗留①，非本轮引入）

> 备注（观察项，非 v063 缺陷）：master 侧存在 1 个空提交 `51b3057`（"init"，author `t <t@t.io>`，无文件变更），为 merge `9f89908` 第一父；非 v063 worktree 提交链产物，不影响本任务交付物，仅登记供用户知悉。

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase 9 complete（全部 9 Phase done） |
| 2 | Where am I going? | 已交付；遗留 ①-④ 排后续轮 |
| 3 | What's the goal? | 9 条方法论门控+指针增量引入 + 合并回 + 重部署 |
| 4 | What have I learned? | See findings.md |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区（task-v063 已 complete，无 pending） |
