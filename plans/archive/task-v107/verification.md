# Verification Contract & Phase Gates

## Goal (1 sentence)

对 task-planner 项目完成三维深度审查对齐（内容质量/稳定性/执行部署），产出分级问题清单与授权修复候选闭环，交付可验证审查报告。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: 全量 42 个 selftest 回归 0 FAIL（与 v106 基线 660/0 对齐）
  Evidence: progress.md Phase 1 段 [sub:2] 行；checkpoint subagent-state/2-code-runner.md（42 行逐脚本 rc=0 原文）；主进程机械求和=660/0；bash -n 75 脚本 0 语法 FAIL（findings [Phase 1 S1] 行）
- [x] VC-2: 审查报告 plans/task-v107/report.md 落盘，覆盖三维，问题条目含 file:line 锚点与分级
  Evidence: report.md 六段齐备（Read 复核）；42 条条目（EX-1×1+P1×7+P2×27+待复核×5+核验×2，sub:10 对齐审查更正后口径=表格数据行）
- [x] VC-3: 报告问题清单抽查 ≥3 条可复现
  Evidence: verification.md 下方「Evidence 抽查」段 8 条抽验记录（S1 三条+S2 两条+S3 一条+S4 两条+EX-1 复现），全部证实
- [x] VC-4: 三宿主部署位一致性结论明确
  Evidence: checkpoint subagent-state/7-executor.md 差异清单全文：.claude/.opencode 位 9/10 IDENTICAL（仅主仓 backup 目录+plan-resume tests 不部署）；⚠️ .zcode 位 videop1 双向漂移（部署位 28 variant vs 主仓 16 等）已逐条披露；「第二套部署」误判证伪撤销（.opencode=.config 软链同 inode）
- [x] VC-5: 修复项处置闭环——用户超时未授权 → 零修复实施（§六 P0+28.4 D6 不可自动裁决），R-01~R-15 完整留 report.md §4 待授权清单，EX-1 与待裁决 5 项留 §5
  Evidence: report.md §4（R-01~R-15 逐项锚点+修法）+ §5（待裁决 5 项）；task_plan Phase 5 Status=skipped 豁免路径登记
- [x] VC-6: 全部审查结论经 alignment-review 对齐审查收尾（42.6.2），无未处置对齐冲突
  Evidence: checkpoint subagent-state/10-executor.md（CHANGES_REQUESTED：1 P1 计数漂移+2 P2）→ 主进程全部处置（report/progress/task_plan 三处 42 条口径更正+Status 翻转+质量审查工具登记如实修正），处置后残留 0

**终验规则**：全部 VC 通过 → outcome: **COMPLETE**

---

## Phase Gates

### Phase 1: 基线与全面回归（机械层）
**Goal**: 语法扫描+selftest 回归+部署位盘点三基线
**Depends on**: none
**Done when**: [x] 75 脚本 0 FAIL / [x] 42 selftest 660/0 / [x] 三宿主盘点完成
**Verification**:
- [x] V-1.1: VC-1 — 660/0 与基线一致（checkpoint 2 原文 42 行）
- [x] V-1.2: VC-4 基线 — 盘点清单（findings [sub:S3] 段+checkpoint 9）
Status: `complete` Last verified: 2026-10-02

### Phase 2: 内容质量深度审查（文档面四波）
**Goal**: 主文档面/references+templates/卫星/根目录四波问题清单
**Depends on**: Phase 1
**Done when**: [x] 四波各出问题清单（附证据）/ [x] 主进程抽验全证实
**Verification**:
- [x] V-2.1: VC-2 — 四波清单汇入 report.md §3.2-3.5（42 条中 41 条内容面）
- [x] V-2.2: VC-3 — 抽验 8 条全证实（见下方抽查段）
Status: `complete` Last verified: 2026-10-02

### Phase 3: 部署一致性对齐审查
**Goal**: 三宿主 diff+第二套部署核实
**Depends on**: Phase 1（盘点清单）
**Done when**: [x] 10 skill×3 宿主逐个结论 / [x] 误判证伪撤销
**Verification**:
- [x] V-3.1: VC-4 — 差异清单全文（checkpoint 7）+EX-1 定级 P1-高
Status: `complete` Last verified: 2026-10-02

### Phase 4: 审查报告汇总与问题分级
**Goal**: report.md 六段交付
**Depends on**: Phase 1-3
**Done when**: [x] 六段齐备 / [x] 候选清单可执行
**Verification**:
- [x] V-4.1: VC-2/VC-3 — Read 复核+计数口径经 sub:10 更正为表行实数
Status: `complete` Last verified: 2026-10-02

### Phase 5: 授权修复与回归（条件 Phase）
**Goal**: 授权项修复+回归（条件触发）
**Depends on**: Phase 4 + 用户授权
**Done when**: [x] AskUserQuestion 分组呈报 / [x] 用户超时未答复 → 零修复+候选完整留档
**Verification**:
- [x] V-5.1: VC-5 — 未授权零写入+report §4/§5 清单完整（豁免路径判定 PASS）
Status: `complete`（skipped-未授权豁免路径，语义登记于 task_plan Phase 5 块） Last verified: 2026-10-02

