# Task Plan: 计划审计 R1→R9 反复打回根治（审计限流 + 止损）

**状态：COMPLETE（2026-11-21）** — 机器化止损落地，审计域自测全绿，基线 FAIL 不增；已合并 master（c0c7344）+ 两处部署位 md5 diff=0 + 部署位 selftest 全绿。

## 🎯 用户需求原文
> 2 解决2中间存在的问题（= 上一交付遗留第2点：计划审计 R1→R9 反复打回的流程问题，审计限流，本次单独治）

## 目标
把计划审计门从"轮次不设上限、≥3轮无进展仅文本纪律上报"升级为**机器化止损**：能识别"同一问题重复出现=无实质进展"、达到阈值自动升级/上报，并把审计-修正-再审的循环成本降下来（简版输入包、VC 判别力静态前置）。复用上一任务落地的 planctl.py JSON 权威源（audits[] 已存在）。

## 阶段（P1-P4）
- [x] P1 设计审计止损规则：无进展判定（同一 issue token 跨轮重复）、阈值、升级路径（decision-arbiter/用户）
- [x] P2 planctl.py 扩展：audits[] 记录 issue 指纹 + check audit 增加"无进展轮次"判定；提供 `audit-add` 的 --issues 参数
- [x] P3 文本条款：Rule 109 + SKILL.md 审计门把止损从纪律升级为机器门；简版再审输入包（只带上轮问题清单+改动 diff，不重读全量基线）
- [x] P4 selftest + 全量回归 + 合并部署

## 验收
- [x] check audit 能识别"连续 N 轮同一 issue"并给出 FAIL/升级信号（负控制：不同 issue 不误判）— selftest 17/17 + 24/24 PASS
- [x] 全量 selftest FAIL 数不增（基线 8）— 审计域全绿；3 FAIL 经 master 对照确认为基线预存
- [x] 三处部署位 md5 diff=0 — 源仓 + 两处部署位 8 文件 md5 diff=0；部署位复跑 planctl 17/17 + audit-gate 24/24 PASS

## 验证
每阶段 Verify command 见 progress.md；终验跑 selftest-planctl.py 17/17 + selftest-plan-audit-gate.sh 24/24 + 受影响静态锚子集 + master 对照基线。

## worktree
tmp/worktrees/task-audit-rework-cap-20261121（分支 wt/...，基准 master a9061a8，含上一任务 merge 8590bf0）
