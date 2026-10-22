# Drift Check — Phase 1（task-kb-cr-lits-20261023）

> **降档承接声明**：本判定为降档承接——drift-checker 两连 provider 故障，按 22.3 兜底链由通用子代理承接。判定语义照 drift-checker SOP：只读判定 + 唯一写=本检查点。

- **判定**：**ALIGNED**
- **检查范围**：Phase 1 动作（worktree `wt/task-kb-cr-lits-20261023`，基线 923aa54）vs R1-R2 射程
- **判定锚**：R1=修 L-1~L-8 全 8 项；R2=收口链（部署/推送属 Phase 4，Phase 1 不涉远端操作=不漂移）；VC-1~5 为验收面

## 证据 — commit 清单逐行对照 R 射程

`git log --oneline 923aa54..HEAD` = 7 个提交（与期望 7 个 fix/feat 一致；6 fix + 1 feat）：

| # | commit | 声明 L 项 | 触碰文件 | 射程判定（scope_files 对照） |
|---|--------|----------|----------|------------------------------|
| 1 | `93e998c` fix L-1/L-8 | L-1 k8s 双 glob 并集 + L-8 delegation 日期 nit | `scripts/check-delegation.sh` | ✅ 射程内（L-1 登记文件 + L-8 ③日期 nit） |
| 2 | `df8502b` fix L-7/L-8 | L-7 机械产物抽单函数 + L-8 ①②头注/留痕 | `scripts/check-scope.sh` | ✅ 射程内（L-7/L-8 登记文件） |
| 3 | `5abd917` fix L-6 | 轻量档文案改真语义（零行为变更） | `scripts/task-plan-init.cjs` | ✅ 射程内（L-6 登记文件，D-L6 裁决 (b)） |
| 4 | `1f4da9d` fix L-8 | 模板 kb-* 路径基准统一 | `templates/task_plan.md` | ✅ 射程内（L-8 ③模板 nit 行 353/355 区） |
| 5 | `b69ed9e` feat L-3/L-4 | RC-28 守护 51.13 + 头注 RC 计数同步 | `scripts/selftest-requirement-coverage.sh` | ✅ 射程内（L-3/L-4 登记文件） |
| 6 | `9484bb2` fix L-2 | LANE 精确 token 解析（仅 L0-E 豁免） | `scripts/check-tier-consistency.sh` | ✅ 射程内（L-2 登记文件，D-L2b 裁决） |
| 7 | `3544076` fix L-5 | 计数口径 74→76（实测 dedup）+ 行数注 193→203 | `README.md` + `docs/ARCHITECTURE.md` | ✅ 射程内（L-5 两登记文档，D-L5b 扩面） |

**R1 完整性**：L-1~L-8 全 8 项均有 commit 覆盖（L-8 三 nit 分布于 #1/#2/#4）。`git diff --stat 923aa54..HEAD` = 恰好 8 文件 110+/40-，**全部 ∈ 执行范围限制表（5 脚本+2 文档+1 模板）**，无越界文件、无顺手重构面。

**R2 远端面**：Phase 1 无任何 push/部署动作（收口链=Phase 4 白名单，当前 pending）→ 不漂移。

**工作区状态**（`git status --short`）：仅 2 处 untracked，零受管修改：
- `?? tmp/` = 5 个 VC-2 夹具（vc2-l0e/l0/l0t/l0t2ph/l0-scope12/task_plan.md）——§五 P1 夹具豁免区，合法
- `?? plans/task-kb-cr-lits-20261023/` = subagent-state 检查点×8（1-s1…7-s7 + 8-s8-regression）——Rule 22.8 协议簿记产物（task_plan Handoff 表明示 `<wt>/plans/.../subagent-state/` 路径），**非代码变更，非射程越界**；注：任务描述期望"仅 tmp/ untracked"，此处多出 plans/ 簿记区属协议规定位置，判不漂移

**VC-1~5 验收面**（progress.md Phase 1 段回填）：VC-1 双清单 k8s 同列 PASS / VC-2 五夹具 exit code PASS（l0e=0, l0=1, l0t=0, l0t2ph=1, l0-scope12=1）/ VC-3 28/28+头注 PASS / VC-4 dedup=76 正文 74 口径清零 PASS / VC-5 文案 0 残留+单函数 5 处 PASS。

**非漂移观察（登记备查，不影响判定）**：
1. `8-s8-regression.md` 检查点已在位 = Phase 2 S8 回归已启动（与 task_plan `Current Phase: Phase 2` 一致，属计划正向推进，非 Phase 1 漂移）
2. findings「登记不修（CR 呈现）」4 项（阻断文案 stdout / 跨文件行号锚漂移 / 路由表编号列快照 / registry.tsv 八子条历史口径）= 主进程显式范围裁决，射程外但已登记，不构成漂移

## 留痕三件套行

| 时间 | 结果 | VC 条目 | 结论 |
|------|------|---------|------|
| 2026-10-23 02:44 | 只读判定 PASS（git log/status 取证 7 commit + 8 scope 文件 + 2 untracked 簿记区；降档承接=drift-checker 两连 provider 故障） | VC-1~VC-5 | **ALIGNED**：动作与 R1-R2 射程一致——仅 L-1~L-8 登记射程内 8 文件变更，无越界，无 Phase 1 远端操作；无偏离面 |
