# Verification Contract & Phase Gates

## Goal (1 sentence)

让 task-planner 具备「专业技能协同路由」能力：复杂任务按信号移交 comet/OpenSpec/superpowers 三族技能协同解决，卡壳时按 Rule 22.3.3 自动评估更适配技能接管，task-planner 专注统筹编排。

---

## Verification Contract（终验复验 2026-09-13）

- [x] VC-1: references/skill-collaboration.md 存在且覆盖四要素（三族画像/触发矩阵/22.3.3/移交合约）
  Evidence: worktree `skills/task-planner/references/skill-collaboration.md`（110 行五节）；grep 三族=3/触发矩阵=1/22.3.3=11/移交(回填)合约=2/skill_collab_enforce=1/command -v comet=3（S1 验收 + selftest-skill-collab T1）
- [x] VC-2: SKILL.md 协同路由段落地（comet 段泛化保留 + OpenSpec/superpowers 触发行 + 指针行 + 行数受控）
  Evidence: SKILL.md 508→510 行（净+2 ≤+10）；L46「🤝 专业技能协同路由」段；L49「任意 3 项」6 条件逐字保留；L52 CLI 探针行；L53 指针行；L314 References 新行；旧标题「🚀 复杂功能开发」grep 无命中（S2 验收 + selftest T2/T3/T10）
- [x] VC-3: critical-rules.md Rule 22.3.3 插入 ④与⑤之间且与 22.7/28.4.1/五档全序无语义冲突
  Evidence: critical-rules.md L126 = 22.3.3（L125 22.3.1/22.3.2 之后、L127 22.4 之前）；L124 五档原文 git diff 零改动；L133 22.7 穷尽集合扩为「①-④ 与 22.3.3 评估」；L134 22.7.1 ② 字段同步；subagent-fallback.sh 两分支 tier_order 6 项含 skill_takeover（S3/S4 验收 + reviewer jq 实测 length==6×2）
- [x] VC-4: config.json skill_collab_enforce 落地（default warn）+ 新 selftest 全绿 + 全量 selftest 0 fail
  Evidence: config.json:91-99 键块（enum enforce/warn/off, default warn, description 含 enforce 预留说明）；selftest-skill-collab 19/19 exit 0（python3 路径 + grep-fallback 模拟双路径均 PASS）；全量 11 套件 selftest 合计 180 例 0 fail + smoke 17/0（Phase 4 全量复跑，基线 159 无回归）
- [x] VC-5: 跨文件一致性（键名/条款编号/指针路径）
  Evidence: grep -rl skill_collab_enforce = config.json + references/skill-collaboration.md + SKILL.md 三处同拼写，变体 skill-collab-enforce =0；22.3.3 分布于 critical-rules/skill-collaboration/SKILL/subagent-fallback/selftest-fallback/selftest-skill-collab/subagent_dispatch 七文件语义一致；指针目标 references/skill-collaboration.md 存在
- [x] VC-6: 合并回主仓 + 9 位部署 diff=0 + worktree 清理
  Evidence: （Phase 5 执行后回填——smart-merge-back --deploy 输出 + git log merge commit + diff -r 复验 + worktree list 无本任务条目）→ 见下方 Phase 5 补记
- [x] VC-7: Code Review Gate = APPROVED
  Evidence: Code Reviewer 子代理（agent_a42aa962）VERDICT: APPROVED，ISSUES 无 P0/P1，3 条 P2/P3 建议中 P2（T7 python3 兜底）+P3（注释口径）已由微修 S7 收口（f0fcdc8，双路径 19/19 复验），P3（既有 T07c jq 转义噪音）登记遗留 D-3；reviewer 证据：git show 1eecc1b + jq tier_order length==6×2 + 三脚本复跑全绿

**终验规则核对**：7/7 VC 通过 → outcome: **COMPLETE**（遗留 D-1..D-3 均为非阻断建议项，见下）

## Phase Gates（全部 complete）

| Phase | Status | 关键证据 |
|-------|--------|---------|
| 1 调研 | complete | checkpoint 01（三族画像+冲突面 1 硬断言）+ findings Research Findings |
| 2 机制设计 | complete | findings D1-D5 + Decisions 4 行 + 计划修订重 attest（acf50acd） |
| 3 实现 | complete | S1-S5 全 done（Handoff 02-06 ☑），commit 1eecc1b，9 文件（7改2新） |
| 4 验证 | complete | 全量 selftest 180 例 0 fail + smoke 17/0 + VC-5 一致性 + Code Review APPROVED + 微修 f0fcdc8 |
| 5 合并部署 | complete | 见下方 Phase 5 补记 |

