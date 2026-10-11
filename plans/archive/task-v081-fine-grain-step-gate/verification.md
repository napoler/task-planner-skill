# Verification Contract & Phase Gates — task-v081 步骤枚举门控

## Goal (1 sentence)

给 task-planner 派发链路补「步骤枚举数」门控维度（step_max_steps 默认 4），使"单子代理打包 13 步"类粗粒度派发在计划期被提示、派发期被硬拦，全量 selftest 0 FAIL、合并部署三实体位 IDENTICAL 并 push。

---

## Verification Contract — 终验复验（2026-09-18）

- [x] VC-1: config 键落位
  Evidence: `jq -r '.properties.subagent.properties.step_max_steps.default' config.json` → `4`（schema 363-368 + defaults 409；S1 验收 diff 仅两处新增）
- [x] VC-2: enforce 档 13 步硬拦
  Evidence: fixtures/f13.md → `check-dispatch.sh pretool` rc=2，stderr「步骤枚举超限(13>4)」（progress.md P2 Test 表行 1；SG-03）
- [x] VC-3: 4 步放行 + warn 落盘
  Evidence: fixtures/f04.md rc=0 stderr=0 字节；warn 档 rc=0 且 task-planner-dispatch-warn-<sid> 文件含「步骤枚举超限」（P2 Test 表行 2-3；SG-04/05）
- [x] VC-4: 任务书防绕门
  Evidence: fixtures/fbook.md（prompt 引用任务书,任务书内含 13 步）→ rc=2 计数取任务书（P2 Test 表行 4；SG-06）
- [x] VC-5: 计划侧 advisory 双向
  Evidence: fixtures/plan-a.md（6 枚举）出「SKIPPED … 步骤枚举 6 > step_max_steps(4)」exit 0；plan-b.md 对照静默 exit 0（P2 Test 表行 5-6；SG-08/09）
- [x] VC-6: 条款增量在位 + 纯增量
  Evidence: critical-rules.md task-v081 锚×3、SKILL.md ×2、subagent_dispatch.md ×1（grep -c 实查 3/2/1）；diff vs baseline 9 文件快照——deletions 全为行内扩展原行,旧内容完整保留于新行前缀,语义零删除（progress.md P3 Test 表）
- [x] VC-7: 双侧全量 0 FAIL
  Evidence: worktree 22 脚本 366/0 + 合并后 master 22 脚本 366/0（均主进程逐 Total 行'='分列求和,/tmp/tp-v081-master-totals.txt 留档）
- [x] VC-8: 三部署位 IDENTICAL
  Evidence: 主进程 `diff -r` 亲验 ~/.zcode、~/.claude、~/.config/opencode 三位均 IDENTICAL（smart-merge-back --deploy 报告+亲验双证）
- [x] VC-9: CHANGELOG + 行数自洽
  Evidence: CHANGELOG.md Unreleased 顶部 task-v081 条目在位；SKILL.md 恒 543 行（≤548 断言未触,净增 0 → 断言扩围条件分支 N/A）
- [x] VC-10: push 完成 + 隔离清理
  Evidence: `git push` 输出 34c3959..38ed103 master→master；worktree remove+branch -d 已执行,`git worktree list` 仅存主仓,无残留 wt/* 分支

**outcome: COMPLETE**（10/10 PASS,无遗留阻塞）

---

## 必要知识储备符合性核验

| 必读知识源 | 核验方式(交付物对照点) | 结论 |
|-----------|----------------------|------|
| Rule 21.1b/22.3/22.4/22.6 现行文本 | 增量前逐行 Read（114/127/132 锚）,增量后 grep 复核 | 符合 |
| fine_grain_checks 现行实现 | ④插③后 `[ -z "$hits" ]` 前,复用 hits/mode 管线 | 符合 |
| S-unit 数值门控 awk 块与列位 | col3/col5/col7 提取与既有 $5/$7 同范式 | 符合 |
| selftest 范式与行数断言两处 | selftest 对齐 veto/skill-modify 范式;断言两处未触（净增0） | 符合 |
| 派发 8 字段字面契约 | 全程派发 prompt 均含三文件路径+8 字段 token | 符合 |

## 委派统计复验（Rule 25.4）

机器统计（修正 Executor 字段并重锁后）：
```json
{"phases_total":6,"phases_delegated":0,"main_direct_count":6,"delegation_rate":0.000,"violations":0,"verdict":"ok"}
```
- [x] 委派率 0.0 < 0.7,但主进程直做理由全部命中 Rule 25.3 白名单（①git 编排/②计划文件/③机械验证/⑤22.3④ 接管单文件≤300行）→ **WHITELIST-EXEMPT 放行**
- [x] 环境事实：本会话 sonnet-1/继承/haiku-1 档位派发全部 `Cannot start: No reasoning level selected`（Plan Writer×2/general-purpose×1/Code Assistant×1,Error Log #2/#3）,仅 mini 档可用;两次 Explore(mini) 派发遇 provider server error（Error Log #5 探针成功/#CR 两次失败）
- 首跑 violation（P2/P3/P4 Executor 未随接管事实同步）已回炉修正并重锁 attest（SHA a2c87e04）,复跑 verdict=ok

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查:触发 0 项,豁免 0 项,未处置 0 项（SG-07 测试预期错属执行中即时修复,非降质行为;反思两行已落 progress.md P4）
- [x] Evidence 抽查 ≥3 条:①fixtures/f13.err（rc=2 输出可复现）②部署位 grep -c step_max_steps（2/5/7 可复现）③master totals 文件 366/0（可重跑复现）
- [x] 豁免登记:无
- [x] 无未处置违规

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------------------------|
| 1 | Where am I? | 全 Phase complete,已交付 |
| 2 | Where am I going? | 无剩余 Phase（遗留建议见下） |
| 3 | What's the goal? | 步骤枚举门控落地并部署 |
| 4 | What have I learned? | 见 findings.md + notepad-learnings.md |
| 5 | What have I done? | 见 progress.md |
| 6 | Which tasks need processing? | 无本任务遗留;deferred 见下 |

**遗留建议（不阻塞交付,登记后续轮次）**：① check-plan-dispatch.sh 既有 STEP_MAX_MIN/FILES 的 jq 单层路径与 config 双层结构不符（静默回退恰为同值,行为无损）——可顺手修正但超出本任务纯增量范围,留 deferred；② count_step_markers 对"行首 markdown 编号列表"口径未覆盖（防误伤取舍）,若后续出现编号列表型 13 步逃逸再收紧。
