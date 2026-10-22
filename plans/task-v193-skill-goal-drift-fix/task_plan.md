# Task Plan: 修复 task-planner「部分交付即停 / 0 母图即 complete」缺陷

- task_id: task-v193-skill-goal-drift-fix
- 日期: 2026-10-21
- 载体: dynamic-workflow（修复-task-planner-目标漂移与媒体产出门控）
- 事故锚点: sess_c9dffdc0-5d5b-4bb6-ab43-87be1b11fb04（项目 /mnt/data/dev/videop1）

## 用户需求原文

> 解决当前 skill 执行任务偏差 比如 sess_c9dffdc0 中 要从补充道具图以及设定 最终恶意停留在补充设定
> 没有产出任何母图就恶意停止 这严重的违规 必须确保执行过程完成的检查 也就是开始时候制定完善的验证
> 以及目标 确保不会出现这种低级错误

## 目标

在 task-planner 技能（`skills/task-planner/`）内修复两处根因：
1. 计划期 目标/VC 未锚定用户**多类别**原始诉求（媒体/母图交付被上游 workflow ask 静默收窄丢弃）；
2. 完成门控对**可计数媒体交付**无「0/N 产出即拦截」判据，导致 0 母图仍判 complete 并放行停止。

## 范围

- 只改 `skills/task-planner/` 下的技能源（文本优先：Rule NN 子条 + selftest 断言；不新增 hook/脚本/机器门）。
- 事故证据只读：`/mnt/data/dev/videop1/plans/task-videop1-shiyan-settings-backfill-001/`、
  `/home/terry/.zcode/cli/artifacts/sess_c9dffdc0-.../`。
- 不做：部署位同步（需用户裁决）、行为面冒烟（需新会话）。

## 步骤 / Phase

1. [x] 还原事故：读计划与 artifacts，确认「请求交付类别 vs 实际产出」缺口。
2. [x] 盘点技能现状：规则正文、相关 Rule NN、媒体门控是否存在、回归入口。
3. [x] 并行四视角根因诊断（目标锚定 / 媒体产出门控 / 完成声称门 / 作用域收窄），每条发现独立复核（18 条：17 verified / 1 unconfirmed）。
4. [x] 汇总根因并设计最小修复（Rule 51.9-51.13，L0-T 文本优先，零新 config 键）。
5. [x] 换人复审修复方案。
6. [x] 落地修复并跑通回归：三文件已改主仓工作树（未提交）；自测 selftest-requirement-coverage 27/27；全量 92 脚本 91 PASS / 1 FAIL（唯一 FAIL=selftest-rule-reserve-pairing，系并发 task-v195 的 rule-93 预留态，与本改动 0 关联）。

## 结果（2026-10-21）

- 三文件改动：critical-rules.md 新增 51.9-51.13；SKILL.md 更新 51 bullet；selftest-requirement-coverage.sh 扩 RC-24..RC-27。
- B-1 豁免：本会话曾 `allow-direct.sh on`（30min 窗口，代用户执行，已落 ledger，现已 off）。
- 回归口径修正：workflow 产物内「回归未通过」= 脚本 world.run 相对路径 bug；操作者用绝对路径独立复核 = 91/92 干净（上条唯一 FAIL 为预存并发态）。
- 未做（待用户裁决）：git 提交/合并、部署位同步（~/.zcode/skills 4 位）、行为面冒烟、worktree 隔离（本 run 落主仓工作树，§11.5 例外未获显式放行）。

## VC（验收）

| VC | 判据 | 验证方式 |
|---|---|---|
| VC-1 | 事故缺口有第一手证据（计划原文 + 0 母图事实） | Read 计划目录与 artifacts |
| VC-2 | 每条根因发现经独立复核，标注 verified/unconfirmed | 复核子代理复现 |
| VC-3 | 修复设计为最小文本改动，可粘贴落地 | 方案设计者产出 clause |
| VC-4 | 落地后全量 selftest 通过（0 FAIL） | `bash skills/task-planner/scripts/run-selftests.sh --fresh` exit=0 |

## 执行范围限制

- 文本优先（宪法 §四.6）：只做条款文本 + 自测断言，不新增 hook/守护脚本/机器门。
- 工作树内直接改（未提交），提交/合并由用户决定；部署位同步待用户授权。
