# S27 A-3 COMPLIANCE-CHECK — checkpoint

## 状态: in_progress（实施中）

## step1 进场核对 ✅
- HEAD = 53ff7833ec635a838cb355037fcf1b092b425a95 (53ff783 = S26 commit)
- git status --short 空

## step2 设计定案
- 插入位: check-complete.sh AUTO-TIER 段(:961)之后、warn-count 段(:964)之前；位于 C-2 键③ sed 锚区（:484 锚区间 :505「FMEA 门控终验点」→:570「失败挽救链路终验门控」）之外 → 键③哈希不变 → 全量重跑后 SKIP 复效
- 映射表: 脚本内表（提案「脚本内表或 registry」→ 选脚本内表，零新文件零 registry 同步负担）
- 检查项(tier 分域):
  - 3-file(findings/progress 存在): standard=机器可查缺失点名; mini=38.4 豁免跳过
  - VC 表行数: standard≥5 / mini≥2 (同 VC-GATE 降档口径)
  - V-N 映射≥1/Phase: 仅 standard; mini=38.4② 豁免跳过
  - 委派统计段(verification.md): standard 缺失 warn; mini 模板无该段 → 缺失静默(不误报)
  - Handoff verify_done 全勾: standard; mini=6列简化表无 verify_done 列 → 跳过
- warn 档: 全部缺失 → [compliance] WARNING 点名, 不阻断(exit 码不动=python_rc)
- mini 判定复用既有 PLAN_TIER_MINI(:606 已算)

## step3 实施 ✅（commit a243253）
- 插入位=check-complete.sh :961 后（AUTO-TIER 段后、warn-count 段前），键③哈希覆盖段之外
- 键③哈希对拍: HEAD@53ff783 与工作区 sed 段 sha256 逐字节一致 = df727b477adae7204550dceb065b9e7950bafd707caa8ba823acb37d636f67ad
- 新增 63 行: [compliance] 段 = 映射表脚本内（3-File / VC 行数 / S-unit 表 / 委派统计段 / Handoff verify_done），
  mini 域=复用 PLAN_TIER_MINI(:606) 跳过 38.4③ 委派率豁免项（委派统计段/verify_done）+ VC 降档阈值 5→2
- 注释 [2026-09-27 task-v091 S27 A-3]；零触碰 21.4/Rule 26/10 selftest/S20/S23 块语义

## step4 验收 ✅
- 夹具A standard 缺项: rc=0 + [compliance] WARNING 点名 "verification.md 委派统计段缺失(C14/Rule 25)"
- 夹具B mini 豁免缺失（无 verification.md）: rc=0, [compliance] OK（tier=mini 分域，WARNING=0）
- 夹具C standard 完整: rc=0, [compliance] OK, 全输出 WARNING 计数=0
- 10 selftest Total 逐个: veto 13/13, error-loop 16/16, skill-modify 9/9, plan-tier 32/32,
  workflow-orchestration 16/16, conclusion-discipline 24/24, mechanism-profile 19/19,
  reflect-verify 12/12, task-boundary 11/11, template-lifecycle 18/18（FAIL=0, C 锚终核对冲突=0）
- selftest-final-gate-hash: PASS=22 FAIL=0（键③未变→SKIP 复效成立，全量重跑一轮后 SKIP 复效在证=夹具⑥c）
- commit: a243253 feat(task-planner): task-v091/S27 A-3 — check-complete COMPLIANCE-CHECK（tier 感知分域，warn 档）
  （分支 wt/task-v091-efficiency-optimization, 1 file changed, 63 insertions, status clean）
