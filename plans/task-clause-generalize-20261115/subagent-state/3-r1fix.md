# 3-r1fix 检查点（R-1 句尾增量修复）

## 目标文件
`/mnt/data/dev/task-planner-skill/tmp/worktrees/task-clause-generalize-20261115/skills/task-drift-guard/references/critical-rules-drift.md`

## 改动行号
- 64.7 所在行：68（`grep -n '64\.7 用户原话对照锚'` 定位）

## 自验输出原文

### 1) `grep -cF '非 trivial 档专档缺失（文件不存在）与空/零条目同款' <文件>`
```text
1
```

### 2) `grep -cF 'trash 扩批被计划内任务项背书）。非 trivial 档专档缺失' <文件>`（接缝）
```text
1
```

### 3) `git diff --numstat -- <文件>`（相对 HEAD，仅本行）
```text
1	1	skills/task-drift-guard/references/critical-rules-drift.md
```

### 附加：64.7 单行确认
命令：`grep -n '64\.7 用户原话对照锚' ... | wc -l`
```text
1
```

## git diff 全文
```diff
diff --git a/skills/task-drift-guard/references/critical-rules-drift.md b/skills/task-drift-guard/references/critical-rules-drift.md
index 40c941e..aae31f9 100644
--- a/skills/task-drift-guard/references/critical-rules-drift.md
+++ b/skills/task-drift-guard/references/critical-rules-drift.md
@@ -65,5 +65,5 @@
 64.5 **机制守护（mechanism guard）**：机器面五接线——`ledger-append.sh` VALID_EVENTS 增 `drift_check` 枚举（值尾追加，锚行随实现漂移以 grep VALID_EVENTS 为准，既有枚举零改动）；`check-3file-gate.sh` 追加第 6 条件段（既有条件 1-5 语义零改动）；`zcode-posttooluse.sh` 追加计数段（复用既有 additionalContext 注入 helper）；`../../task-planner/companion/agents/drift-checker.md` 判定输入段；SKILL.md 接线 2 处（Phase 循环第 6 步 [DRIFT CHECK] 块内追加 64.1 留痕行 + 合规清单 C4 行末追加留痕句——DCS-01~20 字面锚零触碰）。守护面=`scripts/selftest-drift-enforcement.sh`（静态断言+行为级 fixture（DCE-01~23，随守护面演进），fixture 范式对照 selftest-four-file-dataflow.sh）+ selftest-registry.tsv 登记。What=每处接线挂既有管线+静态与行为双断言；Why=53.2 根治判据=机制·守卫·载体三件齐，条款无挂点=死文（59.6 同范式）；行为 fixture 防「守措辞不守行为」错位复发（根因③）。
 
 64.6 **零新 config 键与既有 Rules 关系**：不新增任何 config.json 键——降档与调参走 env（`TASK_PLANNER_DRIFT_ENFORCE` / `TASK_PLANNER_DRIFT_RHYTHM_N`），豁免走计划声明行 `drift_exempt`（59.7/43.4/44.4 同范式：键膨胀=配置面失控面）。关系：Rule 11/15 触发时机与三态判定原文零改动（本条只加证据链与节奏）；Rule 61 载体契约零改动（64.4 只加输入要求）；Rule 19.2 门控=第三条件追加非改写；Rule 62 四文件流转正交；SKILL.md 上界计数措辞（「1-62」等）本次不动（63 未落地避免计数失真，v146 同款遗留延续）。
-- **64.7 用户原话对照锚强制（专档缺失=禁 ALIGNED — task-drift-fakeqc-20261115 判例）**：drift-checker 检查点判定必须记录**用户原话对照面**=`user-session-log.md` 最近含目标/指令类内容的条目号+一句话摘要（跳过寒暄/确认类条目；同号条目优先——与 51.3 双锚口径一致；61.2「用户目标原话」字段的对照物溯源）；判定基线=计划 Goal ∩ 专档最近原话双锚——专档缺失且 plan 属 trivial 代码修复档（init-session.sh user-session-log 按需创建档）→ 检查点记 `专档=未建档(tier)` 并按 64.1 留痕即可，不判 BLOCKED；专档在位但空/零条目，或 Goal 与最近原话零交集时，ALIGNED 判定无效，按 64.1 未执行处置（64.2 门控拦截）并叠加 🔴BLOCKED 升级用户（防「基线被未授权扩展污染后对污染基线自证 ALIGNED」——被投诉判例计划目录缺专档，80.8 五决策点读取全落空，trash 扩批被计划内任务项背书）。**与 64.2.1 分工**：64.2.1 管零交集的判定与不可豁免（门控面），本条管检查点留痕字段与专档缺失处置（证据面）；同一事实由 64.2.1 定级、本条留痕，惩罚不双计。机制=L0-T 文本锚（64.6 同范式零脚本零新键）。判例锚：被投诉计划 task_plan.md 的 trash 审计任务项条目（取证报告 E6-02/E6-03）+E6-06（专档 NOT FOUND）（判例=task-drift-fakeqc-20261115 判例）。
+- **64.7 用户原话对照锚强制（专档缺失=禁 ALIGNED — task-drift-fakeqc-20261115 判例）**：drift-checker 检查点判定必须记录**用户原话对照面**=`user-session-log.md` 最近含目标/指令类内容的条目号+一句话摘要（跳过寒暄/确认类条目；同号条目优先——与 51.3 双锚口径一致；61.2「用户目标原话」字段的对照物溯源）；判定基线=计划 Goal ∩ 专档最近原话双锚——专档缺失且 plan 属 trivial 代码修复档（init-session.sh user-session-log 按需创建档）→ 检查点记 `专档=未建档(tier)` 并按 64.1 留痕即可，不判 BLOCKED；专档在位但空/零条目，或 Goal 与最近原话零交集时，ALIGNED 判定无效，按 64.1 未执行处置（64.2 门控拦截）并叠加 🔴BLOCKED 升级用户（防「基线被未授权扩展污染后对污染基线自证 ALIGNED」——被投诉判例计划目录缺专档，80.8 五决策点读取全落空，trash 扩批被计划内任务项背书）。非 trivial 档专档缺失（文件不存在）与空/零条目同款按 64.1 留痕+🔴BLOCKED 升级处置——D-4 豁免仅限 trivial 代码修复档。**与 64.2.1 分工**：64.2.1 管零交集的判定与不可豁免（门控面），本条管检查点留痕字段与专档缺失处置（证据面）；同一事实由 64.2.1 定级、本条留痕，惩罚不双计。机制=L0-T 文本锚（64.6 同范式零脚本零新键）。判例锚：被投诉计划 task_plan.md 的 trash 审计任务项条目（取证报告 E6-02/E6-03）+E6-06（专档 NOT FOUND）（判例=task-drift-fakeqc-20261115 判例）。
```