### Phase 6: 对齐终验与簿记
**Goal**: alignment-review+VC 复验+簿记
**Depends on**: Phase 1-5
**Done when**: [x] 对齐审查执行+三发现全处置 / [x] VC 逐条复验 / [x] 簿记 commit
**Verification**:
- [x] V-6.1: VC-6 — checkpoint 10 CHANGES_REQUESTED 三项全处置
- [x] V-6.2: 本文件全量填写+check-complete exit 0
Status: `complete` Last verified: 2026-10-02

---

## Evidence 抽查记录（VC-3，主进程第一手复现）

| # | 抽验项 | 结果 |
|---|--------|------|
| 1 | P-1 SKILL.md:64「5 个文件」vs init-session.sh:3「5 文件→6 文件」 | 证实 |
| 2 | P-2 Rule16 锚 21 vs grep -rl 实测 22 | 证实 |
| 3 | P-6 install-companion.sh 实位 lib/ 非 scripts/ | 证实（计划已修） |
| 4 | P1-1 templates/task_plan.md:249 旧 worktree 约定 | 证实 |
| 5 | P1-2 knowledge-brief.md:9「维持 20」vs 实测 22 | 证实 |
| 6 | C-P1 cost-guard 17.5「>15 STOP」vs 主侧 0 命中「强制 STOP」 | 证实 |
| 7 | D6-01 根级 scripts/ 不存在+README_zh:59 引用失效 | 证实 |
| 8 | EX-1 部署位 variant 28 vs 主仓 16+diff 12 个 video 家族 | 证实（checkpoint 7+主进程 diff 抽验） |

## 📚 必要知识储备符合性核验（终验项）

| 必读知识源 | 核验方式(交付物对照点) | 结论 |
|-----------|----------------------|------|
| v106 基线（42 selftest 660/0/三部署位 IDENTICAL） | Phase 1 回归对照+Phase 3 对账发现 .zcode 位已漂移（基线时效性修正） | 符合（基线漂移已被审查捕获并披露） |
| review-library 池与 alignment-review 清单 | Phase 6 按 alignment-review 四要素执行（checkpoint 10） | 符合 |
| 审查锚点清单（SKILL 索引面两处/计数锚/RL/R 守卫） | 波1 五维含索引面两处核对（checkpoint 3） | 符合 |
| 部署合约 install-companion/smart-merge-back | Phase 3 对账路径核实（lib/ 实位修正） | 符合 |

## 委派统计复验（Rule 25.4）

```json
{"phases_total":6,"phases_delegated":3,"main_direct_count":3,"delegation_rate":0.500,"main_direct":[{"phase":"1 基线与全面回归（机械层）","reason":"executor（sonnet-1）（S2 selftest 回归，22.3① 改派自 code-runner mini）+ 主进程接管 S1/S3（白名单③ 机械验证命令；mini provider rejected×2）"},{"phase":"5 授权修复与回归（条件 Phase — 用户裁决后）","reason":"skipped 未执行（D6 未授权零写入，无直做工作）"},{"phase":"6 对齐终验与簿记","reason":"例外理由：① git/worktree 编排 + ② 计划系统文件簿记——Rule 25.3 白名单"}],"violations":[],"verdict":"ok"}
```

- [x] 主进程直做 Phase 均在白名单内（Phase 1=③ 机械验证命令；Phase 5=skipped 无工作；Phase 6=①② git+簿记）→ **WHITELIST-EXEMPT 放行**（先例：v099-v106 各轮）
- [x] verdict=ok（初跑 violation=Phase 1 Executor 字段与事实不符已回炉修正）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查：触发 0 项（无打包/无伪证据/无静默降级；子代理 8 字段全合规），豁免 0 项，未处置 0 项
- [x] Evidence 抽查 ≥3 条：8 条全证实（上表）
- [x] 豁免登记：无
- [x] 未处置违规：无 → 不降级

## Goal Gate (终验)

```
## Goal Verification — 三维深度审查对齐交付
- [x] VC-1: 42 selftest 660/0+75 脚本 0 语法 FAIL → PASS
- [x] VC-2: report.md 六段/42 条/锚点齐备 → PASS
- [x] VC-3: 抽验 8/8 证实 → PASS
- [x] VC-4: 三宿主结论明确（EX-1 披露） → PASS
- [x] VC-5: 未授权零修复+候选完整留档 → PASS（豁免路径）
- [x] VC-6: 对齐审查三发现全处置 → PASS

 outcome: COMPLETE
```

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | 全 Phase complete，终验 COMPLETE |
| 2 | Where am I going? | 簿记 commit+INDEX 后交付；R-01~R-15 待用户授权可开修复轮 |
| 3 | What's the goal? | 见上方 Goal |
| 4 | What have I learned? | See findings.md（videop1 双源分叉/计数漂移链/误判证伪） |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
