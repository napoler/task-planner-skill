# Task Plan: task-veriffirst-20261116（#2 验证前置定位增量 — mini stub，L0-lite 双门放行口径，零新脚本零 attest）
<!-- plan_tier: mini | execution_lane: L1-lite（纯文档条款增量，§11.5② 豁免 worktree；主进程直做） -->
<!-- 背景：/goal #2 诉求（验证前置定位）未含于已 COMPLETE 的前计划 task-superpowers-openspec-routing-20261116（其定稿早于 #2 入档 11 秒），本计划为独立 mini 增量；设计稿=plans/task-superpowers-openspec-routing-20261116/increment-veriffirst-draft.md -->

## Goal
spec-mode.md 文末落「## 5. 验证前置定位」段（目标驱动/测试驱动宣言+验证三载体映射+反模式）+SKILL.md Spec 模式行尾指针+skill-collaboration.md 初筛段行尾验证依赖信号句——定位层与既有 §1b 复杂度路由层同构互引，形成 Superpowers×OpenSpec「定位+路由」融合闭环。

## 用户需求锚（Rule 51.1）
- R1 [目标]（逐字锚=plans/task-superpowers-openspec-routing-20261116/user-session-log.md#2）: 「就是将将验证放在前置，就是验证脚本或者是验证规则规范放在前置，确保就是在整个任务开始的初期，在不偏移的情况下，就确定好目标以及评审方案。而不是后期执行，在任务偏移之后，出现了执行，然后再去编写验证，这样可能就是说可能会存在严重的隐患。……大体就是这个意思，我希望将整个项目的项目放在这种定位。」

## ✅ Verification Contract（验证前置：改动前基线=/tmp/veriffirst-baseline.log，采集先于任何编辑）
| # | 判定 | 验证命令 |
|---|------|---------|
| VC-1 | spec-mode.md §5 段在位（定位宣言+三载体映射+反模式） | grep -q "验证前置定位" skills/task-planner/references/spec-mode.md && grep -q "后期补验证" skills/task-planner/references/spec-mode.md && grep -q "test-driven-development" skills/task-planner/references/spec-mode.md && grep -q "openspec-verify-change" skills/task-planner/references/spec-mode.md |
| VC-2 | SKILL.md Spec 模式行尾 §5 指针在位 | grep -q 'spec-mode.md` §5' skills/task-planner/SKILL.md |
| VC-3 | skill-collaboration.md 初筛段验证依赖信号句在位 | grep -q "验证前置定位" skills/plan-collab-router/references/skill-collaboration.md |
| VC-4 | 回归无新增 FAIL | post-edit run-selftests Total 对照基线：FAIL 增量=0（新 FAIL 逐项归因，非本增量改动面→登记预存/他因） |
| VC-5 | 纯增量（既有文字零改动） | git diff 三文件：删除行=0（行尾追加行以 PREFIX-OK 判：新行以旧行全文为前缀） |
| VC-6 | 4 部署位同步 diff=0 | for 4 位 × 3 文件 diff -q 对照 master |

## Phases
- [x] P1 基线采集+锚点确认（基线 nohup 先于编辑启动；三载体锚已 Read：spec-mode §4 尾行/SKILL.md:65 行尾/collab:55 行尾）
- [x] P2 三载体条款落地（spec-mode §5 由 code-assistant 子代理落段[委派守卫拦主进程直写]，SKILL.md/collab 两处行尾追加主进程完成；落段后发现任务书字形损坏两处已派原代理修正并盘上复核）
- [x] P3 回归对照（VC-4）+部署同步（VC-6）
- [x] P4 收尾簿记（commit fc37133 + 4 位部署 diff=0 + memory 更新）

## 📋 执行记录（2026-11-16 03:19-03:28 收口）
| VC | 结果 | 证据 |
|----|------|------|
| VC-1 spec-mode §5 | PASS | grep 验证前置定位/后期补验证×2/test-driven-development/openspec-verify-change 全命中（子代理自验+主进程盘上复核双确认） |
| VC-2 SKILL.md §5 指针 | PASS | grep 'spec-mode.md` §5' 命中（行尾 PREFIX-OK 追加） |
| VC-3 collab 初筛段信号句 | PASS | grep 验证前置定位 命中（行尾 PREFIX-OK 追加） |
| VC-4 回归 | PASS | 改动前基线 Total 98/93/5（/tmp/veriffirst-baseline.log）vs 改动后 Total 98/93/5（/tmp/veriffirst-post.log）——**FAIL 同集零增量** |
| VC-5 纯增量 | PASS | numstat spec-mode 16/1（1 删=EOF 换行规范化，锚行文本同文成对）、SKILL 1/1、collab 1/1（均 PREFIX-OK） |
| VC-6 部署同步 | PASS | commit fc37133 后 cp ×4 位，diff -q 12 对全绿 |
| outcome | **COMPLETE** | 全 VC PASS；commit=fc37133；部署=4 位 diff=0 |

**基线污染归因登记**：改动前基线 FAIL=5 多于对方 02:57 master 跑的 FAIL=2（多出 registry/self-resolution/summary-readability 三项）——采集窗口恰逢 mdedit merge 落盘（03:11:38-56）+本增量两处行尾追加落盘，属混合态样本；因改动后跑与基线**同集**，本增量零回归结论不受影响。该 3 项预存 FAIL 归因=mdedit 合并/环境漂移，非本增量改动面，登记观察不处置（scope 外）。

## 变更标注表（Rule 74.3 — 增量默认，无删除无替代）
| 编号 | 对象（文件+锚点） | 类型 | 吸收判定 | 用户原话（节选） | 执行动作 |
|------|------------------|------|---------|----------------|---------|
| CA-1 | skills/task-planner/references/spec-mode.md（§4 尾行后） | 新增（§5 段） | 增量 | 「将验证放在前置……任务初期就定好目标以及审核评判机制」 | 文末追加 §5 全段 |
| CA-2 | skills/task-planner/SKILL.md（:65 行尾，既有 §1b 指针之后） | 修改（行尾追加） | 增量（PREFIX-OK） | 同 R1 | 行尾追加 §5 指针半句 |
| CA-3 | skills/plan-collab-router/references/skill-collaboration.md（:55 行尾） | 修改（行尾追加） | 增量（PREFIX-OK） | R1+「促进融合」 | 行尾追加验证依赖信号句（互引 §5） |

## 竞态登记（2026-11-16 多会话赛道）
本增量执行窗口内 master 先后落地：superpowers-routing 收口（42ab794/4189ec6/60dd179）+mdedit feat 合并（794492a/88fc7d9/71e32dc）；三载体在本次编辑前实测 clean、4 位已同步 mdedit 内容。本增量提交用 pathspec 锁定（禁 add -A 捎带），部署同步从 commit 后 master 内容 cp。
