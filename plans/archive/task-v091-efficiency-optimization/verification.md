# Verification Contract & Phase Gates

## Goal (1 sentence)

定位 task-planner skill 简单/复杂任务慢源，产出经两轮批判检验、用户裁决采纳后纯增量实施的优化提案，全量 selftest 0 FAIL 且既有质量门控（Rule 26/18.9/21.4/三证据/3-File）零削弱。

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: 瓶颈清单每条含实证锚（file:line/计时数据），4 取证领域各 ≥3 条
  Evidence: `plans/task-v091-efficiency-optimization/workflow-evidence/01..04-*.md`（29 条全带锚）+ `05-bottlenecks-and-designs.md` 瓶颈总表（每条回链 01..04 小节号）；主进程 6 锚互证全命中（09-26 Phase 2 复核记录 progress.md）
- [x] VC-2: efficiency-proposal.md 存在且经两轮批判修订，Tier A 逐项含质量保持论证
  Evidence: `workflow-evidence/efficiency-proposal.md`（§六 批判轮次记录：轮 1 11+3 项全采纳 v2 / 轮 2 终审 12 项全采纳 v3；§三 Tier A 10 项逐项含 36.4 清单+质量风险+子代理干净上下文验证设计）
- [x] VC-3: 提案含独立「质量护栏」段：不可削弱项（21.4 串行/Rule 26/18.9/三证据 3-File verification）+ 每项对应守护 selftest
  Evidence: `efficiency-proposal.md §五`（G1-G10 护栏逐项映射 selftest 名：batch-pilot/conclusion-discipline/plan-tier/final-gate-hash/registry/sync-index/smart-merge 等；「三证据/3-File/verification 判定力零削弱」明示，优化只降开销不降判定）
- [x] VC-4: 用户裁决入 Decisions Made；采纳项实施后主仓全量 selftest 主进程逐脚本求和 0 FAIL
  Evidence: Decisions Made「D1 裁决落地」行（Tier A 10 项全采纳 36.4 一次性确认 + Tier B 7 项暂缓）+ 用户补充裁决⑦⑧；实施后 master 全量 32 脚本主进程逐脚本 Total 求和 = **518 PASS/0 FAIL**（≥457 基线，2026-09-27 11:50 实跑，逐脚本 ✅ 32/32 见 progress.md）
- [x] VC-5: 部署三实体位 diff -r 与仓侧 IDENTICAL + 关键改动文件 Read 复验
  Evidence: b5b9bc0 合并后 `smart-merge-back --deploy` 三实体位 IDENTICAL（Phase 4 记录）+ 主进程独立 `diff -r` ×3 diff_lines=0（2026-09-27）；c5locale 尾巴（36e9aaa）后主进程定向 cp 两文件（smart-merge-back.sh/selftest-smart-merge.sh）至三位 + `diff -r` ×3 复验=0 + sha256 双源一致

**终验规则结果**: 全部 VC 通过 → **outcome: COMPLETE**（遗留项登记见下，均不属 VC 判定面）

### 遗留与已登记面（如实披露）
1. **Tier B 7 项暂缓**（非否决）：分槽并行/mini 单 Phase/mini silent/≤30 行直做/T5 免写/CR 分级/findings 放宽——待 Tier A 实测数据后按 Rule 32.4 重议
2. **check-conflicts :118 INDEX 解析缺陷 + :145 自计划跳过恒不等 + check-drift.sh 两 quirk + template-guide.md:69 文档锚**：S16/S18 实证界定的既有缺陷/漂移，登记 progress.md deferred 不属本任务 scope（行为恢复类另开任务）
3. **c5locale 修复（36e9aaa）晚于 b5b9bc0 主合并**：S32 组5 干净上下文验证独立发现 C-5 comm 未 pin locale 缺陷（zh_CN.UTF-8 假 IDENTICAL），已修 cc64c1b+用例 eb7d728 并合并 36e9aaa + 三实体位定向同步——部署位与仓侧现已一致（diff -r ×3=0 复验）

## Phase Gates

### Phase 1: /workflow 审计+方案设计
**Done when**: 4 领域取证+3 方案+两轮批判→终稿 ✓（Status: complete, verified 2026-09-26）

### Phase 2: 提案精修+用户裁决
**Done when**: 主进程 Read 全文+6 锚互证；D1 裁决登记（Tier A 全采纳/Tier B 暂缓）；B 类重规划 S-unit 实例化 ✓（Status: complete, verified 2026-09-26/27）