### Phase 5 补记（合并回 + 部署）
- smart-merge-back.sh --deploy：ALREADY_MERGED 预检 → --no-ff 合并 → merge commit 见主仓 git log
- 9 位部署对账：定向 cp -rL 重部署 + diff -r 复验 diff=0（未跑 sync-companion，规避反向拉回陷阱）
- worktree 清理：git worktree remove + git branch -d 完成，`git worktree list` 无本任务条目
- 证据：主仓 git log + 部署对账输出（详见 progress.md Phase 5 段）

## 📚 必要知识储备符合性核验（终验项）

| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| 本仓 SKILL.md / critical-rules.md / config.json | Phase 1/2 定点精读 + 改动对照原锚点（L46-52/L124/L81-89） | 符合（五档语义零改动经 diff 复核） |
| comet/OpenSpec/superpowers 三族 SKILL.md | Phase 1 explore 全读 frontmatter+重点全文，画像表带 file:line 证据 | 符合（路由信号直接来源于三族原文件） |
| 部署流程要点（9 位定向 cp，禁 sync-companion） | Phase 5 按约执行 | 符合 |

## 委派统计复验（Rule 25.4）

```json
{"phases_total":5,"phases_delegated":2,"main_direct_count":3,"delegation_rate":0.400,"main_direct":[{"phase":"2 机制设计…","reason":"例外理由：② 计划系统文件维护 + 调度管理器规划设计本职——Rule 25.3 白名单"},{"phase":"4 验证…","reason":"mini + 主进程机械验证白名单③：只读 grep/diff/selftest 执行"},{"phase":"5 合并部署交付…","reason":"例外理由：① git/worktree 编排 + ② 计划系统簿记——Rule 25.3 白名单"}],"violations":[],"verdict":"ok"}
```

- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（② / ③ / ①②，Rule 25.3 六项白名单内）
- [x] 委派率 0.4 < 0.7 但全部直做理由命中白名单 → **WHITELIST-EXEMPT 放行**（stats verdict=ok, violations=[]）
- 补充：Phase 3 的 5 个 S-unit 与 Phase 4 的 Code Reviewer 均为子代理执行（实际子代理派发 8 次：plan-writer/explore/executor×5/reviewer，全程串行 Rule 21.4）

## 质量门控统计（Rule 26）

- [x] Q1-Q6 逐项核查：触发 0 项，豁免 0 项，未处置 0 项（无伪造证据/无跳过验收/无静默降级；子代理产出 100% Read 复核后采信）
- [x] Evidence 抽查 ≥3 条：① selftest 19/19+31/31 主进程亲跑复现 ② SKILL.md L46-53/314 sed 亲验 ③ critical-rules L124-126 五档语义 diff 亲验 — 全部可 Read、可复现
- [x] 豁免登记：无
- [x] 未处置违规：无 → outcome 不降级

## 遗留项（非阻断，均 P3 级或文档性）

| # | 内容 | 建议 |
|---|------|------|
| D-1 | config#skill_collab_enforce 三档本轮纯流程层执行，无 hook 机械校验（设计如此，enforce 语义预留） | 后续轮可接 PreToolUse/门控校验 |
| D-2 | scripts/ 无 selftest 聚合 runner，新 selftest-skill-collab.sh 独立直跑 | 引入聚合器时补登记 |
| D-3 | 既有 selftest-fallback.sh:108,110 T07c jq 转义写法产生 stderr 噪音后侥幸 PASS（非本次引入，reviewer P3 顺手项） | 后续清理轮改写 jq 路径表达式 |
| D-4 | 计划 Phase 4 提到的「verify.sh」路径含糊：实际位于 `lib/verify.sh`（非 scripts/），部署位体检 `TASK_PLANNER_ROOT=<位> bash <位>/lib/verify.sh` = 25 pass/0 fail（交付时补跑通过）；canonical 健康检查亦由 smoke.sh#verify_installation 覆盖（17/17） | 计划模板措辞可后续对齐为 lib/verify.sh |

## Goal Verification（Goal Gate）

对照 Verification Contract 逐条复验：
- [x] VC-1 → PASS（110 行四要素，grep 证据）
- [x] VC-2 → PASS（510 行净+2，语义保留，指针 3 处）
- [x] VC-3 → PASS（L126 落位，五档零改动，六档机械层）
- [x] VC-4 → PASS（config 键 + 180 例 0 fail 无回归）
- [x] VC-5 → PASS（三处键名一致+七文件 22.3.3+指针存在）
- [x] VC-6 → PASS（Phase 5 补记：merge + 9 位 diff=0 + 清理）
- [x] VC-7 → PASS（APPROVED + P2/P3 收口）

 outcome: **COMPLETE**

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | 终验交付（全 Phase complete） |
| 2 | Where am I going? | 交付报告 + memory 簿记 |
| 3 | What's the goal? | 见顶部 Goal |
| 4 | What have I learned? | findings.md（三族画像/D1-D5 设计/冲突面） |
| 5 | What have I done? | progress.md（5 Phase 全程） |
| 6 | Which tasks need processing? | plans/INDEX.md 无遗留待处理 |
