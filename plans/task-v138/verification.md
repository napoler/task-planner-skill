# Verification Contract & Phase Gates

## Goal (1 sentence)

落地 Rule 55「可复用能力落盘纪律」（55.1-55.6）+ 固定能力资产（`scripts/capabilities/agnes-quota.sh` + `references/capability-registry.md`）+ 两个生成执行体 SOP 接线 + selftest 守护，全量 selftest FAIL=0 后合并回 master 并部署三宿主。

---

## Verification Contract（终验复验 — 2026-10-06，全部 PASS）

- [x] VC-1: Rule 55 六子条在 critical-rules.md 文件尾纯增量 + SKILL.md 索引（`grep -cE '^55\.[1-6] '`=6；`grep -c '^### 55 '`=1；`grep -c 'Rule 55' SKILL.md`=3；`40-55`=1/`40-53`=0）
  Evidence: master@5ed69e7 `skills/task-planner/references/critical-rules.md:613-623`；`SKILL.md:9/:268/:311/:334`（v139 合入后行号微移）；commit d6cc6c8（+23/-9）
- [x] VC-2: agnes-quota.sh 存在+bash -n 过+无硬编码密钥+实跑结构化输出；F1 修复后非 200 显式失败（审查闭环）
  Evidence: 211 行；`Total: 20 PASS=20 FAIL=0`（CP-11 bash -n/CP-16 禁密钥）；真端点 `--json` exit=0 verdict=未填充；mock 404 → exit 5 失败 verdict（CP-19）；mutant 旧逻辑对 mock 伪成功被断言咬合（sub:16 evidence）
- [x] VC-3: capability-registry.md 首条 8 列完整
  Evidence: `references/capability-registry.md:8-10`（8 列表头+agnes-quota 行 8 字段非空）；对齐审查 sub:18 逐字段核销
- [x] VC-4: 两执行体 SOP 复用指向行（对称接线）
  Evidence: `companion/agents/video-generation-executor.md:43`、`image-generation-executor.md:42`（各 +1 行，grep capability-registry/agnes-quota 各=1）
- [x] VC-5: 全量 selftest FAIL=0（脚本数随基线演进 52→53；总数主进程逐脚本复核）
  Evidence: Phase 4 S1 52/52（主进程 grep 复核 /tmp/selftest-v138/log/）；Phase 4b 后主进程机械重跑 `scripts=53 scripts_with_fail=0`（v136 并行新增 selftest-execution-honesty.sh 计入）；`git diff` 既有脚本仅纪元/行数钉同步（sub:09/sub:10，断言强度不减弱）
- [x] VC-6: 合并回 master + 三宿主部署 IDENTICAL + 账本 land + worktree 清理
  Evidence: merge 1992566（他会话）+ merge 5ed69e7（fix）；agnes-quota.sh sha256 前 12 位四端一致 `9fb898f9333a`；账本末行 `{"rule":55,"status":"landed","task_id":"task-v138","ts":"2026-10-06"}`；`git worktree list` 仅主仓；`git status --porcelain -- skills/`=0

**终验规则**：端点定论=「billing 端点存在但计费层未填充」→ 计划预设 PARTIAL 分支（V2 端点不可得时）经 Phase 1 探针升级为「端点在、数据未填充」→ 脚本按规格直查+如实呈现+禁推算（真跑成功），V2 判 **PASS**（非 PARTIAL）；全部 VC 通过 → **COMPLETE**。

---

## Phase Gates

