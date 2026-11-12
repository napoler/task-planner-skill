# Task Plan: variant 存量模板全量升级改造（28 文件三结构统一）
<!-- mini stub（用户裁决「全部升级改造」即 D1 放行；同 anchor-eread 模式） -->
template_type: rule-enhancement
plan_tier: mini
execution_lane: L1

## 用户需求原文（R 逐字）
- **R1**: 「是否完成对当前skill的存量模板文件进行升级改造」<sub>（问询→实测=variant 存量零升级）</sub>
- **R2**: 「全部升级改造」<sub>（[目标] D1 放行=28 文件全量）</sub>

## Goal
28 个 variant 独立全文模板统一升级到新口径三结构（10 列 S-unit 表+Goal 单元表+Batch 引导），rule-enhancement 7 列旧表替换；mini-lite/l0-lite 白名单豁免；worktree 三执行体并行→回归→合并→三位部署→三仓 push。

## VC（验证契约）
| # | 判定标准 | Verify command |
|---|---------|----------------|
| VC-1 | 28 文件三结构达标（每文件 goal-id 表含「对应 S-unit/Phase」+10 列 ID 表+Batch Report） | 主仓合并后逐 grep（判据落 findings §2）→ **PASS(2026-11-13 ALL-28-PASS 终扫)** |
| VC-2 | 无回归：selftest 全量=基线（2 预存） | `bash skills/task-planner/scripts/run-selftests.sh 2>&1 \| tail -1` |
| VC-3 | 部署生效：variant 目录×三位 diff=0+三仓 push | `diff -r skills/task-planner/templates/variant/ ~/.zcode/skills/task-planner/templates/variant/` 空 |
| VC-4 | 白名单豁免面零触碰：mini-lite/l0-lite 与 master 一致 | `git diff master -- skills/task-planner/templates/variant/mini-lite-type.md skills/task-planner/templates/variant/l0-lite-type.md` 空 |

## S-unit（10 列新口径）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | （A6）组 A 九文件三结构统一升级 | 继承 | worktree 路径+findings §1 统一增量块+§3 处置规则 | 组内自检六条全过（198+ 行，错字零） | 15min | 9f/90l/15min | 无 | - | done |
| S2 | （A6）组 B 九文件三结构统一升级 | 继承 | 同上 | 组内自检全过（181+；publish 既有 Batch 保留只补缺） | 15min | 9f/90l/15min | 无 | - | done |
| S3 | （A6）组 C 十文件三结构统一升级（含 rule-enhancement 7 列表替换） | 继承 | 同上+§3 特例条款 | 组内自检全过（218+/3-；7 列表=0） | 15min | 10f/100l/15min | 无 | - | done |
| S4 | （A7）回归+合并部署 push+簿记 | code-runner-agent | worktree 路径+stash 窗口法 | VC-2/3/4 全过 | 15min | 1f/10l/15min | 无 | S1,S2,S3 | done（主进程白名单①②直做） |

## 不变量
- mini-lite/l0-lite 零改动（Rule 38.2 白名单：增仪式区块=模板违约，selftest-plan-tier 断言）；既有段落语义零改动（增量追加文件尾/rule-enhancement 表替换除外）；零新脚本。

## 判例与条款文本
见 findings.md（统一增量块逐字+处置规则+特例）。
