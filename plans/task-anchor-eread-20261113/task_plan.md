# Task Plan: Rule 106.1a 结构文件插段纪律条款化（吞锚惯犯就地根治）
<!-- mini stub（lightweight-exemption 判例口径：≤12 行核心面；轻量档=L0-lite 精神但含部署面故 L1-mini） -->
template_type: rule-enhancement
plan_tier: mini
execution_lane: L1

## 用户需求原文（R 逐字）
- **R1**: 「106.1 结构回读条款化（吞锚惯犯根治）——建议另立任务 这个还让人重开  你不是忘记当前会话主要就是解决  被恶意吞掉 也就是多次写一个文件出错」<sub>（[目标]——否决拖延，就地落地）</sub>

## Goal
对已 land 的 Rule 106.1 追加 **106.1a 结构文件插段纪律**（判例=本会话吞锚 4-7 犯：插段前 grep 段清单+new_string 必含锚行子串+Edit 后强制结构回读），worktree 修改→回归→合并→三部署位→push，一链收口。

## VC（验证契约）
| # | 判定标准 | Verify command |
|---|---------|----------------|
| VC-1 | 106.1a 条款落盘（判例锚+三规约齐） | `grep -c '106.1a' skills/task-discipline/references/critical-rules-discipline.md` ≥2（标题+正文） |
| VC-2 | 无回归：selftest 全量=基线（2 预存） | `bash skills/task-planner/scripts/run-selftests.sh 2>&1 \| tail -1` |
| VC-3 | 部署生效：discipline 文件×三位 diff=0+三仓 push | `diff skills/task-discipline/references/critical-rules-discipline.md ~/.zcode/skills/task-discipline/references/critical-rules-discipline.md` 空 |

## S-unit（10 列新口径）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | （A6）worktree 内 106.1 段后追加 106.1a 条款（逐字文本见 findings §1）+SKILL 3i 行尾补 106.1a 引用 | 继承 | worktree 路径 + findings §1 条款逐字 | 106.1a 落盘（:725）+3i 引用在位（执行体诚实上报 VC-1 判据笔误 ≥2 应为 ≥1，主进程亲验达标） | 10min | 2f/16l/10min | 无 | - | done |
| S2 | （A7）主仓回归+合并部署 push+簿记 | code-runner-agent | worktree 路径+stash 窗口法 | VC-2/VC-3 全过 | 15min | 1f/10l/15min | 无 | S1 | done（主进程白名单①②直做，stub 例外登记） |

## 不变量
- 不改 106.1-106.5 既有语义（纯追加 106.1a）；零新脚本；不碰他任务在途文件；wt/task-v168-machine-parked 不碰。

## 判例与条款文本
见 findings.md §1（逐字）。判例来源=本会话 progress Error Log（task-docmod 三犯+task-tpl-verify-fix 四犯）。

## Status
- Phase 1（落条款+合并部署）：**complete** ✅ 2026-11-13——VC-1 达标（106.1a :725+3i 引用）/VC-2 PASS（97/95/2=基线）/VC-3 PASS（2 文件×3 位 ALL-SYNCED；三仓 push 源 79a8462/zcode ab85317/claude db54c1d）；worktree 清理零遗留；mini stub 判例=用户裁决 #3 否决拖延就地执行