| Phase | Goal | Done when | Status | Last verified |
|-------|------|-----------|--------|---------------|
| Phase 1 | 端点定论（调研+鉴权校准探针） | 可用/不可得判定带原始证据 | complete（findings [sub:02]..[sub:06]） | 2026-10-05 |
| Phase 2 | Rule 55 条款+SKILL 索引+纪元钉同步 | 六子条+索引+回归绿 | complete（d6cc6c8） | 2026-10-05 |
| Phase 3 | 能力脚本+注册表+接线+守护 | 四资产落地+实跑+断言咬合 | complete（62561a1） | 2026-10-05 |
| Phase 4 S1 | 全量回归 | FAIL=0 主进程复核 | complete（52/52） | 2026-10-05 |
| Phase 4 S2 | 代码审查 | CHANGES_REQUESTED 闭环 | complete（F1→Phase 4b 修复，5ed69e7） | 2026-10-06 |
| Phase 4 S3 | 对齐审查 | APPROVED | complete（sub:18，0 P0/P1） | 2026-10-06 |
| Phase 4b | F1 修复+mock 断言 | mock 404→exit5；53/53 | complete（8b12495） | 2026-10-06 |
| Phase 5 | 合并+部署+簿记 | IDENTICAL×3+land 55+worktree 清 | complete（5ed69e7） | 2026-10-06 |

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论 |
|-----------|----------------------|---------------------|
| design-brief §3.1 条款骨架 | critical-rules.md:613-623 六子条逐条对照 | 符合（54.1 预留状态注记现滞后=LOW-1 deferred） |
| findings [sub:05]/[sub:06] 端点定论 | agnes-quota.sh 规格（key 候选链/校准/绕缓存/禁推算） | 符合 |
| Rule 45 注释完整性 | 脚本头 What+Why+判例+退出码；selftest 同 | 符合 |
| knowledge-brief §4 易错点 12 条 | Error Log 三行+条款判例锚+spec 文件 | 符合 |

## 委派统计复验（Rule 25.4）

- [x] 主进程直做 Phase（Phase 5 编排/部署/簿记）均在计划 Executor 字段登记白名单①②例外理由
- [x] 委派率 0.8（4/5 Phase 子代理执行）≥ delegation_rate_floor 0.7；Handoff 登记表 14 行（含改派与重试单元）全部 verify_done

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查：触发 0 项未处置；Error Log 3 行均带 Root Cause+Prevention（Learning Gate 素材）
- [x] Evidence 抽查 ≥3 条：VC-2 mock 咬合（复现命令在 sub:16）、VC-5 主进程机械回归（本会话 Bash 输出）、VC-6 四端 sha256 对账（本会话 Bash 输出）——均可复现
- [x] 豁免登记：无
- [x] 未处置违规：无（对齐审查 2 LOW 均 deferred 登记，见下）

## Deferred（显式登记，不阻断终验）
1. LOW-1：critical-rules.md:618 附近 55.2 内嵌注记「Rule 54.1…task-v136 预留未落地」已滞后（v136 已于 b2d38e5 落地）——语义指向正确，单行行内改写可修；留给下一轮技能维护任务（或 55 纪元扫尾轮）顺带修正
2. LOW-2：本计划 VC-5 字面「51+1=52」与实测 53 的差额=v136 并行新增脚本——Phase 4b 起已按实际基线执行，计划文档字面不回改（历史时点值）

## Goal Gate (终验)

```
## Goal Verification — Rule 55 可复用能力落盘纪律落地
- [x] VC-1: 条款+索引在位（critical-rules:613 / SKILL:9,268,311,334）→ PASS
- [x] VC-2: 脚本实跑+F1 闭环+mock 咬合（20/20）→ PASS
- [x] VC-3: 注册表 8 列首条（registry:8-10）→ PASS
- [x] VC-4: 两执行体接线（video:43/image:42）→ PASS
- [x] VC-5: 全量回归 FAIL=0（53 脚本，主进程复核）→ PASS
- [x] VC-6: 合并+部署 IDENTICAL×3+land+清理 → PASS

 outcome: COMPLETE
```

**COMPLETE**：全部 VC 通过；F1 阻塞项经 fix-phase 闭环；对齐审查 APPROVED；2 LOW deferred 显式登记。

---

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | 终验 COMPLETE（2026-10-06） |
| 2 | Where am I going? | 交付总结+memory 归档 |
| 3 | What's the goal? | 见 Goal |
| 4 | What have I learned? | findings.md（缓存态观测≠鉴权证据；key 解析落盘判例） |
| 5 | What have I done? | progress.md（Phase 1-5 全段） |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区（v133/v135 在途，非本任务） |
