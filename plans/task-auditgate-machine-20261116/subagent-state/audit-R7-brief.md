# R7 复审任务书 — task-auditgate-machine-20261116（R6 APPROVED 后修订轮 R6a + 登记簿记的范围化复审）

你是本计划的独立审计体（R7 复审轮）。工作目录 /mnt/data/dev/task-planner-skill。除检查点外只读审查，禁修改任何仓库文件。

## 背景与需求锚

用户需求逐字锚（user-session-log.md #1）：「三、未完成项与风险 1 授权 2 测试」。计划需求锚 R1=「1 授权」R2=「2 测试」R3=「三、未完成项与风险」。plan_tier=standard / execution_lane=L1。

审计轨迹（progress.md 全录）：R1×14→R2×6→R3×1→R4×2→R5×2 全部修复；R6 **APPROVED**（0C/0I）。R6 后主进程登记裁决时以 /tmp 一手实测发现 checker 聚合设计的**中间态假阳性**（末段聚合吞进修复轮块反引号元引用 `结论: **APPROVED**` → head -304 截断态伪 PASS）→ 修订轮 R6a 加固（① 聚合边界止于下一个 H2 `## ` 行 ② 结论行 ERE 行首结构锚定 `^- 轮次: R[0-9]+ \| 审计体: .+ \| 结论: \*\*APPROVED\*\*` ③ 中间态负例进 VC-1 r4 与 VC-3 fixture）。

## R7 复审范围（范围化，禁重审全计划）

只审四面：
①**R6a 加固闭环**（progress.md R6a 段 + 三落点）：
- task_plan.md :38/:78/:141/:275 两约束落点语义完整、互洽
- verification.md :15 VC-1 判据 + :17 Verify command（r4 中间态负例：REJECTED 段+后随含反引号 APPROVED 元引用的修复轮块→必 rc1；注意 r4 用 sprintf %c 96 构造反引号避命令注入——核验该构造正确性与命令无反引号包裹）+ :23 VC-3 fixture
- knowledge-brief.md :27 加固说明
- 判别性抽测：自建 /tmp mock 按两约束实现，对四态（终态 APPROVED/中间态假阳性/纯 REJECTED/无留痕）复测 rc 与预期一致；对照当前真实 progress.md 末段聚合 → rc=0（真实终态不假阴）
②**登记时点簿记**（主进程 R6 登记时同步，critic R6 建议项）：
- progress.md [plan-audit-R6] 段三 token+APPROVED 为最后审计段；锚定形态计数=1
- progress.md 5-Question 块已刷新（W-1 处置）；verification.md :207 已同步（N-1 处置）
- task_plan.md Handoff 登记表 #6-#16 回填与 :440 计数行更新（N-2 处置）——核验 16 行与 progress.md 审计轨迹/修复轮段一致、无虚构
③**修复是否引入新缺陷**：R1-R3 逐字锚 task_plan.md:16-18 未动；user-session-log.md 未动（mtime 2026-11-16 23:39:23）；无新增 [plan-audit-RN] 段（R6 后应为 6 个审计段）；表格内管道字符未破坏 check-plan-dispatch 列解析（R6a 自曝缺陷已修正——复跑核验 SKIPPED=0）；八机械门 rc=0
④历轮遗留升级必要性（R6 残留 1W+3N 留档项有无升级论据；无则维持留档）

## 输入材料（绝对路径，只读）

- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/{task_plan.md,verification.md,progress.md,findings.md,knowledge-brief.md}
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/subagent-state/（audit-R4/5/6、fix-R4/4b/5/6a 检查点）

可做 /tmp 沙箱模拟实测（禁写入仓库目录）。

## 裁决映射（审计体出具，主进程只登记）

`0 CRITICAL 且 0 IMPORTANT ⇒ APPROVED，否则 REJECTED`；WARNING/QUESTION/NIT 留档不阻断。

## checkpoint:（唯一允许写入点）

/mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/subagent-state/audit-R7.md — 动工前写，完成后追加裁决与发现清单。

## 输出格式（8 字段返回模板）

- status:/result:/evidence:/files_modified:/verification_results:/learnings:/next_steps:/risks:
发现清单逐条：编号+严重度+文件:行+一句描述+修复建议；末行唯一裁决行 `结论: **APPROVED**` 或 `结论: **REJECTED**`。
