# S8 行号锚批检查点（主进程补写落盘）
> 背景：S8 执行体（agent_6530cf2b）完成文件修改后返回消息陷入重复循环（死循环信号），但 worktree 实际改动完好。主进程按 Rule 22.8「不信返回消息、只信产出物」逐 diff 复核后采信，并补写本检查点（drift-check 整改项 2，2026-10-09）。原检查点编号 17 空缺由此补齐。

## 实际改动（一手 diff 复核，commit fca4f40 内）
1. **D9 selftest-registry.tsv:50**：锚列 `SKILL.md:286,201,310 / critical-rules.md:522-530 / templates/delivery-summary.md:35` → `SKILL.md:206(C35),319(bullet) / critical-rules.md:566-575(51.1-51.8) / templates/delivery-summary.md:35;critical-rules.md 51.8/Q9` + 行内注 `# 2026-10-08 task-v149 行号锚对齐实态（D9）`
   - 主进程复验：SKILL.md:206=C35 行 ✓、:319=Rule 51 bullet ✓、CR:566-575=51.1-51.8 ✓
   - 残留修正（主进程 trivial 承接）：delivery-summary 锚 :35（空行）→ `:36(需求覆盖核对块)`（grep -n 一手实测 :36=`## 需求覆盖核对`）
2. **D10 init-session.sh:380**：注释锚 `SKILL.md:524`（超 498 行范围）→ `SKILL.md:505` + 注 `# 2026-10-08 task-v149 行号锚对齐实态（D10）`
   - 注：505 为改锚时点的全集成实态行号（S16 后 SKILL.md=505 行），语义指「自动路由」描述行
3. **D11 selftest-plan-dispatch.sh:37**：注释锚 templates/task_plan.md:144 语义漂移修正（2 行 diff）
4. **D12 selftest-reliability-institution.sh:14,80**：注释演进滞后补齐（4 行 diff）

## 采信依据
- `git diff 21f7e6b..HEAD -- <四文件>` 逐行 Read 复核（本检查点写作时完成）
- drift-check（23-drift-checker-p3.md）抽查 D9 registry:50 sed 复验属实
- 例外登记：本检查点为主进程代写（子代理返回死循环），非执行体自写——Rule 22.8 目的（断点可恢复+结论必落盘）已满足

## 未验证项
- D10/D11/D12 三处锚未逐 sed 复验（drift-check 同项未验证）——Phase 4 全量回归覆盖（plan-dispatch selftest 在套件内）
