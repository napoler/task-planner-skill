# ck-audit-r3 — 计划独立审计 R3（简版：R2 后主进程亲修增量 + R2 问题闭环）

- 审计体: critic（只读计划文档；除本 checkpoint 与 progress.md 追加行外未写任何文件；未改 worktree 源码）
- 时间: 2026-11-20T22:09:49+08:00
- 对象: verification.md 的 VC-1..VC-5 命令现况 + task_plan 判定标准 + knowledge-brief 口径 + worktree 基线实证
- 裁决: **REJECTED**（C=0 I=2 W=2 NIT=3）

## 1. 闭环核对基线（已读）
- progress.md [plan-audit-R1]/[R1 处置]/[R1-fix]/[R2]/[R2 处置→主进程亲修] 全段；ck-audit-r2.md；verification.md 全文（1-193）；task_plan.md VC 表 88-96 + CA 表 152-154 + FMEA 320；knowledge-brief.md §1-§5。
- worktree `tmp/worktrees/task-pointer-switch-defect-20261120`：git status 干净、HEAD=f4dc96b（未开工），init-session.sh:1235-1238 / set-active-plan.sh:259-278 仍为裸匹配 + skip。

## 2. 独立复跑（全部自建夹具，/tmp/pts-audit-r3）
命令抽取方式：从 verification.md 逐行抽 `**Verify command**: bash -lc '...'` 共 **13** 条 → bash -n 全 OK。

| 命令 | 未修 worktree | 规范修复 mock | 判别力 |
|------|--------------|--------------|--------|
| VC-1 (L16) | rc=1（side 目录不存在，stderr=「skip 写入防沿袭互踩」） | rc=0（side=new-switch-task，stderr 含 old-claimant + 挂起/恢复） | 红→绿 ✓ |
| VC-2 (L20) | rc=1（无「指针未切换」） | rc=0 | 红→绿 ✓ |
| VC-3 (L24) | rc=2（A 夹具误拦，side 未写） | rc=0 | 红→绿 ✓ |
| VC-4 (L28) | rc=1 | rc=0（首版仅 E 块有 attest → rc=1，补进 D 块后绿，证明断言有齿） | 红→绿 ✓ |
| VC-5 (L33) | rc=1（PL-11 缺） | rc=0 | 红→绿 ✓ |
| V-1.1/V-1.2/V-2.1/V-2.2/V-3.1/V-4.1/V-4.2 | 1/2/1/1/2/1/2 | 全 0 | ✓ |
| V-3.2 | 0 | 0 | 纯回归面（非判别项） |

红绿旁证：
- VC-3 换等价正则拼写 `(\*\*){0,1}` → rc=0（不做字面绑定）✓
- VC-5 提交越界新脚本 `skills/task-planner/scripts/new-guard.sh`（commit）→ rc=1 ✓（R2-I2 闭环）
- VC-5 `git mv` selftest 到 `skills/task-planner/evil/` 并提交 → rc=1 ✓（rename 不可绕过）

## 3. 新发现（本次未闭环项）
- **I-1** VC-5 判别面不足：selftest 被改成「零断言 + 仅 `# PL-11 TODO` 注释」→ VC-5 rc=0；仅保留 PL-11/PL-12 两条 → rc=0。即 VC-5 文本要求的「PL-01..PL-10 语义保留」与「新增断言覆盖 init 一次切换/通告/fallback 门控/非加粗不漏判」均不可验。
- **I-2** VC-3 缺模板散文夹具：以 `grep -Eqi '^\s*[-*]\s*.*status.*in_progress'`（行首锚定但未锚 `Status:` 控制行）替换 → VC-3 rc=0；但真实模板散文行 `- Update phase status as you progress: pending → in_progress → complete`（templates/task_plan.md:511，仓内多份真实计划同款）导致 complete 态 claimant 被误拦（side=MISSING、输出「指针未切换」）。与 task_plan.md:93 判定标准「模板散文/注释误命中」不一致。
- W-1 VC-3 静态反向断言恒真：`grep -Fq "grep -qi Status.*in_progress"`（无引号字面）在含 `grep -qi 'Status.*in_progress'`（带单引号）的未修代码上亦不命中 → 该断言从未判别，注释却宣称「剥注释后无裸 grep 字面」。
- W-2 VC-2 只验文案 + rc，不验 side 未写入（文案/状态矛盾不判红）；状态面由 PL-10 交叉覆盖，但受 I-1 影响不成立。
- NIT-1 progress.md:127「全 14 条 Verify command」实为 13 条（第 14 个命中是 :12 的说明行文本）。
- NIT-2 knowledge-brief §2 把裸 grep 锚成 `init-session.sh:1235`/`set-active-plan.sh:273`，实际为 1236 / 261（§3 区间 1229-1256、259-278/265/266/278 正确）。
- NIT-3 VC-1 的 `grep -q "old-claimant"` 属弱锚（任意上下文回显即可满足）。

## 4. R2 问题闭环矩阵
R2-C1 VC-3 恒红 → 已闭环（现红 rc=2 / 规范修复绿 rc=0 / 等价正则绿）
R2-C2 VC-5 语法错+恒真+commit 绕过 → 语法/红绿/commit/rename 四面已闭环；但残留判别面缺口=I-1
R2-I1 VC-4 缺 attest 断言 → 已闭环（断言有齿，置于 E 块时 rc=1）
R2-I2 commit 绕过 → 已闭环（越界提交 rc=1）
W-1 字面绑定 → 已闭环（行为夹具，等价拼写仍绿）
W-2 PL-11 无判据 → 部分闭环（仅存在性判据，见 I-1）
W-3/NIT → 留档，无阻塞

## 5. 断点续做指引
- mock 仓：/tmp/pts-audit-r3/{mock(规范修复,12 PASS), mock_alt(等价正则), mock_oos(提交越界), mock_gut/mock_min/mock_mincmt(selftest 掏空三态), mock_rename, mock_naive2(松散锚定=散文误拦)}
- 命令副本：cmd01..cmd13（原文抽取）、mock_*/oos_*/ren_*/alt_*/naive2_*/gut_*/min_*/mincmt_*（替换 WT 与基线 sha 后版本）
- 若续做：先核实 I-1/I-2 修正后再跑 cmd03/cmd05 双 mock 对照即可判定