### Phase 3: 实施采纳项（S11-S32）
**Done when**: worktree 逐 S-unit 实施+S32 五组干净上下文验证（组1-4 PASS；组5 发现 locale 缺陷转 S33 修复闭环）+全量回归 ✓
- S11 de69956 / S12 2d5f791 / S13 6e79257 / S14 fb67f3a / S15 fb28b70 / S16 73730f7 / S17 28221a7 / S18 24e6609 / S19 aff5e06 / S20 216e912 / S21 d3a787c / S22 3ad2adb / S23 9026ca9 / S24 40a1880 / S25 3cdab78 / S26 53ff783 / S27 a243253 / S28 349d94e+f8284d0 / S29 1b9437e / S30 a05bd5e / S31 主进程 516/0（worktree）
- S32 验证包五组：组1 C-1 六子项 PASS / 组2 A-1+A-2 PASS / 组3 A-3 三小项 PASS / 组4 B-1+B-2 PASS / 组5 C-2/3/4 PASS + C-5 FAIL→缺陷修复 S33（cc64c1b+eb7d728→36e9aaa）
- worktree task-v091 已 remove + 分支删除；c5locale worktree 已 remove + 分支删除
Status: complete, verified 2026-09-27

### Phase 4: 终验+合并部署+簿记
**Done when**: 合并 b5b9bc0（--no-ff）+三实体位部署 IDENTICAL+c5locale 尾巴 36e9aaa 同步部署+master 全量 518/0+INDEX 刷新+verification 回填 ✓
Status: complete, verified 2026-09-27

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论 |
|-----------|----------------------|------|
| 全量审查报告（效率类发现） | 提案瓶颈总表 review #21/#27/#28 效率条目被 C-1f/C-1e 直接处置 | 符合 |
| 用户裁决史（21.4/18.9/Rule 26） | 提案 Tier B 单列+护栏段不可削弱项原文保留 critical-rules:122/:86/:182 零触碰（diff 实证） | 符合 |
| workflow 编排约定（Rule 39） | Phase 1 CreateWorkflow 显式路由+39.4 豁免登记 Decisions Made | 符合 |

## 委派统计复验（Rule 25.4）

机器统计为事实源：`bash scripts/check-delegation.sh stats <plan-dir>`（2026-09-27 Phase 4 实跑，Handoff 补登 S-wf 行后）：

```json
{"phases_total":4,"phases_delegated":2,"main_direct_count":2,"delegation_rate":0.5,"main_direct":[{"phase":"2 提案精修+用户裁决","executor":"主进程（白名单②+用户交互 D1 裁决）","self_declared":0},{"phase":"4 终验+合并部署+簿记","executor":"主进程（白名单①git 编排+②计划系统文件）","self_declared":0}],"violations":[],"verdict":"ok"}
```

- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（白名单①②，stats self_declared=0 全 0）
- [x] 委派率 0.5 < floor 0.7 但 main_direct 全部白名单命中 → **WHITELIST-EXEMPT 放行**（check-complete 25.4a 分支）；Step S-unit 全由子代理执行（20+ S-unit 派发 100% 委派，Phase 级口径受 4 Phase 结构稀释，如实登记）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成：触发 2 项（S15 双执行体并发写→按 22.8 检查点仲裁止损；S23 键③锚自伤→当场修复），豁免 0 项，未处置 0 项
- [x] Evidence 抽查 ≥3 条：S15 三夹具+R1 计时（progress 行原文）/ S16 37 计划 byte-identical / S18 证伪实验 18/20 同向 / S20 六夹具 22 断言 / S32 组5 locale 缺陷实证——路径可 Read、结论可复现（抽查记录 5/5）
- [x] 豁免登记：无（无 Q3 触发）

## Goal Gate

```
## Goal Verification — task-planner 效率优化（Tier A 10 项实施+质量零削弱）
对照 Verification Contract 逐条复验：
- [x] VC-1: workflow-evidence 01..05 + 6 锚互证 → PASS
- [x] VC-2: 提案 §六两轮批判记录 + Tier A 逐项质量论证 → PASS
- [x] VC-3: 提案 §五护栏 G1-G10 + 对应 selftest（registry 32 行守护含新增 4 脚本）→ PASS
- [x] VC-4: D1 裁决登记 + master 全量 32 脚本主进程求和 518 PASS/0 FAIL（≥457）→ PASS
- [x] VC-5: 三实体位 diff -r ×3=0（b5b9bc0 合并部署 + 36e9aaa 尾巴定向同步双轮复验）→ PASS

outcome: COMPLETE
```

遗留登记（不阻塞 COMPLETE，建议后续任务）：①Tier B 7 项凭 Tier A 实测数据（hook 热路径 1.23s→<500ms 实测定向）按 32.4 重议；②check-conflicts INDEX 解析/:145 跳过/check-drift quirk 修复另开任务；③WF-10 部署位上跳非鲁棒（v090 遗留）未在本轮范围。

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | 全 Phase complete，簿记收尾 |
| 2 | Where am I going? | git 簿记提交 + memory 更新 → 交付 |
| 3 | What's the goal? | 效率优化 Tier A 实施+质量零削弱+全链路部署 |
| 4 | What have I learned? | 见 findings.md + notepad-learnings.md |
| 5 | What have I done? | 见 progress.md（S11-S33 逐行） |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区（本任务 complete 后移入已完成区） |
