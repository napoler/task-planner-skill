# 60-explore-v107-legacy — v107 遗留复核查 checkpoint（主进程转写）

> 2026-10-02 由 Explore 子代理只读执行，无 Write 权限未自落盘；主进程据其返回消息转写（Rule 22.8 检查点补记）。

## 执行摘要
status: partial（只读审计完成，A~E 全节判定带证据；checkpoint 自落盘受阻已转写）

## A. R 系列实测
- R-04 已解决：template-guide.md:32「29 个」、:76「5 核心+3 辅助+29 variant=37」；template-mapping.md:39 计数链「v115 回流起 29 类」；grep '26 个\|23 个' 0 命中。清账=0b680bd/84b1dd5/3f829ab 三跳。
- R-05 部分解决：INSTALL_zh.md:296-310 与 critical-rules.md:357 已 29 口径；**残留=critical-rules.md:326「沉淀模板质量对齐既有 13 变体」现行时态与实测 29 不符**（:320 历史叙事可辩护）。
- R-07 仍 OPEN：裸 `references/critical-rules.md` 残留于 plan-cost-guard/references/cost-control.md:168、cost_log.md:7,69、plan-template-kit/references/template-mapping.md:39。
- R-09(CONTRIBUTING) 仍 OPEN：CONTRIBUTING.md/CONTRIBUTING_zh.md:47,52,137 幽灵 `bash scripts/validate.sh`（仓根无 scripts/、validate.sh 不存在，实为 lib/verify.sh）+ 幽灵 flag `--force`/`--target`（install.sh 实 flag 集=--canonical/--tools/--no-verify/--no-backup/--dry-run）。
- R-10 部分解决：task-planner/SKILL.md:57 已 bun .ts；**残留=CLAUDE.md:81 `python3 -m py_compile …session-catchup.ts` 语义错**。
- R-01 部分解决：SKILL.md:64 已「6 个文件（v107 R-01 清账）」；**残留=CLAUDE.md 目录树 grep knowledge-brief 0 命中，缺第 6 文件行**。
- R-15 部分解决：dispatch-examples.md DX-01..03 在位；**残留=batch-quality-gate.md:111「批量 variant 枚举 publish」未含 video/video-fix**。
- R-03/06/08/11/13/14 已解决（实测证据见 sub 返回）。

## B. 待裁决口径
- B1 (P-5) 仍 OPEN：SKILL.md:9 frontmatter 具名枚举止于 Rule 36（v116 仅加「含 40-45」括注）；正文 :305 已全列 40-45——frontmatter 与正文索引面不齐。
- B2 (T-1) 已解决：writing:27/research:26/publish:29 注脚「示例值（目标项目相对）」在位；4 幽灵脚本仓内 0 实存。
- B3 (T-2) 部分解决：主模板三区块在位（task_plan.md:336/363/375）；29 variant 中「委派统计」仅 memory-hygiene 1 家有（mini-lite 设计豁免，实缺 27 家）；「Handoff 登记表」缺的 12 家恰为 v115 回流的 video/image 族（回流未级联 v108 区块补全）；Drift Log 仅 mini-lite 缺（设计豁免）。
- B4 (C-P6) 部分解决：三处均已 .ts 化无 .py 残留，但 plan-resume/SKILL.md:246 为裸名、无宿主/全路径统一口径（sub 标注：:246 是概念对比表，「不统一」或属误读，需主进程裁决）。

## C. D6-19 仍 OPEN：CHANGELOG.md:108-110 [Unreleased]「### 删除」段=(无)；2337ce0（README/INSTALL 移入 skills/task-planner/ 删仓根英文版）删除回填未补。事实面实证：仓根 README.md/INSTALL.md 不存在、skills/task-planner/{INSTALL,README}.md 存在。

## D. videop1 全部达标：主仓 skills/ 与三宿主均无 videop1；主仓 variant=29，三宿主 task-planner 位各 29（单轨化成立）；v115 佐证 commit 3f829ab/7f55722/fa38067。

## E. P-4 守卫成立但零余量：SKILL.md 'Rules 1-39'=2、CLAUDE.md=1、README_zh.md 'Rules 1-45'=2、skills/task-planner/README.md 'Rules 1-39'=1 → 合计 6=守卫下限（任一锚行被删即 WF-10 FAIL，登记风险）。

## 附：部署分叉审计（Explore 第 1 份报告）
- 三宿主 task-planner 与主仓唯一分叉=scripts/selftest-workflow-orchestration.sh（宿主为 v116 前旧版，md5 三宿主一致=部署未跟上，非本地改动；同步=单向 cp，无回流面）。
- companion/.backup-20260930/1001-* 共 4 个目录全部 gitignore 覆盖（.gitignore:8 `.backup-*/`），git status 干净；非阻塞，可择机清理。
- 三宿主顶层 review-library 11 池软链 11×3 全部有效；软链解析到宿主副本（当前内容与主仓等价）。
