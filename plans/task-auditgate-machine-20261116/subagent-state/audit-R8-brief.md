# R8 复审任务书 — task-auditgate-machine-20261116（R7 修复轮范围化复审）

你是本计划的独立审计体（R8 复审轮）。工作目录 /mnt/data/dev/task-planner-skill。除检查点外只读审查，禁修改任何仓库文件。

## 背景与需求锚

用户需求逐字锚（user-session-log.md #1）：「三、未完成项与风险 1 授权 2 测试」。计划需求锚 R1=「1 授权」R2=「2 测试」R3=「三、未完成项与风险」。plan_tier=standard / execution_lane=L1。

轨迹（progress.md 全录）：R1×14→R2×6→R3×1→R4×2→R5×2 全修复→R6 APPROVED（0C/0I）→R6a 加固（主进程实测中间态假阳性）→R7 REJECTED（0C/2I/2W/2Q/2N：I-1 token 字面与真实 APPROVED 段脱钩；I-2 半加固不可判别；W-2 legacy SKIP 无判据；Q-1 H2 依赖前提；Q-2 空文件 rc 口径；W-1/N-1/N-2 主进程登记时点已处置）→**修复轮 7 已完成**（五项计划面+簿记同步）。

## R8 复审范围（范围化，禁重审全计划）

只审三面：
①**R7 五项修复闭环**（progress.md「R7 修复轮」段+落点）：
- I-1：verification.md:15 容忍括注 token（`^- 问题清单([（(][^）)]*[）)])?:`）+ r7 真实 R6 段字节形态正例 + r3 规范示意正例并存；task_plan:78/:141/:275、kb、progress:76 占位区四处同步
- I-2：VC-1 r5（fixture a：段内裸文 APPROVED→rc1）/ r6（fixture b：后随 H2 块锚定 APPROVED→rc1）；末断言 r1..r7 全链；VC-3 逐约束承重归属（边界↔b/锚定↔a/全缺↔r4）
- W-2：legacy SKIP 用例（无声明→rc0+SKIP token）；Q-1：H2 写作规范依赖三处登记+progress 占位区追加行；Q-2：rc 分层契约（缺失/不可读=rc2；存在但空=rc1；VC-3 rc2 用例=删文件）
- **判别性抽测**：自建 /tmp mock 按两约束+容忍 token 实现，复测七态（r1-r7）与 VC-1 期望一致；半加固变体（仅边界/仅锚定）分别被 r6/r5 抓住；真实生产形态（r7 形态）rc=0；对照真实 progress.md 当前末段（R7 REJECTED）→ checker 应 rc=1（fail-closed 正确——R8 APPROVED 登记前不该放行）
②**修复是否引入新缺陷**：R1-R3 逐字锚/user-session-log（mtime+sha）/审计段数=7/锚定 APPROVED=1/无新增 [plan-audit-RN] 段；Verify command 无反引号包裹、表格列解析正常；八机械门 rc=0；Handoff #17/#18 与派发算术（14+4）自洽
③历轮遗留升级必要性（R7 残留 W/Q/N 与更早留档项有无升级论据；无则维持）

## 输入材料（绝对路径，只读）

- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/{task_plan.md,verification.md,progress.md,findings.md,knowledge-brief.md}
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/subagent-state/（audit-R4/5/6/7、fix-R4/4b/5/6a/7 检查点）

可做 /tmp 沙箱模拟实测（禁写入仓库目录）。

## 裁决映射（审计体出具，主进程只登记）

`0 CRITICAL 且 0 IMPORTANT ⇒ APPROVED，否则 REJECTED`；WARNING/QUESTION/NIT 留档不阻断。

## checkpoint:（唯一允许写入点）

/mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/subagent-state/audit-R8.md — 动工前写，完成后追加裁决与发现清单。

## 输出格式（8 字段返回模板）

- status:/result:/evidence:/files_modified:/verification_results:/learnings:/next_steps:/risks:
发现清单逐条：编号+严重度+文件:行+一句描述+修复建议；末行唯一裁决行 `结论: **APPROVED**` 或 `结论: **REJECTED**`。
