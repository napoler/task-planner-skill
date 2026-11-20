# ck-audit-r1 — 计划独立审计（Rule 109 R1）

- 审计体: critic（只读）
- 时间: 2026-11-20T21:17:52+08:00
- 对象: task-pointer-switch-defect-20261120（task_plan/findings/progress/verification/knowledge-brief/user-session-log + worktree 代码）

## 已完成步骤
1. 需求覆盖 + 篡改面：R1 与 user-session-log#1 逐字比对 **213/213 字符全等**（无改写/注入）；Goal 在范围内，未新增脚本/hook 需求。
2. 机制与冲突审计：init-session.sh:1214-1258、set-active-plan.sh:181-288、zcode-userpromptsubmit.sh:237-262、zcode-posttooluse.sh:120-170、check-skill-modify.sh:43-70、resolve-plan-dir.sh:40-110、archive-plan.sh:104-108 全部实读。
3. VC 可执行性：VC-1/VC-2/VC-4 夹具实测「修复前红 → 规范修复后绿」；VC-3 实测**规范修复后仍红**；VC-5 实测**修复前即绿**（恒真）。

## 关键实测证据（/tmp/pts-audit-r1）
- VC-1 于 worktree 原版: rc=1，err=`skip 写入防沿袭互踩`，side 文件未生成 → 缺陷现状复现成立。
- VC-1 于 mock 规范修复（/tmp/pts-audit-r1/mockwt）: rc=0 → 夹具可转绿。
- VC-2 原版 rc=1（缺「指针未切换」）→ mock 修复后 rc=0。
- VC-3 原版 rc=1；mock 规范修复后仍 rc=1（step1 正判据不命中，step2/3=0）。
- VC-5 原版（未改动 worktree）rc=0，scope 文件 0 字节 → 恒真。
- VC-4 mock 补 G2 文案后 dblock=0 / eblock=0（可转绿）。
- mock 规范修复后 selftest PL-01..PL-10 全 PASS（FAIL=0）→ 基线不被 G4 文案破坏。
- 多 owner 实测：a/b/c 三个同 sid in_progress + owner，`set c-plan` 报「被在途计划 a-plan 声明」skip。

## 中间结论
裁决倾向 REJECTED（C=2 I=4 W=5 NIT=1；另有 Q=3）。IN_PROGRESS 无。

## 断点续做指引
如需复核：`/tmp/pts-audit-r1/mockwt`（规范修复 mock，可直接复跑 VC-1~VC-4）；`/tmp/pts-audit-r1/fx1`（原版 VC-1 夹具产物）。
