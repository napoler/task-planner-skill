# ck-audit-r2 — 计划独立审计 R2（简版：变更增量 + R1 闭环）

- 审计体: critic（只读，未改计划文档外的任何文件；仅追加 progress.md [plan-audit-R2] 行）
- 时间: 2026-11-20T21:51:44+08:00
- 对象: task_plan.md / verification.md / progress.md 的 R1-fix 增量 + worktree 源码实证
- 裁决: **REJECTED**（C=2 I=2 W=3 NIT=1）

## 已完成步骤
1. R1 基线建立：读 progress.md [plan-audit-R1]/[R1 处置]/[R1-fix]、ck-audit-r1.md、ck-audit-fix.md、knowledge-brief §3。
2. 12 项修正逐一核落点并实跑 VC-1~VC-5（/tmp/pts-audit-r2，含 canonical mock）。
3. I-1/I-2/I-3 流程口径跨文档一致性核对 + 调用点反查。
4. 产出裁决并追加 progress.md 行。

## 实跑证据（/tmp/pts-audit-r2）
- 未修复 worktree：VC-1=1 / VC-2=1 / VC-3=1 / VC-4=1 / VC-5=127（**语法错误**，非判别性失败）
- canonical mock（init G1+fallback 门控 / set 锚定+文案 / SKILL D+E）：VC-1=0 / VC-2=0 / VC-4=0，**VC-3=1**
- VC-3 绿的唯一路径：同时改 `set-active-plan.sh:197`（gc completed-ttl 行）→ mock2 rc=0（该改动未登记于 CA 表）
- VC-5 语义等价修复版（修 `\"` 嵌套）：未修复 clean worktree 即 rc=0（恒真）；commit 后含越界新脚本仍 rc=0（scope 守卫可绕过）
- 等价正则 `(\*\*){0,1}`（行为已验证匹配加粗/非加粗两形态）→ VC-3 rc=1（字面绑定）

## 断点续做指引
- mock 仓：mockrepo（canonical 修复，含提交态）/ mockrepo2（另补 :197 修复=VC-3 绿）/ mockrepo3（`\(\*\*\)\?` 错误拼写）/ mockrepo4（`{0,1}` 等价拼写）
- 命令副本：vc16/vc20/vc24/vc28/vc33*.cmd、vc5-intent.sh（VC-5 语义等价实现）
