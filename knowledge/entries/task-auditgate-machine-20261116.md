---
id: task-auditgate-machine-20261116
title: "计划审计门机器强门落地（checker+attest [audit-gate]+selftest；R1-R8+CR 两轮全独立审计闭环）"
tags: [task-planner, rule-109-8, audit-gate, 机器门, mutation-判别性]
sources: [plans/archive/task-auditgate-machine-20261116/task_plan.md, plans/archive/task-auditgate-machine-20261116/progress.md, plans/archive/task-auditgate-machine-20261116/subagent-state/]
updated: 2026-11-17
---

# 计划审计门机器强门（task-auditgate-machine-20261116 COMPLETE）

## 落地终态（master d6201f0+0fb46eb，部署位 IDENTICAL，归档 ARCHIVED）

| 交付物 | 终态锚 |
|--------|--------|
| 判定器 | `skills/task-planner/scripts/check-plan-audit-gate.sh`（lane 优先/行首声明/[plan-audit-skip] 行首锚定/H2 边界+结论行 ERE 锚定/容忍括注 token/rc 分层 rc2=缺失或不可读、存在但空=rc1） |
| attest 接线 | `attest-plan.sh` 四处增量（--skip-audit-check/cksum 第 8 参数组 skip_audit+ENFORCE+sha256(progress.md)/window-lint 后门块/enforce-warn(默认)-off 阶梯+enforce 下 rc2 证据缺失同拒锁） |
| selftest | `selftest-plan-audit-gate.sh` 19 断言（判别性经 mutation 终证：常量化 progress 哈希→PAG-14 FAIL 0/0） |
| 文本条款 | critical-rules.md 109.8 六子项（109.7 原样）；SKILL.md 审计门机器门行 |
| 登记 | selftest-registry.tsv 四列行；`^### 109 `=1 保持 |

## 机器门行为速记

- attest 锁定时自动跑 checker：`[audit-gate] PASS: 末段审计留痕 [plan-audit-R8] APPROVED`（本计划自身已闭环——机器门对自己 plan-dir rc=0）
- enforce 一行开启硬门：`TASK_PLANNER_AUDIT_GATE_ENFORCE=enforce`（默认 warn 首版起步——存量不重锁；off=显式 SKIP；--skip-audit-check=唯一逃生 WARN+披露）
- 判据核心：末段 `[plan-audit-RN]` 聚合止 H2+结论行行首锚定+`问题清单` 容忍括注；rc2=缺失/不可读、存在但空=rc1

## 可复用教训（本任务新增四条铁律级）

1. **判别性测试唯一可靠验收=mutation**：清缓存后再断言=没有断言；「错了会红」须用注入缺陷实证（PAG-14 常量化 mutation FAIL 0/0 终证）。
2. **判据 token 必须匹配真实生产留痕字节形态**（R7 I-1：spec 字面 `问题清单:` vs 真实 `- 问题清单（留档，不阻断）:`——spec 与数据脱钩会让 checker 拒掉自己机制的计划）。
3. **多约束测试须「只缺其一」独立负例**：合成「全缺」负例只能证明全缺被抓，半加固实现全绿通过（R7 I-2→r5/r6 独立承重 fixture）。
4. **反造谣须覆盖「修复声称」本身**：本任务主进程两犯（Handoff 假更新+4 处声称未落盘）均被独立复检抓出——收据逐关键断言盘上复核，修复声称亦不豁免。

## 存量迁移与遗留

- 存量：9 无声明 legacy（SKIP 放行）+7 个 standard/L1 无留痕在途（不重锁）；首版默认 warn 起步，`TASK_PLANNER_AUDIT_GATE_ENFORCE=enforce` 一行切硬门（用户如需立即 enforce 请示一句即改）。
- 遗留（N 级登记）：selftest 编号 14→17→18→19→15→16 非单调（可读性）；selftest-self-resolution 跨执行根 flaky（环境态依赖，主仓恒红属基线内）；check-complete 的 `execution_lane: L0` 子串探针被计划散文误命中（既有脚本面，另行任务）。
